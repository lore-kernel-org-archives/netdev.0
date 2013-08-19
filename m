From: Valas Valancius <vytautas.valancius@gmail.com>
Subject: [PATCH] Passing sk_buff metadata information to user space in TUNTAP driver.
Date: Mon, 19 Aug 2013 13:29:37 -0700
Message-ID: <1376944177-20031-1-git-send-email-vytautas.valancius@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	netdev@vger.kernel.org
To: Valas Valancius <valas@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:39343 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121Ab3HSUag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 16:30:36 -0400
Received: by mail-pa0-f53.google.com with SMTP id lb1so2629428pab.26
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 13:30:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Valas Valancius <valas@google.com>

This patch introduces an optional metadata header to TUNTAP driver to pass
sk_buff information to user space. The patch currently enables passing
of skb->mark field and allows for easy expansion to add more sk_buff
fields later.

Tested: Compiled, booted. Process 1: openend TAP interface, enabled metadata
header on that interface. Process 2: opened a socket, set fwmark with SO_MARK
sock option, send packets, observed mark to propagate in Process 1.

Change-Id: I5d00522e9c4d9c1b57b4f4ac55c419a85de35dae
---
 drivers/net/tun.c           | 64 ++++++++++++++++++++++++++++++++++++++++++++-
 include/uapi/linux/if_tun.h |  7 +++++
 2 files changed, 70 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 978d865..f997d59 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -103,6 +103,15 @@ do {								\
 
 #define GOODCOPY_LEN 128
 
+/* Metadata header structure. */
+struct tun_meta_header {
+	/* struct sk_buff.mark */
+	int mark;
+};
+
+#define TUN_META_HDR_SZ sizeof(struct tun_meta_header)
+#define TUN_META_MARK_OFFSET offsetof(struct tun_meta_header, mark)
+
 #define FLT_EXACT_COUNT 8
 struct tap_filter {
 	unsigned int    count;    /* Number of addrs. Zero means disabled */
@@ -1227,6 +1236,20 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 		total += tun->vnet_hdr_sz;
 	}
 
+	if (tun->flags & TUN_META_HDR) {
+		struct tun_meta_header meta = { 0 };
+		len -= TUN_META_HDR_SZ;
+		if (len < 0)
+			return -EINVAL;
+
+		meta.mark = skb->mark;
+
+		if (unlikely(memcpy_toiovecend(iv, (void *)&meta, total,
+					       sizeof(meta))))
+			return -EFAULT;
+		total += TUN_META_HDR_SZ;
+	}
+
 	if (!vlan_tx_tag_present(skb)) {
 		len = min_t(int, skb->len, len);
 	} else {
@@ -1487,6 +1510,9 @@ static int tun_flags(struct tun_struct *tun)
 	if (tun->flags & TUN_PERSIST)
 		flags |= IFF_PERSIST;
 
+	if (tun->flags & TUN_META_HDR)
+		flags |= IFF_META_HDR;
+
 	return flags;
 }
 
@@ -1666,6 +1692,11 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	else
 		tun->flags &= ~TUN_TAP_MQ;
 
+	if (ifr->ifr_flags & IFF_META_HDR)
+		tun->flags |= TUN_META_HDR;
+	else
+		tun->flags &= ~TUN_META_HDR;
+
 	/* Make sure persistent devices do not get stuck in
 	 * xoff state.
 	 */
@@ -1815,6 +1846,8 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	kgid_t group;
 	int sndbuf;
 	int vnet_hdr_sz;
+	int tun_meta_param;
+	int tun_meta_value;
 	int ret;
 
 	if (cmd == TUNSETIFF || cmd == TUNSETQUEUE || _IOC_TYPE(cmd) == 0x89) {
@@ -1828,7 +1861,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		 * This is needed because we never checked for invalid flags on
 		 * TUNSETIFF. */
 		return put_user(IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE |
-				IFF_VNET_HDR | IFF_MULTI_QUEUE,
+				IFF_VNET_HDR | IFF_MULTI_QUEUE | IFF_META_HDR,
 				(unsigned int __user*)argp);
 	} else if (cmd == TUNSETQUEUE)
 		return tun_set_queue(file, &ifr);
@@ -1996,6 +2029,35 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		tun->vnet_hdr_sz = vnet_hdr_sz;
 		break;
 
+	case TUNGETMETAPARAM:
+		if (copy_from_user(&tun_meta_param, argp,
+				   sizeof(tun_meta_param))) {
+			ret = -EFAULT;
+			break;
+		}
+
+		ret = 0;
+		switch (tun_meta_param) {
+		case TUN_GET_META_HDR_SZ:
+			tun_meta_value = TUN_META_HDR_SZ;
+			break;
+
+		case TUN_GET_META_MARK_OFFSET:
+			tun_meta_value = TUN_META_MARK_OFFSET;
+			break;
+
+		default:
+			ret = -EINVAL;
+			break;
+		}
+
+		if (!ret)
+			if (copy_to_user(argp, &tun_meta_value,
+					 sizeof(tun_meta_value)))
+				ret = -EFAULT;
+		break;
+
+
 	case TUNATTACHFILTER:
 		/* Can be set only for TAPs */
 		ret = -EINVAL;
diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
index 1870ee2..26e6c9e 100644
--- a/include/uapi/linux/if_tun.h
+++ b/include/uapi/linux/if_tun.h
@@ -36,6 +36,7 @@
 #define TUN_PERSIST 	0x0100	
 #define TUN_VNET_HDR 	0x0200
 #define TUN_TAP_MQ      0x0400
+#define TUN_META_HDR	0x0800
 
 /* Ioctl defines */
 #define TUNSETNOCSUM  _IOW('T', 200, int) 
@@ -56,10 +57,12 @@
 #define TUNGETVNETHDRSZ _IOR('T', 215, int)
 #define TUNSETVNETHDRSZ _IOW('T', 216, int)
 #define TUNSETQUEUE  _IOW('T', 217, int)
+#define TUNGETMETAPARAM _IOR('T', 218, int)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
 #define IFF_TAP		0x0002
+#define IFF_META_HDR	0x0004
 #define IFF_NO_PI	0x1000
 /* This flag has no real effect */
 #define IFF_ONE_QUEUE	0x2000
@@ -103,4 +106,8 @@ struct tun_filter {
 	__u8   addr[0][ETH_ALEN];
 };
 
+/* TUNGETMETAPARAM metadata header request types. */
+#define TUN_GET_META_HDR_SZ 0
+#define TUN_GET_META_MARK_OFFSET 1
+
 #endif /* _UAPI__IF_TUN_H */
-- 
1.8.3
