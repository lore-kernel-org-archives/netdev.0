From: Tobias Brunner <tobias@strongswan.org>
Subject: [PATCH ipsec] xfrm: Ignore socket policies when rebuilding hash
 tables
Date: Fri, 29 Jul 2016 09:57:32 +0200
Message-ID: <8e6b1395-6f17-66ce-e257-6b6073ca7103@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Christophe Gouault <christophe.gouault@6wind.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sitav-80046.hsr.ch ([152.96.80.46]:49686 "EHLO
	mail.strongswan.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbcG2IHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 04:07:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 net/xfrm/xfrm_policy.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b5e665b3cfb0..45f9cf97ea25 100644
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
