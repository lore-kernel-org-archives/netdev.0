From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 2/2] macvlan: Avoid unnecessary multicast cloning
Date: Wed, 1 Jun 2016 11:45:44 +0800
Message-ID: <20160601034544.GC31335@gondor.apana.org.au>
References: <20160526234433.GU8402@wantstofly.org>
 <20160530081752.GA4956@gondor.apana.org.au>
 <20160530082828.GB5106@gondor.apana.org.au>
 <20160531.140713.2187659962450926738.davem@davemloft.net>
 <20160601034218.GA31335@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: buytenh@wantstofly.org, kaber@trash.net, netdev@vger.kernel.org,
	jpirko@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:43831 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756726AbcFADpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 23:45:54 -0400
Content-Disposition: inline
In-Reply-To: <20160601034218.GA31335@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we always queue a multicast packet for further processing,
even if none of the macvlan devices are subscribed to the address.

This patch optimises this by adding a global multicast filter for
a macvlan_port.

Note that this patch doesn't handle the broadcast addresses of the
individual macvlan devices correctly, if they are not all identical
to vlan->lowerdev.  However, this is already broken because there
is no mechanism in place to update the individual multicast filters
when you change the broadcast address.

If someone cares enough they should fix this by collecting all
broadcast addresses for a macvlan as we do for multicast and unicast.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index a71fa59..0c65bd9 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -49,6 +49,7 @@ struct macvlan_port {
 	bool 			passthru;
 	int			count;
 	struct hlist_head	vlan_source_hash[MACVLAN_HASH_SIZE];
+	DECLARE_BITMAP(mc_filter, MACVLAN_MC_FILTER_SZ);
 };
 
 struct macvlan_source_entry {
@@ -419,6 +420,8 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 
 	port = macvlan_port_get_rcu(skb->dev);
 	if (is_multicast_ether_addr(eth->h_dest)) {
+		unsigned int hash;
+
 		skb = ip_check_defrag(dev_net(skb->dev), skb, IP_DEFRAG_MACVLAN);
 		if (!skb)
 			return RX_HANDLER_CONSUMED;
@@ -436,7 +439,9 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 			goto out;
 		}
 
-		macvlan_broadcast_enqueue(port, src, skb);
+		hash = mc_hash(NULL, eth->h_dest);
+		if (test_bit(hash, port->mc_filter))
+			macvlan_broadcast_enqueue(port, src, skb);
 
 		return RX_HANDLER_PASS;
 	}
@@ -722,12 +727,12 @@ static void macvlan_change_rx_flags(struct net_device *dev, int change)
 	}
 }
 
-static void macvlan_set_mac_lists(struct net_device *dev)
+static void macvlan_compute_filter(unsigned long *mc_filter,
+				   struct net_device *dev,
+				   struct macvlan_dev *vlan)
 {
-	struct macvlan_dev *vlan = netdev_priv(dev);
-
 	if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) {
-		bitmap_fill(vlan->mc_filter, MACVLAN_MC_FILTER_SZ);
+		bitmap_fill(mc_filter, MACVLAN_MC_FILTER_SZ);
 	} else {
 		struct netdev_hw_addr *ha;
 		DECLARE_BITMAP(filter, MACVLAN_MC_FILTER_SZ);
@@ -739,10 +744,33 @@ static void macvlan_set_mac_lists(struct net_device *dev)
 
 		__set_bit(mc_hash(vlan, dev->broadcast), filter);
 
-		bitmap_copy(vlan->mc_filter, filter, MACVLAN_MC_FILTER_SZ);
+		bitmap_copy(mc_filter, filter, MACVLAN_MC_FILTER_SZ);
 	}
+}
+
+static void macvlan_set_mac_lists(struct net_device *dev)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+
+	macvlan_compute_filter(vlan->mc_filter, dev, vlan);
+
 	dev_uc_sync(vlan->lowerdev, dev);
 	dev_mc_sync(vlan->lowerdev, dev);
+
+	/* This is slightly inaccurate as we're including the subscription
+	 * list of vlan->lowerdev too.
+	 *
+	 * Bug alert: This only works if everyone has the same broadcast
+	 * address as lowerdev.  As soon as someone changes theirs this
+	 * will break.
+	 *
+	 * However, this is already broken as when you change your broadcast
+	 * address we don't get called.
+	 *
+	 * The solution is to maintain a list of broadcast addresses like
+	 * we do for uc/mc, if you care.
+	 */
+	macvlan_compute_filter(vlan->port->mc_filter, vlan->lowerdev, NULL);
 }
 
 static int macvlan_change_mtu(struct net_device *dev, int new_mtu)
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
