From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH v4 net-next 11/11] ibmvnic: Move queue restarting in
 ibmvnic_tx_complete
Date: Wed, 03 May 2017 14:05:25 -0400
Message-ID: <20170503180525.29742.42057.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170503180246.29742.64039.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:54005 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753495AbdECOQs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 10:16:48 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v43EElcQ037999
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 10:16:43 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a79vtc3e6-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 10:16:42 -0400
Received: from localhost
        by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 3 May 2017 10:16:41 -0400
In-Reply-To: <20170503180246.29742.64039.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Restart of the subqueue should occur outside of the loop processing
any tx buffers instead of doing this in the middle of the loop.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---

v2: Use __netif_subqueue_stopped() instead of netif_subqueue_stopped()
to avoid possible using un-initialized skb variable.
---
 drivers/net/ethernet/ibm/ibmvnic.c |   22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 1b6268c..4f2d329 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1809,19 +1809,8 @@ static int ibmvnic_complete_tx(struct ibmvnic_adapter *adapter,
 			}
 
 			if (txbuff->last_frag) {
-				if (atomic_sub_return(next->tx_comp.num_comps,
-						      &scrq->used) <=
-				    (adapter->req_tx_entries_per_subcrq / 2) &&
-				    netif_subqueue_stopped(adapter->netdev,
-							   txbuff->skb)) {
-					netif_wake_subqueue(adapter->netdev,
-							    scrq->pool_index);
-					netdev_dbg(adapter->netdev,
-						   "Started queue %d\n",
-						   scrq->pool_index);
-				}
-
 				dev_kfree_skb_any(txbuff->skb);
+				txbuff->skb = NULL;
 			}
 
 			adapter->tx_pool[pool].free_map[adapter->tx_pool[pool].
@@ -1832,6 +1821,15 @@ static int ibmvnic_complete_tx(struct ibmvnic_adapter *adapter,
 		}
 		/* remove tx_comp scrq*/
 		next->tx_comp.first = 0;
+
+		if (atomic_sub_return(next->tx_comp.num_comps, &scrq->used) <=
+		    (adapter->req_tx_entries_per_subcrq / 2) &&
+		    __netif_subqueue_stopped(adapter->netdev,
+					     scrq->pool_index)) {
+			netif_wake_subqueue(adapter->netdev, scrq->pool_index);
+			netdev_info(adapter->netdev, "Started queue %d\n",
+				    scrq->pool_index);
+		}
 	}
 
 	enable_scrq_irq(adapter, scrq);
