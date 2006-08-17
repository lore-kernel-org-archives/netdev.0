From: David Miller <davem@davemloft.net>
Subject: [PATCH 11/15]: [XFRM]: Kill excessive refcounting of xfrm_state
 objects.
Date: Thu, 17 Aug 2006 01:28:28 -0700 (PDT)
Message-ID: <20060817.012828.08319292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37050
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932346AbWHQI20 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 04:28:26 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[XFRM]: Kill excessive refcounting of xfrm_state objects.

The refcounting done for timers and hash table insertions
are just wasted cycles.  We can eliminate all of this
refcounting because:

1) The implicit refcount when the xfrm_state object is active
   will always be held while the object is in the hash tables.
   We never kfree() the xfrm_state until long after we've made
   sure that it has been unhashed.

2) Timers are even easier.  Once we mark that x->km.state as
   anything other than XFRM_STATE_VALID (__xfrm_state_delete
   sets it to XFRM_STATE_DEAD), any timer that fires will
   do nothing and return without rearming the timer.

   Therefore we can defer the del_timer calls until when the
   object is about to be freed up during GC.  We have to use
   del_timer_sync() and defer it to GC because we can't do
   a del_timer_sync() while holding x->lock which all callers
   of __xfrm_state_delete hold.

This makes SA changes even more light-weight.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_state.c |   54 +++++++++++++------------------------------------
 1 files changed, 14 insertions(+), 40 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index b1c0ae7..814e72e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -229,10 +229,8 @@ void km_state_expired(struct xfrm_state 
 
 static void xfrm_state_gc_destroy(struct xfrm_state *x)
 {
-	if (del_timer(&x->timer))
-		BUG();
-	if (del_timer(&x->rtimer))
-		BUG();
+	del_timer_sync(&x->timer);
+	del_timer_sync(&x->rtimer);
 	kfree(x->aalg);
 	kfree(x->ealg);
 	kfree(x->calg);
@@ -323,9 +321,9 @@ static void xfrm_timer_handler(unsigned 
 	if (warn)
 		km_state_expired(x, 0, 0);
 resched:
-	if (next != LONG_MAX &&
-	    !mod_timer(&x->timer, jiffies + make_jiffies(next)))
-		xfrm_state_hold(x);
+	if (next != LONG_MAX)
+		mod_timer(&x->timer, jiffies + make_jiffies(next));
+
 	goto out;
 
 expired:
@@ -340,7 +338,6 @@ expired:
 
 out:
 	spin_unlock(&x->lock);
-	xfrm_state_put(x);
 }
 
 static void xfrm_replay_timer_handler(unsigned long data);
@@ -394,17 +391,10 @@ int __xfrm_state_delete(struct xfrm_stat
 		x->km.state = XFRM_STATE_DEAD;
 		spin_lock(&xfrm_state_lock);
 		hlist_del(&x->bydst);
-		__xfrm_state_put(x);
-		if (x->id.spi) {
+		if (x->id.spi)
 			hlist_del(&x->byspi);
-			__xfrm_state_put(x);
-		}
 		xfrm_state_num--;
 		spin_unlock(&xfrm_state_lock);
-		if (del_timer(&x->timer))
-			__xfrm_state_put(x);
-		if (del_timer(&x->rtimer))
-			__xfrm_state_put(x);
 
 		/* All xfrm_state objects are created by xfrm_state_alloc.
 		 * The xfrm_state_alloc call gives a reference, and that
@@ -579,14 +569,11 @@ xfrm_state_find(xfrm_address_t *daddr, x
 		if (km_query(x, tmpl, pol) == 0) {
 			x->km.state = XFRM_STATE_ACQ;
 			hlist_add_head(&x->bydst, xfrm_state_bydst+h);
-			xfrm_state_hold(x);
 			if (x->id.spi) {
 				h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, family);
 				hlist_add_head(&x->byspi, xfrm_state_byspi+h);
-				xfrm_state_hold(x);
 			}
 			x->lft.hard_add_expires_seconds = XFRM_ACQ_EXPIRES;
-			xfrm_state_hold(x);
 			x->timer.expires = jiffies + XFRM_ACQ_EXPIRES*HZ;
 			add_timer(&x->timer);
 		} else {
@@ -609,24 +596,17 @@ static void __xfrm_state_insert(struct x
 {
 	unsigned int h;
 
-	h = xfrm_dst_hash(&x->id.daddr, x->props.reqid, x->props.family);
-
 	x->genid = ++xfrm_state_genid;
 
+	h = xfrm_dst_hash(&x->id.daddr, x->props.reqid, x->props.family);
 	hlist_add_head(&x->bydst, xfrm_state_bydst+h);
-	xfrm_state_hold(x);
 
 	h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, x->props.family);
-
 	hlist_add_head(&x->byspi, xfrm_state_byspi+h);
-	xfrm_state_hold(x);
-
-	if (!mod_timer(&x->timer, jiffies + HZ))
-		xfrm_state_hold(x);
 
-	if (x->replay_maxage &&
-	    !mod_timer(&x->rtimer, jiffies + x->replay_maxage))
-		xfrm_state_hold(x);
+	mod_timer(&x->timer, jiffies + HZ);
+	if (x->replay_maxage)
+		mod_timer(&x->rtimer, jiffies + x->replay_maxage);
 
 	wake_up(&km_waitq);
 
@@ -738,7 +718,6 @@ static struct xfrm_state *__find_acq_cor
 		xfrm_state_hold(x);
 		x->timer.expires = jiffies + XFRM_ACQ_EXPIRES*HZ;
 		add_timer(&x->timer);
-		xfrm_state_hold(x);
 		hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 		wake_up(&km_waitq);
 	}
@@ -840,8 +819,7 @@ out:
 		memcpy(&x1->lft, &x->lft, sizeof(x1->lft));
 		x1->km.dying = 0;
 
-		if (!mod_timer(&x1->timer, jiffies + HZ))
-			xfrm_state_hold(x1);
+		mod_timer(&x1->timer, jiffies + HZ);
 		if (x1->curlft.use_time)
 			xfrm_state_check_expire(x1);
 
@@ -866,8 +844,7 @@ int xfrm_state_check_expire(struct xfrm_
 	if (x->curlft.bytes >= x->lft.hard_byte_limit ||
 	    x->curlft.packets >= x->lft.hard_packet_limit) {
 		x->km.state = XFRM_STATE_EXPIRED;
-		if (!mod_timer(&x->timer, jiffies))
-			xfrm_state_hold(x);
+		mod_timer(&x->timer, jiffies);
 		return -EINVAL;
 	}
 
@@ -1010,7 +987,6 @@ xfrm_alloc_spi(struct xfrm_state *x, u32
 		spin_lock_bh(&xfrm_state_lock);
 		h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, x->props.family);
 		hlist_add_head(&x->byspi, xfrm_state_byspi+h);
-		xfrm_state_hold(x);
 		spin_unlock_bh(&xfrm_state_lock);
 		wake_up(&km_waitq);
 	}
@@ -1096,9 +1072,8 @@ void xfrm_replay_notify(struct xfrm_stat
 	c.data.aevent = event;
 	km_state_notify(x, &c);
 
-	if (x->replay_maxage &&
-	    !mod_timer(&x->rtimer, jiffies + x->replay_maxage)) {
-		xfrm_state_hold(x);
+	if (x->replay_maxage) {
+		mod_timer(&x->rtimer, jiffies + x->replay_maxage);
 		x->xflags &= ~XFRM_TIME_DEFER;
 	}
 }
@@ -1118,7 +1093,6 @@ static void xfrm_replay_timer_handler(un
 	}
 
 	spin_unlock(&x->lock);
-	xfrm_state_put(x);
 }
 
 int xfrm_replay_check(struct xfrm_state *x, u32 seq)
-- 
1.4.2.rc2.g3e042

