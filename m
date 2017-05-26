From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 02/11] ibmvnic: Handle failover after failed init
 crq
Date: Fri, 26 May 2017 10:30:19 -0400
Message-ID: <20170526143019.63648.61597.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
References: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:52203 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1764905AbdEZOmE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 10:42:04 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4QEdPqb024001
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:04 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2apkxx72ta-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:03 -0400
Received: from localhost
        by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 26 May 2017 10:42:02 -0400
In-Reply-To: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Allen <jallen@linux.vnet.ibm.com>

Handle case where phyp sends a failover after failing to send the
init crq.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   11 ++++++++++-
 drivers/net/ethernet/ibm/ibmvnic.h |    2 +-
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 4997de4..1f7cf6f 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -3167,6 +3167,8 @@ static void ibmvnic_handle_crq(union ibmvnic_crq *crq,
 		switch (gen_crq->cmd) {
 		case IBMVNIC_CRQ_INIT:
 			dev_info(dev, "Partner initialized\n");
+			adapter->from_passive_init = true;
+			complete(&adapter->init_done);
 			break;
 		case IBMVNIC_CRQ_INIT_COMPLETE:
 			dev_info(dev, "Partner initialization complete\n");
@@ -3481,11 +3483,18 @@ static int ibmvnic_init(struct ibmvnic_adapter *adapter)
 		return rc;
 	}
 
+	adapter->from_passive_init = false;
+
 	init_completion(&adapter->init_done);
 	ibmvnic_send_crq_init(adapter);
 	if (!wait_for_completion_timeout(&adapter->init_done, timeout)) {
 		dev_err(dev, "Initialization sequence timed out\n");
-		release_crq_queue(adapter);
+		return -1;
+	}
+
+	if (adapter->from_passive_init) {
+		adapter->state = VNIC_OPEN;
+		adapter->from_passive_init = false;
 		return -1;
 	}
 
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 4816e04..fa6ac4e 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -1031,5 +1031,5 @@ struct ibmvnic_adapter {
 	struct list_head rwi_list;
 	struct work_struct ibmvnic_reset;
 	bool resetting;
-	bool napi_enabled;
+	bool napi_enabled, from_passive_init;
 };
