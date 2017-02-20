From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH net-next v3 2/4] net: mvneta: avoid getting buf_phys_addr from rx_desc again
Date: Mon, 20 Feb 2017 20:53:42 +0800
Message-ID: <20170220125344.3555-3-jszhang@marvell.com>
References: <20170220125344.3555-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Jisheng Zhang <jszhang@marvell.com>
To: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>,
        <arnd@arndb.de>, <gregory.clement@free-electrons.com>,
        <mw@semihalf.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170220125344.3555-1-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In hot code path mvneta_rx_hwbm(), the rx_desc->buf_phys_addr is read
four times. The rx_desc is allocated by dma_alloc_coherent, it's
uncacheable if the device isn't cache-coherent, reading from uncached
memory is fairly slow. So reuse the read out phys_addr variable to
avoid the extra reading from uncached memory.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
Suggested-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 06df72b8da85..a25042801eec 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2082,8 +2082,7 @@ static int mvneta_rx_hwbm(struct mvneta_port *pp, int rx_todo,
 		    (rx_status & MVNETA_RXD_ERR_SUMMARY)) {
 err_drop_frame_ret_pool:
 			/* Return the buffer to the pool */
-			mvneta_bm_pool_put_bp(pp->bm_priv, bm_pool,
-					      rx_desc->buf_phys_addr);
+			mvneta_bm_pool_put_bp(pp->bm_priv, bm_pool, phys_addr);
 err_drop_frame:
 			dev->stats.rx_errors++;
 			mvneta_rx_error(pp, rx_desc);
@@ -2098,7 +2097,7 @@ static int mvneta_rx_hwbm(struct mvneta_port *pp, int rx_todo,
 				goto err_drop_frame_ret_pool;
 
 			dma_sync_single_range_for_cpu(dev->dev.parent,
-			                              rx_desc->buf_phys_addr,
+			                              phys_addr,
 			                              MVNETA_MH_SIZE + NET_SKB_PAD,
 			                              rx_bytes,
 			                              DMA_FROM_DEVICE);
@@ -2114,8 +2113,7 @@ static int mvneta_rx_hwbm(struct mvneta_port *pp, int rx_todo,
 			rcvd_bytes += rx_bytes;
 
 			/* Return the buffer to the pool */
-			mvneta_bm_pool_put_bp(pp->bm_priv, bm_pool,
-					      rx_desc->buf_phys_addr);
+			mvneta_bm_pool_put_bp(pp->bm_priv, bm_pool, phys_addr);
 
 			/* leave the descriptor and buffer untouched */
 			continue;
-- 
2.11.0
