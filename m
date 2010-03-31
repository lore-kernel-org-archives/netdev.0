From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH 3/4] xfrm: remove policy lock when accessing policy->walk.dead
Date: Wed, 31 Mar 2010 13:17:05 +0300
Message-ID: <1270030626-16687-5-git-send-email-timo.teras@iki.fi>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:34536 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933203Ab0CaKRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 06:17:31 -0400
Received: by mail-ew0-f220.google.com with SMTP id 20so1817152ewy.1
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 03:17:30 -0700 (PDT)
In-Reply-To: <1270030626-16687-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All of the code considers ->dead as a hint that the cached policy
needs to get refreshed. The read side can just drop the read lock
without any side effects.

The write side needs to make sure that it's written only exactly
once. Only possible race is at xfrm_policy_kill(). This is fixed
by checking result of __xfrm_policy_unlink() when needed. It will
always succeed if the policy object is looked up from the hash
list (so some checks are removed), but it needs to be checked if
we are trying to unlink policy via a reference (appropriate
checks added).

Since policy->walk.dead is written exactly once, it no longer
needs to be protected with a write lock.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
 net/xfrm/xfrm_policy.c |   31 +++++++++----------------------
 net/xfrm/xfrm_user.c   |    6 +-----
 2 files changed, 10 insertions(+), 27 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 843e066..82789cf 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -156,7 +156,7 @@ static void xfrm_policy_timer(unsigned long data)
 
 	read_lock(&xp->lock);
 
-	if (xp->walk.dead)
+	if (unlikely(xp->walk.dead))
 		goto out;
 
 	dir = xfrm_policy_id2dir(xp->index);
@@ -297,17 +297,7 @@ static DECLARE_WORK(xfrm_policy_gc_work, xfrm_policy_gc_task);
 
 static void xfrm_policy_kill(struct xfrm_policy *policy)
 {
-	int dead;
-
-	write_lock_bh(&policy->lock);
-	dead = policy->walk.dead;
 	policy->walk.dead = 1;
-	write_unlock_bh(&policy->lock);
-
-	if (unlikely(dead)) {
-		WARN_ON(1);
-		return;
-	}
 
 	spin_lock_bh(&xfrm_policy_gc_lock);
 	hlist_add_head(&policy->bydst, &xfrm_policy_gc_list);
@@ -776,7 +766,6 @@ xfrm_policy_flush_secctx_check(struct net *net, u8 type, struct xfrm_audit *audi
 int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 {
 	int dir, err = 0, cnt = 0;
-	struct xfrm_policy *dp;
 
 	write_lock_bh(&xfrm_policy_lock);
 
@@ -794,10 +783,9 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 				     &net->xfrm.policy_inexact[dir], bydst) {
 			if (pol->type != type)
 				continue;
-			dp = __xfrm_policy_unlink(pol, dir);
+			__xfrm_policy_unlink(pol, dir);
 			write_unlock_bh(&xfrm_policy_lock);
-			if (dp)
-				cnt++;
+			cnt++;
 
 			xfrm_audit_policy_delete(pol, 1, audit_info->loginuid,
 						 audit_info->sessionid,
@@ -816,10 +804,9 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 					     bydst) {
 				if (pol->type != type)
 					continue;
-				dp = __xfrm_policy_unlink(pol, dir);
+				__xfrm_policy_unlink(pol, dir);
 				write_unlock_bh(&xfrm_policy_lock);
-				if (dp)
-					cnt++;
+				cnt++;
 
 				xfrm_audit_policy_delete(pol, 1,
 							 audit_info->loginuid,
@@ -1132,6 +1119,9 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 		__xfrm_policy_link(pol, XFRM_POLICY_MAX+dir);
 	}
 	if (old_pol)
+		/* Unlinking succeeds always. This is the only function
+		 * allowed to delete or replace socket policy.
+		 */
 		__xfrm_policy_unlink(old_pol, XFRM_POLICY_MAX+dir);
 	write_unlock_bh(&xfrm_policy_lock);
 
@@ -1737,11 +1727,8 @@ restart:
 			goto error;
 		}
 
-		for (pi = 0; pi < npols; pi++) {
-			read_lock_bh(&pols[pi]->lock);
+		for (pi = 0; pi < npols; pi++)
 			pol_dead |= pols[pi]->walk.dead;
-			read_unlock_bh(&pols[pi]->lock);
-		}
 
 		write_lock_bh(&policy->lock);
 		if (unlikely(pol_dead || stale_bundle(dst))) {
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index da5ba86..a267fbd 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1770,13 +1770,9 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (xp == NULL)
 		return -ENOENT;
 
-	read_lock(&xp->lock);
-	if (xp->walk.dead) {
-		read_unlock(&xp->lock);
+	if (unlikely(xp->walk.dead))
 		goto out;
-	}
 
-	read_unlock(&xp->lock);
 	err = 0;
 	if (up->hard) {
 		uid_t loginuid = NETLINK_CB(skb).loginuid;
-- 
1.6.3.3

