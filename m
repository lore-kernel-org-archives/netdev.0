From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net,stable] net: cdc_ncm: fix control message ordering
Date: Mon, 17 Mar 2014 16:25:18 +0100
Message-ID: <1395069918-18585-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Pasi=20K=C3=A4rkk=C3=A4inen?= <pasik@iki.fi>,
	=?UTF-8?q?Thomas=20Sch=C3=A4fer?= <tschaefer@t-online.de>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:36293 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754444AbaCQP0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 11:26:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a context modified revert of commit 6a9612e2cb22
("net: cdc_ncm: remove ncm_parm field") which introduced
a NCM specification violation, causing setup errors for
some devices. These errors resulted in the device and
host disagreeing about shared settings, with complete
failure to communicate as the end result.

The NCM specification require that many of the NCM specific
control reuests are sent only while the NCM Data Interface
is in alternate setting 0. Reverting the commit ensures that
we follow this requirement.

=46ixes: 6a9612e2cb22 ("net: cdc_ncm: remove ncm_parm field")
Reported-and-tested-by: Pasi K=C3=A4rkk=C3=A4inen <pasik@iki.fi>
Reported-by: Thomas Sch=C3=A4fer <tschaefer@t-online.de>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
This needs to go to v3.14 and v3.13.x stable. The bug was introduced
in v3.13.

Bj=C3=B8rn

 drivers/net/usb/cdc_ncm.c   | 48 ++++++++++++++++++++++---------------=
--------
 include/linux/usb/cdc_ncm.h |  1 +
 2 files changed, 24 insertions(+), 25 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index dbff290ed0e4..d350d2795e10 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -68,7 +68,6 @@ static struct usb_driver cdc_ncm_driver;
 static int cdc_ncm_setup(struct usbnet *dev)
 {
 	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
-	struct usb_cdc_ncm_ntb_parameters ncm_parm;
 	u32 val;
 	u8 flags;
 	u8 iface_no;
@@ -82,22 +81,22 @@ static int cdc_ncm_setup(struct usbnet *dev)
 	err =3D usbnet_read_cmd(dev, USB_CDC_GET_NTB_PARAMETERS,
 			      USB_TYPE_CLASS | USB_DIR_IN
 			      |USB_RECIP_INTERFACE,
-			      0, iface_no, &ncm_parm,
-			      sizeof(ncm_parm));
+			      0, iface_no, &ctx->ncm_parm,
+			      sizeof(ctx->ncm_parm));
 	if (err < 0) {
 		dev_err(&dev->intf->dev, "failed GET_NTB_PARAMETERS\n");
 		return err; /* GET_NTB_PARAMETERS is required */
 	}
=20
 	/* read correct set of parameters according to device mode */
-	ctx->rx_max =3D le32_to_cpu(ncm_parm.dwNtbInMaxSize);
-	ctx->tx_max =3D le32_to_cpu(ncm_parm.dwNtbOutMaxSize);
-	ctx->tx_remainder =3D le16_to_cpu(ncm_parm.wNdpOutPayloadRemainder);
-	ctx->tx_modulus =3D le16_to_cpu(ncm_parm.wNdpOutDivisor);
-	ctx->tx_ndp_modulus =3D le16_to_cpu(ncm_parm.wNdpOutAlignment);
+	ctx->rx_max =3D le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize);
+	ctx->tx_max =3D le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize);
+	ctx->tx_remainder =3D le16_to_cpu(ctx->ncm_parm.wNdpOutPayloadRemaind=
er);
+	ctx->tx_modulus =3D le16_to_cpu(ctx->ncm_parm.wNdpOutDivisor);
+	ctx->tx_ndp_modulus =3D le16_to_cpu(ctx->ncm_parm.wNdpOutAlignment);
 	/* devices prior to NCM Errata shall set this field to zero */
-	ctx->tx_max_datagrams =3D le16_to_cpu(ncm_parm.wNtbOutMaxDatagrams);
-	ntb_fmt_supported =3D le16_to_cpu(ncm_parm.bmNtbFormatsSupported);
+	ctx->tx_max_datagrams =3D le16_to_cpu(ctx->ncm_parm.wNtbOutMaxDatagra=
ms);
+	ntb_fmt_supported =3D le16_to_cpu(ctx->ncm_parm.bmNtbFormatsSupported=
);
=20
 	/* there are some minor differences in NCM and MBIM defaults */
 	if (cdc_ncm_comm_intf_is_mbim(ctx->control->cur_altsetting)) {
@@ -146,7 +145,7 @@ static int cdc_ncm_setup(struct usbnet *dev)
 	}
=20
 	/* inform device about NTB input size changes */
-	if (ctx->rx_max !=3D le32_to_cpu(ncm_parm.dwNtbInMaxSize)) {
+	if (ctx->rx_max !=3D le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize)) {
 		__le32 dwNtbInMaxSize =3D cpu_to_le32(ctx->rx_max);
=20
 		err =3D usbnet_write_cmd(dev, USB_CDC_SET_NTB_INPUT_SIZE,
@@ -162,14 +161,6 @@ static int cdc_ncm_setup(struct usbnet *dev)
 		dev_dbg(&dev->intf->dev, "Using default maximum transmit length=3D%d=
\n",
 			CDC_NCM_NTB_MAX_SIZE_TX);
 		ctx->tx_max =3D CDC_NCM_NTB_MAX_SIZE_TX;
-
-		/* Adding a pad byte here simplifies the handling in
-		 * cdc_ncm_fill_tx_frame, by making tx_max always
-		 * represent the real skb max size.
-		 */
-		if (ctx->tx_max % usb_maxpacket(dev->udev, dev->out, 1) =3D=3D 0)
-			ctx->tx_max++;
-
 	}
=20
 	/*
@@ -439,6 +430,10 @@ advance:
 		goto error2;
 	}
=20
+	/* initialize data interface */
+	if (cdc_ncm_setup(dev))
+		goto error2;
+
 	/* configure data interface */
 	temp =3D usb_set_interface(dev->udev, iface_no, data_altsetting);
 	if (temp) {
@@ -453,12 +448,6 @@ advance:
 		goto error2;
 	}
=20
-	/* initialize data interface */
-	if (cdc_ncm_setup(dev))	{
-		dev_dbg(&intf->dev, "cdc_ncm_setup() failed\n");
-		goto error2;
-	}
-
 	usb_set_intfdata(ctx->data, dev);
 	usb_set_intfdata(ctx->control, dev);
=20
@@ -475,6 +464,15 @@ advance:
 	dev->hard_mtu =3D ctx->tx_max;
 	dev->rx_urb_size =3D ctx->rx_max;
=20
+	/* cdc_ncm_setup will override dwNtbOutMaxSize if it is
+	 * outside the sane range. Adding a pad byte here if necessary
+	 * simplifies the handling in cdc_ncm_fill_tx_frame, making
+	 * tx_max always represent the real skb max size.
+	 */
+	if (ctx->tx_max !=3D le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize) &&
+	    ctx->tx_max % usb_maxpacket(dev->udev, dev->out, 1) =3D=3D 0)
+		ctx->tx_max++;
+
 	return 0;
=20
 error2:
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index c3fa80745996..2c14d9cdd57a 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -88,6 +88,7 @@
 #define cdc_ncm_data_intf_is_mbim(x)  ((x)->desc.bInterfaceProtocol =3D=
=3D USB_CDC_MBIM_PROTO_NTB)
=20
 struct cdc_ncm_ctx {
+	struct usb_cdc_ncm_ntb_parameters ncm_parm;
 	struct hrtimer tx_timer;
 	struct tasklet_struct bh;
=20
--=20
1.9.0
