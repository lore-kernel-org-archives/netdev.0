From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 08/25] iov_iter.c: convert copy_from_iter() to iterate_and_advance
Date: Tue,  9 Dec 2014 22:50:21 +0000
Message-ID: <1418165438-2205-8-git-send-email-viro@ZenIV.linux.org.uk>
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
 mm/iov_iter.c | 106 +++++++++-------------------------------------------------
 1 file changed, 15 insertions(+), 91 deletions(-)

diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index 17b7144..791429d 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -142,51 +142,6 @@ static size_t copy_to_iter_iovec(void *from, size_t bytes, struct iov_iter *i)
 	return wanted - bytes;
 }
 
-static size_t copy_from_iter_iovec(void *to, size_t bytes, struct iov_iter *i)
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
-}
-
 static size_t copy_page_to_iter_iovec(struct page *page, size_t offset, size_t bytes,
 			 struct iov_iter *i)
 {
@@ -444,48 +399,6 @@ static size_t copy_to_iter_bvec(void *from, size_t bytes, struct iov_iter *i)
 	return wanted - bytes;
 }
 
-static size_t copy_from_iter_bvec(void *to, size_t bytes, struct iov_iter *i)
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
-}
-
 size_t copy_to_iter(void *addr, size_t bytes, struct iov_iter *i)
 {
 	if (i->type & ITER_BVEC)
@@ -497,10 +410,21 @@ EXPORT_SYMBOL(copy_to_iter);
 
 size_t copy_from_iter(void *addr, size_t bytes, struct iov_iter *i)
 {
-	if (i->type & ITER_BVEC)
-		return copy_from_iter_bvec(addr, bytes, i);
-	else
-		return copy_from_iter_iovec(addr, bytes, i);
+	char *to = addr;
+	if (unlikely(bytes > i->count))
+		bytes = i->count;
+
+	if (unlikely(!bytes))
+		return 0;
+
+	iterate_and_advance(i, bytes, v,
+		__copy_from_user((to += v.iov_len) - v.iov_len, v.iov_base,
+				 v.iov_len),
+		memcpy_from_page((to += v.bv_len) - v.bv_len, v.bv_page,
+				 v.bv_offset, v.bv_len)
+	)
+
+	return bytes;
 }
 EXPORT_SYMBOL(copy_from_iter);
 
-- 
2.1.3
