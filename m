From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH 2/2] net: pxa168_eth: Use dma_wmb/rmb where appropriate
Date: Fri, 13 May 2016 19:57:30 +0800
Message-ID: <1463140650-7038-3-git-send-email-jszhang@marvell.com>
References: <1463140650-7038-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jisheng Zhang <jszhang@marvell.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1463140650-7038-1-git-send-email-jszhang@marvell.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Update the pxa168_eth driver to use the dma_rmb/wmb calls instead of the
full barriers in order to improve performance: reduced 97ns/39ns on
average in tx/rx path on Marvell BG4CT platform.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index db774e3..728a115 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -342,9 +342,9 @@ static void rxq_refill(struct net_device *dev)
 		pep->rx_skb[used_rx_desc] = skb;
 
 		/* Return the descriptor to DMA ownership */
-		wmb();
+		dma_wmb();
 		p_used_rx_desc->cmd_sts = BUF_OWNED_BY_DMA | RX_EN_INT;
-		wmb();
+		dma_wmb();
 
 		/* Move the used descriptor pointer to the next descriptor */
 		pep->rx_used_desc_q = (used_rx_desc + 1) % pep->rx_ring_size;
@@ -794,7 +794,7 @@ static int rxq_process(struct net_device *dev, int budget)
 		rx_used_desc = pep->rx_used_desc_q;
 		rx_desc = &pep->p_rx_desc_area[rx_curr_desc];
 		cmd_sts = rx_desc->cmd_sts;
-		rmb();
+		dma_rmb();
 		if (cmd_sts & (BUF_OWNED_BY_DMA))
 			break;
 		skb = pep->rx_skb[rx_curr_desc];
@@ -1289,7 +1289,7 @@ static int pxa168_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	skb_tx_timestamp(skb);
 
-	wmb();
+	dma_wmb();
 	desc->cmd_sts = BUF_OWNED_BY_DMA | TX_GEN_CRC | TX_FIRST_DESC |
 			TX_ZERO_PADDING | TX_LAST_DESC | TX_EN_INT;
 	wmb();
-- 
2.8.1
