From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH 2/2] net: mv643xx_eth: use dma_wmb/rmb where appropriate
Date: Fri, 13 May 2016 19:59:20 +0800
Message-ID: <1463140760-7128-3-git-send-email-jszhang@marvell.com>
References: <1463140760-7128-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Jisheng Zhang <jszhang@marvell.com>
To: <sebastian.hesselbarth@gmail.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463140760-7128-1-git-send-email-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the mv643xx_eth driver to use the dma_rmb/wmb calls instead of
the full barriers in order to improve performance.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index c6d8124..13b71e3 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -536,7 +536,7 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 		cmd_sts = rx_desc->cmd_sts;
 		if (cmd_sts & BUFFER_OWNED_BY_DMA)
 			break;
-		rmb();
+		dma_rmb();
 
 		skb = rxq->rx_skb[rxq->rx_curr_desc];
 		rxq->rx_skb[rxq->rx_curr_desc] = NULL;
@@ -647,9 +647,9 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 						  DMA_FROM_DEVICE);
 		rx_desc->buf_size = size;
 		rxq->rx_skb[rx] = skb;
-		wmb();
+		dma_wmb();
 		rx_desc->cmd_sts = BUFFER_OWNED_BY_DMA | RX_ENABLE_INTERRUPT;
-		wmb();
+		dma_wmb();
 
 		/*
 		 * The hardware automatically prepends 2 bytes of
@@ -889,7 +889,7 @@ static int txq_submit_tso(struct tx_queue *txq, struct sk_buff *skb,
 	skb_tx_timestamp(skb);
 
 	/* ensure all other descriptors are written before first cmd_sts */
-	wmb();
+	dma_wmb();
 	first_tx_desc->cmd_sts = first_cmd_sts;
 
 	/* clear TX_END status */
@@ -994,7 +994,7 @@ static int txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb,
 	skb_tx_timestamp(skb);
 
 	/* ensure all other descriptors are written before first cmd_sts */
-	wmb();
+	dma_wmb();
 	desc->cmd_sts = cmd_sts;
 
 	/* clear TX_END status */
-- 
2.8.1
