From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 06/17] saner iov_iter initialization primitives
Date: Sat, 11 Apr 2015 22:18:17 +0100
Message-ID: <1428787108-13650-6-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37868 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932410AbbDKVSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 17:18:30 -0400
In-Reply-To: <20150411211742.GJ889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

iovec-backed iov_iter instances are assumed to satisfy several properties:
	* no more than UIO_MAXIOV elements in iovec array
	* total size of all ranges is no more than MAX_RW_COUNT
	* all ranges pass access_ok().

The problem is, invariants of data structures should be established in the
primitives creating those data structures, not in the code using those
primitives.  And iov_iter_init() violates that principle.  For a while we
managed to get away with that, but once the use of iov_iter started to
spread, it didn't take long for shit to hit the fan - missed check in
sys_sendto() had introduced a roothole.

We _do_ have primitives for importing and validating iovecs (both native and
compat ones) and those primitives are almost always followed by shoving the
resulting iovec into iov_iter.  Life would be considerably simpler (and safer)
if we combined those primitives with initializing iov_iter.

That gives us two new primitives - import_iovec() and compat_import_iovec().
Calling conventions:
	iovec = iov_array;
	err = import_iovec(direction, uvec, nr_segs,
			   ARRAY_SIZE(iov_array), &iovec,
			   &iter);
imports user vector into kernel space (into iov_array if it fits, allocated
if it doesn't fit or if iovec was NULL), validates it and sets iter up to
refer to it.  On success 0 is returned and allocated kernel copy (or NULL
if the array had fit into caller-supplied one) is returned via iovec.
On failure all allocations are undone and -E... is returned.  If the total
size of ranges exceeds MAX_RW_COUNT, the excess is silently truncated.

compat_import_iovec() expects uvec to be a pointer to user array of compat_iovec;
otherwise it's identical to import_iovec().

Finally, import_single_range() sets iov_iter backed by single-element iovec
covering a user-supplied range -

	err = import_single_range(direction, address, size, iovec, &iter);

does validation and sets iter up.  Again, size in excess of MAX_RW_COUNT gets
silently truncated.

Next commits will be switching the things up to use of those and reducing
the amount of iov_iter_init() instances.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/uio.h | 14 +++++++++++++
 lib/iov_iter.c      | 57 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 71 insertions(+)

diff --git a/include/linux/uio.h b/include/linux/uio.h
index 7188029..1f4a37f 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -139,4 +139,18 @@ static inline void iov_iter_reexpand(struct iov_iter *i, size_t count)
 size_t csum_and_copy_to_iter(void *addr, size_t bytes, __wsum *csum, struct iov_iter *i);
 size_t csum_and_copy_from_iter(void *addr, size_t bytes, __wsum *csum, struct iov_iter *i);
 
+int import_iovec(int type, const struct iovec __user * uvector,
+		 unsigned nr_segs, unsigned fast_segs,
+		 struct iovec **iov, struct iov_iter *i);
+
+#ifdef CONFIG_COMPAT
+struct compat_iovec;
+int compat_import_iovec(int type, const struct compat_iovec __user * uvector,
+		 unsigned nr_segs, unsigned fast_segs,
+		 struct iovec **iov, struct iov_iter *i);
+#endif
+
+int import_single_range(int type, void __user *buf, size_t len,
+		 struct iovec *iov, struct iov_iter *i);
+
 #endif
diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index 9d96e283..fc6e33f 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -766,3 +766,60 @@ const void *dup_iter(struct iov_iter *new, struct iov_iter *old, gfp_t flags)
 				   flags);
 }
 EXPORT_SYMBOL(dup_iter);
+
+int import_iovec(int type, const struct iovec __user * uvector,
+		 unsigned nr_segs, unsigned fast_segs,
+		 struct iovec **iov, struct iov_iter *i)
+{
+	ssize_t n;
+	struct iovec *p;
+	n = rw_copy_check_uvector(type, uvector, nr_segs, fast_segs,
+				  *iov, &p);
+	if (n < 0) {
+		if (p != *iov)
+			kfree(p);
+		*iov = NULL;
+		return n;
+	}
+	iov_iter_init(i, type, p, nr_segs, n);
+	*iov = p == *iov ? NULL : p;
+	return 0;
+}
+EXPORT_SYMBOL(import_iovec);
+
+#ifdef CONFIG_COMPAT
+#include <linux/compat.h>
+
+int compat_import_iovec(int type, const struct compat_iovec __user * uvector,
+		 unsigned nr_segs, unsigned fast_segs,
+		 struct iovec **iov, struct iov_iter *i)
+{
+	ssize_t n;
+	struct iovec *p;
+	n = compat_rw_copy_check_uvector(type, uvector, nr_segs, fast_segs,
+				  *iov, &p);
+	if (n < 0) {
+		if (p != *iov)
+			kfree(p);
+		*iov = NULL;
+		return n;
+	}
+	iov_iter_init(i, type, p, nr_segs, n);
+	*iov = p == *iov ? NULL : p;
+	return 0;
+}
+#endif
+
+int import_single_range(int rw, void __user *buf, size_t len,
+		 struct iovec *iov, struct iov_iter *i)
+{
+	if (len > MAX_RW_COUNT)
+		len = MAX_RW_COUNT;
+	if (unlikely(!access_ok(!rw, buf, len)))
+		return -EFAULT;
+
+	iov->iov_base = buf;
+	iov->iov_len = len;
+	iov_iter_init(i, rw, iov, 1, len);
+	return 0;
+}
-- 
2.1.4
