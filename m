From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net 5/7] ibmvnic: Merge the two release_sub_crq_queue
 routines
Date: Thu, 30 Mar 2017 02:49:18 -0400
Message-ID: <20170330064917.20309.98583.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170330064542.20309.17448.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:48137 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754450AbdC3C75 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 22:59:57 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2U2sWPU030735
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 22:59:56 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29gdaeg3w7-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 22:59:56 -0400
Received: from localhost
        by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 29 Mar 2017 22:59:55 -0400
In-Reply-To: <20170330064542.20309.17448.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keeping two routines for releasing sub crqs, one for when irqs are not
initialized and one for when they are, is a bit of overkill. Merge the
two routines to a common release routine that will check for an irq
and release it if needed.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   54 +++++++++++++++---------------------
 1 file changed, 22 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 6774b3c..f2d2f1f 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -88,7 +88,6 @@
 static int ibmvnic_version = IBMVNIC_INITIAL_VERSION;
 static int ibmvnic_remove(struct vio_dev *);
 static void release_sub_crqs(struct ibmvnic_adapter *);
-static void release_sub_crqs_no_irqs(struct ibmvnic_adapter *);
 static int ibmvnic_reset_crq(struct ibmvnic_adapter *);
 static int ibmvnic_send_crq_init(struct ibmvnic_adapter *);
 static int ibmvnic_reenable_crq_queue(struct ibmvnic_adapter *);
@@ -526,7 +525,7 @@ static int ibmvnic_login(struct net_device *netdev)
 	do {
 		if (adapter->renegotiate) {
 			adapter->renegotiate = false;
-			release_sub_crqs_no_irqs(adapter);
+			release_sub_crqs(adapter);
 
 			reinit_completion(&adapter->init_done);
 			send_cap_queries(adapter);
@@ -1371,49 +1370,40 @@ static void release_sub_crqs(struct ibmvnic_adapter *adapter)
 	int i;
 
 	if (adapter->tx_scrq) {
-		for (i = 0; i < adapter->req_tx_queues; i++)
-			if (adapter->tx_scrq[i]) {
+		for (i = 0; i < adapter->req_tx_queues; i++) {
+			if (!adapter->tx_scrq[i])
+				continue;
+
+			if (adapter->tx_scrq[i]->irq) {
 				free_irq(adapter->tx_scrq[i]->irq,
 					 adapter->tx_scrq[i]);
 				irq_dispose_mapping(adapter->tx_scrq[i]->irq);
-				release_sub_crq_queue(adapter,
-						      adapter->tx_scrq[i]);
+				adapter->tx_scrq[i]->irq = 0;
 			}
+
+			release_sub_crq_queue(adapter, adapter->tx_scrq[i]);
+		}
+
 		kfree(adapter->tx_scrq);
 		adapter->tx_scrq = NULL;
 	}
 
 	if (adapter->rx_scrq) {
-		for (i = 0; i < adapter->req_rx_queues; i++)
-			if (adapter->rx_scrq[i]) {
+		for (i = 0; i < adapter->req_rx_queues; i++) {
+			if (!adapter->rx_scrq[i])
+				continue;
+
+			if (adapter->rx_scrq[i]->irq) {
 				free_irq(adapter->rx_scrq[i]->irq,
 					 adapter->rx_scrq[i]);
 				irq_dispose_mapping(adapter->rx_scrq[i]->irq);
-				release_sub_crq_queue(adapter,
-						      adapter->rx_scrq[i]);
+				adapter->rx_scrq[i]->irq = 0;
 			}
-		kfree(adapter->rx_scrq);
-		adapter->rx_scrq = NULL;
-	}
-}
 
-static void release_sub_crqs_no_irqs(struct ibmvnic_adapter *adapter)
-{
-	int i;
-
-	if (adapter->tx_scrq) {
-		for (i = 0; i < adapter->req_tx_queues; i++)
-			if (adapter->tx_scrq[i])
-				release_sub_crq_queue(adapter,
-						      adapter->tx_scrq[i]);
-		adapter->tx_scrq = NULL;
-	}
+			release_sub_crq_queue(adapter, adapter->rx_scrq[i]);
+		}
 
-	if (adapter->rx_scrq) {
-		for (i = 0; i < adapter->req_rx_queues; i++)
-			if (adapter->rx_scrq[i])
-				release_sub_crq_queue(adapter,
-						      adapter->rx_scrq[i]);
+		kfree(adapter->rx_scrq);
 		adapter->rx_scrq = NULL;
 	}
 }
@@ -1609,7 +1599,7 @@ static int init_sub_crq_irqs(struct ibmvnic_adapter *adapter)
 		free_irq(adapter->tx_scrq[j]->irq, adapter->tx_scrq[j]);
 		irq_dispose_mapping(adapter->rx_scrq[j]->irq);
 	}
-	release_sub_crqs_no_irqs(adapter);
+	release_sub_crqs(adapter);
 	return rc;
 }
 
@@ -2499,7 +2489,7 @@ static void handle_request_cap_rsp(union ibmvnic_crq *crq,
 			 *req_value,
 			 (long int)be64_to_cpu(crq->request_capability_rsp.
 					       number), name);
-		release_sub_crqs_no_irqs(adapter);
+		release_sub_crqs(adapter);
 		*req_value = be64_to_cpu(crq->request_capability_rsp.number);
 		init_sub_crqs(adapter, 1);
 		return;
