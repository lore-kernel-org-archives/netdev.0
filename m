From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 2/5] smsc95xx: remove unnecessary variables
Date: Mon, 24 Sep 2012 15:40:51 +0100
Message-ID: <1348497654-9915-3-git-send-email-steve.glendinning@shawell.net>
References: <1348497654-9915-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:37775 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756170Ab2IXOu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 10:50:27 -0400
In-Reply-To: <1348497654-9915-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removes unnecessary variables as smsc95xx_write_reg takes its
value by parameter.  Early versions passed this parameter by
reference.

Also replace hardcoded interrupt status value with a #define

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |   29 +++++++++--------------------
 drivers/net/usb/smsc95xx.h |    1 +
 2 files changed, 10 insertions(+), 20 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index ed1e551..5d0256b 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -460,12 +460,10 @@ static int smsc95xx_link_reset(struct usbnet *dev)
 	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
 	unsigned long flags;
 	u16 lcladv, rmtadv;
-	u32 intdata;
 
 	/* clear interrupt status */
 	smsc95xx_mdio_read(dev->net, mii->phy_id, PHY_INT_SRC);
-	intdata = 0xFFFFFFFF;
-	smsc95xx_write_reg(dev, INT_STS, intdata);
+	smsc95xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL_);
 
 	mii_check_media(mii, 1, 1);
 	mii_ethtool_gset(&dev->mii, &ecmd);
@@ -677,7 +675,6 @@ static void smsc95xx_start_tx_path(struct usbnet *dev)
 {
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	unsigned long flags;
-	u32 reg_val;
 
 	/* Enable Tx at MAC */
 	spin_lock_irqsave(&pdata->mac_cr_lock, flags);
@@ -687,8 +684,7 @@ static void smsc95xx_start_tx_path(struct usbnet *dev)
 	smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr);
 
 	/* Enable Tx at SCSRs */
-	reg_val = TX_CFG_ON_;
-	smsc95xx_write_reg(dev, TX_CFG, reg_val);
+	smsc95xx_write_reg(dev, TX_CFG, TX_CFG_ON_);
 }
 
 /* Starts the Receive path */
@@ -753,8 +749,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 
 	netif_dbg(dev, ifup, dev->net, "entering smsc95xx_reset\n");
 
-	write_buf = HW_CFG_LRST_;
-	ret = smsc95xx_write_reg(dev, HW_CFG, write_buf);
+	ret = smsc95xx_write_reg(dev, HW_CFG, HW_CFG_LRST_);
 	if (ret < 0) {
 		netdev_warn(dev->net, "Failed to write HW_CFG_LRST_ bit in HW_CFG register, ret = %d\n",
 			    ret);
@@ -777,8 +772,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 		return ret;
 	}
 
-	write_buf = PM_CTL_PHY_RST_;
-	ret = smsc95xx_write_reg(dev, PM_CTRL, write_buf);
+	ret = smsc95xx_write_reg(dev, PM_CTRL, PM_CTL_PHY_RST_);
 	if (ret < 0) {
 		netdev_warn(dev->net, "Failed to write PM_CTRL: %d\n", ret);
 		return ret;
@@ -863,8 +857,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 		  "Read Value from BURST_CAP after writing: 0x%08x\n",
 		  read_buf);
 
-	read_buf = DEFAULT_BULK_IN_DELAY;
-	ret = smsc95xx_write_reg(dev, BULK_IN_DLY, read_buf);
+	ret = smsc95xx_write_reg(dev, BULK_IN_DLY, DEFAULT_BULK_IN_DELAY);
 	if (ret < 0) {
 		netdev_warn(dev->net, "ret = %d\n", ret);
 		return ret;
@@ -910,8 +903,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from HW_CFG after writing: 0x%08x\n", read_buf);
 
-	write_buf = 0xFFFFFFFF;
-	ret = smsc95xx_write_reg(dev, INT_STS, write_buf);
+	ret = smsc95xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL_);
 	if (ret < 0) {
 		netdev_warn(dev->net, "Failed to write INT_STS register, ret=%d\n",
 			    ret);
@@ -936,15 +928,13 @@ static int smsc95xx_reset(struct usbnet *dev)
 	}
 
 	/* Init Tx */
-	write_buf = 0;
-	ret = smsc95xx_write_reg(dev, FLOW, write_buf);
+	ret = smsc95xx_write_reg(dev, FLOW, 0);
 	if (ret < 0) {
 		netdev_warn(dev->net, "Failed to write FLOW: %d\n", ret);
 		return ret;
 	}
 
-	read_buf = AFC_CFG_DEFAULT;
-	ret = smsc95xx_write_reg(dev, AFC_CFG, read_buf);
+	ret = smsc95xx_write_reg(dev, AFC_CFG, AFC_CFG_DEFAULT);
 	if (ret < 0) {
 		netdev_warn(dev->net, "Failed to write AFC_CFG: %d\n", ret);
 		return ret;
@@ -959,8 +949,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 
 	/* Init Rx */
 	/* Set Vlan */
-	write_buf = (u32)ETH_P_8021Q;
-	ret = smsc95xx_write_reg(dev, VLAN1, write_buf);
+	ret = smsc95xx_write_reg(dev, VLAN1, (u32)ETH_P_8021Q);
 	if (ret < 0) {
 		netdev_warn(dev->net, "Failed to write VAN1: %d\n", ret);
 		return ret;
diff --git a/drivers/net/usb/smsc95xx.h b/drivers/net/usb/smsc95xx.h
index 86bc449..a275b62 100644
--- a/drivers/net/usb/smsc95xx.h
+++ b/drivers/net/usb/smsc95xx.h
@@ -63,6 +63,7 @@
 #define INT_STS_TDFO_			(0x00001000)
 #define INT_STS_RXDF_			(0x00000800)
 #define INT_STS_GPIOS_			(0x000007FF)
+#define INT_STS_CLEAR_ALL_		(0xFFFFFFFF)
 
 #define RX_CFG				(0x0C)
 #define RX_FIFO_FLUSH_			(0x00000001)
-- 
1.7.9.5
