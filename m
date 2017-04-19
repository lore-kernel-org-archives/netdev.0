From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 04/10] ibmvnic: Fixup atomic API usage
Date: Wed, 19 Apr 2017 13:44:47 -0400
Message-ID: <20170419174446.37372.33815.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170419174015.37372.48544.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:58589 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S934567AbdDSNzy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 09:55:54 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3JDrg21088150
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:55:49 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29x744xpg4-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:55:49 -0400
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 19 Apr 2017 09:55:48 -0400
In-Reply-To: <20170419174015.37372.48544.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian King <brking@linux.vnet.ibm.com>

Replace a couple of modifications of an atomic followed
by a read of the atomic, which is no longer atomic, to
use atomic_XX_return variants to avoid race conditions.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index c10bae7..b5871df 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -962,9 +962,8 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 		goto out;
 	}
 
-	atomic_inc(&tx_scrq->used);
-
-	if (atomic_read(&tx_scrq->used) >= adapter->req_tx_entries_per_subcrq) {
+	if (atomic_inc_return(&tx_scrq->used)
+					>= adapter->req_tx_entries_per_subcrq) {
 		netdev_info(netdev, "Stopping queue %d\n", queue_num);
 		netif_stop_subqueue(netdev, queue_num);
 	}
@@ -1499,9 +1498,8 @@ static int ibmvnic_complete_tx(struct ibmvnic_adapter *adapter,
 			}
 
 			if (txbuff->last_frag) {
-				atomic_dec(&scrq->used);
-
-				if (atomic_read(&scrq->used) <=
+				if (atomic_sub_return(next->tx_comp.num_comps,
+						      &scrq->used) <=
 				    (adapter->req_tx_entries_per_subcrq / 2) &&
 				    netif_subqueue_stopped(adapter->netdev,
 							   txbuff->skb)) {
