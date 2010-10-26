From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 1/5] netdev: bfin_mac: clean up printk messages
Date: Tue, 26 Oct 2010 03:40:23 -0400
Message-ID: <1288078827-17495-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:38814 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751994Ab0JZHkT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 03:40:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_* and pr_* helper funcs for output rather than printk.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.c |   65 +++++++++++++++++++++--------------------------
 1 files changed, 29 insertions(+), 36 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index ce1e5e9..a572bcb 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -8,6 +8,11 @@
  * Licensed under the GPL-2 or later.
  */
 
+#define DRV_VERSION	"1.1"
+#define DRV_DESC	"Blackfin on-chip Ethernet MAC driver"
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -41,12 +46,7 @@
 
 #include "bfin_mac.h"
 
-#define DRV_NAME	"bfin_mac"
-#define DRV_VERSION	"1.1"
-#define DRV_AUTHOR	"Bryan Wu, Luke Yang"
-#define DRV_DESC	"Blackfin on-chip Ethernet MAC driver"
-
-MODULE_AUTHOR(DRV_AUTHOR);
+MODULE_AUTHOR("Bryan Wu, Luke Yang");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION(DRV_DESC);
 MODULE_ALIAS("platform:bfin_mac");
@@ -189,8 +189,7 @@ static int desc_list_init(void)
 		/* allocate a new skb for next time receive */
 		new_skb = dev_alloc_skb(PKT_BUF_SZ + NET_IP_ALIGN);
 		if (!new_skb) {
-			printk(KERN_NOTICE DRV_NAME
-			       ": init: low on mem - packet dropped\n");
+			pr_notice("init: low on mem - packet dropped\n");
 			goto init_error;
 		}
 		skb_reserve(new_skb, NET_IP_ALIGN);
@@ -240,7 +239,7 @@ static int desc_list_init(void)
 
 init_error:
 	desc_list_free();
-	printk(KERN_ERR DRV_NAME ": kmalloc failed\n");
+	pr_err("kmalloc failed\n");
 	return -ENOMEM;
 }
 
@@ -259,8 +258,7 @@ static int bfin_mdio_poll(void)
 	while ((bfin_read_EMAC_STAADD()) & STABUSY) {
 		udelay(1);
 		if (timeout_cnt-- < 0) {
-			printk(KERN_ERR DRV_NAME
-			": wait MDC/MDIO transaction to complete timeout\n");
+			pr_err("wait MDC/MDIO transaction to complete timeout\n");
 			return -ETIMEDOUT;
 		}
 	}
@@ -350,9 +348,9 @@ static void bfin_mac_adjust_link(struct net_device *dev)
 					opmode &= ~RMII_10;
 					break;
 				default:
-					printk(KERN_WARNING
-						"%s: Ack!  Speed (%d) is not 10/100!\n",
-						DRV_NAME, phydev->speed);
+					netdev_warn(dev,
+						"Ack! Speed (%d) is not 10/100!\n",
+						phydev->speed);
 					break;
 				}
 				bfin_write_EMAC_OPMODE(opmode);
@@ -417,14 +415,13 @@ static int mii_probe(struct net_device *dev, int phy_mode)
 
 	/* now we are supposed to have a proper phydev, to attach to... */
 	if (!phydev) {
-		printk(KERN_INFO "%s: Don't found any phy device at all\n",
-			dev->name);
+		netdev_err(dev, "no phy device found\n");
 		return -ENODEV;
 	}
 
 	if (phy_mode != PHY_INTERFACE_MODE_RMII &&
 		phy_mode != PHY_INTERFACE_MODE_MII) {
-		printk(KERN_INFO "%s: Invalid phy interface mode\n", dev->name);
+		netdev_err(dev, "invalid phy interface mode\n");
 		return -EINVAL;
 	}
 
@@ -432,7 +429,7 @@ static int mii_probe(struct net_device *dev, int phy_mode)
 			0, phy_mode);
 
 	if (IS_ERR(phydev)) {
-		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
+		netdev_err(dev, "could not attach PHY\n");
 		return PTR_ERR(phydev);
 	}
 
@@ -453,11 +450,10 @@ static int mii_probe(struct net_device *dev, int phy_mode)
 	lp->old_duplex = -1;
 	lp->phydev = phydev;
 
-	printk(KERN_INFO "%s: attached PHY driver [%s] "
-	       "(mii_bus:phy_addr=%s, irq=%d, mdc_clk=%dHz(mdc_div=%d)"
-	       "@sclk=%dMHz)\n",
-	       DRV_NAME, phydev->drv->name, dev_name(&phydev->dev), phydev->irq,
-	       MDC_CLK, mdc_div, sclk/1000000);
+	pr_info("attached PHY driver [%s] "
+	        "(mii_bus:phy_addr=%s, irq=%d, mdc_clk=%dHz(mdc_div=%d)@sclk=%dMHz)\n",
+	        phydev->drv->name, dev_name(&phydev->dev), phydev->irq,
+	        MDC_CLK, mdc_div, sclk/1000000);
 
 	return 0;
 }
@@ -502,7 +498,7 @@ bfin_mac_ethtool_setsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 static void bfin_mac_ethtool_getdrvinfo(struct net_device *dev,
 					struct ethtool_drvinfo *info)
 {
-	strcpy(info->driver, DRV_NAME);
+	strcpy(info->driver, KBUILD_MODNAME);
 	strcpy(info->version, DRV_VERSION);
 	strcpy(info->fw_version, "N/A");
 	strcpy(info->bus_info, dev_name(&dev->dev));
@@ -827,8 +823,7 @@ static void bfin_tx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
 		while ((!(bfin_read_EMAC_PTP_ISTAT() & TXTL)) && (--timeout_cnt))
 			udelay(1);
 		if (timeout_cnt == 0)
-			printk(KERN_ERR DRV_NAME
-					": fails to timestamp the TX packet\n");
+			netdev_err(netdev, "timestamp the TX packet failed\n");
 		else {
 			struct skb_shared_hwtstamps shhwtstamps;
 			u64 ns;
@@ -1083,8 +1078,7 @@ static void bfin_mac_rx(struct net_device *dev)
 	 * we which case we simply drop the packet
 	 */
 	if (current_rx_ptr->status.status_word & RX_ERROR_MASK) {
-		printk(KERN_NOTICE DRV_NAME
-		       ": rx: receive error - packet dropped\n");
+		netdev_notice(dev, "rx: receive error - packet dropped\n");
 		dev->stats.rx_dropped++;
 		goto out;
 	}
@@ -1094,8 +1088,7 @@ static void bfin_mac_rx(struct net_device *dev)
 
 	new_skb = dev_alloc_skb(PKT_BUF_SZ + NET_IP_ALIGN);
 	if (!new_skb) {
-		printk(KERN_NOTICE DRV_NAME
-		       ": rx: low on mem - packet dropped\n");
+		netdev_notice(dev, "rx: low on mem - packet dropped\n");
 		dev->stats.rx_dropped++;
 		goto out;
 	}
@@ -1213,7 +1206,7 @@ static int bfin_mac_enable(struct phy_device *phydev)
 	int ret;
 	u32 opmode;
 
-	pr_debug("%s: %s\n", DRV_NAME, __func__);
+	pr_debug("%s\n", __func__);
 
 	/* Set RX DMA */
 	bfin_write_DMA1_NEXT_DESC_PTR(&(rx_list_head->desc_a));
@@ -1323,7 +1316,7 @@ static void bfin_mac_set_multicast_list(struct net_device *dev)
 	u32 sysctl;
 
 	if (dev->flags & IFF_PROMISC) {
-		printk(KERN_INFO "%s: set to promisc mode\n", dev->name);
+		netdev_info(dev, "set promisc mode\n");
 		sysctl = bfin_read_EMAC_OPMODE();
 		sysctl |= PR;
 		bfin_write_EMAC_OPMODE(sysctl);
@@ -1393,7 +1386,7 @@ static int bfin_mac_open(struct net_device *dev)
 	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
 	 */
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		printk(KERN_WARNING DRV_NAME ": no valid ethernet hw addr\n");
+		netdev_warn(dev, "no valid ethernet hw addr\n");
 		return -EINVAL;
 	}
 
@@ -1558,7 +1551,7 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	bfin_mac_hwtstamp_init(ndev);
 
 	/* now, print out the card info, in a short format.. */
-	dev_info(&pdev->dev, "%s, Version %s\n", DRV_DESC, DRV_VERSION);
+	netdev_info(ndev, "%s, Version %s\n", DRV_DESC, DRV_VERSION);
 
 	return 0;
 
@@ -1650,7 +1643,7 @@ static int __devinit bfin_mii_bus_probe(struct platform_device *pdev)
 	 * so set the GPIO pins to Ethernet mode
 	 */
 	pin_req = mii_bus_pd->mac_peripherals;
-	rc = peripheral_request_list(pin_req, DRV_NAME);
+	rc = peripheral_request_list(pin_req, KBUILD_MODNAME);
 	if (rc) {
 		dev_err(&pdev->dev, "Requesting peripherals failed!\n");
 		return rc;
@@ -1739,7 +1732,7 @@ static struct platform_driver bfin_mac_driver = {
 	.resume = bfin_mac_resume,
 	.suspend = bfin_mac_suspend,
 	.driver = {
-		.name = DRV_NAME,
+		.name = KBUILD_MODNAME,
 		.owner	= THIS_MODULE,
 	},
 };
-- 
1.7.3.2

