From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/3] xfrm: Fix xfrm_dst_cache memleak
Date: Wed, 1 Nov 2017 11:05:01 +0100
Message-ID: <1509530703-12707-2-git-send-email-steffen.klassert@secunet.com>
References: <1509530703-12707-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:60002 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752043AbdKAKFP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 06:05:15 -0400
In-Reply-To: <1509530703-12707-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have a memleak whenever a flow matches a policy without
a matching SA. In this case we generate a dummy bundle and
take an additional refcount on the dst_entry. This was needed
as long as we had the flowcache. The flowcache removal patches
deleted all related refcounts but forgot the one for the
dummy bundle case. Fix the memleak by removing this refcount.

Fixes: 3ca28286ea80 ("xfrm_policy: bypass flow_cache_lookup")
Reported-by: Maxime Bizon <mbizon@freebox.fr>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 2746b62..8cafb3c 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2076,7 +2076,6 @@ xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 	xdst->num_xfrms = num_xfrms;
 	memcpy(xdst->pols, pols, sizeof(struct xfrm_policy *) * num_pols);
 
-	dst_hold(&xdst->u.dst);
 	return xdst;
 
 inc_error:
-- 
2.7.4
