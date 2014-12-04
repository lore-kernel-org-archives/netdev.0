From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC][PATCH 02/13] iov_iter.c: iterate_and_advance
Date: Thu,  4 Dec 2014 20:23:06 +0000
Message-ID: <1417724597-17099-2-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141204202011.GO29748@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

same as iterate_all_kinds, but iterator is moved to the position past
the last byte we'd handled.

iov_iter_advance() converted to it

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 mm/iov_iter.c | 104 ++++++++++++++++------------------------------------------
 1 file changed, 28 insertions(+), 76 deletions(-)

diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index 798fcb4..e91bf0a 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -70,6 +70,33 @@
 	}							\
 }
 
+#define iterate_and_advance(i, n, v, I, B) {			\
+	size_t skip = i->iov_offset;				\
+	if (unlikely(i->type & ITER_BVEC)) {			\
+		const struct bio_vec *bvec;			\
+		struct bio_vec v;				\
+		iterate_bvec(i, n, v, bvec, skip, (B))		\
+		if (skip == bvec->bv_len) {			\
+			bvec++;					\
+			skip = 0;				\
+		}						\
+		i->nr_segs -= bvec - i->bvec;			\
+		i->bvec = bvec;					\
+	} else {						\
+		const struct iovec *iov;			\
+		struct iovec v;					\
+		iterate_iovec(i, n, v, iov, skip, (I))		\
+		if (skip == iov->iov_len) {			\
+			iov++;					\
+			skip = 0;				\
+		}						\
+		i->nr_segs -= iov - i->iov;			\
+		i->iov = iov;					\
+	}							\
+	i->count -= n;						\
+	i->iov_offset = skip;					\
+}
+
 static size_t copy_to_iter_iovec(void *from, size_t bytes, struct iov_iter *i)
 {
 	size_t skip, copy, left, wanted;
@@ -366,42 +393,6 @@ static size_t zero_iovec(size_t bytes, struct iov_iter *i)
 	return wanted - bytes;
 }
 
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
@@ -685,42 +676,6 @@ static size_t zero_bvec(size_t bytes, struct iov_iter *i)
 	return wanted - bytes;
 }
 
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
 static ssize_t get_pages_bvec(struct iov_iter *i,
 		   struct page **pages, size_t maxsize, unsigned maxpages,
 		   size_t *start)
@@ -849,10 +804,7 @@ EXPORT_SYMBOL(iov_iter_copy_from_user_atomic);
 
 void iov_iter_advance(struct iov_iter *i, size_t size)
 {
-	if (i->type & ITER_BVEC)
-		advance_bvec(i, size);
-	else
-		advance_iovec(i, size);
+	iterate_and_advance(i, size, v, 0, 0)
 }
 EXPORT_SYMBOL(iov_iter_advance);
 
-- 
2.1.3
