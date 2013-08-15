From: Fan Du <fan.du@windriver.com>
Subject: [PATCH 2/3] xfrm: Update xfrm_state lifetime expire after clock_was_set
Date: Thu, 15 Aug 2013 15:50:42 +0800
Message-ID: <1376553043-19007-3-git-send-email-fan.du@windriver.com>
References: <1376553043-19007-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <herbert@gondor.hengli.com.au>, <dborkman@redhat.com>,
	<netdev@vger.kernel.org>
To: <tglx@linutronix.de>, <davem@davemloft.net>,
	<steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.windriver.com ([128.224.252.3]:44485 "EHLO
	mail7.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760288Ab3HOHvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 03:51:12 -0400
In-Reply-To: <1376553043-19007-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After clock_was_set called to set new time or host resume from suspend
state. Notify IKED with soft timeout for SAs which haven't reach its
soft timeout limit. For those dying SAs, arrange them to hard expire.

This modification is characterized by SA is sensible to any degree of
clock changes while as SA lifetime is marked by second.

Another point is clock_was_set is traversing all net name space to
update SA time while holding rtnl_lock, it may not scale very well.

Signed-off-by: Fan Du <fan.du@windriver.com>

v3:
  - Fix lockdep complaint about circular locking with trying to acquire
    state->clock while holding xfrm_state_lock.
v2:
  - Use notifier when clock was set, and then update SA lifetime accordingly.
---
 net/xfrm/xfrm_state.c |   44 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 44 insertions(+)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 78f66fa..dcfcd98 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2002,6 +2002,48 @@ int xfrm_init_state(struct xfrm_state *x)
 
 EXPORT_SYMBOL(xfrm_init_state);
 
+static int clock_change_callback(struct notifier_block *nb,
+				unsigned long reason, void *arg)
+{
+	struct xfrm_state_walk *walk;
+	struct xfrm_state *state;
+	struct net *net;
+	long next;
+
+	rtnl_lock();
+	for_each_net(net) {
+		spin_lock_bh(&xfrm_state_lock);
+		list_for_each_entry(walk, &net->xfrm.state_all, all) {
+			state = container_of(walk, struct xfrm_state, km);
+			xfrm_state_hold(state);
+			spin_unlock_bh(&xfrm_state_lock);
+
+			spin_lock_bh(&state->lock);
+			if (state->km.dying) {
+				next = 0;
+			} else {
+				state->km.dying = 1;
+				km_state_expired(state, 0, 0);
+				next = state->lft.hard_add_expires_seconds -
+					state->lft.soft_add_expires_seconds;
+			}
+			state->km.state = XFRM_STATE_EXPIRED;
+			tasklet_hrtimer_start(&state->mtimer, ktime_set(next, 0), HRTIMER_MODE_REL);
+			spin_unlock_bh(&state->lock);
+			xfrm_state_put(state);
+			spin_lock_bh(&xfrm_state_lock);
+		}
+		spin_unlock_bh(&xfrm_state_lock);
+	}
+	rtnl_unlock();
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block clock_change_notifier = {
+	.notifier_call = clock_change_callback,
+};
+
 int __net_init xfrm_state_init(struct net *net)
 {
 	unsigned int sz;
@@ -2026,6 +2068,7 @@ int __net_init xfrm_state_init(struct net *net)
 	INIT_HLIST_HEAD(&net->xfrm.state_gc_list);
 	INIT_WORK(&net->xfrm.state_gc_work, xfrm_state_gc_task);
 	init_waitqueue_head(&net->xfrm.km_waitq);
+	register_clock_change_notifier(&clock_change_notifier);
 	return 0;
 
 out_byspi:
@@ -2057,6 +2100,7 @@ void xfrm_state_fini(struct net *net)
 	xfrm_hash_free(net->xfrm.state_bysrc, sz);
 	WARN_ON(!hlist_empty(net->xfrm.state_bydst));
 	xfrm_hash_free(net->xfrm.state_bydst, sz);
+	unregister_clock_change_notifier(&clock_change_notifier);
 }
 
 #ifdef CONFIG_AUDITSYSCALL
-- 
1.7.9.5
