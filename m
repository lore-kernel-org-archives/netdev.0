From: Anton Blanchard <anton@samba.org>
Subject: [patch 02/20] ibmveth: batch rx buffer replacement
Date: Mon, 23 Aug 2010 10:09:32 +1000
Message-ID: <20100823001238.474940661@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:35031 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751249Ab0HWA1O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:27:14 -0400
Content-Disposition: inline; filename=veth_watermark
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the moment we try and replenish the receive ring on every rx interrupt.
We even have a pool->threshold but aren't using it.

To limit the maximum latency incurred when refilling, change the threshold
from 1/2 to 7/8 and reduce the largest rx pool from 768 buffers to 512 which
should be more than enough.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 08:52:26.774004158 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 08:52:27.963919704 +1000
@@ -178,7 +178,7 @@ static void ibmveth_init_buffer_pool(str
 	pool->size = pool_size;
 	pool->index = pool_index;
 	pool->buff_size = buff_size;
-	pool->threshold = pool_size / 2;
+	pool->threshold = pool_size * 7 / 8;
 	pool->active = pool_active;
 }
 
@@ -315,10 +315,13 @@ static void ibmveth_replenish_task(struc
 
 	adapter->replenish_task_cycles++;
 
-	for (i = (IbmVethNumBufferPools - 1); i >= 0; i--)
-		if(adapter->rx_buff_pool[i].active)
-			ibmveth_replenish_buffer_pool(adapter,
-						     &adapter->rx_buff_pool[i]);
+	for (i = (IbmVethNumBufferPools - 1); i >= 0; i--) {
+		struct ibmveth_buff_pool *pool = &adapter->rx_buff_pool[i];
+
+		if (pool->active &&
+		    (atomic_read(&pool->available) < pool->threshold))
+			ibmveth_replenish_buffer_pool(adapter, pool);
+	}
 
 	adapter->rx_no_buffer = *(u64*)(((char*)adapter->buffer_list_addr) + 4096 - 8);
 }
Index: net-next-2.6/drivers/net/ibmveth.h
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.h	2010-08-23 08:52:16.164757227 +1000
+++ net-next-2.6/drivers/net/ibmveth.h	2010-08-23 08:52:27.963919704 +1000
@@ -102,7 +102,7 @@ static inline long h_illan_attributes(un
 #define IBMVETH_MAX_BUF_SIZE (1024 * 128)
 
 static int pool_size[] = { 512, 1024 * 2, 1024 * 16, 1024 * 32, 1024 * 64 };
-static int pool_count[] = { 256, 768, 256, 256, 256 };
+static int pool_count[] = { 256, 512, 256, 256, 256 };
 static int pool_active[] = { 1, 1, 0, 0, 0};
 
 #define IBM_VETH_INVALID_MAP ((u16)0xffff)


