From: Fan Du <fan.du@windriver.com>
Subject: [PATCH] xfrm: Refactor xfrm_state timer management
Date: Thu, 1 Aug 2013 15:39:50 +0800
Message-ID: <1375342790-2852-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <herbert@gondor.hengli.com.au>,
	<netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:59927 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490Ab3HAHj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 03:39:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current xfrm_state timer management is vulnerable in below several ways:

- Use hrtimer for timer, the timer handler use wall clock checking expire events
  commit e3c0d047 "Fix unexpected SA hard expiration after changing date" fix
  the partial problem by notify IKED with soft -> expire sequence when user
  changing system time forward. But it didn't fix the issue when use changing
  system time backwards, which is most crucial as SAs lifetime will be a *bigger*
  one when doing so, thus buy much time for cracker.

  In short words, changing system time forward/backward can either result in
  long long lifetime SAs or sudden SA hard expired first.

  It actually can be fixed this by adding more flags, and with more complicated
  checking whether system time is being turned forward or backward. I did it and
  eventually works well. But it's only for "add time expire", taking care of
  "use time expire" will add more logic into timer handler, and much more
  complicated.

- When user give "use lifetime" by xfrm user configuration
  interface, current xfrm_state timer management will actually turn the timer on
  even when no IP packet hit policy, and the "use lifetime" eventually become
  "add lifetime".

The culprit is: with one timer for both "add lifetime" and "use lifetime", at the
same time using wall clock to check two expire events. This patch tries to solve
it by:
- Switch real time timer with monotonic timer against any system time changing
- Use "add lifetime" to override "use lifetime" when both applied, as most popular
  IKED like Racoon2/StrongSwan use "add lifetime" only.
- Start "add lifetime" timer only when xfrm_state is updated/added
- Start "use lifetime" timer when actually SAs is used.
- Start the timer with soft lifetime interval first, and then in timer handler
  rearm timer with hard lifetime to get rid of using wall clock.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/net/xfrm.h    |   10 ++--
 net/xfrm/xfrm_state.c |  140 ++++++++++++++++++++++++-------------------------
 2 files changed, 76 insertions(+), 74 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 94ce082..0d76fa4 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -214,8 +214,8 @@ struct xfrm_state {
 	struct xfrm_lifetime_cur curlft;
 	struct tasklet_hrtimer	mtimer;
 
-	/* used to fix curlft->add_time when changing date */
-	long		saved_tmo;
+	/* how much seconds when hard expire happen after soft expire */
+	long            tmo;
 
 	/* Last used time */
 	unsigned long		lastused;
@@ -242,7 +242,11 @@ static inline struct net *xs_net(struct xfrm_state *x)
 
 /* xflags - make enum if more show up */
 #define XFRM_TIME_DEFER	1
-#define XFRM_SOFT_EXPIRE 2
+#define XFRM_SA_ADD_MODE 2
+#define XFRM_SA_USE_MODE 4
+#define XFRM_SA_ACQ_MODE 8
+#define XFRM_SA_SOFT_STAGE 16
+#define XFRM_SA_HARD_STAGE 32
 
 enum {
 	XFRM_STATE_VOID,
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 78f66fa..fc578a3 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -393,10 +393,7 @@ static enum hrtimer_restart xfrm_timer_handler(struct hrtimer * me)
 {
 	struct tasklet_hrtimer *thr = container_of(me, struct tasklet_hrtimer, timer);
 	struct xfrm_state *x = container_of(thr, struct xfrm_state, mtimer);
-	struct net *net = xs_net(x);
-	unsigned long now = get_seconds();
 	long next = LONG_MAX;
-	int warn = 0;
 	int err = 0;
 
 	spin_lock(&x->lock);
@@ -404,72 +401,31 @@ static enum hrtimer_restart xfrm_timer_handler(struct hrtimer * me)
 		goto out;
 	if (x->km.state == XFRM_STATE_EXPIRED)
 		goto expired;
-	if (x->lft.hard_add_expires_seconds) {
-		long tmo = x->lft.hard_add_expires_seconds +
-			x->curlft.add_time - now;
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
-		if (tmo < next)
-			next = tmo;
-	}
-	if (x->lft.hard_use_expires_seconds) {
-		long tmo = x->lft.hard_use_expires_seconds +
-			(x->curlft.use_time ? : now) - now;
-		if (tmo <= 0)
-			goto expired;
-		if (tmo < next)
-			next = tmo;
-	}
-	if (x->km.dying)
-		goto resched;
-	if (x->lft.soft_add_expires_seconds) {
-		long tmo = x->lft.soft_add_expires_seconds +
-			x->curlft.add_time - now;
-		if (tmo <= 0) {
-			warn = 1;
-			x->xflags &= ~XFRM_SOFT_EXPIRE;
-		} else if (tmo < next) {
-			next = tmo;
-			x->xflags |= XFRM_SOFT_EXPIRE;
-			x->saved_tmo = tmo;
-		}
-	}
-	if (x->lft.soft_use_expires_seconds) {
-		long tmo = x->lft.soft_use_expires_seconds +
-			(x->curlft.use_time ? : now) - now;
-		if (tmo <= 0)
-			warn = 1;
-		else if (tmo < next)
-			next = tmo;
-	}
+	/* If we reach here from acquire process, we expired surely */
+	if (x->xflags & XFRM_SA_ACQ_MODE)
+		goto expired;
 
-	x->km.dying = warn;
-	if (warn)
+	if (x->xflags & XFRM_SA_SOFT_STAGE) {
+		x->xflags &= ~XFRM_SA_SOFT_STAGE;
+		x->xflags |= XFRM_SA_HARD_STAGE;
+		next = x->tmo;
+		x->km.dying = 1;
+		/* Notify AF_KEY listener about soft expire event */
 		km_state_expired(x, 0, 0);
-resched:
-	if (next != LONG_MAX){
-		tasklet_hrtimer_start(&x->mtimer, ktime_set(next, 0), HRTIMER_MODE_REL);
+		/* Arm the timer for hard expire event now. */
+		tasklet_hrtimer_start(&x->mtimer, ktime_set(next, 0),
+					HRTIMER_MODE_REL);
+		goto out;
+	} else if (x->xflags & XFRM_SA_HARD_STAGE) {
+		/* Notify AF_KEY listener about hard expire event */
+		goto expired;
+	} else {
+		/* Cann't be here, catch buggy code! */
+		printk(KERN_WARNING "Enter xfrm_state->mtimer handler with unkonw reason!\n");
+		goto out;
 	}
 
-	goto out;
-
 expired:
-	if (x->km.state == XFRM_STATE_ACQ && x->id.spi == 0) {
-		x->km.state = XFRM_STATE_EXPIRED;
-		wake_up(&net->xfrm.km_waitq);
-		next = 2;
-		goto resched;
-	}
-
 	err = __xfrm_state_delete(x);
 	if (!err && x->id.spi)
 		km_state_expired(x, 1, 0);
@@ -499,7 +455,8 @@ struct xfrm_state *xfrm_state_alloc(struct net *net)
 		INIT_HLIST_NODE(&x->bydst);
 		INIT_HLIST_NODE(&x->bysrc);
 		INIT_HLIST_NODE(&x->byspi);
-		tasklet_hrtimer_init(&x->mtimer, xfrm_timer_handler, CLOCK_REALTIME, HRTIMER_MODE_ABS);
+		/* Using monotonic clock against any wall clock changing */
+		tasklet_hrtimer_init(&x->mtimer, xfrm_timer_handler, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
 		setup_timer(&x->rtimer, xfrm_replay_timer_handler,
 				(unsigned long)x);
 		x->curlft.add_time = get_seconds();
@@ -872,8 +829,11 @@ found:
 				h = xfrm_spi_hash(net, &x->id.daddr, x->id.spi, x->id.proto, encap_family);
 				hlist_add_head(&x->byspi, net->xfrm.state_byspi+h);
 			}
-			x->lft.hard_add_expires_seconds = net->xfrm.sysctl_acq_expires;
-			tasklet_hrtimer_start(&x->mtimer, ktime_set(net->xfrm.sysctl_acq_expires, 0), HRTIMER_MODE_REL);
+
+			/* Mark xfrm_state with acquire mode for IKED negotiation timeout */
+			x->xflags |= XFRM_SA_ACQ_MODE;
+			tasklet_hrtimer_start(&x->mtimer, ktime_set(net->xfrm.sysctl_acq_expires, 0),
+				HRTIMER_MODE_REL);
 			net->xfrm.state_num++;
 			xfrm_hash_grow_check(net, x->bydst.next != NULL);
 		} else {
@@ -948,7 +908,22 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 		hlist_add_head(&x->byspi, net->xfrm.state_byspi+h);
 	}
 
-	tasklet_hrtimer_start(&x->mtimer, ktime_set(1, 0), HRTIMER_MODE_REL);
+	/* Use "add expire" if user supply them, and start "use expire" later on */
+	x->xflags &= ~XFRM_SA_ACQ_MODE;
+	if (x->lft.soft_use_expires_seconds) {
+		x->xflags |= XFRM_SA_USE_MODE;
+		x->tmo = x->lft.hard_use_expires_seconds - x->lft.soft_use_expires_seconds;
+	} else if (x->lft.soft_add_expires_seconds) {
+		x->xflags |= XFRM_SA_ADD_MODE;
+		x->xflags |= XFRM_SA_SOFT_STAGE;
+		x->tmo = x->lft.hard_add_expires_seconds - x->lft.soft_add_expires_seconds;
+		tasklet_hrtimer_start(&x->mtimer, ktime_set(x->lft.soft_add_expires_seconds, 0), HRTIMER_MODE_REL);
+	} else {
+		/* Cann't be here, catch buggy code */
+		 printk("========ERROR: no use time and add time set by user!\n");
+	}
+
+
 	if (x->replay_maxage)
 		mod_timer(&x->rtimer, jiffies + x->replay_maxage);
 
@@ -1048,8 +1023,10 @@ static struct xfrm_state *__find_acq_core(struct net *net, struct xfrm_mark *m,
 		x->props.reqid = reqid;
 		x->mark.v = m->v;
 		x->mark.m = m->m;
-		x->lft.hard_add_expires_seconds = net->xfrm.sysctl_acq_expires;
 		xfrm_state_hold(x);
+
+		/* Mark xfrm_state with acquire mode for IKED negotiation timeout */
+		x->xflags |= XFRM_SA_ACQ_MODE;
 		tasklet_hrtimer_start(&x->mtimer, ktime_set(net->xfrm.sysctl_acq_expires, 0), HRTIMER_MODE_REL);
 		list_add(&x->km.all, &net->xfrm.state_all);
 		hlist_add_head(&x->bydst, net->xfrm.state_bydst+h);
@@ -1333,7 +1310,21 @@ out:
 		memcpy(&x1->lft, &x->lft, sizeof(x1->lft));
 		x1->km.dying = 0;
 
-		tasklet_hrtimer_start(&x1->mtimer, ktime_set(1, 0), HRTIMER_MODE_REL);
+
+		x1->xflags &= ~(XFRM_SA_ACQ_MODE | XFRM_SA_USE_MODE | XFRM_SA_ADD_MODE);
+		/* Use "add expire" if user supply them, and we start "use expire" later on */
+		if (x1->lft.soft_use_expires_seconds) {
+			x1->xflags |= XFRM_SA_USE_MODE;
+			x1->tmo = x1->lft.hard_use_expires_seconds - x1->lft.soft_use_expires_seconds;
+		} else if (x1->lft.soft_add_expires_seconds) {
+			x1->xflags |= XFRM_SA_ADD_MODE;
+			x1->xflags |= XFRM_SA_SOFT_STAGE;
+			x1->tmo = x1->lft.hard_add_expires_seconds - x1->lft.soft_add_expires_seconds;
+			tasklet_hrtimer_start(&x1->mtimer, ktime_set(x1->lft.soft_add_expires_seconds, 0), HRTIMER_MODE_REL);
+		} else {
+			/* Cann't be here, catch buggy code */
+			printk("========ERROR: no use time and add time set by user!\n");
+		}
 		if (x1->curlft.use_time)
 			xfrm_state_check_expire(x1);
 
@@ -1351,8 +1342,15 @@ EXPORT_SYMBOL(xfrm_state_update);
 
 int xfrm_state_check_expire(struct xfrm_state *x)
 {
-	if (!x->curlft.use_time)
+	if (!x->curlft.use_time) {
 		x->curlft.use_time = get_seconds();
+		if (x->xflags & XFRM_SA_USE_MODE) {
+			/* We turn on xfrm_state timer for "use expire" at this right place */
+			x->xflags |= XFRM_SA_SOFT_STAGE;
+			tasklet_hrtimer_start(&x->mtimer, ktime_set(x->lft.soft_use_expires_seconds, 0),
+				HRTIMER_MODE_REL);
+		}
+	}
 
 	if (x->curlft.bytes >= x->lft.hard_byte_limit ||
 	    x->curlft.packets >= x->lft.hard_packet_limit) {
-- 
1.7.9.5
