From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next] ibmvnic: Add netdev_dbg output for debugging
Date: Mon, 07 Aug 2017 15:02:58 -0400
Message-ID: <20170807190258.13228.24698.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:38817 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751247AbdHGPQJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 11:16:09 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v77F8qCB034637
        for <netdev@vger.kernel.org>; Mon, 7 Aug 2017 11:16:09 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2c6m54vb8u-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 11:16:08 -0400
Received: from localhost
        by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Mon, 7 Aug 2017 11:16:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To ease debugging of the ibmvnic driver add a series of netdev_dbg()
statements to track driver status, especially during initialization,
removal, and resetting of the driver.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   78 +++++++++++++++++++++++++++++++++---
 1 file changed, 72 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 5932160..4dd9415 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -389,6 +389,8 @@ static int init_stats_token(struct ibmvnic_adapter *adapter)
 	struct device *dev = &adapter->vdev->dev;
 	dma_addr_t stok;
 
+	netdev_dbg(adapter->netdev, "Initializing stats token\n");
+
 	stok = dma_map_single(dev, &adapter->stats,
 			      sizeof(struct ibmvnic_statistics),
 			      DMA_FROM_DEVICE);
@@ -411,6 +413,8 @@ static int reset_rx_pools(struct ibmvnic_adapter *adapter)
 	for (i = 0; i < rx_scrqs; i++) {
 		rx_pool = &adapter->rx_pool[i];
 
+		netdev_dbg(adapter->netdev, "Re-setting rx_pool[%d]\n", i);
+
 		rc = reset_long_term_buff(adapter, &rx_pool->long_term_buff);
 		if (rc)
 			return rc;
@@ -443,6 +447,8 @@ static void release_rx_pools(struct ibmvnic_adapter *adapter)
 	for (i = 0; i < rx_scrqs; i++) {
 		rx_pool = &adapter->rx_pool[i];
 
+		netdev_dbg(adapter->netdev, "Releasing rx_pool[%d]\n", i);
+
 		kfree(rx_pool->free_map);
 		free_long_term_buff(adapter, &rx_pool->long_term_buff);
 
@@ -489,7 +495,7 @@ static int init_rx_pools(struct net_device *netdev)
 		rx_pool = &adapter->rx_pool[i];
 
 		netdev_dbg(adapter->netdev,
-			   "Initializing rx_pool %d, %lld buffs, %lld bytes each\n",
+			   "Initializing rx_pool[%d], %lld buffs, %lld bytes each\n",
 			   i, adapter->req_rx_add_entries_per_subcrq,
 			   be64_to_cpu(size_array[i]));
 
@@ -539,6 +545,8 @@ static int reset_tx_pools(struct ibmvnic_adapter *adapter)
 
 	tx_scrqs = be32_to_cpu(adapter->login_rsp_buf->num_txsubm_subcrqs);
 	for (i = 0; i < tx_scrqs; i++) {
+		netdev_dbg(adapter->netdev, "Re-setting tx_pool[%d]\n", i);
+
 		tx_pool = &adapter->tx_pool[i];
 
 		rc = reset_long_term_buff(adapter, &tx_pool->long_term_buff);
@@ -569,6 +577,7 @@ static void release_tx_pools(struct ibmvnic_adapter *adapter)
 
 	tx_scrqs = be32_to_cpu(adapter->login_rsp_buf->num_txsubm_subcrqs);
 	for (i = 0; i < tx_scrqs; i++) {
+		netdev_dbg(adapter->netdev, "Releasing tx_pool[%d]\n", i);
 		tx_pool = &adapter->tx_pool[i];
 		kfree(tx_pool->tx_buff);
 		free_long_term_buff(adapter, &tx_pool->long_term_buff);
@@ -595,6 +604,11 @@ static int init_tx_pools(struct net_device *netdev)
 
 	for (i = 0; i < tx_subcrqs; i++) {
 		tx_pool = &adapter->tx_pool[i];
+
+		netdev_dbg(adapter->netdev,
+			   "Initializing tx_pool[%d], %lld buffs\n",
+			   i, adapter->req_tx_entries_per_subcrq);
+
 		tx_pool->tx_buff = kcalloc(adapter->req_tx_entries_per_subcrq,
 					   sizeof(struct ibmvnic_tx_buff),
 					   GFP_KERNEL);
@@ -665,8 +679,10 @@ static void ibmvnic_napi_disable(struct ibmvnic_adapter *adapter)
 	if (!adapter->napi_enabled)
 		return;
 
-	for (i = 0; i < adapter->req_rx_queues; i++)
+	for (i = 0; i < adapter->req_rx_queues; i++) {
+		netdev_dbg(adapter->netdev, "Disabling napi[%d]\n", i);
 		napi_disable(&adapter->napi[i]);
+	}
 
 	adapter->napi_enabled = false;
 }
@@ -677,6 +693,8 @@ static int ibmvnic_login(struct net_device *netdev)
 	unsigned long timeout = msecs_to_jiffies(30000);
 	struct device *dev = &adapter->vdev->dev;
 
+	netdev_dbg(netdev, "Logging into server\n");
+
 	do {
 		if (adapter->renegotiate) {
 			adapter->renegotiate = false;
@@ -716,8 +734,11 @@ static void release_resources(struct ibmvnic_adapter *adapter)
 
 	if (adapter->napi) {
 		for (i = 0; i < adapter->req_rx_queues; i++) {
-			if (&adapter->napi[i])
+			if (&adapter->napi[i]) {
+				netdev_dbg(adapter->netdev,
+					   "Releasing napi[%d]\n", i);
 				netif_napi_del(&adapter->napi[i]);
+			}
 		}
 	}
 }
@@ -730,7 +751,8 @@ static int set_link_state(struct ibmvnic_adapter *adapter, u8 link_state)
 	bool resend;
 	int rc;
 
-	netdev_err(netdev, "setting link state %d\n", link_state);
+	netdev_dbg(netdev, "setting link state %d\n", link_state);
+
 	memset(&crq, 0, sizeof(crq));
 	crq.logical_link_state.first = IBMVNIC_CRQ_CMD;
 	crq.logical_link_state.cmd = LOGICAL_LINK_STATE;
@@ -767,6 +789,9 @@ static int set_real_num_queues(struct net_device *netdev)
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
 	int rc;
 
+	netdev_dbg(netdev, "Setting TX queues (%llx) and RX queues (%llx)\n",
+		   adapter->req_tx_queues, adapter->req_rx_queues);
+
 	rc = netif_set_real_num_tx_queues(netdev, adapter->req_tx_queues);
 	if (rc) {
 		netdev_err(netdev, "failed to set the number of tx queues\n");
@@ -804,6 +829,7 @@ static int init_resources(struct ibmvnic_adapter *adapter)
 		return -ENOMEM;
 
 	for (i = 0; i < adapter->req_rx_queues; i++) {
+		netdev_dbg(netdev, "Adding napi[%d]\n", i);
 		netif_napi_add(netdev, &adapter->napi[i], ibmvnic_poll,
 			       NAPI_POLL_WEIGHT);
 	}
@@ -832,6 +858,7 @@ static int __ibmvnic_open(struct net_device *netdev)
 	 * set the logical link state to up
 	 */
 	for (i = 0; i < adapter->req_rx_queues; i++) {
+		netdev_dbg(netdev, "Enabling rx_scrq[%d] irq\n", i);
 		if (prev_state == VNIC_CLOSED)
 			enable_irq(adapter->rx_scrq[i]->irq);
 		else
@@ -839,6 +866,7 @@ static int __ibmvnic_open(struct net_device *netdev)
 	}
 
 	for (i = 0; i < adapter->req_tx_queues; i++) {
+		netdev_dbg(netdev, "Enabling tx_scrq[%d] irq\n", i);
 		if (prev_state == VNIC_CLOSED)
 			enable_irq(adapter->tx_scrq[i]->irq);
 		else
@@ -912,6 +940,7 @@ static void clean_tx_pools(struct ibmvnic_adapter *adapter)
 		if (!tx_pool)
 			continue;
 
+		netdev_dbg(adapter->netdev, "Cleaning tx_pool[%d]\n", i);
 		for (j = 0; j < tx_entries; j++) {
 			if (tx_pool->tx_buff[j].skb) {
 				dev_kfree_skb_any(tx_pool->tx_buff[j].skb);
@@ -927,6 +956,7 @@ static int __ibmvnic_close(struct net_device *netdev)
 	int rc = 0;
 	int i;
 
+	netdev_dbg(adapter->netdev, "Closing device\n");
 	adapter->state = VNIC_CLOSING;
 
 	/* ensure that transmissions are stopped if called by do_reset */
@@ -939,8 +969,11 @@ static int __ibmvnic_close(struct net_device *netdev)
 
 	if (adapter->tx_scrq) {
 		for (i = 0; i < adapter->req_tx_queues; i++)
-			if (adapter->tx_scrq[i]->irq)
+			if (adapter->tx_scrq[i]->irq) {
+				netdev_dbg(adapter->netdev,
+					   "Disabling tx_scrq[%d] irq\n", i);
 				disable_irq(adapter->tx_scrq[i]->irq);
+			}
 	}
 
 	rc = set_link_state(adapter, IBMVNIC_LOGICAL_LNK_DN);
@@ -959,8 +992,11 @@ static int __ibmvnic_close(struct net_device *netdev)
 					break;
 			}
 
-			if (adapter->rx_scrq[i]->irq)
+			if (adapter->rx_scrq[i]->irq) {
+				netdev_dbg(adapter->netdev,
+					   "Disabling rx_scrq[%d] irq\n", i);
 				disable_irq(adapter->rx_scrq[i]->irq);
+			}
 		}
 	}
 
@@ -1353,6 +1389,9 @@ static int do_reset(struct ibmvnic_adapter *adapter,
 	struct net_device *netdev = adapter->netdev;
 	int i, rc;
 
+	netdev_dbg(adapter->netdev, "Re-setting driver (%d)\n",
+		   rwi->reset_reason);
+
 	netif_carrier_off(netdev);
 	adapter->reset_reason = rwi->reset_reason;
 
@@ -1477,6 +1516,7 @@ static void __ibmvnic_reset(struct work_struct *work)
 	}
 
 	if (rc) {
+		netdev_dbg(adapter->netdev, "Reset failed\n");
 		free_all_rwi(adapter);
 		mutex_unlock(&adapter->reset_lock);
 		return;
@@ -1526,6 +1566,8 @@ static void ibmvnic_reset(struct ibmvnic_adapter *adapter,
 	rwi->reset_reason = reason;
 	list_add_tail(&rwi->list, &adapter->rwi_list);
 	mutex_unlock(&adapter->rwi_lock);
+
+	netdev_dbg(adapter->netdev, "Scheduling reset (reason %d)\n", reason);
 	schedule_work(&adapter->ibmvnic_reset);
 }
 
@@ -1885,12 +1927,14 @@ static int reset_sub_crq_queues(struct ibmvnic_adapter *adapter)
 	int i, rc;
 
 	for (i = 0; i < adapter->req_tx_queues; i++) {
+		netdev_dbg(adapter->netdev, "Re-setting tx_scrq[%d]\n", i);
 		rc = reset_one_sub_crq_queue(adapter, adapter->tx_scrq[i]);
 		if (rc)
 			return rc;
 	}
 
 	for (i = 0; i < adapter->req_rx_queues; i++) {
+		netdev_dbg(adapter->netdev, "Re-setting rx_scrq[%d]\n", i);
 		rc = reset_one_sub_crq_queue(adapter, adapter->rx_scrq[i]);
 		if (rc)
 			return rc;
@@ -1994,6 +2038,8 @@ static void release_sub_crqs(struct ibmvnic_adapter *adapter)
 			if (!adapter->tx_scrq[i])
 				continue;
 
+			netdev_dbg(adapter->netdev, "Releasing tx_scrq[%d]\n",
+				   i);
 			if (adapter->tx_scrq[i]->irq) {
 				free_irq(adapter->tx_scrq[i]->irq,
 					 adapter->tx_scrq[i]);
@@ -2013,6 +2059,8 @@ static void release_sub_crqs(struct ibmvnic_adapter *adapter)
 			if (!adapter->rx_scrq[i])
 				continue;
 
+			netdev_dbg(adapter->netdev, "Releasing rx_scrq[%d]\n",
+				   i);
 			if (adapter->rx_scrq[i]->irq) {
 				free_irq(adapter->rx_scrq[i]->irq,
 					 adapter->rx_scrq[i]);
@@ -2167,6 +2215,8 @@ static int init_sub_crq_irqs(struct ibmvnic_adapter *adapter)
 	int rc = 0;
 
 	for (i = 0; i < adapter->req_tx_queues; i++) {
+		netdev_dbg(adapter->netdev, "Initializing tx_scrq[%d] irq\n",
+			   i);
 		scrq = adapter->tx_scrq[i];
 		scrq->irq = irq_create_mapping(NULL, scrq->hw_irq);
 
@@ -2188,6 +2238,8 @@ static int init_sub_crq_irqs(struct ibmvnic_adapter *adapter)
 	}
 
 	for (i = 0; i < adapter->req_rx_queues; i++) {
+		netdev_dbg(adapter->netdev, "Initializing rx_scrq[%d] irq\n",
+			   i);
 		scrq = adapter->rx_scrq[i];
 		scrq->irq = irq_create_mapping(NULL, scrq->hw_irq);
 		if (!scrq->irq) {
@@ -2230,6 +2282,8 @@ static int init_sub_crqs(struct ibmvnic_adapter *adapter)
 	int more = 0;
 	int i;
 
+	netdev_dbg(adapter->netdev, "Initializing sub-CRQs\n");
+
 	total_queues = adapter->req_tx_queues + adapter->req_rx_queues;
 
 	allqueues = kcalloc(total_queues, sizeof(*allqueues), GFP_KERNEL);
@@ -2309,6 +2363,8 @@ static void ibmvnic_send_req_caps(struct ibmvnic_adapter *adapter, int retry)
 	struct device *dev = &adapter->vdev->dev;
 	union ibmvnic_crq crq;
 
+	netdev_dbg(adapter->netdev, "Sending requested capabilities\n");
+
 	if (!retry) {
 		/* Sub-CRQ entries are 32 byte long */
 		int entries_page = 4 * PAGE_SIZE / (sizeof(u64) * 4);
@@ -2696,6 +2752,8 @@ static void send_cap_queries(struct ibmvnic_adapter *adapter)
 {
 	union ibmvnic_crq crq;
 
+	netdev_dbg(adapter->netdev, "Sending capability queries\n");
+
 	atomic_set(&adapter->running_cap_crqs, 0);
 	memset(&crq, 0, sizeof(crq));
 	crq.query_capability.first = IBMVNIC_CRQ_CMD;
@@ -3580,6 +3638,8 @@ static int ibmvnic_reenable_crq_queue(struct ibmvnic_adapter *adapter)
 	struct vio_dev *vdev = adapter->vdev;
 	int rc;
 
+	netdev_dbg(adapter->netdev, "Re-enabling CRQ\n");
+
 	do {
 		rc = plpar_hcall_norets(H_ENABLE_CRQ, vdev->unit_address);
 	} while (rc == H_IN_PROGRESS || rc == H_BUSY || H_IS_LONG_BUSY(rc));
@@ -3597,6 +3657,8 @@ static int ibmvnic_reset_crq(struct ibmvnic_adapter *adapter)
 	struct vio_dev *vdev = adapter->vdev;
 	int rc;
 
+	netdev_dbg(adapter->netdev, "Re-setting CRQ\n");
+
 	/* Close the CRQ */
 	do {
 		rc = plpar_hcall_norets(H_FREE_CRQ, vdev->unit_address);
@@ -3648,6 +3710,8 @@ static int init_crq_queue(struct ibmvnic_adapter *adapter)
 	struct vio_dev *vdev = adapter->vdev;
 	int rc, retrc = -ENOMEM;
 
+	netdev_dbg(adapter->netdev, "Initializing CRQ\n");
+
 	if (crq->msgs)
 		return 0;
 
@@ -3722,6 +3786,8 @@ static int ibmvnic_init(struct ibmvnic_adapter *adapter)
 	unsigned long timeout = msecs_to_jiffies(30000);
 	int rc;
 
+	netdev_dbg(adapter->netdev, "Initializing driver.\n");
+
 	if (adapter->resetting) {
 		rc = ibmvnic_reset_crq(adapter);
 		if (!rc)
