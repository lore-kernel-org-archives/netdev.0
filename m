From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH v4 02/10] net/macb: memory barriers cleanup
Date: Wed, 31 Oct 2012 17:04:51 +0100
Message-ID: <e6ea9b93cd6525dd388175dd3ee88ee1f23300c0.1351690694.git.nicolas.ferre@atmel.com>
References: <cover.1351690694.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bhutchings@solarflare.com>,
	<linux-arm-kernel@lists.infradead.org>, <plagnioj@jcrosoft.com>,
	<patrice.vilchez@atmel.com>, <linux-kernel@vger.kernel.org>,
	<manabian@gmail.com>, <David.Laight@ACULAB.COM>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<havard@skinnemoen.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1351690694.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Havard Skinnemoen <havard@skinnemoen.net>

Remove a couple of unneeded barriers and document the remaining ones.

Signed-off-by: Havard Skinnemoen <havard@skinnemoen.net>
[nicolas.ferre@atmel.com: split patch in topics]
Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Tested-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 0931cb7..e7f554d 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -373,7 +373,9 @@ static void macb_tx(struct macb *bp)
 
 		BUG_ON(skb == NULL);
 
+		/* Make hw descriptor updates visible to CPU */
 		rmb();
+
 		bufstat = bp->tx_ring[tail].ctrl;
 
 		if (!(bufstat & MACB_BIT(TX_USED)))
@@ -416,7 +418,10 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 			if (frag == last_frag)
 				break;
 		}
+
+		/* Make descriptor updates visible to hardware */
 		wmb();
+
 		return 1;
 	}
 
@@ -437,12 +442,14 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 					       frag_len);
 		offset += RX_BUFFER_SIZE;
 		bp->rx_ring[frag].addr &= ~MACB_BIT(RX_USED);
-		wmb();
 
 		if (frag == last_frag)
 			break;
 	}
 
+	/* Make descriptor updates visible to hardware */
+	wmb();
+
 	skb->protocol = eth_type_trans(skb, bp->dev);
 
 	bp->stats.rx_packets++;
@@ -462,6 +469,8 @@ static void discard_partial_frame(struct macb *bp, unsigned int begin,
 
 	for (frag = begin; frag != end; frag = NEXT_RX(frag))
 		bp->rx_ring[frag].addr &= ~MACB_BIT(RX_USED);
+
+	/* Make descriptor updates visible to hardware */
 	wmb();
 
 	/*
@@ -480,7 +489,9 @@ static int macb_rx(struct macb *bp, int budget)
 	for (; budget > 0; tail = NEXT_RX(tail)) {
 		u32 addr, ctrl;
 
+		/* Make hw descriptor updates visible to CPU */
 		rmb();
+
 		addr = bp->rx_ring[tail].addr;
 		ctrl = bp->rx_ring[tail].ctrl;
 
@@ -675,6 +686,8 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	bp->tx_ring[entry].addr = mapping;
 	bp->tx_ring[entry].ctrl = ctrl;
+
+	/* Make newly initialized descriptor visible to hardware */
 	wmb();
 
 	entry = NEXT_TX(entry);
@@ -783,9 +796,6 @@ static void macb_init_rings(struct macb *bp)
 
 static void macb_reset_hw(struct macb *bp)
 {
-	/* Make sure we have the write buffer for ourselves */
-	wmb();
-
 	/*
 	 * Disable RX and TX (XXX: Should we halt the transmission
 	 * more gracefully?)
-- 
1.8.0
