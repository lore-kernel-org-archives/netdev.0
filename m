From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/3] [NETLINK]: Directly return -EINTR from netlink_dump_start()
Date: Thu, 22 Mar 2007 00:18:04 +0100
Message-ID: <20070321231822.524479713@lsx.localdomain>
References: <20070321231801.342849239@lsx.localdomain>
Cc: netdev@vger.kernel.org, kaber@trash.net,
	Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:50351 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750821AbXCUXVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 19:21:30 -0400
Content-Disposition: inline; filename=netlink_dump_start_retval
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that all users of netlink_dump_start() use netlink_run_queue()
to process the receive queue, it is possible to return -EINTR from
netlink_dump_start() directly, therefore simplying the callers.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/core/rtnetlink.c
===================================================================
--- net-2.6.22.orig/net/core/rtnetlink.c	2007-03-21 18:38:32.000000000 +0100
+++ net-2.6.22/net/core/rtnetlink.c	2007-03-22 00:09:35.000000000 +0100
@@ -858,7 +858,6 @@ static int rtnetlink_rcv_msg(struct sk_b
 	int min_len;
 	int family;
 	int type;
-	int err;
 
 	type = nlh->nlmsg_type;
 	if (type > RTM_MAX)
@@ -887,10 +886,7 @@ static int rtnetlink_rcv_msg(struct sk_b
 		if (dumpit == NULL)
 			return -EINVAL;
 
-		err = netlink_dump_start(rtnl, skb, nlh, dumpit, NULL);
-		if (err == 0)
-			err = -EINTR;
-		return err;
+		return netlink_dump_start(rtnl, skb, nlh, dumpit, NULL);
 	}
 
 	memset(rta_buf, 0, (rtattr_max * sizeof(struct rtattr *)));
Index: net-2.6.22/net/ipv4/inet_diag.c
===================================================================
--- net-2.6.22.orig/net/ipv4/inet_diag.c	2007-03-22 00:08:05.000000000 +0100
+++ net-2.6.22/net/ipv4/inet_diag.c	2007-03-22 00:10:05.000000000 +0100
@@ -818,8 +818,6 @@ static int inet_diag_rcv_msg(struct sk_b
 		return -ENOENT;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
-		int err;
-
 		if (nlmsg_attrlen(nlh, hdrlen)) {
 			struct nlattr *attr;
 
@@ -831,11 +829,8 @@ static int inet_diag_rcv_msg(struct sk_b
 				return -EINVAL;
 		}
 
-		err = netlink_dump_start(idiagnl, skb, nlh,
-					 inet_diag_dump, NULL);
-		if (err == 0)
-			err = -EINTR;
-		return err;
+		return netlink_dump_start(idiagnl, skb, nlh,
+					  inet_diag_dump, NULL);
 	}
 
 	return inet_diag_get_exact(skb, nlh);
Index: net-2.6.22/net/netfilter/nf_conntrack_netlink.c
===================================================================
--- net-2.6.22.orig/net/netfilter/nf_conntrack_netlink.c	2007-03-21 18:38:32.000000000 +0100
+++ net-2.6.22/net/netfilter/nf_conntrack_netlink.c	2007-03-22 00:08:25.000000000 +0100
@@ -724,11 +724,8 @@ ctnetlink_get_conntrack(struct sock *ctn
 		if (NFNL_MSG_TYPE(nlh->nlmsg_type) == IPCTNL_MSG_CT_GET_CTRZERO)
 			return -ENOTSUPP;
 #endif
-		err = netlink_dump_start(ctnl, skb, nlh, ctnetlink_dump_table,
-					 ctnetlink_done);
-		if (err == 0)
-			err = -EINTR;
-		return err;
+		return netlink_dump_start(ctnl, skb, nlh, ctnetlink_dump_table,
+					  ctnetlink_done);
 	}
 
 	if (nfattr_bad_size(cda, CTA_MAX, cta_min))
@@ -1266,12 +1263,9 @@ ctnetlink_get_expect(struct sock *ctnl, 
 		return -EINVAL;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
-		err = netlink_dump_start(ctnl, skb, nlh,
-					 ctnetlink_exp_dump_table,
-					 ctnetlink_done);
-		if (err == 0)
-			err = -EINTR;
-		return err;
+		return netlink_dump_start(ctnl, skb, nlh,
+					  ctnetlink_exp_dump_table,
+					  ctnetlink_done);
 	}
 
 	if (cda[CTA_EXPECT_MASTER-1])
Index: net-2.6.22/net/netlink/af_netlink.c
===================================================================
--- net-2.6.22.orig/net/netlink/af_netlink.c	2007-03-22 00:02:36.000000000 +0100
+++ net-2.6.22/net/netlink/af_netlink.c	2007-03-22 00:08:25.000000000 +0100
@@ -1426,7 +1426,12 @@ int netlink_dump_start(struct sock *ssk,
 
 	netlink_dump(sk);
 	sock_put(sk);
-	return 0;
+
+	/* We successfully started a dump, by returning -EINTR we
+	 * signal the queue mangement to interrupt processing of
+	 * any netlink messages so userspace gets a chance to read
+	 * the results. */
+	return -EINTR;
 }
 
 void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
Index: net-2.6.22/net/netlink/genetlink.c
===================================================================
--- net-2.6.22.orig/net/netlink/genetlink.c	2007-03-21 18:38:32.000000000 +0100
+++ net-2.6.22/net/netlink/genetlink.c	2007-03-22 00:08:25.000000000 +0100
@@ -323,11 +323,8 @@ static int genl_rcv_msg(struct sk_buff *
 		if (ops->dumpit == NULL)
 			return -EOPNOTSUPP;
 
-		err = netlink_dump_start(genl_sock, skb, nlh,
-					 ops->dumpit, ops->done);
-		if (err == 0)
-			err = -EINTR;
-		return err;
+		return netlink_dump_start(genl_sock, skb, nlh,
+					  ops->dumpit, ops->done);
 	}
 
 	if (ops->doit == NULL)
Index: net-2.6.22/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.22.orig/net/xfrm/xfrm_user.c	2007-03-21 18:38:32.000000000 +0100
+++ net-2.6.22/net/xfrm/xfrm_user.c	2007-03-22 00:10:29.000000000 +0100
@@ -1857,7 +1857,7 @@ static int xfrm_user_rcv_msg(struct sk_b
 {
 	struct rtattr *xfrma[XFRMA_MAX];
 	struct xfrm_link *link;
-	int type, min_len, err;
+	int type, min_len;
 
 	type = nlh->nlmsg_type;
 	if (type > XFRM_MSG_MAX)
@@ -1876,10 +1876,7 @@ static int xfrm_user_rcv_msg(struct sk_b
 		if (link->dump == NULL)
 			return -EINVAL;
 
-		err = netlink_dump_start(xfrm_nl, skb, nlh, link->dump, NULL);
-		if (err == 0)
-			err = -EINTR;
-		return err;
+		return netlink_dump_start(xfrm_nl, skb, nlh, link->dump, NULL);
 	}
 
 	memset(xfrma, 0, sizeof(xfrma));

--

