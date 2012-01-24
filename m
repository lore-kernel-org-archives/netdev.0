From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Remove bogus checks of rt_gateway being zero.
Date: Tue, 24 Jan 2012 18:09:37 -0500 (EST)
Message-ID: <20120124.180937.1535236308212704084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274Ab2AXXJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 18:09:40 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q0ON9b0E025053
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 24 Jan 2012 15:09:40 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It can never actually happen.  rt_gateway is either the fully resolved
flow lookup key's destination address, or the non-zero FIB entry gateway
address.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Applied to net-next

 net/ipv4/ip_gre.c |    8 +++-----
 net/ipv4/ipip.c   |    2 --
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 2b53a1f..fc21335 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -724,11 +724,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			goto tx_error;
 		}
 
-		if (skb->protocol == htons(ETH_P_IP)) {
+		if (skb->protocol == htons(ETH_P_IP))
 			rt = skb_rtable(skb);
-			if ((dst = rt->rt_gateway) == 0)
-				goto tx_error_icmp;
-		}
 #if IS_ENABLED(CONFIG_IPV6)
 		else if (skb->protocol == htons(ETH_P_IPV6)) {
 			struct neighbour *neigh = dst_get_neighbour_noref(skb_dst(skb));
@@ -910,9 +907,10 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	__IPTUNNEL_XMIT(tstats, &dev->stats);
 	return NETDEV_TX_OK;
 
+#if IS_ENABLED(CONFIG_IPV6)
 tx_error_icmp:
 	dst_link_failure(skb);
-
+#endif
 tx_error:
 	dev->stats.tx_errors++;
 	dev_kfree_skb(skb);
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 413ed1b..be2cbd1 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -454,8 +454,6 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			dev->stats.tx_fifo_errors++;
 			goto tx_error;
 		}
-		if ((dst = rt->rt_gateway) == 0)
-			goto tx_error_icmp;
 	}
 
 	rt = ip_route_output_ports(dev_net(dev), &fl4, NULL,
-- 
1.7.6.5
