From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/9] [NETLINK]: Convert core netlink handling to new netlink api
Date: Sat, 05 Aug 2006 00:00:02 +0200
Message-ID: <20060805003535.811223323@postel.suug.ch>
References: <20060805003452.493542515@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:5101 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1422675AbWHEAnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 20:43:09 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_af
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes a theoretical memory and locking leak when the size of
the netlink header would exceed the skb tailroom.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/net/netlink/af_netlink.c
===================================================================
--- net-2.6.19.orig/net/netlink/af_netlink.c
+++ net-2.6.19/net/netlink/af_netlink.c
@@ -1147,7 +1147,7 @@ static int netlink_sendmsg(struct kiocb 
 	if (len > sk->sk_sndbuf - 32)
 		goto out;
 	err = -ENOBUFS;
-	skb = alloc_skb(len, GFP_KERNEL);
+	skb = nlmsg_new(len, GFP_KERNEL);
 	if (skb==NULL)
 		goto out;
 
@@ -1342,19 +1342,18 @@ static int netlink_dump(struct sock *sk)
 	struct netlink_callback *cb;
 	struct sk_buff *skb;
 	struct nlmsghdr *nlh;
-	int len;
+	int len, err = -ENOBUFS;
 	
 	skb = sock_rmalloc(sk, NLMSG_GOODSIZE, 0, GFP_KERNEL);
 	if (!skb)
-		return -ENOBUFS;
+		goto errout;
 
 	spin_lock(&nlk->cb_lock);
 
 	cb = nlk->cb;
 	if (cb == NULL) {
-		spin_unlock(&nlk->cb_lock);
-		kfree_skb(skb);
-		return -EINVAL;
+		err = -EINVAL;
+		goto errout_skb;
 	}
 
 	len = cb->dump(skb, cb);
@@ -1366,8 +1365,12 @@ static int netlink_dump(struct sock *sk)
 		return 0;
 	}
 
-	nlh = NLMSG_NEW_ANSWER(skb, cb, NLMSG_DONE, sizeof(len), NLM_F_MULTI);
-	memcpy(NLMSG_DATA(nlh), &len, sizeof(len));
+	nlh = nlmsg_put_answer(skb, cb, NLMSG_DONE, sizeof(len), NLM_F_MULTI);
+	if (!nlh)
+		goto errout_skb;
+
+	memcpy(nlmsg_data(nlh), &len, sizeof(len));
+
 	skb_queue_tail(&sk->sk_receive_queue, skb);
 	sk->sk_data_ready(sk, skb->len);
 
@@ -1379,8 +1382,11 @@ static int netlink_dump(struct sock *sk)
 	netlink_destroy_callback(cb);
 	return 0;
 
-nlmsg_failure:
-	return -ENOBUFS;
+errout_skb:
+	spin_unlock(&nlk->cb_lock);
+	kfree_skb(skb);
+errout:
+	return err;
 }
 
 int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
@@ -1432,11 +1438,11 @@ void netlink_ack(struct sk_buff *in_skb,
 	int size;
 
 	if (err == 0)
-		size = NLMSG_SPACE(sizeof(struct nlmsgerr));
+		size = nlmsg_total_size(sizeof(*errmsg));
 	else
-		size = NLMSG_SPACE(4 + NLMSG_ALIGN(nlh->nlmsg_len));
+		size = nlmsg_total_size(sizeof(*errmsg) + nlmsg_len(nlh));
 
-	skb = alloc_skb(size, GFP_KERNEL);
+	skb = nlmsg_new(size, GFP_KERNEL);
 	if (!skb) {
 		struct sock *sk;
 
@@ -1452,16 +1458,15 @@ void netlink_ack(struct sk_buff *in_skb,
 
 	rep = __nlmsg_put(skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
 			  NLMSG_ERROR, sizeof(struct nlmsgerr), 0);
-	errmsg = NLMSG_DATA(rep);
+	errmsg = nlmsg_data(rep);
 	errmsg->error = err;
-	memcpy(&errmsg->msg, nlh, err ? nlh->nlmsg_len : sizeof(struct nlmsghdr));
+	memcpy(&errmsg->msg, nlh, err ? nlh->nlmsg_len : sizeof(*nlh));
 	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
 }
 
 static int netlink_rcv_skb(struct sk_buff *skb, int (*cb)(struct sk_buff *,
 						     struct nlmsghdr *, int *))
 {
-	unsigned int total_len;
 	struct nlmsghdr *nlh;
 	int err;
 
@@ -1471,8 +1476,6 @@ static int netlink_rcv_skb(struct sk_buf
 		if (nlh->nlmsg_len < NLMSG_HDRLEN || skb->len < nlh->nlmsg_len)
 			return 0;
 
-		total_len = min(NLMSG_ALIGN(nlh->nlmsg_len), skb->len);
-
 		if (cb(skb, nlh, &err) < 0) {
 			/* Not an error, but we have to interrupt processing
 			 * here. Note: that in this case we do not pull
@@ -1484,7 +1487,7 @@ static int netlink_rcv_skb(struct sk_buf
 		} else if (nlh->nlmsg_flags & NLM_F_ACK)
 			netlink_ack(skb, nlh, 0);
 
-		skb_pull(skb, total_len);
+		netlink_queue_skip(nlh, skb);
 	}
 
 	return 0;

