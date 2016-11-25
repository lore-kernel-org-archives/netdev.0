From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/3] xfrm: unbreak xfrm_sk_policy_lookup
Date: Fri, 25 Nov 2016 07:57:59 +0100
Message-ID: <1480057080-20177-3-git-send-email-steffen.klassert@secunet.com>
References: <1480057080-20177-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mx.secunet.com ([62.96.220.56]:45294 "EHLO c.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752810AbcKYHHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 02:07:25 -0500
In-Reply-To: <1480057080-20177-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

if we succeed grabbing the refcount, then
  if (err && !xfrm_pol_hold_rcu)

will evaluate to false so this hits last else branch which then
sets policy to ERR_PTR(0).

Fixes: ae33786f73a7ce ("xfrm: policy: only use rcu in xfrm_sk_policy_lookup")
Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Tested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index fd69866..5bf7e1bf 100644
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
1.9.1
