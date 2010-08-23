From: Anton Blanchard <anton@samba.org>
Subject: [patch 04/20] ibmveth: Add tx_copybreak
Date: Mon, 23 Aug 2010 10:09:34 +1000
Message-ID: <20100823001238.661834862@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:35036 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751249Ab0HWA1e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:27:34 -0400
Content-Disposition: inline; filename=veth_tx_copybreak
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the existing bounce buffer if we send a buffer under a certain size.
This saves the overhead of a TCE map/unmap.

I can't see any reason for the wmb() in the bounce buffer case, if we need
a barrier it will be before we call h_send_logical_lan but we have
nothing in the common case. Remove it.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 08:52:28.563877123 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 08:52:29.173833820 +1000
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
 


