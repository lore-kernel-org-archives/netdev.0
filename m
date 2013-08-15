From: Fan Du <fan.du@windriver.com>
Subject: [PATCH 3/3] xfrm: Revert "Fix unexpected SA hard expiration after changing date"
Date: Thu, 15 Aug 2013 15:50:43 +0800
Message-ID: <1376553043-19007-4-git-send-email-fan.du@windriver.com>
References: <1376553043-19007-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <herbert@gondor.hengli.com.au>, <dborkman@redhat.com>,
	<netdev@vger.kernel.org>
To: <tglx@linutronix.de>, <davem@davemloft.net>,
	<steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40374 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760455Ab3HOHvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 03:51:13 -0400
In-Reply-To: <1376553043-19007-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since SAs lifetime timeout has been updated whenever clock_was_set is
called. So commit: e3c0d04750751389d5116267f8cf4687444d9a50
("Fix unexpected SA hard expiration after changing date") is not needed
anymore.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/net/xfrm.h    |    4 ----
 net/xfrm/xfrm_state.c |   21 ++++-----------------
 2 files changed, 4 insertions(+), 21 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 94ce082..b9df23f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -214,9 +214,6 @@ struct xfrm_state {
 	struct xfrm_lifetime_cur curlft;
 	struct tasklet_hrtimer	mtimer;
 
-	/* used to fix curlft->add_time when changing date */
-	long		saved_tmo;
-
 	/* Last used time */
 	unsigned long		lastused;
 
@@ -242,7 +239,6 @@ static inline struct net *xs_net(struct xfrm_state *x)
 
 /* xflags - make enum if more show up */
 #define XFRM_TIME_DEFER	1
-#define XFRM_SOFT_EXPIRE 2
 
 enum {
 	XFRM_STATE_VOID,
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index dcfcd98..79bf9a0 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -407,17 +407,8 @@ static enum hrtimer_restart xfrm_timer_handler(struct hrtimer * me)
 	if (x->lft.hard_add_expires_seconds) {
 		long tmo = x->lft.hard_add_expires_seconds +
 			x->curlft.add_time - now;
-		if (tmo <= 0) {
-			if (x->xflags & XFRM_SOFT_EXPIRE) {
-				/* enter hard expire without soft expire first?!
-				 * setting a new date could trigger this.
-				 * workarbound: fix x->curflt.add_time by below:
-				 */
-				x->curlft.add_time = now - x->saved_tmo - 1;
-				tmo = x->lft.hard_add_expires_seconds - x->saved_tmo;
-			} else
-				goto expired;
-		}
+		if (tmo <= 0)
+			goto expired;
 		if (tmo < next)
 			next = tmo;
 	}
@@ -434,14 +425,10 @@ static enum hrtimer_restart xfrm_timer_handler(struct hrtimer * me)
 	if (x->lft.soft_add_expires_seconds) {
 		long tmo = x->lft.soft_add_expires_seconds +
 			x->curlft.add_time - now;
-		if (tmo <= 0) {
+		if (tmo <= 0)
 			warn = 1;
-			x->xflags &= ~XFRM_SOFT_EXPIRE;
-		} else if (tmo < next) {
+		else if (tmo < next)
 			next = tmo;
-			x->xflags |= XFRM_SOFT_EXPIRE;
-			x->saved_tmo = tmo;
-		}
 	}
 	if (x->lft.soft_use_expires_seconds) {
 		long tmo = x->lft.soft_use_expires_seconds +
-- 
1.7.9.5
