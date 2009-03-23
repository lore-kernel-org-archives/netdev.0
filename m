From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/bridge: use the maximum hard_header_len of ports
 for bridging device
Date: Mon, 23 Mar 2009 15:20:28 -0700 (PDT)
Message-ID: <20090323.152028.205335400.davem@davemloft.net>
References: <1237539869-30721-1-git-send-email-leoli@freescale.com>
	<20090323085122.4c9d21f2@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49229
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750972AbZCWWUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 18:20:41 -0400
In-Reply-To: <20090323085122.4c9d21f2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 23 Mar 2009 08:51:22 -0700

> That ensures big enough header for locally generated packets, but
> any drivers that need bigger headroom still must handle bridged packets
> that come in with smaller space. When bridging packets, the skb comes
> from the allocation by the receiving driver. Almost all drivers will
> use dev_alloc_skb() which will allocate NET_SKB_PAD (16) bytes of
> additional headroom. This is used to hold copy of ethernet header for
> the bridge/netfilter code.
> 
> So your patch is fine as an optimization but a driver can not safely
> depend on any additional headroom. The driver must check if there
> is space, and if no space is available, reallocate and copy.

We had some plans to deal with this kind of issue for wireless
too.  Let me see if I can find the RFC patch from that discussion...

Here it is, similar code would be added to the ipv4/ipv6 forwarding
paths:

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7c1d446..6c06fba 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -600,6 +600,7 @@ struct net_device
  * Cache line mostly used on receive path (including eth_type_trans())
  */
 	unsigned long		last_rx;	/* Time of last Rx	*/
+	unsigned int		rx_alloc_extra;
 	/* Interface address info used in eth_type_trans() */
 	unsigned char		dev_addr[MAX_ADDR_LEN];	/* hw address, (before bcast 
 							because most packets are unicast) */
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index bdd7c35..531e483 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -42,6 +42,22 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
 		if (nf_bridge_maybe_copy_header(skb))
 			kfree_skb(skb);
 		else {
+			unsigned int headroom = skb_headroom(skb);
+			unsigned int hh_len = LL_RESERVED_SPACE(skb->dev);
+
+			if (headroom < hh_len) {
+				struct net_device *in_dev;
+				unsigned int extra;
+
+				in_dev = __dev_get_by_index(dev_net(skb->dev),
+							    skb->iif);
+				BUG_ON(!in_dev);
+
+				extra = hh_len - headroom;
+				if (extra >= in_dev->rx_alloc_extra)
+					in_dev->rx_alloc_extra = extra;
+			}
+
 			skb_push(skb, ETH_HLEN);
 
 			dev_queue_xmit(skb);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5c459f2..74a2515 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -255,11 +255,12 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 		unsigned int length, gfp_t gfp_mask)
 {
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
+	unsigned int extra = dev->rx_alloc_extra + NET_SKB_PAD;
 	struct sk_buff *skb;
 
-	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
+	skb = __alloc_skb(length + extra, gfp_mask, 0, node);
 	if (likely(skb)) {
-		skb_reserve(skb, NET_SKB_PAD);
+		skb_reserve(skb, extra);
 		skb->dev = dev;
 	}
 	return skb;
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index f35eaea..86f0e36 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1562,13 +1562,13 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 	 * be cloned. This could happen, e.g., with Linux bridge code passing
 	 * us broadcast frames. */
 
-	if (head_need > 0 || skb_cloned(skb)) {
+	if (head_need > 0 || skb_header_cloned(skb)) {
 #if 0
 		printk(KERN_DEBUG "%s: need to reallocate buffer for %d bytes "
 		       "of headroom\n", dev->name, head_need);
 #endif
 
-		if (skb_cloned(skb))
+		if (skb_header_cloned(skb))
 			I802_DEBUG_INC(local->tx_expand_skb_head_cloned);
 		else
 			I802_DEBUG_INC(local->tx_expand_skb_head);
