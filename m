From: Fan Du <fan.du@windriver.com>
Subject: [PATCH v2] XFRM: remove redundant parameter "int dir" in struct xfrm_mgr.acquire
Date: Wed, 15 Aug 2012 10:13:47 +0800
Message-ID: <1344996827-20620-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:41489 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980Ab2HOCNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 22:13:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sematically speaking, xfrm_mgr.acquire is called when kernel intends to ask
user space IKE daemon to negotiate SAs with peers. IOW the direction will
*always* be XFRM_POLICY_OUT, so remove int dir for clarity.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
Changelog for V2:
	- Remove "int dir" in build_acquire parameter suggested by Steffen Klassert.


 include/net/xfrm.h    |    2 +-
 net/key/af_key.c      |    4 ++--
 net/xfrm/xfrm_state.c |    2 +-
 net/xfrm/xfrm_user.c  |    9 ++++-----
 4 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 62b619e..5e1662d 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -571,7 +571,7 @@ struct xfrm_mgr {
 	struct list_head	list;
 	char			*id;
 	int			(*notify)(struct xfrm_state *x, const struct km_event *c);
-	int			(*acquire)(struct xfrm_state *x, struct xfrm_tmpl *, struct xfrm_policy *xp, int dir);
+	int			(*acquire)(struct xfrm_state *x, struct xfrm_tmpl *, struct xfrm_policy *xp);
 	struct xfrm_policy	*(*compile_policy)(struct sock *sk, int opt, u8 *data, int len, int *dir);
 	int			(*new_mapping)(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport);
 	int			(*notify_policy)(struct xfrm_policy *x, int dir, const struct km_event *c);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 34e4185..ec7d161 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3024,7 +3024,7 @@ static u32 get_acqseq(void)
 	return res;
 }
 
-static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *xp, int dir)
+static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *xp)
 {
 	struct sk_buff *skb;
 	struct sadb_msg *hdr;
@@ -3105,7 +3105,7 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 	pol->sadb_x_policy_len = sizeof(struct sadb_x_policy)/sizeof(uint64_t);
 	pol->sadb_x_policy_exttype = SADB_X_EXT_POLICY;
 	pol->sadb_x_policy_type = IPSEC_POLICY_IPSEC;
-	pol->sadb_x_policy_dir = dir+1;
+	pol->sadb_x_policy_dir = XFRM_POLICY_OUT + 1;
 	pol->sadb_x_policy_id = xp->index;
 
 	/* Set sadb_comb's. */
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 87cd0e4..7856c33 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1700,7 +1700,7 @@ int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol)
 
 	read_lock(&xfrm_km_lock);
 	list_for_each_entry(km, &xfrm_km_list, list) {
-		acqret = km->acquire(x, t, pol, XFRM_POLICY_OUT);
+		acqret = km->acquire(x, t, pol);
 		if (!acqret)
 			err = acqret;
 	}
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index e75d8e4..ab58034 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2567,8 +2567,7 @@ static inline size_t xfrm_acquire_msgsize(struct xfrm_state *x,
 }
 
 static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
-			 struct xfrm_tmpl *xt, struct xfrm_policy *xp,
-			 int dir)
+			 struct xfrm_tmpl *xt, struct xfrm_policy *xp)
 {
 	__u32 seq = xfrm_get_acqseq();
 	struct xfrm_user_acquire *ua;
@@ -2583,7 +2582,7 @@ static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 	memcpy(&ua->id, &x->id, sizeof(ua->id));
 	memcpy(&ua->saddr, &x->props.saddr, sizeof(ua->saddr));
 	memcpy(&ua->sel, &x->sel, sizeof(ua->sel));
-	copy_to_user_policy(xp, &ua->policy, dir);
+	copy_to_user_policy(xp, &ua->policy, XFRM_POLICY_OUT);
 	ua->aalgos = xt->aalgos;
 	ua->ealgos = xt->ealgos;
 	ua->calgos = xt->calgos;
@@ -2605,7 +2604,7 @@ static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 }
 
 static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *xt,
-			     struct xfrm_policy *xp, int dir)
+			     struct xfrm_policy *xp)
 {
 	struct net *net = xs_net(x);
 	struct sk_buff *skb;
@@ -2614,7 +2613,7 @@ static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *xt,
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_acquire(skb, x, xt, xp, dir) < 0)
+	if (build_acquire(skb, x, xt, xp) < 0)
 		BUG();
 
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_ACQUIRE, GFP_ATOMIC);
-- 
1.7.1
