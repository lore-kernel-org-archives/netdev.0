From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/5] xfrm: Take xfrm_state_lock in xfrm_migrate_state_find
Date: Thu, 27 Feb 2014 07:16:37 +0100
Message-ID: <1393481799-20492-4-git-send-email-steffen.klassert@secunet.com>
References: <1393481799-20492-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57446 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751501AbaB0GQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 01:16:52 -0500
In-Reply-To: <1393481799-20492-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A comment on xfrm_migrate_state_find() says that xfrm_state_lock
is held. This is apparently not the case, but we need it to
traverse through the state lists.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 97d117b..c101023 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1215,11 +1215,12 @@ out:
 	return NULL;
 }
 
-/* net->xfrm.xfrm_state_lock is held */
 struct xfrm_state *xfrm_migrate_state_find(struct xfrm_migrate *m, struct net *net)
 {
 	unsigned int h;
-	struct xfrm_state *x;
+	struct xfrm_state *x = NULL;
+
+	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 
 	if (m->reqid) {
 		h = xfrm_dst_hash(net, &m->old_daddr, &m->old_saddr,
@@ -1236,7 +1237,7 @@ struct xfrm_state *xfrm_migrate_state_find(struct xfrm_migrate *m, struct net *n
 					     m->old_family))
 				continue;
 			xfrm_state_hold(x);
-			return x;
+			break;
 		}
 	} else {
 		h = xfrm_src_hash(net, &m->old_daddr, &m->old_saddr,
@@ -1251,11 +1252,13 @@ struct xfrm_state *xfrm_migrate_state_find(struct xfrm_migrate *m, struct net *n
 					     m->old_family))
 				continue;
 			xfrm_state_hold(x);
-			return x;
+			break;
 		}
 	}
 
-	return NULL;
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
+
+	return x;
 }
 EXPORT_SYMBOL(xfrm_migrate_state_find);
 
-- 
1.7.9.5
