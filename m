From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/5] xfrm: Use __xfrm_policy_link in xfrm_policy_insert
Date: Wed, 3 Dec 2014 11:05:00 +0100
Message-ID: <1417601101-18625-5-git-send-email-steffen.klassert@secunet.com>
References: <1417601101-18625-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33455 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751401AbaLCKF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 05:05:26 -0500
In-Reply-To: <1417601101-18625-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>

For a long time we couldn't actually use __xfrm_policy_link in
xfrm_policy_insert because the latter wanted to do hashing at
a specific position.

Now that __xfrm_policy_link no longer does hashing it can now
be safely used in xfrm_policy_insert to kill some duplicate code,
finally reuniting general policies with socket policies.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index f4d3a12..178fa0e 100644
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
-- 
1.9.1
