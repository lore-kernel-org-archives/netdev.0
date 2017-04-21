From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 4/7] ibmvnic: Move initialization of the stats
 token to ibmvnic_open
Date: Fri, 21 Apr 2017 15:38:58 -0400
Message-ID: <20170421193857.11030.24472.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170421193627.11030.34813.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:52050 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1041953AbdDUSoi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:44:38 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3LFn15a011191
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:50:02 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29ygefq175-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:50:02 -0400
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 21 Apr 2017 11:50:01 -0400
In-Reply-To: <20170421193627.11030.34813.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should be initializing the stats token in the same place we
initialize the other resources for the driver.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index cc34bf9..199cccb 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -607,6 +607,10 @@ static int ibmvnic_open(struct net_device *netdev)
 		return -1;
 	}
 
+	rc = init_stats_token(adapter);
+	if (rc)
+		return rc;
+
 	adapter->map_id = 1;
 	adapter->napi = kcalloc(adapter->req_rx_queues,
 				sizeof(struct napi_struct), GFP_KERNEL);
@@ -3241,12 +3245,6 @@ static int ibmvnic_init(struct ibmvnic_adapter *adapter)
 		return rc;
 	}
 
-	rc = init_stats_token(adapter);
-	if (rc) {
-		release_crq_queue(adapter);
-		return rc;
-	}
-
 	init_completion(&adapter->init_done);
 	ibmvnic_send_crq_init(adapter);
 	if (!wait_for_completion_timeout(&adapter->init_done, timeout)) {
