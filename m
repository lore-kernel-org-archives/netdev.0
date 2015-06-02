From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH RFC 2/2] cdc_ncm: split the cdc_ncm_ndp funciton
Date: Tue,  2 Jun 2015 11:08:35 +0200
Message-ID: <1433236115-5594-3-git-send-email-mrkiko.rs@gmail.com>
References: <1433236115-5594-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1433236115-5594-1-git-send-email-mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Split this function in two new ones:
- cdc_ncm_ndp16_find: finds an NDP block in the chain mathcing a supplied
  signature; a pointer to it is returned in case of success;
- cdc_ncm_ndp16_push: create and add to skb a new NDP block;

cdc_ncm_ndp16_push refers to the last NDP visited by cdc_ncm_ndp16_find, hence
this code is stateful.

Signed-Off-By: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c | 30 +++++++++++++++++++++---------
 1 file changed, 21 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 8067b8f..3c837d6 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -980,7 +980,7 @@ static void cdc_ncm_align_tail(struct sk_buff *skb, size_t modulus, size_t remai
 /* return a pointer to a valid struct usb_cdc_ncm_ndp16 of type sign, possibly
  * allocating a new one within skb
  */
-static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct cdc_ncm_ctx *ctx, struct sk_buff *skb, __le32 sign, size_t reserve)
+static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp16_find(struct cdc_ncm_ctx *ctx, struct sk_buff *skb, __le32 sign)
 {
 	struct usb_cdc_ncm_ndp16 *ndp16 = NULL;
 	struct usb_cdc_ncm_nth16 *nth16 = (void *)skb->data;
@@ -988,12 +988,20 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct cdc_ncm_ctx *ctx, struct sk_
 
 	/* follow the chain of NDPs, looking for a match */
 	while (ndpoffset) {
-		ndp16 = (struct usb_cdc_ncm_ndp16 *)(skb->data + ndpoffset);
-		if  (ndp16->dwSignature == sign)
-			return ndp16;
+		ctx->tx_curr_ndp16 = (struct usb_cdc_ncm_ndp16 *)(skb->data + ndpoffset);
+		if (ctx->tx_curr_ndp16->dwSignature == sign)
+			ndp16 = ctx->tx_curr_ndp16;
 		ndpoffset = le16_to_cpu(ndp16->wNextNdpIndex);
 	}
+  
+  return ndp16;
+}
 
+static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp16_push(struct cdc_ncm_ctx *ctx, struct sk_buff *skb, __le32 sign, size_t reserve)
+{
+	struct usb_cdc_ncm_ndp16 *ndp16 = ctx->tx_curr_ndp16;
+	struct usb_cdc_ncm_nth16 *nth16 = (void *)skb->data;
+  
 	/* align new NDP */
 	cdc_ncm_align_tail(skb, ctx->tx_ndp_modulus, 0, ctx->tx_max);
 
@@ -1070,11 +1078,15 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 				break;
 		}
 
-		/* get the appropriate NDP for this skb */
-		ndp16 = cdc_ncm_ndp(ctx, skb_out, sign, skb->len + ctx->tx_modulus + ctx->tx_remainder);
