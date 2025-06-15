#!/bin/bash

# Script để tự động gộp (squash) N commit cuối cùng thành một.
# Commit message của commit gần nhất sẽ được sử dụng cho commit đã gộp.
# Cách dùng: ./git-squash-auto.sh <số-commit>

# --- Kiểm tra đầu vào ---
if [ -z "$1" ]; then
  echo "Lỗi: Vui lòng cung cấp số commit cần squash."
  echo "Cách dùng: $0 <số-commit>"
  exit 1
fi

if ! [[ "$1" =~ ^[0-9]+$ ]]; then
  echo "Lỗi: Đối số phải là một số nguyên dương."
  exit 1
fi

NUM_COMMITS=$1
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# --- Kiểm tra số lượng commit có đủ không ---
TOTAL_COMMITS=$(git rev-list --count HEAD)
if [ "$TOTAL_COMMITS" -le "$NUM_COMMITS" ]; then
    echo "Lỗi: Không đủ số lượng commit để squash."
    echo "Nhánh '$CURRENT_BRANCH' chỉ có $TOTAL_COMMITS commit."
    exit 1
fi


# --- Cảnh báo an toàn ---
echo "Bạn đang ở trên nhánh: $CURRENT_BRANCH"
if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" || "$CURRENT_BRANCH" == "develop" ]]; then
  read -p "CẢNH BÁO: Bạn đang cố gắng squash trên một nhánh chung ($CURRENT_BRANCH). Điều này rất nguy hiểm. Bạn có chắc chắn muốn tiếp tục không? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Hành động đã được hủy."
    exit 1
  fi
fi

read -p "Bạn có chắc chắn muốn SQUASH $NUM_COMMITS commit cuối cùng trên nhánh '$CURRENT_BRANCH' không? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Hành động đã được hủy."
  exit 1
fi

# --- Bắt đầu quá trình tự động ---

# 1. Lấy commit message của commit gần nhất (HEAD)
echo "Đang lấy commit message từ commit gần nhất..."
LATEST_COMMIT_MESSAGE=$(git log -1 --pretty=%B)

# 2. Reset soft về N commit trước, giữ lại các thay đổi trong a Staging Area
echo "Đang reset về HEAD~$NUM_COMMITS..."
git reset --soft HEAD~"$NUM_COMMITS"

# 3. Commit lại với message đã lấy ở bước 1
echo "Đang tạo commit mới đã được gộp..."
git commit -m "$LATEST_COMMIT_MESSAGE"

# --- Hướng dẫn tiếp theo ---
echo ""
echo "✅ Hoàn tất! $NUM_COMMITS commit cuối cùng đã được gộp thành công thành một."
echo "Hãy kiểm tra lại lịch sử commit bằng 'git log'."
echo "Sau khi xác nhận mọi thứ đã đúng, hãy push bằng lệnh:"
echo "git push --force-with-lease"
