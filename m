From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/10]: [XFRM]: Convert xfrm_state hash linkage to hlists.
Date: Tue, 15 Aug 2006 04:38:39 -0700 (PDT)
Message-ID: <20060815.043839.78708438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:1243
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030249AbWHOLim (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 07:38:42 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[XFRM]: Convert xfrm_state hash linkage to hlists.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h    |    4 +--
 net/xfrm/xfrm_state.c |   71 +++++++++++++++++++++++++++----------------------
 2 files changed, 41 insertions(+), 34 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 2cbaee7..e2bb0a9 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -94,8 +94,8 @@ extern struct mutex xfrm_cfg_mutex;
 struct xfrm_state
 {
 	/* Note: bydst is re-used during gc */
-	struct list_head	bydst;
-	struct list_head	byspi;
+	struct hlist_node	bydst;
+	struct hlist_node	byspi;
 
 	atomic_t		refcnt;
 	spinlock_t		lock;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index e4b0c6e..724479f 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -46,8 +46,8 @@ #define XFRM_DST_HSIZE		1024
  * Main use is finding SA after policy selected tunnel or transport mode.
  * Also, it can be used by ah/esp icmp error handler to find offending SA.
  */
-static struct list_head xfrm_state_bydst[XFRM_DST_HSIZE];
-static struct list_head xfrm_state_byspi[XFRM_DST_HSIZE];
+static struct hlist_head xfrm_state_bydst[XFRM_DST_HSIZE];
+static struct hlist_head xfrm_state_byspi[XFRM_DST_HSIZE];
 
 static __inline__
 unsigned __xfrm4_dst_hash(xfrm_address_t *addr)
@@ -116,7 +116,7 @@ static DEFINE_RWLOCK(xfrm_state_afinfo_l
 static struct xfrm_state_afinfo *xfrm_state_afinfo[NPROTO];
 
 static struct work_struct xfrm_state_gc_work;
-static struct list_head xfrm_state_gc_list = LIST_HEAD_INIT(xfrm_state_gc_list);
+static HLIST_HEAD(xfrm_state_gc_list);
 static DEFINE_SPINLOCK(xfrm_state_gc_lock);
 
 static int xfrm_state_gc_flush_bundles;
@@ -152,8 +152,8 @@ static void xfrm_state_gc_destroy(struct
 static void xfrm_state_gc_task(void *data)
 {
 	struct xfrm_state *x;
-	struct list_head *entry, *tmp;
-	struct list_head gc_list = LIST_HEAD_INIT(gc_list);
+	struct hlist_node *entry, *tmp;
+	struct hlist_head gc_list;
 
 	if (xfrm_state_gc_flush_bundles) {
 		xfrm_state_gc_flush_bundles = 0;
@@ -161,13 +161,13 @@ static void xfrm_state_gc_task(void *dat
 	}
 
 	spin_lock_bh(&xfrm_state_gc_lock);
-	list_splice_init(&xfrm_state_gc_list, &gc_list);
+	gc_list.first = xfrm_state_gc_list.first;
+	INIT_HLIST_HEAD(&xfrm_state_gc_list);
 	spin_unlock_bh(&xfrm_state_gc_lock);
 
-	list_for_each_safe(entry, tmp, &gc_list) {
-		x = list_entry(entry, struct xfrm_state, bydst);
+	hlist_for_each_entry_safe(x, entry, tmp, &gc_list, bydst)
 		xfrm_state_gc_destroy(x);
-	}
+
 	wake_up(&km_waitq);
 }
 
@@ -261,8 +261,8 @@ struct xfrm_state *xfrm_state_alloc(void
 	if (x) {
 		atomic_set(&x->refcnt, 1);
 		atomic_set(&x->tunnel_users, 0);
-		INIT_LIST_HEAD(&x->bydst);
-		INIT_LIST_HEAD(&x->byspi);
+		INIT_HLIST_NODE(&x->bydst);
+		INIT_HLIST_NODE(&x->byspi);
 		init_timer(&x->timer);
 		x->timer.function = xfrm_timer_handler;
 		x->timer.data	  = (unsigned long)x;
@@ -287,7 +287,7 @@ void __xfrm_state_destroy(struct xfrm_st
 	BUG_TRAP(x->km.state == XFRM_STATE_DEAD);
 
 	spin_lock_bh(&xfrm_state_gc_lock);
-	list_add(&x->bydst, &xfrm_state_gc_list);
+	hlist_add_head(&x->bydst, &xfrm_state_gc_list);
 	spin_unlock_bh(&xfrm_state_gc_lock);
 	schedule_work(&xfrm_state_gc_work);
 }
@@ -300,10 +300,10 @@ int __xfrm_state_delete(struct xfrm_stat
 	if (x->km.state != XFRM_STATE_DEAD) {
 		x->km.state = XFRM_STATE_DEAD;
 		spin_lock(&xfrm_state_lock);
-		list_del(&x->bydst);
+		hlist_del(&x->bydst);
 		__xfrm_state_put(x);
 		if (x->id.spi) {
-			list_del(&x->byspi);
+			hlist_del(&x->byspi);
 			__xfrm_state_put(x);
 		}
 		spin_unlock(&xfrm_state_lock);
@@ -349,12 +349,13 @@ EXPORT_SYMBOL(xfrm_state_delete);
 void xfrm_state_flush(u8 proto)
 {
 	int i;
-	struct xfrm_state *x;
 
 	spin_lock_bh(&xfrm_state_lock);
 	for (i = 0; i < XFRM_DST_HSIZE; i++) {
+		struct hlist_node *entry;
+		struct xfrm_state *x;
 restart:
-		list_for_each_entry(x, xfrm_state_bydst+i, bydst) {
+		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
 			if (!xfrm_state_kern(x) &&
 			    (proto == IPSEC_PROTO_ANY || x->id.proto == proto)) {
 				xfrm_state_hold(x);
@@ -391,8 +392,9 @@ static struct xfrm_state *__xfrm_state_l
 {
 	unsigned int h = xfrm_spi_hash(daddr, spi, proto, family);
 	struct xfrm_state *x;
+	struct hlist_node *entry;
 
-	list_for_each_entry(x, xfrm_state_byspi+h, byspi) {
+	hlist_for_each_entry(x, entry, xfrm_state_byspi+h, byspi) {
 		if (x->props.family != family ||
 		    x->id.spi       != spi ||
 		    x->id.proto     != proto)
@@ -424,14 +426,15 @@ xfrm_state_find(xfrm_address_t *daddr, x
 		struct xfrm_policy *pol, int *err,
 		unsigned short family)
 {
-	unsigned h = xfrm_dst_hash(daddr, family);
+	unsigned int h = xfrm_dst_hash(daddr, family);
+	struct hlist_node *entry;
 	struct xfrm_state *x, *x0;
 	int acquire_in_progress = 0;
 	int error = 0;
 	struct xfrm_state *best = NULL;
 	
 	spin_lock_bh(&xfrm_state_lock);
-	list_for_each_entry(x, xfrm_state_bydst+h, bydst) {
+	hlist_for_each_entry(x, entry, xfrm_state_bydst+h, bydst) {
 		if (x->props.family == family &&
 		    x->props.reqid == tmpl->reqid &&
 		    xfrm_state_addr_check(x, daddr, saddr, family) &&
@@ -491,11 +494,11 @@ xfrm_state_find(xfrm_address_t *daddr, x
 
 		if (km_query(x, tmpl, pol) == 0) {
 			x->km.state = XFRM_STATE_ACQ;
-			list_add_tail(&x->bydst, xfrm_state_bydst+h);
+			hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 			xfrm_state_hold(x);
 			if (x->id.spi) {
 				h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, family);
-				list_add(&x->byspi, xfrm_state_byspi+h);
+				hlist_add_head(&x->byspi, xfrm_state_byspi+h);
 				xfrm_state_hold(x);
 			}
 			x->lft.hard_add_expires_seconds = XFRM_ACQ_EXPIRES;
@@ -522,12 +525,12 @@ static void __xfrm_state_insert(struct x
 {
 	unsigned h = xfrm_dst_hash(&x->id.daddr, x->props.family);
 
-	list_add(&x->bydst, xfrm_state_bydst+h);
+	hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 	xfrm_state_hold(x);
 
 	h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, x->props.family);
 
-	list_add(&x->byspi, xfrm_state_byspi+h);
+	hlist_add_head(&x->byspi, xfrm_state_byspi+h);
 	xfrm_state_hold(x);
 
 	if (!mod_timer(&x->timer, jiffies + HZ))
@@ -554,9 +557,10 @@ EXPORT_SYMBOL(xfrm_state_insert);
 static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 reqid, u8 proto, xfrm_address_t *daddr, xfrm_address_t *saddr, int create)
 {
 	unsigned int h = xfrm_dst_hash(daddr, family);
+	struct hlist_node *entry;
 	struct xfrm_state *x;
 
-	list_for_each_entry(x, xfrm_state_bydst+h, bydst) {
+	hlist_for_each_entry(x, entry, xfrm_state_bydst+h, bydst) {
 		if (x->props.reqid  != reqid ||
 		    x->props.mode   != mode ||
 		    x->props.family != family ||
@@ -623,7 +627,7 @@ static struct xfrm_state *__find_acq_cor
 		x->timer.expires = jiffies + XFRM_ACQ_EXPIRES*HZ;
 		add_timer(&x->timer);
 		xfrm_state_hold(x);
-		list_add_tail(&x->bydst, xfrm_state_bydst+h);
+		hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 		wake_up(&km_waitq);
 	}
 
@@ -823,10 +827,12 @@ EXPORT_SYMBOL(xfrm_find_acq);
 static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq)
 {
 	int i;
-	struct xfrm_state *x;
 
 	for (i = 0; i < XFRM_DST_HSIZE; i++) {
-		list_for_each_entry(x, xfrm_state_bydst+i, bydst) {
+		struct hlist_node *entry;
+		struct xfrm_state *x;
+
+		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
 			if (x->km.seq == seq && x->km.state == XFRM_STATE_ACQ) {
 				xfrm_state_hold(x);
 				return x;
@@ -893,7 +899,7 @@ xfrm_alloc_spi(struct xfrm_state *x, u32
 	if (x->id.spi) {
 		spin_lock_bh(&xfrm_state_lock);
 		h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, x->props.family);
-		list_add(&x->byspi, xfrm_state_byspi+h);
+		hlist_add_head(&x->byspi, xfrm_state_byspi+h);
 		xfrm_state_hold(x);
 		spin_unlock_bh(&xfrm_state_lock);
 		wake_up(&km_waitq);
@@ -906,12 +912,13 @@ int xfrm_state_walk(u8 proto, int (*func
 {
 	int i;
 	struct xfrm_state *x;
+	struct hlist_node *entry;
 	int count = 0;
 	int err = 0;
 
 	spin_lock_bh(&xfrm_state_lock);
 	for (i = 0; i < XFRM_DST_HSIZE; i++) {
-		list_for_each_entry(x, xfrm_state_bydst+i, bydst) {
+		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
 			if (proto == IPSEC_PROTO_ANY || x->id.proto == proto)
 				count++;
 		}
@@ -922,7 +929,7 @@ int xfrm_state_walk(u8 proto, int (*func
 	}
 
 	for (i = 0; i < XFRM_DST_HSIZE; i++) {
-		list_for_each_entry(x, xfrm_state_bydst+i, bydst) {
+		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
 			if (proto != IPSEC_PROTO_ANY && x->id.proto != proto)
 				continue;
 			err = func(x, --count, data);
@@ -1351,8 +1358,8 @@ void __init xfrm_state_init(void)
 	int i;
 
 	for (i=0; i<XFRM_DST_HSIZE; i++) {
-		INIT_LIST_HEAD(&xfrm_state_bydst[i]);
-		INIT_LIST_HEAD(&xfrm_state_byspi[i]);
+		INIT_HLIST_HEAD(&xfrm_state_bydst[i]);
+		INIT_HLIST_HEAD(&xfrm_state_byspi[i]);
 	}
 	INIT_WORK(&xfrm_state_gc_work, xfrm_state_gc_task, NULL);
 }
-- 
1.4.2.rc2.g3e042

