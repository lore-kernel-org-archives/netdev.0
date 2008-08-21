From: adobriyan@gmail.com
Subject: [PATCH 05/38] Fix ip{,6}_route_me_harder() in netns
Date: Fri, 22 Aug 2008 02:39:58 +0400
Message-ID: <20080821223958.GA31601@x200.localdomain>
References: <20080821215825.GE31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kaber@trash.net, containers@lists.linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080821215825.GE31136@x200.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ip_route_me_harder() is called on output codepaths:
1) IPVS: honestly, not sure, looks like it can be called during forwarding
2) IPv4 REJECT: refreshing comment re skb->dst is valid and assigment of
   skb->dst right before call :^)
3) NAT: called in LOCAL_OUT hook
4) iptable_mangle: LOCAL_OUT hook
5) nf_ip_reroute(): LOCAL_OUT hook (no clue about queueing packets to luserspace)

ip6_route_me_harder() is also called in output codepaths:
1) ip6table_mangle: LOCAL_OUT hook
2) nf_ip6_reroute: LOCAL_OUT hook (ditto)

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/netfilter.c |    7 ++++---
 net/ipv6/netfilter.c |    3 +--
 2 files changed, 5 insertions(+), 5 deletions(-)

--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -12,6 +12,7 @@
 /* route_me_harder function, used by iptable_nat, iptable_mangle + ip_queue */
 int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 {
+	struct net *net = dev_net(skb->dst->dev);
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 	struct flowi fl = {};
@@ -19,7 +20,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 	unsigned int hh_len;
 	unsigned int type;
 
-	type = inet_addr_type(&init_net, iph->saddr);
+	type = inet_addr_type(net, iph->saddr);
 	if (addr_type == RTN_UNSPEC)
 		addr_type = type;
 
@@ -33,7 +34,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 		fl.nl_u.ip4_u.tos = RT_TOS(iph->tos);
 		fl.oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
 		fl.mark = skb->mark;
-		if (ip_route_output_key(&init_net, &rt, &fl) != 0)
+		if (ip_route_output_key(net, &rt, &fl) != 0)
 			return -1;
 
 		/* Drop old route. */
@@ -43,7 +44,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 		/* non-local src, find valid iif to satisfy
 		 * rp-filter when calling ip_route_input. */
 		fl.nl_u.ip4_u.daddr = iph->saddr;
-		if (ip_route_output_key(&init_net, &rt, &fl) != 0)
+		if (ip_route_output_key(net, &rt, &fl) != 0)
 			return -1;
 
 		odst = skb->dst;
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -23,7 +23,7 @@ int ip6_route_me_harder(struct sk_buff *skb)
 		    .saddr = iph->saddr, } },
 	};
 
-	dst = ip6_route_output(&init_net, skb->sk, &fl);
+	dst = ip6_route_output(dev_net(skb->dst->dev), skb->sk, &fl);
 
 #ifdef CONFIG_XFRM
 	if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
-- 
1.5.6.3


