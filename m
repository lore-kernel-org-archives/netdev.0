From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: [Patch]net/xfrm/xfrm_policy.c: replace timer with delayed_work
Date: Sat, 16 Feb 2008 23:55:34 +0800 (CST)
Message-ID: <20080216.235534.237382205.xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.238]:16433 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbYBPP7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2008 10:59:49 -0500
Received: by qb-out-0506.google.com with SMTP id e11so580350qbe.15
        for <netdev@vger.kernel.org>; Sat, 16 Feb 2008 07:59:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As suggested by Herbert, using workqueue is better than timer
for net/xfrm/xfrm_policy.c, so replace them with delayed_work.

Note that, this patch is not fully tested, just compile and
run as a whole on an Intel Core Duo matchine. So should be
in -mm first.

Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: David Miller <davem@davemloft.net>

---
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ac72116..53f4794 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -430,7 +430,7 @@ struct xfrm_policy
 	/* This lock only affects elements except for entry. */
 	rwlock_t		lock;
 	atomic_t		refcnt;
-	struct timer_list	timer;
+	struct delayed_work	work;
 
 	u32			priority;
 	u32			index;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 47219f9..58066f0 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -126,9 +126,10 @@ static inline unsigned long make_jiffies(long secs)
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
@@ -181,7 +182,7 @@ static void xfrm_policy_timer(unsigned long data)
 	if (warn)
 		km_policy_expired(xp, dir, 0, 0);
 	if (next != LONG_MAX &&
-	    !mod_timer(&xp->timer, jiffies + make_jiffies(next)))
+	    !schedule_delayed_work(&xp->work, make_jiffies(next)))
 		xfrm_pol_hold(xp);
 
 out:
@@ -208,12 +209,11 @@ struct xfrm_policy *xfrm_policy_alloc(gfp_t gfp)
 	policy = kzalloc(sizeof(struct xfrm_policy), gfp);
 
 	if (policy) {
+		INIT_DELAYED_WORK(&policy->work, xfrm_policy_worker);
 		INIT_HLIST_NODE(&policy->bydst);
 		INIT_HLIST_NODE(&policy->byidx);
 		rwlock_init(&policy->lock);
 		atomic_set(&policy->refcnt, 1);
-		setup_timer(&policy->timer, xfrm_policy_timer,
-				(unsigned long)policy);
 	}
 	return policy;
 }
@@ -227,7 +227,7 @@ void xfrm_policy_destroy(struct xfrm_policy *policy)
 
 	BUG_ON(policy->bundles);
 
-	if (del_timer(&policy->timer))
+	if (cancel_delayed_work(&policy->work))
 		BUG();
 
 	security_xfrm_policy_free(policy);
@@ -244,7 +244,7 @@ static void xfrm_policy_gc_kill(struct xfrm_policy *policy)
 		dst_free(dst);
 	}
 
-	if (del_timer(&policy->timer))
+	if (cancel_delayed_work(&policy->work))
 		atomic_dec(&policy->refcnt);
 
 	if (atomic_read(&policy->refcnt) > 1)
@@ -566,7 +566,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	hlist_add_head(&policy->byidx, xfrm_policy_byidx+idx_hash(policy->index));
 	policy->curlft.add_time = get_seconds();
 	policy->curlft.use_time = 0;
-	if (!mod_timer(&policy->timer, jiffies + HZ))
+	if (!schedule_delayed_work(&policy->work, HZ))
 		xfrm_pol_hold(policy);
 	write_unlock_bh(&xfrm_policy_lock);
 
