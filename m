From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 2/8] cdc-ncm: use common CDC parser
Date: Thu, 16 Jul 2015 22:18:28 +0200
Message-ID: <B0A92094-0F80-4B93-9CC0-274C75E6B095@mork.no>
References: <1437074680-3515-1-git-send-email-oneukum@suse.com> <1437074680-3515-2-git-send-email-oneukum@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Oliver Neukum <oneukum@suse.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:42758 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751163AbbGPUS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2015 16:18:56 -0400
In-Reply-To: <1437074680-3515-2-git-send-email-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm on vacation without any usable Internet or other code access, so yo=
u'll have to excuse me if I'm missing something.  But this seems to lea=
ve union_desc uninitialized, doesn't it?

Bj=C3=B8rn

On July 16, 2015 9:24:34 PM CEST, Oliver Neukum <oneukum@suse.com> wrot=
e:
>Switch to the common parser
>
>Signed-off-by: Oliver Neukum <oneukum@suse.com>
>---
>drivers/net/usb/cdc_ncm.c | 69
>+++++++----------------------------------------
> 1 file changed, 9 insertions(+), 60 deletions(-)
>
>diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
>index db40175..2cef13a 100644
>--- a/drivers/net/usb/cdc_ncm.c
>+++ b/drivers/net/usb/cdc_ncm.c
>@@ -698,6 +698,7 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct
>usb_interface *intf, u8 data_
> 	int len;
> 	int temp;
> 	u8 iface_no;
>+	struct usb_cdc_parsed_header hdr;
>=20
> 	ctx =3D kzalloc(sizeof(*ctx), GFP_KERNEL);
> 	if (!ctx)
>@@ -722,66 +723,14 @@ int cdc_ncm_bind_common(struct usbnet *dev,
>struct usb_interface *intf, u8 data_
> 	len =3D intf->cur_altsetting->extralen;
>=20
> 	/* parse through descriptors associated with control interface */
>-	while ((len > 0) && (buf[0] > 2) && (buf[0] <=3D len)) {
>-
>-		if (buf[1] !=3D USB_DT_CS_INTERFACE)
>-			goto advance;
>-
>-		switch (buf[2]) {
>-		case USB_CDC_UNION_TYPE:
>-			if (buf[0] < sizeof(*union_desc))
>-				break;
>-
>-			union_desc =3D (const struct usb_cdc_union_desc *)buf;
>-			/* the master must be the interface we are probing */
>-			if (intf->cur_altsetting->desc.bInterfaceNumber !=3D
>-			    union_desc->bMasterInterface0) {
>-				dev_dbg(&intf->dev, "bogus CDC Union\n");
>-				goto error;
>-			}
>-			ctx->data =3D usb_ifnum_to_if(dev->udev,
>-						    union_desc->bSlaveInterface0);
>-			break;
>-
>-		case USB_CDC_ETHERNET_TYPE:
>-			if (buf[0] < sizeof(*(ctx->ether_desc)))
>-				break;
>-
>-			ctx->ether_desc =3D
>-					(const struct usb_cdc_ether_desc *)buf;
>-			break;
>-
>-		case USB_CDC_NCM_TYPE:
>-			if (buf[0] < sizeof(*(ctx->func_desc)))
>-				break;
>-
>-			ctx->func_desc =3D (const struct usb_cdc_ncm_desc *)buf;
>-			break;
>-
>-		case USB_CDC_MBIM_TYPE:
>-			if (buf[0] < sizeof(*(ctx->mbim_desc)))
>-				break;
>-
>-			ctx->mbim_desc =3D (const struct usb_cdc_mbim_desc *)buf;
>-			break;
>-
>-		case USB_CDC_MBIM_EXTENDED_TYPE:
>-			if (buf[0] < sizeof(*(ctx->mbim_extended_desc)))
>-				break;
>-
>-			ctx->mbim_extended_desc =3D
>-				(const struct usb_cdc_mbim_extended_desc *)buf;
>-			break;
>-
>-		default:
>-			break;
>-		}
>-advance:
>-		/* advance to next descriptor */
>-		temp =3D buf[0];
>-		buf +=3D temp;
>-		len -=3D temp;
>-	}
>+	cdc_parse_cdc_header(&hdr, intf, buf, len);
>+
>+	ctx->data =3D usb_ifnum_to_if(dev->udev,=20
>+				    hdr.usb_cdc_union_desc->bSlaveInterface0);
>+	ctx->ether_desc =3D hdr.usb_cdc_ether_desc;
>+	ctx->func_desc =3D hdr.usb_cdc_ncm_desc;
>+	ctx->mbim_desc =3D hdr.usb_cdc_mbim_desc;
>+	ctx->mbim_extended_desc =3D hdr.usb_cdc_mbim_extended_desc;
>=20
> 	/* some buggy devices have an IAD but no CDC Union */
>	if (!union_desc && intf->intf_assoc &&
>intf->intf_assoc->bInterfaceCount =3D=3D 2) {
