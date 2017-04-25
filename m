From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/2] ibmvnic: Split initialization of scrqs to its
 own routine
Date: Tue, 25 Apr 2017 15:01:04 -0400
Message-ID: <20170425190104.41126.22322.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170425185704.41126.65738.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40261 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1949082AbdDYPMS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:12:18 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3PF9PUA099587
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 11:12:17 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2a1v50xpke-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 11:12:17 -0400
Received: from localhost
        by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Tue, 25 Apr 2017 11:12:16 -0400
In-Reply-To: <20170425185704.41126.65738.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split the sending of capability request crqs and the initialization
of sub crqs into their own routines. This is a first step to moving
the allocation of sub-crqs out of interrupt context.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |  101 +++++++++++++++++++-----------------
 1 file changed, 54 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 51bf337..c2e260c 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1678,48 +1678,20 @@ static int init_sub_crq_irqs(struct ibmvnic_adapter *adapter)
 	return rc;
 }
 
-static void init_sub_crqs(struct ibmvnic_adapter *adapter, int retry)
+static int init_sub_crqs(struct ibmvnic_adapter *adapter)
 {
 	struct device *dev = &adapter->vdev->dev;
 	struct ibmvnic_sub_crq_queue **allqueues;
 	int registered_queues = 0;
-	union ibmvnic_crq crq;
 	int total_queues;
 	int more = 0;
 	int i;
 
-	if (!retry) {
-		/* Sub-CRQ entries are 32 byte long */
-		int entries_page = 4 * PAGE_SIZE / (sizeof(u64) * 4);
-
-		if (adapter->min_tx_entries_per_subcrq > entries_page ||
-		    adapter->min_rx_add_entries_per_subcrq > entries_page) {
-			dev_err(dev, "Fatal, invalid entries per sub-crq\n");
-			goto allqueues_failed;
-		}
-
-		/* Get the minimum between the queried max and the entries
-		 * that fit in our PAGE_SIZE
-		 */
-		adapter->req_tx_entries_per_subcrq =
-		    adapter->max_tx_entries_per_subcrq > entries_page ?
-		    entries_page : adapter->max_tx_entries_per_subcrq;
-		adapter->req_rx_add_entries_per_subcrq =
-		    adapter->max_rx_add_entries_per_subcrq > entries_page ?
-		    entries_page : adapter->max_rx_add_entries_per_subcrq;
-
-		adapter->req_tx_queues = adapter->opt_tx_comp_sub_queues;
-		adapter->req_rx_queues = adapter->opt_rx_comp_queues;
-		adapter->req_rx_add_queues = adapter->max_rx_add_queues;
-
-		adapter->req_mtu = adapter->netdev->mtu + ETH_HLEN;
-	}
-
 	total_queues = adapter->req_tx_queues + adapter->req_rx_queues;
 
 	allqueues = kcalloc(total_queues, sizeof(*allqueues), GFP_ATOMIC);
 	if (!allqueues)
-		goto allqueues_failed;
+		return -1;
 
 	for (i = 0; i < total_queues; i++) {
 		allqueues[i] = init_sub_crq_queue(adapter);
@@ -1776,6 +1748,56 @@ static void init_sub_crqs(struct ibmvnic_adapter *adapter, int retry)
 		adapter->rx_scrq[i]->scrq_num = i;
 	}
 
+	kfree(allqueues);
+	return 0;
+
+rx_failed:
+	kfree(adapter->tx_scrq);
+	adapter->tx_scrq = NULL;
+tx_failed:
+	for (i = 0; i < registered_queues; i++)
+		release_sub_crq_queue(adapter, allqueues[i]);
+	kfree(allqueues);
+	return -1;
+}
+
+static void ibmvnic_send_req_caps(struct ibmvnic_adapter *adapter, int retry)
+{
+	struct device *dev = &adapter->vdev->dev;
+	union ibmvnic_crq crq;
+	int rc;
+
+	if (!retry) {
+		/* Sub-CRQ entries are 32 byte long */
+		int entries_page = 4 * PAGE_SIZE / (sizeof(u64) * 4);
+
+		if (adapter->min_tx_entries_per_subcrq > entries_page ||
+		    adapter->min_rx_add_entries_per_subcrq > entries_page) {
+			dev_err(dev, "Fatal, invalid entries per sub-crq\n");
+			return;
+		}
+
+		/* Get the minimum between the queried max and the entries
+		 * that fit in our PAGE_SIZE
+		 */
+		adapter->req_tx_entries_per_subcrq =
+		    adapter->max_tx_entries_per_subcrq > entries_page ?
+		    entries_page : adapter->max_tx_entries_per_subcrq;
+		adapter->req_rx_add_entries_per_subcrq =
+		    adapter->max_rx_add_entries_per_subcrq > entries_page ?
+		    entries_page : adapter->max_rx_add_entries_per_subcrq;
+
+		adapter->req_tx_queues = adapter->opt_tx_comp_sub_queues;
+		adapter->req_rx_queues = adapter->opt_rx_comp_queues;
+		adapter->req_rx_add_queues = adapter->max_rx_add_queues;
+
+		adapter->req_mtu = adapter->netdev->mtu + ETH_HLEN;
+	}
+
+	rc = init_sub_crqs(adapter);
+	if (rc)
+		return;
+
 	memset(&crq, 0, sizeof(crq));
 	crq.request_capability.first = IBMVNIC_CRQ_CMD;
 	crq.request_capability.cmd = REQUEST_CAPABILITY;
@@ -1829,20 +1851,6 @@ static void init_sub_crqs(struct ibmvnic_adapter *adapter, int retry)
 		atomic_inc(&adapter->running_cap_crqs);
 		ibmvnic_send_crq(adapter, &crq);
 	}
-
-	kfree(allqueues);
-
-	return;
-
-rx_failed:
-	kfree(adapter->tx_scrq);
-	adapter->tx_scrq = NULL;
-tx_failed:
-	for (i = 0; i < registered_queues; i++)
-		release_sub_crq_queue(adapter, allqueues[i]);
-	kfree(allqueues);
-allqueues_failed:
-	ibmvnic_remove(adapter->vdev);
 }
 
 static int pending_scrq(struct ibmvnic_adapter *adapter,
@@ -2568,7 +2576,7 @@ static void handle_request_cap_rsp(union ibmvnic_crq *crq,
 					       number), name);
 		release_sub_crqs(adapter);
 		*req_value = be64_to_cpu(crq->request_capability_rsp.number);
-		init_sub_crqs(adapter, 1);
+		ibmvnic_send_req_caps(adapter, 1);
 		return;
 	default:
 		dev_err(dev, "Error %d in request cap rsp\n",
@@ -2881,8 +2889,7 @@ static void handle_query_cap_rsp(union ibmvnic_crq *crq,
 out:
 	if (atomic_read(&adapter->running_cap_crqs) == 0) {
 		adapter->wait_capability = false;
-		init_sub_crqs(adapter, 0);
-		/* We're done querying the capabilities, initialize sub-crqs */
+		ibmvnic_send_req_caps(adapter, 0);
 	}
 }
 
