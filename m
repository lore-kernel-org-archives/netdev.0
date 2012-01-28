From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/5] ipv4: ip_gre: Convert to dst_neigh_lookup()
Date: Fri, 27 Jan 2012 21:03:30 -0500 (EST)
Message-ID: <20120127.210330.2099432961070702736.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339Ab2A1CDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 21:03:32 -0500
Received: from localhost (cpe-66-65-56-15.nyc.res.rr.com [66.65.56.15])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q0S23Vmv009876
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 27 Jan 2012 18:03:31 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The conversion is very similar to that made to ipv6's SIT code.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_gre.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 05f7419..bf95416 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -730,10 +730,12 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		}
 #if IS_ENABLED(CONFIG_IPV6)
 		else if (skb->protocol == htons(ETH_P_IPV6)) {
-			struct neighbour *neigh = dst_get_neighbour_noref(skb_dst(skb));
 			const struct in6_addr *addr6;
+			struct neighbour *neigh;
+			bool do_tx_error_icmp;
 			int addr_type;
 
+			neigh = dst_neigh_lookup(skb_dst(skb), &ipv6_hdr(skb)->daddr);
 			if (neigh == NULL)
 				goto tx_error;
 
@@ -746,9 +748,14 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			}
 
 			if ((addr_type & IPV6_ADDR_COMPATv4) == 0)
+				do_tx_error_icmp = true;
+			else {
+				do_tx_error_icmp = false;
+				dst = addr6->s6_addr32[3];
+			}
+			neigh_release(neigh);
+			if (do_tx_error_icmp)
 				goto tx_error_icmp;
-
-			dst = addr6->s6_addr32[3];
 		}
 #endif
 		else
-- 
1.7.7.5
