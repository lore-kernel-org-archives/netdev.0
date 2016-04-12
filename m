From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net-next] ibmvnic: Defer tx completion processing using a wait
 queue
Date: Tue, 12 Apr 2016 14:38:36 -0500
Message-ID: <570D4EBC.60409@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e18.ny.us.ibm.com ([129.33.205.208]:53620 "EHLO
	e18.ny.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757151AbcDLTjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 15:39:03 -0400
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
	Tue, 12 Apr 2016 15:38:56 -0400
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id B279C38C8041
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 15:38:46 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u3CJckCE38863004
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 19:38:46 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u3CJcjm0030431
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 15:38:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves tx completion processing out of interrupt context, deferring work
using a wait queue. With this work now deferred, we must account for the
possibility that skbs can be sent faster than we can process completion
requests in which case the tx buffer will overflow. If the tx buffer is
full, ibmvnic_xmit will return NETDEV_TX_BUSY and stop the current tx
queue. Subsequently, the queue will be restarted in ibmvnic_complete_tx
when all pending tx completion requests have been cleared.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
---
diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 864cb21..641e340 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -105,6 +105,7 @@ static int pending_scrq(struct ibmvnic_adapter *,
 			struct ibmvnic_sub_crq_queue *);
 static union sub_crq *ibmvnic_next_scrq(struct ibmvnic_adapter *,
 					struct ibmvnic_sub_crq_queue *);
+static int ibmvnic_tx_work(void *data);
 static int ibmvnic_poll(struct napi_struct *napi, int data);
 static void send_map_query(struct ibmvnic_adapter *adapter);
 static void send_request_map(struct ibmvnic_adapter *, dma_addr_t, __be32, u8);
@@ -437,6 +438,17 @@ static int ibmvnic_open(struct net_device *netdev)

 		tx_pool->consumer_index = 0;
 		tx_pool->producer_index = 0;
+
+		init_waitqueue_head(&tx_pool->ibmvnic_tx_comp_q);
+		tx_pool->work_thread =
+			kthread_run(ibmvnic_tx_work, adapter->tx_scrq[i],
+				    "%s_%s_%d",
+				    IBMVNIC_NAME, adapter->netdev->name, i);
+		if (IS_ERR(tx_pool->work_thread)) {
+			dev_err(dev, "Couldn't create kernel thread: %ld\n",
+				PTR_ERR(tx_pool->work_thread));
+			goto thread_failed;
+		}
 	}
 	adapter->bounce_buffer_size =
 	    (netdev->mtu + ETH_HLEN - 1) / PAGE_SIZE + 1;
@@ -477,6 +489,9 @@ bounce_map_failed:
 bounce_alloc_failed:
 	i = tx_subcrqs - 1;
 	kfree(adapter->tx_pool[i].free_map);
+thread_failed:
+	for (j = 0; j < i; j++)
+		kthread_stop(adapter->tx_pool[j].work_thread);
 tx_fm_alloc_failed:
 	free_long_term_buff(adapter, &adapter->tx_pool[i].long_term_buff);
 tx_ltb_alloc_failed:
@@ -731,6 +746,16 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 	}

 	index = tx_pool->free_map[tx_pool->consumer_index];
+	/* tx queue full */
+	if ((index + 1) % adapter->max_tx_entries_per_subcrq ==
+	    tx_pool->free_map[tx_pool->producer_index]) {
+		netif_tx_stop_queue(netdev_get_tx_queue(netdev, queue_num));
+		tx_send_failed++;
+		tx_dropped++;
+		ret = NETDEV_TX_BUSY;
+		goto out;
+	}
+
 	offset = index * adapter->req_mtu;
 	dst = tx_pool->long_term_buff.buff + offset;
 	memset(dst, 0, adapter->req_mtu);
@@ -1314,6 +1339,7 @@ static int ibmvnic_complete_tx(struct ibmvnic_adapter *adapter,
 {
 	struct device *dev = &adapter->vdev->dev;
 	struct ibmvnic_tx_buff *txbuff;
+	struct netdev_queue *txq;
 	union sub_crq *next;
 	int index;
 	int i, j;
@@ -1361,6 +1387,10 @@ restart_loop:
 		next->tx_comp.first = 0;
 	}

+	txq = netdev_get_tx_queue(adapter->netdev, scrq->pool_index);
+	if (netif_tx_queue_stopped(txq))
+		netif_tx_wake_queue(txq);
+
 	enable_scrq_irq(adapter, scrq);

 	if (pending_scrq(adapter, scrq)) {
@@ -1371,13 +1401,35 @@ restart_loop:
 	return 0;
 }

+static int ibmvnic_tx_work(void *data)
+{
+	int rc;
+	struct ibmvnic_sub_crq_queue *scrq = data;
+	struct ibmvnic_adapter *adapter = scrq->adapter;
+
+	while (1) {
+		rc = wait_event_interruptible(adapter->
+					      tx_pool[scrq->pool_index].
+					      ibmvnic_tx_comp_q,
+					      pending_scrq(adapter, scrq));
+		BUG_ON(rc);
+
+		if (kthread_should_stop())
+			break;
+
+		disable_scrq_irq(adapter, scrq);
+
+		ibmvnic_complete_tx(adapter, scrq);
+	}
+	return 0;
+}
+
 static irqreturn_t ibmvnic_interrupt_tx(int irq, void *instance)
 {
 	struct ibmvnic_sub_crq_queue *scrq = instance;
 	struct ibmvnic_adapter *adapter = scrq->adapter;

-	disable_scrq_irq(adapter, scrq);
-	ibmvnic_complete_tx(adapter, scrq);
+	wake_up(&adapter->tx_pool[scrq->pool_index].ibmvnic_tx_comp_q);

 	return IRQ_HANDLED;
 }
