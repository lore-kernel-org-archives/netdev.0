From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net] ibmvnic: Use common counter for capabilities checks
Date: Wed, 15 Feb 2017 12:17:59 -0600
Message-ID: <1487182680-29421-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1487182680-29421-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:42957 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752728AbdBOSSM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 13:18:12 -0500
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1FIEVnn143298
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 13:18:11 -0500
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0a-001b2d01.pphosted.com with ESMTP id 28mstg6rbs-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 13:18:11 -0500
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 15 Feb 2017 13:18:10 -0500
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
        by d01dlp01.pok.ibm.com (Postfix) with ESMTP id C27F638C8046
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 13:18:08 -0500 (EST)
In-Reply-To: <1487182680-29421-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two different counters were being used for capabilities
requests and queries. These commands are not called
at the same time so there is no reason a single counter
cannot be used.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 71 ++++++++++++++++++++------------------
 drivers/net/ethernet/ibm/ibmvnic.h |  3 +-
 2 files changed, 39 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 244be77..fb683f2 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1255,8 +1255,6 @@ static void release_sub_crqs(struct ibmvnic_adapter *adapter)
 			}
 		adapter->rx_scrq = NULL;
 	}
-
-	adapter->requested_caps = 0;
 }
 
 static void release_sub_crqs_no_irqs(struct ibmvnic_adapter *adapter)
@@ -1278,8 +1276,6 @@ static void release_sub_crqs_no_irqs(struct ibmvnic_adapter *adapter)
 						      adapter->rx_scrq[i]);
 		adapter->rx_scrq = NULL;
 	}
-
-	adapter->requested_caps = 0;
 }
 
 static int disable_scrq_irq(struct ibmvnic_adapter *adapter,
@@ -1567,30 +1563,36 @@ static void init_sub_crqs(struct ibmvnic_adapter *adapter, int retry)
 
 	crq.request_capability.capability = cpu_to_be16(REQ_TX_QUEUES);
 	crq.request_capability.number = cpu_to_be64(adapter->req_tx_queues);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.request_capability.capability = cpu_to_be16(REQ_RX_QUEUES);
 	crq.request_capability.number = cpu_to_be64(adapter->req_rx_queues);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.request_capability.capability = cpu_to_be16(REQ_RX_ADD_QUEUES);
 	crq.request_capability.number = cpu_to_be64(adapter->req_rx_add_queues);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.request_capability.capability =
 	    cpu_to_be16(REQ_TX_ENTRIES_PER_SUBCRQ);
 	crq.request_capability.number =
 	    cpu_to_be64(adapter->req_tx_entries_per_subcrq);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.request_capability.capability =
 	    cpu_to_be16(REQ_RX_ADD_ENTRIES_PER_SUBCRQ);
 	crq.request_capability.number =
 	    cpu_to_be64(adapter->req_rx_add_entries_per_subcrq);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.request_capability.capability = cpu_to_be16(REQ_MTU);
 	crq.request_capability.number = cpu_to_be64(adapter->req_mtu);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	if (adapter->netdev->flags & IFF_PROMISC) {
@@ -1598,12 +1600,14 @@ static void init_sub_crqs(struct ibmvnic_adapter *adapter, int retry)
 			crq.request_capability.capability =
 			    cpu_to_be16(PROMISC_REQUESTED);
 			crq.request_capability.number = cpu_to_be64(1);
+			atomic_inc(&adapter->running_cap_crqs);
 			ibmvnic_send_crq(adapter, &crq);
 		}
 	} else {
 		crq.request_capability.capability =
 		    cpu_to_be16(PROMISC_REQUESTED);
 		crq.request_capability.number = cpu_to_be64(0);
+		atomic_inc(&adapter->running_cap_crqs);
 		ibmvnic_send_crq(adapter, &crq);
 	}
 
@@ -1955,112 +1959,112 @@ static void send_cap_queries(struct ibmvnic_adapter *adapter)
 {
 	union ibmvnic_crq crq;
 
-	atomic_set(&adapter->running_cap_queries, 0);
+	atomic_set(&adapter->running_cap_crqs, 0);
 	memset(&crq, 0, sizeof(crq));
 	crq.query_capability.first = IBMVNIC_CRQ_CMD;
 	crq.query_capability.cmd = QUERY_CAPABILITY;
 
 	crq.query_capability.capability = cpu_to_be16(MIN_TX_QUEUES);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability = cpu_to_be16(MIN_RX_QUEUES);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability = cpu_to_be16(MIN_RX_ADD_QUEUES);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability = cpu_to_be16(MAX_TX_QUEUES);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability = cpu_to_be16(MAX_RX_QUEUES);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability = cpu_to_be16(MAX_RX_ADD_QUEUES);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability =
 	    cpu_to_be16(MIN_TX_ENTRIES_PER_SUBCRQ);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability =
 	    cpu_to_be16(MIN_RX_ADD_ENTRIES_PER_SUBCRQ);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability =
 	    cpu_to_be16(MAX_TX_ENTRIES_PER_SUBCRQ);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability =
 	    cpu_to_be16(MAX_RX_ADD_ENTRIES_PER_SUBCRQ);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability = cpu_to_be16(TCP_IP_OFFLOAD);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability = cpu_to_be16(PROMISC_SUPPORTED);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability = cpu_to_be16(MIN_MTU);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability = cpu_to_be16(MAX_MTU);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability = cpu_to_be16(MAX_MULTICAST_FILTERS);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability = cpu_to_be16(VLAN_HEADER_INSERTION);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability = cpu_to_be16(MAX_TX_SG_ENTRIES);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability = cpu_to_be16(RX_SG_SUPPORTED);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability = cpu_to_be16(OPT_TX_COMP_SUB_QUEUES);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability = cpu_to_be16(OPT_RX_COMP_QUEUES);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability =
 			cpu_to_be16(OPT_RX_BUFADD_Q_PER_RX_COMP_Q);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability =
 			cpu_to_be16(OPT_TX_ENTRIES_PER_SUBCRQ);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability =
 			cpu_to_be16(OPT_RXBA_ENTRIES_PER_SUBCRQ);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.query_capability.capability = cpu_to_be16(TX_RX_DESC_REQ);
-	atomic_inc(&adapter->running_cap_queries);
+	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 }
 
@@ -2348,6 +2352,7 @@ static void handle_request_cap_rsp(union ibmvnic_crq *crq,
 	u64 *req_value;
 	char *name;
 
+	atomic_dec(&adapter->running_cap_crqs);
 	switch (be16_to_cpu(crq->request_capability_rsp.capability)) {
 	case REQ_TX_QUEUES:
 		req_value = &adapter->req_tx_queues;
@@ -2402,7 +2407,7 @@ static void handle_request_cap_rsp(union ibmvnic_crq *crq,
 	}
 
 	/* Done receiving requested capabilities, query IP offload support */
-	if (++adapter->requested_caps == 7) {
+	if (atomic_read(&adapter->running_cap_crqs) == 0) {
 		union ibmvnic_crq newcrq;
 		int buf_sz = sizeof(struct ibmvnic_query_ip_offload_buffer);
 		struct ibmvnic_query_ip_offload_buffer *ip_offload_buf =
@@ -2543,9 +2548,9 @@ static void handle_query_cap_rsp(union ibmvnic_crq *crq,
 	struct device *dev = &adapter->vdev->dev;
 	long rc;
 
-	atomic_dec(&adapter->running_cap_queries);
+	atomic_dec(&adapter->running_cap_crqs);
 	netdev_dbg(netdev, "Outstanding queries: %d\n",
-		   atomic_read(&adapter->running_cap_queries));
+		   atomic_read(&adapter->running_cap_crqs));
 	rc = crq->query_capability.rc.code;
 	if (rc) {
 		dev_err(dev, "Error %ld in QUERY_CAP_RSP\n", rc);
@@ -2703,7 +2708,7 @@ static void handle_query_cap_rsp(union ibmvnic_crq *crq,
 	}
 
 out:
-	if (atomic_read(&adapter->running_cap_queries) == 0)
+	if (atomic_read(&adapter->running_cap_crqs) == 0)
 		init_sub_crqs(adapter, 0);
 		/* We're done querying the capabilities, initialize sub-crqs */
 }
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 0d0edc3..504d05c 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -976,11 +976,10 @@ struct ibmvnic_adapter {
 	dma_addr_t login_rsp_buf_token;
 	int login_rsp_buf_sz;
 
-	atomic_t running_cap_queries;
+	atomic_t running_cap_crqs;
 
 	struct ibmvnic_sub_crq_queue **tx_scrq;
 	struct ibmvnic_sub_crq_queue **rx_scrq;
-	int requested_caps;
 	bool renegotiate;
 
 	/* rx structs */
-- 
2.7.4
