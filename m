From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tun
Date: Mon, 15 Mar 2004 10:28:10 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040315102810.2111a5d7@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vtun@office.satix.net.sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
        Maxim Krasnyansky
 <maxk@qualcomm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tun verifies the user address before doing memcpy_from/toiovec.  There are
two problems with this strategy.  First, it is possible on an SMP machine
to construct cases where a page is unmmapped between the verify and the copy,
and it is also faster to do the verification only once.

diff -Nru a/drivers/net/tun.c b/drivers/net/tun.c
--- a/drivers/net/tun.c	Mon Mar 15 10:16:30 2004
+++ b/drivers/net/tun.c	Mon Mar 15 10:16:30 2004
@@ -169,7 +169,7 @@
 	return mask;
 }
 
-/* Get packet from user space buffer(already verified) */
+/* Get packet from user space buffer */
 static __inline__ ssize_t tun_get_user(struct tun_struct *tun, struct iovec *iv, size_t count)
 {
 	struct tun_pi pi = { 0, __constant_htons(ETH_P_IP) };
@@ -180,7 +180,8 @@
 		if ((len -= sizeof(pi)) > len)
 			return -EINVAL;
 
-		memcpy_fromiovec((void *)&pi, iv, sizeof(pi));
+		if(memcpy_fromiovec((void *)&pi, iv, sizeof(pi)))
+			return -EFAULT;
 	}
  
 	if (!(skb = alloc_skb(len + 2, GFP_KERNEL))) {
@@ -189,7 +190,8 @@
 	}
 
 	skb_reserve(skb, 2);
-	memcpy_fromiovec(skb_put(skb, len), iv, len);
+	if (memcpy_fromiovec(skb_put(skb, len), iv, len))
+		return -EFAULT;
 
 	skb->dev = tun->dev;
 	switch (tun->flags & TUN_TYPE_MASK) {
@@ -213,26 +215,29 @@
 	return count;
 } 
 
+static inline size_t iov_total(const struct iovec *iv, unsigned long count)
+{
+	unsigned long i;
+	size_t len;
+
+	for (i = 0, len = 0; i < count; i++) 
+		len += iv[i].iov_len;
+
+	return len;
+}
+
 /* Writev */
 static ssize_t tun_chr_writev(struct file * file, const struct iovec *iv, 
 			      unsigned long count, loff_t *pos)
 {
 	struct tun_struct *tun = file->private_data;
-	unsigned long i;
-	size_t len;
 
 	if (!tun)
 		return -EBADFD;
 
 	DBG(KERN_INFO "%s: tun_chr_write %ld\n", tun->dev->name, count);
 
-	for (i = 0, len = 0; i < count; i++) {
-		if (verify_area(VERIFY_READ, iv[i].iov_base, iv[i].iov_len))
-			return -EFAULT;
-		len += iv[i].iov_len;
-	}
-
-	return tun_get_user(tun, (struct iovec *) iv, len);
+	return tun_get_user(tun, (struct iovec *) iv, iov_total(iv, count));
 }
 
 /* Write */
@@ -243,7 +248,7 @@
 	return tun_chr_writev(file, &iv, 1, pos);
 }
 
-/* Put packet to the user space buffer (already verified) */
+/* Put packet to the user space buffer */
 static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 				       struct sk_buff *skb,
 				       struct iovec *iv, int len)
@@ -260,7 +265,8 @@
 			pi.flags |= TUN_PKT_STRIP;
 		}
  
-		memcpy_toiovec(iv, (void *) &pi, sizeof(pi));
+		if (memcpy_toiovec(iv, (void *) &pi, sizeof(pi)))
+			return -EFAULT;
 		total += sizeof(pi);
 	}       
 
@@ -283,18 +289,13 @@
 	DECLARE_WAITQUEUE(wait, current);
 	struct sk_buff *skb;
 	ssize_t len, ret = 0;
-	unsigned long i;
 
 	if (!tun)
 		return -EBADFD;
 
 	DBG(KERN_INFO "%s: tun_chr_read\n", tun->dev->name);
 
-	for (i = 0, len = 0; i < count; i++) {
-		if (verify_area(VERIFY_WRITE, iv[i].iov_base, iv[i].iov_len))
-			return -EFAULT;
-		len += iv[i].iov_len;
-	}
+	len = iov_total(iv, count);
 	if (len < 0)
 		return -EINVAL;
 
