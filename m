From: Alexey Orishko <alexey.orishko@gmail.com>
Subject: [PATCH net-next 3/4] cdc_ncm: avoid discarding datagrams in rx path
Date: Wed, 14 Mar 2012 22:26:12 +0100
Message-ID: <1331760373-1914-3-git-send-email-alexey.orishko@stericsson.com>
References: <1331760373-1914-1-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, gregkh@linuxfoundation.org,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net, oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:56690 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932388Ab2CNV0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 17:26:41 -0400
In-Reply-To: <1331760373-1914-1-git-send-email-alexey.orishko@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes:
- removed a limit for amount of datagrams for IN NTB
- using pointer to traverse NTB in rx_fixup()
- renamed "temp" to "len" in rx_fixup()
- do NTB sequence number check in rx path
Tested on Intel/ARM.

Reviewed-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
Tested-by: Dmitry Tarnyagin <Dmitry.Tarnyagin@stericsson.com>
Signed-off-by: Alexey Orishko <alexey.orishko@stericsson.com>
---
 drivers/net/usb/cdc_ncm.c |  102 +++++++++++++++++++++----------------=
--------
 1 files changed, 47 insertions(+), 55 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index f8f1946..7adc9f6 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -71,13 +71,10 @@
=20
 /*
  * Maximum amount of datagrams in NCM Datagram Pointer Table, not coun=
ting
- * the last NULL entry. Any additional datagrams in NTB would be disca=
rded.
+ * the last NULL entry.
  */
 #define	CDC_NCM_DPT_DATAGRAMS_MAX		40
=20
-/* Maximum amount of IN datagrams in NTB */
-#define	CDC_NCM_DPT_DATAGRAMS_IN_MAX		0 /* unlimited */
-
 /* Restart the timer, if amount of datagrams is less than given value =
*/
 #define	CDC_NCM_RESTART_TIMER_DATAGRAM_CNT	3
 #define	CDC_NCM_TIMER_PENDING_CNT		2
@@ -95,7 +92,6 @@ struct cdc_ncm_data {
 };
=20
 struct cdc_ncm_ctx {
-	struct cdc_ncm_data rx_ncm;
 	struct cdc_ncm_data tx_ncm;
 	struct usb_cdc_ncm_ntb_parameters ncm_parm;
 	struct hrtimer tx_timer;
@@ -135,6 +131,7 @@ struct cdc_ncm_ctx {
 	u16 tx_modulus;
 	u16 tx_ndp_modulus;
 	u16 tx_seq;
+	u16 rx_seq;
 	u16 connected;
 };
=20
@@ -956,108 +953,103 @@ error:
 static int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in=
)
 {
 	struct sk_buff *skb;
-	struct cdc_ncm_ctx *ctx;
-	int sumlen;
-	int actlen;
-	int temp;
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	int len;
 	int nframes;
 	int x;
 	int offset;
+	struct usb_cdc_ncm_nth16 *nth16;
+	struct usb_cdc_ncm_ndp16 *ndp16;
+	struct usb_cdc_ncm_dpe16 *dpe16;
=20
-	ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
 	if (ctx =3D=3D NULL)
 		goto error;
=20
-	actlen =3D skb_in->len;
-	sumlen =3D CDC_NCM_NTB_MAX_SIZE_RX;
-
-	if (actlen < (sizeof(ctx->rx_ncm.nth16) + sizeof(ctx->rx_ncm.ndp16)))=
 {
+	if (skb_in->len < (sizeof(struct usb_cdc_ncm_nth16) +
+					sizeof(struct usb_cdc_ncm_ndp16))) {
 		pr_debug("frame too short\n");
 		goto error;
 	}
=20
-	memcpy(&(ctx->rx_ncm.nth16), ((u8 *)skb_in->data),
-						sizeof(ctx->rx_ncm.nth16));
+	nth16 =3D (struct usb_cdc_ncm_nth16 *)skb_in->data;
=20
-	if (le32_to_cpu(ctx->rx_ncm.nth16.dwSignature) !=3D
-	    USB_CDC_NCM_NTH16_SIGN) {
+	if (le32_to_cpu(nth16->dwSignature) !=3D USB_CDC_NCM_NTH16_SIGN) {
 		pr_debug("invalid NTH16 signature <%u>\n",
-			 le32_to_cpu(ctx->rx_ncm.nth16.dwSignature));
+					le32_to_cpu(nth16->dwSignature));
 		goto error;
 	}
=20
-	temp =3D le16_to_cpu(ctx->rx_ncm.nth16.wBlockLength);
-	if (temp > sumlen) {
-		pr_debug("unsupported NTB block length %u/%u\n", temp, sumlen);
+	len =3D le16_to_cpu(nth16->wBlockLength);
+	if (len > ctx->rx_max) {
+		pr_debug("unsupported NTB block length %u/%u\n", len,
+								ctx->rx_max);
 		goto error;
 	}
=20
-	temp =3D le16_to_cpu(ctx->rx_ncm.nth16.wNdpIndex);
-	if ((temp + sizeof(ctx->rx_ncm.ndp16)) > actlen) {
-		pr_debug("invalid DPT16 index\n");
+	if ((ctx->rx_seq + 1) !=3D le16_to_cpu(nth16->wSequence) &&
+		(ctx->rx_seq || le16_to_cpu(nth16->wSequence)) &&
+		!((ctx->rx_seq =3D=3D 0xffff) && !le16_to_cpu(nth16->wSequence))) {
+		pr_debug("sequence number glitch prev=3D%d curr=3D%d\n",
+				ctx->rx_seq, le16_to_cpu(nth16->wSequence));
+	}
+	ctx->rx_seq =3D le16_to_cpu(nth16->wSequence);
+
+	len =3D le16_to_cpu(nth16->wNdpIndex);
+	if ((len + sizeof(struct usb_cdc_ncm_ndp16)) > skb_in->len) {
+		pr_debug("invalid DPT16 index <%u>\n",
+					le16_to_cpu(nth16->wNdpIndex));
 		goto error;
 	}
=20
-	memcpy(&(ctx->rx_ncm.ndp16), ((u8 *)skb_in->data) + temp,
-						sizeof(ctx->rx_ncm.ndp16));
+	ndp16 =3D (struct usb_cdc_ncm_ndp16 *)(((u8 *)skb_in->data) + len);
=20
-	if (le32_to_cpu(ctx->rx_ncm.ndp16.dwSignature) !=3D
-	    USB_CDC_NCM_NDP16_NOCRC_SIGN) {
+	if (le32_to_cpu(ndp16->dwSignature) !=3D USB_CDC_NCM_NDP16_NOCRC_SIGN=
) {
 		pr_debug("invalid DPT16 signature <%u>\n",
-			 le32_to_cpu(ctx->rx_ncm.ndp16.dwSignature));
+					le32_to_cpu(ndp16->dwSignature));
 		goto error;
 	}
=20
-	if (le16_to_cpu(ctx->rx_ncm.ndp16.wLength) <
-	    USB_CDC_NCM_NDP16_LENGTH_MIN) {
+	if (le16_to_cpu(ndp16->wLength) < USB_CDC_NCM_NDP16_LENGTH_MIN) {
 		pr_debug("invalid DPT16 length <%u>\n",
-			 le32_to_cpu(ctx->rx_ncm.ndp16.dwSignature));
+					le32_to_cpu(ndp16->dwSignature));
 		goto error;
 	}
=20
-	nframes =3D ((le16_to_cpu(ctx->rx_ncm.ndp16.wLength) -
+	nframes =3D ((le16_to_cpu(ndp16->wLength) -
 					sizeof(struct usb_cdc_ncm_ndp16)) /
 					sizeof(struct usb_cdc_ncm_dpe16));
 	nframes--; /* we process NDP entries except for the last one */
=20
-	pr_debug("nframes =3D %u\n", nframes);
+	len +=3D sizeof(struct usb_cdc_ncm_ndp16);
=20
-	temp +=3D sizeof(ctx->rx_ncm.ndp16);
-
-	if ((temp + nframes * (sizeof(struct usb_cdc_ncm_dpe16))) > actlen) {
+	if ((len + nframes * (sizeof(struct usb_cdc_ncm_dpe16))) >
+								skb_in->len) {
 		pr_debug("Invalid nframes =3D %d\n", nframes);
 		goto error;
 	}
=20
-	if (nframes > CDC_NCM_DPT_DATAGRAMS_MAX) {
-		pr_debug("Truncating number of frames from %u to %u\n",
-					nframes, CDC_NCM_DPT_DATAGRAMS_MAX);
-		nframes =3D CDC_NCM_DPT_DATAGRAMS_MAX;
-	}
-
-	memcpy(&(ctx->rx_ncm.dpe16), ((u8 *)skb_in->data) + temp,
-				nframes * (sizeof(struct usb_cdc_ncm_dpe16)));
+	dpe16 =3D (struct usb_cdc_ncm_dpe16 *)(((u8 *)skb_in->data) + len);
=20
-	for (x =3D 0; x < nframes; x++) {
-		offset =3D le16_to_cpu(ctx->rx_ncm.dpe16[x].wDatagramIndex);
-		temp =3D le16_to_cpu(ctx->rx_ncm.dpe16[x].wDatagramLength);
+	for (x =3D 0; x < nframes; x++, dpe16++) {
+		offset =3D le16_to_cpu(dpe16->wDatagramIndex);
+		len =3D le16_to_cpu(dpe16->wDatagramLength);
=20
 		/*
 		 * CDC NCM ch. 3.7
 		 * All entries after first NULL entry are to be ignored
 		 */
-		if ((offset =3D=3D 0) || (temp =3D=3D 0)) {
+		if ((offset =3D=3D 0) || (len =3D=3D 0)) {
 			if (!x)
 				goto error; /* empty NTB */
 			break;
 		}
=20
 		/* sanity checking */
-		if (((offset + temp) > actlen) ||
-		    (temp > CDC_NCM_MAX_DATAGRAM_SIZE) || (temp < ETH_HLEN)) {
+		if (((offset + len) > skb_in->len) ||
+				(len > ctx->rx_max) || (len < ETH_HLEN)) {
 			pr_debug("invalid frame detected (ignored)"
 					"offset[%u]=3D%u, length=3D%u, skb=3D%p\n",
-					x, offset, temp, skb_in);
+					x, offset, len, skb_in);
 			if (!x)
 				goto error;
 			break;
@@ -1066,9 +1058,9 @@ static int cdc_ncm_rx_fixup(struct usbnet *dev, s=
truct sk_buff *skb_in)
 			skb =3D skb_clone(skb_in, GFP_ATOMIC);
 			if (!skb)
 				goto error;
-			skb->len =3D temp;
+			skb->len =3D len;
 			skb->data =3D ((u8 *)skb_in->data) + offset;
-			skb_set_tail_pointer(skb, temp);
+			skb_set_tail_pointer(skb, len);
 			usbnet_skb_return(dev, skb);
 		}
 	}
--=20
1.7.4.1
