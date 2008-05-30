From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/7] tlan: 64bit conversion
Date: Fri, 30 May 2008 09:49:55 -0700
Message-ID: <20080530165033.693514298@vyatta.com>
References: <20080530164951.033143725@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, Samuel Chessman <chessman@tux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:34074 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751351AbYE3QxU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 12:53:20 -0400
Content-Disposition: inline; filename=tlan-64bit-warn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make this driver compile cleanly on 64 bit platforms.
Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/Kconfig	2008-05-30 08:53:58.000000000 -0700
+++ b/drivers/net/Kconfig	2008-05-30 08:54:08.000000000 -0700
@@ -1670,7 +1670,7 @@ config SUNDANCE_MMIO
 
 config TLAN
 	tristate "TI ThunderLAN support"
-	depends on NET_PCI && (PCI || EISA) && !64BIT
+	depends on NET_PCI && (PCI || EISA)
 	---help---
 	  If you have a PCI Ethernet network card based on the ThunderLAN chip
 	  which is supported by this driver, say Y and read the
--- a/drivers/net/tlan.c	2008-05-30 08:53:46.000000000 -0700
+++ b/drivers/net/tlan.c	2008-05-30 09:25:55.000000000 -0700
@@ -346,23 +346,21 @@ static void	TLan_EeReceiveByte( u16, u8 
 static int	TLan_EeReadByte( struct net_device *, u8, u8 * );
 
 
-static void
+static inline void
 TLan_StoreSKB( struct tlan_list_tag *tag, struct sk_buff *skb)
 {
 	unsigned long addr = (unsigned long)skb;
-	tag->buffer[9].address = (u32)addr;
-	addr >>= 31;	/* >>= 32 is undefined for 32bit arch, stupid C */
-	addr >>= 1;
-	tag->buffer[8].address = (u32)addr;
+	tag->buffer[9].address = addr;
+	tag->buffer[8].address = upper_32_bits(addr);
 }
 
-static struct sk_buff *
-TLan_GetSKB( struct tlan_list_tag *tag)
+static inline struct sk_buff *
+TLan_GetSKB( const struct tlan_list_tag *tag)
 {
-	unsigned long addr = tag->buffer[8].address;
-	addr <<= 31;
-	addr <<= 1;
-	addr |= tag->buffer[9].address;
+	unsigned long addr;
+
+	addr = tag->buffer[8].address;
+	addr |= (tag->buffer[9].address << 16) << 16;
 	return (struct sk_buff *) addr;
 }
 
@@ -858,7 +856,8 @@ static int TLan_Init( struct net_device 
 		dma_size = ( TLAN_NUM_RX_LISTS + TLAN_NUM_TX_LISTS )
 	           * ( sizeof(TLanList) );
 	}
-	priv->dmaStorage = pci_alloc_consistent(priv->pciDev, dma_size, &priv->dmaStorageDMA);
+	priv->dmaStorage = pci_alloc_consistent(priv->pciDev,
+						dma_size, &priv->dmaStorageDMA);
 	priv->dmaSize = dma_size;
 
 	if ( priv->dmaStorage == NULL ) {
@@ -867,11 +866,11 @@ static int TLan_Init( struct net_device 
 		return -ENOMEM;
 	}
 	memset( priv->dmaStorage, 0, dma_size );
-	priv->rxList = (TLanList *)
-		       ( ( ( (u32) priv->dmaStorage ) + 7 ) & 0xFFFFFFF8 );
-	priv->rxListDMA = ( ( ( (u32) priv->dmaStorageDMA ) + 7 ) & 0xFFFFFFF8 );
+	priv->rxList = (TLanList *) ALIGN((unsigned long)priv->dmaStorage, 8);
+	priv->rxListDMA = ALIGN(priv->dmaStorageDMA, 8);
 	priv->txList = priv->rxList + TLAN_NUM_RX_LISTS;
 	priv->txListDMA = priv->rxListDMA + sizeof(TLanList) * TLAN_NUM_RX_LISTS;
+
 	if ( bbuf ) {
 		priv->rxBuffer = (u8 *) ( priv->txList + TLAN_NUM_TX_LISTS );
 		priv->rxBufferDMA =priv->txListDMA + sizeof(TLanList) * TLAN_NUM_TX_LISTS;
@@ -1584,7 +1583,7 @@ static u32 TLan_HandleRxEOF( struct net_
 			if ( new_skb != NULL ) {
 				skb = TLan_GetSKB(head_list);
 				pci_unmap_single(priv->pciDev, head_list->buffer[0].address, TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
-				skb_trim( skb, frameSize );
+				skb_put( skb, frameSize );
 
 				dev->stats.rx_bytes += frameSize;
 
@@ -1592,9 +1591,8 @@ static u32 TLan_HandleRxEOF( struct net_
 				netif_rx( skb );
 
 				skb_reserve( new_skb, 2 );
-				t = (void *) skb_put( new_skb, TLAN_MAX_FRAME_SIZE );
 				head_list->buffer[0].address = pci_map_single(priv->pciDev, new_skb->data, TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
-				head_list->buffer[8].address = (u32) t;
+
 				TLan_StoreSKB(head_list, new_skb);
 			} else
 				printk(KERN_WARNING "TLAN:  Couldn't allocate memory for received data.\n" );
@@ -2003,10 +2001,8 @@ static void TLan_ResetLists( struct net_
 			} else {
 				skb->dev = dev;
 				skb_reserve( skb, 2 );
-				t = (void *) skb_put( skb, TLAN_MAX_FRAME_SIZE );
 			}
 			list->buffer[0].address = pci_map_single(priv->pciDev, t, TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
-			list->buffer[8].address = (u32) t;
 			TLan_StoreSKB(list, skb);
 		}
 		list->buffer[1].count = 0;
@@ -2108,7 +2104,7 @@ static void TLan_PrintList( TLanList *li
 {
 	int i;
 
-	printk( "TLAN:   %s List %d at 0x%08x\n", type, num, (u32) list );
+	printk( "TLAN:   %s List %d at %p\n", type, num, list );
 	printk( "TLAN:      Forward    = 0x%08x\n",  list->forward );
 	printk( "TLAN:      CSTAT      = 0x%04hx\n", list->cStat );
 	printk( "TLAN:      Frame Size = 0x%04hx\n", list->frameSize );

-- 

