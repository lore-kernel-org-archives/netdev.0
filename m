From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 1/2] xfrm: Remove ancient sleeping when the SA is in
 acquire state
Date: Thu, 10 Oct 2013 08:33:46 +0200
Message-ID: <20131010063346.GP7660@secunet.com>
References: <20131010063301.GO7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:38392 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125Ab3JJGdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Oct 2013 02:33:49 -0400
Received: from localhost (alg1 [127.0.0.1])
	by a.mx.secunet.com (Postfix) with ESMTP id 282481A007E
	for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 08:33:48 +0200 (CEST)
Received: from a.mx.secunet.com ([127.0.0.1])
	by localhost (a.mx.secunet.com [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id LBlvQdzqHmig for <netdev@vger.kernel.org>;
	Thu, 10 Oct 2013 08:33:46 +0200 (CEST)
Received: from mail-srv1.secumail.de (unknown [10.53.40.200])
	by a.mx.secunet.com (Postfix) with ESMTP id C9B151A007B
	for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 08:33:46 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20131010063301.GO7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We now queue packets to the policy if the states are not yet resolved,
this replaces the ancient sleeping code. Also the sleeping can cause
indefinite task hangs if the needed state does not get resolved.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/netns/xfrm.h |    2 --
 net/key/af_key.c         |    5 ++---
 net/xfrm/xfrm_policy.c   |   21 ++-------------------
 net/xfrm/xfrm_state.c    |   21 +--------------------
 4 files changed, 5 insertions(+), 44 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 5299e69..bda8039 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -33,8 +33,6 @@ struct netns_xfrm {
 	struct hlist_head	state_gc_list;
 	struct work_struct	state_gc_work;
 
-	wait_queue_head_t	km_waitq;
-
 	struct list_head	policy_all;
 	struct hlist_head	*policy_byidx;
 	unsigned int		policy_idx_hmask;
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 9d58537..239289d 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1379,10 +1379,9 @@ static int pfkey_acquire(struct sock *sk, struct sk_buff *skb, const struct sadb
 		return 0;
 
 	spin_lock_bh(&x->lock);
-	if (x->km.state == XFRM_STATE_ACQ) {
+	if (x->km.state == XFRM_STATE_ACQ)
 		x->km.state = XFRM_STATE_ERROR;
-		wake_up(&net->xfrm.km_waitq);
-	}
+
 	spin_unlock_bh(&x->lock);
 	xfrm_state_put(x);
 	return 0;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index ed38d5d..b885c76 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1875,8 +1875,7 @@ static struct xfrm_dst *xfrm_create_dummy_bundle(struct net *net,
 	if (IS_ERR(xdst))
 		return xdst;
 
-	if (net->xfrm.sysctl_larval_drop || num_xfrms <= 0 ||
-	    (fl->flowi_flags & FLOWI_FLAG_CAN_SLEEP))
+	if (net->xfrm.sysctl_larval_drop || num_xfrms <= 0)
 		return xdst;
 
 	dst1 = &xdst->u.dst;
@@ -2051,7 +2050,6 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 	u8 dir = policy_to_flow_dir(XFRM_POLICY_OUT);
 	int i, err, num_pols, num_xfrms = 0, drop_pols = 0;
 
-restart:
 	dst = NULL;
 	xdst = NULL;
 	route = NULL;
@@ -2131,23 +2129,8 @@ restart:
 
 			return make_blackhole(net, family, dst_orig);
 		}
-		if (fl->flowi_flags & FLOWI_FLAG_CAN_SLEEP) {
-			DECLARE_WAITQUEUE(wait, current);
 
-			add_wait_queue(&net->xfrm.km_waitq, &wait);
-			set_current_state(TASK_INTERRUPTIBLE);
-			schedule();
-			set_current_state(TASK_RUNNING);
-			remove_wait_queue(&net->xfrm.km_waitq, &wait);
-
-			if (!signal_pending(current)) {
-				dst_release(dst);
-				goto restart;
-			}
-
-			err = -ERESTART;
-		} else
-			err = -EAGAIN;
+		err = -EAGAIN;
 
 		XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTNOSTATES);
 		goto error;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index b9c3f9e..14518eb 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -374,8 +374,6 @@ static void xfrm_state_gc_task(struct work_struct *work)
 
 	hlist_for_each_entry_safe(x, tmp, &gc_list, gclist)
 		xfrm_state_gc_destroy(x);
-
-	wake_up(&net->xfrm.km_waitq);
 }
 
 static inline unsigned long make_jiffies(long secs)
@@ -390,7 +388,6 @@ static enum hrtimer_restart xfrm_timer_handler(struct hrtimer * me)
 {
 	struct tasklet_hrtimer *thr = container_of(me, struct tasklet_hrtimer, timer);
 	struct xfrm_state *x = container_of(thr, struct xfrm_state, mtimer);
-	struct net *net = xs_net(x);
 	unsigned long now = get_seconds();
 	long next = LONG_MAX;
 	int warn = 0;
@@ -460,12 +457,8 @@ resched:
 	goto out;
 
 expired:
-	if (x->km.state == XFRM_STATE_ACQ && x->id.spi == 0) {
+	if (x->km.state == XFRM_STATE_ACQ && x->id.spi == 0)
 		x->km.state = XFRM_STATE_EXPIRED;
-		wake_up(&net->xfrm.km_waitq);
-		next = 2;
-		goto resched;
-	}
 
 	err = __xfrm_state_delete(x);
 	if (!err && x->id.spi)
@@ -637,7 +630,6 @@ restart:
 
 out:
 	spin_unlock_bh(&xfrm_state_lock);
-	wake_up(&net->xfrm.km_waitq);
 	return err;
 }
 EXPORT_SYMBOL(xfrm_state_flush);
@@ -950,8 +942,6 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 	if (x->replay_maxage)
 		mod_timer(&x->rtimer, jiffies + x->replay_maxage);
 
-	wake_up(&net->xfrm.km_waitq);
-
 	net->xfrm.state_num++;
 
 	xfrm_hash_grow_check(net, x->bydst.next != NULL);
@@ -1655,16 +1645,12 @@ EXPORT_SYMBOL(km_state_notify);
 
 void km_state_expired(struct xfrm_state *x, int hard, u32 portid)
 {
-	struct net *net = xs_net(x);
 	struct km_event c;
 
 	c.data.hard = hard;
 	c.portid = portid;
 	c.event = XFRM_MSG_EXPIRE;
 	km_state_notify(x, &c);
-
-	if (hard)
-		wake_up(&net->xfrm.km_waitq);
 }
 
 EXPORT_SYMBOL(km_state_expired);
@@ -1707,16 +1693,12 @@ EXPORT_SYMBOL(km_new_mapping);
 
 void km_policy_expired(struct xfrm_policy *pol, int dir, int hard, u32 portid)
 {
-	struct net *net = xp_net(pol);
 	struct km_event c;
 
 	c.data.hard = hard;
 	c.portid = portid;
 	c.event = XFRM_MSG_POLEXPIRE;
 	km_policy_notify(pol, dir, &c);
-
-	if (hard)
-		wake_up(&net->xfrm.km_waitq);
 }
 EXPORT_SYMBOL(km_policy_expired);
 
@@ -2025,7 +2007,6 @@ int __net_init xfrm_state_init(struct net *net)
 	INIT_WORK(&net->xfrm.state_hash_work, xfrm_hash_resize);
 	INIT_HLIST_HEAD(&net->xfrm.state_gc_list);
 	INIT_WORK(&net->xfrm.state_gc_work, xfrm_state_gc_task);
-	init_waitqueue_head(&net->xfrm.km_waitq);
 	return 0;
 
 out_byspi:
-- 
1.7.9.5
