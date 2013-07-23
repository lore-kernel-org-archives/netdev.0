From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [RFC 1/2] tun: allow overrriding ethtool info
Date: Tue, 23 Jul 2013 10:28:15 -0700
Message-ID: <20130723102815.079bfe4a@nehalam.linuxnetplumber.net>
References: <2F174B03-5074-4BA0-B91A-8F2F62C2B082@cygnusnetworks.de>
	<5192BDD6.6060703@qti.qualcomm.com>
	<3E916AF0-C587-443D-B653-C968A96C8751@cygnusnetworks.de>
	<48A2F278-A32C-47C6-AD2D-1FC15EC73B88@cygnusnetworks.de>
	<51E5BE27.3060207@qti.qualcomm.com>
	<E4A37B97-95FE-42C3-AD78-119BA406A44A@cygnusnetworks.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Max Krasnyansky <maxk@qti.qualcomm.com>
To: Helmut Grohne <h.grohne@cygnusnetworks.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:45761 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933220Ab3GWR34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 13:29:56 -0400
Received: by mail-pd0-f176.google.com with SMTP id t12so8347085pdi.35
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 10:29:55 -0700 (PDT)
In-Reply-To: <E4A37B97-95FE-42C3-AD78-119BA406A44A@cygnusnetworks.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds new ioctl to allow overrriding the ethtool information
returned by the TUN device. This is useful when using tun device as a surrogate
for hardware or other software emulation.

If the application does not override the ethtool settings, the
original hard coded values are used.

This version is compile tested only, included to show how API works.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 drivers/net/tun.c           |   56 +++++++++++++++++++++++++++++++++-----------
 include/uapi/linux/if_tun.h |   15 +++++++++++
 2 files changed, 58 insertions(+), 13 deletions(-)

--- a/drivers/net/tun.c	2013-07-23 09:18:01.936046624 -0700
+++ b/drivers/net/tun.c	2013-07-23 09:52:37.054143993 -0700
@@ -187,6 +187,8 @@ struct tun_struct {
 	struct list_head disabled;
 	void *security;
 	u32 flow_count;
+
+	struct tun_info info;
 };
 
 static inline u32 tun_hashfn(u32 rxhash)
@@ -870,9 +872,12 @@ static void tun_net_init(struct net_devi
 {
 	struct tun_struct *tun = netdev_priv(dev);
 
+	strlcpy(tun->info.driver, DRV_NAME, sizeof(tun->info.driver));
+
 	switch (tun->flags & TUN_TYPE_MASK) {
 	case TUN_TUN_DEV:
 		dev->netdev_ops = &tun_netdev_ops;
+		strlcpy(tun->info.bus, "tun", sizeof(tun->info.bus));
 
 		/* Point-to-Point TUN Device */
 		dev->hard_header_len = 0;
@@ -887,6 +892,8 @@ static void tun_net_init(struct net_devi
 
 	case TUN_TAP_DEV:
 		dev->netdev_ops = &tap_netdev_ops;
+		strlcpy(tun->info.bus, "tap", sizeof(tun->info.bus));
+
 		/* Ethernet TAP Device */
 		ether_setup(dev);
 		dev->priv_flags &= ~IFF_TX_SKB_SHARING;
@@ -1426,6 +1433,9 @@ static void tun_setup(struct net_device
 
 	tun->owner = INVALID_UID;
 	tun->group = INVALID_GID;
+	tun->info.speed = SPEED_10;
+	tun->info.duplex = DUPLEX_FULL;
+	tun->info.port = PORT_TP;
 
 	dev->ethtool_ops = &tun_ethtool_ops;
 	dev->destructor = tun_free_netdev;
@@ -2088,6 +2098,15 @@ static long __tun_chr_ioctl(struct file
 		tun_detach_filter(tun, tun->numqueues);
 		break;
 
+	case TUNSETINFO: {
+		struct tun_info info;
+		if (copy_from_user(argp, &info, sizeof(info)))
+			ret = -EFAULT;
+
+		tun->info = info;
+		break;
+	}
+
 	default:
 		ret = -EINVAL;
 		break;
@@ -2229,11 +2248,13 @@ static struct miscdevice tun_miscdev = {
 
 static int tun_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
+	struct tun_struct *tun = netdev_priv(dev);
+
 	cmd->supported		= 0;
 	cmd->advertising	= 0;
-	ethtool_cmd_speed_set(cmd, SPEED_10);
-	cmd->duplex		= DUPLEX_FULL;
-	cmd->port		= PORT_TP;
+	ethtool_cmd_speed_set(cmd, tun->info.speed);
+	cmd->duplex		= tun->info.duplex;
+	cmd->port		= tun->info.port;
 	cmd->phy_address	= 0;
 	cmd->transceiver	= XCVR_INTERNAL;
 	cmd->autoneg		= AUTONEG_DISABLE;
@@ -2242,21 +2263,24 @@ static int tun_get_settings(struct net_d
 	return 0;
 }
 
+static int tun_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+
+	tun->info.speed  = ethtool_cmd_speed(ecmd);
+	tun->info.duplex = ecmd->duplex;
+	tun->info.port   = ecmd->port;
+
+	return 0;
+}
+
 static void tun_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct tun_struct *tun = netdev_priv(dev);
 
-	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->driver, tun->info.driver, sizeof(info->driver));
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
-
-	switch (tun->flags & TUN_TYPE_MASK) {
-	case TUN_TUN_DEV:
-		strlcpy(info->bus_info, "tun", sizeof(info->bus_info));
-		break;
-	case TUN_TAP_DEV:
-		strlcpy(info->bus_info, "tap", sizeof(info->bus_info));
-		break;
-	}
+	strlcpy(info->bus_info, tun->info.bus, sizeof(info->bus_info));
 }
 
 static u32 tun_get_msglevel(struct net_device *dev)
@@ -2279,6 +2303,7 @@ static void tun_set_msglevel(struct net_
 
 static const struct ethtool_ops tun_ethtool_ops = {
 	.get_settings	= tun_get_settings,
+	.set_settings	= tun_set_settings,
 	.get_drvinfo	= tun_get_drvinfo,
 	.get_msglevel	= tun_get_msglevel,
 	.set_msglevel	= tun_set_msglevel,
--- a/include/uapi/linux/if_tun.h	2013-07-23 09:18:01.936046624 -0700
+++ b/include/uapi/linux/if_tun.h	2013-07-23 09:52:26.870271418 -0700
@@ -56,6 +56,7 @@
 #define TUNGETVNETHDRSZ _IOR('T', 215, int)
 #define TUNSETVNETHDRSZ _IOW('T', 216, int)
 #define TUNSETQUEUE  _IOW('T', 217, int)
+#define TUNSETINFO     _IOW('T', 219, struct tun_info)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
@@ -103,4 +104,17 @@ struct tun_filter {
 	__u8   addr[0][ETH_ALEN];
 };
 
+/*
+ * Ethtool info
+ * This is used to allow spoofing the speed/duplex and driver information
+ */
+struct tun_info {
+	__u32 speed;
+	__u8  duplex;
+	__u8  port;
+
+	char driver[32];
+	char bus[32];
+};
+
 #endif /* _UAPI__IF_TUN_H */
