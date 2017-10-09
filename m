From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/4] xfrm: don't call xfrm_policy_cache_flush under xfrm_state_lock
Date: Mon, 9 Oct 2017 09:16:39 +0200
Message-ID: <1507533399-29399-5-git-send-email-steffen.klassert@secunet.com>
References: <1507533399-29399-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49536 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753943AbdJIHQs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 03:16:48 -0400
In-Reply-To: <1507533399-29399-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Artem Savkov <asavkov@redhat.com>

I might be wrong but it doesn't look like xfrm_state_lock is required
for xfrm_policy_cache_flush and calling it under this lock triggers both
"sleeping function called from invalid context" and "possible circular
locking dependency detected" warnings on flush.

Fixes: ec30d78c14a8 xfrm: add xdst pcpu cache
Signed-off-by: Artem Savkov <asavkov@redhat.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 0dab1cd..1221347 100644
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
2.7.4
