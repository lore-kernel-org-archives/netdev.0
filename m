From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 5/5] smsc95xx: expand check_ macros
Date: Fri, 30 Nov 2012 15:55:52 +0000
Message-ID: <1354290952-27109-6-git-send-email-steve.glendinning@shawell.net>
References: <1354290952-27109-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:47841 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030987Ab2K3P4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 10:56:04 -0500
In-Reply-To: <1354290952-27109-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These macros, while reducing the amount of code, hide flow control
and make the code more confusing to follow and review.  This patch
expands them.  It should have no functional effect on the driver.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |  512 +++++++++++++++++++++++++++++++++-----------
 1 file changed, 391 insertions(+), 121 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index b9eb490..f7e1e18 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -55,15 +55,6 @@
 #define FEATURE_PHY_NLP_CROSSOVER	(0x02)
 #define FEATURE_AUTOSUSPEND		(0x04)
 
-#define check_warn(ret, fmt, args...) \
-	({ if (ret < 0) netdev_warn(dev->net, fmt, ##args); })
-
-#define check_warn_return(ret, fmt, args...) \
-	({ if (ret < 0) { netdev_warn(dev->net, fmt, ##args); return ret; } })
-
-#define check_warn_goto_done(ret, fmt, args...) \
-	({ if (ret < 0) { netdev_warn(dev->net, fmt, ##args); goto done; } })
-
 struct smsc95xx_priv {
 	u32 mac_cr;
 	u32 hash_hi;
@@ -166,7 +157,11 @@ static int __must_check __smsc95xx_phy_wait_not_busy(struct usbnet *dev,
 
 	do {
 		ret = __smsc95xx_read_reg(dev, MII_ADDR, &val, in_pm);
-		check_warn_return(ret, "Error reading MII_ACCESS\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading MII_ACCESS\n");
+			return ret;
+		}
+
 		if (!(val & MII_BUSY_))
 			return 0;
 	} while (!time_after(jiffies, start_time + HZ));
@@ -185,20 +180,32 @@ static int __smsc95xx_mdio_read(struct net_device *netdev, int phy_id, int idx,
 
 	/* confirm MII not busy */
 	ret = __smsc95xx_phy_wait_not_busy(dev, in_pm);
-	check_warn_goto_done(ret, "MII is busy in smsc95xx_mdio_read\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "MII is busy in smsc95xx_mdio_read\n");
+		goto done;
+	}
 
 	/* set the address, index & direction (read from PHY) */
 	phy_id &= dev->mii.phy_id_mask;
 	idx &= dev->mii.reg_num_mask;
 	addr = (phy_id << 11) | (idx << 6) | MII_READ_ | MII_BUSY_;
 	ret = __smsc95xx_write_reg(dev, MII_ADDR, addr, in_pm);
-	check_warn_goto_done(ret, "Error writing MII_ADDR\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing MII_ADDR\n");
+		goto done;
+	}
 
 	ret = __smsc95xx_phy_wait_not_busy(dev, in_pm);
-	check_warn_goto_done(ret, "Timed out reading MII reg %02X\n", idx);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Timed out reading MII reg %02X\n", idx);
+		goto done;
+	}
 
 	ret = __smsc95xx_read_reg(dev, MII_DATA, &val, in_pm);
-	check_warn_goto_done(ret, "Error reading MII_DATA\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading MII_DATA\n");
+		goto done;
+	}
 
 	ret = (u16)(val & 0xFFFF);
 
@@ -218,21 +225,33 @@ static void __smsc95xx_mdio_write(struct net_device *netdev, int phy_id,
 
 	/* confirm MII not busy */
 	ret = __smsc95xx_phy_wait_not_busy(dev, in_pm);
-	check_warn_goto_done(ret, "MII is busy in smsc95xx_mdio_write\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "MII is busy in smsc95xx_mdio_write\n");
+		goto done;
+	}
 
 	val = regval;
 	ret = __smsc95xx_write_reg(dev, MII_DATA, val, in_pm);
-	check_warn_goto_done(ret, "Error writing MII_DATA\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing MII_DATA\n");
+		goto done;
+	}
 
 	/* set the address, index & direction (write to PHY) */
 	phy_id &= dev->mii.phy_id_mask;
 	idx &= dev->mii.reg_num_mask;
 	addr = (phy_id << 11) | (idx << 6) | MII_WRITE_ | MII_BUSY_;
 	ret = __smsc95xx_write_reg(dev, MII_ADDR, addr, in_pm);
-	check_warn_goto_done(ret, "Error writing MII_ADDR\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing MII_ADDR\n");
+		goto done;
+	}
 
 	ret = __smsc95xx_phy_wait_not_busy(dev, in_pm);
-	check_warn_goto_done(ret, "Timed out writing MII reg %02X\n", idx);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Timed out writing MII reg %02X\n", idx);
+		goto done;
+	}
 
 done:
 	mutex_unlock(&dev->phy_mutex);
@@ -269,7 +288,11 @@ static int __must_check smsc95xx_wait_eeprom(struct usbnet *dev)
 
 	do {
 		ret = smsc95xx_read_reg(dev, E2P_CMD, &val);
-		check_warn_return(ret, "Error reading E2P_CMD\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading E2P_CMD\n");
+			return ret;
+		}
+
 		if (!(val & E2P_CMD_BUSY_) || (val & E2P_CMD_TIMEOUT_))
 			break;
 		udelay(40);
@@ -291,7 +314,10 @@ static int __must_check smsc95xx_eeprom_confirm_not_busy(struct usbnet *dev)
 
 	do {
 		ret = smsc95xx_read_reg(dev, E2P_CMD, &val);
-		check_warn_return(ret, "Error reading E2P_CMD\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading E2P_CMD\n");
+			return ret;
+		}
 
 		if (!(val & E2P_CMD_BUSY_))
 			return 0;
@@ -319,14 +345,20 @@ static int smsc95xx_read_eeprom(struct usbnet *dev, u32 offset, u32 length,
 	for (i = 0; i < length; i++) {
 		val = E2P_CMD_BUSY_ | E2P_CMD_READ_ | (offset & E2P_CMD_ADDR_);
 		ret = smsc95xx_write_reg(dev, E2P_CMD, val);
-		check_warn_return(ret, "Error writing E2P_CMD\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing E2P_CMD\n");
+			return ret;
+		}
 
 		ret = smsc95xx_wait_eeprom(dev);
 		if (ret < 0)
 			return ret;
 
 		ret = smsc95xx_read_reg(dev, E2P_DATA, &val);
-		check_warn_return(ret, "Error reading E2P_DATA\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading E2P_DATA\n");
+			return ret;
+		}
 
 		data[i] = val & 0xFF;
 		offset++;
@@ -351,7 +383,10 @@ static int smsc95xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 	/* Issue write/erase enable command */
 	val = E2P_CMD_BUSY_ | E2P_CMD_EWEN_;
 	ret = smsc95xx_write_reg(dev, E2P_CMD, val);
-	check_warn_return(ret, "Error writing E2P_DATA\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing E2P_DATA\n");
+		return ret;
+	}
 
 	ret = smsc95xx_wait_eeprom(dev);
 	if (ret < 0)
@@ -362,12 +397,18 @@ static int smsc95xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 		/* Fill data register */
 		val = data[i];
 		ret = smsc95xx_write_reg(dev, E2P_DATA, val);
-		check_warn_return(ret, "Error writing E2P_DATA\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing E2P_DATA\n");
+			return ret;
+		}
 
 		/* Send "write" command */
 		val = E2P_CMD_BUSY_ | E2P_CMD_WRITE_ | (offset & E2P_CMD_ADDR_);
 		ret = smsc95xx_write_reg(dev, E2P_CMD, val);
-		check_warn_return(ret, "Error writing E2P_CMD\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing E2P_CMD\n");
+			return ret;
+		}
 
 		ret = smsc95xx_wait_eeprom(dev);
 		if (ret < 0)
@@ -450,13 +491,16 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 
 	/* Initiate async writes, as we can't wait for completion here */
 	ret = smsc95xx_write_reg_async(dev, HASHH, &pdata->hash_hi);
-	check_warn(ret, "failed to initiate async write to HASHH\n");
+	if (ret < 0)
+		netdev_warn(dev->net, "failed to initiate async write to HASHH\n");
 
 	ret = smsc95xx_write_reg_async(dev, HASHL, &pdata->hash_lo);
-	check_warn(ret, "failed to initiate async write to HASHL\n");
+	if (ret < 0)
+		netdev_warn(dev->net, "failed to initiate async write to HASHL\n");
 
 	ret = smsc95xx_write_reg_async(dev, MAC_CR, &pdata->mac_cr);
-	check_warn(ret, "failed to initiate async write to MAC_CR\n");
+	if (ret < 0)
+		netdev_warn(dev->net, "failed to initiate async write to MAC_CR\n");
 }
 
 static int smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
@@ -465,7 +509,10 @@ static int smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
 	u32 flow, afc_cfg = 0;
 
 	int ret = smsc95xx_read_reg(dev, AFC_CFG, &afc_cfg);
-	check_warn_return(ret, "Error reading AFC_CFG\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading AFC_CFG\n");
+		return ret;
+	}
 
 	if (duplex == DUPLEX_FULL) {
 		u8 cap = mii_resolve_flowctrl_fdx(lcladv, rmtadv);
@@ -490,12 +537,16 @@ static int smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
 	}
 
 	ret = smsc95xx_write_reg(dev, FLOW, flow);
-	check_warn_return(ret, "Error writing FLOW\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing FLOW\n");
+		return ret;
+	}
 
 	ret = smsc95xx_write_reg(dev, AFC_CFG, afc_cfg);
-	check_warn_return(ret, "Error writing AFC_CFG\n");
+	if (ret < 0)
+		netdev_warn(dev->net, "Error writing AFC_CFG\n");
 
-	return 0;
+	return ret;
 }
 
 static int smsc95xx_link_reset(struct usbnet *dev)
@@ -509,10 +560,16 @@ static int smsc95xx_link_reset(struct usbnet *dev)
 
 	/* clear interrupt status */
 	ret = smsc95xx_mdio_read(dev->net, mii->phy_id, PHY_INT_SRC);
-	check_warn_return(ret, "Error reading PHY_INT_SRC\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading PHY_INT_SRC\n");
+		return ret;
+	}
 
 	ret = smsc95xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL_);
-	check_warn_return(ret, "Error writing INT_STS\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing INT_STS\n");
+		return ret;
+	}
 
 	mii_check_media(mii, 1, 1);
 	mii_ethtool_gset(&dev->mii, &ecmd);
@@ -534,12 +591,16 @@ static int smsc95xx_link_reset(struct usbnet *dev)
 	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
 
 	ret = smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr);
-	check_warn_return(ret, "Error writing MAC_CR\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing MAC_CR\n");
+		return ret;
+	}
 
 	ret = smsc95xx_phy_update_flowcontrol(dev, ecmd.duplex, lcladv, rmtadv);
-	check_warn_return(ret, "Error updating PHY flow control\n");
+	if (ret < 0)
+		netdev_warn(dev->net, "Error updating PHY flow control\n");
 
-	return 0;
+	return ret;
 }
 
 static void smsc95xx_status(struct usbnet *dev, struct urb *urb)
@@ -573,7 +634,10 @@ static int smsc95xx_set_features(struct net_device *netdev,
 	int ret;
 
 	ret = smsc95xx_read_reg(dev, COE_CR, &read_buf);
-	check_warn_return(ret, "Failed to read COE_CR: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read COE_CR: %d\n", ret);
+		return ret;
+	}
 
 	if (features & NETIF_F_HW_CSUM)
 		read_buf |= Tx_COE_EN_;
@@ -586,7 +650,10 @@ static int smsc95xx_set_features(struct net_device *netdev,
 		read_buf &= ~Rx_COE_EN_;
 
 	ret = smsc95xx_write_reg(dev, COE_CR, read_buf);
-	check_warn_return(ret, "Failed to write COE_CR: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write COE_CR: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, hw, dev->net, "COE_CR = 0x%08x\n", read_buf);
 	return 0;
@@ -671,9 +738,10 @@ static int smsc95xx_ethtool_set_wol(struct net_device *net,
 	pdata->wolopts = wolinfo->wolopts & SUPPORTED_WAKE;
 
 	ret = device_set_wakeup_enable(&dev->udev->dev, pdata->wolopts);
-	check_warn_return(ret, "device_set_wakeup_enable error %d\n", ret);
+	if (ret < 0)
+		netdev_warn(dev->net, "device_set_wakeup_enable error %d\n", ret);
 
-	return 0;
+	return ret;
 }
 
 static const struct ethtool_ops smsc95xx_ethtool_ops = {
@@ -728,12 +796,16 @@ static int smsc95xx_set_mac_address(struct usbnet *dev)
 	int ret;
 
 	ret = smsc95xx_write_reg(dev, ADDRL, addr_lo);
-	check_warn_return(ret, "Failed to write ADDRL: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write ADDRL: %d\n", ret);
+		return ret;
+	}
 
 	ret = smsc95xx_write_reg(dev, ADDRH, addr_hi);
-	check_warn_return(ret, "Failed to write ADDRH: %d\n", ret);
+	if (ret < 0)
+		netdev_warn(dev->net, "Failed to write ADDRH: %d\n", ret);
 
-	return 0;
+	return ret;
 }
 
 /* starts the TX path */
@@ -749,13 +821,17 @@ static int smsc95xx_start_tx_path(struct usbnet *dev)
 	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
 
 	ret = smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr);
-	check_warn_return(ret, "Failed to write MAC_CR: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write MAC_CR: %d\n", ret);
+		return ret;
+	}
 
 	/* Enable Tx at SCSRs */
 	ret = smsc95xx_write_reg(dev, TX_CFG, TX_CFG_ON_);
-	check_warn_return(ret, "Failed to write TX_CFG: %d\n", ret);
+	if (ret < 0)
+		netdev_warn(dev->net, "Failed to write TX_CFG: %d\n", ret);
 
-	return 0;
+	return ret;
 }
 
 /* Starts the Receive path */
@@ -770,9 +846,10 @@ static int smsc95xx_start_rx_path(struct usbnet *dev, int in_pm)
 	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
 
 	ret = __smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr, in_pm);
-	check_warn_return(ret, "Failed to write MAC_CR: %d\n", ret);
+	if (ret < 0)
+		netdev_warn(dev->net, "Failed to write MAC_CR: %d\n", ret);
 
-	return 0;
+	return ret;
 }
 
 static int smsc95xx_phy_initialize(struct usbnet *dev)
@@ -807,7 +884,10 @@ static int smsc95xx_phy_initialize(struct usbnet *dev)
 
 	/* read to clear */
 	ret = smsc95xx_mdio_read(dev->net, dev->mii.phy_id, PHY_INT_SRC);
-	check_warn_return(ret, "Failed to read PHY_INT_SRC during init\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read PHY_INT_SRC during init\n");
+		return ret;
+	}
 
 	smsc95xx_mdio_write(dev->net, dev->mii.phy_id, PHY_INT_MASK,
 		PHY_INT_MASK_DEFAULT_);
@@ -826,13 +906,19 @@ static int smsc95xx_reset(struct usbnet *dev)
 	netif_dbg(dev, ifup, dev->net, "entering smsc95xx_reset\n");
 
 	ret = smsc95xx_write_reg(dev, HW_CFG, HW_CFG_LRST_);
-	check_warn_return(ret, "Failed to write HW_CFG_LRST_ bit in HW_CFG\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write HW_CFG_LRST_ bit in HW_CFG\n");
+		return ret;
+	}
 
 	timeout = 0;
 	do {
 		msleep(10);
 		ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
-		check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
+		if (ret < 0) {
+			netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
+			return ret;
+		}
 		timeout++;
 	} while ((read_buf & HW_CFG_LRST_) && (timeout < 100));
 
@@ -842,13 +928,19 @@ static int smsc95xx_reset(struct usbnet *dev)
 	}
 
 	ret = smsc95xx_write_reg(dev, PM_CTRL, PM_CTL_PHY_RST_);
-	check_warn_return(ret, "Failed to write PM_CTRL: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write PM_CTRL: %d\n", ret);
+		return ret;
+	}
 
 	timeout = 0;
 	do {
 		msleep(10);
 		ret = smsc95xx_read_reg(dev, PM_CTRL, &read_buf);
-		check_warn_return(ret, "Failed to read PM_CTRL: %d\n", ret);
+		if (ret < 0) {
+			netdev_warn(dev->net, "Failed to read PM_CTRL: %d\n", ret);
+			return ret;
+		}
 		timeout++;
 	} while ((read_buf & PM_CTL_PHY_RST_) && (timeout < 100));
 
@@ -865,7 +957,10 @@ static int smsc95xx_reset(struct usbnet *dev)
 		  dev->net->dev_addr);
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
-	check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net, "Read Value from HW_CFG : 0x%08x\n",
 		  read_buf);
@@ -873,10 +968,17 @@ static int smsc95xx_reset(struct usbnet *dev)
 	read_buf |= HW_CFG_BIR_;
 
 	ret = smsc95xx_write_reg(dev, HW_CFG, read_buf);
-	check_warn_return(ret, "Failed to write HW_CFG_BIR_ bit in HW_CFG\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write HW_CFG_BIR_ bit in HW_CFG\n");
+		return ret;
+	}
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
-	check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
+		return ret;
+	}
+
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from HW_CFG after writing HW_CFG_BIR_: 0x%08x\n",
 		  read_buf);
@@ -896,27 +998,42 @@ static int smsc95xx_reset(struct usbnet *dev)
 		  (ulong)dev->rx_urb_size);
 
 	ret = smsc95xx_write_reg(dev, BURST_CAP, burst_cap);
-	check_warn_return(ret, "Failed to write BURST_CAP: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write BURST_CAP: %d\n", ret);
+		return ret;
+	}
 
 	ret = smsc95xx_read_reg(dev, BURST_CAP, &read_buf);
-	check_warn_return(ret, "Failed to read BURST_CAP: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read BURST_CAP: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from BURST_CAP after writing: 0x%08x\n",
 		  read_buf);
 
 	ret = smsc95xx_write_reg(dev, BULK_IN_DLY, DEFAULT_BULK_IN_DELAY);
-	check_warn_return(ret, "Failed to write BULK_IN_DLY: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write BULK_IN_DLY: %d\n", ret);
+		return ret;
+	}
 
 	ret = smsc95xx_read_reg(dev, BULK_IN_DLY, &read_buf);
-	check_warn_return(ret, "Failed to read BULK_IN_DLY: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read BULK_IN_DLY: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from BULK_IN_DLY after writing: 0x%08x\n",
 		  read_buf);
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
-	check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net, "Read Value from HW_CFG: 0x%08x\n",
 		  read_buf);
@@ -930,66 +1047,111 @@ static int smsc95xx_reset(struct usbnet *dev)
 	read_buf |= NET_IP_ALIGN << 9;
 
 	ret = smsc95xx_write_reg(dev, HW_CFG, read_buf);
-	check_warn_return(ret, "Failed to write HW_CFG: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write HW_CFG: %d\n", ret);
+		return ret;
+	}
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
-	check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from HW_CFG after writing: 0x%08x\n", read_buf);
 
 	ret = smsc95xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL_);
-	check_warn_return(ret, "Failed to write INT_STS: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write INT_STS: %d\n", ret);
+		return ret;
+	}
 
 	ret = smsc95xx_read_reg(dev, ID_REV, &read_buf);
-	check_warn_return(ret, "Failed to read ID_REV: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read ID_REV: %d\n", ret);
+		return ret;
+	}
 	netif_dbg(dev, ifup, dev->net, "ID_REV = 0x%08x\n", read_buf);
 
 	/* Configure GPIO pins as LED outputs */
 	write_buf = LED_GPIO_CFG_SPD_LED | LED_GPIO_CFG_LNK_LED |
 		LED_GPIO_CFG_FDX_LED;
 	ret = smsc95xx_write_reg(dev, LED_GPIO_CFG, write_buf);
-	check_warn_return(ret, "Failed to write LED_GPIO_CFG: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write LED_GPIO_CFG: %d\n", ret);
+		return ret;
+	}
 
 	/* Init Tx */
 	ret = smsc95xx_write_reg(dev, FLOW, 0);
-	check_warn_return(ret, "Failed to write FLOW: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write FLOW: %d\n", ret);
+		return ret;
+	}
 
 	ret = smsc95xx_write_reg(dev, AFC_CFG, AFC_CFG_DEFAULT);
-	check_warn_return(ret, "Failed to write AFC_CFG: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write AFC_CFG: %d\n", ret);
+		return ret;
+	}
 
 	/* Don't need mac_cr_lock during initialisation */
 	ret = smsc95xx_read_reg(dev, MAC_CR, &pdata->mac_cr);
-	check_warn_return(ret, "Failed to read MAC_CR: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read MAC_CR: %d\n", ret);
+		return ret;
+	}
 
 	/* Init Rx */
 	/* Set Vlan */
 	ret = smsc95xx_write_reg(dev, VLAN1, (u32)ETH_P_8021Q);
-	check_warn_return(ret, "Failed to write VLAN1: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write VLAN1: %d\n", ret);
+		return ret;
+	}
 
 	/* Enable or disable checksum offload engines */
 	ret = smsc95xx_set_features(dev->net, dev->net->features);
-	check_warn_return(ret, "Failed to set checksum offload features\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to set checksum offload features\n");
+		return ret;
+	}
 
 	smsc95xx_set_multicast(dev->net);
 
 	ret = smsc95xx_phy_initialize(dev);
-	check_warn_return(ret, "Failed to init PHY\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to init PHY\n");
+		return ret;
+	}
 
 	ret = smsc95xx_read_reg(dev, INT_EP_CTL, &read_buf);
-	check_warn_return(ret, "Failed to read INT_EP_CTL: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read INT_EP_CTL: %d\n", ret);
+		return ret;
+	}
 
 	/* enable PHY interrupts */
 	read_buf |= INT_EP_CTL_PHY_INT_;
 
 	ret = smsc95xx_write_reg(dev, INT_EP_CTL, read_buf);
-	check_warn_return(ret, "Failed to write INT_EP_CTL: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to write INT_EP_CTL: %d\n", ret);
+		return ret;
+	}
 
 	ret = smsc95xx_start_tx_path(dev);
-	check_warn_return(ret, "Failed to start TX path\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to start TX path\n");
+		return ret;
+	}
 
 	ret = smsc95xx_start_rx_path(dev, 0);
-	check_warn_return(ret, "Failed to start RX path\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to start RX path\n");
+		return ret;
+	}
 
 	netif_dbg(dev, ifup, dev->net, "smsc95xx_reset, return 0\n");
 	return 0;
@@ -1017,7 +1179,10 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	printk(KERN_INFO SMSC_CHIPNAME " v" SMSC_DRIVER_VERSION "\n");
 
 	ret = usbnet_get_endpoints(dev, intf);
-	check_warn_return(ret, "usbnet_get_endpoints failed: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "usbnet_get_endpoints failed: %d\n", ret);
+		return ret;
+	}
 
 	dev->data[0] = (unsigned long)kzalloc(sizeof(struct smsc95xx_priv),
 		GFP_KERNEL);
@@ -1044,7 +1209,10 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	/* detect device revision as different features may be available */
 	ret = smsc95xx_read_reg(dev, ID_REV, &val);
-	check_warn_return(ret, "Failed to read ID_REV: %d\n", ret);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read ID_REV: %d\n", ret);
+		return ret;
+	}
 	val >>= 16;
 
 	if ((val == ID_REV_CHIP_ID_9500A_) || (val == ID_REV_CHIP_ID_9530_) ||
@@ -1089,11 +1257,17 @@ static int smsc95xx_enable_phy_wakeup_interrupts(struct usbnet *dev, u16 mask)
 
 	/* read to clear */
 	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, PHY_INT_SRC);
-	check_warn_return(ret, "Error reading PHY_INT_SRC\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading PHY_INT_SRC\n");
+		return ret;
+	}
 
 	/* enable interrupt source */
 	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, PHY_INT_MASK);
-	check_warn_return(ret, "Error reading PHY_INT_MASK\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading PHY_INT_MASK\n");
+		return ret;
+	}
 
 	ret |= mask;
 
@@ -1109,10 +1283,16 @@ static int smsc95xx_link_ok_nopm(struct usbnet *dev)
 
 	/* first, a dummy read, needed to latch some MII phys */
 	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, MII_BMSR);
-	check_warn_return(ret, "Error reading MII_BMSR\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading MII_BMSR\n");
+		return ret;
+	}
 
 	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, MII_BMSR);
-	check_warn_return(ret, "Error reading MII_BMSR\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading MII_BMSR\n");
+		return ret;
+	}
 
 	return !!(ret & BMSR_LSTATUS);
 }
@@ -1124,13 +1304,19 @@ static int smsc95xx_enter_suspend0(struct usbnet *dev)
 	int ret;
 
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	check_warn_return(ret, "Error reading PM_CTRL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading PM_CTRL\n");
+		return ret;
+	}
 
 	val &= (~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_));
 	val |= PM_CTL_SUS_MODE_0;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	check_warn_return(ret, "Error writing PM_CTRL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing PM_CTRL\n");
+		return ret;
+	}
 
 	/* clear wol status */
 	val &= ~PM_CTL_WUPS_;
@@ -1141,13 +1327,17 @@ static int smsc95xx_enter_suspend0(struct usbnet *dev)
 		val |= PM_CTL_WUPS_ED_;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	check_warn_return(ret, "Error writing PM_CTRL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing PM_CTRL\n");
+		return ret;
+	}
 
 	/* read back PM_CTRL */
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	check_warn_return(ret, "Error reading PM_CTRL\n");
+	if (ret < 0)
+		netdev_warn(dev->net, "Error reading PM_CTRL\n");
 
-	return 0;
+	return ret;
 }
 
 static int smsc95xx_enter_suspend1(struct usbnet *dev)
@@ -1166,7 +1356,10 @@ static int smsc95xx_enter_suspend1(struct usbnet *dev)
 
 	/* enable energy detect power-down mode */
 	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, PHY_MODE_CTRL_STS);
-	check_warn_return(ret, "Error reading PHY_MODE_CTRL_STS\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading PHY_MODE_CTRL_STS\n");
+		return ret;
+	}
 
 	ret |= MODE_CTRL_STS_EDPWRDOWN_;
 
@@ -1174,22 +1367,29 @@ static int smsc95xx_enter_suspend1(struct usbnet *dev)
 
 	/* enter SUSPEND1 mode */
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	check_warn_return(ret, "Error reading PM_CTRL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading PM_CTRL\n");
+		return ret;
+	}
 
 	val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
 	val |= PM_CTL_SUS_MODE_1;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	check_warn_return(ret, "Error writing PM_CTRL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing PM_CTRL\n");
+		return ret;
+	}
 
 	/* clear wol status, enable energy detection */
 	val &= ~PM_CTL_WUPS_;
 	val |= (PM_CTL_WUPS_ED_ | PM_CTL_ED_EN_);
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	check_warn_return(ret, "Error writing PM_CTRL\n");
+	if (ret < 0)
+		netdev_warn(dev->net, "Error writing PM_CTRL\n");
 
-	return 0;
+	return ret;
 }
 
 static int smsc95xx_enter_suspend2(struct usbnet *dev)
@@ -1198,15 +1398,19 @@ static int smsc95xx_enter_suspend2(struct usbnet *dev)
 	int ret;
 
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	check_warn_return(ret, "Error reading PM_CTRL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading PM_CTRL\n");
+		return ret;
+	}
 
 	val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
 	val |= PM_CTL_SUS_MODE_2;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	check_warn_return(ret, "Error writing PM_CTRL\n");
+	if (ret < 0)
+		netdev_warn(dev->net, "Error writing PM_CTRL\n");
 
-	return 0;
+	return ret;
 }
 
 static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
@@ -1217,7 +1421,10 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	int ret;
 
 	ret = usbnet_suspend(intf, message);
-	check_warn_return(ret, "usbnet_suspend error\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "usbnet_suspend error\n");
+		return ret;
+	}
 
 	/* determine if link is up using only _nopm functions */
 	link_up = smsc95xx_link_ok_nopm(dev);
@@ -1231,20 +1438,32 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 		/* disable energy detect (link up) & wake up events */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_goto_done(ret, "Error reading WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading WUCSR\n");
+			goto done;
+		}
 
 		val &= ~(WUCSR_MPEN_ | WUCSR_WAKE_EN_);
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_goto_done(ret, "Error writing WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing WUCSR\n");
+			goto done;
+		}
 
 		ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-		check_warn_goto_done(ret, "Error reading PM_CTRL\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading PM_CTRL\n");
+			goto done;
+		}
 
 		val &= ~(PM_CTL_ED_EN_ | PM_CTL_WOL_EN_);
 
 		ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-		check_warn_goto_done(ret, "Error writing PM_CTRL\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing PM_CTRL\n");
+			goto done;
+		}
 
 		ret = smsc95xx_enter_suspend2(dev);
 		goto done;
@@ -1253,7 +1472,10 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	if (pdata->wolopts & WAKE_PHY) {
 		ret = smsc95xx_enable_phy_wakeup_interrupts(dev,
 			(PHY_INT_MASK_ANEG_COMP_ | PHY_INT_MASK_LINK_DOWN_));
-		check_warn_goto_done(ret, "error enabling PHY wakeup ints\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "error enabling PHY wakeup ints\n");
+			goto done;
+		}
 
 		/* if link is down then configure EDPD and enter SUSPEND1,
 		 * otherwise enter SUSPEND0 below
@@ -1338,51 +1560,77 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 		for (i = 0; i < (wuff_filter_count * 4); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, filter_mask[i]);
-			if (ret < 0)
+			if (ret < 0) {
+				netdev_warn(dev->net, "Error writing WUFF\n");
 				kfree(filter_mask);
-			check_warn_goto_done(ret, "Error writing WUFF\n");
+				goto done;
+			}
 		}
 		kfree(filter_mask);
 
 		for (i = 0; i < (wuff_filter_count / 4); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, command[i]);
-			check_warn_goto_done(ret, "Error writing WUFF\n");
+			if (ret < 0) {
+				netdev_warn(dev->net, "Error writing WUFF\n");
+				goto done;
+			}
 		}
 
 		for (i = 0; i < (wuff_filter_count / 4); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, offset[i]);
-			check_warn_goto_done(ret, "Error writing WUFF\n");
+			if (ret < 0) {
+				netdev_warn(dev->net, "Error writing WUFF\n");
+				goto done;
+			}
 		}
 
 		for (i = 0; i < (wuff_filter_count / 2); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, crc[i]);
-			check_warn_goto_done(ret, "Error writing WUFF\n");
+			if (ret < 0) {
+				netdev_warn(dev->net, "Error writing WUFF\n");
+				goto done;
+			}
 		}
 
 		/* clear any pending pattern match packet status */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_goto_done(ret, "Error reading WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading WUCSR\n");
+			goto done;
+		}
 
 		val |= WUCSR_WUFR_;
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_goto_done(ret, "Error writing WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing WUCSR\n");
+			goto done;
+		}
 	}
 
 	if (pdata->wolopts & WAKE_MAGIC) {
 		/* clear any pending magic packet status */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_goto_done(ret, "Error reading WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading WUCSR\n");
+			goto done;
+		}
 
 		val |= WUCSR_MPR_;
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_goto_done(ret, "Error writing WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing WUCSR\n");
+			goto done;
+		}
 	}
 
 	/* enable/disable wakeup sources */
 	ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-	check_warn_goto_done(ret, "Error reading WUCSR\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading WUCSR\n");
+		goto done;
+	}
 
 	if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
 		netdev_info(dev->net, "enabling pattern match wakeup\n");
@@ -1401,11 +1649,17 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	}
 
 	ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-	check_warn_goto_done(ret, "Error writing WUCSR\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing WUCSR\n");
+		goto done;
+	}
 
 	/* enable wol wakeup source */
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	check_warn_goto_done(ret, "Error reading PM_CTRL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error reading PM_CTRL\n");
+		goto done;
+	}
 
 	val |= PM_CTL_WOL_EN_;
 
@@ -1414,7 +1668,10 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 		val |= PM_CTL_ED_EN_;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	check_warn_goto_done(ret, "Error writing PM_CTRL\n");
+	if (ret < 0) {
+		netdev_warn(dev->net, "Error writing PM_CTRL\n");
+		goto done;
+	}
 
 	/* enable receiver to enable frame reception */
 	smsc95xx_start_rx_path(dev, 1);
@@ -1441,28 +1698,41 @@ static int smsc95xx_resume(struct usb_interface *intf)
 	if (pdata->wolopts) {
 		/* clear wake-up sources */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading WUCSR\n");
+			return ret;
+		}
 
 		val &= ~(WUCSR_WAKE_EN_ | WUCSR_MPEN_);
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing WUCSR\n");
+			return ret;
+		}
 
 		/* clear wake-up status */
 		ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-		check_warn_return(ret, "Error reading PM_CTRL\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error reading PM_CTRL\n");
+			return ret;
+		}
 
 		val &= ~PM_CTL_WOL_EN_;
 		val |= PM_CTL_WUPS_;
 
 		ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-		check_warn_return(ret, "Error writing PM_CTRL\n");
+		if (ret < 0) {
+			netdev_warn(dev->net, "Error writing PM_CTRL\n");
+			return ret;
+		}
 	}
 
 	ret = usbnet_resume(intf);
-	check_warn_return(ret, "usbnet_resume error\n");
+	if (ret < 0)
+		netdev_warn(dev->net, "usbnet_resume error\n");
 
-	return 0;
+	return ret;
 }
 
 static void smsc95xx_rx_csum_offload(struct sk_buff *skb)
-- 
1.7.10.4
