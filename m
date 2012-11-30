From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 2/2] smsc75xx: expand check_ macros
Date: Fri, 30 Nov 2012 14:52:44 +0000
Message-ID: <1354287164-9884-3-git-send-email-steve.glendinning@shawell.net>
References: <1354287164-9884-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:47299 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756940Ab2K3Owu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 09:52:50 -0500
In-Reply-To: <1354287164-9884-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These macros, while reducing the amount of code, hide flow control
and make the code more confusing to follow and review.  This patch
expands them.  It should have no functional effect on the driver.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |  735 ++++++++++++++++++++++++++++++++++----------
 1 file changed, 576 insertions(+), 159 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 86d9249..1cbd936 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -64,15 +64,6 @@
 #define SUSPEND_ALLMODES		(SUSPEND_SUSPEND0 | SUSPEND_SUSPEND1 | \
 					 SUSPEND_SUSPEND2 | SUSPEND_SUSPEND3)
 
-#define check_warn(ret, fmt, args...) \
-	({ if (ret < 0) netdev_warn(dev->net, fmt, ##args); })
-
-#define check_warn_return(ret, fmt, args...) \
-	({ if (ret < 0) { netdev_warn(dev->net, fmt, ##args); return ret; } })
-
-#define check_warn_goto_done(ret, fmt, args...) \
-	({ if (ret < 0) { netdev_warn(dev->net, fmt, ##args); goto done; } })
-
 struct smsc75xx_priv {
 	struct usbnet *dev;
 	u32 rfe_ctl;
@@ -182,7 +173,10 @@ static __must_check int __smsc75xx_phy_wait_not_busy(struct usbnet *dev,
 
 	do {
 		ret = __smsc75xx_read_reg(dev, MII_ACCESS, &val, in_pm);
-		check_warn_return(ret, "Error reading MII_ACCESS\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading MII_ACCESS\n");
+			return ret;
+		}
 
 		if (!(val & MII_ACCESS_BUSY))
 			return 0;
@@ -202,7 +196,10 @@ static int __smsc75xx_mdio_read(struct net_device *netdev, int phy_id, int idx,
 
 	/* confirm MII not busy */
 	ret = __smsc75xx_phy_wait_not_busy(dev, in_pm);
-	check_warn_goto_done(ret, "MII is busy in smsc75xx_mdio_read\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "MII is busy in smsc75xx_mdio_read\n");
+		goto done;
+	}
 
 	/* set the address, index & direction (read from PHY) */
 	phy_id &= dev->mii.phy_id_mask;
@@ -211,13 +208,22 @@ static int __smsc75xx_mdio_read(struct net_device *netdev, int phy_id, int idx,
 		| ((idx << MII_ACCESS_REG_ADDR_SHIFT) & MII_ACCESS_REG_ADDR)
 		| MII_ACCESS_READ | MII_ACCESS_BUSY;
 	ret = __smsc75xx_write_reg(dev, MII_ACCESS, addr, in_pm);
-	check_warn_goto_done(ret, "Error writing MII_ACCESS\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing MII_ACCESS\n");
+		goto done;
+	}
 
 	ret = __smsc75xx_phy_wait_not_busy(dev, in_pm);
-	check_warn_goto_done(ret, "Timed out reading MII reg %02X\n", idx);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Timed out reading MII reg %02X\n", idx);
+		goto done;
+	}
 
 	ret = __smsc75xx_read_reg(dev, MII_DATA, &val, in_pm);
-	check_warn_goto_done(ret, "Error reading MII_DATA\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading MII_DATA\n");
+		goto done;
+	}
 
 	ret = (u16)(val & 0xFFFF);
 
@@ -237,11 +243,17 @@ static void __smsc75xx_mdio_write(struct net_device *netdev, int phy_id,
 
 	/* confirm MII not busy */
 	ret = __smsc75xx_phy_wait_not_busy(dev, in_pm);
-	check_warn_goto_done(ret, "MII is busy in smsc75xx_mdio_write\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "MII is busy in smsc75xx_mdio_write\n");
+		goto done;
+	}
 
 	val = regval;
 	ret = __smsc75xx_write_reg(dev, MII_DATA, val, in_pm);
-	check_warn_goto_done(ret, "Error writing MII_DATA\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing MII_DATA\n");
+		goto done;
+	}
 
 	/* set the address, index & direction (write to PHY) */
 	phy_id &= dev->mii.phy_id_mask;
@@ -250,10 +262,16 @@ static void __smsc75xx_mdio_write(struct net_device *netdev, int phy_id,
 		| ((idx << MII_ACCESS_REG_ADDR_SHIFT) & MII_ACCESS_REG_ADDR)
 		| MII_ACCESS_WRITE | MII_ACCESS_BUSY;
 	ret = __smsc75xx_write_reg(dev, MII_ACCESS, addr, in_pm);
-	check_warn_goto_done(ret, "Error writing MII_ACCESS\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing MII_ACCESS\n");
+		goto done;
+	}
 
 	ret = __smsc75xx_phy_wait_not_busy(dev, in_pm);
-	check_warn_goto_done(ret, "Timed out writing MII reg %02X\n", idx);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Timed out writing MII reg %02X\n", idx);
+		goto done;
+	}
 
 done:
 	mutex_unlock(&dev->phy_mutex);
@@ -290,7 +308,10 @@ static int smsc75xx_wait_eeprom(struct usbnet *dev)
 
 	do {
 		ret = smsc75xx_read_reg(dev, E2P_CMD, &val);
-		check_warn_return(ret, "Error reading E2P_CMD\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading E2P_CMD\n");
+			return ret;
+		}
 
 		if (!(val & E2P_CMD_BUSY) || (val & E2P_CMD_TIMEOUT))
 			break;
@@ -313,7 +334,10 @@ static int smsc75xx_eeprom_confirm_not_busy(struct usbnet *dev)
 
 	do {
 		ret = smsc75xx_read_reg(dev, E2P_CMD, &val);
-		check_warn_return(ret, "Error reading E2P_CMD\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading E2P_CMD\n");
+			return ret;
+		}
 
 		if (!(val & E2P_CMD_BUSY))
 			return 0;
@@ -341,14 +365,20 @@ static int smsc75xx_read_eeprom(struct usbnet *dev, u32 offset, u32 length,
 	for (i = 0; i < length; i++) {
 		val = E2P_CMD_BUSY | E2P_CMD_READ | (offset & E2P_CMD_ADDR);
 		ret = smsc75xx_write_reg(dev, E2P_CMD, val);
-		check_warn_return(ret, "Error writing E2P_CMD\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing E2P_CMD\n");
+			return ret;
+		}
 
 		ret = smsc75xx_wait_eeprom(dev);
 		if (ret < 0)
 			return ret;
 
 		ret = smsc75xx_read_reg(dev, E2P_DATA, &val);
-		check_warn_return(ret, "Error reading E2P_DATA\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading E2P_DATA\n");
+			return ret;
+		}
 
 		data[i] = val & 0xFF;
 		offset++;
@@ -373,7 +403,10 @@ static int smsc75xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 	/* Issue write/erase enable command */
 	val = E2P_CMD_BUSY | E2P_CMD_EWEN;
 	ret = smsc75xx_write_reg(dev, E2P_CMD, val);
-	check_warn_return(ret, "Error writing E2P_CMD\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing E2P_CMD\n");
+		return ret;
+	}
 
 	ret = smsc75xx_wait_eeprom(dev);
 	if (ret < 0)
@@ -384,12 +417,18 @@ static int smsc75xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 		/* Fill data register */
 		val = data[i];
 		ret = smsc75xx_write_reg(dev, E2P_DATA, val);
-		check_warn_return(ret, "Error writing E2P_DATA\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing E2P_DATA\n");
+			return ret;
+		}
 
 		/* Send "write" command */
 		val = E2P_CMD_BUSY | E2P_CMD_WRITE | (offset & E2P_CMD_ADDR);
 		ret = smsc75xx_write_reg(dev, E2P_CMD, val);
-		check_warn_return(ret, "Error writing E2P_CMD\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing E2P_CMD\n");
+			return ret;
+		}
 
 		ret = smsc75xx_wait_eeprom(dev);
 		if (ret < 0)
@@ -408,7 +447,10 @@ static int smsc75xx_dataport_wait_not_busy(struct usbnet *dev)
 	for (i = 0; i < 100; i++) {
 		u32 dp_sel;
 		ret = smsc75xx_read_reg(dev, DP_SEL, &dp_sel);
-		check_warn_return(ret, "Error reading DP_SEL\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading DP_SEL\n");
+			return ret;
+		}
 
 		if (dp_sel & DP_SEL_DPRDY)
 			return 0;
@@ -431,28 +473,49 @@ static int smsc75xx_dataport_write(struct usbnet *dev, u32 ram_select, u32 addr,
 	mutex_lock(&pdata->dataport_mutex);
 
 	ret = smsc75xx_dataport_wait_not_busy(dev);
-	check_warn_goto_done(ret, "smsc75xx_dataport_write busy on entry\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "smsc75xx_dataport_write busy on entry\n");
+		goto done;
+	}
 
 	ret = smsc75xx_read_reg(dev, DP_SEL, &dp_sel);
-	check_warn_goto_done(ret, "Error reading DP_SEL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading DP_SEL\n");
+		goto done;
+	}
 
 	dp_sel &= ~DP_SEL_RSEL;
 	dp_sel |= ram_select;
 	ret = smsc75xx_write_reg(dev, DP_SEL, dp_sel);
-	check_warn_goto_done(ret, "Error writing DP_SEL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing DP_SEL\n");
+		goto done;
+	}
 
 	for (i = 0; i < length; i++) {
 		ret = smsc75xx_write_reg(dev, DP_ADDR, addr + i);
-		check_warn_goto_done(ret, "Error writing DP_ADDR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing DP_ADDR\n");
+			goto done;
+		}
 
 		ret = smsc75xx_write_reg(dev, DP_DATA, buf[i]);
-		check_warn_goto_done(ret, "Error writing DP_DATA\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing DP_DATA\n");
+			goto done;
+		}
 
 		ret = smsc75xx_write_reg(dev, DP_CMD, DP_CMD_WRITE);
-		check_warn_goto_done(ret, "Error writing DP_CMD\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing DP_CMD\n");
+			goto done;
+		}
 
 		ret = smsc75xx_dataport_wait_not_busy(dev);
-		check_warn_goto_done(ret, "smsc75xx_dataport_write timeout\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "smsc75xx_dataport_write timeout\n");
+			goto done;
+		}
 	}
 
 done:
@@ -480,7 +543,8 @@ static void smsc75xx_deferred_multicast_write(struct work_struct *param)
 		DP_SEL_VHF_HASH_LEN, pdata->multicast_hash_table);
 
 	ret = smsc75xx_write_reg(dev, RFE_CTL, pdata->rfe_ctl);
-	check_warn(ret, "Error writing RFE_CRL\n");
+	if (ret < 0)
+		netdev_warn(dev->net, "Error writing RFE_CRL\n");
 }
 
 static void smsc75xx_set_multicast(struct net_device *netdev)
@@ -554,10 +618,16 @@ static int smsc75xx_update_flowcontrol(struct usbnet *dev, u8 duplex,
 	}
 
 	ret = smsc75xx_write_reg(dev, FLOW, flow);
-	check_warn_return(ret, "Error writing FLOW\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing FLOW\n");
+		return ret;
+	}
 
 	ret = smsc75xx_write_reg(dev, FCT_FLOW, fct_flow);
-	check_warn_return(ret, "Error writing FCT_FLOW\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing FCT_FLOW\n");
+		return ret;
+	}
 
 	return 0;
 }
@@ -574,7 +644,10 @@ static int smsc75xx_link_reset(struct usbnet *dev)
 		PHY_INT_SRC_CLEAR_ALL);
 
 	ret = smsc75xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL);
-	check_warn_return(ret, "Error writing INT_STS\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing INT_STS\n");
+		return ret;
+	}
 
 	mii_check_media(mii, 1, 1);
 	mii_ethtool_gset(&dev->mii, &ecmd);
@@ -658,9 +731,10 @@ static int smsc75xx_ethtool_set_wol(struct net_device *net,
 	pdata->wolopts = wolinfo->wolopts & SUPPORTED_WAKE;
 
 	ret = device_set_wakeup_enable(&dev->udev->dev, pdata->wolopts);
-	check_warn_return(ret, "device_set_wakeup_enable error %d\n", ret);
+	if (ret < 0)
+		netdev_warn(dev->net, "device_set_wakeup_enable error %d\n", ret);
 
-	return 0;
+	return ret;
 }
 
 static const struct ethtool_ops smsc75xx_ethtool_ops = {
@@ -713,19 +787,29 @@ static int smsc75xx_set_mac_address(struct usbnet *dev)
 	u32 addr_hi = dev->net->dev_addr[4] | dev->net->dev_addr[5] << 8;
 
 	int ret = smsc75xx_write_reg(dev, RX_ADDRH, addr_hi);
-	check_warn_return(ret, "Failed to write RX_ADDRH: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write RX_ADDRH: %d\n", ret);
+		return ret;
+	}
 
 	ret = smsc75xx_write_reg(dev, RX_ADDRL, addr_lo);
-	check_warn_return(ret, "Failed to write RX_ADDRL: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write RX_ADDRL: %d\n", ret);
+		return ret;
+	}
 
 	addr_hi |= ADDR_FILTX_FB_VALID;
 	ret = smsc75xx_write_reg(dev, ADDR_FILTX, addr_hi);
-	check_warn_return(ret, "Failed to write ADDR_FILTX: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write ADDR_FILTX: %d\n", ret);
+		return ret;
+	}
 
 	ret = smsc75xx_write_reg(dev, ADDR_FILTX + 4, addr_lo);
-	check_warn_return(ret, "Failed to write ADDR_FILTX+4: %d\n", ret);
+	if (ret < 0)
+		netdev_warn(dev->net, "Failed to write ADDR_FILTX+4: %d\n", ret);
 
-	return 0;
+	return ret;
 }
 
 static int smsc75xx_phy_initialize(struct usbnet *dev)
@@ -747,7 +831,10 @@ static int smsc75xx_phy_initialize(struct usbnet *dev)
 	do {
 		msleep(10);
 		bmcr = smsc75xx_mdio_read(dev->net, dev->mii.phy_id, MII_BMCR);
-		check_warn_return(bmcr, "Error reading MII_BMCR\n");
+		if (bmcr < 0) {
+			netdev_warn(dev->net, "Error reading MII_BMCR\n");
+			return bmcr;
+		}
 		timeout++;
 	} while ((bmcr & BMCR_RESET) && (timeout < 100));
 
@@ -764,7 +851,11 @@ static int smsc75xx_phy_initialize(struct usbnet *dev)
 
 	/* read and write to clear phy interrupt status */
 	ret = smsc75xx_mdio_read(dev->net, dev->mii.phy_id, PHY_INT_SRC);
-	check_warn_return(ret, "Error reading PHY_INT_SRC\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading PHY_INT_SRC\n");
+		return ret;
+	}
+
 	smsc75xx_mdio_write(dev->net, dev->mii.phy_id, PHY_INT_SRC, 0xffff);
 
 	smsc75xx_mdio_write(dev->net, dev->mii.phy_id, PHY_INT_MASK,
@@ -782,14 +873,20 @@ static int smsc75xx_set_rx_max_frame_length(struct usbnet *dev, int size)
 	bool rxenabled;
 
 	ret = smsc75xx_read_reg(dev, MAC_RX, &buf);
-	check_warn_return(ret, "Failed to read MAC_RX: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read MAC_RX: %d\n", ret);
+		return ret;
+	}
 
 	rxenabled = ((buf & MAC_RX_RXEN) != 0);
 
 	if (rxenabled) {
 		buf &= ~MAC_RX_RXEN;
 		ret = smsc75xx_write_reg(dev, MAC_RX, buf);
-		check_warn_return(ret, "Failed to write MAC_RX: %d\n", ret);
+		if (ret < 0) {
+			netdev_warn(dev->net, "Failed to write MAC_RX: %d\n", ret);
+			return ret;
+		}
 	}
 
 	/* add 4 to size for FCS */
@@ -797,12 +894,18 @@ static int smsc75xx_set_rx_max_frame_length(struct usbnet *dev, int size)
 	buf |= (((size + 4) << MAC_RX_MAX_SIZE_SHIFT) & MAC_RX_MAX_SIZE);
 
 	ret = smsc75xx_write_reg(dev, MAC_RX, buf);
-	check_warn_return(ret, "Failed to write MAC_RX: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write MAC_RX: %d\n", ret);
+		return ret;
+	}
 
 	if (rxenabled) {
 		buf |= MAC_RX_RXEN;
 		ret = smsc75xx_write_reg(dev, MAC_RX, buf);
-		check_warn_return(ret, "Failed to write MAC_RX: %d\n", ret);
+		if (ret < 0) {
+			netdev_warn(dev->net, "Failed to write MAC_RX: %d\n", ret);
+			return ret;
+		}
 	}
 
 	return 0;
@@ -813,7 +916,10 @@ static int smsc75xx_change_mtu(struct net_device *netdev, int new_mtu)
 	struct usbnet *dev = netdev_priv(netdev);
 
 	int ret = smsc75xx_set_rx_max_frame_length(dev, new_mtu);
-	check_warn_return(ret, "Failed to set mac rx frame length\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to set mac rx frame length\n");
+		return ret;
+	}
 
 	return usbnet_change_mtu(netdev, new_mtu);
 }
@@ -838,9 +944,10 @@ static int smsc75xx_set_features(struct net_device *netdev,
 	/* it's racing here! */
 
 	ret = smsc75xx_write_reg(dev, RFE_CTL, pdata->rfe_ctl);
-	check_warn_return(ret, "Error writing RFE_CTL\n");
+	if (ret < 0)
+		netdev_warn(dev->net, "Error writing RFE_CTL\n");
 
-	return 0;
+	return ret;
 }
 
 static int smsc75xx_wait_ready(struct usbnet *dev, int in_pm)
@@ -853,7 +960,10 @@ static int smsc75xx_wait_ready(struct usbnet *dev, int in_pm)
 
 		ret = __smsc75xx_read_reg(dev, PMT_CTL, &buf, in_pm);
 
-		check_warn_return(ret, "Failed to read PMT_CTL: %d\n", ret);
+		if (ret < 0) {
+			netdev_warn(dev->net, "Failed to read PMT_CTL: %d\n", ret);
+			return ret;
+		}
 
 		if (buf & PMT_CTL_DEV_RDY)
 			return 0;
@@ -875,21 +985,33 @@ static int smsc75xx_reset(struct usbnet *dev)
 	netif_dbg(dev, ifup, dev->net, "entering smsc75xx_reset\n");
 
 	ret = smsc75xx_wait_ready(dev, 0);
-	check_warn_return(ret, "device not ready in smsc75xx_reset\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "device not ready in smsc75xx_reset\n");
+		return ret;
+	}
 
 	ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
-	check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
+		return ret;
+	}
 
 	buf |= HW_CFG_LRST;
 
 	ret = smsc75xx_write_reg(dev, HW_CFG, buf);
-	check_warn_return(ret, "Failed to write HW_CFG: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write HW_CFG: %d\n", ret);
+		return ret;
+	}
 
 	timeout = 0;
 	do {
 		msleep(10);
 		ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
-		check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
+		if (ret < 0) {
+			netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
+			return ret;
+		}
 		timeout++;
 	} while ((buf & HW_CFG_LRST) && (timeout < 100));
 
@@ -901,18 +1023,27 @@ static int smsc75xx_reset(struct usbnet *dev)
 	netif_dbg(dev, ifup, dev->net, "Lite reset complete, resetting PHY\n");
 
 	ret = smsc75xx_read_reg(dev, PMT_CTL, &buf);
-	check_warn_return(ret, "Failed to read PMT_CTL: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read PMT_CTL: %d\n", ret);
+		return ret;
+	}
 
 	buf |= PMT_CTL_PHY_RST;
 
 	ret = smsc75xx_write_reg(dev, PMT_CTL, buf);
-	check_warn_return(ret, "Failed to write PMT_CTL: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write PMT_CTL: %d\n", ret);
+		return ret;
+	}
 
 	timeout = 0;
 	do {
 		msleep(10);
 		ret = smsc75xx_read_reg(dev, PMT_CTL, &buf);
-		check_warn_return(ret, "Failed to read PMT_CTL: %d\n", ret);
+		if (ret < 0) {
+			netdev_warn(dev->net, "Failed to read PMT_CTL: %d\n", ret);
+			return ret;
+		}
 		timeout++;
 	} while ((buf & PMT_CTL_PHY_RST) && (timeout < 100));
 
@@ -926,13 +1057,19 @@ static int smsc75xx_reset(struct usbnet *dev)
 	smsc75xx_init_mac_address(dev);
 
 	ret = smsc75xx_set_mac_address(dev);
-	check_warn_return(ret, "Failed to set mac address\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to set mac address\n");
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net, "MAC Address: %pM\n",
 		  dev->net->dev_addr);
 
 	ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
-	check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net, "Read Value from HW_CFG : 0x%08x\n",
 		  buf);
@@ -940,10 +1077,16 @@ static int smsc75xx_reset(struct usbnet *dev)
 	buf |= HW_CFG_BIR;
 
 	ret = smsc75xx_write_reg(dev, HW_CFG, buf);
-	check_warn_return(ret, "Failed to write HW_CFG: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net,  "Failed to write HW_CFG: %d\n", ret);
+		return ret;
+	}
 
 	ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
-	check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net, "Read Value from HW_CFG after writing HW_CFG_BIR: 0x%08x\n",
 		  buf);
@@ -963,36 +1106,57 @@ static int smsc75xx_reset(struct usbnet *dev)
 		  (ulong)dev->rx_urb_size);
 
 	ret = smsc75xx_write_reg(dev, BURST_CAP, buf);
-	check_warn_return(ret, "Failed to write BURST_CAP: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write BURST_CAP: %d\n", ret);
+		return ret;
+	}
 
 	ret = smsc75xx_read_reg(dev, BURST_CAP, &buf);
-	check_warn_return(ret, "Failed to read BURST_CAP: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read BURST_CAP: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from BURST_CAP after writing: 0x%08x\n", buf);
 
 	ret = smsc75xx_write_reg(dev, BULK_IN_DLY, DEFAULT_BULK_IN_DELAY);
-	check_warn_return(ret, "Failed to write BULK_IN_DLY: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write BULK_IN_DLY: %d\n", ret);
+		return ret;
+	}
 
 	ret = smsc75xx_read_reg(dev, BULK_IN_DLY, &buf);
-	check_warn_return(ret, "Failed to read BULK_IN_DLY: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read BULK_IN_DLY: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from BULK_IN_DLY after writing: 0x%08x\n", buf);
 
 	if (turbo_mode) {
 		ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
-		check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
+		if (ret < 0) {
+			netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
+			return ret;
+		}
 
 		netif_dbg(dev, ifup, dev->net, "HW_CFG: 0x%08x\n", buf);
 
 		buf |= (HW_CFG_MEF | HW_CFG_BCE);
 
 		ret = smsc75xx_write_reg(dev, HW_CFG, buf);
-		check_warn_return(ret, "Failed to write HW_CFG: %d\n", ret);
+		if (ret < 0) {
+			netdev_warn(dev->net, "Failed to write HW_CFG: %d\n", ret);
+			return ret;
+		}
 
 		ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
-		check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
+		if (ret < 0) {
+			netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
+			return ret;
+		}
 
 		netif_dbg(dev, ifup, dev->net, "HW_CFG: 0x%08x\n", buf);
 	}
@@ -1000,58 +1164,92 @@ static int smsc75xx_reset(struct usbnet *dev)
 	/* set FIFO sizes */
 	buf = (MAX_RX_FIFO_SIZE - 512) / 512;
 	ret = smsc75xx_write_reg(dev, FCT_RX_FIFO_END, buf);
-	check_warn_return(ret, "Failed to write FCT_RX_FIFO_END: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write FCT_RX_FIFO_END: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net, "FCT_RX_FIFO_END set to 0x%08x\n", buf);
 
 	buf = (MAX_TX_FIFO_SIZE - 512) / 512;
 	ret = smsc75xx_write_reg(dev, FCT_TX_FIFO_END, buf);
-	check_warn_return(ret, "Failed to write FCT_TX_FIFO_END: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write FCT_TX_FIFO_END: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net, "FCT_TX_FIFO_END set to 0x%08x\n", buf);
 
 	ret = smsc75xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL);
-	check_warn_return(ret, "Failed to write INT_STS: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write INT_STS: %d\n", ret);
+		return ret;
+	}
 
 	ret = smsc75xx_read_reg(dev, ID_REV, &buf);
-	check_warn_return(ret, "Failed to read ID_REV: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read ID_REV: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net, "ID_REV = 0x%08x\n", buf);
 
 	ret = smsc75xx_read_reg(dev, E2P_CMD, &buf);
-	check_warn_return(ret, "Failed to read E2P_CMD: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read E2P_CMD: %d\n", ret);
+		return ret;
+	}
 
 	/* only set default GPIO/LED settings if no EEPROM is detected */
 	if (!(buf & E2P_CMD_LOADED)) {
 		ret = smsc75xx_read_reg(dev, LED_GPIO_CFG, &buf);
-		check_warn_return(ret, "Failed to read LED_GPIO_CFG: %d\n",
-				  ret);
+		if (ret < 0) {
+			netdev_warn(dev->net, "Failed to read LED_GPIO_CFG: %d\n", ret);
+			return ret;
+		}
 
 		buf &= ~(LED_GPIO_CFG_LED2_FUN_SEL | LED_GPIO_CFG_LED10_FUN_SEL);
 		buf |= LED_GPIO_CFG_LEDGPIO_EN | LED_GPIO_CFG_LED2_FUN_SEL;
 
 		ret = smsc75xx_write_reg(dev, LED_GPIO_CFG, buf);
-		check_warn_return(ret, "Failed to write LED_GPIO_CFG: %d\n",
-				  ret);
+		if (ret < 0) {
+			netdev_warn(dev->net, "Failed to write LED_GPIO_CFG: %d\n", ret);
+			return ret;
+		}
 	}
 
 	ret = smsc75xx_write_reg(dev, FLOW, 0);
-	check_warn_return(ret, "Failed to write FLOW: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write FLOW: %d\n", ret);
+		return ret;
+	}
 
 	ret = smsc75xx_write_reg(dev, FCT_FLOW, 0);
-	check_warn_return(ret, "Failed to write FCT_FLOW: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write FCT_FLOW: %d\n", ret);
+		return ret;
+	}
 
 	/* Don't need rfe_ctl_lock during initialisation */
 	ret = smsc75xx_read_reg(dev, RFE_CTL, &pdata->rfe_ctl);
-	check_warn_return(ret, "Failed to read RFE_CTL: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read RFE_CTL: %d\n", ret);
+		return ret;
+	}
 
 	pdata->rfe_ctl |= RFE_CTL_AB | RFE_CTL_DPF;
 
 	ret = smsc75xx_write_reg(dev, RFE_CTL, pdata->rfe_ctl);
-	check_warn_return(ret, "Failed to write RFE_CTL: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write RFE_CTL: %d\n", ret);
+		return ret;
+	}
 
 	ret = smsc75xx_read_reg(dev, RFE_CTL, &pdata->rfe_ctl);
-	check_warn_return(ret, "Failed to read RFE_CTL: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read RFE_CTL: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net, "RFE_CTL set to 0x%08x\n",
 		  pdata->rfe_ctl);
@@ -1062,65 +1260,107 @@ static int smsc75xx_reset(struct usbnet *dev)
 	smsc75xx_set_multicast(dev->net);
 
 	ret = smsc75xx_phy_initialize(dev);
-	check_warn_return(ret, "Failed to initialize PHY: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to initialize PHY: %d\n", ret);
+		return ret;
+	}
 
 	ret = smsc75xx_read_reg(dev, INT_EP_CTL, &buf);
-	check_warn_return(ret, "Failed to read INT_EP_CTL: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read INT_EP_CTL: %d\n", ret);
+		return ret;
+	}
 
 	/* enable PHY interrupts */
 	buf |= INT_ENP_PHY_INT;
 
 	ret = smsc75xx_write_reg(dev, INT_EP_CTL, buf);
-	check_warn_return(ret, "Failed to write INT_EP_CTL: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write INT_EP_CTL: %d\n", ret);
+		return ret;
+	}
 
 	/* allow mac to detect speed and duplex from phy */
 	ret = smsc75xx_read_reg(dev, MAC_CR, &buf);
-	check_warn_return(ret, "Failed to read MAC_CR: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read MAC_CR: %d\n", ret);
+		return ret;
+	}
 
 	buf |= (MAC_CR_ADD | MAC_CR_ASD);
 	ret = smsc75xx_write_reg(dev, MAC_CR, buf);
-	check_warn_return(ret, "Failed to write MAC_CR: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write MAC_CR: %d\n", ret);
+		return ret;
+	}
 
 	ret = smsc75xx_read_reg(dev, MAC_TX, &buf);
-	check_warn_return(ret, "Failed to read MAC_TX: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read MAC_TX: %d\n", ret);
+		return ret;
+	}
 
 	buf |= MAC_TX_TXEN;
 
 	ret = smsc75xx_write_reg(dev, MAC_TX, buf);
-	check_warn_return(ret, "Failed to write MAC_TX: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write MAC_TX: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net, "MAC_TX set to 0x%08x\n", buf);
 
 	ret = smsc75xx_read_reg(dev, FCT_TX_CTL, &buf);
-	check_warn_return(ret, "Failed to read FCT_TX_CTL: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read FCT_TX_CTL: %d\n", ret);
+		return ret;
+	}
 
 	buf |= FCT_TX_CTL_EN;
 
 	ret = smsc75xx_write_reg(dev, FCT_TX_CTL, buf);
-	check_warn_return(ret, "Failed to write FCT_TX_CTL: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write FCT_TX_CTL: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net, "FCT_TX_CTL set to 0x%08x\n", buf);
 
 	ret = smsc75xx_set_rx_max_frame_length(dev, 1514);
-	check_warn_return(ret, "Failed to set max rx frame length\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to set max rx frame length\n");
+		return ret;
+	}
 
 	ret = smsc75xx_read_reg(dev, MAC_RX, &buf);
-	check_warn_return(ret, "Failed to read MAC_RX: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read MAC_RX: %d\n", ret);
+		return ret;
+	}
 
 	buf |= MAC_RX_RXEN;
 
 	ret = smsc75xx_write_reg(dev, MAC_RX, buf);
-	check_warn_return(ret, "Failed to write MAC_RX: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write MAC_RX: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net, "MAC_RX set to 0x%08x\n", buf);
 
 	ret = smsc75xx_read_reg(dev, FCT_RX_CTL, &buf);
-	check_warn_return(ret, "Failed to read FCT_RX_CTL: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read FCT_RX_CTL: %d\n", ret);
+		return ret;
+	}
 
 	buf |= FCT_RX_CTL_EN;
 
 	ret = smsc75xx_write_reg(dev, FCT_RX_CTL, buf);
-	check_warn_return(ret, "Failed to write FCT_RX_CTL: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write FCT_RX_CTL: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net, "FCT_RX_CTL set to 0x%08x\n", buf);
 
@@ -1149,7 +1389,10 @@ static int smsc75xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	printk(KERN_INFO SMSC_CHIPNAME " v" SMSC_DRIVER_VERSION "\n");
 
 	ret = usbnet_get_endpoints(dev, intf);
-	check_warn_return(ret, "usbnet_get_endpoints failed: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "usbnet_get_endpoints failed: %d\n", ret);
+		return ret;
+	}
 
 	dev->data[0] = (unsigned long)kzalloc(sizeof(struct smsc75xx_priv),
 		GFP_KERNEL);
@@ -1181,7 +1424,10 @@ static int smsc75xx_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	/* Init all registers */
 	ret = smsc75xx_reset(dev);
-	check_warn_return(ret, "smsc75xx_reset error %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "smsc75xx_reset error %d\n", ret);
+		return ret;
+	}
 
 	dev->net->netdev_ops = &smsc75xx_netdev_ops;
 	dev->net->ethtool_ops = &smsc75xx_ethtool_ops;
@@ -1215,19 +1461,34 @@ static int smsc75xx_write_wuff(struct usbnet *dev, int filter, u32 wuf_cfg,
 	int ret;
 
 	ret = smsc75xx_write_reg(dev, cfg_base, wuf_cfg);
-	check_warn_return(ret, "Error writing WUF_CFGX\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing WUF_CFGX\n");
+		return ret;
+	}
 
 	ret = smsc75xx_write_reg(dev, mask_base, wuf_mask1);
-	check_warn_return(ret, "Error writing WUF_MASKX\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing WUF_MASKX\n");
+		return ret;
+	}
 
 	ret = smsc75xx_write_reg(dev, mask_base + 4, 0);
-	check_warn_return(ret, "Error writing WUF_MASKX\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing WUF_MASKX\n");
+		return ret;
+	}
 
 	ret = smsc75xx_write_reg(dev, mask_base + 8, 0);
-	check_warn_return(ret, "Error writing WUF_MASKX\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing WUF_MASKX\n");
+		return ret;
+	}
 
 	ret = smsc75xx_write_reg(dev, mask_base + 12, 0);
-	check_warn_return(ret, "Error writing WUF_MASKX\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing WUF_MASKX\n");
+		return ret;
+	}
 
 	return 0;
 }
@@ -1239,13 +1500,19 @@ static int smsc75xx_enter_suspend0(struct usbnet *dev)
 	int ret;
 
 	ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
-	check_warn_return(ret, "Error reading PMT_CTL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading PMT_CTL\n");
+		return ret;
+	}
 
 	val &= (~(PMT_CTL_SUS_MODE | PMT_CTL_PHY_RST));
 	val |= PMT_CTL_SUS_MODE_0 | PMT_CTL_WOL_EN | PMT_CTL_WUPS;
 
 	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-	check_warn_return(ret, "Error writing PMT_CTL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing PMT_CTL\n");
+		return ret;
+	}
 
 	pdata->suspend_flags |= SUSPEND_SUSPEND0;
 
@@ -1259,20 +1526,29 @@ static int smsc75xx_enter_suspend1(struct usbnet *dev)
 	int ret;
 
 	ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
-	check_warn_return(ret, "Error reading PMT_CTL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading PMT_CTL\n");
+		return ret;
+	}
 
 	val &= ~(PMT_CTL_SUS_MODE | PMT_CTL_WUPS | PMT_CTL_PHY_RST);
 	val |= PMT_CTL_SUS_MODE_1;
 
 	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-	check_warn_return(ret, "Error writing PMT_CTL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing PMT_CTL\n");
+		return ret;
+	}
 
 	/* clear wol status, enable energy detection */
 	val &= ~PMT_CTL_WUPS;
 	val |= (PMT_CTL_WUPS_ED | PMT_CTL_ED_EN);
 
 	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-	check_warn_return(ret, "Error writing PMT_CTL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing PMT_CTL\n");
+		return ret;
+	}
 
 	pdata->suspend_flags |= SUSPEND_SUSPEND1;
 
@@ -1286,13 +1562,19 @@ static int smsc75xx_enter_suspend2(struct usbnet *dev)
 	int ret;
 
 	ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
-	check_warn_return(ret, "Error reading PMT_CTL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading PMT_CTL\n");
+		return ret;
+	}
 
 	val &= ~(PMT_CTL_SUS_MODE | PMT_CTL_WUPS | PMT_CTL_PHY_RST);
 	val |= PMT_CTL_SUS_MODE_2;
 
 	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-	check_warn_return(ret, "Error writing PMT_CTL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing PMT_CTL\n");
+		return ret;
+	}
 
 	pdata->suspend_flags |= SUSPEND_SUSPEND2;
 
@@ -1306,7 +1588,10 @@ static int smsc75xx_enter_suspend3(struct usbnet *dev)
 	int ret;
 
 	ret = smsc75xx_read_reg_nopm(dev, FCT_RX_CTL, &val);
-	check_warn_return(ret, "Error reading FCT_RX_CTL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading FCT_RX_CTL\n");
+		return ret;
+	}
 
 	if (val & FCT_RX_CTL_RXUSED) {
 		netdev_dbg(dev->net, "rx fifo not empty in autosuspend\n");
@@ -1314,20 +1599,29 @@ static int smsc75xx_enter_suspend3(struct usbnet *dev)
 	}
 
 	ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
-	check_warn_return(ret, "Error reading PMT_CTL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading PMT_CTL\n");
+		return ret;
+	}
 
 	val &= ~(PMT_CTL_SUS_MODE | PMT_CTL_WUPS | PMT_CTL_PHY_RST);
 	val |= PMT_CTL_SUS_MODE_3 | PMT_CTL_RES_CLR_WKP_EN;
 
 	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-	check_warn_return(ret, "Error writing PMT_CTL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing PMT_CTL\n");
+		return ret;
+	}
 
 	/* clear wol status */
 	val &= ~PMT_CTL_WUPS;
 	val |= PMT_CTL_WUPS_WOL;
 
 	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-	check_warn_return(ret, "Error writing PMT_CTL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing PMT_CTL\n");
+		return ret;
+	}
 
 	pdata->suspend_flags |= SUSPEND_SUSPEND3;
 
@@ -1343,11 +1637,17 @@ static int smsc75xx_enable_phy_wakeup_interrupts(struct usbnet *dev, u16 mask)
 
 	/* read to clear */
 	ret = smsc75xx_mdio_read_nopm(dev->net, mii->phy_id, PHY_INT_SRC);
-	check_warn_return(ret, "Error reading PHY_INT_SRC\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading PHY_INT_SRC\n");
+		return ret;
+	}
 
 	/* enable interrupt source */
 	ret = smsc75xx_mdio_read_nopm(dev->net, mii->phy_id, PHY_INT_MASK);
-	check_warn_return(ret, "Error reading PHY_INT_MASK\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading PHY_INT_MASK\n");
+		return ret;
+	}
 
 	ret |= mask;
 
@@ -1363,10 +1663,16 @@ static int smsc75xx_link_ok_nopm(struct usbnet *dev)
 
 	/* first, a dummy read, needed to latch some MII phys */
 	ret = smsc75xx_mdio_read_nopm(dev->net, mii->phy_id, MII_BMSR);
-	check_warn_return(ret, "Error reading MII_BMSR\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading MII_BMSR\n");
+		return ret;
+	}
 
 	ret = smsc75xx_mdio_read_nopm(dev->net, mii->phy_id, MII_BMSR);
-	check_warn_return(ret, "Error reading MII_BMSR\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading MII_BMSR\n");
+		return ret;
+	}
 
 	return !!(ret & BMSR_LSTATUS);
 }
@@ -1388,7 +1694,10 @@ static int smsc75xx_autosuspend(struct usbnet *dev, u32 link_up)
 		/* enable PHY wakeup events for if cable is attached */
 		ret = smsc75xx_enable_phy_wakeup_interrupts(dev,
 			PHY_INT_MASK_ANEG_COMP);
-		check_warn_return(ret, "error enabling PHY wakeup ints\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "error enabling PHY wakeup ints\n");
+			return ret;
+		}
 
 		netdev_info(dev->net, "entering SUSPEND1 mode\n");
 		return smsc75xx_enter_suspend1(dev);
@@ -1397,7 +1706,10 @@ static int smsc75xx_autosuspend(struct usbnet *dev, u32 link_up)
 	/* enable PHY wakeup events so we remote wakeup if cable is pulled */
 	ret = smsc75xx_enable_phy_wakeup_interrupts(dev,
 		PHY_INT_MASK_LINK_DOWN);
-	check_warn_return(ret, "error enabling PHY wakeup ints\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "error enabling PHY wakeup ints\n");
+		return ret;
+	}
 
 	netdev_dbg(dev->net, "autosuspend entering SUSPEND3\n");
 	return smsc75xx_enter_suspend3(dev);
@@ -1411,7 +1723,10 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 	int ret;
 
 	ret = usbnet_suspend(intf, message);
-	check_warn_return(ret, "usbnet_suspend error\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "usbnet_suspend error\n");
+		return ret;
+	}
 
 	if (pdata->suspend_flags) {
 		netdev_warn(dev->net, "error during last resume\n");
@@ -1436,20 +1751,32 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 		/* disable energy detect (link up) & wake up events */
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_goto_done(ret, "Error reading WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading WUCSR\n");
+			goto done;
+		}
 
 		val &= ~(WUCSR_MPEN | WUCSR_WUEN);
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_goto_done(ret, "Error writing WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing WUCSR\n");
+			goto done;
+		}
 
 		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
-		check_warn_goto_done(ret, "Error reading PMT_CTL\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading PMT_CTL\n");
+			goto done;
+		}
 
 		val &= ~(PMT_CTL_ED_EN | PMT_CTL_WOL_EN);
 
 		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-		check_warn_goto_done(ret, "Error writing PMT_CTL\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing PMT_CTL\n");
+			goto done;
+		}
 
 		ret = smsc75xx_enter_suspend2(dev);
 		goto done;
@@ -1458,7 +1785,10 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 	if (pdata->wolopts & WAKE_PHY) {
 		ret = smsc75xx_enable_phy_wakeup_interrupts(dev,
 			(PHY_INT_MASK_ANEG_COMP | PHY_INT_MASK_LINK_DOWN));
-		check_warn_goto_done(ret, "error enabling PHY wakeup ints\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "error enabling PHY wakeup ints\n");
+			goto done;
+		}
 
 		/* if link is down then configure EDPD and enter SUSPEND1,
 		 * otherwise enter SUSPEND0 below
@@ -1470,7 +1800,10 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 			/* enable energy detect power-down mode */
 			ret = smsc75xx_mdio_read_nopm(dev->net, mii->phy_id,
 				PHY_MODE_CTRL_STS);
-			check_warn_goto_done(ret, "Error reading PHY_MODE_CTRL_STS\n");
+			if (ret < 0) {
+				netdev_warn(dev->net, "Error reading PHY_MODE_CTRL_STS\n");
+				goto done;
+			}
 
 			ret |= MODE_CTRL_STS_EDPWRDOWN;
 
@@ -1489,7 +1822,10 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 		/* disable all filters */
 		for (i = 0; i < WUF_NUM; i++) {
 			ret = smsc75xx_write_reg_nopm(dev, WUF_CFGX + i * 4, 0);
-			check_warn_goto_done(ret, "Error writing WUF_CFGX\n");
+			if (ret < 0) {
+				netdev_warn(dev->net, "Error writing WUF_CFGX\n");
+				goto done;
+			}
 		}
 
 		if (pdata->wolopts & WAKE_MCAST) {
@@ -1499,7 +1835,10 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 			val = WUF_CFGX_EN | WUF_CFGX_ATYPE_MULTICAST
 				| smsc_crc(mcast, 3);
 			ret = smsc75xx_write_wuff(dev, filter++, val, 0x0007);
-			check_warn_goto_done(ret, "Error writing wakeup filter\n");
+			if (ret < 0) {
+				netdev_warn(dev->net, "Error writing wakeup filter\n");
+				goto done;
+			}
 		}
 
 		if (pdata->wolopts & WAKE_ARP) {
@@ -1509,102 +1848,159 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 			val = WUF_CFGX_EN | WUF_CFGX_ATYPE_ALL | (0x0C << 16)
 				| smsc_crc(arp, 2);
 			ret = smsc75xx_write_wuff(dev, filter++, val, 0x0003);
-			check_warn_goto_done(ret, "Error writing wakeup filter\n");
+			if (ret < 0) {
+				netdev_warn(dev->net, "Error writing wakeup filter\n");
+				goto done;
+			}
 		}
 
 		/* clear any pending pattern match packet status */
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_goto_done(ret, "Error reading WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading WUCSR\n");
+			goto done;
+		}
 
 		val |= WUCSR_WUFR;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_goto_done(ret, "Error writing WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing WUCSR\n");
+			goto done;
+		}
 
 		netdev_info(dev->net, "enabling packet match detection\n");
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_goto_done(ret, "Error reading WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading WUCSR\n");
+			goto done;
+		}
 
 		val |= WUCSR_WUEN;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_goto_done(ret, "Error writing WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing WUCSR\n");
+			goto done;
+		}
 	} else {
 		netdev_info(dev->net, "disabling packet match detection\n");
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_goto_done(ret, "Error reading WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading WUCSR\n");
+			goto done;
+		}
 
 		val &= ~WUCSR_WUEN;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_goto_done(ret, "Error writing WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing WUCSR\n");
+			goto done;
+		}
 	}
 
 	/* disable magic, bcast & unicast wakeup sources */
 	ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-	check_warn_goto_done(ret, "Error reading WUCSR\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading WUCSR\n");
+		goto done;
+	}
 
 	val &= ~(WUCSR_MPEN | WUCSR_BCST_EN | WUCSR_PFDA_EN);
 
 	ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-	check_warn_goto_done(ret, "Error writing WUCSR\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing WUCSR\n");
+		goto done;
+	}
 
 	if (pdata->wolopts & WAKE_PHY) {
 		netdev_info(dev->net, "enabling PHY wakeup\n");
 
 		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
-		check_warn_goto_done(ret, "Error reading PMT_CTL\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading PMT_CTL\n");
+			goto done;
+		}
 
 		/* clear wol status, enable energy detection */
 		val &= ~PMT_CTL_WUPS;
 		val |= (PMT_CTL_WUPS_ED | PMT_CTL_ED_EN);
 
 		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-		check_warn_goto_done(ret, "Error writing PMT_CTL\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing PMT_CTL\n");
+			goto done;
+		}
 	}
 
 	if (pdata->wolopts & WAKE_MAGIC) {
 		netdev_info(dev->net, "enabling magic packet wakeup\n");
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_goto_done(ret, "Error reading WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading WUCSR\n");
+			goto done;
+		}
 
 		/* clear any pending magic packet status */
 		val |= WUCSR_MPR | WUCSR_MPEN;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_goto_done(ret, "Error writing WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing WUCSR\n");
+			goto done;
+		}
 	}
 
 	if (pdata->wolopts & WAKE_BCAST) {
 		netdev_info(dev->net, "enabling broadcast detection\n");
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_goto_done(ret, "Error reading WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading WUCSR\n");
+			goto done;
+		}
 
 		val |= WUCSR_BCAST_FR | WUCSR_BCST_EN;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_goto_done(ret, "Error writing WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing WUCSR\n");
+			goto done;
+		}
 	}
 
 	if (pdata->wolopts & WAKE_UCAST) {
 		netdev_info(dev->net, "enabling unicast detection\n");
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_goto_done(ret, "Error reading WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading WUCSR\n");
+			goto done;
+		}
 
 		val |= WUCSR_WUFR | WUCSR_PFDA_EN;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_goto_done(ret, "Error writing WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing WUCSR\n");
+			goto done;
+		}
 	}
 
 	/* enable receiver to enable frame reception */
 	ret = smsc75xx_read_reg_nopm(dev, MAC_RX, &val);
-	check_warn_goto_done(ret, "Failed to read MAC_RX: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read MAC_RX: %d\n", ret);
+		goto done;
+	}
 
 	val |= MAC_RX_RXEN;
 
 	ret = smsc75xx_write_reg_nopm(dev, MAC_RX, val);
-	check_warn_goto_done(ret, "Failed to write MAC_RX: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write MAC_RX: %d\n", ret);
+		goto done;
+	}
 
 	/* some wol options are enabled, so enter SUSPEND0 */
 	netdev_info(dev->net, "entering SUSPEND0 mode\n");
@@ -1632,39 +2028,60 @@ static int smsc75xx_resume(struct usb_interface *intf)
 	if (suspend_flags & SUSPEND_ALLMODES) {
 		/* Disable wakeup sources */
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading WUCSR\n");
+			return ret;
+		}
 
 		val &= ~(WUCSR_WUEN | WUCSR_MPEN | WUCSR_PFDA_EN
 			| WUCSR_BCST_EN);
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing WUCSR\n");
+			return ret;
+		}
 
 		/* clear wake-up status */
 		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
-		check_warn_return(ret, "Error reading PMT_CTL\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading PMT_CTL\n");
+			return ret;
+		}
 
 		val &= ~PMT_CTL_WOL_EN;
 		val |= PMT_CTL_WUPS;
 
 		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-		check_warn_return(ret, "Error writing PMT_CTL\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing PMT_CTL\n");
+			return ret;
+		}
 	}
 
 	if (suspend_flags & SUSPEND_SUSPEND2) {
 		netdev_info(dev->net, "resuming from SUSPEND2\n");
 
 		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
-		check_warn_return(ret, "Error reading PMT_CTL\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading PMT_CTL\n");
+			return ret;
+		}
 
 		val |= PMT_CTL_PHY_PWRUP;
 
 		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-		check_warn_return(ret, "Error writing PMT_CTL\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing PMT_CTL\n");
+			return ret;
+		}
 	}
 
 	ret = smsc75xx_wait_ready(dev, 1);
-	check_warn_return(ret, "device not ready in smsc75xx_resume\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "device not ready in smsc75xx_resume\n");
+		return ret;
+	}
 
 	return usbnet_resume(intf);
 }
-- 
1.7.10.4
