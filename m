From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/2] xfrm: Do not hash socket policies
Date: Thu, 13 Nov 2014 17:01:38 +0800
Message-ID: <E1XoqHa-0000pL-2k@gondolin.me.apana.org.au>
References: <20141113090048.GA3120@gondor.apana.org.au>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:58718 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932094AbaKMJBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 04:01:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Back in 2003 when I added policy expiration, I half-heartedly
did a clean-up and renamed xfrm_sk_policy_link/xfrm_sk_policy_unlink
to __xfrm_policy_link/__xfrm_policy_unlink, because the latter
could be reused for all policies.  I never actually got around
to using __xfrm_policy_link for non-socket policies.

Later on hashing was added to all xfrm policies, including socket
policies.  In fact, we don't need hashing on socket policies at
all since they're always looked up via a linked list.

This patch restores xfrm_sk_policy_link/xfrm_sk_policy_unlink
as wrappers around __xfrm_policy_link/__xfrm_policy_unlink so
that it's obvious we're dealing with socket policies.

This patch also removes hashing from __xfrm_policy_link as for
now it's only used by socket policies which do not need to be
hashed.  Ironically this will in fact allow us to use this helper
for non-socket policies which I shall do later.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/netns/xfrm.h |    4 ++--
 net/xfrm/xfrm_policy.c   |   35 +++++++++++++++++++++--------------
 2 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 9da7982..730d82a 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -50,8 +50,8 @@ struct netns_xfrm {
 	struct list_head	policy_all;
 	struct hlist_head	*policy_byidx;
 	unsigned int		policy_idx_hmask;
-	struct hlist_head	policy_inexact[XFRM_POLICY_MAX * 2];
-	struct xfrm_policy_hash	policy_bydst[XFRM_POLICY_MAX * 2];
+	struct hlist_head	policy_inexact[XFRM_POLICY_MAX];
+	struct xfrm_policy_hash	policy_bydst[XFRM_POLICY_MAX];
 	unsigned int		policy_count[XFRM_POLICY_MAX * 2];
 	struct work_struct	policy_hash_work;
 	struct xfrm_policy_hthresh policy_hthresh;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 88bf289..2c4daf2 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1247,17 +1247,10 @@ out:
 static void __xfrm_policy_link(struct xfrm_policy *pol, int dir)
 {
 	struct net *net = xp_net(pol);
-	struct hlist_head *chain = policy_hash_bysel(net, &pol->selector,
-						     pol->family, dir);
 
 	list_add(&pol->walk.all, &net->xfrm.policy_all);
-	hlist_add_head(&pol->bydst, chain);
-	hlist_add_head(&pol->byidx, net->xfrm.policy_byidx+idx_hash(net, pol->index));
 	net->xfrm.policy_count[dir]++;
 	xfrm_pol_hold(pol);
-
-	if (xfrm_bydst_should_resize(net, dir, NULL))
-		schedule_work(&net->xfrm.policy_hash_work);
 }
 
 static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
@@ -1265,17 +1258,31 @@ static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 {
 	struct net *net = xp_net(pol);
 
-	if (hlist_unhashed(&pol->bydst))
+	if (list_empty(&pol->walk.all))
 		return NULL;
 
-	hlist_del_init(&pol->bydst);
-	hlist_del(&pol->byidx);
-	list_del(&pol->walk.all);
+	/* Socket policies are not hashed. */
+	if (!hlist_unhashed(&pol->bydst)) {
+		hlist_del(&pol->bydst);
+		hlist_del(&pol->byidx);
+	}
+
+	list_del_init(&pol->walk.all);
 	net->xfrm.policy_count[dir]--;
 
 	return pol;
 }
 
+static void xfrm_sk_policy_link(struct xfrm_policy *pol, int dir)
+{
+	__xfrm_policy_link(pol, XFRM_POLICY_MAX + dir);
+}
+
+static void xfrm_sk_policy_unlink(struct xfrm_policy *pol, int dir)
+{
+	__xfrm_policy_unlink(pol, XFRM_POLICY_MAX + dir);
+}
+
 int xfrm_policy_delete(struct xfrm_policy *pol, int dir)
 {
 	struct net *net = xp_net(pol);
@@ -1307,7 +1314,7 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 	if (pol) {
 		pol->curlft.add_time = get_seconds();
 		pol->index = xfrm_gen_index(net, XFRM_POLICY_MAX+dir, 0);
-		__xfrm_policy_link(pol, XFRM_POLICY_MAX+dir);
+		xfrm_sk_policy_link(pol, dir);
 	}
 	if (old_pol) {
 		if (pol)
@@ -1316,7 +1323,7 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 		/* Unlinking succeeds always. This is the only function
 		 * allowed to delete or replace socket policy.
 		 */
-		__xfrm_policy_unlink(old_pol, XFRM_POLICY_MAX+dir);
+		xfrm_sk_policy_unlink(old_pol, dir);
 	}
 	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
@@ -1349,7 +1356,7 @@ static struct xfrm_policy *clone_policy(const struct xfrm_policy *old, int dir)
 		memcpy(newp->xfrm_vec, old->xfrm_vec,
 		       newp->xfrm_nr*sizeof(struct xfrm_tmpl));
 		write_lock_bh(&net->xfrm.xfrm_policy_lock);
-		__xfrm_policy_link(newp, XFRM_POLICY_MAX+dir);
+		xfrm_sk_policy_link(newp, dir);
 		write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 		xfrm_pol_put(newp);
 	}
