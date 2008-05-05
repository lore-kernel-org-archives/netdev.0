From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Mon, 05 May 2008 16:03:28 -0700 (PDT)
Message-ID: <20080505.160328.203996832.davem@davemloft.net>
References: <1209972139.3655.9.camel@johannes.berg>
	<1ba2fa240805050727r2060b0b4x3a9b3240647b66b1@mail.gmail.com>
	<1210000923.8245.26.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1210000923.8245.26.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Mon, 05 May 2008 17:22:03 +0200

> 
> > I've did some measurement of the TX path  on an embedded system (2.6.23 kernel)
> > When bridging packets from an ethernet device to wireless  there is
> > loss of 12% in the CPU utilization and equivalent throughput reduction
> > in data packets that are checked and expanded in
> > ieee80211_subif_start_xmit function.
> 
> Yeah, I figured.

I think we can handle this without clones or copies.

First, the skb_header_cloned() patch I posted in another reply will
get rid of copying due to clones.  I've included it below for
completeness.

The next problem is to make sure there is enough space available.  And
all that's needed is some help from the bridging layer and some hooks
into netdev_alloc_skb().

On bridge transmit, it knows the input and output devices, and the
requirements of LL header space on the transmit side.

If the transmit requirements are not met for the received packet, we
can tag the difference into the input netdev.

Using that information we can allocate extra space in
netdev_alloc_skb(), and do an skb_reserve().

The only requirement is that the ethernet driver serving input packets
uses netdev_alloc_skb().  The most important drivers already do, and
those which do not are trivially converted.

The following along with Johannes's needed_header et al. patch should
take care of the overhead.

If this proves to be a working solution, we can do something similar
for IPv4 and IPv6 forwarding.  At that point, we should make this
"adjust input device extra space" a helper function that all of
these spots can call.

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
index bdd7c35..d2b2272 100644
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
+				if (extra >= in_dex->rx_alloc_extra)
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
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
