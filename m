From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 2/3] netxen: fix deadlock on dev close
Date: Fri, 17 Jul 2009 18:27:07 -0700
Message-ID: <1247880428-4895-3-git-send-email-dhananjay@netxen.com>
References: <1247880428-4895-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:44296 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754324AbZGRB1K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2009 21:27:10 -0400
In-Reply-To: <1247880428-4895-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netxen: fix deadlock on dev close

The tx ring accounting fix in commit cb2107be43d2fc5eadec58b92b
("netxen: fix tx ring accounting") introduced intermittent
deadlock when inteface is going down.

This was possibly combined effect of speculative tx pause,
calling netif_tx_lock instead of queue lock and unclean
synchronization with napi which could end up unmasking
interrupt.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    2 ++
 drivers/net/netxen/netxen_nic_hw.c   |    9 +++++----
 drivers/net/netxen/netxen_nic_init.c |    5 +++--
 drivers/net/netxen/netxen_nic_main.c |   20 +++++++++++++-------
 4 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 9fa71fa..f86e050 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -774,6 +774,8 @@ struct nx_host_tx_ring {
 	u32 crb_cmd_consumer;
 	u32 num_desc;
 
+	struct netdev_queue *txq;
+
 	struct netxen_cmd_buffer *cmd_buf_arr;
 	struct cmd_desc_type0 *desc_head;
 	dma_addr_t phys_addr;
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index ce3b89d..b9123d4 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -461,13 +461,14 @@ netxen_send_cmd_descs(struct netxen_adapter *adapter,
 	i = 0;
 
 	tx_ring = adapter->tx_ring;
-	netif_tx_lock_bh(adapter->netdev);
+	__netif_tx_lock_bh(tx_ring->txq);
 
 	producer = tx_ring->producer;
 	consumer = tx_ring->sw_consumer;
 
-	if (nr_desc >= find_diff_among(producer, consumer, tx_ring->num_desc)) {
-		netif_tx_unlock_bh(adapter->netdev);
+	if (nr_desc >= netxen_tx_avail(tx_ring)) {
+		netif_tx_stop_queue(tx_ring->txq);
+		__netif_tx_unlock_bh(tx_ring->txq);
 		return -EBUSY;
 	}
 
@@ -490,7 +491,7 @@ netxen_send_cmd_descs(struct netxen_adapter *adapter,
 
 	netxen_nic_update_cmd_producer(adapter, tx_ring);
 
-	netif_tx_unlock_bh(adapter->netdev);
+	__netif_tx_unlock_bh(tx_ring->txq);
 
 	return 0;
 }
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index b899bd5..5d3343e 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -214,6 +214,7 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 	adapter->tx_ring = tx_ring;
 
 	tx_ring->num_desc = adapter->num_txd;
+	tx_ring->txq = netdev_get_tx_queue(netdev, 0);
 
 	cmd_buf_arr = vmalloc(TX_BUFF_RINGSIZE(tx_ring));
 	if (cmd_buf_arr == NULL) {
@@ -1400,10 +1401,10 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 		smp_mb();
 
 		if (netif_queue_stopped(netdev) && netif_carrier_ok(netdev)) {
-			netif_tx_lock(netdev);
+			__netif_tx_lock(tx_ring->txq, smp_processor_id());
 			if (netxen_tx_avail(tx_ring) > TX_STOP_THRESH)
 				netif_wake_queue(netdev);
-			netif_tx_unlock(netdev);
+			__netif_tx_unlock(tx_ring->txq);
 		}
 	}
 	/*
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 9a7c4c8..370c52f 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -215,9 +215,9 @@ netxen_napi_disable(struct netxen_adapter *adapter)
 
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
-		napi_disable(&sds_ring->napi);
 		netxen_nic_disable_int(sds_ring);
-		synchronize_irq(sds_ring->irq);
+		napi_synchronize(&sds_ring->napi);
+		napi_disable(&sds_ring->napi);
 	}
 }
 
@@ -833,11 +833,11 @@ netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
 
 	adapter->ahw.linkup = 0;
 
-	netxen_napi_enable(adapter);
-
 	if (adapter->max_sds_rings > 1)
 		netxen_config_rss(adapter, 1);
 
+	netxen_napi_enable(adapter);
+
 	if (adapter->capabilities & NX_FW_CAPABILITY_LINK_NOTIFICATION)
 		netxen_linkevent_request(adapter, 1);
 	else
@@ -851,8 +851,9 @@ netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
 static void
 netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
 {
+	spin_lock(&adapter->tx_clean_lock);
 	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
+	netif_tx_disable(netdev);
 
 	if (adapter->stop_port)
 		adapter->stop_port(adapter);
@@ -863,9 +864,10 @@ netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
 	netxen_napi_disable(adapter);
 
 	netxen_release_tx_buffers(adapter);
+	spin_unlock(&adapter->tx_clean_lock);
 
-	FLUSH_SCHEDULED_WORK();
 	del_timer_sync(&adapter->watchdog_timer);
+	FLUSH_SCHEDULED_WORK();
 }
 
 
@@ -1645,6 +1647,9 @@ static void netxen_tx_timeout_task(struct work_struct *work)
 	struct netxen_adapter *adapter =
 		container_of(work, struct netxen_adapter, tx_timeout_task);
 
+	if (!netif_running(adapter->netdev))
+		return;
+
 	printk(KERN_ERR "%s %s: transmit timeout, resetting.\n",
 	       netxen_nic_driver_name, adapter->netdev->name);
 
@@ -1757,7 +1762,8 @@ static int netxen_nic_poll(struct napi_struct *napi, int budget)
 
 	if ((work_done < budget) && tx_complete) {
 		napi_complete(&sds_ring->napi);
-		netxen_nic_enable_int(sds_ring);
+		if (netif_running(adapter->netdev))
+			netxen_nic_enable_int(sds_ring);
 	}
 
 	return work_done;
-- 
1.6.0.2

