From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 03/10] net: fixes for skb_send_sock
Date: Tue, 15 Aug 2017 22:31:34 -0700
Message-ID: <20170816053134.15445.4546.stgit@john-Precision-Tower-5810>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, john.fastabend@gmail.com,
        tom@herbertland.com
To: davem@davemloft.net, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:38598 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750912AbdHPFbw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 01:31:52 -0400
Received: by mail-pf0-f196.google.com with SMTP id h75so423234pfh.5
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 22:31:51 -0700 (PDT)
In-Reply-To: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple fixes to new skb_send_sock infrastructure. However, no users
currently exist for this code (adding user in next handful of patches)
so it should not be possible to trigger a panic with existing in-kernel
code.

Fixes: 306b13eb3cf9 ("proto_ops: Add locked held versions of sendmsg and sendpage")
Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 net/core/skbuff.c |    2 +-
 net/socket.c      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index cb12359..917da73 100644
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
index b332d1e..c729625 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -658,7 +658,7 @@ int kernel_sendmsg_locked(struct sock *sk, struct msghdr *msg,
 	struct socket *sock = sk->sk_socket;
 
 	if (!sock->ops->sendmsg_locked)
-		sock_no_sendmsg_locked(sk, msg, size);
+		return sock_no_sendmsg_locked(sk, msg, size);
 
 	iov_iter_kvec(&msg->msg_iter, WRITE | ITER_KVEC, vec, num, size);
 
