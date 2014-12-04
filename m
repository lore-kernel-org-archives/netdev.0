From: Petri Gynther <pgynther@google.com>
Subject: [PATCH 1/4 net-next] net: bcmgenet: bcmgenet_init_tx_ring() cleanup
Date: Wed,  3 Dec 2014 20:11:31 -0800 (PST)
Message-ID: <20141204041131.830CB2200C7@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f73.google.com ([209.85.213.73]:49178 "EHLO
	mail-yh0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbaLDELd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 23:11:33 -0500
Received: by mail-yh0-f73.google.com with SMTP id f10so919086yha.4
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 20:11:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 23 +++++++++--------------
 1 file changed, 9 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f2fadb0..78ab733 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1679,17 +1679,16 @@ static int init_umac(struct bcmgenet_priv *priv)
 	return 0;
 }
 
-/* Initialize all house-keeping variables for a TX ring, along
- * with corresponding hardware registers
+/*
+ * Initialize a Tx ring along with corresponding hardware registers.
  */
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
@@ -1702,12 +1701,12 @@ static void bcmgenet_init_tx_ring(struct bcmgenet_priv *priv,
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
 
@@ -1718,22 +1717,18 @@ static void bcmgenet_init_tx_ring(struct bcmgenet_priv *priv,
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
