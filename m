From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netlink: autosize skb lengthes
Date: Fri, 07 Mar 2014 12:02:33 -0800
Message-ID: <1394222553.20149.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:60508 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbaCGUCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 15:02:35 -0500
Received: by mail-pb0-f41.google.com with SMTP id jt11so4609507pbb.14
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2014 12:02:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

One known problem with netlink is the fact that NLMSG_GOODSIZE is
really small on PAGE_SIZE==4096 architectures, and it is difficult
to know in advance what buffer size is used by the application.

This patch adds an automatic learning of the size.

First netlink message will still be limited to ~4K, but if user used
bigger buffers, then following messages will be able to use up to 16KB.

This speedups dump() operations by a large factor and should be safe
for legacy applications.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Thomas Graf <tgraf@suug.ch>
---
Google-Bug-Id: 13305844

 net/netlink/af_netlink.c |   27 ++++++++++++++++++++++++++-
 net/netlink/af_netlink.h |    1 +
 2 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 9db8bab27fa2..c2d585c4f7c5 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2343,6 +2343,11 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 	}
 #endif
 
+	/* Record the max length of recvmsg() calls for future allocations */
+	nlk->max_recvmsg_len = max(nlk->max_recvmsg_len, len);
+	nlk->max_recvmsg_len = min_t(size_t, nlk->max_recvmsg_len,
+				     16384);
+
 	copied = data_skb->len;
 	if (len < copied) {
 		msg->msg_flags |= MSG_TRUNC;
@@ -2587,7 +2592,27 @@ static int netlink_dump(struct sock *sk)
 	if (!netlink_rx_is_mmaped(sk) &&
 	    atomic_read(&sk->sk_rmem_alloc) >= sk->sk_rcvbuf)
 		goto errout_skb;
-	skb = netlink_alloc_skb(sk, alloc_size, nlk->portid, GFP_KERNEL);
+
+	/* NLMSG_GOODSIZE is small to avoid high order allocations being
+	 * required, but it makes sense to _attempt_ a 16K bytes allocation
+	 * to reduce number of system calls on dump operations, if user
+	 * ever provided a big enough buffer.
+	 */
+	if (alloc_size < nlk->max_recvmsg_len) {
+		skb = netlink_alloc_skb(sk,
+					nlk->max_recvmsg_len,
+					nlk->portid,
+					GFP_KERNEL |
+					__GFP_NOWARN |
+					__GFP_NORETRY);
+		/* available room should be exact amount to avoid MSG_TRUNC */
+		if (skb)
+			skb_reserve(skb, skb_tailroom(skb) -
+					 nlk->max_recvmsg_len);
+	}
+	if (!skb)
+		skb = netlink_alloc_skb(sk, alloc_size, nlk->portid,
+					GFP_KERNEL);
 	if (!skb)
 		goto errout_skb;
 	netlink_skb_set_owner_r(skb, sk);
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index acbd774eeb7c..ed13a790b00e 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -31,6 +31,7 @@ struct netlink_sock {
 	u32			ngroups;
 	unsigned long		*groups;
 	unsigned long		state;
+	size_t			max_recvmsg_len;
 	wait_queue_head_t	wait;
 	bool			cb_running;
 	struct netlink_callback	cb;
