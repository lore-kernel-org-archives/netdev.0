From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 08/24] net: cdc_ncm: remove ncm_parm field
Date: Fri,  1 Nov 2013 11:16:45 +0100
Message-ID: <1383301021-16613-9-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49979 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753666Ab3KAKRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 06:17:25 -0400
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moving the call to cdc_ncm_setup() after the endpoint
setup removes the last remaining reference to ncm_parm
outside cdc_ncm_setup.

Collecting all the ncm_parm based calculations in
cdc_ncm_setup improves readability.

Cc: Alexey Orishko <alexey.orishko@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c   |   46 +++++++++++++++++++++--------------=
--------
 include/linux/usb/cdc_ncm.h |    1 -
 2 files changed, 23 insertions(+), 24 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index fc36a99..4de3a542 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -83,6 +83,7 @@ cdc_ncm_get_drvinfo(struct net_device *net, struct et=
htool_drvinfo *info)
 static u8 cdc_ncm_setup(struct usbnet *dev)
 {
 	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	struct usb_cdc_ncm_ntb_parameters ncm_parm;
 	u32 val;
 	u8 flags;
 	u8 iface_no;
@@ -97,22 +98,22 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
 	err =3D usbnet_read_cmd(dev, USB_CDC_GET_NTB_PARAMETERS,
 			      USB_TYPE_CLASS | USB_DIR_IN
 			      |USB_RECIP_INTERFACE,
-			      0, iface_no, &ctx->ncm_parm,
-			      sizeof(ctx->ncm_parm));
+			      0, iface_no, &ncm_parm,
+			      sizeof(ncm_parm));
 	if (err < 0) {
 		pr_debug("failed GET_NTB_PARAMETERS\n");
 		return 1;
 	}
=20
 	/* read correct set of parameters according to device mode */
-	ctx->rx_max =3D le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize);
-	ctx->tx_max =3D le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize);
-	ctx->tx_remainder =3D le16_to_cpu(ctx->ncm_parm.wNdpOutPayloadRemaind=
er);
-	ctx->tx_modulus =3D le16_to_cpu(ctx->ncm_parm.wNdpOutDivisor);
-	ctx->tx_ndp_modulus =3D le16_to_cpu(ctx->ncm_parm.wNdpOutAlignment);
+	ctx->rx_max =3D le32_to_cpu(ncm_parm.dwNtbInMaxSize);
+	ctx->tx_max =3D le32_to_cpu(ncm_parm.dwNtbOutMaxSize);
+	ctx->tx_remainder =3D le16_to_cpu(ncm_parm.wNdpOutPayloadRemainder);
+	ctx->tx_modulus =3D le16_to_cpu(ncm_parm.wNdpOutDivisor);
+	ctx->tx_ndp_modulus =3D le16_to_cpu(ncm_parm.wNdpOutAlignment);
 	/* devices prior to NCM Errata shall set this field to zero */
-	ctx->tx_max_datagrams =3D le16_to_cpu(ctx->ncm_parm.wNtbOutMaxDatagra=
ms);
-	ntb_fmt_supported =3D le16_to_cpu(ctx->ncm_parm.bmNtbFormatsSupported=
);
+	ctx->tx_max_datagrams =3D le16_to_cpu(ncm_parm.wNtbOutMaxDatagrams);
+	ntb_fmt_supported =3D le16_to_cpu(ncm_parm.bmNtbFormatsSupported);
=20
 	eth_hlen =3D ETH_HLEN;
 	min_dgram_size =3D CDC_NCM_MIN_DATAGRAM_SIZE;
@@ -153,7 +154,7 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
 	}
=20
 	/* inform device about NTB input size changes */
-	if (ctx->rx_max !=3D le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize)) {
+	if (ctx->rx_max !=3D le32_to_cpu(ncm_parm.dwNtbInMaxSize)) {
 		__le32 dwNtbInMaxSize =3D cpu_to_le32(ctx->rx_max);
=20
 		err =3D usbnet_write_cmd(dev, USB_CDC_SET_NTB_INPUT_SIZE,
@@ -171,6 +172,14 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
 		pr_debug("Using default maximum transmit length=3D%d\n",
 						CDC_NCM_NTB_MAX_SIZE_TX);
 		ctx->tx_max =3D CDC_NCM_NTB_MAX_SIZE_TX;
+
+		/* Adding a pad byte here simplifies the handling in
+		 * cdc_ncm_fill_tx_frame, by making tx_max always
+		 * represent the real skb max size.
+		 */
+		if (ctx->tx_max % usb_maxpacket(dev->udev, dev->out, 1) =3D=3D 0)
+			ctx->tx_max++;
+
 	}
=20
 	/*
@@ -473,10 +482,6 @@ advance:
 	if (temp)
 		goto error2;
=20
-	/* initialize data interface */
-	if (cdc_ncm_setup(dev))
-		goto error2;
-
 	/* configure data interface */
 	temp =3D usb_set_interface(dev->udev, iface_no, data_altsetting);
 	if (temp)
@@ -487,6 +492,10 @@ advance:
 	if (!dev->in || !dev->out || !dev->status)
 		goto error2;
=20
+	/* initialize data interface */
+	if (cdc_ncm_setup(dev))
+		goto error2;
+
 	dev->net->ethtool_ops =3D &cdc_ncm_ethtool_ops;
=20
 	usb_set_intfdata(ctx->data, dev);
@@ -501,15 +510,6 @@ advance:
=20
 	dev->rx_urb_size =3D ctx->rx_max;
=20
-	/* cdc_ncm_setup will override dwNtbOutMaxSize if it is
-	 * outside the sane range. Adding a pad byte here if necessary
-	 * simplifies the handling in cdc_ncm_fill_tx_frame, making
-	 * tx_max always represent the real skb max size.
-	 */
-	if (ctx->tx_max !=3D le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize) &&
-	    ctx->tx_max % usb_maxpacket(dev->udev, dev->out, 1) =3D=3D 0)
-		ctx->tx_max++;
-
 	return 0;
=20
 error2:
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index f14af3d..89b52a0 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -88,7 +88,6 @@
 #define cdc_ncm_data_intf_is_mbim(x)  ((x)->desc.bInterfaceProtocol =3D=
=3D USB_CDC_MBIM_PROTO_NTB)
=20
 struct cdc_ncm_ctx {
-	struct usb_cdc_ncm_ntb_parameters ncm_parm;
 	struct hrtimer tx_timer;
 	struct tasklet_struct bh;
=20
--=20
1.7.10.4
