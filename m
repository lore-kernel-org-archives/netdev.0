From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] ipv6: sit: Convert to dst_neigh_lookup()
Date: Thu, 26 Jan 2012 15:55:57 -0500 (EST)
Message-ID: <20120126.155557.374992396150331978.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633Ab2AZU4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 15:56:00 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q0QKtwux010260
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 26 Jan 2012 12:55:59 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The only semantic difference is that we now hold a reference to the
neighbour and thus have to release it.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/sit.c |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 133768e..c4ffd17 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -680,9 +680,10 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	/* ISATAP (RFC4214) - must come before 6to4 */
 	if (dev->priv_flags & IFF_ISATAP) {
 		struct neighbour *neigh = NULL;
+		bool do_tx_error = false;
 
 		if (skb_dst(skb))
-			neigh = dst_get_neighbour_noref(skb_dst(skb));
+			neigh = dst_neigh_lookup(skb_dst(skb), &iph6->daddr);
 
 		if (neigh == NULL) {
 			if (net_ratelimit())
@@ -697,6 +698,10 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		     ipv6_addr_is_isatap(addr6))
 			dst = addr6->s6_addr32[3];
 		else
+			do_tx_error = true;
+
+		neigh_release(neigh);
+		if (do_tx_error)
 			goto tx_error;
 	}
 
@@ -705,9 +710,10 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 
 	if (!dst) {
 		struct neighbour *neigh = NULL;
+		bool do_tx_error = false;
 
 		if (skb_dst(skb))
-			neigh = dst_get_neighbour_noref(skb_dst(skb));
+			neigh = dst_neigh_lookup(skb_dst(skb), &iph6->daddr);
 
 		if (neigh == NULL) {
 			if (net_ratelimit())
@@ -723,10 +729,14 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			addr_type = ipv6_addr_type(addr6);
 		}
 
-		if ((addr_type & IPV6_ADDR_COMPATv4) == 0)
-			goto tx_error_icmp;
+		if ((addr_type & IPV6_ADDR_COMPATv4) != 0)
+			dst = addr6->s6_addr32[3];
+		else
+			do_tx_error = true;
 
-		dst = addr6->s6_addr32[3];
+		neigh_release(neigh);
+		if (do_tx_error)
+			goto tx_error;
 	}
 
 	rt = ip_route_output_ports(dev_net(dev), &fl4, NULL,
-- 
1.7.7.6
