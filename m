From: Neil Armstrong <narmstrong@neotion.com>
Subject: [PATCH v2 1/2] net: macb: Separate rx and tx ring init function
Date: Fri, 18 Jul 2014 14:43:02 +0200
Message-ID: <53C91656.7010009@neotion.com>
Reply-To: narmstrong@neotion.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Neil Armstrong <narmstrong@neotion.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A single method is called to initialize the TX and RX rings.
Separate the methods into distinct ones for MACB and GEM contexts.
Also remove the multiple assignments from the original code.

Signed-off-by: Neil Armstrong <narmstrong@neotion.com>
---
 drivers/net/ethernet/cadence/macb.c |   36 ++++++++++++++++++++++++++--------
 drivers/net/ethernet/cadence/macb.h |    3 +-
 2 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index e9daa07..4d73110 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1219,7 +1219,15 @@ out_err:
 	return -ENOMEM;
 }
 
-static void gem_init_rings(struct macb *bp)
+static void gem_init_rx_rings(struct macb *bp)
+{
+	bp->rx_tail = 0;
+	bp->rx_prepared_head = 0;
+
+	gem_rx_refill(bp);
+}
+
+static void gem_init_tx_rings(struct macb *bp)
 {
 	int i;
 
@@ -1229,12 +1237,11 @@ static void gem_init_rings(struct macb *bp)
 	}
 	bp->tx_ring[TX_RING_SIZE - 1].ctrl |= MACB_BIT(TX_WRAP);
 
-	bp->rx_tail = bp->rx_prepared_head = bp->tx_head = bp->tx_tail = 0;
-
-	gem_rx_refill(bp);
+	bp->tx_head = 0;
+	bp->tx_tail = 0;
 }
 
-static void macb_init_rings(struct macb *bp)
+static void macb_init_rx_rings(struct macb *bp)
 {
 	int i;
 	dma_addr_t addr;
@@ -1247,13 +1254,21 @@ static void macb_init_rings(struct macb *bp)
 	}
 	bp->rx_ring[RX_RING_SIZE - 1].addr |= MACB_BIT(RX_WRAP);
 
+	bp->rx_tail = 0;
+}
+
+static void macb_init_tx_rings(struct macb *bp)
+{
+	int i;
+
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		bp->tx_ring[i].addr = 0;
 		bp->tx_ring[i].ctrl = MACB_BIT(TX_USED);
 	}
 	bp->tx_ring[TX_RING_SIZE - 1].ctrl |= MACB_BIT(TX_WRAP);
 
-	bp->rx_tail = bp->tx_head = bp->tx_tail = 0;
+	bp->tx_head = 0;
+	bp->tx_tail = 0;
 }
 
 static void macb_reset_hw(struct macb *bp)
@@ -1554,7 +1569,8 @@ static int macb_open(struct net_device *dev)
 
 	napi_enable(&bp->napi);
 
-	bp->macbgem_ops.mog_init_rings(bp);
+	bp->macbgem_ops.mog_init_rx_rings(bp);
+	bp->macbgem_ops.mog_init_tx_rings(bp);
 	macb_init_hw(bp);
 
 	/* schedule a link state check */
@@ -1901,12 +1917,14 @@ static int __init macb_probe(struct platform_device *pdev)
 	if (macb_is_gem(bp)) {
 		bp->macbgem_ops.mog_alloc_rx_buffers = gem_alloc_rx_buffers;
 		bp->macbgem_ops.mog_free_rx_buffers = gem_free_rx_buffers;
-		bp->macbgem_ops.mog_init_rings = gem_init_rings;
+		bp->macbgem_ops.mog_init_rx_rings = gem_init_rx_rings;
+		bp->macbgem_ops.mog_init_tx_rings = gem_init_tx_rings;
 		bp->macbgem_ops.mog_rx = gem_rx;
 	} else {
 		bp->macbgem_ops.mog_alloc_rx_buffers = macb_alloc_rx_buffers;
 		bp->macbgem_ops.mog_free_rx_buffers = macb_free_rx_buffers;
-		bp->macbgem_ops.mog_init_rings = macb_init_rings;
+		bp->macbgem_ops.mog_init_rx_rings = macb_init_rx_rings;
+		bp->macbgem_ops.mog_init_tx_rings = macb_init_tx_rings;
 		bp->macbgem_ops.mog_rx = macb_rx;
 	}
 
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 51c0244..8016d08 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -550,7 +550,8 @@ struct macb;
 struct macb_or_gem_ops {
 	int	(*mog_alloc_rx_buffers)(struct macb *bp);
 	void	(*mog_free_rx_buffers)(struct macb *bp);
-	void	(*mog_init_rings)(struct macb *bp);
+	void	(*mog_init_rx_rings)(struct macb *bp);
+	void	(*mog_init_tx_rings)(struct macb *bp);
 	int	(*mog_rx)(struct macb *bp, int budget);
 };
 
-- 
1.7.0.4
