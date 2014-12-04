From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC][PATCH 09/13] iov_iter.c: convert copy_to_iter() to iterate_and_advance
Date: Thu,  4 Dec 2014 20:23:13 +0000
Message-ID: <1417724597-17099-9-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141204202011.GO29748@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 mm/iov_iter.c | 91 ++++++-----------------------------------------------------
 1 file changed, 9 insertions(+), 82 deletions(-)

diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index 791429d..66665449 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -97,51 +97,6 @@
 	i->iov_offset = skip;					\
 }
 
-static size_t copy_to_iter_iovec(void *from, size_t bytes, struct iov_iter *i)
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
-}
-
 static size_t copy_page_to_iter_iovec(struct page *page, size_t offset, size_t bytes,
 			 struct iov_iter *i)
 {
@@ -360,51 +315,23 @@ static void memzero_page(struct page *page, size_t offset, size_t len)
 	kunmap_atomic(addr);
 }
 
-static size_t copy_to_iter_bvec(void *from, size_t bytes, struct iov_iter *i)
+size_t copy_to_iter(void *addr, size_t bytes, struct iov_iter *i)
 {
-	size_t skip, copy, wanted;
-	const struct bio_vec *bvec;
-
+	char *from = addr;
 	if (unlikely(bytes > i->count))
 		bytes = i->count;
 
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
-}
+	iterate_and_advance(i, bytes, v,
+		__copy_to_user(v.iov_base, (from += v.iov_len) - v.iov_len,
+			       v.iov_len),
+		memcpy_to_page(v.bv_page, v.bv_offset,
+			       (from += v.bv_len) - v.bv_len, v.bv_len)
+	)
 
-size_t copy_to_iter(void *addr, size_t bytes, struct iov_iter *i)
-{
-	if (i->type & ITER_BVEC)
-		return copy_to_iter_bvec(addr, bytes, i);
-	else
-		return copy_to_iter_iovec(addr, bytes, i);
+	return bytes;
 }
 EXPORT_SYMBOL(copy_to_iter);
 
-- 
2.1.3
