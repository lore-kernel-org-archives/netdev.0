From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] iovec: move memcpy_from/toiovecend to lib/iovec.c
Date: Thu, 19 Jun 2014 21:22:56 +0300
Message-ID: <1403201568-22828-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <rdunlap@infradead.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	stephen hemminger <stephen@networkplumber.org>,
	Sean Hefty <sean.hefty@intel.com>,
	FX Le Bail <fx.lebail@yahoo.com>,
	Jason Wang <jasowang@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ERROR: "memcpy_fromiovecend" [drivers/vhost/vhost_scsi.ko] undefined!

commit 9f977ef7b671f6169eca78bf40f230fe84b7c7e5
    vhost-scsi: Include prot_bytes into expected data transfer length
in target-pending makes drivers/vhost/scsi.c call memcpy_fromiovecend().
This function is not available when CONFIG_NET is not enabled.

socket.h already includes uio.h, so no callers need updating.

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

David, could you please ack merging this through
target-pending to avoid dependency issues?

Thanks!

 include/linux/socket.h |  4 ----
 include/linux/uio.h    |  4 ++++
 lib/iovec.c            | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++
 net/core/iovec.c       | 55 --------------------------------------------------
 4 files changed, 59 insertions(+), 59 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 8e98297..ec538fc 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -305,8 +305,6 @@ struct ucred {
 /* IPX options */
 #define IPX_TYPE	1
 
-extern int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
-			       int offset, int len);
 extern int csum_partial_copy_fromiovecend(unsigned char *kdata, 
 					  struct iovec *iov, 
 					  int offset, 
@@ -315,8 +313,6 @@ extern unsigned long iov_pages(const struct iovec *iov, int offset,
 			       unsigned long nr_segs);
 
 extern int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr_storage *address, int mode);
-extern int memcpy_toiovecend(const struct iovec *v, unsigned char *kdata,
-			     int offset, int len);
 extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr_storage *kaddr);
 extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
 
diff --git a/include/linux/uio.h b/include/linux/uio.h
index 199bcc3..8a4709a 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -89,5 +89,9 @@ static inline size_t iov_iter_count(struct iov_iter *i)
 
 int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len);
 int memcpy_toiovec(struct iovec *iov, unsigned char *kdata, int len);
+int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
+			int offset, int len);
+int memcpy_toiovecend(const struct iovec *v, unsigned char *kdata,
+		      int offset, int len);
 
 #endif
diff --git a/lib/iovec.c b/lib/iovec.c
index 454baa8..7a7c2da 100644
--- a/lib/iovec.c
+++ b/lib/iovec.c
@@ -51,3 +51,58 @@ int memcpy_toiovec(struct iovec *iov, unsigned char *kdata, int len)
 	return 0;
 }
 EXPORT_SYMBOL(memcpy_toiovec);
+
+/*
+ *	Copy kernel to iovec. Returns -EFAULT on error.
+ */
+
+int memcpy_toiovecend(const struct iovec *iov, unsigned char *kdata,
+		      int offset, int len)
+{
+	int copy;
+	for (; len > 0; ++iov) {
+		/* Skip over the finished iovecs */
+		if (unlikely(offset >= iov->iov_len)) {
+			offset -= iov->iov_len;
+			continue;
+		}
+		copy = min_t(unsigned int, iov->iov_len - offset, len);
+		if (copy_to_user(iov->iov_base + offset, kdata, copy))
+			return -EFAULT;
+		offset = 0;
+		kdata += copy;
+		len -= copy;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(memcpy_toiovecend);
+
+/*
+ *	Copy iovec to kernel. Returns -EFAULT on error.
+ */
+
+int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
+			int offset, int len)
+{
+	/* Skip over the finished iovecs */
+	while (offset >= iov->iov_len) {
+		offset -= iov->iov_len;
+		iov++;
+	}
+
+	while (len > 0) {
+		u8 __user *base = iov->iov_base + offset;
+		int copy = min_t(unsigned int, len, iov->iov_len - offset);
+
+		offset = 0;
+		if (copy_from_user(kdata, base, copy))
+			return -EFAULT;
+		len -= copy;
+		kdata += copy;
+		iov++;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(memcpy_fromiovecend);
diff --git a/net/core/iovec.c b/net/core/iovec.c
index b618694..827dd6b 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -75,61 +75,6 @@ int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr_storage *a
 }
 
 /*
- *	Copy kernel to iovec. Returns -EFAULT on error.
- */
-
-int memcpy_toiovecend(const struct iovec *iov, unsigned char *kdata,
-		      int offset, int len)
-{
-	int copy;
-	for (; len > 0; ++iov) {
-		/* Skip over the finished iovecs */
-		if (unlikely(offset >= iov->iov_len)) {
-			offset -= iov->iov_len;
-			continue;
-		}
-		copy = min_t(unsigned int, iov->iov_len - offset, len);
-		if (copy_to_user(iov->iov_base + offset, kdata, copy))
-			return -EFAULT;
-		offset = 0;
-		kdata += copy;
-		len -= copy;
-	}
-
-	return 0;
-}
-EXPORT_SYMBOL(memcpy_toiovecend);
-
-/*
- *	Copy iovec to kernel. Returns -EFAULT on error.
- */
-
-int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
-			int offset, int len)
-{
-	/* Skip over the finished iovecs */
-	while (offset >= iov->iov_len) {
-		offset -= iov->iov_len;
-		iov++;
-	}
-
-	while (len > 0) {
-		u8 __user *base = iov->iov_base + offset;
-		int copy = min_t(unsigned int, len, iov->iov_len - offset);
-
-		offset = 0;
-		if (copy_from_user(kdata, base, copy))
-			return -EFAULT;
-		len -= copy;
-		kdata += copy;
-		iov++;
-	}
-
-	return 0;
-}
-EXPORT_SYMBOL(memcpy_fromiovecend);
-
-/*
  *	And now for the all-in-one: copy and checksum from a user iovec
  *	directly to a datagram
  *	Calls to csum_partial but the last must be in 32 bit chunks
-- 
MST
