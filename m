From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/2] xfrm: Fix refcount imbalance in xfrm_lookup
Date: Wed, 23 Jul 2014 10:18:06 +0200
Message-ID: <1406103487-1656-2-git-send-email-steffen.klassert@secunet.com>
References: <1406103487-1656-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39819 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755655AbaGWISX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2014 04:18:23 -0400
In-Reply-To: <1406103487-1656-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm_lookup must return a dst_entry with a refcount for the caller.
Git commit 1a1ccc96abb ("xfrm: Remove caching of xfrm_policy_sk_bundles")
removed this refcount for the socket policy case accidentally.
This patch restores it and sets DST_NOCACHE flag to make sure
that the dst_entry is freed when the refcount becomes null.

Fixes: 1a1ccc96abb ("xfrm: Remove caching of xfrm_policy_sk_bundles")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index a8ef510..0525d78 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2097,6 +2097,8 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 				goto no_transform;
 			}
 
+			dst_hold(&xdst->u.dst);
+			xdst->u.dst.flags |= DST_NOCACHE;
 			route = xdst->route;
 		}
 	}
-- 
1.9.1
