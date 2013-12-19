From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/8] xfrm: Remove ancient sleeping when the SA is in acquire state
Date: Thu, 19 Dec 2013 07:36:41 +0100
Message-ID: <1387435005-8987-5-git-send-email-steffen.klassert@secunet.com>
References: <1387435005-8987-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48195 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752786Ab3LSGhV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 01:37:21 -0500
In-Reply-To: <1387435005-8987-1-git-send-email-steffen.klassert@secunet.com>
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
index ea28404..1006a26 100644
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
index 9a039ac..5beabd8 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1380,10 +1380,9 @@ static int pfkey_acquire(struct sock *sk, struct sk_buff *skb, const struct sadb
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
index 73b04d3..a7487f3 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1901,8 +1901,7 @@ static struct xfrm_dst *xfrm_create_dummy_bundle(struct net *net,
 	if (IS_ERR(xdst))
 		return xdst;
 
-	if (net->xfrm.sysctl_larval_drop || num_xfrms <= 0 ||
-	    (fl->flowi_flags & FLOWI_FLAG_CAN_SLEEP))
+	if (net->xfrm.sysctl_larval_drop || num_xfrms <= 0)
 		return xdst;
 
 	dst1 = &xdst->u.dst;
@@ -2077,7 +2076,6 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 	u8 dir = policy_to_flow_dir(XFRM_POLICY_OUT);
 	int i, err, num_pols, num_xfrms = 0, drop_pols = 0;
 
-restart:
 	dst = NULL;
 	xdst = NULL;
 	route = NULL;
@@ -2157,23 +2155,8 @@ restart:
 
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
index 290479d..e845066 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -372,8 +372,6 @@ static void xfrm_state_gc_task(struct work_struct *work)
 
 	hlist_for_each_entry_safe(x, tmp, &gc_list, gclist)
 		xfrm_state_gc_destroy(x);
-
-	wake_up(&net->xfrm.km_waitq);
 }
 
 static inline unsigned long make_jiffies(long secs)
@@ -388,7 +386,6 @@ static enum hrtimer_restart xfrm_timer_handler(struct hrtimer * me)
 {
 	struct tasklet_hrtimer *thr = container_of(me, struct tasklet_hrtimer, timer);
 	struct xfrm_state *x = container_of(thr, struct xfrm_state, mtimer);
-	struct net *net = xs_net(x);
 	unsigned long now = get_seconds();
 	long next = LONG_MAX;
 	int warn = 0;
@@ -458,12 +455,8 @@ resched:
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
 	if (!err)
@@ -635,7 +628,6 @@ restart:
 
 out:
 	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
-	wake_up(&net->xfrm.km_waitq);
 	return err;
 }
 EXPORT_SYMBOL(xfrm_state_flush);
@@ -948,8 +940,6 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 	if (x->replay_maxage)
 		mod_timer(&x->rtimer, jiffies + x->replay_maxage);
 
-	wake_up(&net->xfrm.km_waitq);
-
 	net->xfrm.state_num++;
 
 	xfrm_hash_grow_check(net, x->bydst.next != NULL);
@@ -1658,16 +1648,12 @@ EXPORT_SYMBOL(km_state_notify);
 
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
@@ -1710,16 +1696,12 @@ EXPORT_SYMBOL(km_new_mapping);
 
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
 
@@ -2028,7 +2010,6 @@ int __net_init xfrm_state_init(struct net *net)
 	INIT_WORK(&net->xfrm.state_hash_work, xfrm_hash_resize);
 	INIT_HLIST_HEAD(&net->xfrm.state_gc_list);
 	INIT_WORK(&net->xfrm.state_gc_work, xfrm_state_gc_task);
-	init_waitqueue_head(&net->xfrm.km_waitq);
 	spin_lock_init(&net->xfrm.xfrm_state_lock);
 	return 0;
 
-- 
1.7.9.5
