From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/6] xfrm: Ignore socket policies when rebuilding hash tables
Date: Thu, 8 Sep 2016 08:29:13 +0200
Message-ID: <1473316155-12186-5-git-send-email-steffen.klassert@secunet.com>
References: <1473316155-12186-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35822 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754582AbcIHG3d (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:29:33 -0400
In-Reply-To: <1473316155-12186-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Brunner <tobias@strongswan.org>

Whenever thresholds are changed the hash tables are rebuilt.  This is
done by enumerating all policies and hashing and inserting them into
the right table according to the thresholds and direction.

Because socket policies are also contained in net->xfrm.policy_all but
no hash tables are defined for their direction (dir + XFRM_POLICY_MAX)
this causes a NULL or invalid pointer dereference after returning from
policy_hash_bysel() if the rebuild is done while any socket policies
are installed.

Since the rebuild after changing thresholds is scheduled this crash
could even occur if the userland sets thresholds seemingly before
installing any socket policies.

Fixes: 53c2e285f970 ("xfrm: Do not hash socket policies")
Signed-off-by: Tobias Brunner <tobias@strongswan.org>
Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b5e665b..45f9cf9 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -626,6 +626,10 @@ static void xfrm_hash_rebuild(struct work_struct *work)
 
 	/* re-insert all policies by order of creation */
 	list_for_each_entry_reverse(policy, &net->xfrm.policy_all, walk.all) {
+		if (xfrm_policy_id2dir(policy->index) >= XFRM_POLICY_MAX) {
+			/* skip socket policies */
+			continue;
+		}
 		newpos = NULL;
 		chain = policy_hash_bysel(net, &policy->selector,
 					  policy->family,
-- 
1.9.1
