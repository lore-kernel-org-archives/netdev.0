From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 2/4] ibmveth: Fix issue with DMA mapping failure
Date: Thu, 08 Sep 2011 10:41:04 +1000
Message-ID: <20110908004121.669225190@samba.org>
References: <20110908004102.355674129@samba.org>
Cc: netdev@vger.kernel.org
To: Santiago Leon <santil@linux.vnet.ibm.com>,
	brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60840 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757659Ab1IHAp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Sep 2011 20:45:27 -0400
Content-Disposition: inline; filename=ibmveth_dma_mapping_error.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

descs[].fields.address is 32bit which truncates any dma mapping
errors so dma_mapping_error() fails to catch it.

Use a dma_addr_t to do the comparison. With this patch I was able
to transfer many gigabytes of data with IOMMU fault injection set
at 10% probability.

Signed-off-by: Anton Blanchard <anton@samba.org>
Cc: <stable@kernel.org> # v2.6.37+
---

Index: linux-build/drivers/net/ibmveth.c
===================================================================
--- linux-build.orig/drivers/net/ibmveth.c	2011-09-01 15:01:18.066844039 +1000
+++ linux-build/drivers/net/ibmveth.c	2011-09-01 15:03:34.299079796 +1000
@@ -930,6 +930,7 @@ static netdev_tx_t ibmveth_start_xmit(st
 	union ibmveth_buf_desc descs[6];
 	int last, i;
 	int force_bounce = 0;
+	dma_addr_t dma_addr;
 
 	/*
 	 * veth handles a maximum of 6 segments including the header, so
@@ -994,17 +995,16 @@ retry_bounce:
 	}
 
 	/* Map the header */
-	descs[0].fields.address = dma_map_single(&adapter->vdev->dev, skb->data,
-						 skb_headlen(skb),
-						 DMA_TO_DEVICE);
-	if (dma_mapping_error(&adapter->vdev->dev, descs[0].fields.address))
+	dma_addr = dma_map_single(&adapter->vdev->dev, skb->data,
+				  skb_headlen(skb), DMA_TO_DEVICE);
+	if (dma_mapping_error(&adapter->vdev->dev, dma_addr))
 		goto map_failed;
 
 	descs[0].fields.flags_len = desc_flags | skb_headlen(skb);
+	descs[0].fields.address = dma_addr;
 
 	/* Map the frags */
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		unsigned long dma_addr;
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		dma_addr = dma_map_page(&adapter->vdev->dev, frag->page,
