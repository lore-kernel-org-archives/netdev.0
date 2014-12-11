From: Petri Gynther <pgynther@google.com>
Subject: [PATCH v2 1/4 net-next] net: bcmgenet: bcmgenet_init_tx_ring() cleanup
Date: Thu, 11 Dec 2014 02:20:30 -0800 (PST)
Message-ID: <20141211102030.5E534222AAA@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:55211 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbaLKKUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 05:20:32 -0500
Received: by mail-pd0-f201.google.com with SMTP id ft15so712641pdb.0
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 02:20:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 23 ++++++++---------------
 1 file changed, 8 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 7078bd3..ea7a137 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1680,17 +1680,14 @@ static int init_umac(struct bcmgenet_priv *priv)
 	return 0;
 }
 
-/* Initialize all house-keeping variables for a TX ring, along
- * with corresponding hardware registers
- */
+/* Initialize a Tx ring along with corresponding hardware registers */
 static void bcmgenet_init_tx_ring(struct bcmgenet_priv *priv,
 				  unsigned int index, unsigned int size,
-				  unsigned int write_ptr, unsigned int end_ptr)
+				  unsigned int start_ptr, unsigned int end_ptr)
 {
 	struct bcmgenet_tx_ring *ring = &priv->tx_rings[index];
 	u32 words_per_bd = WORDS_PER_BD(priv);
 	u32 flow_period_val = 0;
-	unsigned int first_bd;
 
 	spin_lock_init(&ring->lock);
 	ring->index = index;
@@ -1703,12 +1700,12 @@ static void bcmgenet_init_tx_ring(struct bcmgenet_priv *priv,
 		ring->int_enable = bcmgenet_tx_ring_int_enable;
 		ring->int_disable = bcmgenet_tx_ring_int_disable;
 	}
-	ring->cbs = priv->tx_cbs + write_ptr;
+	ring->cbs = priv->tx_cbs + start_ptr;
 	ring->size = size;
 	ring->c_index = 0;
 	ring->free_bds = size;
-	ring->write_ptr = write_ptr;
-	ring->cb_ptr = write_ptr;
+	ring->write_ptr = start_ptr;
+	ring->cb_ptr = start_ptr;
 	ring->end_ptr = end_ptr - 1;
 	ring->prod_index = 0;
 
@@ -1719,22 +1716,18 @@ static void bcmgenet_init_tx_ring(struct bcmgenet_priv *priv,
 	bcmgenet_tdma_ring_writel(priv, index, 0, TDMA_PROD_INDEX);
 	bcmgenet_tdma_ring_writel(priv, index, 0, TDMA_CONS_INDEX);
 	bcmgenet_tdma_ring_writel(priv, index, 1, DMA_MBUF_DONE_THRESH);
-	/* Disable rate control for now */
 	bcmgenet_tdma_ring_writel(priv, index, flow_period_val,
 				  TDMA_FLOW_PERIOD);
-	/* Unclassified traffic goes to ring 16 */
 	bcmgenet_tdma_ring_writel(priv, index,
 				  ((size << DMA_RING_SIZE_SHIFT) |
 				   RX_BUF_LENGTH), DMA_RING_BUF_SIZE);
 
-	first_bd = write_ptr;
-
 	/* Set start and end address, read and write pointers */
-	bcmgenet_tdma_ring_writel(priv, index, first_bd * words_per_bd,
+	bcmgenet_tdma_ring_writel(priv, index, start_ptr * words_per_bd,
 				  DMA_START_ADDR);
-	bcmgenet_tdma_ring_writel(priv, index, first_bd * words_per_bd,
+	bcmgenet_tdma_ring_writel(priv, index, start_ptr * words_per_bd,
 				  TDMA_READ_PTR);
-	bcmgenet_tdma_ring_writel(priv, index, first_bd,
+	bcmgenet_tdma_ring_writel(priv, index, start_ptr * words_per_bd,
 				  TDMA_WRITE_PTR);
 	bcmgenet_tdma_ring_writel(priv, index, end_ptr * words_per_bd - 1,
 				  DMA_END_ADDR);
-- 
2.2.0.rc0.207.ga3a616c
