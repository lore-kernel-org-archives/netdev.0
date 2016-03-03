From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net,stable] cdc_ncm: toggle altsetting to force reset before setup
Date: Thu,  3 Mar 2016 22:20:53 +0100
Message-ID: <1457040053-25271-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some devices will silently fail setup unless they are reset first.
This is necessary even if the data interface is already in
altsetting 0, which it will be when the device is probed for the
first time.  Briefly toggling the altsetting forces a function
reset regardless of the initial state.

This fixes a setup problem observed on a number of Huawei devices,
appearing to operate in NTB-32 mode even if we explicitly set them
to NTB-16 mode.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index dc0212c3cc28..be927964375b 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -837,7 +837,11 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct=
 usb_interface *intf, u8 data_
=20
 	iface_no =3D ctx->data->cur_altsetting->desc.bInterfaceNumber;
=20
-	/* reset data interface */
+	/* Reset data interface. Some devices will not reset properly
+	 * unless they are configured first.  Toggle the altsetting to
+	 * force a reset
+	 */
+	usb_set_interface(dev->udev, iface_no, data_altsetting);
 	temp =3D usb_set_interface(dev->udev, iface_no, 0);
 	if (temp) {
 		dev_dbg(&intf->dev, "set interface failed\n");
--=20
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
