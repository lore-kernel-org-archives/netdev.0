From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 02/15] ehea: Update multiqueue support
Date: Thu, 12 May 2011 10:52:15 +1000
Message-ID: <20110512005622.681433781@samba.org>
References: <20110512005213.897432612@samba.org>
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:35812 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752726Ab1ELBRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 21:17:23 -0400
Content-Disposition: inline; filename=ehea_2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ehea driver had some multiqueue support but was missing the last
few years of networking stack improvements:

- Use skb_record_rx_queue to record which queue an skb came in on.

- Remove the driver specific netif_queue lock and use the networking
  stack transmit lock instead.

- Remove the driver specific transmit queue hashing and use 
  skb_get_queue_mapping instead.

- Use netif_tx_{start|stop|wake}_queue where appropriate. We can also
  remove pr->queue_stopped and just check the queue status directly.

- Print all 16 queues in the ethtool stats.

We now enable multiqueue by default since it is a clear win on all my
testing so far.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

v2: Review from Michael Ellerman:

- Move skb_record_rx_queue into ehea_fill_skb

- Fix unlock issue when stopping a transmit queue in ehea_proc_cqes.
  For my penance I cut the queue down to force the stop/start logic
  to be exercised. Over a million queue stop/start operations completed
  successfully while running a TCP RR benchmark.

Index: linux-net/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:48.840103988 +1000
+++ linux-net/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:49.640116670 +1000
@@ -60,7 +60,7 @@ static int rq1_entries = EHEA_DEF_ENTRIE
 static int rq2_entries = EHEA_DEF_ENTRIES_RQ2;
 static int rq3_entries = EHEA_DEF_ENTRIES_RQ3;
 static int sq_entries = EHEA_DEF_ENTRIES_SQ;
-static int use_mcs;
+static int use_mcs = 1;
 static int use_lro;
 static int lro_max_aggr = EHEA_LRO_MAX_AGGR;
 static int num_tx_qps = EHEA_NUM_TX_QP;
@@ -93,7 +93,7 @@ MODULE_PARM_DESC(rq1_entries, "Number of
 MODULE_PARM_DESC(sq_entries, " Number of entries for the Send Queue  "
 		 "[2^x - 1], x = [6..14]. Default = "
 		 __MODULE_STRING(EHEA_DEF_ENTRIES_SQ) ")");
-MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Multiple receive queues, Default = 0 ");
+MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Multiple receive queues, Default = 1 ");
 
 MODULE_PARM_DESC(lro_max_aggr, " LRO: Max packets to be aggregated. Default = "
 		 __MODULE_STRING(EHEA_LRO_MAX_AGGR));
@@ -542,7 +542,8 @@ static inline int ehea_check_cqe(struct
 }
 
 static inline void ehea_fill_skb(struct net_device *dev,
-				 struct sk_buff *skb, struct ehea_cqe *cqe)
+				 struct sk_buff *skb, struct ehea_cqe *cqe,
+				 struct ehea_port_res *pr)
 {
 	int length = cqe->num_bytes_transfered - 4;	/*remove CRC */
 
@@ -556,6 +557,8 @@ static inline void ehea_fill_skb(struct
 		skb->csum = csum_unfold(~cqe->inet_checksum_value);
 	} else
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	skb_record_rx_queue(skb, pr - &pr->port->port_res[0]);
 }
 
 static inline struct sk_buff *get_skb_by_index(struct sk_buff **skb_array,
@@ -752,7 +755,7 @@ static int ehea_proc_rwqes(struct net_de
 				}
 				skb_copy_to_linear_data(skb, ((char *)cqe) + 64,
 						 cqe->num_bytes_transfered - 4);
-				ehea_fill_skb(dev, skb, cqe);
+				ehea_fill_skb(dev, skb, cqe, pr);
 			} else if (rq == 2) {
 				/* RQ2 */
 				skb = get_skb_by_index(skb_arr_rq2,
@@ -762,7 +765,7 @@ static int ehea_proc_rwqes(struct net_de
 						  "rq2: skb=NULL\n");
 					break;
 				}
-				ehea_fill_skb(dev, skb, cqe);
+				ehea_fill_skb(dev, skb, cqe, pr);
 				processed_rq2++;
 			} else {
 				/* RQ3 */
@@ -773,7 +776,7 @@ static int ehea_proc_rwqes(struct net_de
 						  "rq3: skb=NULL\n");
 					break;
 				}
-				ehea_fill_skb(dev, skb, cqe);
+				ehea_fill_skb(dev, skb, cqe, pr);
 				processed_rq3++;
 			}
 
@@ -859,7 +862,8 @@ static struct ehea_cqe *ehea_proc_cqes(s
 	int cqe_counter = 0;
 	int swqe_av = 0;
 	int index;
-	unsigned long flags;
+	struct netdev_queue *txq = netdev_get_tx_queue(pr->port->netdev,
+						pr - &pr->port->port_res[0]);
 
 	cqe = ehea_poll_cq(send_cq);
 	while (cqe && (quota > 0)) {
@@ -909,14 +913,15 @@ static struct ehea_cqe *ehea_proc_cqes(s
 	ehea_update_feca(send_cq, cqe_counter);
 	atomic_add(swqe_av, &pr->swqe_avail);
 
-	spin_lock_irqsave(&pr->netif_queue, flags);
-
-	if (pr->queue_stopped && (atomic_read(&pr->swqe_avail)
-				  >= pr->swqe_refill_th)) {
-		netif_wake_queue(pr->port->netdev);
-		pr->queue_stopped = 0;
+	if (unlikely(netif_tx_queue_stopped(txq) &&
+		     (atomic_read(&pr->swqe_avail) >= pr->swqe_refill_th))) {
+		__netif_tx_lock(txq, smp_processor_id());
+		if (netif_tx_queue_stopped(txq) &&
+		    (atomic_read(&pr->swqe_avail) >= pr->swqe_refill_th))
+			netif_tx_wake_queue(txq);
+		__netif_tx_unlock(txq);
 	}
-	spin_unlock_irqrestore(&pr->netif_queue, flags);
+
 	wake_up(&pr->port->swqe_avail_wq);
 
 	return cqe;
@@ -1253,7 +1258,7 @@ static void ehea_parse_eqe(struct ehea_a
 				netif_info(port, link, dev,
 					   "Logical port down\n");
 				netif_carrier_off(dev);
-				netif_stop_queue(dev);
+				netif_tx_disable(dev);
 			}
 
 		if (EHEA_BMASK_GET(NEQE_EXTSWITCH_PORT_UP, eqe)) {
@@ -1284,7 +1289,7 @@ static void ehea_parse_eqe(struct ehea_a
 	case EHEA_EC_PORT_MALFUNC:
 		netdev_info(dev, "Port malfunction\n");
 		netif_carrier_off(dev);
-		netif_stop_queue(dev);
+		netif_tx_disable(dev);
 		break;
 	default:
 		netdev_err(dev, "unknown event code %x, eqe=0x%llX\n", ec, eqe);
@@ -1536,7 +1541,6 @@ static int ehea_init_port_res(struct ehe
 	pr->rx_packets = rx_packets;
 
 	pr->port = port;
-	spin_lock_init(&pr->netif_queue);
 
 	pr->eq = ehea_create_eq(adapter, eq_type, EHEA_MAX_ENTRIES_EQ, 0);
 	if (!pr->eq) {
@@ -2233,35 +2237,17 @@ static void ehea_xmit3(struct sk_buff *s
 	dev_kfree_skb(skb);
 }
 
-static inline int ehea_hash_skb(struct sk_buff *skb, int num_qps)
-{
-	struct tcphdr *tcp;
-	u32 tmp;
-
-	if ((skb->protocol == htons(ETH_P_IP)) &&
-	    (ip_hdr(skb)->protocol == IPPROTO_TCP)) {
-		tcp = (struct tcphdr *)(skb_network_header(skb) +
-					(ip_hdr(skb)->ihl * 4));
-		tmp = (tcp->source + (tcp->dest << 16)) % 31;
-		tmp += ip_hdr(skb)->daddr % 31;
-		return tmp % num_qps;
-	} else
-		return 0;
-}
-
 static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ehea_port *port = netdev_priv(dev);
 	struct ehea_swqe *swqe;
-	unsigned long flags;
 	u32 lkey;
 	int swqe_index;
 	struct ehea_port_res *pr;
+	struct netdev_queue *txq;
 
-	pr = &port->port_res[ehea_hash_skb(skb, port->num_tx_qps)];
-
-	if (pr->queue_stopped)
-		return NETDEV_TX_BUSY;
+	pr = &port->port_res[skb_get_queue_mapping(skb)];
+	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
 
 	swqe = ehea_get_swqe(pr->qp, &swqe_index);
 	memset(swqe, 0, SWQE_HEADER_SIZE);
@@ -2311,20 +2297,15 @@ static int ehea_start_xmit(struct sk_buf
 		ehea_dump(swqe, 512, "swqe");
 
 	if (unlikely(test_bit(__EHEA_STOP_XFER, &ehea_driver_flags))) {
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(txq);
 		swqe->tx_control |= EHEA_SWQE_PURGE;
 	}
 
 	ehea_post_swqe(pr->qp, swqe);
 
 	if (unlikely(atomic_read(&pr->swqe_avail) <= 1)) {
-		spin_lock_irqsave(&pr->netif_queue, flags);
-		if (unlikely(atomic_read(&pr->swqe_avail) <= 1)) {
-			pr->p_stats.queue_stopped++;
-			netif_stop_queue(dev);
-			pr->queue_stopped = 1;
-		}
-		spin_unlock_irqrestore(&pr->netif_queue, flags);
+		pr->p_stats.queue_stopped++;
+		netif_tx_stop_queue(txq);
 	}
 
 	return NETDEV_TX_OK;
@@ -2677,7 +2658,7 @@ static int ehea_open(struct net_device *
 	ret = ehea_up(dev);
 	if (!ret) {
 		port_napi_enable(port);
-		netif_start_queue(dev);
+		netif_tx_start_all_queues(dev);
 	}
 
 	mutex_unlock(&port->port_lock);
@@ -2721,7 +2702,7 @@ static int ehea_stop(struct net_device *
 	set_bit(__EHEA_DISABLE_PORT_RESET, &port->flags);
 	cancel_work_sync(&port->reset_task);
 	mutex_lock(&port->port_lock);
-	netif_stop_queue(dev);
+	netif_tx_stop_all_queues(dev);
 	port_napi_disable(port);
 	ret = ehea_down(dev);
 	mutex_unlock(&port->port_lock);
@@ -2945,7 +2926,7 @@ static void ehea_reset_port(struct work_
 	mutex_lock(&dlpar_mem_lock);
 	port->resets++;
 	mutex_lock(&port->port_lock);
-	netif_stop_queue(dev);
+	netif_tx_disable(dev);
 
 	port_napi_disable(port);
 
@@ -2961,7 +2942,7 @@ static void ehea_reset_port(struct work_
 
 	port_napi_enable(port);
 
-	netif_wake_queue(dev);
+	netif_tx_wake_all_queues(dev);
 out:
 	mutex_unlock(&port->port_lock);
 	mutex_unlock(&dlpar_mem_lock);
@@ -2988,7 +2969,7 @@ static void ehea_rereg_mrs(void)
 
 				if (dev->flags & IFF_UP) {
 					mutex_lock(&port->port_lock);
-					netif_stop_queue(dev);
+					netif_tx_disable(dev);
 					ehea_flush_sq(port);
 					ret = ehea_stop_qps(dev);
 					if (ret) {
@@ -3033,7 +3014,7 @@ static void ehea_rereg_mrs(void)
 						if (!ret) {
 							check_sqs(port);
 							port_napi_enable(port);
-							netif_wake_queue(dev);
+							netif_tx_wake_all_queues(dev);
 						} else {
 							netdev_err(dev, "Unable to restart QPS\n");
 						}
@@ -3210,7 +3191,7 @@ struct ehea_port *ehea_setup_single_port
 	int jumbo;
 
 	/* allocate memory for the port structures */
-	dev = alloc_etherdev(sizeof(struct ehea_port));
+	dev = alloc_etherdev_mq(sizeof(struct ehea_port), EHEA_MAX_PORT_RES);
 
 	if (!dev) {
 		pr_err("no mem for net_device\n");
@@ -3242,6 +3223,10 @@ struct ehea_port *ehea_setup_single_port
 	if (ret)
 		goto out_free_mc_list;
 
+	netif_set_real_num_rx_queues(dev, port->num_def_qps);
+	netif_set_real_num_tx_queues(dev, port->num_def_qps +
+				     port->num_add_tx_qps);
+
 	port_dev = ehea_register_port(port, dn);
 	if (!port_dev)
 		goto out_free_mc_list;
Index: linux-net/drivers/net/ehea/ehea.h
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea.h	2011-05-12 07:47:48.840103988 +1000
+++ linux-net/drivers/net/ehea/ehea.h	2011-05-12 07:47:49.640116670 +1000
@@ -375,8 +375,6 @@ struct ehea_port_res {
 	struct ehea_q_skb_arr rq3_skba;
 	struct ehea_q_skb_arr sq_skba;
 	int sq_skba_size;
-	spinlock_t netif_queue;
-	int queue_stopped;
 	int swqe_refill_th;
 	atomic_t swqe_avail;
 	int swqe_ll_count;
Index: linux-net/drivers/net/ehea/ehea_ethtool.c
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea_ethtool.c	2011-05-12 07:47:10.869501966 +1000
+++ linux-net/drivers/net/ehea/ehea_ethtool.c	2011-05-12 07:47:49.640116670 +1000
@@ -189,7 +189,6 @@ static char ehea_ethtool_stats_keys[][ET
 	{"IP cksum errors"},
 	{"Frame cksum errors"},
 	{"num SQ stopped"},
-	{"SQ stopped"},
 	{"PR0 free_swqes"},
 	{"PR1 free_swqes"},
 	{"PR2 free_swqes"},
@@ -198,6 +197,14 @@ static char ehea_ethtool_stats_keys[][ET
 	{"PR5 free_swqes"},
 	{"PR6 free_swqes"},
 	{"PR7 free_swqes"},
+	{"PR8 free_swqes"},
+	{"PR9 free_swqes"},
+	{"PR10 free_swqes"},
+	{"PR11 free_swqes"},
+	{"PR12 free_swqes"},
+	{"PR13 free_swqes"},
+	{"PR14 free_swqes"},
+	{"PR15 free_swqes"},
 	{"LRO aggregated"},
 	{"LRO flushed"},
 	{"LRO no_desc"},
@@ -255,11 +262,7 @@ static void ehea_get_ethtool_stats(struc
 		tmp += port->port_res[k].p_stats.queue_stopped;
 	data[i++] = tmp;
 
-	for (k = 0, tmp = 0; k < EHEA_MAX_PORT_RES; k++)
-		tmp |= port->port_res[k].queue_stopped;
-	data[i++] = tmp;
-
-	for (k = 0; k < 8; k++)
+	for (k = 0; k < 16; k++)
 		data[i++] = atomic_read(&port->port_res[k].swqe_avail);
 
 	for (k = 0, tmp = 0; k < EHEA_MAX_PORT_RES; k++)


