From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH 2.6.37-rc1] net-next: Add multiqueue support to vmxnet3
 driver
Date: Fri, 19 Nov 2010 10:46:59 -0800 (PST)
Message-ID: <alpine.LRH.2.00.1011191023500.8304@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Shreyas Bhatewara <sbhatewara@vmware.com>

Add multiqueue support to vmxnet3 driver

This change adds multiqueue and thus receive side scaling support
to vmxnet3 device driver. Number of rx queues is limited to 1 in cases
where MSI is not configured or one MSIx vector is not available per rx 
queue

Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
Reviewed-by: Bhavesh Davda <bhavesh@vmware.com>

---

On Wed, 17 Nov 2010, David Miller wrote:

> 
> It should be turned on by default, otherwise don't add the code until
> it's "ready."

Okay, posting a patch with multiqueue turned on by default.

> 
> We had slight performance regressions in the past when various drivers
> added multiqueue support, but the aggregate performance increased for
> multi-flow cases, and this was deemed a fine tradeoff.  I was hoping
> you'd use similar logic.

Yes, we have experienced the same at our end. There is a minor 
performance regression in few cases. For example, in the table below : rx 
throughput is almost the same but CPU utilization has increased in some 
cases. 

        |             Transmit            |              Receive             |
msg/soc |Throughput Mbps|      CPU        |Throughput Mbps |        CPU      |
size    |---------------+-----------------+----------------+-----------------|
        | mq |nomq|%Gain| mq  |Nomq |%Gain| mq |nomq|%Gain | mq  |nomq |%Gain|
--------+----+----+-----+-----+-----+-----+----+----+------+-----+-----+------
32K/32K |2245|2113|6.255|0.9  |0.9  |0    |2001|2006|-0.240|1.045|1.088|4.114|
32K/32K |2283|2111|8.183|0.864|0.896|3.70 |2029|2020|0.4359|1.117|1.075|-3.76|
64K/64K |2251|2094|7.522|0.837|0.879|5.01 |2036|2019|0.8104|1.085|1.096|1.013|
64L/64K |2251|2112|6.596|0.855|0.855|0    |1998|2008|-0.534|1.055|1.032|-2.18|


> 
> Otherwise, send this stuff when it's ready, and no sooner.
> 

The patch is ready. 

Ben, Thanks for taking a look. Your comments have been incorporated in 
this patch.




diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 21314e0..429627f 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -44,6 +44,9 @@ MODULE_DEVICE_TABLE(pci, vmxnet3_pciid_table);
 
 static atomic_t devices_found;
 
+#define VMXNET3_MAX_DEVICES 10
+static int enable_mq = 1;
+static int irq_share_mode;
 
 /*
  *    Enable/Disable the given intr
@@ -99,7 +102,7 @@ vmxnet3_ack_events(struct vmxnet3_adapter *adapter, u32 events)
 static bool
 vmxnet3_tq_stopped(struct vmxnet3_tx_queue *tq, struct vmxnet3_adapter *adapter)
 {
-	return netif_queue_stopped(adapter->netdev);
+	return tq->stopped;

 }
 
 
@@ -107,7 +110,7 @@ static void
 vmxnet3_tq_start(struct vmxnet3_tx_queue *tq, struct vmxnet3_adapter *adapter)
 {
 	tq->stopped = false;
-	netif_start_queue(adapter->netdev);
+	netif_start_subqueue(adapter->netdev, tq - adapter->tx_queue);
 }
 
 
@@ -115,7 +118,7 @@ static void
 vmxnet3_tq_wake(struct vmxnet3_tx_queue *tq, struct vmxnet3_adapter *adapter)
 {
 	tq->stopped = false;
-	netif_wake_queue(adapter->netdev);
+	netif_wake_subqueue(adapter->netdev, (tq - adapter->tx_queue));
 }
 
 
@@ -124,7 +127,7 @@ vmxnet3_tq_stop(struct vmxnet3_tx_queue *tq, struct vmxnet3_adapter *adapter)
 {
 	tq->stopped = true;
 	tq->num_stop++;
-	netif_stop_queue(adapter->netdev);
+	netif_stop_subqueue(adapter->netdev, (tq - adapter->tx_queue));
 }
 
 
@@ -135,6 +138,7 @@ static void
 vmxnet3_check_link(struct vmxnet3_adapter *adapter, bool affectTxQueue)
 {
 	u32 ret;
+	int i;
 
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD, VMXNET3_CMD_GET_LINK);
 	ret = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_CMD);
@@ -145,22 +149,28 @@ vmxnet3_check_link(struct vmxnet3_adapter *adapter, bool affectTxQueue)
 		if (!netif_carrier_ok(adapter->netdev))
 			netif_carrier_on(adapter->netdev);
 
-		if (affectTxQueue)
-			vmxnet3_tq_start(&adapter->tx_queue, adapter);
+		if (affectTxQueue) {
+			for (i = 0; i < adapter->num_tx_queues; i++)
+				vmxnet3_tq_start(&adapter->tx_queue[i],
+						 adapter);
+		}
 	} else {
 		printk(KERN_INFO "%s: NIC Link is Down\n",
 		       adapter->netdev->name);
 		if (netif_carrier_ok(adapter->netdev))
 			netif_carrier_off(adapter->netdev);
 
-		if (affectTxQueue)
-			vmxnet3_tq_stop(&adapter->tx_queue, adapter);
+		if (affectTxQueue) {
+			for (i = 0; i < adapter->num_tx_queues; i++)
+				vmxnet3_tq_stop(&adapter->tx_queue[i], adapter);
+		}
 	}
 }
 
 static void
 vmxnet3_process_events(struct vmxnet3_adapter *adapter)
 {
+	int i;
 	u32 events = le32_to_cpu(adapter->shared->ecr);
 	if (!events)
 		return;
@@ -176,16 +186,18 @@ vmxnet3_process_events(struct vmxnet3_adapter *adapter)
 		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 				       VMXNET3_CMD_GET_QUEUE_STATUS);
 
-		if (adapter->tqd_start->status.stopped) {
-			printk(KERN_ERR "%s: tq error 0x%x\n",
-			       adapter->netdev->name,
-			       le32_to_cpu(adapter->tqd_start->status.error));
-		}
-		if (adapter->rqd_start->status.stopped) {
-			printk(KERN_ERR "%s: rq error 0x%x\n",
-			       adapter->netdev->name,
-			       adapter->rqd_start->status.error);
-		}
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			if (adapter->tqd_start[i].status.stopped)
+				dev_err(&adapter->netdev->dev,
+					"%s: tq[%d] error 0x%x\n",
+					adapter->netdev->name, i, le32_to_cpu(
+					adapter->tqd_start[i].status.error));
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			if (adapter->rqd_start[i].status.stopped)
+				dev_err(&adapter->netdev->dev,
+					"%s: rq[%d] error 0x%x\n",
+					adapter->netdev->name, i,
+					adapter->rqd_start[i].status.error);
 
 		schedule_work(&adapter->work);
 	}
@@ -410,7 +422,7 @@ vmxnet3_tq_cleanup(struct vmxnet3_tx_queue *tq,
 }
 
 
-void
+static void
 vmxnet3_tq_destroy(struct vmxnet3_tx_queue *tq,
 		   struct vmxnet3_adapter *adapter)
 {
@@ -437,6 +449,17 @@ vmxnet3_tq_destroy(struct vmxnet3_tx_queue *tq,
 }
 
 
+/* Destroy all tx queues */
+void
+vmxnet3_tq_destroy_all(struct vmxnet3_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		vmxnet3_tq_destroy(&adapter->tx_queue[i], adapter);
+}
+
+
 static void
 vmxnet3_tq_init(struct vmxnet3_tx_queue *tq,
 		struct vmxnet3_adapter *adapter)
@@ -518,6 +541,14 @@ err:
 	return -ENOMEM;
 }
 
+static void
+vmxnet3_tq_cleanup_all(struct vmxnet3_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		vmxnet3_tq_cleanup(&adapter->tx_queue[i], adapter);
+}
 
 /*
  *    starting from ring->next2fill, allocate rx buffers for the given ring
@@ -732,6 +763,17 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx *ctx,
 }
 
 
+/* Init all tx queues */
+static void
+vmxnet3_tq_init_all(struct vmxnet3_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		vmxnet3_tq_init(&adapter->tx_queue[i], adapter);
+}
+
+
 /*
  *    parse and copy relevant protocol headers:
  *      For a tso pkt, relevant headers are L2/3/4 including options
@@ -903,6 +945,21 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 		}
 	}
 
+	spin_lock_irqsave(&tq->tx_lock, flags);
+
+	if (count > vmxnet3_cmd_ring_desc_avail(&tq->tx_ring)) {
+		tq->stats.tx_ring_full++;
+		dev_dbg(&adapter->netdev->dev,
+			"tx queue stopped on %s, next2comp %u"
+			" next2fill %u\n", adapter->netdev->name,
+			tq->tx_ring.next2comp, tq->tx_ring.next2fill);
+
+		vmxnet3_tq_stop(tq, adapter);
+		spin_unlock_irqrestore(&tq->tx_lock, flags);
+		return NETDEV_TX_BUSY;
+	}
+
+
 	ret = vmxnet3_parse_and_copy_hdr(skb, tq, &ctx, adapter);
 	if (ret >= 0) {
 		BUG_ON(ret <= 0 && ctx.copy_size != 0);
@@ -926,20 +983,6 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 		goto drop_pkt;
 	}
 
-	spin_lock_irqsave(&tq->tx_lock, flags);
-
-	if (count > vmxnet3_cmd_ring_desc_avail(&tq->tx_ring)) {
-		tq->stats.tx_ring_full++;
-		dev_dbg(&adapter->netdev->dev,
-			"tx queue stopped on %s, next2comp %u"
-			" next2fill %u\n", adapter->netdev->name,
-			tq->tx_ring.next2comp, tq->tx_ring.next2fill);
-
-		vmxnet3_tq_stop(tq, adapter);
-		spin_unlock_irqrestore(&tq->tx_lock, flags);
-		return NETDEV_TX_BUSY;
-	}
-
 	/* fill tx descs related to addr & len */
 	vmxnet3_map_pkt(skb, &ctx, tq, adapter->pdev, adapter);
 
@@ -1000,7 +1043,8 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 	if (le32_to_cpu(tq->shared->txNumDeferred) >=
 					le32_to_cpu(tq->shared->txThreshold)) {
 		tq->shared->txNumDeferred = 0;
-		VMXNET3_WRITE_BAR0_REG(adapter, VMXNET3_REG_TXPROD,
+		VMXNET3_WRITE_BAR0_REG(adapter,
+				       VMXNET3_REG_TXPROD + tq->qid * 8,
 				       tq->tx_ring.next2fill);
 	}
 
@@ -1020,7 +1064,10 @@ vmxnet3_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 
-	return vmxnet3_tq_xmit(skb, &adapter->tx_queue, adapter, netdev);
+		BUG_ON(skb->queue_mapping > adapter->num_tx_queues);
+		return vmxnet3_tq_xmit(skb,
+				       &adapter->tx_queue[skb->queue_mapping],
+				       adapter, netdev);
 }
 
 
@@ -1106,9 +1153,9 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 			break;
 		}
 		num_rxd++;
-
+		BUG_ON(rcd->rqID != rq->qid && rcd->rqID != rq->qid2);
 		idx = rcd->rxdIdx;
-		ring_idx = rcd->rqID == rq->qid ? 0 : 1;
+		ring_idx = rcd->rqID < adapter->num_rx_queues ? 0 : 1;
 		vmxnet3_getRxDesc(rxd, &rq->rx_ring[ring_idx].base[idx].rxd,
 				  &rxCmdDesc);
 		rbi = rq->buf_info[ring_idx] + idx;
@@ -1260,6 +1307,16 @@ vmxnet3_rq_cleanup(struct vmxnet3_rx_queue *rq,
 }
 
 
+static void
+vmxnet3_rq_cleanup_all(struct vmxnet3_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		vmxnet3_rq_cleanup(&adapter->rx_queue[i], adapter);
+}
+
+
 void vmxnet3_rq_destroy(struct vmxnet3_rx_queue *rq,
 			struct vmxnet3_adapter *adapter)
 {
@@ -1351,6 +1408,25 @@ vmxnet3_rq_init(struct vmxnet3_rx_queue *rq,
 
 
 static int
+vmxnet3_rq_init_all(struct vmxnet3_adapter *adapter)
+{
+	int i, err = 0;
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		err = vmxnet3_rq_init(&adapter->rx_queue[i], adapter);
+		if (unlikely(err)) {
+			dev_err(&adapter->netdev->dev, "%s: failed to "
+				"initialize rx queue%i\n",
+				adapter->netdev->name, i);
+			break;
+		}
+	}
+	return err;
+
+}
+
+
+static int
 vmxnet3_rq_create(struct vmxnet3_rx_queue *rq, struct vmxnet3_adapter *adapter)
 {
 	int i;
@@ -1398,33 +1474,177 @@ err:
 
 
 static int
+vmxnet3_rq_create_all(struct vmxnet3_adapter *adapter)
+{
+	int i, err = 0;
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		err = vmxnet3_rq_create(&adapter->rx_queue[i], adapter);
+		if (unlikely(err)) {
+			dev_err(&adapter->netdev->dev,
+				"%s: failed to create rx queue%i\n",
+				adapter->netdev->name, i);
+			goto err_out;
+		}
+	}
+	return err;
+err_out:
+	vmxnet3_rq_destroy_all(adapter);
+	return err;
+
+}
+
+/* Multiple queue aware polling function for tx and rx */
+
+static int
 vmxnet3_do_poll(struct vmxnet3_adapter *adapter, int budget)
 {
+	int rcd_done = 0, i;
 	if (unlikely(adapter->shared->ecr))
 		vmxnet3_process_events(adapter);
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		vmxnet3_tq_tx_complete(&adapter->tx_queue[i], adapter);
 
-	vmxnet3_tq_tx_complete(&adapter->tx_queue, adapter);
-	return vmxnet3_rq_rx_complete(&adapter->rx_queue, adapter, budget);
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		rcd_done += vmxnet3_rq_rx_complete(&adapter->rx_queue[i],
+						   adapter, budget);
+	return rcd_done;
 }
 
 
 static int
 vmxnet3_poll(struct napi_struct *napi, int budget)
 {
-	struct vmxnet3_adapter *adapter = container_of(napi,
-					  struct vmxnet3_adapter, napi);
+	struct vmxnet3_rx_queue *rx_queue = container_of(napi,
+					  struct vmxnet3_rx_queue, napi);
+	int rxd_done;
+
+	rxd_done = vmxnet3_do_poll(rx_queue->adapter, budget);
+
+	if (rxd_done < budget) {
+		napi_complete(napi);
+		vmxnet3_enable_all_intrs(rx_queue->adapter);
+	}
+	return rxd_done;
+}
+
+/*
+ * NAPI polling function for MSI-X mode with multiple Rx queues
+ * Returns the # of the NAPI credit consumed (# of rx descriptors processed)
+ */
+
+static int
+vmxnet3_poll_rx_only(struct napi_struct *napi, int budget)
+{
+	struct vmxnet3_rx_queue *rq = container_of(napi,
+						struct vmxnet3_rx_queue, napi);
+	struct vmxnet3_adapter *adapter = rq->adapter;
 	int rxd_done;
 
-	rxd_done = vmxnet3_do_poll(adapter, budget);
+	/* When sharing interrupt with corresponding tx queue, process
+	 * tx completions in that queue as well
+	 */
+	if (adapter->share_intr == VMXNET3_INTR_BUDDYSHARE) {
+		struct vmxnet3_tx_queue *tq =
+				&adapter->tx_queue[rq - adapter->rx_queue];
+		vmxnet3_tq_tx_complete(tq, adapter);
+	}
+
+	rxd_done = vmxnet3_rq_rx_complete(rq, adapter, budget);
 
 	if (rxd_done < budget) {
 		napi_complete(napi);
-		vmxnet3_enable_intr(adapter, 0);
+		vmxnet3_enable_intr(adapter, rq->comp_ring.intr_idx);
 	}
 	return rxd_done;
 }
 
 
+#ifdef CONFIG_PCI_MSI
+
+/*
+ * Handle completion interrupts on tx queues
+ * Returns whether or not the intr is handled
+ */
+
+static irqreturn_t
+vmxnet3_msix_tx(int irq, void *data)
+{
+	struct vmxnet3_tx_queue *tq = data;
+	struct vmxnet3_adapter *adapter = tq->adapter;
+
+	if (adapter->intr.mask_mode == VMXNET3_IMM_ACTIVE)
+		vmxnet3_disable_intr(adapter, tq->comp_ring.intr_idx);
+
+	/* Handle the case where only one irq is allocate for all tx queues */
+	if (adapter->share_intr == VMXNET3_INTR_TXSHARE) {
+		int i;
+		for (i = 0; i < adapter->num_tx_queues; i++) {
+			struct vmxnet3_tx_queue *txq = &adapter->tx_queue[i];
+			vmxnet3_tq_tx_complete(txq, adapter);
+		}
+	} else {
+		vmxnet3_tq_tx_complete(tq, adapter);
+	}
+	vmxnet3_enable_intr(adapter, tq->comp_ring.intr_idx);
+
+	return IRQ_HANDLED;
+}
+
+
+/*
+ * Handle completion interrupts on rx queues. Returns whether or not the
+ * intr is handled
+ */
+
+static irqreturn_t
+vmxnet3_msix_rx(int irq, void *data)
+{
+	struct vmxnet3_rx_queue *rq = data;
+	struct vmxnet3_adapter *adapter = rq->adapter;
+
+	/* disable intr if needed */
+	if (adapter->intr.mask_mode == VMXNET3_IMM_ACTIVE)
+		vmxnet3_disable_intr(adapter, rq->comp_ring.intr_idx);
+	napi_schedule(&rq->napi);
+
+	return IRQ_HANDLED;
+}
+
+/*
+ *----------------------------------------------------------------------------
+ *
+ * vmxnet3_msix_event --
+ *
+ *    vmxnet3 msix event intr handler
+ *
+ * Result:
+ *    whether or not the intr is handled
+ *
+ *----------------------------------------------------------------------------
+ */
+
+static irqreturn_t
+vmxnet3_msix_event(int irq, void *data)
+{
+	struct net_device *dev = data;
+	struct vmxnet3_adapter *adapter = netdev_priv(dev);
+
+	/* disable intr if needed */
+	if (adapter->intr.mask_mode == VMXNET3_IMM_ACTIVE)
+		vmxnet3_disable_intr(adapter, adapter->intr.event_intr_idx);
+
+	if (adapter->shared->ecr)
+		vmxnet3_process_events(adapter);
+
+	vmxnet3_enable_intr(adapter, adapter->intr.event_intr_idx);
+
+	return IRQ_HANDLED;
+}
+
+#endif /* CONFIG_PCI_MSI  */
+
+
 /* Interrupt handler for vmxnet3  */
 static irqreturn_t
 vmxnet3_intr(int irq, void *dev_id)
@@ -1432,7 +1652,7 @@ vmxnet3_intr(int irq, void *dev_id)
 	struct net_device *dev = dev_id;
 	struct vmxnet3_adapter *adapter = netdev_priv(dev);
 
-	if (unlikely(adapter->intr.type == VMXNET3_IT_INTX)) {
+	if (adapter->intr.type == VMXNET3_IT_INTX) {
 		u32 icr = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_ICR);
 		if (unlikely(icr == 0))
 			/* not ours */
@@ -1442,77 +1662,144 @@ vmxnet3_intr(int irq, void *dev_id)
 
 	/* disable intr if needed */
 	if (adapter->intr.mask_mode == VMXNET3_IMM_ACTIVE)
-		vmxnet3_disable_intr(adapter, 0);
+		vmxnet3_disable_all_intrs(adapter);
 
-	napi_schedule(&adapter->napi);
+	napi_schedule(&adapter->rx_queue[0].napi);
 
 	return IRQ_HANDLED;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 
-
 /* netpoll callback. */
 static void
 vmxnet3_netpoll(struct net_device *netdev)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
-	int irq;
 
-#ifdef CONFIG_PCI_MSI
-	if (adapter->intr.type == VMXNET3_IT_MSIX)
-		irq = adapter->intr.msix_entries[0].vector;
-	else
-#endif
-		irq = adapter->pdev->irq;
+	if (adapter->intr.mask_mode == VMXNET3_IMM_ACTIVE)
+		vmxnet3_disable_all_intrs(adapter);
+
+	vmxnet3_do_poll(adapter, adapter->rx_queue[0].rx_ring[0].size);
+	vmxnet3_enable_all_intrs(adapter);
 
-	disable_irq(irq);
-	vmxnet3_intr(irq, netdev);
-	enable_irq(irq);
 }
-#endif
+#endif	/* CONFIG_NET_POLL_CONTROLLER */
 
 static int
 vmxnet3_request_irqs(struct vmxnet3_adapter *adapter)
 {
-	int err;
+	struct vmxnet3_intr *intr = &adapter->intr;
+	int err = 0, i;
+	int vector = 0;
 
 #ifdef CONFIG_PCI_MSI
 	if (adapter->intr.type == VMXNET3_IT_MSIX) {
-		/* we only use 1 MSI-X vector */
-		err = request_irq(adapter->intr.msix_entries[0].vector,
-				  vmxnet3_intr, 0, adapter->netdev->name,
-				  adapter->netdev);
-	} else if (adapter->intr.type == VMXNET3_IT_MSI) {
+		for (i = 0; i < adapter->num_tx_queues; i++) {
+			if (adapter->share_intr != VMXNET3_INTR_BUDDYSHARE) {
+				sprintf(adapter->tx_queue[i].name, "%s-tx-%d",
+					adapter->netdev->name, vector);
+				err = request_irq(
+					      intr->msix_entries[vector].vector,
+					      vmxnet3_msix_tx, 0,
+					      adapter->tx_queue[i].name,
+					      &adapter->tx_queue[i]);
+			} else {
+				sprintf(adapter->tx_queue[i].name, "%s-rxtx-%d",
+					adapter->netdev->name, vector);
+			}
+			if (err) {
+				dev_err(&adapter->netdev->dev,
+					"Failed to request irq for MSIX, %s, "
+					"error %d\n",
+					adapter->tx_queue[i].name, err);
+				return err;
+			}
+
+			/* Handle the case where only 1 MSIx was allocated for
+			 * all tx queues */
+			if (adapter->share_intr == VMXNET3_INTR_TXSHARE) {
+				for (; i < adapter->num_tx_queues; i++)
+					adapter->tx_queue[i].comp_ring.intr_idx
+								= vector;
+				vector++;
+				break;
+			} else {
+				adapter->tx_queue[i].comp_ring.intr_idx
+								= vector++;
+			}
+		}
+		if (adapter->share_intr == VMXNET3_INTR_BUDDYSHARE)
+			vector = 0;
+
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+			if (adapter->share_intr != VMXNET3_INTR_BUDDYSHARE)
+				sprintf(adapter->rx_queue[i].name, "%s-rx-%d",
+					adapter->netdev->name, vector);
+			else
+				sprintf(adapter->rx_queue[i].name, "%s-rxtx-%d",
+					adapter->netdev->name, vector);
+			err = request_irq(intr->msix_entries[vector].vector,
+					  vmxnet3_msix_rx, 0,
+					  adapter->rx_queue[i].name,
+					  &(adapter->rx_queue[i]));
+			if (err) {
+				printk(KERN_ERR "Failed to request irq for MSIX"
+				       ", %s, error %d\n",
+				       adapter->rx_queue[i].name, err);
+				return err;
+			}
+
+			adapter->rx_queue[i].comp_ring.intr_idx = vector++;
+		}
+
+		sprintf(intr->event_msi_vector_name, "%s-event-%d",
+			adapter->netdev->name, vector);
+		err = request_irq(intr->msix_entries[vector].vector,
+				  vmxnet3_msix_event, 0,
+				  intr->event_msi_vector_name, adapter->netdev);
+		intr->event_intr_idx = vector;
+
+	} else if (intr->type == VMXNET3_IT_MSI) {
+		adapter->num_rx_queues = 1;
 		err = request_irq(adapter->pdev->irq, vmxnet3_intr, 0,
 				  adapter->netdev->name, adapter->netdev);
-	} else
+	} else {
 #endif
-	{
+		adapter->num_rx_queues = 1;
 		err = request_irq(adapter->pdev->irq, vmxnet3_intr,
 				  IRQF_SHARED, adapter->netdev->name,
 				  adapter->netdev);
+#ifdef CONFIG_PCI_MSI
 	}
-
-	if (err)
+#endif
+	intr->num_intrs = vector + 1;
+	if (err) {
 		printk(KERN_ERR "Failed to request irq %s (intr type:%d), error"
-		       ":%d\n", adapter->netdev->name, adapter->intr.type, err);
+		       ":%d\n", adapter->netdev->name, intr->type, err);
+	} else {
+		/* Number of rx queues will not change after this */
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+			struct vmxnet3_rx_queue *rq = &adapter->rx_queue[i];
+			rq->qid = i;
+			rq->qid2 = i + adapter->num_rx_queues;
+		}
 
 
-	if (!err) {
-		int i;
-		/* init our intr settings */
-		for (i = 0; i < adapter->intr.num_intrs; i++)
-			adapter->intr.mod_levels[i] = UPT1_IML_ADAPTIVE;
 
-		/* next setup intr index for all intr sources */
-		adapter->tx_queue.comp_ring.intr_idx = 0;
-		adapter->rx_queue.comp_ring.intr_idx = 0;
-		adapter->intr.event_intr_idx = 0;
+		/* init our intr settings */
+		for (i = 0; i < intr->num_intrs; i++)
+			intr->mod_levels[i] = UPT1_IML_ADAPTIVE;
+		if (adapter->intr.type != VMXNET3_IT_MSIX) {
+			adapter->intr.event_intr_idx = 0;
+			for (i = 0; i < adapter->num_tx_queues; i++)
+				adapter->tx_queue[i].comp_ring.intr_idx = 0;
+			adapter->rx_queue[0].comp_ring.intr_idx = 0;
+		}
 
 		printk(KERN_INFO "%s: intr type %u, mode %u, %u vectors "
-		       "allocated\n", adapter->netdev->name, adapter->intr.type,
-		       adapter->intr.mask_mode, adapter->intr.num_intrs);
+		       "allocated\n", adapter->netdev->name, intr->type,
+		       intr->mask_mode, intr->num_intrs);
 	}
 
 	return err;
@@ -1522,18 +1809,32 @@ vmxnet3_request_irqs(struct vmxnet3_adapter *adapter)
 static void
 vmxnet3_free_irqs(struct vmxnet3_adapter *adapter)
 {
-	BUG_ON(adapter->intr.type == VMXNET3_IT_AUTO ||
-	       adapter->intr.num_intrs <= 0);
+	struct vmxnet3_intr *intr = &adapter->intr;
+	BUG_ON(intr->type == VMXNET3_IT_AUTO || intr->num_intrs <= 0);
 
-	switch (adapter->intr.type) {
+	switch (intr->type) {
 #ifdef CONFIG_PCI_MSI
 	case VMXNET3_IT_MSIX:
 	{
-		int i;
+		int i, vector = 0;
+
+		if (adapter->share_intr != VMXNET3_INTR_BUDDYSHARE) {
+			for (i = 0; i < adapter->num_tx_queues; i++) {
+				free_irq(intr->msix_entries[vector++].vector,
+					 &(adapter->tx_queue[i]));
+				if (adapter->share_intr == VMXNET3_INTR_TXSHARE)
+					break;
+			}
+		}
+
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+			free_irq(intr->msix_entries[vector++].vector,
+				 &(adapter->rx_queue[i]));
+		}
 
-		for (i = 0; i < adapter->intr.num_intrs; i++)
-			free_irq(adapter->intr.msix_entries[i].vector,
-				 adapter->netdev);
+		free_irq(intr->msix_entries[vector].vector,
+			 adapter->netdev);
+		BUG_ON(vector >= intr->num_intrs);
 		break;
 	}
 #endif
@@ -1727,6 +2028,15 @@ vmxnet3_set_mc(struct net_device *netdev)
 	kfree(new_table);
 }
 
+void
+vmxnet3_rq_destroy_all(struct vmxnet3_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		vmxnet3_rq_destroy(&adapter->rx_queue[i], adapter);
+}
+
 
 /*
  *   Set up driver_shared based on settings in adapter.
@@ -1774,40 +2084,72 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 	devRead->misc.mtu = cpu_to_le32(adapter->netdev->mtu);
 	devRead->misc.queueDescPA = cpu_to_le64(adapter->queue_desc_pa);
 	devRead->misc.queueDescLen = cpu_to_le32(
-				     sizeof(struct Vmxnet3_TxQueueDesc) +
-				     sizeof(struct Vmxnet3_RxQueueDesc));
+		adapter->num_tx_queues * sizeof(struct Vmxnet3_TxQueueDesc) +
+		adapter->num_rx_queues * sizeof(struct Vmxnet3_RxQueueDesc));
 
 	/* tx queue settings */
-	BUG_ON(adapter->tx_queue.tx_ring.base == NULL);
-
-	devRead->misc.numTxQueues = 1;
-	tqc = &adapter->tqd_start->conf;
-	tqc->txRingBasePA   = cpu_to_le64(adapter->tx_queue.tx_ring.basePA);
-	tqc->dataRingBasePA = cpu_to_le64(adapter->tx_queue.data_ring.basePA);
-	tqc->compRingBasePA = cpu_to_le64(adapter->tx_queue.comp_ring.basePA);
-	tqc->ddPA           = cpu_to_le64(virt_to_phys(
-						adapter->tx_queue.buf_info));
-	tqc->txRingSize     = cpu_to_le32(adapter->tx_queue.tx_ring.size);
-	tqc->dataRingSize   = cpu_to_le32(adapter->tx_queue.data_ring.size);
-	tqc->compRingSize   = cpu_to_le32(adapter->tx_queue.comp_ring.size);
-	tqc->ddLen          = cpu_to_le32(sizeof(struct vmxnet3_tx_buf_info) *
-			      tqc->txRingSize);
-	tqc->intrIdx        = adapter->tx_queue.comp_ring.intr_idx;
+	devRead->misc.numTxQueues =  adapter->num_tx_queues;
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		struct vmxnet3_tx_queue	*tq = &adapter->tx_queue[i];
+		BUG_ON(adapter->tx_queue[i].tx_ring.base == NULL);
+		tqc = &adapter->tqd_start[i].conf;
+		tqc->txRingBasePA   = cpu_to_le64(tq->tx_ring.basePA);
+		tqc->dataRingBasePA = cpu_to_le64(tq->data_ring.basePA);
+		tqc->compRingBasePA = cpu_to_le64(tq->comp_ring.basePA);
+		tqc->ddPA           = cpu_to_le64(virt_to_phys(tq->buf_info));
+		tqc->txRingSize     = cpu_to_le32(tq->tx_ring.size);
+		tqc->dataRingSize   = cpu_to_le32(tq->data_ring.size);
+		tqc->compRingSize   = cpu_to_le32(tq->comp_ring.size);
+		tqc->ddLen          = cpu_to_le32(
+					sizeof(struct vmxnet3_tx_buf_info) *
+					tqc->txRingSize);
+		tqc->intrIdx        = tq->comp_ring.intr_idx;
+	}
 
 	/* rx queue settings */
-	devRead->misc.numRxQueues = 1;
-	rqc = &adapter->rqd_start->conf;
-	rqc->rxRingBasePA[0] = cpu_to_le64(adapter->rx_queue.rx_ring[0].basePA);
-	rqc->rxRingBasePA[1] = cpu_to_le64(adapter->rx_queue.rx_ring[1].basePA);
-	rqc->compRingBasePA  = cpu_to_le64(adapter->rx_queue.comp_ring.basePA);
-	rqc->ddPA            = cpu_to_le64(virt_to_phys(
-						adapter->rx_queue.buf_info));
-	rqc->rxRingSize[0]   = cpu_to_le32(adapter->rx_queue.rx_ring[0].size);
-	rqc->rxRingSize[1]   = cpu_to_le32(adapter->rx_queue.rx_ring[1].size);
-	rqc->compRingSize    = cpu_to_le32(adapter->rx_queue.comp_ring.size);
-	rqc->ddLen           = cpu_to_le32(sizeof(struct vmxnet3_rx_buf_info) *
-			       (rqc->rxRingSize[0] + rqc->rxRingSize[1]));
-	rqc->intrIdx         = adapter->rx_queue.comp_ring.intr_idx;
+	devRead->misc.numRxQueues = adapter->num_rx_queues;
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		struct vmxnet3_rx_queue	*rq = &adapter->rx_queue[i];
+		rqc = &adapter->rqd_start[i].conf;
+		rqc->rxRingBasePA[0] = cpu_to_le64(rq->rx_ring[0].basePA);
+		rqc->rxRingBasePA[1] = cpu_to_le64(rq->rx_ring[1].basePA);
+		rqc->compRingBasePA  = cpu_to_le64(rq->comp_ring.basePA);
+		rqc->ddPA            = cpu_to_le64(virt_to_phys(
+							rq->buf_info));
+		rqc->rxRingSize[0]   = cpu_to_le32(rq->rx_ring[0].size);
+		rqc->rxRingSize[1]   = cpu_to_le32(rq->rx_ring[1].size);
+		rqc->compRingSize    = cpu_to_le32(rq->comp_ring.size);
+		rqc->ddLen           = cpu_to_le32(
+					sizeof(struct vmxnet3_rx_buf_info) *
+					(rqc->rxRingSize[0] +
+					 rqc->rxRingSize[1]));
+		rqc->intrIdx         = rq->comp_ring.intr_idx;
+	}
+
+#ifdef VMXNET3_RSS
+	memset(adapter->rss_conf, 0, sizeof(*adapter->rss_conf));
+
+	if (adapter->rss) {
+		struct UPT1_RSSConf *rssConf = adapter->rss_conf;
+		devRead->misc.uptFeatures |= UPT1_F_RSS;
+		devRead->misc.numRxQueues = adapter->num_rx_queues;
+		rssConf->hashType = UPT1_RSS_HASH_TYPE_TCP_IPV4 |
+				    UPT1_RSS_HASH_TYPE_IPV4 |
+				    UPT1_RSS_HASH_TYPE_TCP_IPV6 |
+				    UPT1_RSS_HASH_TYPE_IPV6;
+		rssConf->hashFunc = UPT1_RSS_HASH_FUNC_TOEPLITZ;
+		rssConf->hashKeySize = UPT1_RSS_MAX_KEY_SIZE;
+		rssConf->indTableSize = VMXNET3_RSS_IND_TABLE_SIZE;
+		get_random_bytes(&rssConf->hashKey[0], rssConf->hashKeySize);
+		for (i = 0; i < rssConf->indTableSize; i++)
+			rssConf->indTable[i] = i % adapter->num_rx_queues;
+
+		devRead->rssConfDesc.confVer = 1;
+		devRead->rssConfDesc.confLen = sizeof(*rssConf);
+		devRead->rssConfDesc.confPA  = virt_to_phys(rssConf);
+	}
+
+#endif /* VMXNET3_RSS */
 
 	/* intr settings */
 	devRead->intrConf.autoMask = adapter->intr.mask_mode ==
@@ -1829,18 +2171,18 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 int
 vmxnet3_activate_dev(struct vmxnet3_adapter *adapter)
 {
-	int err;
+	int err, i;
 	u32 ret;
 
-	dev_dbg(&adapter->netdev->dev,
-		"%s: skb_buf_size %d, rx_buf_per_pkt %d, ring sizes"
-		" %u %u %u\n", adapter->netdev->name, adapter->skb_buf_size,
-		adapter->rx_buf_per_pkt, adapter->tx_queue.tx_ring.size,
-		adapter->rx_queue.rx_ring[0].size,
-		adapter->rx_queue.rx_ring[1].size);
-
-	vmxnet3_tq_init(&adapter->tx_queue, adapter);
-	err = vmxnet3_rq_init(&adapter->rx_queue, adapter);
+	dev_dbg(&adapter->netdev->dev, "%s: skb_buf_size %d, rx_buf_per_pkt %d,"
+		" ring sizes %u %u %u\n", adapter->netdev->name,
+		adapter->skb_buf_size, adapter->rx_buf_per_pkt,
+		adapter->tx_queue[0].tx_ring.size,
+		adapter->rx_queue[0].rx_ring[0].size,
+		adapter->rx_queue[0].rx_ring[1].size);
+
+	vmxnet3_tq_init_all(adapter);
+	err = vmxnet3_rq_init_all(adapter);
 	if (err) {
 		printk(KERN_ERR "Failed to init rx queue for %s: error %d\n",
 		       adapter->netdev->name, err);
@@ -1870,10 +2212,15 @@ vmxnet3_activate_dev(struct vmxnet3_adapter *adapter)
 		err = -EINVAL;
 		goto activate_err;
 	}
-	VMXNET3_WRITE_BAR0_REG(adapter, VMXNET3_REG_RXPROD,
-			       adapter->rx_queue.rx_ring[0].next2fill);
-	VMXNET3_WRITE_BAR0_REG(adapter, VMXNET3_REG_RXPROD2,
-			       adapter->rx_queue.rx_ring[1].next2fill);
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		VMXNET3_WRITE_BAR0_REG(adapter,
+				VMXNET3_REG_RXPROD + i * VMXNET3_REG_ALIGN,
+				adapter->rx_queue[i].rx_ring[0].next2fill);
+		VMXNET3_WRITE_BAR0_REG(adapter, (VMXNET3_REG_RXPROD2 +
+				(i * VMXNET3_REG_ALIGN)),
+				adapter->rx_queue[i].rx_ring[1].next2fill);
+	}
 
 	/* Apply the rx filter settins last. */
 	vmxnet3_set_mc(adapter->netdev);
@@ -1883,8 +2230,8 @@ vmxnet3_activate_dev(struct vmxnet3_adapter *adapter)
 	 * tx queue if the link is up.
 	 */
 	vmxnet3_check_link(adapter, true);
-
-	napi_enable(&adapter->napi);
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		napi_enable(&adapter->rx_queue[i].napi);
 	vmxnet3_enable_all_intrs(adapter);
 	clear_bit(VMXNET3_STATE_BIT_QUIESCED, &adapter->state);
 	return 0;
@@ -1896,7 +2243,7 @@ activate_err:
 irq_err:
 rq_err:
 	/* free up buffers we allocated */
-	vmxnet3_rq_cleanup(&adapter->rx_queue, adapter);
+	vmxnet3_rq_cleanup_all(adapter);
 	return err;
 }
 
@@ -1911,6 +2258,7 @@ vmxnet3_reset_dev(struct vmxnet3_adapter *adapter)
 int
 vmxnet3_quiesce_dev(struct vmxnet3_adapter *adapter)
 {
+	int i;
 	if (test_and_set_bit(VMXNET3_STATE_BIT_QUIESCED, &adapter->state))
 		return 0;
 
@@ -1919,13 +2267,14 @@ vmxnet3_quiesce_dev(struct vmxnet3_adapter *adapter)
 			       VMXNET3_CMD_QUIESCE_DEV);
 	vmxnet3_disable_all_intrs(adapter);
 
-	napi_disable(&adapter->napi);
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		napi_disable(&adapter->rx_queue[i].napi);
 	netif_tx_disable(adapter->netdev);
 	adapter->link_speed = 0;
 	netif_carrier_off(adapter->netdev);
 
-	vmxnet3_tq_cleanup(&adapter->tx_queue, adapter);
-	vmxnet3_rq_cleanup(&adapter->rx_queue, adapter);
+	vmxnet3_tq_cleanup_all(adapter);
+	vmxnet3_rq_cleanup_all(adapter);
 	vmxnet3_free_irqs(adapter);
 	return 0;
 }
@@ -2047,7 +2396,9 @@ vmxnet3_free_pci_resources(struct vmxnet3_adapter *adapter)
 static void
 vmxnet3_adjust_rx_ring_size(struct vmxnet3_adapter *adapter)
 {
-	size_t sz;
+	size_t sz, i, ring0_size, ring1_size, comp_size;
+	struct vmxnet3_rx_queue	*rq = &adapter->rx_queue[0];
+
 
 	if (adapter->netdev->mtu <= VMXNET3_MAX_SKB_BUF_SIZE -
 				    VMXNET3_MAX_ETH_HDR_SIZE) {
@@ -2069,11 +2420,19 @@ vmxnet3_adjust_rx_ring_size(struct vmxnet3_adapter *adapter)
 	 * rx_buf_per_pkt * VMXNET3_RING_SIZE_ALIGN
 	 */
 	sz = adapter->rx_buf_per_pkt * VMXNET3_RING_SIZE_ALIGN;
-	adapter->rx_queue.rx_ring[0].size = (adapter->rx_queue.rx_ring[0].size +
-					     sz - 1) / sz * sz;
-	adapter->rx_queue.rx_ring[0].size = min_t(u32,
-					    adapter->rx_queue.rx_ring[0].size,
-					    VMXNET3_RX_RING_MAX_SIZE / sz * sz);
+	ring0_size = adapter->rx_queue[0].rx_ring[0].size;
+	ring0_size = (ring0_size + sz - 1) / sz * sz;
+	ring0_size = min_t(u32, rq->rx_ring[0].size, VMXNET3_RX_RING_MAX_SIZE /
+			   sz * sz);
+	ring1_size = adapter->rx_queue[0].rx_ring[1].size;
+	comp_size = ring0_size + ring1_size;
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		rq = &adapter->rx_queue[i];
+		rq->rx_ring[0].size = ring0_size;
+		rq->rx_ring[1].size = ring1_size;
+		rq->comp_ring.size = comp_size;
+	}
 }
 
 
@@ -2081,29 +2440,53 @@ int
 vmxnet3_create_queues(struct vmxnet3_adapter *adapter, u32 tx_ring_size,
 		      u32 rx_ring_size, u32 rx_ring2_size)
 {
-	int err;
-
-	adapter->tx_queue.tx_ring.size   = tx_ring_size;
-	adapter->tx_queue.data_ring.size = tx_ring_size;
-	adapter->tx_queue.comp_ring.size = tx_ring_size;
-	adapter->tx_queue.shared = &adapter->tqd_start->ctrl;
-	adapter->tx_queue.stopped = true;
-	err = vmxnet3_tq_create(&adapter->tx_queue, adapter);
-	if (err)
-		return err;
+	int err = 0, i;
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		struct vmxnet3_tx_queue	*tq = &adapter->tx_queue[i];
+		tq->tx_ring.size   = tx_ring_size;
+		tq->data_ring.size = tx_ring_size;
+		tq->comp_ring.size = tx_ring_size;
+		tq->shared = &adapter->tqd_start[i].ctrl;
+		tq->stopped = true;
+		tq->adapter = adapter;
+		tq->qid = i;
+		err = vmxnet3_tq_create(tq, adapter);
+		/*
+		 * Too late to change num_tx_queues. We cannot do away with
+		 * lesser number of queues than what we asked for
+		 */
+		if (err)
+			goto queue_err;
+	}
 
-	adapter->rx_queue.rx_ring[0].size = rx_ring_size;
-	adapter->rx_queue.rx_ring[1].size = rx_ring2_size;
+	adapter->rx_queue[0].rx_ring[0].size = rx_ring_size;
+	adapter->rx_queue[0].rx_ring[1].size = rx_ring2_size;
 	vmxnet3_adjust_rx_ring_size(adapter);
-	adapter->rx_queue.comp_ring.size  = adapter->rx_queue.rx_ring[0].size +
-					    adapter->rx_queue.rx_ring[1].size;
-	adapter->rx_queue.qid  = 0;
-	adapter->rx_queue.qid2 = 1;
-	adapter->rx_queue.shared = &adapter->rqd_start->ctrl;
-	err = vmxnet3_rq_create(&adapter->rx_queue, adapter);
-	if (err)
-		vmxnet3_tq_destroy(&adapter->tx_queue, adapter);
-
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		struct vmxnet3_rx_queue *rq = &adapter->rx_queue[i];
+		/* qid and qid2 for rx queues will be assigned later when num
+		 * of rx queues is finalized after allocating intrs */
+		rq->shared = &adapter->rqd_start[i].ctrl;
+		rq->adapter = adapter;
+		err = vmxnet3_rq_create(rq, adapter);
+		if (err) {
+			if (i == 0) {
+				printk(KERN_ERR "Could not allocate any rx"
+				       "queues. Aborting.\n");
+				goto queue_err;
+			} else {
+				printk(KERN_INFO "Number of rx queues changed "
+				       "to : %d.\n", i);
+				adapter->num_rx_queues = i;
+				err = 0;
+				break;
+			}
+		}
+	}
+	return err;
+queue_err:
+	vmxnet3_tq_destroy_all(adapter);
 	return err;
 }
 
@@ -2111,11 +2494,12 @@ static int
 vmxnet3_open(struct net_device *netdev)
 {
 	struct vmxnet3_adapter *adapter;
-	int err;
+	int err, i;
 
 	adapter = netdev_priv(netdev);
 
-	spin_lock_init(&adapter->tx_queue.tx_lock);
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		spin_lock_init(&adapter->tx_queue[i].tx_lock);
 
 	err = vmxnet3_create_queues(adapter, VMXNET3_DEF_TX_RING_SIZE,
 				    VMXNET3_DEF_RX_RING_SIZE,
@@ -2130,8 +2514,8 @@ vmxnet3_open(struct net_device *netdev)
 	return 0;
 
 activate_err:
-	vmxnet3_rq_destroy(&adapter->rx_queue, adapter);
-	vmxnet3_tq_destroy(&adapter->tx_queue, adapter);
+	vmxnet3_rq_destroy_all(adapter);
+	vmxnet3_tq_destroy_all(adapter);
 queue_err:
 	return err;
 }
@@ -2151,8 +2535,8 @@ vmxnet3_close(struct net_device *netdev)
 
 	vmxnet3_quiesce_dev(adapter);
 
-	vmxnet3_rq_destroy(&adapter->rx_queue, adapter);
-	vmxnet3_tq_destroy(&adapter->tx_queue, adapter);
+	vmxnet3_rq_destroy_all(adapter);
+	vmxnet3_tq_destroy_all(adapter);
 
 	clear_bit(VMXNET3_STATE_BIT_RESETTING, &adapter->state);
 
@@ -2164,6 +2548,8 @@ vmxnet3_close(struct net_device *netdev)
 void
 vmxnet3_force_close(struct vmxnet3_adapter *adapter)
 {
+	int i;
+
 	/*
 	 * we must clear VMXNET3_STATE_BIT_RESETTING, otherwise
 	 * vmxnet3_close() will deadlock.
@@ -2171,7 +2557,8 @@ vmxnet3_force_close(struct vmxnet3_adapter *adapter)
 	BUG_ON(test_bit(VMXNET3_STATE_BIT_RESETTING, &adapter->state));
 
 	/* we need to enable NAPI, otherwise dev_close will deadlock */
-	napi_enable(&adapter->napi);
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		napi_enable(&adapter->rx_queue[i].napi);
 	dev_close(adapter->netdev);
 }
 
@@ -2202,14 +2589,11 @@ vmxnet3_change_mtu(struct net_device *netdev, int new_mtu)
 		vmxnet3_reset_dev(adapter);
 
 		/* we need to re-create the rx queue based on the new mtu */
-		vmxnet3_rq_destroy(&adapter->rx_queue, adapter);
+		vmxnet3_rq_destroy_all(adapter);
 		vmxnet3_adjust_rx_ring_size(adapter);
-		adapter->rx_queue.comp_ring.size  =
-					adapter->rx_queue.rx_ring[0].size +
-					adapter->rx_queue.rx_ring[1].size;
-		err = vmxnet3_rq_create(&adapter->rx_queue, adapter);
+		err = vmxnet3_rq_create_all(adapter);
 		if (err) {
-			printk(KERN_ERR "%s: failed to re-create rx queue,"
+			printk(KERN_ERR "%s: failed to re-create rx queues,"
 				" error %d. Closing it.\n", netdev->name, err);
 			goto out;
 		}
@@ -2274,6 +2658,55 @@ vmxnet3_read_mac_addr(struct vmxnet3_adapter *adapter, u8 *mac)
 	mac[5] = (tmp >> 8) & 0xff;
 }
 
+#ifdef CONFIG_PCI_MSI
+
+/*
+ * Enable MSIx vectors.
+ * Returns :
+ *	0 on successful enabling of required vectors,
+ *	VMXNET3_LINUX_MIN_MSIX_VECT when only minumum number of vectors required
+ *	 could be enabled.
+ *	number of vectors which can be enabled otherwise (this number is smaller
+ *	 than VMXNET3_LINUX_MIN_MSIX_VECT)
+ */
+
+static int
+vmxnet3_acquire_msix_vectors(struct vmxnet3_adapter *adapter,
+			     int vectors)
+{
+	int err = 0, vector_threshold;
+	vector_threshold = VMXNET3_LINUX_MIN_MSIX_VECT;
+
+	while (vectors >= vector_threshold) {
+		err = pci_enable_msix(adapter->pdev, adapter->intr.msix_entries,
+				      vectors);
+		if (!err) {
+			adapter->intr.num_intrs = vectors;
+			return 0;
+		} else if (err < 0) {
+			printk(KERN_ERR "Failed to enable MSI-X for %s, error"
+			       " %d\n",	adapter->netdev->name, err);
+			vectors = 0;
+		} else if (err < vector_threshold) {
+			break;
+		} else {
+			/* If fails to enable required number of MSI-x vectors
+			 * try enabling 3 of them. One each for rx, tx and event
+			 */
+			vectors = vector_threshold;
+			printk(KERN_ERR "Failed to enable %d MSI-X for %s, try"
+			       " %d instead\n", vectors, adapter->netdev->name,
+			       vector_threshold);
+		}
+	}
+
+	printk(KERN_INFO "Number of MSI-X interrupts which can be allocatedi"
+	       " are lower than min threshold required.\n");
+	return err;
+}
+
+
+#endif /* CONFIG_PCI_MSI */
 
 static void
 vmxnet3_alloc_intr_resources(struct vmxnet3_adapter *adapter)
@@ -2293,16 +2726,47 @@ vmxnet3_alloc_intr_resources(struct vmxnet3_adapter *adapter)
 
 #ifdef CONFIG_PCI_MSI
 	if (adapter->intr.type == VMXNET3_IT_MSIX) {
-		int err;
-
-		adapter->intr.msix_entries[0].entry = 0;
-		err = pci_enable_msix(adapter->pdev, adapter->intr.msix_entries,
-				      VMXNET3_LINUX_MAX_MSIX_VECT);
-		if (!err) {
-			adapter->intr.num_intrs = 1;
-			adapter->intr.type = VMXNET3_IT_MSIX;
+		int vector, err = 0;
+
+		adapter->intr.num_intrs = (adapter->share_intr ==
+					   VMXNET3_INTR_TXSHARE) ? 1 :
+					   adapter->num_tx_queues;
+		adapter->intr.num_intrs += (adapter->share_intr ==
+					   VMXNET3_INTR_BUDDYSHARE) ? 0 :
+					   adapter->num_rx_queues;
+		adapter->intr.num_intrs += 1;		/* for link event */
+
+		adapter->intr.num_intrs = (adapter->intr.num_intrs >
+					   VMXNET3_LINUX_MIN_MSIX_VECT
+					   ? adapter->intr.num_intrs :
+					   VMXNET3_LINUX_MIN_MSIX_VECT);
+
+		for (vector = 0; vector < adapter->intr.num_intrs; vector++)
+			adapter->intr.msix_entries[vector].entry = vector;
+
+		err = vmxnet3_acquire_msix_vectors(adapter,
+						   adapter->intr.num_intrs);
+		/* If we cannot allocate one MSIx vector per queue
+		 * then limit the number of rx queues to 1
+		 */
+		if (err == VMXNET3_LINUX_MIN_MSIX_VECT) {
+			if (adapter->share_intr != VMXNET3_INTR_BUDDYSHARE
+			    || adapter->num_rx_queues != 2) {
+				adapter->share_intr = VMXNET3_INTR_TXSHARE;
+				printk(KERN_ERR "Number of rx queues : 1\n");
+				adapter->num_rx_queues = 1;
+				adapter->intr.num_intrs =
+						VMXNET3_LINUX_MIN_MSIX_VECT;
+			}
 			return;
 		}
+		if (!err)
+			return;
+
+		/* If we cannot allocate MSIx vectors use only one rx queue */
+		printk(KERN_INFO "Failed to enable MSI-X for %s, error %d."
+		       "#rx queues : 1, try MSI\n", adapter->netdev->name, err);
+
 		adapter->intr.type = VMXNET3_IT_MSI;
 	}
 
@@ -2310,12 +2774,15 @@ vmxnet3_alloc_intr_resources(struct vmxnet3_adapter *adapter)
 		int err;
 		err = pci_enable_msi(adapter->pdev);
 		if (!err) {
+			adapter->num_rx_queues = 1;
 			adapter->intr.num_intrs = 1;
 			return;
 		}
 	}
 #endif /* CONFIG_PCI_MSI */
 
+	adapter->num_rx_queues = 1;
+	printk(KERN_INFO "Using INTx interrupt, #Rx queues: 1.\n");
 	adapter->intr.type = VMXNET3_IT_INTX;
 
 	/* INT-X related setting */
@@ -2343,6 +2810,7 @@ vmxnet3_tx_timeout(struct net_device *netdev)
 
 	printk(KERN_ERR "%s: tx hang\n", adapter->netdev->name);
 	schedule_work(&adapter->work);
+	netif_wake_queue(adapter->netdev);
 }
 
 
@@ -2399,8 +2867,29 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	struct net_device *netdev;
 	struct vmxnet3_adapter *adapter;
 	u8 mac[ETH_ALEN];
+	int size;
+	int num_tx_queues;
+	int num_rx_queues;
+
+#ifdef VMXNET3_RSS
+	if (enable_mq)
+		num_rx_queues = min(VMXNET3_DEVICE_MAX_RX_QUEUES,
+				    (int)num_online_cpus());
+	else
+#endif
+		num_rx_queues = 1;
+
+	if (enable_mq)
+		num_tx_queues = min(VMXNET3_DEVICE_MAX_TX_QUEUES,
+				    (int)num_online_cpus());
+	else
+		num_tx_queues = 1;
+
+	netdev = alloc_etherdev_mq(sizeof(struct vmxnet3_adapter),
+				   max(num_tx_queues, num_rx_queues));
+	printk(KERN_INFO "# of Tx queues : %d, # of Rx queues : %d\n",
+	       num_tx_queues, num_rx_queues);
 
-	netdev = alloc_etherdev(sizeof(struct vmxnet3_adapter));
 	if (!netdev) {
 		printk(KERN_ERR "Failed to alloc ethernet device for adapter "
 			"%s\n",	pci_name(pdev));
@@ -2422,9 +2911,12 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 		goto err_alloc_shared;
 	}
 
-	adapter->tqd_start = pci_alloc_consistent(adapter->pdev,
-			     sizeof(struct Vmxnet3_TxQueueDesc) +
-			     sizeof(struct Vmxnet3_RxQueueDesc),
+	adapter->num_rx_queues = num_rx_queues;
+	adapter->num_tx_queues = num_tx_queues;
+
+	size = sizeof(struct Vmxnet3_TxQueueDesc) * adapter->num_tx_queues;
+	size += sizeof(struct Vmxnet3_RxQueueDesc) * adapter->num_rx_queues;
+	adapter->tqd_start = pci_alloc_consistent(adapter->pdev, size,
 			     &adapter->queue_desc_pa);
 
 	if (!adapter->tqd_start) {
@@ -2433,8 +2925,8 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 		err = -ENOMEM;
 		goto err_alloc_queue_desc;
 	}
-	adapter->rqd_start = (struct Vmxnet3_RxQueueDesc *)(adapter->tqd_start
-							    + 1);
+	adapter->rqd_start = (struct Vmxnet3_RxQueueDesc *)(adapter->tqd_start +
+							adapter->num_tx_queues);
 
 	adapter->pm_conf = kmalloc(sizeof(struct Vmxnet3_PMConf), GFP_KERNEL);
 	if (adapter->pm_conf == NULL) {
@@ -2444,6 +2936,17 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 		goto err_alloc_pm;
 	}
 
+#ifdef VMXNET3_RSS
+
+	adapter->rss_conf = kmalloc(sizeof(struct UPT1_RSSConf), GFP_KERNEL);
+	if (adapter->rss_conf == NULL) {
+		printk(KERN_ERR "Failed to allocate memory for %s\n",
+		       pci_name(pdev));
+		err = -ENOMEM;
+		goto err_alloc_rss;
+	}
+#endif /* VMXNET3_RSS */
+
 	err = vmxnet3_alloc_pci_resources(adapter, &dma64);
 	if (err < 0)
 		goto err_alloc_pci;
@@ -2471,18 +2974,48 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	vmxnet3_declare_features(adapter, dma64);
 
 	adapter->dev_number = atomic_read(&devices_found);
+
+	 adapter->share_intr = irq_share_mode;
+	if (adapter->share_intr == VMXNET3_INTR_BUDDYSHARE &&
+	    adapter->num_tx_queues != adapter->num_rx_queues)
+		adapter->share_intr = VMXNET3_INTR_DONTSHARE;
+
 	vmxnet3_alloc_intr_resources(adapter);
 
+#ifdef VMXNET3_RSS
+	if (adapter->num_rx_queues > 1 &&
+	    adapter->intr.type == VMXNET3_IT_MSIX) {
+		adapter->rss = true;
+		printk(KERN_INFO "RSS is enabled.\n");
+	} else {
+		adapter->rss = false;
+	}
+#endif
+
 	vmxnet3_read_mac_addr(adapter, mac);
 	memcpy(netdev->dev_addr,  mac, netdev->addr_len);
 
 	netdev->netdev_ops = &vmxnet3_netdev_ops;
-	netdev->watchdog_timeo = 5 * HZ;
 	vmxnet3_set_ethtool_ops(netdev);
+	netdev->watchdog_timeo = 5 * HZ;
 
 	INIT_WORK(&adapter->work, vmxnet3_reset_work);
 
-	netif_napi_add(netdev, &adapter->napi, vmxnet3_poll, 64);
+	if (adapter->intr.type == VMXNET3_IT_MSIX) {
+		int i;
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+			netif_napi_add(adapter->netdev,
+				       &adapter->rx_queue[i].napi,
+				       vmxnet3_poll_rx_only, 64);
+		}
+	} else {
+		netif_napi_add(adapter->netdev, &adapter->rx_queue[0].napi,
+			       vmxnet3_poll, 64);
+	}
+
+	netif_set_real_num_tx_queues(adapter->netdev, adapter->num_tx_queues);
+	netif_set_real_num_rx_queues(adapter->netdev, adapter->num_rx_queues);
+
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 	err = register_netdev(netdev);
 
@@ -2502,11 +3035,14 @@ err_register:
 err_ver:
 	vmxnet3_free_pci_resources(adapter);
 err_alloc_pci:
+#ifdef VMXNET3_RSS
+	kfree(adapter->rss_conf);
+err_alloc_rss:
+#endif
 	kfree(adapter->pm_conf);
 err_alloc_pm:
-	pci_free_consistent(adapter->pdev, sizeof(struct Vmxnet3_TxQueueDesc) +
-			    sizeof(struct Vmxnet3_RxQueueDesc),
-			    adapter->tqd_start, adapter->queue_desc_pa);
+	pci_free_consistent(adapter->pdev, size, adapter->tqd_start,
+			    adapter->queue_desc_pa);
 err_alloc_queue_desc:
 	pci_free_consistent(adapter->pdev, sizeof(struct Vmxnet3_DriverShared),
 			    adapter->shared, adapter->shared_pa);
@@ -2522,6 +3058,16 @@ vmxnet3_remove_device(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
+	int size = 0;
+	int num_rx_queues;
+
+#ifdef VMXNET3_RSS
+	if (enable_mq)
+		num_rx_queues = min(VMXNET3_DEVICE_MAX_RX_QUEUES,
+				    (int)num_online_cpus());
+	else
+#endif
+		num_rx_queues = 1;
 
 	flush_scheduled_work();
 
@@ -2529,10 +3075,15 @@ vmxnet3_remove_device(struct pci_dev *pdev)
 
 	vmxnet3_free_intr_resources(adapter);
 	vmxnet3_free_pci_resources(adapter);
+#ifdef VMXNET3_RSS
+	kfree(adapter->rss_conf);
+#endif
 	kfree(adapter->pm_conf);
-	pci_free_consistent(adapter->pdev, sizeof(struct Vmxnet3_TxQueueDesc) +
-			    sizeof(struct Vmxnet3_RxQueueDesc),
-			    adapter->tqd_start, adapter->queue_desc_pa);
+
+	size = sizeof(struct Vmxnet3_TxQueueDesc) * adapter->num_tx_queues;
+	size += sizeof(struct Vmxnet3_RxQueueDesc) * num_rx_queues;
+	pci_free_consistent(adapter->pdev, size, adapter->tqd_start,
+			    adapter->queue_desc_pa);
 	pci_free_consistent(adapter->pdev, sizeof(struct Vmxnet3_DriverShared),
 			    adapter->shared, adapter->shared_pa);
 	free_netdev(netdev);
@@ -2563,7 +3114,7 @@ vmxnet3_suspend(struct device *device)
 	vmxnet3_free_intr_resources(adapter);
 
 	netif_device_detach(netdev);
-	netif_stop_queue(netdev);
+	netif_tx_stop_all_queues(netdev);
 
 	/* Create wake-up filters. */
 	pmConf = adapter->pm_conf;
@@ -2726,3 +3277,5 @@ MODULE_AUTHOR("VMware, Inc.");
 MODULE_DESCRIPTION(VMXNET3_DRIVER_DESC);
 MODULE_LICENSE("GPL v2");
 MODULE_VERSION(VMXNET3_DRIVER_VERSION_STRING);
+
+
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index b79070b..9ddaea6 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -151,44 +151,42 @@ vmxnet3_get_stats(struct net_device *netdev)
 	struct UPT1_TxStats *devTxStats;
 	struct UPT1_RxStats *devRxStats;
 	struct net_device_stats *net_stats = &netdev->stats;
+	int i;
 
 	adapter = netdev_priv(netdev);
 
 	/* Collect the dev stats into the shared area */
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD, VMXNET3_CMD_GET_STATS);
 
-	/* Assuming that we have a single queue device */
-	devTxStats = &adapter->tqd_start->stats;
-	devRxStats = &adapter->rqd_start->stats;
-
-	/* Get access to the driver stats per queue */
-	drvTxStats = &adapter->tx_queue.stats;
-	drvRxStats = &adapter->rx_queue.stats;
-
 	memset(net_stats, 0, sizeof(*net_stats));
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		devTxStats = &adapter->tqd_start[i].stats;
+		drvTxStats = &adapter->tx_queue[i].stats;
+		net_stats->tx_packets += devTxStats->ucastPktsTxOK +
+					devTxStats->mcastPktsTxOK +
+					devTxStats->bcastPktsTxOK;
+		net_stats->tx_bytes += devTxStats->ucastBytesTxOK +
+				      devTxStats->mcastBytesTxOK +
+				      devTxStats->bcastBytesTxOK;
+		net_stats->tx_errors += devTxStats->pktsTxError;
+		net_stats->tx_dropped += drvTxStats->drop_total;
+	}
 
-	net_stats->rx_packets = devRxStats->ucastPktsRxOK +
-				devRxStats->mcastPktsRxOK +
-				devRxStats->bcastPktsRxOK;
-
-	net_stats->tx_packets = devTxStats->ucastPktsTxOK +
-				devTxStats->mcastPktsTxOK +
-				devTxStats->bcastPktsTxOK;
-
-	net_stats->rx_bytes = devRxStats->ucastBytesRxOK +
-			      devRxStats->mcastBytesRxOK +
-			      devRxStats->bcastBytesRxOK;
-
-	net_stats->tx_bytes = devTxStats->ucastBytesTxOK +
-			      devTxStats->mcastBytesTxOK +
-			      devTxStats->bcastBytesTxOK;
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		devRxStats = &adapter->rqd_start[i].stats;
+		drvRxStats = &adapter->rx_queue[i].stats;
+		net_stats->rx_packets += devRxStats->ucastPktsRxOK +
+					devRxStats->mcastPktsRxOK +
+					devRxStats->bcastPktsRxOK;
 
-	net_stats->rx_errors = devRxStats->pktsRxError;
-	net_stats->tx_errors = devTxStats->pktsTxError;
-	net_stats->rx_dropped = drvRxStats->drop_total;
-	net_stats->tx_dropped = drvTxStats->drop_total;
-	net_stats->multicast =  devRxStats->mcastPktsRxOK;
+		net_stats->rx_bytes += devRxStats->ucastBytesRxOK +
+				      devRxStats->mcastBytesRxOK +
+				      devRxStats->bcastBytesRxOK;
 
+		net_stats->rx_errors += devRxStats->pktsRxError;
+		net_stats->rx_dropped += drvRxStats->drop_total;
+		net_stats->multicast +=  devRxStats->mcastPktsRxOK;
+	}
 	return net_stats;
 }
 
@@ -307,24 +305,26 @@ vmxnet3_get_ethtool_stats(struct net_device *netdev,
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 	u8 *base;
 	int i;
+	int j = 0;
 
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD, VMXNET3_CMD_GET_STATS);
 
 	/* this does assume each counter is 64-bit wide */
+/* TODO change this for multiple queues */
 
-	base = (u8 *)&adapter->tqd_start->stats;
+	base = (u8 *)&adapter->tqd_start[j].stats;
 	for (i = 0; i < ARRAY_SIZE(vmxnet3_tq_dev_stats); i++)
 		*buf++ = *(u64 *)(base + vmxnet3_tq_dev_stats[i].offset);
 
-	base = (u8 *)&adapter->tx_queue.stats;
+	base = (u8 *)&adapter->tx_queue[j].stats;
 	for (i = 0; i < ARRAY_SIZE(vmxnet3_tq_driver_stats); i++)
 		*buf++ = *(u64 *)(base + vmxnet3_tq_driver_stats[i].offset);
 
-	base = (u8 *)&adapter->rqd_start->stats;
+	base = (u8 *)&adapter->rqd_start[j].stats;
 	for (i = 0; i < ARRAY_SIZE(vmxnet3_rq_dev_stats); i++)
 		*buf++ = *(u64 *)(base + vmxnet3_rq_dev_stats[i].offset);
 
-	base = (u8 *)&adapter->rx_queue.stats;
+	base = (u8 *)&adapter->rx_queue[j].stats;
 	for (i = 0; i < ARRAY_SIZE(vmxnet3_rq_driver_stats); i++)
 		*buf++ = *(u64 *)(base + vmxnet3_rq_driver_stats[i].offset);
 
@@ -339,6 +339,7 @@ vmxnet3_get_regs(struct net_device *netdev, struct ethtool_regs *regs, void *p)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 	u32 *buf = p;
+	int i = 0;
 
 	memset(p, 0, vmxnet3_get_regs_len(netdev));
 
@@ -347,28 +348,29 @@ vmxnet3_get_regs(struct net_device *netdev, struct ethtool_regs *regs, void *p)
 	/* Update vmxnet3_get_regs_len if we want to dump more registers */
 
 	/* make each ring use multiple of 16 bytes */
-	buf[0] = adapter->tx_queue.tx_ring.next2fill;
-	buf[1] = adapter->tx_queue.tx_ring.next2comp;
-	buf[2] = adapter->tx_queue.tx_ring.gen;
+/* TODO change this for multiple queues */
+	buf[0] = adapter->tx_queue[i].tx_ring.next2fill;
+	buf[1] = adapter->tx_queue[i].tx_ring.next2comp;
+	buf[2] = adapter->tx_queue[i].tx_ring.gen;
 	buf[3] = 0;
 
-	buf[4] = adapter->tx_queue.comp_ring.next2proc;
-	buf[5] = adapter->tx_queue.comp_ring.gen;
-	buf[6] = adapter->tx_queue.stopped;
+	buf[4] = adapter->tx_queue[i].comp_ring.next2proc;
+	buf[5] = adapter->tx_queue[i].comp_ring.gen;
+	buf[6] = adapter->tx_queue[i].stopped;
 	buf[7] = 0;
 
-	buf[8] = adapter->rx_queue.rx_ring[0].next2fill;
-	buf[9] = adapter->rx_queue.rx_ring[0].next2comp;
-	buf[10] = adapter->rx_queue.rx_ring[0].gen;
+	buf[8] = adapter->rx_queue[i].rx_ring[0].next2fill;
+	buf[9] = adapter->rx_queue[i].rx_ring[0].next2comp;
+	buf[10] = adapter->rx_queue[i].rx_ring[0].gen;
 	buf[11] = 0;
 
-	buf[12] = adapter->rx_queue.rx_ring[1].next2fill;
-	buf[13] = adapter->rx_queue.rx_ring[1].next2comp;
-	buf[14] = adapter->rx_queue.rx_ring[1].gen;
+	buf[12] = adapter->rx_queue[i].rx_ring[1].next2fill;
+	buf[13] = adapter->rx_queue[i].rx_ring[1].next2comp;
+	buf[14] = adapter->rx_queue[i].rx_ring[1].gen;
 	buf[15] = 0;
 
-	buf[16] = adapter->rx_queue.comp_ring.next2proc;
-	buf[17] = adapter->rx_queue.comp_ring.gen;
+	buf[16] = adapter->rx_queue[i].comp_ring.next2proc;
+	buf[17] = adapter->rx_queue[i].comp_ring.gen;
 	buf[18] = 0;
 	buf[19] = 0;
 }
@@ -435,8 +437,10 @@ vmxnet3_get_ringparam(struct net_device *netdev,
 	param->rx_mini_max_pending = 0;
 	param->rx_jumbo_max_pending = 0;
 
-	param->rx_pending = adapter->rx_queue.rx_ring[0].size;
-	param->tx_pending = adapter->tx_queue.tx_ring.size;
+	param->rx_pending = adapter->rx_queue[0].rx_ring[0].size *
+			    adapter->num_rx_queues;
+	param->tx_pending = adapter->tx_queue[0].tx_ring.size *
+			    adapter->num_tx_queues;
 	param->rx_mini_pending = 0;
 	param->rx_jumbo_pending = 0;
 }
@@ -480,8 +484,8 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 							   sz) != 0)
 		return -EINVAL;
 
-	if (new_tx_ring_size == adapter->tx_queue.tx_ring.size &&
-			new_rx_ring_size == adapter->rx_queue.rx_ring[0].size) {
+	if (new_tx_ring_size == adapter->tx_queue[0].tx_ring.size &&
+	    new_rx_ring_size == adapter->rx_queue[0].rx_ring[0].size) {
 		return 0;
 	}
 
@@ -498,11 +502,12 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 
 		/* recreate the rx queue and the tx queue based on the
 		 * new sizes */
-		vmxnet3_tq_destroy(&adapter->tx_queue, adapter);
-		vmxnet3_rq_destroy(&adapter->rx_queue, adapter);
+		vmxnet3_tq_destroy_all(adapter);
+		vmxnet3_rq_destroy_all(adapter);
 
 		err = vmxnet3_create_queues(adapter, new_tx_ring_size,
 			new_rx_ring_size, VMXNET3_DEF_RX_RING_SIZE);
+
 		if (err) {
 			/* failed, most likely because of OOM, try default
 			 * size */
@@ -535,6 +540,65 @@ out:
 }
 
 
+static int
+vmxnet3_get_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *info,
+		  void *rules)
+{
+	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
+	switch (info->cmd) {
+	case ETHTOOL_GRXRINGS:
+		info->data = adapter->num_rx_queues;
+		return 0;
+	}
+	return -EOPNOTSUPP;
+}
+
+
+static int
+vmxnet3_get_rss_indir(struct net_device *netdev,
+		      struct ethtool_rxfh_indir *p)
+{
+	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
+	struct UPT1_RSSConf *rssConf = adapter->rss_conf;
+	unsigned int n = min_t(unsigned int, p->size, rssConf->indTableSize);
+
+	p->size = rssConf->indTableSize;
+	while (n--)
+		p->ring_index[n] = rssConf->indTable[n];
+	return 0;
+
+}
+
+static int
+vmxnet3_set_rss_indir(struct net_device *netdev,
+		      const struct ethtool_rxfh_indir *p)
+{
+	unsigned int i;
+	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
+	struct UPT1_RSSConf *rssConf = adapter->rss_conf;
+
+	if (p->size != rssConf->indTableSize)
+		return -EINVAL;
+	for (i = 0; i < rssConf->indTableSize; i++) {
+		/*
+		 * Return with error code if any of the queue indices
+		 * is out of range
+		 */
+		if (p->ring_index[i] < 0 ||
+		    p->ring_index[i] >= adapter->num_rx_queues)
+			return -EINVAL;
+	}
+
+	for (i = 0; i < rssConf->indTableSize; i++)
+		rssConf->indTable[i] = p->ring_index[i];
+
+	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
+			       VMXNET3_CMD_UPDATE_RSSIDT);
+
+	return 0;
+
+}
+
 static struct ethtool_ops vmxnet3_ethtool_ops = {
 	.get_settings      = vmxnet3_get_settings,
 	.get_drvinfo       = vmxnet3_get_drvinfo,
@@ -558,6 +622,9 @@ static struct ethtool_ops vmxnet3_ethtool_ops = {
 	.get_ethtool_stats = vmxnet3_get_ethtool_stats,
 	.get_ringparam     = vmxnet3_get_ringparam,
 	.set_ringparam     = vmxnet3_set_ringparam,
+	.get_rxnfc         = vmxnet3_get_rxnfc,
+	.get_rxfh_indir    = vmxnet3_get_rss_indir,
+	.set_rxfh_indir    = vmxnet3_set_rss_indir,
 };
 
 void vmxnet3_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index edf2288..7fadeed 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -68,11 +68,15 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.0.14.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.0.16.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01000E00
+#define VMXNET3_DRIVER_VERSION_NUM      0x01001000
 
+#if defined(CONFIG_PCI_MSI)
+	/* RSS only makes sense if MSI-X is supported. */
+	#define VMXNET3_RSS
+#endif
 
 /*
  * Capabilities
@@ -218,16 +222,19 @@ struct vmxnet3_tx_ctx {
 };
 
 struct vmxnet3_tx_queue {
+	char			name[IFNAMSIZ+8]; /* To identify interrupt */
+	struct vmxnet3_adapter		*adapter;
 	spinlock_t                      tx_lock;
 	struct vmxnet3_cmd_ring         tx_ring;
-	struct vmxnet3_tx_buf_info     *buf_info;
+	struct vmxnet3_tx_buf_info      *buf_info;
 	struct vmxnet3_tx_data_ring     data_ring;
 	struct vmxnet3_comp_ring        comp_ring;
-	struct Vmxnet3_TxQueueCtrl            *shared;
+	struct Vmxnet3_TxQueueCtrl      *shared;
 	struct vmxnet3_tq_driver_stats  stats;
 	bool                            stopped;
 	int                             num_stop;  /* # of times the queue is
 						    * stopped */
+	int				qid;
 } __attribute__((__aligned__(SMP_CACHE_BYTES)));
 
 enum vmxnet3_rx_buf_type {
@@ -259,6 +266,9 @@ struct vmxnet3_rq_driver_stats {
 };
 
 struct vmxnet3_rx_queue {
+	char			name[IFNAMSIZ + 8]; /* To identify interrupt */
+	struct vmxnet3_adapter	  *adapter;
+	struct napi_struct        napi;
 	struct vmxnet3_cmd_ring   rx_ring[2];
 	struct vmxnet3_comp_ring  comp_ring;
 	struct vmxnet3_rx_ctx     rx_ctx;
@@ -271,7 +281,16 @@ struct vmxnet3_rx_queue {
 	struct vmxnet3_rq_driver_stats  stats;
 } __attribute__((__aligned__(SMP_CACHE_BYTES)));
 
-#define VMXNET3_LINUX_MAX_MSIX_VECT     1
+#define VMXNET3_DEVICE_MAX_TX_QUEUES 8
+#define VMXNET3_DEVICE_MAX_RX_QUEUES 8   /* Keep this value as a power of 2 */
+
+/* Should be less than UPT1_RSS_MAX_IND_TABLE_SIZE */
+#define VMXNET3_RSS_IND_TABLE_SIZE (VMXNET3_DEVICE_MAX_RX_QUEUES * 4)
+
+#define VMXNET3_LINUX_MAX_MSIX_VECT     (VMXNET3_DEVICE_MAX_TX_QUEUES + \
+					 VMXNET3_DEVICE_MAX_RX_QUEUES + 1)
+#define VMXNET3_LINUX_MIN_MSIX_VECT     3    /* 1 for each : tx, rx and event */
+
 
 struct vmxnet3_intr {
 	enum vmxnet3_intr_mask_mode  mask_mode;
@@ -279,27 +298,32 @@ struct vmxnet3_intr {
 	u8  num_intrs;			/* # of intr vectors */
 	u8  event_intr_idx;		/* idx of the intr vector for event */
 	u8  mod_levels[VMXNET3_LINUX_MAX_MSIX_VECT]; /* moderation level */
+	char	event_msi_vector_name[IFNAMSIZ+11];
 #ifdef CONFIG_PCI_MSI
 	struct msix_entry msix_entries[VMXNET3_LINUX_MAX_MSIX_VECT];
 #endif
 };
 
+/* Interrupt sharing schemes, share_intr */
+#define VMXNET3_INTR_BUDDYSHARE 0    /* Corresponding tx,rx queues share irq */
+#define VMXNET3_INTR_TXSHARE 1	     /* All tx queues share one irq */
+#define VMXNET3_INTR_DONTSHARE 2     /* each queue has its own irq */
+
+
 #define VMXNET3_STATE_BIT_RESETTING   0
 #define VMXNET3_STATE_BIT_QUIESCED    1
 struct vmxnet3_adapter {
-	struct vmxnet3_tx_queue         tx_queue;
-	struct vmxnet3_rx_queue         rx_queue;
-	struct napi_struct              napi;
-	struct vlan_group              *vlan_grp;
-
-	struct vmxnet3_intr             intr;
-
-	struct Vmxnet3_DriverShared    *shared;
-	struct Vmxnet3_PMConf          *pm_conf;
-	struct Vmxnet3_TxQueueDesc     *tqd_start;     /* first tx queue desc */
-	struct Vmxnet3_RxQueueDesc     *rqd_start;     /* first rx queue desc */
-	struct net_device              *netdev;
-	struct pci_dev                 *pdev;
+	struct vmxnet3_tx_queue		tx_queue[VMXNET3_DEVICE_MAX_TX_QUEUES];
+	struct vmxnet3_rx_queue		rx_queue[VMXNET3_DEVICE_MAX_RX_QUEUES];
+	struct vlan_group		*vlan_grp;
+	struct vmxnet3_intr		intr;
+	struct Vmxnet3_DriverShared	*shared;
+	struct Vmxnet3_PMConf		*pm_conf;
+	struct Vmxnet3_TxQueueDesc	*tqd_start;     /* all tx queue desc */
+	struct Vmxnet3_RxQueueDesc	*rqd_start;	/* all rx queue desc */
+	struct net_device		*netdev;
+	struct net_device_stats		net_stats;
+	struct pci_dev			*pdev;
 
 	u8			__iomem *hw_addr0; /* for BAR 0 */
 	u8			__iomem *hw_addr1; /* for BAR 1 */
@@ -308,6 +332,12 @@ struct vmxnet3_adapter {
 	bool				rxcsum;
 	bool				lro;
 	bool				jumbo_frame;
+#ifdef VMXNET3_RSS
+	struct UPT1_RSSConf		*rss_conf;
+	bool				rss;
+#endif
+	u32				num_rx_queues;
+	u32				num_tx_queues;
 
 	/* rx buffer related */
 	unsigned			skb_buf_size;
@@ -327,6 +357,7 @@ struct vmxnet3_adapter {
 	unsigned long  state;    /* VMXNET3_STATE_BIT_xxx */
 
 	int dev_number;
+	int share_intr;
 };
 
 #define VMXNET3_WRITE_BAR0_REG(adapter, reg, val)  \
@@ -366,12 +397,10 @@ void
 vmxnet3_reset_dev(struct vmxnet3_adapter *adapter);
 
 void
-vmxnet3_tq_destroy(struct vmxnet3_tx_queue *tq,
-		   struct vmxnet3_adapter *adapter);
+vmxnet3_tq_destroy_all(struct vmxnet3_adapter *adapter);
 
 void
-vmxnet3_rq_destroy(struct vmxnet3_rx_queue *rq,
-		   struct vmxnet3_adapter *adapter);
+vmxnet3_rq_destroy_all(struct vmxnet3_adapter *adapter);
 
 int
 vmxnet3_create_queues(struct vmxnet3_adapter *adapter,
