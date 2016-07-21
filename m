From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [RFC PATCH net-next] ibmvnic: Handle backing device failover and reinitialization
Date: Wed, 20 Jul 2016 22:58:33 -0500
Message-ID: <1469073513-318-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: jallen@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:34137 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750728AbcGUD6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 23:58:38 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6L3sF0h132914
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 23:58:37 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24akx6mq1q-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 23:58:37 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Wed, 20 Jul 2016 21:58:36 -0600
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 3D5F2C40002
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 21:58:18 -0600 (MDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An upcoming feature of IBM VNIC protocol is the ability to configure
redundant backing devices for a VNIC client. In case of a failure
on the current backing device, the driver will receive a signal
from the hypervisor indicating that a failover will occur. The driver
will then wait for a message from the backing device before starting
the establishing a new connection.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
RFC because this patch doesn't apply to the net-next tree yet.
It relies on some patches that were recently included in the net tree.
---
 drivers/net/ethernet/ibm/ibmvnic.c | 35 ++++++++++++++++++++++++++++++++---
 drivers/net/ethernet/ibm/ibmvnic.h |  2 ++
 2 files changed, 34 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 88f3c85..0922298 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -203,7 +203,8 @@ static void free_long_term_buff(struct ibmvnic_adapter *adapter,
 	struct device *dev = &adapter->vdev->dev;
 
 	dma_free_coherent(dev, ltb->size, ltb->buff, ltb->addr);
-	send_request_unmap(adapter, ltb->map_id);
+	if (!adapter->failover)
+		send_request_unmap(adapter, ltb->map_id);
 }
 
 static int alloc_rx_pool(struct ibmvnic_adapter *adapter,
@@ -471,7 +472,10 @@ static int ibmvnic_open(struct net_device *netdev)
 	crq.logical_link_state.link_state = IBMVNIC_LOGICAL_LNK_UP;
 	ibmvnic_send_crq(adapter, &crq);
 
-	netif_tx_start_all_queues(netdev);
+	if (!adapter->failover)
+		netif_tx_start_all_queues(netdev);
+	else
+		netif_tx_wake_all_queues(netdev);
 
 	return 0;
 
@@ -522,7 +526,10 @@ static int ibmvnic_close(struct net_device *netdev)
 	for (i = 0; i < adapter->req_rx_queues; i++)
 		napi_disable(&adapter->napi[i]);
 
-	netif_tx_stop_all_queues(netdev);
+	if (!adapter->failover)
+		netif_tx_stop_all_queues(netdev);
+	else
+		netif_tx_disable(netdev);
 
 	if (adapter->bounce_buffer) {
 		if (!dma_mapping_error(dev, adapter->bounce_buffer_dma)) {
@@ -3280,6 +3287,10 @@ static void ibmvnic_handle_crq(union ibmvnic_crq *crq,
 			rc = ibmvnic_send_crq_init(adapter);
 			if (rc)
 				dev_err(dev, "Error sending init rc=%ld\n", rc);
+		} else if (gen_crq->cmd == IBMVNIC_DEVICE_FAILOVER) {
+			dev_info(dev, "Backing device failover detected\n");
+			netif_carrier_off(netdev);
+			adapter->failover = true;
 		} else {
 			/* The adapter lost the connection */
 			dev_err(dev, "Virtual Adapter failed (rc=%d)\n",
@@ -3615,8 +3626,17 @@ static void handle_crq_init_rsp(struct work_struct *work)
 	struct device *dev = &adapter->vdev->dev;
 	struct net_device *netdev = adapter->netdev;
 	unsigned long timeout = msecs_to_jiffies(30000);
+	bool restart = false;
 	int rc;
 
+	if (adapter->failover) {
+		release_sub_crqs(adapter);
+		if (netif_running(netdev)) {
+			ibmvnic_close(netdev);
+			restart = true;
+		}
+	}
+
 	send_version_xchg(adapter);
 	reinit_completion(&adapter->init_done);
 	if (!wait_for_completion_timeout(&adapter->init_done, timeout)) {
@@ -3645,6 +3665,14 @@ static void handle_crq_init_rsp(struct work_struct *work)
 
 	netdev->real_num_tx_queues = adapter->req_tx_queues;
 
+	if (adapter->failover) {
+		if (restart)
+			ibmvnic_open(netdev);
+		netif_carrier_on(netdev);
+		adapter->failover = false;
+		return;
+	}
+
 	rc = register_netdev(netdev);
 	if (rc) {
 		dev_err(dev,
@@ -3692,6 +3720,7 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	dev_set_drvdata(&dev->dev, netdev);
 	adapter->vdev = dev;
 	adapter->netdev = netdev;
+	adapter->failover = false;
 
 	ether_addr_copy(adapter->mac_addr, mac_addr_p);
 	ether_addr_copy(netdev->dev_addr, adapter->mac_addr);
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index e82898f..bfc84c7 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -830,6 +830,7 @@ enum ibmvfc_crq_format {
 	IBMVNIC_CRQ_INIT                 = 0x01,
 	IBMVNIC_CRQ_INIT_COMPLETE        = 0x02,
 	IBMVNIC_PARTITION_MIGRATED       = 0x06,
+	IBMVNIC_DEVICE_FAILOVER          = 0x08,
 };
 
 struct ibmvnic_crq_queue {
@@ -1047,4 +1048,5 @@ struct ibmvnic_adapter {
 	u8 map_id;
 
 	struct work_struct vnic_crq_init;
+	bool failover;
 };
-- 
1.8.3.1
