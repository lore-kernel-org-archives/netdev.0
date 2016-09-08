From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 11/17] xfrm: policy: use atomic_inc_not_zero in rcu section
Date: Thu, 8 Sep 2016 07:54:46 +0200
Message-ID: <1473314092-11319-12-git-send-email-steffen.klassert@secunet.com>
References: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36351 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753817AbcIHGvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:51:25 -0400
In-Reply-To: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

If we don't hold the policy lock anymore the refcnt might
already be 0, i.e. policy struct is about to be free'd.

Switch to atomic_inc_not_zero to avoid this.

On removal policies are already unlinked from the tables (lists)
before the last _put occurs so we are not supposed to find the same
'dead' entry on the next loop, so its safe to just repeat the lookup.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 576d903..09f2e2b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -60,6 +60,11 @@ static void __xfrm_policy_link(struct xfrm_policy *pol, int dir);
 static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 						int dir);
 
+static inline bool xfrm_pol_hold_rcu(struct xfrm_policy *policy)
+{
+	return atomic_inc_not_zero(&policy->refcnt);
+}
+
 static inline bool
 __xfrm4_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 {
@@ -1164,7 +1169,8 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 	if (read_seqcount_retry(&xfrm_policy_hash_generation, sequence))
 		goto retry;
 
-	xfrm_pol_hold(ret);
+	if (ret && !xfrm_pol_hold_rcu(ret))
+		goto retry;
 fail:
 	read_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
-- 
1.9.1
