From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] xfrm: Assign the inner mode output function to the dst
 entry
Date: Tue, 10 May 2011 07:36:38 +0200
Message-ID: <20110510053638.GB8013@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57225 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751546Ab1EJFfM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2011 01:35:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As it is, we assign the outer modes output function to the dst entry
when we create the xfrm bundle. This leads to two problems on interfamily
scenarios. We might insert ipv4 packets into ip6_fragment when called
from xfrm6_output. The system crashes if we try to fragment an ipv4
packet with ip6_fragment. This issue was introduced with git commit
ad0081e4 (ipv6: Fragment locally generated tunnel-mode IPSec6 packets
as needed). The second issue is, that we might insert ipv4 packets in
netfilter6 and vice versa on interfamily scenarios.

With this patch we assign the inner mode output function to the dst entry
when we create the xfrm bundle. So xfrm4_output/xfrm6_output from the inner
mode is used and the right fragmentation and netfilter functions are called.
We switch then to outer mode with the output_finish functions.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h      |    3 +++
 net/ipv4/xfrm4_output.c |    8 ++++++--
 net/ipv4/xfrm4_state.c  |    1 +
 net/ipv6/xfrm6_output.c |    6 +++---
 net/ipv6/xfrm6_state.c  |    1 +
 net/xfrm/xfrm_policy.c  |   14 +++++++++++++-
 6 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 6ae4bc5..20afeaa 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -324,6 +324,7 @@ struct xfrm_state_afinfo {
 	int			(*tmpl_sort)(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n);
 	int			(*state_sort)(struct xfrm_state **dst, struct xfrm_state **src, int n);
 	int			(*output)(struct sk_buff *skb);
+	int			(*output_finish)(struct sk_buff *skb);
 	int			(*extract_input)(struct xfrm_state *x,
 						 struct sk_buff *skb);
 	int			(*extract_output)(struct xfrm_state *x,
@@ -1454,6 +1455,7 @@ static inline int xfrm4_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 extern int xfrm4_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm4_output(struct sk_buff *skb);
+extern int xfrm4_output_finish(struct sk_buff *skb);
 extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family);
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
 extern int xfrm6_extract_header(struct sk_buff *skb);
@@ -1470,6 +1472,7 @@ extern __be32 xfrm6_tunnel_spi_lookup(struct net *net, xfrm_address_t *saddr);
 extern int xfrm6_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm6_output(struct sk_buff *skb);
+extern int xfrm6_output_finish(struct sk_buff *skb);
 extern int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
 				 u8 **prevhdr);
 
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 571aa96..2d51840 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -69,7 +69,7 @@ int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(xfrm4_prepare_output);
 
-static int xfrm4_output_finish(struct sk_buff *skb)
+int xfrm4_output_finish(struct sk_buff *skb)
 {
 #ifdef CONFIG_NETFILTER
 	if (!skb_dst(skb)->xfrm) {
@@ -86,7 +86,11 @@ static int xfrm4_output_finish(struct sk_buff *skb)
 
 int xfrm4_output(struct sk_buff *skb)
 {
+	struct dst_entry *dst = skb_dst(skb);
+	struct xfrm_state *x = dst->xfrm;
+
 	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, skb,
-			    NULL, skb_dst(skb)->dev, xfrm4_output_finish,
+			    NULL, dst->dev,
+			    x->outer_mode->afinfo->output_finish,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 1717c64..805d63e 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -78,6 +78,7 @@ static struct xfrm_state_afinfo xfrm4_state_afinfo = {
 	.init_tempsel		= __xfrm4_init_tempsel,
 	.init_temprop		= xfrm4_init_temprop,
 	.output			= xfrm4_output,
+	.output_finish		= xfrm4_output_finish,
 	.extract_input		= xfrm4_extract_input,
 	.extract_output		= xfrm4_extract_output,
 	.transport_finish	= xfrm4_transport_finish,
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 8e688b3..49a91c5 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -79,7 +79,7 @@ int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(xfrm6_prepare_output);
 
-static int xfrm6_output_finish(struct sk_buff *skb)
+int xfrm6_output_finish(struct sk_buff *skb)
 {
 #ifdef CONFIG_NETFILTER
 	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
@@ -97,9 +97,9 @@ static int __xfrm6_output(struct sk_buff *skb)
 	if ((x && x->props.mode == XFRM_MODE_TUNNEL) &&
 	    ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
 		dst_allfrag(skb_dst(skb)))) {
-			return ip6_fragment(skb, xfrm6_output_finish);
+			return ip6_fragment(skb, x->outer_mode->afinfo->output_finish);
 	}
-	return xfrm6_output_finish(skb);
+	return x->outer_mode->afinfo->output_finish(skb);
 }
 
 int xfrm6_output(struct sk_buff *skb)
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index afe941e..248f0b2 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -178,6 +178,7 @@ static struct xfrm_state_afinfo xfrm6_state_afinfo = {
 	.tmpl_sort		= __xfrm6_tmpl_sort,
 	.state_sort		= __xfrm6_state_sort,
 	.output			= xfrm6_output,
+	.output_finish		= xfrm6_output_finish,
 	.extract_input		= xfrm6_extract_input,
 	.extract_output		= xfrm6_extract_output,
 	.transport_finish	= xfrm6_transport_finish,
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 15792d8..b4d745e 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1406,6 +1406,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 	struct net *net = xp_net(policy);
 	unsigned long now = jiffies;
 	struct net_device *dev;
+	struct xfrm_mode *inner_mode;
 	struct dst_entry *dst_prev = NULL;
 	struct dst_entry *dst0 = NULL;
 	int i = 0;
@@ -1436,6 +1437,17 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 			goto put_states;
 		}
 
+		if (xfrm[i]->sel.family == AF_UNSPEC) {
+			inner_mode = xfrm_ip2inner_mode(xfrm[i],
+							xfrm_af2proto(family));
+			if (!inner_mode) {
+				err = -EAFNOSUPPORT;
+				dst_release(dst);
+				goto put_states;
+			}
+		} else
+			inner_mode = xfrm[i]->inner_mode;
+
 		if (!dst_prev)
 			dst0 = dst1;
 		else {
@@ -1464,7 +1476,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		dst1->lastuse = now;
 
 		dst1->input = dst_discard;
-		dst1->output = xfrm[i]->outer_mode->afinfo->output;
+		dst1->output = inner_mode->afinfo->output;
 
 		dst1->next = dst_prev;
 		dst_prev = dst1;
-- 
1.7.0.4

