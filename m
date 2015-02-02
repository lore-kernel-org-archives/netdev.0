From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v2 15/18] vhost: switch vhost get_indirect() to iov_iter, kill memcpy_fromiovec()
Date: Mon,  2 Feb 2015 07:59:34 +0000
Message-ID: <1422863977-17668-15-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	kvm@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:32986 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932857AbbBBH7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 02:59:40 -0500
In-Reply-To: <20150131035513.GK29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: kvm@vger.kernel.org
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/vhost/vhost.c |  6 ++++--
 include/linux/uio.h   |  1 -
 lib/iovec.c           | 25 -------------------------
 3 files changed, 4 insertions(+), 28 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index cb807d0..2ee2826 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1125,6 +1125,7 @@ static int get_indirect(struct vhost_virtqueue *vq,
 	struct vring_desc desc;
 	unsigned int i = 0, count, found = 0;
 	u32 len = vhost32_to_cpu(vq, indirect->len);
+	struct iov_iter from;
 	int ret;
 
 	/* Sanity check */
@@ -1142,6 +1143,7 @@ static int get_indirect(struct vhost_virtqueue *vq,
 		vq_err(vq, "Translation failure %d in indirect.\n", ret);
 		return ret;
 	}
+	iov_iter_init(&from, READ, vq->indirect, ret, len);
 
 	/* We will use the result as an address to read from, so most
 	 * architectures only need a compiler barrier here. */
@@ -1164,8 +1166,8 @@ static int get_indirect(struct vhost_virtqueue *vq,
 			       i, count);
 			return -EINVAL;
 		}
-		if (unlikely(memcpy_fromiovec((unsigned char *)&desc,
-					      vq->indirect, sizeof desc))) {
+		if (unlikely(copy_from_iter(&desc, sizeof(desc), &from) !=
+			     sizeof(desc))) {
 			vq_err(vq, "Failed indirect descriptor: idx %d, %zx\n",
 			       i, (size_t)vhost64_to_cpu(vq, indirect->addr) + i * sizeof desc);
 			return -EINVAL;
diff --git a/include/linux/uio.h b/include/linux/uio.h
index 1c5e453..af3439f 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -135,7 +135,6 @@ static inline void iov_iter_reexpand(struct iov_iter *i, size_t count)
 size_t csum_and_copy_to_iter(void *addr, size_t bytes, __wsum *csum, struct iov_iter *i);
 size_t csum_and_copy_from_iter(void *addr, size_t bytes, __wsum *csum, struct iov_iter *i);
 
-int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len);
 int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
 			int offset, int len);
 int memcpy_toiovecend(const struct iovec *v, unsigned char *kdata,
diff --git a/lib/iovec.c b/lib/iovec.c
index 2d99cb4..4a90875 100644
--- a/lib/iovec.c
+++ b/lib/iovec.c
@@ -3,31 +3,6 @@
 #include <linux/uio.h>
 
 /*
- *	Copy iovec to kernel. Returns -EFAULT on error.
- *
- *	Note: this modifies the original iovec.
- */
-
-int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len)
-{
-	while (len > 0) {
-		if (iov->iov_len) {
-			int copy = min_t(unsigned int, len, iov->iov_len);
-			if (copy_from_user(kdata, iov->iov_base, copy))
-				return -EFAULT;
-			len -= copy;
-			kdata += copy;
-			iov->iov_base += copy;
-			iov->iov_len -= copy;
-		}
-		iov++;
-	}
-
-	return 0;
-}
-EXPORT_SYMBOL(memcpy_fromiovec);
-
-/*
  *	Copy kernel to iovec. Returns -EFAULT on error.
  */
 
-- 
2.1.4
