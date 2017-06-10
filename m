From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2 1/2] net: mvpp2: remove mvpp2_bm_cookie_{build,pool_get}
Date: Sat, 10 Jun 2017 23:18:21 +0200
Message-ID: <20170610211822.24371-2-thomas.petazzoni@free-electrons.com>
References: <20170610211822.24371-1-thomas.petazzoni@free-electrons.com>
Cc: Marc Zyngier <marc.zyngier@arm.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:44377 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751642AbdFJVSg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 17:18:36 -0400
In-Reply-To: <20170610211822.24371-1-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit removes the useless remove
mvpp2_bm_cookie_{build,pool_get} functions. All what
mvpp2_bm_cookie_build() was doing is compute a 32-bit value by
concatenating the pool number and the CPU number... only to get the pool
number re-extracted by mvpp2_bm_cookie_pool_get() later on.

Instead, just get the pool number directly from RX descriptor status,
and pass it to mvpp2_pool_refill() and mvpp2_rx_refill().

This has the added benefit of dropping a smp_processor_id() call in a
migration-enabled context, which is wrong, and is the original
motivation for making this change.

Fixes: 3f518509dedc9 ("ethernet: Add new driver for Marvell Armada 375 network unit")
Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 47 +++++++++++-------------------------
 1 file changed, 14 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 70bca2a..5841e53 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -3920,12 +3920,6 @@ static inline u32 mvpp2_bm_cookie_pool_set(u32 cookie, int pool)
 	return bm;
 }
 
-/* Get pool number from a BM cookie */
-static inline int mvpp2_bm_cookie_pool_get(unsigned long cookie)
-{
-	return (cookie >> MVPP2_BM_COOKIE_POOL_OFFS) & 0xFF;
-}
-
 /* Release buffer to BM */
 static inline void mvpp2_bm_pool_put(struct mvpp2_port *port, int pool,
 				     dma_addr_t buf_dma_addr,
@@ -3961,12 +3955,10 @@ static inline void mvpp2_bm_pool_put(struct mvpp2_port *port, int pool,
 }
 
 /* Refill BM pool */
-static void mvpp2_pool_refill(struct mvpp2_port *port, u32 bm,
+static void mvpp2_pool_refill(struct mvpp2_port *port, int pool,
 			      dma_addr_t dma_addr,
 			      phys_addr_t phys_addr)
 {
-	int pool = mvpp2_bm_cookie_pool_get(bm);
-
 	mvpp2_bm_pool_put(port, pool, dma_addr, phys_addr);
 }
 
@@ -4513,21 +4505,6 @@ static void mvpp2_rxq_offset_set(struct mvpp2_port *port,
 	mvpp2_write(port->priv, MVPP2_RXQ_CONFIG_REG(prxq), val);
 }
 
-/* Obtain BM cookie information from descriptor */
-static u32 mvpp2_bm_cookie_build(struct mvpp2_port *port,
-				 struct mvpp2_rx_desc *rx_desc)
-{
-	int cpu = smp_processor_id();
-	int pool;
-
-	pool = (mvpp2_rxdesc_status_get(port, rx_desc) &
-		MVPP2_RXD_BM_POOL_ID_MASK) >>
-		MVPP2_RXD_BM_POOL_ID_OFFS;
-
-	return ((pool & 0xFF) << MVPP2_BM_COOKIE_POOL_OFFS) |
-	       ((cpu & 0xFF) << MVPP2_BM_COOKIE_CPU_OFFS);
-}
-
 /* Tx descriptors helper methods */
 
 /* Get pointer to next Tx descriptor to be processed (send) by HW */
@@ -4978,9 +4955,13 @@ static void mvpp2_rxq_drop_pkts(struct mvpp2_port *port,
 
 	for (i = 0; i < rx_received; i++) {
 		struct mvpp2_rx_desc *rx_desc = mvpp2_rxq_next_desc_get(rxq);
-		u32 bm = mvpp2_bm_cookie_build(port, rx_desc);
+		u32 status = mvpp2_rxdesc_status_get(port, rx_desc);
+		int pool;
+
+		pool = (status & MVPP2_RXD_BM_POOL_ID_MASK) >>
+			MVPP2_RXD_BM_POOL_ID_OFFS;
 
-		mvpp2_pool_refill(port, bm,
+		mvpp2_pool_refill(port, pool,
 				  mvpp2_rxdesc_dma_addr_get(port, rx_desc),
 				  mvpp2_rxdesc_cookie_get(port, rx_desc));
 	}
@@ -5418,7 +5399,7 @@ static void mvpp2_rx_csum(struct mvpp2_port *port, u32 status,
 
 /* Reuse skb if possible, or allocate a new skb and add it to BM pool */
 static int mvpp2_rx_refill(struct mvpp2_port *port,
-			   struct mvpp2_bm_pool *bm_pool, u32 bm)
+			   struct mvpp2_bm_pool *bm_pool, int pool)
 {
 	dma_addr_t dma_addr;
 	phys_addr_t phys_addr;
@@ -5430,7 +5411,7 @@ static int mvpp2_rx_refill(struct mvpp2_port *port,
 	if (!buf)
 		return -ENOMEM;
 
-	mvpp2_pool_refill(port, bm, dma_addr, phys_addr);
+	mvpp2_pool_refill(port, pool, dma_addr, phys_addr);
 
 	return 0;
 }
@@ -5488,7 +5469,7 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 		unsigned int frag_size;
 		dma_addr_t dma_addr;
 		phys_addr_t phys_addr;
-		u32 bm, rx_status;
+		u32 rx_status;
 		int pool, rx_bytes, err;
 		void *data;
 
@@ -5500,8 +5481,8 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 		phys_addr = mvpp2_rxdesc_cookie_get(port, rx_desc);
 		data = (void *)phys_to_virt(phys_addr);
 
-		bm = mvpp2_bm_cookie_build(port, rx_desc);
-		pool = mvpp2_bm_cookie_pool_get(bm);
+		pool = (rx_status & MVPP2_RXD_BM_POOL_ID_MASK) >>
+			MVPP2_RXD_BM_POOL_ID_OFFS;
 		bm_pool = &port->priv->bm_pools[pool];
 
 		/* In case of an error, release the requested buffer pointer
@@ -5514,7 +5495,7 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 			dev->stats.rx_errors++;
 			mvpp2_rx_error(port, rx_desc);
 			/* Return the buffer to the pool */
-			mvpp2_pool_refill(port, bm, dma_addr, phys_addr);
+			mvpp2_pool_refill(port, pool, dma_addr, phys_addr);
 			continue;
 		}
 
@@ -5529,7 +5510,7 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 			goto err_drop_frame;
 		}
 
-		err = mvpp2_rx_refill(port, bm_pool, bm);
+		err = mvpp2_rx_refill(port, bm_pool, pool);
 		if (err) {
 			netdev_err(port->dev, "failed to refill BM pools\n");
 			goto err_drop_frame;
-- 
2.9.4
