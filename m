From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 04/25] iov_iter.c: convert iov_iter_get_pages() to iterate_all_kinds
Date: Tue,  9 Dec 2014 22:50:17 +0000
Message-ID: <1418165438-2205-4-git-send-email-viro@ZenIV.linux.org.uk>
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
 mm/iov_iter.c | 78 +++++++++++++++++++++--------------------------------------
 1 file changed, 28 insertions(+), 50 deletions(-)

diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index bc666e7..75e29ef 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -428,34 +428,6 @@ void iov_iter_init(struct iov_iter *i, int direction,
 }
 EXPORT_SYMBOL(iov_iter_init);
 
-static ssize_t get_pages_iovec(struct iov_iter *i,
-		   struct page **pages, size_t maxsize, unsigned maxpages,
-		   size_t *start)
-{
-	size_t offset = i->iov_offset;
-	const struct iovec *iov = i->iov;
-	size_t len;
-	unsigned long addr;
-	int n;
-	int res;
-
-	len = iov->iov_len - offset;
-	if (len > i->count)
-		len = i->count;
-	if (len > maxsize)
-		len = maxsize;
-	addr = (unsigned long)iov->iov_base + offset;
-	len += *start = addr & (PAGE_SIZE - 1);
-	if (len > maxpages * PAGE_SIZE)
-		len = maxpages * PAGE_SIZE;
-	addr &= ~(PAGE_SIZE - 1);
-	n = (len + PAGE_SIZE - 1) / PAGE_SIZE;
-	res = get_user_pages_fast(addr, n, (i->type & WRITE) != WRITE, pages);
-	if (unlikely(res < 0))
-		return res;
-	return (res == n ? len : res * PAGE_SIZE) - *start;
-}
-
 static ssize_t get_pages_alloc_iovec(struct iov_iter *i,
 		   struct page ***pages, size_t maxsize,
 		   size_t *start)
@@ -650,24 +622,6 @@ static size_t zero_bvec(size_t bytes, struct iov_iter *i)
 	return wanted - bytes;
 }
 
-static ssize_t get_pages_bvec(struct iov_iter *i,
-		   struct page **pages, size_t maxsize, unsigned maxpages,
-		   size_t *start)
-{
-	const struct bio_vec *bvec = i->bvec;
-	size_t len = bvec->bv_len - i->iov_offset;
-	if (len > i->count)
-		len = i->count;
-	if (len > maxsize)
-		len = maxsize;
-	/* can't be more than PAGE_SIZE */
-	*start = bvec->bv_offset + i->iov_offset;
-
-	get_page(*pages = bvec->bv_page);
-
-	return len;
-}
-
 static ssize_t get_pages_alloc_bvec(struct iov_iter *i,
 		   struct page ***pages, size_t maxsize,
 		   size_t *start)
@@ -792,10 +746,34 @@ ssize_t iov_iter_get_pages(struct iov_iter *i,
 		   struct page **pages, size_t maxsize, unsigned maxpages,
 		   size_t *start)
 {
-	if (i->type & ITER_BVEC)
-		return get_pages_bvec(i, pages, maxsize, maxpages, start);
-	else
-		return get_pages_iovec(i, pages, maxsize, maxpages, start);
+	if (maxsize > i->count)
+		maxsize = i->count;
+
+	if (!maxsize)
+		return 0;
+
+	iterate_all_kinds(i, maxsize, v, ({
+		unsigned long addr = (unsigned long)v.iov_base;
+		size_t len = v.iov_len + (*start = addr & (PAGE_SIZE - 1));
+		int n;
+		int res;
+
+		if (len > maxpages * PAGE_SIZE)
+			len = maxpages * PAGE_SIZE;
+		addr &= ~(PAGE_SIZE - 1);
+		n = DIV_ROUND_UP(len, PAGE_SIZE);
+		res = get_user_pages_fast(addr, n, (i->type & WRITE) != WRITE, pages);
+		if (unlikely(res < 0))
+			return res;
+		return (res == n ? len : res * PAGE_SIZE) - *start;
+	0;}),({
+		/* can't be more than PAGE_SIZE */
+		*start = v.bv_offset;
+		get_page(*pages = v.bv_page);
+		return v.bv_len;
+	})
+	)
+	return 0;
 }
 EXPORT_SYMBOL(iov_iter_get_pages);
 
-- 
2.1.3
