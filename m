From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 06/25] iov_iter.c: convert iov_iter_zero() to iterate_and_advance
Date: Tue,  9 Dec 2014 22:50:19 +0000
Message-ID: <1418165438-2205-6-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141209224928.GL22149@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141209224928.GL22149@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 mm/iov_iter.c | 98 ++++++++---------------------------------------------------
 1 file changed, 12 insertions(+), 86 deletions(-)

diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index 3214b9b..39ad713 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -349,50 +349,6 @@ done:
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
 /*
  * Fault in the first iovec of the given iov_iter, to a maximum length
  * of bytes. Returns 0 on success, or non-zero if the memory could not be
@@ -548,43 +504,6 @@ static size_t copy_page_from_iter_bvec(struct page *page, size_t offset,
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
 size_t copy_page_to_iter(struct page *page, size_t offset, size_t bytes,
 			 struct iov_iter *i)
 {
@@ -625,11 +544,18 @@ EXPORT_SYMBOL(copy_from_iter);
 
 size_t iov_iter_zero(size_t bytes, struct iov_iter *i)
 {
-	if (i->type & ITER_BVEC) {
-		return zero_bvec(bytes, i);
-	} else {
-		return zero_iovec(bytes, i);
-	}
+	if (unlikely(bytes > i->count))
+		bytes = i->count;
+
+	if (unlikely(!bytes))
+		return 0;
+
+	iterate_and_advance(i, bytes, v,
+		__clear_user(v.iov_base, v.iov_len),
+		memzero_page(v.bv_page, v.bv_offset, v.bv_len)
+	)
+
+	return bytes;
 }
 EXPORT_SYMBOL(iov_iter_zero);
 
-- 
2.1.3
