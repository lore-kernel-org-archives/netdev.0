From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 1/2 net] ibmvnic: Fix overflowing firmware/hardware TX queue
Date: Sun,  5 Mar 2017 12:18:41 -0600
Message-ID: <1488737922-17305-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: jallen@linux.vnet.ibm.com, nfont@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com, wvoigt@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:56181 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751573AbdCESSt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 13:18:49 -0500
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v25IIkSe145977
        for <netdev@vger.kernel.org>; Sun, 5 Mar 2017 13:18:48 -0500
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
        by mx0a-001b2d01.pphosted.com with ESMTP id 28yva1wpyp-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 05 Mar 2017 13:18:48 -0500
Received: from localhost
        by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Sun, 5 Mar 2017 11:18:47 -0700
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
        by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id DACC719D8026
        for <netdev@vger.kernel.org>; Sun,  5 Mar 2017 11:17:55 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a counter to track the number of outstanding transmissions sent
that have not received completions. If the counter reaches the maximum
number of queue entries, stop transmissions on that queue. As we receive 
more completions from firmware, wake the queue once the counter reaches 
an acceptable level.

This patch prevents hardware/firmware TX queue from filling up and
and generating errors.  Since incorporating this fix, internal testing
has reported that these firmware errors have stopped.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 27 ++++++++++++++++++++++++++-
 drivers/net/ethernet/ibm/ibmvnic.h |  1 +
 2 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 9198e6b..0e87b83 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -705,6 +705,7 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 	u8 *hdrs = (u8 *)&adapter->tx_rx_desc_req;
 	struct device *dev = &adapter->vdev->dev;
 	struct ibmvnic_tx_buff *tx_buff = NULL;
+	struct ibmvnic_sub_crq_queue *tx_scrq;
 	struct ibmvnic_tx_pool *tx_pool;
 	unsigned int tx_send_failed = 0;
 	unsigned int tx_map_failed = 0;
@@ -724,6 +725,7 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 	int ret = 0;
 
 	tx_pool = &adapter->tx_pool[queue_num];
+	tx_scrq = adapter->tx_scrq[queue_num];
 	txq = netdev_get_tx_queue(netdev, skb_get_queue_mapping(skb));
 	handle_array = (u64 *)((u8 *)(adapter->login_rsp_buf) +
 				   be32_to_cpu(adapter->login_rsp_buf->
@@ -826,6 +828,14 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 		ret = NETDEV_TX_BUSY;
 		goto out;
 	}
+
+	atomic_inc(&tx_scrq->used);
+
+	if (atomic_read(&tx_scrq->used) >= adapter->req_tx_entries_per_subcrq) {
+		netdev_info(netdev, "Stopping queue %d\n", queue_num);
+		netif_stop_subqueue(netdev, queue_num);
+	}
+
 	tx_packets++;
 	tx_bytes += skb->len;
 	txq->trans_start = jiffies;
@@ -1213,6 +1223,7 @@ static struct ibmvnic_sub_crq_queue *init_sub_crq_queue(struct ibmvnic_adapter
 	scrq->adapter = adapter;
 	scrq->size = 4 * PAGE_SIZE / sizeof(*scrq->msgs);
 	scrq->cur = 0;
+	atomic_set(&scrq->used, 0);
 	scrq->rx_skb_top = NULL;
 	spin_lock_init(&scrq->lock);
 
@@ -1355,8 +1366,22 @@ static int ibmvnic_complete_tx(struct ibmvnic_adapter *adapter,
 						 DMA_TO_DEVICE);
 			}
 
-			if (txbuff->last_frag)
+			if (txbuff->last_frag) {
+				atomic_dec(&scrq->used);
+
+				if (atomic_read(&scrq->used) <=
+				    (adapter->req_tx_entries_per_subcrq / 2) &&
+				    netif_subqueue_stopped(adapter->netdev,
+							   txbuff->skb)) {
+					netif_wake_subqueue(adapter->netdev,
+							    scrq->pool_index);
+					netdev_dbg(adapter->netdev,
+						   "Started queue %d\n",
+						   scrq->pool_index);
+				}
+
 				dev_kfree_skb_any(txbuff->skb);
+			}
 
 			adapter->tx_pool[pool].free_map[adapter->tx_pool[pool].
 						     producer_index] = index;
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 422824f..1993b42 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -863,6 +863,7 @@ struct ibmvnic_sub_crq_queue {
 	spinlock_t lock;
 	struct sk_buff *rx_skb_top;
 	struct ibmvnic_adapter *adapter;
+	atomic_t used;
 };
 
 struct ibmvnic_long_term_buff {
-- 
1.8.3.1
