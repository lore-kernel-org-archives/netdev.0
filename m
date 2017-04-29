From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 11/11] ibmvnic: Move queue restart
Date: Sat, 29 Apr 2017 04:16:35 -0400
Message-ID: <20170429081634.13438.38831.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170429080710.13438.39798.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:56214 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751531AbdD2E16 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 00:27:58 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3T4OMo9119753
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 00:27:48 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a45ttg9yb-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 00:27:47 -0400
Received: from localhost
        by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Sat, 29 Apr 2017 00:27:46 -0400
In-Reply-To: <20170429080710.13438.39798.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


---
 drivers/net/ethernet/ibm/ibmvnic.c |   23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 4a2b99f..12536ba 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1776,6 +1776,7 @@ static int ibmvnic_complete_tx(struct ibmvnic_adapter *adapter,
 	struct device *dev = &adapter->vdev->dev;
 	struct ibmvnic_tx_buff *txbuff;
 	union sub_crq *next;
+	struct sk_buff *skb;
 	int index;
 	int i, j;
 	u8 first;
@@ -1808,20 +1809,10 @@ static int ibmvnic_complete_tx(struct ibmvnic_adapter *adapter,
 						 DMA_TO_DEVICE);
 			}
 
+			skb = txbuff->skb;
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
@@ -1832,6 +1823,14 @@ static int ibmvnic_complete_tx(struct ibmvnic_adapter *adapter,
 		}
 		/* remove tx_comp scrq*/
 		next->tx_comp.first = 0;
+				
+		if (atomic_sub_return(next->tx_comp.num_comps, &scrq->used) <=
+		    (adapter->req_tx_entries_per_subcrq / 2) &&
+		    netif_subqueue_stopped(adapter->netdev, skb)) {
+			netif_wake_subqueue(adapter->netdev, scrq->pool_index);
+			netdev_info(adapter->netdev, "Started queue %d\n",
+				    scrq->pool_index);
+		}
 	}
 
 	enable_scrq_irq(adapter, scrq);
