From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 02/21] ibmveth: batch rx buffer replacement
Date: Fri, 03 Sep 2010 23:28:09 -0500
Message-ID: <20100904042809.2655.42894.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:40168 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759Ab0IDE2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 00:28:38 -0400
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844GcF4005428
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:16:38 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o844SbGv135634
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:28:37 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844Sb59031393
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:28:37 -0600
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the moment we try and replenish the receive ring on every rx interrupt.
We even have a pool->threshold but aren't using it.

To limit the maximum latency incurred when refilling, change the threshold
from 1/2 to 7/8 and reduce the largest rx pool from 768 buffers to 512 which
should be more than enough.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:18:36.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:18:37.000000000 -0500
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
--- net-next-2.6.orig//drivers/net/ibmveth.h	2010-09-03 22:17:03.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.h	2010-09-03 22:18:37.000000000 -0500
@@ -102,7 +102,7 @@ static inline long h_illan_attributes(un
 #define IBMVETH_MAX_BUF_SIZE (1024 * 128)
 
 static int pool_size[] = { 512, 1024 * 2, 1024 * 16, 1024 * 32, 1024 * 64 };
-static int pool_count[] = { 256, 768, 256, 256, 256 };
+static int pool_count[] = { 256, 512, 256, 256, 256 };
 static int pool_active[] = { 1, 1, 0, 0, 0};
 
 #define IBM_VETH_INVALID_MAP ((u16)0xffff)
