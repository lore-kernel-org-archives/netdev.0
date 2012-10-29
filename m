From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 2/4] usbnet: smsc75xx: apply the introduced usbnet_read[write]_cmd_nopm
Date: Mon, 29 Oct 2012 15:45:07 +0800
Message-ID: <1351496709-26934-3-git-send-email-ming.lei@canonical.com>
References: <1351496709-26934-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1351496709-26934-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch applies the introduced usbnet_read_cmd_nopm() and
usbnet_write_cmd_nopm() in the callback of resume and suspend
to avoid deadlock if USB runtime PM is considered into
usbnet_read_cmd() and usbnet_write_cmd().

Cc: Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/smsc75xx.c |  133 +++++++++++++++++++++++++++-----------------
 1 file changed, 83 insertions(+), 50 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 1baa53a..d4d6d31 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -82,18 +82,23 @@ static bool turbo_mode = true;
 module_param(turbo_mode, bool, 0644);
 MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx transaction");
 
-static int __must_check smsc75xx_read_reg(struct usbnet *dev, u32 index,
-					  u32 *data)
+static int __must_check __smsc75xx_read_reg(struct usbnet *dev, u32 index,
+					    u32 *data, int in_pm)
 {
 	u32 buf;
 	int ret;
+	int (*fn)(struct usbnet *, u8, u8, u16, u16, void *, u16);
 
 	BUG_ON(!dev);
 
-	ret = usbnet_read_cmd(dev, USB_VENDOR_REQUEST_READ_REGISTER,
-			      USB_DIR_IN | USB_TYPE_VENDOR |
-			      USB_RECIP_DEVICE,
-			      0, index, &buf, 4);
+	if (!in_pm)
+		fn = usbnet_read_cmd;
+	else
+		fn = usbnet_read_cmd_nopm;
+
+	ret = fn(dev, USB_VENDOR_REQUEST_READ_REGISTER, USB_DIR_IN
+		 | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+		 0, index, &buf, 4);
 	if (unlikely(ret < 0))
 		netdev_warn(dev->net,
 			"Failed to read reg index 0x%08x: %d", index, ret);
@@ -104,21 +109,26 @@ static int __must_check smsc75xx_read_reg(struct usbnet *dev, u32 index,
 	return ret;
 }
 
-static int __must_check smsc75xx_write_reg(struct usbnet *dev, u32 index,
-					   u32 data)
+static int __must_check __smsc75xx_write_reg(struct usbnet *dev, u32 index,
+					     u32 data, int in_pm)
 {
 	u32 buf;
 	int ret;
+	int (*fn)(struct usbnet *, u8, u8, u16, u16, const void *, u16);
 
 	BUG_ON(!dev);
 
+	if (!in_pm)
+		fn = usbnet_write_cmd;
+	else
+		fn = usbnet_write_cmd_nopm;
+
 	buf = data;
 	cpu_to_le32s(&buf);
 
-	ret = usbnet_write_cmd(dev, USB_VENDOR_REQUEST_WRITE_REGISTER,
-			       USB_DIR_OUT | USB_TYPE_VENDOR |
-			       USB_RECIP_DEVICE,
-			       0, index, &buf, 4);
+	ret = fn(dev, USB_VENDOR_REQUEST_WRITE_REGISTER, USB_DIR_OUT
+		 | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+		 0, index, &buf, 4);
 	if (unlikely(ret < 0))
 		netdev_warn(dev->net,
 			"Failed to write reg index 0x%08x: %d", index, ret);
@@ -126,16 +136,38 @@ static int __must_check smsc75xx_write_reg(struct usbnet *dev, u32 index,
 	return ret;
 }
 
+static int __must_check smsc75xx_read_reg_nopm(struct usbnet *dev, u32 index,
+					       u32 *data)
+{
+	return __smsc75xx_read_reg(dev, index, data, 1);
+}
+
+static int __must_check smsc75xx_write_reg_nopm(struct usbnet *dev, u32 index,
+						u32 data)
+{
+	return __smsc75xx_write_reg(dev, index, data, 1);
+}
+
+static int __must_check smsc75xx_read_reg(struct usbnet *dev, u32 index,
+					  u32 *data)
+{
+	return __smsc75xx_read_reg(dev, index, data, 0);
+}
+
+static int __must_check smsc75xx_write_reg(struct usbnet *dev, u32 index,
+					   u32 data)
+{
+	return __smsc75xx_write_reg(dev, index, data, 0);
+}
+
 static int smsc75xx_set_feature(struct usbnet *dev, u32 feature)
 {
 	if (WARN_ON_ONCE(!dev))
 		return -EINVAL;
 
-	cpu_to_le32s(&feature);
-
-	return usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
-		USB_REQ_SET_FEATURE, USB_RECIP_DEVICE, feature, 0, NULL, 0,
-		USB_CTRL_SET_TIMEOUT);
+	return usbnet_write_cmd_nopm(dev, USB_REQ_SET_FEATURE,
+				     USB_DIR_OUT | USB_RECIP_DEVICE,
+				     feature, 0, NULL, 0);
 }
 
 static int smsc75xx_clear_feature(struct usbnet *dev, u32 feature)
@@ -143,11 +175,9 @@ static int smsc75xx_clear_feature(struct usbnet *dev, u32 feature)
 	if (WARN_ON_ONCE(!dev))
 		return -EINVAL;
 
-	cpu_to_le32s(&feature);
-
-	return usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
-		USB_REQ_CLEAR_FEATURE, USB_RECIP_DEVICE, feature, 0, NULL, 0,
-		USB_CTRL_SET_TIMEOUT);
+	return usbnet_write_cmd_nopm(dev, USB_REQ_CLEAR_FEATURE,
+				     USB_DIR_OUT | USB_RECIP_DEVICE,
+				     feature, 0, NULL, 0);
 }
 
 /* Loop until the read is completed with timeout
@@ -793,13 +823,16 @@ static int smsc75xx_set_features(struct net_device *netdev,
 	return 0;
 }
 
-static int smsc75xx_wait_ready(struct usbnet *dev)
+static int smsc75xx_wait_ready(struct usbnet *dev, int in_pm)
 {
 	int timeout = 0;
 
 	do {
 		u32 buf;
-		int ret = smsc75xx_read_reg(dev, PMT_CTL, &buf);
+		int ret;
+
+		ret = __smsc75xx_read_reg(dev, PMT_CTL, &buf, in_pm);
+
 		check_warn_return(ret, "Failed to read PMT_CTL: %d", ret);
 
 		if (buf & PMT_CTL_DEV_RDY)
@@ -821,7 +854,7 @@ static int smsc75xx_reset(struct usbnet *dev)
 
 	netif_dbg(dev, ifup, dev->net, "entering smsc75xx_reset");
 
-	ret = smsc75xx_wait_ready(dev);
+	ret = smsc75xx_wait_ready(dev, 0);
 	check_warn_return(ret, "device not ready in smsc75xx_reset");
 
 	ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
@@ -1158,30 +1191,30 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 		netdev_info(dev->net, "entering SUSPEND2 mode");
 
 		/* disable energy detect (link up) & wake up events */
-		ret = smsc75xx_read_reg(dev, WUCSR, &val);
+		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
 		check_warn_return(ret, "Error reading WUCSR");
 
 		val &= ~(WUCSR_MPEN | WUCSR_WUEN);
 
-		ret = smsc75xx_write_reg(dev, WUCSR, val);
+		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
 		check_warn_return(ret, "Error writing WUCSR");
 
-		ret = smsc75xx_read_reg(dev, PMT_CTL, &val);
+		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
 		check_warn_return(ret, "Error reading PMT_CTL");
 
 		val &= ~(PMT_CTL_ED_EN | PMT_CTL_WOL_EN);
 
-		ret = smsc75xx_write_reg(dev, PMT_CTL, val);
+		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
 		check_warn_return(ret, "Error writing PMT_CTL");
 
 		/* enter suspend2 mode */
-		ret = smsc75xx_read_reg(dev, PMT_CTL, &val);
+		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
 		check_warn_return(ret, "Error reading PMT_CTL");
 
 		val &= ~(PMT_CTL_SUS_MODE | PMT_CTL_WUPS | PMT_CTL_PHY_RST);
 		val |= PMT_CTL_SUS_MODE_2;
 
-		ret = smsc75xx_write_reg(dev, PMT_CTL, val);
+		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
 		check_warn_return(ret, "Error writing PMT_CTL");
 
 		return 0;
@@ -1189,17 +1222,17 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 	if (pdata->wolopts & WAKE_MAGIC) {
 		/* clear any pending magic packet status */
-		ret = smsc75xx_read_reg(dev, WUCSR, &val);
+		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
 		check_warn_return(ret, "Error reading WUCSR");
 
 		val |= WUCSR_MPR;
 
-		ret = smsc75xx_write_reg(dev, WUCSR, val);
+		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
 		check_warn_return(ret, "Error writing WUCSR");
 	}
 
 	/* enable/disable magic packup wake */
-	ret = smsc75xx_read_reg(dev, WUCSR, &val);
+	ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
 	check_warn_return(ret, "Error reading WUCSR");
 
 	if (pdata->wolopts & WAKE_MAGIC) {
@@ -1210,47 +1243,47 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 		val &= ~WUCSR_MPEN;
 	}
 
-	ret = smsc75xx_write_reg(dev, WUCSR, val);
+	ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
 	check_warn_return(ret, "Error writing WUCSR");
 
 	/* enable wol wakeup source */
-	ret = smsc75xx_read_reg(dev, PMT_CTL, &val);
+	ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
 	check_warn_return(ret, "Error reading PMT_CTL");
 
 	val |= PMT_CTL_WOL_EN;
 
-	ret = smsc75xx_write_reg(dev, PMT_CTL, val);
+	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
 	check_warn_return(ret, "Error writing PMT_CTL");
 
 	/* enable receiver */
-	ret = smsc75xx_read_reg(dev, MAC_RX, &val);
+	ret = smsc75xx_read_reg_nopm(dev, MAC_RX, &val);
 	check_warn_return(ret, "Failed to read MAC_RX: %d", ret);
 
 	val |= MAC_RX_RXEN;
 
-	ret = smsc75xx_write_reg(dev, MAC_RX, val);
+	ret = smsc75xx_write_reg_nopm(dev, MAC_RX, val);
 	check_warn_return(ret, "Failed to write MAC_RX: %d", ret);
 
 	/* some wol options are enabled, so enter SUSPEND0 */
 	netdev_info(dev->net, "entering SUSPEND0 mode");
 
-	ret = smsc75xx_read_reg(dev, PMT_CTL, &val);
+	ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
 	check_warn_return(ret, "Error reading PMT_CTL");
 
 	val &= (~(PMT_CTL_SUS_MODE | PMT_CTL_WUPS | PMT_CTL_PHY_RST));
 	val |= PMT_CTL_SUS_MODE_0;
 
-	ret = smsc75xx_write_reg(dev, PMT_CTL, val);
+	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
 	check_warn_return(ret, "Error writing PMT_CTL");
 
 	/* clear wol status */
 	val &= ~PMT_CTL_WUPS;
 	val |= PMT_CTL_WUPS_WOL;
-	ret = smsc75xx_write_reg(dev, PMT_CTL, val);
+	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
 	check_warn_return(ret, "Error writing PMT_CTL");
 
 	/* read back PMT_CTL */
-	ret = smsc75xx_read_reg(dev, PMT_CTL, &val);
+	ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
 	check_warn_return(ret, "Error reading PMT_CTL");
 
 	smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
@@ -1271,36 +1304,36 @@ static int smsc75xx_resume(struct usb_interface *intf)
 		smsc75xx_clear_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
 
 		/* Disable magic packup wake */
-		ret = smsc75xx_read_reg(dev, WUCSR, &val);
+		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
 		check_warn_return(ret, "Error reading WUCSR");
 
 		val &= ~WUCSR_MPEN;
 
-		ret = smsc75xx_write_reg(dev, WUCSR, val);
+		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
 		check_warn_return(ret, "Error writing WUCSR");
 
 		/* clear wake-up status */
-		ret = smsc75xx_read_reg(dev, PMT_CTL, &val);
+		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
 		check_warn_return(ret, "Error reading PMT_CTL");
 
 		val &= ~PMT_CTL_WOL_EN;
 		val |= PMT_CTL_WUPS;
 
-		ret = smsc75xx_write_reg(dev, PMT_CTL, val);
+		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
 		check_warn_return(ret, "Error writing PMT_CTL");
 	} else {
 		netdev_info(dev->net, "resuming from SUSPEND2");
 
-		ret = smsc75xx_read_reg(dev, PMT_CTL, &val);
+		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
 		check_warn_return(ret, "Error reading PMT_CTL");
 
 		val |= PMT_CTL_PHY_PWRUP;
 
-		ret = smsc75xx_write_reg(dev, PMT_CTL, val);
+		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
 		check_warn_return(ret, "Error writing PMT_CTL");
 	}
 
-	ret = smsc75xx_wait_ready(dev);
+	ret = smsc75xx_wait_ready(dev, 1);
 	check_warn_return(ret, "device not ready in smsc75xx_resume");
 
 	return usbnet_resume(intf);
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
