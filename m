From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH v4 net-next 04/11] ibmvnic: Delete napi's when releasing
 driver resources
Date: Wed, 03 May 2017 14:04:44 -0400
Message-ID: <20170503180444.29742.99980.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170503180246.29742.64039.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:37917 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752900AbdECOQD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 10:16:03 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v43EDhEa051978
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 10:16:02 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a7ch3w9yh-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 10:16:02 -0400
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 3 May 2017 10:16:01 -0400
In-Reply-To: <20170503180246.29742.64039.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The napi structs allocated at drivier initializatio need to be
free'ed when releasing the drivers resources.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index a7c7a94..d52d98c 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -552,11 +552,20 @@ static int ibmvnic_login(struct net_device *netdev)
 
 static void release_resources(struct ibmvnic_adapter *adapter)
 {
+	int i;
+
 	release_tx_pools(adapter);
 	release_rx_pools(adapter);
 
 	release_stats_token(adapter);
 	release_error_buffers(adapter);
+
+	if (adapter->napi) {
+		for (i = 0; i < adapter->req_rx_queues; i++) {
+			if (&adapter->napi[i])
+				netif_napi_del(&adapter->napi[i]);
+		}
+	}
 }
 
 static int set_link_state(struct ibmvnic_adapter *adapter, u8 link_state)
