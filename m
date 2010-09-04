From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 01/21] ibmveth: Remove integer divide caused by modulus
Date: Fri, 03 Sep 2010 23:28:04 -0500
Message-ID: <20100904042804.2655.10351.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:40163 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753Ab0IDE2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 00:28:33 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844GXF3005323
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:16:33 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o844SWtF142610
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:28:32 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844SV7d031211
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:28:32 -0600
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace some modulus operators with an increment and compare to avoid
an integer divide.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:17:03.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:18:34.000000000 -0500
@@ -252,7 +252,9 @@ static void ibmveth_replenish_buffer_poo
 		}
 
 		free_index = pool->consumer_index;
-		pool->consumer_index = (pool->consumer_index + 1) % pool->size;
+		pool->consumer_index++;
+		if (pool->consumer_index >= pool->size)
+			pool->consumer_index = 0;
 		index = pool->free_map[free_index];
 
 		ibmveth_assert(index != IBM_VETH_INVALID_MAP);
@@ -377,9 +379,10 @@ static void ibmveth_remove_buffer_from_p
 			 DMA_FROM_DEVICE);
 
 	free_index = adapter->rx_buff_pool[pool].producer_index;
-	adapter->rx_buff_pool[pool].producer_index
-		= (adapter->rx_buff_pool[pool].producer_index + 1)
-		% adapter->rx_buff_pool[pool].size;
+	adapter->rx_buff_pool[pool].producer_index++;
+	if (adapter->rx_buff_pool[pool].producer_index >=
+	    adapter->rx_buff_pool[pool].size)
+		adapter->rx_buff_pool[pool].producer_index = 0;
 	adapter->rx_buff_pool[pool].free_map[free_index] = index;
 
 	mb();
