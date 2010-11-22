From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC] [PATCH 11/11] xfrm: Add user interface for esn and big
 anti-replay windows
Date: Mon, 22 Nov 2010 11:34:30 +0100
Message-ID: <20101122103430.GN1868@secunet.com>
References: <20101122102455.GC1868@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Gruenbacher <agruen@suse.de>,
	Alex Badea <abadea@ixiacom.com>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101122102455.GC1868@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a netlink based user interface to configure
esn and big anti-replay windows. The new netlink attribute
XFRMA_REPLAY_ESN_VAL is used to configure the new implementation.
If the XFRM_STATE_ESN flag is set, we use esn and support for big
anti-replay windows for the configured state. If this flag is not
set we use the new implementation with 32 bit sequence numbers.
A big anti-replay window can be configured in this case anyway.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c |    2 +
 net/xfrm/xfrm_user.c  |   99 ++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 87 insertions(+), 14 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index a5035c0..fc82563 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -355,6 +355,8 @@ static void xfrm_state_gc_destroy(struct xfrm_state *x)
 	kfree(x->calg);
 	kfree(x->encap);
 	kfree(x->coaddr);
+	kfree(x->replay_esn);
+	kfree(x->preplay_esn);
 	if (x->inner_mode)
 		xfrm_put_mode(x->inner_mode);
 	if (x->inner_mode_iaf)
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 77452dc..cf6cab2 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -118,6 +118,19 @@ static inline int verify_sec_ctx_len(struct nlattr **attrs)
 	return 0;
 }
 
+static inline int verify_replay(struct xfrm_usersa_info *p,
+				struct nlattr **attrs)
+{
+	struct nlattr *rt = attrs[XFRMA_REPLAY_ESN_VAL];
+
+	if (!rt)
+		return 0;
+
+	if (p->replay_window != 0)
+		return -EINVAL;
+
+	return 0;
+}
 
 static int verify_newsa_info(struct xfrm_usersa_info *p,
 			     struct nlattr **attrs)
@@ -207,6 +220,8 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 		goto out;
 	if ((err = verify_sec_ctx_len(attrs)))
 		goto out;
+	if ((err = verify_replay(p, attrs)))
+		goto out;
 
 	err = -EINVAL;
 	switch (p->mode) {
@@ -337,6 +352,33 @@ static int attach_aead(struct xfrm_algo_aead **algpp, u8 *props,
 	return 0;
 }
 
+static int xfrm_alloc_replay_state_esn(struct xfrm_replay_state_esn **replay_esn,
+				       struct xfrm_replay_state_esn **preplay_esn,
+				       struct nlattr *rta)
+{
+	struct xfrm_replay_state_esn *p, *pp, *up;
+
+	if (!rta)
+		return 0;
+
+	up = nla_data(rta);
+
+	p = kmemdup(up, xfrm_replay_state_esn_len(up), GFP_KERNEL);
+	if (!p)
+		return -ENOMEM;
+
+	pp = kmemdup(up, xfrm_replay_state_esn_len(up), GFP_KERNEL);
+	if (!pp) {
+		kfree(p);
+		return -ENOMEM;
+	}
+
+	*replay_esn = p;
+	*preplay_esn = pp;
+
+	return 0;
+}
+
 static inline int xfrm_user_sec_ctx_size(struct xfrm_sec_ctx *xfrm_ctx)
 {
 	int len = 0;
@@ -372,10 +414,20 @@ static void copy_from_user_state(struct xfrm_state *x, struct xfrm_usersa_info *
 static void xfrm_update_ae_params(struct xfrm_state *x, struct nlattr **attrs)
 {
 	struct nlattr *rp = attrs[XFRMA_REPLAY_VAL];
+	struct nlattr *re = attrs[XFRMA_REPLAY_ESN_VAL];
 	struct nlattr *lt = attrs[XFRMA_LTIME_VAL];
 	struct nlattr *et = attrs[XFRMA_ETIMER_THRESH];
 	struct nlattr *rt = attrs[XFRMA_REPLAY_THRESH];
 
+	if (re) {
+		struct xfrm_replay_state_esn *replay_esn;
+		replay_esn = nla_data(re);
+		memcpy(x->replay_esn, replay_esn,
+		       xfrm_replay_state_esn_len(replay_esn));
+		memcpy(x->preplay_esn, replay_esn,
+		       xfrm_replay_state_esn_len(replay_esn));
+	}
+
 	if (rp) {
 		struct xfrm_replay_state *replay;
 		replay = nla_data(rp);
@@ -456,13 +508,14 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 	    security_xfrm_state_alloc(x, nla_data(attrs[XFRMA_SEC_CTX])))
 		goto error;
 
+	if ((err = xfrm_alloc_replay_state_esn(&x->replay_esn, &x->preplay_esn,
+					       attrs[XFRMA_REPLAY_ESN_VAL])))
+		goto error;
+
 	x->km.seq = p->seq;
 	x->replay_maxdiff = net->xfrm.sysctl_aevent_rseqth;
 	/* sysctl_xfrm_aevent_etime is in 100ms units */
 	x->replay_maxage = (net->xfrm.sysctl_aevent_etime*HZ)/XFRM_AE_ETH_M;
-	x->preplay.bitmap = 0;
-	x->preplay.seq = x->replay.seq+x->replay_maxdiff;
-	x->preplay.oseq = x->replay.oseq +x->replay_maxdiff;
 
 	if ((err = xfrm_init_replay(x)))
 		goto error;
@@ -693,6 +746,10 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 	if (xfrm_mark_put(skb, &x->mark))
 		goto nla_put_failure;
 
+	if (x->replay_esn)
+		NLA_PUT(skb, XFRMA_REPLAY_ESN_VAL,
+			xfrm_replay_state_esn_len(x->replay_esn), x->replay_esn);
+
 	if (x->security && copy_sec_ctx(x->security, skb) < 0)
 		goto nla_put_failure;
 
@@ -1560,10 +1617,14 @@ static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	return 0;
 }
 
-static inline size_t xfrm_aevent_msgsize(void)
+static inline size_t xfrm_aevent_msgsize(struct xfrm_state *x)
 {
+	size_t replay_size = x->replay_esn ?
+			      xfrm_replay_state_esn_len(x->replay_esn) :
+			      sizeof(struct xfrm_replay_state);
+
 	return NLMSG_ALIGN(sizeof(struct xfrm_aevent_id))
-	       + nla_total_size(sizeof(struct xfrm_replay_state))
+	       + nla_total_size(replay_size)
 	       + nla_total_size(sizeof(struct xfrm_lifetime_cur))
 	       + nla_total_size(sizeof(struct xfrm_mark))
 	       + nla_total_size(4) /* XFRM_AE_RTHR */
@@ -1588,7 +1649,13 @@ static int build_aevent(struct sk_buff *skb, struct xfrm_state *x, struct km_eve
 	id->reqid = x->props.reqid;
 	id->flags = c->data.aevent;
 
-	NLA_PUT(skb, XFRMA_REPLAY_VAL, sizeof(x->replay), &x->replay);
+	if (x->replay_esn)
+		NLA_PUT(skb, XFRMA_REPLAY_ESN_VAL,
+			xfrm_replay_state_esn_len(x->replay_esn),
+			x->replay_esn);
+	else
+		NLA_PUT(skb, XFRMA_REPLAY_VAL, sizeof(x->replay), &x->replay);
+
 	NLA_PUT(skb, XFRMA_LTIME_VAL, sizeof(x->curlft), &x->curlft);
 
 	if (id->flags & XFRM_AE_RTHR)
@@ -1621,16 +1688,16 @@ static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_aevent_id *p = nlmsg_data(nlh);
 	struct xfrm_usersa_id *id = &p->sa_id;
 
-	r_skb = nlmsg_new(xfrm_aevent_msgsize(), GFP_ATOMIC);
-	if (r_skb == NULL)
-		return -ENOMEM;
-
 	mark = xfrm_mark_get(attrs, &m);
 
 	x = xfrm_state_lookup(net, mark, &id->daddr, id->spi, id->proto, id->family);
-	if (x == NULL) {
-		kfree_skb(r_skb);
+	if (x == NULL)
 		return -ESRCH;
+
+	r_skb = nlmsg_new(xfrm_aevent_msgsize(x), GFP_ATOMIC);
+	if (r_skb == NULL) {
+		xfrm_state_put(x);
+		return -ENOMEM;
 	}
 
 	/*
@@ -1662,9 +1729,10 @@ static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_mark m;
 	struct xfrm_aevent_id *p = nlmsg_data(nlh);
 	struct nlattr *rp = attrs[XFRMA_REPLAY_VAL];
+	struct nlattr *re = attrs[XFRMA_REPLAY_ESN_VAL];
 	struct nlattr *lt = attrs[XFRMA_LTIME_VAL];
 
-	if (!lt && !rp)
+	if (!lt && !rp && !re)
 		return err;
 
 	/* pedantic mode - thou shalt sayeth replaceth */
@@ -2124,6 +2192,7 @@ static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
 	[XFRMA_MIGRATE]		= { .len = sizeof(struct xfrm_user_migrate) },
 	[XFRMA_KMADDRESS]	= { .len = sizeof(struct xfrm_user_kmaddress) },
 	[XFRMA_MARK]		= { .len = sizeof(struct xfrm_mark) },
+	[XFRMA_REPLAY_ESN_VAL]	= { .len = sizeof(struct xfrm_replay_state_esn) },
 };
 
 static struct xfrm_link {
@@ -2251,7 +2320,7 @@ static int xfrm_aevent_state_notify(struct xfrm_state *x, struct km_event *c)
 	struct net *net = xs_net(x);
 	struct sk_buff *skb;
 
-	skb = nlmsg_new(xfrm_aevent_msgsize(), GFP_ATOMIC);
+	skb = nlmsg_new(xfrm_aevent_msgsize(x), GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
@@ -2303,6 +2372,8 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 		l += nla_total_size(sizeof(*x->calg));
 	if (x->encap)
 		l += nla_total_size(sizeof(*x->encap));
+	if (x->replay_esn)
+		l += nla_total_size(xfrm_replay_state_esn_len(x->replay_esn));
 	if (x->security)
 		l += nla_total_size(sizeof(struct xfrm_user_sec_ctx) +
 				    x->security->ctx_len);
-- 
1.7.0.4
