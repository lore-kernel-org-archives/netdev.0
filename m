From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 10/10][IP6MR]: Use on-device stats instead of private
 ones.
Date: Tue, 20 May 2008 20:44:39 +0400
Message-ID: <4832FFF7.4080804@openvz.org>
References: <4832FBD7.7040209@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:51439 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761606AbYETQrF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 12:47:05 -0400
In-Reply-To: <4832FBD7.7040209@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to ipmr.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

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
+	reg_dev->stats->rx_bytes += skb->len;
+	reg_dev->stats->rx_packets++;
 	skb->dst = NULL;
 	nf_reset(skb);
 	netif_rx(skb);
@@ -409,26 +409,20 @@ static struct inet6_protocol pim6_protocol = {
 static int reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	read_lock(&mrt_lock);
-	((struct net_device_stats *)netdev_priv(dev))->tx_bytes += skb->len;
-	((struct net_device_stats *)netdev_priv(dev))->tx_packets++;
+	dev->stats->tx_bytes += skb->len;
+	dev->stats->tx_packets++;
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
+		vif->dev->stats->tx_bytes += skb->len;
+		vif->dev->stats->tx_packets++;
 		ip6mr_cache_report(skb, vifi, MRT6MSG_WHOLEPKT);
 		kfree_skb(skb);
 		return 0;
-- 
1.5.3.4

