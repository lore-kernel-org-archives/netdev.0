From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net] ibmvnic: Initialize SCRQ's during login renegotiation
Date: Tue,  1 Aug 2017 15:04:36 -0500
Message-ID: <1501617876-17568-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:43540 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752370AbdHAUEn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 16:04:43 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v71K4Wda031411
        for <netdev@vger.kernel.org>; Tue, 1 Aug 2017 16:04:43 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2c2y7n37v0-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 16:04:42 -0400
Received: from localhost
        by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Tue, 1 Aug 2017 14:04:42 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCRQ resources are freed during renegotiation, but they are not
re-allocated afterwards due to some changes in the initialization
process. Fix that by re-allocating the memory after renegotation.

SCRQ's can also be freed if a server capabilities request fails.
If this were encountered during a device reset for example,
SCRQ's may not be re-allocated. This operation is not necessary
anymore so remove it.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index a3e6946..c45e8e3 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -111,6 +111,7 @@ static void send_request_map(struct ibmvnic_adapter *, dma_addr_t, __be32, u8);
 static void send_request_unmap(struct ibmvnic_adapter *, u8);
 static void send_login(struct ibmvnic_adapter *adapter);
 static void send_cap_queries(struct ibmvnic_adapter *adapter);
+static int init_sub_crqs(struct ibmvnic_adapter *);
 static int init_sub_crq_irqs(struct ibmvnic_adapter *adapter);
 static int ibmvnic_init(struct ibmvnic_adapter *);
 static void release_crq_queue(struct ibmvnic_adapter *);
@@ -651,6 +652,7 @@ static int ibmvnic_login(struct net_device *netdev)
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
 	unsigned long timeout = msecs_to_jiffies(30000);
 	struct device *dev = &adapter->vdev->dev;
+	int rc;
 
 	do {
 		if (adapter->renegotiate) {
@@ -664,6 +666,18 @@ static int ibmvnic_login(struct net_device *netdev)
 				dev_err(dev, "Capabilities query timeout\n");
 				return -1;
 			}
+			rc = init_sub_crqs(adapter);
+			if (rc) {
+				dev_err(dev,
+					"Initialization of SCRQ's failed\n");
+				return -1;
+			}
+			rc = init_sub_crq_irqs(adapter);
+			if (rc) {
+				dev_err(dev,
+					"Initialization of SCRQ's irqs failed\n");
+				return -1;
+			}
 		}
 
 		reinit_completion(&adapter->init_done);
@@ -3004,7 +3018,6 @@ static void handle_request_cap_rsp(union ibmvnic_crq *crq,
 			 *req_value,
 			 (long int)be64_to_cpu(crq->request_capability_rsp.
 					       number), name);
-		release_sub_crqs(adapter);
 		*req_value = be64_to_cpu(crq->request_capability_rsp.number);
 		ibmvnic_send_req_caps(adapter, 1);
 		return;
-- 
2.7.4
