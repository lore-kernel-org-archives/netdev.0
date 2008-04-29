From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] 3c359: use netstats in net_device structure
Date: Tue, 29 Apr 2008 12:44:20 +0300
Message-ID: <4816EDF4.2000300@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080306080708030505090005"
Cc: davem@davemloft.net, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:50712 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753478AbYD2JpE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 05:45:04 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JqmOP-0004g1-26
	for netdev@vger.kernel.org; Tue, 29 Apr 2008 09:44:57 +0000
Received: from 82-135-208-232.static.zebra.lt ([82.135.208.232])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 09:44:57 +0000
Received: from paulius.zaleckas by 82-135-208-232.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 09:44:57 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080306080708030505090005
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.
Kill xl_get_stats function, because by default it is used identical
internal_stats function from net/core/dev.c

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------080306080708030505090005
Content-Type: text/x-patch;
 name="3c359_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3c359_netstats.patch"

diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index 45208a0..7766cde 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -132,7 +132,6 @@ static void xl_dn_comp(struct net_device *dev);
 static int xl_close(struct net_device *dev);
 static void xl_set_rx_mode(struct net_device *dev);
 static irqreturn_t xl_interrupt(int irq, void *dev_id);
-static struct net_device_stats * xl_get_stats(struct net_device *dev);
 static int xl_set_mac_address(struct net_device *dev, void *addr) ; 
 static void xl_arb_cmd(struct net_device *dev);
 static void xl_asb_cmd(struct net_device *dev) ; 
@@ -343,7 +342,6 @@ static int __devinit xl_probe(struct pci_dev *pdev,
 	dev->stop=&xl_close;
 	dev->do_ioctl=NULL;
 	dev->set_multicast_list=&xl_set_rx_mode;
-	dev->get_stats=&xl_get_stats ;
 	dev->set_mac_address=&xl_set_mac_address ; 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
@@ -921,7 +919,7 @@ static void xl_rx(struct net_device *dev)
 					adv_rx_ring(dev) ; 
 				
 				adv_rx_ring(dev) ; /* One more time just for luck :) */ 
-				xl_priv->xl_stats.rx_dropped++ ; 
+				dev->stats.rx_dropped++ ; 
 
 				writel(ACK_INTERRUPT | UPCOMPACK | LATCH_ACK , xl_mmio + MMIO_COMMAND) ; 
 				return ; 				
@@ -957,7 +955,7 @@ static void xl_rx(struct net_device *dev)
 			if (skb==NULL) { /* Still need to fix the rx ring */
 				printk(KERN_WARNING "%s: dev_alloc_skb failed in rx, single buffer \n",dev->name) ; 
 				adv_rx_ring(dev) ; 
-				xl_priv->xl_stats.rx_dropped++ ; 
+				dev->stats.rx_dropped++ ; 
 				writel(ACK_INTERRUPT | UPCOMPACK | LATCH_ACK , xl_mmio + MMIO_COMMAND) ; 
 				return ; 
 			}
@@ -971,8 +969,8 @@ static void xl_rx(struct net_device *dev)
 			xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr = cpu_to_le32(pci_map_single(xl_priv->pdev,skb->data,xl_priv->pkt_buf_sz, PCI_DMA_FROMDEVICE));
 			xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfraglen = cpu_to_le32(xl_priv->pkt_buf_sz) | RXUPLASTFRAG;
 			adv_rx_ring(dev) ; 
-			xl_priv->xl_stats.rx_packets++ ; 
-			xl_priv->xl_stats.rx_bytes += frame_length ; 	
+			dev->stats.rx_packets++ ; 
+			dev->stats.rx_bytes += frame_length ; 	
 
 			netif_rx(skb2) ; 		
 		 } /* if multiple buffers */
@@ -1182,8 +1180,8 @@ static int xl_xmit(struct sk_buff *skb, struct net_device *dev)
 		txd->buffer = cpu_to_le32(pci_map_single(xl_priv->pdev, skb->data, skb->len, PCI_DMA_TODEVICE));
 		txd->buffer_length = cpu_to_le32(skb->len) | TXDNFRAGLAST;
 		xl_priv->tx_ring_skb[tx_head] = skb ; 
-		xl_priv->xl_stats.tx_packets++ ; 
-		xl_priv->xl_stats.tx_bytes += skb->len ;
+		dev->stats.tx_packets++ ; 
+		dev->stats.tx_bytes += skb->len ;
 
 		/* 
 		 * Set the nextptr of the previous descriptor equal to this descriptor, add XL_TX_RING_SIZE -1 
@@ -1463,12 +1461,6 @@ static void xl_srb_bh(struct net_device *dev)
 	return ; 	
 } 
 
-static struct net_device_stats * xl_get_stats(struct net_device *dev)
-{
-	struct xl_private *xl_priv = netdev_priv(dev);
-	return (struct net_device_stats *) &xl_priv->xl_stats; 
-}
-
 static int xl_set_mac_address (struct net_device *dev, void *addr) 
 {
 	struct sockaddr *saddr = addr ; 
diff --git a/drivers/net/tokenring/3c359.h b/drivers/net/tokenring/3c359.h
index b880cba..0f8b4ec 100644
--- a/drivers/net/tokenring/3c359.h
+++ b/drivers/net/tokenring/3c359.h
@@ -273,8 +273,6 @@ struct xl_private {
 	struct wait_queue *srb_wait;
 	volatile int asb_queued;   
 
-	struct net_device_stats xl_stats ;
-
 	u16 mac_buffer ; 	
 	u16 xl_lan_status ;
 	u8 xl_ring_speed ;

--------------080306080708030505090005--

