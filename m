From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 13/13] xfrm: Cleanup error handling of xfrm_state_clone
Date: Mon, 24 Feb 2014 11:00:01 +0100
Message-ID: <1393236001-2445-14-git-send-email-steffen.klassert@secunet.com>
References: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39140 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752181AbaBXKAS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 05:00:18 -0500
In-Reply-To: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The error pointer passed to xfrm_state_clone() is unchecked,
so remove it and indicate an error by returning a null pointer.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c |   16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index a750901..5339c26 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1148,10 +1148,9 @@ out:
 EXPORT_SYMBOL(xfrm_state_add);
 
 #ifdef CONFIG_XFRM_MIGRATE
-static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
+static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig)
 {
 	struct net *net = xs_net(orig);
-	int err = -ENOMEM;
 	struct xfrm_state *x = xfrm_state_alloc(net);
 	if (!x)
 		goto out;
@@ -1200,15 +1199,13 @@ static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
 	}
 
 	if (orig->replay_esn) {
-		err = xfrm_replay_clone(x, orig);
-		if (err)
+		if (xfrm_replay_clone(x, orig))
 			goto error;
 	}
 
 	memcpy(&x->mark, &orig->mark, sizeof(x->mark));
 
-	err = xfrm_init_state(x);
-	if (err)
+	if (xfrm_init_state(x) < 0)
 		goto error;
 
 	x->props.flags = orig->props.flags;
@@ -1223,8 +1220,6 @@ static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
  error:
 	xfrm_state_put(x);
 out:
-	if (errp)
-		*errp = err;
 	return NULL;
 }
 
@@ -1276,9 +1271,8 @@ struct xfrm_state *xfrm_state_migrate(struct xfrm_state *x,
 				      struct xfrm_migrate *m)
 {
 	struct xfrm_state *xc;
-	int err;
 
-	xc = xfrm_state_clone(x, &err);
+	xc = xfrm_state_clone(x);
 	if (!xc)
 		return NULL;
 
@@ -1291,7 +1285,7 @@ struct xfrm_state *xfrm_state_migrate(struct xfrm_state *x,
 		   state is to be updated as it is a part of triplet */
 		xfrm_state_insert(xc);
 	} else {
-		if ((err = xfrm_state_add(xc)) < 0)
+		if (xfrm_state_add(xc) < 0)
 			goto error;
 	}
 
-- 
1.7.9.5
