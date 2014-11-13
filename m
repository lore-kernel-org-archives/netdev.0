From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/2] xfrm: Use __xfrm_policy_link in xfrm_policy_insert
Date: Thu, 13 Nov 2014 17:01:39 +0800
Message-ID: <E1XoqHb-0000pi-CB@gondolin.me.apana.org.au>
References: <20141113090048.GA3120@gondor.apana.org.au>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:42645 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932165AbaKMJBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 04:01:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For a long time we couldn't actually use __xfrm_policy_link in
xfrm_policy_insert because the latter wanted to do hashing at
a specific position.

Now that __xfrm_policy_link no longer does hashing it can now
be safely used in xfrm_policy_insert to kill some duplicate code,
finally reuniting general policies with socket policies.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/xfrm/xfrm_policy.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 2c4daf2..0a69c87 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -55,6 +55,7 @@ static int stale_bundle(struct dst_entry *dst);
 static int xfrm_bundle_ok(struct xfrm_dst *xdst);
 static void xfrm_policy_queue_process(unsigned long arg);
 
+static void __xfrm_policy_link(struct xfrm_policy *pol, int dir);
 static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 						int dir);
 
@@ -779,8 +780,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 		hlist_add_behind(&policy->bydst, newpos);
 	else
 		hlist_add_head(&policy->bydst, chain);
-	xfrm_pol_hold(policy);
-	net->xfrm.policy_count[dir]++;
+	__xfrm_policy_link(policy, dir);
 	atomic_inc(&net->xfrm.flow_cache_genid);
 
 	/* After previous checking, family can either be AF_INET or AF_INET6 */
@@ -799,7 +799,6 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	policy->curlft.use_time = 0;
 	if (!mod_timer(&policy->timer, jiffies + HZ))
 		xfrm_pol_hold(policy);
-	list_add(&policy->walk.all, &net->xfrm.policy_all);
 	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	if (delpol)
