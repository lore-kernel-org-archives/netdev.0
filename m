From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 02/11] net: cdc_ncm: factor out one-time device initialization
Date: Sat, 10 May 2014 17:41:40 +0200
Message-ID: <1399736509-1159-3-git-send-email-bjorn@mork.no>
References: <1399736509-1159-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43759 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752161AbaEJPmU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 May 2014 11:42:20 -0400
In-Reply-To: <1399736509-1159-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split the parts of setup dealing with device initialization from
parts just setting defaults for attributes which might be
changed after initialization.

Some commands of the device initialization are only allowed when
the data interface is in its disabled altsetting, so we must
separate them out of we are to allow rerunning parts of setup.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c | 251 ++++++++++++++++++++++++++++----------=
--------
 1 file changed, 155 insertions(+), 96 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 87a32edf7ea5..d2e9b56c27ff 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -113,19 +113,51 @@ static void cdc_ncm_update_rxtx_max(struct usbnet=
 *dev, u32 new_rx, u32 new_tx)
 	ctx->tx_max =3D val;
 }
=20
-static int cdc_ncm_setup(struct usbnet *dev)
+/* helpers for NCM and MBIM differences */
+static u8 cdc_ncm_flags(struct usbnet *dev)
 {
 	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
-	u32 val;
-	u8 flags;
-	u8 iface_no;
-	int err;
-	int eth_hlen;
-	u16 mbim_mtu;
-	u16 ntb_fmt_supported;
-	__le16 max_datagram_size;
=20
-	iface_no =3D ctx->control->cur_altsetting->desc.bInterfaceNumber;
+	if (cdc_ncm_comm_intf_is_mbim(dev->intf->cur_altsetting) && ctx->mbim=
_desc)
+		return ctx->mbim_desc->bmNetworkCapabilities;
+	if (ctx->func_desc)
+		return ctx->func_desc->bmNetworkCapabilities;
+	return 0;
+}
+
+static int cdc_ncm_eth_hlen(struct usbnet *dev)
+{
+	if (cdc_ncm_comm_intf_is_mbim(dev->intf->cur_altsetting))
+		return 0;
+	return ETH_HLEN;
+}
+
+static u32 cdc_ncm_min_dgram_size(struct usbnet *dev)
+{
+	if (cdc_ncm_comm_intf_is_mbim(dev->intf->cur_altsetting))
+		return CDC_MBIM_MIN_DATAGRAM_SIZE;
+	return CDC_NCM_MIN_DATAGRAM_SIZE;
+}
+
+static u32 cdc_ncm_max_dgram_size(struct usbnet *dev)
+{
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+
+	if (cdc_ncm_comm_intf_is_mbim(dev->intf->cur_altsetting) && ctx->mbim=
_desc)
+		return le16_to_cpu(ctx->mbim_desc->wMaxSegmentSize);
+	if (ctx->ether_desc)
+		return le16_to_cpu(ctx->ether_desc->wMaxSegmentSize);
+	return CDC_NCM_MAX_DATAGRAM_SIZE;
+}
+
+/* initial one-time device setup.  MUST be called with the data interf=
ace
+ * in altsetting 0
+ */
+static int cdc_ncm_init(struct usbnet *dev)
+{
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	u8 iface_no =3D ctx->control->cur_altsetting->desc.bInterfaceNumber;
+	int err;
=20
 	err =3D usbnet_read_cmd(dev, USB_CDC_GET_NTB_PARAMETERS,
 			      USB_TYPE_CLASS | USB_DIR_IN
@@ -137,7 +169,35 @@ static int cdc_ncm_setup(struct usbnet *dev)
 		return err; /* GET_NTB_PARAMETERS is required */
 	}
=20
-	/* read correct set of parameters according to device mode */
+	/* set CRC Mode */
+	if (cdc_ncm_flags(dev) & USB_CDC_NCM_NCAP_CRC_MODE) {
+		dev_dbg(&dev->intf->dev, "Setting CRC mode off\n");
+		err =3D usbnet_write_cmd(dev, USB_CDC_SET_CRC_MODE,
+				       USB_TYPE_CLASS | USB_DIR_OUT
+				       | USB_RECIP_INTERFACE,
+				       USB_CDC_NCM_CRC_NOT_APPENDED,
+				       iface_no, NULL, 0);
+		if (err < 0)
+			dev_err(&dev->intf->dev, "SET_CRC_MODE failed\n");
+	}
+
+	/* set NTB format, if both formats are supported.
+	 *
+	 * "The host shall only send this command while the NCM Data
+	 *  Interface is in alternate setting 0."
+	 */
+	if (le16_to_cpu(ctx->ncm_parm.bmNtbFormatsSupported) & USB_CDC_NCM_NT=
H32_SIGN) {
+		dev_dbg(&dev->intf->dev, "Setting NTB format to 16-bit\n");
+		err =3D usbnet_write_cmd(dev, USB_CDC_SET_NTB_FORMAT,
+				       USB_TYPE_CLASS | USB_DIR_OUT
+				       | USB_RECIP_INTERFACE,
+				       USB_CDC_NCM_NTB16_FORMAT,
+				       iface_no, NULL, 0);
+		if (err < 0)
+			dev_err(&dev->intf->dev, "SET_NTB_FORMAT failed\n");
+	}
+
+	/* set initial device values */
 	ctx->rx_max =3D le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize);
 	ctx->tx_max =3D le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize);
 	ctx->tx_remainder =3D le16_to_cpu(ctx->ncm_parm.wNdpOutPayloadRemaind=
er);
@@ -145,43 +205,73 @@ static int cdc_ncm_setup(struct usbnet *dev)
 	ctx->tx_ndp_modulus =3D le16_to_cpu(ctx->ncm_parm.wNdpOutAlignment);
 	/* devices prior to NCM Errata shall set this field to zero */
 	ctx->tx_max_datagrams =3D le16_to_cpu(ctx->ncm_parm.wNtbOutMaxDatagra=
ms);
-	ntb_fmt_supported =3D le16_to_cpu(ctx->ncm_parm.bmNtbFormatsSupported=
);
-
-	/* there are some minor differences in NCM and MBIM defaults */
-	if (cdc_ncm_comm_intf_is_mbim(ctx->control->cur_altsetting)) {
-		if (!ctx->mbim_desc)
-			return -EINVAL;
-		eth_hlen =3D 0;
-		flags =3D ctx->mbim_desc->bmNetworkCapabilities;
-		ctx->max_datagram_size =3D le16_to_cpu(ctx->mbim_desc->wMaxSegmentSi=
ze);
-		if (ctx->max_datagram_size < CDC_MBIM_MIN_DATAGRAM_SIZE)
-			ctx->max_datagram_size =3D CDC_MBIM_MIN_DATAGRAM_SIZE;
-	} else {
-		if (!ctx->func_desc)
-			return -EINVAL;
-		eth_hlen =3D ETH_HLEN;
-		flags =3D ctx->func_desc->bmNetworkCapabilities;
-		ctx->max_datagram_size =3D le16_to_cpu(ctx->ether_desc->wMaxSegmentS=
ize);
-		if (ctx->max_datagram_size < CDC_NCM_MIN_DATAGRAM_SIZE)
-			ctx->max_datagram_size =3D CDC_NCM_MIN_DATAGRAM_SIZE;
-	}
-
-	/* common absolute max for NCM and MBIM */
-	if (ctx->max_datagram_size > CDC_NCM_MAX_DATAGRAM_SIZE)
-		ctx->max_datagram_size =3D CDC_NCM_MAX_DATAGRAM_SIZE;
=20
 	dev_dbg(&dev->intf->dev,
 		"dwNtbInMaxSize=3D%u dwNtbOutMaxSize=3D%u wNdpOutPayloadRemainder=3D=
%u wNdpOutDivisor=3D%u wNdpOutAlignment=3D%u wNtbOutMaxDatagrams=3D%u f=
lags=3D0x%x\n",
 		ctx->rx_max, ctx->tx_max, ctx->tx_remainder, ctx->tx_modulus,
-		ctx->tx_ndp_modulus, ctx->tx_max_datagrams, flags);
+		ctx->tx_ndp_modulus, ctx->tx_max_datagrams, cdc_ncm_flags(dev));
=20
 	/* max count of tx datagrams */
 	if ((ctx->tx_max_datagrams =3D=3D 0) ||
 			(ctx->tx_max_datagrams > CDC_NCM_DPT_DATAGRAMS_MAX))
 		ctx->tx_max_datagrams =3D CDC_NCM_DPT_DATAGRAMS_MAX;
=20
-	/* clamp rx_max and tx_max and inform device */
-	cdc_ncm_update_rxtx_max(dev, le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize=
), le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize));
+	return 0;
+}
+
+/* set a new max datagram size */
+static void cdc_ncm_set_dgram_size(struct usbnet *dev, int new_size)
+{
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	u8 iface_no =3D ctx->control->cur_altsetting->desc.bInterfaceNumber;
+	__le16 max_datagram_size;
+	u16 mbim_mtu;
+	int err;
+
+	/* set default based on descriptors */
+	ctx->max_datagram_size =3D clamp_t(u32, new_size,
+					 cdc_ncm_min_dgram_size(dev),
+					 CDC_NCM_MAX_DATAGRAM_SIZE);
+
+	/* inform the device about the selected Max Datagram Size? */
+	if (!(cdc_ncm_flags(dev) & USB_CDC_NCM_NCAP_MAX_DATAGRAM_SIZE))
+		goto out;
+
+	/* read current mtu value from device */
+	err =3D usbnet_read_cmd(dev, USB_CDC_GET_MAX_DATAGRAM_SIZE,
+			      USB_TYPE_CLASS | USB_DIR_IN | USB_RECIP_INTERFACE,
+			      0, iface_no, &max_datagram_size, 2);
+	if (err < 0) {
+		dev_dbg(&dev->intf->dev, "GET_MAX_DATAGRAM_SIZE failed\n");
+		goto out;
+	}
+
+	if (le16_to_cpu(max_datagram_size) =3D=3D ctx->max_datagram_size)
+		goto out;
+
+	max_datagram_size =3D cpu_to_le16(ctx->max_datagram_size);
+	err =3D usbnet_write_cmd(dev, USB_CDC_SET_MAX_DATAGRAM_SIZE,
+			       USB_TYPE_CLASS | USB_DIR_OUT | USB_RECIP_INTERFACE,
+			       0, iface_no, &max_datagram_size, 2);
+	if (err < 0)
+		dev_dbg(&dev->intf->dev, "SET_MAX_DATAGRAM_SIZE failed\n");
+
+out:
+	/* set MTU to max supported by the device if necessary */
+	dev->net->mtu =3D min_t(int, dev->net->mtu, ctx->max_datagram_size - =
cdc_ncm_eth_hlen(dev));
+
+	/* do not exceed operater preferred MTU */
+	if (ctx->mbim_extended_desc) {
+		mbim_mtu =3D le16_to_cpu(ctx->mbim_extended_desc->wMTU);
+		if (mbim_mtu !=3D 0 && mbim_mtu < dev->net->mtu)
+			dev->net->mtu =3D mbim_mtu;
+	}
+}
+
+static void cdc_ncm_fix_modulus(struct usbnet *dev)
+{
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	u32 val;
=20
 	/*
 	 * verify that the structure alignment is:
@@ -218,68 +308,26 @@ static int cdc_ncm_setup(struct usbnet *dev)
 	}
=20
 	/* adjust TX-remainder according to NCM specification. */
-	ctx->tx_remainder =3D ((ctx->tx_remainder - eth_hlen) &
+	ctx->tx_remainder =3D ((ctx->tx_remainder - cdc_ncm_eth_hlen(dev)) &
 			     (ctx->tx_modulus - 1));
+}
=20
-	/* additional configuration */
-
-	/* set CRC Mode */
-	if (flags & USB_CDC_NCM_NCAP_CRC_MODE) {
-		err =3D usbnet_write_cmd(dev, USB_CDC_SET_CRC_MODE,
-				       USB_TYPE_CLASS | USB_DIR_OUT
-				       | USB_RECIP_INTERFACE,
-				       USB_CDC_NCM_CRC_NOT_APPENDED,
-				       iface_no, NULL, 0);
-		if (err < 0)
-			dev_dbg(&dev->intf->dev, "Setting CRC mode off failed\n");
-	}
-
-	/* set NTB format, if both formats are supported */
-	if (ntb_fmt_supported & USB_CDC_NCM_NTH32_SIGN) {
-		err =3D usbnet_write_cmd(dev, USB_CDC_SET_NTB_FORMAT,
-				       USB_TYPE_CLASS | USB_DIR_OUT
-				       | USB_RECIP_INTERFACE,
-				       USB_CDC_NCM_NTB16_FORMAT,
-				       iface_no, NULL, 0);
-		if (err < 0)
-			dev_dbg(&dev->intf->dev, "Setting NTB format to 16-bit failed\n");
-	}
-
-	/* inform the device about the selected Max Datagram Size */
-	if (!(flags & USB_CDC_NCM_NCAP_MAX_DATAGRAM_SIZE))
-		goto out;
-
-	/* read current mtu value from device */
-	err =3D usbnet_read_cmd(dev, USB_CDC_GET_MAX_DATAGRAM_SIZE,
-			      USB_TYPE_CLASS | USB_DIR_IN | USB_RECIP_INTERFACE,
-			      0, iface_no, &max_datagram_size, 2);
-	if (err < 0) {
-		dev_dbg(&dev->intf->dev, "GET_MAX_DATAGRAM_SIZE failed\n");
-		goto out;
-	}
+static int cdc_ncm_setup(struct usbnet *dev)
+{
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
=20
-	if (le16_to_cpu(max_datagram_size) =3D=3D ctx->max_datagram_size)
-		goto out;
+	/* initialize basic device settings */
+	cdc_ncm_init(dev);
=20
-	max_datagram_size =3D cpu_to_le16(ctx->max_datagram_size);
-	err =3D usbnet_write_cmd(dev, USB_CDC_SET_MAX_DATAGRAM_SIZE,
-			       USB_TYPE_CLASS | USB_DIR_OUT | USB_RECIP_INTERFACE,
-			       0, iface_no, &max_datagram_size, 2);
-	if (err < 0)
-		dev_dbg(&dev->intf->dev, "SET_MAX_DATAGRAM_SIZE failed\n");
-
-out:
-	/* set MTU to max supported by the device if necessary */
-	if (dev->net->mtu > ctx->max_datagram_size - eth_hlen)
-		dev->net->mtu =3D ctx->max_datagram_size - eth_hlen;
+	/* clamp rx_max and tx_max and inform device */
+	cdc_ncm_update_rxtx_max(dev, le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize=
),
+				le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize));
=20
-	/* do not exceed operater preferred MTU */
-	if (ctx->mbim_extended_desc) {
-		mbim_mtu =3D le16_to_cpu(ctx->mbim_extended_desc->wMTU);
-		if (mbim_mtu !=3D 0 && mbim_mtu < dev->net->mtu)
-			dev->net->mtu =3D mbim_mtu;
-	}
+	/* sanitize the modulus and remainder values */
+	cdc_ncm_fix_modulus(dev);
=20
+	/* set max datagram size */
+	cdc_ncm_set_dgram_size(dev, cdc_ncm_max_dgram_size(dev));
 	return 0;
 }
=20
@@ -443,10 +491,21 @@ advance:
 	}
=20
 	/* check if we got everything */
-	if (!ctx->data || (!ctx->mbim_desc && !ctx->ether_desc)) {
-		dev_dbg(&intf->dev, "CDC descriptors missing\n");
+	if (!ctx->data) {
+		dev_dbg(&intf->dev, "CDC Union missing and no IAD found\n");
 		goto error;
 	}
+	if (cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting)) {
+		if (!ctx->mbim_desc) {
+			dev_dbg(&intf->dev, "MBIM functional descriptor missing\n");
+			goto error;
+		}
+	} else {
+		if (!ctx->ether_desc || !ctx->func_desc) {
+			dev_dbg(&intf->dev, "NCM or ECM functional descriptors missing\n");
+			goto error;
+		}
+	}
=20
 	/* claim data interface, if different from control */
 	if (ctx->data !=3D ctx->control) {
--=20
2.0.0.rc2
