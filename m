From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] remove dead exports from xfrm
Date: Sun, 24 Oct 2004 15:40:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041024134012.GB20174@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

there's lots of dead exports in xfrm, are they needed for some future
plans or can we just kill them like in the patch below?


--- 1.69/include/net/xfrm.h	2004-10-21 06:47:36 +02:00
+++ edited/include/net/xfrm.h	2004-10-23 14:04:08 +02:00
@@ -178,8 +178,6 @@
 
 extern int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo);
 extern int xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo);
-extern struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family);
-extern void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo);
 
 #define XFRM_ACQ_EXPIRES	30
 
@@ -200,8 +198,6 @@
 
 extern int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo);
 extern int xfrm_state_unregister_afinfo(struct xfrm_state_afinfo *afinfo);
-extern struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned short family);
-extern void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
 
 extern void xfrm_state_delete_tunnel(struct xfrm_state *x);
 
@@ -805,14 +801,12 @@
 extern void xfrm_state_insert(struct xfrm_state *x);
 extern int xfrm_state_add(struct xfrm_state *x);
 extern int xfrm_state_update(struct xfrm_state *x);
-extern int xfrm_state_check_space(struct xfrm_state *x, struct sk_buff *skb);
 extern struct xfrm_state *xfrm_state_lookup(xfrm_address_t *daddr, u32 spi, u8 proto, unsigned short family);
 extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern void xfrm_state_delete(struct xfrm_state *x);
 extern void xfrm_state_flush(u8 proto);
 extern int xfrm_replay_check(struct xfrm_state *x, u32 seq);
 extern void xfrm_replay_advance(struct xfrm_state *x, u32 seq);
-extern int xfrm_check_selectors(struct xfrm_state **x, int n, struct flowi *fl);
 extern int xfrm_state_check(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm4_rcv(struct sk_buff *skb);
 extern int xfrm4_output(struct sk_buff **pskb);
@@ -863,7 +857,6 @@
 				  xfrm_address_t *daddr, xfrm_address_t *saddr, 
 				  int create, unsigned short family);
 extern void xfrm_policy_flush(void);
-extern void xfrm_policy_kill(struct xfrm_policy *);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 extern struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir, struct flowi *fl);
 extern int xfrm_flush_bundles(void);
--- 1.4/net/xfrm/xfrm_export.c	2004-08-19 16:13:10 +02:00
+++ edited/net/xfrm/xfrm_export.c	2004-10-23 14:04:12 +02:00
@@ -12,22 +12,17 @@
 EXPORT_SYMBOL(__xfrm_route_forward);
 EXPORT_SYMBOL(xfrm_state_alloc);
 EXPORT_SYMBOL(__xfrm_state_destroy);
-EXPORT_SYMBOL(xfrm_state_find);
 EXPORT_SYMBOL(xfrm_state_insert);
 EXPORT_SYMBOL(xfrm_state_add);
 EXPORT_SYMBOL(xfrm_state_update);
 EXPORT_SYMBOL(xfrm_state_check_expire);
-EXPORT_SYMBOL(xfrm_state_check_space);
 EXPORT_SYMBOL(xfrm_state_check);
 EXPORT_SYMBOL(xfrm_state_lookup);
 EXPORT_SYMBOL(xfrm_state_register_afinfo);
 EXPORT_SYMBOL(xfrm_state_unregister_afinfo);
-EXPORT_SYMBOL(xfrm_state_get_afinfo);
-EXPORT_SYMBOL(xfrm_state_put_afinfo);
 EXPORT_SYMBOL(xfrm_state_delete_tunnel);
 EXPORT_SYMBOL(xfrm_replay_check);
 EXPORT_SYMBOL(xfrm_replay_advance);
-EXPORT_SYMBOL(xfrm_check_selectors);
 EXPORT_SYMBOL(__secpath_destroy);
 EXPORT_SYMBOL(secpath_dup);
 EXPORT_SYMBOL(xfrm_get_acqseq);
@@ -44,7 +39,6 @@
 EXPORT_SYMBOL(xfrm_find_acq);
 EXPORT_SYMBOL(xfrm_alloc_spi);
 EXPORT_SYMBOL(xfrm_state_flush);
-EXPORT_SYMBOL(xfrm_policy_kill);
 EXPORT_SYMBOL(xfrm_policy_bysel);
 EXPORT_SYMBOL(xfrm_policy_insert);
 EXPORT_SYMBOL(xfrm_policy_walk);
@@ -54,8 +48,6 @@
 EXPORT_SYMBOL(xfrm_dst_lookup);
 EXPORT_SYMBOL(xfrm_policy_register_afinfo);
 EXPORT_SYMBOL(xfrm_policy_unregister_afinfo);
-EXPORT_SYMBOL(xfrm_policy_get_afinfo);
-EXPORT_SYMBOL(xfrm_policy_put_afinfo);
 
 EXPORT_SYMBOL_GPL(xfrm_probe_algs);
 EXPORT_SYMBOL_GPL(xfrm_count_auth_supported);
--- 1.56/net/xfrm/xfrm_policy.c	2004-10-21 06:49:33 +02:00
+++ edited/net/xfrm/xfrm_policy.c	2004-10-23 14:04:31 +02:00
@@ -40,6 +40,9 @@
 	LIST_HEAD_INIT(xfrm_policy_gc_list);
 static spinlock_t xfrm_policy_gc_lock = SPIN_LOCK_UNLOCKED;
 
+static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family);
+static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo);
+
 int xfrm_register_type(struct xfrm_type *type, unsigned short family)
 {
 	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
@@ -286,7 +289,7 @@
  * entry dead. The rule must be unlinked from lists to the moment.
  */
 
-void xfrm_policy_kill(struct xfrm_policy *policy)
+static void xfrm_policy_kill(struct xfrm_policy *policy)
 {
 	write_lock_bh(&policy->lock);
 	if (policy->dead)
@@ -1187,7 +1190,7 @@
 	return err;
 }
 
-struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family)
+static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family)
 {
 	struct xfrm_policy_afinfo *afinfo;
 	if (unlikely(family >= NPROTO))
@@ -1200,7 +1203,7 @@
 	return afinfo;
 }
 
-void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo)
+static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo)
 {
 	if (unlikely(afinfo == NULL))
 		return;
--- 1.49/net/xfrm/xfrm_state.c	2004-09-23 22:04:21 +02:00
+++ edited/net/xfrm/xfrm_state.c	2004-10-23 14:02:23 +02:00
@@ -48,6 +48,9 @@
 
 static void __xfrm_state_delete(struct xfrm_state *x);
 
+static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned short family);
+static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
+
 static void xfrm_state_gc_destroy(struct xfrm_state *x)
 {
 	if (del_timer(&x->timer))
@@ -526,7 +529,7 @@
 	return 0;
 }
 
-int xfrm_state_check_space(struct xfrm_state *x, struct sk_buff *skb)
+static int xfrm_state_check_space(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int nhead = x->props.header_len + LL_RESERVED_SPACE(skb->dst->dev)
 		- skb_headroom(skb);
@@ -740,19 +743,6 @@
 	}
 }
 
-int xfrm_check_selectors(struct xfrm_state **x, int n, struct flowi *fl)
-{
-	int i;
-
-	for (i=0; i<n; i++) {
-		int match;
-		match = xfrm_selector_match(&x[i]->sel, fl, x[i]->props.family);
-		if (!match)
-			return -EINVAL;
-	}
-	return 0;
-}
-
 static struct list_head xfrm_km_list = LIST_HEAD_INIT(xfrm_km_list);
 static rwlock_t		xfrm_km_lock = RW_LOCK_UNLOCKED;
 
@@ -914,7 +904,7 @@
 	return err;
 }
 
-struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned short family)
+static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned short family)
 {
 	struct xfrm_state_afinfo *afinfo;
 	if (unlikely(family >= NPROTO))
@@ -927,7 +917,7 @@
 	return afinfo;
 }
 
-void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo)
+static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo)
 {
 	if (unlikely(afinfo == NULL))
 		return;
