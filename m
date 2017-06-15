From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 4/5 net-next] ibmvnic: Remove VNIC_CLOSING check from pending_scrq
Date: Wed, 14 Jun 2017 22:35:47 -0500
Message-ID: <1497497748-14075-4-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1497497748-14075-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:37016 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751955AbdFODgF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 23:36:05 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5F3YAK9053535
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 23:36:04 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2b3h7gtwxx-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 23:36:04 -0400
Received: from localhost
        by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 14 Jun 2017 23:36:03 -0400
In-Reply-To: <1497497748-14075-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a kernel panic resulting from data access of a NULL
pointer during device close. The pending_scrq routine is
meant to determine whether there is a valid sub-CRQ message
awaiting processing. When the device is closing, however,
there is a possibility that NULL messages can be processed
because pending_scrq will always return 1 even if there
no valid message in the queue.

It's not clear what this closing state check was originally
meant to accomplish, so just remove it.  

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 167b47b..5378b21 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -2268,8 +2268,7 @@ static int pending_scrq(struct ibmvnic_adapter *adapter,
 {
 	union sub_crq *entry = &scrq->msgs[scrq->cur];
 
-	if (entry->generic.first & IBMVNIC_CRQ_CMD_RSP ||
-	    adapter->state == VNIC_CLOSING)
+	if (entry->generic.first & IBMVNIC_CRQ_CMD_RSP)
 		return 1;
 	else
 		return 0;
-- 
1.8.5.6
