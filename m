From: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Subject: [PATCH 1/1] tun: change speed from 10M to dynamically configured
Date: Fri, 13 Feb 2015 14:19:13 +0800
Message-ID: <1423808353-8722-2-git-send-email-Yanjun.Zhu@windriver.com>
References: <1423808353-8722-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <mst@redhat.com>, <jasowang@redhat.com>,
	<viro@zeniv.linux.org.uk>, <davem@davemloft.net>,
	<sergei.shtylyov@cogentembedded.com>, <jonathon.reinhart@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53027 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbbBMGU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 01:20:27 -0500
In-Reply-To: <1423808353-8722-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default speed of normal nic is 1000M while the default speed
of tun is 10M. Now the default speed of tun is changed to 1000M.
And there are 3 options: 10M, 100M and 1000M to the speed of tun.
The command "ethtool -s tun0 speed 10/100/1000" can configure the
speed of tun dynamically.

CC: Michael S. Tsirkin <mst@redhat.com>
CC: Jason Wang <jasowang@redhat.com>
CC: Al Viro <viro@zeniv.linux.org.uk>
Reviewed-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Reviewed-by: Jonathon Reinhart <jonathon.reinhart@gmail.com>
Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 drivers/net/tun.c           | 43 ++++++++++++++++++++++++++++++++++++++++++-
 include/uapi/linux/if_tun.h |  5 +++++
 2 files changed, 47 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 8c8dc16..423b276 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -950,6 +950,9 @@ static void tun_net_init(struct net_device *dev)
 		dev->addr_len = 0;
 		dev->mtu = 1500;
 
+		/* Set default speed 1000M */
+		tun->flags |= TUN_CTRL_SPD_1000;
+
 		/* Zero header length */
 		dev->type = ARPHRD_NONE;
 		dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
@@ -2257,9 +2260,18 @@ static struct miscdevice tun_miscdev = {
 
 static int tun_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
+	struct tun_struct *tun = netdev_priv(dev);
+
+	/* Get the speed of tun */
+	if (tun->flags & TUN_CTRL_SPD_1000) {
+		ethtool_cmd_speed_set(cmd, SPEED_1000);
+	} else if (tun->flags & TUN_CTRL_SPD_100) {
+		ethtool_cmd_speed_set(cmd, SPEED_100);
+	} else
+		ethtool_cmd_speed_set(cmd, SPEED_10);
+
 	cmd->supported		= 0;
 	cmd->advertising	= 0;
-	ethtool_cmd_speed_set(cmd, SPEED_10);
 	cmd->duplex		= DUPLEX_FULL;
 	cmd->port		= PORT_TP;
 	cmd->phy_address	= 0;
@@ -2287,6 +2299,34 @@ static void tun_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
 	}
 }
 
+static int tun_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+	u32 speed = ethtool_cmd_speed(cmd);
+	int ret = 0;
+
+	/* Set speed flag */
+	switch (speed) {
+	case 10:
+		tun->flags &= ~(TUN_CTRL_SPD_100 | TUN_CTRL_SPD_1000);
+		tun->flags |= TUN_CTRL_SPD_10;
+		break;
+	case 100:
+		tun->flags &= ~(TUN_CTRL_SPD_10 | TUN_CTRL_SPD_1000);
+		tun->flags |= TUN_CTRL_SPD_100;
+		break;
+	case 1000:
+		tun->flags &= ~(TUN_CTRL_SPD_10 | TUN_CTRL_SPD_100);
+		tun->flags |= TUN_CTRL_SPD_1000;
+		break;
+	default:
+		ret = -EINVAL;
+		tun_debug(KERN_INFO, tun, "wrong speed!\n");
+	}
+
+	return ret;
+}
+
 static u32 tun_get_msglevel(struct net_device *dev)
 {
 #ifdef TUN_DEBUG
@@ -2307,6 +2347,7 @@ static void tun_set_msglevel(struct net_device *dev, u32 value)
 
 static const struct ethtool_ops tun_ethtool_ops = {
 	.get_settings	= tun_get_settings,
+	.set_settings	= tun_set_settings,
 	.get_drvinfo	= tun_get_drvinfo,
 	.get_msglevel	= tun_get_msglevel,
 	.set_msglevel	= tun_set_msglevel,
diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
index 50ae243..78a09a7 100644
--- a/include/uapi/linux/if_tun.h
+++ b/include/uapi/linux/if_tun.h
@@ -66,6 +66,11 @@
 #define IFF_PERSIST	0x0800
 #define IFF_NOFILTER	0x1000
 
+/*add speed control, default 1000M*/
+#define TUN_CTRL_SPD_10         0x0020
+#define TUN_CTRL_SPD_100        0x0040
+#define TUN_CTRL_SPD_1000       0x0080
+
 /* Socket options */
 #define TUN_TX_TIMESTAMP 1
 
-- 
1.9.1
