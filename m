From: greearb@candelatech.com
Subject: [PATCH v3 1/2] ipv6:  Add more debugging around accept-ra logic.
Date: Wed, 25 Jun 2014 14:44:52 -0700
Message-ID: <1403732693-18282-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:34057 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756529AbaFYVpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 17:45:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This is disabled by default, just like similar debug info
already in this module.  But, makes it easier to find out
why RA is not being accepted when debugging strange behaviour.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---

No changes since -v1, patch is against 3.14.8+

 net/ipv6/ndisc.c | 51 +++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 43 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 09a22f4..2fef3d5 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1073,6 +1073,9 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	optlen = (skb_tail_pointer(skb) - skb_transport_header(skb)) -
 		sizeof(struct ra_msg);
 
+	ND_PRINTK(2, info,
+		  "RA: %s, dev: %s\n",
+		  __func__, skb->dev->name);
 	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL)) {
 		ND_PRINTK(2, warn, "RA: source address is not link-local\n");
 		return;
@@ -1105,13 +1108,21 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		return;
 	}
 
-	if (!ipv6_accept_ra(in6_dev))
+	if (!ipv6_accept_ra(in6_dev)) {
+		ND_PRINTK(2, info,
+			  "RA: %s, did not accept ra for dev: %s\n",
+			  __func__, skb->dev->name);
 		goto skip_linkparms;
+	}
 
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	/* skip link-specific parameters from interior routers */
-	if (skb->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT)
+	if (skb->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT) {
+		ND_PRINTK(2, info,
+			  "RA: %s, nodetype is NODEFAULT, dev: %s\n",
+			  __func__, skb->dev->name);
 		goto skip_linkparms;
+	}
 #endif
 
 	if (in6_dev->if_flags & IF_RS_SENT) {
@@ -1133,11 +1144,20 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 				(ra_msg->icmph.icmp6_addrconf_other ?
 					IF_RA_OTHERCONF : 0);
 
-	if (!in6_dev->cnf.accept_ra_defrtr)
+	if (!in6_dev->cnf.accept_ra_defrtr) {
+		ND_PRINTK(2, info,
+			  "RA: %s, defrtr is false for dev: %s\n",
+			  __func__, skb->dev->name);
 		goto skip_defrtr;
+	}
 
-	if (ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr, NULL, 0))
+	if (ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
+			  NULL, 0)) {
+		ND_PRINTK(2, info,
+			  "RA: %s, chk_addr failed for dev: %s\n",
+			  __func__, skb->dev->name);
 		goto skip_defrtr;
+	}
 
 	lifetime = ntohs(ra_msg->icmph.icmp6_rt_lifetime);
 
@@ -1166,8 +1186,10 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		rt = NULL;
 	}
 
+	ND_PRINTK(3, info, "RA: rt: %p  lifetime: %d, for dev: %s\n",
+		  rt, lifetime, skb->dev->name);
 	if (rt == NULL && lifetime) {
-		ND_PRINTK(3, dbg, "RA: adding default router\n");
+		ND_PRINTK(3, info, "RA: adding default router\n");
 
 		rt = rt6_add_dflt_router(&ipv6_hdr(skb)->saddr, skb->dev, pref);
 		if (rt == NULL) {
@@ -1263,12 +1285,21 @@ skip_linkparms:
 			     NEIGH_UPDATE_F_ISROUTER);
 	}
 
-	if (!ipv6_accept_ra(in6_dev))
+	if (!ipv6_accept_ra(in6_dev)) {
+		ND_PRINTK(2, info,
+			  "RA: %s, accept_ra is false for dev: %s\n",
+			  __func__, skb->dev->name);
 		goto out;
+	}
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
-	if (ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr, NULL, 0))
+	if (ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
+			  NULL, 0)) {
+		ND_PRINTK(2, info,
+			  "RA: %s, chk-addr (route info) is false for dev: %s\n",
+			  __func__, skb->dev->name);
 		goto skip_routeinfo;
+	}
 
 	if (in6_dev->cnf.accept_ra_rtr_pref && ndopts.nd_opts_ri) {
 		struct nd_opt_hdr *p;
@@ -1296,8 +1327,12 @@ skip_routeinfo:
 
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	/* skip link-specific ndopts from interior routers */
-	if (skb->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT)
+	if (skb->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT) {
+		ND_PRINTK(2, info,
+			  "RA: %s, nodetype is NODEFAULT (interior routes), dev: %s\n",
+			  __func__, skb->dev->name);
 		goto out;
+	}
 #endif
 
 	if (in6_dev->cnf.accept_ra_pinfo && ndopts.nd_opts_pi) {
-- 
1.7.11.7
