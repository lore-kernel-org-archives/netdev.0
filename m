From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH v3 net-next 07/11] ibmvnic: Wait for any pending scrqs
 entries at driver close
Date: Tue, 02 May 2017 14:52:53 -0400
Message-ID: <20170502185253.28214.11101.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170502185006.28214.89072.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:44902 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751434AbdEBPEQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:04:16 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v42F401m069361
        for <netdev@vger.kernel.org>; Tue, 2 May 2017 11:04:11 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a6frxe9sh-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 11:04:10 -0400
Received: from localhost
        by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Tue, 2 May 2017 11:04:10 -0400
In-Reply-To: <20170502185006.28214.89072.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When closing the ibmvnic driver we need to wait for any pending
sub crq entries to ensure they are handled.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   47 +++++++++++++++++++++---------------
 1 file changed, 27 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 0400ae7..4da7080 100644
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
