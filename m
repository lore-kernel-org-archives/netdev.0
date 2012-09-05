From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH 02/10] net/macb: memory barriers cleanup
Date: Wed, 5 Sep 2012 10:19:09 +0200
Message-ID: <8f4d7383d051ed4e3617944141c7746505e35638.1346775479.git.nicolas.ferre@atmel.com>
References: <cover.1346775479.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patrice.vilchez@atmel.com, nicolas.ferre@atmel.com,
 linux-kernel@vger.kernel.org, havard@skinnemoen.net, jamie@jamieiles.com,
 plagnioj@jcrosoft.com, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <cover.1346775479.git.nicolas.ferre@atmel.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Havard Skinnemoen <havard@skinnemoen.net>

Remove a couple of unneeded barriers and document the remaining ones.

Signed-off-by: Havard Skinnemoen <havard@skinnemoen.net>
[nicolas.ferre@atmel.com: split patch in topics]
Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c |   18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 9a10f69..26ca01e 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -372,7 +372,9 @@ static void macb_tx(struct macb *bp)
 
 		BUG_ON(skb == NULL);
 
+		/* Make hw descriptor updates visible to CPU */
 		rmb();
+
 		bufstat = bp->tx_ring[tail].ctrl;
 
 		if (!(bufstat & MACB_BIT(TX_USED)))
@@ -415,7 +417,10 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 			if (frag == last_frag)
 				break;
 		}
+
+		/* Make descriptor updates visible to hardware */
 		wmb();
+
 		return 1;
 	}
 
@@ -436,12 +441,14 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
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
@@ -461,6 +468,8 @@ static void discard_partial_frame(struct macb *bp, unsigned int begin,
 
 	for (frag = begin; frag != end; frag = NEXT_RX(frag))
 		bp->rx_ring[frag].addr &= ~MACB_BIT(RX_USED);
+
+	/* Make descriptor updates visible to hardware */
 	wmb();
 
 	/*
@@ -479,7 +488,9 @@ static int macb_rx(struct macb *bp, int budget)
 	for (; budget > 0; tail = NEXT_RX(tail)) {
 		u32 addr, ctrl;
 
+		/* Make hw descriptor updates visible to CPU */
 		rmb();
+
 		addr = bp->rx_ring[tail].addr;
 		ctrl = bp->rx_ring[tail].ctrl;
 
@@ -674,6 +685,8 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	bp->tx_ring[entry].addr = mapping;
 	bp->tx_ring[entry].ctrl = ctrl;
+
+	/* Make newly initialized descriptor visible to hardware */
 	wmb();
 
 	entry = NEXT_TX(entry);
@@ -782,9 +795,6 @@ static void macb_init_rings(struct macb *bp)
 
 static void macb_reset_hw(struct macb *bp)
 {
-	/* Make sure we have the write buffer for ourselves */
-	wmb();
-
 	/*
 	 * Disable RX and TX (XXX: Should we halt the transmission
 	 * more gracefully?)
-- 
1.7.10
