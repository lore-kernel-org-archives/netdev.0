From: Petri Gynther <pgynther@google.com>
Subject: [PATCH v2 3/4 net-next] net: bcmgenet: precalculate TxCB->bd_addr
Date: Thu, 11 Dec 2014 02:20:56 -0800 (PST)
Message-ID: <20141211102056.9C580222AAA@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:38974 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220AbaLKKU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 05:20:58 -0500
Received: by mail-ob0-f201.google.com with SMTP id nt9so330326obb.0
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 02:20:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is 1-to-1 mapping between TxCBs and TxBDs. Precalculate TxCB->bd_addr
once in bcmgenet_init_dma() instead of doing it over and over needlessly in
bcmgenet_get_txcb().

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index d46ff12..4a7744b 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -920,7 +920,7 @@ static struct enet_cb *bcmgenet_get_txcb(struct bcmgenet_priv *priv,
 
 	tx_cb_ptr = ring->cbs;
 	tx_cb_ptr += ring->write_ptr - ring->cb_ptr;
-	tx_cb_ptr->bd_addr = priv->tx_bds + ring->write_ptr * DMA_DESC_SIZE;
+
 	/* Advancing local write pointer */
 	if (ring->write_ptr == ring->end_ptr)
 		ring->write_ptr = ring->cb_ptr;
@@ -1918,6 +1918,8 @@ static void bcmgenet_fini_dma(struct bcmgenet_priv *priv)
 static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
 {
 	int ret;
+	unsigned int i;
+	struct enet_cb *cb;
 
 	netif_dbg(priv, hw, priv->dev, "bcmgenet: init_edma\n");
 
@@ -1944,6 +1946,11 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
 		return -ENOMEM;
 	}
 
+	for (i = 0; i < priv->num_tx_bds; i++) {
+		cb = priv->tx_cbs + i;
+		cb->bd_addr = priv->tx_bds + i * DMA_DESC_SIZE;
+	}
+
 	/* Initialize Tx queues */
 	bcmgenet_init_tx_queues(priv->dev);
 
-- 
2.2.0.rc0.207.ga3a616c
