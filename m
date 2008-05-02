From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: [Patch] (revised) net/xfrm/xfrm_policy.c: replace timer with
 delayed_work
Date: Fri, 2 May 2008 13:35:55 +0800 (CST)
Message-ID: <alpine.LFD.1.10.0805021323470.3349@localhost.localdomain>
References: <20080216.235534.237382205.xiyou.wangcong@gmail.com> <20080427011809.GA662@gondor.apana.org.au> <20080428.225312.58450957.xiyou.wangcong@gmail.com> <20080428151342.GA12007@gondor.apana.org.au> <alpine.LFD.1.10.0804302355120.2940@localhost.localdomain>
 <20080501011123.GA4060@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: WANG Cong <xiyou.wangcong@gmail.com>, linux-kernel@vger.kernel.org,
	davem@davemloft.net, akpm@osdl.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:37189 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755187AbYEBFcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 01:32:11 -0400
Received: by wf-out-1314.google.com with SMTP id 28so1145757wfc.4
        for <netdev@vger.kernel.org>; Thu, 01 May 2008 22:32:08 -0700 (PDT)
In-Reply-To: <20080501011123.GA4060@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As suggested by Herbert Xu, using workqueue is better than timer
for net/xfrm/xfrm_policy.c, so replace them with delayed_work.
And due to this change, we have to disable BH when trying to
lock.

Note that, this patch is not fully tested, so should be
in -mm first.

Signed-off-by: WANG Cong <wangcong@zeuux.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: David Miller <davem@davemloft.net>

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
+	    !schedule_delayed_work(&xp->work, make_jiffies(next)))
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
+	if (!schedule_delayed_work(&policy->work, HZ))
  		xfrm_pol_hold(policy);
  	list_add_tail(&policy->bytype, &xfrm_policy_bytype[policy->type]);
  	write_unlock_bh(&xfrm_policy_lock);
