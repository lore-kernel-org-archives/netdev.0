From: Anton Blanchard <anton@samba.org>
Subject: [patch 18/20] ibmveth: Convert driver specific assert to BUG_ON
Date: Mon, 23 Aug 2010 10:09:48 +1000
Message-ID: <20100823001239.992577028@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51871 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751297Ab0HWA3z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:29:55 -0400
Content-Disposition: inline; filename=veth_BUG_ON
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We had a driver specific assert function which wasn't enabled most of the
time. Convert them to BUG_ON and enable them all the time.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 09:23:32.781489458 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 09:23:35.101324676 +1000
@@ -52,18 +52,6 @@
 
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
@@ -248,8 +236,8 @@ static void ibmveth_replenish_buffer_poo
 			pool->consumer_index = 0;
 		index = pool->free_map[free_index];
 
-		ibmveth_assert(index != IBM_VETH_INVALID_MAP);
-		ibmveth_assert(pool->skbuff[index] == NULL);
+		BUG_ON(index == IBM_VETH_INVALID_MAP);
+		BUG_ON(pool->skbuff[index] != NULL);
 
 		dma_addr = dma_map_single(&adapter->vdev->dev, skb->data,
 				pool->buff_size, DMA_FROM_DEVICE);
@@ -368,12 +356,12 @@ static void ibmveth_remove_buffer_from_p
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
 
@@ -401,8 +389,8 @@ static inline struct sk_buff *ibmveth_rx
 	unsigned int pool = correlator >> 32;
 	unsigned int index = correlator & 0xffffffffUL;
 
-	ibmveth_assert(pool < IBMVETH_NUM_BUFF_POOLS);
-	ibmveth_assert(index < adapter->rx_buff_pool[pool].size);
+	BUG_ON(pool >= IBMVETH_NUM_BUFF_POOLS);
+	BUG_ON(index >= adapter->rx_buff_pool[pool].size);
 
 	return adapter->rx_buff_pool[pool].skbuff[index];
 }
@@ -417,8 +405,8 @@ static void ibmveth_rxq_recycle_buffer(s
 	union ibmveth_buf_desc desc;
 	unsigned long lpar_rc;
 
-	ibmveth_assert(pool < IBMVETH_NUM_BUFF_POOLS);
-	ibmveth_assert(index < adapter->rx_buff_pool[pool].size);
+	BUG_ON(pool >= IBMVETH_NUM_BUFF_POOLS);
+	BUG_ON(index >= adapter->rx_buff_pool[pool].size);
 
 	if (!adapter->rx_buff_pool[pool].active) {
 		ibmveth_rxq_harvest_buffer(adapter);
@@ -1145,7 +1133,7 @@ restart_poll:
 		lpar_rc = h_vio_signal(adapter->vdev->unit_address,
 				       VIO_IRQ_ENABLE);
 
-		ibmveth_assert(lpar_rc == H_SUCCESS);
+		BUG_ON(lpar_rc != H_SUCCESS);
 
 		napi_complete(napi);
 
@@ -1169,7 +1157,7 @@ static irqreturn_t ibmveth_interrupt(int
 	if (napi_schedule_prep(&adapter->napi)) {
 		lpar_rc = h_vio_signal(adapter->vdev->unit_address,
 				       VIO_IRQ_DISABLE);
-		ibmveth_assert(lpar_rc == H_SUCCESS);
+		BUG_ON(lpar_rc != H_SUCCESS);
 		__napi_schedule(&adapter->napi);
 	}
 	return IRQ_HANDLED;


