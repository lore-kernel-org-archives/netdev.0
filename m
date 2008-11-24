From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] net: gen_estimator: Fix gen_kill_estimator() lookups
Date: Mon, 24 Nov 2008 12:04:04 +0000
Message-ID: <20081124120404.GA16413@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:49298 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823AbYKXMEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 07:04:11 -0500
Received: by ey-out-2122.google.com with SMTP id 6so795301eyi.37
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 04:04:09 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gen_kill_estimator() linear lists lookups are very slow, and e.g. while
deleting a large number of HTB classes soft lockups were reported. Here
is another try to fix this problem: this time internally, with rbtree,
so similarly to Jamal's hashing idea IIRC. (Looking for next hits could
be still optimized, but it's really fast as it is.)

Reported-by: Badalian Vyacheslav <slavon@bigtelecom.ru>
Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/core/gen_estimator.c |   76 ++++++++++++++++++++++++++++++++++------------
 1 files changed, 56 insertions(+), 20 deletions(-)

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 57abe82..80aa160 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -31,6 +31,7 @@
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
+#include <linux/rbtree.h>
 #include <net/sock.h>
 #include <net/gen_stats.h>
 
@@ -89,6 +90,7 @@ struct gen_estimator
 	u32			avpps;
 	u32			avbps;
 	struct rcu_head		e_rcu;
+	struct rb_node		node;
 };
 
 struct gen_estimator_head
@@ -102,6 +104,9 @@ static struct gen_estimator_head elist[EST_MAX_INTERVAL+1];
 /* Protects against NULL dereference */
 static DEFINE_RWLOCK(est_lock);
 
+/* Protects against soft lockup during large deletion */
+static struct rb_root est_root = RB_ROOT;
+
 static void est_timer(unsigned long arg)
 {
 	int idx = (int)arg;
@@ -139,6 +144,45 @@ skip:
 	rcu_read_unlock();
 }
 
+static void gen_add_node(struct gen_estimator *est)
+{
+	struct rb_node **p = &est_root.rb_node, *parent = NULL;
+
+	while (*p) {
+		struct gen_estimator *e;
+
+		parent = *p;
+		e = rb_entry(parent, struct gen_estimator, node);
+
+		if (est->bstats > e->bstats)
+			p = &parent->rb_right;
+		else
+			p = &parent->rb_left;
+	}
+	rb_link_node(&est->node, parent, p);
+	rb_insert_color(&est->node, &est_root);
+}
+
+static struct gen_estimator *gen_find_node(struct gnet_stats_basic *bstats,
+					   struct gnet_stats_rate_est *rate_est)
+{
+	struct rb_node *p = est_root.rb_node;
+
+	while (p) {
+		struct gen_estimator *e;
+
+		e = rb_entry(p, struct gen_estimator, node);
+
+		if (bstats > e->bstats)
+			p = p->rb_right;
+		else if (bstats < e->bstats || rate_est != e->rate_est)
+			p = p->rb_left;
+		else
+			return e;
+	}
+	return NULL;
+}
+
 /**
  * gen_new_estimator - create a new rate estimator
  * @bstats: basic statistics
@@ -194,6 +238,8 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
 		mod_timer(&elist[idx].timer, jiffies + ((HZ/4) << idx));
 
 	list_add_rcu(&est->list, &elist[idx].list);
+	gen_add_node(est);
+
 	return 0;
 }
 
@@ -209,34 +255,24 @@ static void __gen_kill_estimator(struct rcu_head *head)
  * @bstats: basic statistics
  * @rate_est: rate estimator statistics
  *
- * Removes the rate estimator specified by &bstats and &rate_est
- * and deletes the timer.
+ * Removes the rate estimator specified by &bstats and &rate_est.
  *
  * NOTE: Called under rtnl_mutex
  */
 void gen_kill_estimator(struct gnet_stats_basic *bstats,
-	struct gnet_stats_rate_est *rate_est)
+			struct gnet_stats_rate_est *rate_est)
 {
-	int idx;
-	struct gen_estimator *e, *n;
-
-	for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {
-
-		/* Skip non initialized indexes */
-		if (!elist[idx].timer.function)
-			continue;
+	struct gen_estimator *e;
 
-		list_for_each_entry_safe(e, n, &elist[idx].list, list) {
-			if (e->rate_est != rate_est || e->bstats != bstats)
-				continue;
+	while ((e = gen_find_node(bstats, rate_est))) {
+		rb_erase(&e->node, &est_root);
 
-			write_lock_bh(&est_lock);
-			e->bstats = NULL;
-			write_unlock_bh(&est_lock);
+		write_lock_bh(&est_lock);
+		e->bstats = NULL;
+		write_unlock_bh(&est_lock);
 
-			list_del_rcu(&e->list);
-			call_rcu(&e->e_rcu, __gen_kill_estimator);
-		}
+		list_del_rcu(&e->list);
+		call_rcu(&e->e_rcu, __gen_kill_estimator);
 	}
 }
 
