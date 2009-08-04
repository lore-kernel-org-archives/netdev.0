From: Benjamin LaHaise <ben.lahaise@neterion.com>
Subject: [5/6] vxge: prefetch skb->data
Date: Tue, 4 Aug 2009 16:21:57 -0400
Message-ID: <20090804202157.GF9924@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:33062 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932505AbZHDUj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 16:39:57 -0400
Received: from guinness.s2io.com (localhost [127.0.0.1])
	by barracuda.s2io.com (Spam Firewall) with ESMTP id A6A862065FF6
	for <netdev@vger.kernel.org>; Tue,  4 Aug 2009 16:22:00 -0400 (EDT)
Received: from guinness.s2io.com (142-46-210.147.tel-ott.com [142.46.210.147]) by barracuda.s2io.com with ESMTP id sulyXt3xiknbx8yj for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 16:22:00 -0400 (EDT)
Received: from neterion.com ([10.16.18.36])
	by guinness.s2io.com (8.12.6/8.12.6) with ESMTP id n74KLwmd013319
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 16:21:59 -0400 (EDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements prefetching of skb->data from a copy of the pointer 
in the descriptor (which is already in the L1 cache at this point).  This 
improves netperf rx performance (netperf -L 0,0 -c -H 192.168.254.2 -- -M 
131072 -m 131072) by 4.9% on a P4 Xeon host.

Signed-off-by: Benjamin LaHaise <ben.lahaise@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index f32abd5..e4dd716 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -286,6 +286,7 @@ vxge_rx_alloc(void *dtrh, struct vxge_ring *ring, const int skb_size)
 	skb_reserve(skb, VXGE_HW_HEADER_ETHERNET_II_802_3_ALIGN);
 
 	rx_priv->skb = skb;
+	rx_priv->skb_data = NULL;
 	rx_priv->data_size = skb_size;
 	vxge_debug_entryexit(VXGE_TRACE,
 		"%s: %s:%d Exiting...", ring->ndev->name, __func__, __LINE__);
@@ -305,7 +306,8 @@ static int vxge_rx_map(void *dtrh, struct vxge_ring *ring)
 		ring->ndev->name, __func__, __LINE__);
 	rx_priv = vxge_hw_ring_rxd_private_get(dtrh);
 
-	dma_addr = pci_map_single(ring->pdev, rx_priv->skb->data,
+	rx_priv->skb_data = rx_priv->skb->data;
+	dma_addr = pci_map_single(ring->pdev, rx_priv->skb_data,
 				rx_priv->data_size, PCI_DMA_FROMDEVICE);
 
 	if (dma_addr == 0) {
@@ -450,6 +452,7 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
 		skb = rx_priv->skb;
 		data_size = rx_priv->data_size;
 		data_dma = rx_priv->data_dma;
+		prefetch(rx_priv->skb_data);
 
 		vxge_debug_rx(VXGE_TRACE,
 			"%s: %s:%d  skb = 0x%p",
@@ -1056,6 +1059,7 @@ vxge_rx_term(void *dtrh, enum vxge_hw_rxd_state state, void *userdata)
 		rx_priv->data_size, PCI_DMA_FROMDEVICE);
 
 	dev_kfree_skb(rx_priv->skb);
+	rx_priv->skb_data = NULL;
 
 	vxge_debug_entryexit(VXGE_TRACE,
 		"%s: %s:%d  Exiting...",
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
index 8b3989b..9c36b3a 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -378,6 +378,7 @@ struct vxgedev {
 
 struct vxge_rx_priv {
 	struct sk_buff		*skb;
+	unsigned char		*skb_data;
 	dma_addr_t		data_dma;
 	dma_addr_t		data_size;
 };
