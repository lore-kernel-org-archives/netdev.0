From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH 3/4] net: diag: Support SOCK_DESTROY for inet sockets.
Date: Wed, 18 Nov 2015 10:43:43 +0900
Message-ID: <1447811024-8553-4-git-send-email-lorenzo@google.com>
References: <1447811024-8553-1-git-send-email-lorenzo@google.com>
Cc: edumazet@google.com, ek@google.com, maze@google.com,
	dtor@google.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35507 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755165AbbKRBoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 20:44:18 -0500
Received: by pacej9 with SMTP id ej9so26802468pac.2
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 17:44:17 -0800 (PST)
In-Reply-To: <1447811024-8553-1-git-send-email-lorenzo@google.com>
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
index a4c7ef4..cacbd8b 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -425,7 +425,7 @@ out:
 }
 EXPORT_SYMBOL_GPL(inet_diag_dump_one_icsk);
 
-static int inet_diag_get_exact(struct sk_buff *in_skb,
+static int inet_diag_cmd_exact(int cmd, struct sk_buff *in_skb,
 			       const struct nlmsghdr *nlh,
 			       const struct inet_diag_req_v2 *req)
 {
@@ -435,8 +435,12 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
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
@@ -949,7 +953,7 @@ static int inet_diag_get_exact_compat(struct sk_buff *in_skb,
 	req.idiag_states = rc->idiag_states;
 	req.id = rc->id;
 
-	return inet_diag_get_exact(in_skb, nlh, &req);
+	return inet_diag_cmd_exact(SOCK_DIAG_BY_FAMILY, in_skb, nlh, &req);
 }
 
 static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
@@ -983,7 +987,7 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 	return inet_diag_get_exact_compat(skb, nlh);
 }
 
-static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
+static int inet_diag_handler_cmd(struct sk_buff *skb, struct nlmsghdr *h)
 {
 	int hdrlen = sizeof(struct inet_diag_req_v2);
 	struct net *net = sock_net(skb->sk);
@@ -991,7 +995,8 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 	if (nlmsg_len(h) < hdrlen)
 		return -EINVAL;
 
-	if (h->nlmsg_flags & NLM_F_DUMP) {
+	if (h->nlmsg_type == SOCK_DIAG_BY_FAMILY &&
+	    h->nlmsg_flags & NLM_F_DUMP) {
 		if (nlmsg_attrlen(h, hdrlen)) {
 			struct nlattr *attr;
 
@@ -1010,7 +1015,7 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 		}
 	}
 
-	return inet_diag_get_exact(skb, h, nlmsg_data(h));
+	return inet_diag_cmd_exact(h->nlmsg_type, skb, h, nlmsg_data(h));
 }
 
 static
@@ -1061,14 +1066,16 @@ int inet_diag_handler_get_info(struct sk_buff *skb, struct sock *sk)
 
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
