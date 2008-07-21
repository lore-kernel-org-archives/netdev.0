From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 03/31] ip6tables mangle in netns for real
Date: Mon, 21 Jul 2008 20:32:35 +0400
Message-ID: <20080721163235.GG13264@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, den@openvz.org, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, benjamin.thery@bull.net
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PRE_ROUTING, INPUT, FORWARD -- grab netns from in device,
OUTPUT, POST_ROUTING -- from out device.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv6/netfilter/ip6table_mangle.c |   30 +++++++++++++++++++++---------
 1 file changed, 21 insertions(+), 9 deletions(-)

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
1.5.4.5


