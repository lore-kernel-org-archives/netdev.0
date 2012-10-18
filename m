From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 04/14] net: cdc_ncm: adding MBIM support to ncm_setup
Date: Thu, 18 Oct 2012 22:40:57 +0200
Message-ID: <1350592867-25651-5-git-send-email-bjorn@mork.no>
References: <1350592867-25651-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Greg Suarez <gpsuarez2512@gmail.com>,
	"Fangxiaozhi (Franko)" <fangxiaozhi@huawei.com>,
	Dan Williams <dcbw@redhat.com>,
	Aleksander Morgado <aleksander@lanedo.com>,
	Greg Suarez <gsuarez@smithmicro.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60370 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932416Ab2JRUmu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 16:42:50 -0400
In-Reply-To: <1350592867-25651-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Greg Suarez <gsuarez@smithmicro.com>

MBIM and NCM are very similar, so we can reuse most of the
setup and bind logic in cdc_ncm for CDC MBIM devices.  Handle
a few minor differences in ncm_setup.

Signed-off-by: Greg Suarez <gsuarez@smithmicro.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |   51 ++++++++++++++++++++++++++++++++-----=
--------
 1 file changed, 36 insertions(+), 15 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 6a65662..bddb0e4 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -64,6 +64,9 @@
 /* Minimum value for MaxDatagramSize, ch. 6.2.9 */
 #define	CDC_NCM_MIN_DATAGRAM_SIZE		1514	/* bytes */
=20
+/* Minimum value for MaxDatagramSize, ch. 8.1.3 */
+#define CDC_MBIM_MIN_DATAGRAM_SIZE              2048    /* bytes */
+
 #define	CDC_NCM_MIN_TX_PKT			512	/* bytes */
=20
 /* Default value for MaxDatagramSize */
@@ -98,6 +101,7 @@ struct cdc_ncm_ctx {
 	struct tasklet_struct bh;
=20
 	const struct usb_cdc_ncm_desc *func_desc;
+	const struct usb_cdc_mbim_desc *mbim_desc;
 	const struct usb_cdc_header_desc *header_desc;
 	const struct usb_cdc_union_desc *union_desc;
 	const struct usb_cdc_ether_desc *ether_desc;
@@ -158,7 +162,10 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 	u8 flags;
 	u8 iface_no;
 	int err;
+	int eth_hlen;
 	u16 ntb_fmt_supported;
+	u32 min_dgram_size;
+	u32 min_hdr_size;
=20
 	iface_no =3D ctx->control->cur_altsetting->desc.bInterfaceNumber;
=20
@@ -184,10 +191,19 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 	ctx->tx_max_datagrams =3D le16_to_cpu(ctx->ncm_parm.wNtbOutMaxDatagra=
ms);
 	ntb_fmt_supported =3D le16_to_cpu(ctx->ncm_parm.bmNtbFormatsSupported=
);
=20
-	if (ctx->func_desc !=3D NULL)
+	eth_hlen =3D ETH_HLEN;
+	min_dgram_size =3D CDC_NCM_MIN_DATAGRAM_SIZE;
+	min_hdr_size =3D CDC_NCM_MIN_HDR_SIZE;
+	if (ctx->mbim_desc !=3D NULL) {
+		flags =3D ctx->mbim_desc->bmNetworkCapabilities;
+		eth_hlen =3D 0;
+		min_dgram_size =3D CDC_MBIM_MIN_DATAGRAM_SIZE;
+		min_hdr_size =3D 0;
+	} else if (ctx->func_desc !=3D NULL) {
 		flags =3D ctx->func_desc->bmNetworkCapabilities;
-	else
+	} else {
 		flags =3D 0;
+	}
=20
 	pr_debug("dwNtbInMaxSize=3D%u dwNtbOutMaxSize=3D%u "
 		 "wNdpOutPayloadRemainder=3D%u wNdpOutDivisor=3D%u "
@@ -224,6 +240,7 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 				err =3D -ENOMEM;
 				goto size_err;
 			}
+			ndp_in_sz->dwNtbInMaxSize =3D cpu_to_le32(ctx->rx_max);
=20
 			err =3D usb_control_msg(ctx->udev,
 					usb_sndctrlpipe(ctx->udev, 0),
@@ -260,7 +277,7 @@ size_err:
=20
 	/* verify maximum size of transmitted NTB in bytes */
 	if ((ctx->tx_max <
-	    (CDC_NCM_MIN_HDR_SIZE + CDC_NCM_MIN_DATAGRAM_SIZE)) ||
+	    (min_hdr_size + min_dgram_size)) ||
 	    (ctx->tx_max > CDC_NCM_NTB_MAX_SIZE_TX)) {
 		pr_debug("Using default maximum transmit length=3D%d\n",
 						CDC_NCM_NTB_MAX_SIZE_TX);
@@ -302,8 +319,8 @@ size_err:
 	}
=20
 	/* adjust TX-remainder according to NCM specification. */
-	ctx->tx_remainder =3D ((ctx->tx_remainder - ETH_HLEN) &
-						(ctx->tx_modulus - 1));
+	ctx->tx_remainder =3D ((ctx->tx_remainder - eth_hlen) &
+			     (ctx->tx_modulus - 1));
=20
 	/* additional configuration */
=20
@@ -330,12 +347,18 @@ size_err:
 			pr_debug("Setting NTB format to 16-bit failed\n");
 	}
=20
-	ctx->max_datagram_size =3D CDC_NCM_MIN_DATAGRAM_SIZE;
+	ctx->max_datagram_size =3D min_dgram_size;
=20
 	/* set Max Datagram Size (MTU) */
 	if (flags & USB_CDC_NCM_NCAP_MAX_DATAGRAM_SIZE) {
 		__le16 *max_datagram_size;
-		u16 eth_max_sz =3D le16_to_cpu(ctx->ether_desc->wMaxSegmentSize);
+		u16 eth_max_sz;
+		if (ctx->ether_desc !=3D NULL)
+			eth_max_sz =3D le16_to_cpu(ctx->ether_desc->wMaxSegmentSize);
+		else if (ctx->mbim_desc !=3D NULL)
+			eth_max_sz =3D le16_to_cpu(ctx->mbim_desc->wMaxSegmentSize);
+		else
+			goto max_dgram_err;
=20
 		max_datagram_size =3D kzalloc(sizeof(*max_datagram_size),
 				GFP_KERNEL);
@@ -352,7 +375,7 @@ size_err:
 				2, 1000);
 		if (err < 0) {
 			pr_debug("GET_MAX_DATAGRAM_SIZE failed, use size=3D%u\n",
-						CDC_NCM_MIN_DATAGRAM_SIZE);
+				 min_dgram_size);
 		} else {
 			ctx->max_datagram_size =3D
 				le16_to_cpu(*max_datagram_size);
@@ -361,12 +384,10 @@ size_err:
 					ctx->max_datagram_size =3D eth_max_sz;
=20
 			if (ctx->max_datagram_size > CDC_NCM_MAX_DATAGRAM_SIZE)
-				ctx->max_datagram_size =3D
-						CDC_NCM_MAX_DATAGRAM_SIZE;
+				ctx->max_datagram_size =3D CDC_NCM_MAX_DATAGRAM_SIZE;
=20
-			if (ctx->max_datagram_size < CDC_NCM_MIN_DATAGRAM_SIZE)
-				ctx->max_datagram_size =3D
-					CDC_NCM_MIN_DATAGRAM_SIZE;
+			if (ctx->max_datagram_size < min_dgram_size)
+				ctx->max_datagram_size =3D min_dgram_size;
=20
 			/* if value changed, update device */
 			if (ctx->max_datagram_size !=3D
@@ -387,8 +408,8 @@ size_err:
 	}
=20
 max_dgram_err:
-	if (ctx->netdev->mtu !=3D (ctx->max_datagram_size - ETH_HLEN))
-		ctx->netdev->mtu =3D ctx->max_datagram_size - ETH_HLEN;
+	if (ctx->netdev->mtu !=3D (ctx->max_datagram_size - eth_hlen))
+		ctx->netdev->mtu =3D ctx->max_datagram_size - eth_hlen;
=20
 	return 0;
 }
--=20
1.7.10.4
