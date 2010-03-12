From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 5/6] smsc95xx: check return code from control messages
Date: Fri, 12 Mar 2010 13:35:07 +0000
Message-ID: <1268400907-25309-1-git-send-email-steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 77-44-110-64.xdsl.murphx.net ([77.44.110.64]:47422 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753990Ab0CLNfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Mar 2010 08:35:13 -0500
Received: from localhost.localdomain (unknown [10.0.20.109])
	by drevil2.shawell.net (Postfix) with ESMTP id EACB467B9E
	for <netdev@vger.kernel.org>; Fri, 12 Mar 2010 13:35:07 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds additional checks of the values returned by
smsc95xx_(read|write)_reg, and wraps their common patterns
in macros.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |  302 +++++++++++++++++++-------------------------
 1 files changed, 128 insertions(+), 174 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 56fe73d..fb50d58 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -47,6 +47,15 @@
 #define SMSC95XX_TX_OVERHEAD_CSUM	(12)
 #define USB_VENDOR_ID_SMSC		(0x0424)
 
+#define check_warn(ret, fmt, args...) \
+	({ if (ret < 0) netdev_warn(dev->net, fmt, ##args); })
+
+#define check_warn_return(ret, fmt, args...) \
+	({ if (ret < 0) { netdev_warn(dev->net, fmt, ##args); return ret; } })
+
+#define check_warn_goto_done(ret, fmt, args...) \
+	({ if (ret < 0) { netdev_warn(dev->net, fmt, ##args); goto done; } })
+
 struct smsc95xx_priv {
 	u32 mac_cr;
 	spinlock_t mac_cr_lock;
@@ -63,7 +72,8 @@ static int turbo_mode = true;
 module_param(turbo_mode, bool, 0644);
 MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx transaction");
 
-static int smsc95xx_read_reg(struct usbnet *dev, u32 index, u32 *data)
+static int __must_check smsc95xx_read_reg(struct usbnet *dev, u32 index,
+					  u32 *data)
 {
 	u32 *buf = kmalloc(4, GFP_KERNEL);
 	int ret;
@@ -88,7 +98,8 @@ static int smsc95xx_read_reg(struct usbnet *dev, u32 index, u32 *data)
 	return ret;
 }
 
-static int smsc95xx_write_reg(struct usbnet *dev, u32 index, u32 data)
+static int __must_check smsc95xx_write_reg(struct usbnet *dev, u32 index,
+					   u32 data)
 {
 	u32 *buf = kmalloc(4, GFP_KERNEL);
 	int ret;
@@ -120,9 +131,12 @@ static int smsc95xx_phy_wait_not_busy(struct usbnet *dev)
 {
 	unsigned long start_time = jiffies;
 	u32 val;
+	int ret;
 
 	do {
-		smsc95xx_read_reg(dev, MII_ADDR, &val);
+		ret = smsc95xx_read_reg(dev, MII_ADDR, &val);
+		check_warn_return(ret, "Error reading MII_ACCESS");
+
 		if (!(val & MII_BUSY_))
 			return 0;
 	} while (!time_after(jiffies, start_time + HZ));
@@ -134,33 +148,32 @@ static int smsc95xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
 {
 	struct usbnet *dev = netdev_priv(netdev);
 	u32 val, addr;
+	int ret;
 
 	mutex_lock(&dev->phy_mutex);
 
 	/* confirm MII not busy */
-	if (smsc95xx_phy_wait_not_busy(dev)) {
-		netdev_warn(dev->net, "MII is busy in smsc95xx_mdio_read\n");
-		mutex_unlock(&dev->phy_mutex);
-		return -EIO;
-	}
+	ret = smsc95xx_phy_wait_not_busy(dev);
+	check_warn_goto_done(ret, "MII is busy in smsc95xx_mdio_read");
 
 	/* set the address, index & direction (read from PHY) */
 	phy_id &= dev->mii.phy_id_mask;
 	idx &= dev->mii.reg_num_mask;
 	addr = (phy_id << 11) | (idx << 6) | MII_READ_;
-	smsc95xx_write_reg(dev, MII_ADDR, addr);
+	ret = smsc95xx_write_reg(dev, MII_ADDR, addr);
+	check_warn_goto_done(ret, "Error writing MII_ACCESS");
 
-	if (smsc95xx_phy_wait_not_busy(dev)) {
-		netdev_warn(dev->net, "Timed out reading MII reg %02X\n", idx);
-		mutex_unlock(&dev->phy_mutex);
-		return -EIO;
-	}
+	ret = smsc95xx_phy_wait_not_busy(dev);
+	check_warn_goto_done(ret, "Timed out reading MII reg %02X", idx);
 
-	smsc95xx_read_reg(dev, MII_DATA, &val);
+	ret = smsc95xx_read_reg(dev, MII_DATA, &val);
+	check_warn_goto_done(ret, "Error reading MII_DATA");
 
-	mutex_unlock(&dev->phy_mutex);
+	ret = (u16)(val & 0xFFFF);
 
-	return (u16)(val & 0xFFFF);
+done:
+	mutex_unlock(&dev->phy_mutex);
+	return ret;
 }
 
 static void smsc95xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
@@ -168,28 +181,29 @@ static void smsc95xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
 {
 	struct usbnet *dev = netdev_priv(netdev);
 	u32 val, addr;
+	int ret;
 
 	mutex_lock(&dev->phy_mutex);
 
 	/* confirm MII not busy */
-	if (smsc95xx_phy_wait_not_busy(dev)) {
-		netdev_warn(dev->net, "MII is busy in smsc95xx_mdio_write\n");
-		mutex_unlock(&dev->phy_mutex);
-		return;
-	}
+	ret = smsc95xx_phy_wait_not_busy(dev);
+	check_warn_goto_done(ret, "MII is busy in smsc95xx_mdio_write");
 
 	val = regval;
-	smsc95xx_write_reg(dev, MII_DATA, val);
+	ret = smsc95xx_write_reg(dev, MII_DATA, val);
+	check_warn_goto_done(ret, "Error writing MII_DATA");
 
 	/* set the address, index & direction (write to PHY) */
 	phy_id &= dev->mii.phy_id_mask;
 	idx &= dev->mii.reg_num_mask;
 	addr = (phy_id << 11) | (idx << 6) | MII_WRITE_;
-	smsc95xx_write_reg(dev, MII_ADDR, addr);
+	ret = smsc95xx_write_reg(dev, MII_ADDR, addr);
+	check_warn_goto_done(ret, "Error writing MII_ACCESS");
 
-	if (smsc95xx_phy_wait_not_busy(dev))
-		netdev_warn(dev->net, "Timed out writing MII reg %02X\n", idx);
+	ret = smsc95xx_phy_wait_not_busy(dev);
+	check_warn_goto_done(ret, "Timed out writing MII reg %02X", idx);
 
+done:
 	mutex_unlock(&dev->phy_mutex);
 }
 
@@ -197,9 +211,12 @@ static int smsc95xx_wait_eeprom(struct usbnet *dev)
 {
 	unsigned long start_time = jiffies;
 	u32 val;
+	int ret;
 
 	do {
-		smsc95xx_read_reg(dev, E2P_CMD, &val);
+		ret = smsc95xx_read_reg(dev, E2P_CMD, &val);
+		check_warn_return(ret, "Error reading E2P_CMD");
+
 		if (!(val & E2P_CMD_BUSY_) || (val & E2P_CMD_TIMEOUT_))
 			break;
 		udelay(40);
@@ -217,9 +234,11 @@ static int smsc95xx_eeprom_confirm_not_busy(struct usbnet *dev)
 {
 	unsigned long start_time = jiffies;
 	u32 val;
+	int ret;
 
 	do {
-		smsc95xx_read_reg(dev, E2P_CMD, &val);
+		ret = smsc95xx_read_reg(dev, E2P_CMD, &val);
+		check_warn_return(ret, "Error reading E2P_CMD");
 
 		if (!(val & E2P_CMD_BUSY_))
 			return 0;
@@ -246,13 +265,15 @@ static int smsc95xx_read_eeprom(struct usbnet *dev, u32 offset, u32 length,
 
 	for (i = 0; i < length; i++) {
 		val = E2P_CMD_BUSY_ | E2P_CMD_READ_ | (offset & E2P_CMD_ADDR_);
-		smsc95xx_write_reg(dev, E2P_CMD, val);
+		ret = smsc95xx_write_reg(dev, E2P_CMD, val);
+		check_warn_return(ret, "Error writing E2P_CMD");
 
 		ret = smsc95xx_wait_eeprom(dev);
 		if (ret < 0)
 			return ret;
 
-		smsc95xx_read_reg(dev, E2P_DATA, &val);
+		ret = smsc95xx_read_reg(dev, E2P_DATA, &val);
+		check_warn_return(ret, "Error reading E2P_DATA");
 
 		data[i] = val & 0xFF;
 		offset++;
@@ -276,7 +297,8 @@ static int smsc95xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 
 	/* Issue write/erase enable command */
 	val = E2P_CMD_BUSY_ | E2P_CMD_EWEN_;
-	smsc95xx_write_reg(dev, E2P_CMD, val);
+	ret = smsc95xx_write_reg(dev, E2P_CMD, val);
+	check_warn_return(ret, "Error writing E2P_CMD");
 
 	ret = smsc95xx_wait_eeprom(dev);
 	if (ret < 0)
@@ -286,11 +308,13 @@ static int smsc95xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 
 		/* Fill data register */
 		val = data[i];
-		smsc95xx_write_reg(dev, E2P_DATA, val);
+		ret = smsc95xx_write_reg(dev, E2P_DATA, val);
+		check_warn_return(ret, "Error writing E2P_DATA");
 
 		/* Send "write" command */
 		val = E2P_CMD_BUSY_ | E2P_CMD_WRITE_ | (offset & E2P_CMD_ADDR_);
-		smsc95xx_write_reg(dev, E2P_CMD, val);
+		ret = smsc95xx_write_reg(dev, E2P_CMD, val);
+		check_warn_return(ret, "Error writing E2P_CMD");
 
 		ret = smsc95xx_wait_eeprom(dev);
 		if (ret < 0)
@@ -308,8 +332,7 @@ static void smsc95xx_async_cmd_callback(struct urb *urb)
 	struct usbnet *dev = usb_context->dev;
 	int status = urb->status;
 
-	if (status < 0)
-		netdev_warn(dev->net, "async callback failed with %d\n", status);
+	check_warn(status, "async callback failed with %d\n", status);
 
 	kfree(usb_context);
 	usb_free_urb(urb);
@@ -415,16 +438,14 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 	smsc95xx_write_reg_async(dev, MAC_CR, &pdata->mac_cr);
 }
 
-static void smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
-					    u16 lcladv, u16 rmtadv)
+static int smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
+					   u16 lcladv, u16 rmtadv)
 {
 	u32 flow, afc_cfg = 0;
 
 	int ret = smsc95xx_read_reg(dev, AFC_CFG, &afc_cfg);
-	if (ret < 0) {
-		netdev_warn(dev->net, "error reading AFC_CFG\n");
-		return;
-	}
+	check_warn_return(ret, "Error reading AFC_CFG");
+
 
 	if (duplex == DUPLEX_FULL) {
 		u8 cap = mii_resolve_flowctrl_fdx(lcladv, rmtadv);
@@ -448,8 +469,13 @@ static void smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
 		afc_cfg |= 0xF;
 	}
 
-	smsc95xx_write_reg(dev, FLOW, flow);
-	smsc95xx_write_reg(dev,	AFC_CFG, afc_cfg);
+	ret = smsc95xx_write_reg(dev, FLOW, flow);
+	check_warn_return(ret, "Error writing FLOW");
+
+	ret = smsc95xx_write_reg(dev,	AFC_CFG, afc_cfg);
+	check_warn_return(ret, "Error writing AFC_CFG");
+
+	return 0;
 }
 
 static int smsc95xx_link_reset(struct usbnet *dev)
@@ -460,11 +486,15 @@ static int smsc95xx_link_reset(struct usbnet *dev)
 	unsigned long flags;
 	u16 lcladv, rmtadv;
 	u32 intdata;
+	int ret;
 
 	/* clear interrupt status */
-	smsc95xx_mdio_read(dev->net, mii->phy_id, PHY_INT_SRC);
+	ret = smsc95xx_mdio_read(dev->net, mii->phy_id, PHY_INT_SRC);
+	check_warn_return(ret, "Error reading PHY_INT_SRC");
+
 	intdata = 0xFFFFFFFF;
-	smsc95xx_write_reg(dev, INT_STS, intdata);
+	ret = smsc95xx_write_reg(dev, INT_STS, intdata);
+	check_warn_return(ret, "Error writing INT_STS");
 
 	mii_check_media(mii, 1, 1);
 	mii_ethtool_gset(&dev->mii, &ecmd);
@@ -484,7 +514,8 @@ static int smsc95xx_link_reset(struct usbnet *dev)
 	}
 	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
 
-	smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr);
+	ret = smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr);
+	check_warn_return(ret, "Error writing MAC_CR");
 
 	smsc95xx_phy_update_flowcontrol(dev, ecmd.duplex, lcladv, rmtadv);
 
@@ -519,10 +550,7 @@ static int smsc95xx_set_csums(struct usbnet *dev)
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	u32 read_buf;
 	int ret = smsc95xx_read_reg(dev, COE_CR, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read COE_CR: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to read COE_CR: %d\n", ret);
 
 	if (pdata->use_tx_csum)
 		read_buf |= Tx_COE_EN_;
@@ -535,10 +563,7 @@ static int smsc95xx_set_csums(struct usbnet *dev)
 		read_buf &= ~Rx_COE_EN_;
 
 	ret = smsc95xx_write_reg(dev, COE_CR, read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write COE_CR: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to write COE_CR: %d\n", ret);
 
 	netif_dbg(dev, hw, dev->net, "COE_CR = 0x%08x\n", read_buf);
 	return 0;
@@ -662,50 +687,53 @@ static int smsc95xx_set_mac_address(struct usbnet *dev)
 	int ret;
 
 	ret = smsc95xx_write_reg(dev, ADDRL, addr_lo);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write ADDRL: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to write ADDRL: %d\n", ret);
 
 	ret = smsc95xx_write_reg(dev, ADDRH, addr_hi);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write ADDRH: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to write ADDRH: %d\n", ret);
 
 	return 0;
 }
 
 /* starts the TX path */
-static void smsc95xx_start_tx_path(struct usbnet *dev)
+static int smsc95xx_start_tx_path(struct usbnet *dev)
 {
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	unsigned long flags;
 	u32 reg_val;
+	int ret;
 
 	/* Enable Tx at MAC */
 	spin_lock_irqsave(&pdata->mac_cr_lock, flags);
 	pdata->mac_cr |= MAC_CR_TXEN_;
 	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
 
-	smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr);
+	ret = smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr);
+	check_warn_return(ret, "Failed to write MAC_CR: %d\n", ret);
 
 	/* Enable Tx at SCSRs */
 	reg_val = TX_CFG_ON_;
-	smsc95xx_write_reg(dev, TX_CFG, reg_val);
+	ret = smsc95xx_write_reg(dev, TX_CFG, reg_val);
+	check_warn_return(ret, "Failed to write TX_CFG: %d\n", ret);
+
+	return 0;
 }
 
 /* Starts the Receive path */
-static void smsc95xx_start_rx_path(struct usbnet *dev)
+static int smsc95xx_start_rx_path(struct usbnet *dev)
 {
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	unsigned long flags;
+	int ret;
 
 	spin_lock_irqsave(&pdata->mac_cr_lock, flags);
 	pdata->mac_cr |= MAC_CR_RXEN_;
 	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
 
-	smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr);
+	ret = smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr);
+	check_warn_return(ret, "Failed to write MAC_CR: %d\n", ret);
+
+	return 0;
 }
 
 static int smsc95xx_phy_initialize(struct usbnet *dev)
@@ -760,20 +788,13 @@ static int smsc95xx_reset(struct usbnet *dev)
 
 	write_buf = HW_CFG_LRST_;
 	ret = smsc95xx_write_reg(dev, HW_CFG, write_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write HW_CFG_LRST_ bit in HW_CFG register, ret = %d\n",
-			    ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to write HW_CFG: %d\n", ret);
 
 	timeout = 0;
 	do {
 		msleep(10);
 		ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
-			return ret;
-		}
+		check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
 		timeout++;
 	} while ((read_buf & HW_CFG_LRST_) && (timeout < 100));
 
@@ -784,19 +805,13 @@ static int smsc95xx_reset(struct usbnet *dev)
 
 	write_buf = PM_CTL_PHY_RST_;
 	ret = smsc95xx_write_reg(dev, PM_CTRL, write_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write PM_CTRL: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to write PM_CTRL: %d\n", ret);
 
 	timeout = 0;
 	do {
 		msleep(10);
 		ret = smsc95xx_read_reg(dev, PM_CTRL, &read_buf);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Failed to read PM_CTRL: %d\n", ret);
-			return ret;
-		}
+		check_warn_return(ret, "Failed to read PM_CTRL: %d\n", ret);
 		timeout++;
 	} while ((read_buf & PM_CTL_PHY_RST_) && (timeout < 100));
 
@@ -815,10 +830,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 		  "MAC Address: %pM\n", dev->net->dev_addr);
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
 
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from HW_CFG : 0x%08x\n", read_buf);
@@ -826,17 +838,11 @@ static int smsc95xx_reset(struct usbnet *dev)
 	read_buf |= HW_CFG_BIR_;
 
 	ret = smsc95xx_write_reg(dev, HW_CFG, read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write HW_CFG_BIR_ bit in HW_CFG register, ret = %d\n",
-			    ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to write HW_CFG: %d\n", ret);
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
+
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from HW_CFG after writing HW_CFG_BIR_: 0x%08x\n",
 		  read_buf);
@@ -856,41 +862,29 @@ static int smsc95xx_reset(struct usbnet *dev)
 		  "rx_urb_size=%ld\n", (ulong)dev->rx_urb_size);
 
 	ret = smsc95xx_write_reg(dev, BURST_CAP, burst_cap);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write BURST_CAP: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to write BURST_CAP: %d\n", ret);
 
 	ret = smsc95xx_read_reg(dev, BURST_CAP, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read BURST_CAP: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to read BURST_CAP: %d\n", ret);
+
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from BURST_CAP after writing: 0x%08x\n",
 		  read_buf);
 
 	read_buf = DEFAULT_BULK_IN_DELAY;
 	ret = smsc95xx_write_reg(dev, BULK_IN_DLY, read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "ret = %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to write BULK_IN_DLY: %d\n", ret);
 
 	ret = smsc95xx_read_reg(dev, BULK_IN_DLY, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read BULK_IN_DLY: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to read BULK_IN_DLY: %d\n", ret);
+
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from BULK_IN_DLY after writing: 0x%08x\n",
 		  read_buf);
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
+
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from HW_CFG: 0x%08x\n", read_buf);
 
@@ -903,103 +897,66 @@ static int smsc95xx_reset(struct usbnet *dev)
 	read_buf |= NET_IP_ALIGN << 9;
 
 	ret = smsc95xx_write_reg(dev, HW_CFG, read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write HW_CFG register, ret=%d\n",
-			    ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to write HW_CFG: %d\n", ret);
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
+
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from HW_CFG after writing: 0x%08x\n", read_buf);
 
 	write_buf = 0xFFFFFFFF;
 	ret = smsc95xx_write_reg(dev, INT_STS, write_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write INT_STS register, ret=%d\n",
-			    ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to write INT_STS: %d\n", ret);
 
 	ret = smsc95xx_read_reg(dev, ID_REV, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read ID_REV: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to read ID_REG: %d\n", ret);
+
 	netif_dbg(dev, ifup, dev->net, "ID_REV = 0x%08x\n", read_buf);
 
 	/* Configure GPIO pins as LED outputs */
 	write_buf = LED_GPIO_CFG_SPD_LED | LED_GPIO_CFG_LNK_LED |
 		LED_GPIO_CFG_FDX_LED;
 	ret = smsc95xx_write_reg(dev, LED_GPIO_CFG, write_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write LED_GPIO_CFG register, ret=%d\n",
-			    ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to write LED_GPIO_CFG: %d\n", ret);
 
 	/* Init Tx */
 	write_buf = 0;
 	ret = smsc95xx_write_reg(dev, FLOW, write_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write FLOW: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to write FLOW: %d\n", ret);
 
 	read_buf = AFC_CFG_DEFAULT;
 	ret = smsc95xx_write_reg(dev, AFC_CFG, read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write AFC_CFG: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to write AFC_CFG: %d\n", ret);
 
 	/* Don't need mac_cr_lock during initialisation */
 	ret = smsc95xx_read_reg(dev, MAC_CR, &pdata->mac_cr);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read MAC_CR: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to read MAC_CR: %d\n", ret);
 
 	/* Init Rx */
 	/* Set Vlan */
 	write_buf = (u32)ETH_P_8021Q;
 	ret = smsc95xx_write_reg(dev, VLAN1, write_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write VAN1: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to write VLAN1: %d\n", ret);
 
 	/* Enable or disable checksum offload engines */
 	ethtool_op_set_tx_hw_csum(netdev, pdata->use_tx_csum);
 	ret = smsc95xx_set_csums(dev);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to set csum offload: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to set csum offload: %d\n", ret);
 
 	smsc95xx_set_multicast(dev->net);
 
-	if (smsc95xx_phy_initialize(dev) < 0)
-		return -EIO;
+	ret = smsc95xx_phy_initialize(dev);
+	check_warn_return(ret, "Failed to init PHY: %d\n", ret);
 
 	ret = smsc95xx_read_reg(dev, INT_EP_CTL, &read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to read INT_EP_CTL: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to read INT_EP_CTL: %d\n", ret);
 
 	/* enable PHY interrupts */
 	read_buf |= INT_EP_CTL_PHY_INT_;
 
 	ret = smsc95xx_write_reg(dev, INT_EP_CTL, read_buf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to write INT_EP_CTL: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "Failed to write INT_EP_CTL: %d\n", ret);
 
 	smsc95xx_start_tx_path(dev);
 	smsc95xx_start_rx_path(dev);
@@ -1028,10 +985,7 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	printk(KERN_INFO SMSC_CHIPNAME " v" SMSC_DRIVER_VERSION "\n");
 
 	ret = usbnet_get_endpoints(dev, intf);
-	if (ret < 0) {
-		netdev_warn(dev->net, "usbnet_get_endpoints failed: %d\n", ret);
-		return ret;
-	}
+	check_warn_return(ret, "usbnet_get_endpoints failed: %d\n", ret);
 
 	dev->data[0] = (unsigned long)kzalloc(sizeof(struct smsc95xx_priv),
 		GFP_KERNEL);
-- 
1.6.6.1

