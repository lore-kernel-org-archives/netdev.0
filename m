From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 5/5] net: mvpp2: remove mvpp2_pool_refill()
Date: Thu,  8 Jun 2017 17:27:27 +0200
Message-ID: <1496935647-29670-6-git-send-email-thomas.petazzoni@free-electrons.com>
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
Received: from mail.free-electrons.com ([62.4.15.54]:34646 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751926AbdFHP2L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 11:28:11 -0400
In-Reply-To: <1496935647-29670-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When all a function does is calling another function with the exact same
arguments, in the exact same order, you know it's time to remove said
function. Which is exactly what this commit does.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 14 +++-----------
 1 file changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 4ca1639..747e3a4 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -3943,14 +3943,6 @@ static inline void mvpp2_bm_pool_put(struct mvpp2_port *port, int pool,
 	put_cpu();
 }
 
-/* Refill BM pool */
-static void mvpp2_pool_refill(struct mvpp2_port *port, int pool,
-			      dma_addr_t dma_addr,
-			      phys_addr_t phys_addr)
-{
-	mvpp2_bm_pool_put(port, pool, dma_addr, phys_addr);
-}
-
 /* Allocate buffers for the pool */
 static int mvpp2_bm_bufs_add(struct mvpp2_port *port,
 			     struct mvpp2_bm_pool *bm_pool, int buf_num)
@@ -4980,7 +4972,7 @@ static void mvpp2_rxq_drop_pkts(struct mvpp2_port *port,
 		pool = (status & MVPP2_RXD_BM_POOL_ID_MASK) >>
 			MVPP2_RXD_BM_POOL_ID_OFFS;
 
-		mvpp2_pool_refill(port, pool,
+		mvpp2_bm_pool_put(port, pool,
 				  mvpp2_rxdesc_dma_addr_get(port, rx_desc),
 				  mvpp2_rxdesc_cookie_get(port, rx_desc));
 	}
@@ -5434,7 +5426,7 @@ static int mvpp2_rx_refill(struct mvpp2_port *port,
 	if (!buf)
 		return -ENOMEM;
 
-	mvpp2_pool_refill(port, pool, dma_addr, phys_addr);
+	mvpp2_bm_pool_put(port, pool, dma_addr, phys_addr);
 
 	return 0;
 }
@@ -5518,7 +5510,7 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 			dev->stats.rx_errors++;
 			mvpp2_rx_error(port, rx_desc);
 			/* Return the buffer to the pool */
-			mvpp2_pool_refill(port, pool, dma_addr, phys_addr);
+			mvpp2_bm_pool_put(port, pool, dma_addr, phys_addr);
 			continue;
 		}
 
-- 
2.7.4
