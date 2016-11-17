From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec] xfrm: unbreak xfrm_sk_policy_lookup
Date: Thu, 17 Nov 2016 13:21:46 +0100
Message-ID: <1479385306-24731-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:55672 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932790AbcKQSSs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 13:18:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if we succeed grabbing the refcount, then
  if (err && !xfrm_pol_hold_rcu)

will evaluate to false so this hits last else branch which then
sets policy to ERR_PTR(0).

Fixes: ae33786f73a7ce ("xfrm: policy: only use rcu in xfrm_sk_policy_lookup")
Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Tested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_policy.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index fd6986634e6f..5bf7e1bfeac7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1268,12 +1268,14 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(const struct sock *sk, int dir,
 			err = security_xfrm_policy_lookup(pol->security,
 						      fl->flowi_secid,
 						      policy_to_flow_dir(dir));
-			if (!err && !xfrm_pol_hold_rcu(pol))
-				goto again;
-			else if (err == -ESRCH)
+			if (!err) {
+				if (!xfrm_pol_hold_rcu(pol))
+					goto again;
+			} else if (err == -ESRCH) {
 				pol = NULL;
-			else
+			} else {
 				pol = ERR_PTR(err);
+			}
 		} else
 			pol = NULL;
 	}
-- 
2.7.3
