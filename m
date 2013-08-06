From: Jason Wang <jasowang@redhat.com>
Subject: [net-next 1/6] net: move iov_pages() to net/core/iovec.c
Date: Tue,  6 Aug 2013 17:45:03 +0800
Message-ID: <1375782308-10565-2-git-send-email-jasowang@redhat.com>
References: <1375782308-10565-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1375782308-10565-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To let it be reused and reduce code duplication.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c  |   23 -----------------------
 drivers/net/tun.c      |   23 -----------------------
 include/linux/socket.h |    2 ++
 net/core/iovec.c       |   24 ++++++++++++++++++++++++
 4 files changed, 26 insertions(+), 46 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index a98fb0e..dfec20d 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -698,29 +698,6 @@ static int macvtap_skb_to_vnet_hdr(const struct sk_buff *skb,
 	return 0;
 }
 
-static unsigned long iov_pages(const struct iovec *iv, int offset,
-			       unsigned long nr_segs)
-{
-	unsigned long seg, base;
-	int pages = 0, len, size;
-
-	while (nr_segs && (offset >= iv->iov_len)) {
-		offset -= iv->iov_len;
-		++iv;
-		--nr_segs;
-	}
-
-	for (seg = 0; seg < nr_segs; seg++) {
-		base = (unsigned long)iv[seg].iov_base + offset;
-		len = iv[seg].iov_len - offset;
-		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
-		pages += size;
-		offset = 0;
-	}
-
-	return pages;
-}
-
 /* Get packet from user space buffer */
 static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 				const struct iovec *iv, unsigned long total_len,
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 5dce262..18527ef 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1041,29 +1041,6 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 	return 0;
 }
 
-static unsigned long iov_pages(const struct iovec *iv, int offset,
-			       unsigned long nr_segs)
-{
-	unsigned long seg, base;
-	int pages = 0, len, size;
-
-	while (nr_segs && (offset >= iv->iov_len)) {
-		offset -= iv->iov_len;
-		++iv;
-		--nr_segs;
-	}
-
-	for (seg = 0; seg < nr_segs; seg++) {
-		base = (unsigned long)iv[seg].iov_base + offset;
-		len = iv[seg].iov_len - offset;
-		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
-		pages += size;
-		offset = 0;
-	}
-
-	return pages;
-}
-
 /* Get packet from user space buffer */
 static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 			    void *msg_control, const struct iovec *iv,
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 230c04b..445ef75 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -313,6 +313,8 @@ extern int csum_partial_copy_fromiovecend(unsigned char *kdata,
 					  struct iovec *iov, 
 					  int offset, 
 					  unsigned int len, __wsum *csump);
+extern unsigned long iov_pages(const struct iovec *iov, int offset,
+			       unsigned long nr_segs);
 
 extern int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr_storage *address, int mode);
 extern int memcpy_toiovecend(const struct iovec *v, unsigned char *kdata,
diff --git a/net/core/iovec.c b/net/core/iovec.c
index de178e4..b77eeec 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -212,3 +212,27 @@ out_fault:
 	goto out;
 }
 EXPORT_SYMBOL(csum_partial_copy_fromiovecend);
+
+unsigned long iov_pages(const struct iovec *iov, int offset,
+			unsigned long nr_segs)
+{
+	unsigned long seg, base;
+	int pages = 0, len, size;
+
+	while (nr_segs && (offset >= iov->iov_len)) {
+		offset -= iov->iov_len;
+		++iov;
+		--nr_segs;
+	}
+
+	for (seg = 0; seg < nr_segs; seg++) {
+		base = (unsigned long)iov[seg].iov_base + offset;
+		len = iov[seg].iov_len - offset;
+		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
+		pages += size;
+		offset = 0;
+	}
+
+	return pages;
+}
+EXPORT_SYMBOL(iov_pages);
-- 
1.7.1
