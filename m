From: Daniele Palmas <dnlplm@gmail.com>
Subject: [PATCH 1/1] NET: usb: cdc_ncm: adding MBIM RESET_FUNCTION request and modifying ncm bind common code
Date: Wed, 23 Nov 2016 13:36:46 +0100
Message-ID: <1479904606-30647-2-git-send-email-dnlplm@gmail.com>
References: <1479904606-30647-1-git-send-email-dnlplm@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        Daniele Palmas <dnlplm@gmail.com>
To: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
        Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:34198 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934685AbcKWMhK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 07:37:10 -0500
In-Reply-To: <1479904606-30647-1-git-send-email-dnlplm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some latest QC based modems seem not to properly accept altsetting
toggling in cdc_ncm_bind_common, making them to fail. The workaround
was to introduce an empirically decided pause to avoid the failure.

This patch introduces a different approach: for MBIM devices, instead
of toggling interfaces, the MBIM class-specific request code
RESET_FUNCTION is used in order to reset the function to its initial
state, removing the need for the pause.

Signed-off-by: Daniele Palmas <dnlplm@gmail.com>
---
 drivers/net/usb/cdc_ncm.c    | 39 +++++++++++++++++++++++++++------------
 include/uapi/linux/usb/cdc.h |  1 +
 2 files changed, 28 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 877c951..e8a7a76 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -498,6 +498,22 @@ static int cdc_ncm_init(struct usbnet *dev)
 		return err; /* GET_NTB_PARAMETERS is required */
 	}
 
+	/* Some modems (e.g. Telit LE922A6) need to reset the MBIM function
+	 * or they will fail to work properly.
+	 * For details on RESET_FUNCTION request see document
+	 * "USB Communication Class Subclass Specification for MBIM"
+	 * RESET_FUNCTION should be harmless for all the other MBIM modems
+	 */
+	if (cdc_ncm_comm_intf_is_mbim(ctx->control->cur_altsetting)) {
+		err = usbnet_write_cmd(dev, USB_CDC_RESET_FUNCTION,
+				       USB_TYPE_CLASS | USB_DIR_OUT
+				       | USB_RECIP_INTERFACE,
+				       0, iface_no, NULL, 0);
+		if (err < 0) {
+			dev_err(&dev->intf->dev, "failed RESET_FUNCTION\n");
+		}
+	}
+
 	/* set CRC Mode */
 	if (cdc_ncm_flags(dev) & USB_CDC_NCM_NCAP_CRC_MODE) {
 		dev_dbg(&dev->intf->dev, "Setting CRC mode off\n");
@@ -842,25 +858,24 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf, u8 data_
 	/* Reset data interface. Some devices will not reset properly
 	 * unless they are configured first.  Toggle the altsetting to
 	 * force a reset
+	 * This is applied only to ncm devices, since it has been verified
+	 * to cause issues with some MBIM modems (e.g. Telit LE922A6).
+	 * MBIM devices reset is achieved using MBIM request RESET_FUNCTION
+	 * in cdc_ncm_init
 	 */
-	usb_set_interface(dev->udev, iface_no, data_altsetting);
-	temp = usb_set_interface(dev->udev, iface_no, 0);
-	if (temp) {
-		dev_dbg(&intf->dev, "set interface failed\n");
-		goto error2;
+	if (!cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting)) {
+		usb_set_interface(dev->udev, iface_no, data_altsetting);
+		temp = usb_set_interface(dev->udev, iface_no, 0);
+		if (temp) {
+			dev_dbg(&intf->dev, "set interface failed\n");
+			goto error2;
+		}
 	}
 
 	/* initialize basic device settings */
 	if (cdc_ncm_init(dev))
 		goto error2;
 
-	/* Some firmwares need a pause here or they will silently fail
-	 * to set up the interface properly.  This value was decided
-	 * empirically on a Sierra Wireless MC7455 running 02.08.02.00
-	 * firmware.
-	 */
-	usleep_range(10000, 20000);
-
 	/* configure data interface */
 	temp = usb_set_interface(dev->udev, iface_no, data_altsetting);
 	if (temp) {
diff --git a/include/uapi/linux/usb/cdc.h b/include/uapi/linux/usb/cdc.h
index e2bc417..30258fb 100644
--- a/include/uapi/linux/usb/cdc.h
+++ b/include/uapi/linux/usb/cdc.h
@@ -231,6 +231,7 @@ struct usb_cdc_mbim_extended_desc {
 
 #define USB_CDC_SEND_ENCAPSULATED_COMMAND	0x00
 #define USB_CDC_GET_ENCAPSULATED_RESPONSE	0x01
+#define USB_CDC_RESET_FUNCTION			0x05
 #define USB_CDC_REQ_SET_LINE_CODING		0x20
 #define USB_CDC_REQ_GET_LINE_CODING		0x21
 #define USB_CDC_REQ_SET_CONTROL_LINE_STATE	0x22
-- 
2.7.4
