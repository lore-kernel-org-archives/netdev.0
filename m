From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/5] [NETLINK]: Ignore control messages directly in netlink_run_queue()
Date: Wed, 21 Mar 2007 01:18:15 +0100
Message-ID: <20070321001900.885191779@lsx.localdomain>
References: <20070321001810.616784269@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44315 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933602AbXCUAUO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 20:20:14 -0400
Content-Disposition: inline; filename=netlink_run_queue_ignore_ctrl_msgs
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes netlink_rcv_skb() to skip netlink controll messages and don't
pass them on to the message handler.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/netlink/af_netlink.c
===================================================================
--- net-2.6.22.orig/net/netlink/af_netlink.c	2007-03-21 01:17:13.000000000 +0100
+++ net-2.6.22/net/netlink/af_netlink.c	2007-03-21 01:17:46.000000000 +0100
@@ -1479,6 +1479,10 @@ static int netlink_rcv_skb(struct sk_buf
 		if (!(nlh->nlmsg_flags & NLM_F_REQUEST))
 			goto skip;
 
+		/* Skip control messages */
+		if (nlh->nlmsg_type < NLMSG_MIN_TYPE)
+			goto skip;
+
 		if (cb(skb, nlh, &err) < 0) {
 			/* Not an error, but we have to interrupt processing
 			 * here. Note: that in this case we do not pull
Index: net-2.6.22/net/core/rtnetlink.c
===================================================================
--- net-2.6.22.orig/net/core/rtnetlink.c	2007-03-21 01:17:13.000000000 +0100
+++ net-2.6.22/net/core/rtnetlink.c	2007-03-21 01:17:46.000000000 +0100
@@ -863,10 +863,6 @@ rtnetlink_rcv_msg(struct sk_buff *skb, s
 
 	type = nlh->nlmsg_type;
 
-	/* A control message: ignore them */
-	if (type < RTM_BASE)
-		return 0;
-
 	/* Unknown message: reply with EINVAL */
 	if (type > RTM_MAX)
 		goto err_inval;
Index: net-2.6.22/net/netlink/genetlink.c
===================================================================
--- net-2.6.22.orig/net/netlink/genetlink.c	2007-03-21 01:17:13.000000000 +0100
+++ net-2.6.22/net/netlink/genetlink.c	2007-03-21 01:17:46.000000000 +0100
@@ -304,9 +304,6 @@ static int genl_rcv_msg(struct sk_buff *
 	struct genlmsghdr *hdr = nlmsg_data(nlh);
 	int hdrlen, err = -EINVAL;
 
-	if (nlh->nlmsg_type < NLMSG_MIN_TYPE)
-		goto ignore;
-
 	family = genl_family_find_byid(nlh->nlmsg_type);
 	if (family == NULL) {
 		err = -ENOENT;
@@ -364,9 +361,6 @@ static int genl_rcv_msg(struct sk_buff *
 	*errp = err = ops->doit(skb, &info);
 	return err;
 
-ignore:
-	return 0;
-
 errout:
 	*errp = err;
 	return -1;
Index: net-2.6.22/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.22.orig/net/xfrm/xfrm_user.c	2007-03-21 01:17:13.000000000 +0100
+++ net-2.6.22/net/xfrm/xfrm_user.c	2007-03-21 01:17:46.000000000 +0100
@@ -1861,10 +1861,6 @@ static int xfrm_user_rcv_msg(struct sk_b
 
 	type = nlh->nlmsg_type;
 
-	/* A control message: ignore them */
-	if (type < XFRM_MSG_BASE)
-		return 0;
-
 	/* Unknown message: reply with EINVAL */
 	if (type > XFRM_MSG_MAX)
 		goto err_einval;

--

