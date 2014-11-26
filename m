From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net] net-timestamp: make tcp_recvmsg call ipv6_recv_error for AF_INET6 socks
Date: Wed, 26 Nov 2014 14:53:02 -0500
Message-ID: <1417031582-16480-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:44727 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbaKZTxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 14:53:20 -0500
Received: by mail-yk0-f176.google.com with SMTP id q200so1587856ykb.35
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 11:53:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

TCP timestamping introduced MSG_ERRQUEUE handling for TCP sockets.
If the socket is of family AF_INET6, call ipv6_recv_error instead
of ip_recv_error.

This change is more complex than a single branch due to the loadable
ipv6 module. It reuses a pre-existing indirect function call from
ping. The ping code is safe to call, because it is part of the core
ipv6 module and always present when AF_INET6 sockets are active.

Signed-off-by: Willem de Bruijn <willemb@google.com>

----

It may also be worthwhile to add WARN_ON_ONCE(sk->family == AF_INET6)
to ip_recv_error.
---
 include/net/inet_common.h |  2 ++
 net/ipv4/af_inet.c        | 11 +++++++++++
 net/ipv4/ping.c           | 12 ++----------
 net/ipv4/tcp.c            |  2 +-
 4 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index fe7994c..b2828a0 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -37,6 +37,8 @@ int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
 int inet_ctl_sock_create(struct sock **sk, unsigned short family,
 			 unsigned short type, unsigned char protocol,
 			 struct net *net);
+int inet_recv_error(struct sock *sk, struct msghdr *msg, int len,
+		    int *addr_len);
 
 static inline void inet_ctl_sock_destroy(struct sock *sk)
 {
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8b7fe5b..e67da4e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1386,6 +1386,17 @@ out:
 	return pp;
 }
 
+int inet_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
+{
+	if (sk->sk_family == AF_INET)
+		return ip_recv_error(sk, msg, len, addr_len);
+#if IS_ENABLED(CONFIG_IPV6)
+	if (sk->sk_family == AF_INET6)
+		return pingv6_ops.ipv6_recv_error(sk, msg, len, addr_len);
+#endif
+	return -EINVAL;
+}
+
 static int inet_gro_complete(struct sk_buff *skb, int nhoff)
 {
 	__be16 newlen = htons(skb->len - nhoff);
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 85a02a7..5d740cc 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -855,16 +855,8 @@ int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (flags & MSG_OOB)
 		goto out;
 
-	if (flags & MSG_ERRQUEUE) {
-		if (family == AF_INET) {
-			return ip_recv_error(sk, msg, len, addr_len);
-#if IS_ENABLED(CONFIG_IPV6)
-		} else if (family == AF_INET6) {
-			return pingv6_ops.ipv6_recv_error(sk, msg, len,
-							  addr_len);
-#endif
-		}
-	}
+	if (flags & MSG_ERRQUEUE)
+		return inet_recv_error(sk, msg, len, addr_len);
 
 	skb = skb_recv_datagram(sk, flags, noblock, &err);
 	if (!skb)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 39ec0c3..38c2bcb 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1598,7 +1598,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	u32 urg_hole = 0;
 
 	if (unlikely(flags & MSG_ERRQUEUE))
-		return ip_recv_error(sk, msg, len, addr_len);
+		return inet_recv_error(sk, msg, len, addr_len);
 
 	if (sk_can_busy_loop(sk) && skb_queue_empty(&sk->sk_receive_queue) &&
 	    (sk->sk_state == TCP_ESTABLISHED))
-- 
2.2.0.rc0.207.ga3a616c
