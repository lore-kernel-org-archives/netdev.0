From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: [PATCH v2 1/1] net: macb: remove BUG_ON() and reset the queue to handle RX errors
Date: Fri, 25 Mar 2016 10:37:34 +0100
Message-ID: <1458898654-25864-1-git-send-email-cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <narmstrong@baylibre.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes two BUG_ON() used to notify about RX queue corruptions
on macb (not gem) hardware without actually handling the error.

The new code skips corrupted frames but still processes faultless frames.
Then it resets the RX queue before restarting the reception from a clean
state.

This patch is a rework of an older patch proposed by Neil Armstrong:
http://patchwork.ozlabs.org/patch/371525/

Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Acked-by: Neil Armstrong <narmstrong@baylibre.com>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---

ChangeLog

v1 -> v2
- add Acked-by Neil Armstrong and Nicolas Ferre
- use bool type instead of int for the 'reset_rx_queue' variable
- move longer declarations before shorter declarations

 drivers/net/ethernet/cadence/macb.c | 59 ++++++++++++++++++++++++++++++-------
 1 file changed, 49 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index f715352a9b85..6c3dc27cb100 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -917,7 +917,10 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 		unsigned int frag_len = bp->rx_buffer_size;
 
 		if (offset + frag_len > len) {
-			BUG_ON(frag != last_frag);
+			if (unlikely(frag != last_frag)) {
+				dev_kfree_skb_any(skb);
+				return -1;
+			}
 			frag_len = len - offset;
 		}
 		skb_copy_to_linear_data_offset(skb, offset,
@@ -945,8 +948,23 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 	return 0;
 }
 
+static inline void macb_init_rx_ring(struct macb *bp)
+{
+	dma_addr_t addr;
+	int i;
+
+	addr = bp->rx_buffers_dma;
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		bp->rx_ring[i].addr = addr;
+		bp->rx_ring[i].ctrl = 0;
+		addr += bp->rx_buffer_size;
+	}
+	bp->rx_ring[RX_RING_SIZE - 1].addr |= MACB_BIT(RX_WRAP);
+}
+
 static int macb_rx(struct macb *bp, int budget)
 {
+	bool reset_rx_queue = false;
 	int received = 0;
 	unsigned int tail;
 	int first_frag = -1;
@@ -972,10 +990,18 @@ static int macb_rx(struct macb *bp, int budget)
 
 		if (ctrl & MACB_BIT(RX_EOF)) {
 			int dropped;
-			BUG_ON(first_frag == -1);
+
+			if (unlikely(first_frag == -1)) {
+				reset_rx_queue = true;
+				continue;
+			}
 
 			dropped = macb_rx_frame(bp, first_frag, tail);
 			first_frag = -1;
+			if (unlikely(dropped < 0)) {
+				reset_rx_queue = true;
+				continue;
+			}
 			if (!dropped) {
 				received++;
 				budget--;
@@ -983,6 +1009,26 @@ static int macb_rx(struct macb *bp, int budget)
 		}
 	}
 
+	if (unlikely(reset_rx_queue)) {
+		unsigned long flags;
+		u32 ctrl;
+
+		netdev_err(bp->dev, "RX queue corruption: reset it\n");
+
+		spin_lock_irqsave(&bp->lock, flags);
+
+		ctrl = macb_readl(bp, NCR);
+		macb_writel(bp, NCR, ctrl & ~MACB_BIT(RE));
+
+		macb_init_rx_ring(bp);
+		macb_writel(bp, RBQP, bp->rx_ring_dma);
+
+		macb_writel(bp, NCR, ctrl | MACB_BIT(RE));
+
+		spin_unlock_irqrestore(&bp->lock, flags);
+		return received;
+	}
+
 	if (first_frag != -1)
 		bp->rx_tail = first_frag;
 	else
@@ -1523,15 +1569,8 @@ static void gem_init_rings(struct macb *bp)
 static void macb_init_rings(struct macb *bp)
 {
 	int i;
-	dma_addr_t addr;
 
-	addr = bp->rx_buffers_dma;
-	for (i = 0; i < RX_RING_SIZE; i++) {
-		bp->rx_ring[i].addr = addr;
-		bp->rx_ring[i].ctrl = 0;
-		addr += bp->rx_buffer_size;
-	}
-	bp->rx_ring[RX_RING_SIZE - 1].addr |= MACB_BIT(RX_WRAP);
+	macb_init_rx_ring(bp);
 
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		bp->queues[0].tx_ring[i].addr = 0;
-- 
1.8.2.2
