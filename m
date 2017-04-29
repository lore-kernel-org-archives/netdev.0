From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 04/11] ibmvnic: Delete napi's when releasing driver
 resources
Date: Sat, 29 Apr 2017 04:15:52 -0400
Message-ID: <20170429081551.13438.43710.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170429080710.13438.39798.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:46492 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753119AbdD2E1F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 00:27:05 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3T4OKcH080795
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 00:27:04 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a4kqfr4ye-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 00:27:04 -0400
Received: from localhost
        by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Sat, 29 Apr 2017 00:27:03 -0400
In-Reply-To: <20170429080710.13438.39798.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The napi structs allocated at drivier initializatio need to be
free'ed when releasing the drivers resources.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index b3d9b28..9f2686d 100644
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
