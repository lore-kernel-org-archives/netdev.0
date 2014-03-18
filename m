From: Ben Chan <benchan@chromium.org>
Subject: [PATCH v3 2/2] net: cdc_ncm: respect operator preferred MTU reported by MBIM
Date: Mon, 17 Mar 2014 20:59:05 -0700
Message-ID: <1395115145-31821-2-git-send-email-benchan@chromium.org>
References: <1395115145-31821-1-git-send-email-benchan@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Greg Suarez <gsuarez@smithmicro.com>
To: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:56430 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753035AbaCRD7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 23:59:07 -0400
Received: by mail-ob0-f201.google.com with SMTP id gq1so1310242obb.4
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 20:59:06 -0700 (PDT)
In-Reply-To: <1395115145-31821-1-git-send-email-benchan@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to "Universal Serial Bus Communications Class Subclass
Specification for Mobile Broadband Interface Model, Revision 1.0,
Errata-1" published by USB-IF, the wMTU field of the MBIM extended
functional descriptor indicates the operator preferred MTU for IP data
streams.

This patch modifies cdc_ncm_setup to ensure that the MTU value set on
the usbnet device does not exceed the operator preferred MTU indicated
by wMTU if the MBIM device exposes a MBIM extended functional
descriptor.

Signed-off-by: Ben Chan <benchan@chromium.org>
---
Patch v3 (which is same as v2) adds the le16_to_cpu conversion on
ctx->mbim_extended_desc->wMTU as pointed out and suggested by
'Bj=C3=B8rn Mork <bjorn@mork.no>'.

 drivers/net/usb/cdc_ncm.c   | 17 +++++++++++++++++
 include/linux/usb/cdc_ncm.h |  1 +
 2 files changed, 18 insertions(+)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index dbff290..e8711a8 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -74,6 +74,7 @@ static int cdc_ncm_setup(struct usbnet *dev)
 	u8 iface_no;
 	int err;
 	int eth_hlen;
+	u16 mbim_mtu;
 	u16 ntb_fmt_supported;
 	__le16 max_datagram_size;
=20
@@ -261,6 +262,14 @@ out:
 	/* set MTU to max supported by the device if necessary */
 	if (dev->net->mtu > ctx->max_datagram_size - eth_hlen)
 		dev->net->mtu =3D ctx->max_datagram_size - eth_hlen;
+
+	/* do not exceed operater preferred MTU */
+	if (ctx->mbim_extended_desc) {
+		mbim_mtu =3D le16_to_cpu(ctx->mbim_extended_desc->wMTU);
+		if (mbim_mtu !=3D 0 && mbim_mtu < dev->net->mtu)
+			dev->net->mtu =3D mbim_mtu;
+	}
+
 	return 0;
 }
=20
@@ -399,6 +408,14 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct=
 usb_interface *intf, u8 data_
 			ctx->mbim_desc =3D (const struct usb_cdc_mbim_desc *)buf;
 			break;
=20
+		case USB_CDC_MBIM_EXTENDED_TYPE:
+			if (buf[0] < sizeof(*(ctx->mbim_extended_desc)))
+				break;
+
+			ctx->mbim_extended_desc =3D
+				(const struct usb_cdc_mbim_extended_desc *)buf;
+			break;
+
 		default:
 			break;
 		}
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index c3fa807..bdf05fb 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -93,6 +93,7 @@ struct cdc_ncm_ctx {
=20
 	const struct usb_cdc_ncm_desc *func_desc;
 	const struct usb_cdc_mbim_desc *mbim_desc;
+	const struct usb_cdc_mbim_extended_desc *mbim_extended_desc;
 	const struct usb_cdc_ether_desc *ether_desc;
=20
 	struct usb_interface *control;
--=20
1.9.0.279.gdc9e3eb
