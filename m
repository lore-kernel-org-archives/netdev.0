From: Colin King <colin.king@canonical.com>
Subject: [PATCH] via-velocity: remove null pointer check on array tdinfo->skb_dma
Date: Thu,  8 Sep 2016 10:04:24 +0100
Message-ID: <20160908090424.16545-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

tdinfo->skb_dma is a 7 element array of dma_addr_t hence cannot be
null, so the pull pointer check on tdinfo->skb_dma  is redundant.
Remove it.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/via/via-velocity.c | 21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index f38696c..b1167a9 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -1724,24 +1724,21 @@ static void velocity_free_tx_buf(struct velocity_info *vptr,
 		struct velocity_td_info *tdinfo, struct tx_desc *td)
 {
 	struct sk_buff *skb = tdinfo->skb;
+	int i;
 
 	/*
 	 *	Don't unmap the pre-allocated tx_bufs
 	 */
-	if (tdinfo->skb_dma) {
-		int i;
+	for (i = 0; i < tdinfo->nskb_dma; i++) {
+		size_t pktlen = max_t(size_t, skb->len, ETH_ZLEN);
 
-		for (i = 0; i < tdinfo->nskb_dma; i++) {
-			size_t pktlen = max_t(size_t, skb->len, ETH_ZLEN);
+		/* For scatter-gather */
+		if (skb_shinfo(skb)->nr_frags > 0)
+			pktlen = max_t(size_t, pktlen,
+				       td->td_buf[i].size & ~TD_QUEUE);
 
-			/* For scatter-gather */
-			if (skb_shinfo(skb)->nr_frags > 0)
-				pktlen = max_t(size_t, pktlen,
-						td->td_buf[i].size & ~TD_QUEUE);
-
-			dma_unmap_single(vptr->dev, tdinfo->skb_dma[i],
-					le16_to_cpu(pktlen), DMA_TO_DEVICE);
-		}
+		dma_unmap_single(vptr->dev, tdinfo->skb_dma[i],
+				 le16_to_cpu(pktlen), DMA_TO_DEVICE);
 	}
 	dev_kfree_skb_irq(skb);
 	tdinfo->skb = NULL;
-- 
2.9.3
