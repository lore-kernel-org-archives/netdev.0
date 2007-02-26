From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH] ehea: NAPI multi queue TX/RX path for SMP
Date: Mon, 26 Feb 2007 17:00:50 +0100
Message-ID: <200702261700.51220.ossthema@de.ibm.com>
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
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Roland Dreier <rdreier@cisco.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:17911 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbXBZQGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 11:06:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

This patch replaces the former posted patch
([PATCH] ehea: Optional TX/RX path optimized for SMP) and provides
a functionality that allows parallel RX processing on multiple RX
queues by using dummy netdevices as proposed by Roland Dreier.
The fairness amongst this net devices and other network devices 
is thus better than in our first approach.

Is there a way to avoid overloading a single CPU with multiple netdev
receive processes using NAPI? A distribution based on CPU load might
help to improve the throughput. Pinning interrupts shows there is 
still some room for improvements.

Regards,
Jan-Bernd

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
---



diff -Nurp -X dontdiff linux-2.6.21-rc1/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.21-rc1/drivers/net/ehea/ehea.h	2007-02-26 16:17:14.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea.h	2007-02-26 16:29:08.000000000 +0100
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0048"
+#define DRV_VERSION	"EHEA_0050"
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
@@ -78,8 +78,6 @@
 #define EHEA_RQ2_PKT_SIZE       1522
 #define EHEA_L_PKT_SIZE         256	/* low latency */
 
-#define EHEA_POLL_MAX_RWQE      1000
-
 /* Send completion signaling */
 #define EHEA_SIG_IV_LONG           1
 
@@ -357,8 +355,8 @@ struct ehea_port_res {
 	struct ehea_qp *qp;
 	struct ehea_cq *send_cq;
 	struct ehea_cq *recv_cq;
-	struct ehea_eq *send_eq;
-	struct ehea_eq *recv_eq;
+	struct ehea_eq *eq;
+	struct net_device *d_netdev;
 	spinlock_t send_lock;
 	struct ehea_q_skb_arr rq1_skba;
 	struct ehea_q_skb_arr rq2_skba;
@@ -372,7 +370,6 @@ struct ehea_port_res {
 	int swqe_count;
 	u32 swqe_id_counter;
 	u64 tx_packets;
-	struct tasklet_struct send_comp_task;
 	spinlock_t recv_lock;
 	struct port_state p_state;
 	u64 rx_packets;
@@ -416,7 +413,9 @@ struct ehea_port {
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
--- linux-2.6.21-rc1/drivers/net/ehea/ehea_main.c	2007-02-26 16:17:14.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2007-02-26 16:20:16.000000000 +0100
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
@@ -71,6 +73,7 @@ MODULE_PARM_DESC(rq1_entries, "Number of
 MODULE_PARM_DESC(sq_entries, " Number of entries for the Send Queue  "
 		 "[2^x - 1], x = [6..14]. Default = "
 		 __MODULE_STRING(EHEA_DEF_ENTRIES_SQ) ")");
+MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Multiple receive queues, Default = 1 ");
 
 void ehea_dump(void *adr, int len, char *msg) {
 	int x;
@@ -197,7 +200,7 @@ static int ehea_refill_rq_def(struct ehe
 		struct sk_buff *skb = netdev_alloc_skb(dev, packet_size);
 		if (!skb) {
 			ehea_error("%s: no mem for skb/%d wqes filled",
-				   dev->name, i);
+				   pr->port->netdev->name, i);
 			q_skba->os_skbs = fill_wqes - i;
 			ret = -ENOMEM;
 			break;
@@ -345,10 +348,11 @@ static int ehea_treat_poll_error(struct 
 	return 0;
 }
 
-static int ehea_poll(struct net_device *dev, int *budget)
+static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
+					struct ehea_port_res *pr,
+					int *budget)
 {
-	struct ehea_port *port = netdev_priv(dev);
-	struct ehea_port_res *pr = &port->port_res[0];
+	struct ehea_port *port = pr->port;
 	struct ehea_qp *qp = pr->qp;
 	struct ehea_cqe *cqe;
 	struct sk_buff *skb;
@@ -359,14 +363,12 @@ static int ehea_poll(struct net_device *
 	int skb_arr_rq2_len = pr->rq2_skba.len;
 	int skb_arr_rq3_len = pr->rq3_skba.len;
 	int processed, processed_rq1, processed_rq2, processed_rq3;
-	int wqe_index, last_wqe_index, rq, intreq, my_quota, port_reset;
+	int wqe_index, last_wqe_index, rq, my_quota, port_reset;
 
 	processed = processed_rq1 = processed_rq2 = processed_rq3 = 0;
 	last_wqe_index = 0;
 	my_quota = min(*budget, dev->quota);
-	my_quota = min(my_quota, EHEA_POLL_MAX_RWQE);
 
-	/* rq0 is low latency RQ */
 	cqe = ehea_poll_rq1(qp, &wqe_index);
 	while ((my_quota > 0) && cqe) {
 		ehea_inc_rq1(qp);
@@ -386,14 +388,15 @@ static int ehea_poll(struct net_device *
 				if (unlikely(!skb)) {
 					if (netif_msg_rx_err(port))
 						ehea_error("LL rq1: skb=NULL");
-					skb = netdev_alloc_skb(dev,
+
+					skb = netdev_alloc_skb(port->netdev,
 							       EHEA_L_PKT_SIZE);
 					if (!skb)
 						break;
 				}
 				memcpy(skb->data, ((char*)cqe) + 64,
 				       cqe->num_bytes_transfered - 4);
-				ehea_fill_skb(dev, skb, cqe);
+				ehea_fill_skb(port->netdev, skb, cqe);
 			} else if (rq == 2) {  /* RQ2 */
 				skb = get_skb_by_index(skb_arr_rq2,
 						       skb_arr_rq2_len, cqe);
@@ -402,7 +405,7 @@ static int ehea_poll(struct net_device *
 						ehea_error("rq2: skb=NULL");
 					break;
 				}
-				ehea_fill_skb(dev, skb, cqe);
+				ehea_fill_skb(port->netdev, skb, cqe);
 				processed_rq2++;
 			} else {  /* RQ3 */
 				skb = get_skb_by_index(skb_arr_rq3,
@@ -412,7 +415,7 @@ static int ehea_poll(struct net_device *
 						ehea_error("rq3: skb=NULL");
 					break;
 				}
-				ehea_fill_skb(dev, skb, cqe);
+				ehea_fill_skb(port->netdev, skb, cqe);
 				processed_rq3++;
 			}
 
@@ -421,8 +424,7 @@ static int ehea_poll(struct net_device *
 							 cqe->vlan_tag);
 			else
 				netif_receive_skb(skb);
-
-		} else { /* Error occured */
+		} else {
 			pr->p_state.poll_receive_errors++;
 			port_reset = ehea_treat_poll_error(pr, rq, cqe,
 							   &processed_rq2,
@@ -433,32 +435,18 @@ static int ehea_poll(struct net_device *
 		cqe = ehea_poll_rq1(qp, &wqe_index);
 	}
 
-	dev->quota -= processed;
-	*budget -= processed;
-
-	pr->p_state.ehea_poll += 1;
 	pr->rx_packets += processed;
+	*budget -= processed;
 
 	ehea_refill_rq1(pr, last_wqe_index, processed_rq1);
 	ehea_refill_rq2(pr, processed_rq2);
 	ehea_refill_rq3(pr, processed_rq3);
 
-	intreq = ((pr->p_state.ehea_poll & 0xF) == 0xF);
-
-	if (!cqe || intreq) {
-		netif_rx_complete(dev);
-		ehea_reset_cq_ep(pr->recv_cq);
-		ehea_reset_cq_n1(pr->recv_cq);
-		cqe = hw_qeit_get_valid(&qp->hw_rqueue1);
-		if (!cqe || intreq)
-			return 0;
-		if (!netif_rx_reschedule(dev, my_quota))
-			return 0;
-	}
-	return 1;
+	cqe = ehea_poll_rq1(qp, &wqe_index);
+	return cqe;
 }
 
-void free_sent_skbs(struct ehea_cqe *cqe, struct ehea_port_res *pr)
+static void ehea_free_sent_skbs(struct ehea_cqe *cqe, struct ehea_port_res *pr)
 {
 	struct sk_buff *skb;
 	int index, max_index_mask, i;
@@ -479,26 +467,19 @@ void free_sent_skbs(struct ehea_cqe *cqe
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
@@ -515,16 +496,19 @@ void ehea_send_irq_tasklet(unsigned long
 
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
@@ -532,22 +516,55 @@ void ehea_send_irq_tasklet(unsigned long
 	}
 	spin_unlock_irqrestore(&pr->netif_queue, flags);
 
-	if (unlikely(cqe))
-		tasklet_hi_schedule(&pr->send_comp_task);
+	return cqe;
 }
 
-static irqreturn_t ehea_send_irq_handler(int irq, void *param)
+#define EHEA_NAPI_POLL_NUM_BEFORE_IRQ 16
+
+static int ehea_poll(struct net_device *dev, int *budget)
 {
-	struct ehea_port_res *pr = param;
-	tasklet_hi_schedule(&pr->send_comp_task);
-	return IRQ_HANDLED;
+	struct ehea_port_res *pr = dev->priv;
+	struct ehea_cqe *cqe;
+	struct ehea_cqe *cqe_skb = NULL;
+	int force_irq, wqe_index;
+
+	cqe = ehea_poll_rq1(pr->qp, &wqe_index);
+	cqe_skb = ehea_poll_cq(pr->send_cq);
+
+	force_irq = (pr->poll_counter > EHEA_NAPI_POLL_NUM_BEFORE_IRQ);
+
+	if ((!cqe && !cqe_skb) || force_irq) {
+		pr->poll_counter = 0;
+		netif_rx_complete(dev);
+		ehea_reset_cq_ep(pr->recv_cq);
+		ehea_reset_cq_ep(pr->send_cq);
+		ehea_reset_cq_n1(pr->recv_cq);
+		ehea_reset_cq_n1(pr->send_cq);
+		cqe = ehea_poll_rq1(pr->qp, &wqe_index);
+		cqe_skb = ehea_poll_cq(pr->send_cq);
+
+		if (!cqe && !cqe_skb) 
+			return 0;
+
+		if (!netif_rx_reschedule(dev, dev->quota)) 
+			return 0;
+	}
+	
+	cqe = ehea_proc_rwqes(dev, pr, budget);
+	cqe_skb = ehea_proc_cqes(pr, 300);
+
+	if (cqe || cqe_skb)
+		pr->poll_counter++;
+       
+	return 1;
 }
 
 static irqreturn_t ehea_recv_irq_handler(int irq, void *param)
 {
 	struct ehea_port_res *pr = param;
-	struct ehea_port *port = pr->port;
-	netif_rx_schedule(port->netdev);
+
+	netif_rx_schedule(pr->d_netdev);
+
 	return IRQ_HANDLED;
 }
 
@@ -650,19 +667,25 @@ int ehea_sense_port_attr(struct ehea_por
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
@@ -882,23 +905,6 @@ static int ehea_reg_interrupts(struct ne
 	struct ehea_port_res *pr;
 	int i, ret;
 
-	for (i = 0; i < port->num_def_qps; i++) {
-		pr = &port->port_res[i];
-		snprintf(pr->int_recv_name, EHEA_IRQ_NAME_SIZE - 1
-			 , "%s-recv%d", dev->name, i);
-		ret = ibmebus_request_irq(NULL, pr->recv_eq->attr.ist1,
-					  ehea_recv_irq_handler,
-					  IRQF_DISABLED, pr->int_recv_name, pr);
-		if (ret) {
-			ehea_error("failed registering irq for ehea_recv_int:"
-				   "port_res_nr:%d, ist=%X", i,
-				   pr->recv_eq->attr.ist1);
-			goto out_free_seq;
-		}
-		if (netif_msg_ifup(port))
-			ehea_info("irq_handle 0x%X for funct ehea_recv_int %d "
-				  "registered", pr->recv_eq->attr.ist1, i);
-	}
 
 	snprintf(port->int_aff_name, EHEA_IRQ_NAME_SIZE - 1, "%s-aff",
 		 dev->name);
@@ -916,41 +922,41 @@ static int ehea_reg_interrupts(struct ne
 		ehea_info("irq_handle 0x%X for function qp_aff_irq_handler "
 			  "registered", port->qp_eq->attr.ist1);
 
+
 	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
 		pr = &port->port_res[i];
 		snprintf(pr->int_send_name, EHEA_IRQ_NAME_SIZE - 1,
-			 "%s-send%d", dev->name, i);
-		ret = ibmebus_request_irq(NULL, pr->send_eq->attr.ist1,
-					  ehea_send_irq_handler,
+			 "%s-queue%d", dev->name, i);
+		ret = ibmebus_request_irq(NULL, pr->eq->attr.ist1,
+					  ehea_recv_irq_handler,
 					  IRQF_DISABLED, pr->int_send_name,
 					  pr);
 		if (ret) {
-			ehea_error("failed registering irq for ehea_send "
+			ehea_error("failed registering irq for ehea_queue "
 				   "port_res_nr:%d, ist=%X", i,
-				   pr->send_eq->attr.ist1);
+				   pr->eq->attr.ist1);
 			goto out_free_req;
 		}
 		if (netif_msg_ifup(port))
-			ehea_info("irq_handle 0x%X for function ehea_send_int "
-				  "%d registered", pr->send_eq->attr.ist1, i);
+			ehea_info("irq_handle 0x%X for function ehea_queue_int "
+				  "%d registered", pr->eq->attr.ist1, i);
 	}
 out:
 	return ret;
 
+
 out_free_req:
 	while (--i >= 0) {
-		u32 ist = port->port_res[i].send_eq->attr.ist1;
+		u32 ist = port->port_res[i].eq->attr.ist1;
 		ibmebus_free_irq(NULL, ist, &port->port_res[i]);
 	}
+
 out_free_qpeq:
 	ibmebus_free_irq(NULL, port->qp_eq->attr.ist1, port);
 	i = port->num_def_qps;
-out_free_seq:
-	while (--i >= 0) {
-		u32 ist = port->port_res[i].recv_eq->attr.ist1;
-		ibmebus_free_irq(NULL, ist, &port->port_res[i]);
-	}
+
 	goto out;
+
 }
 
 static void ehea_free_interrupts(struct net_device *dev)
@@ -960,21 +966,13 @@ static void ehea_free_interrupts(struct 
 	int i;
 
 	/* send */
+
 	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
 		pr = &port->port_res[i];
-		ibmebus_free_irq(NULL, pr->send_eq->attr.ist1, pr);
+		ibmebus_free_irq(NULL, pr->eq->attr.ist1, pr);
 		if (netif_msg_intr(port))
 			ehea_info("free send irq for res %d with handle 0x%X",
-				  i, pr->send_eq->attr.ist1);
-	}
-
-	/* receive */
-	for (i = 0; i < port->num_def_qps; i++) {
-		pr = &port->port_res[i];
-		ibmebus_free_irq(NULL, pr->recv_eq->attr.ist1, pr);
-		if (netif_msg_intr(port))
-			ehea_info("free recv irq for res %d with handle 0x%X",
-				  i, pr->recv_eq->attr.ist1);
+				  i, pr->eq->attr.ist1);
 	}
 
 	/* associated events */
@@ -1003,9 +1001,14 @@ static int ehea_configure_port(struct eh
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
 
@@ -1108,20 +1111,14 @@ static int ehea_init_port_res(struct ehe
 	spin_lock_init(&pr->xmit_lock);
 	spin_lock_init(&pr->netif_queue);
 
-	pr->recv_eq = ehea_create_eq(adapter, eq_type, EHEA_MAX_ENTRIES_EQ, 0);
-	if (!pr->recv_eq) {
-		ehea_error("create_eq failed (recv_eq)");
-		goto out_free;
-	}
-
-	pr->send_eq = ehea_create_eq(adapter, eq_type, EHEA_MAX_ENTRIES_EQ, 0);
-	if (!pr->send_eq) {
-		ehea_error("create_eq failed (send_eq)");
+	pr->eq = ehea_create_eq(adapter, eq_type, EHEA_MAX_ENTRIES_EQ, 0);
+	if (!pr->eq) {
+		ehea_error("create_eq failed (eq)");
 		goto out_free;
 	}
 
 	pr->recv_cq = ehea_create_cq(adapter, pr_cfg->max_entries_rcq,
-				     pr->recv_eq->fw_handle,
+				     pr->eq->fw_handle,
 				     port->logical_port_id);
 	if (!pr->recv_cq) {
 		ehea_error("create_cq failed (cq_recv)");
@@ -1129,7 +1126,7 @@ static int ehea_init_port_res(struct ehe
 	}
 
 	pr->send_cq = ehea_create_cq(adapter, pr_cfg->max_entries_scq,
-				     pr->send_eq->fw_handle,
+				     pr->eq->fw_handle,
 				     port->logical_port_id);
 	if (!pr->send_cq) {
 		ehea_error("create_cq failed (cq_send)");
@@ -1194,11 +1191,20 @@ static int ehea_init_port_res(struct ehe
 		ret = -EIO;
 		goto out_free;
 	}
-	tasklet_init(&pr->send_comp_task, ehea_send_irq_tasklet,
-		     (unsigned long)pr);
+
 	atomic_set(&pr->swqe_avail, init_attr->act_nr_send_wqes - 1);
 
 	kfree(init_attr);
+
+	pr->d_netdev = alloc_netdev(0, "", ether_setup);
+	if (!pr->d_netdev)
+		goto out_free;
+	pr->d_netdev->priv = pr;
+	pr->d_netdev->weight = 64;
+	pr->d_netdev->poll = ehea_poll;
+	set_bit(__LINK_STATE_START, &pr->d_netdev->state);
+	strcpy(pr->d_netdev->name, port->netdev->name);
+
 	ret = 0;
 	goto out;
 
@@ -1211,8 +1217,7 @@ out_free:
 	ehea_destroy_qp(pr->qp);
 	ehea_destroy_cq(pr->send_cq);
 	ehea_destroy_cq(pr->recv_cq);
-	ehea_destroy_eq(pr->send_eq);
-	ehea_destroy_eq(pr->recv_eq);
+	ehea_destroy_eq(pr->eq);
 out:
 	return ret;
 }
@@ -1221,13 +1226,14 @@ static int ehea_clean_portres(struct ehe
 {
 	int ret, i;
 
+	free_netdev(pr->d_netdev);
+
 	ret = ehea_destroy_qp(pr->qp);
 
 	if (!ret) {
 		ehea_destroy_cq(pr->send_cq);
 		ehea_destroy_cq(pr->recv_cq);
-		ehea_destroy_eq(pr->send_eq);
-		ehea_destroy_eq(pr->recv_eq);
+		ehea_destroy_eq(pr->eq);
 
 		for (i = 0; i < pr->rq1_skba.len; i++)
 			if (pr->rq1_skba.arr[i])
@@ -1789,6 +1795,19 @@ static void ehea_xmit3(struct sk_buff *s
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
@@ -1796,9 +1815,18 @@ static int ehea_start_xmit(struct sk_buf
 	unsigned long flags;
 	u32 lkey;
 	int swqe_index;
-	struct ehea_port_res *pr = &port->port_res[0];
+	struct ehea_port_res *pr;
+
+	pr = &port->port_res[ehea_hash_skb(skb, port->num_tx_qps)];
+
 
-	spin_lock(&pr->xmit_lock);
+	if (!spin_trylock(&pr->xmit_lock))
+		return NETDEV_TX_BUSY;
+
+	if (pr->queue_stopped) {
+		spin_unlock(&pr->xmit_lock);
+		return NETDEV_TX_BUSY;
+	}
 
 	swqe = ehea_get_swqe(pr->qp, &swqe_index);
 	memset(swqe, 0, SWQE_HEADER_SIZE);
@@ -2058,7 +2086,7 @@ static int ehea_port_res_setup(struct eh
 	}
 
 	pr_cfg.max_entries_rcq = rq1_entries + rq2_entries + rq3_entries;
-	pr_cfg.max_entries_scq = sq_entries;
+	pr_cfg.max_entries_scq = sq_entries * 2;
 	pr_cfg.max_entries_sq = sq_entries;
 	pr_cfg.max_entries_rq1 = rq1_entries;
 	pr_cfg.max_entries_rq2 = rq2_entries;
@@ -2206,8 +2234,10 @@ static int ehea_down(struct net_device *
 	ehea_drop_multicast_list(dev);
 	ehea_free_interrupts(dev);
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
-		tasklet_kill(&port->port_res[i].send_comp_task);
+	for (i = 0; i < port->num_def_qps; i++)
+		while (test_bit(__LINK_STATE_RX_SCHED, 
+				&port->port_res[i].d_netdev->state))
+			msleep(1);
 
 	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 	ret = ehea_clean_all_portres(port);
diff -Nurp -X dontdiff linux-2.6.21-rc1/drivers/net/ehea/ehea_qmr.h patched_kernel/drivers/net/ehea/ehea_qmr.h
--- linux-2.6.21-rc1/drivers/net/ehea/ehea_qmr.h	2007-02-23 15:23:45.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea_qmr.h	2007-02-26 16:20:22.000000000 +0100
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
