From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 6/7][IP6TUNNEL]: Use proper net instead of init_net
 stubs.
Date: Tue, 15 Apr 2008 18:08:24 +0400
Message-ID: <4804B6D8.6010202@openvz.org>
References: <4804B478.3040606@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:51826 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753693AbYDONeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 09:34:04 -0400
In-Reply-To: <4804B478.3040606@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the ip_route_output_key(), dev_get_by_...() and ipv6_chk_addr()
calls are now stubbed with init_net.

Fortunately, all the places already have where to get the proper
net from.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/ip6_tunnel.c |   26 +++++++++++++++-----------
 1 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 7d2aa6e..d9b2721 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -543,7 +543,7 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	fl.fl4_dst = eiph->saddr;
 	fl.fl4_tos = RT_TOS(eiph->tos);
 	fl.proto = IPPROTO_IPIP;
-	if (ip_route_output_key(&init_net, &rt, &fl))
+	if (ip_route_output_key(dev_net(skb->dev), &rt, &fl))
 		goto out;
 
 	skb2->dev = rt->u.dst.dev;
@@ -555,7 +555,7 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		fl.fl4_dst = eiph->daddr;
 		fl.fl4_src = eiph->saddr;
 		fl.fl4_tos = eiph->tos;
-		if (ip_route_output_key(&init_net, &rt, &fl) ||
+		if (ip_route_output_key(dev_net(skb->dev), &rt, &fl) ||
 		    rt->u.dst.dev->type != ARPHRD_TUNNEL) {
 			ip_rt_put(rt);
 			goto out;
@@ -612,7 +612,8 @@ ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		skb_reset_network_header(skb2);
 
 		/* Try to guess incoming interface */
-		rt = rt6_lookup(&init_net, &ipv6_hdr(skb2)->saddr, NULL, 0, 0);
+		rt = rt6_lookup(dev_net(skb->dev), &ipv6_hdr(skb2)->saddr,
+				NULL, 0, 0);
 
 		if (rt && rt->rt6i_dev)
 			skb2->dev = rt->rt6i_dev;
@@ -656,16 +657,17 @@ static inline int ip6_tnl_rcv_ctl(struct ip6_tnl *t)
 {
 	struct ip6_tnl_parm *p = &t->parms;
 	int ret = 0;
+	struct net *net = dev_net(t->dev);
 
 	if (p->flags & IP6_TNL_F_CAP_RCV) {
 		struct net_device *ldev = NULL;
 
 		if (p->link)
-			ldev = dev_get_by_index(&init_net, p->link);
+			ldev = dev_get_by_index(net, p->link);
 
 		if ((ipv6_addr_is_multicast(&p->laddr) ||
-		     likely(ipv6_chk_addr(&init_net, &p->laddr, ldev, 0))) &&
-		    likely(!ipv6_chk_addr(&init_net, &p->raddr, NULL, 0)))
+		     likely(ipv6_chk_addr(net, &p->laddr, ldev, 0))) &&
+		    likely(!ipv6_chk_addr(net, &p->raddr, NULL, 0)))
 			ret = 1;
 
 		if (ldev)
@@ -793,19 +795,20 @@ static inline int ip6_tnl_xmit_ctl(struct ip6_tnl *t)
 {
 	struct ip6_tnl_parm *p = &t->parms;
 	int ret = 0;
+	struct net *net = dev_net(t->dev);
 
 	if (p->flags & IP6_TNL_F_CAP_XMIT) {
 		struct net_device *ldev = NULL;
 
 		if (p->link)
-			ldev = dev_get_by_index(&init_net, p->link);
+			ldev = dev_get_by_index(net, p->link);
 
-		if (unlikely(!ipv6_chk_addr(&init_net, &p->laddr, ldev, 0)))
+		if (unlikely(!ipv6_chk_addr(net, &p->laddr, ldev, 0)))
 			printk(KERN_WARNING
 			       "%s xmit: Local address not yet configured!\n",
 			       p->name);
 		else if (!ipv6_addr_is_multicast(&p->raddr) &&
-			 unlikely(ipv6_chk_addr(&init_net, &p->raddr, NULL, 0)))
+			 unlikely(ipv6_chk_addr(net, &p->raddr, NULL, 0)))
 			printk(KERN_WARNING
 			       "%s xmit: Routing loop! "
 			       "Remote address found on this node!\n",
@@ -858,7 +861,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	if ((dst = ip6_tnl_dst_check(t)) != NULL)
 		dst_hold(dst);
 	else {
-		dst = ip6_route_output(&init_net, NULL, fl);
+		dst = ip6_route_output(dev_net(dev), NULL, fl);
 
 		if (dst->error || xfrm_lookup(&dst, fl, NULL, 0) < 0)
 			goto tx_err_link_failure;
@@ -1123,7 +1126,8 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 		int strict = (ipv6_addr_type(&p->raddr) &
 			      (IPV6_ADDR_MULTICAST|IPV6_ADDR_LINKLOCAL));
 
-		struct rt6_info *rt = rt6_lookup(&init_net, &p->raddr, &p->laddr,
+		struct rt6_info *rt = rt6_lookup(dev_net(dev),
+						 &p->raddr, &p->laddr,
 						 p->link, strict);
 
 		if (rt == NULL)
-- 
1.5.3.4

