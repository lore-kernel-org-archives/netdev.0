From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH] ehea: removing unused functionality
Date: Fri, 23 Mar 2007 17:18:53 +0100
Message-ID: <200703231718.53668.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:44948 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbXCWQ2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 12:28:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch includes:
- removal of unused fields in structs
- ethtool statistics cleanup
- removes unsed functionality from send path

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
---


This patch applies on top of the netdev upstream branch for 2.6.22


 drivers/net/ehea/ehea.h         |   25 ++-------
 drivers/net/ehea/ehea_ethtool.c |  111 ++++++++++++++--------------------------
 drivers/net/ehea/ehea_main.c    |   55 +++++++------------
 drivers/net/ehea/ehea_qmr.h     |    2
 4 files changed, 69 insertions(+), 124 deletions(-)


diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index f889933..1405d0b 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -39,7 +39,7 @@ #include <asm/abs_addr.h>
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0054"
+#define DRV_VERSION	"EHEA_0055"
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
@@ -79,7 +79,6 @@ #define EHEA_RQ2_PKT_SIZE       1522
 #define EHEA_L_PKT_SIZE         256	/* low latency */
 
 /* Send completion signaling */
-#define EHEA_SIG_IV_LONG           1
 
 /* Protection Domain Identifier */
 #define EHEA_PD_ID        0xaabcdeff
@@ -106,11 +105,7 @@ #define EHEA_BCMC_VLANID_SINGLE	0x00
 #define EHEA_CACHE_LINE          128
 
 /* Memory Regions */
-#define EHEA_MR_MAX_TX_PAGES   20
-#define EHEA_MR_TX_DATA_PN      3
 #define EHEA_MR_ACC_CTRL       0x00800000
-#define EHEA_RWQES_PER_MR_RQ2  10
-#define EHEA_RWQES_PER_MR_RQ3  10
 
 #define EHEA_WATCH_DOG_TIMEOUT 10*HZ
 
@@ -318,17 +313,12 @@ struct ehea_mr {
 /*
  * Port state information
  */
-struct port_state {
-	int poll_max_processed;
+struct port_stats {
 	int poll_receive_errors;
-	int ehea_poll;
 	int queue_stopped;
-	int min_swqe_avail;
-	u64 sqc_stop_sum;
-	int pkt_send;
-	int pkt_xmit;
-	int send_tasklet;
-	int nwqe;
+	int err_tcp_cksum;
+	int err_ip_cksum;
+	int err_frame_crc;
 };
 
 #define EHEA_IRQ_NAME_SIZE 20
@@ -347,6 +337,7 @@ struct ehea_q_skb_arr {
  * Port resources
  */
 struct ehea_port_res {
+	struct port_stats p_stats;
 	struct ehea_mr send_mr;       	/* send memory region */
 	struct ehea_mr recv_mr;       	/* receive memory region */
 	spinlock_t xmit_lock;
@@ -358,7 +349,6 @@ struct ehea_port_res {
 	struct ehea_cq *recv_cq;
 	struct ehea_eq *eq;
 	struct net_device *d_netdev;
-	spinlock_t send_lock;
 	struct ehea_q_skb_arr rq1_skba;
 	struct ehea_q_skb_arr rq2_skba;
 	struct ehea_q_skb_arr rq3_skba;
@@ -368,11 +358,8 @@ struct ehea_port_res {
 	int swqe_refill_th;
 	atomic_t swqe_avail;
 	int swqe_ll_count;
-	int swqe_count;
 	u32 swqe_id_counter;
 	u64 tx_packets;
-	spinlock_t recv_lock;
-	struct port_state p_state;
 	u64 rx_packets;
 	u32 poll_counter;
 };
diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_ethtool.c
index 9f57c2e..170aff3 100644
--- a/drivers/net/ehea/ehea_ethtool.c
+++ b/drivers/net/ehea/ehea_ethtool.c
@@ -166,33 +166,23 @@ static u32 ehea_get_rx_csum(struct net_d
 }
 
 static char ehea_ethtool_stats_keys[][ETH_GSTRING_LEN] = {
-	{"poll_max_processed"},
-	{"queue_stopped"},
-	{"min_swqe_avail"},
-	{"poll_receive_err"},
-	{"pkt_send"},
-	{"pkt_xmit"},
-	{"send_tasklet"},
-	{"ehea_poll"},
-	{"nwqe"},
-	{"swqe_available_0"},
 	{"sig_comp_iv"},
 	{"swqe_refill_th"},
 	{"port resets"},
-	{"rxo"},
-	{"rx64"},
-	{"rx65"},
-	{"rx128"},
-	{"rx256"},
-	{"rx512"},
-	{"rx1024"},
-	{"txo"},
-	{"tx64"},
-	{"tx65"},
-	{"tx128"},
-	{"tx256"},
-	{"tx512"},
-	{"tx1024"},
+	{"Receive errors"},
+	{"TCP cksum errors"},
+	{"IP cksum errors"},
+	{"Frame cksum errors"},
+	{"num SQ stopped"},
+	{"SQ stopped"},
+	{"PR0 free_swqes"},
+	{"PR1 free_swqes"},
+	{"PR2 free_swqes"},
+	{"PR3 free_swqes"},
+	{"PR4 free_swqes"},
+	{"PR5 free_swqes"},
+	{"PR6 free_swqes"},
+	{"PR7 free_swqes"},
 };
 
 static void ehea_get_strings(struct net_device *dev, u32 stringset, u8 *data)
@@ -211,63 +201,44 @@ static int ehea_get_stats_count(struct n
 static void ehea_get_ethtool_stats(struct net_device *dev,
 				     struct ethtool_stats *stats, u64 *data)
 {
-	u64 hret;
-	int i;
+	int i, k, tmp;
 	struct ehea_port *port = netdev_priv(dev);
-	struct ehea_adapter *adapter = port->adapter;
-	struct ehea_port_res *pr = &port->port_res[0];
-	struct port_state *p_state = &pr->p_state;
-	struct hcp_ehea_port_cb6 *cb6;
 
 	for (i = 0; i < ehea_get_stats_count(dev); i++)
 		data[i] = 0;
-
 	i = 0;
 
-	data[i++] = p_state->poll_max_processed;
-	data[i++] = p_state->queue_stopped;
-	data[i++] = p_state->min_swqe_avail;
-	data[i++] = p_state->poll_receive_errors;
-	data[i++] = p_state->pkt_send;
-	data[i++] = p_state->pkt_xmit;
-	data[i++] = p_state->send_tasklet;
-	data[i++] = p_state->ehea_poll;
-	data[i++] = p_state->nwqe;
-	data[i++] = atomic_read(&port->port_res[0].swqe_avail);
 	data[i++] = port->sig_comp_iv;
 	data[i++] = port->port_res[0].swqe_refill_th;
 	data[i++] = port->resets;
 
-	cb6 = kzalloc(PAGE_SIZE, GFP_KERNEL);
-	if (!cb6) {
-		ehea_error("no mem for cb6");
-		return;
-	}
+	for (k = 0, tmp = 0; k < EHEA_MAX_PORT_RES; k++)
+		tmp += port->port_res[k].p_stats.poll_receive_errors;
+	data[i++] = tmp;
+
+	for (k = 0, tmp = 0; k < EHEA_MAX_PORT_RES; k++)
+		tmp += port->port_res[k].p_stats.err_tcp_cksum;
+	data[i++] = tmp;
+
+	for (k = 0, tmp = 0; k < EHEA_MAX_PORT_RES; k++)
+		tmp += port->port_res[k].p_stats.err_ip_cksum;
+	data[i++] = tmp;
+
+	for (k = 0, tmp = 0; k < EHEA_MAX_PORT_RES; k++)
+		tmp += port->port_res[k].p_stats.err_frame_crc;
+	data[i++] = tmp;
+
+	for (k = 0, tmp = 0; k < EHEA_MAX_PORT_RES; k++)
+		tmp += port->port_res[k].p_stats.queue_stopped;
+	data[i++] = tmp;
+
+	for (k = 0, tmp = 0; k < EHEA_MAX_PORT_RES; k++)
+		tmp |= port->port_res[k].queue_stopped;
+	data[i++] = tmp;
+
+	for (k = 0; k < 8; k++)
+		data[i++] = atomic_read(&port->port_res[k].swqe_avail);
 
-	hret = ehea_h_query_ehea_port(adapter->handle, port->logical_port_id,
-				      H_PORT_CB6, H_PORT_CB6_ALL, cb6);
-	if (netif_msg_hw(port))
-		ehea_dump(cb6, sizeof(*cb6), "ehea_get_ethtool_stats");
-
-	if (hret == H_SUCCESS) {
-		data[i++] = cb6->rxo;
-		data[i++] = cb6->rx64;
-		data[i++] = cb6->rx65;
-		data[i++] = cb6->rx128;
-		data[i++] = cb6->rx256;
-		data[i++] = cb6->rx512;
-		data[i++] = cb6->rx1024;
-		data[i++] = cb6->txo;
-		data[i++] = cb6->tx64;
-		data[i++] = cb6->tx65;
-		data[i++] = cb6->tx128;
-		data[i++] = cb6->tx256;
-		data[i++] = cb6->tx512;
-		data[i++] = cb6->tx1024;
-	} else
-		ehea_error("query_ehea_port failed");
-
-	kfree(cb6);
 }
 
 const struct ethtool_ops ehea_ethtool_ops = {
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 546e50c..a36a023 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -327,6 +327,13 @@ static int ehea_treat_poll_error(struct 
 {
 	struct sk_buff *skb;
 
+	if (cqe->status & EHEA_CQE_STAT_ERR_TCP)
+		pr->p_stats.err_tcp_cksum++;
+	if (cqe->status & EHEA_CQE_STAT_ERR_IP)
+		pr->p_stats.err_ip_cksum++;
+	if (cqe->status & EHEA_CQE_STAT_ERR_CRC)
+		pr->p_stats.err_frame_crc++;
+
 	if (netif_msg_rx_err(pr->port)) {
 		ehea_error("CQE Error for QP %d", pr->qp->init_attr.qp_nr);
 		ehea_dump(cqe, sizeof(*cqe), "CQE");
@@ -428,7 +435,7 @@ static struct ehea_cqe *ehea_proc_rwqes(
 			else
 				netif_receive_skb(skb);
 		} else {
-			pr->p_state.poll_receive_errors++;
+			pr->p_stats.poll_receive_errors++;
 			port_reset = ehea_treat_poll_error(pr, rq, cqe,
 							   &processed_rq2,
 							   &processed_rq3);
@@ -449,34 +456,15 @@ static struct ehea_cqe *ehea_proc_rwqes(
 	return cqe;
 }
 
-static void ehea_free_sent_skbs(struct ehea_cqe *cqe, struct ehea_port_res *pr)
-{
-	struct sk_buff *skb;
-	int index, max_index_mask, i;
-
-	index = EHEA_BMASK_GET(EHEA_WR_ID_INDEX, cqe->wr_id);
-	max_index_mask = pr->sq_skba.len - 1;
-	for (i = 0; i < EHEA_BMASK_GET(EHEA_WR_ID_REFILL, cqe->wr_id); i++) {
-		skb = pr->sq_skba.arr[index];
-		if (likely(skb)) {
-			dev_kfree_skb(skb);
-			pr->sq_skba.arr[index] = NULL;
-		} else {
-			ehea_error("skb=NULL, wr_id=%lX, loop=%d, index=%d",
-				   cqe->wr_id, i, index);
-		}
-		index--;
-		index &= max_index_mask;
-	}
-}
-
 static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 {
+	struct sk_buff *skb;
 	struct ehea_cq *send_cq = pr->send_cq;
 	struct ehea_cqe *cqe;
 	int quota = my_quota;
 	int cqe_counter = 0;
 	int swqe_av = 0;
+	int index;
 	unsigned long flags;
 
 	cqe = ehea_poll_cq(send_cq);
@@ -498,8 +486,13 @@ static struct ehea_cqe *ehea_proc_cqes(s
 			ehea_dump(cqe, sizeof(*cqe), "CQE");
 
 		if (likely(EHEA_BMASK_GET(EHEA_WR_ID_TYPE, cqe->wr_id)
-			   == EHEA_SWQE2_TYPE))
-			ehea_free_sent_skbs(cqe, pr);
+			   == EHEA_SWQE2_TYPE)) {
+
+			index = EHEA_BMASK_GET(EHEA_WR_ID_INDEX, cqe->wr_id);
+			skb = pr->sq_skba.arr[index];
+			dev_kfree_skb(skb);
+			pr->sq_skba.arr[index] = NULL;
+		}
 
 		swqe_av += EHEA_BMASK_GET(EHEA_WR_ID_REFILL, cqe->wr_id);
 		quota--;
@@ -1092,8 +1085,6 @@ static int ehea_init_port_res(struct ehe
 	memset(pr, 0, sizeof(struct ehea_port_res));
 
 	pr->port = port;
-	spin_lock_init(&pr->send_lock);
-	spin_lock_init(&pr->recv_lock);
 	spin_lock_init(&pr->xmit_lock);
 	spin_lock_init(&pr->netif_queue);
 
@@ -1808,7 +1799,6 @@ static int ehea_start_xmit(struct sk_buf
 
 	pr = &port->port_res[ehea_hash_skb(skb, port->num_tx_qps)];
 
-
 	if (!spin_trylock(&pr->xmit_lock))
 		return NETDEV_TX_BUSY;
 
@@ -1838,6 +1828,7 @@ static int ehea_start_xmit(struct sk_buf
 		swqe->wr_id =
 			EHEA_BMASK_SET(EHEA_WR_ID_TYPE, EHEA_SWQE2_TYPE)
 		      | EHEA_BMASK_SET(EHEA_WR_ID_COUNT, pr->swqe_id_counter)
+		      | EHEA_BMASK_SET(EHEA_WR_ID_REFILL, 1)
 		      | EHEA_BMASK_SET(EHEA_WR_ID_INDEX, pr->sq_skba.index);
 		pr->sq_skba.arr[pr->sq_skba.index] = skb;
 
@@ -1846,14 +1837,7 @@ static int ehea_start_xmit(struct sk_buf
 
 		lkey = pr->send_mr.lkey;
 		ehea_xmit2(skb, dev, swqe, lkey);
-
-		if (pr->swqe_count >= (EHEA_SIG_IV_LONG - 1)) {
-			swqe->wr_id |= EHEA_BMASK_SET(EHEA_WR_ID_REFILL,
-						      EHEA_SIG_IV_LONG);
-			swqe->tx_control |= EHEA_SWQE_SIGNALLED_COMPLETION;
-			pr->swqe_count = 0;
-		} else
-			pr->swqe_count += 1;
+		swqe->tx_control |= EHEA_SWQE_SIGNALLED_COMPLETION;
 	}
 	pr->swqe_id_counter += 1;
 
@@ -1873,6 +1857,7 @@ static int ehea_start_xmit(struct sk_buf
 	if (unlikely(atomic_read(&pr->swqe_avail) <= 1)) {
 		spin_lock_irqsave(&pr->netif_queue, flags);
 		if (unlikely(atomic_read(&pr->swqe_avail) <= 1)) {
+			pr->p_stats.queue_stopped++;
 			netif_stop_queue(dev);
 			pr->queue_stopped = 1;
 		}
diff --git a/drivers/net/ehea/ehea_qmr.h b/drivers/net/ehea/ehea_qmr.h
index 2460331..c0eb3e0 100644
--- a/drivers/net/ehea/ehea_qmr.h
+++ b/drivers/net/ehea/ehea_qmr.h
@@ -142,6 +142,8 @@ #define EHEA_CQE_TYPE_RQ           0x60
 #define EHEA_CQE_STAT_ERR_MASK     0x721F
 #define EHEA_CQE_STAT_FAT_ERR_MASK 0x1F
 #define EHEA_CQE_STAT_ERR_TCP      0x4000
+#define EHEA_CQE_STAT_ERR_IP       0x2000
+#define EHEA_CQE_STAT_ERR_CRC      0x1000
 
 struct ehea_cqe {
 	u64 wr_id;		/* work request ID from WQE */
