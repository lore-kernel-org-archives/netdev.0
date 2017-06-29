From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net-next] ibmvnic: Fix assignment of RX/TX IRQ's
Date: Wed, 28 Jun 2017 19:55:54 -0500
Message-ID: <1498697754-17019-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: jallen@linux.vnet.ibm.com, nfont@linux.vnet.ibm.com,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:54430 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751545AbdF2A4H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 20:56:07 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5T0rZSk090524
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 20:56:07 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2bc7a4kmb3-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 20:56:06 -0400
Received: from localhost
        by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 28 Jun 2017 18:56:06 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver currently creates RX/TX queues during device probe, but
assigns IRQ's to them during device open. On reset, however,
IRQ's are assigned when resetting the queues. If there is a reset
while the device is closed and the device is later opened, the driver will
request IRQ's twice, causing the open to fail. This patch assigns
the IRQ's in the ibmvnic_init function after the queues are reset or
initialized, ensuring IRQ's are only requested once.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 87db1eb..a3e6946 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -763,12 +763,6 @@ static int init_resources(struct ibmvnic_adapter *adapter)
 	if (rc)
 		return rc;
 
-	rc = init_sub_crq_irqs(adapter);
-	if (rc) {
-		netdev_err(netdev, "failed to initialize sub crq irqs\n");
-		return -1;
-	}
-
 	rc = init_stats_token(adapter);
 	if (rc)
 		return rc;
@@ -1803,7 +1797,6 @@ static int reset_sub_crq_queues(struct ibmvnic_adapter *adapter)
 			return rc;
 	}
 
-	rc = init_sub_crq_irqs(adapter);
 	return rc;
 }
 
@@ -3669,6 +3662,13 @@ static int ibmvnic_init(struct ibmvnic_adapter *adapter)
 	if (rc) {
 		dev_err(dev, "Initialization of sub crqs failed\n");
 		release_crq_queue(adapter);
+		return rc;
+	}
+
+	rc = init_sub_crq_irqs(adapter);
+	if (rc) {
+		dev_err(dev, "Failed to initialize sub crq irqs\n");
+		release_crq_queue(adapter);
 	}
 
 	return rc;
-- 
2.7.4
