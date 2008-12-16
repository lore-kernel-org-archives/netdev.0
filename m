From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: [PATCH 2/2] tlan: Remove broken support for big buffers
Date: Tue, 16 Dec 2008 17:25:16 +0200
Message-ID: <1229441116-15077-2-git-send-email-sakari.ailus@iki.fi>
References: <4947C842.1020503@iki.fi>
 <1229441116-15077-1-git-send-email-sakari.ailus@iki.fi>
Cc: Sakari Ailus <sakari.ailus@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw03.mail.saunalahti.fi ([195.197.172.111]:44728 "EHLO
	gw03.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757341AbYLPPZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 10:25:23 -0500
In-Reply-To: <1229441116-15077-1-git-send-email-sakari.ailus@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The big rx/tx buffer support is broken and unlikely to be very useful as
such. Remove it.

Signed-off-by: Sakari Ailus <sakari.ailus@iki.fi>
---
 drivers/net/tlan.c |  211 +++++++++++++++++++---------------------------------
 1 files changed, 77 insertions(+), 134 deletions(-)

diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index e604982..2a2aacb 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -163,6 +163,11 @@
  *	v1.15 Apr 4, 2002    - Correct operation when aui=1 to be
  *	                       10T half duplex no loopback
  *	                       Thanks to Gunnar Eikman
+ *
+ *	Sakari Ailus <sakari.ailus@iki.fi>:
+ *
+ *	v1.15a Dec 15 2008   - Remove bbuf support, it doesn't work anyway.
+ *
  *******************************************************************************/
 
 #include <linux/module.h>
@@ -213,12 +218,8 @@ static  int		debug;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "ThunderLAN debug mask");
 
-static	int		bbuf;
-module_param(bbuf, int, 0);
-MODULE_PARM_DESC(bbuf, "ThunderLAN use big buffer (0-1)");
-
 static	const char TLanSignature[] = "TLAN";
-static  const char tlan_banner[] = "ThunderLAN driver v1.15\n";
+static  const char tlan_banner[] = "ThunderLAN driver v1.15a\n";
 static  int tlan_have_pci;
 static  int tlan_have_eisa;
 
@@ -859,13 +860,8 @@ static int TLan_Init( struct net_device *dev )
 
 	priv = netdev_priv(dev);
 
-	if ( bbuf ) {
-		dma_size = ( TLAN_NUM_RX_LISTS + TLAN_NUM_TX_LISTS )
-	           * ( sizeof(TLanList) + TLAN_MAX_FRAME_SIZE );
-	} else {
-		dma_size = ( TLAN_NUM_RX_LISTS + TLAN_NUM_TX_LISTS )
-	           * ( sizeof(TLanList) );
-	}
+	dma_size = ( TLAN_NUM_RX_LISTS + TLAN_NUM_TX_LISTS )
+		* ( sizeof(TLanList) );
 	priv->dmaStorage = pci_alloc_consistent(priv->pciDev,
 						dma_size, &priv->dmaStorageDMA);
 	priv->dmaSize = dma_size;
@@ -881,16 +877,6 @@ static int TLan_Init( struct net_device *dev )
 	priv->txList = priv->rxList + TLAN_NUM_RX_LISTS;
 	priv->txListDMA = priv->rxListDMA + sizeof(TLanList) * TLAN_NUM_RX_LISTS;
 
-	if ( bbuf ) {
-		priv->rxBuffer = (u8 *) ( priv->txList + TLAN_NUM_TX_LISTS );
-		priv->rxBufferDMA =priv->txListDMA
-			+ sizeof(TLanList) * TLAN_NUM_TX_LISTS;
-		priv->txBuffer = priv->rxBuffer
-			+ ( TLAN_NUM_RX_LISTS * TLAN_MAX_FRAME_SIZE );
-		priv->txBufferDMA = priv->rxBufferDMA
-			+ ( TLAN_NUM_RX_LISTS * TLAN_MAX_FRAME_SIZE );
-	}
-
 	err = 0;
 	for ( i = 0;  i < 6 ; i++ )
 		err |= TLan_EeReadByte( dev,
@@ -1094,9 +1080,8 @@ static void TLan_tx_timeout_work(struct work_struct *work)
 static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 {
 	TLanPrivateInfo *priv = netdev_priv(dev);
-	TLanList	*tail_list;
 	dma_addr_t	tail_list_phys;
-	u8		*tail_buffer;
+	TLanList	*tail_list;
 	unsigned long	flags;
 	unsigned int    txlen;
 
@@ -1125,15 +1110,10 @@ static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 
 	tail_list->forward = 0;
 
-	if ( bbuf ) {
-		tail_buffer = priv->txBuffer + ( priv->txTail * TLAN_MAX_FRAME_SIZE );
-		skb_copy_from_linear_data(skb, tail_buffer, txlen);
-	} else {
-		tail_list->buffer[0].address = pci_map_single(priv->pciDev,
-							      skb->data, txlen,
-							      PCI_DMA_TODEVICE);
-		TLan_StoreSKB(tail_list, skb);
-	}
+	tail_list->buffer[0].address = pci_map_single(priv->pciDev,
+						      skb->data, txlen,
+						      PCI_DMA_TODEVICE);
+	TLan_StoreSKB(tail_list, skb);
 
 	tail_list->frameSize = (u16) txlen;
 	tail_list->buffer[0].count = TLAN_LAST_BUFFER | (u32) txlen;
@@ -1163,9 +1143,6 @@ static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 
 	CIRC_INC( priv->txTail, TLAN_NUM_TX_LISTS );
 
-	if ( bbuf )
-		dev_kfree_skb_any(skb);
-
 	dev->trans_start = jiffies;
 	return 0;
 
@@ -1429,17 +1406,16 @@ static u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
 	head_list = priv->txList + priv->txHead;
 
 	while (((tmpCStat = head_list->cStat ) & TLAN_CSTAT_FRM_CMP) && (ack < 255)) {
+		struct sk_buff *skb = TLan_GetSKB(head_list);
+
 		ack++;
-		if ( ! bbuf ) {
-			struct sk_buff *skb = TLan_GetSKB(head_list);
-			pci_unmap_single(priv->pciDev, head_list->buffer[0].address,
-					 max(skb->len,
-					     (unsigned int)TLAN_MIN_FRAME_SIZE),
-					 PCI_DMA_TODEVICE);
-			dev_kfree_skb_any(skb);
-			head_list->buffer[8].address = 0;
-			head_list->buffer[9].address = 0;
-		}
+		pci_unmap_single(priv->pciDev, head_list->buffer[0].address,
+				 max(skb->len,
+				     (unsigned int)TLAN_MIN_FRAME_SIZE),
+				 PCI_DMA_TODEVICE);
+		dev_kfree_skb_any(skb);
+		head_list->buffer[8].address = 0;
+		head_list->buffer[9].address = 0;
 
 		if ( tmpCStat & TLAN_CSTAT_EOC )
 			eoc = 1;
@@ -1549,7 +1525,6 @@ static u32 TLan_HandleRxEOF( struct net_device *dev, u16 host_int )
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u32		ack = 0;
 	int		eoc = 0;
-	u8		*head_buffer;
 	TLanList	*head_list;
 	struct sk_buff	*skb;
 	TLanList	*tail_list;
@@ -1564,53 +1539,33 @@ static u32 TLan_HandleRxEOF( struct net_device *dev, u16 host_int )
 	while (((tmpCStat = head_list->cStat) & TLAN_CSTAT_FRM_CMP) && (ack < 255)) {
 		dma_addr_t frameDma = head_list->buffer[0].address;
 		u32 frameSize = head_list->frameSize;
+		struct sk_buff *new_skb;
+
 		ack++;
 		if (tmpCStat & TLAN_CSTAT_EOC)
 			eoc = 1;
 
-		if (bbuf) {
-			skb = netdev_alloc_skb(dev, frameSize + 7);
-			if ( !skb )
-				goto drop_and_reuse;
-
-			head_buffer = priv->rxBuffer
-				+ (priv->rxHead * TLAN_MAX_FRAME_SIZE);
-			skb_reserve(skb, 2);
-			pci_dma_sync_single_for_cpu(priv->pciDev,
-						    frameDma, frameSize,
-						    PCI_DMA_FROMDEVICE);
-			skb_copy_from_linear_data(skb, head_buffer, frameSize);
-			skb_put(skb, frameSize);
-			dev->stats.rx_bytes += frameSize;
-
-			skb->protocol = eth_type_trans( skb, dev );
-			netif_rx( skb );
-		} else {
-			struct sk_buff *new_skb;
+		new_skb = netdev_alloc_skb(dev, TLAN_MAX_FRAME_SIZE + 7 );
+		if ( !new_skb )
+			goto drop_and_reuse;
 
-			new_skb = netdev_alloc_skb(dev, TLAN_MAX_FRAME_SIZE + 7 );
-			if ( !new_skb )
-				goto drop_and_reuse;
+		skb = TLan_GetSKB(head_list);
+		pci_unmap_single(priv->pciDev, frameDma,
+				 TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
+		skb_put( skb, frameSize );
 
-			skb = TLan_GetSKB(head_list);
-			pci_unmap_single(priv->pciDev, frameDma,
-					 TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
-			skb_put( skb, frameSize );
+		dev->stats.rx_bytes += frameSize;
 
-			dev->stats.rx_bytes += frameSize;
+		skb->protocol = eth_type_trans( skb, dev );
+		netif_rx( skb );
 
-			skb->protocol = eth_type_trans( skb, dev );
-			netif_rx( skb );
+		skb_reserve( new_skb, NET_IP_ALIGN );
+		head_list->buffer[0].address = pci_map_single(priv->pciDev,
+							      new_skb->data,
+							      TLAN_MAX_FRAME_SIZE,
+							      PCI_DMA_FROMDEVICE);
 
-			skb_reserve( new_skb, NET_IP_ALIGN );
-			head_list->buffer[0].address = pci_map_single(priv->pciDev,
-								      new_skb->data,
-								      TLAN_MAX_FRAME_SIZE,
-								      PCI_DMA_FROMDEVICE);
-
-			TLan_StoreSKB(head_list, new_skb);
-
-		}
+		TLan_StoreSKB(head_list, new_skb);
 drop_and_reuse:
 		head_list->forward = 0;
 		head_list->cStat = 0;
@@ -1995,12 +1950,7 @@ static void TLan_ResetLists( struct net_device *dev )
 	for ( i = 0; i < TLAN_NUM_TX_LISTS; i++ ) {
 		list = priv->txList + i;
 		list->cStat = TLAN_CSTAT_UNUSED;
-		if ( bbuf ) {
-			list->buffer[0].address = priv->txBufferDMA
-				+ ( i * TLAN_MAX_FRAME_SIZE );
-		} else {
-			list->buffer[0].address = 0;
-		}
+		list->buffer[0].address = 0;
 		list->buffer[2].count = 0;
 		list->buffer[2].address = 0;
 		list->buffer[8].address = 0;
@@ -2015,23 +1965,18 @@ static void TLan_ResetLists( struct net_device *dev )
 		list->cStat = TLAN_CSTAT_READY;
 		list->frameSize = TLAN_MAX_FRAME_SIZE;
 		list->buffer[0].count = TLAN_MAX_FRAME_SIZE | TLAN_LAST_BUFFER;
-		if ( bbuf ) {
-			list->buffer[0].address = priv->rxBufferDMA
-				+ ( i * TLAN_MAX_FRAME_SIZE );
-		} else {
-			skb = netdev_alloc_skb(dev, TLAN_MAX_FRAME_SIZE + 7 );
-			if ( !skb ) {
-				pr_err("TLAN: out of memory for received data.\n" );
-				break;
-			}
-
-			skb_reserve( skb, NET_IP_ALIGN );
-			list->buffer[0].address = pci_map_single(priv->pciDev,
-								 skb->data,
-								 TLAN_MAX_FRAME_SIZE,
-								 PCI_DMA_FROMDEVICE);
-			TLan_StoreSKB(list, skb);
+		skb = netdev_alloc_skb(dev, TLAN_MAX_FRAME_SIZE + 7 );
+		if ( !skb ) {
+			pr_err("TLAN: out of memory for received data.\n" );
+			break;
 		}
+
+		skb_reserve( skb, NET_IP_ALIGN );
+		list->buffer[0].address = pci_map_single(priv->pciDev,
+							 skb->data,
+							 TLAN_MAX_FRAME_SIZE,
+							 PCI_DMA_FROMDEVICE);
+		TLan_StoreSKB(list, skb);
 		list->buffer[1].count = 0;
 		list->buffer[1].address = 0;
 		list->forward = list_phys + sizeof(TLanList);
@@ -2054,35 +1999,33 @@ static void TLan_FreeLists( struct net_device *dev )
 	TLanList	*list;
 	struct sk_buff	*skb;
 
-	if ( ! bbuf ) {
-		for ( i = 0; i < TLAN_NUM_TX_LISTS; i++ ) {
-			list = priv->txList + i;
-			skb = TLan_GetSKB(list);
-			if ( skb ) {
-				pci_unmap_single(
-					priv->pciDev,
-					list->buffer[0].address,
-					max(skb->len,
-					    (unsigned int)TLAN_MIN_FRAME_SIZE),
-					PCI_DMA_TODEVICE);
-				dev_kfree_skb_any( skb );
-				list->buffer[8].address = 0;
-				list->buffer[9].address = 0;
-			}
+	for ( i = 0; i < TLAN_NUM_TX_LISTS; i++ ) {
+		list = priv->txList + i;
+		skb = TLan_GetSKB(list);
+		if ( skb ) {
+			pci_unmap_single(
+				priv->pciDev,
+				list->buffer[0].address,
+				max(skb->len,
+				    (unsigned int)TLAN_MIN_FRAME_SIZE),
+				PCI_DMA_TODEVICE);
+			dev_kfree_skb_any( skb );
+			list->buffer[8].address = 0;
+			list->buffer[9].address = 0;
 		}
+	}
 
-		for ( i = 0; i < TLAN_NUM_RX_LISTS; i++ ) {
-			list = priv->rxList + i;
-			skb = TLan_GetSKB(list);
-			if ( skb ) {
-				pci_unmap_single(priv->pciDev,
-						 list->buffer[0].address,
-						 TLAN_MAX_FRAME_SIZE,
-						 PCI_DMA_FROMDEVICE);
-				dev_kfree_skb_any( skb );
-				list->buffer[8].address = 0;
-				list->buffer[9].address = 0;
-			}
+	for ( i = 0; i < TLAN_NUM_RX_LISTS; i++ ) {
+		list = priv->rxList + i;
+		skb = TLan_GetSKB(list);
+		if ( skb ) {
+			pci_unmap_single(priv->pciDev,
+					 list->buffer[0].address,
+					 TLAN_MAX_FRAME_SIZE,
+					 PCI_DMA_FROMDEVICE);
+			dev_kfree_skb_any( skb );
+			list->buffer[8].address = 0;
+			list->buffer[9].address = 0;
 		}
 	}
 } /* TLan_FreeLists */
-- 
1.5.6.5

