From: Fan Du <fan.du@windriver.com>
Subject: [RFC PATCHv2 2/3] xfrm: Update xfrm_state lifetime expire after clock_was_set
Date: Wed, 7 Aug 2013 17:04:55 +0800
Message-ID: <1375866296-15079-3-git-send-email-fan.du@windriver.com>
References: <1375866296-15079-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:46631 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757276Ab3HGJDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 05:03:18 -0400
In-Reply-To: <1375866296-15079-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After clock_was_set called to set new time or host resume from suspend
state. Notify IKED with soft timeout for SAs which haven't reach its
soft timeout limit. For those dying SAs, arrange them to hard expire.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/xfrm/xfrm_state.c |   40 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 40 insertions(+)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 78f66fa..25e808d 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2002,6 +2002,44 @@ int xfrm_init_state(struct xfrm_state *x)
 
 EXPORT_SYMBOL(xfrm_init_state);
 
+extern struct atomic_notifier_head clock_change_notifier_list;
+static int clock_change_callback(struct notifier_block *nb,
+                               unsigned long reason, void *arg)
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
+			spin_lock(&state->lock);
+			if(state->km.dying) {
+				next = 0;
+			} else {
+				state->km.dying = 1;
+				km_state_expired(state, 0, 0);
+				next = state->lft.hard_add_expires_seconds -
+					state->lft.soft_add_expires_seconds;
+			}
+			state->km.state = XFRM_STATE_EXPIRED;
+			tasklet_hrtimer_start(&state->mtimer, ktime_set(next,0), HRTIMER_MODE_REL);
+			spin_unlock(&state->lock);
+		}
+		spin_unlock_bh(&xfrm_state_lock);
+	}
+	rtnl_unlock();
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block clock_change_notifier = {
+        .notifier_call = clock_change_callback,
+};
+
 int __net_init xfrm_state_init(struct net *net)
 {
 	unsigned int sz;
@@ -2026,6 +2064,8 @@ int __net_init xfrm_state_init(struct net *net)
 	INIT_HLIST_HEAD(&net->xfrm.state_gc_list);
 	INIT_WORK(&net->xfrm.state_gc_work, xfrm_state_gc_task);
 	init_waitqueue_head(&net->xfrm.km_waitq);
+	atomic_notifier_chain_register(&clock_change_notifier_list,
+					&clock_change_notifier);
 	return 0;
 
 out_byspi:
-- 
1.7.9.5
