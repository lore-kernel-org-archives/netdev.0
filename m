From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH v3 net-next 01/11] ibmvnic: Move resource initialization to
 its own routine
Date: Tue, 02 May 2017 14:52:17 -0400
Message-ID: <20170502185217.28214.21260.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170502185006.28214.89072.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:47450 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751139AbdEBPDf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:03:35 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v42ErmVL129716
        for <netdev@vger.kernel.org>; Tue, 2 May 2017 11:03:35 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a6q0n9yfq-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 11:03:34 -0400
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Tue, 2 May 2017 11:03:33 -0400
In-Reply-To: <20170502185006.28214.89072.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move all of the calls to initialize resources for the driver to
a separate routine.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   71 ++++++++++++++++++++----------------
 1 file changed, 39 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 4fcd2f0..c67f1d6 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -624,22 +624,10 @@ static int set_real_num_queues(struct net_device *netdev)
 	return rc;
 }
 
-static int ibmvnic_open(struct net_device *netdev)
+static int init_resources(struct ibmvnic_adapter *adapter)
 {
-	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
-	struct device *dev = &adapter->vdev->dev;
-	int rc = 0;
-	int i;
-
-	if (adapter->is_closed) {
-		rc = ibmvnic_init(adapter);
-		if (rc)
-			return rc;
-	}
-
-	rc = ibmvnic_login(netdev);
-	if (rc)
-		return rc;
+	struct net_device *netdev = adapter->netdev;
+	int i, rc;
 
 	rc = set_real_num_queues(netdev);
 	if (rc)
@@ -647,7 +635,7 @@ static int ibmvnic_open(struct net_device *netdev)
 
 	rc = init_sub_crq_irqs(adapter);
 	if (rc) {
-		dev_err(dev, "failed to initialize sub crq irqs\n");
+		netdev_err(netdev, "failed to initialize sub crq irqs\n");
 		return -1;
 	}
 
@@ -659,25 +647,47 @@ static int ibmvnic_open(struct net_device *netdev)
 	adapter->napi = kcalloc(adapter->req_rx_queues,
 				sizeof(struct napi_struct), GFP_KERNEL);
 	if (!adapter->napi)
-		goto ibmvnic_open_fail;
+		return -ENOMEM;
+
 	for (i = 0; i < adapter->req_rx_queues; i++) {
 		netif_napi_add(netdev, &adapter->napi[i], ibmvnic_poll,
 			       NAPI_POLL_WEIGHT);
-		napi_enable(&adapter->napi[i]);
 	}
 
 	send_map_query(adapter);
 
 	rc = init_rx_pools(netdev);
 	if (rc)
-		goto ibmvnic_open_fail;
+		return rc;
 
 	rc = init_tx_pools(netdev);
+	return rc;
+}
+
+static int ibmvnic_open(struct net_device *netdev)
+{
+	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
+	int i, rc;
+
+	if (adapter->is_closed) {
+		rc = ibmvnic_init(adapter);
+		if (rc)
+			return rc;
+	}
+
+	rc = ibmvnic_login(netdev);
 	if (rc)
-		goto ibmvnic_open_fail;
+		return rc;
+
+	rc = init_resources(adapter);
+	if (rc)
+		return rc;
 
 	replenish_pools(adapter);
 
+	for (i = 0; i < adapter->req_rx_queues; i++)
+		napi_enable(&adapter->napi[i]);
+
 	/* We're ready to receive frames, enable the sub-crq interrupts and
 	 * set the logical link state to up
 	 */
@@ -688,19 +698,16 @@ static int ibmvnic_open(struct net_device *netdev)
 		enable_scrq_irq(adapter, adapter->tx_scrq[i]);
 
 	rc = set_link_state(adapter, IBMVNIC_LOGICAL_LNK_UP);
-	if (rc)
-		goto ibmvnic_open_fail;
-
-	netif_tx_start_all_queues(netdev);
-	adapter->is_closed = false;
-
-	return 0;
+	if (rc) {
+		for (i = 0; i < adapter->req_rx_queues; i++)
+			napi_disable(&adapter->napi[i]);
+		release_resources(adapter);
+	} else {
+		netif_tx_start_all_queues(netdev);
+		adapter->is_closed = false;
+	}
 
-ibmvnic_open_fail:
-	for (i = 0; i < adapter->req_rx_queues; i++)
-		napi_disable(&adapter->napi[i]);
-	release_resources(adapter);
-	return -ENOMEM;
+	return rc;
 }
 
 static void disable_sub_crqs(struct ibmvnic_adapter *adapter)
