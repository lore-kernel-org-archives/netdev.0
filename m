From: dhananjay@netxen.com
Subject: [patch 5/7] netxen: fix race in interrupt / napi
Date: Wed, 26 Dec 2007 10:23:57 -0800
Message-ID: <20071226182927.778015972@netxen.com>
References: <20071226182352.704678179@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:45032 "EHLO dut46.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751453AbXLZSZy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Dec 2007 13:25:54 -0500
Content-Disposition: inline; filename=poll.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch simplifies netxen ISR and poll() routine. Interrupts are not
unmasked in interrupt routine based on a racy has_work() checks, but
left to the napi poll function to enable them. 

This also fixes crash in netif_rx_action(), when work_done == budget.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Index: upstream/drivers/net/netxen/netxen_nic_main.c
===================================================================
--- upstream.orig/drivers/net/netxen/netxen_nic_main.c
+++ upstream/drivers/net/netxen/netxen_nic_main.c
@@ -63,7 +63,6 @@ static int netxen_nic_xmit_frame(struct 
 static void netxen_tx_timeout(struct net_device *netdev);
 static void netxen_tx_timeout_task(struct work_struct *work);
 static void netxen_watchdog(unsigned long);
-static int netxen_handle_int(struct netxen_adapter *, struct net_device *);
 static int netxen_nic_poll(struct napi_struct *napi, int budget);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void netxen_nic_poll_controller(struct net_device *netdev);
@@ -1218,40 +1217,6 @@ static void netxen_tx_timeout_task(struc
 	netif_wake_queue(adapter->netdev);
 }
 
-static int
-netxen_handle_int(struct netxen_adapter *adapter, struct net_device *netdev)
-{
-	u32 ret = 0;
-
-	DPRINTK(INFO, "Entered handle ISR\n");
-	adapter->stats.ints++;
-
-	netxen_nic_disable_int(adapter);
-
-	if (netxen_nic_rx_has_work(adapter) || netxen_nic_tx_has_work(adapter)) {
-		if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
-			/*
-			 * Interrupts are already disabled.
-			 */
-			__netif_rx_schedule(netdev, &adapter->napi);
-		} else {
-			static unsigned int intcount = 0;
-			if ((++intcount & 0xfff) == 0xfff)
-				DPRINTK(KERN_ERR
-				       "%s: %s interrupt %d while in poll\n",
-				       netxen_nic_driver_name, netdev->name,
-				       intcount);
-		}
-		ret = 1;
-	}
-
-	if (ret == 0) {
-		netxen_nic_enable_int(adapter);
-	}
-
-	return ret;
-}
-
 /*
  * netxen_intr - Interrupt Handler
  * @irq: interrupt number
@@ -1278,8 +1243,12 @@ irqreturn_t netxen_intr(int irq, void *d
 		}
 	}
 
-	if (netif_running(netdev))
-		netxen_handle_int(adapter, netdev);
+	adapter->stats.ints++;
+
+	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
+		netxen_nic_disable_int(adapter);
+		__netif_rx_schedule(netdev, &adapter->napi);
+	}
 
 	return IRQ_HANDLED;
 }
@@ -1287,12 +1256,11 @@ irqreturn_t netxen_intr(int irq, void *d
 static int netxen_nic_poll(struct napi_struct *napi, int budget)
 {
 	struct netxen_adapter *adapter = container_of(napi, struct netxen_adapter, napi);
-	struct net_device *netdev = adapter->netdev;
-	int done = 1;
+	int tx_complete;
 	int ctx;
 	int work_done;
 
-	DPRINTK(INFO, "polling for %d descriptors\n", *budget);
+	tx_complete = netxen_process_cmd_ring(adapter);
 
 	work_done = 0;
 	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
@@ -1312,16 +1280,8 @@ static int netxen_nic_poll(struct napi_s
 						     budget / MAX_RCV_CTX);
 	}
 
-	if (work_done >= budget && netxen_nic_rx_has_work(adapter) != 0)
-		done = 0;
-
-	if (netxen_process_cmd_ring((unsigned long)adapter) == 0)
-		done = 0;
-
-	DPRINTK(INFO, "new work_done: %d work_to_do: %d\n",
-		work_done, work_to_do);
-	if (done) {
-		netif_rx_complete(netdev, napi);
+	if ((work_done < budget) && tx_complete) {
+		netif_rx_complete(adapter->netdev, &adapter->napi);
 		netxen_nic_enable_int(adapter);
 	}
 
Index: upstream/drivers/net/netxen/netxen_nic.h
===================================================================
--- upstream.orig/drivers/net/netxen/netxen_nic.h
+++ upstream/drivers/net/netxen/netxen_nic.h
@@ -839,7 +839,6 @@ struct netxen_rcv_desc_ctx {
 	u32 flags;
 	u32 producer;
 	u32 rcv_pending;	/* Num of bufs posted in phantom */
-	u32 rcv_free;		/* Num of bufs in free list */
 	dma_addr_t phys_addr;
 	struct pci_dev *phys_pdev;
 	struct rcv_desc *desc_head;	/* address of rx ring in Phantom */
@@ -1073,12 +1072,10 @@ void netxen_tso_check(struct netxen_adap
 		      struct cmd_desc_type0 *desc, struct sk_buff *skb);
 int netxen_nic_hw_resources(struct netxen_adapter *adapter);
 void netxen_nic_clear_stats(struct netxen_adapter *adapter);
-int netxen_nic_rx_has_work(struct netxen_adapter *adapter);
-int netxen_nic_tx_has_work(struct netxen_adapter *adapter);
 void netxen_watchdog_task(struct work_struct *work);
 void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx,
 			    u32 ringid);
-int netxen_process_cmd_ring(unsigned long data);
+int netxen_process_cmd_ring(struct netxen_adapter *adapter);
 u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctx, int max);
 void netxen_nic_set_multi(struct net_device *netdev);
 int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu);
Index: upstream/drivers/net/netxen/netxen_nic_init.c
===================================================================
--- upstream.orig/drivers/net/netxen/netxen_nic_init.c
+++ upstream/drivers/net/netxen/netxen_nic_init.c
@@ -185,7 +185,6 @@ void netxen_initialize_adapter_sw(struct
 		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
 			struct netxen_rx_buffer *rx_buf;
 			rcv_desc = &adapter->recv_ctx[ctxid].rcv_desc[ring];
-			rcv_desc->rcv_free = rcv_desc->max_rx_desc_count;
 			rcv_desc->begin_alloc = 0;
 			rx_buf = rcv_desc->rx_buf_arr;
 			num_rx_bufs = rcv_desc->max_rx_desc_count;
@@ -975,28 +974,6 @@ int netxen_phantom_init(struct netxen_ad
 	return 0;
 }
 
-int netxen_nic_rx_has_work(struct netxen_adapter *adapter)
-{
-	int ctx;
-
-	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
-		struct netxen_recv_context *recv_ctx =
-		    &(adapter->recv_ctx[ctx]);
-		u32 consumer;
-		struct status_desc *desc_head;
-		struct status_desc *desc;
-
-		consumer = recv_ctx->status_rx_consumer;
-		desc_head = recv_ctx->rcv_status_desc_head;
-		desc = &desc_head[consumer];
-
-		if (netxen_get_sts_owner(desc) & STATUS_OWNER_HOST)
-			return 1;
-	}
-
-	return 0;
-}
-
 static int netxen_nic_check_temp(struct netxen_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -1175,7 +1152,6 @@ static void netxen_process_rcv(struct ne
 
 	netdev->last_rx = jiffies;
 
-	rcv_desc->rcv_free++;
 	rcv_desc->rcv_pending--;
 
 	/*
@@ -1231,23 +1207,22 @@ u32 netxen_process_rcv_ring(struct netxe
 		recv_ctx->status_rx_consumer = consumer;
 		recv_ctx->status_rx_producer = producer;
 
+		smp_wmb();
 		/* Window = 1 */
 		writel(consumer,
 		       NETXEN_CRB_NORMALIZE(adapter,
 					    recv_crb_registers[adapter->portnum].
 					    crb_rcv_status_consumer));
-		wmb();
 	}
 
 	return count;
 }
 
 /* Process Command status ring */
-int netxen_process_cmd_ring(unsigned long data)
+int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 {
 	u32 last_consumer;
 	u32 consumer;
-	struct netxen_adapter *adapter = (struct netxen_adapter *)data;
 	int count1 = 0;
 	int count2 = 0;
 	struct netxen_cmd_buffer *buffer;
@@ -1353,11 +1328,7 @@ int netxen_process_cmd_ring(unsigned lon
 	 * There is still a possible race condition and the host could miss an
 	 * interrupt. The card has to take care of this.
 	 */
-	if (adapter->last_cmd_consumer == consumer &&
-	    (((adapter->cmd_producer + 1) %
-	      adapter->max_tx_desc_count) == adapter->last_cmd_consumer)) {
-		consumer = le32_to_cpu(*(adapter->cmd_consumer));
-	}
+	consumer = le32_to_cpu(*(adapter->cmd_consumer));
 	done = (adapter->last_cmd_consumer == consumer);
 
 	spin_unlock(&adapter->tx_lock);
@@ -1436,8 +1407,6 @@ void netxen_post_rx_buffers(struct netxe
 		rcv_desc->begin_alloc = index;
 		rcv_desc->rcv_pending += count;
 		rcv_desc->producer = producer;
-		if (rcv_desc->rcv_free >= 32) {
-			rcv_desc->rcv_free = 0;
 			/* Window = 1 */
 			writel((producer - 1) &
 			       (rcv_desc->max_rx_desc_count - 1),
@@ -1461,8 +1430,6 @@ void netxen_post_rx_buffers(struct netxe
 			writel(msg,
 			       DB_NORMALIZE(adapter,
 					    NETXEN_RCV_PRODUCER_OFFSET));
-			wmb();
-		}
 	}
 }
 
@@ -1526,8 +1493,6 @@ static void netxen_post_rx_buffers_nodb(
 		rcv_desc->begin_alloc = index;
 		rcv_desc->rcv_pending += count;
 		rcv_desc->producer = producer;
-		if (rcv_desc->rcv_free >= 32) {
-			rcv_desc->rcv_free = 0;
 			/* Window = 1 */
 			writel((producer - 1) &
 			       (rcv_desc->max_rx_desc_count - 1),
@@ -1537,21 +1502,9 @@ static void netxen_post_rx_buffers_nodb(
 						    rcv_desc_crb[ringid].
 						    crb_rcv_producer_offset));
 			wmb();
-		}
 	}
 }
 
-int netxen_nic_tx_has_work(struct netxen_adapter *adapter)
-{
-	if (find_diff_among(adapter->last_cmd_consumer,
-			    adapter->cmd_producer,
-			    adapter->max_tx_desc_count) > 0)
-		return 1;
-
-	return 0;
-}
-
-
 void netxen_nic_clear_stats(struct netxen_adapter *adapter)
 {
 	memset(&adapter->stats, 0, sizeof(adapter->stats));

-- 
