From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 1/5] net: mvpp2: remove mvpp2_bm_cookie_{build,pool_get}
Date: Thu,  8 Jun 2017 17:27:23 +0200
Message-ID: <1496935647-29670-2-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1496935647-29670-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Marcin Wojtas <mw@semihalf.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Markus Elfring <elfring@users.sourceforge.net>,
        Marc Zyngier <marc.zyngier@arm.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:34604 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751803AbdFHP2C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 11:28:02 -0400
In-Reply-To: <1496935647-29670-1-git-send-email-thomas.petazzoni@free-electrons.com>
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
 drivers/net/ethernet/marvell/mvpp2.c | 51 ++++++++++--------------------------
 1 file changed, 14 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 9b875d7..cff45e3 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -666,10 +666,6 @@ enum mvpp2_prs_l3_cast {
 #define MVPP2_BM_SWF_LONG_POOL(port)	((port > 2) ? 2 : port)
 #define MVPP2_BM_SWF_SHORT_POOL		3
 
-/* BM cookie (32 bits) definition */
-#define MVPP2_BM_COOKIE_POOL_OFFS	8
-#define MVPP2_BM_COOKIE_CPU_OFFS	24
-
 /* BM short pool packet size
  * These value assure that for SWF the total number
  * of bytes allocated for each buffer will be 512
@@ -3920,12 +3916,6 @@ static inline u32 mvpp2_bm_cookie_pool_set(u32 cookie, int pool)
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
@@ -3961,12 +3951,10 @@ static inline void mvpp2_bm_pool_put(struct mvpp2_port *port, int pool,
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
 
@@ -4515,21 +4503,6 @@ static void mvpp2_rxq_offset_set(struct mvpp2_port *port,
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
@@ -4980,9 +4953,13 @@ static void mvpp2_rxq_drop_pkts(struct mvpp2_port *port,
 
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
@@ -5420,7 +5397,7 @@ static void mvpp2_rx_csum(struct mvpp2_port *port, u32 status,
 
 /* Reuse skb if possible, or allocate a new skb and add it to BM pool */
 static int mvpp2_rx_refill(struct mvpp2_port *port,
-			   struct mvpp2_bm_pool *bm_pool, u32 bm)
+			   struct mvpp2_bm_pool *bm_pool, int pool)
 {
 	dma_addr_t dma_addr;
 	phys_addr_t phys_addr;
@@ -5432,7 +5409,7 @@ static int mvpp2_rx_refill(struct mvpp2_port *port,
 	if (!buf)
 		return -ENOMEM;
 
-	mvpp2_pool_refill(port, bm, dma_addr, phys_addr);
+	mvpp2_pool_refill(port, pool, dma_addr, phys_addr);
 
 	return 0;
 }
@@ -5490,7 +5467,7 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 		unsigned int frag_size;
 		dma_addr_t dma_addr;
 		phys_addr_t phys_addr;
-		u32 bm, rx_status;
+		u32 rx_status;
 		int pool, rx_bytes, err;
 		void *data;
 
@@ -5502,8 +5479,8 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 		phys_addr = mvpp2_rxdesc_cookie_get(port, rx_desc);
 		data = (void *)phys_to_virt(phys_addr);
 
-		bm = mvpp2_bm_cookie_build(port, rx_desc);
-		pool = mvpp2_bm_cookie_pool_get(bm);
+		pool = (rx_status & MVPP2_RXD_BM_POOL_ID_MASK) >>
+			MVPP2_RXD_BM_POOL_ID_OFFS;
 		bm_pool = &port->priv->bm_pools[pool];
 
 		/* In case of an error, release the requested buffer pointer
@@ -5516,7 +5493,7 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 			dev->stats.rx_errors++;
 			mvpp2_rx_error(port, rx_desc);
 			/* Return the buffer to the pool */
-			mvpp2_pool_refill(port, bm, dma_addr, phys_addr);
+			mvpp2_pool_refill(port, pool, dma_addr, phys_addr);
 			continue;
 		}
 
@@ -5531,7 +5508,7 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 			goto err_drop_frame;
 		}
 
-		err = mvpp2_rx_refill(port, bm_pool, bm);
+		err = mvpp2_rx_refill(port, bm_pool, pool);
 		if (err) {
 			netdev_err(port->dev, "failed to refill BM pools\n");
 			goto err_drop_frame;
-- 
2.7.4
