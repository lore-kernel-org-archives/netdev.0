From: Yogesh Ashok Powar <yogeshp@marvell.com>
Subject: Query on skb headroom and bridging ethernet and wlan
Date: Thu, 21 Apr 2011 10:35:41 +0530
Message-ID: <20110421050539.GA25362@hertz.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes.berg@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dakia2.marvell.com ([65.219.4.35]:51159 "EHLO
	dakia2.marvell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab1DUFN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 01:13:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David/Johannes,
	We have observed significant throughput drop on TX path on
embedded system when bridging packets from ethernet to wireless side.
Our drivers on ethernet and wireless are MV643XX and MWL8K, respectively.

We found that mac80211 end up calling ieee80211_skb_resize (from
net/mac80211/tx.c) for every data packet as the skb_headroom was few
bytes short than the actual requirement.

We are considering two possible solutions to the problem:
1. Use the scheme developed by Johannes and David.
2. Address the issue by tuning the required extra tx headroom in the mwl8k
wireless driver.

The scheme developed by Johannes and David is discussed at the thread started by
Johannes on "mac80211: assign needed_headroom/tailroom for netdevs".

Can be seen at
http://kerneltrap.com/mailarchive/linux-netdev/2008/5/4/1719104

In one of the reply, David Miller has proposed a solution for such cases; please
see http://lists.openwall.net/netdev/2008/05/05/133

For completeness I am adding David's patch after few modifications, mainly
replacing old variables with the updated ones to make compilation error free.

With the patch below and a change in ethernet driver to use netdev_alloc_skb, 
overhead of ieee80211_skb_resize can be avoided on our setup.

We would like to know, why is this patch (or something similar) not upstream?
Or, are there issues that are difficult to resolve?

Thanks
Yogesh Powar

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0249fe7..1827ef0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1193,6 +1193,7 @@ struct net_device {
 						 * use it if/when necessary, to
 						 * avoid dirtying this cache line.
 						 */
+	unsigned int rx_alloc_extra;
 
 	struct net_device	*master; /* Pointer to master device of a group,
 					  * which this device is member of.
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index ee64287..cb2a462 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -46,6 +46,23 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
 	    (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))) {
 		kfree_skb(skb);
 	} else {
+		unsigned int headroom = skb_headroom(skb);
+		unsigned int hh_len = LL_RESERVED_SPACE(skb->dev);
+
+		if (headroom < hh_len) {
+			struct net_device *in_dev;
+			unsigned int extra;
+
+			in_dev = __dev_get_by_index(dev_net(skb->dev), skb->skb_iif);
+
+			BUG_ON(!in_dev);
+
+			extra = hh_len - headroom;
+
+			if (extra > in_dev->rx_alloc_extra)
+				in_dev->rx_alloc_extra = extra;
+		}
+
 		skb_push(skb, ETH_HLEN);
 		dev_queue_xmit(skb);
 	}
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 801dd08..d9cbd4f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -249,10 +249,11 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 		unsigned int length, gfp_t gfp_mask)
 {
 	struct sk_buff *skb;
+	unsigned int extra = dev->rx_alloc_extra + NET_SKB_PAD;
 
-	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, NUMA_NO_NODE);
+	skb = __alloc_skb(length + extra, gfp_mask, 0, NUMA_NO_NODE);
 	if (likely(skb)) {
-		skb_reserve(skb, NET_SKB_PAD);
+		skb_reserve(skb, extra);
 		skb->dev = dev;
 	}
 	return skb;
-- 
