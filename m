From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] ipv6: Store ndisc_nodeid in IP6CB().
Date: Wed, 19 May 2010 19:55:36 -0700 (PDT)
Message-ID: <20100519.195536.32704411.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@redhat.com, nhorman@tuxdriver.com, nhorman@redhat.com,
	eric.dumazet@gmail.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: bmb@athenacr.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57248
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752497Ab0ETCz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 22:55:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There is no reason we need to use up space in the generic
SKB area for this.  All packet input paths in ipv6 explicitly
clear out the IP6CB() area and therefore the default value
for ndisc_nodeid will be correct.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/ipv6.h   |    2 +-
 include/linux/skbuff.h |    9 ++-------
 net/ipv6/ndisc.c       |   11 ++++++-----
 net/ipv6/sit.c         |    9 ++++++---
 4 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index e0cc9a7..fc39add 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -247,7 +247,7 @@ struct inet6_skb_parm {
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 	__u16			dsthao;
 #endif
-
+	__u8			ndisc_nodetype;
 #define IP6SKB_XFRM_TRANSFORMED	1
 #define IP6SKB_FORWARDED	2
 };
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 124f90c..7c16f24 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -369,14 +369,9 @@ struct sk_buff {
 #endif
 #endif
 
-	kmemcheck_bitfield_begin(flags2);
-	__u16			queue_mapping:16;
-#ifdef CONFIG_IPV6_NDISC_NODETYPE
-	__u8			ndisc_nodetype:2;
-#endif
-	kmemcheck_bitfield_end(flags2);
+	__u16			queue_mapping;
 
-	/* 0/14 bit hole */
+	/* 16 bit hole */
 
 #ifdef CONFIG_NET_DMA
 	dma_cookie_t		dma_cookie;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index da0a4d2..e7c0897 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1134,7 +1134,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	}
 
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
-	if (skb->ndisc_nodetype == NDISC_NODETYPE_HOST) {
+	if (IP6CB(skb)->ndisc_nodetype == NDISC_NODETYPE_HOST) {
 		ND_PRINTK2(KERN_WARNING
 			   "ICMPv6 RA: from host or unauthorized router\n");
 		return;
@@ -1166,7 +1166,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	/* skip link-specific parameters from interior routers */
-	if (skb->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT)
+	if (IP6CB(skb)->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT)
 		goto skip_linkparms;
 #endif
 
@@ -1323,7 +1323,8 @@ skip_linkparms:
 		     p = ndisc_next_option(p, ndopts.nd_opts_ri_end)) {
 			struct route_info *ri = (struct route_info *)p;
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
-			if (skb->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT &&
+			if (IP6CB(skb)->ndisc_nodetype ==
+			    NDISC_NODETYPE_NODEFAULT &&
 			    ri->prefix_len == 0)
 				continue;
 #endif
@@ -1337,7 +1338,7 @@ skip_linkparms:
 
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	/* skip link-specific ndopts from interior routers */
-	if (skb->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT)
+	if (IP6CB(skb)->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT)
 		goto out;
 #endif
 
@@ -1405,7 +1406,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 	u8 *lladdr = NULL;
 
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
-	switch (skb->ndisc_nodetype) {
+	switch (IP6CB(skb)->ndisc_nodetype) {
 	case NDISC_NODETYPE_HOST:
 	case NDISC_NODETYPE_NODEFAULT:
 		ND_PRINTK2(KERN_WARNING
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 5abae10..ac014e0 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -427,21 +427,24 @@ static int
 isatap_chksrc(struct sk_buff *skb, struct iphdr *iph, struct ip_tunnel *t)
 {
 	struct ip_tunnel_prl_entry *p;
+	struct inet6_skb_parm *cb;
 	int ok = 1;
 
+	cb = IP6CB(skb);
+
 	rcu_read_lock();
 	p = __ipip6_tunnel_locate_prl(t, iph->saddr);
 	if (p) {
 		if (p->flags & PRL_DEFAULT)
-			skb->ndisc_nodetype = NDISC_NODETYPE_DEFAULT;
+			cb->ndisc_nodetype = NDISC_NODETYPE_DEFAULT;
 		else
-			skb->ndisc_nodetype = NDISC_NODETYPE_NODEFAULT;
+			cb->ndisc_nodetype = NDISC_NODETYPE_NODEFAULT;
 	} else {
 		struct in6_addr *addr6 = &ipv6_hdr(skb)->saddr;
 		if (ipv6_addr_is_isatap(addr6) &&
 		    (addr6->s6_addr32[3] == iph->saddr) &&
 		    ipv6_chk_prefix(addr6, t->dev))
-			skb->ndisc_nodetype = NDISC_NODETYPE_HOST;
+			cb->ndisc_nodetype = NDISC_NODETYPE_HOST;
 		else
 			ok = 0;
 	}
-- 
1.7.0.4

