From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 5/5][RFC] smsc95xx: enable dynamic autosuspend (RFC)
Date: Thu, 22 Nov 2012 18:05:26 +0000
Message-ID: <1353607526-19307-6-git-send-email-steve.glendinning@shawell.net>
References: <1353607526-19307-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:59736 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753792Ab2KVSf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 13:35:27 -0500
In-Reply-To: <1353607526-19307-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a work in-progress patch.  It's not yet complete but
I thought I'd share it for comments, feedback and testing.

This patch enables dynamic autosuspend for all devices
supported by the driver, but it will only actually work on
LAN9500A (as this has a new SUSPEND3 mode for this purpose).
Unfortunately we don't know if the connected device supports
this feature until we query its ID register at runtime.

On unsupported devices (LAN9500/9512/9514) this patch claims
to support the feature but if enabled it will always return
failure to the autosuspend call (and fill up the kernel log
with a message every 2s).

Suggestions on how best to indicate this capability at runtime
instead of compile-time would be appreciated, so we don't have
to repeatedly fail if accidentally enabled.  Or maybe this is
actually the best way?

We should also be able to identify devices supporting
autosuspend from the USB VID/PID if this would help.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |  124 +++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 122 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index bf88543..463571c 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -55,6 +55,14 @@
 #define FEATURE_PHY_NLP_CROSSOVER	(0x02)
 #define FEATURE_AUTOSUSPEND		(0x04)
 
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
 
@@ -71,6 +79,7 @@ struct smsc95xx_priv {
 	u32 wolopts;
 	spinlock_t mac_cr_lock;
 	u8 features;
+	u8 suspend_flags;
 };
 
 static bool turbo_mode = true;
@@ -1162,6 +1171,8 @@ static int smsc95xx_enter_suspend0(struct usbnet *dev)
 
 	smsc95xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
 
+	pdata->suspend_flags |= SUSPEND_SUSPEND0 | SUSPEND_REMOTEWAKE;
+
 	return 0;
 }
 
@@ -1206,11 +1217,14 @@ static int smsc95xx_enter_suspend1(struct usbnet *dev)
 
 	smsc95xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
 
+	pdata->suspend_flags |= SUSPEND_SUSPEND1 | SUSPEND_REMOTEWAKE;
+
 	return 0;
 }
 
 static int smsc95xx_enter_suspend2(struct usbnet *dev)
 {
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	u32 val;
 	int ret;
 
@@ -1223,9 +1237,80 @@ static int smsc95xx_enter_suspend2(struct usbnet *dev)
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
 	check_warn_return(ret, "Error writing PM_CTRL");
 
+	pdata->suspend_flags |= SUSPEND_SUSPEND2;
+
+	return 0;
+}
+
+static int smsc95xx_enter_suspend3(struct usbnet *dev)
+{
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	u32 val;
+	int ret;
+
+	ret = smsc95xx_read_reg_nopm(dev, RX_FIFO_INF, &val);
+	check_warn_return(ret, "Error reading RX_FIFO_INF");
+
+	if (val & 0xFFFF) {
+		netdev_info(dev->net, "rx fifo not empty in autosuspend");
+		return -EBUSY;
+	}
+
+	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
+	check_warn_return(ret, "Error reading PM_CTRL");
+
+	val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
+	val |= PM_CTL_SUS_MODE_3 | PM_CTL_RES_CLR_WKP_STS;
+
+	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
+	check_warn_return(ret, "Error writing PM_CTRL");
+
+	/* clear wol status */
+	val &= ~PM_CTL_WUPS_;
+	val |= PM_CTL_WUPS_WOL_;
+
+	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
+	check_warn_return(ret, "Error writing PM_CTRL");
+
+	smsc95xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
+
+	pdata->suspend_flags |= SUSPEND_SUSPEND3 | SUSPEND_REMOTEWAKE;
+
 	return 0;
 }
 
+static int smsc95xx_autosuspend(struct usbnet *dev, u32 link_up)
+{
+	int ret;
+
+	if (!netif_running(dev->net)) {
+		/* interface is ifconfig down so fully power down hw */
+		netdev_dbg(dev->net, "autosuspend entering SUSPEND2");
+		return smsc95xx_enter_suspend2(dev);
+	}
+
+	if (!link_up) {
+		/* link is down so enter EDPD mode */
+		netdev_dbg(dev->net, "autosuspend entering SUSPEND1");
+
+		/* enable PHY wakeup events for if cable is attached */
+		ret = smsc95xx_enable_phy_wakeup_interrupts(dev,
+			PHY_INT_MASK_ANEG_COMP_);
+		check_warn_return(ret, "error enabling PHY wakeup ints");
+
+		netdev_info(dev->net, "entering SUSPEND1 mode");
+		return smsc95xx_enter_suspend1(dev);
+	}
+
+	/* enable PHY wakeup events so we remote wakeup if cable is pulled */
+	ret = smsc95xx_enable_phy_wakeup_interrupts(dev,
+		PHY_INT_MASK_LINK_DOWN_);
+	check_warn_return(ret, "error enabling PHY wakeup ints");
+
+	netdev_dbg(dev->net, "autosuspend entering SUSPEND3");
+	return smsc95xx_enter_suspend3(dev);
+}
+
 static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct usbnet *dev = usb_get_intfdata(intf);
@@ -1233,12 +1318,30 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	u32 val, link_up;
 	int ret;
 
+	/* TODO: don't indicate this feature to usb framework if
+	 * our current hardware doesn't have the capability
+	 */
+	if ((message.event == PM_EVENT_AUTO_SUSPEND) &&
+	    (!(pdata->features & FEATURE_AUTOSUSPEND))) {
+		netdev_warn(dev->net, "autosuspend not supported");
+		return -EBUSY;
+	}
+
 	ret = usbnet_suspend(intf, message);
 	check_warn_return(ret, "usbnet_suspend error");
 
+	if (pdata->suspend_flags) {
+		netdev_warn(dev->net, "error during last resume");
+		pdata->suspend_flags = 0;
+	}
+
 	/* determine if link is up using only _nopm functions */
 	link_up = smsc95xx_link_ok_nopm(dev);
 
+	if (message.event == PM_EVENT_AUTO_SUSPEND)
+		return smsc95xx_autosuspend(dev, link_up);
+
+	/* if we get this far we're not autosuspending */
 	/* if no wol options set, or if link is down and we're not waking on
 	 * PHY activity, enter lowest power SUSPEND2 mode
 	 */
@@ -1437,14 +1540,23 @@ static int smsc95xx_resume(struct usb_interface *intf)
 {
 	struct usbnet *dev = usb_get_intfdata(intf);
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	u8 suspend_flags = pdata->suspend_flags;
 	int ret;
 	u32 val;
 
 	BUG_ON(!dev);
 
-	if (pdata->wolopts) {
-		smsc95xx_clear_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
+	netdev_dbg(dev->net, "resume suspend_flags=0x%02x", suspend_flags);
 
+	/* do this first to ensure it's cleared even in error case */
+	pdata->suspend_flags = 0;
+
+	if (suspend_flags & SUSPEND_REMOTEWAKE) {
+		ret = smsc95xx_clear_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
+		check_warn_return(ret, "Error disabling remote wakeup");
+	}
+
+	if (suspend_flags & SUSPEND_ALLMODES) {
 		/* clear wake-up sources */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
 		check_warn_return(ret, "Error reading WUCSR");
@@ -1623,6 +1735,12 @@ static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
 	return skb;
 }
 
+static int smsc95xx_manage_power(struct usbnet *dev, int on)
+{
+	dev->intf->needs_remote_wakeup = on;
+	return 0;
+}
+
 static const struct driver_info smsc95xx_info = {
 	.description	= "smsc95xx USB 2.0 Ethernet",
 	.bind		= smsc95xx_bind,
@@ -1632,6 +1750,7 @@ static const struct driver_info smsc95xx_info = {
 	.rx_fixup	= smsc95xx_rx_fixup,
 	.tx_fixup	= smsc95xx_tx_fixup,
 	.status		= smsc95xx_status,
+	.manage_power	= smsc95xx_manage_power,
 	.flags		= FLAG_ETHER | FLAG_SEND_ZLP | FLAG_LINK_INTR,
 };
 
@@ -1739,6 +1858,7 @@ static struct usb_driver smsc95xx_driver = {
 	.reset_resume	= smsc95xx_resume,
 	.disconnect	= usbnet_disconnect,
 	.disable_hub_initiated_lpm = 1,
+	.supports_autosuspend = 1,
 };
 
 module_usb_driver(smsc95xx_driver);
-- 
1.7.10.4
