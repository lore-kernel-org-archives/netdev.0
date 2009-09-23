From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tunnel: eliminate recursion field
Date: Wed, 23 Sep 2009 22:17:24 +0200
Message-ID: <4ABA8254.9000701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33632 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbZIWURX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 16:17:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems recursion field from "struct ip_tunnel" is not anymore needed.
recursion prevention is done at the upper level (in dev_queue_xmit()),
since we use HARD_TX_LOCK protection for tunnels.

This avoids a cache line ping pong on "struct ip_tunnel" : This structure
should be now mostly read on xmit and receive paths.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/ipip.h |    1 -
 net/ipv4/ip_gre.c  |   13 +------------
 net/ipv4/ipip.c    |    8 --------
 3 files changed, 1 insertion(+), 21 deletions(-)

diff --git a/include/net/ipip.h b/include/net/ipip.h
index 5d3036f..76e3ea6 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -12,7 +12,6 @@ struct ip_tunnel
 	struct ip_tunnel	*next;
 	struct net_device	*dev;
 
-	int			recursion;	/* Depth of hard_start_xmit recursion */
 	int			err_count;	/* Number of arrived ICMP errors */
 	unsigned long		err_time;	/* Time when the last ICMP error arrived */
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index d9645c9..41ada99 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -66,10 +66,7 @@
    solution, but it supposes maintaing new variable in ALL
    skb, even if no tunneling is used.
 
-   Current solution: t->recursion lock breaks dead loops. It looks
-   like dev->tbusy flag, but I preferred new variable, because
-   the semantics is different. One day, when hard_start_xmit
-   will be multithreaded we will have to use skb->encapsulation.
+   Current solution: HARD_TX_LOCK lock breaks dead loops.
 
 
 
@@ -678,11 +675,6 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	__be32 dst;
 	int    mtu;
 
-	if (tunnel->recursion++) {
-		stats->collisions++;
-		goto tx_error;
-	}
-
 	if (dev->type == ARPHRD_ETHER)
 		IPCB(skb)->flags = 0;
 
@@ -820,7 +812,6 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			ip_rt_put(rt);
 			stats->tx_dropped++;
 			dev_kfree_skb(skb);
-			tunnel->recursion--;
 			return NETDEV_TX_OK;
 		}
 		if (skb->sk)
@@ -888,7 +879,6 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	nf_reset(skb);
 
 	IPTUNNEL_XMIT();
-	tunnel->recursion--;
 	return NETDEV_TX_OK;
 
 tx_error_icmp:
@@ -897,7 +887,6 @@ tx_error_icmp:
 tx_error:
 	stats->tx_errors++;
 	dev_kfree_skb(skb);
-	tunnel->recursion--;
 	return NETDEV_TX_OK;
 }
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 62548cb..08ccd34 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -402,11 +402,6 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	__be32 dst = tiph->daddr;
 	int    mtu;
 
-	if (tunnel->recursion++) {
-		stats->collisions++;
-		goto tx_error;
-	}
-
 	if (skb->protocol != htons(ETH_P_IP))
 		goto tx_error;
 
@@ -485,7 +480,6 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			ip_rt_put(rt);
 			stats->tx_dropped++;
 			dev_kfree_skb(skb);
-			tunnel->recursion--;
 			return NETDEV_TX_OK;
 		}
 		if (skb->sk)
@@ -523,7 +517,6 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	nf_reset(skb);
 
 	IPTUNNEL_XMIT();
-	tunnel->recursion--;
 	return NETDEV_TX_OK;
 
 tx_error_icmp:
@@ -531,7 +524,6 @@ tx_error_icmp:
 tx_error:
 	stats->tx_errors++;
 	dev_kfree_skb(skb);
-	tunnel->recursion--;
 	return NETDEV_TX_OK;
 }
 
