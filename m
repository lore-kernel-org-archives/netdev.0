From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 2/4] [RESEND] netxen: napi and irq cleanup
Date: Mon, 17 Mar 2008 19:59:49 -0700
Message-ID: <1205809191-20901-3-git-send-email-dhananjay@netxen.com>
References: <1205809191-20901-1-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:59172 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752114AbYCRDJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 23:09:19 -0400
In-Reply-To: <1205809191-20901-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o separate and simpler irq handler for msi interrupts, avoids few checks
  than legacy mode.
o avoid redudant tx_has_work() and rx_has_work() checks in interrupt
  and napi, which can uncork irq based on racy (lockless) access to tx
  and rx ring indices. If we get interrupt, there's sufficient reason to
  schedule napi.
o replenish rx ring more often, remove self-imposed threshold rcv_free
  that prevents posting rx desc to card. This improves performance in
  low memory.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
Tested-by: Vernon Mauery <mauery@us.ibm.com>
---
 drivers/net/netxen/netxen_nic.h      |    5 +-
 drivers/net/netxen/netxen_nic_init.c |   76 +---------------------
 drivers/net/netxen/netxen_nic_isr.c  |   17 +----
 drivers/net/netxen/netxen_nic_main.c |  113 ++++++++++++----------------------
 4 files changed, 48 insertions(+), 163 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 876cd06..8b6546c 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -842,7 +842,6 @@ struct netxen_rcv_desc_ctx {
 	u32 flags;
 	u32 producer;
 	u32 rcv_pending;	/* Num of bufs posted in phantom */
-	u32 rcv_free;		/* Num of bufs in free list */
 	dma_addr_t phys_addr;
 	struct pci_dev *phys_pdev;
 	struct rcv_desc *desc_head;	/* address of rx ring in Phantom */
@@ -1076,12 +1075,10 @@ void netxen_tso_check(struct netxen_adapter *adapter,
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
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 43eb1f6..64fc18d 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -185,7 +185,6 @@ void netxen_initialize_adapter_sw(struct netxen_adapter *adapter)
 		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
 			struct netxen_rx_buffer *rx_buf;
 			rcv_desc = &adapter->recv_ctx[ctxid].rcv_desc[ring];
-			rcv_desc->rcv_free = rcv_desc->max_rx_desc_count;
 			rcv_desc->begin_alloc = 0;
 			rx_buf = rcv_desc->rx_buf_arr;
 			num_rx_bufs = rcv_desc->max_rx_desc_count;
@@ -976,28 +975,6 @@ int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
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
@@ -1040,7 +1017,6 @@ static int netxen_nic_check_temp(struct netxen_adapter *adapter)
 
 void netxen_watchdog_task(struct work_struct *work)
 {
-	struct net_device *netdev;
 	struct netxen_adapter *adapter =
 		container_of(work, struct netxen_adapter, watchdog_task);
 
@@ -1050,20 +1026,6 @@ void netxen_watchdog_task(struct work_struct *work)
 	if (adapter->handle_phy_intr)
 		adapter->handle_phy_intr(adapter);
 
-	netdev = adapter->netdev;
-	if ((netif_running(netdev)) && !netif_carrier_ok(netdev) &&
-			netxen_nic_link_ok(adapter) ) {
-		printk(KERN_INFO "%s %s (port %d), Link is up\n",
-			       netxen_nic_driver_name, netdev->name, adapter->portnum);
-		netif_carrier_on(netdev);
-		netif_wake_queue(netdev);
-	} else if(!(netif_running(netdev)) && netif_carrier_ok(netdev)) {
-		printk(KERN_ERR "%s %s Link is Down\n",
-				netxen_nic_driver_name, netdev->name);
-		netif_carrier_off(netdev);
-		netif_stop_queue(netdev);
-	}
-
 	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
 }
 
@@ -1177,7 +1139,6 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 
 	netdev->last_rx = jiffies;
 
-	rcv_desc->rcv_free++;
 	rcv_desc->rcv_pending--;
 
 	/*
@@ -1202,13 +1163,6 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 	u32 producer = 0;
 	int count = 0, ring;
 
-	DPRINTK(INFO, "procesing receive\n");
-	/*
-	 * we assume in this case that there is only one port and that is
-	 * port #1...changes need to be done in firmware to indicate port
-	 * number as part of the descriptor. This way we will be able to get
-	 * the netdev which is associated with that device.
-	 */
 	while (count < max) {
 		desc = &desc_head[consumer];
 		if (!(netxen_get_sts_owner(desc) & STATUS_OWNER_HOST)) {
@@ -1221,10 +1175,8 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 		consumer = (consumer + 1) & (adapter->max_rx_desc_count - 1);
 		count++;
 	}
-	if (count) {
-		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
-			netxen_post_rx_buffers_nodb(adapter, ctxid, ring);
-		}
+	for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
+		netxen_post_rx_buffers_nodb(adapter, ctxid, ring);
 	}
 
 	/* update the consumer index in phantom */
@@ -1235,20 +1187,18 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 		/* Window = 1 */
 		writel(consumer,
 		       NETXEN_CRB_NORMALIZE(adapter,
-					    recv_crb_registers[adapter->portnum].
+				    recv_crb_registers[adapter->portnum].
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
@@ -1435,8 +1385,6 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 		rcv_desc->begin_alloc = index;
 		rcv_desc->rcv_pending += count;
 		rcv_desc->producer = producer;
-		if (rcv_desc->rcv_free >= 32) {
-			rcv_desc->rcv_free = 0;
 			/* Window = 1 */
 			writel((producer - 1) &
 			       (rcv_desc->max_rx_desc_count - 1),
@@ -1460,8 +1408,6 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 			writel(msg,
 			       DB_NORMALIZE(adapter,
 					    NETXEN_RCV_PRODUCER_OFFSET));
-			wmb();
-		}
 	}
 }
 
@@ -1525,8 +1471,6 @@ static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 		rcv_desc->begin_alloc = index;
 		rcv_desc->rcv_pending += count;
 		rcv_desc->producer = producer;
-		if (rcv_desc->rcv_free >= 32) {
-			rcv_desc->rcv_free = 0;
 			/* Window = 1 */
 			writel((producer - 1) &
 			       (rcv_desc->max_rx_desc_count - 1),
@@ -1536,21 +1480,9 @@ static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
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
diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
index 48a404a..1a2333a 100644
--- a/drivers/net/netxen/netxen_nic_isr.c
+++ b/drivers/net/netxen/netxen_nic_isr.c
@@ -193,14 +193,14 @@ int netxen_nic_link_ok(struct netxen_adapter *adapter)
 void netxen_nic_xgbe_handle_phy_intr(struct netxen_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	u32 val, val1;
+	u32 val;
 
 	/* WINDOW = 1 */
 	val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
 	val >>= (physical_port[adapter->portnum] * 8);
-	val1 = val & 0xff;
+	val &= 0xff;
 
-	if (adapter->ahw.xg_linkup == 1 && val1 != XG_LINK_UP) {
+	if (adapter->ahw.xg_linkup == 1 && val != XG_LINK_UP) {
 		printk(KERN_INFO "%s: %s NIC Link is down\n",
 		       netxen_nic_driver_name, netdev->name);
 		adapter->ahw.xg_linkup = 0;
@@ -208,16 +208,7 @@ void netxen_nic_xgbe_handle_phy_intr(struct netxen_adapter *adapter)
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 		}
-		/* read twice to clear sticky bits */
-		/* WINDOW = 0 */
-		netxen_nic_read_w0(adapter, NETXEN_NIU_XG_STATUS, &val1);
-		netxen_nic_read_w0(adapter, NETXEN_NIU_XG_STATUS, &val1);
-
-		if ((val & 0xffb) != 0xffb) {
-			printk(KERN_INFO "%s ISR: Sync/Align BAD: 0x%08x\n",
-			       netxen_nic_driver_name, val1);
-		}
-	} else if (adapter->ahw.xg_linkup == 0 && val1 == XG_LINK_UP) {
+	} else if (adapter->ahw.xg_linkup == 0 && val == XG_LINK_UP) {
 		printk(KERN_INFO "%s: %s NIC Link is up\n",
 		       netxen_nic_driver_name, netdev->name);
 		adapter->ahw.xg_linkup = 1;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index cd665da..9595520 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -63,12 +63,12 @@ static int netxen_nic_xmit_frame(struct sk_buff *, struct net_device *);
 static void netxen_tx_timeout(struct net_device *netdev);
 static void netxen_tx_timeout_task(struct work_struct *work);
 static void netxen_watchdog(unsigned long);
-static int netxen_handle_int(struct netxen_adapter *, struct net_device *);
 static int netxen_nic_poll(struct napi_struct *napi, int budget);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void netxen_nic_poll_controller(struct net_device *netdev);
 #endif
 static irqreturn_t netxen_intr(int irq, void *data);
+static irqreturn_t netxen_msi_intr(int irq, void *data);
 
 int physical_port[] = {0, 1, 2, 3};
 
@@ -405,7 +405,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->set_mac_address    = netxen_nic_set_mac;
 	netdev->change_mtu	   = netxen_nic_change_mtu;
 	netdev->tx_timeout	   = netxen_tx_timeout;
-	netdev->watchdog_timeo     = HZ;
+	netdev->watchdog_timeo     = 2*HZ;
 
 	netxen_nic_change_mtu(netdev, netdev->mtu);
 
@@ -823,6 +823,8 @@ static int netxen_nic_open(struct net_device *netdev)
 	struct netxen_adapter *adapter = (struct netxen_adapter *)netdev->priv;
 	int err = 0;
 	int ctx, ring;
+	irq_handler_t handler;
+	unsigned long flags = IRQF_SAMPLE_RANDOM;
 
 	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC) {
 		err = netxen_init_firmware(adapter);
@@ -846,9 +848,14 @@ static int netxen_nic_open(struct net_device *netdev)
 				netxen_post_rx_buffers(adapter, ctx, ring);
 		}
 		adapter->irq = adapter->ahw.pdev->irq;
-		err = request_irq(adapter->ahw.pdev->irq, netxen_intr,
-				  IRQF_SHARED|IRQF_SAMPLE_RANDOM, netdev->name,
-				  adapter);
+		if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
+			handler = netxen_msi_intr;
+		else {
+			flags |= IRQF_SHARED;
+			handler = netxen_intr;
+		}
+		err = request_irq(adapter->irq, handler,
+				  flags, netdev->name, adapter);
 		if (err) {
 			printk(KERN_ERR "request_irq failed with: %d\n", err);
 			netxen_free_hw_resources(adapter);
@@ -857,21 +864,12 @@ static int netxen_nic_open(struct net_device *netdev)
 
 		adapter->is_up = NETXEN_ADAPTER_UP_MAGIC;
 	}
-	if (!adapter->driver_mismatch)
-		mod_timer(&adapter->watchdog_timer, jiffies);
-
-	napi_enable(&adapter->napi);
-
-	netxen_nic_enable_int(adapter);
-
 	/* Done here again so that even if phantom sw overwrote it,
 	 * we set it */
 	if (adapter->init_port
 	    && adapter->init_port(adapter, adapter->portnum) != 0) {
-	    del_timer_sync(&adapter->watchdog_timer);
 		printk(KERN_ERR "%s: Failed to initialize port %d\n",
 				netxen_nic_driver_name, adapter->portnum);
-		napi_disable(&adapter->napi);
 		return -EIO;
 	}
 	if (adapter->macaddr_set)
@@ -884,6 +882,12 @@ static int netxen_nic_open(struct net_device *netdev)
 		adapter->set_mtu(adapter, netdev->mtu);
 
 	if (!adapter->driver_mismatch)
+		mod_timer(&adapter->watchdog_timer, jiffies);
+
+	napi_enable(&adapter->napi);
+	netxen_nic_enable_int(adapter);
+
+	if (!adapter->driver_mismatch)
 		netif_start_queue(netdev);
 
 	return 0;
@@ -1196,81 +1200,50 @@ static void netxen_tx_timeout_task(struct work_struct *work)
 	netif_wake_queue(adapter->netdev);
 }
 
-static int
-netxen_handle_int(struct netxen_adapter *adapter, struct net_device *netdev)
+static inline void
+netxen_handle_int(struct netxen_adapter *adapter)
 {
-	u32 ret = 0;
-
-	DPRINTK(INFO, "Entered handle ISR\n");
-	adapter->stats.ints++;
-
 	netxen_nic_disable_int(adapter);
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
+	napi_schedule(&adapter->napi);
 }
 
-/*
- * netxen_intr - Interrupt Handler
- * @irq: interrupt number
- * data points to adapter stucture (which may be handling more than 1 port
- */
 irqreturn_t netxen_intr(int irq, void *data)
 {
 	struct netxen_adapter *adapter = data;
-	struct net_device *netdev = adapter->netdev;
 	u32 our_int = 0;
 
-	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
-		our_int = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
-		/* not our interrupt */
-		if ((our_int & (0x80 << adapter->portnum)) == 0)
-			return IRQ_NONE;
-	}
+	our_int = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
+	/* not our interrupt */
+	if ((our_int & (0x80 << adapter->portnum)) == 0)
+		return IRQ_NONE;
 
 	if (adapter->intr_scheme == INTR_SCHEME_PERPORT) {
 		/* claim interrupt */
-		if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
-			writel(our_int & ~((u32)(0x80 << adapter->portnum)),
+		writel(our_int & ~((u32)(0x80 << adapter->portnum)),
 			NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
-		}
 	}
 
-	if (netif_running(netdev))
-		netxen_handle_int(adapter, netdev);
+	netxen_handle_int(adapter);
 
 	return IRQ_HANDLED;
 }
 
+irqreturn_t netxen_msi_intr(int irq, void *data)
+{
+	struct netxen_adapter *adapter = data;
+
+	netxen_handle_int(adapter);
+	return IRQ_HANDLED;
+}
+
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
@@ -1290,16 +1263,8 @@ static int netxen_nic_poll(struct napi_struct *napi, int budget)
 						     budget / MAX_RCV_CTX);
 	}
 
-	if (work_done >= budget)
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
 
-- 
1.5.4

