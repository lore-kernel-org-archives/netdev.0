From: "fan.du" <fan.du@windriver.com>
Subject: [PATCH] [XFRM] Fix unexpected SA hard expiration after changing date
Date: Mon, 18 Jun 2012 16:24:16 +0800
Message-ID: <1340007856-27651-2-git-send-email-fan.du@windriver.com>
References: <1340007856-27651-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <fdu@windriver.com>
To: <davem@davemloft.net>, <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:50236 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439Ab2FRIYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 04:24:47 -0400
In-Reply-To: <1340007856-27651-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After SA is setup, one timer is armed to detect soft/hard expiration,
however the timer handler uses xtime to do the math. This makes hard
expiration occurs first before soft expiration after setting new date
with big interval. As a result new child SA is deleted before rekeying
the new one.

Signed-off-by: fan.du <fan.du@windriver.com>
---
 include/net/xfrm.h    |    2 ++
 net/xfrm/xfrm_state.c |   22 ++++++++++++++++++----
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 2933d74..1734acc 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -214,6 +214,8 @@ struct xfrm_state
 	/* Private data of this transformer, format is opaque,
 	 * interpreted by xfrm_type methods. */
 	void			*data;
+	u32				flags;
+	long			saved_tmo;
 };
 
 /* xflags - make enum if more show up */
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index fd77cf0..da2cc78 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -442,8 +442,18 @@ static void xfrm_timer_handler(unsigned long data)
 	if (x->lft.hard_add_expires_seconds) {
 		long tmo = x->lft.hard_add_expires_seconds +
 			x->curlft.add_time - now;
-		if (tmo <= 0)
-			goto expired;
+		if (tmo <= 0) {
+			if (x->flags != 1)
+				goto expired;
+			else {
+				/* enter hard expire without soft expire first?!
+				 * setting a new date could trigger this.
+				 * workarbound: fix x->curflt.add_time by below:
+				 */
+				x->curlft.add_time = now - x->saved_tmo - 1;
+				tmo = x->lft.hard_add_expires_seconds - x->saved_tmo;
+			}
+		}
 		if (tmo < next)
 			next = tmo;
 	}
@@ -460,10 +470,14 @@ static void xfrm_timer_handler(unsigned long data)
 	if (x->lft.soft_add_expires_seconds) {
 		long tmo = x->lft.soft_add_expires_seconds +
 			x->curlft.add_time - now;
-		if (tmo <= 0)
+		if (tmo <= 0) {
 			warn = 1;
-		else if (tmo < next)
+			x->flags = 0;
+		} else if (tmo < next) {
 			next = tmo;
+			x->flags = 1;
+			x->saved_tmo = tmo;
+		}
 	}
 	if (x->lft.soft_use_expires_seconds) {
 		long tmo = x->lft.soft_use_expires_seconds +
-- 
1.6.3.1
