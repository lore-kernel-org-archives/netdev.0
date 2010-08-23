From: Anton Blanchard <anton@samba.org>
Subject: [patch 09/20] ibmveth: Add optional flush of rx buffer
Date: Mon, 23 Aug 2010 10:09:39 +1000
Message-ID: <20100823001239.140230115@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51828 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751749Ab0HWA2Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:28:25 -0400
Content-Disposition: inline; filename=veth_flush_buffer
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some machines we can improve the bandwidth by ensuring rx buffers are
not in the cache. Add a module option that is disabled by default that flushes
rx buffers on insertion.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 08:52:31.003703934 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 08:52:31.363678383 +1000
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


