From: Artem Savkov <asavkov@redhat.com>
Subject: [PATCH] xfrm: don't call xfrm_policy_cache_flush under xfrm_state_lock
Date: Wed, 27 Sep 2017 14:25:37 +0200
Message-ID: <20170927122537.14235-1-asavkov@redhat.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Artem Savkov <asavkov@redhat.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52826 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752330AbdI0MZt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Sep 2017 08:25:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I might be wrong but it doesn't look like xfrm_state_lock is required
for xfrm_policy_cache_flush and calling it under this lock triggers both
"sleeping function called from invalid context" and "possible circular
locking dependency detected" warnings on flush.

Fixes: ec30d78c14a8 xfrm: add xdst pcpu cache
Signed-off-by: Artem Savkov <asavkov@redhat.com>
---
 net/xfrm/xfrm_state.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 0dab1cd79ce4..12213477cd3a 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -732,12 +732,12 @@ int xfrm_state_flush(struct net *net, u8 proto, bool task_valid)
 			}
 		}
 	}
+out:
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 	if (cnt) {
 		err = 0;
 		xfrm_policy_cache_flush();
 	}
-out:
-	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 	return err;
 }
 EXPORT_SYMBOL(xfrm_state_flush);
-- 
2.13.5
