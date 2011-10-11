From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-next] xfrm: Simplify the replay check and advance
 functions
Date: Tue, 11 Oct 2011 13:58:37 +0200
Message-ID: <20111011115837.GK1830@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53530 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918Ab1JKL6l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 07:58:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The replay check and replay advance functions had some code
duplications. This patch removes the duplications.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_replay.c |   98 ++++++++++++++++-------------------------------
 1 files changed, 34 insertions(+), 64 deletions(-)

diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index b11ea69..6ca3574 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -203,8 +203,6 @@ static int xfrm_replay_check_bmp(struct xfrm_state *x,
 	if (!replay_esn->replay_window)
 		return 0;
 
-	pos = (replay_esn->seq - 1) % replay_esn->replay_window;
-
 	if (unlikely(seq == 0))
 		goto err;
 
@@ -216,19 +214,18 @@ static int xfrm_replay_check_bmp(struct xfrm_state *x,
 		goto err;
 	}
 
-	if (pos >= diff) {
+	pos = (replay_esn->seq - 1) % replay_esn->replay_window;
+
+	if (pos >= diff)
 		bitnr = (pos - diff) % replay_esn->replay_window;
-		nr = bitnr >> 5;
-		bitnr = bitnr & 0x1F;
-		if (replay_esn->bmp[nr] & (1U << bitnr))
-			goto err_replay;
-	} else {
+	else
 		bitnr = replay_esn->replay_window - (diff - pos);
-		nr = bitnr >> 5;
-		bitnr = bitnr & 0x1F;
-		if (replay_esn->bmp[nr] & (1U << bitnr))
-			goto err_replay;
-	}
+
+	nr = bitnr >> 5;
+	bitnr = bitnr & 0x1F;
+	if (replay_esn->bmp[nr] & (1U << bitnr))
+		goto err_replay;
+
 	return 0;
 
 err_replay:
@@ -259,39 +256,27 @@ static void xfrm_replay_advance_bmp(struct xfrm_state *x, __be32 net_seq)
 				bitnr = bitnr & 0x1F;
 				replay_esn->bmp[nr] &=  ~(1U << bitnr);
 			}
-
-			bitnr = (pos + diff) % replay_esn->replay_window;
-			nr = bitnr >> 5;
-			bitnr = bitnr & 0x1F;
-			replay_esn->bmp[nr] |= (1U << bitnr);
 		} else {
 			nr = (replay_esn->replay_window - 1) >> 5;
 			for (i = 0; i <= nr; i++)
 				replay_esn->bmp[i] = 0;
-
-			bitnr = (pos + diff) % replay_esn->replay_window;
-			nr = bitnr >> 5;
-			bitnr = bitnr & 0x1F;
-			replay_esn->bmp[nr] |= (1U << bitnr);
 		}
 
+		bitnr = (pos + diff) % replay_esn->replay_window;
 		replay_esn->seq = seq;
 	} else {
 		diff = replay_esn->seq - seq;
 
-		if (pos >= diff) {
+		if (pos >= diff)
 			bitnr = (pos - diff) % replay_esn->replay_window;
-			nr = bitnr >> 5;
-			bitnr = bitnr & 0x1F;
-			replay_esn->bmp[nr] |= (1U << bitnr);
-		} else {
+		else
 			bitnr = replay_esn->replay_window - (diff - pos);
-			nr = bitnr >> 5;
-			bitnr = bitnr & 0x1F;
-			replay_esn->bmp[nr] |= (1U << bitnr);
-		}
 	}
 
+	nr = bitnr >> 5;
+	bitnr = bitnr & 0x1F;
+	replay_esn->bmp[nr] |= (1U << bitnr);
+
 	if (xfrm_aevent_is_on(xs_net(x)))
 		xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
 }
@@ -390,8 +375,6 @@ static int xfrm_replay_check_esn(struct xfrm_state *x,
 	if (!wsize)
 		return 0;
 
-	pos = (replay_esn->seq - 1) % replay_esn->replay_window;
-
 	if (unlikely(seq == 0 && replay_esn->seq_hi == 0 &&
 		     (replay_esn->seq < replay_esn->replay_window - 1)))
 		goto err;
@@ -415,19 +398,18 @@ static int xfrm_replay_check_esn(struct xfrm_state *x,
 		goto err;
 	}
 
-	if (pos >= diff) {
+	pos = (replay_esn->seq - 1) % replay_esn->replay_window;
+
+	if (pos >= diff)
 		bitnr = (pos - diff) % replay_esn->replay_window;
-		nr = bitnr >> 5;
-		bitnr = bitnr & 0x1F;
-		if (replay_esn->bmp[nr] & (1U << bitnr))
-			goto err_replay;
-	} else {
+	else
 		bitnr = replay_esn->replay_window - (diff - pos);
-		nr = bitnr >> 5;
-		bitnr = bitnr & 0x1F;
-		if (replay_esn->bmp[nr] & (1U << bitnr))
-			goto err_replay;
-	}
+
+	nr = bitnr >> 5;
+	bitnr = bitnr & 0x1F;
+	if (replay_esn->bmp[nr] & (1U << bitnr))
+		goto err_replay;
+
 	return 0;
 
 err_replay:
@@ -465,22 +447,13 @@ static void xfrm_replay_advance_esn(struct xfrm_state *x, __be32 net_seq)
 				bitnr = bitnr & 0x1F;
 				replay_esn->bmp[nr] &=  ~(1U << bitnr);
 			}
-
-			bitnr = (pos + diff) % replay_esn->replay_window;
-			nr = bitnr >> 5;
-			bitnr = bitnr & 0x1F;
-			replay_esn->bmp[nr] |= (1U << bitnr);
 		} else {
 			nr = (replay_esn->replay_window - 1) >> 5;
 			for (i = 0; i <= nr; i++)
 				replay_esn->bmp[i] = 0;
-
-			bitnr = (pos + diff) % replay_esn->replay_window;
-			nr = bitnr >> 5;
-			bitnr = bitnr & 0x1F;
-			replay_esn->bmp[nr] |= (1U << bitnr);
 		}
 
+		bitnr = (pos + diff) % replay_esn->replay_window;
 		replay_esn->seq = seq;
 
 		if (unlikely(wrap > 0))
@@ -488,19 +461,16 @@ static void xfrm_replay_advance_esn(struct xfrm_state *x, __be32 net_seq)
 	} else {
 		diff = replay_esn->seq - seq;
 
-		if (pos >= diff) {
+		if (pos >= diff)
 			bitnr = (pos - diff) % replay_esn->replay_window;
-			nr = bitnr >> 5;
-			bitnr = bitnr & 0x1F;
-			replay_esn->bmp[nr] |= (1U << bitnr);
-		} else {
+		else
 			bitnr = replay_esn->replay_window - (diff - pos);
-			nr = bitnr >> 5;
-			bitnr = bitnr & 0x1F;
-			replay_esn->bmp[nr] |= (1U << bitnr);
-		}
 	}
 
+	nr = bitnr >> 5;
+	bitnr = bitnr & 0x1F;
+	replay_esn->bmp[nr] |= (1U << bitnr);
+
 	if (xfrm_aevent_is_on(xs_net(x)))
 		xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
 }
-- 
1.7.0.4
