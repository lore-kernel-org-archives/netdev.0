From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 19/21] ibmveth: Convert driver specific assert to BUG_ON
Date: Fri, 03 Sep 2010 23:29:41 -0500
Message-ID: <20100904042941.2655.86845.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:46332 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754639Ab0IDEaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 00:30:11 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844QJ41019477
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:26:19 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o844UBTR187336
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:30:11 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844U9Ci003834
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:30:10 -0600
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We had a driver specific assert function which wasn't enabled most of the
time. Convert them to BUG_ON and enable them all the time.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:19:26.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:19:26.000000000 -0500
@@ -53,18 +53,6 @@
 
 #include "ibmveth.h"
 
-#undef DEBUG
-
-#ifdef DEBUG
-#define ibmveth_assert(expr) \
-  if (!(expr)) {                                   \
-    printk(KERN_DEBUG "assertion failed (%s:%3.3d ua:%x): %s\n", __FILE__, __LINE__, adapter->vdev->unit_address, #expr); \
-    BUG(); \
-  }
-#else
-#define ibmveth_assert(expr)
-#endif
-
 static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance);
 static void ibmveth_rxq_harvest_buffer(struct ibmveth_adapter *adapter);
 static unsigned long ibmveth_get_desired_dma(struct vio_dev *vdev);
@@ -251,8 +239,8 @@ static void ibmveth_replenish_buffer_poo
 			pool->consumer_index = 0;
 		index = pool->free_map[free_index];
 
-		ibmveth_assert(index != IBM_VETH_INVALID_MAP);
-		ibmveth_assert(pool->skbuff[index] == NULL);
+		BUG_ON(index == IBM_VETH_INVALID_MAP);
+		BUG_ON(pool->skbuff[index] != NULL);
 
 		dma_addr = dma_map_single(&adapter->vdev->dev, skb->data,
 				pool->buff_size, DMA_FROM_DEVICE);
@@ -371,12 +359,12 @@ static void ibmveth_remove_buffer_from_p
 	unsigned int free_index;
 	struct sk_buff *skb;
 
-	ibmveth_assert(pool < IBMVETH_NUM_BUFF_POOLS);
-	ibmveth_assert(index < adapter->rx_buff_pool[pool].size);
+	BUG_ON(pool >= IBMVETH_NUM_BUFF_POOLS);
+	BUG_ON(index >= adapter->rx_buff_pool[pool].size);
 
 	skb = adapter->rx_buff_pool[pool].skbuff[index];
 
-	ibmveth_assert(skb != NULL);
+	BUG_ON(skb == NULL);
 
 	adapter->rx_buff_pool[pool].skbuff[index] = NULL;
 
@@ -404,8 +392,8 @@ static inline struct sk_buff *ibmveth_rx
 	unsigned int pool = correlator >> 32;
 	unsigned int index = correlator & 0xffffffffUL;
 
-	ibmveth_assert(pool < IBMVETH_NUM_BUFF_POOLS);
-	ibmveth_assert(index < adapter->rx_buff_pool[pool].size);
+	BUG_ON(pool >= IBMVETH_NUM_BUFF_POOLS);
+	BUG_ON(index >= adapter->rx_buff_pool[pool].size);
 
 	return adapter->rx_buff_pool[pool].skbuff[index];
 }
@@ -420,8 +408,8 @@ static void ibmveth_rxq_recycle_buffer(s
 	union ibmveth_buf_desc desc;
 	unsigned long lpar_rc;
 
-	ibmveth_assert(pool < IBMVETH_NUM_BUFF_POOLS);
-	ibmveth_assert(index < adapter->rx_buff_pool[pool].size);
+	BUG_ON(pool >= IBMVETH_NUM_BUFF_POOLS);
+	BUG_ON(index >= adapter->rx_buff_pool[pool].size);
 
 	if (!adapter->rx_buff_pool[pool].active) {
 		ibmveth_rxq_harvest_buffer(adapter);
@@ -1181,7 +1169,7 @@ restart_poll:
 		lpar_rc = h_vio_signal(adapter->vdev->unit_address,
 				       VIO_IRQ_ENABLE);
 
-		ibmveth_assert(lpar_rc == H_SUCCESS);
+		BUG_ON(lpar_rc != H_SUCCESS);
 
 		napi_complete(napi);
 
@@ -1205,7 +1193,7 @@ static irqreturn_t ibmveth_interrupt(int
 	if (napi_schedule_prep(&adapter->napi)) {
 		lpar_rc = h_vio_signal(adapter->vdev->unit_address,
 				       VIO_IRQ_DISABLE);
-		ibmveth_assert(lpar_rc == H_SUCCESS);
+		BUG_ON(lpar_rc != H_SUCCESS);
 		__napi_schedule(&adapter->napi);
 	}
 	return IRQ_HANDLED;
