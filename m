From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/7] tlan: manage rx allocation failure better
Date: Fri, 30 May 2008 09:49:56 -0700
Message-ID: <20080530165033.768240631@vyatta.com>
References: <20080530164951.033143725@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, Samuel Chessman <chessman@tux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:34077 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751794AbYE3Qx2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 12:53:28 -0400
Content-Disposition: inline; filename=tlan-alloc-fail.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rx allocation failure at runtime is non-fatal. For normal Rx frame, it
just reuses the buffer, and during setup it just continues with a smaller
receive buffer pool.

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/tlan.c	2008-05-30 09:25:55.000000000 -0700
+++ b/drivers/net/tlan.c	2008-05-30 09:26:36.000000000 -0700
@@ -1539,8 +1539,6 @@ static u32 TLan_HandleRxEOF( struct net_
 	TLanList	*head_list;
 	struct sk_buff	*skb;
 	TLanList	*tail_list;
-	void		*t;
-	u32		frameSize;
 	u16		tmpCStat;
 	dma_addr_t	head_list_phys;
 
@@ -1549,40 +1547,34 @@ static u32 TLan_HandleRxEOF( struct net_
 	head_list_phys = priv->rxListDMA + sizeof(TLanList) * priv->rxHead;
 
 	while (((tmpCStat = head_list->cStat) & TLAN_CSTAT_FRM_CMP) && (ack < 255)) {
-		frameSize = head_list->frameSize;
+		dma_addr_t frameDma = head_list->buffer[0].address;
+		u32 frameSize = head_list->frameSize;
 		ack++;
 		if (tmpCStat & TLAN_CSTAT_EOC)
 			eoc = 1;
 
 		if (bbuf) {
-			skb = dev_alloc_skb(frameSize + 7);
-			if (skb == NULL)
-				printk(KERN_INFO "TLAN: Couldn't allocate memory for received data.\n");
-			else {
+			skb = netdev_alloc_skb(dev, frameSize + 7);
+			if ( skb ) {
 				head_buffer = priv->rxBuffer + (priv->rxHead * TLAN_MAX_FRAME_SIZE);
 				skb_reserve(skb, 2);
-				t = (void *) skb_put(skb, frameSize);
-
-				dev->stats.rx_bytes += head_list->frameSize;
+				pci_dma_sync_single_for_cpu(priv->pciDev,
+							    frameDma, frameSize,
+							    PCI_DMA_FROMDEVICE);
+				skb_copy_from_linear_data(skb, head_buffer, frameSize);
+				skb_put(skb, frameSize);
+				dev->stats.rx_bytes += frameSize;
 
-				memcpy( t, head_buffer, frameSize );
 				skb->protocol = eth_type_trans( skb, dev );
 				netif_rx( skb );
 			}
 		} else {
 			struct sk_buff *new_skb;
 
-			/*
-		 	 *	I changed the algorithm here. What we now do
-		 	 *	is allocate the new frame. If this fails we
-		 	 *	simply recycle the frame.
-		 	 */
-
-			new_skb = dev_alloc_skb( TLAN_MAX_FRAME_SIZE + 7 );
-
-			if ( new_skb != NULL ) {
+			new_skb = netdev_alloc_skb(dev, TLAN_MAX_FRAME_SIZE + 7 );
+			if ( new_skb ) {
 				skb = TLan_GetSKB(head_list);
-				pci_unmap_single(priv->pciDev, head_list->buffer[0].address, TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
+				pci_unmap_single(priv->pciDev, frameDma, TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
 				skb_put( skb, frameSize );
 
 				dev->stats.rx_bytes += frameSize;
@@ -1590,12 +1582,12 @@ static u32 TLan_HandleRxEOF( struct net_
 				skb->protocol = eth_type_trans( skb, dev );
 				netif_rx( skb );
 
-				skb_reserve( new_skb, 2 );
+				skb_reserve( new_skb, NET_IP_ALIGN );
 				head_list->buffer[0].address = pci_map_single(priv->pciDev, new_skb->data, TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
 
 				TLan_StoreSKB(head_list, new_skb);
-			} else
-				printk(KERN_WARNING "TLAN:  Couldn't allocate memory for received data.\n" );
+			}
+
 		}
 
 		head_list->forward = 0;
@@ -1994,24 +1986,27 @@ static void TLan_ResetLists( struct net_
 		if ( bbuf ) {
 			list->buffer[0].address = priv->rxBufferDMA + ( i * TLAN_MAX_FRAME_SIZE );
 		} else {
-			skb = dev_alloc_skb( TLAN_MAX_FRAME_SIZE + 7 );
-			if ( skb == NULL ) {
+			skb = netdev_alloc_skb(dev, TLAN_MAX_FRAME_SIZE + 7 );
+			if ( !skb ) {
 				printk( "TLAN:  Couldn't allocate memory for received data.\n" );
-				/* If this ever happened it would be a problem */
-			} else {
-				skb->dev = dev;
-				skb_reserve( skb, 2 );
+				break;
 			}
+
+			skb_reserve( skb, NET_IP_ALIGN );
 			list->buffer[0].address = pci_map_single(priv->pciDev, t, TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
 			TLan_StoreSKB(list, skb);
 		}
 		list->buffer[1].count = 0;
 		list->buffer[1].address = 0;
-		if ( i < TLAN_NUM_RX_LISTS - 1 )
-			list->forward = list_phys + sizeof(TLanList);
-		else
-			list->forward = 0;
+		list->forward = list_phys + sizeof(TLanList);
+	}
+
+	/* in case ran out of memory early, clear bits */
+	while (i < TLAN_NUM_RX_LISTS) {
+		TLan_StoreSKB(priv->rxList + i, NULL);
+		++i;
 	}
+	list->forward = 0;
 
 } /* TLan_ResetLists */
 

-- 

