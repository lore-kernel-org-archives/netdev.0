From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net 2/4] ibmvnic: Move login to its own routine
Date: Fri, 17 Mar 2017 17:13:41 -0500
Message-ID: <1489788823-20980-3-git-send-email-jallen@linux.vnet.ibm.com>
References: <1489788823-20980-1-git-send-email-jallen@linux.vnet.ibm.com>
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com,
        nfont@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:53614 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751023AbdCRBuJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 21:50:09 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2HM9152141440
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 18:14:06 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
        by mx0a-001b2d01.pphosted.com with ESMTP id 297yvckdr0-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 18:14:05 -0400
Received: from localhost
        by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Fri, 17 Mar 2017 16:14:05 -0600
In-Reply-To: <1489788823-20980-1-git-send-email-jallen@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the code that handles login and renegotiation of ibmvnic
capabilities to its own routine.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 28 ++++++++++++++++++++--------
 1 file changed, 20 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 7588c12..b6606d8 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -371,18 +371,11 @@ static void free_rx_pool(struct ibmvnic_adapter *adapter,
 	pool->rx_buff = NULL;
 }
 
-static int ibmvnic_open(struct net_device *netdev)
+static int ibmvnic_login(struct net_device *netdev)
 {
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
 	unsigned long timeout = msecs_to_jiffies(30000);
 	struct device *dev = &adapter->vdev->dev;
-	struct ibmvnic_tx_pool *tx_pool;
-	union ibmvnic_crq crq;
-	int rxadd_subcrqs;
-	u64 *size_array;
-	int tx_subcrqs;
-	int rc = 0;
-	int i, j;
 
 	do {
 		if (adapter->renegotiate) {
@@ -407,6 +400,25 @@ static int ibmvnic_open(struct net_device *netdev)
 		}
 	} while (adapter->renegotiate);
 
+	return 0;
+}
+
+static int ibmvnic_open(struct net_device *netdev)
+{
+	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
+	struct device *dev = &adapter->vdev->dev;
+	struct ibmvnic_tx_pool *tx_pool;
+	union ibmvnic_crq crq;
+	int rxadd_subcrqs;
+	u64 *size_array;
+	int tx_subcrqs;
+	int rc = 0;
+	int i, j;
+
+	rc = ibmvnic_login(netdev);
+	if (rc)
+		return rc;
+
 	rc = netif_set_real_num_tx_queues(netdev, adapter->req_tx_queues);
 	if (rc) {
 		dev_err(dev, "failed to set the number of tx queues\n");
-- 
2.7.4
