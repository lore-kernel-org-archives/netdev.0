From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 21/24] net: cdc_ncm: refactoring cdc_ncm_setup
Date: Fri,  1 Nov 2013 11:16:58 +0100
Message-ID: <1383301021-16613-22-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49971 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755919Ab3KAKRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 06:17:22 -0400
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rewriting the "set max datagram" part of dc_ncm_setup to
separate the selection and validatation of the size from
the code which optionally informs the device of this
value.  This ensures that we use the correct value
regardless of device support for the get and set commands.

Removing some of the many indent levels while doing this
to make the code more readable.

Cc: Alexey Orishko <alexey.orishko@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |  108 ++++++++++++++++++-------------------=
--------
 1 file changed, 44 insertions(+), 64 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 83e6d5b..62dcb2e 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -76,8 +76,7 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
 	int err;
 	int eth_hlen;
 	u16 ntb_fmt_supported;
-	u32 min_dgram_size;
-	u32 min_hdr_size;
+	__le16 max_datagram_size;
=20
 	iface_no =3D ctx->control->cur_altsetting->desc.bInterfaceNumber;
=20
@@ -101,20 +100,29 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
 	ctx->tx_max_datagrams =3D le16_to_cpu(ncm_parm.wNtbOutMaxDatagrams);
 	ntb_fmt_supported =3D le16_to_cpu(ncm_parm.bmNtbFormatsSupported);
=20
-	eth_hlen =3D ETH_HLEN;
-	min_dgram_size =3D CDC_NCM_MIN_DATAGRAM_SIZE;
-	min_hdr_size =3D CDC_NCM_MIN_HDR_SIZE;
-	if (ctx->mbim_desc !=3D NULL) {
-		flags =3D ctx->mbim_desc->bmNetworkCapabilities;
+	/* there are some minor differences in NCM and MBIM defaults */
+	if (cdc_ncm_comm_intf_is_mbim(ctx->control->cur_altsetting)) {
+		if (!ctx->mbim_desc)
+			return -EINVAL;
 		eth_hlen =3D 0;
-		min_dgram_size =3D CDC_MBIM_MIN_DATAGRAM_SIZE;
-		min_hdr_size =3D 0;
-	} else if (ctx->func_desc !=3D NULL) {
-		flags =3D ctx->func_desc->bmNetworkCapabilities;
+		flags =3D ctx->mbim_desc->bmNetworkCapabilities;
+		ctx->max_datagram_size =3D le16_to_cpu(ctx->mbim_desc->wMaxSegmentSi=
ze);
+		if (ctx->max_datagram_size < CDC_MBIM_MIN_DATAGRAM_SIZE)
+			ctx->max_datagram_size =3D CDC_MBIM_MIN_DATAGRAM_SIZE;
 	} else {
-		flags =3D 0;
+		if (!ctx->func_desc)
+			return -EINVAL;
+		eth_hlen =3D ETH_HLEN;
+		flags =3D ctx->func_desc->bmNetworkCapabilities;
+		ctx->max_datagram_size =3D le16_to_cpu(ctx->ether_desc->wMaxSegmentS=
ize);
+		if (ctx->max_datagram_size < CDC_NCM_MIN_DATAGRAM_SIZE)
+			ctx->max_datagram_size =3D CDC_NCM_MIN_DATAGRAM_SIZE;
 	}
=20
+	/* common absolute max for NCM and MBIM */
+	if (ctx->max_datagram_size > CDC_NCM_MAX_DATAGRAM_SIZE)
+		ctx->max_datagram_size =3D CDC_NCM_MAX_DATAGRAM_SIZE;
+
 	dev_dbg(&dev->intf->dev,
 		"dwNtbInMaxSize=3D%u dwNtbOutMaxSize=3D%u wNdpOutPayloadRemainder=3D=
%u wNdpOutDivisor=3D%u wNdpOutAlignment=3D%u wNtbOutMaxDatagrams=3D%u f=
lags=3D0x%x\n",
 		ctx->rx_max, ctx->tx_max, ctx->tx_remainder, ctx->tx_modulus,
@@ -151,8 +159,7 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
 	}
=20
 	/* verify maximum size of transmitted NTB in bytes */
-	if ((ctx->tx_max <
-	    (min_hdr_size + min_dgram_size)) ||
+	if ((ctx->tx_max < (CDC_NCM_MIN_HDR_SIZE + ctx->max_datagram_size)) |=
|
 	    (ctx->tx_max > CDC_NCM_NTB_MAX_SIZE_TX)) {
 		dev_dbg(&dev->intf->dev, "Using default maximum transmit length=3D%d=
\n",
 			CDC_NCM_NTB_MAX_SIZE_TX);
@@ -229,60 +236,33 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
 			dev_dbg(&dev->intf->dev, "Setting NTB format to 16-bit failed\n");
 	}
=20
-	ctx->max_datagram_size =3D min_dgram_size;
+	/* inform the device about the selected Max Datagram Size */
+	if (!(flags & USB_CDC_NCM_NCAP_MAX_DATAGRAM_SIZE))
+		goto out;
=20
-	/* set Max Datagram Size (MTU) */
-	if (flags & USB_CDC_NCM_NCAP_MAX_DATAGRAM_SIZE) {
-		__le16 max_datagram_size;
-		u16 eth_max_sz;
-		if (ctx->ether_desc !=3D NULL)
-			eth_max_sz =3D le16_to_cpu(ctx->ether_desc->wMaxSegmentSize);
-		else if (ctx->mbim_desc !=3D NULL)
-			eth_max_sz =3D le16_to_cpu(ctx->mbim_desc->wMaxSegmentSize);
-		else
-			goto max_dgram_err;
-
-		err =3D usbnet_read_cmd(dev, USB_CDC_GET_MAX_DATAGRAM_SIZE,
-				      USB_TYPE_CLASS | USB_DIR_IN
-				      | USB_RECIP_INTERFACE,
-				      0, iface_no, &max_datagram_size, 2);
-		if (err < 0) {
-			dev_dbg(&dev->intf->dev, "GET_MAX_DATAGRAM_SIZE failed, use size=3D=
%u\n",
-				min_dgram_size);
-		} else {
-			ctx->max_datagram_size =3D
-				le16_to_cpu(max_datagram_size);
-			/* Check Eth descriptor value */
-			if (ctx->max_datagram_size > eth_max_sz)
-					ctx->max_datagram_size =3D eth_max_sz;
-
-			if (ctx->max_datagram_size > CDC_NCM_MAX_DATAGRAM_SIZE)
-				ctx->max_datagram_size =3D CDC_NCM_MAX_DATAGRAM_SIZE;
-
-			if (ctx->max_datagram_size < min_dgram_size)
-				ctx->max_datagram_size =3D min_dgram_size;
-
-			/* if value changed, update device */
-			if (ctx->max_datagram_size !=3D
-					le16_to_cpu(max_datagram_size)) {
-				max_datagram_size =3D cpu_to_le16(ctx->max_datagram_size);
-				err =3D usbnet_write_cmd(dev,
-						USB_CDC_SET_MAX_DATAGRAM_SIZE,
-						USB_TYPE_CLASS | USB_DIR_OUT
-						 | USB_RECIP_INTERFACE,
-						0,
-						iface_no, &max_datagram_size,
-						2);
-				if (err < 0)
-					dev_dbg(&dev->intf->dev, "SET_MAX_DGRAM_SIZE failed\n");
-			}
-		}
+	/* read current mtu value from device */
+	err =3D usbnet_read_cmd(dev, USB_CDC_GET_MAX_DATAGRAM_SIZE,
+			      USB_TYPE_CLASS | USB_DIR_IN | USB_RECIP_INTERFACE,
+			      0, iface_no, &max_datagram_size, 2);
+	if (err < 0) {
+		dev_dbg(&dev->intf->dev, "GET_MAX_DATAGRAM_SIZE failed\n");
+		goto out;
 	}
=20
-max_dgram_err:
-	if (dev->net->mtu !=3D (ctx->max_datagram_size - eth_hlen))
-		dev->net->mtu =3D ctx->max_datagram_size - eth_hlen;
+	if (le16_to_cpu(max_datagram_size) =3D=3D ctx->max_datagram_size)
+		goto out;
+
+	max_datagram_size =3D cpu_to_le16(ctx->max_datagram_size);
+	err =3D usbnet_write_cmd(dev, USB_CDC_SET_MAX_DATAGRAM_SIZE,
+			       USB_TYPE_CLASS | USB_DIR_OUT | USB_RECIP_INTERFACE,
+			       0, iface_no, &max_datagram_size, 2);
+	if (err < 0)
+		dev_dbg(&dev->intf->dev, "SET_MAX_DATAGRAM_SIZE failed\n");
=20
+out:
+	/* set MTU to max supported by the device if necessary */
+	if (dev->net->mtu > ctx->max_datagram_size - eth_hlen)
+		dev->net->mtu =3D ctx->max_datagram_size - eth_hlen;
 	return 0;
 }
=20
--=20
1.7.10.4
