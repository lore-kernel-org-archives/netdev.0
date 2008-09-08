From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 04/33] Fix {ip,6}_route_me_harder() in netns
Date: Mon,  8 Sep 2008 07:02:41 +0400
Message-ID: <1220842990-30500-4-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.185]:64313 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbYIHDBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2008 23:01:35 -0400
Received: by gv-out-0910.google.com with SMTP id e6so91841gvc.37
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2008 20:01:34 -0700 (PDT)
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take netns from skb->dst->dev. It should be safe because, they are called
from LOCAL_OUT hook where dst is valid (though, I'm not exactly sure about
IPVS and queueing packets to userspace).

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index f8edacd..9c54024 100644
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
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 8c6c5e7..4cb4844 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -23,7 +23,7 @@ int ip6_route_me_harder(struct sk_buff *skb)
 		    .saddr = iph->saddr, } },
 	};
 
-	dst = ip6_route_output(&init_net, skb->sk, &fl);
+	dst = ip6_route_output(dev_net(skb->dst->dev), skb->sk, &fl);
 
 #ifdef CONFIG_XFRM
 	if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
