From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net 4/5] ibmvnic: Fix endian errors in error reporting output
Date: Wed, 25 Jan 2017 15:02:22 -0600
Message-ID: <1485378143-5084-4-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1485378143-5084-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, wvoigt@us.ibm.com,
        nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:45177 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751713AbdAYVCe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 16:02:34 -0500
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0PKwfBG088910
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 16:02:33 -0500
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2871dxmu6r-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 16:02:33 -0500
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 25 Jan 2017 16:02:31 -0500
In-Reply-To: <1485378143-5084-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Error reports received from firmware were not being converted from
big endian values, leading to bogus error codes reported on little
endian systems.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index ec4eaed..ec6c5fe 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -2185,12 +2185,12 @@ static void handle_error_info_rsp(union ibmvnic_crq *crq,
 
 	if (!found) {
 		dev_err(dev, "Couldn't find error id %x\n",
-			crq->request_error_rsp.error_id);
+			be32_to_cpu(crq->request_error_rsp.error_id));
 		return;
 	}
 
 	dev_err(dev, "Detailed info for error id %x:",
-		crq->request_error_rsp.error_id);
+		be32_to_cpu(crq->request_error_rsp.error_id));
 
 	for (i = 0; i < error_buff->len; i++) {
 		pr_cont("%02x", (int)error_buff->buff[i]);
@@ -2269,8 +2269,8 @@ static void handle_error_indication(union ibmvnic_crq *crq,
 	dev_err(dev, "Firmware reports %serror id %x, cause %d\n",
 		crq->error_indication.
 		    flags & IBMVNIC_FATAL_ERROR ? "FATAL " : "",
-		crq->error_indication.error_id,
-		crq->error_indication.error_cause);
+		be32_to_cpu(crq->error_indication.error_id),
+		be16_to_cpu(crq->error_indication.error_cause));
 
 	error_buff = kmalloc(sizeof(*error_buff), GFP_ATOMIC);
 	if (!error_buff)
-- 
1.8.3.1
