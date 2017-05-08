From: Jim Baxter <jim_baxter@mentor.com>
Subject: [PATCH V2 1/1] net: cdc_ncm: Fix TX zero padding
Date: Mon, 8 May 2017 13:49:57 +0100
Message-ID: <1494247797-1732-2-git-send-email-jim_baxter@mentor.com>
References: <1494247797-1732-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <jim_baxter@mentor.com>
To: <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Oliver Neukum <oliver@neukum.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494247797-1732-1-git-send-email-jim_baxter@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The zero padding that is added to NTB's does
not zero the memory correctly.
This is because the skb_put modifies the value
of skb_out->len which results in the memset
command not setting any memory to zero as
(ctx->tx_max - skb_out->len) == 0.

I have resolved this by storing the size of
the memory to be zeroed before the skb_put
and using this in the memset call.

Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
Reviewed-by: Bjørn Mork <bjorn@mork.no>
---

V1: Sent to linux-use for review.
V2: Added netdev mailing list as it was missed for V1.

 drivers/net/usb/cdc_ncm.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index f317984..e2a48d7 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1087,6 +1087,7 @@ struct sk_buff *
 	u16 n = 0, index, ndplen;
 	u8 ready2send = 0;
 	u32 delayed_ndp_size;
+	size_t padding_count;
 
 	/* When our NDP gets written in cdc_ncm_ndp(), then skb_out->len gets updated
 	 * accordingly. Otherwise, we should check here.
@@ -1243,11 +1244,13 @@ struct sk_buff *
 	 * a ZLP after full sized NTBs.
 	 */
 	if (!(dev->driver_info->flags & FLAG_SEND_ZLP) &&
-	    skb_out->len > ctx->min_tx_pkt)
-		memset(skb_put(skb_out, ctx->tx_max - skb_out->len), 0,
-		       ctx->tx_max - skb_out->len);
-	else if (skb_out->len < ctx->tx_max && (skb_out->len % dev->maxpacket) == 0)
+	    skb_out->len > ctx->min_tx_pkt) {
+		padding_count = ctx->tx_max - skb_out->len;
+		memset(skb_put(skb_out, padding_count), 0, padding_count);
+	} else if (skb_out->len < ctx->tx_max &&
+		   (skb_out->len % dev->maxpacket) == 0) {
 		*skb_put(skb_out, 1) = 0;	/* force short packet */
+	}
 
 	/* set final frame length */
 	nth16 = (struct usb_cdc_ncm_nth16 *)skb_out->data;
-- 
1.9.1
