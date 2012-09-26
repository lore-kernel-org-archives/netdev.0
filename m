From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 2/2] smsc75xx: add wol magic packet support
Date: Wed, 26 Sep 2012 16:13:14 +0100
Message-ID: <1348672394-15191-2-git-send-email-steve.glendinning@shawell.net>
References: <1348672394-15191-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:57593 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756757Ab2IZPNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 11:13:24 -0400
In-Reply-To: <1348672394-15191-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables wake from system suspend on magic packet.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |  184 +++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 172 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 83b9927..a480c46 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -52,6 +52,7 @@
 #define USB_PRODUCT_ID_LAN7500		(0x7500)
 #define USB_PRODUCT_ID_LAN7505		(0x7505)
 #define RXW_PADDING			2
+#define SUPPORTED_WAKE			(WAKE_MAGIC)
 
 #define check_warn(ret, fmt, args...) \
 	({ if (ret < 0) netdev_warn(dev->net, fmt, ##args); })
@@ -65,6 +66,7 @@
 struct smsc75xx_priv {
 	struct usbnet *dev;
 	u32 rfe_ctl;
+	u32 wolopts;
 	u32 multicast_hash_table[DP_SEL_VHF_HASH_LEN];
 	struct mutex dataport_mutex;
 	spinlock_t rfe_ctl_lock;
@@ -135,6 +137,28 @@ static int __must_check smsc75xx_write_reg(struct usbnet *dev, u32 index,
 	return ret;
 }
 
+static int smsc75xx_set_feature(struct usbnet *dev, u32 feature)
+{
+	BUG_ON(!dev);
+
+	cpu_to_le32s(&feature);
+
+	return usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
+		USB_REQ_SET_FEATURE, USB_RECIP_DEVICE, feature, 0, NULL, 0,
+		USB_CTRL_SET_TIMEOUT);
+}
+
+static int smsc75xx_clear_feature(struct usbnet *dev, u32 feature)
+{
+	BUG_ON(!dev);
+
+	cpu_to_le32s(&feature);
+
+	return usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
+		USB_REQ_CLEAR_FEATURE, USB_RECIP_DEVICE, feature, 0, NULL, 0,
+		USB_CTRL_SET_TIMEOUT);
+}
+
 /* Loop until the read is completed with timeout
  * called with phy_mutex held */
 static int smsc75xx_phy_wait_not_busy(struct usbnet *dev)
@@ -578,6 +602,26 @@ static int smsc75xx_ethtool_set_eeprom(struct net_device *netdev,
 	return smsc75xx_write_eeprom(dev, ee->offset, ee->len, data);
 }
 
+static void smsc75xx_ethtool_get_wol(struct net_device *net,
+				     struct ethtool_wolinfo *wolinfo)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
+
+	wolinfo->supported = SUPPORTED_WAKE;
+	wolinfo->wolopts = pdata->wolopts;
+}
+
+static int smsc75xx_ethtool_set_wol(struct net_device *net,
+				    struct ethtool_wolinfo *wolinfo)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
+
+	pdata->wolopts = wolinfo->wolopts & SUPPORTED_WAKE;
+	return 0;
+}
+
 static const struct ethtool_ops smsc75xx_ethtool_ops = {
 	.get_link	= usbnet_get_link,
 	.nway_reset	= usbnet_nway_reset,
@@ -589,6 +633,8 @@ static const struct ethtool_ops smsc75xx_ethtool_ops = {
 	.get_eeprom_len	= smsc75xx_ethtool_get_eeprom_len,
 	.get_eeprom	= smsc75xx_ethtool_get_eeprom,
 	.set_eeprom	= smsc75xx_ethtool_set_eeprom,
+	.get_wol	= smsc75xx_ethtool_get_wol,
+	.set_wol	= smsc75xx_ethtool_set_wol,
 };
 
 static int smsc75xx_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
@@ -1109,45 +1155,159 @@ static void smsc75xx_unbind(struct usbnet *dev, struct usb_interface *intf)
 static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct usbnet *dev = usb_get_intfdata(intf);
+	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
 	int ret;
 	u32 val;
 
-	BUG_ON(!dev);
-
 	ret = usbnet_suspend(intf, message);
 	check_warn_return(ret, "usbnet_suspend error");
 
-	netdev_info(dev->net, "entering SUSPEND2 mode");
+	/* if no wol options set, enter lowest power SUSPEND2 mode */
+	if (!(pdata->wolopts & SUPPORTED_WAKE)) {
+		netdev_info(dev->net, "entering SUSPEND2 mode");
+
+		/* disable energy detect (link up) & wake up events */
+		ret = smsc75xx_read_reg(dev, WUCSR, &val);
+		check_warn_return(ret, "Error reading WUCSR");
+
+		val &= ~(WUCSR_MPEN | WUCSR_WUEN);
+
+		ret = smsc75xx_write_reg(dev, WUCSR, val);
+		check_warn_return(ret, "Error writing WUCSR");
+
+		ret = smsc75xx_read_reg(dev, PMT_CTL, &val);
+		check_warn_return(ret, "Error reading PMT_CTL");
+
+		val &= ~(PMT_CTL_ED_EN | PMT_CTL_WOL_EN);
+
+		ret = smsc75xx_write_reg(dev, PMT_CTL, val);
+		check_warn_return(ret, "Error writing PMT_CTL");
+
+		/* enter suspend2 mode */
+		ret = smsc75xx_read_reg(dev, PMT_CTL, &val);
+		check_warn_return(ret, "Error reading PMT_CTL");
+
+		val &= ~(PMT_CTL_SUS_MODE | PMT_CTL_WUPS | PMT_CTL_PHY_RST);
+		val |= PMT_CTL_SUS_MODE_2;
+
+		ret = smsc75xx_write_reg(dev, PMT_CTL, val);
+		check_warn_return(ret, "Error writing PMT_CTL");
+
+		return 0;
+	}
+
+	if (pdata->wolopts & WAKE_MAGIC) {
+		/* clear any pending magic packet status */
+		ret = smsc75xx_read_reg(dev, WUCSR, &val);
+		check_warn_return(ret, "Error reading WUCSR");
+
+		val |= WUCSR_MPR;
+
+		ret = smsc75xx_write_reg(dev, WUCSR, val);
+		check_warn_return(ret, "Error writing WUCSR");
+	}
+
+	/* enable/disable magic packup wake */
+	ret = smsc75xx_read_reg(dev, WUCSR, &val);
+	check_warn_return(ret, "Error reading WUCSR");
+
+	if (pdata->wolopts & WAKE_MAGIC) {
+		netdev_info(dev->net, "enabling magic packet wakeup");
+		val |= WUCSR_MPEN;
+	} else {
+		netdev_info(dev->net, "disabling magic packet wakeup");
+		val &= ~WUCSR_MPEN;
+	}
+
+	ret = smsc75xx_write_reg(dev, WUCSR, val);
+	check_warn_return(ret, "Error writing WUCSR");
+
+	/* enable wol wakeup source */
+	ret = smsc75xx_read_reg(dev, PMT_CTL, &val);
+	check_warn_return(ret, "Error reading PMT_CTL");
+
+	val |= PMT_CTL_WOL_EN;
+
+	ret = smsc75xx_write_reg(dev, PMT_CTL, val);
+	check_warn_return(ret, "Error writing PMT_CTL");
+
+	/* enable receiver */
+	ret = smsc75xx_read_reg(dev, MAC_RX, &val);
+	check_warn_return(ret, "Failed to read MAC_RX: %d", ret);
+
+	val |= MAC_RX_RXEN;
+
+	ret = smsc75xx_write_reg(dev, MAC_RX, val);
+	check_warn_return(ret, "Failed to write MAC_RX: %d", ret);
+
+	/* some wol options are enabled, so enter SUSPEND0 */
+	netdev_info(dev->net, "entering SUSPEND0 mode");
 
 	ret = smsc75xx_read_reg(dev, PMT_CTL, &val);
 	check_warn_return(ret, "Error reading PMT_CTL");
 
-	val &= ~(PMT_CTL_SUS_MODE | PMT_CTL_WUPS | PMT_CTL_PHY_RST);
-	val |= PMT_CTL_SUS_MODE_2;
+	val &= (~(PMT_CTL_SUS_MODE | PMT_CTL_WUPS | PMT_CTL_PHY_RST));
+	val |= PMT_CTL_SUS_MODE_0;
+
+	ret = smsc75xx_write_reg(dev, PMT_CTL, val);
+	check_warn_return(ret, "Error writing PMT_CTL");
 
+	/* clear wol status */
+	val &= ~PMT_CTL_WUPS;
+	val |= PMT_CTL_WUPS_WOL;
 	ret = smsc75xx_write_reg(dev, PMT_CTL, val);
 	check_warn_return(ret, "Error writing PMT_CTL");
 
+	/* read back PMT_CTL */
+	ret = smsc75xx_read_reg(dev, PMT_CTL, &val);
+	check_warn_return(ret, "Error reading PMT_CTL");
+
+	smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
+
 	return 0;
 }
 
 static int smsc75xx_resume(struct usb_interface *intf)
 {
 	struct usbnet *dev = usb_get_intfdata(intf);
+	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
 	int ret;
 	u32 val;
 
-	BUG_ON(!dev);
+	if (pdata->wolopts & WAKE_MAGIC) {
+		netdev_info(dev->net, "resuming from SUSPEND0");
 
-	netdev_info(dev->net, "resuming from SUSPEND2");
+		smsc75xx_clear_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
 
-	ret = smsc75xx_read_reg(dev, PMT_CTL, &val);
-	check_warn_return(ret, "Error reading PMT_CTL");
+		/* Disable magic packup wake */
+		ret = smsc75xx_read_reg(dev, WUCSR, &val);
+		check_warn_return(ret, "Error reading WUCSR");
 
-	val |= PMT_CTL_PHY_PWRUP;
+		val &= ~WUCSR_MPEN;
 
-	ret = smsc75xx_write_reg(dev, PMT_CTL, val);
-	check_warn_return(ret, "Error writing PMT_CTL");
+		ret = smsc75xx_write_reg(dev, WUCSR, val);
+		check_warn_return(ret, "Error writing WUCSR");
+
+		/* clear wake-up status */
+		ret = smsc75xx_read_reg(dev, PMT_CTL, &val);
+		check_warn_return(ret, "Error reading PMT_CTL");
+
+		val &= ~PMT_CTL_WOL_EN;
+		val |= PMT_CTL_WUPS;
+
+		ret = smsc75xx_write_reg(dev, PMT_CTL, val);
+		check_warn_return(ret, "Error writing PMT_CTL");
+	} else {
+		netdev_info(dev->net, "resuming from SUSPEND2");
+
+		ret = smsc75xx_read_reg(dev, PMT_CTL, &val);
+		check_warn_return(ret, "Error reading PMT_CTL");
+
+		val |= PMT_CTL_PHY_PWRUP;
+
+		ret = smsc75xx_write_reg(dev, PMT_CTL, val);
+		check_warn_return(ret, "Error writing PMT_CTL");
+	}
 
 	ret = smsc75xx_wait_ready(dev);
 	check_warn_return(ret, "device not ready in smsc75xx_resume");
-- 
1.7.9.5
