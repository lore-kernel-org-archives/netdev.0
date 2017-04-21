From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/7] ibmvnic: Set real number of rx queues
Date: Fri, 21 Apr 2017 15:38:40 -0400
Message-ID: <20170421193840.11030.74131.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170421193627.11030.34813.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:47231 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1423118AbdDUSCX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:02:23 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3LFmwen010743
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:49:44 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29ygefq0vn-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:49:44 -0400
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 21 Apr 2017 11:49:44 -0400
In-Reply-To: <20170421193627.11030.34813.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Along with 5 TX queues, 5 RX queues are allocated at the beginning of
device probe. However, only the real number of TX queues is set. Configure
the real number of RX queues as well.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   26 +++++++++++++++++++++-----
 1 file changed, 21 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index e8c72ab..7f4cecb 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -560,6 +560,24 @@ static void release_resources(struct ibmvnic_adapter *adapter)
 	release_error_buffers(adapter);
 }
 
+static int set_real_num_queues(struct net_device *netdev)
+{
+	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
+	int rc;
+
+	rc = netif_set_real_num_tx_queues(netdev, adapter->req_tx_queues);
+	if (rc) {
+		netdev_err(netdev, "failed to set the number of tx queues\n");
+		return rc;
+	}
+
+	rc = netif_set_real_num_rx_queues(netdev, adapter->req_rx_queues);
+	if (rc)
+		netdev_err(netdev, "failed to set the number of rx queues\n");
+
+	return rc;
+}
+
 static int ibmvnic_open(struct net_device *netdev)
 {
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
@@ -578,11 +596,9 @@ static int ibmvnic_open(struct net_device *netdev)
 	if (rc)
 		return rc;
 
-	rc = netif_set_real_num_tx_queues(netdev, adapter->req_tx_queues);
-	if (rc) {
-		dev_err(dev, "failed to set the number of tx queues\n");
-		return -1;
-	}
+	rc = set_real_num_queues(netdev);
+	if (rc)
+		return rc;
 
 	rc = init_sub_crq_irqs(adapter);
 	if (rc) {
