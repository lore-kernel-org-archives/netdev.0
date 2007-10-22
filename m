From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [RFC][PATCH 2/3][XFRM]: Support to increment packet processing statistics.
Date: Mon, 22 Oct 2007 15:11:21 +0900
Message-ID: <11930334813857-git-send-email-nakam@linux-ipv6.org>
References: <20071017.213523.58458049.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:47268 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751772AbXJVGcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 02:32:18 -0400
In-Reply-To: <20071017.213523.58458049.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 net/ipv4/xfrm4_input.c  |   48 +++++++++++++++++++++++++++---------
 net/ipv4/xfrm4_output.c |    4 ++-
 net/ipv6/xfrm6_input.c  |   56 ++++++++++++++++++++++++++++++++----------
 net/ipv6/xfrm6_output.c |    4 ++-
 net/xfrm/xfrm_output.c  |   19 +++++++++++---
 net/xfrm/xfrm_policy.c  |   61 +++++++++++++++++++++++++++++++++++++---------
 6 files changed, 148 insertions(+), 44 deletions(-)

diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 5e95c8a..956e093 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -45,36 +45,52 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 	unsigned int nhoff = offsetof(struct iphdr, protocol);
 
 	seq = 0;
-	if (!spi && (err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0)
+	if (!spi && (err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0) {
+		XFRM_INC_STATS(XFRM_MIB_INHDRERROR);
 		goto drop;
+	}
 
 	do {
 		const struct iphdr *iph = ip_hdr(skb);
 
-		if (xfrm_nr == XFRM_MAX_DEPTH)
+		if (xfrm_nr == XFRM_MAX_DEPTH) {
+			XFRM_INC_STATS(XFRM_MIB_INBUFFERERROR);
 			goto drop;
+		}
 
 		x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, spi,
 				      nexthdr, AF_INET);
-		if (x == NULL)
+		if (x == NULL) {
+			XFRM_INC_STATS(XFRM_MIB_INNOSTATES);
 			goto drop;
+		}
 
 		spin_lock(&x->lock);
-		if (unlikely(x->km.state != XFRM_STATE_VALID))
+		if (unlikely(x->km.state != XFRM_STATE_VALID)) {
+			XFRM_INC_STATS(XFRM_MIB_INSTATEINVALID);
 			goto drop_unlock;
+		}
 
-		if ((x->encap ? x->encap->encap_type : 0) != encap_type)
+		if ((x->encap ? x->encap->encap_type : 0) != encap_type) {
+			XFRM_INC_STATS(XFRM_MIB_INSTATEMISMATCH);
 			goto drop_unlock;
+		}
 
-		if (x->props.replay_window && xfrm_replay_check(x, seq))
+		if (x->props.replay_window && xfrm_replay_check(x, seq)) {
+			XFRM_INC_STATS(XFRM_MIB_INSEQOUTOFWINDOW);
 			goto drop_unlock;
+		}
 
-		if (xfrm_state_check_expire(x))
+		if (xfrm_state_check_expire(x)) {
+			XFRM_INC_STATS(XFRM_MIB_INSTATEEXPIRED);
 			goto drop_unlock;
+		}
 
 		nexthdr = x->type->input(x, skb);
-		if (nexthdr <= 0)
+		if (nexthdr <= 0) {
+			XFRM_INC_STATS(XFRM_MIB_INSTATEPROTOERROR);
 			goto drop_unlock;
+		}
 
 		skb_network_header(skb)[nhoff] = nexthdr;
 
@@ -91,8 +107,10 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 
 		xfrm_vec[xfrm_nr++] = x;
 
-		if (x->outer_mode->input(x, skb))
+		if (x->outer_mode->input(x, skb)) {
+			XFRM_INC_STATS(XFRM_MIB_INSTATEMODEERROR);
 			goto drop;
+		}
 
 		if (x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) {
 			decaps = 1;
@@ -100,8 +118,10 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 		}
 
 		err = xfrm_parse_spi(skb, nexthdr, &spi, &seq);
-		if (err < 0)
+		if (err < 0) {
+			XFRM_INC_STATS(XFRM_MIB_INHDRERROR);
 			goto drop;
+		}
 	} while (!err);
 
 	/* Allocate new secpath or COW existing one. */
@@ -109,14 +129,18 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
 		struct sec_path *sp;
 		sp = secpath_dup(skb->sp);
-		if (!sp)
+		if (!sp) {
+			XFRM_INC_STATS(XFRM_MIB_INERROR);
 			goto drop;
+		}
 		if (skb->sp)
 			secpath_put(skb->sp);
 		skb->sp = sp;
 	}
-	if (xfrm_nr + skb->sp->len > XFRM_MAX_DEPTH)
+	if (xfrm_nr + skb->sp->len > XFRM_MAX_DEPTH) {
+		XFRM_INC_STATS(XFRM_MIB_INBUFFERERROR);
 		goto drop;
+	}
 
 	memcpy(skb->sp->xvec + skb->sp->len, xfrm_vec,
 	       xfrm_nr * sizeof(xfrm_vec[0]));
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index c4a7156..9d1d7b9 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -49,8 +49,10 @@ static inline int xfrm4_output_one(struct sk_buff *skb)
 
 	if (x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) {
 		err = xfrm4_tunnel_check_size(skb);
-		if (err)
+		if (err) {
+			XFRM_INC_STATS(XFRM_MIB_OUTLENGTHERROR);
 			goto error_nolock;
+		}
 	}
 
 	err = xfrm_output(skb);
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 5157837..4cf2206 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -29,32 +29,46 @@ int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 	nhoff = IP6CB(skb)->nhoff;
 
 	seq = 0;
-	if (!spi && (err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0)
+	if (!spi && (err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0) {
+		XFRM_INC_STATS(XFRM_MIB_INHDRERROR);
 		goto drop;
+	}
 
 	do {
 		struct ipv6hdr *iph = ipv6_hdr(skb);
 
-		if (xfrm_nr == XFRM_MAX_DEPTH)
+		if (xfrm_nr == XFRM_MAX_DEPTH) {
+			XFRM_INC_STATS(XFRM_MIB_INBUFFERERROR);
 			goto drop;
+		}
 
 		x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, spi,
 				      nexthdr, AF_INET6);
-		if (x == NULL)
+		if (x == NULL) {
+			XFRM_INC_STATS(XFRM_MIB_INNOSTATES);
 			goto drop;
+		}
 		spin_lock(&x->lock);
-		if (unlikely(x->km.state != XFRM_STATE_VALID))
+		if (unlikely(x->km.state != XFRM_STATE_VALID)) {
+			XFRM_INC_STATS(XFRM_MIB_INSTATEINVALID);
 			goto drop_unlock;
+		}
 
-		if (x->props.replay_window && xfrm_replay_check(x, seq))
+		if (x->props.replay_window && xfrm_replay_check(x, seq)) {
+			XFRM_INC_STATS(XFRM_MIB_INSEQOUTOFWINDOW);
 			goto drop_unlock;
+		}
 
-		if (xfrm_state_check_expire(x))
+		if (xfrm_state_check_expire(x)) {
+			XFRM_INC_STATS(XFRM_MIB_INSTATEEXPIRED);
 			goto drop_unlock;
+		}
 
 		nexthdr = x->type->input(x, skb);
-		if (nexthdr <= 0)
+		if (nexthdr <= 0) {
+			XFRM_INC_STATS(XFRM_MIB_INSTATEPROTOERROR);
 			goto drop_unlock;
+		}
 
 		skb_network_header(skb)[nhoff] = nexthdr;
 
@@ -68,31 +82,39 @@ int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 
 		xfrm_vec[xfrm_nr++] = x;
 
-		if (x->outer_mode->input(x, skb))
+		if (x->outer_mode->input(x, skb)) {
+			XFRM_INC_STATS(XFRM_MIB_INSTATEMODEERROR);
 			goto drop;
+		}
 
 		if (x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) {
 			decaps = 1;
 			break;
 		}
 
-		if ((err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) < 0)
+		if ((err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) < 0) {
+			XFRM_INC_STATS(XFRM_MIB_INHDRERROR);
 			goto drop;
+		}
 	} while (!err);
 
 	/* Allocate new secpath or COW existing one. */
 	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
 		struct sec_path *sp;
 		sp = secpath_dup(skb->sp);
-		if (!sp)
+		if (!sp) {
+			XFRM_INC_STATS(XFRM_MIB_INERROR);
 			goto drop;
+		}
 		if (skb->sp)
 			secpath_put(skb->sp);
 		skb->sp = sp;
 	}
 
-	if (xfrm_nr + skb->sp->len > XFRM_MAX_DEPTH)
+	if (xfrm_nr + skb->sp->len > XFRM_MAX_DEPTH) {
+		XFRM_INC_STATS(XFRM_MIB_INBUFFERERROR);
 		goto drop;
+	}
 
 	memcpy(skb->sp->xvec + skb->sp->len, xfrm_vec,
 	       xfrm_nr * sizeof(xfrm_vec[0]));
@@ -217,22 +239,28 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 		break;
 	}
 
-	if (!xfrm_vec_one)
+	if (!xfrm_vec_one) {
+		XFRM_INC_STATS(XFRM_MIB_INNOSTATES);
 		goto drop;
+	}
 
 	/* Allocate new secpath or COW existing one. */
 	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
 		struct sec_path *sp;
 		sp = secpath_dup(skb->sp);
-		if (!sp)
+		if (!sp) {
+			XFRM_INC_STATS(XFRM_MIB_INERROR);
 			goto drop;
+		}
 		if (skb->sp)
 			secpath_put(skb->sp);
 		skb->sp = sp;
 	}
 
-	if (1 + skb->sp->len > XFRM_MAX_DEPTH)
+	if (1 + skb->sp->len > XFRM_MAX_DEPTH) {
+		XFRM_INC_STATS(XFRM_MIB_INBUFFERERROR);
 		goto drop;
+	}
 
 	skb->sp->xvec[skb->sp->len] = xfrm_vec_one;
 	skb->sp->len ++;
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 6569767..6dfc74d 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -52,8 +52,10 @@ static inline int xfrm6_output_one(struct sk_buff *skb)
 
 	if (x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) {
 		err = xfrm6_tunnel_check_size(skb);
-		if (err)
+		if (err) {
+			XFRM_INC_STATS(XFRM_MIB_OUTLENGTHERROR);
 			goto error_nolock;
+		}
 	}
 
 	err = xfrm_output(skb);
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index f4bfd6c..39e40ac 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -32,9 +32,13 @@ static int xfrm_state_check_space(struct xfrm_state *x, struct sk_buff *skb)
 static int xfrm_state_check(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err = xfrm_state_check_expire(x);
-	if (err < 0)
+	if (err < 0) {
+		XFRM_INC_STATS(XFRM_MIB_OUTSTATEEXPIRED);
 		goto err;
+	}
 	err = xfrm_state_check_space(x, skb);
+	if (err)
+		XFRM_INC_STATS(XFRM_MIB_OUTLENGTHERROR);
 err:
 	return err;
 }
@@ -47,8 +51,10 @@ int xfrm_output(struct sk_buff *skb)
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		err = skb_checksum_help(skb);
-		if (err)
+		if (err) {
+			XFRM_INC_STATS(XFRM_MIB_OUTERROR);
 			goto error_nolock;
+		}
 	}
 
 	do {
@@ -64,8 +70,10 @@ int xfrm_output(struct sk_buff *skb)
 		}
 
 		err = x->outer_mode->output(x, skb);
-		if (err)
+		if (err) {
+			XFRM_INC_STATS(XFRM_MIB_OUTSTATEMODEERROR);
 			goto error;
+		}
 
 		x->curlft.bytes += skb->len;
 		x->curlft.packets++;
@@ -73,10 +81,13 @@ int xfrm_output(struct sk_buff *skb)
 		spin_unlock_bh(&x->lock);
 
 		err = x->type->output(x, skb);
-		if (err)
+		if (err) {
+			XFRM_INC_STATS(XFRM_MIB_OUTSTATEPROTOERROR);
 			goto error_nolock;
+		}
 
 		if (!(skb->dst = dst_pop(dst))) {
+			XFRM_INC_STATS(XFRM_MIB_OUTERROR);
 			err = -EHOSTUNREACH;
 			goto error_nolock;
 		}
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index e770998..2f6a1ec 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1326,8 +1326,10 @@ restart:
 
 	if (sk && sk->sk_policy[XFRM_POLICY_OUT]) {
 		policy = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl);
-		if (IS_ERR(policy))
+		if (IS_ERR(policy)) {
+			XFRM_INC_STATS(XFRM_MIB_OUTPOLERROR);
 			return PTR_ERR(policy);
+		}
 	}
 
 	if (!policy) {
@@ -1338,8 +1340,10 @@ restart:
 
 		policy = flow_cache_lookup(fl, dst_orig->ops->family,
 					   dir, xfrm_policy_lookup);
-		if (IS_ERR(policy))
+		if (IS_ERR(policy)) {
+			XFRM_INC_STATS(XFRM_MIB_OUTPOLERROR);
 			return PTR_ERR(policy);
+		}
 	}
 
 	if (!policy)
@@ -1354,6 +1358,7 @@ restart:
 	switch (policy->action) {
 	case XFRM_POLICY_BLOCK:
 		/* Prohibit the flow */
+		XFRM_INC_STATS(XFRM_MIB_OUTPOLBLOCK);
 		err = -EPERM;
 		goto error;
 
@@ -1373,6 +1378,7 @@ restart:
 		 */
 		dst = xfrm_find_bundle(fl, policy, family);
 		if (IS_ERR(dst)) {
+			XFRM_INC_STATS(XFRM_MIB_OUTBUNDLEERROR);
 			err = PTR_ERR(dst);
 			goto error;
 		}
@@ -1387,10 +1393,12 @@ restart:
 							    XFRM_POLICY_OUT);
 			if (pols[1]) {
 				if (IS_ERR(pols[1])) {
+					XFRM_INC_STATS(XFRM_MIB_OUTPOLERROR);
 					err = PTR_ERR(pols[1]);
 					goto error;
 				}
 				if (pols[1]->action == XFRM_POLICY_BLOCK) {
+					XFRM_INC_STATS(XFRM_MIB_OUTPOLBLOCK);
 					err = -EPERM;
 					goto error;
 				}
@@ -1436,6 +1444,7 @@ restart:
 				nx = xfrm_tmpl_resolve(pols, npols, fl, xfrm, family);
 
 				if (nx == -EAGAIN && signal_pending(current)) {
+					XFRM_INC_STATS(XFRM_MIB_OUTNOSTATES);
 					err = -ERESTART;
 					goto error;
 				}
@@ -1446,8 +1455,10 @@ restart:
 				}
 				err = nx;
 			}
-			if (err < 0)
+			if (err < 0) {
+				XFRM_INC_STATS(XFRM_MIB_OUTNOSTATES);
 				goto error;
+			}
 		}
 		if (nx == 0) {
 			/* Flow passes not transformed. */
@@ -1462,6 +1473,7 @@ restart:
 			int i;
 			for (i=0; i<nx; i++)
 				xfrm_state_put(xfrm[i]);
+			XFRM_INC_STATS(XFRM_MIB_OUTBUNDLEERROR);
 			goto error;
 		}
 
@@ -1482,6 +1494,7 @@ restart:
 			if (dst)
 				dst_free(dst);
 
+			XFRM_INC_STATS(XFRM_MIB_OUTBUNDLEERROR);
 			err = -EHOSTUNREACH;
 			goto error;
 		}
@@ -1494,6 +1507,7 @@ restart:
 			write_unlock_bh(&policy->lock);
 			if (dst)
 				dst_free(dst);
+			XFRM_INC_STATS(XFRM_MIB_OUTBUNDLEERROR);
 			goto error;
 		}
 
@@ -1635,8 +1649,11 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	u8 fl_dir = policy_to_flow_dir(dir);
 	int xerr_idx = -1;
 
-	if (xfrm_decode_session(skb, &fl, family) < 0)
+	if (xfrm_decode_session(skb, &fl, family) < 0) {
+		XFRM_INC_STATS(XFRM_MIB_INHDRERROR);
 		return 0;
+	}
+
 	nf_nat_decode_session(skb, &fl, family);
 
 	/* First, check used SA against their selectors. */
@@ -1645,28 +1662,35 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 
 		for (i=skb->sp->len-1; i>=0; i--) {
 			struct xfrm_state *x = skb->sp->xvec[i];
-			if (!xfrm_selector_match(&x->sel, &fl, family))
+			if (!xfrm_selector_match(&x->sel, &fl, family)) {
+				XFRM_INC_STATS(XFRM_MIB_INSTATEMISMATCH);
 				return 0;
+			}
 		}
 	}
 
 	pol = NULL;
 	if (sk && sk->sk_policy[dir]) {
 		pol = xfrm_sk_policy_lookup(sk, dir, &fl);
-		if (IS_ERR(pol))
+		if (IS_ERR(pol)) {
+			XFRM_INC_STATS(XFRM_MIB_INPOLERROR);
 			return 0;
+		}
 	}
 
 	if (!pol)
 		pol = flow_cache_lookup(&fl, family, fl_dir,
 					xfrm_policy_lookup);
 
-	if (IS_ERR(pol))
+	if (IS_ERR(pol)) {
+		XFRM_INC_STATS(XFRM_MIB_INPOLERROR);
 		return 0;
+	}
 
 	if (!pol) {
 		if (skb->sp && secpath_has_nontransport(skb->sp, 0, &xerr_idx)) {
 			xfrm_secpath_reject(xerr_idx, skb, &fl);
+			XFRM_INC_STATS(XFRM_MIB_INNOPOLS);
 			return 0;
 		}
 		return 1;
@@ -1682,8 +1706,10 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 						    &fl, family,
 						    XFRM_POLICY_IN);
 		if (pols[1]) {
-			if (IS_ERR(pols[1]))
+			if (IS_ERR(pols[1])) {
+				XFRM_INC_STATS(XFRM_MIB_INPOLERROR);
 				return 0;
+			}
 			pols[1]->curlft.use_time = get_seconds();
 			npols ++;
 		}
@@ -1704,10 +1730,14 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 
 		for (pi = 0; pi < npols; pi++) {
 			if (pols[pi] != pol &&
-			    pols[pi]->action != XFRM_POLICY_ALLOW)
+			    pols[pi]->action != XFRM_POLICY_ALLOW) {
+				XFRM_INC_STATS(XFRM_MIB_INPOLBLOCK);
 				goto reject;
-			if (ti + pols[pi]->xfrm_nr >= XFRM_MAX_DEPTH)
+			}
+			if (ti + pols[pi]->xfrm_nr >= XFRM_MAX_DEPTH) {
+				XFRM_INC_STATS(XFRM_MIB_INBUFFERERROR);
 				goto reject_error;
+			}
 			for (i = 0; i < pols[pi]->xfrm_nr; i++)
 				tpp[ti++] = &pols[pi]->xfrm_vec[i];
 		}
@@ -1729,16 +1759,20 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 				if (k < -1)
 					/* "-2 - errored_index" returned */
 					xerr_idx = -(2+k);
+				XFRM_INC_STATS(XFRM_MIB_INTMPLMISMATCH);
 				goto reject;
 			}
 		}
 
-		if (secpath_has_nontransport(sp, k, &xerr_idx))
+		if (secpath_has_nontransport(sp, k, &xerr_idx)) {
+			XFRM_INC_STATS(XFRM_MIB_INTMPLMISMATCH);
 			goto reject;
+		}
 
 		xfrm_pols_put(pols, npols);
 		return 1;
 	}
+	XFRM_INC_STATS(XFRM_MIB_INPOLBLOCK);
 
 reject:
 	xfrm_secpath_reject(xerr_idx, skb, &fl);
@@ -1752,8 +1786,11 @@ int __xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 {
 	struct flowi fl;
 
-	if (xfrm_decode_session(skb, &fl, family) < 0)
+	if (xfrm_decode_session(skb, &fl, family) < 0) {
+		/* XXX: we should have something like FWDHDRERROR here. */
+		XFRM_INC_STATS(XFRM_MIB_INHDRERROR);
 		return 0;
+	}
 
 	return xfrm_lookup(&skb->dst, &fl, NULL, 0) == 0;
 }
-- 
1.4.4.2

