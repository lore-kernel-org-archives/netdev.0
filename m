From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net 1/4] ibmvnic: Move login and queue negotiation into ibmvnic_open
Date: Fri, 17 Mar 2017 17:13:40 -0500
Message-ID: <1489788823-20980-2-git-send-email-jallen@linux.vnet.ibm.com>
References: <1489788823-20980-1-git-send-email-jallen@linux.vnet.ibm.com>
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com,
        nfont@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:56476 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751023AbdCQWWK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 18:22:10 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2HM94C4070574
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 18:13:58 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
        by mx0a-001b2d01.pphosted.com with ESMTP id 298me68xhy-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 18:13:58 -0400
Received: from localhost
        by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Fri, 17 Mar 2017 18:13:57 -0400
In-Reply-To: <1489788823-20980-1-git-send-email-jallen@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VNIC server expects LINK_STATE_UP to be sent within 30s of the login. If we
exceed the timeout, VNIC server will attempt to fail over. Since time
between probe and open of the device is indeterminate, move login and queue
negotiation into ibmvnic open so we can guarantee that login and sending
LINK_STATE_UP occur within the 30s window.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 88 +++++++++++++++++++-------------------
 1 file changed, 43 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index b23d654..7588c12 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -110,6 +110,9 @@ static int ibmvnic_poll(struct napi_struct *napi, int data);
 static void send_map_query(struct ibmvnic_adapter *adapter);
 static void send_request_map(struct ibmvnic_adapter *, dma_addr_t, __be32, u8);
 static void send_request_unmap(struct ibmvnic_adapter *, u8);
+static void send_login(struct ibmvnic_adapter *adapter);
+static void send_cap_queries(struct ibmvnic_adapter *adapter);
+static int init_sub_crq_irqs(struct ibmvnic_adapter *adapter);
 
 struct ibmvnic_stat {
 	char name[ETH_GSTRING_LEN];
@@ -371,14 +374,51 @@ static void free_rx_pool(struct ibmvnic_adapter *adapter,
 static int ibmvnic_open(struct net_device *netdev)
 {
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
+	unsigned long timeout = msecs_to_jiffies(30000);
 	struct device *dev = &adapter->vdev->dev;
 	struct ibmvnic_tx_pool *tx_pool;
 	union ibmvnic_crq crq;
 	int rxadd_subcrqs;
 	u64 *size_array;
 	int tx_subcrqs;
+	int rc = 0;
 	int i, j;
 
+	do {
+		if (adapter->renegotiate) {
+			adapter->renegotiate = false;
+			release_sub_crqs_no_irqs(adapter);
+
+			reinit_completion(&adapter->init_done);
+			send_cap_queries(adapter);
+			if (!wait_for_completion_timeout(&adapter->init_done,
+							 timeout)) {
+				dev_err(dev, "Capabilities query timeout\n");
+				return -1;
+			}
+		}
+
+		reinit_completion(&adapter->init_done);
+		send_login(adapter);
+		if (!wait_for_completion_timeout(&adapter->init_done,
+						 timeout)) {
+			dev_err(dev, "Login timeout\n");
+			return -1;
+		}
+	} while (adapter->renegotiate);
+
+	rc = netif_set_real_num_tx_queues(netdev, adapter->req_tx_queues);
+	if (rc) {
+		dev_err(dev, "failed to set the number of tx queues\n");
+		return -1;
+	}
+
+	rc = init_sub_crq_irqs(adapter);
+	if (rc) {
+		dev_err(dev, "failed to initialize sub crq irqs\n");
+		return -1;
+	}
+
 	rxadd_subcrqs =
 	    be32_to_cpu(adapter->login_rsp_buf->num_rxadd_subcrqs);
 	tx_subcrqs =
@@ -508,6 +548,7 @@ static int ibmvnic_open(struct net_device *netdev)
 	for (i = 0; i < adapter->req_rx_queues; i++)
 		napi_disable(&adapter->napi[i]);
 alloc_napi_failed:
+	release_sub_crqs(adapter);
 	return -ENOMEM;
 }
 
@@ -3421,8 +3462,7 @@ static void ibmvnic_handle_crq(union ibmvnic_crq *crq,
 		dma_unmap_single(dev, adapter->ip_offload_ctrl_tok,
 				 sizeof(adapter->ip_offload_ctrl),
 				 DMA_TO_DEVICE);
-		/* We're done with the queries, perform the login */
-		send_login(adapter);
+		complete(&adapter->init_done);
 		break;
 	case REQUEST_RAS_COMP_NUM_RSP:
 		netdev_dbg(netdev, "Got Request RAS Comp Num Response\n");
@@ -3702,26 +3742,6 @@ static void handle_crq_init_rsp(struct work_struct *work)
 		goto task_failed;
 	}
 
-	do {
-		if (adapter->renegotiate) {
-			adapter->renegotiate = false;
-			release_sub_crqs_no_irqs(adapter);
-
-			reinit_completion(&adapter->init_done);
-			send_cap_queries(adapter);
-			if (!wait_for_completion_timeout(&adapter->init_done,
-							 timeout)) {
-				dev_err(dev, "Passive init timeout\n");
-				goto task_failed;
-			}
-		}
-	} while (adapter->renegotiate);
-	rc = init_sub_crq_irqs(adapter);
-
-	if (rc)
-		goto task_failed;
-
-	netdev->real_num_tx_queues = adapter->req_tx_queues;
 	netdev->mtu = adapter->req_mtu - ETH_HLEN;
 
 	if (adapter->failover) {
@@ -3842,39 +3862,17 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	if (!wait_for_completion_timeout(&adapter->init_done, timeout))
 		return 0;
 
-	do {
-		if (adapter->renegotiate) {
-			adapter->renegotiate = false;
-			release_sub_crqs_no_irqs(adapter);
-
-			reinit_completion(&adapter->init_done);
-			send_cap_queries(adapter);
-			if (!wait_for_completion_timeout(&adapter->init_done,
-							 timeout))
-				return 0;
-		}
-	} while (adapter->renegotiate);
-
-	rc = init_sub_crq_irqs(adapter);
-	if (rc) {
-		dev_err(&dev->dev, "failed to initialize sub crq irqs\n");
-		goto free_debugfs;
-	}
-
-	netdev->real_num_tx_queues = adapter->req_tx_queues;
 	netdev->mtu = adapter->req_mtu - ETH_HLEN;
 
 	rc = register_netdev(netdev);
 	if (rc) {
 		dev_err(&dev->dev, "failed to register netdev rc=%d\n", rc);
-		goto free_sub_crqs;
+		goto free_debugfs;
 	}
 	dev_info(&dev->dev, "ibmvnic registered\n");
 
 	return 0;
 
-free_sub_crqs:
-	release_sub_crqs(adapter);
 free_debugfs:
 	if (adapter->debugfs_dir && !IS_ERR(adapter->debugfs_dir))
 		debugfs_remove_recursive(adapter->debugfs_dir);
-- 
2.7.4
