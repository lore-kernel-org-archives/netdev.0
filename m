From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/7] net: xfrm: don't double-hold dst when sk_policy in use.
Date: Tue, 29 Aug 2017 12:31:28 +0200
Message-ID: <1504002694-1931-2-git-send-email-steffen.klassert@secunet.com>
References: <1504002694-1931-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50648 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751695AbdH2Kbm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 06:31:42 -0400
In-Reply-To: <1504002694-1931-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>

While removing dst_entry garbage collection, commit 52df157f17e5
("xfrm: take refcnt of dst when creating struct xfrm_dst bundle")
changed xfrm_resolve_and_create_bundle so it returns an xdst with
a refcount of 1 instead of 0.

However, it did not delete the dst_hold performed by xfrm_lookup
when a per-socket policy is in use. This means that when a
socket policy is in use, dst entries returned by xfrm_lookup have
a refcount of 2, and are not freed when no longer in use.

Cc: Wei Wang <weiwan@google.com>
Fixes: 52df157f17 ("xfrm: take refcnt of dst when creating struct xfrm_dst bundle")
Tested: https://android-review.googlesource.com/417481
Tested: https://android-review.googlesource.com/418659
Tested: https://android-review.googlesource.com/424463
Tested: https://android-review.googlesource.com/452776 passes on net-next
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
Acked-by: Wei Wang <weiwan@google.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 6f5a0dad..69b16ee 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2226,7 +2226,6 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 				goto no_transform;
 			}
 
-			dst_hold(&xdst->u.dst);
 			route = xdst->route;
 		}
 	}
-- 
2.7.4
