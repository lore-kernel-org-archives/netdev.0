From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 2/3] [XFRM]: Support to increment packet dropping statistics.
Date: Fri, 21 Dec 2007 12:41:59 +0900
Message-ID: <11982085193489-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:58060 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1755126AbXLUEJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:09:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 net/ipv6/xfrm6_input.c |    3 ++
 net/xfrm/xfrm_input.c  |   41 +++++++++++++++++++++++-------
 net/xfrm/xfrm_output.c |    6 ++++-
 net/xfrm/xfrm_policy.c |   63 ++++++++++++++++++++++++++++++++++++++---------
 4 files changed, 90 insertions(+), 23 deletions(-)

diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index f835ab4..6644fc6 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -72,6 +72,7 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 
 		sp = secpath_dup(skb->sp);
 		if (!sp) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMINERROR);
 			goto drop;
 		}
 		if (skb->sp)
@@ -80,6 +81,7 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 	}
 
 	if (1 + skb->sp->len == XFRM_MAX_DEPTH) {
+		XFRM_INC_STATS(LINUX_MIB_XFRMINBUFFERERROR);
 		goto drop;
 	}
 
@@ -149,6 +151,7 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 	}
 
 	if (!x) {
+		XFRM_INC_STATS(LINUX_MIB_XFRMINNOSTATES);
 		goto drop;
 	}
 
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 8624cbd..493243f 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -119,8 +119,10 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		struct sec_path *sp;
 
 		sp = secpath_dup(skb->sp);
-		if (!sp)
+		if (!sp) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMINERROR);
 			goto drop;
+		}
 		if (skb->sp)
 			secpath_put(skb->sp);
 		skb->sp = sp;
@@ -131,31 +133,45 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	family = XFRM_SPI_SKB_CB(skb)->family;
 
 	seq = 0;
-	if (!spi && (err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0)
+	if (!spi && (err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0) {
+		XFRM_INC_STATS(LINUX_MIB_XFRMINHDRERROR);
 		goto drop;
+	}
 
 	do {
-		if (skb->sp->len == XFRM_MAX_DEPTH)
+		if (skb->sp->len == XFRM_MAX_DEPTH) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMINBUFFERERROR);
 			goto drop;
+		}
 
 		x = xfrm_state_lookup(daddr, spi, nexthdr, family);
-		if (x == NULL)
+		if (x == NULL) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMINNOSTATES);
 			goto drop;
+		}
 
 		skb->sp->xvec[skb->sp->len++] = x;
 
 		spin_lock(&x->lock);
-		if (unlikely(x->km.state != XFRM_STATE_VALID))
+		if (unlikely(x->km.state != XFRM_STATE_VALID)) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEINVALID);
 			goto drop_unlock;
+		}
 
-		if ((x->encap ? x->encap->encap_type : 0) != encap_type)
+		if ((x->encap ? x->encap->encap_type : 0) != encap_type) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEINVALID);
 			goto drop_unlock;
+		}
 
-		if (x->props.replay_window && xfrm_replay_check(x, seq))
+		if (x->props.replay_window && xfrm_replay_check(x, seq)) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMINSEQOUTOFWINDOW);
 			goto drop_unlock;
+		}
 
-		if (xfrm_state_check_expire(x))
+		if (xfrm_state_check_expire(x)) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEEXPIRED);
 			goto drop_unlock;
+		}
 
 		spin_unlock(&x->lock);
 
@@ -171,6 +187,7 @@ resume:
 		if (nexthdr <= 0) {
 			if (nexthdr == -EBADMSG)
 				x->stats.integrity_failed++;
+			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEPROTOERROR);
 			goto drop_unlock;
 		}
 
@@ -187,8 +204,10 @@ resume:
 
 		XFRM_MODE_SKB_CB(skb)->protocol = nexthdr;
 
-		if (x->inner_mode->input(x, skb))
+		if (x->inner_mode->input(x, skb)) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEMODEERROR);
 			goto drop;
+		}
 
 		if (x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) {
 			decaps = 1;
@@ -203,8 +222,10 @@ resume:
 		family = x->outer_mode->afinfo->family;
 
 		err = xfrm_parse_spi(skb, nexthdr, &spi, &seq);
-		if (err < 0)
+		if (err < 0) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMINHDRERROR);
 			goto drop;
+		}
 	} while (!err);
 
 	nf_reset(skb);
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 26fa0cb..867484a 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -69,10 +69,13 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 		err = x->type->output(x, skb);
 
 resume:
-		if (err)
+		if (err) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMOUTSTATEPROTOERROR);
 			goto error_nolock;
+		}
 
 		if (!(skb->dst = dst_pop(dst))) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMOUTERROR);
 			err = -EHOSTUNREACH;
 			goto error_nolock;
 		}
@@ -167,6 +170,7 @@ int xfrm_output(struct sk_buff *skb)
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		err = skb_checksum_help(skb);
 		if (err) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMOUTERROR);
 			kfree_skb(skb);
 			return err;
 		}
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7dcc6c1..6f8ca24 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1494,8 +1494,10 @@ restart:
 	if (sk && sk->sk_policy[XFRM_POLICY_OUT]) {
 		policy = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl);
 		err = PTR_ERR(policy);
-		if (IS_ERR(policy))
+		if (IS_ERR(policy)) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMOUTPOLERROR);
 			goto dropdst;
+		}
 	}
 
 	if (!policy) {
@@ -1529,6 +1531,7 @@ restart:
 	default:
 	case XFRM_POLICY_BLOCK:
 		/* Prohibit the flow */
+		XFRM_INC_STATS(LINUX_MIB_XFRMOUTPOLBLOCK);
 		err = -EPERM;
 		goto error;
 
@@ -1548,6 +1551,7 @@ restart:
 		 */
 		dst = xfrm_find_bundle(fl, policy, family);
 		if (IS_ERR(dst)) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMOUTBUNDLECHECKERROR);
 			err = PTR_ERR(dst);
 			goto error;
 		}
@@ -1562,10 +1566,12 @@ restart:
 							    XFRM_POLICY_OUT);
 			if (pols[1]) {
 				if (IS_ERR(pols[1])) {
+					XFRM_INC_STATS(LINUX_MIB_XFRMOUTPOLERROR);
 					err = PTR_ERR(pols[1]);
 					goto error;
 				}
 				if (pols[1]->action == XFRM_POLICY_BLOCK) {
+					XFRM_INC_STATS(LINUX_MIB_XFRMOUTPOLBLOCK);
 					err = -EPERM;
 					goto error;
 				}
@@ -1611,6 +1617,7 @@ restart:
 				nx = xfrm_tmpl_resolve(pols, npols, fl, xfrm, family);
 
 				if (nx == -EAGAIN && signal_pending(current)) {
+					XFRM_INC_STATS(LINUX_MIB_XFRMOUTNOSTATES);
 					err = -ERESTART;
 					goto error;
 				}
@@ -1621,8 +1628,10 @@ restart:
 				}
 				err = nx;
 			}
-			if (err < 0)
+			if (err < 0) {
+				XFRM_INC_STATS(LINUX_MIB_XFRMOUTNOSTATES);
 				goto error;
+			}
 		}
 		if (nx == 0) {
 			/* Flow passes not transformed. */
@@ -1632,8 +1641,10 @@ restart:
 
 		dst = xfrm_bundle_create(policy, xfrm, nx, fl, dst_orig);
 		err = PTR_ERR(dst);
-		if (IS_ERR(dst))
+		if (IS_ERR(dst)) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMOUTBUNDLEGENERROR);
 			goto error;
+		}
 
 		for (pi = 0; pi < npols; pi++) {
 			read_lock_bh(&pols[pi]->lock);
@@ -1652,6 +1663,10 @@ restart:
 			if (dst)
 				dst_free(dst);
 
+			if (pol_dead)
+				XFRM_INC_STATS(LINUX_MIB_XFRMOUTPOLDEAD);
+			else
+				XFRM_INC_STATS(LINUX_MIB_XFRMOUTBUNDLECHECKERROR);
 			err = -EHOSTUNREACH;
 			goto error;
 		}
@@ -1664,6 +1679,7 @@ restart:
 			write_unlock_bh(&policy->lock);
 			if (dst)
 				dst_free(dst);
+			XFRM_INC_STATS(LINUX_MIB_XFRMOUTBUNDLECHECKERROR);
 			goto error;
 		}
 
@@ -1817,8 +1833,11 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	dir &= XFRM_POLICY_MASK;
 	fl_dir = policy_to_flow_dir(dir);
 
-	if (__xfrm_decode_session(skb, &fl, family, reverse) < 0)
+	if (__xfrm_decode_session(skb, &fl, family, reverse) < 0) {
+		XFRM_INC_STATS(LINUX_MIB_XFRMINHDRERROR);
 		return 0;
+	}
+
 	nf_nat_decode_session(skb, &fl, family);
 
 	/* First, check used SA against their selectors. */
@@ -1827,28 +1846,35 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 
 		for (i=skb->sp->len-1; i>=0; i--) {
 			struct xfrm_state *x = skb->sp->xvec[i];
-			if (!xfrm_selector_match(&x->sel, &fl, family))
+			if (!xfrm_selector_match(&x->sel, &fl, family)) {
+				XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEMISMATCH);
 				return 0;
+			}
 		}
 	}
 
 	pol = NULL;
 	if (sk && sk->sk_policy[dir]) {
 		pol = xfrm_sk_policy_lookup(sk, dir, &fl);
-		if (IS_ERR(pol))
+		if (IS_ERR(pol)) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMINPOLERROR);
 			return 0;
+		}
 	}
 
 	if (!pol)
 		pol = flow_cache_lookup(&fl, family, fl_dir,
 					xfrm_policy_lookup);
 
-	if (IS_ERR(pol))
+	if (IS_ERR(pol)) {
+		XFRM_INC_STATS(LINUX_MIB_XFRMINPOLERROR);
 		return 0;
+	}
 
 	if (!pol) {
 		if (skb->sp && secpath_has_nontransport(skb->sp, 0, &xerr_idx)) {
 			xfrm_secpath_reject(xerr_idx, skb, &fl);
+			XFRM_INC_STATS(LINUX_MIB_XFRMINNOPOLS);
 			return 0;
 		}
 		return 1;
@@ -1864,8 +1890,10 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 						    &fl, family,
 						    XFRM_POLICY_IN);
 		if (pols[1]) {
-			if (IS_ERR(pols[1]))
+			if (IS_ERR(pols[1])) {
+				XFRM_INC_STATS(LINUX_MIB_XFRMINPOLERROR);
 				return 0;
+			}
 			pols[1]->curlft.use_time = get_seconds();
 			npols ++;
 		}
@@ -1886,10 +1914,14 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 
 		for (pi = 0; pi < npols; pi++) {
 			if (pols[pi] != pol &&
-			    pols[pi]->action != XFRM_POLICY_ALLOW)
+			    pols[pi]->action != XFRM_POLICY_ALLOW) {
+				XFRM_INC_STATS(LINUX_MIB_XFRMINPOLBLOCK);
 				goto reject;
-			if (ti + pols[pi]->xfrm_nr >= XFRM_MAX_DEPTH)
+			}
+			if (ti + pols[pi]->xfrm_nr >= XFRM_MAX_DEPTH) {
+				XFRM_INC_STATS(LINUX_MIB_XFRMINBUFFERERROR);
 				goto reject_error;
+			}
 			for (i = 0; i < pols[pi]->xfrm_nr; i++)
 				tpp[ti++] = &pols[pi]->xfrm_vec[i];
 		}
@@ -1911,16 +1943,20 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 				if (k < -1)
 					/* "-2 - errored_index" returned */
 					xerr_idx = -(2+k);
+				XFRM_INC_STATS(LINUX_MIB_XFRMINTMPLMISMATCH);
 				goto reject;
 			}
 		}
 
-		if (secpath_has_nontransport(sp, k, &xerr_idx))
+		if (secpath_has_nontransport(sp, k, &xerr_idx)) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMINTMPLMISMATCH);
 			goto reject;
+		}
 
 		xfrm_pols_put(pols, npols);
 		return 1;
 	}
+	XFRM_INC_STATS(LINUX_MIB_XFRMINPOLBLOCK);
 
 reject:
 	xfrm_secpath_reject(xerr_idx, skb, &fl);
@@ -1934,8 +1970,11 @@ int __xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 {
 	struct flowi fl;
 
-	if (xfrm_decode_session(skb, &fl, family) < 0)
+	if (xfrm_decode_session(skb, &fl, family) < 0) {
+		/* XXX: we should have something like FWDHDRERROR here. */
+		XFRM_INC_STATS(LINUX_MIB_XFRMINHDRERROR);
 		return 0;
+	}
 
 	return xfrm_lookup(&skb->dst, &fl, NULL, 0) == 0;
 }
-- 
1.4.4.2

