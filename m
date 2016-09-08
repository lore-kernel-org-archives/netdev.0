From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 13/17] xfrm: policy: only use rcu in xfrm_sk_policy_lookup
Date: Thu, 8 Sep 2016 07:54:48 +0200
Message-ID: <1473314092-11319-14-git-send-email-steffen.klassert@secunet.com>
References: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36353 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754211AbcIHGvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:51:25 -0400
In-Reply-To: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Don't acquire the readlock anymore and rely on rcu alone.

In case writer on other CPU changed policy at the wrong moment (after we
obtained sk policy pointer but before we could obtain the reference)
just repeat the lookup.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 9302647..3d27b9a 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1249,10 +1249,9 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(const struct sock *sk, int dir,
 						 const struct flowi *fl)
 {
 	struct xfrm_policy *pol;
-	struct net *net = sock_net(sk);
 
 	rcu_read_lock();
-	read_lock_bh(&net->xfrm.xfrm_policy_lock);
+ again:
 	pol = rcu_dereference(sk->sk_policy[dir]);
 	if (pol != NULL) {
 		bool match = xfrm_selector_match(&pol->selector, fl,
@@ -1267,8 +1266,8 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(const struct sock *sk, int dir,
 			err = security_xfrm_policy_lookup(pol->security,
 						      fl->flowi_secid,
 						      policy_to_flow_dir(dir));
-			if (!err)
-				xfrm_pol_hold(pol);
+			if (!err && !xfrm_pol_hold_rcu(pol))
+				goto again;
 			else if (err == -ESRCH)
 				pol = NULL;
 			else
@@ -1277,7 +1276,6 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(const struct sock *sk, int dir,
 			pol = NULL;
 	}
 out:
-	read_unlock_bh(&net->xfrm.xfrm_policy_lock);
 	rcu_read_unlock();
 	return pol;
 }
-- 
1.9.1
