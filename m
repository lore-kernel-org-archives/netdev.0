From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH] net: cdc_ncm: fix NULL pointer deref in cdc_ncm_bind_common
Date: Mon, 23 Nov 2015 14:32:10 +0100
Message-ID: <1448285530-6223-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit 77b0a099674a ("cdc-ncm: use common parser") added a dangerous
new trust in the CDC functional descriptors presented by the device,
unconditionally assuming that any device handled by the driver has
a CDC Union descriptor.

This descriptor is required by the NCM and MBIM specs, but crashing
on non-compliant devices is still unacceptable. Not only will that
allow malicious devices to crash the kernel, but in this case it is
also well known that there are non-compliant real devices on the
market - as shown by the comment accompanying the IAD workaround
in the same function.

The Sierra Wireless EM7305 is an example of such device, having
a CDC header and a CDC MBIM descriptor but no CDC Union:

    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber       12
      bAlternateSetting       0
      bNumEndpoints           1
      bInterfaceClass         2 Communications
      bInterfaceSubClass     14
      bInterfaceProtocol      0
      iInterface              0
      CDC Header:
        bcdCDC               1.10
      CDC MBIM:
        bcdMBIMVersion       1.00
        wMaxControlMessage   4096
        bNumberFilters       16
        bMaxFilterSize       128
        wMaxSegmentSize      4064
        bmNetworkCapabilities 0x20
          8-byte ntb input size
      Endpoint Descriptor:
	..

The conversion to a common parser also left the local cdc_union
variable untouched.  This caused the IAD workaround code to be applied
to all devices with an IAD descriptor, which was never intended.  Finis=
h
the conversion by testing for hdr.usb_cdc_union_desc instead.

Cc: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
=46ixes: 77b0a099674a ("cdc-ncm: use common parser")
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index a187f08113ec..3b1ba8237768 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -691,7 +691,6 @@ static void cdc_ncm_free(struct cdc_ncm_ctx *ctx)
=20
 int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf=
, u8 data_altsetting, int drvflags)
 {
-	const struct usb_cdc_union_desc *union_desc =3D NULL;
 	struct cdc_ncm_ctx *ctx;
 	struct usb_driver *driver;
 	u8 *buf;
@@ -725,15 +724,16 @@ int cdc_ncm_bind_common(struct usbnet *dev, struc=
t usb_interface *intf, u8 data_
 	/* parse through descriptors associated with control interface */
 	cdc_parse_cdc_header(&hdr, intf, buf, len);
=20
-	ctx->data =3D usb_ifnum_to_if(dev->udev,
-				    hdr.usb_cdc_union_desc->bSlaveInterface0);
+	if (hdr.usb_cdc_union_desc)
+		ctx->data =3D usb_ifnum_to_if(dev->udev,
+					    hdr.usb_cdc_union_desc->bSlaveInterface0);
 	ctx->ether_desc =3D hdr.usb_cdc_ether_desc;
 	ctx->func_desc =3D hdr.usb_cdc_ncm_desc;
 	ctx->mbim_desc =3D hdr.usb_cdc_mbim_desc;
 	ctx->mbim_extended_desc =3D hdr.usb_cdc_mbim_extended_desc;
=20
 	/* some buggy devices have an IAD but no CDC Union */
-	if (!union_desc && intf->intf_assoc && intf->intf_assoc->bInterfaceCo=
unt =3D=3D 2) {
+	if (!hdr.usb_cdc_union_desc && intf->intf_assoc && intf->intf_assoc->=
bInterfaceCount =3D=3D 2) {
 		ctx->data =3D usb_ifnum_to_if(dev->udev, intf->cur_altsetting->desc.=
bInterfaceNumber + 1);
 		dev_dbg(&intf->dev, "CDC Union missing - got slave from IAD\n");
 	}
--=20
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
