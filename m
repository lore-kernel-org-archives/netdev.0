From: jamal <hadi@cyberus.ca>
Subject: Re: take 2  WAS(Re: PATCH: IPSEC xfrm events
Date: 03 Apr 2005 10:31:58 -0400
Message-ID: <1112538718.1096.394.camel@jzny.localdomain>
References: <1112319441.1089.83.camel@jzny.localdomain>
	 <20050401042106.GA27762@gondor.apana.org.au>
	 <1112353398.1096.116.camel@jzny.localdomain>
	 <20050401114258.GA2932@gondor.apana.org.au>
	 <1112358278.1096.160.camel@jzny.localdomain>
	 <20050401123554.GA3468@gondor.apana.org.au>
	 <1112403845.1088.14.camel@jzny.localdomain>
	 <20050402012813.GA24575@gondor.apana.org.au>
	 <1112406164.1088.54.camel@jzny.localdomain>
	 <20050402014619.GB24861@gondor.apana.org.au>
	 <1112469601.1088.173.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-CbZvGNdJ/zGTATpkMExl"
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1112469601.1088.173.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-CbZvGNdJ/zGTATpkMExl
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Small change after some testing.
Herbert havent heard back from you - this looks very palatable in my
opinion with comments below still in effect.

cheers,
jamal

On Sat, 2005-04-02 at 14:20, jamal wrote:

> Ok, heres a general patch first cut i think i got all that was discussed
> in there. ive done some basic 5 minutes tests on.
> Once we have agreement i will pass it on to Masahide-san to do more
> thorough testing.
> Look at the XXX comments in the patch.
> 
> A couple of interesting things:
> 
> 1) Weve discussed this before Herbert and i think you misspoke that
> pfkey delivers to all listerners.
> 
> pfkey Add/del/upd now really do tell all processes about what happened.
> Before pfkey would skip the originating process. So far this doesnt seem
> to be an issue in the basic testing.
> 
> 2) I ended adding a policy_notify to the pfkey manager to make the code
> generic. Interesting thing is i dont think pfkey knows what to do with 
> policy expiration or i am misreading the code.
> I dont see any message type for policy expiration as i do for sa
> expiration. Ive put some hooks and a little noise. I could remove the
> printks - for now they are just place holders.
> 
> cheers,
> jamal

--=-CbZvGNdJ/zGTATpkMExl
Content-Disposition: attachment; filename=ipsec-event-take2-1
Content-Type: text/plain; name=ipsec-event-take2-1; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/include/net/xfrm.h	2005-03-25 22:28:26.000000000 -0500
+++ b/include/net/xfrm.h	2005-04-02 11:59:17.000000000 -0500
@@ -157,6 +157,28 @@
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
+struct km_event
+{
+	u32	data; 
+	u32	seq; 
+	u32	pid; 
+	u32	event; 
+};
+
+
 struct xfrm_type;
 struct xfrm_dst;
 struct xfrm_policy_afinfo {
@@ -178,6 +200,9 @@
 
 extern int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo);
 extern int xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo);
+extern void km_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c);
+extern void km_state_notify(struct xfrm_state *x, struct km_event *c);
+
 
 #define XFRM_ACQ_EXPIRES	30
 
@@ -283,17 +308,17 @@
 	struct xfrm_tmpl       	xfrm_vec[XFRM_MAX_DEPTH];
 };
 
-#define XFRM_KM_TIMEOUT		30
 
+#define XFRM_KM_TIMEOUT		30
 struct xfrm_mgr
 {
 	struct list_head	list;
 	char			*id;
-	int			(*notify)(struct xfrm_state *x, int event);
+	int			(*notify)(struct xfrm_state *x, struct km_event *c);
 	int			(*acquire)(struct xfrm_state *x, struct xfrm_tmpl *, struct xfrm_policy *xp, int dir);
 	struct xfrm_policy	*(*compile_policy)(u16 family, int opt, u8 *data, int len, int *dir);
 	int			(*new_mapping)(struct xfrm_state *x, xfrm_address_t *ipaddr, u16 sport);
-	int			(*notify_policy)(struct xfrm_policy *x, int dir, int event);
+	int			(*notify_policy)(struct xfrm_policy *x, int dir, struct km_event *c);
 };
 
 extern int xfrm_register_km(struct xfrm_mgr *km);
@@ -802,7 +827,7 @@
 extern int xfrm_state_update(struct xfrm_state *x);
 extern struct xfrm_state *xfrm_state_lookup(xfrm_address_t *daddr, u32 spi, u8 proto, unsigned short family);
 extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
-extern void xfrm_state_delete(struct xfrm_state *x);
+extern int xfrm_state_delete(struct xfrm_state *x);
 extern void xfrm_state_flush(u8 proto);
 extern int xfrm_replay_check(struct xfrm_state *x, u32 seq);
 extern void xfrm_replay_advance(struct xfrm_state *x, u32 seq);
--- a/include/linux/xfrm.h	2005-03-25 22:28:39.000000000 -0500
+++ b/include/linux/xfrm.h	2005-04-02 09:53:03.000000000 -0500
@@ -254,5 +254,7 @@
 
 #define XFRMGRP_ACQUIRE		1
 #define XFRMGRP_EXPIRE		2
+#define XFRMGRP_SA		4
+#define XFRMGRP_POLICY		8
 
 #endif /* _LINUX_XFRM_H */
--- a/net/xfrm/xfrm_state.c	2005-03-25 22:28:25.000000000 -0500
+++ b/net/xfrm/xfrm_state.c	2005-04-02 12:15:37.000000000 -0500
@@ -48,7 +48,7 @@
 static struct list_head xfrm_state_gc_list = LIST_HEAD_INIT(xfrm_state_gc_list);
 static DEFINE_SPINLOCK(xfrm_state_gc_lock);
 
-static void __xfrm_state_delete(struct xfrm_state *x);
+static int __xfrm_state_delete(struct xfrm_state *x);
 
 static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned short family);
 static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
@@ -208,8 +208,10 @@
 }
 EXPORT_SYMBOL(__xfrm_state_destroy);
 
-static void __xfrm_state_delete(struct xfrm_state *x)
+static int __xfrm_state_delete(struct xfrm_state *x)
 {
+	int err = -ESRCH;
+
 	if (x->km.state != XFRM_STATE_DEAD) {
 		x->km.state = XFRM_STATE_DEAD;
 		spin_lock(&xfrm_state_lock);
@@ -236,14 +238,47 @@
 		 * is what we are dropping here.
 		 */
 		atomic_dec(&x->refcnt);
+		err = 0;
 	}
+
+	return err;
 }
 
-void xfrm_state_delete(struct xfrm_state *x)
+static DEFINE_RWLOCK(xfrm_km_lock);
+static struct list_head xfrm_km_list = LIST_HEAD_INIT(xfrm_km_list);
+
+void km_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
 {
+	struct xfrm_mgr *km;
+
+	read_lock(&xfrm_km_lock);
+	list_for_each_entry(km, &xfrm_km_list, list)
+		if (km->notify_policy)
+			km->notify_policy(xp, dir, c);
+	read_unlock(&xfrm_km_lock);
+}
+
+void km_state_notify(struct xfrm_state *x, struct km_event *c)
+{
+	struct xfrm_mgr *km;
+	read_lock(&xfrm_km_lock);
+	list_for_each_entry(km, &xfrm_km_list, list)
+		km->notify(x, c);
+	read_unlock(&xfrm_km_lock);
+}
+
+EXPORT_SYMBOL(km_policy_notify);
+EXPORT_SYMBOL(km_state_notify);
+
+int xfrm_state_delete(struct xfrm_state *x)
+{
+	int err;
+
 	spin_lock_bh(&x->lock);
-	__xfrm_state_delete(x);
+	err = __xfrm_state_delete(x);
 	spin_unlock_bh(&x->lock);
+
+	return err;
 }
 EXPORT_SYMBOL(xfrm_state_delete);
 
@@ -402,6 +437,7 @@
 
 static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq);
 
+
 int xfrm_state_add(struct xfrm_state *x)
 {
 	struct xfrm_state_afinfo *afinfo;
@@ -764,37 +800,45 @@
 }
 EXPORT_SYMBOL(xfrm_replay_advance);
 
-static struct list_head xfrm_km_list = LIST_HEAD_INIT(xfrm_km_list);
-static DEFINE_RWLOCK(xfrm_km_lock);
 
 static void km_state_expired(struct xfrm_state *x, int hard)
 {
-	struct xfrm_mgr *km;
+	struct km_event c;
 
 	if (hard)
 		x->km.state = XFRM_STATE_EXPIRED;
 	else
 		x->km.dying = 1;
 
-	read_lock(&xfrm_km_lock);
-	list_for_each_entry(km, &xfrm_km_list, list)
-		km->notify(x, hard);
-	read_unlock(&xfrm_km_lock);
+	/* XXX: Do we wanna do this right at the top??
+	 * if the state is dead we dont want to announce 
+	 * the expire - a delete may already have announced
+	 * it 
+	*/
+	if (x->km.state == XFRM_STATE_DEAD)
+		return;
+	c.data = hard;
+	c.event = XFRM_SAP_EXPIRED;
+	km_state_notify(x, &c);
 
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
@@ -819,13 +863,20 @@
 
 void km_policy_expired(struct xfrm_policy *pol, int dir, int hard)
 {
-	struct xfrm_mgr *km;
+	struct km_event c;
 
-	read_lock(&xfrm_km_lock);
-	list_for_each_entry(km, &xfrm_km_list, list)
-		if (km->notify_policy)
-			km->notify_policy(pol, dir, hard);
-	read_unlock(&xfrm_km_lock);
+	/* XXX: Do we still wanna wakeup km_waitq?
+	 * if the policy is dead we dont want to announce 
+	 * the expire - a delete may already have announced
+	 * it 
+	*/
+	if (pol->dead)
+		return;
+
+	c.data = hard;
+	c.data = hard;
+	c.event = XFRM_SAP_EXPIRED;
+	km_policy_notify(pol, dir, &c);
 
 	if (hard)
 		wake_up(&km_waitq);
--- a/net/xfrm/xfrm_policy.c	2005-03-25 22:28:21.000000000 -0500
+++ b/net/xfrm/xfrm_policy.c	2005-04-02 12:16:30.000000000 -0500
@@ -298,7 +298,7 @@
  * entry dead. The rule must be unlinked from lists to the moment.
  */
 
-static void xfrm_policy_kill(struct xfrm_policy *policy)
+static void xfrm_policy_kill(struct xfrm_policy *policy, int dir)
 {
 	write_lock_bh(&policy->lock);
 	if (policy->dead)
@@ -378,7 +378,7 @@
 	write_unlock_bh(&xfrm_policy_lock);
 
 	if (delpol) {
-		xfrm_policy_kill(delpol);
+		xfrm_policy_kill(delpol, dir);
 	}
 	return 0;
 }
@@ -402,7 +402,7 @@
 
 	if (pol && delete) {
 		atomic_inc(&flow_cache_genid);
-		xfrm_policy_kill(pol);
+		xfrm_policy_kill(pol, dir);
 	}
 	return pol;
 }
@@ -425,7 +425,7 @@
 
 	if (pol && delete) {
 		atomic_inc(&flow_cache_genid);
-		xfrm_policy_kill(pol);
+		xfrm_policy_kill(pol, dir);
 	}
 	return pol;
 }
@@ -442,7 +442,7 @@
 			xfrm_policy_list[dir] = xp->next;
 			write_unlock_bh(&xfrm_policy_lock);
 
-			xfrm_policy_kill(xp);
+			xfrm_policy_kill(xp, dir);
 
 			write_lock_bh(&xfrm_policy_lock);
 		}
@@ -558,7 +558,7 @@
 	if (pol) {
 		if (dir < XFRM_POLICY_MAX)
 			atomic_inc(&flow_cache_genid);
-		xfrm_policy_kill(pol);
+		xfrm_policy_kill(pol, dir);
 	}
 }
 
@@ -579,7 +579,7 @@
 	write_unlock_bh(&xfrm_policy_lock);
 
 	if (old_pol) {
-		xfrm_policy_kill(old_pol);
+		xfrm_policy_kill(old_pol, dir);
 	}
 	return 0;
 }
--- a/net/xfrm/xfrm_user.c	2005-03-25 22:28:22.000000000 -0500
+++ b/net/xfrm/xfrm_user.c	2005-04-02 12:21:32.000000000 -0500
@@ -268,6 +268,7 @@
 	struct xfrm_usersa_info *p = NLMSG_DATA(nlh);
 	struct xfrm_state *x;
 	int err;
+	struct km_event c;
 
 	err = verify_newsa_info(p, (struct rtattr **) xfrma);
 	if (err)
@@ -285,14 +286,26 @@
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
 		xfrm_state_put(x);
+		return err;
 	}
 
+	c.seq = nlh->nlmsg_seq;
+	c.pid = nlh->nlmsg_pid;
+	if (nlh->nlmsg_type == XFRM_MSG_NEWSA)
+		c.event = XFRM_SAP_ADDED;
+	else
+		c.event = XFRM_SAP_UPDATED;
+
+	km_state_notify(x, &c);
+
 	return err;
 }
 
 static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
 {
 	struct xfrm_state *x;
+	int err;
+	struct km_event c;
 	struct xfrm_usersa_id *p = NLMSG_DATA(nlh);
 
 	x = xfrm_state_lookup(&p->daddr, p->spi, p->proto, p->family);
@@ -304,10 +317,20 @@
 		return -EPERM;
 	}
 
-	xfrm_state_delete(x);
+	err = xfrm_state_delete(x);
+	if (err < 0) {
+		x->km.state = XFRM_STATE_DEAD;
+		xfrm_state_put(x);
+		return err;
+	}
+
+	c.seq = nlh->nlmsg_seq;
+	c.pid = nlh->nlmsg_pid;
+	c.event = XFRM_SAP_DELETED;
+	km_state_notify(x, &c);
 	xfrm_state_put(x);
 
-	return 0;
+	return err;
 }
 
 static void copy_to_user_state(struct xfrm_state *x, struct xfrm_usersa_info *p)
@@ -672,6 +695,7 @@
 {
 	struct xfrm_userpolicy_info *p = NLMSG_DATA(nlh);
 	struct xfrm_policy *xp;
+	struct km_event c;
 	int err;
 	int excl;
 
@@ -683,6 +707,10 @@
 	if (!xp)
 		return err;
 
+	/* shouldnt excl be based on nlh flags?? 
+	 * Aha! this is anti-netlink really i.e  more pfkey derived
+	 * in netlink excl is a flag and you wouldnt need
+	 * a type XFRM_MSG_UPDPOLICY - JHS */
 	excl = nlh->nlmsg_type == XFRM_MSG_NEWPOLICY;
 	err = xfrm_policy_insert(p->dir, xp, excl);
 	if (err) {
@@ -690,6 +718,16 @@
 		return err;
 	}
 
+
+	if (!excl)
+		c.event = XFRM_SAP_UPDATED;
+	else
+		c.event = XFRM_SAP_ADDED;
+
+	c.seq = nlh->nlmsg_seq;
+	c.pid = nlh->nlmsg_pid;
+	km_policy_notify(xp, p->dir, &c);
+
 	xfrm_pol_put(xp);
 
 	return 0;
@@ -807,8 +845,10 @@
 	struct xfrm_policy *xp;
 	struct xfrm_userpolicy_id *p;
 	int err;
+	struct km_event c;
 	int delete;
 
+
 	p = NLMSG_DATA(nlh);
 	delete = nlh->nlmsg_type == XFRM_MSG_DELPOLICY;
 
@@ -834,6 +874,11 @@
 					      NETLINK_CB(skb).pid,
 					      MSG_DONTWAIT);
 		}
+	} else {
+		c.event = XFRM_SAP_DELETED;
+		c.seq = nlh->nlmsg_seq;
+		c.pid = nlh->nlmsg_pid;
+		km_policy_notify(xp, p->dir, &c);
 	}
 
 	xfrm_pol_put(xp);
@@ -843,15 +888,28 @@
 
 static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
 {
+	struct km_event c;
 	struct xfrm_usersa_flush *p = NLMSG_DATA(nlh);
 
 	xfrm_state_flush(p->proto);
+	c.data = p->proto;
+	c.event = XFRM_SAP_FLUSHED;
+	c.seq = nlh->nlmsg_seq;
+	c.pid = nlh->nlmsg_pid;
+	km_state_notify(NULL, &c);
+
 	return 0;
 }
 
 static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
 {
+	struct km_event c;
+
 	xfrm_policy_flush();
+	c.event = XFRM_SAP_FLUSHED;
+	c.seq = nlh->nlmsg_seq;
+	c.pid = nlh->nlmsg_pid;
+	km_policy_notify(NULL, 0, &c);
 	return 0;
 }
 
@@ -1053,10 +1111,11 @@
 	return -1;
 }
 
-static int xfrm_send_state_notify(struct xfrm_state *x, int hard)
+static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
 {
 	struct sk_buff *skb;
-
+	int hard = c ->data;
+	/* fix to do alloc using NLM macros */
 	skb = alloc_skb(sizeof(struct xfrm_user_expire) + 16, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
@@ -1069,6 +1128,94 @@
 	return netlink_broadcast(xfrm_nl, skb, 0, XFRMGRP_EXPIRE, GFP_ATOMIC);
 }
 
+static int xfrm_notify_sa_flush(struct km_event *c)
+{
+	struct xfrm_usersa_flush *p;
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	unsigned char *b;
+	int len = NLMSG_LENGTH(sizeof(struct xfrm_usersa_flush));
+
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+	b = skb->tail;
+
+	nlh = NLMSG_PUT(skb, c->pid,  c->seq,
+			XFRM_MSG_FLUSHSA, sizeof(*p));
+	nlh->nlmsg_flags = 0;
+
+	p = NLMSG_DATA(nlh);
+	p->proto = c->data;
+
+	nlh->nlmsg_len = skb->tail - b;
+
+	return netlink_broadcast(xfrm_nl, skb, 0, XFRMGRP_SA, GFP_ATOMIC);
+
+nlmsg_failure:
+	kfree_skb(skb);
+	return -1;
+}
+
+static int xfrm_notify_sa( struct xfrm_state *x, struct km_event *c)
+{
+	struct xfrm_usersa_info *p;
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	u32 nlt;
+	unsigned char *b;
+	int len = NLMSG_LENGTH(sizeof(struct xfrm_usersa_info));
+
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+	b = skb->tail;
+
+	if (c->event == XFRM_SAP_ADDED)
+		nlt = XFRM_MSG_NEWSA;
+	else if (c->event == XFRM_SAP_UPDATED)
+		nlt = XFRM_MSG_UPDSA;
+	else if (c->event == XFRM_SAP_DELETED)
+		nlt = XFRM_MSG_DELSA;
+	else
+		goto nlmsg_failure;
+
+	nlh = NLMSG_PUT(skb, c->pid, c->seq, nlt, sizeof(*p));
+	nlh->nlmsg_flags = 0;
+
+	p = NLMSG_DATA(nlh);
+	copy_to_user_state(x, p);
+
+	nlh->nlmsg_len = skb->tail - b;
+
+	return netlink_broadcast(xfrm_nl, skb, 0, XFRMGRP_SA, GFP_ATOMIC);
+
+nlmsg_failure:
+	kfree_skb(skb);
+	return -1;
+}
+
+static int xfrm_send_state_notify(struct xfrm_state *x, struct km_event *c)
+{
+
+	switch (c->event) {
+	case XFRM_SAP_EXPIRED:
+		return xfrm_exp_state_notify(x, c);
+	case XFRM_SAP_DELETED:
+	case XFRM_SAP_UPDATED:
+	case XFRM_SAP_ADDED:
+		return xfrm_notify_sa(x, c);
+	case XFRM_SAP_FLUSHED:
+		return xfrm_notify_sa_flush(c);
+	default:
+		 printk("pfkey: Unknown SA event %d\n",c->event);
+		 break;
+	}
+
+	return 0;
+
+}
+
 static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 			 struct xfrm_tmpl *xt, struct xfrm_policy *xp,
 			 int dir)
@@ -1202,7 +1349,8 @@
 	return -1;
 }
 
-static int xfrm_send_policy_notify(struct xfrm_policy *xp, int dir, int hard)
+
+static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
 {
 	struct sk_buff *skb;
 	size_t len;
@@ -1213,7 +1361,7 @@
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_polexpire(skb, xp, dir, hard) < 0)
+	if (build_polexpire(skb, xp, dir, c->data) < 0)
 		BUG();
 
 	NETLINK_CB(skb).dst_groups = XFRMGRP_EXPIRE;
@@ -1221,6 +1369,90 @@
 	return netlink_broadcast(xfrm_nl, skb, 0, XFRMGRP_EXPIRE, GFP_ATOMIC);
 }
 
+static int xfrm_notify_policy( struct xfrm_policy *xp, int dir, struct km_event *c)
+{
+	struct xfrm_userpolicy_info *p;
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	u32 nlt = 0 ;
+	unsigned char *b;
+	int len = NLMSG_LENGTH(sizeof(struct xfrm_userpolicy_info));
+
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+	b = skb->tail;
+
+	if (c->event == XFRM_SAP_ADDED)
+		nlt = XFRM_MSG_NEWPOLICY;
+	else if (c->event == XFRM_SAP_UPDATED)
+		nlt = XFRM_MSG_UPDPOLICY;
+	else if (c->event == XFRM_SAP_DELETED)
+		nlt = XFRM_MSG_DELPOLICY;
+	else
+		goto nlmsg_failure;
+
+	nlh = NLMSG_PUT(skb, c->pid, c->seq, nlt, sizeof(*p));
+
+	p = NLMSG_DATA(nlh);
+
+	nlh->nlmsg_flags = 0;
+
+	copy_to_user_policy(xp, p, dir);
+
+	nlh->nlmsg_len = skb->tail - b;
+
+	return netlink_broadcast(xfrm_nl, skb, 0, XFRMGRP_POLICY, GFP_ATOMIC);
+
+nlmsg_failure:
+	kfree_skb(skb);
+	return -1;
+}
+
+static int xfrm_notify_policy_flush(struct km_event *c)
+{
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	unsigned char *b;
+	int len = NLMSG_LENGTH(0);
+
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+	b = skb->tail;
+
+
+	nlh = NLMSG_PUT(skb, c->pid, c->seq, XFRM_MSG_FLUSHPOLICY, 0);
+
+	nlh->nlmsg_len = skb->tail - b;
+
+	return netlink_broadcast(xfrm_nl, skb, 0, XFRMGRP_POLICY, GFP_ATOMIC);
+
+nlmsg_failure:
+	kfree_skb(skb);
+	return -1;
+}
+
+static int xfrm_send_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
+{
+
+	switch (c->event) {
+	case XFRM_SAP_ADDED:
+	case XFRM_SAP_UPDATED:
+	case XFRM_SAP_DELETED:
+		return xfrm_notify_policy(xp, dir, c);
+	case XFRM_SAP_FLUSHED:
+		return xfrm_notify_policy_flush(c);
+	case XFRM_SAP_EXPIRED:
+		return xfrm_exp_policy_notify(xp, dir, c);
+	default:
+		printk("Netlink Unknown Policy event %d\n",c->event);
+	}
+
+	return 0;
+
+}
+
 static struct xfrm_mgr netlink_mgr = {
 	.id		= "netlink",
 	.notify		= xfrm_send_state_notify,
--- a/net/key/af_key.c	2005-03-25 22:28:39.000000000 -0500
+++ b/net/key/af_key.c	2005-04-02 18:05:24.000000000 -0500
@@ -1240,13 +1240,85 @@
 	return 0;
 }
 
+static inline int event2poltype (int event)
+{
+	switch (event) {
+	case XFRM_SAP_DELETED:
+		return SADB_X_SPDDELETE;
+	case XFRM_SAP_ADDED:
+		return SADB_X_SPDADD;
+	case XFRM_SAP_UPDATED:
+		return SADB_X_SPDUPDATE;
+	case XFRM_SAP_EXPIRED:
+	//	return SADB_X_SPDEXPIRE;
+	default:
+		printk("pfkey: Unknown policy event %d\n",event);
+		break;
+	}
+
+	return 0;
+}
+
+static inline int event2keytype (int event)
+{
+	switch (event) {
+	case XFRM_SAP_DELETED:
+		return SADB_DELETE;
+	case XFRM_SAP_ADDED:
+		return SADB_ADD;
+	case XFRM_SAP_UPDATED:
+		return SADB_UPDATE;
+	case XFRM_SAP_EXPIRED:
+		return SADB_EXPIRE;
+	default:
+		printk("pfkey: Unknown SA event %d\n",event);
+		break;
+	}
+
+	return 0;
+}
+
+/* ADD/UPD/DEL */
+static int key_notify_sa(struct xfrm_state *x, struct km_event *c)
+{
+	struct sk_buff *skb;
+	struct sadb_msg *hdr;
+	int hsc = 3;
+
+	if (c->event == XFRM_SAP_DELETED)
+		hsc = 0;
+
+	if (c->event == XFRM_SAP_EXPIRED) {
+		if (c->data)
+			hsc = 2;
+		else
+			hsc = 1;
+	}
+
+	skb = pfkey_xfrm_state2msg(x, 0, hsc);
+
+	if (IS_ERR(skb))
+		return  PTR_ERR(skb);
+
+	hdr = (struct sadb_msg *) skb->data;
+	hdr->sadb_msg_version = PF_KEY_V2;
+	hdr->sadb_msg_type = event2keytype(c->event);
+	hdr->sadb_msg_satype = pfkey_proto2satype(x->id.proto);
+	hdr->sadb_msg_errno = 0;
+	hdr->sadb_msg_reserved = 0;
+	hdr->sadb_msg_seq = c->seq;
+	hdr->sadb_msg_pid = c->pid;
+
+	pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_ALL, NULL);
+
+	return 0;
+}
 
 static int pfkey_add(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
 {
-	struct sk_buff *out_skb;
-	struct sadb_msg *out_hdr;
 	struct xfrm_state *x;
 	int err;
+	struct km_event c;
 
 	xfrm_probe_algs();
 	
@@ -1256,7 +1328,7 @@
 
 	if (hdr->sadb_msg_type == SADB_ADD)
 		err = xfrm_state_add(x);
-	else
+	else 
 		err = xfrm_state_update(x);
 
 	if (err < 0) {
@@ -1265,27 +1337,22 @@
 		return err;
 	}
 
-	out_skb = pfkey_xfrm_state2msg(x, 0, 3);
-	if (IS_ERR(out_skb))
-		return  PTR_ERR(out_skb); /* XXX Should we return 0 here ? */
-
-	out_hdr = (struct sadb_msg *) out_skb->data;
-	out_hdr->sadb_msg_version = hdr->sadb_msg_version;
-	out_hdr->sadb_msg_type = hdr->sadb_msg_type;
-	out_hdr->sadb_msg_satype = pfkey_proto2satype(x->id.proto);
-	out_hdr->sadb_msg_errno = 0;
-	out_hdr->sadb_msg_reserved = 0;
-	out_hdr->sadb_msg_seq = hdr->sadb_msg_seq;
-	out_hdr->sadb_msg_pid = hdr->sadb_msg_pid;
-
-	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ALL, sk);
+	if (hdr->sadb_msg_type == SADB_ADD)
+		c.event = XFRM_SAP_ADDED;
+	else
+		c.event = XFRM_SAP_UPDATED;
+	c.seq = hdr->sadb_msg_seq;
+	c.pid = hdr->sadb_msg_pid;
+	km_state_notify(x, &c);
 
-	return 0;
+	return err;
 }
 
 static int pfkey_delete(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
 {
 	struct xfrm_state *x;
+	struct km_event c;
+	int err;
 
 	if (!ext_hdrs[SADB_EXT_SA-1] ||
 	    !present_and_same_family(ext_hdrs[SADB_EXT_ADDRESS_SRC-1],
@@ -1301,13 +1368,20 @@
 		return -EPERM;
 	}
 	
-	xfrm_state_delete(x);
-	xfrm_state_put(x);
+	err = xfrm_state_delete(x);
+	if (err < 0) {
+		x->km.state = XFRM_STATE_DEAD;
+		xfrm_state_put(x);
+		return err;
+	}
 
-	pfkey_broadcast(skb_clone(skb, GFP_KERNEL), GFP_KERNEL, 
-			BROADCAST_ALL, sk);
+	c.seq = hdr->sadb_msg_seq;
+	c.pid = hdr->sadb_msg_pid;
+	c.event = XFRM_SAP_DELETED;
+	km_state_notify(x, &c);
+	xfrm_state_put(x);
 
-	return 0;
+	return err;
 }
 
 static int pfkey_get(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
@@ -1445,28 +1519,42 @@
 	return 0;
 }
 
+static int key_notify_sa_flush(struct km_event *c)
+{
+	struct sk_buff *skb;
+	struct sadb_msg *hdr;
+
+	skb = alloc_skb(sizeof(struct sadb_msg) + 16, GFP_ATOMIC);
+	if (!skb)
+		return -ENOBUFS;
+	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
+	// XXX:do we have to pass proto as well?
+	hdr->sadb_msg_seq = c->seq;
+	hdr->sadb_msg_pid = c->pid;
+	hdr->sadb_msg_version = PF_KEY_V2;
+	hdr->sadb_msg_errno = (uint8_t) 0;
+	hdr->sadb_msg_len = (sizeof(struct sadb_msg) / sizeof(uint64_t));
+
+	pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_ALL, NULL);
+
+	return 0;
+}
+
 static int pfkey_flush(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
 {
 	unsigned proto;
-	struct sk_buff *skb_out;
-	struct sadb_msg *hdr_out;
+	struct km_event c;
 
 	proto = pfkey_satype2proto(hdr->sadb_msg_satype);
 	if (proto == 0)
 		return -EINVAL;
 
-	skb_out = alloc_skb(sizeof(struct sadb_msg) + 16, GFP_KERNEL);
-	if (!skb_out)
-		return -ENOBUFS;
-
 	xfrm_state_flush(proto);
-
-	hdr_out = (struct sadb_msg *) skb_put(skb_out, sizeof(struct sadb_msg));
-	pfkey_hdr_dup(hdr_out, hdr);
-	hdr_out->sadb_msg_errno = (uint8_t) 0;
-	hdr_out->sadb_msg_len = (sizeof(struct sadb_msg) / sizeof(uint64_t));
-
-	pfkey_broadcast(skb_out, GFP_KERNEL, BROADCAST_ALL, NULL);
+	c.data = proto;
+	c.seq = hdr->sadb_msg_seq;
+	c.pid = hdr->sadb_msg_pid;
+	c.event = XFRM_SAP_FLUSHED;
+	km_state_notify(NULL, &c);
 
 	return 0;
 }
@@ -1859,6 +1947,31 @@
 	hdr->sadb_msg_reserved = atomic_read(&xp->refcnt);
 }
 
+static int key_notify_policy( struct xfrm_policy *xp, int dir, struct km_event *c)
+{
+	struct sk_buff *out_skb;
+	struct sadb_msg *out_hdr;
+	int err;
+
+	out_skb = pfkey_xfrm_policy2msg_prep(xp);
+	if (IS_ERR(out_skb)) {
+		err =  PTR_ERR(out_skb);
+		goto out;
+	}
+	pfkey_xfrm_policy2msg(out_skb, xp, dir);
+
+	out_hdr = (struct sadb_msg *) out_skb->data;
+	out_hdr->sadb_msg_version =  PF_KEY_V2;
+	out_hdr->sadb_msg_type = event2poltype(c->event);
+	out_hdr->sadb_msg_errno = 0;
+	out_hdr->sadb_msg_seq = c->seq;
+	out_hdr->sadb_msg_pid = c->pid;
+	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ALL, NULL);
+out:
+	return 0;
+
+}
+
 static int pfkey_spdadd(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
 {
 	int err;
@@ -1866,8 +1979,7 @@
 	struct sadb_address *sa;
 	struct sadb_x_policy *pol;
 	struct xfrm_policy *xp;
-	struct sk_buff *out_skb;
-	struct sadb_msg *out_hdr;
+	struct km_event c;
 
 	if (!present_and_same_family(ext_hdrs[SADB_EXT_ADDRESS_SRC-1],
 				     ext_hdrs[SADB_EXT_ADDRESS_DST-1]) ||
@@ -1935,31 +2047,25 @@
 	    (err = parse_ipsecrequests(xp, pol)) < 0)
 		goto out;
 
-	out_skb = pfkey_xfrm_policy2msg_prep(xp);
-	if (IS_ERR(out_skb)) {
-		err =  PTR_ERR(out_skb);
-		goto out;
-	}
 
 	err = xfrm_policy_insert(pol->sadb_x_policy_dir-1, xp,
 				 hdr->sadb_msg_type != SADB_X_SPDUPDATE);
+
 	if (err) {
-		kfree_skb(out_skb);
-		goto out;
+		kfree(xp);
+		return err;
 	}
 
-	pfkey_xfrm_policy2msg(out_skb, xp, pol->sadb_x_policy_dir-1);
+	if (hdr->sadb_msg_type == SADB_X_SPDUPDATE) 
+		c.event = XFRM_SAP_UPDATED;
+	else 
+		c.event = XFRM_SAP_ADDED;
 
-	xfrm_pol_put(xp);
+	c.seq = hdr->sadb_msg_seq;
+	c.pid = hdr->sadb_msg_pid;
 
-	out_hdr = (struct sadb_msg *) out_skb->data;
-	out_hdr->sadb_msg_version = hdr->sadb_msg_version;
-	out_hdr->sadb_msg_type = hdr->sadb_msg_type;
-	out_hdr->sadb_msg_satype = 0;
-	out_hdr->sadb_msg_errno = 0;
-	out_hdr->sadb_msg_seq = hdr->sadb_msg_seq;
-	out_hdr->sadb_msg_pid = hdr->sadb_msg_pid;
-	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ALL, sk);
+	km_policy_notify(xp, pol->sadb_x_policy_dir-1, &c);
+	xfrm_pol_put(xp);
 	return 0;
 
 out:
@@ -1973,9 +2079,8 @@
 	struct sadb_address *sa;
 	struct sadb_x_policy *pol;
 	struct xfrm_policy *xp;
-	struct sk_buff *out_skb;
-	struct sadb_msg *out_hdr;
 	struct xfrm_selector sel;
+	struct km_event c;
 
 	if (!present_and_same_family(ext_hdrs[SADB_EXT_ADDRESS_SRC-1],
 				     ext_hdrs[SADB_EXT_ADDRESS_DST-1]) ||
@@ -2010,24 +2115,11 @@
 
 	err = 0;
 
-	out_skb = pfkey_xfrm_policy2msg_prep(xp);
-	if (IS_ERR(out_skb)) {
-		err =  PTR_ERR(out_skb);
-		goto out;
-	}
-	pfkey_xfrm_policy2msg(out_skb, xp, pol->sadb_x_policy_dir-1);
-
-	out_hdr = (struct sadb_msg *) out_skb->data;
-	out_hdr->sadb_msg_version = hdr->sadb_msg_version;
-	out_hdr->sadb_msg_type = SADB_X_SPDDELETE;
-	out_hdr->sadb_msg_satype = 0;
-	out_hdr->sadb_msg_errno = 0;
-	out_hdr->sadb_msg_seq = hdr->sadb_msg_seq;
-	out_hdr->sadb_msg_pid = hdr->sadb_msg_pid;
-	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ALL, sk);
-	err = 0;
+	c.seq = hdr->sadb_msg_seq;
+	c.pid = hdr->sadb_msg_pid;
+	c.event = XFRM_SAP_DELETED;
+	km_policy_notify(xp, pol->sadb_x_policy_dir-1, &c);
 
-out:
 	xfrm_pol_put(xp);
 	return err;
 }
@@ -2037,8 +2129,7 @@
 	int err;
 	struct sadb_x_policy *pol;
 	struct xfrm_policy *xp;
-	struct sk_buff *out_skb;
-	struct sadb_msg *out_hdr;
+	struct km_event c;
 
 	if ((pol = ext_hdrs[SADB_X_EXT_POLICY-1]) == NULL)
 		return -EINVAL;
@@ -2050,24 +2141,19 @@
 
 	err = 0;
 
-	out_skb = pfkey_xfrm_policy2msg_prep(xp);
-	if (IS_ERR(out_skb)) {
-		err =  PTR_ERR(out_skb);
-		goto out;
+	/* 
+	 * XXX: previous get was doing a broadcast-all _always_
+	 * which didnt seem right for non-deletion case - JHS
+	 * This is like the way netlink behaves ..
+	 * Shall i restore original behavior?
+	*/
+	if (hdr->sadb_msg_type == SADB_X_SPDDELETE2) {
+		c.seq = hdr->sadb_msg_seq;
+		c.pid = hdr->sadb_msg_pid;
+		c.event = XFRM_SAP_DELETED;
+		km_policy_notify(xp, pol->sadb_x_policy_dir-1, &c);
 	}
-	pfkey_xfrm_policy2msg(out_skb, xp, pol->sadb_x_policy_dir-1);
-
-	out_hdr = (struct sadb_msg *) out_skb->data;
-	out_hdr->sadb_msg_version = hdr->sadb_msg_version;
-	out_hdr->sadb_msg_type = hdr->sadb_msg_type;
-	out_hdr->sadb_msg_satype = 0;
-	out_hdr->sadb_msg_errno = 0;
-	out_hdr->sadb_msg_seq = hdr->sadb_msg_seq;
-	out_hdr->sadb_msg_pid = hdr->sadb_msg_pid;
-	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ALL, sk);
-	err = 0;
 
-out:
 	xfrm_pol_put(xp);
 	return err;
 }
@@ -2102,22 +2188,33 @@
 	return xfrm_policy_walk(dump_sp, &data);
 }
 
-static int pfkey_spdflush(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
+static int key_notify_policy_flush(struct km_event *c)
 {
 	struct sk_buff *skb_out;
-	struct sadb_msg *hdr_out;
-
-	skb_out = alloc_skb(sizeof(struct sadb_msg) + 16, GFP_KERNEL);
+	struct sadb_msg *hdr;
+	skb_out = alloc_skb(sizeof(struct sadb_msg) + 16, GFP_ATOMIC);
 	if (!skb_out)
 		return -ENOBUFS;
+	hdr = (struct sadb_msg *) skb_put(skb_out, sizeof(struct sadb_msg));
+	hdr->sadb_msg_seq = c->seq;
+	hdr->sadb_msg_pid = c->pid;
+	hdr->sadb_msg_version = PF_KEY_V2;
+	hdr->sadb_msg_errno = (uint8_t) 0;
+	hdr->sadb_msg_len = (sizeof(struct sadb_msg) / sizeof(uint64_t));
+	pfkey_broadcast(skb_out, GFP_ATOMIC, BROADCAST_ALL, NULL);
+	return 0;
 
-	xfrm_policy_flush();
+}
 
-	hdr_out = (struct sadb_msg *) skb_put(skb_out, sizeof(struct sadb_msg));
-	pfkey_hdr_dup(hdr_out, hdr);
-	hdr_out->sadb_msg_errno = (uint8_t) 0;
-	hdr_out->sadb_msg_len = (sizeof(struct sadb_msg) / sizeof(uint64_t));
-	pfkey_broadcast(skb_out, GFP_KERNEL, BROADCAST_ALL, NULL);
+static int pfkey_spdflush(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
+{
+	struct km_event c;
+
+	xfrm_policy_flush();
+	c.event = XFRM_SAP_FLUSHED;
+	c.pid = hdr->sadb_msg_pid;
+	c.seq = hdr->sadb_msg_seq;
+	km_policy_notify(NULL, 0, &c);
 
 	return 0;
 }
@@ -2317,11 +2414,25 @@
 	}
 }
 
-static int pfkey_send_notify(struct xfrm_state *x, int hard)
+/* XXX: Noisy for now */
+static int key_notify_policy_expire(struct xfrm_policy *xp, struct km_event *c)
+{
+	printk("pfkey doesnt deal with expired policies ..\n");
+	return 0;
+}
+
+static int key_notify_sa_expire(struct xfrm_state *x, struct km_event *c)
 {
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
-	int hsc = (hard ? 2 : 1);
+	int hard;
+	int hsc;
+
+	hard = c->data;
+	if (hard)
+		hsc = 2;
+	else
+		hsc = 1;
 
 	out_skb = pfkey_xfrm_state2msg(x, 0, hsc);
 	if (IS_ERR(out_skb))
@@ -2340,6 +2451,43 @@
 	return 0;
 }
 
+static int pfkey_send_notify(struct xfrm_state *x, struct km_event *c)
+{
+	switch (c->event) {
+	case XFRM_SAP_EXPIRED:
+		return key_notify_sa_expire(x, c);
+	case XFRM_SAP_DELETED:
+	case XFRM_SAP_ADDED:
+	case XFRM_SAP_UPDATED:
+		return key_notify_sa(x, c);
+	case XFRM_SAP_FLUSHED:
+		return key_notify_sa_flush(c);
+	default:
+		printk("pfkey: Unknown SA event %d\n",c->event);
+		break;
+	}
+
+	return 0;
+}
+
+static int pfkey_send_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
+{
+	switch (c->event) {
+	case XFRM_SAP_EXPIRED:
+		return key_notify_policy_expire(xp, c);
+	case XFRM_SAP_DELETED:
+	case XFRM_SAP_ADDED:
+	case XFRM_SAP_UPDATED:
+		return key_notify_policy(xp, dir, c);
+	case XFRM_SAP_FLUSHED:
+		return key_notify_policy_flush(c);
+	default:
+		printk("pfkey: Unknown policy event %d\n",c->event);
+		break;
+	}
+
+	return 0;
+}
 static u32 get_acqseq(void)
 {
 	u32 res;
@@ -2856,6 +3004,7 @@
 	.acquire	= pfkey_send_acquire,
 	.compile_policy	= pfkey_compile_policy,
 	.new_mapping	= pfkey_send_new_mapping,
+	.notify_policy	= pfkey_send_policy_notify,
 };
 
 static void __exit ipsec_pfkey_exit(void)

--=-CbZvGNdJ/zGTATpkMExl--
