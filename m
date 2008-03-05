From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC] inter address family IPsec tunnel on the fly
Date: Wed, 5 Mar 2008 21:37:27 +0900
Message-ID: <20080305213727.35f46f2f.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:42219 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757753AbYCEMhf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 07:37:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

This patch fix inter address family ipsec tunneling
when we install IPsec SA via PF_KEY interface
because there are no interface to set the selector.

This patch is for net-2.6

Signed-off-by: Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Best regards,

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index eea7785..6a52805 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -386,6 +386,48 @@ enum {
 
 extern int xfrm_register_mode(struct xfrm_mode *mode, int family);
 extern int xfrm_unregister_mode(struct xfrm_mode *mode, int family);
+extern struct xfrm_mode *xfrm_get_mode(unsigned int encap, int family);
+extern void xfrm_put_mode(struct xfrm_mode *mode);
+
+static inline int xfrm_proto2af(int proto)
+{
+	switch (proto) {
+	case IPPROTO_IPIP:
+		return AF_INET;
+	case IPPROTO_IPV6:
+		return AF_INET6;
+	default:
+		return AF_UNSPEC;
+	}
+}
+
+static inline int xfrm_af2proto(unsigned int family)
+{
+	switch(family) {
+	case AF_INET:
+		return IPPROTO_IPIP;
+	case AF_INET6:
+		return IPPROTO_IPV6;
+	default:
+		return 0;
+	}
+}
+
+static inline struct xfrm_mode *xfrm_get_inner_mode(struct xfrm_state *x, int family)
+{
+	if (x->inner_mode)
+		return x->inner_mode;
+	else
+		return xfrm_get_mode(x->props.mode, family);
+}
+
+static inline void xfrm_put_inner_mode(struct xfrm_state *x, struct xfrm_mode *mode)
+{
+	if (x->inner_mode != NULL)
+		xfrm_put_mode(mode);
+}
+
+extern int xfrm_inner_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 
 struct xfrm_tmpl
 {
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index 8dee617..584e6d7 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -41,7 +41,7 @@ static int xfrm4_mode_tunnel_output(stru
 	top_iph->ihl = 5;
 	top_iph->version = 4;
 
-	top_iph->protocol = x->inner_mode->afinfo->proto;
+	top_iph->protocol = xfrm_af2proto(skb->dst->ops->family);
 
 	/* DS disclosed */
 	top_iph->tos = INET_ECN_encapsulate(XFRM_MODE_SKB_CB(skb)->tos,
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index d5a58a8..8c3180a 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -56,7 +56,7 @@ int xfrm4_prepare_output(struct xfrm_sta
 {
 	int err;
 
-	err = x->inner_mode->afinfo->extract_output(x, skb);
+	err = xfrm_inner_extract_output(x, skb);
 	if (err)
 		return err;
 
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 0c742fa..e20529b 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -45,7 +45,7 @@ static int xfrm6_mode_tunnel_output(stru
 
 	memcpy(top_iph->flow_lbl, XFRM_MODE_SKB_CB(skb)->flow_lbl,
 	       sizeof(top_iph->flow_lbl));
-	top_iph->nexthdr = x->inner_mode->afinfo->proto;
+	top_iph->nexthdr = xfrm_af2proto(skb->dst->ops->family);
 
 	dsfield = XFRM_MODE_SKB_CB(skb)->tos;
 	dsfield = INET_ECN_encapsulate(dsfield, dsfield);
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 79ccfb0..0af823c 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -62,7 +62,7 @@ int xfrm6_prepare_output(struct xfrm_sta
 {
 	int err;
 
-	err = x->inner_mode->afinfo->extract_output(x, skb);
+	err = xfrm_inner_extract_output(x, skb);
 	if (err)
 		return err;
 
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 8b5f486..7c175e1 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1219,9 +1219,6 @@ static struct xfrm_state * pfkey_msg2xfr
 		x->sel.prefixlen_s = addr->sadb_address_prefixlen;
 	}
 
-	if (!x->sel.family)
-		x->sel.family = x->props.family;
-
 	if (ext_hdrs[SADB_X_EXT_NAT_T_TYPE-1]) {
 		struct sadb_x_nat_t_type* n_type;
 		struct xfrm_encap_tmpl *natt;
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 62188c6..c81455f 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -82,6 +82,35 @@ int xfrm_parse_spi(struct sk_buff *skb, 
 	return 0;
 }
 
+static inline int xfrm_inner_input(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct xfrm_mode *inner_mode;
+	int err;
+
+	inner_mode = xfrm_get_inner_mode(x, xfrm_proto2af(XFRM_MODE_SKB_CB(skb)->protocol));
+	if (!inner_mode)
+		return -EINVAL;
+	err = inner_mode->input(x, skb);
+	xfrm_put_inner_mode(x, inner_mode);
+
+	return err;
+}
+
+static inline int xfrm_inner_input2(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct xfrm_mode *inner_mode;
+	int err;
+
+	inner_mode = xfrm_get_inner_mode(x, xfrm_proto2af(XFRM_MODE_SKB_CB(skb)->protocol));
+	if (!inner_mode)
+		return -EINVAL;
+	err = inner_mode->input2(x, skb);
+	if (err >= 0)
+		err = inner_mode->afinfo->eth_proto;
+	xfrm_put_inner_mode(x, inner_mode);
+	return err;
+}
+
 int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
@@ -90,8 +119,10 @@ int xfrm_prepare_input(struct xfrm_state
 	if (err)
 		return err;
 
-	skb->protocol = x->inner_mode->afinfo->eth_proto;
-	return x->inner_mode->input2(x, skb);
+	err = xfrm_inner_input2(x, skb);
+	if (err >= 0)
+		skb->protocol = err;
+	return 0;
 }
 EXPORT_SYMBOL(xfrm_prepare_input);
 
@@ -207,7 +238,8 @@ resume:
 
 		XFRM_MODE_SKB_CB(skb)->protocol = nexthdr;
 
-		if (x->inner_mode->input(x, skb)) {
+		err = xfrm_inner_input(x, skb);
+		if (err) {
 			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEMODEERROR);
 			goto drop;
 		}
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 569d377..711873e 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -18,6 +18,21 @@ #include <linux/spinlock.h>
 #include <net/dst.h>
 #include <net/xfrm.h>
 
+int xfrm_inner_extract_output(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct xfrm_mode *inner_mode;
+	int err;
+
+	inner_mode = xfrm_get_inner_mode(x, skb->dst->ops->family);
+	if (!inner_mode)
+		return -EINVAL;
+	err = inner_mode->afinfo->extract_output(x, skb);
+	xfrm_put_inner_mode(x, inner_mode);
+
+	return err;
+}
+EXPORT_SYMBOL(xfrm_inner_extract_output);
+
 static int xfrm_output2(struct sk_buff *skb);
 
 static int xfrm_state_check_space(struct xfrm_state *x, struct sk_buff *skb)
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 7ba65e8..88894b1 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -344,7 +344,7 @@ int xfrm_unregister_mode(struct xfrm_mod
 }
 EXPORT_SYMBOL(xfrm_unregister_mode);
 
-static struct xfrm_mode *xfrm_get_mode(unsigned int encap, int family)
+struct xfrm_mode *xfrm_get_mode(unsigned int encap, int family)
 {
 	struct xfrm_state_afinfo *afinfo;
 	struct xfrm_mode *mode;
@@ -372,7 +372,7 @@ retry:
 	return mode;
 }
 
-static void xfrm_put_mode(struct xfrm_mode *mode)
+void xfrm_put_mode(struct xfrm_mode *mode)
 {
 	module_put(mode->owner);
 }
@@ -796,7 +796,7 @@ xfrm_state_find(xfrm_address_t *daddr, x
 			      selector.
 			 */
 			if (x->km.state == XFRM_STATE_VALID) {
-				if (!xfrm_selector_match(&x->sel, fl, x->sel.family) ||
+				if ((x->sel.family && !xfrm_selector_match(&x->sel, fl, x->sel.family)) ||
 				    !security_xfrm_state_pol_flow_match(x, pol, fl))
 					continue;
 				if (!best ||
@@ -1962,13 +1962,15 @@ int xfrm_init_state(struct xfrm_state *x
 		goto error;
 
 	err = -EPROTONOSUPPORT;
-	x->inner_mode = xfrm_get_mode(x->props.mode, x->sel.family);
-	if (x->inner_mode == NULL)
-		goto error;
+	if (x->sel.family != 0) {
+		x->inner_mode = xfrm_get_mode(x->props.mode, x->sel.family);
+		if (x->inner_mode == NULL)
+			goto error;
 
-	if (!(x->inner_mode->flags & XFRM_MODE_FLAG_TUNNEL) &&
-	    family != x->sel.family)
-		goto error;
+		if (!(x->inner_mode->flags & XFRM_MODE_FLAG_TUNNEL) &&
+		    family != x->sel.family)
+			goto error;
+	}
 
 	x->type = xfrm_get_type(x->id.proto, family);
 	if (x->type == NULL)
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index f971ca5..6499a84 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -287,13 +287,6 @@ static void copy_from_user_state(struct 
 	x->props.family = p->family;
 	memcpy(&x->props.saddr, &p->saddr, sizeof(x->props.saddr));
 	x->props.flags = p->flags;
-
-	/*
-	 * Set inner address family if the KM left it as zero.
-	 * See comment in validate_tmpl.
-	 */
-	if (!x->sel.family)
-		x->sel.family = p->family;
 }
 
 /*
