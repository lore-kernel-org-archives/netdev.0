From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/7] tlan: use netdevice stats
Date: Fri, 30 May 2008 09:49:53 -0700
Message-ID: <20080530165033.520199120@vyatta.com>
References: <20080530164951.033143725@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, Samuel Chessman <chessman@tux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:34063 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750909AbYE3QxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 12:53:07 -0400
Content-Disposition: inline; filename=tlan-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use new netdevice common stats area.

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/tlan.c	2008-05-30 08:47:37.000000000 -0700
+++ b/drivers/net/tlan.c	2008-05-30 08:49:51.000000000 -0700
@@ -1276,7 +1276,7 @@ static struct net_device_stats *TLan_Get
 			TLan_PrintList( priv->txList + i, "TX", i );
 	}
 
-	return ( &( (TLanPrivateInfo *) netdev_priv(dev) )->stats );
+	return &dev->stats;
 
 } /* TLan_GetStats */
 
@@ -1434,7 +1434,7 @@ static u32 TLan_HandleTxEOF( struct net_
 		if ( tmpCStat & TLAN_CSTAT_EOC )
 			eoc = 1;
 
-		priv->stats.tx_bytes += head_list->frameSize;
+		dev->stats.tx_bytes += head_list->frameSize;
 
 		head_list->cStat = TLAN_CSTAT_UNUSED;
 		netif_start_queue(dev);
@@ -1564,7 +1564,7 @@ static u32 TLan_HandleRxEOF( struct net_
 				skb_reserve(skb, 2);
 				t = (void *) skb_put(skb, frameSize);
 
-				priv->stats.rx_bytes += head_list->frameSize;
+				dev->stats.rx_bytes += head_list->frameSize;
 
 				memcpy( t, head_buffer, frameSize );
 				skb->protocol = eth_type_trans( skb, dev );
@@ -1586,7 +1586,7 @@ static u32 TLan_HandleRxEOF( struct net_
 				pci_unmap_single(priv->pciDev, head_list->buffer[0].address, TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
 				skb_trim( skb, frameSize );
 
-				priv->stats.rx_bytes += frameSize;
+				dev->stats.rx_bytes += frameSize;
 
 				skb->protocol = eth_type_trans( skb, dev );
 				netif_rx( skb );
@@ -2142,7 +2142,6 @@ static void TLan_PrintList( TLanList *li
 
 static void TLan_ReadAndClearStats( struct net_device *dev, int record )
 {
-	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u32		tx_good, tx_under;
 	u32		rx_good, rx_over;
 	u32		def_tx, crc, code;
@@ -2179,18 +2178,18 @@ static void TLan_ReadAndClearStats( stru
 	loss       = inb( dev->base_addr + TLAN_DIO_DATA + 2 );
 
 	if ( record ) {
-		priv->stats.rx_packets += rx_good;
-		priv->stats.rx_errors  += rx_over + crc + code;
-		priv->stats.tx_packets += tx_good;
-		priv->stats.tx_errors  += tx_under + loss;
-		priv->stats.collisions += multi_col + single_col + excess_col + late_col;
-
-		priv->stats.rx_over_errors    += rx_over;
-		priv->stats.rx_crc_errors     += crc;
-		priv->stats.rx_frame_errors   += code;
+		dev->stats.rx_packets += rx_good;
+		dev->stats.rx_errors  += rx_over + crc + code;
+		dev->stats.tx_packets += tx_good;
+		dev->stats.tx_errors  += tx_under + loss;
+		dev->stats.collisions += multi_col + single_col + excess_col + late_col;
+
+		dev->stats.rx_over_errors    += rx_over;
+		dev->stats.rx_crc_errors     += crc;
+		dev->stats.rx_frame_errors   += code;
 
-		priv->stats.tx_aborted_errors += tx_under;
-		priv->stats.tx_carrier_errors += loss;
+		dev->stats.tx_aborted_errors += tx_under;
+		dev->stats.tx_carrier_errors += loss;
 	}
 
 } /* TLan_ReadAndClearStats */
--- a/drivers/net/tlan.h	2008-05-30 08:46:59.000000000 -0700
+++ b/drivers/net/tlan.h	2008-05-30 08:47:09.000000000 -0700
@@ -194,7 +194,6 @@ typedef struct tlan_private_tag {
 	u32			timerSetAt;
 	u32			timerType;
 	struct timer_list	timer;
-	struct net_device_stats	stats;
 	struct board		*adapter;
 	u32			adapterRev;
 	u32			aui;

-- 

