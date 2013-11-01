From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 01/24] net: cdc_ncm: simplify and optimize frame padding
Date: Fri,  1 Nov 2013 11:16:38 +0100
Message-ID: <1383301021-16613-2-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49960 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755270Ab3KAKRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 06:17:22 -0400
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can avoid the costly division for the common case where
we pad the frame to tx_max size as long as we ensure that
tx_max is either the device specified dwNtbOutMaxSize or not
a multiplum of wMaxPacketSize.

Using the preconverted 'maxpacket' field avoids converting
wMaxPacketSize to CPU endianness for every transmitted frame

And since we only will hit the one byte padding rule for short
frames, we can drop testing the skb for tailroom.

The change means that tx_max now represents the real maximum
skb size, enabling us to allocate the correct size instead of
always making room for one extra byte.

Cc: Alexey Orishko <alexey.orishko@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |   31 +++++++++++++++++++------------
 1 file changed, 19 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 43afde8..38566bf 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -506,6 +506,15 @@ advance:
 	dev->status =3D ctx->status_ep;
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
 	ctx->tx_speed =3D ctx->rx_speed =3D 0;
 	return 0;
=20
@@ -664,6 +673,7 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct=
 cdc_ncm_ctx *ctx, struct sk_
 struct sk_buff *
 cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb, __=
le32 sign)
 {
+	struct usbnet *dev =3D netdev_priv(ctx->netdev);
 	struct usb_cdc_ncm_nth16 *nth16;
 	struct usb_cdc_ncm_ndp16 *ndp16;
 	struct sk_buff *skb_out;
@@ -683,7 +693,7 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, stru=
ct sk_buff *skb, __le32 sign)
=20
 	/* allocate a new OUT skb */
 	if (!skb_out) {
-		skb_out =3D alloc_skb((ctx->tx_max + 1), GFP_ATOMIC);
+		skb_out =3D alloc_skb(ctx->tx_max, GFP_ATOMIC);
 		if (skb_out =3D=3D NULL) {
 			if (skb !=3D NULL) {
 				dev_kfree_skb_any(skb);
@@ -788,19 +798,16 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, st=
ruct sk_buff *skb, __le32 sign)
 		/* variables will be reset at next call */
 	}
=20
-	/*
-	 * If collected data size is less or equal CDC_NCM_MIN_TX_PKT bytes,
-	 * we send buffers as it is. If we get more data, it would be more
-	 * efficient for USB HS mobile device with DMA engine to receive a fu=
ll
-	 * size NTB, than canceling DMA transfer and receiving a short packet=
=2E
+	/* If collected data size is less or equal CDC_NCM_MIN_TX_PKT
+	 * bytes, we send buffers as it is. If we get more data, it
+	 * would be more efficient for USB HS mobile device with DMA
+	 * engine to receive a full size NTB, than canceling DMA
+	 * transfer and receiving a short packet.
 	 */
 	if (skb_out->len > CDC_NCM_MIN_TX_PKT)
-		/* final zero padding */
-		memset(skb_put(skb_out, ctx->tx_max - skb_out->len), 0, ctx->tx_max =
- skb_out->len);
-
-	/* do we need to prevent a ZLP? */
-	if (((skb_out->len % le16_to_cpu(ctx->out_ep->desc.wMaxPacketSize)) =3D=
=3D 0) &&
-	    (skb_out->len < le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize)) && sk=
b_tailroom(skb_out))
+		memset(skb_put(skb_out, ctx->tx_max - skb_out->len), 0,
+		       ctx->tx_max - skb_out->len);
+	else if ((skb_out->len % dev->maxpacket) =3D=3D 0)
 		*skb_put(skb_out, 1) =3D 0;	/* force short packet */
=20
 	/* set final frame length */
--=20
1.7.10.4
