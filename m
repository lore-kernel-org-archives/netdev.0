From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 1/2] smsc95xx: add wol magic packet support
Date: Wed, 26 Sep 2012 16:13:13 +0100
Message-ID: <1348672394-15191-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:57591 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756757Ab2IZPNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 11:13:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables wake from system suspend on magic packet.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |  182 ++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/usb/smsc95xx.h |    5 ++
 2 files changed, 180 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 6c89a08..c04ba76 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -46,6 +46,7 @@
 #define SMSC95XX_INTERNAL_PHY_ID	(1)
 #define SMSC95XX_TX_OVERHEAD		(8)
 #define SMSC95XX_TX_OVERHEAD_CSUM	(12)
+#define SUPPORTED_WAKE			(WAKE_MAGIC)
 
 #define check_warn(ret, fmt, args...) \
 	({ if (ret < 0) netdev_warn(dev->net, fmt, ##args); })
@@ -60,6 +61,7 @@ struct smsc95xx_priv {
 	u32 mac_cr;
 	u32 hash_hi;
 	u32 hash_lo;
+	u32 wolopts;
 	spinlock_t mac_cr_lock;
 };
 
@@ -125,6 +127,28 @@ static int __must_check smsc95xx_write_reg(struct usbnet *dev, u32 index,
 	return ret;
 }
 
+static int smsc95xx_set_feature(struct usbnet *dev, u32 feature)
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
+static int smsc95xx_clear_feature(struct usbnet *dev, u32 feature)
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
 static int __must_check smsc95xx_phy_wait_not_busy(struct usbnet *dev)
@@ -636,6 +660,26 @@ smsc95xx_ethtool_getregs(struct net_device *netdev, struct ethtool_regs *regs,
 	}
 }
 
+static void smsc95xx_ethtool_get_wol(struct net_device *net,
+				     struct ethtool_wolinfo *wolinfo)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+
+	wolinfo->supported = SUPPORTED_WAKE;
+	wolinfo->wolopts = pdata->wolopts;
+}
+
+static int smsc95xx_ethtool_set_wol(struct net_device *net,
+				    struct ethtool_wolinfo *wolinfo)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+
+	pdata->wolopts = wolinfo->wolopts & SUPPORTED_WAKE;
+	return 0;
+}
+
 static const struct ethtool_ops smsc95xx_ethtool_ops = {
 	.get_link	= usbnet_get_link,
 	.nway_reset	= usbnet_nway_reset,
@@ -649,6 +693,8 @@ static const struct ethtool_ops smsc95xx_ethtool_ops = {
 	.set_eeprom	= smsc95xx_ethtool_set_eeprom,
 	.get_regs_len	= smsc95xx_ethtool_getregslen,
 	.get_regs	= smsc95xx_ethtool_getregs,
+	.get_wol	= smsc95xx_ethtool_get_wol,
+	.set_wol	= smsc95xx_ethtool_set_wol,
 };
 
 static int smsc95xx_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
@@ -1021,25 +1067,147 @@ static void smsc95xx_unbind(struct usbnet *dev, struct usb_interface *intf)
 static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct usbnet *dev = usb_get_intfdata(intf);
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
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
+		ret = smsc95xx_read_reg(dev, WUCSR, &val);
+		check_warn_return(ret, "Error reading WUCSR");
+
+		val &= ~(WUCSR_MPEN_ | WUCSR_WAKE_EN_);
+
+		ret = smsc95xx_write_reg(dev, WUCSR, val);
+		check_warn_return(ret, "Error writing WUCSR");
+
+		ret = smsc95xx_read_reg(dev, PM_CTRL, &val);
+		check_warn_return(ret, "Error reading PM_CTRL");
+
+		val &= ~(PM_CTL_ED_EN_ | PM_CTL_WOL_EN_);
+
+		ret = smsc95xx_write_reg(dev, PM_CTRL, val);
+		check_warn_return(ret, "Error writing PM_CTRL");
+
+		/* enter suspend2 mode */
+		ret = smsc95xx_read_reg(dev, PM_CTRL, &val);
+		check_warn_return(ret, "Error reading PM_CTRL");
+
+		val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
+		val |= PM_CTL_SUS_MODE_2;
+
+		ret = smsc95xx_write_reg(dev, PM_CTRL, val);
+		check_warn_return(ret, "Error writing PM_CTRL");
+
+		return 0;
+	}
+
+	if (pdata->wolopts & WAKE_MAGIC) {
+		/* clear any pending magic packet status */
+		ret = smsc95xx_read_reg(dev, WUCSR, &val);
+		check_warn_return(ret, "Error reading WUCSR");
+
+		val |= WUCSR_MPR_;
+
+		ret = smsc95xx_write_reg(dev, WUCSR, val);
+		check_warn_return(ret, "Error writing WUCSR");
+	}
 
+	/* enable/disable magic packup wake */
+	ret = smsc95xx_read_reg(dev, WUCSR, &val);
+	check_warn_return(ret, "Error reading WUCSR");
+
+	if (pdata->wolopts & WAKE_MAGIC) {
+		netdev_info(dev->net, "enabling magic packet wakeup");
+		val |= WUCSR_MPEN_;
+	} else {
+		netdev_info(dev->net, "disabling magic packet wakeup");
+		val &= ~WUCSR_MPEN_;
+	}
+
+	ret = smsc95xx_write_reg(dev, WUCSR, val);
+	check_warn_return(ret, "Error writing WUCSR");
+
+	/* enable wol wakeup source */
 	ret = smsc95xx_read_reg(dev, PM_CTRL, &val);
 	check_warn_return(ret, "Error reading PM_CTRL");
 
-	val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
-	val |= PM_CTL_SUS_MODE_2;
+	val |= PM_CTL_WOL_EN_;
 
 	ret = smsc95xx_write_reg(dev, PM_CTRL, val);
 	check_warn_return(ret, "Error writing PM_CTRL");
 
+	/* enable receiver */
+	smsc95xx_start_rx_path(dev);
+
+	/* some wol options are enabled, so enter SUSPEND0 */
+	netdev_info(dev->net, "entering SUSPEND0 mode");
+
+	ret = smsc95xx_read_reg(dev, PM_CTRL, &val);
+	check_warn_return(ret, "Error reading PM_CTRL");
+
+	val &= (~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_));
+	val |= PM_CTL_SUS_MODE_0;
+
+	ret = smsc95xx_write_reg(dev, PM_CTRL, val);
+	check_warn_return(ret, "Error writing PM_CTRL");
+
+	/* clear wol status */
+	val &= ~PM_CTL_WUPS_;
+	val |= PM_CTL_WUPS_WOL_;
+	ret = smsc95xx_write_reg(dev, PM_CTRL, val);
+	check_warn_return(ret, "Error writing PM_CTRL");
+
+	/* read back PM_CTRL */
+	ret = smsc95xx_read_reg(dev, PM_CTRL, &val);
+	check_warn_return(ret, "Error reading PM_CTRL");
+
+	smsc95xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
+
+	return 0;
+}
+
+static int smsc95xx_resume(struct usb_interface *intf)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	int ret;
+	u32 val;
+
+	BUG_ON(!dev);
+
+	if (pdata->wolopts & WAKE_MAGIC) {
+		smsc95xx_clear_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
+
+		/* Disable magic packup wake */
+		ret = smsc95xx_read_reg(dev, WUCSR, &val);
+		check_warn_return(ret, "Error reading WUCSR");
+
+		val &= ~WUCSR_MPEN_;
+
+		ret = smsc95xx_write_reg(dev, WUCSR, val);
+		check_warn_return(ret, "Error writing WUCSR");
+
+		/* clear wake-up status */
+		ret = smsc95xx_read_reg(dev, PM_CTRL, &val);
+		check_warn_return(ret, "Error reading PM_CTRL");
+
+		val &= ~PM_CTL_WOL_EN_;
+		val |= PM_CTL_WUPS_;
+
+		ret = smsc95xx_write_reg(dev, PM_CTRL, val);
+		check_warn_return(ret, "Error writing PM_CTRL");
+	}
+
+	return usbnet_resume(intf);
+	check_warn_return(ret, "usbnet_resume error");
+
 	return 0;
 }
 
@@ -1306,8 +1474,8 @@ static struct usb_driver smsc95xx_driver = {
 	.id_table	= products,
 	.probe		= usbnet_probe,
 	.suspend	= smsc95xx_suspend,
-	.resume		= usbnet_resume,
-	.reset_resume	= usbnet_resume,
+	.resume		= smsc95xx_resume,
+	.reset_resume	= smsc95xx_resume,
 	.disconnect	= usbnet_disconnect,
 	.disable_hub_initiated_lpm = 1,
 };
diff --git a/drivers/net/usb/smsc95xx.h b/drivers/net/usb/smsc95xx.h
index 89ad925..2ff9815 100644
--- a/drivers/net/usb/smsc95xx.h
+++ b/drivers/net/usb/smsc95xx.h
@@ -205,6 +205,11 @@
 #define WUFF				(0x128)
 
 #define WUCSR				(0x12C)
+#define WUCSR_GUE_			(0x00000200)
+#define WUCSR_WUFR_			(0x00000040)
+#define WUCSR_MPR_			(0x00000020)
+#define WUCSR_WAKE_EN_			(0x00000004)
+#define WUCSR_MPEN_			(0x00000002)
 
 #define COE_CR				(0x130)
 #define Tx_COE_EN_			(0x00010000)
-- 
1.7.9.5
