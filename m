From: David Miller <davem@davemloft.net>
Subject: build failure from ip6mr stats change.
Date: Wed, 21 May 2008 14:42:35 -0700 (PDT)
Message-ID: <20080521.144235.43063395.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53277
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753543AbYEUVmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 17:42:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


How could you possibly have test compiled this?

You kept the "stats->foo" dereferences but those all
need to be "stats.foo"

I've fixed it up as below.

UGH, the ipv4 ipmr patch has the same problem, I'll fix that up to :-(

ip6mr: Use on-device stats instead of private ones.

Similar to ipmr.

[ Fix build failures -DaveM ]

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/ip6mr.c |   22 +++++++---------------
 1 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 2de3c46..6d76103 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -388,8 +388,8 @@ static int pim6_rcv(struct sk_buff *skb)
 	skb->ip_summed = 0;
 	skb->pkt_type = PACKET_HOST;
 	dst_release(skb->dst);
-	((struct net_device_stats *)netdev_priv(reg_dev))->rx_bytes += skb->len;
-	((struct net_device_stats *)netdev_priv(reg_dev))->rx_packets++;
+	reg_dev->stats.rx_bytes += skb->len;
+	reg_dev->stats.rx_packets++;
 	skb->dst = NULL;
 	nf_reset(skb);
 	netif_rx(skb);
@@ -409,26 +409,20 @@ static struct inet6_protocol pim6_protocol = {
 static int reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	read_lock(&mrt_lock);
-	((struct net_device_stats *)netdev_priv(dev))->tx_bytes += skb->len;
-	((struct net_device_stats *)netdev_priv(dev))->tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
 	ip6mr_cache_report(skb, reg_vif_num, MRT6MSG_WHOLEPKT);
 	read_unlock(&mrt_lock);
 	kfree_skb(skb);
 	return 0;
 }
 
-static struct net_device_stats *reg_vif_get_stats(struct net_device *dev)
-{
-	return (struct net_device_stats *)netdev_priv(dev);
-}
-
 static void reg_vif_setup(struct net_device *dev)
 {
 	dev->type		= ARPHRD_PIMREG;
 	dev->mtu		= 1500 - sizeof(struct ipv6hdr) - 8;
 	dev->flags		= IFF_NOARP;
 	dev->hard_start_xmit	= reg_vif_xmit;
-	dev->get_stats		= reg_vif_get_stats;
 	dev->destructor		= free_netdev;
 }
 
@@ -436,9 +430,7 @@ static struct net_device *ip6mr_reg_vif(void)
 {
 	struct net_device *dev;
 
-	dev = alloc_netdev(sizeof(struct net_device_stats), "pim6reg",
-			   reg_vif_setup);
-
+	dev = alloc_netdev(0, "pim6reg", reg_vif_setup);
 	if (dev == NULL)
 		return NULL;
 
@@ -1377,8 +1369,8 @@ static int ip6mr_forward2(struct sk_buff *skb, struct mfc6_cache *c, int vifi)
 	if (vif->flags & MIFF_REGISTER) {
 		vif->pkt_out++;
 		vif->bytes_out += skb->len;
-		((struct net_device_stats *)netdev_priv(vif->dev))->tx_bytes += skb->len;
-		((struct net_device_stats *)netdev_priv(vif->dev))->tx_packets++;
+		vif->dev->stats.tx_bytes += skb->len;
+		vif->dev->stats.tx_packets++;
 		ip6mr_cache_report(skb, vifi, MRT6MSG_WHOLEPKT);
 		kfree_skb(skb);
 		return 0;
-- 
1.5.5.1.308.g1fbb5

