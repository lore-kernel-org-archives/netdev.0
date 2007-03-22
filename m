From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 7/8] [IPv4] diag: Use netlink_run_queue() to process the receive queue
Date: Thu, 22 Mar 2007 23:18:11 +0100
Message-ID: <20070322221850.587457838@lsx.localdomain>
References: <20070322221804.000124130@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56202 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161158AbXCVWWM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 18:22:12 -0400
Content-Disposition: inline; filename=inet_diag_queue_run
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Makes use of netlink_run_queue() to process the receive queue and
converts inet_diag_rcv_msg() to use the type safe netlink interface.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/ipv4/inet_diag.c
===================================================================
--- net-2.6.22.orig/net/ipv4/inet_diag.c	2007-03-22 23:15:31.000000000 +0100
+++ net-2.6.22/net/ipv4/inet_diag.c	2007-03-22 23:16:05.000000000 +0100
@@ -806,68 +806,48 @@ done:
 	return skb->len;
 }
 
-static inline int inet_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int inet_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	if (!(nlh->nlmsg_flags&NLM_F_REQUEST))
-		return 0;
+	int hdrlen = sizeof(struct inet_diag_req);
 
-	if (nlh->nlmsg_type >= INET_DIAG_GETSOCK_MAX)
-		goto err_inval;
+	if (nlh->nlmsg_type >= INET_DIAG_GETSOCK_MAX ||
+	    nlmsg_len(nlh) < hdrlen)
+		return -EINVAL;
 
 	if (inet_diag_table[nlh->nlmsg_type] == NULL)
 		return -ENOENT;
 
-	if (NLMSG_LENGTH(sizeof(struct inet_diag_req)) > skb->len)
-		goto err_inval;
-
-	if (nlh->nlmsg_flags&NLM_F_DUMP) {
-		if (nlh->nlmsg_len >
-		    (4 + NLMSG_SPACE(sizeof(struct inet_diag_req)))) {
-			struct rtattr *rta = (void *)(NLMSG_DATA(nlh) +
-						 sizeof(struct inet_diag_req));
-			if (rta->rta_type != INET_DIAG_REQ_BYTECODE ||
-			    rta->rta_len < 8 ||
-			    rta->rta_len >
-			    (nlh->nlmsg_len -
-			     NLMSG_SPACE(sizeof(struct inet_diag_req))))
-				goto err_inval;
-			if (inet_diag_bc_audit(RTA_DATA(rta), RTA_PAYLOAD(rta)))
-				goto err_inval;
-		}
-		return netlink_dump_start(idiagnl, skb, nlh,
-					  inet_diag_dump, NULL);
-	} else
-		return inet_diag_get_exact(skb, nlh);
-
-err_inval:
-	return -EINVAL;
-}
+	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+		int err;
 
+		if (nlmsg_attrlen(nlh, hdrlen)) {
+			struct nlattr *attr;
 
-static inline void inet_diag_rcv_skb(struct sk_buff *skb)
-{
-	if (skb->len >= NLMSG_SPACE(0)) {
-		int err;
-		struct nlmsghdr *nlh = nlmsg_hdr(skb);
+			attr = nlmsg_find_attr(nlh, hdrlen,
+					       INET_DIAG_REQ_BYTECODE);
+			if (attr == NULL ||
+			    nla_len(attr) < sizeof(struct inet_diag_bc_op) ||
+			    inet_diag_bc_audit(nla_data(attr), nla_len(attr)))
+				return -EINVAL;
+		}
 
-		if (nlh->nlmsg_len < sizeof(*nlh) ||
-		    skb->len < nlh->nlmsg_len)
-			return;
-		err = inet_diag_rcv_msg(skb, nlh);
-		if (err || nlh->nlmsg_flags & NLM_F_ACK)
-			netlink_ack(skb, nlh, err);
+		err = netlink_dump_start(idiagnl, skb, nlh,
+					 inet_diag_dump, NULL);
+		if (err == 0)
+			err = -EINTR;
+		return err;
 	}
+
+	return inet_diag_get_exact(skb, nlh);
 }
 
 static void inet_diag_rcv(struct sock *sk, int len)
 {
-	struct sk_buff *skb;
-	unsigned int qlen = skb_queue_len(&sk->sk_receive_queue);
+	unsigned int qlen = 0;
 
-	while (qlen-- && (skb = skb_dequeue(&sk->sk_receive_queue))) {
-		inet_diag_rcv_skb(skb);
-		kfree_skb(skb);
-	}
+	do {
+		netlink_run_queue(sk, &qlen, &inet_diag_rcv_msg);
+	} while (qlen);
 }
 
 static DEFINE_SPINLOCK(inet_diag_register_lock);

--

