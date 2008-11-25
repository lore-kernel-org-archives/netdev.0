From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 23/53] netns xfrm: trivial netns propagations
Date: Tue, 25 Nov 2008 20:26:55 +0300
Message-ID: <1227634045-27534-23-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:28929 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753641AbYKYRYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:24:32 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1144223ugf.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:24:31 -0800 (PST)
In-Reply-To: <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take netns from xfrm_state or xfrm_policy.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 net/xfrm/xfrm_policy.c |   15 +++++++-----
 net/xfrm/xfrm_state.c  |   59 +++++++++++++++++++++++++++--------------------
 2 files changed, 43 insertions(+), 31 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 1d30086..3d931f5 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1069,29 +1069,32 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir, struc
 
 static void __xfrm_policy_link(struct xfrm_policy *pol, int dir)
 {
+	struct net *net = xp_net(pol);
 	struct hlist_head *chain = policy_hash_bysel(&pol->selector,
 						     pol->family, dir);
 
-	list_add(&pol->walk.all, &init_net.xfrm.policy_all);
+	list_add(&pol->walk.all, &net->xfrm.policy_all);
 	hlist_add_head(&pol->bydst, chain);
-	hlist_add_head(&pol->byidx, init_net.xfrm.policy_byidx+idx_hash(pol->index));
-	init_net.xfrm.policy_count[dir]++;
+	hlist_add_head(&pol->byidx, net->xfrm.policy_byidx+idx_hash(pol->index));
+	net->xfrm.policy_count[dir]++;
 	xfrm_pol_hold(pol);
 
-	if (xfrm_bydst_should_resize(&init_net, dir, NULL))
-		schedule_work(&init_net.xfrm.policy_hash_work);
+	if (xfrm_bydst_should_resize(net, dir, NULL))
+		schedule_work(&net->xfrm.policy_hash_work);
 }
 
 static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 						int dir)
 {
+	struct net *net = xp_net(pol);
+
 	if (hlist_unhashed(&pol->bydst))
 		return NULL;
 
 	hlist_del(&pol->bydst);
 	hlist_del(&pol->byidx);
 	list_del(&pol->walk.all);
-	init_net.xfrm.policy_count[dir]--;
+	net->xfrm.policy_count[dir]--;
 
 	return pol;
 }
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 72b2956..f3f635d 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -412,6 +412,7 @@ static inline unsigned long make_jiffies(long secs)
 static void xfrm_timer_handler(unsigned long data)
 {
 	struct xfrm_state *x = (struct xfrm_state*)data;
+	struct net *net = xs_net(x);
 	unsigned long now = get_seconds();
 	long next = LONG_MAX;
 	int warn = 0;
@@ -469,7 +470,7 @@ resched:
 expired:
 	if (x->km.state == XFRM_STATE_ACQ && x->id.spi == 0) {
 		x->km.state = XFRM_STATE_EXPIRED;
-		wake_up(&init_net.xfrm.km_waitq);
+		wake_up(&net->xfrm.km_waitq);
 		next = 2;
 		goto resched;
 	}
@@ -522,17 +523,20 @@ EXPORT_SYMBOL(xfrm_state_alloc);
 
 void __xfrm_state_destroy(struct xfrm_state *x)
 {
+	struct net *net = xs_net(x);
+
 	WARN_ON(x->km.state != XFRM_STATE_DEAD);
 
 	spin_lock_bh(&xfrm_state_gc_lock);
-	hlist_add_head(&x->gclist, &init_net.xfrm.state_gc_list);
+	hlist_add_head(&x->gclist, &net->xfrm.state_gc_list);
 	spin_unlock_bh(&xfrm_state_gc_lock);
-	schedule_work(&init_net.xfrm.state_gc_work);
+	schedule_work(&net->xfrm.state_gc_work);
 }
 EXPORT_SYMBOL(__xfrm_state_destroy);
 
 int __xfrm_state_delete(struct xfrm_state *x)
 {
+	struct net *net = xs_net(x);
 	int err = -ESRCH;
 
 	if (x->km.state != XFRM_STATE_DEAD) {
@@ -543,7 +547,7 @@ int __xfrm_state_delete(struct xfrm_state *x)
 		hlist_del(&x->bysrc);
 		if (x->id.spi)
 			hlist_del(&x->byspi);
-		init_net.xfrm.state_num--;
+		net->xfrm.state_num--;
 		spin_unlock(&xfrm_state_lock);
 
 		/* All xfrm_state objects are created by xfrm_state_alloc.
@@ -745,12 +749,12 @@ __xfrm_state_locate(struct xfrm_state *x, int use_spi, int family)
 						  x->id.proto, family);
 }
 
-static void xfrm_hash_grow_check(int have_hash_collision)
+static void xfrm_hash_grow_check(struct net *net, int have_hash_collision)
 {
 	if (have_hash_collision &&
-	    (init_net.xfrm.state_hmask + 1) < xfrm_state_hashmax &&
-	    init_net.xfrm.state_num > init_net.xfrm.state_hmask)
-		schedule_work(&init_net.xfrm.state_hash_work);
+	    (net->xfrm.state_hmask + 1) < xfrm_state_hashmax &&
+	    net->xfrm.state_num > net->xfrm.state_hmask)
+		schedule_work(&net->xfrm.state_hash_work);
 }
 
 struct xfrm_state *
@@ -851,7 +855,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 			x->timer.expires = jiffies + sysctl_xfrm_acq_expires*HZ;
 			add_timer(&x->timer);
 			init_net.xfrm.state_num++;
-			xfrm_hash_grow_check(x->bydst.next != NULL);
+			xfrm_hash_grow_check(&init_net, x->bydst.next != NULL);
 		} else {
 			x->km.state = XFRM_STATE_DEAD;
 			to_put = x;
@@ -904,48 +908,50 @@ EXPORT_SYMBOL(xfrm_stateonly_find);
 
 static void __xfrm_state_insert(struct xfrm_state *x)
 {
+	struct net *net = xs_net(x);
 	unsigned int h;
 
 	x->genid = ++xfrm_state_genid;
 
-	list_add(&x->km.all, &init_net.xfrm.state_all);
+	list_add(&x->km.all, &net->xfrm.state_all);
 
-	h = xfrm_dst_hash(&init_net, &x->id.daddr, &x->props.saddr,
+	h = xfrm_dst_hash(net, &x->id.daddr, &x->props.saddr,
 			  x->props.reqid, x->props.family);
-	hlist_add_head(&x->bydst, init_net.xfrm.state_bydst+h);
+	hlist_add_head(&x->bydst, net->xfrm.state_bydst+h);
 
-	h = xfrm_src_hash(&init_net, &x->id.daddr, &x->props.saddr, x->props.family);
-	hlist_add_head(&x->bysrc, init_net.xfrm.state_bysrc+h);
+	h = xfrm_src_hash(net, &x->id.daddr, &x->props.saddr, x->props.family);
+	hlist_add_head(&x->bysrc, net->xfrm.state_bysrc+h);
 
 	if (x->id.spi) {
-		h = xfrm_spi_hash(&init_net, &x->id.daddr, x->id.spi, x->id.proto,
+		h = xfrm_spi_hash(net, &x->id.daddr, x->id.spi, x->id.proto,
 				  x->props.family);
 
-		hlist_add_head(&x->byspi, init_net.xfrm.state_byspi+h);
+		hlist_add_head(&x->byspi, net->xfrm.state_byspi+h);
 	}
 
 	mod_timer(&x->timer, jiffies + HZ);
 	if (x->replay_maxage)
 		mod_timer(&x->rtimer, jiffies + x->replay_maxage);
 
-	wake_up(&init_net.xfrm.km_waitq);
+	wake_up(&net->xfrm.km_waitq);
 
-	init_net.xfrm.state_num++;
+	net->xfrm.state_num++;
 
-	xfrm_hash_grow_check(x->bydst.next != NULL);
+	xfrm_hash_grow_check(net, x->bydst.next != NULL);
 }
 
 /* xfrm_state_lock is held */
 static void __xfrm_state_bump_genids(struct xfrm_state *xnew)
 {
+	struct net *net = xs_net(xnew);
 	unsigned short family = xnew->props.family;
 	u32 reqid = xnew->props.reqid;
 	struct xfrm_state *x;
 	struct hlist_node *entry;
 	unsigned int h;
 
-	h = xfrm_dst_hash(&init_net, &xnew->id.daddr, &xnew->props.saddr, reqid, family);
-	hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+h, bydst) {
+	h = xfrm_dst_hash(net, &xnew->id.daddr, &xnew->props.saddr, reqid, family);
+	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h, bydst) {
 		if (x->props.family	== family &&
 		    x->props.reqid	== reqid &&
 		    !xfrm_addr_cmp(&x->id.daddr, &xnew->id.daddr, family) &&
@@ -1044,7 +1050,7 @@ static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 re
 
 		init_net.xfrm.state_num++;
 
-		xfrm_hash_grow_check(x->bydst.next != NULL);
+		xfrm_hash_grow_check(&init_net, x->bydst.next != NULL);
 	}
 
 	return x;
@@ -1109,8 +1115,9 @@ EXPORT_SYMBOL(xfrm_state_add);
 #ifdef CONFIG_XFRM_MIGRATE
 static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
 {
+	struct net *net = xs_net(orig);
 	int err = -ENOMEM;
-	struct xfrm_state *x = xfrm_state_alloc(&init_net);
+	struct xfrm_state *x = xfrm_state_alloc(net);
 	if (!x)
 		goto error;
 
@@ -1734,6 +1741,7 @@ EXPORT_SYMBOL(km_state_notify);
 
 void km_state_expired(struct xfrm_state *x, int hard, u32 pid)
 {
+	struct net *net = xs_net(x);
 	struct km_event c;
 
 	c.data.hard = hard;
@@ -1742,7 +1750,7 @@ void km_state_expired(struct xfrm_state *x, int hard, u32 pid)
 	km_state_notify(x, &c);
 
 	if (hard)
-		wake_up(&init_net.xfrm.km_waitq);
+		wake_up(&net->xfrm.km_waitq);
 }
 
 EXPORT_SYMBOL(km_state_expired);
@@ -1785,6 +1793,7 @@ EXPORT_SYMBOL(km_new_mapping);
 
 void km_policy_expired(struct xfrm_policy *pol, int dir, int hard, u32 pid)
 {
+	struct net *net = xp_net(pol);
 	struct km_event c;
 
 	c.data.hard = hard;
@@ -1793,7 +1802,7 @@ void km_policy_expired(struct xfrm_policy *pol, int dir, int hard, u32 pid)
 	km_policy_notify(pol, dir, &c);
 
 	if (hard)
-		wake_up(&init_net.xfrm.km_waitq);
+		wake_up(&net->xfrm.km_waitq);
 }
 EXPORT_SYMBOL(km_policy_expired);
 
-- 
1.5.6.5

