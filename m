From: Guo-Fu Tseng <cooldavid@cooldavid.org>
Subject: [PATCH net-2.6 4/7] jme: Change bufinf memory location
Date: Mon, 6 Jul 2009 22:39:46 +0800
Message-ID: <20090706145548.C25A92B015@cooldavid.org>
Cc: "netdev" <netdev@vger.kernel.org>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:39373 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752683AbZGFOzm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2009 10:55:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a large chunk of memory space preserved for
for modules, using kmalloc to obtain the needed memory.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |   86 ++++++++++++++++++++++++++++++++++++++---------------
 drivers/net/jme.h |    3 +-
 2 files changed, 63 insertions(+), 26 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 8de3940..4a55b05 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -522,12 +522,8 @@ jme_setup_tx_resources(struct jme_adapter *jme)
 				   &(txring->dmaalloc),
 				   GFP_ATOMIC);
 
-	if (!txring->alloc) {
-		txring->desc = NULL;
-		txring->dmaalloc = 0;
-		txring->dma = 0;
-		return -ENOMEM;
-	}
+	if (!txring->alloc)
+		goto err_set_null;
 
 	/*
 	 * 16 Bytes align
@@ -539,6 +535,11 @@ jme_setup_tx_resources(struct jme_adapter *jme)
 	atomic_set(&txring->next_to_clean, 0);
 	atomic_set(&txring->nr_free, jme->tx_ring_size);
 
+	txring->bufinf		= kmalloc(sizeof(struct jme_buffer_info) *
+					jme->tx_ring_size, GFP_ATOMIC);
+	if (unlikely(!(txring->bufinf)))
+		goto err_free_txring;
+
 	/*
 	 * Initialize Transmit Descriptors
 	 */
@@ -547,6 +548,20 @@ jme_setup_tx_resources(struct jme_adapter *jme)
 		sizeof(struct jme_buffer_info) * jme->tx_ring_size);
 
 	return 0;
+
+err_free_txring:
+	dma_free_coherent(&(jme->pdev->dev),
+			  TX_RING_ALLOC_SIZE(jme->tx_ring_size),
+			  txring->alloc,
+			  txring->dmaalloc);
+
+err_set_null:
+	txring->desc = NULL;
+	txring->dmaalloc = 0;
+	txring->dma = 0;
+	txring->bufinf = NULL;
+
+	return -ENOMEM;
 }
 
 static void
@@ -557,16 +572,19 @@ jme_free_tx_resources(struct jme_adapter *jme)
 	struct jme_buffer_info *txbi;
 
 	if (txring->alloc) {
-		for (i = 0 ; i < jme->tx_ring_size ; ++i) {
-			txbi = txring->bufinf + i;
-			if (txbi->skb) {
-				dev_kfree_skb(txbi->skb);
-				txbi->skb = NULL;
+		if (txring->bufinf) {
+			for (i = 0 ; i < jme->tx_ring_size ; ++i) {
+				txbi = txring->bufinf + i;
+				if (txbi->skb) {
+					dev_kfree_skb(txbi->skb);
+					txbi->skb = NULL;
+				}
+				txbi->mapping		= 0;
+				txbi->len		= 0;
+				txbi->nr_desc		= 0;
+				txbi->start_xmit	= 0;
 			}
-			txbi->mapping		= 0;
-			txbi->len		= 0;
-			txbi->nr_desc		= 0;
-			txbi->start_xmit	= 0;
+			kfree(txring->bufinf);
 		}
 
 		dma_free_coherent(&(jme->pdev->dev),
@@ -578,11 +596,11 @@ jme_free_tx_resources(struct jme_adapter *jme)
 		txring->desc		= NULL;
 		txring->dmaalloc	= 0;
 		txring->dma		= 0;
+		txring->bufinf		= NULL;
 	}
 	txring->next_to_use	= 0;
 	atomic_set(&txring->next_to_clean, 0);
 	atomic_set(&txring->nr_free, 0);
-
 }
 
 static inline void
@@ -720,8 +738,11 @@ jme_free_rx_resources(struct jme_adapter *jme)
 	struct jme_ring *rxring = &(jme->rxring[0]);
 
 	if (rxring->alloc) {
-		for (i = 0 ; i < jme->rx_ring_size ; ++i)
-			jme_free_rx_buf(jme, i);
+		if (rxring->bufinf) {
+			for (i = 0 ; i < jme->rx_ring_size ; ++i)
+				jme_free_rx_buf(jme, i);
+			kfree(rxring->bufinf);
+		}
 
 		dma_free_coherent(&(jme->pdev->dev),
 				  RX_RING_ALLOC_SIZE(jme->rx_ring_size),
@@ -731,6 +752,7 @@ jme_free_rx_resources(struct jme_adapter *jme)
 		rxring->desc     = NULL;
 		rxring->dmaalloc = 0;
 		rxring->dma      = 0;
+		rxring->bufinf   = NULL;
 	}
 	rxring->next_to_use   = 0;
 	atomic_set(&rxring->next_to_clean, 0);
@@ -746,12 +768,8 @@ jme_setup_rx_resources(struct jme_adapter *jme)
 				   RX_RING_ALLOC_SIZE(jme->rx_ring_size),
 				   &(rxring->dmaalloc),
 				   GFP_ATOMIC);
-	if (!rxring->alloc) {
-		rxring->desc = NULL;
-		rxring->dmaalloc = 0;
-		rxring->dma = 0;
-		return -ENOMEM;
-	}
+	if (!rxring->alloc)
+		goto err_set_null;
 
 	/*
 	 * 16 Bytes align
@@ -762,9 +780,16 @@ jme_setup_rx_resources(struct jme_adapter *jme)
 	rxring->next_to_use	= 0;
 	atomic_set(&rxring->next_to_clean, 0);
 
+	rxring->bufinf		= kmalloc(sizeof(struct jme_buffer_info) *
+					jme->rx_ring_size, GFP_ATOMIC);
+	if (unlikely(!(rxring->bufinf)))
+		goto err_free_rxring;
+
 	/*
 	 * Initiallize Receive Descriptors
 	 */
+	memset(rxring->bufinf, 0,
+		sizeof(struct jme_buffer_info) * jme->rx_ring_size);
 	for (i = 0 ; i < jme->rx_ring_size ; ++i) {
 		if (unlikely(jme_make_new_rx_buf(jme, i))) {
 			jme_free_rx_resources(jme);
@@ -775,6 +800,19 @@ jme_setup_rx_resources(struct jme_adapter *jme)
 	}
 
 	return 0;
+
+err_free_rxring:
+	dma_free_coherent(&(jme->pdev->dev),
+			  RX_RING_ALLOC_SIZE(jme->rx_ring_size),
+			  rxring->alloc,
+			  rxring->dmaalloc);
+err_set_null:
+	rxring->desc = NULL;
+	rxring->dmaalloc = 0;
+	rxring->dma = 0;
+	rxring->bufinf = NULL;
+
+	return -ENOMEM;
 }
 
 static inline void
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index 0025e68..9d3cedd 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -372,7 +372,6 @@ struct jme_buffer_info {
 /*
  * The structure holding buffer information and ring descriptors all together.
  */
-#define MAX_RING_DESC_NR	1024
 struct jme_ring {
 	void *alloc;		/* pointer to allocated memory */
 	void *desc;		/* pointer to ring memory  */
@@ -380,7 +379,7 @@ struct jme_ring {
 	dma_addr_t dma;		/* phys address for ring dma */
 
 	/* Buffer information corresponding to each descriptor */
-	struct jme_buffer_info bufinf[MAX_RING_DESC_NR];
+	struct jme_buffer_info *bufinf;
 
 	int next_to_use;
 	atomic_t next_to_clean;
-- 
1.6.0.6

