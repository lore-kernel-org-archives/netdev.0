From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 05/11] ibmvnic: Non-fatal error handling
Date: Fri, 26 May 2017 10:30:37 -0400
Message-ID: <20170526143037.63648.45770.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
References: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:57302 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S940672AbdEZOmX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 10:42:23 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4QEdPvR072150
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:22 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2apa6sw9jt-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:22 -0400
Received: from localhost
        by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 26 May 2017 10:42:21 -0400
In-Reply-To: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Allen <jallen@linux.vnet.ibm.com>

Handle non-fatal error conditions. The process to do this when
resetting the driver is to just do __ibmvnic_close followed by
__ibmvnic_open.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   56 ++++++++++++++++++++----------------
 drivers/net/ethernet/ibm/ibmvnic.h |    1 +
 2 files changed, 32 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 0f705e6..def867a 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1225,37 +1225,41 @@ static int do_reset(struct ibmvnic_adapter *adapter,
 	if (rc)
 		return rc;
 
-	/* remove the closed state so when we call open it appears
-	 * we are coming from the probed state.
-	 */
-	adapter->state = VNIC_PROBED;
+	if (adapter->reset_reason != VNIC_RESET_NON_FATAL) {
+		/* remove the closed state so when we call open it appears
+		 * we are coming from the probed state.
+		 */
+		adapter->state = VNIC_PROBED;
 
-	release_resources(adapter);
-	release_sub_crqs(adapter);
-	release_crq_queue(adapter);
+		release_resources(adapter);
+		release_sub_crqs(adapter);
+		release_crq_queue(adapter);
 
-	rc = ibmvnic_init(adapter);
-	if (rc)
-		return 0;
+		rc = ibmvnic_init(adapter);
+		if (rc)
+			return 0;
 
-	/* If the adapter was in PROBE state prior to the reset, exit here. */
-	if (reset_state == VNIC_PROBED)
-		return 0;
+		/* If the adapter was in PROBE state prior to the reset,
+		 * exit here.
+		 */
+		if (reset_state == VNIC_PROBED)
+			return 0;
 
-	rc = ibmvnic_login(netdev);
-	if (rc) {
-		adapter->state = VNIC_PROBED;
-		return 0;
-	}
+		rc = ibmvnic_login(netdev);
+		if (rc) {
+			adapter->state = VNIC_PROBED;
+			return 0;
+		}
 
-	rtnl_lock();
-	rc = init_resources(adapter);
-	rtnl_unlock();
-	if (rc)
-		return rc;
+		rtnl_lock();
+		rc = init_resources(adapter);
+		rtnl_unlock();
+		if (rc)
+			return rc;
 
-	if (reset_state == VNIC_CLOSED)
-		return 0;
+		if (reset_state == VNIC_CLOSED)
+			return 0;
+	}
 
 	rc = __ibmvnic_open(netdev);
 	if (rc) {
@@ -2763,6 +2767,8 @@ static void handle_error_indication(union ibmvnic_crq *crq,
 
 	if (crq->error_indication.flags & IBMVNIC_FATAL_ERROR)
 		ibmvnic_reset(adapter, VNIC_RESET_FATAL);
+	else
+		ibmvnic_reset(adapter, VNIC_RESET_NON_FATAL);
 }
 
 static void handle_change_mac_rsp(union ibmvnic_crq *crq,
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index fa6ac4e..7e2300e 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -925,6 +925,7 @@ enum vnic_state {VNIC_PROBING = 1,
 enum ibmvnic_reset_reason {VNIC_RESET_FAILOVER = 1,
 			   VNIC_RESET_MOBILITY,
 			   VNIC_RESET_FATAL,
+			   VNIC_RESET_NON_FATAL,
 			   VNIC_RESET_TIMEOUT};
 
 struct ibmvnic_rwi {
