From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] ibmveth: Fix leak when recycling skb and hypervisor returns
 error
Date: Thu, 25 Aug 2011 09:20:19 +1000
Message-ID: <20110825092019.777aea6e@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:55429 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054Ab1HXXUX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 19:20:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If h_add_logical_lan_buffer returns an error we need to free
the skb.

Signed-off-by: Anton Blanchard <anton@samba.org>
Cc: stable <stable@kernel.org>
---

Index: linux-net/drivers/net/ethernet/ibm/ibmveth.c
===================================================================
--- linux-net.orig/drivers/net/ethernet/ibm/ibmveth.c	2011-08-24 17:06:56.894207820 +1000
+++ linux-net/drivers/net/ethernet/ibm/ibmveth.c	2011-08-25 08:44:14.212105871 +1000
@@ -395,7 +395,7 @@ static inline struct sk_buff *ibmveth_rx
 }
 
 /* recycle the current buffer on the rx queue */
-static void ibmveth_rxq_recycle_buffer(struct ibmveth_adapter *adapter)
+static int ibmveth_rxq_recycle_buffer(struct ibmveth_adapter *adapter)
 {
 	u32 q_index = adapter->rx_queue.index;
 	u64 correlator = adapter->rx_queue.queue_addr[q_index].correlator;
@@ -403,6 +403,7 @@ static void ibmveth_rxq_recycle_buffer(s
 	unsigned int index = correlator & 0xffffffffUL;
 	union ibmveth_buf_desc desc;
 	unsigned long lpar_rc;
+	int ret = 1;
 
 	BUG_ON(pool >= IBMVETH_NUM_BUFF_POOLS);
 	BUG_ON(index >= adapter->rx_buff_pool[pool].size);
@@ -410,7 +411,7 @@ static void ibmveth_rxq_recycle_buffer(s
 	if (!adapter->rx_buff_pool[pool].active) {
 		ibmveth_rxq_harvest_buffer(adapter);
 		ibmveth_free_buffer_pool(adapter, &adapter->rx_buff_pool[pool]);
-		return;
+		goto out;
 	}
 
 	desc.fields.flags_len = IBMVETH_BUF_VALID |
@@ -423,12 +424,16 @@ static void ibmveth_rxq_recycle_buffer(s
 		netdev_dbg(adapter->netdev, "h_add_logical_lan_buffer failed "
 			   "during recycle rc=%ld", lpar_rc);
 		ibmveth_remove_buffer_from_pool(adapter, adapter->rx_queue.queue_addr[adapter->rx_queue.index].correlator);
+		ret = 0;
 	}
 
 	if (++adapter->rx_queue.index == adapter->rx_queue.num_slots) {
 		adapter->rx_queue.index = 0;
 		adapter->rx_queue.toggle = !adapter->rx_queue.toggle;
 	}
+
+out:
+	return ret;
 }
 
 static void ibmveth_rxq_harvest_buffer(struct ibmveth_adapter *adapter)
@@ -1084,8 +1089,9 @@ restart_poll:
 				if (rx_flush)
 					ibmveth_flush_buffer(skb->data,
 						length + offset);
+				if (!ibmveth_rxq_recycle_buffer(adapter))
+					kfree_skb(skb);
 				skb = new_skb;
-				ibmveth_rxq_recycle_buffer(adapter);
 			} else {
 				ibmveth_rxq_harvest_buffer(adapter);
 				skb_reserve(skb, offset);
