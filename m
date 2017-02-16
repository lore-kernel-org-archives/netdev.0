From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 02/13] xfrm: policy: xfrm_get_tos cannot fail
Date: Thu, 16 Feb 2017 13:18:36 +0100
Message-ID: <1487247527-17925-3-git-send-email-steffen.klassert@secunet.com>
References: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49272 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753618AbdBPMS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:18:56 -0500
In-Reply-To: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

The comment makes it look like get_tos() is used to validate something,
but it turns out the comment was about xfrm_find_bundle() which got removed
years ago.

xfrm_get_tos will return either the tos (ipv4) or 0 (ipv6).

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 19 +++++--------------
 1 file changed, 5 insertions(+), 14 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 99ad1af2..6fffa2f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1538,19 +1538,13 @@ int __xfrm_sk_clone_policy(struct sock *sk, const struct sock *osk)
 
 }
 
-/* Check that the bundle accepts the flow and its components are
- * still valid.
- */
-
-static inline int xfrm_get_tos(const struct flowi *fl, int family)
+static int xfrm_get_tos(const struct flowi *fl, int family)
 {
-	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
-	int tos;
-
-	if (!afinfo)
-		return -EINVAL;
+	struct xfrm_policy_afinfo *afinfo;
+	int tos = 0;
 
-	tos = afinfo->get_tos(fl);
+	afinfo = xfrm_policy_get_afinfo(family);
+	tos = afinfo ? afinfo->get_tos(fl) : 0;
 
 	xfrm_policy_put_afinfo(afinfo);
 
@@ -1705,9 +1699,6 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 	xfrm_flowi_addr_get(fl, &saddr, &daddr, family);
 
 	tos = xfrm_get_tos(fl, family);
-	err = tos;
-	if (tos < 0)
-		goto put_states;
 
 	dst_hold(dst);
 
-- 
1.9.1
