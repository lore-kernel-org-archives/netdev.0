From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: [Patch]net/xfrm/xfrm_state.c: replace timer with delayed_work
Date: Sun, 17 Feb 2008 00:00:49 +0800 (CST)
Message-ID: <20080217.000049.88383747.xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.225]:26831 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155AbYBPQFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2008 11:05:05 -0500
Received: by qb-out-0506.google.com with SMTP id e11so582641qbe.15
        for <netdev@vger.kernel.org>; Sat, 16 Feb 2008 08:05:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Also suggested by Herbert Xu, using workqueue is better than timer
for net/xfrm/xfrm_state.c, so replace them with delayed_work.

Note that, this patch is not fully tested, just compile and
run as a whole on an Intel Core Duo matchine. So should be
in -mm first.

Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: David Miller <davem@davemloft.net>

---
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ac72116..ff718b4 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -188,14 +188,14 @@ struct xfrm_state
 	u32			replay_maxage;
 	u32			replay_maxdiff;
 
-	/* Replay detection notification timer */
-	struct timer_list	rtimer;
+	/* Replay detection notification delayed work */
+	struct delayed_work	rwork;
 
 	/* Statistics */
 	struct xfrm_stats	stats;
 
 	struct xfrm_lifetime_cur curlft;
-	struct timer_list	timer;
+	struct delayed_work	work;
 
 	/* Last used time */
 	unsigned long		lastused;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 7ba65e8..e0511c9 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -379,8 +379,8 @@ static void xfrm_put_mode(struct xfrm_mode *mode)
 
 static void xfrm_state_gc_destroy(struct xfrm_state *x)
 {
-	del_timer_sync(&x->timer);
-	del_timer_sync(&x->rtimer);
+	cancel_delayed_work_sync(&x->work);
+	cancel_delayed_work_sync(&x->rwork);
 	kfree(x->aalg);
 	kfree(x->ealg);
 	kfree(x->calg);
@@ -423,9 +423,10 @@ static inline unsigned long make_jiffies(long secs)
 		return secs*HZ;
 }
 
-static void xfrm_timer_handler(unsigned long data)
+static void xfrm_work_handler(struct work_struct *w)
 {
-	struct xfrm_state *x = (struct xfrm_state*)data;
+	struct xfrm_state *x =
+		container_of((struct delayed_work *)w, struct xfrm_state, work);
 	unsigned long now = get_seconds();
 	long next = LONG_MAX;
 	int warn = 0;
@@ -476,7 +477,7 @@ static void xfrm_timer_handler(unsigned long data)
 		km_state_expired(x, 0, 0);
 resched:
 	if (next != LONG_MAX)
-		mod_timer(&x->timer, jiffies + make_jiffies(next));
+		schedule_delayed_work(&x->work, make_jiffies(next));
 
 	goto out;
 
@@ -499,7 +500,7 @@ out:
 	spin_unlock(&x->lock);
 }
 
-static void xfrm_replay_timer_handler(unsigned long data);
+static void xfrm_replay_work_handler(struct work_struct *);
 
 struct xfrm_state *xfrm_state_alloc(void)
 {
@@ -513,9 +514,8 @@ struct xfrm_state *xfrm_state_alloc(void)
 		INIT_HLIST_NODE(&x->bydst);
 		INIT_HLIST_NODE(&x->bysrc);
 		INIT_HLIST_NODE(&x->byspi);
-		setup_timer(&x->timer, xfrm_timer_handler, (unsigned long)x);
-		setup_timer(&x->rtimer, xfrm_replay_timer_handler,
-				(unsigned long)x);
+		INIT_DELAYED_WORK(&x->work, xfrm_work_handler);
+		INIT_DELAYED_WORK(&x->rwork, xfrm_replay_work_handler);
 		x->curlft.add_time = get_seconds();
 		x->lft.soft_byte_limit = XFRM_INF;
 		x->lft.soft_packet_limit = XFRM_INF;
@@ -851,8 +851,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 				hlist_add_head(&x->byspi, xfrm_state_byspi+h);
 			}
 			x->lft.hard_add_expires_seconds = sysctl_xfrm_acq_expires;
-			x->timer.expires = jiffies + sysctl_xfrm_acq_expires*HZ;
-			add_timer(&x->timer);
+			schedule_delayed_work(&x->work, sysctl_xfrm_acq_expires*HZ);
 			xfrm_state_num++;
 			xfrm_hash_grow_check(x->bydst.next != NULL);
 		} else {
@@ -923,9 +922,9 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 		hlist_add_head(&x->byspi, xfrm_state_byspi+h);
 	}
 
-	mod_timer(&x->timer, jiffies + HZ);
+	schedule_delayed_work(&x->work, HZ);
 	if (x->replay_maxage)
-		mod_timer(&x->rtimer, jiffies + x->replay_maxage);
+		schedule_delayed_work(&x->rwork, x->replay_maxage);
 
 	wake_up(&km_waitq);
 
@@ -1034,8 +1033,7 @@ static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 re
 		x->props.reqid = reqid;
 		x->lft.hard_add_expires_seconds = sysctl_xfrm_acq_expires;
 		xfrm_state_hold(x);
-		x->timer.expires = jiffies + sysctl_xfrm_acq_expires*HZ;
-		add_timer(&x->timer);
+		schedule_delayed_work(&x->work, sysctl_xfrm_acq_expires*HZ);
 		hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 		h = xfrm_src_hash(daddr, saddr, family);
 		hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
@@ -1302,7 +1300,7 @@ out:
 		memcpy(&x1->lft, &x->lft, sizeof(x1->lft));
 		x1->km.dying = 0;
 
-		mod_timer(&x1->timer, jiffies + HZ);
+		schedule_delayed_work(&x1->work, HZ);
 		if (x1->curlft.use_time)
 			xfrm_state_check_expire(x1);
 
@@ -1327,7 +1325,7 @@ int xfrm_state_check_expire(struct xfrm_state *x)
 	if (x->curlft.bytes >= x->lft.hard_byte_limit ||
 	    x->curlft.packets >= x->lft.hard_packet_limit) {
 		x->km.state = XFRM_STATE_EXPIRED;
-		mod_timer(&x->timer, jiffies);
+		schedule_delayed_work(&x->work, 0);
 		return -EINVAL;
 	}
 
@@ -1596,13 +1594,14 @@ void xfrm_replay_notify(struct xfrm_state *x, int event)
 	km_state_notify(x, &c);
 
 	if (x->replay_maxage &&
-	    !mod_timer(&x->rtimer, jiffies + x->replay_maxage))
+	    !schedule_delayed_work(&x->rwork, x->replay_maxage))
 		x->xflags &= ~XFRM_TIME_DEFER;
 }
 
-static void xfrm_replay_timer_handler(unsigned long data)
+static void xfrm_replay_work_handler(struct work_struct *w)
 {
-	struct xfrm_state *x = (struct xfrm_state*)data;
+	struct xfrm_state *x =
+		container_of((struct delayed_work *)w, struct xfrm_state, rwork);
 
 	spin_lock(&x->lock);
 
