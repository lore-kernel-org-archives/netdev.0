From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 08/14] net: cdc_ncm: refactoring for tx multiplexing
Date: Thu, 18 Oct 2012 22:41:01 +0200
Message-ID: <1350592867-25651-9-git-send-email-bjorn@mork.no>
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
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60312 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753134Ab2JRUmZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 16:42:25 -0400
In-Reply-To: <1350592867-25651-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding multiplexed NDP support to cdc_ncm_fill_tx_frame, allowing
transmissions of multiple independent sessions within the same NTB.

Refactoring the code quite a bit to avoid having to store copies
of multiple NDPs being prepared for tx. The old code would still
reserve enough room for a maximum sized NDP in the skb so we might
as well keep them in the skb while they are being prepared.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |  247 +++++++++++++++++++------------------=
--------
 1 file changed, 102 insertions(+), 145 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 07d199a..aeebf7c 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -88,14 +88,11 @@
 	(sizeof(struct usb_cdc_ncm_nth16) + sizeof(struct usb_cdc_ncm_ndp16) =
+ \
 	(CDC_NCM_DPT_DATAGRAMS_MAX + 1) * sizeof(struct usb_cdc_ncm_dpe16))
=20
-struct cdc_ncm_data {
-	struct usb_cdc_ncm_nth16 nth16;
-	struct usb_cdc_ncm_ndp16 ndp16;
-	struct usb_cdc_ncm_dpe16 dpe16[CDC_NCM_DPT_DATAGRAMS_MAX + 1];
-};
+#define CDC_NCM_NDP_SIZE \
+	(sizeof(struct usb_cdc_ncm_ndp16) +				\
+	      (CDC_NCM_DPT_DATAGRAMS_MAX + 1) * sizeof(struct usb_cdc_ncm_dpe=
16))
=20
 struct cdc_ncm_ctx {
-	struct cdc_ncm_data tx_ncm;
 	struct usb_cdc_ncm_ntb_parameters ncm_parm;
 	struct hrtimer tx_timer;
 	struct tasklet_struct bh;
@@ -117,13 +114,12 @@ struct cdc_ncm_ctx {
=20
 	struct sk_buff *tx_curr_skb;
 	struct sk_buff *tx_rem_skb;
+	__le32 tx_rem_sign;
=20
 	spinlock_t mtx;
 	atomic_t stop;
=20
 	u32 tx_timer_pending;
-	u32 tx_curr_offset;
-	u32 tx_curr_last_offset;
 	u32 tx_curr_frame_num;
 	u32 rx_speed;
 	u32 tx_speed;
@@ -682,51 +678,75 @@ static int cdc_ncm_bind(struct usbnet *dev, struc=
t usb_interface *intf)
 	return ret;
 }
=20
-static void cdc_ncm_zero_fill(u8 *ptr, u32 first, u32 end, u32 max)
+static void cdc_ncm_align_tail(struct sk_buff *skb, size_t modulus, si=
ze_t remainder, size_t max)
 {
-	if (first >=3D max)
-		return;
-	if (first >=3D end)
-		return;
-	if (end > max)
-		end =3D max;
-	memset(ptr + first, 0, end - first);
+	size_t align =3D ALIGN(skb->len, modulus) - skb->len + remainder;
+
+	if (skb->len + align > max)
+		align =3D max - skb->len;
+	if (align && skb_tailroom(skb) >=3D align)
+		memset(skb_put(skb, align), 0, align);
+}
+
+/* return a pointer to a valid struct usb_cdc_ncm_ndp16 of type sign, =
possibly
+ * allocating a new one within skb
+ */
+static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct cdc_ncm_ctx *ctx, =
struct sk_buff *skb, __le32 sign, size_t reserve)
+{
+	struct usb_cdc_ncm_ndp16 *ndp16 =3D NULL;
+	struct usb_cdc_ncm_nth16 *nth16 =3D (void *)skb->data;
+	size_t ndpoffset =3D le16_to_cpu(nth16->wNdpIndex);
+
+	/* follow the chain of NDPs, looking for a match */
+	while (ndpoffset) {
+		ndp16 =3D (struct usb_cdc_ncm_ndp16 *)(skb->data + ndpoffset);
+		if  (ndp16->dwSignature =3D=3D sign)
+			return ndp16;
+		ndpoffset =3D le16_to_cpu(ndp16->wNextNdpIndex);
+	}
+
+	/* align new NDP */
+	cdc_ncm_align_tail(skb, ctx->tx_ndp_modulus, 0, ctx->tx_max);
+
+	/* verify that there is room for the NDP and the datagram (reserve) *=
/
+	if ((ctx->tx_max - skb->len - reserve) < CDC_NCM_NDP_SIZE)
+		return NULL;
+
+	/* link to it */
+	if (ndp16)
+		ndp16->wNextNdpIndex =3D cpu_to_le16(skb->len);
+	else
+		nth16->wNdpIndex =3D cpu_to_le16(skb->len);
+
+	/* push a new empty NDP */
+	ndp16 =3D (struct usb_cdc_ncm_ndp16 *)memset(skb_put(skb, CDC_NCM_NDP=
_SIZE), 0, CDC_NCM_NDP_SIZE);
+	ndp16->dwSignature =3D sign;
+	ndp16->wLength =3D cpu_to_le16(sizeof(struct usb_cdc_ncm_ndp16) + siz=
eof(struct usb_cdc_ncm_dpe16));
+	return ndp16;
 }
=20
 static struct sk_buff *
-cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
+cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb, __=
le32 sign)
 {
+	struct usb_cdc_ncm_nth16 *nth16;
+	struct usb_cdc_ncm_ndp16 *ndp16;
 	struct sk_buff *skb_out;
-	u32 rem;
-	u32 offset;
-	u32 last_offset;
-	u16 n =3D 0, index;
+	u16 n =3D 0, index, ndplen;
 	u8 ready2send =3D 0;
=20
 	/* if there is a remaining skb, it gets priority */
-	if (skb !=3D NULL)
+	if (skb !=3D NULL) {
 		swap(skb, ctx->tx_rem_skb);
-	else
+		swap(sign, ctx->tx_rem_sign);
+	} else {
 		ready2send =3D 1;
-
-	/*
-	 * +----------------+
-	 * | skb_out        |
-	 * +----------------+
-	 *           ^ offset
-	 *        ^ last_offset
-	 */
+	}
=20
 	/* check if we are resuming an OUT skb */
-	if (ctx->tx_curr_skb !=3D NULL) {
-		/* pop variables */
-		skb_out =3D ctx->tx_curr_skb;
-		offset =3D ctx->tx_curr_offset;
-		last_offset =3D ctx->tx_curr_last_offset;
-		n =3D ctx->tx_curr_frame_num;
+	skb_out =3D ctx->tx_curr_skb;
=20
-	} else {
-		/* reset variables */
+	/* allocate a new OUT skb */
+	if (!skb_out) {
 		skb_out =3D alloc_skb((ctx->tx_max + 1), GFP_ATOMIC);
 		if (skb_out =3D=3D NULL) {
 			if (skb !=3D NULL) {
@@ -735,35 +755,21 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, st=
ruct sk_buff *skb)
 			}
 			goto exit_no_skb;
 		}
+		/* fill out the initial 16-bit NTB header */
+		nth16 =3D (struct usb_cdc_ncm_nth16 *)memset(skb_put(skb_out, sizeof=
(struct usb_cdc_ncm_nth16)), 0, sizeof(struct usb_cdc_ncm_nth16));
+		nth16->dwSignature =3D cpu_to_le32(USB_CDC_NCM_NTH16_SIGN);
+		nth16->wHeaderLength =3D cpu_to_le16(sizeof(struct usb_cdc_ncm_nth16=
));
+		nth16->wSequence =3D cpu_to_le16(ctx->tx_seq++);
=20
-		/* make room for NTH and NDP */
-		offset =3D ALIGN(sizeof(struct usb_cdc_ncm_nth16),
-					ctx->tx_ndp_modulus) +
-					sizeof(struct usb_cdc_ncm_ndp16) +
-					(ctx->tx_max_datagrams + 1) *
-					sizeof(struct usb_cdc_ncm_dpe16);
-
-		/* store last valid offset before alignment */
-		last_offset =3D offset;
-		/* align first Datagram offset correctly */
-		offset =3D ALIGN(offset, ctx->tx_modulus) + ctx->tx_remainder;
-		/* zero buffer till the first IP datagram */
-		cdc_ncm_zero_fill(skb_out->data, 0, offset, offset);
-		n =3D 0;
+		/* count total number of frames in this NTB */
 		ctx->tx_curr_frame_num =3D 0;
 	}
=20
-	for (; n < ctx->tx_max_datagrams; n++) {
-		/* check if end of transmit buffer is reached */
-		if (offset >=3D ctx->tx_max) {
-			ready2send =3D 1;
-			break;
-		}
-		/* compute maximum buffer size */
-		rem =3D ctx->tx_max - offset;
-
+	for (n =3D ctx->tx_curr_frame_num; n < ctx->tx_max_datagrams; n++) {
+		/* send any remaining skb first */
 		if (skb =3D=3D NULL) {
 			skb =3D ctx->tx_rem_skb;
+			sign =3D ctx->tx_rem_sign;
 			ctx->tx_rem_skb =3D NULL;
=20
 			/* check for end of skb */
@@ -771,7 +777,14 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, str=
uct sk_buff *skb)
 				break;
 		}
=20
-		if (skb->len > rem) {
+		/* get the appropriate NDP for this skb */
+		ndp16 =3D cdc_ncm_ndp(ctx, skb_out, sign, skb->len + ctx->tx_modulus=
 + ctx->tx_remainder);
+
+		/* align beginning of next frame */
+		cdc_ncm_align_tail(skb_out,  ctx->tx_modulus, ctx->tx_remainder, ctx=
->tx_max);
+
+		/* check if we had enough room left for both NDP and frame */
+		if (!ndp16 || skb_out->len + skb->len > ctx->tx_max) {
 			if (n =3D=3D 0) {
 				/* won't fit, MTU problem? */
 				dev_kfree_skb_any(skb);
@@ -784,31 +797,30 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, st=
ruct sk_buff *skb)
 					ctx->netdev->stats.tx_dropped++;
 				}
 				ctx->tx_rem_skb =3D skb;
+				ctx->tx_rem_sign =3D sign;
 				skb =3D NULL;
 				ready2send =3D 1;
 			}
 			break;
 		}
=20
-		memcpy(((u8 *)skb_out->data) + offset, skb->data, skb->len);
-
-		ctx->tx_ncm.dpe16[n].wDatagramLength =3D cpu_to_le16(skb->len);
-		ctx->tx_ncm.dpe16[n].wDatagramIndex =3D cpu_to_le16(offset);
-
-		/* update offset */
-		offset +=3D skb->len;
+		/* calculate frame number withing this NDP */
+		ndplen =3D le16_to_cpu(ndp16->wLength);
+		index =3D (ndplen - sizeof(struct usb_cdc_ncm_ndp16)) / sizeof(struc=
t usb_cdc_ncm_dpe16) - 1;
=20
-		/* store last valid offset before alignment */
-		last_offset =3D offset;
-
-		/* align offset correctly */
-		offset =3D ALIGN(offset, ctx->tx_modulus) + ctx->tx_remainder;
-
-		/* zero padding */
-		cdc_ncm_zero_fill(skb_out->data, last_offset, offset,
-								ctx->tx_max);
+		/* OK, add this skb */
+		ndp16->dpe16[index].wDatagramLength =3D cpu_to_le16(skb->len);
+		ndp16->dpe16[index].wDatagramIndex =3D cpu_to_le16(skb_out->len);
+		ndp16->wLength =3D cpu_to_le16(ndplen + sizeof(struct usb_cdc_ncm_dp=
e16));
+		memcpy(skb_put(skb_out, skb->len), skb->data, skb->len);
 		dev_kfree_skb_any(skb);
 		skb =3D NULL;
+
+		/* send now if this NDP is full */
+		if (index >=3D CDC_NCM_DPT_DATAGRAMS_MAX) {
+			ready2send =3D 1;
+			break;
+		}
 	}
=20
 	/* free up any dangling skb */
@@ -824,16 +836,12 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, st=
ruct sk_buff *skb)
 		/* wait for more frames */
 		/* push variables */
 		ctx->tx_curr_skb =3D skb_out;
-		ctx->tx_curr_offset =3D offset;
-		ctx->tx_curr_last_offset =3D last_offset;
 		goto exit_no_skb;
=20
 	} else if ((n < ctx->tx_max_datagrams) && (ready2send =3D=3D 0)) {
 		/* wait for more frames */
 		/* push variables */
 		ctx->tx_curr_skb =3D skb_out;
-		ctx->tx_curr_offset =3D offset;
-		ctx->tx_curr_last_offset =3D last_offset;
 		/* set the pending count */
 		if (n < CDC_NCM_RESTART_TIMER_DATAGRAM_CNT)
 			ctx->tx_timer_pending =3D CDC_NCM_TIMER_PENDING_CNT;
@@ -844,75 +852,24 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, st=
ruct sk_buff *skb)
 		/* variables will be reset at next call */
 	}
=20
-	/* check for overflow */
-	if (last_offset > ctx->tx_max)
-		last_offset =3D ctx->tx_max;
-
-	/* revert offset */
-	offset =3D last_offset;
-
 	/*
 	 * If collected data size is less or equal CDC_NCM_MIN_TX_PKT bytes,
 	 * we send buffers as it is. If we get more data, it would be more
 	 * efficient for USB HS mobile device with DMA engine to receive a fu=
ll
 	 * size NTB, than canceling DMA transfer and receiving a short packet=
=2E
 	 */
-	if (offset > CDC_NCM_MIN_TX_PKT)
-		offset =3D ctx->tx_max;
-
-	/* final zero padding */
-	cdc_ncm_zero_fill(skb_out->data, last_offset, offset, ctx->tx_max);
-
-	/* store last offset */
-	last_offset =3D offset;
-
-	if (((last_offset < ctx->tx_max) && ((last_offset %
-			le16_to_cpu(ctx->out_ep->desc.wMaxPacketSize)) =3D=3D 0)) ||
-	    (((last_offset =3D=3D ctx->tx_max) && ((ctx->tx_max %
-		le16_to_cpu(ctx->out_ep->desc.wMaxPacketSize)) =3D=3D 0)) &&
-		(ctx->tx_max < le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize)))) {
-		/* force short packet */
-		*(((u8 *)skb_out->data) + last_offset) =3D 0;
-		last_offset++;
-	}
+	if (skb_out->len > CDC_NCM_MIN_TX_PKT)
+		/* final zero padding */
+		memset(skb_put(skb_out, ctx->tx_max - skb_out->len), 0, ctx->tx_max =
- skb_out->len);
=20
-	/* zero the rest of the DPEs plus the last NULL entry */
-	for (; n <=3D CDC_NCM_DPT_DATAGRAMS_MAX; n++) {
-		ctx->tx_ncm.dpe16[n].wDatagramLength =3D 0;
-		ctx->tx_ncm.dpe16[n].wDatagramIndex =3D 0;
-	}
-
-	/* fill out 16-bit NTB header */
-	ctx->tx_ncm.nth16.dwSignature =3D cpu_to_le32(USB_CDC_NCM_NTH16_SIGN)=
;
-	ctx->tx_ncm.nth16.wHeaderLength =3D
-					cpu_to_le16(sizeof(ctx->tx_ncm.nth16));
-	ctx->tx_ncm.nth16.wSequence =3D cpu_to_le16(ctx->tx_seq);
-	ctx->tx_ncm.nth16.wBlockLength =3D cpu_to_le16(last_offset);
-	index =3D ALIGN(sizeof(struct usb_cdc_ncm_nth16), ctx->tx_ndp_modulus=
);
-	ctx->tx_ncm.nth16.wNdpIndex =3D cpu_to_le16(index);
-
-	memcpy(skb_out->data, &(ctx->tx_ncm.nth16), sizeof(ctx->tx_ncm.nth16)=
);
-	ctx->tx_seq++;
-
-	/* fill out 16-bit NDP table */
-	ctx->tx_ncm.ndp16.dwSignature =3D
-				cpu_to_le32(USB_CDC_NCM_NDP16_NOCRC_SIGN);
-	rem =3D sizeof(ctx->tx_ncm.ndp16) + ((ctx->tx_curr_frame_num + 1) *
-					sizeof(struct usb_cdc_ncm_dpe16));
-	ctx->tx_ncm.ndp16.wLength =3D cpu_to_le16(rem);
-	ctx->tx_ncm.ndp16.wNextNdpIndex =3D 0; /* reserved */
-
-	memcpy(((u8 *)skb_out->data) + index,
-						&(ctx->tx_ncm.ndp16),
-						sizeof(ctx->tx_ncm.ndp16));
-
-	memcpy(((u8 *)skb_out->data) + index + sizeof(ctx->tx_ncm.ndp16),
-					&(ctx->tx_ncm.dpe16),
-					(ctx->tx_curr_frame_num + 1) *
-					sizeof(struct usb_cdc_ncm_dpe16));
+	/* do we need to prevent a ZLP? */
+	if (((skb_out->len % le16_to_cpu(ctx->out_ep->desc.wMaxPacketSize)) =3D=
=3D 0) &&
+	    (skb_out->len < le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize)) && sk=
b_tailroom(skb_out))
+		*skb_put(skb_out, 1) =3D 0;	/* force short packet */
=20
-	/* set frame length */
-	skb_put(skb_out, last_offset);
+	/* set final frame length */
+	nth16 =3D (struct usb_cdc_ncm_nth16 *)skb_out->data;
+	nth16->wBlockLength =3D cpu_to_le16(skb_out->len);
=20
 	/* return skb */
 	ctx->tx_curr_skb =3D NULL;
@@ -979,7 +936,7 @@ cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff=
 *skb, gfp_t flags)
 		goto error;
=20
 	spin_lock_bh(&ctx->mtx);
-	skb_out =3D cdc_ncm_fill_tx_frame(ctx, skb);
+	skb_out =3D cdc_ncm_fill_tx_frame(ctx, skb, cpu_to_le32(USB_CDC_NCM_N=
DP16_NOCRC_SIGN));
 	spin_unlock_bh(&ctx->mtx);
 	return skb_out;
=20
--=20
1.7.10.4
