From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 6/7] [IPSEC]: Unexport xfrm_replay_notify
Date: Mon, 08 Oct 2007 19:29:43 +0800
Message-ID: <E1Ieqnv-0000oK-00@gondolin.me.apana.org.au>
References: <20071008112818.GA3010@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1740 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752506AbXJHL3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 07:29:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Unexport xfrm_replay_notify

Now that the only callers of xfrm_replay_notify are in xfrm, we can remove
the export.

This patch also removes xfrm_aevent_doreplay since it's now called in just
one spot.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h     |    6 ------
 net/xfrm/xfrm_output.c |    3 ++-
 net/xfrm/xfrm_state.c  |    1 -
 3 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index a267725..064a4ca 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1163,12 +1163,6 @@ static inline int xfrm_aevent_is_on(void)
 	return ret;
 }
 
-static inline void xfrm_aevent_doreplay(struct xfrm_state *x)
-{
-	if (xfrm_aevent_is_on())
-		xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
-}
-
 #ifdef CONFIG_XFRM_MIGRATE
 static inline struct xfrm_algo *xfrm_algo_clone(struct xfrm_algo *orig)
 {
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 20e789d..40d75ec 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -60,7 +60,8 @@ int xfrm_output(struct sk_buff *skb)
 
 		if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
 			XFRM_SKB_CB(skb)->seq = ++x->replay.oseq;
-			xfrm_aevent_doreplay(x);
+			if (xfrm_aevent_is_on())
+				xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
 		}
 
 		err = x->mode->output(x, skb);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 0ecec34..a00745a 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1397,7 +1397,6 @@ void xfrm_replay_notify(struct xfrm_state *x, int event)
 	    !mod_timer(&x->rtimer, jiffies + x->replay_maxage))
 		x->xflags &= ~XFRM_TIME_DEFER;
 }
-EXPORT_SYMBOL(xfrm_replay_notify);
 
 static void xfrm_replay_timer_handler(unsigned long data)
 {
