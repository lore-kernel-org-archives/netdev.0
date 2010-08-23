From: Anton Blanchard <anton@samba.org>
Subject: [patch 05/20] ibmveth: Add rx_copybreak
Date: Mon, 23 Aug 2010 10:09:35 +1000
Message-ID: <20100823001238.751613683@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:35039 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751480Ab0HWA1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:27:43 -0400
Content-Disposition: inline; filename=veth_rx_copybreak
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For small packets, create a new skb and copy the packet into it so we
avoid tearing down and creating a TCE entry.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 08:52:29.173833820 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 08:52:29.793789816 +1000
@@ -122,6 +122,11 @@ module_param(tx_copybreak, uint, 0644);
 MODULE_PARM_DESC(tx_copybreak,
 	"Maximum size of packet that is copied to a new buffer on transmit");
 
+static unsigned int rx_copybreak __read_mostly = 128;
+module_param(rx_copybreak, uint, 0644);
+MODULE_PARM_DESC(rx_copybreak,
+	"Maximum size of packet that is copied to a new buffer on receive");
+
 struct ibmveth_stat {
 	char name[ETH_GSTRING_LEN];
 	int offset;
@@ -1002,8 +1007,6 @@ static int ibmveth_poll(struct napi_stru
 
  restart_poll:
 	do {
-		struct sk_buff *skb;
-
 		if (!ibmveth_rxq_pending_buffer(adapter))
 			break;
 
@@ -1014,20 +1017,34 @@ static int ibmveth_poll(struct napi_stru
 			ibmveth_debug_printk("recycling invalid buffer\n");
 			ibmveth_rxq_recycle_buffer(adapter);
 		} else {
+			struct sk_buff *skb, *new_skb;
 			int length = ibmveth_rxq_frame_length(adapter);
 			int offset = ibmveth_rxq_frame_offset(adapter);
 			int csum_good = ibmveth_rxq_csum_good(adapter);
 
 			skb = ibmveth_rxq_get_buffer(adapter);
-			if (csum_good)
-				skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-			ibmveth_rxq_harvest_buffer(adapter);
+			new_skb = NULL;
+			if (length < rx_copybreak)
+				new_skb = netdev_alloc_skb(netdev, length);
+
+			if (new_skb) {
+				skb_copy_to_linear_data(new_skb,
+							skb->data + offset,
+							length);
+				skb = new_skb;
+				ibmveth_rxq_recycle_buffer(adapter);
+			} else {
+				ibmveth_rxq_harvest_buffer(adapter);
+				skb_reserve(skb, offset);
+			}
 
-			skb_reserve(skb, offset);
 			skb_put(skb, length);
 			skb->protocol = eth_type_trans(skb, netdev);
 
+			if (csum_good)
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+
 			netif_receive_skb(skb);	/* send it up */
 
 			netdev->stats.rx_packets++;


