From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [RFC] IXP4xx: Make the Ethernet driver use built-in netdev stats.
Date: Sun, 21 Dec 2008 02:12:54 +0100
Message-ID: <m3r642baax.fsf@maximus.localdomain>
References: <m3vdtebadt.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:48651 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752068AbYLUBNE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2008 20:13:04 -0500
In-Reply-To: <m3vdtebadt.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Sun\, 21 Dec 2008 02\:11\:10 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Few patches I'm posting for review only.

Not for operational use.

IXP4xx: Make the Ethernet driver use built-in netdev stats.

--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -164,7 +164,6 @@ struct port {
 	struct npe *npe;
 	struct net_device *netdev;
 	struct napi_struct napi;
-	struct net_device_stats stat;
 	struct mii_if_info mii;
 	struct delayed_work mdio_thread;
 	struct eth_plat_info *plat;
@@ -562,7 +561,7 @@ static int eth_poll(struct napi_struct *napi, int budget)
 #endif
 
 		if (!skb) {
-			port->stat.rx_dropped++;
+			dev->stats.rx_dropped++;
 			/* put the desc back on RX-ready queue */
 			desc->buf_len = MAX_MRU;
 			desc->pkt_len = 0;
@@ -589,8 +588,8 @@ static int eth_poll(struct napi_struct *napi, int budget)
 
 		skb->protocol = eth_type_trans(skb, dev);
 		dev->last_rx = jiffies;
-		port->stat.rx_packets++;
-		port->stat.rx_bytes += skb->len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += skb->len;
 		netif_receive_skb(skb);
 
 		/* put the new buffer on RX-free queue */
@@ -635,8 +634,8 @@ static void eth_txdone_irq(void *unused)
 		debug_desc(phys, desc);
 
 		if (port->tx_buff_tab[n_desc]) { /* not the draining packet */
-			port->stat.tx_packets++;
-			port->stat.tx_bytes += desc->pkt_len;
+			port->netdev->stats.tx_packets++;
+			port->netdev->stats.tx_bytes += desc->pkt_len;
 
 			dma_unmap_tx(port, desc);
 #if DEBUG_TX
@@ -674,7 +673,7 @@ static int eth_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (unlikely(skb->len > MAX_MRU)) {
 		dev_kfree_skb(skb);
-		port->stat.tx_errors++;
+		dev->stats.tx_errors++;
 		return NETDEV_TX_OK;
 	}
 
@@ -690,7 +689,7 @@ static int eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	bytes = ALIGN(offset + len, 4);
 	if (!(mem = kmalloc(bytes, GFP_ATOMIC))) {
 		dev_kfree_skb(skb);
-		port->stat.tx_dropped++;
+		dev->stats.tx_dropped++;
 		return NETDEV_TX_OK;
 	}
 	memcpy_swab32(mem, (u32 *)((int)skb->data & ~3), bytes / 4);
@@ -704,7 +703,7 @@ static int eth_xmit(struct sk_buff *skb, struct net_device *dev)
 #else
 		kfree(mem);
 #endif
-		port->stat.tx_dropped++;
+		dev->stats.tx_dropped++;
 		return NETDEV_TX_OK;
 	}
 
@@ -747,12 +746,6 @@ static int eth_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 
-static struct net_device_stats *eth_stats(struct net_device *dev)
-{
-	struct port *port = netdev_priv(dev);
-	return &port->stat;
-}
-
 static void eth_set_mcast_list(struct net_device *dev)
 {
 	struct port *port = netdev_priv(dev);
@@ -1156,7 +1149,6 @@ static int __devinit eth_init_one(struct platform_device *pdev)
 	dev->open = eth_open;
 	dev->hard_start_xmit = eth_xmit;
 	dev->stop = eth_close;
-	dev->get_stats = eth_stats;
 	dev->do_ioctl = eth_ioctl;
 	dev->set_multicast_list = eth_set_mcast_list;
 	dev->tx_queue_len = 100;

-- 
Krzysztof Halasa
