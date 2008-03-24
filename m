From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: Re: [PATCH][IPSEC] inter address family IPsec tunnel on the fly
Date: Mon, 24 Mar 2008 16:44:28 +0900
Message-ID: <20080324164428.2c5e9012.kazunori@miyazawa.org>
References: <47D2A6B5.101@miyazawa.org>
	<20080308.141506.193713220.davem@davemloft.net>
	<20080314122314.b877cfab.kazunori@miyazawa.org>
	<20080321.042048.198566667.davem@davemloft.net>
	<20080324161646.5e4ff0eb.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
To: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:59539 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752681AbYCXHob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 03:44:31 -0400
In-Reply-To: <20080324161646.5e4ff0eb.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Mar 2008 16:16:46 +0900
Kazunori MIYAZAWA <kazunori@miyazawa.org> wrote:

> On Fri, 21 Mar 2008 04:20:48 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
> > Date: Fri, 14 Mar 2008 12:23:14 +0900
> > 
> > > I made the patch for that.
> > > 
> > > Signed-off-by Kazunori MIYAZAWA <kazunori@miyazawa.org>
> > 
> > This looks fine.
> > 
> > Because the inner mode is resolved at xfrm creation time, I think the
> > overall cost is small enough that we can avoid the config option.
> > And anyways, if something matters for performance we can fix that.
> > 
> > Could you respin this patch with it removed?
> > 
> 
> Hi David,
> 
> Sorry for my late reply because of weekend :-)
> 
> I removed the ifdef from the patch and I roughly tested
> with compling and doing IPsec for ICMP(v6) on the kernel.
> 

Sorry, the patch has typo. Please use this.

Signed-off-by: Kazunori MIYAZAWA <kazunori@miyazawa.org>


diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 619c53b..4e6f956 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -204,6 +204,7 @@ struct xfrm_state
 	 * transformer. */
 	const struct xfrm_type	*type;
 	struct xfrm_mode	*inner_mode;
+	struct xfrm_mode	*inner_mode_iaf;
 	struct xfrm_mode	*outer_mode;
 
 	/* Security context */
@@ -387,6 +388,27 @@ enum {
 extern int xfrm_register_mode(struct xfrm_mode *mode, int family);
 extern int xfrm_unregister_mode(struct xfrm_mode *mode, int family);
 
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
+static inline struct xfrm_mode *xfrm_ip2inner_mode(struct xfrm_state *x, int ipproto)
+{
+	if ((ipproto == IPPROTO_IPIP && x->props.family == AF_INET) ||
+	    (ipproto == IPPROTO_IPV6 && x->props.family == AF_INET6))
+		return x->inner_mode;
+	else
+		return x->inner_mode_iaf;
+}
+
 struct xfrm_tmpl
 {
 /* id in template is interpreted as:
@@ -1253,6 +1275,7 @@ extern int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi,
 extern int xfrm_input_resume(struct sk_buff *skb, int nexthdr);
 extern int xfrm_output_resume(struct sk_buff *skb, int err);
 extern int xfrm_output(struct sk_buff *skb);
+extern int xfrm_inner_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm4_extract_header(struct sk_buff *skb);
 extern int xfrm4_extract_input(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index 8dee617..584e6d7 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -41,7 +41,7 @@ static int xfrm4_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
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
@@ -56,7 +56,7 @@ int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
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
@@ -45,7 +45,7 @@ static int xfrm6_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 
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
@@ -62,7 +62,7 @@ int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
 
-	err = x->inner_mode->afinfo->extract_output(x, skb);
+	err = xfrm_inner_extract_output(x, skb);
 	if (err)
 		return err;
 
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 8b5f486..e9ef9af 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1219,7 +1219,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct sadb_msg *hdr,
 		x->sel.prefixlen_s = addr->sadb_address_prefixlen;
 	}
 
-	if (!x->sel.family)
+	if (x->props.mode == XFRM_MODE_TRANSPORT)
 		x->sel.family = x->props.family;
 
 	if (ext_hdrs[SADB_X_EXT_NAT_T_TYPE-1]) {
diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 62188c6..7527940 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -84,14 +84,21 @@ int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq)
 
 int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb)
 {
+	struct xfrm_mode *inner_mode = x->inner_mode;
 	int err;
 
 	err = x->outer_mode->afinfo->extract_input(x, skb);
 	if (err)
 		return err;
 
-	skb->protocol = x->inner_mode->afinfo->eth_proto;
-	return x->inner_mode->input2(x, skb);
+	if (x->sel.family == AF_UNSPEC) {
+		inner_mode = xfrm_ip2inner_mode(x, XFRM_MODE_SKB_CB(skb)->protocol);
+		if (inner_mode == NULL)
+			return -EAFNOSUPPORT;
+	}
+
+	skb->protocol = inner_mode->afinfo->eth_proto;
+	return inner_mode->input2(x, skb);
 }
 EXPORT_SYMBOL(xfrm_prepare_input);
 
@@ -101,6 +108,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	__be32 seq;
 	struct xfrm_state *x;
 	xfrm_address_t *daddr;
+	struct xfrm_mode *inner_mode;
 	unsigned int family;
 	int decaps = 0;
 	int async = 0;
@@ -207,7 +215,15 @@ resume:
 
 		XFRM_MODE_SKB_CB(skb)->protocol = nexthdr;
 
-		if (x->inner_mode->input(x, skb)) {
+		inner_mode = x->inner_mode;
+
+		if (x->sel.family == AF_UNSPEC) {
+			inner_mode = xfrm_ip2inner_mode(x, XFRM_MODE_SKB_CB(skb)->protocol);
+			if (inner_mode == NULL)
+				goto drop;
+		}
+
+		if (inner_mode->input(x, skb)) {
 			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEMODEERROR);
 			goto drop;
 		}
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 569d377..2519129 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -124,7 +124,7 @@ int xfrm_output_resume(struct sk_buff *skb, int err)
 		if (!x)
 			return dst_output(skb);
 
-		err = nf_hook(x->inner_mode->afinfo->family,
+		err = nf_hook(skb->dst->ops->family,
 			      NF_INET_POST_ROUTING, skb,
 			      NULL, skb->dst->dev, xfrm_output2);
 		if (unlikely(err != 1))
@@ -193,4 +193,20 @@ int xfrm_output(struct sk_buff *skb)
 
 	return xfrm_output2(skb);
 }
+
+int xfrm_inner_extract_output(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct xfrm_mode *inner_mode;
+	if (x->sel.family == AF_UNSPEC)
+		inner_mode = xfrm_ip2inner_mode(x,
+				xfrm_af2proto(skb->dst->ops->family));
+	else
+		inner_mode = x->inner_mode;
+
+	if (inner_mode == NULL)
+		return -EAFNOSUPPORT;
+	return inner_mode->afinfo->extract_output(x, skb);
+}
+
 EXPORT_SYMBOL_GPL(xfrm_output);
+EXPORT_SYMBOL_GPL(xfrm_inner_extract_output);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 7ba65e8..d4ca77a 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -388,6 +388,8 @@ static void xfrm_state_gc_destroy(struct xfrm_state *x)
 	kfree(x->coaddr);
 	if (x->inner_mode)
 		xfrm_put_mode(x->inner_mode);
+	if (x->inner_mode_iaf)
+		xfrm_put_mode(x->inner_mode_iaf);
 	if (x->outer_mode)
 		xfrm_put_mode(x->outer_mode);
 	if (x->type) {
@@ -523,6 +525,8 @@ struct xfrm_state *xfrm_state_alloc(void)
 		x->lft.hard_packet_limit = XFRM_INF;
 		x->replay_maxage = 0;
 		x->replay_maxdiff = 0;
+		x->inner_mode = NULL;
+		x->inner_mode_iaf = NULL;
 		spin_lock_init(&x->lock);
 	}
 	return x;
@@ -796,7 +800,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 			      selector.
 			 */
 			if (x->km.state == XFRM_STATE_VALID) {
-				if (!xfrm_selector_match(&x->sel, fl, x->sel.family) ||
+				if ((x->sel.family && !xfrm_selector_match(&x->sel, fl, x->sel.family)) ||
 				    !security_xfrm_state_pol_flow_match(x, pol, fl))
 					continue;
 				if (!best ||
@@ -1944,6 +1948,7 @@ int xfrm_state_mtu(struct xfrm_state *x, int mtu)
 int xfrm_init_state(struct xfrm_state *x)
 {
 	struct xfrm_state_afinfo *afinfo;
+	struct xfrm_mode *inner_mode;
 	int family = x->props.family;
 	int err;
 
@@ -1962,13 +1967,48 @@ int xfrm_init_state(struct xfrm_state *x)
 		goto error;
 
 	err = -EPROTONOSUPPORT;
-	x->inner_mode = xfrm_get_mode(x->props.mode, x->sel.family);
-	if (x->inner_mode == NULL)
-		goto error;
 
-	if (!(x->inner_mode->flags & XFRM_MODE_FLAG_TUNNEL) &&
-	    family != x->sel.family)
-		goto error;
+	if (x->sel.family != AF_UNSPEC) {
+		inner_mode = xfrm_get_mode(x->props.mode, x->sel.family);
+		if (inner_mode == NULL)
+			goto error;
+
+		if (!(inner_mode->flags & XFRM_MODE_FLAG_TUNNEL) &&
+		    family != x->sel.family) {
+			xfrm_put_mode(inner_mode);
+			goto error;
+		}
+
+		x->inner_mode = inner_mode;
+	} else {
+		struct xfrm_mode *inner_mode_iaf;
+
+		inner_mode = xfrm_get_mode(x->props.mode, AF_INET);
+		if (inner_mode == NULL)
+			goto error;
+
+		if (!(inner_mode->flags & XFRM_MODE_FLAG_TUNNEL)) {
+			xfrm_put_mode(inner_mode);
+			goto error;
+		}
+
+		inner_mode_iaf = xfrm_get_mode(x->props.mode, AF_INET6);
+		if (inner_mode_iaf == NULL)
+			goto error;
+
+ 		if (!(inner_mode_iaf->flags & XFRM_MODE_FLAG_TUNNEL)) {
+			xfrm_put_mode(inner_mode_iaf);
+			goto error;
+		}
+
+		if (x->props.family == AF_INET) {
+			x->inner_mode = inner_mode;
+			x->inner_mode_iaf = inner_mode_iaf;	
+		} else {
+			x->inner_mode = inner_mode_iaf;
+			x->inner_mode_iaf = inner_mode;
+		}
+	}
 
 	x->type = xfrm_get_type(x->id.proto, family);
 	if (x->type == NULL)
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index f971ca5..5d96f27 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -288,12 +288,9 @@ static void copy_from_user_state(struct xfrm_state *x, struct xfrm_usersa_info *
 	memcpy(&x->props.saddr, &p->saddr, sizeof(x->props.saddr));
 	x->props.flags = p->flags;
 
-	/*
-	 * Set inner address family if the KM left it as zero.
-	 * See comment in validate_tmpl.
-	 */
-	if (!x->sel.family)
+	if (x->props.mode == XFRM_MODE_TRANSPORT)
 		x->sel.family = p->family;
+
 }
 
 /*
