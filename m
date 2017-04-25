From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/2] ibmvnic: Move initialization of sub crqs to
 ibmvnic_init
Date: Tue, 25 Apr 2017 15:01:10 -0400
Message-ID: <20170425190110.41126.42778.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170425185704.41126.65738.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:52850 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1949101AbdDYPMZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:12:25 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3PF9OhN090073
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 11:12:20 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a28hf96b4-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 11:12:20 -0400
Received: from localhost
        by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Tue, 25 Apr 2017 11:12:18 -0400
In-Reply-To: <20170425185704.41126.65738.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sub crq structures are initialized in interrupt context while
handling the response to crqs when negotiating capabilities for
the driver. The sub crqs do not need to be initialized at this point
and can be moved to being done from ibmvnic_init. Moving the init
of the sub crqs to ibmvnic_init also allows use to allocate the
memory with GFP_KERNEL instead of GFP_ATOMIC.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index c2e260c..4fcd2f0 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1390,12 +1390,12 @@ static struct ibmvnic_sub_crq_queue *init_sub_crq_queue(struct ibmvnic_adapter
 	struct ibmvnic_sub_crq_queue *scrq;
 	int rc;
 
-	scrq = kzalloc(sizeof(*scrq), GFP_ATOMIC);
+	scrq = kzalloc(sizeof(*scrq), GFP_KERNEL);
 	if (!scrq)
 		return NULL;
 
 	scrq->msgs =
-		(union sub_crq *)__get_free_pages(GFP_ATOMIC | __GFP_ZERO, 2);
+		(union sub_crq *)__get_free_pages(GFP_KERNEL | __GFP_ZERO, 2);
 	if (!scrq->msgs) {
 		dev_warn(dev, "Couldn't allocate crq queue messages page\n");
 		goto zero_page_failed;
@@ -1689,7 +1689,7 @@ static int init_sub_crqs(struct ibmvnic_adapter *adapter)
 
 	total_queues = adapter->req_tx_queues + adapter->req_rx_queues;
 
-	allqueues = kcalloc(total_queues, sizeof(*allqueues), GFP_ATOMIC);
+	allqueues = kcalloc(total_queues, sizeof(*allqueues), GFP_KERNEL);
 	if (!allqueues)
 		return -1;
 
@@ -1729,7 +1729,7 @@ static int init_sub_crqs(struct ibmvnic_adapter *adapter)
 	}
 
 	adapter->tx_scrq = kcalloc(adapter->req_tx_queues,
-				   sizeof(*adapter->tx_scrq), GFP_ATOMIC);
+				   sizeof(*adapter->tx_scrq), GFP_KERNEL);
 	if (!adapter->tx_scrq)
 		goto tx_failed;
 
@@ -1739,7 +1739,7 @@ static int init_sub_crqs(struct ibmvnic_adapter *adapter)
 	}
 
 	adapter->rx_scrq = kcalloc(adapter->req_rx_queues,
-				   sizeof(*adapter->rx_scrq), GFP_ATOMIC);
+				   sizeof(*adapter->rx_scrq), GFP_KERNEL);
 	if (!adapter->rx_scrq)
 		goto rx_failed;
 
@@ -1765,7 +1765,6 @@ static void ibmvnic_send_req_caps(struct ibmvnic_adapter *adapter, int retry)
 {
 	struct device *dev = &adapter->vdev->dev;
 	union ibmvnic_crq crq;
-	int rc;
 
 	if (!retry) {
 		/* Sub-CRQ entries are 32 byte long */
@@ -1794,10 +1793,6 @@ static void ibmvnic_send_req_caps(struct ibmvnic_adapter *adapter, int retry)
 		adapter->req_mtu = adapter->netdev->mtu + ETH_HLEN;
 	}
 
-	rc = init_sub_crqs(adapter);
-	if (rc)
-		return;
-
 	memset(&crq, 0, sizeof(crq));
 	crq.request_capability.first = IBMVNIC_CRQ_CMD;
 	crq.request_capability.cmd = REQUEST_CAPABILITY;
@@ -3317,7 +3312,13 @@ static int ibmvnic_init(struct ibmvnic_adapter *adapter)
 		return -1;
 	}
 
-	return 0;
+	rc = init_sub_crqs(adapter);
+	if (rc) {
+		dev_err(dev, "Initialization of sub crqs failed\n");
+		release_crq_queue(adapter);
+	}
+
+	return rc;
 }
 
 static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
