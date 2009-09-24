From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tunnels: Optimize tx path
Date: Thu, 24 Sep 2009 09:43:58 +0200
Message-ID: <4ABB233E.5050503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52795 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508AbZIXHn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 03:43:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently dirty a cache line to update tunnel device stats
(tx_packets/tx_bytes). We better use the txq->tx_bytes/tx_packets
counters that already are present in cpu cache, in the cache
line shared with txq->_xmit_lock

This patch extends IPTUNNEL_XMIT() macro to use txq pointer
provided by the caller.

Also &tunnel->dev->stats can be replaced by &dev->stats

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/ipip.h |    6 +++---
 net/ipv4/ip_gre.c  |    5 +++--
 net/ipv4/ipip.c    |    5 +++--
 net/ipv6/sit.c     |    5 +++--
 4 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/include/net/ipip.h b/include/net/ipip.h
index 5d3036f..8f990bb 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -50,9 +50,9 @@ struct ip_tunnel_prl_entry
 	ip_select_ident(iph, &rt->u.dst, NULL);				\
 									\
 	err = ip_local_out(skb);					\
-	if (net_xmit_eval(err) == 0) {					\
-		stats->tx_bytes += pkt_len;				\
-		stats->tx_packets++;					\
+	if (likely(net_xmit_eval(err) == 0)) {				\
+		txq->tx_bytes += pkt_len;				\
+		txq->tx_packets++;					\
 	} else {							\
 		stats->tx_errors++;					\
 		stats->tx_aborted_errors++;				\
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index d9645c9..45b8785 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -665,7 +665,8 @@ drop_nolock:
 static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct net_device_stats *stats = &tunnel->dev->stats;
+	struct net_device_stats *stats = &dev->stats;
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
 	struct iphdr  *old_iph = ip_hdr(skb);
 	struct iphdr  *tiph;
 	u8     tos;
@@ -818,7 +819,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		struct sk_buff *new_skb = skb_realloc_headroom(skb, max_headroom);
 		if (!new_skb) {
 			ip_rt_put(rt);
-			stats->tx_dropped++;
+			txq->tx_dropped++;
 			dev_kfree_skb(skb);
 			tunnel->recursion--;
 			return NETDEV_TX_OK;
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 62548cb..40b3730 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -390,7 +390,8 @@ static int ipip_rcv(struct sk_buff *skb)
 static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct net_device_stats *stats = &tunnel->dev->stats;
+	struct net_device_stats *stats = &dev->stats;
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
 	struct iphdr  *tiph = &tunnel->parms.iph;
 	u8     tos = tunnel->parms.iph.tos;
 	__be16 df = tiph->frag_off;
@@ -483,7 +484,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		struct sk_buff *new_skb = skb_realloc_headroom(skb, max_headroom);
 		if (!new_skb) {
 			ip_rt_put(rt);
-			stats->tx_dropped++;
+			txq->tx_dropped++;
 			dev_kfree_skb(skb);
 			tunnel->recursion--;
 			return NETDEV_TX_OK;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 0ae4f64..a4aeb2b 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -613,7 +613,8 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 				     struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct net_device_stats *stats = &tunnel->dev->stats;
+	struct net_device_stats *stats = &dev->stats;
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
 	struct iphdr  *tiph = &tunnel->parms.iph;
 	struct ipv6hdr *iph6 = ipv6_hdr(skb);
 	u8     tos = tunnel->parms.iph.tos;
@@ -751,7 +752,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		struct sk_buff *new_skb = skb_realloc_headroom(skb, max_headroom);
 		if (!new_skb) {
 			ip_rt_put(rt);
-			stats->tx_dropped++;
+			txq->tx_dropped++;
 			dev_kfree_skb(skb);
 			tunnel->recursion--;
 			return NETDEV_TX_OK;
