From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH v4 3/4] net: diag: Support SOCK_DESTROY for inet sockets.
Date: Tue,  1 Dec 2015 16:04:25 +0900
Message-ID: <1448953466-132321-3-git-send-email-lorenzo@google.com>
References: <1448953466-132321-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	eric.dumazet@gmail.com, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36783 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755029AbbLAHEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 02:04:46 -0500
Received: by pacdm15 with SMTP id dm15so212368796pac.3
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 23:04:45 -0800 (PST)
In-Reply-To: <1448953466-132321-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This passes the SOCK_DESTROY operation to the underlying
protocol diag handler, or returns -EINVAL if that handler does
not define a destroy operation.

Most of this patch is just renaming functions. This is not
strictly necessary, but it would be fairly counterintuitive to
have the code to destroy inet sockets be in a function whose name
starts with inet_diag_get.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/linux/inet_diag.h |  4 ++++
 net/ipv4/inet_diag.c      | 23 +++++++++++++++--------
 2 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index e7032f04..7c27fa1 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -24,6 +24,10 @@ struct inet_diag_handler {
 	void		(*idiag_get_info)(struct sock *sk,
 					  struct inet_diag_msg *r,
 					  void *info);
+
+	int		(*destroy)(struct sk_buff *in_skb,
+				   const struct inet_diag_req_v2 *req);
+
 	__u16		idiag_type;
 	__u16		idiag_info_size;
 };
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index cfabb8f..8bb8e7a 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -426,7 +426,7 @@ out:
 }
 EXPORT_SYMBOL_GPL(inet_diag_dump_one_icsk);
 
-static int inet_diag_get_exact(struct sk_buff *in_skb,
+static int inet_diag_cmd_exact(int cmd, struct sk_buff *in_skb,
 			       const struct nlmsghdr *nlh,
 			       const struct inet_diag_req_v2 *req)
 {
@@ -436,8 +436,12 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
 	handler = inet_diag_lock_handler(req->sdiag_protocol);
 	if (IS_ERR(handler))
 		err = PTR_ERR(handler);
-	else
+	else if (cmd == SOCK_DIAG_BY_FAMILY)
 		err = handler->dump_one(in_skb, nlh, req);
+	else if (cmd == SOCK_DESTROY && handler->destroy)
+		err = handler->destroy(in_skb, req);
+	else
+		err = -EOPNOTSUPP;
 	inet_diag_unlock_handler(handler);
 
 	return err;
@@ -950,7 +954,7 @@ static int inet_diag_get_exact_compat(struct sk_buff *in_skb,
 	req.idiag_states = rc->idiag_states;
 	req.id = rc->id;
 
-	return inet_diag_get_exact(in_skb, nlh, &req);
+	return inet_diag_cmd_exact(SOCK_DIAG_BY_FAMILY, in_skb, nlh, &req);
 }
 
 static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
@@ -984,7 +988,7 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 	return inet_diag_get_exact_compat(skb, nlh);
 }
 
-static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
+static int inet_diag_handler_cmd(struct sk_buff *skb, struct nlmsghdr *h)
 {
 	int hdrlen = sizeof(struct inet_diag_req_v2);
 	struct net *net = sock_net(skb->sk);
@@ -992,7 +996,8 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 	if (nlmsg_len(h) < hdrlen)
 		return -EINVAL;
 
-	if (h->nlmsg_flags & NLM_F_DUMP) {
+	if (h->nlmsg_type == SOCK_DIAG_BY_FAMILY &&
+	    h->nlmsg_flags & NLM_F_DUMP) {
 		if (nlmsg_attrlen(h, hdrlen)) {
 			struct nlattr *attr;
 
@@ -1011,7 +1016,7 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 		}
 	}
 
-	return inet_diag_get_exact(skb, h, nlmsg_data(h));
+	return inet_diag_cmd_exact(h->nlmsg_type, skb, h, nlmsg_data(h));
 }
 
 static
@@ -1062,14 +1067,16 @@ int inet_diag_handler_get_info(struct sk_buff *skb, struct sock *sk)
 
 static const struct sock_diag_handler inet_diag_handler = {
 	.family = AF_INET,
-	.dump = inet_diag_handler_dump,
+	.dump = inet_diag_handler_cmd,
 	.get_info = inet_diag_handler_get_info,
+	.destroy = inet_diag_handler_cmd,
 };
 
 static const struct sock_diag_handler inet6_diag_handler = {
 	.family = AF_INET6,
-	.dump = inet_diag_handler_dump,
+	.dump = inet_diag_handler_cmd,
 	.get_info = inet_diag_handler_get_info,
+	.destroy = inet_diag_handler_cmd,
 };
 
 int inet_diag_register(const struct inet_diag_handler *h)
-- 
2.6.0.rc2.230.g3dd15c0
