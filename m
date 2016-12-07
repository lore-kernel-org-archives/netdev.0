From: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/1] NET: usb: cdc_mbim: add quirk for supporting Telit LE922A
Date: Wed,  7 Dec 2016 14:07:48 +0100
Message-ID: <1481116068-32691-2-git-send-email-dnlplm@gmail.com>
References: <1481116068-32691-1-git-send-email-dnlplm@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
        Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481116068-32691-1-git-send-email-dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Telit LE922A MBIM based composition does not work properly
with altsetting toggle done in cdc_ncm_bind_common.

This patch adds CDC_MBIM_FLAG_AVOID_ALTSETTING_TOGGLE quirk
to avoid this procedure that, instead, is mandatory for
other modems.

Signed-off-by: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/cdc_mbim.c  | 21 +++++++++++++++++++++
 drivers/net/usb/cdc_ncm.c   | 14 +++++++++-----
 include/linux/usb/cdc_ncm.h |  3 ++-
 3 files changed, 32 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 96a5028..3a98f37 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -602,6 +602,21 @@ static const struct driver_info cdc_mbim_info_ndp_to_end = {
 	.data = CDC_NCM_FLAG_NDP_TO_END,
 };
 
+/* Some modems (e.g. Telit LE922A6) do not work properly with altsetting
+ * toggle done in cdc_ncm_bind_common. CDC_MBIM_FLAG_AVOID_ALTSETTING_TOGGLE
+ * flag is used to avoid this procedure.
+ */
+static const struct driver_info cdc_mbim_info_avoid_altsetting_toggle = {
+	.description = "CDC MBIM",
+	.flags = FLAG_NO_SETINT | FLAG_MULTI_PACKET | FLAG_WWAN,
+	.bind = cdc_mbim_bind,
+	.unbind = cdc_mbim_unbind,
+	.manage_power = cdc_mbim_manage_power,
+	.rx_fixup = cdc_mbim_rx_fixup,
+	.tx_fixup = cdc_mbim_tx_fixup,
+	.data = CDC_MBIM_FLAG_AVOID_ALTSETTING_TOGGLE,
+};
+
 static const struct usb_device_id mbim_devs[] = {
 	/* This duplicate NCM entry is intentional. MBIM devices can
 	 * be disguised as NCM by default, and this is necessary to
@@ -626,6 +641,12 @@ static const struct usb_device_id mbim_devs[] = {
 	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, USB_CLASS_COMM, USB_CDC_SUBCLASS_MBIM, USB_CDC_PROTO_NONE),
 	  .driver_info = (unsigned long)&cdc_mbim_info_ndp_to_end,
 	},
+
+	/* Telit LE922A6 in MBIM composition */
+	{ USB_DEVICE_AND_INTERFACE_INFO(0x1bc7, 0x1041, USB_CLASS_COMM, USB_CDC_SUBCLASS_MBIM, USB_CDC_PROTO_NONE),
+	  .driver_info = (unsigned long)&cdc_mbim_info_avoid_altsetting_toggle,
+	},
+
 	/* default entry */
 	{ USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_MBIM, USB_CDC_PROTO_NONE),
 	  .driver_info = (unsigned long)&cdc_mbim_info_zlp,
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 877c951..afbfc0f 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -839,11 +839,18 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf, u8 data_
 
 	iface_no = ctx->data->cur_altsetting->desc.bInterfaceNumber;
 
+	/* Device-specific flags */
+	ctx->drvflags = drvflags;
+
 	/* Reset data interface. Some devices will not reset properly
 	 * unless they are configured first.  Toggle the altsetting to
-	 * force a reset
+	 * force a reset.
+	 * Some other devices do not work properly with this procedure
+	 * that can be avoided using quirk CDC_MBIM_FLAG_AVOID_ALTSETTING_TOGGLE
 	 */
-	usb_set_interface(dev->udev, iface_no, data_altsetting);
+	if (!(ctx->drvflags & CDC_MBIM_FLAG_AVOID_ALTSETTING_TOGGLE))
+		usb_set_interface(dev->udev, iface_no, data_altsetting);
+
 	temp = usb_set_interface(dev->udev, iface_no, 0);
 	if (temp) {
 		dev_dbg(&intf->dev, "set interface failed\n");
@@ -890,9 +897,6 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf, u8 data_
 	/* finish setting up the device specific data */
 	cdc_ncm_setup(dev);
 
-	/* Device-specific flags */
-	ctx->drvflags = drvflags;
