From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net] ibmvnic: Fix endian errors in error reporting output
Date: Wed, 15 Feb 2017 10:33:33 -0600
Message-ID: <1487176413-16523-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:60578 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751328AbdBOQdm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 11:33:42 -0500
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1FGXdaf014814
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 11:33:42 -0500
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
        by mx0a-001b2d01.pphosted.com with ESMTP id 28mq9qhuek-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 11:33:41 -0500
Received: from localhost
        by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 15 Feb 2017 09:33:39 -0700
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
        by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 667411FF0021
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 09:33:14 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Error reports received from firmware were not being converted from
big endian values, leading to bogus error codes reported on little
endian systems.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
This patch depends on 
"[PATCH net] ibmvnic: Fix endian error when requesting device capabilites"
---
 drivers/net/ethernet/ibm/ibmvnic.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 158b49a..a07b8d7 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -2186,12 +2186,12 @@ static void handle_error_info_rsp(union ibmvnic_crq *crq,
 
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
@@ -2270,8 +2270,8 @@ static void handle_error_indication(union ibmvnic_crq *crq,
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
