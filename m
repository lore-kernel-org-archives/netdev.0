From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH net] net: stmmac: free an skb first when there are no longer any descriptors using it
Date: Tue, 20 Jun 2017 14:32:41 +0200
Message-ID: <20170620123241.5677-1-niklas.cassel@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Niklas Cassel <niklass@axis.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When having the skb pointer in the first descriptor, stmmac_tx_clean
can get called at a moment where the IP has only cleared the own bit
of the first descriptor, thus freeing the skb, even though there can
be several descriptors whose buffers point into the same skb.

By simply moving the skb pointer from the first descriptor to the last
descriptor, a skb will get freed only when the IP has cleared the
own bit of all the descriptors that are using that skb.

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6a1cb59728fe..3c73227ba04c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2830,7 +2830,6 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	tx_q->tx_skbuff_dma[first_entry].buf = des;
 	tx_q->tx_skbuff_dma[first_entry].len = skb_headlen(skb);
-	tx_q->tx_skbuff[first_entry] = skb;
 
 	first->des0 = cpu_to_le32(des);
 
@@ -2864,6 +2863,14 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	tx_q->tx_skbuff_dma[tx_q->cur_tx].last_segment = true;
 
+	/* Only the last descriptor gets to point to the skb. */
+	tx_q->tx_skbuff[tx_q->cur_tx] = skb;
+
+	/* We've used all descriptors we need for this skb, however,
+	 * advance cur_tx so that it references a fresh descriptor.
+	 * ndo_start_xmit will fill this descriptor the next time it's
+	 * called and stmmac_tx_clean may clean up to this descriptor.
+	 */
 	tx_q->cur_tx = STMMAC_GET_ENTRY(tx_q->cur_tx, DMA_TX_SIZE);
 
 	if (unlikely(stmmac_tx_avail(priv, queue) <= (MAX_SKB_FRAGS + 1))) {
@@ -2996,8 +3003,6 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	first = desc;
 
-	tx_q->tx_skbuff[first_entry] = skb;
-
 	enh_desc = priv->plat->enh_desc;
 	/* To program the descriptors according to the size of the frame */
 	if (enh_desc)
@@ -3045,8 +3050,15 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 						skb->len);
 	}
 
-	entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
+	/* Only the last descriptor gets to point to the skb. */
+	tx_q->tx_skbuff[entry] = skb;
 
+	/* We've used all descriptors we need for this skb, however,
+	 * advance cur_tx so that it references a fresh descriptor.
+	 * ndo_start_xmit will fill this descriptor the next time it's
+	 * called and stmmac_tx_clean may clean up to this descriptor.
+	 */
+	entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
 	tx_q->cur_tx = entry;
 
 	if (netif_msg_pktdata(priv)) {
-- 
2.11.0
