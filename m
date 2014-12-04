From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC][PATCH 07/13] iov_iter.c: get rid of bvec_copy_page_{to,from}_iter()
Date: Thu,  4 Dec 2014 20:23:11 +0000
Message-ID: <1417724597-17099-7-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141204202011.GO29748@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

Just have copy_page_{to,from}_iter() fall back to kmap_atomic +
copy_{to,from}_iter() + kunmap_atomic() in ITER_BVEC case.  As
the matter of fact, that's what we want to do for any iov_iter
kind that isn't blocking - e.g. ITER_KVEC will also go that way
once we recognize it on iov_iter.c primitives level

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 mm/iov_iter.c | 60 ++++++++++++++++++++++++-----------------------------------
 1 file changed, 24 insertions(+), 36 deletions(-)

diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index 39ad713..17b7144 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -486,30 +486,33 @@ static size_t copy_from_iter_bvec(void *to, size_t bytes, struct iov_iter *i)
 	return wanted;
 }
 
-static size_t copy_page_to_iter_bvec(struct page *page, size_t offset,
-					size_t bytes, struct iov_iter *i)
+size_t copy_to_iter(void *addr, size_t bytes, struct iov_iter *i)
 {
-	void *kaddr = kmap_atomic(page);
-	size_t wanted = copy_to_iter_bvec(kaddr + offset, bytes, i);
-	kunmap_atomic(kaddr);
-	return wanted;
+	if (i->type & ITER_BVEC)
+		return copy_to_iter_bvec(addr, bytes, i);
+	else
+		return copy_to_iter_iovec(addr, bytes, i);
 }
+EXPORT_SYMBOL(copy_to_iter);
 
-static size_t copy_page_from_iter_bvec(struct page *page, size_t offset,
-					size_t bytes, struct iov_iter *i)
+size_t copy_from_iter(void *addr, size_t bytes, struct iov_iter *i)
 {
-	void *kaddr = kmap_atomic(page);
-	size_t wanted = copy_from_iter_bvec(kaddr + offset, bytes, i);
-	kunmap_atomic(kaddr);
-	return wanted;
+	if (i->type & ITER_BVEC)
+		return copy_from_iter_bvec(addr, bytes, i);
+	else
+		return copy_from_iter_iovec(addr, bytes, i);
 }
+EXPORT_SYMBOL(copy_from_iter);
 
 size_t copy_page_to_iter(struct page *page, size_t offset, size_t bytes,
 			 struct iov_iter *i)
 {
-	if (i->type & ITER_BVEC)
-		return copy_page_to_iter_bvec(page, offset, bytes, i);
-	else
+	if (i->type & (ITER_BVEC|ITER_KVEC)) {
+		void *kaddr = kmap_atomic(page);
+		size_t wanted = copy_to_iter(kaddr + offset, bytes, i);
+		kunmap_atomic(kaddr);
+		return wanted;
+	} else
 		return copy_page_to_iter_iovec(page, offset, bytes, i);
 }
 EXPORT_SYMBOL(copy_page_to_iter);
@@ -517,31 +520,16 @@ EXPORT_SYMBOL(copy_page_to_iter);
 size_t copy_page_from_iter(struct page *page, size_t offset, size_t bytes,
 			 struct iov_iter *i)
 {
-	if (i->type & ITER_BVEC)
-		return copy_page_from_iter_bvec(page, offset, bytes, i);
-	else
+	if (i->type & ITER_BVEC) {
+		void *kaddr = kmap_atomic(page);
+		size_t wanted = copy_from_iter(kaddr + offset, bytes, i);
+		kunmap_atomic(kaddr);
+		return wanted;
+	} else
 		return copy_page_from_iter_iovec(page, offset, bytes, i);
 }
 EXPORT_SYMBOL(copy_page_from_iter);
 
-size_t copy_to_iter(void *addr, size_t bytes, struct iov_iter *i)
-{
-	if (i->type & ITER_BVEC)
-		return copy_to_iter_bvec(addr, bytes, i);
-	else
-		return copy_to_iter_iovec(addr, bytes, i);
-}
-EXPORT_SYMBOL(copy_to_iter);
-
-size_t copy_from_iter(void *addr, size_t bytes, struct iov_iter *i)
-{
-	if (i->type & ITER_BVEC)
-		return copy_from_iter_bvec(addr, bytes, i);
-	else
-		return copy_from_iter_iovec(addr, bytes, i);
-}
-EXPORT_SYMBOL(copy_from_iter);
-
 size_t iov_iter_zero(size_t bytes, struct iov_iter *i)
 {
 	if (unlikely(bytes > i->count))
-- 
2.1.3
