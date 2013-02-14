From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 7/7] xfrm: Allow inserting policies with matching mark and different priorities
Date: Thu, 14 Feb 2013 12:47:27 +0100
Message-ID: <1360842447-3344-8-git-send-email-steffen.klassert@secunet.com>
References: <1360842447-3344-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44538 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934317Ab3BNLr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 06:47:58 -0500
In-Reply-To: <1360842447-3344-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently can not insert policies with mark and mask
such that some flows would be matched from both policies.
We make this possible when the priority of these policies
are different. If both policies match a flow, the one with
the higher priority is used.

Reported-by: Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>
Reported-by: Romain Kuntz <r.kuntz@ipflavors.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 456b11b..257dfb1 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -607,6 +607,21 @@ static void xfrm_policy_requeue(struct xfrm_policy *old,
 	spin_unlock_bh(&pq->hold_queue.lock);
 }
 
+static bool xfrm_policy_mark_match(struct xfrm_policy *policy,
+				   struct xfrm_policy *pol)
+{
+	u32 mark = policy->mark.v & policy->mark.m;
+
+	if (policy->mark.v == pol->mark.v && policy->mark.m == pol->mark.m)
+		return true;
+
+	if ((mark & pol->mark.m) == pol->mark.v &&
+	    policy->priority == pol->priority)
+		return true;
+
+	return false;
+}
+
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 {
 	struct net *net = xp_net(policy);
@@ -614,7 +629,6 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	struct xfrm_policy *delpol;
 	struct hlist_head *chain;
 	struct hlist_node *entry, *newpos;
-	u32 mark = policy->mark.v & policy->mark.m;
 
 	write_lock_bh(&xfrm_policy_lock);
 	chain = policy_hash_bysel(net, &policy->selector, policy->family, dir);
@@ -623,7 +637,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	hlist_for_each_entry(pol, entry, chain, bydst) {
 		if (pol->type == policy->type &&
 		    !selector_cmp(&pol->selector, &policy->selector) &&
-		    (mark & pol->mark.m) == pol->mark.v &&
+		    xfrm_policy_mark_match(policy, pol) &&
 		    xfrm_sec_ctx_match(pol->security, policy->security) &&
 		    !WARN_ON(delpol)) {
 			if (excl) {
-- 
1.7.9.5
