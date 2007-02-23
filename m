From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH] ehea: Optional TX/RX path optimized for SMP
Date: Fri, 23 Feb 2007 17:30:58 +0100
Message-ID: <200702231730.58579.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:38029 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933127AbXBWQg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Feb 2007 11:36:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

This patch introduces an optional alternative receive processing
functionality (enabled via module load parameter). The ehea adapter
can sort TCP traffic to multiple receive queues to be processed by
the driver in parallel on multiple CPUs. The hardware always puts
packets for an individual tcp stream on the same queue. As the
current NAPI interface does not allow to handle parallel receive
threads for a single adapter (processing on multiple CPUs in parallel)
this patch uses tasklets with a simple fairness algorithm instead. 
On the send side we also take advantage of ehea's multiple send queue
capabilites. A simple hash function in combination with the LL_TX
attribute allows to process tx-packets on multiple CPUs on different
queues. The hash function is needed to guarantee proper TCP packet
ordering. This alternative packet processing functionality leads to 
significant performance improvements with ehea. 

Are there any concerns about this approach?

Regards,
Jan-Bernd

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
---



diff -Nurp -X dontdiff linux-2.6.21-rc1/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.21-rc1/drivers/net/ehea/ehea.h	2007-02-23 15:40:42.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea.h	2007-02-23 16:17:37.000000000 +0100
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0048"
+#define DRV_VERSION	"EHEA_0049"
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
@@ -375,8 +375,12 @@ struct ehea_port_res {
 	struct tasklet_struct send_comp_task;
 	spinlock_t recv_lock;
 	struct port_state p_state;
+	struct tasklet_struct recv_task;
 	u64 rx_packets;
 	u32 poll_counter;
+	u32 spoll_counter;
+	u32 rtcount;
+	u32 stcount;
 };
 
 
@@ -416,7 +420,9 @@ struct ehea_port {
 	char int_aff_name[EHEA_IRQ_NAME_SIZE];
 	int allmulti;			 /* Indicates IFF_ALLMULTI state */
 	int promisc;		 	 /* Indicates IFF_PROMISC state */
+	int num_tx_qps;
 	int num_add_tx_qps;
+	int num_mcs;
 	int resets;
 	u64 mac_addr;
 	u32 logical_port_id;
diff -Nurp -X dontdiff linux-2.6.21-rc1/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.21-rc1/drivers/net/ehea/ehea_main.c	2007-02-23 15:40:42.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2007-02-23 16:17:42.000000000 +0100
@@ -51,12 +51,14 @@ static int rq1_entries = EHEA_DEF_ENTRIE
 static int rq2_entries = EHEA_DEF_ENTRIES_RQ2;
 static int rq3_entries = EHEA_DEF_ENTRIES_RQ3;
 static int sq_entries = EHEA_DEF_ENTRIES_SQ;
+static int use_mcs = 0;
 
 module_param(msg_level, int, 0);
 module_param(rq1_entries, int, 0);
 module_param(rq2_entries, int, 0);
 module_param(rq3_entries, int, 0);
 module_param(sq_entries, int, 0);
+module_param(use_mcs, int, 0);
 
 MODULE_PARM_DESC(msg_level, "msg_level");
 MODULE_PARM_DESC(rq3_entries, "Number of entries for Receive Queue 3 "
@@ -71,6 +73,8 @@ MODULE_PARM_DESC(rq1_entries, "Number of
 MODULE_PARM_DESC(sq_entries, " Number of entries for the Send Queue  "
 		 "[2^x - 1], x = [6..14]. Default = "
 		 __MODULE_STRING(EHEA_DEF_ENTRIES_SQ) ")");
+MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:MCS, Default = 0 ");
+
 
 void ehea_dump(void *adr, int len, char *msg) {
 	int x;
@@ -345,10 +349,12 @@ static int ehea_treat_poll_error(struct 
 	return 0;
 }
 
-static int ehea_poll(struct net_device *dev, int *budget)
+static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
+					struct ehea_port_res *pr,
+					int max_packets,
+					int *packet_cnt)
 {
-	struct ehea_port *port = netdev_priv(dev);
-	struct ehea_port_res *pr = &port->port_res[0];
+	struct ehea_port *port = pr->port;
 	struct ehea_qp *qp = pr->qp;
 	struct ehea_cqe *cqe;
 	struct sk_buff *skb;
@@ -359,14 +365,12 @@ static int ehea_poll(struct net_device *
 	int skb_arr_rq2_len = pr->rq2_skba.len;
 	int skb_arr_rq3_len = pr->rq3_skba.len;
 	int processed, processed_rq1, processed_rq2, processed_rq3;
-	int wqe_index, last_wqe_index, rq, intreq, my_quota, port_reset;
+	int wqe_index, last_wqe_index, rq, my_quota, port_reset;
 
 	processed = processed_rq1 = processed_rq2 = processed_rq3 = 0;
 	last_wqe_index = 0;
-	my_quota = min(*budget, dev->quota);
-	my_quota = min(my_quota, EHEA_POLL_MAX_RWQE);
+	my_quota = max_packets;
 
-	/* rq0 is low latency RQ */
 	cqe = ehea_poll_rq1(qp, &wqe_index);
 	while ((my_quota > 0) && cqe) {
 		ehea_inc_rq1(qp);
@@ -386,6 +390,7 @@ static int ehea_poll(struct net_device *
 				if (unlikely(!skb)) {
 					if (netif_msg_rx_err(port))
 						ehea_error("LL rq1: skb=NULL");
+
 					skb = netdev_alloc_skb(dev,
 							       EHEA_L_PKT_SIZE);
 					if (!skb)
@@ -421,8 +426,7 @@ static int ehea_poll(struct net_device *
 							 cqe->vlan_tag);
 			else
 				netif_receive_skb(skb);
-
-		} else { /* Error occured */
+		} else {
 			pr->p_state.poll_receive_errors++;
 			port_reset = ehea_treat_poll_error(pr, rq, cqe,
 							   &processed_rq2,
@@ -433,24 +437,83 @@ static int ehea_poll(struct net_device *
 		cqe = ehea_poll_rq1(qp, &wqe_index);
 	}
 
-	dev->quota -= processed;
-	*budget -= processed;
-
-	pr->p_state.ehea_poll += 1;
 	pr->rx_packets += processed;
+	*packet_cnt = processed;
 
 	ehea_refill_rq1(pr, last_wqe_index, processed_rq1);
 	ehea_refill_rq2(pr, processed_rq2);
 	ehea_refill_rq3(pr, processed_rq3);
 
-	intreq = ((pr->p_state.ehea_poll & 0xF) == 0xF);
+	cqe = ehea_poll_rq1(qp, &wqe_index);
+	return cqe;
+}
+
+#define EHEA_POLL_TASK_QUOTA 300
+#define EHEA_POLL_NUM_BEFORE_IRQ 4
 
-	if (!cqe || intreq) {
+void ehea_poll_task(unsigned long data)
+{
+	struct ehea_port_res *pr = (struct ehea_port_res*)data;
+	struct net_device *dev = pr->port->netdev;
+	struct ehea_cqe *cqe;
+	int packet_cnt, force_irq, wqe_index;
+
+	pr->rtcount++;
+	cqe = ehea_poll_rq1(pr->qp, &wqe_index);
+	if (!cqe) {
+		ehea_reset_cq_ep(pr->recv_cq);
+		ehea_reset_cq_n1(pr->recv_cq);
+		ehea_proc_rwqes(dev, pr, EHEA_POLL_TASK_QUOTA, &packet_cnt);
+		pr->poll_counter = 0;
+		return;
+	}
+
+	force_irq = (pr->poll_counter > EHEA_POLL_NUM_BEFORE_IRQ);
+	if (force_irq) {
+		pr->poll_counter = 0;
+		ehea_reset_cq_ep(pr->recv_cq);
+		ehea_reset_cq_n1(pr->recv_cq);
+	}
+
+	cqe = ehea_proc_rwqes(dev, pr, EHEA_POLL_TASK_QUOTA, &packet_cnt);
+
+	if (cqe)
+		pr->poll_counter++;
+	else
+		pr->poll_counter = 0;
+
+	if (pr->rtcount % 2)
+		tasklet_schedule(&pr->recv_task);
+	else
+		tasklet_hi_schedule(&pr->recv_task);
+}
+
+#define EHEA_NAPI_POLL_NUM_BEFORE_IRQ 16
+
+static int ehea_poll(struct net_device *dev, int *budget)
+{
+	struct ehea_port *port = netdev_priv(dev);
+	struct ehea_port_res *pr = &port->port_res[0];
+	struct ehea_cqe *cqe;
+	int packet_cnt, my_quota, force_irq, wqe_index;
+
+	my_quota = min(*budget, dev->quota);
+	my_quota = min(my_quota, EHEA_POLL_MAX_RWQE);
+
+	cqe = ehea_proc_rwqes(dev, pr, my_quota, &packet_cnt);
+	pr->poll_counter++;
+	*budget -= packet_cnt;
+
+	force_irq = (pr->poll_counter > EHEA_NAPI_POLL_NUM_BEFORE_IRQ);
+
+	if (!cqe || force_irq) {
+		pr->poll_counter = 0;
 		netif_rx_complete(dev);
 		ehea_reset_cq_ep(pr->recv_cq);
 		ehea_reset_cq_n1(pr->recv_cq);
-		cqe = hw_qeit_get_valid(&qp->hw_rqueue1);
-		if (!cqe || intreq)
+		cqe = ehea_poll_rq1(pr->qp, &wqe_index);
+
+		if (!cqe || force_irq)
 			return 0;
 		if (!netif_rx_reschedule(dev, my_quota))
 			return 0;
@@ -458,7 +521,7 @@ static int ehea_poll(struct net_device *
 	return 1;
 }
 
-void free_sent_skbs(struct ehea_cqe *cqe, struct ehea_port_res *pr)
+static void ehea_free_sent_skbs(struct ehea_cqe *cqe, struct ehea_port_res *pr)
 {
 	struct sk_buff *skb;
 	int index, max_index_mask, i;
@@ -479,26 +542,19 @@ void free_sent_skbs(struct ehea_cqe *cqe
 	}
 }
 
-#define MAX_SENDCOMP_QUOTA 400
-void ehea_send_irq_tasklet(unsigned long data)
+static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 {
-	struct ehea_port_res *pr = (struct ehea_port_res*)data;
 	struct ehea_cq *send_cq = pr->send_cq;
 	struct ehea_cqe *cqe;
-	int quota = MAX_SENDCOMP_QUOTA;
+	int quota = my_quota;
 	int cqe_counter = 0;
 	int swqe_av = 0;
 	unsigned long flags;
 
-	do {
-		cqe = ehea_poll_cq(send_cq);
-		if (!cqe) {
-			ehea_reset_cq_ep(send_cq);
-			ehea_reset_cq_n1(send_cq);
-			cqe = ehea_poll_cq(send_cq);
-			if (!cqe)
-				break;
-		}
+	cqe = ehea_poll_cq(send_cq);
+	while(cqe && (quota > 0)) {
+		ehea_inc_cq(send_cq);
+
 		cqe_counter++;
 		rmb();
 		if (cqe->status & EHEA_CQE_STAT_ERR_MASK) {
@@ -515,16 +571,19 @@ void ehea_send_irq_tasklet(unsigned long
 
 		if (likely(EHEA_BMASK_GET(EHEA_WR_ID_TYPE, cqe->wr_id)
 			   == EHEA_SWQE2_TYPE))
-			free_sent_skbs(cqe, pr);
+			ehea_free_sent_skbs(cqe, pr);
 
 		swqe_av += EHEA_BMASK_GET(EHEA_WR_ID_REFILL, cqe->wr_id);
 		quota--;
-	} while (quota > 0);
+
+		cqe = ehea_poll_cq(send_cq);
+	};
 
 	ehea_update_feca(send_cq, cqe_counter);
 	atomic_add(swqe_av, &pr->swqe_avail);
 
 	spin_lock_irqsave(&pr->netif_queue, flags);
+
 	if (pr->queue_stopped && (atomic_read(&pr->swqe_avail)
 				  >= pr->swqe_refill_th)) {
 		netif_wake_queue(pr->port->netdev);
@@ -532,8 +591,48 @@ void ehea_send_irq_tasklet(unsigned long
 	}
 	spin_unlock_irqrestore(&pr->netif_queue, flags);
 
-	if (unlikely(cqe))
+	return cqe;
+}
+
+#define MAX_SENDCOMP_QUOTA 400
+#define EHEA_SPOLL_IRQ 3 
+void ehea_send_irq_tasklet(unsigned long data)
+{
+	struct ehea_port_res *pr = (struct ehea_port_res*)data;
+	struct ehea_cq *send_cq = pr->send_cq;
+	struct ehea_cqe *cqe;
+	int force_irq = 0;
+
+	pr->stcount++;
+
+	cqe = ehea_poll_cq(send_cq);
+	if (!cqe) {
+		pr->spoll_counter = 0;
+		ehea_reset_cq_ep(send_cq);
+		ehea_reset_cq_n1(send_cq);
+		ehea_proc_cqes(pr, MAX_SENDCOMP_QUOTA);
+		return;
+	}
+
+	force_irq = (pr->spoll_counter > EHEA_SPOLL_IRQ);
+
+	if (force_irq) {
+		pr->spoll_counter = 0;
+		ehea_reset_cq_ep(send_cq);
+		ehea_reset_cq_n1(send_cq);
+	}
+
+	cqe = ehea_proc_cqes(pr, MAX_SENDCOMP_QUOTA);
+
+	if (cqe)
+		pr->spoll_counter++;
+	else
+		pr->spoll_counter = 0;
+
+	if (pr->stcount % 2)
 		tasklet_hi_schedule(&pr->send_comp_task);
+	else
+		tasklet_schedule(&pr->send_comp_task);
 }
 
 static irqreturn_t ehea_send_irq_handler(int irq, void *param)
@@ -547,7 +646,12 @@ static irqreturn_t ehea_recv_irq_handler
 {
 	struct ehea_port_res *pr = param;
 	struct ehea_port *port = pr->port;
-	netif_rx_schedule(port->netdev);
+
+	if (use_mcs) 
+		tasklet_hi_schedule(&pr->recv_task);
+	else 
+		netif_rx_schedule(port->netdev);
+
 	return IRQ_HANDLED;
 }
 
@@ -650,19 +754,25 @@ int ehea_sense_port_attr(struct ehea_por
 	}
 
 	port->autoneg = 1;
+	port->num_mcs = cb0->num_default_qps;
 
 	/* Number of default QPs */
-	port->num_def_qps = cb0->num_default_qps;
+	if (use_mcs)
+		port->num_def_qps = cb0->num_default_qps;
+	else
+		port->num_def_qps = 1;
 
 	if (!port->num_def_qps) {
 		ret = -EINVAL;
 		goto out_free;
 	}
 
-	if (port->num_def_qps >= EHEA_NUM_TX_QP)
+	port->num_tx_qps = num_tx_qps;
+
+	if (port->num_def_qps >= port->num_tx_qps)
 		port->num_add_tx_qps = 0;
 	else
-		port->num_add_tx_qps = EHEA_NUM_TX_QP - port->num_def_qps;
+		port->num_add_tx_qps = port->num_tx_qps - port->num_def_qps;
 
 	ret = 0;
 out_free:
@@ -1003,9 +1113,14 @@ static int ehea_configure_port(struct eh
 				      PXLY_RC_VLAN_FILTER)
 		     | EHEA_BMASK_SET(PXLY_RC_JUMBO_FRAME, 1);
 
-	for (i = 0; i < port->num_def_qps; i++)
-		cb0->default_qpn_arr[i] = port->port_res[0].qp->init_attr.qp_nr;
-
+	for (i = 0; i < port->num_mcs; i++)
+		if (use_mcs)
+			cb0->default_qpn_arr[i] =
+				port->port_res[i].qp->init_attr.qp_nr;
+		else
+			cb0->default_qpn_arr[i] =
+				port->port_res[0].qp->init_attr.qp_nr;
+	
 	if (netif_msg_ifup(port))
 		ehea_dump(cb0, sizeof(*cb0), "ehea_configure_port");
 
@@ -1196,6 +1311,10 @@ static int ehea_init_port_res(struct ehe
 	}
 	tasklet_init(&pr->send_comp_task, ehea_send_irq_tasklet,
 		     (unsigned long)pr);
+
+	tasklet_init(&pr->recv_task, ehea_poll_task,
+		     (unsigned long)pr);
+
 	atomic_set(&pr->swqe_avail, init_attr->act_nr_send_wqes - 1);
 
 	kfree(init_attr);
@@ -1789,6 +1908,19 @@ static void ehea_xmit3(struct sk_buff *s
 	dev_kfree_skb(skb);
 }
 
+static inline int ehea_hash_skb(struct sk_buff *skb, int num_qps)
+{
+	u32 tmp;
+	if ((skb->nh.iph->protocol == IPPROTO_TCP)
+	    && skb->protocol == ETH_P_IP) {
+		tmp = (skb->h.th->source + (skb->h.th->dest << 16)) % 31;
+		tmp += skb->nh.iph->daddr % 31;
+		return tmp % num_qps;
+	}
+	else
+		return 0;
+}
+
 static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ehea_port *port = netdev_priv(dev);
@@ -1796,9 +1928,17 @@ static int ehea_start_xmit(struct sk_buf
 	unsigned long flags;
 	u32 lkey;
 	int swqe_index;
-	struct ehea_port_res *pr = &port->port_res[0];
+	struct ehea_port_res *pr;
+
+	pr = &port->port_res[ehea_hash_skb(skb, port->num_tx_qps)];
 
-	spin_lock(&pr->xmit_lock);
+	if(!spin_trylock(&pr->xmit_lock))
+		return NETDEV_TX_BUSY;
+
+	if (pr->queue_stopped) {
+		spin_unlock(&pr->xmit_lock);
+		return NETDEV_TX_BUSY;
+	}
 
 	swqe = ehea_get_swqe(pr->qp, &swqe_index);
 	memset(swqe, 0, SWQE_HEADER_SIZE);
@@ -2058,7 +2198,7 @@ static int ehea_port_res_setup(struct eh
 	}
 
 	pr_cfg.max_entries_rcq = rq1_entries + rq2_entries + rq3_entries;
-	pr_cfg.max_entries_scq = sq_entries;
+	pr_cfg.max_entries_scq = sq_entries * 2;
 	pr_cfg.max_entries_sq = sq_entries;
 	pr_cfg.max_entries_rq1 = rq1_entries;
 	pr_cfg.max_entries_rq2 = rq2_entries;
@@ -2209,6 +2349,10 @@ static int ehea_down(struct net_device *
 	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
 		tasklet_kill(&port->port_res[i].send_comp_task);
 
+	if (use_mcs)
+		for (i = 0; i < port->num_def_qps; i++)
+			tasklet_kill(&port->port_res[i].recv_task);
+
 	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 	ret = ehea_clean_all_portres(port);
 	port->state = EHEA_PORT_DOWN;
diff -Nurp -X dontdiff linux-2.6.21-rc1/drivers/net/ehea/ehea_qmr.h patched_kernel/drivers/net/ehea/ehea_qmr.h
--- linux-2.6.21-rc1/drivers/net/ehea/ehea_qmr.h	2007-02-23 15:23:45.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea_qmr.h	2007-02-23 16:17:33.000000000 +0100
@@ -320,6 +320,11 @@ static inline struct ehea_cqe *ehea_poll
 	return hw_qeit_get_valid(queue);
 }
 
+static inline void ehea_inc_cq(struct ehea_cq *cq)
+{
+	hw_qeit_inc(&cq->hw_queue);
+}
+
 static inline void ehea_inc_rq1(struct ehea_qp *qp)
 {
 	hw_qeit_inc(&qp->hw_rqueue1);
@@ -327,7 +332,7 @@ static inline void ehea_inc_rq1(struct e
 
 static inline struct ehea_cqe *ehea_poll_cq(struct ehea_cq *my_cq)
 {
-	return hw_qeit_get_inc_valid(&my_cq->hw_queue);
+	return hw_qeit_get_valid(&my_cq->hw_queue);
 }
 
 #define EHEA_CQ_REGISTER_ORIG 0
