From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 1/4] ibmveth: Fix DMA unmap error
Date: Thu, 08 Sep 2011 10:41:03 +1000
Message-ID: <20110908004121.570234962@samba.org>
References: <20110908004102.355674129@samba.org>
Cc: netdev@vger.kernel.org
To: Santiago Leon <santil@linux.vnet.ibm.com>,
	brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:42999 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757658Ab1IHAp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Sep 2011 20:45:27 -0400
Content-Disposition: inline; filename=ibmveth_1.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian King <brking@linux.vnet.ibm.com>

Commit 6e8ab30ec677 (ibmveth: Add scatter-gather support) introduced a
DMA mapping API inconsistency resulting in dma_unmap_page getting
called on memory mapped via dma_map_single. This was seen when
CONFIG_DMA_API_DEBUG was enabled. Fix up this API usage inconsistency.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
Acked-by: Anton Blanchard <anton@samba.org>
Cc: <stable@kernel.org> # v2.6.37+
---

Index: linux-build/drivers/net/ibmveth.c
===================================================================
--- linux-build.orig/drivers/net/ibmveth.c	2011-09-08 08:00:16.842856634 +1000
+++ linux-build/drivers/net/ibmveth.c	2011-09-08 09:45:43.163851274 +1000
@@ -1026,7 +1026,12 @@ retry_bounce:
 		netdev->stats.tx_bytes += skb->len;
 	}
 
-	for (i = 0; i < skb_shinfo(skb)->nr_frags + 1; i++)
+	dma_unmap_single(&adapter->vdev->dev,
+			 descs[0].fields.address,
+			 descs[0].fields.flags_len & IBMVETH_BUF_LEN_MASK,
+			 DMA_TO_DEVICE);
+
+	for (i = 1; i < skb_shinfo(skb)->nr_frags + 1; i++)
 		dma_unmap_page(&adapter->vdev->dev, descs[i].fields.address,
 			       descs[i].fields.flags_len & IBMVETH_BUF_LEN_MASK,
 			       DMA_TO_DEVICE);
