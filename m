From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH v4 net-next 07/11] ibmvnic: Wait for any pending scrqs
 entries at driver close
Date: Wed, 03 May 2017 14:05:02 -0400
Message-ID: <20170503180502.29742.92401.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170503180246.29742.64039.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:52241 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753327AbdECOQV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 10:16:21 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v43EDZw7078628
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 10:16:21 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a73gwh6rt-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 10:16:20 -0400
Received: from localhost
        by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 3 May 2017 10:16:19 -0400
In-Reply-To: <20170503180246.29742.64039.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When closing the ibmvnic driver we need to wait for any pending
sub crq entries to ensure they are handled.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   47 +++++++++++++++++++++---------------
 1 file changed, 27 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 2297cf2..a312bc1 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -743,23 +743,6 @@ static int ibmvnic_open(struct net_device *netdev)
 	return rc;
 }
 
-static void disable_sub_crqs(struct ibmvnic_adapter *adapter)
-{
-	int i;
-
-	if (adapter->tx_scrq) {
-		for (i = 0; i < adapter->req_tx_queues; i++)
-			if (adapter->tx_scrq[i])
-				disable_irq(adapter->tx_scrq[i]->irq);
-	}
-
-	if (adapter->rx_scrq) {
-		for (i = 0; i < adapter->req_rx_queues; i++)
-			if (adapter->rx_scrq[i])
-				disable_irq(adapter->rx_scrq[i]->irq);
-	}
-}
-
 static void clean_tx_pools(struct ibmvnic_adapter *adapter)
 {
 	struct ibmvnic_tx_pool *tx_pool;
@@ -797,15 +780,39 @@ static int __ibmvnic_close(struct net_device *netdev)
 	adapter->state = VNIC_CLOSING;
 	netif_tx_stop_all_queues(netdev);
 
-	clean_tx_pools(adapter);
-	disable_sub_crqs(adapter);
-
 	if (adapter->napi) {
 		for (i = 0; i < adapter->req_rx_queues; i++)
 			napi_disable(&adapter->napi[i]);
 	}
 
+	clean_tx_pools(adapter);
+
+	if (adapter->tx_scrq) {
+		for (i = 0; i < adapter->req_tx_queues; i++)
+			if (adapter->tx_scrq[i]->irq)
+				disable_irq(adapter->tx_scrq[i]->irq);
+	}
+
 	rc = set_link_state(adapter, IBMVNIC_LOGICAL_LNK_DN);
+	if (rc)
+		return rc;
+
+	if (adapter->rx_scrq) {
+		for (i = 0; i < adapter->req_rx_queues; i++) {
+			int retries = 10;
+
+			while (pending_scrq(adapter, adapter->rx_scrq[i])) {
+				retries--;
+				mdelay(100);
+
+				if (retries == 0)
+					break;
+			}
+
+			if (adapter->rx_scrq[i]->irq)
+				disable_irq(adapter->rx_scrq[i]->irq);
+		}
+	}
 
 	adapter->state = VNIC_CLOSED;
 	return rc;
