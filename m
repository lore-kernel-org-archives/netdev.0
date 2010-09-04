From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 05/21] ibmveth: Add rx_copybreak
Date: Fri, 03 Sep 2010 23:28:25 -0500
Message-ID: <20100904042825.2655.81137.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:43740 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937Ab0IDE2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 00:28:54 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844Nu7x001871
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:23:56 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o844Srgx094480
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:28:53 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844SrPQ032288
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:28:53 -0600
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For small packets, create a new skb and copy the packet into it so we
avoid tearing down and creating a TCE entry.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:18:45.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:18:46.000000000 -0500
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
