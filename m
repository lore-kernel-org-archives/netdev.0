From: <rongqing.li@windriver.com>
Subject: [PATCH] xfrm: optimise to search the inexact policy list
Date: Thu, 14 May 2015 11:16:59 +0800
Message-ID: <1431573419-31253-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47606 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170AbbENDSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 23:18:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

The policies are organized into list by priority ascent of policy,
so it is unnecessary to continue to loop the policy if the priority
of current looped police is larger than or equal priority which is
from the policy_bydst list.

This allows to match policy with ~0U priority in inexact list too.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
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
2.1.4
