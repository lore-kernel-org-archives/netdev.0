From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/3] xfrm: Don't use sk_family for socket policy lookups
Date: Mon, 6 Mar 2017 07:57:27 +0100
Message-ID: <1488783448-12588-3-git-send-email-steffen.klassert@secunet.com>
References: <1488783448-12588-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35440 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752762AbdCFG6G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 01:58:06 -0500
In-Reply-To: <1488783448-12588-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On IPv4-mapped IPv6 addresses sk_family is AF_INET6,
but the flow informations are created based on AF_INET.
So the routing set up 'struct flowi4' but we try to
access 'struct flowi6' what leads to an out of bounds
access. Fix this by using the family we get with the
dst_entry, like we do it for the standard policy lookup.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Tested-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 3c8f5b7..a9af17f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1248,7 +1248,7 @@ static inline int policy_to_flow_dir(int dir)
 }
 
 static struct xfrm_policy *xfrm_sk_policy_lookup(const struct sock *sk, int dir,
-						 const struct flowi *fl)
+						 const struct flowi *fl, u16 family)
 {
 	struct xfrm_policy *pol;
 
@@ -1256,8 +1256,7 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(const struct sock *sk, int dir,
  again:
 	pol = rcu_dereference(sk->sk_policy[dir]);
 	if (pol != NULL) {
-		bool match = xfrm_selector_match(&pol->selector, fl,
-						 sk->sk_family);
+		bool match = xfrm_selector_match(&pol->selector, fl, family);
 		int err = 0;
 
 		if (match) {
@@ -2253,7 +2252,7 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 	sk = sk_const_to_full_sk(sk);
 	if (sk && sk->sk_policy[XFRM_POLICY_OUT]) {
 		num_pols = 1;
-		pols[0] = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl);
+		pols[0] = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl, family);
 		err = xfrm_expand_policies(fl, family, pols,
 					   &num_pols, &num_xfrms);
 		if (err < 0)
@@ -2532,7 +2531,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	pol = NULL;
 	sk = sk_to_full_sk(sk);
 	if (sk && sk->sk_policy[dir]) {
-		pol = xfrm_sk_policy_lookup(sk, dir, &fl);
+		pol = xfrm_sk_policy_lookup(sk, dir, &fl, family);
 		if (IS_ERR(pol)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINPOLERROR);
 			return 0;
-- 
1.9.1
