From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH v2 net-next 2/2] net: mvneta: add BQL support
Date: Mon, 16 Jan 2017 18:08:32 +0100
Message-ID: <1484586512-16412-3-git-send-email-mw@semihalf.com>
References: <1484586512-16412-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
        sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
        jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
        gregory.clement@free-electrons.com, mw@semihalf.com,
        jaz@semihalf.com
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484586512-16412-1-git-send-email-mw@semihalf.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tests showed that when whole bandwidth is consumed, the latency for
various kind of traffic can reach high values. With saturated
link (e.g. with iperf from target to host) simple ping could take
significant amount of time. BQL proved to improve this situation
when implemented in mvneta driver. Measurements of ping latency
for 3 link speeds:
Speed | Latency w/o BQL | Latency with BQL
10    |      7-14 ms    |     3.5 ms
100   |      2-12 ms    |     0.6 ms
1000  |   often timeout |   up to 2ms

Decreasing latency as above result in sligt performance cost - 4kpps
(-1.4%) when pushing 64B packets via two bridged interfaces of Armada 38x.
For 1500B packets in the same setup, the mpstat tool showed +8% of
CPU occupation (default affinity, second CPU idle). Even though this
cost seems reasonable to take, considering other improvements.

This commit adds byte queue limit mechanism for the mvneta driver.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 9624537..6dcc951 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1759,8 +1759,10 @@ static struct mvneta_tx_queue *mvneta_tx_done_policy(struct mvneta_port *pp,
 
 /* Free tx queue skbuffs */
 static void mvneta_txq_bufs_free(struct mvneta_port *pp,
-				 struct mvneta_tx_queue *txq, int num)
+				 struct mvneta_tx_queue *txq, int num,
+				 struct netdev_queue *nq)
 {
+	unsigned int bytes_compl = 0, pkts_compl = 0;
 	int i;
 
 	for (i = 0; i < num; i++) {
@@ -1768,6 +1770,11 @@ static void mvneta_txq_bufs_free(struct mvneta_port *pp,
 			txq->txq_get_index;
 		struct sk_buff *skb = txq->tx_skb[txq->txq_get_index];
 
+		if (skb) {
+			bytes_compl += skb->len;
+			pkts_compl++;
+		}
+
 		mvneta_txq_inc_get(txq);
 
 		if (!IS_TSO_HEADER(txq, tx_desc->buf_phys_addr))
@@ -1778,6 +1785,8 @@ static void mvneta_txq_bufs_free(struct mvneta_port *pp,
 			continue;
 		dev_kfree_skb_any(skb);
 	}
+
+	netdev_tx_completed_queue(nq, pkts_compl, bytes_compl);
 }
 
 /* Handle end of transmission */
@@ -1791,7 +1800,7 @@ static void mvneta_txq_done(struct mvneta_port *pp,
 	if (!tx_done)
 		return;
 
-	mvneta_txq_bufs_free(pp, txq, tx_done);
+	mvneta_txq_bufs_free(pp, txq, tx_done, nq);
 
 	txq->count -= tx_done;
 
@@ -2401,6 +2410,8 @@ static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
 		struct mvneta_pcpu_stats *stats = this_cpu_ptr(pp->stats);
 		struct netdev_queue *nq = netdev_get_tx_queue(dev, txq_id);
 
+		netdev_tx_sent_queue(nq, len);
+
 		txq->count += frags;
 		if (txq->count >= txq->tx_stop_threshold)
 			netif_tx_stop_queue(nq);
@@ -2429,9 +2440,10 @@ static void mvneta_txq_done_force(struct mvneta_port *pp,
 				  struct mvneta_tx_queue *txq)
 
 {
+	struct netdev_queue *nq = netdev_get_tx_queue(pp->dev, txq->id);
 	int tx_done = txq->count;
 
-	mvneta_txq_bufs_free(pp, txq, tx_done);
+	mvneta_txq_bufs_free(pp, txq, tx_done, nq);
 
 	/* reset txq */
 	txq->count = 0;
@@ -2957,6 +2969,8 @@ static int mvneta_txq_init(struct mvneta_port *pp,
 static void mvneta_txq_deinit(struct mvneta_port *pp,
 			      struct mvneta_tx_queue *txq)
 {
+	struct netdev_queue *nq = netdev_get_tx_queue(pp->dev, txq->id);
+
 	kfree(txq->tx_skb);
 
 	if (txq->tso_hdrs)
@@ -2968,6 +2982,8 @@ static void mvneta_txq_deinit(struct mvneta_port *pp,
 				  txq->size * MVNETA_DESC_ALIGNED_SIZE,
 				  txq->descs, txq->descs_phys);
 
+	netdev_tx_reset_queue(nq);
+
 	txq->descs             = NULL;
 	txq->last_desc         = 0;
 	txq->next_desc_to_proc = 0;
-- 
1.8.3.1
