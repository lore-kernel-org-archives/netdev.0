From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net 4/7] ibmvnic: Create init and release routines for the
 rx pool
Date: Thu, 30 Mar 2017 02:49:12 -0400
Message-ID: <20170330064912.20309.15206.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170330064542.20309.17448.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:54953 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754450AbdC3C7v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 22:59:51 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2U2sX14075381
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 22:59:50 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29gbu24kg9-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 22:59:50 -0400
Received: from localhost
        by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 29 Mar 2017 22:59:48 -0400
In-Reply-To: <20170330064542.20309.17448.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the initialization and the release of the rx pool to their own
routines, and update them to do validation.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |  204 ++++++++++++++++++------------------
 1 file changed, 101 insertions(+), 103 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index a9399e9..6774b3c 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -163,21 +163,6 @@ static long h_reg_sub_crq(unsigned long unit_address, unsigned long token,
 	return rc;
 }
 
-/* net_device_ops functions */
-
-static void init_rx_pool(struct ibmvnic_adapter *adapter,
-			 struct ibmvnic_rx_pool *rx_pool, int num, int index,
-			 int buff_size, int active)
-{
-	netdev_dbg(adapter->netdev,
-		   "Initializing rx_pool %d, %d buffs, %d bytes each\n",
-		   index, num, buff_size);
-	rx_pool->size = num;
-	rx_pool->index = index;
-	rx_pool->buff_size = buff_size;
-	rx_pool->active = active;
-}
-
 static int alloc_long_term_buff(struct ibmvnic_adapter *adapter,
 				struct ibmvnic_long_term_buff *ltb, int size)
 {
@@ -214,42 +199,6 @@ static void free_long_term_buff(struct ibmvnic_adapter *adapter,
 		send_request_unmap(adapter, ltb->map_id);
 }
 
-static int alloc_rx_pool(struct ibmvnic_adapter *adapter,
-			 struct ibmvnic_rx_pool *pool)
-{
-	struct device *dev = &adapter->vdev->dev;
-	int i;
-
-	pool->free_map = kcalloc(pool->size, sizeof(int), GFP_KERNEL);
-	if (!pool->free_map)
-		return -ENOMEM;
-
-	pool->rx_buff = kcalloc(pool->size, sizeof(struct ibmvnic_rx_buff),
-				GFP_KERNEL);
-
-	if (!pool->rx_buff) {
-		dev_err(dev, "Couldn't alloc rx buffers\n");
-		kfree(pool->free_map);
-		return -ENOMEM;
-	}
-
-	if (alloc_long_term_buff(adapter, &pool->long_term_buff,
-				 pool->size * pool->buff_size)) {
-		kfree(pool->free_map);
-		kfree(pool->rx_buff);
-		return -ENOMEM;
-	}
-
-	for (i = 0; i < pool->size; ++i)
-		pool->free_map[i] = i;
-
-	atomic_set(&pool->available, 0);
-	pool->next_alloc = 0;
-	pool->next_free = 0;
-
-	return 0;
-}
-
 static void replenish_rx_pool(struct ibmvnic_adapter *adapter,
 			      struct ibmvnic_rx_pool *pool)
 {
@@ -354,25 +303,105 @@ static void replenish_pools(struct ibmvnic_adapter *adapter)
 	}
 }
 
-static void free_rx_pool(struct ibmvnic_adapter *adapter,
-			 struct ibmvnic_rx_pool *pool)
+static void release_rx_pools(struct ibmvnic_adapter *adapter)
 {
-	int i;
-
-	kfree(pool->free_map);
-	pool->free_map = NULL;
+	struct ibmvnic_rx_pool *rx_pool;
+	int rx_scrqs;
+	int i, j;
 
-	if (!pool->rx_buff)
+	if (!adapter->rx_pool)
 		return;
 
-	for (i = 0; i < pool->size; i++) {
-		if (pool->rx_buff[i].skb) {
-			dev_kfree_skb_any(pool->rx_buff[i].skb);
-			pool->rx_buff[i].skb = NULL;
+	rx_scrqs = be32_to_cpu(adapter->login_rsp_buf->num_rxadd_subcrqs);
+	for (i = 0; i < rx_scrqs; i++) {
+		rx_pool = &adapter->rx_pool[i];
+
+		kfree(rx_pool->free_map);
+		free_long_term_buff(adapter, &rx_pool->long_term_buff);
+
+		if (!rx_pool->rx_buff)
+		continue;
+
+		for (j = 0; j < rx_pool->size; j++) {
+			if (rx_pool->rx_buff[j].skb) {
+				dev_kfree_skb_any(rx_pool->rx_buff[i].skb);
+				rx_pool->rx_buff[i].skb = NULL;
+			}
+		}
+
+		kfree(rx_pool->rx_buff);
+	}
+
+	kfree(adapter->rx_pool);
+	adapter->rx_pool = NULL;
+}
+
+static int init_rx_pools(struct net_device *netdev)
+{
+	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
+	struct device *dev = &adapter->vdev->dev;
+	struct ibmvnic_rx_pool *rx_pool;
+	int rxadd_subcrqs;
+	u64 *size_array;
+	int i, j;
+
+	rxadd_subcrqs =
+		be32_to_cpu(adapter->login_rsp_buf->num_rxadd_subcrqs);
+	size_array = (u64 *)((u8 *)(adapter->login_rsp_buf) +
+		be32_to_cpu(adapter->login_rsp_buf->off_rxadd_buff_size));
+
+	adapter->rx_pool = kcalloc(rxadd_subcrqs,
+				   sizeof(struct ibmvnic_rx_pool),
+				   GFP_KERNEL);
+	if (!adapter->rx_pool) {
+		dev_err(dev, "Failed to allocate rx pools\n");
+		return -1;
+	}
+
+	for (i = 0; i < rxadd_subcrqs; i++) {
+		rx_pool = &adapter->rx_pool[i];
+
+		netdev_dbg(adapter->netdev,
+			   "Initializing rx_pool %d, %lld buffs, %lld bytes each\n",
+			   i, adapter->req_rx_add_entries_per_subcrq,
+			   be64_to_cpu(size_array[i]));
+
+		rx_pool->size = adapter->req_rx_add_entries_per_subcrq;
+		rx_pool->index = i;
+		rx_pool->buff_size = be64_to_cpu(size_array[i]);
+		rx_pool->active = 1;
+
+		rx_pool->free_map = kcalloc(rx_pool->size, sizeof(int),
+					    GFP_KERNEL);
+		if (!rx_pool->free_map) {
+			release_rx_pools(adapter);
+			return -1;
+		}
+
+		rx_pool->rx_buff = kcalloc(rx_pool->size,
+					   sizeof(struct ibmvnic_rx_buff),
+					   GFP_KERNEL);
+		if (!rx_pool->rx_buff) {
+			dev_err(dev, "Couldn't alloc rx buffers\n");
+			release_rx_pools(adapter);
+			return -1;
+		}
+
+		if (alloc_long_term_buff(adapter, &rx_pool->long_term_buff,
+					 rx_pool->size * rx_pool->buff_size)) {
+			release_rx_pools(adapter);
+			return -1;
 		}
+
+		for (j = 0; j < rx_pool->size; ++j)
+			rx_pool->free_map[j] = j;
+
+		atomic_set(&rx_pool->available, 0);
+		rx_pool->next_alloc = 0;
+		rx_pool->next_free = 0;
 	}
-	kfree(pool->rx_buff);
-	pool->rx_buff = NULL;
+
+	return 0;
 }
 
 static void release_tx_pools(struct ibmvnic_adapter *adapter)
@@ -526,10 +555,9 @@ static int ibmvnic_open(struct net_device *netdev)
 	struct device *dev = &adapter->vdev->dev;
 	union ibmvnic_crq crq;
 	int rxadd_subcrqs;
-	u64 *size_array;
 	int tx_subcrqs;
 	int rc = 0;
-	int i, j;
+	int i;
 
 	if (adapter->is_closed) {
 		rc = ibmvnic_init(adapter);
@@ -557,9 +585,7 @@ static int ibmvnic_open(struct net_device *netdev)
 	    be32_to_cpu(adapter->login_rsp_buf->num_rxadd_subcrqs);
 	tx_subcrqs =
 	    be32_to_cpu(adapter->login_rsp_buf->num_txsubm_subcrqs);
-	size_array = (u64 *)((u8 *)(adapter->login_rsp_buf) +
-				  be32_to_cpu(adapter->login_rsp_buf->
-					      off_rxadd_buff_size));
+
 	adapter->map_id = 1;
 	adapter->napi = kcalloc(adapter->req_rx_queues,
 				sizeof(struct napi_struct), GFP_KERNEL);
@@ -570,21 +596,12 @@ static int ibmvnic_open(struct net_device *netdev)
 			       NAPI_POLL_WEIGHT);
 		napi_enable(&adapter->napi[i]);
 	}
-	adapter->rx_pool =
-	    kcalloc(rxadd_subcrqs, sizeof(struct ibmvnic_rx_pool), GFP_KERNEL);
 
-	if (!adapter->rx_pool)
-		goto rx_pool_arr_alloc_failed;
 	send_map_query(adapter);
-	for (i = 0; i < rxadd_subcrqs; i++) {
-		init_rx_pool(adapter, &adapter->rx_pool[i],
-			     adapter->req_rx_add_entries_per_subcrq, i,
-			     be64_to_cpu(size_array[i]), 1);
-		if (alloc_rx_pool(adapter, &adapter->rx_pool[i])) {
-			dev_err(dev, "Couldn't alloc rx pool\n");
-			goto rx_pool_alloc_failed;
-		}
-	}
+
+	rc = init_rx_pools(netdev);
+	if (rc)
+		goto rx_pool_failed;
 
 	rc = init_tx_pools(netdev);
 	if (rc)
@@ -621,15 +638,7 @@ static int ibmvnic_open(struct net_device *netdev)
 	kfree(adapter->tx_pool[i].free_map);
 tx_pool_failed:
 	i = rxadd_subcrqs;
-rx_pool_alloc_failed:
-	for (j = 0; j < i; j++) {
-		free_rx_pool(adapter, &adapter->rx_pool[j]);
-		free_long_term_buff(adapter,
-				    &adapter->rx_pool[j].long_term_buff);
-	}
-	kfree(adapter->rx_pool);
-	adapter->rx_pool = NULL;
-rx_pool_arr_alloc_failed:
+rx_pool_failed:
 	for (i = 0; i < adapter->req_rx_queues; i++)
 		napi_disable(&adapter->napi[i]);
 alloc_napi_failed:
@@ -640,21 +649,10 @@ static int ibmvnic_open(struct net_device *netdev)
 static void ibmvnic_release_resources(struct ibmvnic_adapter *adapter)
 {
 	struct device *dev = &adapter->vdev->dev;
-	int rx_scrqs;
-	int i;
 
 	release_bounce_buffer(adapter);
 	release_tx_pools(adapter);
-
-	rx_scrqs = be32_to_cpu(adapter->login_rsp_buf->num_rxadd_subcrqs);
-	for (i = 0; i < rx_scrqs; i++) {
-		struct ibmvnic_rx_pool *rx_pool = &adapter->rx_pool[i];
-
-		free_rx_pool(adapter, rx_pool);
-		free_long_term_buff(adapter, &rx_pool->long_term_buff);
-	}
-	kfree(adapter->rx_pool);
-	adapter->rx_pool = NULL;
+	release_rx_pools(adapter);
 
 	release_sub_crqs(adapter);
 	release_crq_queue(adapter);
