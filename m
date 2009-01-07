From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 32/42] hysdn: convert to net_device_ops and other updates
Date: Tue, 06 Jan 2009 16:33:48 -0800
Message-ID: <20090107003348.948135773@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:60696 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753019AbZAGAyC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:54:02 -0500
Content-Disposition: inline; filename=hysdn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several API problems fixed:
  * use proper allocation
  * handle renames
  * convert to net_device_ops
  * use internal net_device_stats

This driver is putrid (as in old and rotten), so I doubt any one uses it.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/isdn/hysdn/hysdn_net.c |   77 ++++++++++++++++-------------------------
 1 file changed, 31 insertions(+), 46 deletions(-)

--- a/drivers/isdn/hysdn/hysdn_net.c	2009-01-03 21:48:10.166764790 -0800
+++ b/drivers/isdn/hysdn/hysdn_net.c	2009-01-03 22:03:32.319014167 -0800
@@ -38,16 +38,12 @@ char *hysdn_net_revision = "$Revision: 1
 /* inside the definition.                                                   */
 /****************************************************************************/
 struct net_local {
-	struct net_device netdev;	/* the network device */
-	struct net_device_stats stats;
-	/* additional vars may be added here */
-	char dev_name[9];	/* our own device name */
-
 	/* Tx control lock.  This protects the transmit buffer ring
 	 * state along with the "tx full" state of the driver.  This
 	 * means all netif_queue flow control actions are protected
 	 * by this lock as well.
 	 */
+	struct net_device *dev;
 	spinlock_t lock;
 	struct sk_buff *skbs[MAX_SKB_BUFFERS];	/* pointers to tx-skbs */
 	int in_idx, out_idx;	/* indexes to buffer ring */
@@ -55,15 +51,6 @@ struct net_local {
 };				/* net_local */
 
 
-/*****************************************************/
-/* Get the current statistics for this card.         */
-/* This may be called with the card open or closed ! */
-/*****************************************************/
-static struct net_device_stats *
-net_get_stats(struct net_device *dev)
-{
-	return (&((struct net_local *) dev)->stats);
-}				/* net_device_stats */
 
 /*********************************************************************/
 /* Open/initialize the board. This is called (in the current kernel) */
@@ -182,8 +169,8 @@ hysdn_tx_netack(hysdn_card * card)
 	if (!lp->sk_count)
 		return;		/* error condition */
 
-	lp->stats.tx_packets++;
-	lp->stats.tx_bytes += lp->skbs[lp->out_idx]->len;
+	lp->dev->stats.tx_packets++;
+	lp->dev->stats.tx_bytes += lp->skbs[lp->out_idx]->len;
 
 	dev_kfree_skb(lp->skbs[lp->out_idx++]);		/* free skb */
 	if (lp->out_idx >= MAX_SKB_BUFFERS)
@@ -200,29 +187,30 @@ void
 hysdn_rx_netpkt(hysdn_card * card, unsigned char *buf, unsigned short len)
 {
 	struct net_local *lp = card->netif;
+	struct net_device *dev = lp->dev;
 	struct sk_buff *skb;
 
 	if (!lp)
 		return;		/* non existing device */
 
-	lp->stats.rx_bytes += len;
+	dev->stats.rx_bytes += len;
 
 	skb = dev_alloc_skb(len);
 	if (skb == NULL) {
 		printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n",
-		       lp->netdev.name);
-		lp->stats.rx_dropped++;
+		       dev->name);
+		dev->stats.rx_dropped++;
 		return;
 	}
 	/* copy the data */
 	memcpy(skb_put(skb, len), buf, len);
 
 	/* determine the used protocol */
-	skb->protocol = eth_type_trans(skb, &lp->netdev);
+	skb->protocol = eth_type_trans(skb, dev);
 
-	netif_rx(skb);
-	lp->stats.rx_packets++;	/* adjust packet count */
+	dev->stats.rx_packets++;	/* adjust packet count */
 
+	netif_rx(skb);
 }				/* hysdn_rx_netpkt */
 
 /*****************************************************/
@@ -242,24 +230,15 @@ hysdn_tx_netget(hysdn_card * card)
 	return (lp->skbs[lp->out_idx]);		/* next packet to send */
 }				/* hysdn_tx_netget */
 
+static const struct net_device_ops hysdn_netdev_ops = {
+	.ndo_open 		= net_open,
+	.ndo_stop		= net_close,
+	.ndo_start_xmit		= net_send_packet,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
 
-/*******************************************/
-/* init function called by register device */
-/*******************************************/
-static int
-net_init(struct net_device *dev)
-{
-	/* setup the function table */
-	dev->open = net_open;
-	dev->stop = net_close;
-	dev->hard_start_xmit = net_send_packet;
-	dev->get_stats = net_get_stats;
-
-	/* Fill in the fields of the device structure with ethernet values. */
-	ether_setup(dev);
-
-	return (0);		/* success */
-}				/* net_init */
 
 /*****************************************************************************/
 /* hysdn_net_create creates a new net device for the given card. If a device */
@@ -271,28 +250,34 @@ hysdn_net_create(hysdn_card * card)
 {
 	struct net_device *dev;
 	int i;
+	struct net_local *lp;
+
 	if(!card) {
 		printk(KERN_WARNING "No card-pt in hysdn_net_create!\n");
 		return (-ENOMEM);
 	}
 	hysdn_net_release(card);	/* release an existing net device */
-	if ((dev = kzalloc(sizeof(struct net_local), GFP_KERNEL)) == NULL) {
+
+	dev = alloc_etherdev(sizeof(struct net_local));
+	if (!dev) {
 		printk(KERN_WARNING "HYSDN: unable to allocate mem\n");
 		return (-ENOMEM);
 	}
 
+	lp = netdev_priv(dev);
+	lp->dev = dev;
+
+	dev->netdev_ops = &hysdn_netdev_ops;
 	spin_lock_init(&((struct net_local *) dev)->lock);
 
 	/* initialise necessary or informing fields */
 	dev->base_addr = card->iobase;	/* IO address */
 	dev->irq = card->irq;	/* irq */
-	dev->init = net_init;	/* the init function of the device */
-	if(dev->name) {
-		strcpy(dev->name, ((struct net_local *) dev)->dev_name);
-	} 
+
+	dev->netdev_ops = &hysdn_netdev_ops;
 	if ((i = register_netdev(dev))) {
 		printk(KERN_WARNING "HYSDN: unable to create network device\n");
-		kfree(dev);
+		free_netdev(dev);
 		return (i);
 	}
 	dev->ml_priv = card;	/* remember pointer to own data structure */
@@ -316,7 +301,7 @@ hysdn_net_release(hysdn_card * card)
 		return (0);	/* non existing */
 
 	card->netif = NULL;	/* clear out pointer */
-	dev->stop(dev);		/* close the device */
+	net_close(dev);
 
 	flush_tx_buffers((struct net_local *) dev);	/* empty buffers */
 

-- 

