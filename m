From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 01/11] ibmvnic: Track state of adapter napis
Date: Fri, 26 May 2017 10:30:13 -0400
Message-ID: <20170526143013.63648.93222.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
References: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:51823 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1764198AbdEZOl6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 10:41:58 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4QEfMuO030049
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:41:58 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2apkxx72n5-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:41:57 -0400
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 26 May 2017 10:41:56 -0400
In-Reply-To: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Allen <jallen@linux.vnet.ibm.com>

Track the state of ibmvnic napis. The driver can get into states where it
can be reset when napis are already disabled and attempting to disable them
again will cause the driver to hang.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   37 +++++++++++++++++++++++++++---------
 drivers/net/ethernet/ibm/ibmvnic.h |    1 +
 2 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 27f7933..4997de4 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -518,6 +518,32 @@ static void release_error_buffers(struct ibmvnic_adapter *adapter)
 	spin_unlock_irqrestore(&adapter->error_list_lock, flags);
 }
 
+static void ibmvnic_napi_enable(struct ibmvnic_adapter *adapter)
+{
+	int i;
+
+	if (adapter->napi_enabled)
+		return;
+
+	for (i = 0; i < adapter->req_rx_queues; i++)
+		napi_enable(&adapter->napi[i]);
+
+	adapter->napi_enabled = true;
+}
+
+static void ibmvnic_napi_disable(struct ibmvnic_adapter *adapter)
+{
+	int i;
+
+	if (!adapter->napi_enabled)
+		return;
+
+	for (i = 0; i < adapter->req_rx_queues; i++)
+		napi_disable(&adapter->napi[i]);
+
+	adapter->napi_enabled = false;
+}
+
 static int ibmvnic_login(struct net_device *netdev)
 {
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
@@ -674,9 +700,7 @@ static int __ibmvnic_open(struct net_device *netdev)
 
 	adapter->state = VNIC_OPENING;
 	replenish_pools(adapter);
-
-	for (i = 0; i < adapter->req_rx_queues; i++)
-		napi_enable(&adapter->napi[i]);
+	ibmvnic_napi_enable(adapter);
 
 	/* We're ready to receive frames, enable the sub-crq interrupts and
 	 * set the logical link state to up
@@ -779,12 +803,7 @@ static int __ibmvnic_close(struct net_device *netdev)
 
 	adapter->state = VNIC_CLOSING;
 	netif_tx_stop_all_queues(netdev);
-
-	if (adapter->napi) {
-		for (i = 0; i < adapter->req_rx_queues; i++)
-			napi_disable(&adapter->napi[i]);
-	}
-
+	ibmvnic_napi_disable(adapter);
 	clean_tx_pools(adapter);
 
 	if (adapter->tx_scrq) {
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 4702b48..4816e04 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -1031,4 +1031,5 @@ struct ibmvnic_adapter {
 	struct list_head rwi_list;
 	struct work_struct ibmvnic_reset;
 	bool resetting;
+	bool napi_enabled;
 };
