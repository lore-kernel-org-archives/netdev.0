From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: [PATCH v2] ehea: Fixing statistics
Date: Wed, 27 Oct 2010 14:45:14 -0400
Message-ID: <1288205114-852-1-git-send-email-leitao@linux.vnet.ibm.com>
References: <20101027.113940.242117937.davem@davemloft.net>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Breno Leitao <leitao@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:59491 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231Ab0J0SqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:46:17 -0400
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id o9RItSl6004353
	for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 16:55:28 -0200
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9RIqIRs1351898
	for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 16:52:25 -0200
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9RIjmCP027678
	for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 16:45:48 -0200
In-Reply-To: <20101027.113940.242117937.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Applied over Eric's "ehea: fix use after free" patch)

Currently ehea stats are broken. The bytes counters are got from
the hardware, while the packets counters are got from the device
driver. Also, the device driver counters are resetted during the
the down process, and the hardware aren't, causing some weird
numbers.

This patch just consolidates the packets and bytes on the device
driver.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/ehea/ehea.h      |    2 ++
 drivers/net/ehea/ehea_main.c |   32 ++++++++++++++++++++++++++------
 2 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 1321cb6..8e745e7 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -396,7 +396,9 @@ struct ehea_port_res {
 	int swqe_ll_count;
 	u32 swqe_id_counter;
 	u64 tx_packets;
+	u64 tx_bytes;
 	u64 rx_packets;
+	u64 rx_bytes;
 	u32 poll_counter;
 	struct net_lro_mgr lro_mgr;
 	struct net_lro_desc lro_desc[MAX_LRO_DESCRIPTORS];
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index e59d386..182b2a7 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -330,7 +330,7 @@ static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 	struct ehea_port *port = netdev_priv(dev);
 	struct net_device_stats *stats = &port->stats;
 	struct hcp_ehea_port_cb2 *cb2;
-	u64 hret, rx_packets, tx_packets;
+	u64 hret, rx_packets, tx_packets, rx_bytes = 0, tx_bytes = 0;
 	int i;
 
 	memset(stats, 0, sizeof(*stats));
@@ -353,18 +353,22 @@ static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 		ehea_dump(cb2, sizeof(*cb2), "net_device_stats");
 
 	rx_packets = 0;
-	for (i = 0; i < port->num_def_qps; i++)
+	for (i = 0; i < port->num_def_qps; i++) {
 		rx_packets += port->port_res[i].rx_packets;
+		rx_bytes   += port->port_res[i].rx_bytes;
+	}
 
 	tx_packets = 0;
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
+	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
 		tx_packets += port->port_res[i].tx_packets;
+		tx_bytes   += port->port_res[i].tx_bytes;
+	}
 
 	stats->tx_packets = tx_packets;
 	stats->multicast = cb2->rxmcp;
 	stats->rx_errors = cb2->rxuerr;
-	stats->rx_bytes = cb2->rxo;
-	stats->tx_bytes = cb2->txo;
+	stats->rx_bytes = rx_bytes;
+	stats->tx_bytes = tx_bytes;
 	stats->rx_packets = rx_packets;
 
 out_herr:
@@ -703,6 +707,7 @@ static int ehea_proc_rwqes(struct net_device *dev,
 	int skb_arr_rq2_len = pr->rq2_skba.len;
 	int skb_arr_rq3_len = pr->rq3_skba.len;
 	int processed, processed_rq1, processed_rq2, processed_rq3;
+	u64 processed_bytes = 0;
 	int wqe_index, last_wqe_index, rq, port_reset;
 
 	processed = processed_rq1 = processed_rq2 = processed_rq3 = 0;
@@ -760,6 +765,7 @@ static int ehea_proc_rwqes(struct net_device *dev,
 				processed_rq3++;
 			}
 
+			processed_bytes += skb->len;
 			ehea_proc_skb(pr, cqe, skb);
 		} else {
 			pr->p_stats.poll_receive_errors++;
@@ -775,6 +781,7 @@ static int ehea_proc_rwqes(struct net_device *dev,
 		lro_flush_all(&pr->lro_mgr);
 
 	pr->rx_packets += processed;
+	pr->rx_bytes += processed_bytes;
 
 	ehea_refill_rq1(pr, last_wqe_index, processed_rq1);
 	ehea_refill_rq2(pr, processed_rq2);
@@ -1509,9 +1516,20 @@ static int ehea_init_port_res(struct ehea_port *port, struct ehea_port_res *pr,
 	enum ehea_eq_type eq_type = EHEA_EQ;
 	struct ehea_qp_init_attr *init_attr = NULL;
 	int ret = -EIO;
+	u64 tx_bytes, rx_bytes, tx_packets, rx_packets;
+
+	tx_bytes = pr->tx_bytes;
+	tx_packets = pr->tx_packets;
+	rx_bytes = pr->rx_bytes;
+	rx_packets = pr->rx_packets;
 
 	memset(pr, 0, sizeof(struct ehea_port_res));
 
+	pr->tx_bytes = rx_bytes;
+	pr->tx_packets = tx_packets;
+	pr->rx_bytes = rx_bytes;
+	pr->rx_packets = rx_packets;
+
 	pr->port = port;
 	spin_lock_init(&pr->xmit_lock);
 	spin_lock_init(&pr->netif_queue);
@@ -2254,6 +2272,9 @@ static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		swqe->vlan_tag = vlan_tx_tag_get(skb);
 	}
 
+	pr->tx_packets++;
+	pr->tx_bytes += skb->len;
+
 	if (skb->len <= SWQE3_MAX_IMM) {
 		u32 sig_iv = port->sig_comp_iv;
 		u32 swqe_num = pr->swqe_id_counter;
@@ -2295,7 +2316,6 @@ static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	ehea_post_swqe(pr->qp, swqe);
-	pr->tx_packets++;
 
 	if (unlikely(atomic_read(&pr->swqe_avail) <= 1)) {
 		spin_lock_irqsave(&pr->netif_queue, flags);
-- 
1.7.1

