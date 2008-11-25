From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 32/53] netns xfrm: finding policy in netns
Date: Tue, 25 Nov 2008 20:27:04 +0300
Message-ID: <1227634045-27534-32-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-23-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-24-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-25-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-26-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-27-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-28-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-29-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-30-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-31-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:64013 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbYKYRY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:24:56 -0500
Received: by nf-out-0910.google.com with SMTP id d3so28343nfc.21
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:24:54 -0800 (PST)
In-Reply-To: <1227634045-27534-31-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netns parameter to xfrm_policy_bysel_ctx(), xfrm_policy_byidx().

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/xfrm.h     |    4 ++--
 net/key/af_key.c       |    6 +++---
 net/xfrm/xfrm_policy.c |   14 +++++++-------
 net/xfrm/xfrm_user.c   |    8 ++++----
 4 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 766cc71..ec2b7a9 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1439,11 +1439,11 @@ extern int xfrm_policy_walk(struct xfrm_policy_walk *walk,
 	int (*func)(struct xfrm_policy *, int, int, void*), void *);
 extern void xfrm_policy_walk_done(struct xfrm_policy_walk *walk);
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl);
-struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
+struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u8 type, int dir,
 					  struct xfrm_selector *sel,
 					  struct xfrm_sec_ctx *ctx, int delete,
 					  int *err);
-struct xfrm_policy *xfrm_policy_byid(u8, int dir, u32 id, int delete, int *err);
+struct xfrm_policy *xfrm_policy_byid(struct net *net, u8, int dir, u32 id, int delete, int *err);
 int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info);
 u32 xfrm_get_acqseq(void);
 extern int xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 0f44856..ca26811 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2324,7 +2324,7 @@ static int pfkey_spddelete(struct sock *sk, struct sk_buff *skb, struct sadb_msg
 			return err;
 	}
 
-	xp = xfrm_policy_bysel_ctx(XFRM_POLICY_TYPE_MAIN,
+	xp = xfrm_policy_bysel_ctx(&init_net, XFRM_POLICY_TYPE_MAIN,
 				   pol->sadb_x_policy_dir - 1, &sel, pol_ctx,
 				   1, &err);
 	security_xfrm_policy_free(pol_ctx);
@@ -2571,8 +2571,8 @@ static int pfkey_spdget(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
 		return -EINVAL;
 
 	delete = (hdr->sadb_msg_type == SADB_X_SPDDELETE2);
-	xp = xfrm_policy_byid(XFRM_POLICY_TYPE_MAIN, dir, pol->sadb_x_policy_id,
-			      delete, &err);
+	xp = xfrm_policy_byid(&init_net, XFRM_POLICY_TYPE_MAIN, dir,
+			      pol->sadb_x_policy_id, delete, &err);
 	if (xp == NULL)
 		return -ENOENT;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7c264a7..96895ef 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -642,7 +642,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 }
 EXPORT_SYMBOL(xfrm_policy_insert);
 
-struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
+struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u8 type, int dir,
 					  struct xfrm_selector *sel,
 					  struct xfrm_sec_ctx *ctx, int delete,
 					  int *err)
@@ -653,7 +653,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
 
 	*err = 0;
 	write_lock_bh(&xfrm_policy_lock);
-	chain = policy_hash_bysel(&init_net, sel, sel->family, dir);
+	chain = policy_hash_bysel(net, sel, sel->family, dir);
 	ret = NULL;
 	hlist_for_each_entry(pol, entry, chain, bydst) {
 		if (pol->type == type &&
@@ -670,7 +670,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
 				hlist_del(&pol->bydst);
 				hlist_del(&pol->byidx);
 				list_del(&pol->walk.all);
-				init_net.xfrm.policy_count[dir]--;
+				net->xfrm.policy_count[dir]--;
 			}
 			ret = pol;
 			break;
@@ -686,8 +686,8 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
 }
 EXPORT_SYMBOL(xfrm_policy_bysel_ctx);
 
-struct xfrm_policy *xfrm_policy_byid(u8 type, int dir, u32 id, int delete,
-				     int *err)
+struct xfrm_policy *xfrm_policy_byid(struct net *net, u8 type, int dir, u32 id,
+				     int delete, int *err)
 {
 	struct xfrm_policy *pol, *ret;
 	struct hlist_head *chain;
@@ -699,7 +699,7 @@ struct xfrm_policy *xfrm_policy_byid(u8 type, int dir, u32 id, int delete,
 
 	*err = 0;
 	write_lock_bh(&xfrm_policy_lock);
-	chain = init_net.xfrm.policy_byidx + idx_hash(&init_net, id);
+	chain = net->xfrm.policy_byidx + idx_hash(net, id);
 	ret = NULL;
 	hlist_for_each_entry(pol, entry, chain, byidx) {
 		if (pol->type == type && pol->index == id) {
@@ -714,7 +714,7 @@ struct xfrm_policy *xfrm_policy_byid(u8 type, int dir, u32 id, int delete,
 				hlist_del(&pol->bydst);
 				hlist_del(&pol->byidx);
 				list_del(&pol->walk.all);
-				init_net.xfrm.policy_count[dir]--;
+				net->xfrm.policy_count[dir]--;
 			}
 			ret = pol;
 			break;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index d4983e8..efd6ab5 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1330,7 +1330,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return err;
 
 	if (p->index)
-		xp = xfrm_policy_byid(type, p->dir, p->index, delete, &err);
+		xp = xfrm_policy_byid(&init_net, type, p->dir, p->index, delete, &err);
 	else {
 		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
 		struct xfrm_sec_ctx *ctx;
@@ -1347,7 +1347,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 			if (err)
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, ctx,
+		xp = xfrm_policy_bysel_ctx(&init_net, type, p->dir, &p->sel, ctx,
 					   delete, &err);
 		security_xfrm_policy_free(ctx);
 	}
@@ -1571,7 +1571,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return err;
 
 	if (p->index)
-		xp = xfrm_policy_byid(type, p->dir, p->index, 0, &err);
+		xp = xfrm_policy_byid(&init_net, type, p->dir, p->index, 0, &err);
 	else {
 		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
 		struct xfrm_sec_ctx *ctx;
@@ -1588,7 +1588,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 			if (err)
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, ctx, 0, &err);
+		xp = xfrm_policy_bysel_ctx(&init_net, type, p->dir, &p->sel, ctx, 0, &err);
 		security_xfrm_policy_free(ctx);
 	}
 	if (xp == NULL)
-- 
1.5.6.5

