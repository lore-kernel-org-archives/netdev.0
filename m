From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 01/45] atm: br2684 internal stats
Date: Fri, 09 Jan 2009 15:00:58 -0800
Message-ID: <20090109230136.781097598@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42303 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754888AbZAIXSN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:13 -0500
Content-Disposition: inline; filename=br2684-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that stats are in net_device, use them.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/atm/br2684.c	2009-01-08 17:22:18.000000000 -0800
+++ b/net/atm/br2684.c	2009-01-08 23:20:52.000000000 -0800
@@ -83,7 +83,6 @@ struct br2684_dev {
 	struct list_head br2684_devs;
 	int number;
 	struct list_head brvccs;	/* one device <=> one vcc (before xmas) */
-	struct net_device_stats stats;
 	int mac_was_set;
 	enum br2684_payload payload;
 };
@@ -148,9 +147,10 @@ static struct net_device *br2684_find_de
  * the way for multiple vcc's per itf.  Returns true if we can send,
  * otherwise false
  */
-static int br2684_xmit_vcc(struct sk_buff *skb, struct br2684_dev *brdev,
+static int br2684_xmit_vcc(struct sk_buff *skb, struct net_device *dev,
 			   struct br2684_vcc *brvcc)
 {
+	struct br2684_dev *brdev = BRPRIV(dev);
 	struct atm_vcc *atmvcc;
 	int minheadroom = (brvcc->encaps == e_llc) ? 10 : 2;
 
@@ -211,8 +211,8 @@ static int br2684_xmit_vcc(struct sk_buf
 	}
 	atomic_add(skb->truesize, &sk_atm(atmvcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = atmvcc->atm_options;
-	brdev->stats.tx_packets++;
-	brdev->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 	atmvcc->send(atmvcc, skb);
 	return 1;
 }
@@ -233,14 +233,14 @@ static int br2684_start_xmit(struct sk_b
 	brvcc = pick_outgoing_vcc(skb, brdev);
 	if (brvcc == NULL) {
 		pr_debug("no vcc attached to dev %s\n", dev->name);
-		brdev->stats.tx_errors++;
-		brdev->stats.tx_carrier_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_carrier_errors++;
 		/* netif_stop_queue(dev); */
 		dev_kfree_skb(skb);
 		read_unlock(&devs_lock);
 		return 0;
 	}
-	if (!br2684_xmit_vcc(skb, brdev, brvcc)) {
+	if (!br2684_xmit_vcc(skb, dev, brvcc)) {
 		/*
 		 * We should probably use netif_*_queue() here, but that
 		 * involves added complication.  We need to walk before
@@ -248,19 +248,13 @@ static int br2684_start_xmit(struct sk_b
 		 *
 		 * Don't free here! this pointer might be no longer valid!
 		 */
-		brdev->stats.tx_errors++;
-		brdev->stats.tx_fifo_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_fifo_errors++;
 	}
 	read_unlock(&devs_lock);
 	return 0;
 }
 
-static struct net_device_stats *br2684_get_stats(struct net_device *dev)
-{
-	pr_debug("br2684_get_stats\n");
-	return &BRPRIV(dev)->stats;
-}
-
 /*
  * We remember when the MAC gets set, so we don't override it later with
  * the ESI of the ATM card of the first VC
@@ -430,17 +424,17 @@ static void br2684_push(struct atm_vcc *
 	/* sigh, interface is down? */
 	if (unlikely(!(net_dev->flags & IFF_UP)))
 		goto dropped;
-	brdev->stats.rx_packets++;
-	brdev->stats.rx_bytes += skb->len;
+	net_dev->stats.rx_packets++;
+	net_dev->stats.rx_bytes += skb->len;
 	memset(ATM_SKB(skb), 0, sizeof(struct atm_skb_data));
 	netif_rx(skb);
 	return;
 
 dropped:
-	brdev->stats.rx_dropped++;
+	net_dev->stats.rx_dropped++;
 	goto free_skb;
 error:
-	brdev->stats.rx_errors++;
+	net_dev->stats.rx_errors++;
 free_skb:
 	dev_kfree_skb(skb);
 	return;
@@ -531,8 +525,8 @@ static int br2684_regvcc(struct atm_vcc 
 
 		skb->next = skb->prev = NULL;
 		br2684_push(atmvcc, skb);
-		BRPRIV(skb->dev)->stats.rx_bytes -= skb->len;
-		BRPRIV(skb->dev)->stats.rx_packets--;
+		skb->dev->stats.rx_bytes -= skb->len;
+		skb->dev->stats.rx_packets--;
 
 		skb = next;
 	}
@@ -554,7 +548,6 @@ static void br2684_setup(struct net_devi
 	my_eth_mac_addr = netdev->set_mac_address;
 	netdev->set_mac_address = br2684_mac_addr;
 	netdev->hard_start_xmit = br2684_start_xmit;
-	netdev->get_stats = br2684_get_stats;
 
 	INIT_LIST_HEAD(&brdev->brvccs);
 }
@@ -568,7 +561,6 @@ static void br2684_setup_routed(struct n
 	my_eth_mac_addr = netdev->set_mac_address;
 	netdev->set_mac_address = br2684_mac_addr;
 	netdev->hard_start_xmit = br2684_start_xmit;
-	netdev->get_stats = br2684_get_stats;
 	netdev->addr_len = 0;
 	netdev->mtu = 1500;
 	netdev->type = ARPHRD_PPP;


