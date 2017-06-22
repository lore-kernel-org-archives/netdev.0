From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH net-next 3/3] net: mvpp2: remove mvpp2_pool_refill()
Date: Thu, 22 Jun 2017 14:23:20 +0200
Message-ID: <20170622122320.32676-4-thomas.petazzoni@free-electrons.com>
References: <20170622122320.32676-1-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        =?UTF-8?q?Miqu=C3=A8l=20Raynal?= <miquel.raynal@free-electrons.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:38169 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751858AbdFVMXj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 08:23:39 -0400
In-Reply-To: <20170622122320.32676-1-thomas.petazzoni@free-electrons.com>
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
index aad763c..48d21c1 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -3953,14 +3953,6 @@ static inline void mvpp2_bm_pool_put(struct mvpp2_port *port, int pool,
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
@@ -5015,7 +5007,7 @@ static void mvpp2_rxq_drop_pkts(struct mvpp2_port *port,
 		pool = (status & MVPP2_RXD_BM_POOL_ID_MASK) >>
 			MVPP2_RXD_BM_POOL_ID_OFFS;
 
-		mvpp2_pool_refill(port, pool,
+		mvpp2_bm_pool_put(port, pool,
 				  mvpp2_rxdesc_dma_addr_get(port, rx_desc),
 				  mvpp2_rxdesc_cookie_get(port, rx_desc));
 	}
@@ -5469,7 +5461,7 @@ static int mvpp2_rx_refill(struct mvpp2_port *port,
 	if (!buf)
 		return -ENOMEM;
 
-	mvpp2_pool_refill(port, pool, dma_addr, phys_addr);
+	mvpp2_bm_pool_put(port, pool, dma_addr, phys_addr);
 
 	return 0;
 }
@@ -5553,7 +5545,7 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 			dev->stats.rx_errors++;
 			mvpp2_rx_error(port, rx_desc);
 			/* Return the buffer to the pool */
-			mvpp2_pool_refill(port, pool, dma_addr, phys_addr);
+			mvpp2_bm_pool_put(port, pool, dma_addr, phys_addr);
 			continue;
 		}
 
-- 
2.9.4
