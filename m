From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net] net: xfrm: don't double-hold dst when sk_policy in use.
Date: Wed, 23 Aug 2017 17:14:39 +0900
Message-ID: <20170823081439.52796-1-lorenzo@google.com>
Cc: weiwan@google.com, davem@davemloft.net,
        steffen.klassert@secunet.com, misterikkit@gocogle.com,
        Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33110 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753425AbdHWIOq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 04:14:46 -0400
Received: by mail-pf0-f180.google.com with SMTP id k3so4365339pfc.0
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 01:14:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 net/xfrm/xfrm_policy.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 6f5a0dad50..69b16ee327 100644
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
2.14.1.480.gb18f417b89-goog
