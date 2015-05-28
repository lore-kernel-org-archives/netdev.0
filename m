From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 7/7] xfrm: optimise to search the inexact policy list
Date: Thu, 28 May 2015 08:25:54 +0200
Message-ID: <1432794354-19391-8-git-send-email-steffen.klassert@secunet.com>
References: <1432794354-19391-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50015 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752172AbbE1G00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 02:26:26 -0400
In-Reply-To: <1432794354-19391-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

The policies are organized into list by priority ascent of policy,
so it is unnecessary to continue to loop the policy if the priority
of current looped police is larger than or equal priority which is
from the policy_bydst list.

This allows to match policy with ~0U priority in inexact list too.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 3d264e5..18cead7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1114,6 +1114,9 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 	}
 	chain = &net->xfrm.policy_inexact[dir];
 	hlist_for_each_entry(pol, chain, bydst) {
+		if ((pol->priority >= priority) && ret)
+			break;
+
 		err = xfrm_policy_match(pol, fl, type, family, dir);
 		if (err) {
 			if (err == -ESRCH)
@@ -1122,7 +1125,7 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 				ret = ERR_PTR(err);
 				goto fail;
 			}
-		} else if (pol->priority < priority) {
+		} else {
 			ret = pol;
 			break;
 		}
@@ -3203,9 +3206,11 @@ static struct xfrm_policy *xfrm_migrate_policy_find(const struct xfrm_selector *
 	}
 	chain = &net->xfrm.policy_inexact[dir];
 	hlist_for_each_entry(pol, chain, bydst) {
+		if ((pol->priority >= priority) && ret)
+			break;
+
 		if (xfrm_migrate_selector_match(sel, &pol->selector) &&
-		    pol->type == type &&
-		    pol->priority < priority) {
+		    pol->type == type) {
 			ret = pol;
 			break;
 		}
-- 
1.9.1
