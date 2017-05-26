From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 11/11] ibmvnic: Reset sub-crqs during driver reset
Date: Fri, 26 May 2017 10:31:12 -0400
Message-ID: <20170526143111.63648.18053.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
References: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:59418 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1030634AbdEZOm5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 10:42:57 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4QEe3Ue026903
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:56 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2apjnfjmxe-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:56 -0400
Received: from localhost
        by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 26 May 2017 10:42:55 -0400
In-Reply-To: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the ibmvnic driver is resetting, we can just reset the sub crqs
instead of releasing all of their resources and re-allocting them.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   46 ++++++++++++++++++++++++++++++++++--
 1 file changed, 43 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 5661a04..8dcf580 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1320,8 +1320,6 @@ static int do_reset(struct ibmvnic_adapter *adapter,
 		 */
 		adapter->state = VNIC_PROBED;
 
-		release_sub_crqs(adapter);
-
 		rc = ibmvnic_init(adapter);
 		if (rc)
 			return 0;
@@ -1728,6 +1726,45 @@ static void ibmvnic_get_ethtool_stats(struct net_device *dev,
 
 /* Routines for managing CRQs/sCRQs  */
 
+static int reset_one_sub_crq_queue(struct ibmvnic_adapter *adapter,
+				   struct ibmvnic_sub_crq_queue *scrq)
+{
+	int rc;
+
+	if (scrq->irq) {
+		free_irq(scrq->irq, scrq);
+		irq_dispose_mapping(scrq->irq);
+		scrq->irq = 0;
+	}
+
+	memset(scrq->msgs, 0, 2 * PAGE_SIZE);
+	scrq->cur = 0;
+
+	rc = h_reg_sub_crq(adapter->vdev->unit_address, scrq->msg_token,
+			   4 * PAGE_SIZE, &scrq->crq_num, &scrq->hw_irq);
+	return rc;
+}
+
+static int reset_sub_crq_queues(struct ibmvnic_adapter *adapter)
+{
+	int i, rc;
+
+	for (i = 0; i < adapter->req_tx_queues; i++) {
+		rc = reset_one_sub_crq_queue(adapter, adapter->tx_scrq[i]);
+		if (rc)
+			return rc;
+	}
+
+	for (i = 0; i < adapter->req_rx_queues; i++) {
+		rc = reset_one_sub_crq_queue(adapter, adapter->rx_scrq[i]);
+		if (rc)
+			return rc;
+	}
+
+	rc = init_sub_crq_irqs(adapter);
+	return rc;
+}
+
 static void release_sub_crq_queue(struct ibmvnic_adapter *adapter,
 				  struct ibmvnic_sub_crq_queue *scrq)
 {
@@ -3607,7 +3644,10 @@ static int ibmvnic_init(struct ibmvnic_adapter *adapter)
 		return -1;
 	}
 
-	rc = init_sub_crqs(adapter);
+	if (adapter->resetting)
+		rc = reset_sub_crq_queues(adapter);
+	else
+		rc = init_sub_crqs(adapter);
 	if (rc) {
 		dev_err(dev, "Initialization of sub crqs failed\n");
 		release_crq_queue(adapter);
