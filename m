From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] SPD basic actions per netdev
Date: Thu, 01 Apr 2010 07:29:45 -0400
Message-ID: <1270121385.26743.169.camel@bigi>
References: <1270053478.26743.111.camel@bigi>
	 <20100401003352.GA19147@gondor.apana.org.au>
	 <1270089323.26743.138.camel@bigi>
	 <20100401025247.GA19994@gondor.apana.org.au> <4BB42692.9010105@iki.fi>
	 <20100401060145.GB20865@gondor.apana.org.au> <4BB43B38.1060004@iki.fi>
	 <20100401062840.GA21284@gondor.apana.org.au> <4BB43DE6.9060300@iki.fi>
	 <20100401063956.GA21422@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-JoCWHmUJY/tLYdFLQtq4"
Cc: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:15674 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755261Ab0DAL3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 07:29:51 -0400
Received: by qw-out-2122.google.com with SMTP id 8so348347qwh.37
        for <netdev@vger.kernel.org>; Thu, 01 Apr 2010 04:29:51 -0700 (PDT)
In-Reply-To: <20100401063956.GA21422@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-JoCWHmUJY/tLYdFLQtq4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit

On Thu, 2010-04-01 at 14:39 +0800, Herbert Xu wrote:
> On Thu, Apr 01, 2010 at 09:32:06AM +0300, Timo Teräs wrote:
> >
> > On inbound it's always loopback interface. Does the same hold
> > true on forward? I was under the impression that it would
> > reflect the actual destination interface.
> 
> That's a good point.  I suppose there might just be some crazy
> people out there using it this way.
> 
> So Jamal, I think this is a good reason why we do need a new
> field instead of just overloading the current one.  Otherwise
> inbound selectors and forward selectors will have different
> semantics which is needlessly confusing.


So I followed the discussion up to about this point then confusion sets
in for me - in particular about loopback being used for policy_check()
which you guys seem to agree on.
Nod on:  IN+FWD should be treated the same way. Locally generated/OUT
works and I dont muck with that.
The current code is sufficiently clean such that all i need is to worry
about is __xfrm_policy_check() (which is invoked only for IN and FWD).
And thats the only thing i touch - the rest "works as it did before".

[Note: the flow struct used in __xfrm_policy_check() is local to it, so
my touching it affects only the scope of validation of IN/FWD. I dont
see loopback being used for policy check.
Note2: In the FWD policy check, the output dev hasnt been decided
yet at that point. So it sounds fair to define "dev blah" in FWD
direction to mean incoming device (as it is for IN/local destined).]

Q: So if all i want to achieve for now is to make sure that i can
specify a "dev blah" in the forward or in direction and have it work to
identify the incoming device, wouldnt this patch suffice?

I am attaching this patch with a fix to check for FWD as well if you
have a chance i would appreciate if you re-look at it again.

cheers,
jamal


--=-JoCWHmUJY/tLYdFLQtq4
Content-Disposition: attachment; filename="spd-fw-in"
Content-Type: text/x-patch; name="spd-fw-in"; charset="UTF-8"
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
index 843e066..cad67b3 100644
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
+	int use_if = 0, match, ret = -ESRCH;
 
 	if (pol->family != family ||
 	    (fl->mark & pol->mark.m) != pol->mark.v ||
 	    pol->type != type)
 		return ret;
 
-	match = xfrm_selector_match(sel, fl, family);
+	if (dir == FLOW_DIR_IN || dir == FLOW_DIR_FWD)
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
 
+	if (fl_dir ==  FLOW_DIR_IN || fl_dir ==  FLOW_DIR_FWD)
+		fl.iif = use_if = skb->skb_iif;
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
@@ -2243,7 +2252,7 @@ int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *first,
 		if (first->origin && !flow_cache_uli_match(first->origin, fl))
 			return 0;
 		if (first->partner &&
-		    !xfrm_selector_match(first->partner, fl, family))
+		    !xfrm_selector_match(first->partner, fl, family, 0))
 			return 0;
 	}
 #endif
@@ -2253,7 +2262,7 @@ int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *first,
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

--=-JoCWHmUJY/tLYdFLQtq4--

