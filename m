From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 03/25] iov_iter.c: convert iov_iter_npages() to iterate_all_kinds
Date: Tue,  9 Dec 2014 22:50:16 +0000
Message-ID: <1418165438-2205-3-git-send-email-viro@ZenIV.linux.org.uk>
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
 mm/iov_iter.c | 73 ++++++++++++++++-------------------------------------------
 1 file changed, 19 insertions(+), 54 deletions(-)

diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index e91bf0a..bc666e7 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -493,32 +493,6 @@ static ssize_t get_pages_alloc_iovec(struct iov_iter *i,
 	return (res == n ? len : res * PAGE_SIZE) - *start;
 }
 
-static int iov_iter_npages_iovec(const struct iov_iter *i, int maxpages)
-{
-	size_t offset = i->iov_offset;
-	size_t size = i->count;
-	const struct iovec *iov = i->iov;
-	int npages = 0;
-	int n;
-
-	for (n = 0; size && n < i->nr_segs; n++, iov++) {
-		unsigned long addr = (unsigned long)iov->iov_base + offset;
-		size_t len = iov->iov_len - offset;
-		offset = 0;
-		if (unlikely(!len))	/* empty segment */
-			continue;
-		if (len > size)
-			len = size;
-		npages += (addr + len + PAGE_SIZE - 1) / PAGE_SIZE
-			  - addr / PAGE_SIZE;
-		if (npages >= maxpages)	/* don't bother going further */
-			return maxpages;
-		size -= len;
-		offset = 0;
-	}
-	return min(npages, maxpages);
-}
-
 static void memcpy_from_page(char *to, struct page *page, size_t offset, size_t len)
 {
 	char *from = kmap_atomic(page);
@@ -715,30 +689,6 @@ static ssize_t get_pages_alloc_bvec(struct iov_iter *i,
 	return len;
 }
 
-static int iov_iter_npages_bvec(const struct iov_iter *i, int maxpages)
-{
-	size_t offset = i->iov_offset;
-	size_t size = i->count;
-	const struct bio_vec *bvec = i->bvec;
-	int npages = 0;
-	int n;
-
-	for (n = 0; size && n < i->nr_segs; n++, bvec++) {
-		size_t len = bvec->bv_len - offset;
-		offset = 0;
-		if (unlikely(!len))	/* empty segment */
-			continue;
-		if (len > size)
-			len = size;
-		npages++;
-		if (npages >= maxpages)	/* don't bother going further */
-			return maxpages;
-		size -= len;
-		offset = 0;
-	}
-	return min(npages, maxpages);
-}
-
 size_t copy_page_to_iter(struct page *page, size_t offset, size_t bytes,
 			 struct iov_iter *i)
 {
@@ -862,9 +812,24 @@ EXPORT_SYMBOL(iov_iter_get_pages_alloc);
 
 int iov_iter_npages(const struct iov_iter *i, int maxpages)
 {
-	if (i->type & ITER_BVEC)
-		return iov_iter_npages_bvec(i, maxpages);
-	else
-		return iov_iter_npages_iovec(i, maxpages);
+	size_t size = i->count;
+	int npages = 0;
+
+	if (!size)
+		return 0;
+
+	iterate_all_kinds(i, size, v, ({
+		unsigned long p = (unsigned long)v.iov_base;
+		npages += DIV_ROUND_UP(p + v.iov_len, PAGE_SIZE)
+			- p / PAGE_SIZE;
+		if (npages >= maxpages)
+			return maxpages;
+	0;}),({
+		npages++;
+		if (npages >= maxpages)
+			return maxpages;
+	})
+	)
+	return npages;
 }
 EXPORT_SYMBOL(iov_iter_npages);
-- 
2.1.3
