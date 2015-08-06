From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH 2/3] net: mvpp2: enable proper per-CPU TX buffers unmapping
Date: Thu,  6 Aug 2015 19:00:29 +0200
Message-ID: <1438880430-5480-3-git-send-email-mw@semihalf.com>
References: <y>
 <1438880430-5480-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, jason@lakedaemon.net,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com,
	ezequiel.garcia@free-electrons.com, alior@marvell.com,
	jaz@semihalf.com, Marcin Wojtas <mw@semihalf.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:33412 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754486AbbHFRAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 13:00:54 -0400
Received: by labjt7 with SMTP id jt7so35327031lab.0
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2015 10:00:52 -0700 (PDT)
In-Reply-To: <1438880430-5480-1-git-send-email-mw@semihalf.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mvpp2 driver allows usage of per-CPU TX processing. Once the packets are
prepared independetly on each CPU, the hardware enqueues the descriptors in
common TX queue. After they are sent, the buffers and associated sk_buffs
should be released on the corresponding CPU.

This is why a special index is maintained in order to point to the right data to
be released after transmission takes place. Each per-CPU TX queue comprise an
array of sent sk_buffs, freed in mvpp2_txq_bufs_free function. However, the
index was used there also for obtaining a descriptor (and therefore a buffer to
be DMA-unmapped) from common TX queue, which was wrong, because it was not
referring to the current CPU.

This commit enables proper unmapping of sent data buffers by indexing them in
per-CPU queues using a dedicated array for keeping their physical addresses.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 52 +++++++++++++++++++++++++-----------
 1 file changed, 37 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index f94bd12..3e25d314 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -776,6 +776,9 @@ struct mvpp2_txq_pcpu {
 	/* Array of transmitted skb */
 	struct sk_buff **tx_skb;
 
+	/* Array of transmitted buffers' physical addresses */
+	dma_addr_t *tx_buffs;
+
 	/* Index of last TX DMA descriptor that was inserted */
 	int txq_put_index;
 
@@ -961,9 +964,13 @@ static void mvpp2_txq_inc_get(struct mvpp2_txq_pcpu *txq_pcpu)
 }
 
 static void mvpp2_txq_inc_put(struct mvpp2_txq_pcpu *txq_pcpu,
-			      struct sk_buff *skb)
+			      struct sk_buff *skb,
+			      struct mvpp2_tx_desc *tx_desc)
 {
 	txq_pcpu->tx_skb[txq_pcpu->txq_put_index] = skb;
+	if (skb)
+		txq_pcpu->tx_buffs[txq_pcpu->txq_put_index] =
+							 tx_desc->buf_phys_addr;
 	txq_pcpu->txq_put_index++;
 	if (txq_pcpu->txq_put_index == txq_pcpu->size)
 		txq_pcpu->txq_put_index = 0;
@@ -4392,8 +4399,8 @@ static void mvpp2_txq_bufs_free(struct mvpp2_port *port,
 	int i;
 
 	for (i = 0; i < num; i++) {
-		struct mvpp2_tx_desc *tx_desc = txq->descs +
-							txq_pcpu->txq_get_index;
+		dma_addr_t buf_phys_addr =
+				    txq_pcpu->tx_buffs[txq_pcpu->txq_get_index];
 		struct sk_buff *skb = txq_pcpu->tx_skb[txq_pcpu->txq_get_index];
 
 		mvpp2_txq_inc_get(txq_pcpu);
@@ -4401,8 +4408,8 @@ static void mvpp2_txq_bufs_free(struct mvpp2_port *port,
 		if (!skb)
 			continue;
 
-		dma_unmap_single(port->dev->dev.parent, tx_desc->buf_phys_addr,
-				 tx_desc->data_size, DMA_TO_DEVICE);
+		dma_unmap_single(port->dev->dev.parent, buf_phys_addr,
+				 skb_headlen(skb), DMA_TO_DEVICE);
 		dev_kfree_skb_any(skb);
 	}
 }
@@ -4634,12 +4641,13 @@ static int mvpp2_txq_init(struct mvpp2_port *port,
 		txq_pcpu->tx_skb = kmalloc(txq_pcpu->size *
 					   sizeof(*txq_pcpu->tx_skb),
 					   GFP_KERNEL);
-		if (!txq_pcpu->tx_skb) {
-			dma_free_coherent(port->dev->dev.parent,
-					  txq->size * MVPP2_DESC_ALIGNED_SIZE,
-					  txq->descs, txq->descs_phys);
-			return -ENOMEM;
-		}
+		if (!txq_pcpu->tx_skb)
+			goto error;
+
+		txq_pcpu->tx_buffs = kmalloc(txq_pcpu->size *
+					     sizeof(dma_addr_t), GFP_KERNEL);
+		if (!txq_pcpu->tx_buffs)
+			goto error;
 
 		txq_pcpu->count = 0;
 		txq_pcpu->reserved_num = 0;
@@ -4648,6 +4656,19 @@ static int mvpp2_txq_init(struct mvpp2_port *port,
 	}
 
 	return 0;
+
+error:
+	for_each_present_cpu(cpu) {
+		txq_pcpu = per_cpu_ptr(txq->pcpu, cpu);
+		kfree(txq_pcpu->tx_skb);
+		kfree(txq_pcpu->tx_buffs);
+	}
+
+	dma_free_coherent(port->dev->dev.parent,
+			  txq->size * MVPP2_DESC_ALIGNED_SIZE,
+			  txq->descs, txq->descs_phys);
+
+	return -ENOMEM;
 }
 
 /* Free allocated TXQ resources */
@@ -4660,6 +4681,7 @@ static void mvpp2_txq_deinit(struct mvpp2_port *port,
 	for_each_present_cpu(cpu) {
 		txq_pcpu = per_cpu_ptr(txq->pcpu, cpu);
 		kfree(txq_pcpu->tx_skb);
+		kfree(txq_pcpu->tx_buffs);
 	}
 
 	if (txq->descs)
@@ -5129,11 +5151,11 @@ static int mvpp2_tx_frag_process(struct mvpp2_port *port, struct sk_buff *skb,
 		if (i == (skb_shinfo(skb)->nr_frags - 1)) {
 			/* Last descriptor */
 			tx_desc->command = MVPP2_TXD_L_DESC;
-			mvpp2_txq_inc_put(txq_pcpu, skb);
+			mvpp2_txq_inc_put(txq_pcpu, skb, tx_desc);
 		} else {
 			/* Descriptor in the middle: Not First, Not Last */
 			tx_desc->command = 0;
-			mvpp2_txq_inc_put(txq_pcpu, NULL);
+			mvpp2_txq_inc_put(txq_pcpu, NULL, tx_desc);
 		}
 	}
 
@@ -5199,12 +5221,12 @@ static int mvpp2_tx(struct sk_buff *skb, struct net_device *dev)
 		/* First and Last descriptor */
 		tx_cmd |= MVPP2_TXD_F_DESC | MVPP2_TXD_L_DESC;
 		tx_desc->command = tx_cmd;
-		mvpp2_txq_inc_put(txq_pcpu, skb);
+		mvpp2_txq_inc_put(txq_pcpu, skb, tx_desc);
 	} else {
 		/* First but not Last */
 		tx_cmd |= MVPP2_TXD_F_DESC | MVPP2_TXD_PADDING_DISABLE;
 		tx_desc->command = tx_cmd;
-		mvpp2_txq_inc_put(txq_pcpu, NULL);
+		mvpp2_txq_inc_put(txq_pcpu, NULL, tx_desc);
 
 		/* Continue with other skb fragments */
 		if (mvpp2_tx_frag_process(port, skb, aggr_txq, txq)) {
-- 
1.8.3.1
