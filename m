From: Fan Du <fdu@windriver.com>
Subject: [PATCH] [XFRM] Fix unexpected SA hard expiration after changing date
Date: Tue, 19 Jun 2012 17:28:38 +0800
Message-ID: <1340098118-21529-2-git-send-email-fdu@windriver.com>
References: <1340098118-21529-1-git-send-email-fdu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:38207 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716Ab2FSJ2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 05:28:50 -0400
In-Reply-To: <1340098118-21529-1-git-send-email-fdu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After SA is setup, one timer is armed to detect soft/hard expiration,
however the timer handler uses xtime to do the math. This makes hard
expiration occurs first before soft expiration after setting new date
with big interval. As a result new child SA is deleted before rekeying
the new one.

Signed-off-by: Fan Du <fdu@windriver.com>
---
 include/net/xfrm.h    |  3 +++
 net/xfrm/xfrm_state.c | 21 +++++++++++++++++----
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 2933d74..8d16777 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -197,6 +197,8 @@ struct xfrm_state
 
 	struct xfrm_lifetime_cur curlft;
 	struct timer_list	timer;
+	/* used to fix curlft->add_time when changing date */
+	long		saved_tmo;
 
 	/* Last used time */
 	unsigned long		lastused;
@@ -218,6 +220,7 @@ struct xfrm_state
 
 /* xflags - make enum if more show up */
 #define XFRM_TIME_DEFER	1
+#define XFRM_SOFT_EXPIRE 2
 
 enum {
 	XFRM_STATE_VOID,
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index fd77cf0..ab4aa0f 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -442,8 +442,17 @@ static void xfrm_timer_handler(unsigned long data)
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
@@ -460,10 +469,14 @@ static void xfrm_timer_handler(unsigned long data)
 	if (x->lft.soft_add_expires_seconds) {
 		long tmo = x->lft.soft_add_expires_seconds +
 			x->curlft.add_time - now;
-		if (tmo <= 0)
+		if (tmo <= 0) {
 			warn = 1;
-		else if (tmo < next)
+			x->xflags |= ~XFRM_SOFT_EXPIRE;
+		} else if (tmo < next) {
 			next = tmo;
+			x->xflags |= XFRM_SOFT_EXPIRE;
+			x->saved_tmo = tmo;
+		}
 	}
 	if (x->lft.soft_use_expires_seconds) {
 		long tmo = x->lft.soft_use_expires_seconds +
-- 
1.7.11
