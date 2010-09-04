From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 08/21] ibmveth: Add optional flush of rx buffer
Date: Fri, 03 Sep 2010 23:28:41 -0500
Message-ID: <20100904042841.2655.69990.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:41699 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312Ab0IDE3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 00:29:10 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844R9JC003619
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:27:09 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o844T93b227102
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:29:09 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844T9vB000354
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:29:09 -0600
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some machines we can improve the bandwidth by ensuring rx buffers are
not in the cache. Add a module option that is disabled by default that flushes
rx buffers on insertion.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:18:54.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:18:54.000000000 -0500
@@ -127,6 +127,10 @@ module_param(rx_copybreak, uint, 0644);
 MODULE_PARM_DESC(rx_copybreak,
 	"Maximum size of packet that is copied to a new buffer on receive");
 
+static unsigned int rx_flush __read_mostly = 0;
+module_param(rx_flush, uint, 0644);
+MODULE_PARM_DESC(rx_flush, "Flush receive buffers before use");
+
 struct ibmveth_stat {
 	char name[ETH_GSTRING_LEN];
 	int offset;
@@ -234,6 +238,14 @@ static int ibmveth_alloc_buffer_pool(str
 	return 0;
 }
 
+static inline void ibmveth_flush_buffer(void *addr, unsigned long length)
+{
+	unsigned long offset;
+
+	for (offset = 0; offset < length; offset += SMP_CACHE_BYTES)
+		asm("dcbfl %0,%1" :: "b" (addr), "r" (offset));
+}
+
 /* replenish the buffers for a pool.  note that we don't need to
  * skb_reserve these since they are used for incoming...
  */
@@ -286,6 +298,12 @@ static void ibmveth_replenish_buffer_poo
 		desc.fields.flags_len = IBMVETH_BUF_VALID | pool->buff_size;
 		desc.fields.address = dma_addr;
 
+		if (rx_flush) {
+			unsigned int len = min(pool->buff_size,
+						adapter->netdev->mtu +
+						IBMVETH_BUFF_OH);
+			ibmveth_flush_buffer(skb->data, len);
+		}
 		lpar_rc = h_add_logical_lan_buffer(adapter->vdev->unit_address, desc.desc);
 
 		if (lpar_rc != H_SUCCESS)
@@ -1095,6 +1113,9 @@ static int ibmveth_poll(struct napi_stru
 				skb_copy_to_linear_data(new_skb,
 							skb->data + offset,
 							length);
+				if (rx_flush)
+					ibmveth_flush_buffer(skb->data,
+						length + offset);
 				skb = new_skb;
 				ibmveth_rxq_recycle_buffer(adapter);
 			} else {
