From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 3/6] net: fixes for skb_send_sock
Date: Thu, 03 Aug 2017 16:37:36 -0700
Message-ID: <20170803233736.12107.95453.stgit@john-Precision-Tower-5810>
References: <20170803232443.12107.24752.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: davem@davemloft.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:38910 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbdHCXhu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 19:37:50 -0400
Received: by mail-pf0-f193.google.com with SMTP id h75so159602pfh.5
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 16:37:50 -0700 (PDT)
In-Reply-To: <20170803232443.12107.24752.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple fixes to new skb_send_sock infrastructure. However, no users
currently exist for this code (adding user in next handful of patches)
so it should not be possible to trigger a panic with in-kernel code.

Fixes: 306b13eb3cf9 ("proto_ops: Add locked held versions of sendmsg and sendpage")
Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 net/core/skbuff.c |    2 +-
 net/socket.c      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 0f0933b..a0504a5 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2011,7 +2011,7 @@ int skb_send_sock_locked(struct sock *sk, struct sk_buff *skb, int offset,
 
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
 
