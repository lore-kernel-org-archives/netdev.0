From: jamal <hadi@cyberus.ca>
Subject: PATCH: IPSEC xfrm events
Date: 31 Mar 2005 20:37:21 -0500
Message-ID: <1112319441.1089.83.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-RQGyAfq73Wh6tlnAcR0C"
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-RQGyAfq73Wh6tlnAcR0C
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Herbert et al,

Ok, heres the final patch with all the changes discussed.

 include/linux/xfrm.h   |    2 
 include/net/xfrm.h     |   29 ++++++-
 net/key/af_key.c       |   24 +++++-
 net/xfrm/xfrm_policy.c |   25 ++++--
 net/xfrm/xfrm_state.c  |   84 +++++++++++++++++++--
 net/xfrm/xfrm_user.c   |  188
++++++++++++++++++++++++++++++++++++++++++++++++-
 6 files changed, 323 insertions(+), 29 deletions(-)

I have tested this with both setkey and iproute2 (about 10 scenarios or
so). Masahide-san is doing a lot more thorough testing with key servers
as well. He has not tested this patch yet (time difference) but it is
based on the last one he tested.

Let me know what you think. If no issues i would like to push to Dave.
There are comments in the patch that are intentional so they can be
commented on.

cheers,
jamal

--=-RQGyAfq73Wh6tlnAcR0C
Content-Disposition: attachment; filename=ipsec-xfrm-ev-p
Content-Type: text/plain; name=ipsec-xfrm-ev-p; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/include/net/xfrm.h	2005-03-25 22:28:26.000000000 -0500
+++ b/include/net/xfrm.h	2005-03-31 19:26:24.000000000 -0500
@@ -157,6 +157,25 @@
 	XFRM_STATE_DEAD
 };
 
+/* events that could be sent by kernel */
+enum {
+	XFRM_SAP_INVALID,
+	XFRM_SAP_EXPIRED,
+	XFRM_SAP_ADDED,
+	XFRM_SAP_UPDATED,
+	XFRM_SAP_DELETED,
+	XFRM_SAP_FLUSHED,
+	__XFRM_SAP_MAX
+};
+#define XFRM_SAP_MAX (__XFRM_SAP_MAX - 1)
+
+/* callback structure passed from either netlink or pfkey */
+struct km_cb
+{
+	u32	data; /* callee to caller */
+};
+
+
 struct xfrm_type;
 struct xfrm_dst;
 struct xfrm_policy_afinfo {
@@ -178,6 +197,8 @@
 
 extern int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo);
 extern int xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo);
+extern void km_policy_notify(struct xfrm_policy *xp, int dir, int event, struct km_cb *c);
+
 
 #define XFRM_ACQ_EXPIRES	30
 
@@ -283,17 +304,17 @@
 	struct xfrm_tmpl       	xfrm_vec[XFRM_MAX_DEPTH];
 };
 
-#define XFRM_KM_TIMEOUT		30
 
+#define XFRM_KM_TIMEOUT		30
 struct xfrm_mgr
 {
 	struct list_head	list;
 	char			*id;
-	int			(*notify)(struct xfrm_state *x, int event);
+	int			(*notify)(struct xfrm_state *x, int event, struct km_cb *c);
 	int			(*acquire)(struct xfrm_state *x, struct xfrm_tmpl *, struct xfrm_policy *xp, int dir);
 	struct xfrm_policy	*(*compile_policy)(u16 family, int opt, u8 *data, int len, int *dir);
 	int			(*new_mapping)(struct xfrm_state *x, xfrm_address_t *ipaddr, u16 sport);
-	int			(*notify_policy)(struct xfrm_policy *x, int dir, int event);
+	int			(*notify_policy)(struct xfrm_policy *x, int dir, int event, struct km_cb *c);
 };
 
 extern int xfrm_register_km(struct xfrm_mgr *km);
@@ -860,7 +881,7 @@
 
 extern wait_queue_head_t km_waitq;
 extern int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, u16 sport);
-extern void km_policy_expired(struct xfrm_policy *pol, int dir, int hard);
+extern void km_policy_expired(struct xfrm_policy *pol, int dir, int event);
 
 extern void xfrm_input_init(void);
 extern int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, u32 *spi, u32 *seq);
--- a/include/linux/xfrm.h	2005-03-25 22:28:39.000000000 -0500
+++ b/include/linux/xfrm.h	2005-03-31 19:26:24.000000000 -0500
@@ -254,5 +254,7 @@
 
 #define XFRMGRP_ACQUIRE		1
 #define XFRMGRP_EXPIRE		2
+#define XFRMGRP_SA		4
+#define XFRMGRP_POLICY		8
 
 #endif /* _LINUX_XFRM_H */
--- a/net/xfrm/xfrm_state.c	2005-03-25 22:28:25.000000000 -0500
+++ b/net/xfrm/xfrm_state.c	2005-03-31 19:26:24.000000000 -0500
@@ -239,10 +239,56 @@
 	}
 }
 
+static DEFINE_RWLOCK(xfrm_km_lock);
+static struct list_head xfrm_km_list = LIST_HEAD_INIT(xfrm_km_list);
+
+void km_policy_notify(struct xfrm_policy *xp, int dir, int event, struct km_cb *c)
+{
+	struct xfrm_mgr *km;
+
+	read_lock(&xfrm_km_lock);
+	list_for_each_entry(km, &xfrm_km_list, list)
+		if (km && km->notify_policy)
+			km->notify_policy(xp, dir, event, c);
+	read_unlock(&xfrm_km_lock);
+}
+EXPORT_SYMBOL(km_policy_notify);
+
+void km_state_notify(struct xfrm_state *x, struct km_cb *c, int event)
+{
+	struct xfrm_mgr *km;
+	read_lock(&xfrm_km_lock);
+	list_for_each_entry(km, &xfrm_km_list, list)
+		km->notify(x, event, c);
+	read_unlock(&xfrm_km_lock);
+}
+
+void xfrm_state_del_flush(struct xfrm_state *x)
+{
+	spin_lock_bh(&x->lock);
+	__xfrm_state_delete(x);
+	spin_unlock_bh(&x->lock);
+}
+
 void xfrm_state_delete(struct xfrm_state *x)
 {
+	int notif = 0;
 	spin_lock_bh(&x->lock);
+	/* 
+	 * its unfortunate we have to freeze gc for this
+	 * one moment - the other alternative would involve
+	 * memcopying the state and then announcing that.
+	 * think SMP where theres an iota where this could mess
+	 * up - JHS
+	*/
+	spin_lock_bh(&xfrm_state_gc_lock);
+	if (x->km.state != XFRM_STATE_DEAD)
+		notif = 1;
 	__xfrm_state_delete(x);
+
+	if (notif)
+		km_state_notify(x, NULL, XFRM_SAP_DELETED);
+	spin_unlock_bh(&xfrm_state_gc_lock);
 	spin_unlock_bh(&x->lock);
 }
 EXPORT_SYMBOL(xfrm_state_delete);
@@ -251,6 +297,8 @@
 {
 	int i;
 	struct xfrm_state *x;
+	struct km_cb c;
+	int count = 0;
 
 	spin_lock_bh(&xfrm_state_lock);
 	for (i = 0; i < XFRM_DST_HSIZE; i++) {
@@ -261,7 +309,8 @@
 				xfrm_state_hold(x);
 				spin_unlock_bh(&xfrm_state_lock);
 
-				xfrm_state_delete(x);
+				xfrm_state_del_flush(x);
+				count++;
 				xfrm_state_put(x);
 
 				spin_lock_bh(&xfrm_state_lock);
@@ -270,6 +319,10 @@
 		}
 	}
 	spin_unlock_bh(&xfrm_state_lock);
+	if (count) {
+		c.data = proto;
+		km_state_notify(NULL, &c, XFRM_SAP_FLUSHED);
+	}
 	wake_up(&km_waitq);
 }
 EXPORT_SYMBOL(xfrm_state_flush);
@@ -402,6 +455,7 @@
 
 static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq);
 
+
 int xfrm_state_add(struct xfrm_state *x)
 {
 	struct xfrm_state_afinfo *afinfo;
@@ -438,6 +492,7 @@
 			&x->id.daddr, &x->props.saddr, 0);
 
 	__xfrm_state_insert(x);
+	km_state_notify(x, NULL, XFRM_SAP_ADDED);
 	err = 0;
 
 out:
@@ -478,6 +533,7 @@
 
 	if (x1->km.state == XFRM_STATE_ACQ) {
 		__xfrm_state_insert(x);
+		km_state_notify(x, NULL, XFRM_SAP_ADDED);
 		x = NULL;
 	}
 	err = 0;
@@ -509,6 +565,7 @@
 			xfrm_state_check_expire(x1);
 
 		err = 0;
+		km_state_notify(x, NULL, XFRM_SAP_UPDATED);
 	}
 	spin_unlock_bh(&x1->lock);
 
@@ -764,37 +821,41 @@
 }
 EXPORT_SYMBOL(xfrm_replay_advance);
 
-static struct list_head xfrm_km_list = LIST_HEAD_INIT(xfrm_km_list);
-static DEFINE_RWLOCK(xfrm_km_lock);
 
 static void km_state_expired(struct xfrm_state *x, int hard)
 {
 	struct xfrm_mgr *km;
+	struct km_cb c;
 
 	if (hard)
 		x->km.state = XFRM_STATE_EXPIRED;
 	else
 		x->km.dying = 1;
 
+	c.data = hard;
 	read_lock(&xfrm_km_lock);
 	list_for_each_entry(km, &xfrm_km_list, list)
-		km->notify(x, hard);
+		km->notify(x, XFRM_SAP_EXPIRED, &c);
 	read_unlock(&xfrm_km_lock);
 
 	if (hard)
 		wake_up(&km_waitq);
 }
 
+/*
+ * We send to all registered managers regardless of failure
+ * We are happy with one success
+*/
 static int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol)
 {
-	int err = -EINVAL;
+	int err = -EINVAL, acqret;
 	struct xfrm_mgr *km;
 
 	read_lock(&xfrm_km_lock);
 	list_for_each_entry(km, &xfrm_km_list, list) {
-		err = km->acquire(x, t, pol, XFRM_POLICY_OUT);
-		if (!err)
-			break;
+		acqret = km->acquire(x, t, pol, XFRM_POLICY_OUT);
+		if (!acqret)
+			err = acqret;
 	}
 	read_unlock(&xfrm_km_lock);
 	return err;
@@ -820,11 +881,13 @@
 void km_policy_expired(struct xfrm_policy *pol, int dir, int hard)
 {
 	struct xfrm_mgr *km;
+	struct km_cb c;
 
 	read_lock(&xfrm_km_lock);
+	c.data = hard;
 	list_for_each_entry(km, &xfrm_km_list, list)
 		if (km->notify_policy)
-			km->notify_policy(pol, dir, hard);
+			km->notify_policy(pol, dir, XFRM_SAP_EXPIRED, &c);
 	read_unlock(&xfrm_km_lock);
 
 	if (hard)
@@ -957,8 +1020,9 @@
 	if (x->tunnel) {
 		struct xfrm_state *t = x->tunnel;
 
+		/* XXX: Avoid announce?? */
 		if (atomic_read(&t->tunnel_users) == 2)
-			xfrm_state_delete(t);
+			xfrm_state_del_flush(t);
 		atomic_dec(&t->tunnel_users);
 		xfrm_state_put(t);
 		x->tunnel = NULL;
--- a/net/xfrm/xfrm_policy.c	2005-03-25 22:28:21.000000000 -0500
+++ b/net/xfrm/xfrm_policy.c	2005-03-31 19:26:24.000000000 -0500
@@ -298,7 +298,7 @@
  * entry dead. The rule must be unlinked from lists to the moment.
  */
 
-static void xfrm_policy_kill(struct xfrm_policy *policy)
+static void xfrm_policy_kill(struct xfrm_policy *policy, int dir, int notif)
 {
 	write_lock_bh(&policy->lock);
 	if (policy->dead)
@@ -307,6 +307,9 @@
 	policy->dead = 1;
 
 	spin_lock(&xfrm_policy_gc_lock);
+	if (notif) {
+		km_policy_notify(policy, dir, XFRM_SAP_DELETED, NULL);
+	}
 	list_add(&policy->list, &xfrm_policy_gc_list);
 	spin_unlock(&xfrm_policy_gc_lock);
 	schedule_work(&xfrm_policy_gc_work);
@@ -375,10 +378,11 @@
 	policy->curlft.use_time = 0;
 	if (!mod_timer(&policy->timer, jiffies + HZ))
 		xfrm_pol_hold(policy);
+	km_policy_notify(policy, dir, XFRM_SAP_ADDED, NULL);
 	write_unlock_bh(&xfrm_policy_lock);
 
 	if (delpol) {
-		xfrm_policy_kill(delpol);
+		xfrm_policy_kill(delpol, dir, 1);
 	}
 	return 0;
 }
@@ -402,7 +406,7 @@
 
 	if (pol && delete) {
 		atomic_inc(&flow_cache_genid);
-		xfrm_policy_kill(pol);
+		xfrm_policy_kill(pol, dir, 1);
 	}
 	return pol;
 }
@@ -425,16 +429,16 @@
 
 	if (pol && delete) {
 		atomic_inc(&flow_cache_genid);
-		xfrm_policy_kill(pol);
+		xfrm_policy_kill(pol, dir, 1);
 	}
 	return pol;
 }
 EXPORT_SYMBOL(xfrm_policy_byid);
 
-void xfrm_policy_flush(void)
+void xfrm_policy_flush()
 {
 	struct xfrm_policy *xp;
-	int dir;
+	int dir, count = 0;
 
 	write_lock_bh(&xfrm_policy_lock);
 	for (dir = 0; dir < XFRM_POLICY_MAX; dir++) {
@@ -442,12 +446,15 @@
 			xfrm_policy_list[dir] = xp->next;
 			write_unlock_bh(&xfrm_policy_lock);
 
-			xfrm_policy_kill(xp);
+			xfrm_policy_kill(xp, dir, 0);
+			count++;
 
 			write_lock_bh(&xfrm_policy_lock);
 		}
 	}
 	atomic_inc(&flow_cache_genid);
+	if (count)
+		km_policy_notify(NULL, 0, XFRM_SAP_FLUSHED, NULL);
 	write_unlock_bh(&xfrm_policy_lock);
 }
 EXPORT_SYMBOL(xfrm_policy_flush);
@@ -558,7 +565,7 @@
 	if (pol) {
 		if (dir < XFRM_POLICY_MAX)
 			atomic_inc(&flow_cache_genid);
-		xfrm_policy_kill(pol);
+		xfrm_policy_kill(pol, dir, 1);
 	}
 }
 
@@ -579,7 +586,7 @@
 	write_unlock_bh(&xfrm_policy_lock);
 
 	if (old_pol) {
-		xfrm_policy_kill(old_pol);
+		xfrm_policy_kill(old_pol, dir, 1);
 	}
 	return 0;
 }
--- a/net/xfrm/xfrm_user.c	2005-03-25 22:28:22.000000000 -0500
+++ b/net/xfrm/xfrm_user.c	2005-03-31 19:26:24.000000000 -0500
@@ -683,6 +683,10 @@
 	if (!xp)
 		return err;
 
+	/* shouldnt excl be based on nlh flags?? 
+	 * Aha! this is anti-netlink really i.e  more pfkey derived
+	 * in netlink excl is a flag and you wouldnt need
+	 * a type XFRM_MSG_UPDPOLICY - JHS */
 	excl = nlh->nlmsg_type == XFRM_MSG_NEWPOLICY;
 	err = xfrm_policy_insert(p->dir, xp, excl);
 	if (err) {
@@ -1053,10 +1057,10 @@
 	return -1;
 }
 
-static int xfrm_send_state_notify(struct xfrm_state *x, int hard)
+static int xfrm_exp_state_notify(struct xfrm_state *x, u32 hard)
 {
 	struct sk_buff *skb;
-
+	/* fix to do alloc using NLM macros */
 	skb = alloc_skb(sizeof(struct xfrm_user_expire) + 16, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
@@ -1069,6 +1073,98 @@
 	return netlink_broadcast(xfrm_nl, skb, 0, XFRMGRP_EXPIRE, GFP_ATOMIC);
 }
 
+static int xfrm_notify_sa_flush(struct km_cb *c)
+{
+	struct xfrm_usersa_flush *p;
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	unsigned char *b;
+	u32 ppid = 0;
+	int len = NLMSG_LENGTH(sizeof(struct xfrm_usersa_flush));
+
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+	b = skb->tail;
+
+	nlh = NLMSG_PUT(skb, ppid, jiffies,
+			XFRM_MSG_FLUSHSA, sizeof(*p));
+	nlh->nlmsg_flags = 0;
+
+	p = NLMSG_DATA(nlh);
+	if (!c) {
+		printk("xfrm_notify_sa_flush NULL km cb\n");
+		p->proto = 0;
+	} else {
+		p->proto = c->data;
+	}
+
+	nlh->nlmsg_len = skb->tail - b;
+
+	return netlink_broadcast(xfrm_nl, skb, ppid, XFRMGRP_SA, GFP_ATOMIC);
+
+nlmsg_failure:
+	kfree_skb(skb);
+	return -1;
+}
+
+static int xfrm_notify_sa( struct xfrm_state *x, int event, struct km_cb *c)
+{
+	struct xfrm_usersa_info *p;
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	u32 nlt;
+	unsigned char *b;
+	u32 ppid = 0;
+	int len = NLMSG_LENGTH(sizeof(struct xfrm_usersa_info));
+
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+	b = skb->tail;
+
+	if (event == XFRM_SAP_ADDED)
+		nlt = XFRM_MSG_NEWSA;
+	else if (event == XFRM_SAP_UPDATED)
+		nlt = XFRM_MSG_UPDSA;
+	else if (event == XFRM_SAP_DELETED)
+		nlt = XFRM_MSG_DELSA;
+	else
+		goto nlmsg_failure;
+
+	nlh = NLMSG_PUT(skb, ppid, jiffies,
+			nlt, sizeof(*p));
+	nlh->nlmsg_flags = 0;
+
+	p = NLMSG_DATA(nlh);
+	copy_to_user_state(x, p);
+
+	nlh->nlmsg_len = skb->tail - b;
+
+	return netlink_broadcast(xfrm_nl, skb, ppid, XFRMGRP_SA, GFP_ATOMIC);
+
+nlmsg_failure:
+	kfree_skb(skb);
+	return -1;
+}
+
+static int xfrm_send_state_notify(struct xfrm_state *x, int event, struct km_cb *c)
+{
+
+	if ((event == XFRM_SAP_ADDED) || 
+		(event == XFRM_SAP_UPDATED) ||
+		(event == XFRM_SAP_DELETED))
+		return xfrm_notify_sa(x, event, c);
+
+	if (event == XFRM_SAP_FLUSHED) 
+		xfrm_notify_sa_flush(c);
+
+	if (event != XFRM_SAP_EXPIRED)
+		return 0;
+
+	return xfrm_exp_state_notify(x, c->data);
+}
+
 static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 			 struct xfrm_tmpl *xt, struct xfrm_policy *xp,
 			 int dir)
@@ -1202,7 +1298,8 @@
 	return -1;
 }
 
-static int xfrm_send_policy_notify(struct xfrm_policy *xp, int dir, int hard)
+
+static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, int hard)
 {
 	struct sk_buff *skb;
 	size_t len;
@@ -1221,6 +1318,91 @@
 	return netlink_broadcast(xfrm_nl, skb, 0, XFRMGRP_EXPIRE, GFP_ATOMIC);
 }
 
+static int xfrm_notify_policy( struct xfrm_policy *xp, int dir, int event, struct km_cb *c)
+{
+	struct xfrm_userpolicy_info *p;
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	u32 nlt = 0 ;
+	unsigned char *b;
+	int len = NLMSG_LENGTH(sizeof(struct xfrm_userpolicy_info));
+	u32 ppid = 0;
+
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+	b = skb->tail;
+
+	if (event == XFRM_SAP_ADDED)
+		nlt = XFRM_MSG_NEWPOLICY;
+	else if (event == XFRM_SAP_UPDATED)
+		nlt = XFRM_MSG_UPDPOLICY;
+	else if (event == XFRM_SAP_DELETED)
+		nlt = XFRM_MSG_DELPOLICY;
+	else
+		goto nlmsg_failure;
+
+	nlh = NLMSG_PUT(skb, ppid, jiffies, nlt, sizeof(*p));
+
+	p = NLMSG_DATA(nlh);
+
+	nlh->nlmsg_flags = 0;
+
+	copy_to_user_policy(xp, p, dir);
+
+	nlh->nlmsg_len = skb->tail - b;
+
+	return netlink_broadcast(xfrm_nl, skb, ppid, XFRMGRP_POLICY, GFP_ATOMIC);
+
+nlmsg_failure:
+	kfree_skb(skb);
+	return -1;
+}
+
+static int xfrm_notify_policy_flush(struct km_cb *c)
+{
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	unsigned char *b;
+	u32 ppid = 0;
+	int len = NLMSG_LENGTH(0);
+
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+	b = skb->tail;
+
+
+	nlh = NLMSG_PUT(skb, 0, jiffies, XFRM_MSG_FLUSHPOLICY, 0);
+
+	nlh->nlmsg_len = skb->tail - b;
+
+	return netlink_broadcast(xfrm_nl, skb, ppid, XFRMGRP_POLICY, GFP_ATOMIC);
+
+nlmsg_failure:
+	kfree_skb(skb);
+	return -1;
+}
+
+static int xfrm_send_policy_notify(struct xfrm_policy *xp, int dir, int event, struct km_cb *c)
+{
+
+	if ((event == XFRM_SAP_ADDED) || 
+		(event == XFRM_SAP_UPDATED) ||
+		(event == XFRM_SAP_DELETED))
+		return xfrm_notify_policy(xp, dir, event, c);
+
+	if (event == XFRM_SAP_FLUSHED) 
+		return xfrm_notify_policy_flush(c);
+
+	if (event != XFRM_SAP_EXPIRED) {
+		printk("Netlink Unknown Policy event %d\n",event);
+		return 0;
+	}
+
+	return xfrm_exp_policy_notify(xp, dir, c->data);
+}
+
 static struct xfrm_mgr netlink_mgr = {
 	.id		= "netlink",
 	.notify		= xfrm_send_state_notify,
--- a/net/key/af_key.c	2005-03-25 22:28:39.000000000 -0500
+++ b/net/key/af_key.c	2005-03-31 19:26:24.000000000 -0500
@@ -1240,7 +1240,6 @@
 	return 0;
 }
 
-
 static int pfkey_add(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
 {
 	struct sk_buff *out_skb;
@@ -2317,11 +2316,30 @@
 	}
 }
 
-static int pfkey_send_notify(struct xfrm_state *x, int hard)
+static int pfkey_send_notify(struct xfrm_state *x, int event, struct km_cb *c)
 {
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
-	int hsc = (hard ? 2 : 1);
+	int hard;
+	int hsc;
+
+	/* 
+	 * migrate pf_key later - for now only support is for
+	 * expire events 
+	*/
+	if (event != XFRM_SAP_EXPIRED)
+		return 0; 
+
+	if (!c) {
+		printk("pfkey_send_notify: bad CB data!\n");
+		return 0;
+	}
+
+	hard = c->data;
+	if (hard)
+		hsc = 2;
+	else
+		hsc = 1;
 
 	out_skb = pfkey_xfrm_state2msg(x, 0, hsc);
 	if (IS_ERR(out_skb))

--=-RQGyAfq73Wh6tlnAcR0C--
