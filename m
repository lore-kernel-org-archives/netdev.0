From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/5] [NETLINK]: Ignore !NLM_F_REQUEST messages directly in netlink_run_queue()
Date: Wed, 21 Mar 2007 01:18:14 +0100
Message-ID: <20070321001900.748961655@lsx.localdomain>
References: <20070321001810.616784269@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44312 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932854AbXCUAUJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 20:20:09 -0400
Content-Disposition: inline; filename=netlink_run_queue_ignore_non_request
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netlink_rcv_skb() is changed to skip messages which don't have the
NLM_F_REQUEST bit to avoid every netlink family having to perform this
check on their own.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/netlink/af_netlink.c
===================================================================
--- net-2.6.22.orig/net/netlink/af_netlink.c	2007-03-21 01:16:39.000000000 +0100
+++ net-2.6.22/net/netlink/af_netlink.c	2007-03-21 01:17:13.000000000 +0100
@@ -1470,10 +1470,15 @@ static int netlink_rcv_skb(struct sk_buf
 
 	while (skb->len >= nlmsg_total_size(0)) {
 		nlh = nlmsg_hdr(skb);
+		err = 0;
 
 		if (nlh->nlmsg_len < NLMSG_HDRLEN || skb->len < nlh->nlmsg_len)
 			return 0;
 
+		/* Only requests are handled by the kernel */
+		if (!(nlh->nlmsg_flags & NLM_F_REQUEST))
+			goto skip;
+
 		if (cb(skb, nlh, &err) < 0) {
 			/* Not an error, but we have to interrupt processing
 			 * here. Note: that in this case we do not pull
@@ -1481,9 +1486,10 @@ static int netlink_rcv_skb(struct sk_buf
 			 */
 			if (err == 0)
 				return -1;
+		}
+skip:
+		if (nlh->nlmsg_flags & NLM_F_ACK || err)
 			netlink_ack(skb, nlh, err);
-		} else if (nlh->nlmsg_flags & NLM_F_ACK)
-			netlink_ack(skb, nlh, 0);
 
 		netlink_queue_skip(nlh, skb);
 	}
Index: net-2.6.22/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.22.orig/net/xfrm/xfrm_user.c	2007-03-20 23:53:19.000000000 +0100
+++ net-2.6.22/net/xfrm/xfrm_user.c	2007-03-21 01:17:13.000000000 +0100
@@ -1859,9 +1859,6 @@ static int xfrm_user_rcv_msg(struct sk_b
 	struct xfrm_link *link;
 	int type, min_len;
 
-	if (!(nlh->nlmsg_flags & NLM_F_REQUEST))
-		return 0;
-
 	type = nlh->nlmsg_type;
 
 	/* A control message: ignore them */
Index: net-2.6.22/net/netlink/genetlink.c
===================================================================
--- net-2.6.22.orig/net/netlink/genetlink.c	2007-03-20 23:53:19.000000000 +0100
+++ net-2.6.22/net/netlink/genetlink.c	2007-03-21 01:17:13.000000000 +0100
@@ -304,9 +304,6 @@ static int genl_rcv_msg(struct sk_buff *
 	struct genlmsghdr *hdr = nlmsg_data(nlh);
 	int hdrlen, err = -EINVAL;
 
-	if (!(nlh->nlmsg_flags & NLM_F_REQUEST))
-		goto ignore;
-
 	if (nlh->nlmsg_type < NLMSG_MIN_TYPE)
 		goto ignore;
 
Index: net-2.6.22/net/core/rtnetlink.c
===================================================================
--- net-2.6.22.orig/net/core/rtnetlink.c	2007-03-21 00:52:43.000000000 +0100
+++ net-2.6.22/net/core/rtnetlink.c	2007-03-21 01:17:13.000000000 +0100
@@ -861,10 +861,6 @@ rtnetlink_rcv_msg(struct sk_buff *skb, s
 	int type;
 	int err;
 
-	/* Only requests are handled by kernel now */
-	if (!(nlh->nlmsg_flags&NLM_F_REQUEST))
-		return 0;
-
 	type = nlh->nlmsg_type;
 
 	/* A control message: ignore them */

--

