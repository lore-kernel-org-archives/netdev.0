From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC][PATCH 01/13] iov_iter.c: macros for iterating over iov_iter
Date: Thu,  4 Dec 2014 20:23:05 +0000
Message-ID: <1417724597-17099-1-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141204202011.GO29748@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

iterate_all_kinds(iter, size, ident, step_iovec, step_bvec)
iterates through the ranges covered by iter (up to size bytes total),
repeating step_iovec or step_bvec for each of those.  ident is
declared in expansion of that thing, either as struct iovec or
struct bvec, and it contains the range we are currently looking
at.  step_bvec should be a void expression, step_iovec - a size_t
one, with non-zero meaning "stop here, that many bytes from this
range left".  In the end, the amount actually handled is stored
in size.

iov_iter_copy_from_user_atomic() and iov_iter_alignment() converted
to it.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 mm/iov_iter.c | 212 ++++++++++++++++++++++++----------------------------------
 1 file changed, 86 insertions(+), 126 deletions(-)

diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index e34a3cb..798fcb4 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -4,6 +4,72 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 
+#define iterate_iovec(i, n, __v, __p, skip, STEP) {	\
+	size_t left;					\
+	size_t wanted = n;				\
+	__p = i->iov;					\
+	__v.iov_len = min(n, __p->iov_len - skip);	\
+	if (likely(__v.iov_len)) {			\
+		__v.iov_base = __p->iov_base + skip;	\
+		left = (STEP);				\
+		__v.iov_len -= left;			\
+		skip += __v.iov_len;			\
+		n -= __v.iov_len;			\
+	} else {					\
+		left = 0;				\
+	}						\
+	while (unlikely(!left && n)) {			\
+		__p++;					\
+		__v.iov_len = min(n, __p->iov_len);	\
+		if (unlikely(!__v.iov_len))		\
+			continue;			\
+		__v.iov_base = __p->iov_base;		\
+		left = (STEP);				\
+		__v.iov_len -= left;			\
+		skip = __v.iov_len;			\
+		n -= __v.iov_len;			\
+	}						\
+	n = wanted - n;					\
+}
+
+#define iterate_bvec(i, n, __v, __p, skip, STEP) {	\
+	size_t wanted = n;				\
+	__p = i->bvec;					\
+	__v.bv_len = min_t(size_t, n, __p->bv_len - skip);	\
+	if (likely(__v.bv_len)) {			\
+		__v.bv_page = __p->bv_page;		\
+		__v.bv_offset = __p->bv_offset + skip; 	\
+		(void)(STEP);				\
+		skip += __v.bv_len;			\
+		n -= __v.bv_len;			\
+	}						\
+	while (unlikely(n)) {				\
+		__p++;					\
+		__v.bv_len = min_t(size_t, n, __p->bv_len);	\
+		if (unlikely(!__v.bv_len))		\
+			continue;			\
+		__v.bv_page = __p->bv_page;		\
+		__v.bv_offset = __p->bv_offset;		\
+		(void)(STEP);				\
+		skip = __v.bv_len;			\
+		n -= __v.bv_len;			\
+	}						\
+	n = wanted;					\
+}
+
+#define iterate_all_kinds(i, n, v, I, B) {			\
+	size_t skip = i->iov_offset;				\
+	if (unlikely(i->type & ITER_BVEC)) {			\
+		const struct bio_vec *bvec;			\
+		struct bio_vec v;				\
+		iterate_bvec(i, n, v, bvec, skip, (B))		\
+	} else {						\
+		const struct iovec *iov;			\
+		struct iovec v;					\
+		iterate_iovec(i, n, v, iov, skip, (I))		\
+	}							\
+}
+
 static size_t copy_to_iter_iovec(void *from, size_t bytes, struct iov_iter *i)
 {
 	size_t skip, copy, left, wanted;
@@ -300,54 +366,6 @@ static size_t zero_iovec(size_t bytes, struct iov_iter *i)
 	return wanted - bytes;
 }
 
-static size_t __iovec_copy_from_user_inatomic(char *vaddr,
-			const struct iovec *iov, size_t base, size_t bytes)
-{
-	size_t copied = 0, left = 0;
-
-	while (bytes) {
-		char __user *buf = iov->iov_base + base;
-		int copy = min(bytes, iov->iov_len - base);
-
-		base = 0;
-		left = __copy_from_user_inatomic(vaddr, buf, copy);
-		copied += copy;
-		bytes -= copy;
-		vaddr += copy;
-		iov++;
-
-		if (unlikely(left))
-			break;
-	}
-	return copied - left;
-}
-
-/*
- * Copy as much as we can into the page and return the number of bytes which
- * were successfully copied.  If a fault is encountered then return the number of
- * bytes which were copied.
- */
-static size_t copy_from_user_atomic_iovec(struct page *page,
-		struct iov_iter *i, unsigned long offset, size_t bytes)
-{
-	char *kaddr;
-	size_t copied;
-
-	kaddr = kmap_atomic(page);
-	if (likely(i->nr_segs == 1)) {
-		int left;
-		char __user *buf = i->iov->iov_base + i->iov_offset;
-		left = __copy_from_user_inatomic(kaddr + offset, buf, bytes);
-		copied = bytes - left;
-	} else {
-		copied = __iovec_copy_from_user_inatomic(kaddr + offset,
-						i->iov, i->iov_offset, bytes);
-	}
-	kunmap_atomic(kaddr);
-
-	return copied;
-}
-
 static void advance_iovec(struct iov_iter *i, size_t bytes)
 {
 	BUG_ON(i->count < bytes);
@@ -404,30 +422,6 @@ int iov_iter_fault_in_readable(struct iov_iter *i, size_t bytes)
 }
 EXPORT_SYMBOL(iov_iter_fault_in_readable);
 
-static unsigned long alignment_iovec(const struct iov_iter *i)
-{
-	const struct iovec *iov = i->iov;
-	unsigned long res;
-	size_t size = i->count;
-	size_t n;
-
-	if (!size)
-		return 0;
-
-	res = (unsigned long)iov->iov_base + i->iov_offset;
-	n = iov->iov_len - i->iov_offset;
-	if (n >= size)
-		return res | size;
-	size -= n;
-	res |= n;
-	while (size > (++iov)->iov_len) {
-		res |= (unsigned long)iov->iov_base | iov->iov_len;
-		size -= iov->iov_len;
-	}
-	res |= (unsigned long)iov->iov_base | size;
-	return res;
-}
-
 void iov_iter_init(struct iov_iter *i, int direction,
 			const struct iovec *iov, unsigned long nr_segs,
 			size_t count)
@@ -691,28 +685,6 @@ static size_t zero_bvec(size_t bytes, struct iov_iter *i)
 	return wanted - bytes;
 }
 
-static size_t copy_from_user_bvec(struct page *page,
-		struct iov_iter *i, unsigned long offset, size_t bytes)
-{
-	char *kaddr;
-	size_t left;
-	const struct bio_vec *bvec;
-	size_t base = i->iov_offset;
-
-	kaddr = kmap_atomic(page);
-	for (left = bytes, bvec = i->bvec; left; bvec++, base = 0) {
-		size_t copy = min(left, bvec->bv_len - base);
-		if (!bvec->bv_len)
-			continue;
-		memcpy_from_page(kaddr + offset, bvec->bv_page,
-				 bvec->bv_offset + base, copy);
-		offset += copy;
-		left -= copy;
-	}
-	kunmap_atomic(kaddr);
-	return bytes;
-}
-
 static void advance_bvec(struct iov_iter *i, size_t bytes)
 {
 	BUG_ON(i->count < bytes);
@@ -749,30 +721,6 @@ static void advance_bvec(struct iov_iter *i, size_t bytes)
 	}
 }
 
-static unsigned long alignment_bvec(const struct iov_iter *i)
-{
-	const struct bio_vec *bvec = i->bvec;
-	unsigned long res;
-	size_t size = i->count;
-	size_t n;
-
-	if (!size)
-		return 0;
-
-	res = bvec->bv_offset + i->iov_offset;
-	n = bvec->bv_len - i->iov_offset;
-	if (n >= size)
-		return res | size;
-	size -= n;
-	res |= n;
-	while (size > (++bvec)->bv_len) {
-		res |= bvec->bv_offset | bvec->bv_len;
-		size -= bvec->bv_len;
-	}
-	res |= bvec->bv_offset | size;
-	return res;
-}
-
 static ssize_t get_pages_bvec(struct iov_iter *i,
 		   struct page **pages, size_t maxsize, unsigned maxpages,
 		   size_t *start)
@@ -887,10 +835,15 @@ EXPORT_SYMBOL(iov_iter_zero);
 size_t iov_iter_copy_from_user_atomic(struct page *page,
 		struct iov_iter *i, unsigned long offset, size_t bytes)
 {
-	if (i->type & ITER_BVEC)
-		return copy_from_user_bvec(page, i, offset, bytes);
-	else
-		return copy_from_user_atomic_iovec(page, i, offset, bytes);
+	char *kaddr = kmap_atomic(page), *p = kaddr + offset;
+	iterate_all_kinds(i, bytes, v,
+		__copy_from_user_inatomic((p += v.iov_len) - v.iov_len,
+					  v.iov_base, v.iov_len),
+		memcpy_from_page((p += v.bv_len) - v.bv_len, v.bv_page,
+				 v.bv_offset, v.bv_len)
+	)
+	kunmap_atomic(kaddr);
+	return bytes;
 }
 EXPORT_SYMBOL(iov_iter_copy_from_user_atomic);
 
@@ -919,10 +872,17 @@ EXPORT_SYMBOL(iov_iter_single_seg_count);
 
 unsigned long iov_iter_alignment(const struct iov_iter *i)
 {
-	if (i->type & ITER_BVEC)
-		return alignment_bvec(i);
-	else
-		return alignment_iovec(i);
+	unsigned long res = 0;
+	size_t size = i->count;
+
+	if (!size)
+		return 0;
+
+	iterate_all_kinds(i, size, v,
+		(res |= (unsigned long)v.iov_base | v.iov_len, 0),
+		res |= v.bv_offset | v.bv_len
+	)
+	return res;
 }
 EXPORT_SYMBOL(iov_iter_alignment);
 
-- 
2.1.3
