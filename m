From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 04/53] netns xfrm: per-netns xfrm_state_all list
Date: Tue, 25 Nov 2008 20:26:36 +0300
Message-ID: <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:28929 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754286AbYKYRXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:23:39 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1144223ugf.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:23:38 -0800 (PST)
In-Reply-To: <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is done to get
a) simple "something leaked" check
b) cover possible DoSes when other netns puts many, many xfrm_states
   onto a list.
c) not miss "alien xfrm_state" check in some of list iterators in future.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/netns/xfrm.h |    3 +++
 net/xfrm/xfrm_state.c    |   14 ++++++++------
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 1cb0024..6ae234a 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -1,7 +1,10 @@
 #ifndef __NETNS_XFRM_H
 #define __NETNS_XFRM_H
 
+#include <linux/list.h>
+
 struct netns_xfrm {
+	struct list_head	state_all;
 };
 
 #endif
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 81bde76..85bb854 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -50,7 +50,6 @@ static DEFINE_SPINLOCK(xfrm_state_lock);
  * Main use is finding SA after policy selected tunnel or transport mode.
  * Also, it can be used by ah/esp icmp error handler to find offending SA.
  */
-static LIST_HEAD(xfrm_state_all);
 static struct hlist_head *xfrm_state_bydst __read_mostly;
 static struct hlist_head *xfrm_state_bysrc __read_mostly;
 static struct hlist_head *xfrm_state_byspi __read_mostly;
@@ -855,7 +854,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 
 		if (km_query(x, tmpl, pol) == 0) {
 			x->km.state = XFRM_STATE_ACQ;
-			list_add(&x->km.all, &xfrm_state_all);
+			list_add(&x->km.all, &init_net.xfrm.state_all);
 			hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 			h = xfrm_src_hash(daddr, saddr, family);
 			hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
@@ -924,7 +923,7 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 
 	x->genid = ++xfrm_state_genid;
 
-	list_add(&x->km.all, &xfrm_state_all);
+	list_add(&x->km.all, &init_net.xfrm.state_all);
 
 	h = xfrm_dst_hash(&x->id.daddr, &x->props.saddr,
 			  x->props.reqid, x->props.family);
@@ -1053,7 +1052,7 @@ static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 re
 		xfrm_state_hold(x);
 		x->timer.expires = jiffies + sysctl_xfrm_acq_expires*HZ;
 		add_timer(&x->timer);
-		list_add(&x->km.all, &xfrm_state_all);
+		list_add(&x->km.all, &init_net.xfrm.state_all);
 		hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 		h = xfrm_src_hash(daddr, saddr, family);
 		hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
@@ -1559,10 +1558,10 @@ int xfrm_state_walk(struct xfrm_state_walk *walk,
 
 	spin_lock_bh(&xfrm_state_lock);
 	if (list_empty(&walk->all))
-		x = list_first_entry(&xfrm_state_all, struct xfrm_state_walk, all);
+		x = list_first_entry(&init_net.xfrm.state_all, struct xfrm_state_walk, all);
 	else
 		x = list_entry(&walk->all, struct xfrm_state_walk, all);
-	list_for_each_entry_from(x, &xfrm_state_all, all) {
+	list_for_each_entry_from(x, &init_net.xfrm.state_all, all) {
 		if (x->state == XFRM_STATE_DEAD)
 			continue;
 		state = container_of(x, struct xfrm_state, km);
@@ -2085,6 +2084,8 @@ int __net_init xfrm_state_init(struct net *net)
 {
 	unsigned int sz;
 
+	INIT_LIST_HEAD(&net->xfrm.state_all);
+
 	sz = sizeof(struct hlist_head) * 8;
 
 	xfrm_state_bydst = xfrm_hash_alloc(sz);
@@ -2100,6 +2101,7 @@ int __net_init xfrm_state_init(struct net *net)
 
 void xfrm_state_fini(struct net *net)
 {
+	WARN_ON(!list_empty(&net->xfrm.state_all));
 }
 
 #ifdef CONFIG_AUDITSYSCALL
-- 
1.5.6.5

