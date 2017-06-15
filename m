From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 5/5 net-next v2] ibmvnic: Exit polling routine correctly during adapter reset
Date: Wed, 14 Jun 2017 23:50:09 -0500
Message-ID: <1497502209-16248-6-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1497502209-16248-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        davem@davemloft.net, Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:42068 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751976AbdFOEuk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 00:50:40 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5F4mfOd031234
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 00:50:39 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2b3k3ds1dp-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 00:50:39 -0400
Received: from localhost
        by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Thu, 15 Jun 2017 00:50:38 -0400
In-Reply-To: <1497502209-16248-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug where, in the case of a device reset,
the polling routine will never complete, causing napi_disable
to sleep indefinitely when attempting to close the device. 

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 5378b21..ba4c79d 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1504,9 +1504,6 @@ static int ibmvnic_poll(struct napi_struct *napi, int budget)
 	int scrq_num = (int)(napi - adapter->napi);
 	int frames_processed = 0;
 
-	if (adapter->resetting)
-		return 0;
-
 restart_poll:
 	while (frames_processed < budget) {
 		struct sk_buff *skb;
@@ -1516,6 +1513,12 @@ static int ibmvnic_poll(struct napi_struct *napi, int budget)
 		u16 offset;
 		u8 flags = 0;
 
+		if (unlikely(adapter->resetting)) {
+			enable_scrq_irq(adapter, adapter->rx_scrq[scrq_num]);
+			napi_complete_done(napi, frames_processed);
+			return frames_processed;
+		}
+
 		if (!pending_scrq(adapter, adapter->rx_scrq[scrq_num]))
 			break;
 		next = ibmvnic_next_scrq(adapter, adapter->rx_scrq[scrq_num]);
-- 
1.8.5.6
