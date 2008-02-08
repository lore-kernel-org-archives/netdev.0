From: Don Fry <pcnet32@verizon.net>
Subject: [PATCH 2.6.24] pcnet32:  use NET_IP_ALIGN instead of 2
Date: Fri, 08 Feb 2008 07:32:26 -0800
Message-ID: <1202484746.10535.7.camel@new-host.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:63260 "EHLO
	vms042pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbYBHPc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 10:32:28 -0500
Received: from [192.168.1.3] ([96.225.193.28])
 by vms042.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JVX00LC0F5KOAV4@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Fri, 08 Feb 2008 09:32:09 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change hard coded 2 to NET_IP_ALIGN.  Added new #define with comments.
Tested amd_64

Signed-off-by:  Don Fry <pcnet32@verizon.net>
---
--- linux-2.6.24-git13/drivers/net/joe.pcnet32.c	2008-02-04 10:59:08.000000000 -0800
+++ linux-2.6.24-git18/drivers/net/pcnet32.c	2008-02-08 07:20:44.000000000 -0800
@@ -174,7 +174,11 @@ static int homepna[MAX_UNITS];
 #define RX_RING_SIZE		(1 << (PCNET32_LOG_RX_BUFFERS))
 #define RX_MAX_RING_SIZE	(1 << (PCNET32_LOG_MAX_RX_BUFFERS))
 
-#define PKT_BUF_SZ		1544
+#define PKT_BUF_SKB		1544
+/* actual buffer length after being aligned */
+#define PKT_BUF_SIZE		(PKT_BUF_SKB - NET_IP_ALIGN)
+/* chip wants twos complement of the (aligned) buffer length */
+#define NEG_BUF_SIZE		(NET_IP_ALIGN - PKT_BUF_SKB)
 
 /* Offsets from base I/O address. */
 #define PCNET32_WIO_RDP		0x10
@@ -604,7 +608,7 @@ static void pcnet32_realloc_rx_ring(stru
 	/* now allocate any new buffers needed */
 	for (; new < size; new++ ) {
 		struct sk_buff *rx_skbuff;
-		new_skb_list[new] = dev_alloc_skb(PKT_BUF_SZ);
+		new_skb_list[new] = dev_alloc_skb(PKT_BUF_SKB);
 		if (!(rx_skbuff = new_skb_list[new])) {
 			/* keep the original lists and buffers */
 			if (netif_msg_drv(lp))
@@ -613,20 +617,20 @@ static void pcnet32_realloc_rx_ring(stru
 				       dev->name);
 			goto free_all_new;
 		}
-		skb_reserve(rx_skbuff, 2);
+		skb_reserve(rx_skbuff, NET_IP_ALIGN);
 
 		new_dma_addr_list[new] =
 			    pci_map_single(lp->pci_dev, rx_skbuff->data,
-					   PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
+					   PKT_BUF_SIZE, PCI_DMA_FROMDEVICE);
 		new_rx_ring[new].base = cpu_to_le32(new_dma_addr_list[new]);
-		new_rx_ring[new].buf_length = cpu_to_le16(2 - PKT_BUF_SZ);
+		new_rx_ring[new].buf_length = cpu_to_le16(NEG_BUF_SIZE);
 		new_rx_ring[new].status = cpu_to_le16(0x8000);
 	}
 	/* and free any unneeded buffers */
 	for (; new < lp->rx_ring_size; new++) {
 		if (lp->rx_skbuff[new]) {
 			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[new],
-					 PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
+					 PKT_BUF_SIZE, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(lp->rx_skbuff[new]);
 		}
 	}
@@ -651,7 +655,7 @@ static void pcnet32_realloc_rx_ring(stru
 	for (; --new >= lp->rx_ring_size; ) {
 		if (new_skb_list[new]) {
 			pci_unmap_single(lp->pci_dev, new_dma_addr_list[new],
-					 PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
+					 PKT_BUF_SIZE, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(new_skb_list[new]);
 		}
 	}
@@ -678,7 +682,7 @@ static void pcnet32_purge_rx_ring(struct
 		wmb();		/* Make sure adapter sees owner change */
 		if (lp->rx_skbuff[i]) {
 			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i],
-					 PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
+					 PKT_BUF_SIZE, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb_any(lp->rx_skbuff[i]);
 		}
 		lp->rx_skbuff[i] = NULL;
@@ -1201,7 +1205,7 @@ static void pcnet32_rx_entry(struct net_
 	pkt_len = (le32_to_cpu(rxp->msg_length) & 0xfff) - 4;
 
 	/* Discard oversize frames. */
-	if (unlikely(pkt_len > PKT_BUF_SZ - 2)) {
+	if (unlikely(pkt_len > PKT_BUF_SIZE)) {
 		if (netif_msg_drv(lp))
 			printk(KERN_ERR "%s: Impossible packet size %d!\n",
 			       dev->name, pkt_len);
@@ -1218,26 +1222,26 @@ static void pcnet32_rx_entry(struct net_
 	if (pkt_len > rx_copybreak) {
 		struct sk_buff *newskb;
 
-		if ((newskb = dev_alloc_skb(PKT_BUF_SZ))) {
-			skb_reserve(newskb, 2);
+		if ((newskb = dev_alloc_skb(PKT_BUF_SKB))) {
+			skb_reserve(newskb, NET_IP_ALIGN);
 			skb = lp->rx_skbuff[entry];
 			pci_unmap_single(lp->pci_dev,
 					 lp->rx_dma_addr[entry],
-					 PKT_BUF_SZ - 2,
+					 PKT_BUF_SIZE,
 					 PCI_DMA_FROMDEVICE);
 			skb_put(skb, pkt_len);
 			lp->rx_skbuff[entry] = newskb;
 			lp->rx_dma_addr[entry] =
 					    pci_map_single(lp->pci_dev,
 							   newskb->data,
-							   PKT_BUF_SZ - 2,
+							   PKT_BUF_SIZE,
 							   PCI_DMA_FROMDEVICE);
 			rxp->base = cpu_to_le32(lp->rx_dma_addr[entry]);
 			rx_in_place = 1;
 		} else
 			skb = NULL;
 	} else {
-		skb = dev_alloc_skb(pkt_len + 2);
+		skb = dev_alloc_skb(pkt_len + NET_IP_ALIGN);
 	}
 
 	if (skb == NULL) {
@@ -1250,7 +1254,7 @@ static void pcnet32_rx_entry(struct net_
 	}
 	skb->dev = dev;
 	if (!rx_in_place) {
-		skb_reserve(skb, 2);	/* 16 byte align */
+		skb_reserve(skb, NET_IP_ALIGN);
 		skb_put(skb, pkt_len);	/* Make room */
 		pci_dma_sync_single_for_cpu(lp->pci_dev,
 					    lp->rx_dma_addr[entry],
@@ -1291,7 +1295,7 @@ static int pcnet32_rx(struct net_device 
 		 * The docs say that the buffer length isn't touched, but Andrew
 		 * Boyd of QNX reports that some revs of the 79C965 clear it.
 		 */
-		rxp->buf_length = cpu_to_le16(2 - PKT_BUF_SZ);
+		rxp->buf_length = cpu_to_le16(NEG_BUF_SIZE);
 		wmb();	/* Make sure owner changes after others are visible */
 		rxp->status = cpu_to_le16(0x8000);
 		entry = (++lp->cur_rx) & lp->rx_mod_mask;
@@ -2396,7 +2400,7 @@ static int pcnet32_init_ring(struct net_
 		if (rx_skbuff == NULL) {
 			if (!
 			    (rx_skbuff = lp->rx_skbuff[i] =
-			     dev_alloc_skb(PKT_BUF_SZ))) {
+			     dev_alloc_skb(PKT_BUF_SKB))) {
 				/* there is not much, we can do at this point */
 				if (netif_msg_drv(lp))
 					printk(KERN_ERR
@@ -2404,16 +2408,16 @@ static int pcnet32_init_ring(struct net_
 					       dev->name);
 				return -1;
 			}
-			skb_reserve(rx_skbuff, 2);
+			skb_reserve(rx_skbuff, NET_IP_ALIGN);
 		}
 
 		rmb();
 		if (lp->rx_dma_addr[i] == 0)
 			lp->rx_dma_addr[i] =
 			    pci_map_single(lp->pci_dev, rx_skbuff->data,
-					   PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
+					   PKT_BUF_SIZE, PCI_DMA_FROMDEVICE);
 		lp->rx_ring[i].base = cpu_to_le32(lp->rx_dma_addr[i]);
-		lp->rx_ring[i].buf_length = cpu_to_le16(2 - PKT_BUF_SZ);
+		lp->rx_ring[i].buf_length = cpu_to_le16(NEG_BUF_SIZE);
 		wmb();		/* Make sure owner changes after all others are visible */
 		lp->rx_ring[i].status = cpu_to_le16(0x8000);
 	}


