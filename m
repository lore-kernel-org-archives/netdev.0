From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 2/2 net] ibmvnic: Allocate number of rx/tx buffers agreed on by firmware
Date: Sun,  5 Mar 2017 12:10:24 -0600
Message-ID: <1488737424-17067-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1488737424-17067-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: jallen@linux.vnet.ibm.com, nfont@linux.vnic.ibm.com,
        wvoigt@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:60012 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751909AbdCETIU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 14:08:20 -0500
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v25I8bRY132584
        for <netdev@vger.kernel.org>; Sun, 5 Mar 2017 13:10:33 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
        by mx0a-001b2d01.pphosted.com with ESMTP id 28yva1whvv-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 05 Mar 2017 13:10:33 -0500
Received: from localhost
        by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Sun, 5 Mar 2017 11:10:32 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
        by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 02ECE3E4003F
        for <netdev@vger.kernel.org>; Sun,  5 Mar 2017 11:10:30 -0700 (MST)
In-Reply-To: <1488737424-17067-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The amount of TX/RX buffers that the vNIC driver currently allocates
is different from the amount agreed upon in negotiation with firmware.
Correct that by allocating the requested number of buffers confirmed
by firmware.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 0e87b83..5f11b4d 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -404,7 +404,7 @@ static int ibmvnic_open(struct net_device *netdev)
 	send_map_query(adapter);
 	for (i = 0; i < rxadd_subcrqs; i++) {
 		init_rx_pool(adapter, &adapter->rx_pool[i],
-			     IBMVNIC_BUFFS_PER_POOL, i,
+			     adapter->req_rx_add_entries_per_subcrq, i,
 			     be64_to_cpu(size_array[i]), 1);
 		if (alloc_rx_pool(adapter, &adapter->rx_pool[i])) {
 			dev_err(dev, "Couldn't alloc rx pool\n");
@@ -419,23 +419,23 @@ static int ibmvnic_open(struct net_device *netdev)
 	for (i = 0; i < tx_subcrqs; i++) {
 		tx_pool = &adapter->tx_pool[i];
 		tx_pool->tx_buff =
-		    kcalloc(adapter->max_tx_entries_per_subcrq,
+		    kcalloc(adapter->req_tx_entries_per_subcrq,
 			    sizeof(struct ibmvnic_tx_buff), GFP_KERNEL);
 		if (!tx_pool->tx_buff)
 			goto tx_pool_alloc_failed;
 
 		if (alloc_long_term_buff(adapter, &tx_pool->long_term_buff,
-					 adapter->max_tx_entries_per_subcrq *
+					 adapter->req_tx_entries_per_subcrq *
 					 adapter->req_mtu))
 			goto tx_ltb_alloc_failed;
 
 		tx_pool->free_map =
-		    kcalloc(adapter->max_tx_entries_per_subcrq,
+		    kcalloc(adapter->req_tx_entries_per_subcrq,
 			    sizeof(int), GFP_KERNEL);
 		if (!tx_pool->free_map)
 			goto tx_fm_alloc_failed;
 
-		for (j = 0; j < adapter->max_tx_entries_per_subcrq; j++)
+		for (j = 0; j < adapter->req_tx_entries_per_subcrq; j++)
 			tx_pool->free_map[j] = j;
 
 		tx_pool->consumer_index = 0;
@@ -746,7 +746,7 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	tx_pool->consumer_index =
 	    (tx_pool->consumer_index + 1) %
-		adapter->max_tx_entries_per_subcrq;
+		adapter->req_tx_entries_per_subcrq;
 
 	tx_buff = &tx_pool->tx_buff[index];
 	tx_buff->skb = skb;
@@ -819,7 +819,7 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 		if (tx_pool->consumer_index == 0)
 			tx_pool->consumer_index =
-				adapter->max_tx_entries_per_subcrq - 1;
+				adapter->req_tx_entries_per_subcrq - 1;
 		else
 			tx_pool->consumer_index--;
 
@@ -1387,7 +1387,7 @@ static int ibmvnic_complete_tx(struct ibmvnic_adapter *adapter,
 						     producer_index] = index;
 			adapter->tx_pool[pool].producer_index =
 			    (adapter->tx_pool[pool].producer_index + 1) %
-			    adapter->max_tx_entries_per_subcrq;
+			    adapter->req_tx_entries_per_subcrq;
 		}
 		/* remove tx_comp scrq*/
 		next->tx_comp.first = 0;
-- 
1.8.3.1
