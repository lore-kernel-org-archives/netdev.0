From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 8/8] net: mv643xx_eth: Avoid unmapping the TSO header buffers
Date: Fri, 30 May 2014 13:40:11 -0300
Message-ID: <1401468011-10609-9-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>, fugang.duan@freescale.com,
	Willy Tarreau <w@1wt.eu>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:58462 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752015AbaE3Qld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 12:41:33 -0400
In-Reply-To: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The buffers for the TSO headers belong to a DMA coherent region which is
allocated at ndo_open() time, and released at ndo_stop() time.

Therefore, and contrary to the TSO payload descriptor buffers, the TSO header
buffers don't need to be unmapped. This commit adds a check to detect a
TSO header buffer and explicitly prevent the unmap.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 88afbe0..b151a94 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -189,6 +189,9 @@ static char mv643xx_eth_driver_version[] = "1.4";
 #define MV643XX_MAX_TSO_SEGS 100
 #define MV643XX_MAX_SKB_DESCS (MV643XX_MAX_TSO_SEGS * 2 + MAX_SKB_FRAGS)
 
+#define IS_TSO_HEADER(txq, addr) \
+	((addr >= txq->tso_hdrs_dma) && \
+	 (addr < txq->tso_hdrs_dma + txq->tx_ring_size * TSO_HEADER_SIZE))
 /*
  * RX/TX descriptors.
  */
@@ -1072,8 +1075,9 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 			mp->dev->stats.tx_errors++;
 		}
 
-		dma_unmap_single(mp->dev->dev.parent, desc->buf_ptr,
-				 desc->byte_cnt, DMA_TO_DEVICE);
+		if (!IS_TSO_HEADER(txq, desc->buf_ptr))
+			dma_unmap_single(mp->dev->dev.parent, desc->buf_ptr,
+					 desc->byte_cnt, DMA_TO_DEVICE);
 		dev_kfree_skb(skb);
 	}
 
-- 
1.9.1
