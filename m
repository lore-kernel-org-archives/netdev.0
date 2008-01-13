From: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>
Subject: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Sun, 13 Jan 2008 14:26:51 +0200
Message-ID: <478A038B.4090900@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:17721 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbYAMM0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 07:26:02 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1844792fga.17
        for <netdev@vger.kernel.org>; Sun, 13 Jan 2008 04:25:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

The problem with IPsec SP/SA dumping is that they don't work well with large SPD/SADB:s. In netlink the dumping code is O(n^2) and can miss some entries/dump duplicates if the DB is changed between the recv() calls to read the dump entries. This is due to the entry index counting done in xfrm_user code. With af_key the dump entries are just dropped when the socket receive queue is filled.

I tried to address all these problems, and added the xfrm_policy and xfrm_state structure to a new linked list that is used solely for dumping. This way the dumps can be done in O(n) and have an iterator point to them. I also modified to af_key to stop dumping when receive queue is filling up and continue it from a callback at recvfrom() when there's more room.

This patch is against 2.6.23 vanilla. I wanted to get some feedback before I make it against the git tree.

But I'd like to hear about:
- if the approach is ok (adding the entries in one more list)?
- if the new/modified variables, structures and function names are ok?
- if I should port these against net-2.6 or net-2.6.25 git tree?
- if I should split this to more than one commit? (maybe xfrm core, xfrm user and af_key parts?)

Cheers,
  Timo

Index: linux-2.6.23/include/net/xfrm.h
===================================================================
--- linux-2.6.23.orig/include/net/xfrm.h	2008-01-13 14:13:21.000000000 +0200
+++ linux-2.6.23/include/net/xfrm.h	2008-01-13 14:13:34.000000000 +0200
@@ -104,6 +104,7 @@
 struct xfrm_state
 {
 	/* Note: bydst is re-used during gc */
+	struct list_head	all;
 	struct hlist_node	bydst;
 	struct hlist_node	bysrc;
 	struct hlist_node	byspi;
@@ -346,6 +347,7 @@
 struct xfrm_policy
 {
 	struct xfrm_policy	*next;
+	struct list_head	bytype;
 	struct hlist_node	bydst;
 	struct hlist_node	byidx;
 
@@ -912,6 +914,17 @@
 	int priority;
 };
 
+struct xfrm_state_walker {
+	struct xfrm_state *state;
+	int count;
+};
+
+struct xfrm_policy_walker {
+	struct xfrm_policy *policy;
+	int count;
+	int type;
+};
+
 extern void xfrm_init(void);
 extern void xfrm4_init(void);
 extern void xfrm6_init(void);
@@ -921,7 +934,15 @@
 extern void xfrm6_state_init(void);
 extern void xfrm6_state_fini(void);
 
-extern int xfrm_state_walk(u8 proto, int (*func)(struct xfrm_state *, int, void*), void *);
+static inline void xfrm_state_walk_start(struct xfrm_state_walker *walk)
+{
+	walk->state = NULL;
+	walk->count = 0;
+}
+
+extern int xfrm_state_walk(struct xfrm_state_walker *walk, u8 proto,
+			   int (*func)(struct xfrm_state *, int, void*), void *);
+extern void xfrm_state_walk_end(struct xfrm_state_walker *walk);
 extern struct xfrm_state *xfrm_state_alloc(void);
 extern struct xfrm_state *xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr, 
 					  struct flowi *fl, struct xfrm_tmpl *tmpl,
@@ -1025,7 +1046,17 @@
 #endif
 
 struct xfrm_policy *xfrm_policy_alloc(gfp_t gfp);
-extern int xfrm_policy_walk(u8 type, int (*func)(struct xfrm_policy *, int, int, void*), void *);
+
+static inline void xfrm_policy_walk_start(struct xfrm_policy_walker *walk)
+{
+	walk->policy = NULL;
+	walk->count = 0;
+	walk->type = XFRM_POLICY_TYPE_MAIN;
+}
+
+extern int xfrm_policy_walk(struct xfrm_policy_walker *walk, u8 type,
+	int (*func)(struct xfrm_policy *, int, int, void*), void *);
+extern void xfrm_policy_walk_end(struct xfrm_policy_walker *walk);
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl);
 struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
 					  struct xfrm_selector *sel,
Index: linux-2.6.23/net/key/af_key.c
===================================================================
--- linux-2.6.23.orig/net/key/af_key.c	2008-01-13 14:13:21.000000000 +0200
+++ linux-2.6.23/net/key/af_key.c	2008-01-13 14:13:34.000000000 +0200
@@ -48,6 +48,16 @@
 	struct sock	sk;
 	int		registered;
 	int		promisc;
+
+	u8              dump_type;
+	uint8_t		dump_msg_version;
+	uint32_t	dump_msg_pid;
+	int		(*dump)(struct pfkey_sock *sk);
+	void		(*dump_done)(struct pfkey_sock *sk);
+	union {
+		struct xfrm_policy_walker	policy;
+		struct xfrm_state_walker	state;
+	} u;
 };
 
 static inline struct pfkey_sock *pfkey_sk(struct sock *sk)
@@ -55,6 +65,30 @@
 	return (struct pfkey_sock *)sk;
 }
 
+static int pfkey_can_dump(struct sock *sk)
+{
+	if (3 * atomic_read(&sk->sk_rmem_alloc) <= 2 * sk->sk_rcvbuf)
+		return 1;
+	return 0;
+}
+
+static int pfkey_do_dump(struct pfkey_sock *pfk)
+{
+	int rc;
+
+	rc = pfk->dump(pfk);
+	if (rc != 0) {
+		if (rc == -ENOBUFS)
+			return 0;
+		return rc;
+	}
+
+	pfk->dump_done(pfk);
+	pfk->dump = NULL;
+	pfk->dump_done = NULL;
+	return 0;
+}
+
 static void pfkey_sock_destruct(struct sock *sk)
 {
 	skb_queue_purge(&sk->sk_receive_queue);
@@ -1705,45 +1739,62 @@
 	return 0;
 }
 
-struct pfkey_dump_data
-{
-	struct sk_buff *skb;
-	struct sadb_msg *hdr;
-	struct sock *sk;
-};
-
 static int dump_sa(struct xfrm_state *x, int count, void *ptr)
 {
-	struct pfkey_dump_data *data = ptr;
+	struct pfkey_sock *pfk = ptr;
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
 
+	if (!pfkey_can_dump(&pfk->sk))
+		return -ENOBUFS;
+
 	out_skb = pfkey_xfrm_state2msg(x, 1, 3);
 	if (IS_ERR(out_skb))
 		return PTR_ERR(out_skb);
 
 	out_hdr = (struct sadb_msg *) out_skb->data;
-	out_hdr->sadb_msg_version = data->hdr->sadb_msg_version;
+	out_hdr->sadb_msg_version = pfk->dump_msg_version;
 	out_hdr->sadb_msg_type = SADB_DUMP;
 	out_hdr->sadb_msg_satype = pfkey_proto2satype(x->id.proto);
 	out_hdr->sadb_msg_errno = 0;
 	out_hdr->sadb_msg_reserved = 0;
 	out_hdr->sadb_msg_seq = count;
-	out_hdr->sadb_msg_pid = data->hdr->sadb_msg_pid;
-	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ONE, data->sk);
+	out_hdr->sadb_msg_pid = pfk->dump_msg_pid;
+	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ONE, &pfk->sk);
 	return 0;
 }
 
+static int pfkey_dump_sa(struct pfkey_sock *pfk)
+{
+	return xfrm_state_walk(&pfk->u.state, pfk->dump_type,
+			       dump_sa, (void *) pfk);
+}
+
+static void pfkey_dump_sa_done(struct pfkey_sock *pfk)
+{
+	xfrm_state_walk_end(&pfk->u.state);
+}
+
 static int pfkey_dump(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
 {
+	struct pfkey_sock *pfk = pfkey_sk(sk);
 	u8 proto;
-	struct pfkey_dump_data data = { .skb = skb, .hdr = hdr, .sk = sk };
+
+	if (pfk->dump != NULL)
+		return -EBUSY;
 
 	proto = pfkey_satype2proto(hdr->sadb_msg_satype);
 	if (proto == 0)
 		return -EINVAL;
 
-	return xfrm_state_walk(proto, dump_sa, &data);
+	pfk->dump_type = proto;
+	pfk->dump_msg_version = hdr->sadb_msg_version;
+	pfk->dump_msg_pid = hdr->sadb_msg_pid;
+	pfk->dump = pfkey_dump_sa;
+	pfk->dump_done = pfkey_dump_sa_done;
+	xfrm_state_walk_start(&pfk->u.state);
+
+	return pfkey_do_dump(pfk);
 }
 
 static int pfkey_promisc(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
@@ -1776,6 +1827,7 @@
 
 static u32 gen_reqid(void)
 {
+	struct xfrm_policy_walker walker;
 	u32 start;
 	static u32 reqid = IPSEC_MANUAL_REQID_MAX;
 
@@ -1784,9 +1836,11 @@
 		++reqid;
 		if (reqid == 0)
 			reqid = IPSEC_MANUAL_REQID_MAX+1;
-		if (xfrm_policy_walk(XFRM_POLICY_TYPE_MAIN, check_reqid,
+		xfrm_policy_walk_start(&walker);
+		if (xfrm_policy_walk(&walker, XFRM_POLICY_TYPE_MAIN, check_reqid,
 				     (void*)&reqid) != -EEXIST)
 			return reqid;
+		xfrm_policy_walk_end(&walker);
 	} while (reqid != start);
 	return 0;
 }
@@ -2634,11 +2688,14 @@
 
 static int dump_sp(struct xfrm_policy *xp, int dir, int count, void *ptr)
 {
-	struct pfkey_dump_data *data = ptr;
+	struct pfkey_sock *pfk = ptr;
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
 	int err;
 
+	if (!pfkey_can_dump(&pfk->sk))
+		return -ENOBUFS;
+
 	out_skb = pfkey_xfrm_policy2msg_prep(xp);
 	if (IS_ERR(out_skb))
 		return PTR_ERR(out_skb);
@@ -2648,21 +2705,42 @@
 		return err;
 
 	out_hdr = (struct sadb_msg *) out_skb->data;
-	out_hdr->sadb_msg_version = data->hdr->sadb_msg_version;
+	out_hdr->sadb_msg_version = pfk->dump_msg_version;
 	out_hdr->sadb_msg_type = SADB_X_SPDDUMP;
 	out_hdr->sadb_msg_satype = SADB_SATYPE_UNSPEC;
 	out_hdr->sadb_msg_errno = 0;
 	out_hdr->sadb_msg_seq = count;
-	out_hdr->sadb_msg_pid = data->hdr->sadb_msg_pid;
-	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ONE, data->sk);
+	out_hdr->sadb_msg_pid = pfk->dump_msg_pid;
+	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ONE, &pfk->sk);
 	return 0;
 }
 
+static int pfkey_dump_sp(struct pfkey_sock *pfk)
+{
+	return xfrm_policy_walk(&pfk->u.policy, pfk->dump_type,
+				dump_sp, (void *) pfk);
+}
+
+static void pfkey_dump_sp_done(struct pfkey_sock *pfk)
+{
+	xfrm_policy_walk_end(&pfk->u.policy);
+}
+
 static int pfkey_spddump(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
 {
-	struct pfkey_dump_data data = { .skb = skb, .hdr = hdr, .sk = sk };
+	struct pfkey_sock *pfk = pfkey_sk(sk);
+
+	if (pfk->dump != NULL)
+		return -EBUSY;
+
+	pfk->dump_type = XFRM_POLICY_TYPE_MAIN;
+	pfk->dump_msg_version = hdr->sadb_msg_version;
+	pfk->dump_msg_pid = hdr->sadb_msg_pid;
+	pfk->dump = pfkey_dump_sp;
+	pfk->dump_done = pfkey_dump_sp_done;
+	xfrm_policy_walk_start(&pfk->u.policy);
 
-	return xfrm_policy_walk(XFRM_POLICY_TYPE_MAIN, dump_sp, &data);
+	return pfkey_do_dump(pfk);
 }
 
 static int key_notify_policy_flush(struct km_event *c)
@@ -3656,6 +3734,7 @@
 			 int flags)
 {
 	struct sock *sk = sock->sk;
+	struct pfkey_sock *pfk = pfkey_sk(sk);
 	struct sk_buff *skb;
 	int copied, err;
 
@@ -3681,6 +3760,10 @@
 
 	sock_recv_timestamp(msg, sk, skb);
 
+	if (pfk->dump != NULL &&
+	    3 * atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf)
+		pfkey_do_dump(pfk);
+
 	err = (flags & MSG_TRUNC) ? skb->len : copied;
 
 out_free:
Index: linux-2.6.23/net/xfrm/xfrm_policy.c
===================================================================
--- linux-2.6.23.orig/net/xfrm/xfrm_policy.c	2008-01-13 14:13:21.000000000 +0200
+++ linux-2.6.23/net/xfrm/xfrm_policy.c	2008-01-13 14:13:34.000000000 +0200
@@ -36,6 +36,7 @@
 
 static DEFINE_RWLOCK(xfrm_policy_lock);
 
+static struct list_head xfrm_policy_bytype[XFRM_POLICY_TYPE_MAX];
 unsigned int xfrm_policy_count[XFRM_POLICY_MAX*2];
 EXPORT_SYMBOL(xfrm_policy_count);
 
@@ -349,6 +350,7 @@
 	policy = kzalloc(sizeof(struct xfrm_policy), gfp);
 
 	if (policy) {
+		INIT_LIST_HEAD(&policy->bytype);
 		INIT_HLIST_NODE(&policy->bydst);
 		INIT_HLIST_NODE(&policy->byidx);
 		rwlock_init(&policy->lock);
@@ -372,6 +374,10 @@
 	if (del_timer(&policy->timer))
 		BUG();
 
+	write_lock_bh(&xfrm_policy_lock);
+	list_del(&policy->bytype);
+	write_unlock_bh(&xfrm_policy_lock);
+
 	security_xfrm_policy_free(policy);
 	kfree(policy);
 }
@@ -710,6 +716,7 @@
 	policy->curlft.use_time = 0;
 	if (!mod_timer(&policy->timer, jiffies + HZ))
 		xfrm_pol_hold(policy);
+	list_add_tail(&policy->bytype, &xfrm_policy_bytype[policy->type]);
 	write_unlock_bh(&xfrm_policy_lock);
 
 	if (delpol)
@@ -952,61 +959,71 @@
 }
 EXPORT_SYMBOL(xfrm_policy_flush);
 
-int xfrm_policy_walk(u8 type, int (*func)(struct xfrm_policy *, int, int, void*),
+int xfrm_policy_walk(struct xfrm_policy_walker *walk, u8 type,
+		     int (*func)(struct xfrm_policy *, int, int, void*),
 		     void *data)
 {
-	struct xfrm_policy *pol, *last = NULL;
-	struct hlist_node *entry;
-	int dir, last_dir = 0, count, error;
+	struct xfrm_policy *old, *pol, *last = NULL;
+	int error = 0;
+
+	if (type >= XFRM_POLICY_TYPE_MAX && type != XFRM_POLICY_TYPE_ANY)
+		return -EINVAL;
+
+	if (walk->policy == NULL && walk->count != 0)
+		return 0;
 
+	old = pol = walk->policy;
+	walk->policy = NULL;
 	read_lock_bh(&xfrm_policy_lock);
-	count = 0;
 
-	for (dir = 0; dir < 2*XFRM_POLICY_MAX; dir++) {
-		struct hlist_head *table = xfrm_policy_bydst[dir].table;
-		int i;
+	for (; walk->type < XFRM_POLICY_TYPE_MAX; walk->type++) {
+		if (type != walk->type && type != XFRM_POLICY_TYPE_ANY)
+			continue;
 
-		hlist_for_each_entry(pol, entry,
-				     &xfrm_policy_inexact[dir], bydst) {
-			if (pol->type != type)
+		if (pol == NULL) {
+			pol = list_first_entry(&xfrm_policy_bytype[walk->type],
+					       struct xfrm_policy, bytype);
+		}
+		list_for_each_entry_from(pol, &xfrm_policy_bytype[walk->type], bytype) {
+			if (pol->dead)
 				continue;
 			if (last) {
-				error = func(last, last_dir % XFRM_POLICY_MAX,
-					     count, data);
-				if (error)
+				error = func(last, xfrm_policy_id2dir(last->index),
+					     walk->count, data);
+				if (error) {
+					xfrm_pol_hold(last);
+					walk->policy = last;
 					goto out;
-			}
-			last = pol;
-			last_dir = dir;
-			count++;
-		}
-		for (i = xfrm_policy_bydst[dir].hmask; i >= 0; i--) {
-			hlist_for_each_entry(pol, entry, table + i, bydst) {
-				if (pol->type != type)
-					continue;
-				if (last) {
-					error = func(last, last_dir % XFRM_POLICY_MAX,
-						     count, data);
-					if (error)
-						goto out;
 				}
-				last = pol;
-				last_dir = dir;
-				count++;
 			}
+			last = pol;
+			walk->count++;
 		}
+		pol = NULL;
 	}
-	if (count == 0) {
+	if (walk->count == 0) {
 		error = -ENOENT;
 		goto out;
 	}
-	error = func(last, last_dir % XFRM_POLICY_MAX, 0, data);
+	if (last)
+		error = func(last, xfrm_policy_id2dir(last->index), 0, data);
 out:
 	read_unlock_bh(&xfrm_policy_lock);
+	if (old != NULL)
+		xfrm_pol_put(old);
 	return error;
 }
 EXPORT_SYMBOL(xfrm_policy_walk);
 
+void xfrm_policy_walk_end(struct xfrm_policy_walker *walker)
+{
+	if (walker->policy != NULL) {
+		xfrm_pol_put(walker->policy);
+		walker->policy = NULL;
+	}
+}
+EXPORT_SYMBOL(xfrm_policy_walk_end);
+
 /*
  * Find policy to apply to this flow.
  *
@@ -2401,6 +2418,9 @@
 			panic("XFRM: failed to allocate bydst hash\n");
 	}
 
+	for (dir = 0; dir < XFRM_POLICY_TYPE_MAX; dir++)
+		INIT_LIST_HEAD(&xfrm_policy_bytype[dir]);
+
 	INIT_WORK(&xfrm_policy_gc_work, xfrm_policy_gc_task);
 	register_netdevice_notifier(&xfrm_dev_notifier);
 }
Index: linux-2.6.23/net/xfrm/xfrm_state.c
===================================================================
--- linux-2.6.23.orig/net/xfrm/xfrm_state.c	2008-01-13 14:13:21.000000000 +0200
+++ linux-2.6.23/net/xfrm/xfrm_state.c	2008-01-13 14:13:34.000000000 +0200
@@ -50,6 +50,7 @@
  * Main use is finding SA after policy selected tunnel or transport mode.
  * Also, it can be used by ah/esp icmp error handler to find offending SA.
  */
+static LIST_HEAD(xfrm_state_all);
 static struct hlist_head *xfrm_state_bydst __read_mostly;
 static struct hlist_head *xfrm_state_bysrc __read_mostly;
 static struct hlist_head *xfrm_state_byspi __read_mostly;
@@ -319,6 +320,7 @@
 	if (x) {
 		atomic_set(&x->refcnt, 1);
 		atomic_set(&x->tunnel_users, 0);
+		INIT_LIST_HEAD(&x->all);
 		INIT_HLIST_NODE(&x->bydst);
 		INIT_HLIST_NODE(&x->bysrc);
 		INIT_HLIST_NODE(&x->byspi);
@@ -345,6 +347,10 @@
 {
 	BUG_TRAP(x->km.state == XFRM_STATE_DEAD);
 
+	spin_lock_bh(&xfrm_state_lock);
+	list_del(&x->all);
+	spin_unlock_bh(&xfrm_state_lock);
+
 	spin_lock_bh(&xfrm_state_gc_lock);
 	hlist_add_head(&x->bydst, &xfrm_state_gc_list);
 	spin_unlock_bh(&xfrm_state_gc_lock);
@@ -722,6 +728,8 @@
 
 	x->genid = ++xfrm_state_genid;
 
+	list_add_tail(&x->all, &xfrm_state_all);
+
 	h = xfrm_dst_hash(&x->id.daddr, &x->props.saddr,
 			  x->props.reqid, x->props.family);
 	hlist_add_head(&x->bydst, xfrm_state_bydst+h);
@@ -1343,40 +1351,59 @@
 }
 EXPORT_SYMBOL(xfrm_alloc_spi);
 
-int xfrm_state_walk(u8 proto, int (*func)(struct xfrm_state *, int, void*),
+int xfrm_state_walk(struct xfrm_state_walker *walk, u8 proto,
+		    int (*func)(struct xfrm_state *, int, void*),
 		    void *data)
 {
-	int i;
-	struct xfrm_state *x, *last = NULL;
-	struct hlist_node *entry;
-	int count = 0;
+	struct xfrm_state *old, *x, *last = NULL;
 	int err = 0;
 
+	if (walk->state == NULL && walk->count != 0)
+		return 0;
+
+	old = x = walk->state;
+	walk->state = NULL;
 	spin_lock_bh(&xfrm_state_lock);
-	for (i = 0; i <= xfrm_state_hmask; i++) {
-		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
-			if (!xfrm_id_proto_match(x->id.proto, proto))
-				continue;
-			if (last) {
-				err = func(last, count, data);
-				if (err)
-					goto out;
+	if (x == NULL)
+		x = list_first_entry(&xfrm_state_all, struct xfrm_state, all);
+	list_for_each_entry_from(x, &xfrm_state_all, all) {
+		if (x->km.state == XFRM_STATE_DEAD)
+			continue;
+		if (!xfrm_id_proto_match(x->id.proto, proto))
+			continue;
+		if (last) {
+			err = func(last, walk->count, data);
+			if (err) {
+				xfrm_state_hold(last);
+				walk->state = last;
+				goto out;
 			}
-			last = x;
-			count++;
 		}
+		last = x;
+		walk->count++;
 	}
-	if (count == 0) {
+	if (walk->count == 0) {
 		err = -ENOENT;
 		goto out;
 	}
-	err = func(last, 0, data);
+	if (last)
+		err = func(last, 0, data);
 out:
 	spin_unlock_bh(&xfrm_state_lock);
+	if (old != NULL)
+		xfrm_state_put(old);
 	return err;
 }
 EXPORT_SYMBOL(xfrm_state_walk);
 
+void xfrm_state_walk_end(struct xfrm_state_walker *walk)
+{
+	if (walk->state != NULL) {
+		xfrm_state_put(walk->state);
+		walk->state = NULL;
+	}
+}
+EXPORT_SYMBOL(xfrm_state_walk_end);
 
 void xfrm_replay_notify(struct xfrm_state *x, int event)
 {
Index: linux-2.6.23/net/xfrm/xfrm_user.c
===================================================================
--- linux-2.6.23.orig/net/xfrm/xfrm_user.c	2008-01-13 14:13:21.000000000 +0200
+++ linux-2.6.23/net/xfrm/xfrm_user.c	2008-01-13 14:13:34.000000000 +0200
@@ -572,8 +572,6 @@
 	struct sk_buff *out_skb;
 	u32 nlmsg_seq;
 	u16 nlmsg_flags;
-	int start_idx;
-	int this_idx;
 };
 
 static int dump_one_state(struct xfrm_state *x, int count, void *ptr)
@@ -585,9 +583,6 @@
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
 
-	if (sp->this_idx < sp->start_idx)
-		goto out;
-
 	nlh = NLMSG_PUT(skb, NETLINK_CB(in_skb).pid,
 			sp->nlmsg_seq,
 			XFRM_MSG_NEWSA, sizeof(*p));
@@ -629,8 +624,6 @@
 		RTA_PUT(skb, XFRMA_LASTUSED, sizeof(x->lastused), &x->lastused);
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
-out:
-	sp->this_idx++;
 	return 0;
 
 nlmsg_failure:
@@ -639,18 +632,23 @@
 	return -1;
 }
 
+static int xfrm_dump_sa_done(struct netlink_callback *cb)
+{
+	struct xfrm_state_walker *walker = (struct xfrm_state_walker *) cb->args;
+	xfrm_state_walk_end(walker);
+	return 0;
+}
+
 static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
 {
+	struct xfrm_state_walker *walker = (struct xfrm_state_walker *) cb->args;
 	struct xfrm_dump_info info;
 
 	info.in_skb = cb->skb;
 	info.out_skb = skb;
 	info.nlmsg_seq = cb->nlh->nlmsg_seq;
 	info.nlmsg_flags = NLM_F_MULTI;
-	info.this_idx = 0;
-	info.start_idx = cb->args[0];
-	(void) xfrm_state_walk(0, dump_one_state, &info);
-	cb->args[0] = info.this_idx;
+	(void) xfrm_state_walk(walker, 0, dump_one_state, &info);
 
 	return skb->len;
 }
@@ -669,7 +667,6 @@
 	info.out_skb = skb;
 	info.nlmsg_seq = seq;
 	info.nlmsg_flags = 0;
-	info.this_idx = info.start_idx = 0;
 
 	if (dump_one_state(x, 0, &info)) {
 		kfree_skb(skb);
@@ -1273,9 +1270,6 @@
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
 
-	if (sp->this_idx < sp->start_idx)
-		goto out;
-
 	nlh = NLMSG_PUT(skb, NETLINK_CB(in_skb).pid,
 			sp->nlmsg_seq,
 			XFRM_MSG_NEWPOLICY, sizeof(*p));
@@ -1291,8 +1285,6 @@
 		goto nlmsg_failure;
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
-out:
-	sp->this_idx++;
 	return 0;
 
 nlmsg_failure:
@@ -1300,21 +1292,26 @@
 	return -1;
 }
 
+static int xfrm_dump_policy_done(struct netlink_callback *cb)
+{
+	struct xfrm_policy_walker *walker = (struct xfrm_policy_walker *) cb->args;
+
+	xfrm_policy_walk_end(walker);
+	return 0;
+}
+
 static int xfrm_dump_policy(struct sk_buff *skb, struct netlink_callback *cb)
 {
+	struct xfrm_policy_walker *walker = (struct xfrm_policy_walker *) cb->args;
 	struct xfrm_dump_info info;
 
 	info.in_skb = cb->skb;
 	info.out_skb = skb;
 	info.nlmsg_seq = cb->nlh->nlmsg_seq;
 	info.nlmsg_flags = NLM_F_MULTI;
-	info.this_idx = 0;
-	info.start_idx = cb->args[0];
-	(void) xfrm_policy_walk(XFRM_POLICY_TYPE_MAIN, dump_one_policy, &info);
-#ifdef CONFIG_XFRM_SUB_POLICY
-	(void) xfrm_policy_walk(XFRM_POLICY_TYPE_SUB, dump_one_policy, &info);
-#endif
-	cb->args[0] = info.this_idx;
+
+	(void) xfrm_policy_walk(walker, XFRM_POLICY_TYPE_ANY,
+				dump_one_policy, &info);
 
 	return skb->len;
 }
@@ -1334,7 +1331,6 @@
 	info.out_skb = skb;
 	info.nlmsg_seq = seq;
 	info.nlmsg_flags = 0;
-	info.this_idx = info.start_idx = 0;
 
 	if (dump_one_policy(xp, dir, 0, &info) < 0) {
 		kfree_skb(skb);
@@ -1951,15 +1947,18 @@
 static struct xfrm_link {
 	int (*doit)(struct sk_buff *, struct nlmsghdr *, struct rtattr **);
 	int (*dump)(struct sk_buff *, struct netlink_callback *);
+	int (*done)(struct netlink_callback *);
 } xfrm_dispatch[XFRM_NR_MSGTYPES] = {
 	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] = { .doit = xfrm_add_sa        },
 	[XFRM_MSG_DELSA       - XFRM_MSG_BASE] = { .doit = xfrm_del_sa        },
 	[XFRM_MSG_GETSA       - XFRM_MSG_BASE] = { .doit = xfrm_get_sa,
-						   .dump = xfrm_dump_sa       },
+						   .dump = xfrm_dump_sa,
+						   .done = xfrm_dump_sa_done  },
 	[XFRM_MSG_NEWPOLICY   - XFRM_MSG_BASE] = { .doit = xfrm_add_policy    },
 	[XFRM_MSG_DELPOLICY   - XFRM_MSG_BASE] = { .doit = xfrm_get_policy    },
 	[XFRM_MSG_GETPOLICY   - XFRM_MSG_BASE] = { .doit = xfrm_get_policy,
-						   .dump = xfrm_dump_policy   },
+						   .dump = xfrm_dump_policy,
+						   .done = xfrm_dump_policy_done },
 	[XFRM_MSG_ALLOCSPI    - XFRM_MSG_BASE] = { .doit = xfrm_alloc_userspi },
 	[XFRM_MSG_ACQUIRE     - XFRM_MSG_BASE] = { .doit = xfrm_add_acquire   },
 	[XFRM_MSG_EXPIRE      - XFRM_MSG_BASE] = { .doit = xfrm_add_sa_expire },
@@ -1998,7 +1997,7 @@
 		if (link->dump == NULL)
 			return -EINVAL;
 
-		return netlink_dump_start(xfrm_nl, skb, nlh, link->dump, NULL);
+		return netlink_dump_start(xfrm_nl, skb, nlh, link->dump, link->done);
 	}
 
 	memset(xfrma, 0, sizeof(xfrma));
Index: linux-2.6.23/include/linux/xfrm.h
===================================================================
--- linux-2.6.23.orig/include/linux/xfrm.h	2007-10-09 23:31:38.000000000 +0300
+++ linux-2.6.23/include/linux/xfrm.h	2008-01-13 14:13:35.000000000 +0200
@@ -106,7 +106,8 @@
 {
 	XFRM_POLICY_TYPE_MAIN	= 0,
 	XFRM_POLICY_TYPE_SUB	= 1,
-	XFRM_POLICY_TYPE_MAX	= 2
+	XFRM_POLICY_TYPE_MAX	= 2,
+	XFRM_POLICY_TYPE_ANY	= 255
 };
 
 enum

