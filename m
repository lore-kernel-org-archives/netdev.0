From: Fan Du <fdu@windriver.com>
Subject: [PATCH] [XFRM] Fix unexpected SA hard expiration after changing date
Date: Tue, 31 Jul 2012 15:43:54 +0800
Message-ID: <1343720634-1176-2-git-send-email-fdu@windriver.com>
References: <1343720634-1176-1-git-send-email-fdu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:57684 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755780Ab2GaHoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 03:44:05 -0400
In-Reply-To: <1343720634-1176-1-git-send-email-fdu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After SA is setup, one timer is armed to detect soft/hard expiration,
however the timer handler uses xtime to do the math. This makes hard
expiration occurs first before soft expiration after setting new date
with big interval. As a result new child SA is deleted before rekeying
the new one.

Signed-off-by: Fan Du <fdu@windriver.com>
---
 include/net/xfrm.h    |    4 ++++
 net/xfrm/xfrm_state.c |   22 ++++++++++++++++++----
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d9509eb..62b619e 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -213,6 +213,9 @@ struct xfrm_state {
 	struct xfrm_lifetime_cur curlft;
 	struct tasklet_hrtimer	mtimer;
 
+	/* used to fix curlft->add_time when changing date */
+	long		saved_tmo;
+
 	/* Last used time */
 	unsigned long		lastused;
 
@@ -238,6 +241,7 @@ static inline struct net *xs_net(struct xfrm_state *x)
 
 /* xflags - make enum if more show up */
 #define XFRM_TIME_DEFER	1
+#define XFRM_SOFT_EXPIRE 2
 
 enum {
 	XFRM_STATE_VOID,
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 5b228f9..fb64dc6 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -415,8 +415,17 @@ static enum hrtimer_restart xfrm_timer_handler(struct hrtimer * me)
 	if (x->lft.hard_add_expires_seconds) {
 		long tmo = x->lft.hard_add_expires_seconds +
 			x->curlft.add_time - now;
-		if (tmo <= 0)
-			goto expired;
+		if (tmo <= 0) {
+			if (x->xflags & XFRM_SOFT_EXPIRE) {
+				/* enter hard expire without soft expire first?!
+				 * setting a new date could trigger this.
+				 * workarbound: fix x->curflt.add_time by below:
+				 */
+				x->curlft.add_time = now - x->saved_tmo - 1;
+				tmo = x->lft.hard_add_expires_seconds - x->saved_tmo;
+			} else
+				goto expired;
+		}
 		if (tmo < next)
 			next = tmo;
 	}
@@ -433,10 +443,14 @@ static enum hrtimer_restart xfrm_timer_handler(struct hrtimer * me)
 	if (x->lft.soft_add_expires_seconds) {
 		long tmo = x->lft.soft_add_expires_seconds +
 			x->curlft.add_time - now;
-		if (tmo <= 0)
+		if (tmo <= 0) {
 			warn = 1;
-		else if (tmo < next)
+			x->xflags &= ~XFRM_SOFT_EXPIRE;
+		} else if (tmo < next) {
 			next = tmo;
+			x->xflags |= XFRM_SOFT_EXPIRE;
+			x->saved_tmo = tmo;
+		}
 	}
 	if (x->lft.soft_use_expires_seconds) {
 		long tmo = x->lft.soft_use_expires_seconds +
-- 
1.7.1
