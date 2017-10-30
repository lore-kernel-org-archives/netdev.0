From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 4/6] net: mvpp2: limit TSO segments and use stop/wake thresholds
Date: Mon, 30 Oct 2017 11:23:31 +0100
Message-ID: <20171030102333.30781-5-antoine.tenart@free-electrons.com>
References: <20171030102333.30781-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:55542 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752147AbdJ3KZO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 06:25:14 -0400
In-Reply-To: <20171030102333.30781-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Too many TSO descriptors can be required for the default queue size,
when using small MSS values for example. Prevent this by adding a
maximum number of allowed TSO segments (300). In addition set a stop and
a wake thresholds to stop the queue when there's no room for a 1 "worst
case scenario skb". Wake up the queue when the number of descriptors is
low enough.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 1f7d4ea60da0..8dc6bfbd5d0a 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -493,6 +493,13 @@
 /* Maximum number of TXQs used by single port */
 #define MVPP2_MAX_TXQ			8
 
+/* MVPP2_MAX_TSO_SEGS is the maximum number of fragments to allow in the GSO
+ * skb. As we need a maxium of two descriptors per fragments (1 header, 1 data),
+ * multiply this value by two to count the maximum number of skb descs needed.
+ */
+#define MVPP2_MAX_TSO_SEGS		300
+#define MVPP2_MAX_SKB_DESCS		(MVPP2_MAX_TSO_SEGS * 2 + MAX_SKB_FRAGS)
+
 /* Dfault number of RXQs in use */
 #define MVPP2_DEFAULT_RXQ		4
 
@@ -1045,6 +1052,9 @@ struct mvpp2_txq_pcpu {
 	 */
 	int count;
 
+	int wake_threshold;
+	int stop_threshold;
+
 	/* Number of Tx DMA descriptors reserved for each CPU */
 	int reserved_num;
 
@@ -5393,7 +5403,7 @@ static void mvpp2_txq_done(struct mvpp2_port *port, struct mvpp2_tx_queue *txq,
 	txq_pcpu->count -= tx_done;
 
 	if (netif_tx_queue_stopped(nq))
-		if (txq_pcpu->size - txq_pcpu->count >= MAX_SKB_FRAGS + 1)
+		if (txq_pcpu->count <= txq_pcpu->wake_threshold)
 			netif_tx_wake_queue(nq);
 }
 
@@ -5636,6 +5646,9 @@ static int mvpp2_txq_init(struct mvpp2_port *port,
 		txq_pcpu->txq_put_index = 0;
 		txq_pcpu->txq_get_index = 0;
 
+		txq_pcpu->stop_threshold = txq->size - MVPP2_MAX_SKB_DESCS;
+		txq_pcpu->wake_threshold = txq_pcpu->stop_threshold / 2;
+
 		txq_pcpu->tso_headers =
 			dma_alloc_coherent(port->dev->dev.parent,
 					   txq_pcpu->size * TSO_HEADER_SIZE,
@@ -6508,7 +6521,7 @@ static int mvpp2_tx(struct sk_buff *skb, struct net_device *dev)
 		wmb();
 		mvpp2_aggr_txq_pend_desc_add(port, frags);
 
-		if (txq_pcpu->size - txq_pcpu->count < MAX_SKB_FRAGS + 1)
+		if (txq_pcpu->count >= txq_pcpu->stop_threshold)
 			netif_tx_stop_queue(nq);
 
 		u64_stats_update_begin(&stats->syncp);
@@ -7732,6 +7745,7 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 	dev->features = features | NETIF_F_RXCSUM;
 	dev->hw_features |= features | NETIF_F_RXCSUM | NETIF_F_GRO;
 	dev->vlan_features |= features;
+	dev->gso_max_segs = MVPP2_MAX_TSO_SEGS;
 
 	/* MTU range: 68 - 9676 */
 	dev->min_mtu = ETH_MIN_MTU;
-- 
2.14.3
