From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [RFC 6/9] net: cdc_ncm: use true max dgram count for header estimates
Date: Fri,  2 May 2014 23:11:53 +0200
Message-ID: <1399065116-19946-7-git-send-email-bjorn@mork.no>
References: <1399065116-19946-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:55173 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752336AbaEBVMP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2014 17:12:15 -0400
In-Reply-To: <1399065116-19946-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many newer NCM and MBIM devices will request a maximum tx
datagram count which is much smaller than our hardcoded
absolute max. We can reduce the overhead without sacrificing
any of the simplicity for these devices, by simply using the
true negotiated count in when calculated the maximum NTH and
NDP header sizes.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c   |  9 ++++++---
 include/linux/usb/cdc_ncm.h | 10 +---------
 2 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index b20c82c19e02..faa494c0377e 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -162,7 +162,7 @@ static void cdc_ncm_update_rxtx_max(struct usbnet *=
dev, u32 new_rx, u32 new_tx)
 	}
=20
 	/* clamp new_tx to sane values */
-	min =3D CDC_NCM_MIN_HDR_SIZE + ctx->max_datagram_size;
+	min =3D ctx->max_datagram_size + ctx->max_ndp_size + sizeof(struct us=
b_cdc_ncm_nth16);
 	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_TX, le32_to_cpu(ctx->ncm_parm=
=2EdwNtbOutMaxSize));
=20
 	/* some devices set dwNtbOutMaxSize too low for the above default */
@@ -306,6 +306,9 @@ static int cdc_ncm_init(struct usbnet *dev)
 			(ctx->tx_max_datagrams > CDC_NCM_DPT_DATAGRAMS_MAX))
 		ctx->tx_max_datagrams =3D CDC_NCM_DPT_DATAGRAMS_MAX;
=20
+	/* set up maximum NDP size */
+	ctx->max_ndp_size =3D sizeof(struct usb_cdc_ncm_ndp16) + (ctx->tx_max=
_datagrams + 1) * sizeof(struct usb_cdc_ncm_dpe16);
+
 	/* initial coalescing timer interval */
 	ctx->timer_interval =3D CDC_NCM_TIMER_INTERVAL_USEC * NSEC_PER_USEC;
=20
@@ -789,7 +792,7 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct=
 cdc_ncm_ctx *ctx, struct sk_
 	cdc_ncm_align_tail(skb, ctx->tx_ndp_modulus, 0, ctx->tx_max);
=20
 	/* verify that there is room for the NDP and the datagram (reserve) *=
/
-	if ((ctx->tx_max - skb->len - reserve) < CDC_NCM_NDP_SIZE)
+	if ((ctx->tx_max - skb->len - reserve) < ctx->max_ndp_size)
 		return NULL;
=20
 	/* link to it */
@@ -799,7 +802,7 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct=
 cdc_ncm_ctx *ctx, struct sk_
 		nth16->wNdpIndex =3D cpu_to_le16(skb->len);
=20
 	/* push a new empty NDP */
-	ndp16 =3D (struct usb_cdc_ncm_ndp16 *)memset(skb_put(skb, CDC_NCM_NDP=
_SIZE), 0, CDC_NCM_NDP_SIZE);
+	ndp16 =3D (struct usb_cdc_ncm_ndp16 *)memset(skb_put(skb, ctx->max_nd=
p_size), 0, ctx->max_ndp_size);
 	ndp16->dwSignature =3D sign;
 	ndp16->wLength =3D cpu_to_le16(sizeof(struct usb_cdc_ncm_ndp16) + siz=
eof(struct usb_cdc_ncm_dpe16));
 	return ndp16;
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 07ad8c3284a6..bbc4ce9ffef5 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -76,15 +76,6 @@
 #define CDC_NCM_TIMER_INTERVAL_MIN		5UL
 #define CDC_NCM_TIMER_INTERVAL_MAX		(15UL * USEC_PER_SEC)
=20
-/* The following macro defines the minimum header space */
-#define	CDC_NCM_MIN_HDR_SIZE \
-	(sizeof(struct usb_cdc_ncm_nth16) + sizeof(struct usb_cdc_ncm_ndp16) =
+ \
-	(CDC_NCM_DPT_DATAGRAMS_MAX + 1) * sizeof(struct usb_cdc_ncm_dpe16))
-
-#define CDC_NCM_NDP_SIZE \
-	(sizeof(struct usb_cdc_ncm_ndp16) +				\
-	      (CDC_NCM_DPT_DATAGRAMS_MAX + 1) * sizeof(struct usb_cdc_ncm_dpe=
16))
-
 #define cdc_ncm_comm_intf_is_mbim(x)  ((x)->desc.bInterfaceSubClass =3D=
=3D USB_CDC_SUBCLASS_MBIM && \
 				       (x)->desc.bInterfaceProtocol =3D=3D USB_CDC_PROTO_NONE)
 #define cdc_ncm_data_intf_is_mbim(x)  ((x)->desc.bInterfaceProtocol =3D=
=3D USB_CDC_MBIM_PROTO_NTB)
@@ -110,6 +101,7 @@ struct cdc_ncm_ctx {
 	atomic_t stop;
=20
 	u64 timer_interval;
+	u32 max_ndp_size;
=20
 	u32 tx_timer_pending;
 	u32 tx_curr_frame_num;
--=20
2.0.0.rc0
