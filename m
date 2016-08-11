From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 6/8] xfrm: policy: only use rcu in xfrm_sk_policy_lookup
Date: Thu, 11 Aug 2016 15:17:57 +0200
Message-ID: <1470921479-25592-7-git-send-email-fw@strlen.de>
References: <1470921479-25592-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:54984 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752723AbcHKNSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 09:18:02 -0400
In-Reply-To: <1470921479-25592-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't acquire the readlock anymore and rely on rcu alone.

In case writer on other CPU changed policy at the wrong moment (after we
obtained sk policy pointer but before we could obtain the reference)
just repeat the lookup.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_policy.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 398661c..575a48b 100644
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
2.7.3
