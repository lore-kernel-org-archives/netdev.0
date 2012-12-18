From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 1/2] smsc95xx: eliminate duplicate warnings on io failure
Date: Tue, 18 Dec 2012 10:46:13 +0000
Message-ID: <1355827574-15164-2-git-send-email-steve.glendinning@shawell.net>
References: <1355827574-15164-1-git-send-email-steve.glendinning@shawell.net>
Cc: ming.lei@canonical.com, oneukum@suse.de,
	gregkh@linuxfoundation.org,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Joe Perches <joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:60518 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753863Ab2LRKqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 05:46:21 -0500
In-Reply-To: <1355827574-15164-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The register read/write functions already log a warning if
an access fails, so this patch removes the additional warnings
logged by callers that don't add any more information.

This patch makes the resulting driver smaller by not containing
as many warning strings.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |  284 +++++++++++---------------------------------
 1 file changed, 67 insertions(+), 217 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 9b73670..124e67f 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -513,10 +513,8 @@ static int smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
 	u32 flow, afc_cfg = 0;
 
 	int ret = smsc95xx_read_reg(dev, AFC_CFG, &afc_cfg);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error reading AFC_CFG\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	if (duplex == DUPLEX_FULL) {
 		u8 cap = mii_resolve_flowctrl_fdx(lcladv, rmtadv);
@@ -541,16 +539,10 @@ static int smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
 	}
 
 	ret = smsc95xx_write_reg(dev, FLOW, flow);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error writing FLOW\n");
-		return ret;
-	}
-
-	ret = smsc95xx_write_reg(dev, AFC_CFG, afc_cfg);
 	if (ret < 0)
-		netdev_warn(dev->net, "Error writing AFC_CFG\n");
+		return ret;
 
-	return ret;
+	return smsc95xx_write_reg(dev, AFC_CFG, afc_cfg);
 }
 
 static int smsc95xx_link_reset(struct usbnet *dev)
@@ -564,16 +556,12 @@ static int smsc95xx_link_reset(struct usbnet *dev)
 
 	/* clear interrupt status */
 	ret = smsc95xx_mdio_read(dev->net, mii->phy_id, PHY_INT_SRC);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error reading PHY_INT_SRC\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	ret = smsc95xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL_);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error writing INT_STS\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	mii_check_media(mii, 1, 1);
 	mii_ethtool_gset(&dev->mii, &ecmd);
@@ -595,10 +583,8 @@ static int smsc95xx_link_reset(struct usbnet *dev)
 	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
 
 	ret = smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error writing MAC_CR\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	ret = smsc95xx_phy_update_flowcontrol(dev, ecmd.duplex, lcladv, rmtadv);
 	if (ret < 0)
@@ -638,10 +624,8 @@ static int smsc95xx_set_features(struct net_device *netdev,
 	int ret;
 
 	ret = smsc95xx_read_reg(dev, COE_CR, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read COE_CR: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	if (features & NETIF_F_HW_CSUM)
 		read_buf |= Tx_COE_EN_;
@@ -654,10 +638,8 @@ static int smsc95xx_set_features(struct net_device *netdev,
 		read_buf &= ~Rx_COE_EN_;
 
 	ret = smsc95xx_write_reg(dev, COE_CR, read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write COE_CR: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	netif_dbg(dev, hw, dev->net, "COE_CR = 0x%08x\n", read_buf);
 	return 0;
@@ -800,16 +782,10 @@ static int smsc95xx_set_mac_address(struct usbnet *dev)
 	int ret;
 
 	ret = smsc95xx_write_reg(dev, ADDRL, addr_lo);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write ADDRL: %d\n", ret);
-		return ret;
-	}
-
-	ret = smsc95xx_write_reg(dev, ADDRH, addr_hi);
 	if (ret < 0)
-		netdev_warn(dev->net, "Failed to write ADDRH: %d\n", ret);
+		return ret;
 
-	return ret;
+	return smsc95xx_write_reg(dev, ADDRH, addr_hi);
 }
 
 /* starts the TX path */
@@ -825,17 +801,11 @@ static int smsc95xx_start_tx_path(struct usbnet *dev)
 	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
 
 	ret = smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write MAC_CR: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	/* Enable Tx at SCSRs */
-	ret = smsc95xx_write_reg(dev, TX_CFG, TX_CFG_ON_);
-	if (ret < 0)
-		netdev_warn(dev->net, "Failed to write TX_CFG: %d\n", ret);
-
-	return ret;
+	return smsc95xx_write_reg(dev, TX_CFG, TX_CFG_ON_);
 }
 
 /* Starts the Receive path */
@@ -843,17 +813,12 @@ static int smsc95xx_start_rx_path(struct usbnet *dev, int in_pm)
 {
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	unsigned long flags;
-	int ret;
 
 	spin_lock_irqsave(&pdata->mac_cr_lock, flags);
 	pdata->mac_cr |= MAC_CR_RXEN_;
 	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
 
-	ret = __smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr, in_pm);
-	if (ret < 0)
-		netdev_warn(dev->net, "Failed to write MAC_CR: %d\n", ret);
-
-	return ret;
+	return __smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr, in_pm);
 }
 
 static int smsc95xx_phy_initialize(struct usbnet *dev)
@@ -910,19 +875,15 @@ static int smsc95xx_reset(struct usbnet *dev)
 	netif_dbg(dev, ifup, dev->net, "entering smsc95xx_reset\n");
 
 	ret = smsc95xx_write_reg(dev, HW_CFG, HW_CFG_LRST_);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write HW_CFG_LRST_ bit in HW_CFG\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	timeout = 0;
 	do {
 		msleep(10);
 		ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
+		if (ret < 0)
 			return ret;
-		}
 		timeout++;
 	} while ((read_buf & HW_CFG_LRST_) && (timeout < 100));
 
@@ -932,19 +893,15 @@ static int smsc95xx_reset(struct usbnet *dev)
 	}
 
 	ret = smsc95xx_write_reg(dev, PM_CTRL, PM_CTL_PHY_RST_);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write PM_CTRL: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	timeout = 0;
 	do {
 		msleep(10);
 		ret = smsc95xx_read_reg(dev, PM_CTRL, &read_buf);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Failed to read PM_CTRL: %d\n", ret);
+		if (ret < 0)
 			return ret;
-		}
 		timeout++;
 	} while ((read_buf & PM_CTL_PHY_RST_) && (timeout < 100));
 
@@ -961,10 +918,8 @@ static int smsc95xx_reset(struct usbnet *dev)
 		  dev->net->dev_addr);
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	netif_dbg(dev, ifup, dev->net, "Read Value from HW_CFG : 0x%08x\n",
 		  read_buf);
@@ -972,16 +927,12 @@ static int smsc95xx_reset(struct usbnet *dev)
 	read_buf |= HW_CFG_BIR_;
 
 	ret = smsc95xx_write_reg(dev, HW_CFG, read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write HW_CFG_BIR_ bit in HW_CFG\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from HW_CFG after writing HW_CFG_BIR_: 0x%08x\n",
@@ -1002,42 +953,32 @@ static int smsc95xx_reset(struct usbnet *dev)
 		  (ulong)dev->rx_urb_size);
 
 	ret = smsc95xx_write_reg(dev, BURST_CAP, burst_cap);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write BURST_CAP: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	ret = smsc95xx_read_reg(dev, BURST_CAP, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read BURST_CAP: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from BURST_CAP after writing: 0x%08x\n",
 		  read_buf);
 
 	ret = smsc95xx_write_reg(dev, BULK_IN_DLY, DEFAULT_BULK_IN_DELAY);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write BULK_IN_DLY: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	ret = smsc95xx_read_reg(dev, BULK_IN_DLY, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read BULK_IN_DLY: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from BULK_IN_DLY after writing: 0x%08x\n",
 		  read_buf);
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	netif_dbg(dev, ifup, dev->net, "Read Value from HW_CFG: 0x%08x\n",
 		  read_buf);
@@ -1051,69 +992,51 @@ static int smsc95xx_reset(struct usbnet *dev)
 	read_buf |= NET_IP_ALIGN << 9;
 
 	ret = smsc95xx_write_reg(dev, HW_CFG, read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write HW_CFG: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from HW_CFG after writing: 0x%08x\n", read_buf);
 
 	ret = smsc95xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL_);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write INT_STS: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	ret = smsc95xx_read_reg(dev, ID_REV, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read ID_REV: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 	netif_dbg(dev, ifup, dev->net, "ID_REV = 0x%08x\n", read_buf);
 
 	/* Configure GPIO pins as LED outputs */
 	write_buf = LED_GPIO_CFG_SPD_LED | LED_GPIO_CFG_LNK_LED |
 		LED_GPIO_CFG_FDX_LED;
 	ret = smsc95xx_write_reg(dev, LED_GPIO_CFG, write_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write LED_GPIO_CFG: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	/* Init Tx */
 	ret = smsc95xx_write_reg(dev, FLOW, 0);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write FLOW: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	ret = smsc95xx_write_reg(dev, AFC_CFG, AFC_CFG_DEFAULT);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write AFC_CFG: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	/* Don't need mac_cr_lock during initialisation */
 	ret = smsc95xx_read_reg(dev, MAC_CR, &pdata->mac_cr);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read MAC_CR: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	/* Init Rx */
 	/* Set Vlan */
 	ret = smsc95xx_write_reg(dev, VLAN1, (u32)ETH_P_8021Q);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write VLAN1: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	/* Enable or disable checksum offload engines */
 	ret = smsc95xx_set_features(dev->net, dev->net->features);
@@ -1131,19 +1054,15 @@ static int smsc95xx_reset(struct usbnet *dev)
 	}
 
 	ret = smsc95xx_read_reg(dev, INT_EP_CTL, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read INT_EP_CTL: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	/* enable PHY interrupts */
 	read_buf |= INT_EP_CTL_PHY_INT_;
 
 	ret = smsc95xx_write_reg(dev, INT_EP_CTL, read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write INT_EP_CTL: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	ret = smsc95xx_start_tx_path(dev);
 	if (ret < 0) {
@@ -1213,10 +1132,8 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	/* detect device revision as different features may be available */
 	ret = smsc95xx_read_reg(dev, ID_REV, &val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read ID_REV: %d\n", ret);
+	if (ret < 0)
 		return ret;
-	}
 	val >>= 16;
 
 	if ((val == ID_REV_CHIP_ID_9500A_) || (val == ID_REV_CHIP_ID_9530_) ||
@@ -1261,17 +1178,13 @@ static int smsc95xx_enable_phy_wakeup_interrupts(struct usbnet *dev, u16 mask)
 
 	/* read to clear */
 	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, PHY_INT_SRC);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error reading PHY_INT_SRC\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	/* enable interrupt source */
 	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, PHY_INT_MASK);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error reading PHY_INT_MASK\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	ret |= mask;
 
@@ -1287,16 +1200,12 @@ static int smsc95xx_link_ok_nopm(struct usbnet *dev)
 
 	/* first, a dummy read, needed to latch some MII phys */
 	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, MII_BMSR);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error reading MII_BMSR\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, MII_BMSR);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error reading MII_BMSR\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	return !!(ret & BMSR_LSTATUS);
 }
@@ -1308,19 +1217,15 @@ static int smsc95xx_enter_suspend0(struct usbnet *dev)
 	int ret;
 
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error reading PM_CTRL\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	val &= (~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_));
 	val |= PM_CTL_SUS_MODE_0;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error writing PM_CTRL\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	/* clear wol status */
 	val &= ~PM_CTL_WUPS_;
@@ -1331,15 +1236,11 @@ static int smsc95xx_enter_suspend0(struct usbnet *dev)
 		val |= PM_CTL_WUPS_ED_;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error writing PM_CTRL\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	/* read back PM_CTRL */
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	if (ret < 0)
-		netdev_warn(dev->net, "Error reading PM_CTRL\n");
 
 	return ret;
 }
@@ -1360,10 +1261,8 @@ static int smsc95xx_enter_suspend1(struct usbnet *dev)
 
 	/* enable energy detect power-down mode */
 	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, PHY_MODE_CTRL_STS);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error reading PHY_MODE_CTRL_STS\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	ret |= MODE_CTRL_STS_EDPWRDOWN_;
 
@@ -1371,27 +1270,21 @@ static int smsc95xx_enter_suspend1(struct usbnet *dev)
 
 	/* enter SUSPEND1 mode */
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error reading PM_CTRL\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
 	val |= PM_CTL_SUS_MODE_1;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error writing PM_CTRL\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	/* clear wol status, enable energy detection */
 	val &= ~PM_CTL_WUPS_;
 	val |= (PM_CTL_WUPS_ED_ | PM_CTL_ED_EN_);
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	if (ret < 0)
-		netdev_warn(dev->net, "Error writing PM_CTRL\n");
 
 	return ret;
 }
@@ -1402,17 +1295,13 @@ static int smsc95xx_enter_suspend2(struct usbnet *dev)
 	int ret;
 
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error reading PM_CTRL\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
 	val |= PM_CTL_SUS_MODE_2;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	if (ret < 0)
-		netdev_warn(dev->net, "Error writing PM_CTRL\n");
 
 	return ret;
 }
@@ -1442,32 +1331,24 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 		/* disable energy detect (link up) & wake up events */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error reading WUCSR\n");
+		if (ret < 0)
 			goto done;
-		}
 
 		val &= ~(WUCSR_MPEN_ | WUCSR_WAKE_EN_);
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error writing WUCSR\n");
+		if (ret < 0)
 			goto done;
-		}
 
 		ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error reading PM_CTRL\n");
+		if (ret < 0)
 			goto done;
-		}
 
 		val &= ~(PM_CTL_ED_EN_ | PM_CTL_WOL_EN_);
 
 		ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error writing PM_CTRL\n");
+		if (ret < 0)
 			goto done;
-		}
 
 		ret = smsc95xx_enter_suspend2(dev);
 		goto done;
@@ -1565,7 +1446,6 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 		for (i = 0; i < (wuff_filter_count * 4); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, filter_mask[i]);
 			if (ret < 0) {
-				netdev_warn(dev->net, "Error writing WUFF\n");
 				kfree(filter_mask);
 				goto done;
 			}
@@ -1574,67 +1454,51 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 		for (i = 0; i < (wuff_filter_count / 4); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, command[i]);
-			if (ret < 0) {
-				netdev_warn(dev->net, "Error writing WUFF\n");
+			if (ret < 0)
 				goto done;
-			}
 		}
 
 		for (i = 0; i < (wuff_filter_count / 4); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, offset[i]);
-			if (ret < 0) {
-				netdev_warn(dev->net, "Error writing WUFF\n");
+			if (ret < 0)
 				goto done;
-			}
 		}
 
 		for (i = 0; i < (wuff_filter_count / 2); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, crc[i]);
-			if (ret < 0) {
-				netdev_warn(dev->net, "Error writing WUFF\n");
+			if (ret < 0)
 				goto done;
-			}
 		}
 
 		/* clear any pending pattern match packet status */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error reading WUCSR\n");
+		if (ret < 0)
 			goto done;
-		}
 
 		val |= WUCSR_WUFR_;
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error writing WUCSR\n");
+		if (ret < 0)
 			goto done;
-		}
 	}
 
 	if (pdata->wolopts & WAKE_MAGIC) {
 		/* clear any pending magic packet status */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error reading WUCSR\n");
+		if (ret < 0)
 			goto done;
-		}
 
 		val |= WUCSR_MPR_;
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error writing WUCSR\n");
+		if (ret < 0)
 			goto done;
-		}
 	}
 
 	/* enable/disable wakeup sources */
 	ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error reading WUCSR\n");
+	if (ret < 0)
 		goto done;
-	}
 
 	if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
 		netdev_info(dev->net, "enabling pattern match wakeup\n");
@@ -1653,17 +1517,13 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	}
 
 	ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error writing WUCSR\n");
+	if (ret < 0)
 		goto done;
-	}
 
 	/* enable wol wakeup source */
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error reading PM_CTRL\n");
+	if (ret < 0)
 		goto done;
-	}
 
 	val |= PM_CTL_WOL_EN_;
 
@@ -1672,10 +1532,8 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 		val |= PM_CTL_ED_EN_;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error writing PM_CTRL\n");
+	if (ret < 0)
 		goto done;
-	}
 
 	/* enable receiver to enable frame reception */
 	smsc95xx_start_rx_path(dev, 1);
@@ -1702,34 +1560,26 @@ static int smsc95xx_resume(struct usb_interface *intf)
 	if (pdata->wolopts) {
 		/* clear wake-up sources */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error reading WUCSR\n");
+		if (ret < 0)
 			return ret;
-		}
 
 		val &= ~(WUCSR_WAKE_EN_ | WUCSR_MPEN_);
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error writing WUCSR\n");
+		if (ret < 0)
 			return ret;
-		}
 
 		/* clear wake-up status */
 		ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error reading PM_CTRL\n");
+		if (ret < 0)
 			return ret;
-		}
 
 		val &= ~PM_CTL_WOL_EN_;
 		val |= PM_CTL_WUPS_;
 
 		ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error writing PM_CTRL\n");
+		if (ret < 0)
 			return ret;
-		}
 	}
 
 	ret = usbnet_resume(intf);
-- 
1.7.10.4
