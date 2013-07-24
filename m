From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/3] tuntap: allow overriding ethtool driver info
Date: Wed, 24 Jul 2013 16:13:25 -0700
Message-ID: <20130724161325.38404ed3@nehalam.linuxnetplumber.net>
References: <20130724161156.4a8cf02b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Helmut Grohne <h.grohne@cygnusnetworks.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:48948 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753740Ab3GXXP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 19:15:28 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so10266458pbb.36
        for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 16:15:28 -0700 (PDT)
In-Reply-To: <20130724161156.4a8cf02b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds new ioctl to allow setting the ethtool information
returned by the TUN device. This is useful when using tun device as a surrogate
for hardware or other software emulation.

If the application does not override the ethtool settings, the
original hard coded values are used.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 drivers/net/tun.c           |   56 +++++++++++++++++++++++++++++++++-----------
 include/uapi/linux/if_tun.h |   15 +++++++++++
 2 files changed, 58 insertions(+), 13 deletions(-)

--- a/drivers/net/tun.c	2013-07-24 11:33:06.759433743 -0700
+++ b/drivers/net/tun.c	2013-07-24 11:39:56.233298852 -0700
@@ -189,6 +189,7 @@ struct tun_struct {
 	u32 flow_count;
 	u32 speed;
 	u8 duplex;
+	struct tun_info info;
 };
 
 static inline u32 tun_hashfn(u32 rxhash)
@@ -872,9 +873,13 @@ static void tun_net_init(struct net_devi
 {
 	struct tun_struct *tun = netdev_priv(dev);
 
+	strlcpy(tun->info.driver, DRV_NAME, sizeof(tun->info.driver));
+	strlcpy(tun->info.version, DRV_VERSION, sizeof(tun->info.version));
+
 	switch (tun->flags & TUN_TYPE_MASK) {
 	case TUN_TUN_DEV:
 		dev->netdev_ops = &tun_netdev_ops;
+		strlcpy(tun->info.bus, "tun", sizeof(tun->info.bus));
 
 		/* Point-to-Point TUN Device */
 		dev->hard_header_len = 0;
@@ -889,6 +894,8 @@ static void tun_net_init(struct net_devi
 
 	case TUN_TAP_DEV:
 		dev->netdev_ops = &tap_netdev_ops;
+		strlcpy(tun->info.bus, "tap", sizeof(tun->info.bus));
+
 		/* Ethernet TAP Device */
 		ether_setup(dev);
 		dev->priv_flags &= ~IFF_TX_SKB_SHARING;
@@ -2092,6 +2099,15 @@ static long __tun_chr_ioctl(struct file
 		tun_detach_filter(tun, tun->numqueues);
 		break;
 
+	case TUNSETINFO: {
+		struct tun_info info;
+
+		if (copy_from_user(&info, argp, sizeof(info)))
+			return -EFAULT;
+
+		tun->info = info;
+		break;
+	}
 	default:
 		ret = -EINVAL;
 		break;
@@ -2120,6 +2136,7 @@ static long tun_chr_compat_ioctl(struct
 	case TUNSETTXFILTER:
 	case TUNGETSNDBUF:
 	case TUNSETSNDBUF:
+	case TUNSETINFO:
 	case SIOCGIFHWADDR:
 	case SIOCSIFHWADDR:
 		arg = (unsigned long)compat_ptr(arg);
@@ -2267,17 +2284,9 @@ static void tun_get_drvinfo(struct net_d
 {
 	struct tun_struct *tun = netdev_priv(dev);
 
-	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
-	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
-
-	switch (tun->flags & TUN_TYPE_MASK) {
-	case TUN_TUN_DEV:
-		strlcpy(info->bus_info, "tun", sizeof(info->bus_info));
-		break;
-	case TUN_TAP_DEV:
-		strlcpy(info->bus_info, "tap", sizeof(info->bus_info));
-		break;
-	}
+	strlcpy(info->driver, tun->info.driver, sizeof(info->driver));
+	strlcpy(info->version, tun->info.version, sizeof(info->version));
+	strlcpy(info->bus_info, tun->info.bus, sizeof(info->bus_info));
 }
 
 static u32 tun_get_msglevel(struct net_device *dev)
--- a/include/uapi/linux/if_tun.h	2013-07-24 11:24:55.543040360 -0700
+++ b/include/uapi/linux/if_tun.h	2013-07-24 11:35:54.620898504 -0700
@@ -56,6 +56,7 @@
 #define TUNGETVNETHDRSZ _IOR('T', 215, int)
 #define TUNSETVNETHDRSZ _IOW('T', 216, int)
 #define TUNSETQUEUE  _IOW('T', 217, int)
+#define TUNSETINFO     _IOW('T', 219, struct tun_info)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
@@ -103,4 +104,11 @@ struct tun_filter {
 	__u8   addr[0][ETH_ALEN];
 };
 
+/* Subset of ethtool_info */
+struct tun_info {
+	char driver[32];
+	char bus[32];
+	char version[32];
+};
+
 #endif /* _UAPI__IF_TUN_H */
