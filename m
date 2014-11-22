From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] situation with csum_and_copy_... API
Date: Sat, 22 Nov 2014 03:27:18 +0000
Message-ID: <20141122032718.GA24457@ZenIV.linux.org.uk>
References: <CA+55aFyQR2gOzEDROcWFcQzLvTjOxyJRjFJXJ03JB5knd-Gsgg@mail.gmail.com>
 <20141119.161744.1661940121298888832.davem@davemloft.net>
 <20141119213006.GE7996@ZenIV.linux.org.uk>
 <20141119.165340.2162829993279387495.davem@davemloft.net>
 <20141120214753.GR7996@ZenIV.linux.org.uk>
 <1416520542.8629.46.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141120222506.GS7996@ZenIV.linux.org.uk>
 <1416524035.8629.54.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141121084956.GT7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, target-devel@vger.kernel.org,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	Christoph Hellwig <hch@infradead.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141121084956.GT7996@ZenIV.linux.org.uk>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 21, 2014 at 08:49:56AM +0000, Al Viro wrote:

> Overall, I think I have the whole series plotted in enough details to be
> reasonably certain we can pull it off.  Right now I'm dealing with
> mm/iov_iter.c stuff; the amount of boilerplate source is already high enough
> and with those extra primitives it'll get really unpleasant.
> 
> What we need there is something templates-like, as much as I hate C++, and
> I'm still not happy with what I have at the moment...  Hopefully I'll get
> that in more or less tolerable form today.

Folks, I would really like comments on the patch below.  It's an attempt
to reduce the amount of boilerplate code in mm/iov_iter.c; no new primitives
added, just trying to reduce the amount of duplication in there.  I'm not
too fond of the way it currently looks, to put it mildly.  It seems to
work, it's reasonably straightforward and it even generates slightly better
code than before, but I would _very_ welcome any tricks that would allow to
make it not so tasteless.  I like the effect on line count (+124-358), but...

It defines two iterators (for iovec-backed and bvec-backed ones) and converts
a bunch of primitives to those.  The last argument is an expression evaluated
for a bunch of ranges; for bvec one it's void, for iovec - size_t; if it
evaluates to non-0, we treat it as read/write/whatever short by that many
bytes and do not proceed any further.

Any suggestions are welcome.

diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index eafcf60..611af2bd 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -4,11 +4,75 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 
+#define iterate_iovec(i, n, buf, len, move, STEP) {	\
+	const struct iovec *iov = i->iov;		\
+	size_t skip = i->iov_offset;			\
+	size_t left;					\
+	size_t wanted = n;				\
+	buf = iov->iov_base + skip;			\
+	len = min(n, iov->iov_len - skip);		\
+	left = STEP;					\
+	len -= left;					\
+	skip += len;					\
+	n -= len;					\
+	while (unlikely(!left && n)) {			\
+		iov++;					\
+		buf = iov->iov_base;			\
+		len = min(n, iov->iov_len);		\
+		left = STEP;				\
+		len -= left;				\
+		skip = len;				\
+		n -= len;				\
+	}						\
+	n = wanted - n;					\
+	if (move) {					\
+		if (skip == iov->iov_len) {		\
+			iov++;				\
+			skip = 0;			\
+		}					\
+		i->count -= n;				\
+		i->nr_segs -= iov - i->iov;		\
+		i->iov = iov;				\
+		i->iov_offset = skip;			\
+	}						\
+}
+
+#define iterate_bvec(i, n, page, off, len, move, STEP) {\
+	const struct bio_vec *bvec = i->bvec;		\
+	size_t skip = i->iov_offset;			\
+	size_t wanted = n;				\
+	page = bvec->bv_page;				\
+	off = bvec->bv_offset + skip;	 		\
+	len = min_t(size_t, n, bvec->bv_len - skip);	\
+	STEP;						\
+	skip += len;					\
+	n -= len;					\
+	while (unlikely(n)) {				\
+		bvec++;					\
+		page = bvec->bv_page;			\
+		off = bvec->bv_offset;			\
+		len = min_t(size_t, n, bvec->bv_len);	\
+		STEP;					\
+		skip = len;				\
+		n -= len;				\
+	}						\
+	n = wanted;					\
+	if (move) {					\
+		if (skip == bvec->bv_len) {		\
+			bvec++;				\
+			skip = 0;			\
+		}					\
+		i->count -= n;				\
+		i->nr_segs -= bvec - i->bvec;		\
+		i->bvec = bvec;				\
+		i->iov_offset = skip;			\
+	}						\
+}
+
 static size_t copy_to_iter_iovec(void *from, size_t bytes, struct iov_iter *i)
 {
-	size_t skip, copy, left, wanted;
-	const struct iovec *iov;
 	char __user *buf;
+	size_t len;
 
 	if (unlikely(bytes > i->count))
 		bytes = i->count;
@@ -16,44 +80,15 @@ static size_t copy_to_iter_iovec(void *from, size_t bytes, struct iov_iter *i)
 	if (unlikely(!bytes))
 		return 0;
 
-	wanted = bytes;
-	iov = i->iov;
-	skip = i->iov_offset;
-	buf = iov->iov_base + skip;
-	copy = min(bytes, iov->iov_len - skip);
-
-	left = __copy_to_user(buf, from, copy);
-	copy -= left;
-	skip += copy;
-	from += copy;
-	bytes -= copy;
-	while (unlikely(!left && bytes)) {
-		iov++;
-		buf = iov->iov_base;
-		copy = min(bytes, iov->iov_len);
-		left = __copy_to_user(buf, from, copy);
-		copy -= left;
-		skip = copy;
-		from += copy;
-		bytes -= copy;
-	}
-
-	if (skip == iov->iov_len) {
-		iov++;
-		skip = 0;
-	}
-	i->count -= wanted - bytes;
-	i->nr_segs -= iov - i->iov;
-	i->iov = iov;
-	i->iov_offset = skip;
-	return wanted - bytes;
+	iterate_iovec(i, bytes, buf, len, true,
+			__copy_to_user(buf, (from += len) - len, len))
+	return bytes;
 }
 
 static size_t copy_from_iter_iovec(void *to, size_t bytes, struct iov_iter *i)
 {
-	size_t skip, copy, left, wanted;
-	const struct iovec *iov;
 	char __user *buf;
+	size_t len;
 
 	if (unlikely(bytes > i->count))
 		bytes = i->count;
@@ -61,37 +96,9 @@ static size_t copy_from_iter_iovec(void *to, size_t bytes, struct iov_iter *i)
 	if (unlikely(!bytes))
 		return 0;
 
-	wanted = bytes;
-	iov = i->iov;
-	skip = i->iov_offset;
-	buf = iov->iov_base + skip;
-	copy = min(bytes, iov->iov_len - skip);
-
-	left = __copy_from_user(to, buf, copy);
-	copy -= left;
-	skip += copy;
-	to += copy;
-	bytes -= copy;
-	while (unlikely(!left && bytes)) {
-		iov++;
-		buf = iov->iov_base;
-		copy = min(bytes, iov->iov_len);
-		left = __copy_from_user(to, buf, copy);
-		copy -= left;
-		skip = copy;
-		to += copy;
-		bytes -= copy;
-	}
-
-	if (skip == iov->iov_len) {
-		iov++;
-		skip = 0;
-	}
-	i->count -= wanted - bytes;
-	i->nr_segs -= iov - i->iov;
-	i->iov = iov;
-	i->iov_offset = skip;
-	return wanted - bytes;
+	iterate_iovec(i, bytes, buf, len, true,
+			__copy_from_user((to += len) - len, buf, len))
+	return bytes;
 }
 
 static size_t copy_page_to_iter_iovec(struct page *page, size_t offset, size_t bytes,
@@ -256,134 +263,6 @@ done:
 	return wanted - bytes;
 }
 
-static size_t zero_iovec(size_t bytes, struct iov_iter *i)
-{
-	size_t skip, copy, left, wanted;
-	const struct iovec *iov;
-	char __user *buf;
-
-	if (unlikely(bytes > i->count))
-		bytes = i->count;
-
-	if (unlikely(!bytes))
-		return 0;
-
-	wanted = bytes;
-	iov = i->iov;
-	skip = i->iov_offset;
-	buf = iov->iov_base + skip;
-	copy = min(bytes, iov->iov_len - skip);
-
-	left = __clear_user(buf, copy);
-	copy -= left;
-	skip += copy;
-	bytes -= copy;
-
-	while (unlikely(!left && bytes)) {
-		iov++;
-		buf = iov->iov_base;
-		copy = min(bytes, iov->iov_len);
-		left = __clear_user(buf, copy);
-		copy -= left;
-		skip = copy;
-		bytes -= copy;
-	}
-
-	if (skip == iov->iov_len) {
-		iov++;
-		skip = 0;
-	}
-	i->count -= wanted - bytes;
-	i->nr_segs -= iov - i->iov;
-	i->iov = iov;
-	i->iov_offset = skip;
-	return wanted - bytes;
-}
-
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
-static void advance_iovec(struct iov_iter *i, size_t bytes)
-{
-	BUG_ON(i->count < bytes);
-
-	if (likely(i->nr_segs == 1)) {
-		i->iov_offset += bytes;
-		i->count -= bytes;
-	} else {
-		const struct iovec *iov = i->iov;
-		size_t base = i->iov_offset;
-		unsigned long nr_segs = i->nr_segs;
-
-		/*
-		 * The !iov->iov_len check ensures we skip over unlikely
-		 * zero-length segments (without overruning the iovec).
-		 */
-		while (bytes || unlikely(i->count && !iov->iov_len)) {
-			int copy;
-
-			copy = min(bytes, iov->iov_len - base);
-			BUG_ON(!i->count || i->count < copy);
-			i->count -= copy;
-			bytes -= copy;
-			base += copy;
-			if (iov->iov_len == base) {
-				iov++;
-				nr_segs--;
-				base = 0;
-			}
-		}
-		i->iov = iov;
-		i->iov_offset = base;
-		i->nr_segs = nr_segs;
-	}
-}
-
 /*
  * Fault in the first iovec of the given iov_iter, to a maximum length
  * of bytes. Returns 0 on success, or non-zero if the memory could not be
@@ -557,8 +436,8 @@ static void memzero_page(struct page *page, size_t offset, size_t len)
 
 static size_t copy_to_iter_bvec(void *from, size_t bytes, struct iov_iter *i)
 {
-	size_t skip, copy, wanted;
-	const struct bio_vec *bvec;
+	struct page *page;
+	size_t off, len;
 
 	if (unlikely(bytes > i->count))
 		bytes = i->count;
@@ -566,38 +445,15 @@ static size_t copy_to_iter_bvec(void *from, size_t bytes, struct iov_iter *i)
 	if (unlikely(!bytes))
 		return 0;
 
-	wanted = bytes;
-	bvec = i->bvec;
-	skip = i->iov_offset;
-	copy = min_t(size_t, bytes, bvec->bv_len - skip);
-
-	memcpy_to_page(bvec->bv_page, skip + bvec->bv_offset, from, copy);
-	skip += copy;
-	from += copy;
-	bytes -= copy;
-	while (bytes) {
-		bvec++;
-		copy = min(bytes, (size_t)bvec->bv_len);
-		memcpy_to_page(bvec->bv_page, bvec->bv_offset, from, copy);
-		skip = copy;
-		from += copy;
-		bytes -= copy;
-	}
-	if (skip == bvec->bv_len) {
-		bvec++;
-		skip = 0;
-	}
-	i->count -= wanted - bytes;
-	i->nr_segs -= bvec - i->bvec;
-	i->bvec = bvec;
-	i->iov_offset = skip;
-	return wanted - bytes;
+	iterate_bvec(i, bytes, page, off, len, true,
+		     memcpy_from_page((from += len) - len, page, off, len))
+	return bytes;
 }
 
 static size_t copy_from_iter_bvec(void *to, size_t bytes, struct iov_iter *i)
 {
-	size_t skip, copy, wanted;
-	const struct bio_vec *bvec;
+	struct page *page;
+	size_t off, len;
 
 	if (unlikely(bytes > i->count))
 		bytes = i->count;
@@ -605,35 +461,9 @@ static size_t copy_from_iter_bvec(void *to, size_t bytes, struct iov_iter *i)
 	if (unlikely(!bytes))
 		return 0;
 
-	wanted = bytes;
-	bvec = i->bvec;
-	skip = i->iov_offset;
-
-	copy = min(bytes, bvec->bv_len - skip);
-
-	memcpy_from_page(to, bvec->bv_page, bvec->bv_offset + skip, copy);
-
-	to += copy;
-	skip += copy;
-	bytes -= copy;
-
-	while (bytes) {
-		bvec++;
-		copy = min(bytes, (size_t)bvec->bv_len);
-		memcpy_from_page(to, bvec->bv_page, bvec->bv_offset, copy);
-		skip = copy;
-		to += copy;
-		bytes -= copy;
-	}
-	if (skip == bvec->bv_len) {
-		bvec++;
-		skip = 0;
-	}
-	i->count -= wanted;
-	i->nr_segs -= bvec - i->bvec;
-	i->bvec = bvec;
-	i->iov_offset = skip;
-	return wanted;
+	iterate_bvec(i, bytes, page, off, len, true,
+		     memcpy_to_page(page, off, (to += len) - len, len))
+	return bytes;
 }
 
 static size_t copy_page_to_iter_bvec(struct page *page, size_t offset,
@@ -654,101 +484,6 @@ static size_t copy_page_from_iter_bvec(struct page *page, size_t offset,
 	return wanted;
 }
 
-static size_t zero_bvec(size_t bytes, struct iov_iter *i)
-{
-	size_t skip, copy, wanted;
-	const struct bio_vec *bvec;
-
-	if (unlikely(bytes > i->count))
-		bytes = i->count;
-
-	if (unlikely(!bytes))
-		return 0;
-
-	wanted = bytes;
-	bvec = i->bvec;
-	skip = i->iov_offset;
-	copy = min_t(size_t, bytes, bvec->bv_len - skip);
-
-	memzero_page(bvec->bv_page, skip + bvec->bv_offset, copy);
-	skip += copy;
-	bytes -= copy;
-	while (bytes) {
-		bvec++;
-		copy = min(bytes, (size_t)bvec->bv_len);
-		memzero_page(bvec->bv_page, bvec->bv_offset, copy);
-		skip = copy;
-		bytes -= copy;
-	}
-	if (skip == bvec->bv_len) {
-		bvec++;
-		skip = 0;
-	}
-	i->count -= wanted - bytes;
-	i->nr_segs -= bvec - i->bvec;
-	i->bvec = bvec;
-	i->iov_offset = skip;
-	return wanted - bytes;
-}
-
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
-static void advance_bvec(struct iov_iter *i, size_t bytes)
-{
-	BUG_ON(i->count < bytes);
-
-	if (likely(i->nr_segs == 1)) {
-		i->iov_offset += bytes;
-		i->count -= bytes;
-	} else {
-		const struct bio_vec *bvec = i->bvec;
-		size_t base = i->iov_offset;
-		unsigned long nr_segs = i->nr_segs;
-
-		/*
-		 * The !iov->iov_len check ensures we skip over unlikely
-		 * zero-length segments (without overruning the iovec).
-		 */
-		while (bytes || unlikely(i->count && !bvec->bv_len)) {
-			int copy;
-
-			copy = min(bytes, bvec->bv_len - base);
-			BUG_ON(!i->count || i->count < copy);
-			i->count -= copy;
-			bytes -= copy;
-			base += copy;
-			if (bvec->bv_len == base) {
-				bvec++;
-				nr_segs--;
-				base = 0;
-			}
-		}
-		i->bvec = bvec;
-		i->iov_offset = base;
-		i->nr_segs = nr_segs;
-	}
-}
-
 static unsigned long alignment_bvec(const struct iov_iter *i)
 {
 	const struct bio_vec *bvec = i->bvec;
@@ -876,30 +611,61 @@ EXPORT_SYMBOL(copy_from_iter);
 
 size_t iov_iter_zero(size_t bytes, struct iov_iter *i)
 {
+	if (unlikely(bytes > i->count))
+		bytes = i->count;
+
+	if (unlikely(!bytes))
+		return 0;
+
 	if (i->type & ITER_BVEC) {
-		return zero_bvec(bytes, i);
+		struct page *page;
+		size_t off, len;
+		iterate_bvec(i, bytes, page, off, len, true,
+				memzero_page(page, off, len))
 	} else {
-		return zero_iovec(bytes, i);
+		char __user *buf;
+		size_t len;
+		iterate_iovec(i, bytes, buf, len, true,
+				__clear_user(buf, len))
 	}
+	return bytes;
 }
 EXPORT_SYMBOL(iov_iter_zero);
 
 size_t iov_iter_copy_from_user_atomic(struct page *page,
 		struct iov_iter *i, unsigned long offset, size_t bytes)
 {
-	if (i->type & ITER_BVEC)
-		return copy_from_user_bvec(page, i, offset, bytes);
-	else
-		return copy_from_user_atomic_iovec(page, i, offset, bytes);
+	char *kaddr = kmap_atomic(page), *p = kaddr + offset;
+	if (i->type & ITER_BVEC) {
+		struct page *page;
+		size_t off, len;
+		iterate_bvec(i, bytes, page, off, len, false,
+			     memcpy_from_page((p += len) - len, page, off, len))
+	} else {
+		char __user *buf;
+		size_t len;
+		iterate_iovec(i, bytes, buf, len, false,
+			      __copy_from_user_inatomic((p += len) - len,
+							buf, len))
+	}
+	kunmap_atomic(kaddr);
+	return bytes;
 }
 EXPORT_SYMBOL(iov_iter_copy_from_user_atomic);
 
 void iov_iter_advance(struct iov_iter *i, size_t size)
 {
-	if (i->type & ITER_BVEC)
-		advance_bvec(i, size);
-	else
-		advance_iovec(i, size);
+	if (i->type & ITER_BVEC) {
+		struct page *page;
+		size_t off, len;
+		iterate_bvec(i, size, page, off, len, true,
+				(void)0)
+	} else {
+		char __user *buf;
+		size_t len;
+		iterate_iovec(i, size, buf, len, true,
+				0)
+	}
 }
 EXPORT_SYMBOL(iov_iter_advance);
 
