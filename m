From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH v2] net: cdc_ether: allow combined control and data interface
Date: Sat, 29 Jun 2013 12:03:06 +0200
Message-ID: <1372500186-23567-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some Icera based Huawei modems handled by this driver are not
completely CDC ECM compliant, using the same USB interface for both
control and data. The CDC functional descriptors include a Union
naming this interface as both master and slave, so it is supportable
by relaxing the descriptor parsing in case these interfaces are
identical.

This has been tested on a Huawei K3806 and verified to add support
for that device.

Reported-and-tested-by: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
v2: Simplified unbind logic.  Thanks to Oliver Neukum


 drivers/net/usb/cdc_ether.c |   22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 04ee044..4393f14 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -215,6 +215,10 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, st=
ruct usb_interface *intf)
 					goto bad_desc;
 			}
=20
+			/* some devices merge these - skip class check */
+			if (info->control =3D=3D info->data)
+				goto next_desc;
+
 			/* a data interface altsetting does the real i/o */
 			d =3D &info->data->cur_altsetting->desc;
 			if (d->bInterfaceClass !=3D USB_CLASS_CDC_DATA) {
@@ -304,19 +308,23 @@ next_desc:
 	/* claim data interface and set it up ... with side effects.
 	 * network traffic can't flow until an altsetting is enabled.
 	 */
-	status =3D usb_driver_claim_interface(driver, info->data, dev);
-	if (status < 0)
-		return status;
+	if (info->data !=3D info->control) {
+		status =3D usb_driver_claim_interface(driver, info->data, dev);
+		if (status < 0)
+			return status;
+	}
 	status =3D usbnet_get_endpoints(dev, info->data);
 	if (status < 0) {
 		/* ensure immediate exit from usbnet_disconnect */
 		usb_set_intfdata(info->data, NULL);
-		usb_driver_release_interface(driver, info->data);
+		if (info->data !=3D info->control)
+			usb_driver_release_interface(driver, info->data);
 		return status;
 	}
=20
 	/* status endpoint: optional for CDC Ethernet, not RNDIS (or ACM) */
-	dev->status =3D NULL;
+	if (info->data !=3D info->control)
+		dev->status =3D NULL;
 	if (info->control->cur_altsetting->desc.bNumEndpoints =3D=3D 1) {
 		struct usb_endpoint_descriptor	*desc;
=20
@@ -349,6 +357,10 @@ void usbnet_cdc_unbind(struct usbnet *dev, struct =
usb_interface *intf)
 	struct cdc_state		*info =3D (void *) &dev->data;
 	struct usb_driver		*driver =3D driver_of(intf);
=20
+	/* combined interface - nothing  to do */
+	if (info->data =3D=3D info->control)
+		return;
+
 	/* disconnect master --> disconnect slave */
 	if (intf =3D=3D info->control && info->data) {
 		/* ensure immediate exit from usbnet_disconnect */
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
