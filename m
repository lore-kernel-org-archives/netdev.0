From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 4/8] net: mvneta: Avoid unmapping the TSO header buffers
Date: Fri, 30 May 2014 13:40:07 -0300
Message-ID: <1401468011-10609-5-git-send-email-ezequiel.garcia@free-electrons.com>
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
Received: from top.free-electrons.com ([176.31.233.9]:58435 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933415AbaE3QlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 12:41:18 -0400
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
 drivers/net/ethernet/marvell/mvneta.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index f95e7ca..45beca1 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -264,6 +264,10 @@
 	      ETH_HLEN + ETH_FCS_LEN,			     \
 	      MVNETA_CPU_D_CACHE_LINE_SIZE)
 
+#define IS_TSO_HEADER(txq, addr) \
+	((addr >= txq->tso_hdrs_phys) && \
+	 (addr < txq->tso_hdrs_phys + txq->size * TSO_HEADER_SIZE))
+
 #define MVNETA_RX_BUF_SIZE(pkt_size)   ((pkt_size) + NET_SKB_PAD)
 
 struct mvneta_pcpu_stats {
@@ -1291,8 +1295,10 @@ static void mvneta_txq_bufs_free(struct mvneta_port *pp,
 
 		mvneta_txq_inc_get(txq);
 
-		dma_unmap_single(pp->dev->dev.parent, tx_desc->buf_phys_addr,
-				 tx_desc->data_size, DMA_TO_DEVICE);
+		if (!IS_TSO_HEADER(txq, tx_desc->buf_phys_addr))
+			dma_unmap_single(pp->dev->dev.parent,
+					 tx_desc->buf_phys_addr,
+					 tx_desc->data_size, DMA_TO_DEVICE);
 		if (!skb)
 			continue;
 		dev_kfree_skb_any(skb);
@@ -1642,7 +1648,7 @@ err_release:
 	 */
 	for (i = desc_count - 1; i >= 0; i--) {
 		struct mvneta_tx_desc *tx_desc = txq->descs + i;
-		if (!(tx_desc->command & MVNETA_TXD_F_DESC))
+		if (!IS_TSO_HEADER(txq, tx_desc->buf_phys_addr))
 			dma_unmap_single(pp->dev->dev.parent,
 					 tx_desc->buf_phys_addr,
 					 tx_desc->data_size,
-- 
1.9.1
