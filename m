From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/3] [NETLINK]: Remove error pointer from netlink message handler
Date: Thu, 22 Mar 2007 00:18:02 +0100
Message-ID: <20070321231822.242534557@lsx.localdomain>
References: <20070321231801.342849239@lsx.localdomain>
Cc: netdev@vger.kernel.org, kaber@trash.net,
	Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:50339 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753121AbXCUXVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 19:21:20 -0400
Content-Disposition: inline; filename=netlink_run_queue_remove_errp
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The error pointer argument in netlink message handlers is used
to signal the special case where processing has to be interrupted
because a dump was started but no error happened. Instead it is
simpler and more clear to return -EINTR and have netlink_run_queue()
deal with getting the queue right.

nfnetlink passed on this error pointer to its subsystem handlers
but only uses it to signal the start of a netlink dump. Therefore
it can be removed there as well.

This patch also cleans up the error handling in the affected
message handlers to be consistent since it had to be touched anyway.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/core/rtnetlink.c
===================================================================
--- net-2.6.22.orig/net/core/rtnetlink.c	2007-03-21 15:36:28.000000000 +0100
+++ net-2.6.22/net/core/rtnetlink.c	2007-03-21 18:38:32.000000000 +0100
@@ -851,8 +851,7 @@ static int rtattr_max;
 
 /* Process one rtnetlink message. */
 
-static __inline__ int
-rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh, int *errp)
+static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	rtnl_doit_func doit;
 	int sz_idx, kind;
@@ -862,10 +861,8 @@ rtnetlink_rcv_msg(struct sk_buff *skb, s
 	int err;
 
 	type = nlh->nlmsg_type;
-
-	/* Unknown message: reply with EINVAL */
 	if (type > RTM_MAX)
-		goto err_inval;
+		return -EINVAL;
 
 	type -= RTM_BASE;
 
@@ -874,40 +871,33 @@ rtnetlink_rcv_msg(struct sk_buff *skb, s
 		return 0;
 
 	family = ((struct rtgenmsg*)NLMSG_DATA(nlh))->rtgen_family;
-	if (family >= NPROTO) {
-		*errp = -EAFNOSUPPORT;
-		return -1;
-	}
+	if (family >= NPROTO)
+		return -EAFNOSUPPORT;
 
 	sz_idx = type>>2;
 	kind = type&3;
 
-	if (kind != 2 && security_netlink_recv(skb, CAP_NET_ADMIN)) {
-		*errp = -EPERM;
-		return -1;
-	}
+	if (kind != 2 && security_netlink_recv(skb, CAP_NET_ADMIN))
+		return -EPERM;
 
 	if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP) {
 		rtnl_dumpit_func dumpit;
 
 		dumpit = rtnl_get_dumpit(family, type);
 		if (dumpit == NULL)
-			goto err_inval;
+			return -EINVAL;
 
-		if ((*errp = netlink_dump_start(rtnl, skb, nlh,
-						dumpit, NULL)) != 0) {
-			return -1;
-		}
-
-		netlink_queue_skip(nlh, skb);
-		return -1;
+		err = netlink_dump_start(rtnl, skb, nlh, dumpit, NULL);
+		if (err == 0)
+			err = -EINTR;
+		return err;
 	}
 
 	memset(rta_buf, 0, (rtattr_max * sizeof(struct rtattr *)));
 
 	min_len = rtm_min[sz_idx];
 	if (nlh->nlmsg_len < min_len)
-		goto err_inval;
+		return -EINVAL;
 
 	if (nlh->nlmsg_len > min_len) {
 		int attrlen = nlh->nlmsg_len - NLMSG_ALIGN(min_len);
@@ -917,7 +907,7 @@ rtnetlink_rcv_msg(struct sk_buff *skb, s
 			unsigned flavor = attr->rta_type;
 			if (flavor) {
 				if (flavor > rta_max[sz_idx])
-					goto err_inval;
+					return -EINVAL;
 				rta_buf[flavor-1] = attr;
 			}
 			attr = RTA_NEXT(attr, attrlen);
@@ -926,15 +916,9 @@ rtnetlink_rcv_msg(struct sk_buff *skb, s
 
 	doit = rtnl_get_doit(family, type);
 	if (doit == NULL)
-		goto err_inval;
-	err = doit(skb, nlh, (void *)&rta_buf[0]);
-
-	*errp = err;
-	return err;
+		return -EINVAL;
 
-err_inval:
-	*errp = -EINVAL;
-	return -1;
+	return doit(skb, nlh, (void *)&rta_buf[0]);
 }
 
 static void rtnetlink_rcv(struct sock *sk, int len)
Index: net-2.6.22/net/netlink/genetlink.c
===================================================================
--- net-2.6.22.orig/net/netlink/genetlink.c	2007-03-21 15:42:18.000000000 +0100
+++ net-2.6.22/net/netlink/genetlink.c	2007-03-21 18:38:32.000000000 +0100
@@ -295,60 +295,49 @@ int genl_unregister_family(struct genl_f
 	return -ENOENT;
 }
 
-static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
-			       int *errp)
+static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct genl_ops *ops;
 	struct genl_family *family;
 	struct genl_info info;
 	struct genlmsghdr *hdr = nlmsg_data(nlh);
-	int hdrlen, err = -EINVAL;
+	int hdrlen, err;
 
 	family = genl_family_find_byid(nlh->nlmsg_type);
-	if (family == NULL) {
-		err = -ENOENT;
-		goto errout;
-	}
+	if (family == NULL)
+		return -ENOENT;
 
 	hdrlen = GENL_HDRLEN + family->hdrsize;
 	if (nlh->nlmsg_len < nlmsg_msg_size(hdrlen))
-		goto errout;
+		return -EINVAL;
 
 	ops = genl_get_cmd(hdr->cmd, family);
-	if (ops == NULL) {
-		err = -EOPNOTSUPP;
-		goto errout;
-	}
+	if (ops == NULL)
+		return -EOPNOTSUPP;
 
-	if ((ops->flags & GENL_ADMIN_PERM) && security_netlink_recv(skb, CAP_NET_ADMIN)) {
-		err = -EPERM;
-		goto errout;
-	}
+	if ((ops->flags & GENL_ADMIN_PERM) &&
+	    security_netlink_recv(skb, CAP_NET_ADMIN))
+		return -EPERM;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
-		if (ops->dumpit == NULL) {
-			err = -EOPNOTSUPP;
-			goto errout;
-		}
+		if (ops->dumpit == NULL)
+			return -EOPNOTSUPP;
 
-		*errp = err = netlink_dump_start(genl_sock, skb, nlh,
-						 ops->dumpit, ops->done);
+		err = netlink_dump_start(genl_sock, skb, nlh,
+					 ops->dumpit, ops->done);
 		if (err == 0)
-			skb_pull(skb, min(NLMSG_ALIGN(nlh->nlmsg_len),
-					  skb->len));
-		return -1;
+			err = -EINTR;
+		return err;
 	}
 
-	if (ops->doit == NULL) {
-		err = -EOPNOTSUPP;
-		goto errout;
-	}
+	if (ops->doit == NULL)
+		return -EOPNOTSUPP;
 
 	if (family->attrbuf) {
 		err = nlmsg_parse(nlh, hdrlen, family->attrbuf, family->maxattr,
 				  ops->policy);
 		if (err < 0)
-			goto errout;
+			return err;
 	}
 
 	info.snd_seq = nlh->nlmsg_seq;
@@ -358,12 +347,7 @@ static int genl_rcv_msg(struct sk_buff *
 	info.userhdr = nlmsg_data(nlh) + GENL_HDRLEN;
 	info.attrs = family->attrbuf;
 
-	*errp = err = ops->doit(skb, &info);
-	return err;
-
-errout:
-	*errp = err;
-	return -1;
+	return ops->doit(skb, &info);
 }
 
 static void genl_rcv(struct sock *sk, int len)
Index: net-2.6.22/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.22.orig/net/xfrm/xfrm_user.c	2007-03-21 15:48:08.000000000 +0100
+++ net-2.6.22/net/xfrm/xfrm_user.c	2007-03-21 18:38:32.000000000 +0100
@@ -1853,46 +1853,39 @@ static struct xfrm_link {
 	[XFRM_MSG_MIGRATE     - XFRM_MSG_BASE] = { .doit = xfrm_do_migrate    },
 };
 
-static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh, int *errp)
+static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct rtattr *xfrma[XFRMA_MAX];
 	struct xfrm_link *link;
-	int type, min_len;
+	int type, min_len, err;
 
 	type = nlh->nlmsg_type;
-
-	/* Unknown message: reply with EINVAL */
 	if (type > XFRM_MSG_MAX)
-		goto err_einval;
+		return -EINVAL;
 
 	type -= XFRM_MSG_BASE;
 	link = &xfrm_dispatch[type];
 
 	/* All operations require privileges, even GET */
-	if (security_netlink_recv(skb, CAP_NET_ADMIN)) {
-		*errp = -EPERM;
-		return -1;
-	}
+	if (security_netlink_recv(skb, CAP_NET_ADMIN))
+		return -EPERM;
 
 	if ((type == (XFRM_MSG_GETSA - XFRM_MSG_BASE) ||
 	     type == (XFRM_MSG_GETPOLICY - XFRM_MSG_BASE)) &&
 	    (nlh->nlmsg_flags & NLM_F_DUMP)) {
 		if (link->dump == NULL)
-			goto err_einval;
-
-		if ((*errp = netlink_dump_start(xfrm_nl, skb, nlh,
-						link->dump, NULL)) != 0) {
-			return -1;
-		}
+			return -EINVAL;
 
-		netlink_queue_skip(nlh, skb);
-		return -1;
+		err = netlink_dump_start(xfrm_nl, skb, nlh, link->dump, NULL);
+		if (err == 0)
+			err = -EINTR;
+		return err;
 	}
 
 	memset(xfrma, 0, sizeof(xfrma));
 
 	if (nlh->nlmsg_len < (min_len = xfrm_msg_min[type]))
-		goto err_einval;
+		return -EINVAL;
 
 	if (nlh->nlmsg_len > min_len) {
 		int attrlen = nlh->nlmsg_len - NLMSG_ALIGN(min_len);
@@ -1902,7 +1895,7 @@ static int xfrm_user_rcv_msg(struct sk_b
 			unsigned short flavor = attr->rta_type;
 			if (flavor) {
 				if (flavor > XFRMA_MAX)
-					goto err_einval;
+					return -EINVAL;
 				xfrma[flavor - 1] = attr;
 			}
 			attr = RTA_NEXT(attr, attrlen);
@@ -1910,14 +1903,9 @@ static int xfrm_user_rcv_msg(struct sk_b
 	}
 
 	if (link->doit == NULL)
-		goto err_einval;
-	*errp = link->doit(skb, nlh, xfrma);
-
-	return *errp;
+		return -EINVAL;
 
-err_einval:
-	*errp = -EINVAL;
-	return -1;
+	return link->doit(skb, nlh, xfrma);
 }
 
 static void xfrm_netlink_rcv(struct sock *sk, int len)
Index: net-2.6.22/net/netfilter/nfnetlink.c
===================================================================
--- net-2.6.22.orig/net/netfilter/nfnetlink.c	2007-03-21 15:49:41.000000000 +0100
+++ net-2.6.22/net/netfilter/nfnetlink.c	2007-03-21 17:44:24.000000000 +0100
@@ -195,17 +195,14 @@ int nfnetlink_unicast(struct sk_buff *sk
 EXPORT_SYMBOL_GPL(nfnetlink_unicast);
 
 /* Process one complete nfnetlink message. */
-static int nfnetlink_rcv_msg(struct sk_buff *skb,
-				    struct nlmsghdr *nlh, int *errp)
+static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct nfnl_callback *nc;
 	struct nfnetlink_subsystem *ss;
-	int type, err = 0;
+	int type, err;
 
-	if (security_netlink_recv(skb, CAP_NET_ADMIN)) {
-		*errp = -EPERM;
-		return -1;
-	}
+	if (security_netlink_recv(skb, CAP_NET_ADMIN))
+		return -EPERM;
 
 	/* All the messages must at least contain nfgenmsg */
 	if (nlh->nlmsg_len < NLMSG_SPACE(sizeof(struct nfgenmsg)))
@@ -223,12 +220,12 @@ static int nfnetlink_rcv_msg(struct sk_b
 		ss = nfnetlink_get_subsys(type);
 		if (!ss)
 #endif
-			goto err_inval;
+			return -EINVAL;
 	}
 
 	nc = nfnetlink_find_client(type, ss);
 	if (!nc)
-		goto err_inval;
+		return -EINVAL;
 
 	{
 		u_int16_t attr_count =
@@ -239,16 +236,9 @@ static int nfnetlink_rcv_msg(struct sk_b
 
 		err = nfnetlink_check_attributes(ss, nlh, cda);
 		if (err < 0)
-			goto err_inval;
-
-		err = nc->call(nfnl, skb, nlh, cda, errp);
-		*errp = err;
-		return err;
+			return err;
+		return nc->call(nfnl, skb, nlh, cda);
 	}
-
-err_inval:
-	*errp = -EINVAL;
-	return -1;
 }
 
 static void nfnetlink_rcv(struct sock *sk, int len)
Index: net-2.6.22/include/net/netlink.h
===================================================================
--- net-2.6.22.orig/include/net/netlink.h	2007-03-21 15:51:15.000000000 +0100
+++ net-2.6.22/include/net/netlink.h	2007-03-21 15:54:17.000000000 +0100
@@ -214,7 +214,7 @@ struct nl_info {
 
 extern void		netlink_run_queue(struct sock *sk, unsigned int *qlen,
 					  int (*cb)(struct sk_buff *,
-						    struct nlmsghdr *, int *));
+						    struct nlmsghdr *));
 extern void		netlink_queue_skip(struct nlmsghdr *nlh,
 					   struct sk_buff *skb);
 extern int		nlmsg_notify(struct sock *sk, struct sk_buff *skb,
Index: net-2.6.22/net/netlink/af_netlink.c
===================================================================
--- net-2.6.22.orig/net/netlink/af_netlink.c	2007-03-21 15:36:10.000000000 +0100
+++ net-2.6.22/net/netlink/af_netlink.c	2007-03-22 00:02:36.000000000 +0100
@@ -1463,7 +1463,7 @@ void netlink_ack(struct sk_buff *in_skb,
 }
 
 static int netlink_rcv_skb(struct sk_buff *skb, int (*cb)(struct sk_buff *,
-						     struct nlmsghdr *, int *))
+						     struct nlmsghdr *))
 {
 	struct nlmsghdr *nlh;
 	int err;
@@ -1483,13 +1483,11 @@ static int netlink_rcv_skb(struct sk_buf
 		if (nlh->nlmsg_type < NLMSG_MIN_TYPE)
 			goto skip;
 
-		if (cb(skb, nlh, &err) < 0) {
-			/* Not an error, but we have to interrupt processing
-			 * here. Note: that in this case we do not pull
-			 * message from skb, it will be processed later.
-			 */
-			if (err == 0)
-				return -1;
+		err = cb(skb, nlh);
+		if (err == -EINTR) {
+			/* Not an error, but we interrupt processing */
+			netlink_queue_skip(nlh, skb);
+			return err;
 		}
 skip:
 		if (nlh->nlmsg_flags & NLM_F_ACK || err)
@@ -1515,9 +1513,14 @@ skip:
  *
  * qlen must be initialized to 0 before the initial entry, afterwards
  * the function may be called repeatedly until qlen reaches 0.
+ *
+ * The callback function may return -EINTR to signal that processing
+ * of netlink messages shall be interrupted. In this case the message
+ * currently being processed will NOT be requeued onto the receive
+ * queue.
  */
 void netlink_run_queue(struct sock *sk, unsigned int *qlen,
-		       int (*cb)(struct sk_buff *, struct nlmsghdr *, int *))
+		       int (*cb)(struct sk_buff *, struct nlmsghdr *))
 {
 	struct sk_buff *skb;
 
Index: net-2.6.22/net/netfilter/nf_conntrack_netlink.c
===================================================================
--- net-2.6.22.orig/net/netfilter/nf_conntrack_netlink.c	2007-03-21 16:07:09.000000000 +0100
+++ net-2.6.22/net/netfilter/nf_conntrack_netlink.c	2007-03-21 18:38:32.000000000 +0100
@@ -661,7 +661,7 @@ static const size_t cta_min[CTA_MAX] = {
 
 static int
 ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
-			struct nlmsghdr *nlh, struct nfattr *cda[], int *errp)
+			struct nlmsghdr *nlh, struct nfattr *cda[])
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_tuple tuple;
@@ -709,7 +709,7 @@ ctnetlink_del_conntrack(struct sock *ctn
 
 static int
 ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
-			struct nlmsghdr *nlh, struct nfattr *cda[], int *errp)
+			struct nlmsghdr *nlh, struct nfattr *cda[])
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_tuple tuple;
@@ -720,22 +720,15 @@ ctnetlink_get_conntrack(struct sock *ctn
 	int err = 0;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
-		u32 rlen;
-
 #ifndef CONFIG_NF_CT_ACCT
 		if (NFNL_MSG_TYPE(nlh->nlmsg_type) == IPCTNL_MSG_CT_GET_CTRZERO)
 			return -ENOTSUPP;
 #endif
-		if ((*errp = netlink_dump_start(ctnl, skb, nlh,
-						ctnetlink_dump_table,
-						ctnetlink_done)) != 0)
-			return -EINVAL;
-
-		rlen = NLMSG_ALIGN(nlh->nlmsg_len);
-		if (rlen > skb->len)
-			rlen = skb->len;
-		skb_pull(skb, rlen);
-		return 0;
+		err = netlink_dump_start(ctnl, skb, nlh, ctnetlink_dump_table,
+					 ctnetlink_done);
+		if (err == 0)
+			err = -EINTR;
+		return err;
 	}
 
 	if (nfattr_bad_size(cda, CTA_MAX, cta_min))
@@ -1009,7 +1002,7 @@ err:
 
 static int
 ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
-			struct nlmsghdr *nlh, struct nfattr *cda[], int *errp)
+			struct nlmsghdr *nlh, struct nfattr *cda[])
 {
 	struct nf_conntrack_tuple otuple, rtuple;
 	struct nf_conntrack_tuple_hash *h = NULL;
@@ -1260,7 +1253,7 @@ static const size_t cta_min_exp[CTA_EXPE
 
 static int
 ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
-		     struct nlmsghdr *nlh, struct nfattr *cda[], int *errp)
+		     struct nlmsghdr *nlh, struct nfattr *cda[])
 {
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_expect *exp;
@@ -1273,17 +1266,12 @@ ctnetlink_get_expect(struct sock *ctnl, 
 		return -EINVAL;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
-		u32 rlen;
-
-		if ((*errp = netlink_dump_start(ctnl, skb, nlh,
-						ctnetlink_exp_dump_table,
-						ctnetlink_done)) != 0)
-			return -EINVAL;
-		rlen = NLMSG_ALIGN(nlh->nlmsg_len);
-		if (rlen > skb->len)
-			rlen = skb->len;
-		skb_pull(skb, rlen);
-		return 0;
+		err = netlink_dump_start(ctnl, skb, nlh,
+					 ctnetlink_exp_dump_table,
+					 ctnetlink_done);
+		if (err == 0)
+			err = -EINTR;
+		return err;
 	}
 
 	if (cda[CTA_EXPECT_MASTER-1])
@@ -1330,7 +1318,7 @@ out:
 
 static int
 ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
-		     struct nlmsghdr *nlh, struct nfattr *cda[], int *errp)
+		     struct nlmsghdr *nlh, struct nfattr *cda[])
 {
 	struct nf_conntrack_expect *exp, *tmp;
 	struct nf_conntrack_tuple tuple;
@@ -1464,7 +1452,7 @@ out:
 
 static int
 ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
-		     struct nlmsghdr *nlh, struct nfattr *cda[], int *errp)
+		     struct nlmsghdr *nlh, struct nfattr *cda[])
 {
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_expect *exp;
Index: net-2.6.22/net/netfilter/nfnetlink_log.c
===================================================================
--- net-2.6.22.orig/net/netfilter/nfnetlink_log.c	2007-03-21 16:09:47.000000000 +0100
+++ net-2.6.22/net/netfilter/nfnetlink_log.c	2007-03-21 16:10:11.000000000 +0100
@@ -759,7 +759,7 @@ static struct notifier_block nfulnl_rtnl
 
 static int
 nfulnl_recv_unsupp(struct sock *ctnl, struct sk_buff *skb,
-		  struct nlmsghdr *nlh, struct nfattr *nfqa[], int *errp)
+		  struct nlmsghdr *nlh, struct nfattr *nfqa[])
 {
 	return -ENOTSUPP;
 }
@@ -797,7 +797,7 @@ static const int nfula_cfg_min[NFULA_CFG
 
 static int
 nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
-		   struct nlmsghdr *nlh, struct nfattr *nfula[], int *errp)
+		   struct nlmsghdr *nlh, struct nfattr *nfula[])
 {
 	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
 	u_int16_t group_num = ntohs(nfmsg->res_id);
Index: net-2.6.22/net/netfilter/nfnetlink_queue.c
===================================================================
--- net-2.6.22.orig/net/netfilter/nfnetlink_queue.c	2007-03-21 16:10:21.000000000 +0100
+++ net-2.6.22/net/netfilter/nfnetlink_queue.c	2007-03-21 16:11:55.000000000 +0100
@@ -783,7 +783,7 @@ static const int nfqa_verdict_min[NFQA_M
 
 static int
 nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
-		   struct nlmsghdr *nlh, struct nfattr *nfqa[], int *errp)
+		   struct nlmsghdr *nlh, struct nfattr *nfqa[])
 {
 	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
 	u_int16_t queue_num = ntohs(nfmsg->res_id);
@@ -848,7 +848,7 @@ err_out_put:
 
 static int
 nfqnl_recv_unsupp(struct sock *ctnl, struct sk_buff *skb,
-		  struct nlmsghdr *nlh, struct nfattr *nfqa[], int *errp)
+		  struct nlmsghdr *nlh, struct nfattr *nfqa[])
 {
 	return -ENOTSUPP;
 }
@@ -865,7 +865,7 @@ static struct nf_queue_handler nfqh = {
 
 static int
 nfqnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
-		  struct nlmsghdr *nlh, struct nfattr *nfqa[], int *errp)
+		  struct nlmsghdr *nlh, struct nfattr *nfqa[])
 {
 	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
 	u_int16_t queue_num = ntohs(nfmsg->res_id);
Index: net-2.6.22/include/linux/netfilter/nfnetlink.h
===================================================================
--- net-2.6.22.orig/include/linux/netfilter/nfnetlink.h	2007-03-21 16:13:31.000000000 +0100
+++ net-2.6.22/include/linux/netfilter/nfnetlink.h	2007-03-21 16:13:41.000000000 +0100
@@ -111,7 +111,7 @@ struct nfgenmsg {
 struct nfnl_callback
 {
 	int (*call)(struct sock *nl, struct sk_buff *skb, 
-		struct nlmsghdr *nlh, struct nfattr *cda[], int *errp);
+		struct nlmsghdr *nlh, struct nfattr *cda[]);
 	u_int16_t attr_count;	/* number of nfattr's */
 };
 

--

