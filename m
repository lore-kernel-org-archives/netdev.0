From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/2] ibmvnic: Fix failover error path for non-fatal
 resets
Date: Fri, 20 Oct 2017 16:03:00 -0500
Message-ID: <6023d438-2968-0c01-a22f-64f1479af442@linux.vnet.ibm.com>
References: <9bafaca4-75e7-ba82-8eea-35a69c61b6db@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        Nathan Fontenot <nfont@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:52584 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752227AbdJTVDz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 17:03:55 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9KL3WKP026061
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 17:03:54 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dqja31aca-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 17:03:46 -0400
Received: from localhost
        by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Fri, 20 Oct 2017 17:03:04 -0400
In-Reply-To: <9bafaca4-75e7-ba82-8eea-35a69c61b6db@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



For all non-fatal reset conditions, the hypervisor will send a failover when
we attempt to initialize the crq and the vnic client is expected to handle
that failover instead of the existing non-fatal reset. To handle this, we
need to return from init with a return code that indicates that we have hit
this case.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
---
diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index ebbb083..c914d5a 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1452,7 +1452,7 @@ static int do_reset(struct ibmvnic_adapter *adapter,

 		rc = ibmvnic_init(adapter);
 		if (rc)
-			return 0;
+			return IBMVNIC_INIT_FAILED;

 		/* If the adapter was in PROBE state prior to the reset,
 		 * exit here.
@@ -1555,7 +1555,7 @@ static void __ibmvnic_reset(struct work_struct *work)
 	while (rwi) {
 		rc = do_reset(adapter, rwi, reset_state);
 		kfree(rwi);
-		if (rc)
+		if (rc && rc != IBMVNIC_INIT_FAILED)
 			break;

 		rwi = get_next_rwi(adapter);
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 5347a7c..46eed65 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -30,6 +30,8 @@
 #define IBMVNIC_DRIVER_VERSION	"1.0.1"
 #define IBMVNIC_INVALID_MAP	-1
 #define IBMVNIC_STATS_TIMEOUT	1
+#define IBMVNIC_INIT_FAILED	2
+
 /* basic structures plus 100 2k buffers */
 #define IBMVNIC_IO_ENTITLEMENT_DEFAULT	610305
