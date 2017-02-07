From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 1/6] xfrm: policy: xfrm_get_tos cannot fail
Date: Tue,  7 Feb 2017 15:00:14 +0100
Message-ID: <20170207140019.20269-2-fw@strlen.de>
References: <20170207140019.20269-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:56632 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754315AbdBGOB7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 09:01:59 -0500
In-Reply-To: <20170207140019.20269-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The comment makes it look like get_tos() is used to validate something,
but it turns out the comment was about xfrm_find_bundle() which got removed
years ago.

xfrm_get_tos will return either the tos (ipv4) or 0 (ipv6).

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_policy.c | 19 +++++--------------
 1 file changed, 5 insertions(+), 14 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 99ad1af2927f..6fffa2fac607 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1538,19 +1538,13 @@ xfrm_tmpl_resolve(struct xfrm_policy **pols, int npols, const struct flowi *fl,
 
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
2.10.2
