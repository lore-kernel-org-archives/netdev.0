From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH] hostap: Use ethtool_ops
Date: Thu, 24 Mar 2005 19:23:14 -0800
Message-ID: <20050325032314.GA8357@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert ethtool ioctl handler to use ethtool_ops.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


Index: wireless-2.6/drivers/net/wireless/hostap/hostap.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/hostap/hostap.c	2005-03-22 20:07:48.000000000 -0800
+++ wireless-2.6/drivers/net/wireless/hostap/hostap.c	2005-03-22 21:27:00.000000000 -0800
@@ -934,6 +934,8 @@
 		dev->tx_queue_len = 0;
 	}
 
+	SET_ETHTOOL_OPS(dev, &prism2_ethtool_ops);
+
 	netif_stop_queue(dev);
 }
 
Index: wireless-2.6/drivers/net/wireless/hostap/hostap_ioctl.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/hostap/hostap_ioctl.c	2005-03-22 21:15:44.000000000 -0800
+++ wireless-2.6/drivers/net/wireless/hostap/hostap_ioctl.c	2005-03-22 21:27:23.000000000 -0800
@@ -3925,31 +3925,28 @@
 }
 
 
-static int prism2_ioctl_ethtool(local_info_t *local, void __user *useraddr)
+static void prism2_get_drvinfo(struct net_device *dev,
+			       struct ethtool_drvinfo *info)
 {
-	u32 ethcmd;
-	struct ethtool_drvinfo info = { ETHTOOL_GDRVINFO };
-
-	if (copy_from_user(&ethcmd, useraddr, sizeof(ethcmd)))
-		return -EFAULT;
+	struct hostap_interface *iface;
+	local_info_t *local;
 
-	switch (ethcmd) {
-	case ETHTOOL_GDRVINFO:
-		strncpy(info.driver, "hostap", sizeof(info.driver) - 1);
-		strncpy(info.version, PRISM2_VERSION,
-			sizeof(info.version) - 1);
-		snprintf(info.fw_version, sizeof(info.fw_version) - 1,
-			 "%d.%d.%d", (local->sta_fw_ver >> 16) & 0xff,
-			 (local->sta_fw_ver >> 8) & 0xff,
-			 local->sta_fw_ver & 0xff);
-		if (copy_to_user(useraddr, &info, sizeof(info)))
-			return -EFAULT;
-		return 0;
-	}
+	iface = netdev_priv(dev);
+	local = iface->local;
 
-	return -EOPNOTSUPP;
+	strncpy(info->driver, "hostap", sizeof(info->driver) - 1);
+	strncpy(info->version, PRISM2_VERSION,
+		sizeof(info->version) - 1);
+	snprintf(info->fw_version, sizeof(info->fw_version) - 1,
+		 "%d.%d.%d", (local->sta_fw_ver >> 16) & 0xff,
+		 (local->sta_fw_ver >> 8) & 0xff,
+		 local->sta_fw_ver & 0xff);
 }
 
+static struct ethtool_ops prism2_ethtool_ops = {
+	.get_drvinfo = prism2_get_drvinfo
+};
+
 
 /* Structures to export the Wireless Handlers */
 
@@ -4117,10 +4114,6 @@
 		else ret = prism2_ioctl_priv_hostapd(local, &wrq->u.data);
 		break;
 
-	case SIOCETHTOOL:
-		ret = prism2_ioctl_ethtool(local, ifr->ifr_data);
-		break;
-
 	default:
 		ret = -EOPNOTSUPP;
 		break;


-- 
Jouni Malinen                                            PGP id EFC895FA
