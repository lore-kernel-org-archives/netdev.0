From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [Patch] (revised) net/xfrm/xfrm_policy.c: replace timer with
	delayed_work
Date: Tue, 6 May 2008 11:57:12 +0800
Message-ID: <20080506035712.GF2893@hack>
References: <20080216.235534.237382205.xiyou.wangcong@gmail.com> <20080427011809.GA662@gondor.apana.org.au> <20080428.225312.58450957.xiyou.wangcong@gmail.com> <20080428151342.GA12007@gondor.apana.org.au> <alpine.LFD.1.10.0804302355120.2940@localhost.localdomain> <20080501011123.GA4060@gondor.apana.org.au> <alpine.LFD.1.10.0805021323470.3349@localhost.localdomain> <20080506030822.GA14111@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="mojUlQ0s9EVzWg2t"
Cc: WANG Cong <xiyou.wangcong@gmail.com>, linux-kernel@vger.kernel.org,
	davem@davemloft.net, akpm@osdl.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:19476 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753131AbYEFDxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 23:53:20 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1406272wfd.4
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 20:53:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080506030822.GA14111@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--mojUlQ0s9EVzWg2t
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, May 06, 2008 at 11:08:22AM +0800, Herbert Xu wrote:
>On Fri, May 02, 2008 at 01:35:55PM +0800, WANG Cong wrote:
>>
>> @@ -209,16 +210,16 @@ static void xfrm_policy_timer(unsigned long data)
>>  	if (warn)
>>  		km_policy_expired(xp, dir, 0, 0);
>>  	if (next != LONG_MAX &&
>> -	    !mod_timer(&xp->timer, jiffies + make_jiffies(next)))
>> +	    !schedule_delayed_work(&xp->work, make_jiffies(next)))
>>  		xfrm_pol_hold(xp);
>
>I tried it and it pretty much crashed immediately :)
>
>The problem is that schedule_delayed_work's return value is the
>opposite of mod_timer.  So you'll need to reverse the tests.

I apologize.

mod_timer() returns 0 if the timer is pending, schedule_delayed_work()
returns 0 when the work is on the queue.

Oh, yes, you're correct!! It's my fault.

And I recheck the source code. I find del_timer() and
cancel_delayed_work() which I also worried about has no such problem.

So just reverse the check for schedule_delayed_work().

Thanks for your kind help! Updated patches are attached.

--mojUlQ0s9EVzWg2t
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="policy.diff"

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d1350bc..ba1bb24 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -457,7 +457,7 @@ struct xfrm_policy
 	/* This lock only affects elements except for entry. */
 	rwlock_t		lock;
 	atomic_t		refcnt;
-	struct timer_list	timer;
+	struct delayed_work	work;
 
 	u32			priority;
 	u32			index;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index cae9fd8..2ed14e0 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -154,15 +154,16 @@ static inline unsigned long make_jiffies(long secs)
 		return secs*HZ;
 }
 
-static void xfrm_policy_timer(unsigned long data)
+static void xfrm_policy_worker(struct work_struct *w)
 {
-	struct xfrm_policy *xp = (struct xfrm_policy*)data;
+	struct xfrm_policy *xp =
+		container_of((struct delayed_work *)w, struct xfrm_policy, work);
 	unsigned long now = get_seconds();
 	long next = LONG_MAX;
 	int warn = 0;
 	int dir;
 
-	read_lock(&xp->lock);
+	read_lock_bh(&xp->lock);
 
 	if (xp->dead)
 		goto out;
@@ -209,16 +210,16 @@ static void xfrm_policy_timer(unsigned long data)
 	if (warn)
 		km_policy_expired(xp, dir, 0, 0);
 	if (next != LONG_MAX &&
-	    !mod_timer(&xp->timer, jiffies + make_jiffies(next)))
+	    schedule_delayed_work(&xp->work, make_jiffies(next)))
 		xfrm_pol_hold(xp);
 
 out:
-	read_unlock(&xp->lock);
+	read_unlock_bh(&xp->lock);
 	xfrm_pol_put(xp);
 	return;
 
 expired:
-	read_unlock(&xp->lock);
+	read_unlock_bh(&xp->lock);
 	if (!xfrm_policy_delete(xp, dir))
 		km_policy_expired(xp, dir, 1, 0);
 	xfrm_pol_put(xp);
@@ -236,13 +237,12 @@ struct xfrm_policy *xfrm_policy_alloc(gfp_t gfp)
 	policy = kzalloc(sizeof(struct xfrm_policy), gfp);
 
 	if (policy) {
+		INIT_DELAYED_WORK(&policy->work, xfrm_policy_worker);
 		INIT_LIST_HEAD(&policy->bytype);
 		INIT_HLIST_NODE(&policy->bydst);
 		INIT_HLIST_NODE(&policy->byidx);
 		rwlock_init(&policy->lock);
 		atomic_set(&policy->refcnt, 1);
-		setup_timer(&policy->timer, xfrm_policy_timer,
-				(unsigned long)policy);
 	}
 	return policy;
 }
@@ -256,7 +256,7 @@ void xfrm_policy_destroy(struct xfrm_policy *policy)
 
 	BUG_ON(policy->bundles);
 
-	if (del_timer(&policy->timer))
+	if (cancel_delayed_work(&policy->work))
 		BUG();
 
 	write_lock_bh(&xfrm_policy_lock);
@@ -277,7 +277,7 @@ static void xfrm_policy_gc_kill(struct xfrm_policy *policy)
 		dst_free(dst);
 	}
 
-	if (del_timer(&policy->timer))
+	if (cancel_delayed_work(&policy->work))
 		atomic_dec(&policy->refcnt);
 
 	if (atomic_read(&policy->refcnt) > 1)
@@ -615,7 +615,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	hlist_add_head(&policy->byidx, xfrm_policy_byidx+idx_hash(policy->index));
 	policy->curlft.add_time = get_seconds();
 	policy->curlft.use_time = 0;
-	if (!mod_timer(&policy->timer, jiffies + HZ))
+	if (schedule_delayed_work(&policy->work, HZ))
 		xfrm_pol_hold(policy);
 	list_add_tail(&policy->bytype, &xfrm_policy_bytype[policy->type]);
 	write_unlock_bh(&xfrm_policy_lock);

--mojUlQ0s9EVzWg2t
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="state.diff"

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d1350bc..539dccd 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -189,14 +189,14 @@ struct xfrm_state
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
@@ -457,7 +457,7 @@ struct xfrm_policy
 	/* This lock only affects elements except for entry. */
 	rwlock_t		lock;
 	atomic_t		refcnt;
-	struct timer_list	timer;
+	struct delayed_work	work;
 
 	u32			priority;
 	u32			index;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index cae9fd8..2ed14e0 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -154,15 +154,16 @@ static inline unsigned long make_jiffies(long secs)
 		return secs*HZ;
 }
 
-static void xfrm_policy_timer(unsigned long data)
+static void xfrm_policy_worker(struct work_struct *w)
 {
-	struct xfrm_policy *xp = (struct xfrm_policy*)data;
+	struct xfrm_policy *xp =
+		container_of((struct delayed_work *)w, struct xfrm_policy, work);
 	unsigned long now = get_seconds();
 	long next = LONG_MAX;
 	int warn = 0;
 	int dir;
 
-	read_lock(&xp->lock);
+	read_lock_bh(&xp->lock);
 
 	if (xp->dead)
 		goto out;
@@ -209,16 +210,16 @@ static void xfrm_policy_timer(unsigned long data)
 	if (warn)
 		km_policy_expired(xp, dir, 0, 0);
 	if (next != LONG_MAX &&
-	    !mod_timer(&xp->timer, jiffies + make_jiffies(next)))
+	    schedule_delayed_work(&xp->work, make_jiffies(next)))
 		xfrm_pol_hold(xp);
 
 out:
-	read_unlock(&xp->lock);
+	read_unlock_bh(&xp->lock);
 	xfrm_pol_put(xp);
 	return;
 
 expired:
-	read_unlock(&xp->lock);
+	read_unlock_bh(&xp->lock);
 	if (!xfrm_policy_delete(xp, dir))
 		km_policy_expired(xp, dir, 1, 0);
 	xfrm_pol_put(xp);
@@ -236,13 +237,12 @@ struct xfrm_policy *xfrm_policy_alloc(gfp_t gfp)
 	policy = kzalloc(sizeof(struct xfrm_policy), gfp);
 
 	if (policy) {
+		INIT_DELAYED_WORK(&policy->work, xfrm_policy_worker);
 		INIT_LIST_HEAD(&policy->bytype);
 		INIT_HLIST_NODE(&policy->bydst);
 		INIT_HLIST_NODE(&policy->byidx);
 		rwlock_init(&policy->lock);
 		atomic_set(&policy->refcnt, 1);
-		setup_timer(&policy->timer, xfrm_policy_timer,
-				(unsigned long)policy);
 	}
 	return policy;
 }
@@ -256,7 +256,7 @@ void xfrm_policy_destroy(struct xfrm_policy *policy)
 
 	BUG_ON(policy->bundles);
 
-	if (del_timer(&policy->timer))
+	if (cancel_delayed_work(&policy->work))
 		BUG();
 
 	write_lock_bh(&xfrm_policy_lock);
@@ -277,7 +277,7 @@ static void xfrm_policy_gc_kill(struct xfrm_policy *policy)
 		dst_free(dst);
 	}
 
-	if (del_timer(&policy->timer))
+	if (cancel_delayed_work(&policy->work))
 		atomic_dec(&policy->refcnt);
 
 	if (atomic_read(&policy->refcnt) > 1)
@@ -615,7 +615,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	hlist_add_head(&policy->byidx, xfrm_policy_byidx+idx_hash(policy->index));
 	policy->curlft.add_time = get_seconds();
 	policy->curlft.use_time = 0;
-	if (!mod_timer(&policy->timer, jiffies + HZ))
+	if (schedule_delayed_work(&policy->work, HZ))
 		xfrm_pol_hold(policy);
 	list_add_tail(&policy->bytype, &xfrm_policy_bytype[policy->type]);
 	write_unlock_bh(&xfrm_policy_lock);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 72fddaf..b384d81 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -380,8 +380,8 @@ static void xfrm_put_mode(struct xfrm_mode *mode)
 
 static void xfrm_state_gc_destroy(struct xfrm_state *x)
 {
-	del_timer_sync(&x->timer);
-	del_timer_sync(&x->rtimer);
+	cancel_delayed_work_sync(&x->work);
+	cancel_delayed_work_sync(&x->rwork);
 	kfree(x->aalg);
 	kfree(x->ealg);
 	kfree(x->calg);
@@ -426,15 +426,16 @@ static inline unsigned long make_jiffies(long secs)
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
 	int err = 0;
 
-	spin_lock(&x->lock);
+	spin_lock_bh(&x->lock);
 	if (x->km.state == XFRM_STATE_DEAD)
 		goto out;
 	if (x->km.state == XFRM_STATE_EXPIRED)
@@ -479,7 +480,7 @@ static void xfrm_timer_handler(unsigned long data)
 		km_state_expired(x, 0, 0);
 resched:
 	if (next != LONG_MAX)
-		mod_timer(&x->timer, jiffies + make_jiffies(next));
+		schedule_delayed_work(&x->work, make_jiffies(next));
 
 	goto out;
 
@@ -500,10 +501,10 @@ expired:
 				audit_get_sessionid(current), 0);
 
 out:
-	spin_unlock(&x->lock);
+	spin_unlock_bh(&x->lock);
 }
 
-static void xfrm_replay_timer_handler(unsigned long data);
+static void xfrm_replay_work_handler(struct work_struct *);
 
 struct xfrm_state *xfrm_state_alloc(void)
 {
@@ -518,9 +519,8 @@ struct xfrm_state *xfrm_state_alloc(void)
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
@@ -864,8 +864,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 				hlist_add_head(&x->byspi, xfrm_state_byspi+h);
 			}
 			x->lft.hard_add_expires_seconds = sysctl_xfrm_acq_expires;
-			x->timer.expires = jiffies + sysctl_xfrm_acq_expires*HZ;
-			add_timer(&x->timer);
+			schedule_delayed_work(&x->work, sysctl_xfrm_acq_expires*HZ);
 			xfrm_state_num++;
 			xfrm_hash_grow_check(x->bydst.next != NULL);
 		} else {
@@ -938,9 +937,9 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 		hlist_add_head(&x->byspi, xfrm_state_byspi+h);
 	}
 
-	mod_timer(&x->timer, jiffies + HZ);
+	schedule_delayed_work(&x->work, HZ);
 	if (x->replay_maxage)
-		mod_timer(&x->rtimer, jiffies + x->replay_maxage);
+		schedule_delayed_work(&x->rwork, x->replay_maxage);
 
 	wake_up(&km_waitq);
 
@@ -1049,8 +1048,7 @@ static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 re
 		x->props.reqid = reqid;
 		x->lft.hard_add_expires_seconds = sysctl_xfrm_acq_expires;
 		xfrm_state_hold(x);
-		x->timer.expires = jiffies + sysctl_xfrm_acq_expires*HZ;
-		add_timer(&x->timer);
+		schedule_delayed_work(&x->work, sysctl_xfrm_acq_expires*HZ);
 		hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 		h = xfrm_src_hash(daddr, saddr, family);
 		hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
@@ -1317,7 +1315,7 @@ out:
 		memcpy(&x1->lft, &x->lft, sizeof(x1->lft));
 		x1->km.dying = 0;
 
-		mod_timer(&x1->timer, jiffies + HZ);
+		schedule_delayed_work(&x1->work, HZ);
 		if (x1->curlft.use_time)
 			xfrm_state_check_expire(x1);
 
@@ -1342,7 +1340,7 @@ int xfrm_state_check_expire(struct xfrm_state *x)
 	if (x->curlft.bytes >= x->lft.hard_byte_limit ||
 	    x->curlft.packets >= x->lft.hard_packet_limit) {
 		x->km.state = XFRM_STATE_EXPIRED;
-		mod_timer(&x->timer, jiffies);
+		schedule_delayed_work(&x->work, 0);
 		return -EINVAL;
 	}
 
@@ -1622,15 +1620,16 @@ void xfrm_replay_notify(struct xfrm_state *x, int event)
 	km_state_notify(x, &c);
 
 	if (x->replay_maxage &&
-	    !mod_timer(&x->rtimer, jiffies + x->replay_maxage))
+	    schedule_delayed_work(&x->rwork, x->replay_maxage))
 		x->xflags &= ~XFRM_TIME_DEFER;
 }
 
-static void xfrm_replay_timer_handler(unsigned long data)
+static void xfrm_replay_work_handler(struct work_struct *w)
 {
-	struct xfrm_state *x = (struct xfrm_state*)data;
+	struct xfrm_state *x =
+		container_of((struct delayed_work *)w, struct xfrm_state, rwork);
 
-	spin_lock(&x->lock);
+	spin_lock_bh(&x->lock);
 
 	if (x->km.state == XFRM_STATE_VALID) {
 		if (xfrm_aevent_is_on())
@@ -1639,7 +1638,7 @@ static void xfrm_replay_timer_handler(unsigned long data)
 			x->xflags |= XFRM_TIME_DEFER;
 	}
 
-	spin_unlock(&x->lock);
+	spin_unlock_bh(&x->lock);
 }
 
 int xfrm_replay_check(struct xfrm_state *x,

--mojUlQ0s9EVzWg2t--
