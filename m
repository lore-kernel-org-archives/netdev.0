From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next v2 01/12] net: cdc_ncm: split out rx_max/tx_max update of setup
Date: Fri, 16 May 2014 21:48:18 +0200
Message-ID: <1400269709-18854-2-git-send-email-bjorn@mork.no>
References: <1400269709-18854-1-git-send-email-bjorn@mork.no>
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
Received: from canardo.mork.no ([148.122.252.1]:52169 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757375AbaEPTst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 15:48:49 -0400
In-Reply-To: <1400269709-18854-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split out the part of setup dealing with updating the rx_max
and tx_max buffer sizes so that this code can be reused for
dynamically updating the limits.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c | 88 ++++++++++++++++++++++++++++++---------=
--------
 1 file changed, 57 insertions(+), 31 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index d23bca57a23f..e5f5153bf8c6 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -65,6 +65,61 @@ static void cdc_ncm_tx_timeout_start(struct cdc_ncm_=
ctx *ctx);
 static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_tim=
er);
 static struct usb_driver cdc_ncm_driver;
=20
+/* handle rx_max and tx_max changes */
+static void cdc_ncm_update_rxtx_max(struct usbnet *dev, u32 new_rx, u3=
2 new_tx)
+{
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	u8 iface_no =3D ctx->control->cur_altsetting->desc.bInterfaceNumber;
+	u32 val, max, min;
+
+	/* clamp new_rx to sane values */
+	min =3D USB_CDC_NCM_NTB_MIN_IN_SIZE;
+	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_RX, le32_to_cpu(ctx->ncm_parm=
=2EdwNtbInMaxSize));
+
+	/* dwNtbInMaxSize spec violation? Use MIN size for both limits */
+	if (max < min) {
+		dev_warn(&dev->intf->dev, "dwNtbInMaxSize=3D%u is too small. Using %=
u\n",
+			 le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize), min);
+		max =3D min;
+	}
+
+	val =3D clamp_t(u32, new_rx, min, max);
+	if (val !=3D new_rx) {
+		dev_dbg(&dev->intf->dev, "rx_max must be in the [%u, %u] range. Usin=
g %u\n",
+			min, max, val);
+	}
+
+	/* inform device about NTB input size changes */
+	if (val !=3D ctx->rx_max) {
+		__le32 dwNtbInMaxSize =3D cpu_to_le32(val);
+
+		dev_info(&dev->intf->dev, "setting rx_max =3D %u\n", val);
+		if (usbnet_write_cmd(dev, USB_CDC_SET_NTB_INPUT_SIZE,
+				     USB_TYPE_CLASS | USB_DIR_OUT
+				     | USB_RECIP_INTERFACE,
+				     0, iface_no, &dwNtbInMaxSize, 4) < 0)
+			dev_dbg(&dev->intf->dev, "Setting NTB Input Size failed\n");
+		else
+			ctx->rx_max =3D val;
+	}
+
+	/* clamp new_tx to sane values */
+	min =3D CDC_NCM_MIN_HDR_SIZE + ctx->max_datagram_size;
+	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_TX, le32_to_cpu(ctx->ncm_parm=
=2EdwNtbOutMaxSize));
+
+	/* some devices set dwNtbOutMaxSize too low for the above default */
+	min =3D min(min, max);
+
+	val =3D clamp_t(u32, new_tx, min, max);
+	if (val !=3D new_tx) {
+		dev_dbg(&dev->intf->dev, "tx_max must be in the [%u, %u] range. Usin=
g %u\n",
+			min, max, val);
+	}
+	if (val !=3D ctx->tx_max)
+		dev_info(&dev->intf->dev, "setting tx_max =3D %u\n", val);
+	ctx->tx_max =3D val;
+}
+
 static int cdc_ncm_setup(struct usbnet *dev)
 {
 	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
@@ -132,37 +187,8 @@ static int cdc_ncm_setup(struct usbnet *dev)
 			(ctx->tx_max_datagrams > CDC_NCM_DPT_DATAGRAMS_MAX))
 		ctx->tx_max_datagrams =3D CDC_NCM_DPT_DATAGRAMS_MAX;
=20
-	/* verify maximum size of received NTB in bytes */
-	if (ctx->rx_max < USB_CDC_NCM_NTB_MIN_IN_SIZE) {
-		dev_dbg(&dev->intf->dev, "Using min receive length=3D%d\n",
-			USB_CDC_NCM_NTB_MIN_IN_SIZE);
-		ctx->rx_max =3D USB_CDC_NCM_NTB_MIN_IN_SIZE;
-	}
-
-	if (ctx->rx_max > CDC_NCM_NTB_MAX_SIZE_RX) {
-		dev_dbg(&dev->intf->dev, "Using default maximum receive length=3D%d\=
n",
-			CDC_NCM_NTB_MAX_SIZE_RX);
-		ctx->rx_max =3D CDC_NCM_NTB_MAX_SIZE_RX;
-	}
-
-	/* inform device about NTB input size changes */
-	if (ctx->rx_max !=3D le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize)) {
-		__le32 dwNtbInMaxSize =3D cpu_to_le32(ctx->rx_max);
-
-		err =3D usbnet_write_cmd(dev, USB_CDC_SET_NTB_INPUT_SIZE,
-				       USB_TYPE_CLASS | USB_DIR_OUT
-				       | USB_RECIP_INTERFACE,
-				       0, iface_no, &dwNtbInMaxSize, 4);
-		if (err < 0)
-			dev_dbg(&dev->intf->dev, "Setting NTB Input Size failed\n");
-	}
-
-	/* verify maximum size of transmitted NTB in bytes */
-	if (ctx->tx_max > CDC_NCM_NTB_MAX_SIZE_TX) {
-		dev_dbg(&dev->intf->dev, "Using default maximum transmit length=3D%d=
\n",
-			CDC_NCM_NTB_MAX_SIZE_TX);
-		ctx->tx_max =3D CDC_NCM_NTB_MAX_SIZE_TX;
-	}
+	/* clamp rx_max and tx_max and inform device */
+	cdc_ncm_update_rxtx_max(dev, le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize=
), le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize));
=20
 	/*
 	 * verify that the structure alignment is:
--=20
2.0.0.rc2
