From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 04/21] ibmveth: Add tx_copybreak
Date: Fri, 03 Sep 2010 23:28:20 -0500
Message-ID: <20100904042820.2655.19704.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:52111 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780Ab0IDE2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 00:28:48 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844LIdj030868
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:21:18 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o844SmRc209240
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:28:48 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844Sl2J031782
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:28:48 -0600
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the existing bounce buffer if we send a buffer under a certain size.
This saves the overhead of a TCE map/unmap.

I can't see any reason for the wmb() in the bounce buffer case, if we need
a barrier it will be before we call h_send_logical_lan but we have
nothing in the common case. Remove it.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:18:42.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:18:43.000000000 -0500
@@ -117,6 +117,11 @@ MODULE_DESCRIPTION("IBM i/pSeries Virtua
 MODULE_LICENSE("GPL");
 MODULE_VERSION(ibmveth_driver_version);
 
+static unsigned int tx_copybreak __read_mostly = 128;
+module_param(tx_copybreak, uint, 0644);
+MODULE_PARM_DESC(tx_copybreak,
+	"Maximum size of packet that is copied to a new buffer on transmit");
+
 struct ibmveth_stat {
 	char name[ETH_GSTRING_LEN];
 	int offset;
@@ -931,17 +936,24 @@ static netdev_tx_t ibmveth_start_xmit(st
 		buf[1] = 0;
 	}
 
-	data_dma_addr = dma_map_single(&adapter->vdev->dev, skb->data,
-				       skb->len, DMA_TO_DEVICE);
-	if (dma_mapping_error(&adapter->vdev->dev, data_dma_addr)) {
-		if (!firmware_has_feature(FW_FEATURE_CMO))
-			ibmveth_error_printk("tx: unable to map xmit buffer\n");
+	if (skb->len < tx_copybreak) {
+		used_bounce = 1;
+	} else {
+		data_dma_addr = dma_map_single(&adapter->vdev->dev, skb->data,
+					       skb->len, DMA_TO_DEVICE);
+		if (dma_mapping_error(&adapter->vdev->dev, data_dma_addr)) {
+			if (!firmware_has_feature(FW_FEATURE_CMO))
+				ibmveth_error_printk("tx: unable to map "
+						     "xmit buffer\n");
+			tx_map_failed++;
+			used_bounce = 1;
+		}
+	}
+
+	if (used_bounce) {
 		skb_copy_from_linear_data(skb, adapter->bounce_buffer,
 					  skb->len);
 		desc.fields.address = adapter->bounce_buffer_dma;
-		tx_map_failed++;
-		used_bounce = 1;
-		wmb();
 	} else
 		desc.fields.address = data_dma_addr;
 
