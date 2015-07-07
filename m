From: Giuseppe Cantavenera <giuseppe.cantavenera@azcom.it>
Subject: [RFC net-next] xfrm: refactory to avoid state tasklet scheduling errors
Date: Tue,  7 Jul 2015 09:43:17 +0200
Message-ID: <1436254997-2942-1-git-send-email-giuseppe.cantavenera@azcom.it>
Cc: Giuseppe Cantavenera <giuseppe.cantavenera@azcom.it>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>, Fan Du <fan.du@intel.com>,
	Alexander Sverdlin <alexander.sverdlin@nokia.com>,
	Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nokia.com>,
	Giuseppe Cantavenera <giuseppe.cantavenera.ext@nokia.com>,
	Nicholas Faustini <nicholas.faustini.ext@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02b.icteam.com ([80.76.69.99]:38215 "EHLO
	smtp02b.icteam.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbbGGHuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 03:50:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SA state is managed by a tasklet scheduled relying on the wall clock.
Previous changes have already tried to address bugs
when the system time is changed but some error conditions still exist,
because the logic is still coupled with the wall time.

If the time is changed in between the SA is created and the tasklet timer
is started for the first time, the SA scheduling will be broken:
either the SA will expire and never be recreated, or it will expire at
an unexpected time.  The reason is that x->curlft.add_time will not be valid
when the "next" variable is computed for the very first time
in xfrm_timer_handler().

Fix this behaviour by avoiding to rely on the system time.
Stick to relative time intervals and realise a total decoupling
from the wall time.

Based on another patch written and published by
Fan Du (fan.du@intel.com) in 2013 but never merged:
part of the code preserved, some rewritten and improved.
Changes to the logic accounting for the use_time expiration.
Here we allow both add_time and use_time expirations to be set.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Fan Du <fan.du@intel.com>
Cc: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Cc: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nokia.com>
Signed-off-by: Giuseppe Cantavenera <giuseppe.cantavenera.ext@nokia.com>
Signed-off-by: Nicholas Faustini <nicholas.faustini.ext@nokia.com>
---

Hello,

we also meet the same bug Fan Du did a while ago.
Two solutions were proposed in the past:
either forcibly mark as expired all of the keys every time the clock is set,
or replace the existing timers with relative ones.

The former would introduce unexpected behaviour 
(the keys would keep expiring when they shouldn't) and does not address the
real problem: THE COUPLING between the SA scheduling and the wall timer.
Actually it introduces even more of that.

The latter is robust, extremly lightweight and maintanable, and preserves the
expected behaviour, that's why we preferred it.

Any feedback or any other idea is greatly appreciated.

Thanks,
Regards,
Giuseppe

 include/net/xfrm.h    |  10 ++-
 net/xfrm/xfrm_state.c | 181 ++++++++++++++++++++++++++++++++------------------
 2 files changed, 123 insertions(+), 68 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 721e9c3..a1335cf 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -212,8 +212,8 @@ struct xfrm_state {
 	struct xfrm_lifetime_cur curlft;
 	struct tasklet_hrtimer	mtimer;
 
-	/* used to fix curlft->add_time when changing date */
-	long		saved_tmo;
+	/* seconds beetwen hard and software expiration */
+	long            tmo;
 
 	/* Last used time */
 	unsigned long		lastused;
@@ -240,7 +240,11 @@ static inline struct net *xs_net(struct xfrm_state *x)
 
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
index 0ab5413..2c6a5a5 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -387,78 +387,38 @@ static enum hrtimer_restart xfrm_timer_handler(struct hrtimer *me)
 {
 	struct tasklet_hrtimer *thr = container_of(me, struct tasklet_hrtimer, timer);
 	struct xfrm_state *x = container_of(thr, struct xfrm_state, mtimer);
-	unsigned long now = get_seconds();
 	long next = LONG_MAX;
-	int warn = 0;
 	int err = 0;
+	int exp_reason_unknown = 0;
 
 	spin_lock(&x->lock);
 	if (x->km.state == XFRM_STATE_DEAD)
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
+	if (x->xflags & XFRM_SA_ACQ_MODE)
+		goto expired;
 
-	x->km.dying = warn;
-	if (warn)
+	if (x->xflags & XFRM_SA_SOFT_STAGE) {
+		x->xflags &= ~XFRM_SA_SOFT_STAGE;
+		x->xflags |= XFRM_SA_HARD_STAGE;
+		next = x->tmo;
+		x->km.dying = 1;
+		/* Notify AF_KEY listener about the soft expire event */
 		km_state_expired(x, 0, 0);
-resched:
-	if (next != LONG_MAX) {
-		tasklet_hrtimer_start(&x->mtimer, ktime_set(next, 0), HRTIMER_MODE_REL);
+		/* Arm the timer for the hard expire event */
+		tasklet_hrtimer_start(&x->mtimer, ktime_set(next, 0),
+				      HRTIMER_MODE_REL);
+		goto out;
+	} else if (x->xflags & XFRM_SA_HARD_STAGE) {
+		/* Notify AF_KEY listener about hard expire event */
+		goto expired;
+	} else {
+		/* This branch should never be taken. Catch buggy condition. */
+		exp_reason_unknown = 1;
 	}
 
-	goto out;
-
 expired:
-	if (x->km.state == XFRM_STATE_ACQ && x->id.spi == 0)
-		x->km.state = XFRM_STATE_EXPIRED;
-
 	err = __xfrm_state_delete(x);
 	if (!err)
 		km_state_expired(x, 1, 0);
@@ -467,6 +427,7 @@ expired:
 
 out:
 	spin_unlock(&x->lock);
+	BUG_ON(exp_reason_unknown);
 	return HRTIMER_NORESTART;
 }
 
@@ -487,7 +448,7 @@ struct xfrm_state *xfrm_state_alloc(struct net *net)
 		INIT_HLIST_NODE(&x->bysrc);
 		INIT_HLIST_NODE(&x->byspi);
 		tasklet_hrtimer_init(&x->mtimer, xfrm_timer_handler,
-					CLOCK_BOOTTIME, HRTIMER_MODE_ABS);
+					CLOCK_BOOTTIME, HRTIMER_MODE_REL);
 		setup_timer(&x->rtimer, xfrm_replay_timer_handler,
 				(unsigned long)x);
 		x->curlft.add_time = get_seconds();
@@ -866,7 +827,11 @@ found:
 				h = xfrm_spi_hash(net, &x->id.daddr, x->id.spi, x->id.proto, encap_family);
 				hlist_add_head(&x->byspi, net->xfrm.state_byspi+h);
 			}
-			x->lft.hard_add_expires_seconds = net->xfrm.sysctl_acq_expires;
+
+			/* Mark xfrm_state with acquire mode for
+			 *  IKED negotiation timeout
+			 */
+			x->xflags |= XFRM_SA_ACQ_MODE;
 			tasklet_hrtimer_start(&x->mtimer, ktime_set(net->xfrm.sysctl_acq_expires, 0), HRTIMER_MODE_REL);
 			net->xfrm.state_num++;
 			xfrm_hash_grow_check(net, x->bydst.next != NULL);
@@ -947,6 +912,7 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 {
 	struct net *net = xs_net(x);
 	unsigned int h;
+	ktime_t timeout;
 
 	list_add(&x->km.all, &net->xfrm.state_all);
 
@@ -964,7 +930,29 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 		hlist_add_head(&x->byspi, net->xfrm.state_byspi+h);
 	}
 
-	tasklet_hrtimer_start(&x->mtimer, ktime_set(1, 0), HRTIMER_MODE_REL);
+	/* Use the "add expire" timeout if user supplies it.
+	 * The "use expire" ones, if any, will be started later on
+	 */
+	x->xflags &= ~XFRM_SA_ACQ_MODE;
+	if (x->lft.soft_add_expires_seconds &&
+	    x->lft.hard_add_expires_seconds >= x->lft.soft_add_expires_seconds){
+		x->xflags |= XFRM_SA_ADD_MODE;
+		x->xflags |= XFRM_SA_SOFT_STAGE;
+		x->tmo = x->lft.hard_add_expires_seconds -
+		      x->lft.soft_add_expires_seconds;
+
+		timeout = ktime_set(x->lft.soft_add_expires_seconds, 0);
+		tasklet_hrtimer_start(&x->mtimer, timeout, HRTIMER_MODE_REL);
+	}
+
+	if (x->lft.soft_use_expires_seconds &&
+	    x->lft.hard_use_expires_seconds >= x->lft.soft_use_expires_seconds)
+		x->xflags |= XFRM_SA_USE_MODE;
+
+	if (!(x->lft.soft_use_expires_seconds) &&
+	    !(x->lft.soft_add_expires_seconds))
+		pr_info("no use time or add time set by user!\n");
+
 	if (x->replay_maxage)
 		mod_timer(&x->rtimer, jiffies + x->replay_maxage);
 
@@ -1066,8 +1054,12 @@ static struct xfrm_state *__find_acq_core(struct net *net,
 		x->props.reqid = reqid;
 		x->mark.v = m->v;
 		x->mark.m = m->m;
-		x->lft.hard_add_expires_seconds = net->xfrm.sysctl_acq_expires;
 		xfrm_state_hold(x);
+
+		/* Mark xfrm_state with acquire mode
+		 * for IKED negotiation timeout
+		 */
+		x->xflags |= XFRM_SA_ACQ_MODE;
 		tasklet_hrtimer_start(&x->mtimer, ktime_set(net->xfrm.sysctl_acq_expires, 0), HRTIMER_MODE_REL);
 		list_add(&x->km.all, &net->xfrm.state_all);
 		hlist_add_head(&x->bydst, net->xfrm.state_bydst+h);
@@ -1307,6 +1299,7 @@ int xfrm_state_update(struct xfrm_state *x)
 	int err;
 	int use_spi = xfrm_id_proto_match(x->id.proto, IPSEC_PROTO_ANY);
 	struct net *net = xs_net(x);
+	ktime_t timeout;
 
 	to_put = NULL;
 
@@ -1357,7 +1350,30 @@ out:
 		memcpy(&x1->lft, &x->lft, sizeof(x1->lft));
 		x1->km.dying = 0;
 
-		tasklet_hrtimer_start(&x1->mtimer, ktime_set(1, 0), HRTIMER_MODE_REL);
+		x1->xflags &= ~(XFRM_SA_ACQ_MODE | XFRM_SA_USE_MODE
+				 | XFRM_SA_ADD_MODE);
+		if (x1->lft.soft_add_expires_seconds &&
+		    x1->lft.hard_add_expires_seconds >=
+					x1->lft.soft_add_expires_seconds) {
+			x1->xflags |= XFRM_SA_ADD_MODE;
+			x1->xflags |= XFRM_SA_SOFT_STAGE;
+			x1->tmo = x1->lft.hard_add_expires_seconds -
+			       x1->lft.soft_add_expires_seconds;
+			timeout = ktime_set(x1->lft.soft_add_expires_seconds,
+					    0);
+			tasklet_hrtimer_start(&x1->mtimer, timeout,
+					      HRTIMER_MODE_REL);
+		}
+
+		if (x1->lft.soft_use_expires_seconds &&
+		    x1->lft.hard_use_expires_seconds >=
+					x1->lft.soft_use_expires_seconds)
+			x1->xflags |= XFRM_SA_USE_MODE;
+
+		if (!(x->lft.soft_use_expires_seconds) &&
+		    !(x->lft.soft_add_expires_seconds))
+			pr_info("no use time or add time set by user!\n");
+
 		if (x1->curlft.use_time)
 			xfrm_state_check_expire(x1);
 
@@ -1373,10 +1389,45 @@ out:
 }
 EXPORT_SYMBOL(xfrm_state_update);
 
+void xfrm_state_set_usetime_expire(struct xfrm_state *x)
+{
+	ktime_t ktmo_soft_use;
+	ktime_t ktmo_left;
+
+	ktmo_soft_use = ktime_set(x->lft.soft_use_expires_seconds, 0);
+	if (x->xflags & XFRM_SA_ADD_MODE) {
+		ktmo_left = hrtimer_get_remaining(&x->mtimer.timer);
+		/* Remaining time,  with a little margin  */
+		ktmo_left = ktime_sub(ktmo_left, ktime_set(1, 0));
+
+		/* Use the soft_use timeout only if it's shorter than
+		 * the current remaining one
+		 */
+		if (ktime_compare(ktmo_soft_use, ktmo_left) < 0 &&
+		    hrtimer_try_to_cancel(&x->mtimer.timer)) {
+			tasklet_kill(&x->mtimer.tasklet);
+			x->xflags &= ~XFRM_SA_ADD_MODE;
+		} else {
+			goto xfrm_skip_timer_setup;
+		}
+	}
+
+	x->tmo = x->lft.hard_use_expires_seconds -
+	      x->lft.soft_use_expires_seconds;
+	x->xflags |= XFRM_SA_SOFT_STAGE;
+	tasklet_hrtimer_start(&x->mtimer, ktmo_soft_use, HRTIMER_MODE_REL);
+
+xfrm_skip_timer_setup:
+	return;
+}
+
 int xfrm_state_check_expire(struct xfrm_state *x)
 {
-	if (!x->curlft.use_time)
+	if (!x->curlft.use_time) {
 		x->curlft.use_time = get_seconds();
+		if (x->xflags & XFRM_SA_USE_MODE)
+			xfrm_state_set_usetime_expire(x);
+	}
 
 	if (x->curlft.bytes >= x->lft.hard_byte_limit ||
 	    x->curlft.packets >= x->lft.hard_packet_limit) {
-- 
1.9.1
