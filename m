From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/2] iptunnel: specify protocol outside IP header
Date: Tue, 28 May 2013 11:48:15 +0200
Message-ID: <1369734496-21961-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1369734496-21961-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:42076 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933812Ab3E1JtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 05:49:05 -0400
In-Reply-To: <1369734496-21961-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before this patch, ip_tunnel_xmit() was using the field protocol from the IP
header passed into argument.
There is no functional change, this patch prepares the support of IPv4 over
IPv4 for module sit.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/ip_tunnels.h | 2 +-
 net/ipv4/ip_gre.c        | 2 +-
 net/ipv4/ip_tunnel.c     | 4 ++--
 net/ipv4/ipip.c          | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 4b6f0b2..40b4dfc 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -101,7 +101,7 @@ int __net_init ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 void __net_exit ip_tunnel_delete_net(struct ip_tunnel_net *itn);
 
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
-		    const struct iphdr *tnl_params);
+		    const struct iphdr *tnl_params, const u8 protocol);
 int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd);
 int ip_tunnel_change_mtu(struct net_device *dev, int new_mtu);
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 2a83591..a982657 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -429,7 +429,7 @@ static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 		return;
 	}
 
-	ip_tunnel_xmit(skb, dev, tnl_params);
+	ip_tunnel_xmit(skb, dev, tnl_params, tnl_params->protocol);
 }
 
 static netdev_tx_t ipgre_xmit(struct sk_buff *skb,
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index e4147ec..b89095c 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -487,7 +487,7 @@ drop:
 EXPORT_SYMBOL_GPL(ip_tunnel_rcv);
 
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
-		    const struct iphdr *tnl_params)
+		    const struct iphdr *tnl_params, const u8 protocol)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	const struct iphdr *inner_iph;
@@ -670,7 +670,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	iph->version	=	4;
 	iph->ihl	=	sizeof(struct iphdr) >> 2;
 	iph->frag_off	=	df;
-	iph->protocol	=	tnl_params->protocol;
+	iph->protocol	=	protocol;
 	iph->tos	=	ip_tunnel_ecn_encap(tos, inner_iph, skb);
 	iph->daddr	=	fl4.daddr;
 	iph->saddr	=	fl4.saddr;
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 77bfcce..9df7ecd 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -222,7 +222,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		skb->encapsulation = 1;
 	}
 
-	ip_tunnel_xmit(skb, dev, tiph);
+	ip_tunnel_xmit(skb, dev, tiph, tiph->protocol);
 	return NETDEV_TX_OK;
 
 tx_error:
-- 
1.8.2.1
