From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC][PATCH 11/13] csum_and_copy_..._iter()
Date: Thu,  4 Dec 2014 20:23:15 +0000
Message-ID: <1417724597-17099-11-git-send-email-viro@ZenIV.linux.org.uk>
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
 include/linux/uio.h |  2 ++
 mm/iov_iter.c       | 89 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 91 insertions(+)

diff --git a/include/linux/uio.h b/include/linux/uio.h
index 6e16945..28ed2d9 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -124,6 +124,8 @@ static inline void iov_iter_reexpand(struct iov_iter *i, size_t count)
 {
 	i->count = count;
 }
+size_t csum_and_copy_to_iter(void *addr, size_t bytes, __wsum *csum, struct iov_iter *i);
+size_t csum_and_copy_from_iter(void *addr, size_t bytes, __wsum *csum, struct iov_iter *i);
 
 int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len);
 int memcpy_toiovec(struct iovec *iov, unsigned char *kdata, int len);
diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index d74de6d..5a3b4a8 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -3,6 +3,7 @@
 #include <linux/pagemap.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
+#include <net/checksum.h>
 
 #define iterate_iovec(i, n, __v, __p, skip, STEP) {	\
 	size_t left;					\
@@ -605,6 +606,94 @@ ssize_t iov_iter_get_pages_alloc(struct iov_iter *i,
 }
 EXPORT_SYMBOL(iov_iter_get_pages_alloc);
 
+size_t csum_and_copy_from_iter(void *addr, size_t bytes, __wsum *csum,
+			       struct iov_iter *i)
+{
+	char *to = addr;
+	__wsum sum, next;
+	size_t off = 0;
+	if (unlikely(bytes > i->count))
+		bytes = i->count;
+
+	if (unlikely(!bytes))
+		return 0;
+
+	sum = *csum;
+	iterate_and_advance(i, bytes, v, ({
+		int err = 0;
+		next = csum_and_copy_from_user(v.iov_base, 
+					       (to += v.iov_len) - v.iov_len,
+					       v.iov_len, 0, &err);
+		if (!err) {
+			sum = csum_block_add(sum, next, off);
+			off += v.iov_len;
+		}
+		err ? v.iov_len : 0;
+	}), ({
+		char *p = kmap_atomic(v.bv_page);
+		next = csum_partial_copy_nocheck(p + v.bv_offset,
+						 (to += v.bv_len) - v.bv_len,
+						 v.bv_len, 0);
+		kunmap_atomic(p);
+		sum = csum_block_add(sum, next, off);
+		off += v.bv_len;
+	}),({
+		next = csum_partial_copy_nocheck(v.iov_base,
+						 (to += v.iov_len) - v.iov_len,
+						 v.iov_len, 0);
+		sum = csum_block_add(sum, next, off);
+		off += v.iov_len;
+	})
+	)
+	*csum = sum;
+	return bytes;
+}
+EXPORT_SYMBOL(csum_and_copy_from_iter);
+
+size_t csum_and_copy_to_iter(void *addr, size_t bytes, __wsum *csum,
+			     struct iov_iter *i)
+{
+	char *from = addr;
+	__wsum sum, next;
+	size_t off = 0;
+	if (unlikely(bytes > i->count))
+		bytes = i->count;
+
+	if (unlikely(!bytes))
+		return 0;
+
+	sum = *csum;
+	iterate_and_advance(i, bytes, v, ({
+		int err = 0;
+		next = csum_and_copy_to_user((from += v.iov_len) - v.iov_len,
+					     v.iov_base, 
+					     v.iov_len, 0, &err);
+		if (!err) {
+			sum = csum_block_add(sum, next, off);
+			off += v.iov_len;
+		}
+		err ? v.iov_len : 0;
+	}), ({
+		char *p = kmap_atomic(v.bv_page);
+		next = csum_partial_copy_nocheck((from += v.bv_len) - v.bv_len,
+						 p + v.bv_offset,
+						 v.bv_len, 0);
+		kunmap_atomic(p);
+		sum = csum_block_add(sum, next, off);
+		off += v.bv_len;
+	}),({
+		next = csum_partial_copy_nocheck((from += v.iov_len) - v.iov_len,
+						 v.iov_base,
+						 v.iov_len, 0);
+		sum = csum_block_add(sum, next, off);
+		off += v.iov_len;
+	})
+	)
+	*csum = sum;
+	return bytes;
+}
+EXPORT_SYMBOL(csum_and_copy_to_iter);
+
 int iov_iter_npages(const struct iov_iter *i, int maxpages)
 {
 	size_t size = i->count;
-- 
2.1.3
