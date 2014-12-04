From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC][PATCH 10/13] iov_iter.c: handle ITER_KVEC directly
Date: Thu,  4 Dec 2014 20:23:14 +0000
Message-ID: <1417724597-17099-10-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141204202011.GO29748@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

... without bothering with copy_..._user()

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/uio.h |   1 +
 mm/iov_iter.c       | 101 +++++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 89 insertions(+), 13 deletions(-)

diff --git a/include/linux/uio.h b/include/linux/uio.h
index 9b15814..6e16945 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -31,6 +31,7 @@ struct iov_iter {
 	size_t count;
 	union {
 		const struct iovec *iov;
+		const struct kvec *kvec;
 		const struct bio_vec *bvec;
 	};
 	unsigned long nr_segs;
diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index 66665449..d74de6d 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -32,6 +32,29 @@
 	n = wanted - n;					\
 }
 
+#define iterate_kvec(i, n, __v, __p, skip, STEP) {	\
+	size_t wanted = n;				\
+	__p = i->kvec;					\
+	__v.iov_len = min(n, __p->iov_len - skip);	\
+	if (likely(__v.iov_len)) {			\
+		__v.iov_base = __p->iov_base + skip;	\
+		(void)(STEP);				\
+		skip += __v.iov_len;			\
+		n -= __v.iov_len;			\
+	}						\
+	while (unlikely(n)) {				\
+		__p++;					\
+		__v.iov_len = min(n, __p->iov_len);	\
+		if (unlikely(!__v.iov_len))		\
+			continue;			\
+		__v.iov_base = __p->iov_base;		\
+		(void)(STEP);				\
+		skip = __v.iov_len;			\
+		n -= __v.iov_len;			\
+	}						\
+	n = wanted;					\
+}
+
 #define iterate_bvec(i, n, __v, __p, skip, STEP) {	\
 	size_t wanted = n;				\
 	__p = i->bvec;					\
@@ -57,12 +80,16 @@
 	n = wanted;					\
 }
 
-#define iterate_all_kinds(i, n, v, I, B) {			\
+#define iterate_all_kinds(i, n, v, I, B, K) {			\
 	size_t skip = i->iov_offset;				\
 	if (unlikely(i->type & ITER_BVEC)) {			\
 		const struct bio_vec *bvec;			\
 		struct bio_vec v;				\
 		iterate_bvec(i, n, v, bvec, skip, (B))		\
+	} else if (unlikely(i->type & ITER_KVEC)) {		\
+		const struct kvec *kvec;			\
+		struct kvec v;					\
+		iterate_kvec(i, n, v, kvec, skip, (K))		\
 	} else {						\
 		const struct iovec *iov;			\
 		struct iovec v;					\
@@ -70,7 +97,7 @@
 	}							\
 }
 
-#define iterate_and_advance(i, n, v, I, B) {			\
+#define iterate_and_advance(i, n, v, I, B, K) {			\
 	size_t skip = i->iov_offset;				\
 	if (unlikely(i->type & ITER_BVEC)) {			\
 		const struct bio_vec *bvec;			\
@@ -82,6 +109,16 @@
 		}						\
 		i->nr_segs -= bvec - i->bvec;			\
 		i->bvec = bvec;					\
+	} else if (unlikely(i->type & ITER_KVEC)) {		\
+		const struct kvec *kvec;			\
+		struct kvec v;					\
+		iterate_kvec(i, n, v, kvec, skip, (K))		\
+		if (skip == kvec->iov_len) {			\
+			kvec++;					\
+			skip = 0;				\
+		}						\
+		i->nr_segs -= kvec - i->kvec;			\
+		i->kvec = kvec;					\
 	} else {						\
 		const struct iovec *iov;			\
 		struct iovec v;					\
@@ -270,7 +307,7 @@ done:
  */
 int iov_iter_fault_in_readable(struct iov_iter *i, size_t bytes)
 {
-	if (!(i->type & ITER_BVEC)) {
+	if (!(i->type & (ITER_BVEC|ITER_KVEC))) {
 		char __user *buf = i->iov->iov_base + i->iov_offset;
 		bytes = min(bytes, i->iov->iov_len - i->iov_offset);
 		return fault_in_pages_readable(buf, bytes);
@@ -284,10 +321,14 @@ void iov_iter_init(struct iov_iter *i, int direction,
 			size_t count)
 {
 	/* It will get better.  Eventually... */
-	if (segment_eq(get_fs(), KERNEL_DS))
+	if (segment_eq(get_fs(), KERNEL_DS)) {
 		direction |= ITER_KVEC;
-	i->type = direction;
-	i->iov = iov;
+		i->type = direction;
+		i->kvec = (struct kvec *)iov;
+	} else {
+		i->type = direction;
+		i->iov = iov;
+	}
 	i->nr_segs = nr_segs;
 	i->iov_offset = 0;
 	i->count = count;
@@ -328,7 +369,8 @@ size_t copy_to_iter(void *addr, size_t bytes, struct iov_iter *i)
 		__copy_to_user(v.iov_base, (from += v.iov_len) - v.iov_len,
 			       v.iov_len),
 		memcpy_to_page(v.bv_page, v.bv_offset,
-			       (from += v.bv_len) - v.bv_len, v.bv_len)
+			       (from += v.bv_len) - v.bv_len, v.bv_len),
+		memcpy(v.iov_base, (from += v.iov_len) - v.iov_len, v.iov_len)
 	)
 
 	return bytes;
@@ -348,7 +390,8 @@ size_t copy_from_iter(void *addr, size_t bytes, struct iov_iter *i)
 		__copy_from_user((to += v.iov_len) - v.iov_len, v.iov_base,
 				 v.iov_len),
 		memcpy_from_page((to += v.bv_len) - v.bv_len, v.bv_page,
-				 v.bv_offset, v.bv_len)
+				 v.bv_offset, v.bv_len),
+		memcpy((to += v.iov_len) - v.iov_len, v.iov_base, v.iov_len)
 	)
 
 	return bytes;
@@ -371,7 +414,7 @@ EXPORT_SYMBOL(copy_page_to_iter);
 size_t copy_page_from_iter(struct page *page, size_t offset, size_t bytes,
 			 struct iov_iter *i)
 {
-	if (i->type & ITER_BVEC) {
+	if (i->type & (ITER_BVEC|ITER_KVEC)) {
 		void *kaddr = kmap_atomic(page);
 		size_t wanted = copy_from_iter(kaddr + offset, bytes, i);
 		kunmap_atomic(kaddr);
@@ -391,7 +434,8 @@ size_t iov_iter_zero(size_t bytes, struct iov_iter *i)
 
 	iterate_and_advance(i, bytes, v,
 		__clear_user(v.iov_base, v.iov_len),
-		memzero_page(v.bv_page, v.bv_offset, v.bv_len)
+		memzero_page(v.bv_page, v.bv_offset, v.bv_len),
+		memset(v.iov_base, 0, v.iov_len)
 	)
 
 	return bytes;
@@ -406,7 +450,8 @@ size_t iov_iter_copy_from_user_atomic(struct page *page,
 		__copy_from_user_inatomic((p += v.iov_len) - v.iov_len,
 					  v.iov_base, v.iov_len),
 		memcpy_from_page((p += v.bv_len) - v.bv_len, v.bv_page,
-				 v.bv_offset, v.bv_len)
+				 v.bv_offset, v.bv_len),
+		memcpy((p += v.iov_len) - v.iov_len, v.iov_base, v.iov_len)
 	)
 	kunmap_atomic(kaddr);
 	return bytes;
@@ -415,7 +460,7 @@ EXPORT_SYMBOL(iov_iter_copy_from_user_atomic);
 
 void iov_iter_advance(struct iov_iter *i, size_t size)
 {
-	iterate_and_advance(i, size, v, 0, 0)
+	iterate_and_advance(i, size, v, 0, 0, 0)
 }
 EXPORT_SYMBOL(iov_iter_advance);
 
@@ -443,7 +488,8 @@ unsigned long iov_iter_alignment(const struct iov_iter *i)
 
 	iterate_all_kinds(i, size, v,
 		(res |= (unsigned long)v.iov_base | v.iov_len, 0),
-		res |= v.bv_offset | v.bv_len
+		res |= v.bv_offset | v.bv_len,
+		res |= (unsigned long)v.iov_base | v.iov_len
 	)
 	return res;
 }
@@ -478,6 +524,16 @@ ssize_t iov_iter_get_pages(struct iov_iter *i,
 		*start = v.bv_offset;
 		get_page(*pages = v.bv_page);
 		return v.bv_len;
+	}),({
+		unsigned long addr = (unsigned long)v.iov_base, end;
+		size_t len = v.iov_len + (*start = addr & (PAGE_SIZE - 1));
+
+		if (len > maxpages * PAGE_SIZE)
+			len = maxpages * PAGE_SIZE;
+		addr &= ~(PAGE_SIZE - 1);
+		for (end = addr + len; addr < end; addr += PAGE_SIZE)
+			get_page(*pages++ = virt_to_page(addr));
+		return len - *start;
 	})
 	)
 	return 0;
@@ -530,6 +586,19 @@ ssize_t iov_iter_get_pages_alloc(struct iov_iter *i,
 			return -ENOMEM;
 		get_page(*p = v.bv_page);
 		return v.bv_len;
+	}),({
+		unsigned long addr = (unsigned long)v.iov_base, end;
+		size_t len = v.iov_len + (*start = addr & (PAGE_SIZE - 1));
+		int n;
+
+		addr &= ~(PAGE_SIZE - 1);
+		n = DIV_ROUND_UP(len, PAGE_SIZE);
+		*pages = p = get_pages_array(n);
+		if (!p)
+			return -ENOMEM;
+		for (end = addr + len; addr < end; addr += PAGE_SIZE)
+			get_page(*p++ = virt_to_page(addr));
+		return len - *start;
 	})
 	)
 	return 0;
@@ -554,6 +623,12 @@ int iov_iter_npages(const struct iov_iter *i, int maxpages)
 		npages++;
 		if (npages >= maxpages)
 			return maxpages;
+	}),({
+		unsigned long p = (unsigned long)v.iov_base;
+		npages += DIV_ROUND_UP(p + v.iov_len, PAGE_SIZE)
+			- p / PAGE_SIZE;
+		if (npages >= maxpages)
+			return maxpages;
 	})
 	)
 	return npages;
-- 
2.1.3
