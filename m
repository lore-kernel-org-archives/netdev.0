From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 01/51] xfrm_user: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:57:51 -0400
Message-ID: <1333335521-1348-2-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46633 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754122Ab2DBC67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:58:59 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_user.c |  105 +++++++++++++++++++++++++++++--------------------
 1 files changed, 62 insertions(+), 43 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 7128dde..44293b3 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -756,40 +756,50 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 {
 	copy_to_user_state(x, p);
 
-	if (x->coaddr)
-		NLA_PUT(skb, XFRMA_COADDR, sizeof(*x->coaddr), x->coaddr);
+	if (x->coaddr &&
+	    nla_put(skb, XFRMA_COADDR, sizeof(*x->coaddr), x->coaddr))
+		goto nla_put_failure;
 
-	if (x->lastused)
-		NLA_PUT_U64(skb, XFRMA_LASTUSED, x->lastused);
+	if (x->lastused &&
+	    nla_put_u64(skb, XFRMA_LASTUSED, x->lastused))
+		goto nla_put_failure;
 
-	if (x->aead)
-		NLA_PUT(skb, XFRMA_ALG_AEAD, aead_len(x->aead), x->aead);
-	if (x->aalg) {
-		if (copy_to_user_auth(x->aalg, skb))
-			goto nla_put_failure;
+	if (x->aead &&
+	    nla_put(skb, XFRMA_ALG_AEAD, aead_len(x->aead), x->aead))
+		goto nla_put_failure;
 
-		NLA_PUT(skb, XFRMA_ALG_AUTH_TRUNC,
-			xfrm_alg_auth_len(x->aalg), x->aalg);
-	}
-	if (x->ealg)
-		NLA_PUT(skb, XFRMA_ALG_CRYPT, xfrm_alg_len(x->ealg), x->ealg);
-	if (x->calg)
-		NLA_PUT(skb, XFRMA_ALG_COMP, sizeof(*(x->calg)), x->calg);
+	if (x->aalg &&
+	    (copy_to_user_auth(x->aalg, skb) ||
+	     nla_put(skb, XFRMA_ALG_AUTH_TRUNC,
+		     xfrm_alg_auth_len(x->aalg), x->aalg)))
+		goto nla_put_failure;
 
-	if (x->encap)
-		NLA_PUT(skb, XFRMA_ENCAP, sizeof(*x->encap), x->encap);
+	if (x->ealg &&
+	    nla_put(skb, XFRMA_ALG_CRYPT, xfrm_alg_len(x->ealg), x->ealg))
+		goto nla_put_failure;
 
-	if (x->tfcpad)
-		NLA_PUT_U32(skb, XFRMA_TFCPAD, x->tfcpad);
+	if (x->calg &&
+	    nla_put(skb, XFRMA_ALG_COMP, sizeof(*(x->calg)), x->calg))
+		goto nla_put_failure;
+
+	if (x->encap &&
+	    nla_put(skb, XFRMA_ENCAP, sizeof(*x->encap), x->encap))
+		goto nla_put_failure;
+
+	if (x->tfcpad &&
+	    nla_put_u32(skb, XFRMA_TFCPAD, x->tfcpad))
+		goto nla_put_failure;
 
 	if (xfrm_mark_put(skb, &x->mark))
 		goto nla_put_failure;
 
-	if (x->replay_esn)
-		NLA_PUT(skb, XFRMA_REPLAY_ESN_VAL,
-			xfrm_replay_state_esn_len(x->replay_esn), x->replay_esn);
+	if (x->replay_esn &&
+	    nla_put(skb, XFRMA_REPLAY_ESN_VAL,
+		    xfrm_replay_state_esn_len(x->replay_esn),
+		    x->replay_esn))
+		goto nla_put_failure;
 
-	if (x->security && copy_sec_ctx(x->security, skb) < 0)
+	if (x->security && copy_sec_ctx(x->security, skb))
 		goto nla_put_failure;
 
 	return 0;
@@ -912,8 +922,9 @@ static int build_spdinfo(struct sk_buff *skb, struct net *net,
 	sph.spdhcnt = si.spdhcnt;
 	sph.spdhmcnt = si.spdhmcnt;
 
-	NLA_PUT(skb, XFRMA_SPD_INFO, sizeof(spc), &spc);
-	NLA_PUT(skb, XFRMA_SPD_HINFO, sizeof(sph), &sph);
+	if (nla_put(skb, XFRMA_SPD_INFO, sizeof(spc), &spc) ||
+	    nla_put(skb, XFRMA_SPD_HINFO, sizeof(sph), &sph))
+		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
 
@@ -967,8 +978,9 @@ static int build_sadinfo(struct sk_buff *skb, struct net *net,
 	sh.sadhmcnt = si.sadhmcnt;
 	sh.sadhcnt = si.sadhcnt;
 
-	NLA_PUT_U32(skb, XFRMA_SAD_CNT, si.sadcnt);
-	NLA_PUT(skb, XFRMA_SAD_HINFO, sizeof(sh), &sh);
+	if (nla_put_u32(skb, XFRMA_SAD_CNT, si.sadcnt) ||
+	    nla_put(skb, XFRMA_SAD_HINFO, sizeof(sh), &sh))
+		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
 
@@ -1690,21 +1702,27 @@ static int build_aevent(struct sk_buff *skb, struct xfrm_state *x, const struct
 	id->reqid = x->props.reqid;
 	id->flags = c->data.aevent;
 
-	if (x->replay_esn)
-		NLA_PUT(skb, XFRMA_REPLAY_ESN_VAL,
-			xfrm_replay_state_esn_len(x->replay_esn),
-			x->replay_esn);
-	else
-		NLA_PUT(skb, XFRMA_REPLAY_VAL, sizeof(x->replay), &x->replay);
-
-	NLA_PUT(skb, XFRMA_LTIME_VAL, sizeof(x->curlft), &x->curlft);
+	if (x->replay_esn) {
+		if (nla_put(skb, XFRMA_REPLAY_ESN_VAL,
+			    xfrm_replay_state_esn_len(x->replay_esn),
+			    x->replay_esn))
+			goto nla_put_failure;
+	} else {
+		if (nla_put(skb, XFRMA_REPLAY_VAL, sizeof(x->replay),
+			    &x->replay))
+			goto nla_put_failure;
+	}
+	if (nla_put(skb, XFRMA_LTIME_VAL, sizeof(x->curlft), &x->curlft))
+		goto nla_put_failure;
 
-	if (id->flags & XFRM_AE_RTHR)
-		NLA_PUT_U32(skb, XFRMA_REPLAY_THRESH, x->replay_maxdiff);
+	if ((id->flags & XFRM_AE_RTHR) &&
+	    nla_put_u32(skb, XFRMA_REPLAY_THRESH, x->replay_maxdiff))
+		goto nla_put_failure;
 
-	if (id->flags & XFRM_AE_ETHR)
-		NLA_PUT_U32(skb, XFRMA_ETIMER_THRESH,
-			    x->replay_maxage * 10 / HZ);
+	if ((id->flags & XFRM_AE_ETHR) &&
+	    nla_put_u32(skb, XFRMA_ETIMER_THRESH,
+			x->replay_maxage * 10 / HZ))
+		goto nla_put_failure;
 
 	if (xfrm_mark_put(skb, &x->mark))
 		goto nla_put_failure;
@@ -2835,8 +2853,9 @@ static int build_report(struct sk_buff *skb, u8 proto,
 	ur->proto = proto;
 	memcpy(&ur->sel, sel, sizeof(ur->sel));
 
-	if (addr)
-		NLA_PUT(skb, XFRMA_COADDR, sizeof(*addr), addr);
+	if (addr &&
+	    nla_put(skb, XFRMA_COADDR, sizeof(*addr), addr))
+		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
 
-- 
1.7.7.6
