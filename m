From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 2/5 net-next v2] ibmvnic: Ensure that TX queues are disabled in __ibmvnic_close
Date: Wed, 14 Jun 2017 23:50:06 -0500
Message-ID: <1497502209-16248-3-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1497502209-16248-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        davem@davemloft.net, Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:47986 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751742AbdFOEuf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 00:50:35 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5F4mcXG027513
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 00:50:34 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2b3jmg2aam-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 00:50:34 -0400
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Thu, 15 Jun 2017 00:50:33 -0400
In-Reply-To: <1497502209-16248-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netif_tx_disable to guarantee that TX queues are disabled 
when __ibmvnic_close is called by the device reset routine.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 000cd15..d5fbf45 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -886,7 +886,13 @@ static int __ibmvnic_close(struct net_device *netdev)
 	int i;
 
 	adapter->state = VNIC_CLOSING;
-	netif_tx_stop_all_queues(netdev);
+
+	/* ensure that transmissions are stopped if called by do_reset */
+	if (adapter->resetting)
+		netif_tx_disable(netdev);
+	else
+		netif_tx_stop_all_queues(netdev);
+
 	ibmvnic_napi_disable(adapter);
 
 	if (adapter->tx_scrq) {
-- 
1.8.5.6
