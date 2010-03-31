From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] SPD basic actions per netdev
Date: Wed, 31 Mar 2010 18:58:23 -0400
Message-ID: <1270076303.26743.119.camel@bigi>
References: <1270053478.26743.111.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-WH/RlTQsUm7yuTziXvly"
Cc: Timo Teras <timo.teras@iki.fi>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:51600 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758362Ab0CaW62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 18:58:28 -0400
Received: by qyk9 with SMTP id 9so636267qyk.1
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 15:58:27 -0700 (PDT)
In-Reply-To: <1270053478.26743.111.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-WH/RlTQsUm7yuTziXvly
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


And here's something i just tested on net-next that
fixes this for me.

cheers,
jamal

On Wed, 2010-03-31 at 12:38 -0400, jamal wrote:
> This may be oversight in current implementation and possibly
> nobody has needed it before - hence it is not functional.
> 
> I want to have a drop-all policy on a per-interface level
> for incoming packets and add exceptions as i need them.
> [using the flow table is cheap if you have xfrm built in].
> i.e something along the lines of:
> 
> #eth0, wild-card drop all
> ip xfrm policy add src 0.0.0.0/0 dst 0.0.0.0/0 dev eth0 \
>        dir in ptype main action block priority $SOME-HIGH-value
> #eth0, exception
> ip xfrm policy add blah blah dev eth0 \
> dir in ptype main action allow priority $SOME-small-value
> #eth1, wild-card drop all
> ip xfrm policy add src 0.0.0.0/0 dst 0.0.0.0/0 dev eth1 \
>        dir in ptype main action block priority $SOME-HIGH-value
> #eth1 exception ...
> 
> The problem is this works as long as i dont specify an interface.
> i.e, this would work in the in-direction:
> 
> ip xfrm policy add src 0.0.0.0/0 dst 0.0.0.0/0 \
>         dir in ptype main action block priority $SOME-HIGH-value
> 
> This would not work:
> ip xfrm policy add src 0.0.0.0/0 dst 0.0.0.0/0 dev eth0 \
>        dir in ptype main action block priority $SOME-HIGH-value
> 
> 
> The checks in the selector matching is the culprit, example for v4:
> 
> __xfrm4_selector_match(struct xfrm_selector *sel, struct flowi *fl)
> {
>         return  .... &&
>                 .... &&
>                 (fl->oif == sel->ifindex || !sel->ifindex);
> }
> 
> i.e in the second case i have a non-zero sel->ifindex but
> a zero fl->oif; so it wont match.
> 
> One approach to fix this is to pass the direction then i can do
> in the function call, then i can do something along the lines of
> matching if:
> (fl_dir == FLOW_DIR_IN && (fl->iif == sel->ifindex || !sel->ifindex) ||
> (fl->oif == sel->ifindex || !sel->ifindex);
> 
> Is there any reason the selector matching only assumes fl->oif?
> Are there any unforeseen issues/breakages if i added a check for the
> above.
> 
> cheers,
> jamal

--=-WH/RlTQsUm7yuTziXvly
Content-Disposition: attachment; filename="spd-per-intf"
Content-Type: text/x-patch; name="spd-per-intf"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d74e080..ce18464 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -838,7 +838,7 @@ __be16 xfrm_flowi_dport(struct flowi *fl)
 }
 
 extern int xfrm_selector_match(struct xfrm_selector *sel, struct flowi *fl,
-			       unsigned short family);
+			       unsigned short family, int use_if);
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 /*	If neither has a context --> match
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 843e066..e7e230b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -55,35 +55,37 @@ static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 						int dir);
 
 static inline int
-__xfrm4_selector_match(struct xfrm_selector *sel, struct flowi *fl)
+__xfrm4_selector_match(struct xfrm_selector *sel, struct flowi *fl, int uif)
 {
+	int use_if = uif ? uif : fl->oif;
 	return  addr_match(&fl->fl4_dst, &sel->daddr, sel->prefixlen_d) &&
 		addr_match(&fl->fl4_src, &sel->saddr, sel->prefixlen_s) &&
 		!((xfrm_flowi_dport(fl) ^ sel->dport) & sel->dport_mask) &&
 		!((xfrm_flowi_sport(fl) ^ sel->sport) & sel->sport_mask) &&
 		(fl->proto == sel->proto || !sel->proto) &&
-		(fl->oif == sel->ifindex || !sel->ifindex);
+		(use_if == sel->ifindex || !sel->ifindex);
 }
 
 static inline int
-__xfrm6_selector_match(struct xfrm_selector *sel, struct flowi *fl)
+__xfrm6_selector_match(struct xfrm_selector *sel, struct flowi *fl, int uif)
 {
+	int use_if = uif ? uif : fl->oif;
 	return  addr_match(&fl->fl6_dst, &sel->daddr, sel->prefixlen_d) &&
 		addr_match(&fl->fl6_src, &sel->saddr, sel->prefixlen_s) &&
 		!((xfrm_flowi_dport(fl) ^ sel->dport) & sel->dport_mask) &&
 		!((xfrm_flowi_sport(fl) ^ sel->sport) & sel->sport_mask) &&
 		(fl->proto == sel->proto || !sel->proto) &&
-		(fl->oif == sel->ifindex || !sel->ifindex);
+		(use_if == sel->ifindex || !sel->ifindex);
 }
 
 int xfrm_selector_match(struct xfrm_selector *sel, struct flowi *fl,
-		    unsigned short family)
+		    unsigned short family, int ifindex)
 {
 	switch (family) {
 	case AF_INET:
-		return __xfrm4_selector_match(sel, fl);
+		return __xfrm4_selector_match(sel, fl, ifindex);
 	case AF_INET6:
-		return __xfrm6_selector_match(sel, fl);
+		return __xfrm6_selector_match(sel, fl, ifindex);
 	}
 	return 0;
 }
@@ -917,14 +919,17 @@ static int xfrm_policy_match(struct xfrm_policy *pol, struct flowi *fl,
 			     u8 type, u16 family, int dir)
 {
 	struct xfrm_selector *sel = &pol->selector;
-	int match, ret = -ESRCH;
+	int use_if = fl->oif, match, ret = -ESRCH;
 
 	if (pol->family != family ||
 	    (fl->mark & pol->mark.m) != pol->mark.v ||
 	    pol->type != type)
 		return ret;
 
-	match = xfrm_selector_match(sel, fl, family);
+	if (dir == FLOW_DIR_IN)
+		use_if = fl->iif;
+
+	match = xfrm_selector_match(sel, fl, family, use_if);
 	if (match)
 		ret = security_xfrm_policy_lookup(pol->security, fl->secid,
 						  dir);
@@ -1041,7 +1046,7 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir, struc
 	read_lock_bh(&xfrm_policy_lock);
 	if ((pol = sk->sk_policy[dir]) != NULL) {
 		int match = xfrm_selector_match(&pol->selector, fl,
-						sk->sk_family);
+						sk->sk_family, 0);
 		int err = 0;
 
 		if (match) {
@@ -1918,6 +1923,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	struct flowi fl;
 	u8 fl_dir;
 	int xerr_idx = -1;
+	int use_if = 0;
 
 	reverse = dir & ~XFRM_POLICY_MASK;
 	dir &= XFRM_POLICY_MASK;
@@ -1928,6 +1934,9 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 		return 0;
 	}
 
+	if (fl_dir ==  FLOW_DIR_IN)
+		use_if = fl.iif = skb->skb_iif;
+
 	nf_nat_decode_session(skb, &fl, family);
 
 	/* First, check used SA against their selectors. */
@@ -1936,7 +1945,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 
 		for (i=skb->sp->len-1; i>=0; i--) {
 			struct xfrm_state *x = skb->sp->xvec[i];
-			if (!xfrm_selector_match(&x->sel, &fl, family)) {
+			if (!xfrm_selector_match(&x->sel, &fl, family, use_if)) {
 				XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEMISMATCH);
 				return 0;
 			}
@@ -1956,6 +1965,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 		pol = flow_cache_lookup(net, &fl, family, fl_dir,
 					xfrm_policy_lookup);
 
+
 	if (IS_ERR(pol)) {
 		XFRM_INC_STATS(net, LINUX_MIB_XFRMINPOLERROR);
 		return 0;
@@ -2243,7 +2253,7 @@ int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *first,
 		if (first->origin && !flow_cache_uli_match(first->origin, fl))
 			return 0;
 		if (first->partner &&
-		    !xfrm_selector_match(first->partner, fl, family))
+		    !xfrm_selector_match(first->partner, fl, family, 0))
 			return 0;
 	}
 #endif
@@ -2253,7 +2263,7 @@ int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *first,
 	do {
 		struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
 
-		if (fl && !xfrm_selector_match(&dst->xfrm->sel, fl, family))
+		if (fl && !xfrm_selector_match(&dst->xfrm->sel, fl, family, 0))
 			return 0;
 		if (fl && pol &&
 		    !security_xfrm_state_pol_flow_match(dst->xfrm, pol, fl))
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 17d5b96..f47c90b 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -756,7 +756,7 @@ static void xfrm_state_look_at(struct xfrm_policy *pol, struct xfrm_state *x,
 	 */
 	if (x->km.state == XFRM_STATE_VALID) {
 		if ((x->sel.family &&
-		     !xfrm_selector_match(&x->sel, fl, x->sel.family)) ||
+		     !xfrm_selector_match(&x->sel, fl, x->sel.family, 0)) ||
 		    !security_xfrm_state_pol_flow_match(x, pol, fl))
 			return;
 
@@ -769,7 +769,7 @@ static void xfrm_state_look_at(struct xfrm_policy *pol, struct xfrm_state *x,
 		*acq_in_progress = 1;
 	} else if (x->km.state == XFRM_STATE_ERROR ||
 		   x->km.state == XFRM_STATE_EXPIRED) {
-		if (xfrm_selector_match(&x->sel, fl, x->sel.family) &&
+		if (xfrm_selector_match(&x->sel, fl, x->sel.family, 0) &&
 		    security_xfrm_state_pol_flow_match(x, pol, fl))
 			*error = -ESRCH;
 	}

--=-WH/RlTQsUm7yuTziXvly--

