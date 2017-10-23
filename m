From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 2/2] ibmvnic: Fix failover error path for
 non-fatal resets
Date: Mon, 23 Oct 2017 11:34:02 -0500
Message-ID: <0d186152-78b3-fc62-3227-788c314448b0@linux.vnet.ibm.com>
References: <0a25df7c-09d4-c6ca-7441-51535c6c3dc5@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        Nathan Fontenot <nfont@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:52424 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751446AbdJWQeH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:34:07 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9NGWL9S099967
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 12:34:07 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dsha1rsbs-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 12:34:06 -0400
Received: from localhost
        by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Mon, 23 Oct 2017 10:34:06 -0600
In-Reply-To: <0a25df7c-09d4-c6ca-7441-51535c6c3dc5@linux.vnet.ibm.com>
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
index c2c4a5b..fa6b2ad 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1506,7 +1506,7 @@ static int do_reset(struct ibmvnic_adapter *adapter,

 		rc = ibmvnic_init(adapter);
 		if (rc)
-			return 0;
+			return IBMVNIC_INIT_FAILED;

 		/* If the adapter was in PROBE state prior to the reset,
 		 * exit here.
@@ -1609,7 +1609,7 @@ static void __ibmvnic_reset(struct work_struct *work)
 	while (rwi) {
 		rc = do_reset(adapter, rwi, reset_state);
 		kfree(rwi);
-		if (rc)
+		if (rc && rc != IBMVNIC_INIT_FAILED)
 			break;

 		rwi = get_next_rwi(adapter);
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 8de998a..b5aaa6e 100644
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
