From: Patrick McHardy <kaber@trash.net>
Subject: [XFRM]: Fix leak of expired xfrm_states
Date: Mon, 26 Nov 2007 16:05:27 +0100
Message-ID: <474AE0B7.5010709@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080600000603070804050004"
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58733 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbXKZPGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 10:06:18 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080600000603070804050004
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes a xfrm_state leak, which appears to be a
regression from the reference count simplifications.


--------------080600000603070804050004
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 817252c2a475371f9764883c7d0f0cde63b3cfe8
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Nov 26 16:00:50 2007 +0100

    [XFRM]: Fix leak of expired xfrm_states
    
    The xfrm_timer calls __xfrm_state_delete, which drops the final reference
    manually without triggering destruction of the state.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 224b44e..11e9a48 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -416,7 +416,7 @@ static inline unsigned long make_jiffies(long secs)
 
 static void xfrm_timer_handler(unsigned long data)
 {
-	struct xfrm_state *x = (struct xfrm_state*)data;
+	struct xfrm_state *x = (struct xfrm_state*)data, *del = NULL;
 	unsigned long now = get_seconds();
 	long next = LONG_MAX;
 	int warn = 0;
@@ -479,6 +479,8 @@ expired:
 		goto resched;
 	}
 
+	del = x;
+	xfrm_state_hold(del);
 	err = __xfrm_state_delete(x);
 	if (!err && x->id.spi)
 		km_state_expired(x, 1, 0);
@@ -488,6 +490,8 @@ expired:
 
 out:
 	spin_unlock(&x->lock);
+	if (del)
+		xfrm_state_put(del);
 }
 
 static void xfrm_replay_timer_handler(unsigned long data);

--------------080600000603070804050004--
