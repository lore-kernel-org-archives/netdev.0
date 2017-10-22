From: Anna-Maria Gleixner <anna-maria@linutronix.de>
Subject: [PATCH v2 32/37] xfrm: Replace hrtimer tasklet with softirq hrtimer
Date: Sun, 22 Oct 2017 23:40:10 +0200
Message-ID: <20171022214053.654452552@linutronix.de>
References: <20171022213938.940451689@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>, keescook@chromium.org,
        Christoph Hellwig <hch@lst.de>,
        John Stultz <john.stultz@linaro.org>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:45765 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932465AbdJVVnt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 17:43:49 -0400
Content-Disposition: inline;
 filename=xfrm_Replace_hrtimer_tasklet_with_softirq_hrtimer.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>

Switch the timer to HRTIMER_MODE_SOFT, which executed the timer
callback in softirq context and remove the hrtimer_tasklet.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org

---
 include/net/xfrm.h    |    2 +-
 net/xfrm/xfrm_state.c |   30 ++++++++++++++++++------------
 2 files changed, 19 insertions(+), 13 deletions(-)

--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -216,7 +216,7 @@ struct xfrm_state {
 	struct xfrm_stats	stats;
 
 	struct xfrm_lifetime_cur curlft;
-	struct tasklet_hrtimer	mtimer;
+	struct hrtimer		mtimer;
 
 	struct xfrm_state_offload xso;
 
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -426,7 +426,7 @@ static void xfrm_put_mode(struct xfrm_mo
 
 static void xfrm_state_gc_destroy(struct xfrm_state *x)
 {
-	tasklet_hrtimer_cancel(&x->mtimer);
+	hrtimer_cancel(&x->mtimer);
 	del_timer_sync(&x->rtimer);
 	kfree(x->aead);
 	kfree(x->aalg);
@@ -471,8 +471,8 @@ static void xfrm_state_gc_task(struct wo
 
 static enum hrtimer_restart xfrm_timer_handler(struct hrtimer *me)
 {
-	struct tasklet_hrtimer *thr = container_of(me, struct tasklet_hrtimer, timer);
-	struct xfrm_state *x = container_of(thr, struct xfrm_state, mtimer);
+	struct xfrm_state *x = container_of(me, struct xfrm_state, mtimer);
+	enum hrtimer_restart ret = HRTIMER_NORESTART;
 	unsigned long now = get_seconds();
 	long next = LONG_MAX;
 	int warn = 0;
@@ -536,7 +536,8 @@ static enum hrtimer_restart xfrm_timer_h
 		km_state_expired(x, 0, 0);
 resched:
 	if (next != LONG_MAX) {
-		tasklet_hrtimer_start(&x->mtimer, ktime_set(next, 0), HRTIMER_MODE_REL);
+		hrtimer_forward_now(&x->mtimer, ktime_set(next, 0));
+		ret = HRTIMER_RESTART;
 	}
 
 	goto out;
@@ -553,7 +554,7 @@ static enum hrtimer_restart xfrm_timer_h
 
 out:
 	spin_unlock(&x->lock);
-	return HRTIMER_NORESTART;
+	return ret;
 }
 
 static void xfrm_replay_timer_handler(unsigned long data);
@@ -572,8 +573,8 @@ struct xfrm_state *xfrm_state_alloc(stru
 		INIT_HLIST_NODE(&x->bydst);
 		INIT_HLIST_NODE(&x->bysrc);
 		INIT_HLIST_NODE(&x->byspi);
-		tasklet_hrtimer_init(&x->mtimer, xfrm_timer_handler,
-					CLOCK_BOOTTIME, HRTIMER_MODE_ABS);
+		hrtimer_init(&x->mtimer, CLOCK_BOOTTIME, HRTIMER_MODE_ABS_SOFT);
+		x->mtimer.function = xfrm_timer_handler;
 		setup_timer(&x->rtimer, xfrm_replay_timer_handler,
 				(unsigned long)x);
 		x->curlft.add_time = get_seconds();
@@ -1030,7 +1031,9 @@ xfrm_state_find(const xfrm_address_t *da
 				hlist_add_head_rcu(&x->byspi, net->xfrm.state_byspi + h);
 			}
 			x->lft.hard_add_expires_seconds = net->xfrm.sysctl_acq_expires;
-			tasklet_hrtimer_start(&x->mtimer, ktime_set(net->xfrm.sysctl_acq_expires, 0), HRTIMER_MODE_REL);
+			hrtimer_start(&x->mtimer,
+				      ktime_set(net->xfrm.sysctl_acq_expires, 0),
+				      HRTIMER_MODE_REL_SOFT);
 			net->xfrm.state_num++;
 			xfrm_hash_grow_check(net, x->bydst.next != NULL);
 			spin_unlock_bh(&net->xfrm.xfrm_state_lock);
@@ -1141,7 +1144,7 @@ static void __xfrm_state_insert(struct x
 		hlist_add_head_rcu(&x->byspi, net->xfrm.state_byspi + h);
 	}
 
-	tasklet_hrtimer_start(&x->mtimer, ktime_set(1, 0), HRTIMER_MODE_REL);
+	hrtimer_start(&x->mtimer, ktime_set(1, 0), HRTIMER_MODE_REL_SOFT);
 	if (x->replay_maxage)
 		mod_timer(&x->rtimer, jiffies + x->replay_maxage);
 
@@ -1245,7 +1248,9 @@ static struct xfrm_state *__find_acq_cor
 		x->mark.m = m->m;
 		x->lft.hard_add_expires_seconds = net->xfrm.sysctl_acq_expires;
 		xfrm_state_hold(x);
-		tasklet_hrtimer_start(&x->mtimer, ktime_set(net->xfrm.sysctl_acq_expires, 0), HRTIMER_MODE_REL);
+		hrtimer_start(&x->mtimer,
+			      ktime_set(net->xfrm.sysctl_acq_expires, 0),
+			      HRTIMER_MODE_REL_SOFT);
 		list_add(&x->km.all, &net->xfrm.state_all);
 		hlist_add_head_rcu(&x->bydst, net->xfrm.state_bydst + h);
 		h = xfrm_src_hash(net, daddr, saddr, family);
@@ -1544,7 +1549,8 @@ int xfrm_state_update(struct xfrm_state
 		memcpy(&x1->lft, &x->lft, sizeof(x1->lft));
 		x1->km.dying = 0;
 
-		tasklet_hrtimer_start(&x1->mtimer, ktime_set(1, 0), HRTIMER_MODE_REL);
+		hrtimer_start(&x1->mtimer, ktime_set(1, 0),
+			      HRTIMER_MODE_REL_SOFT);
 		if (x1->curlft.use_time)
 			xfrm_state_check_expire(x1);
 
@@ -1568,7 +1574,7 @@ int xfrm_state_check_expire(struct xfrm_
 	if (x->curlft.bytes >= x->lft.hard_byte_limit ||
 	    x->curlft.packets >= x->lft.hard_packet_limit) {
 		x->km.state = XFRM_STATE_EXPIRED;
-		tasklet_hrtimer_start(&x->mtimer, 0, HRTIMER_MODE_REL);
+		hrtimer_start(&x->mtimer, 0, HRTIMER_MODE_REL_SOFT);
 		return -EINVAL;
 	}
 
