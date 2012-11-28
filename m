From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 5/6] smsc75xx: add support for USB dynamic autosuspend
Date: Wed, 28 Nov 2012 15:59:49 +0000
Message-ID: <1354118391-22666-6-git-send-email-steve.glendinning@shawell.net>
References: <1354118391-22666-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:57254 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008Ab2K1QAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:00:07 -0500
In-Reply-To: <1354118391-22666-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for USB dynamic autosuspend to the
smsc75xx driver.  This saves virtually no power in the USB
device but enables power savings in upstream hosts and
the host CPU.

Note currently Linux doesn't automatically enable this
functionality by default for devices so to test this:

 echo auto > /sys/bus/usb/devices/2-1.2/power/control

where 2-1.2 is the USB bus address of the LAN7500.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |  123 ++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 119 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 649bf2a..b852c48 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -57,6 +57,14 @@
 #define SUPPORTED_WAKE			(WAKE_PHY | WAKE_UCAST | WAKE_BCAST | \
 					 WAKE_MCAST | WAKE_ARP | WAKE_MAGIC)
 
+#define SUSPEND_SUSPEND0		(0x01)
+#define SUSPEND_SUSPEND1		(0x02)
+#define SUSPEND_SUSPEND2		(0x04)
+#define SUSPEND_SUSPEND3		(0x08)
+#define SUSPEND_REMOTEWAKE		(0x10)
+#define SUSPEND_ALLMODES		(SUSPEND_SUSPEND0 | SUSPEND_SUSPEND1 | \
+					 SUSPEND_SUSPEND2 | SUSPEND_SUSPEND3)
+
 #define check_warn(ret, fmt, args...) \
 	({ if (ret < 0) netdev_warn(dev->net, fmt, ##args); })
 
@@ -74,6 +82,7 @@ struct smsc75xx_priv {
 	struct mutex dataport_mutex;
 	spinlock_t rfe_ctl_lock;
 	struct work_struct set_multicast;
+	u8 suspend_flags;
 };
 
 struct usb_context {
@@ -1241,6 +1250,7 @@ static int smsc75xx_write_wuff(struct usbnet *dev, int filter, u32 wuf_cfg,
 
 static int smsc75xx_enter_suspend0(struct usbnet *dev)
 {
+	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
 	u32 val;
 	int ret;
 
@@ -1255,11 +1265,14 @@ static int smsc75xx_enter_suspend0(struct usbnet *dev)
 
 	smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
 
+	pdata->suspend_flags |= SUSPEND_SUSPEND0 | SUSPEND_REMOTEWAKE;
+
 	return 0;
 }
 
 static int smsc75xx_enter_suspend1(struct usbnet *dev)
 {
+	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
 	u32 val;
 	int ret;
 
@@ -1281,11 +1294,14 @@ static int smsc75xx_enter_suspend1(struct usbnet *dev)
 
 	smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
 
+	pdata->suspend_flags |= SUSPEND_SUSPEND1 | SUSPEND_REMOTEWAKE;
+
 	return 0;
 }
 
 static int smsc75xx_enter_suspend2(struct usbnet *dev)
 {
+	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
 	u32 val;
 	int ret;
 
@@ -1298,6 +1314,45 @@ static int smsc75xx_enter_suspend2(struct usbnet *dev)
 	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
 	check_warn_return(ret, "Error writing PMT_CTL\n");
 
+	pdata->suspend_flags |= SUSPEND_SUSPEND2;
+
+	return 0;
+}
+
+static int smsc75xx_enter_suspend3(struct usbnet *dev)
+{
+	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
+	u32 val;
+	int ret;
+
+	ret = smsc75xx_read_reg_nopm(dev, FCT_RX_CTL, &val);
+	check_warn_return(ret, "Error reading FCT_RX_CTL\n");
+
+	if (val & FCT_RX_CTL_RXUSED) {
+		netdev_dbg(dev->net, "rx fifo not empty in autosuspend\n");
+		return -EBUSY;
+	}
+
+	ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
+	check_warn_return(ret, "Error reading PMT_CTL\n");
+
+	val &= ~(PMT_CTL_SUS_MODE | PMT_CTL_WUPS | PMT_CTL_PHY_RST);
+	val |= PMT_CTL_SUS_MODE_3 | PMT_CTL_RES_CLR_WKP_EN;
+
+	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
+	check_warn_return(ret, "Error writing PMT_CTL\n");
+
+	/* clear wol status */
+	val &= ~PMT_CTL_WUPS;
+	val |= PMT_CTL_WUPS_WOL;
+
+	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
+	check_warn_return(ret, "Error writing PMT_CTL\n");
+
+	smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
+
+	pdata->suspend_flags |= SUSPEND_SUSPEND3 | SUSPEND_REMOTEWAKE;
+
 	return 0;
 }
 
@@ -1338,6 +1393,38 @@ static int smsc75xx_link_ok_nopm(struct usbnet *dev)
 	return !!(ret & BMSR_LSTATUS);
 }
 
+static int smsc75xx_autosuspend(struct usbnet *dev, u32 link_up)
+{
+	int ret;
+
+	if (!netif_running(dev->net)) {
+		/* interface is ifconfig down so fully power down hw */
+		netdev_dbg(dev->net, "autosuspend entering SUSPEND2\n");
+		return smsc75xx_enter_suspend2(dev);
+	}
+
+	if (!link_up) {
+		/* link is down so enter EDPD mode */
+		netdev_dbg(dev->net, "autosuspend entering SUSPEND1\n");
+
+		/* enable PHY wakeup events for if cable is attached */
+		ret = smsc75xx_enable_phy_wakeup_interrupts(dev,
+			PHY_INT_MASK_ANEG_COMP);
+		check_warn_return(ret, "error enabling PHY wakeup ints\n");
+
+		netdev_info(dev->net, "entering SUSPEND1 mode\n");
+		return smsc75xx_enter_suspend1(dev);
+	}
+
+	/* enable PHY wakeup events so we remote wakeup if cable is pulled */
+	ret = smsc75xx_enable_phy_wakeup_interrupts(dev,
+		PHY_INT_MASK_LINK_DOWN);
+	check_warn_return(ret, "error enabling PHY wakeup ints\n");
+
+	netdev_dbg(dev->net, "autosuspend entering SUSPEND3\n");
+	return smsc75xx_enter_suspend3(dev);
+}
+
 static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct usbnet *dev = usb_get_intfdata(intf);
@@ -1348,9 +1435,20 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 	ret = usbnet_suspend(intf, message);
 	check_warn_goto_done(ret, "usbnet_suspend error\n");
 
+	if (pdata->suspend_flags) {
+		netdev_warn(dev->net, "error during last resume\n");
+		pdata->suspend_flags = 0;
+	}
+
 	/* determine if link is up using only _nopm functions */
 	link_up = smsc75xx_link_ok_nopm(dev);
 
+	if (message.event == PM_EVENT_AUTO_SUSPEND) {
+		ret = smsc75xx_autosuspend(dev, link_up);
+		goto done;
+	}
+
+	/* if we get this far we're not autosuspending */
 	/* if no wol options set, or if link is down and we're not waking on
 	 * PHY activity, enter lowest power SUSPEND2 mode
 	 */
@@ -1544,14 +1642,21 @@ static int smsc75xx_resume(struct usb_interface *intf)
 {
 	struct usbnet *dev = usb_get_intfdata(intf);
 	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
+	u8 suspend_flags = pdata->suspend_flags;
 	int ret;
 	u32 val;
 
-	if (pdata->wolopts) {
-		netdev_info(dev->net, "resuming from SUSPEND0\n");
+	netdev_dbg(dev->net, "resume suspend_flags=0x%02x\n", suspend_flags);
 
-		smsc75xx_clear_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
+	/* do this first to ensure it's cleared even in error case */
+	pdata->suspend_flags = 0;
+
+	if (suspend_flags & SUSPEND_REMOTEWAKE) {
+		ret = smsc75xx_clear_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
+		check_warn_return(ret, "Error disabling remote wakeup\n");
+	}
 
+	if (suspend_flags & SUSPEND_ALLMODES) {
 		/* Disable wakeup sources */
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
 		check_warn_return(ret, "Error reading WUCSR\n");
@@ -1571,7 +1676,9 @@ static int smsc75xx_resume(struct usb_interface *intf)
 
 		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
 		check_warn_return(ret, "Error writing PMT_CTL\n");
-	} else {
+	}
+
+	if (suspend_flags & SUSPEND_SUSPEND2) {
 		netdev_info(dev->net, "resuming from SUSPEND2\n");
 
 		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
@@ -1727,6 +1834,12 @@ static struct sk_buff *smsc75xx_tx_fixup(struct usbnet *dev,
 	return skb;
 }
 
+static int smsc75xx_manage_power(struct usbnet *dev, int on)
+{
+	dev->intf->needs_remote_wakeup = on;
+	return 0;
+}
+
 static const struct driver_info smsc75xx_info = {
 	.description	= "smsc75xx USB 2.0 Gigabit Ethernet",
 	.bind		= smsc75xx_bind,
@@ -1736,6 +1849,7 @@ static const struct driver_info smsc75xx_info = {
 	.rx_fixup	= smsc75xx_rx_fixup,
 	.tx_fixup	= smsc75xx_tx_fixup,
 	.status		= smsc75xx_status,
+	.manage_power	= smsc75xx_manage_power,
 	.flags		= FLAG_ETHER | FLAG_SEND_ZLP | FLAG_LINK_INTR,
 };
 
@@ -1763,6 +1877,7 @@ static struct usb_driver smsc75xx_driver = {
 	.reset_resume	= smsc75xx_resume,
 	.disconnect	= usbnet_disconnect,
 	.disable_hub_initiated_lpm = 1,
+	.supports_autosuspend = 1,
 };
 
 module_usb_driver(smsc75xx_driver);
-- 
1.7.10.4
