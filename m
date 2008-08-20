From: Santiago Leon <santil@us.ibm.com>
Subject: [PATCH] ibmveth: fix bad UDP checksums
Date: Wed, 20 Aug 2008 13:09:19 -0600
Message-ID: <20080820190826.24896.41095.62294@soporte.mitelefono.ec>
Cc: Santiago Leon <santil@us.ibm.com>, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:44023 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753610AbYHTTJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 15:09:39 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7KJ9b4K007947
	for <netdev@vger.kernel.org>; Wed, 20 Aug 2008 15:09:37 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7KJ9LhY209234
	for <netdev@vger.kernel.org>; Wed, 20 Aug 2008 13:09:28 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7KJ9KZF028528
	for <netdev@vger.kernel.org>; Wed, 20 Aug 2008 13:09:21 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a ibmveth bug where bad UDP checksums are being transmitted 
when checksum offloading is enabled.
The hypervisor does checksum offloading only on TCP packets, so ibmveth calls 
skb_checksum_help() for any other protocol.  The bug happens because 
the packet is being modified after the DMA map, so we would need a memory 
barrier before making the hypervisor call.  Reordering the code so that the 
DMA map happens after skb_checksum_help() has the additional advantage of 
fixing a DMA map leak if skb_checksum_help() where to fail.

Please consider applying.

Signed-off-by: Santiago Leon <santil@us.ibm.com>
---

 ibmveth.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- a/drivers/net/ibmveth.c	2008-08-19 07:31:29.000000000 -0400
+++ b/drivers/net/ibmveth.c	2008-08-19 07:46:24.000000000 -0400
@@ -904,8 +904,6 @@ static int ibmveth_start_xmit(struct sk_
 	unsigned long data_dma_addr;
 
 	desc.fields.flags_len = IBMVETH_BUF_VALID | skb->len;
-	data_dma_addr = dma_map_single(&adapter->vdev->dev, skb->data,
-				       skb->len, DMA_TO_DEVICE);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL &&
 	    ip_hdr(skb)->protocol != IPPROTO_TCP && skb_checksum_help(skb)) {
@@ -924,6 +922,8 @@ static int ibmveth_start_xmit(struct sk_
 		buf[1] = 0;
 	}
 
+	data_dma_addr = dma_map_single(&adapter->vdev->dev, skb->data,
+				       skb->len, DMA_TO_DEVICE);
 	if (dma_mapping_error(&adapter->vdev->dev, data_dma_addr)) {
 		if (!firmware_has_feature(FW_FEATURE_CMO))
 			ibmveth_error_printk("tx: unable to map xmit buffer\n");
@@ -932,6 +932,7 @@ static int ibmveth_start_xmit(struct sk_
 		desc.fields.address = adapter->bounce_buffer_dma;
 		tx_map_failed++;
 		used_bounce = 1;
+		wmb();
 	} else
 		desc.fields.address = data_dma_addr;
 
