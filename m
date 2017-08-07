From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v3 net-next 1/5] proto_ops: Fixes to adding locked version of sendmsg/page
Date: Mon,  7 Aug 2017 10:28:14 -0700
Message-ID: <20170807172818.31855-2-tom@quantonium.net>
References: <20170807172818.31855-1-tom@quantonium.net>
Cc: rohit@quantonium.net, davejwatson@fb.com, john.fastabend@gmail.com,
        Tom Herbert <tom@quantonium.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:37304 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751869AbdHGR2t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 13:28:49 -0400
Received: by mail-pg0-f48.google.com with SMTP id y129so4105075pgy.4
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 10:28:49 -0700 (PDT)
In-Reply-To: <20170807172818.31855-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes for two issues pointed out by John Fastabend.

Fixes: 306b13eb3cf9515a ("proto_ops: Add locked held versions of sendmsg and sendpage")
Reported-by: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 net/core/skbuff.c | 2 +-
 net/socket.c      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 42b62c716a33..e3bac9f74789 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2285,7 +2285,7 @@ int skb_send_sock_locked(struct sock *sk, struct sk_buff *skb, int offset,
 
 		slen = min_t(int, len, skb_headlen(skb) - offset);
 		kv.iov_base = skb->data + offset;
-		kv.iov_len = len;
+		kv.iov_len = slen;
 		memset(&msg, 0, sizeof(msg));
 
 		ret = kernel_sendmsg_locked(sk, &msg, &kv, 1, slen);
diff --git a/net/socket.c b/net/socket.c
index b332d1e8e4e4..c729625eb5d3 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -658,7 +658,7 @@ int kernel_sendmsg_locked(struct sock *sk, struct msghdr *msg,
 	struct socket *sock = sk->sk_socket;
 
 	if (!sock->ops->sendmsg_locked)
-		sock_no_sendmsg_locked(sk, msg, size);
+		return sock_no_sendmsg_locked(sk, msg, size);
 
 	iov_iter_kvec(&msg->msg_iter, WRITE | ITER_KVEC, vec, num, size);
 
-- 
2.11.0
