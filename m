From: adobriyan@gmail.com
Subject: [PATCH 03/38] netns nf: ip6table_mangle in netns for real
Date: Fri, 22 Aug 2008 01:57:39 +0400
Message-ID: <20080821215739.GC31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:8250 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756012AbYHUV4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 17:56:17 -0400
Received: by yw-out-2324.google.com with SMTP id 9so9882ywe.1
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 14:56:16 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv6/netfilter/ip6table_mangle.c |   31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -67,17 +67,29 @@ static struct xt_table packet_mangler = {
 
 /* The work comes in here from netfilter.c. */
 static unsigned int
-ip6t_route_hook(unsigned int hook,
+ip6t_in_hook(unsigned int hook,
 	 struct sk_buff *skb,
 	 const struct net_device *in,
 	 const struct net_device *out,
 	 int (*okfn)(struct sk_buff *))
 {
-	return ip6t_do_table(skb, hook, in, out, init_net.ipv6.ip6table_mangle);
+	return ip6t_do_table(skb, hook, in, out,
+			     dev_net(in)->ipv6.ip6table_mangle);
 }
 
 static unsigned int
-ip6t_local_hook(unsigned int hook,
+ip6t_post_routing_hook(unsigned int hook,
+		struct sk_buff *skb,
+		const struct net_device *in,
+		const struct net_device *out,
+		int (*okfn)(struct sk_buff *))
+{
+	return ip6t_do_table(skb, hook, in, out,
+			     dev_net(out)->ipv6.ip6table_mangle);
+}
+
+static unsigned int
+ip6t_local_out_hook(unsigned int hook,
 		   struct sk_buff *skb,
 		   const struct net_device *in,
 		   const struct net_device *out,
@@ -108,7 +120,7 @@ ip6t_local_hook(unsigned int hook,
 	/* flowlabel and prio (includes version, which shouldn't change either */
 	flowlabel = *((u_int32_t *)ipv6_hdr(skb));
 
-	ret = ip6t_do_table(skb, hook, in, out, init_net.ipv6.ip6table_mangle);
+	ret = ip6t_do_table(skb, hook, in, out, dev_net(out)->ipv6.ip6table_mangle);
 
 	if (ret != NF_DROP && ret != NF_STOLEN
 		&& (memcmp(&ipv6_hdr(skb)->saddr, &saddr, sizeof(saddr))
@@ -122,35 +134,35 @@ ip6t_local_hook(unsigned int hook,
 
 static struct nf_hook_ops ip6t_ops[] __read_mostly = {
 	{
-		.hook		= ip6t_route_hook,
+		.hook		= ip6t_in_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
-		.hook		= ip6t_route_hook,
+		.hook		= ip6t_in_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
-		.hook		= ip6t_route_hook,
+		.hook		= ip6t_in_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
-		.hook		= ip6t_local_hook,
+		.hook		= ip6t_local_out_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
-		.hook		= ip6t_route_hook,
+		.hook		= ip6t_post_routing_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_POST_ROUTING,
-- 
1.5.6.3


