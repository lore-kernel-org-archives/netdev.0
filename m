From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 1/1] ibmveth: Fix DMA unmap error
Date: Wed, 07 Sep 2011 16:37:34 -0500
Message-ID: <201109072137.p87LbV51024857@d01av04.pok.ibm.com>
Cc: santil@linux.vnet.ibm.com, anton@samba.org,
	brking@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:48696 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757175Ab1IGVjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Sep 2011 17:39:12 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p87LENs7008130
	for <netdev@vger.kernel.org>; Wed, 7 Sep 2011 17:14:23 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p87LbWn2349330
	for <netdev@vger.kernel.org>; Wed, 7 Sep 2011 17:37:34 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p87LbVWV024887
	for <netdev@vger.kernel.org>; Wed, 7 Sep 2011 17:37:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Commit 6e8ab30ec677925e8999a9f5bdb028736d22d48c introduced a DMA mapping
API inconsistency resulting in dma_unmap_page getting called on memory
mapped via dma_map_single. This was seen when CONFIG_DMA_API_DEBUG was
enabled. Fix up this API usage inconsistency.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
---

 drivers/net/ibmveth.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff -puN drivers/net/ibmveth.c~ibmveth_fix_mapping_issue drivers/net/ibmveth.c
--- linux-2.6/drivers/net/ibmveth.c~ibmveth_fix_mapping_issue	2011-09-07 16:28:19.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.c	2011-09-07 16:28:19.000000000 -0500
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
_
