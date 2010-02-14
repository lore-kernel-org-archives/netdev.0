From: jamal <hadi@cyberus.ca>
Subject: [net-next-2.6 PATCH 4/7] xfrm: SP lookups signature with mark
Date: Sun, 14 Feb 2010 10:18:49 -0500
Message-ID: <1266160732-946-5-git-send-email-hadi@cyberus.ca>
References: <xfrm-mark-net-next>
 <1266160732-946-1-git-send-email-hadi@cyberus.ca>
 <1266160732-946-2-git-send-email-hadi@cyberus.ca>
 <1266160732-946-3-git-send-email-hadi@cyberus.ca>
 <1266160732-946-4-git-send-email-hadi@cyberus.ca>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: timo.teras@iki.fi, kaber@trash.net, herbert@gondor.apana.org.au,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:8739 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322Ab0BNPTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 10:19:09 -0500
Received: by qw-out-2122.google.com with SMTP id 5so313017qwi.37
        for <netdev@vger.kernel.org>; Sun, 14 Feb 2010 07:19:08 -0800 (PST)
In-Reply-To: <1266160732-946-4-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

pass mark to all SP lookups to prepare them for when we add code
to have them search.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 include/net/xfrm.h     |    5 +++--
 net/key/af_key.c       |    4 ++--
 net/xfrm/xfrm_policy.c |    8 ++++----
 net/xfrm/xfrm_user.c   |   10 +++++-----
 4 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 96b6953..676f71b 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1456,11 +1456,12 @@ extern int xfrm_policy_walk(struct net *net, struct xfrm_policy_walk *walk,
 	int (*func)(struct xfrm_policy *, int, int, void*), void *);
 extern void xfrm_policy_walk_done(struct xfrm_policy_walk *walk);
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl);
-struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u8 type, int dir,
+struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark,
+					  u8 type, int dir,
 					  struct xfrm_selector *sel,
 					  struct xfrm_sec_ctx *ctx, int delete,
 					  int *err);
-struct xfrm_policy *xfrm_policy_byid(struct net *net, u8, int dir, u32 id, int delete, int *err);
+struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8, int dir, u32 id, int delete, int *err);
 int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info);
 u32 xfrm_get_acqseq(void);
 extern int xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 4d652c8..31c87df 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2348,7 +2348,7 @@ static int pfkey_spddelete(struct sock *sk, struct sk_buff *skb, struct sadb_msg
 			return err;
 	}
 
-	xp = xfrm_policy_bysel_ctx(net, XFRM_POLICY_TYPE_MAIN,
+	xp = xfrm_policy_bysel_ctx(net, DUMMY_MARK, XFRM_POLICY_TYPE_MAIN,
 				   pol->sadb_x_policy_dir - 1, &sel, pol_ctx,
 				   1, &err);
 	security_xfrm_policy_free(pol_ctx);
@@ -2596,7 +2596,7 @@ static int pfkey_spdget(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
 		return -EINVAL;
 
 	delete = (hdr->sadb_msg_type == SADB_X_SPDDELETE2);
-	xp = xfrm_policy_byid(net, XFRM_POLICY_TYPE_MAIN,
+	xp = xfrm_policy_byid(net, DUMMY_MARK, XFRM_POLICY_TYPE_MAIN,
 			      dir, pol->sadb_x_policy_id, delete, &err);
 	if (xp == NULL)
 		return -ENOENT;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 0ecb16a..e804aa5 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -635,8 +635,8 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 }
 EXPORT_SYMBOL(xfrm_policy_insert);
 
-struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u8 type, int dir,
-					  struct xfrm_selector *sel,
+struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark, u8 type,
+					  int dir, struct xfrm_selector *sel,
 					  struct xfrm_sec_ctx *ctx, int delete,
 					  int *err)
 {
@@ -676,8 +676,8 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u8 type, int dir,
 }
 EXPORT_SYMBOL(xfrm_policy_bysel_ctx);
 
-struct xfrm_policy *xfrm_policy_byid(struct net *net, u8 type, int dir, u32 id,
-				     int delete, int *err)
+struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8 type,
+				     int dir, u32 id, int delete, int *err)
 {
 	struct xfrm_policy *pol, *ret;
 	struct hlist_head *chain;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index a2c9823..6abe4c0 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1457,7 +1457,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return err;
 
 	if (p->index)
-		xp = xfrm_policy_byid(net, type, p->dir, p->index, delete, &err);
+		xp = xfrm_policy_byid(net, DUMMY_MARK, type, p->dir, p->index, delete, &err);
 	else {
 		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
 		struct xfrm_sec_ctx *ctx;
@@ -1474,8 +1474,8 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 			if (err)
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(net, type, p->dir, &p->sel, ctx,
-					   delete, &err);
+		xp = xfrm_policy_bysel_ctx(net, DUMMY_MARK, type, p->dir,
+					   &p->sel, ctx, delete, &err);
 		security_xfrm_policy_free(ctx);
 	}
 	if (xp == NULL)
@@ -1705,7 +1705,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return err;
 
 	if (p->index)
-		xp = xfrm_policy_byid(net, type, p->dir, p->index, 0, &err);
+		xp = xfrm_policy_byid(net, DUMMY_MARK, type, p->dir, p->index, 0, &err);
 	else {
 		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
 		struct xfrm_sec_ctx *ctx;
@@ -1722,7 +1722,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 			if (err)
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(net, type, p->dir, &p->sel, ctx, 0, &err);
+		xp = xfrm_policy_bysel_ctx(net, DUMMY_MARK, type, p->dir, &p->sel, ctx, 0, &err);
 		security_xfrm_policy_free(ctx);
 	}
 	if (xp == NULL)
-- 
1.6.0.4

