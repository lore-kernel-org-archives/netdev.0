From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (20/25) sk98: ethtool transmit checksum and scatter gather
 setting
Date: Mon, 15 Nov 2004 15:51:44 -0800
Message-ID: <20041115155144.3d2e3d1c@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Allow control of transmit checksum with ethtool.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skethtool.c b/drivers/net/sk98lin/skethtool.c
--- a/drivers/net/sk98lin/skethtool.c	2004-11-15 14:36:09 -08:00
+++ b/drivers/net/sk98lin/skethtool.c	2004-11-15 14:36:09 -08:00
@@ -468,9 +468,30 @@
         return ret ? -EIO : 0;
 }
 
+static int sk98_set_sg(struct net_device *dev, u32 data)
+{
+	DEV_NET *pNet = netdev_priv(dev);
+	SK_AC *pAC = pNet->pAC;
+
+	if (!pAC->ChipsetType && data)
+		return -EOPNOTSUPP;
+	return ethtool_op_set_sg(dev, data);
+}
+
+static int sk98_set_tx_csum(struct net_device *dev, u32 data)
+{
+	DEV_NET *pNet = netdev_priv(dev);
+	SK_AC *pAC = pNet->pAC;
+
+	if (!pAC->ChipsetType && data)
+		return -EOPNOTSUPP;
+	return ethtool_op_set_tx_csum(dev, data);
+}
+
 struct ethtool_ops SkGeEthtoolOps = {
 	.get_settings		= sk98_get_settings,
 	.set_settings		= sk98_set_settings,
+	.get_link		= ethtool_op_get_link,
 	.get_drvinfo		= sk98_get_driver_info,
 	.get_strings		= sk98_get_strings,
 	.get_stats_count	= sk98_stats_count,
@@ -478,4 +499,8 @@
 	.phys_id		= sk98_flash_leds,
 	.get_pauseparam		= sk98_get_pause_param,
 	.set_pauseparam		= sk98_set_pause_param,
+	.get_sg			= ethtool_op_get_sg,
+	.set_sg			= sk98_set_sg,
+	.get_tx_csum		= ethtool_op_get_tx_csum,
+	.set_tx_csum		= sk98_set_tx_csum,
 };
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-15 14:36:09 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-15 14:36:09 -08:00
@@ -4177,18 +4177,15 @@
 			printk("    irq moderation:  disabled\n");
 
 
-#ifdef SK_ZEROCOPY
-		if (pAC->ChipsetType)
-#ifdef USE_SK_TX_CHECKSUM
+		if (pAC->dev[FromPort]->features & NETIF_F_SG)
 			printk("    scatter-gather:  enabled\n");
-#else
-			printk("    tx-checksum:     disabled\n");
-#endif
+ 		else
+ 			printk("    scatter-gather:  disabled\n");
+	
+		if (pAC->dev[FromPort]->features & NETIF_F_IP_CSUM)
+			printk("    tx-checksum:     enabled\n");
 		else
-			printk("    scatter-gather:  disabled\n");
-#else
-			printk("    scatter-gather:  disabled\n");
-#endif
+			printk("    tx-checksum:     disabled\n");
 
 #ifndef USE_SK_RX_CHECKSUM
 			printk("    rx-checksum:     disabled\n");
