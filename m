From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: 27 Mar 2005 14:07:29 -0500
Message-ID: <1111950449.1089.938.camel@jzny.localdomain>
References: <1111864971.1092.904.camel@jzny.localdomain>
	 <20050326194707.GA9872@gondor.apana.org.au>
	 <1111867875.1089.915.camel@jzny.localdomain>
	 <20050327081848.GA13428@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-zQLYFdMilXIEmOeqVReN"
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050327081848.GA13428@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-zQLYFdMilXIEmOeqVReN
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2005-03-27 at 03:18, Herbert Xu wrote:

> For non-standard extensions like this I wouldn't worry about PF_KEY.
> After all, if you're going to make sense of all the messages from
> the kernel you'll have to use netlink anyway.
> 

Just for consistency (since both call the same xfrm_state core code)
I made some minor changes to pf_key internal-to-kernel API (not exposed
to user space). Sample patch, still under construction, attached.
pfkey already does adverts on its own after a response from the generic
code. 
In the future this could be modified to do events about the same time
netlink does them i.e invocation from core xfrm_state code.
At the moment pfkey listeners are slightly delayed relative to netlink.

cheers,
jamal

--=-zQLYFdMilXIEmOeqVReN
Content-Disposition: attachment; filename=ipsec_p1-2
Content-Type: text/plain; name=ipsec_p1-2; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- 26115/include/net/xfrm.h	2005-03-19 01:35:02.000000000 -0500
+++ 26115-mod/include/net/xfrm.h	2005-03-27 09:00:03.000000000 -0500
@@ -157,6 +157,36 @@
 	XFRM_STATE_DEAD
 };
 
+/* events that could be sent by kernel */
+enum {
+	XFRM_SA_INVALID,
+	XFRM_SA_EXPIRED,
+	XFRM_SA_ADDED,
+	XFRM_SA_UPDATED,
+	XFRM_SA_DELETED,
+	XFRM_SA_FLUSHED,
+	__XFRM_SA_MAX
+};
+#define XFRM_SA_MAX (__XFRM_SA_MAX - 1)
+
+/* callback structure passed from either netlink or pfkey */
+struct xfrm_sa_cb
+{
+	u32	type; /* the type of caller netlink/pfkey/other */
+	u32	data; /* callee to caller */
+	void *hdr;
+	struct sk_buff *skb;
+};
+
+/* the types used in sa_cb */
+enum {
+	KM_SA_INVALID,
+	KM_SA_NETLINK,
+	KM_SA_PFKEY,
+	__KM_SA_MAX
+};
+#define KM_SA_MAX (__KM_SA_MAX - 1)
+
 struct xfrm_type;
 struct xfrm_dst;
 struct xfrm_policy_afinfo {
@@ -289,7 +319,7 @@
 {
 	struct list_head	list;
 	char			*id;
-	int			(*notify)(struct xfrm_state *x, int event);
+	int			(*notify)(struct xfrm_state *x, int event, struct xfrm_sa_cb *c);
 	int			(*acquire)(struct xfrm_state *x, struct xfrm_tmpl *, struct xfrm_policy *xp, int dir);
 	struct xfrm_policy	*(*compile_policy)(u16 family, int opt, u8 *data, int len, int *dir);
 	int			(*new_mapping)(struct xfrm_state *x, xfrm_address_t *ipaddr, u16 sport);
@@ -798,8 +828,8 @@
 					  unsigned short family);
 extern int xfrm_state_check_expire(struct xfrm_state *x);
 extern void xfrm_state_insert(struct xfrm_state *x);
-extern int xfrm_state_add(struct xfrm_state *x);
-extern int xfrm_state_update(struct xfrm_state *x);
+extern int xfrm_state_add(struct xfrm_state *x, struct xfrm_sa_cb *c);
+extern int xfrm_state_update(struct xfrm_state *x, struct xfrm_sa_cb *c);
 extern struct xfrm_state *xfrm_state_lookup(xfrm_address_t *daddr, u32 spi, u8 proto, unsigned short family);
 extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern void xfrm_state_delete(struct xfrm_state *x);
--- 26115/include/linux/xfrm.h	2005-03-19 01:35:06.000000000 -0500
+++ 26115-mod/include/linux/xfrm.h	2005-03-27 10:19:49.000000000 -0500
@@ -254,5 +254,7 @@
 
 #define XFRMGRP_ACQUIRE		1
 #define XFRMGRP_EXPIRE		2
+#define XFRMGRP_SA		4
+#define XFRMGRP_POLICY		8
 
 #endif /* _LINUX_XFRM_H */
--- 26115/net/xfrm/xfrm_state.c	2005-03-19 01:35:00.000000000 -0500
+++ 26115-mod/net/xfrm/xfrm_state.c	2005-03-27 09:14:09.000000000 -0500
@@ -402,7 +402,19 @@
 
 static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq);
 
-int xfrm_state_add(struct xfrm_state *x)
+static struct list_head xfrm_km_list = LIST_HEAD_INIT(xfrm_km_list);
+static DEFINE_RWLOCK(xfrm_km_lock);
+
+void xfrm_sa_notify(struct xfrm_state *x, struct xfrm_sa_cb *c, int event)
+{
+	struct xfrm_mgr *km;
+	read_lock(&xfrm_km_lock);
+	list_for_each_entry(km, &xfrm_km_list, list)
+		km->notify(x, event, c);
+	read_unlock(&xfrm_km_lock);
+}
+
+int xfrm_state_add(struct xfrm_state *x, struct xfrm_sa_cb *c)
 {
 	struct xfrm_state_afinfo *afinfo;
 	struct xfrm_state *x1;
@@ -438,6 +450,7 @@
 			&x->id.daddr, &x->props.saddr, 0);
 
 	__xfrm_state_insert(x);
+	xfrm_sa_notify(x, c, XFRM_SA_ADDED);
 	err = 0;
 
 out:
@@ -453,7 +466,7 @@
 }
 EXPORT_SYMBOL(xfrm_state_add);
 
-int xfrm_state_update(struct xfrm_state *x)
+int xfrm_state_update(struct xfrm_state *x, struct xfrm_sa_cb *c)
 {
 	struct xfrm_state_afinfo *afinfo;
 	struct xfrm_state *x1;
@@ -478,6 +491,9 @@
 
 	if (x1->km.state == XFRM_STATE_ACQ) {
 		__xfrm_state_insert(x);
+		/* XXXX: We already have xfrm_state_lock
+		 * do we need to grab x->lock as well? */
+		xfrm_sa_notify(x, c, XFRM_SA_ADDED);
 		x = NULL;
 	}
 	err = 0;
@@ -509,6 +525,7 @@
 			xfrm_state_check_expire(x1);
 
 		err = 0;
+		xfrm_sa_notify(x, c, XFRM_SA_UPDATED);
 	}
 	spin_unlock_bh(&x1->lock);
 
@@ -764,37 +781,41 @@
 }
 EXPORT_SYMBOL(xfrm_replay_advance);
 
-static struct list_head xfrm_km_list = LIST_HEAD_INIT(xfrm_km_list);
-static DEFINE_RWLOCK(xfrm_km_lock);
 
 static void km_state_expired(struct xfrm_state *x, int hard)
 {
 	struct xfrm_mgr *km;
+	struct xfrm_sa_cb c;
 
 	if (hard)
 		x->km.state = XFRM_STATE_EXPIRED;
 	else
 		x->km.dying = 1;
 
+	c.data = hard;
 	read_lock(&xfrm_km_lock);
 	list_for_each_entry(km, &xfrm_km_list, list)
-		km->notify(x, hard);
+		km->notify(x, XFRM_SA_EXPIRED, &c);
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
--- 26115/net/xfrm/xfrm_user.c	2005-03-19 01:34:58.000000000 -0500
+++ 26115-mod/net/xfrm/xfrm_user.c	2005-03-27 09:06:49.000000000 -0500
@@ -267,6 +267,7 @@
 {
 	struct xfrm_usersa_info *p = NLMSG_DATA(nlh);
 	struct xfrm_state *x;
+	struct xfrm_sa_cb c;
 	int err;
 
 	err = verify_newsa_info(p, (struct rtattr **) xfrma);
@@ -277,10 +278,14 @@
 	if (!x)
 		return err;
 
+	c.type = KM_SA_NETLINK;
+	c.skb = skb;
+	c.hdr = nlh;
+
 	if (nlh->nlmsg_type == XFRM_MSG_NEWSA)
-		err = xfrm_state_add(x);
+		err = xfrm_state_add(x, &c);
 	else
-		err = xfrm_state_update(x);
+		err = xfrm_state_update(x, &c);
 
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
@@ -1053,10 +1058,10 @@
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
@@ -1069,6 +1074,63 @@
 	return netlink_broadcast(xfrm_nl, skb, 0, XFRMGRP_EXPIRE, GFP_ATOMIC);
 }
 
+static int notify_add_upd( struct xfrm_state *x, int event, struct xfrm_sa_cb *c)
+{
+	struct xfrm_usersa_info *p;
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	u32 nlt;
+	unsigned char *b;
+	u32 ppid = 0;
+	struct nlmsghdr *in_nlh = c->hdr;
+	struct sk_buff *in_skb = c->skb;
+	int len = NLMSG_LENGTH(sizeof(struct xfrm_usersa_info));
+
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+	b = skb->tail;
+
+	if (c->type == KM_SA_NETLINK)
+		ppid = NETLINK_CB(in_skb).pid;
+
+	if (event == XFRM_SA_ADDED)
+		nlt = XFRM_MSG_NEWSA;
+	else if (event == XFRM_SA_UPDATED)
+		nlt = XFRM_MSG_UPDSA;
+	else
+		goto nlmsg_failure;
+
+	nlh = NLMSG_PUT(skb, ppid,
+			in_nlh->nlmsg_seq,
+			nlt, sizeof(*p));
+	nlh->nlmsg_flags = in_nlh->nlmsg_flags;
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
+static int xfrm_send_state_notify(struct xfrm_state *x, int event, struct xfrm_sa_cb *c)
+{
+
+	if ((event == XFRM_SA_ADDED) || (event == XFRM_SA_UPDATED))
+		return notify_add_upd(x, event, c);
+
+	if (event != XFRM_SA_EXPIRED)
+		return 0;
+
+	return xfrm_exp_state_notify(x, c->data);
+
+}
+
 static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 			 struct xfrm_tmpl *xt, struct xfrm_policy *xp,
 			 int dir)
--- 26115/net/key/af_key.c	2005-03-19 01:35:06.000000000 -0500
+++ 26115-mod/net/key/af_key.c	2005-03-27 09:01:01.000000000 -0500
@@ -1246,6 +1246,7 @@
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
 	struct xfrm_state *x;
+	struct xfrm_sa_cb c;
 	int err;
 
 	xfrm_probe_algs();
@@ -1254,10 +1255,14 @@
 	if (IS_ERR(x))
 		return PTR_ERR(x);
 
+	c.type = KM_SA_PFKEY;
+	c.hdr =  hdr;
+	c.skb =  skb;
+
 	if (hdr->sadb_msg_type == SADB_ADD)
-		err = xfrm_state_add(x);
+		err = xfrm_state_add(x, &c);
 	else
-		err = xfrm_state_update(x);
+		err = xfrm_state_update(x, &c);
 
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
@@ -2317,12 +2322,20 @@
 	}
 }
 
-static int pfkey_send_notify(struct xfrm_state *x, int hard)
+static int pfkey_send_notify(struct xfrm_state *x, int event, struct xfrm_sa_cb *c)
 {
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
+	int hard = c->data;
 	int hsc = (hard ? 2 : 1);
 
+	/* 
+	 * migrate pf_key later - for now only support is for
+	 * expire events 
+	*/
+	if (event != XFRM_SA_EXPIRED)
+		return 0; 
+
 	out_skb = pfkey_xfrm_state2msg(x, 0, hsc);
 	if (IS_ERR(out_skb))
 		return PTR_ERR(out_skb);

--=-zQLYFdMilXIEmOeqVReN--
