From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 6/7] [IPSEC]: Lock state when copying non-atomic fields to user-space
Date: Tue, 09 Oct 2007 22:36:36 +0800
Message-ID: <E1IfGCK-0005ML-00@gondolin.me.apana.org.au>
References: <20071009143517.GA20486@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4998 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752864AbXJIOgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 10:36:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Lock state when copying non-atomic fields to user-space

This patch adds locking so that when we're copying non-atomic fields such as
life-time or coaddr to user-space we don't get a partial result.

For af_key I've changed every instance of pfkey_xfrm_state2msg apart from
expiration notification to include the keys and life-times.  This is in-line
with XFRM behaviour.

The actual cases affected are:

* pfkey_getspi: No change as we don't have any keys to copy.
* key_notify_sa:
	+ ADD/UPD: This wouldn't work otherwise.
	+ DEL: It can't hurt.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/key/af_key.c     |   35 +++++++++++++++++++++++++----------
 net/xfrm/xfrm_user.c |   14 ++++++++------
 2 files changed, 33 insertions(+), 16 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 143d46f..7969f8a 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -655,7 +655,8 @@ static inline int pfkey_mode_to_xfrm(int mode)
 	}
 }
 
-static struct sk_buff * pfkey_xfrm_state2msg(struct xfrm_state *x, int add_keys, int hsc)
+static struct sk_buff *__pfkey_xfrm_state2msg(struct xfrm_state *x,
+					      int add_keys, int hsc)
 {
 	struct sk_buff *skb;
 	struct sadb_msg *hdr;
@@ -1009,6 +1010,24 @@ static struct sk_buff * pfkey_xfrm_state2msg(struct xfrm_state *x, int add_keys,
 	return skb;
 }
 
+
+static inline struct sk_buff *pfkey_xfrm_state2msg(struct xfrm_state *x)
+{
+	struct sk_buff *skb;
+
+	spin_lock_bh(&x->lock);
+	skb = __pfkey_xfrm_state2msg(x, 1, 3);
+	spin_unlock_bh(&x->lock);
+
+	return skb;
+}
+
+static inline struct sk_buff *pfkey_xfrm_state2msg_expire(struct xfrm_state *x,
+							  int hsc)
+{
+	return __pfkey_xfrm_state2msg(x, 0, hsc);
+}
+
 static struct xfrm_state * pfkey_msg2xfrm_state(struct sadb_msg *hdr,
 						void **ext_hdrs)
 {
@@ -1322,7 +1341,7 @@ static int pfkey_getspi(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
 	}
 
 	err = xfrm_alloc_spi(x, min_spi, max_spi);
-	resp_skb = err ? ERR_PTR(err) : pfkey_xfrm_state2msg(x, 0, 3);
+	resp_skb = err ? ERR_PTR(err) : pfkey_xfrm_state2msg(x);
 
 	if (IS_ERR(resp_skb)) {
 		xfrm_state_put(x);
@@ -1412,12 +1431,8 @@ static int key_notify_sa(struct xfrm_state *x, struct km_event *c)
 {
 	struct sk_buff *skb;
 	struct sadb_msg *hdr;
-	int hsc = 3;
-
-	if (c->event == XFRM_MSG_DELSA)
-		hsc = 0;
 
-	skb = pfkey_xfrm_state2msg(x, 0, hsc);
+	skb = pfkey_xfrm_state2msg(x);
 
 	if (IS_ERR(skb))
 		return PTR_ERR(skb);
@@ -1529,7 +1544,7 @@ static int pfkey_get(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr,
 	if (x == NULL)
 		return -ESRCH;
 
-	out_skb = pfkey_xfrm_state2msg(x, 1, 3);
+	out_skb = pfkey_xfrm_state2msg(x);
 	proto = x->id.proto;
 	xfrm_state_put(x);
 	if (IS_ERR(out_skb))
@@ -1709,7 +1724,7 @@ static int dump_sa(struct xfrm_state *x, int count, void *ptr)
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
 
-	out_skb = pfkey_xfrm_state2msg(x, 1, 3);
+	out_skb = pfkey_xfrm_state2msg(x);
 	if (IS_ERR(out_skb))
 		return PTR_ERR(out_skb);
 
@@ -2910,7 +2925,7 @@ static int key_notify_sa_expire(struct xfrm_state *x, struct km_event *c)
 	else
 		hsc = 1;
 
-	out_skb = pfkey_xfrm_state2msg(x, 0, hsc);
+	out_skb = pfkey_xfrm_state2msg_expire(x, hsc);
 	if (IS_ERR(out_skb))
 		return PTR_ERR(out_skb);
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2cbbe5e..5238f6a 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -507,8 +507,16 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 				    struct xfrm_usersa_info *p,
 				    struct sk_buff *skb)
 {
+	spin_lock_bh(&x->lock);
 	copy_to_user_state(x, p);
 
+	if (x->coaddr)
+		NLA_PUT(skb, XFRMA_COADDR, sizeof(*x->coaddr), x->coaddr);
+
+	if (x->lastused)
+		NLA_PUT_U64(skb, XFRMA_LASTUSED, x->lastused);
+	spin_unlock_bh(&x->lock);
+
 	if (x->aalg)
 		NLA_PUT(skb, XFRMA_ALG_AUTH, alg_len(x->aalg), x->aalg);
 	if (x->ealg)
@@ -522,12 +530,6 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 	if (x->security && copy_sec_ctx(x->security, skb) < 0)
 		goto nla_put_failure;
 
-	if (x->coaddr)
-		NLA_PUT(skb, XFRMA_COADDR, sizeof(*x->coaddr), x->coaddr);
-
-	if (x->lastused)
-		NLA_PUT_U64(skb, XFRMA_LASTUSED, x->lastused);
-
 	return 0;
 
 nla_put_failure:
