From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 10/25] netns ct: fix ip_route_me_harder() for REEJCT, NAT
	et al
Date: Sun, 22 Jun 2008 05:09:20 +0400
Message-ID: <20080622010920.GK5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ip_route_me_harder() is called on output codepaths:
1) IPVS: honestly, not sure, it can be called during forwarding
2) IPv4 REJECT: refreshing comment re skb->dst is valid
	and assigment of skb->dst right before call :^)
3) NAT: called in LOCAL_OUT hook
4) iptable_mangle: LOCAL_OUT hook
5) nf_ip_reroute(): LOCAL_OUT hook (no clue about queueing packets to luserspace)

P.S.: IPv6 version is also called by mangling code on input, what's the story
      behind this discrepancy?

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/netfilter.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

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
-- 
1.5.4.5


