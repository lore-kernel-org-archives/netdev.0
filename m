From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: speedup sock_recv_ts_and_drops()
Date: Thu, 29 Apr 2010 07:14:43 +0200
Message-ID: <1272518083.2201.119.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:56152 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757723Ab0D3SIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:08:15 -0400
Received: by bwz19 with SMTP id 19so293875bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 11:08:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sock_recv_ts_and_drops() is fat and slow (~ 4% of cpu time on some
profiles)

We can test all socket flags at once to make fast path fast again.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h |   19 ++++++++++++++++++-
 net/socket.c       |    4 ++--
 2 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index d361c77..e1777db 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1635,7 +1635,24 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 		sk->sk_stamp = kt;
 }
 
-extern void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk, struct sk_buff *skb);
+extern void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
+				     struct sk_buff *skb);
+
+static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
+					  struct sk_buff *skb)
+{
+#define FLAGS_TS_OR_DROPS ((1UL << SOCK_RXQ_OVFL)			| \
+			   (1UL << SOCK_RCVTSTAMP)			| \
+			   (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE)	| \
+			   (1UL << SOCK_TIMESTAMPING_SOFTWARE)		| \
+			   (1UL << SOCK_TIMESTAMPING_RAW_HARDWARE) 	| \
+			   (1UL << SOCK_TIMESTAMPING_SYS_HARDWARE))
+
+	if (sk->sk_flags & FLAGS_TS_OR_DROPS)
+		__sock_recv_ts_and_drops(msg, sk, skb);
+	else
+		sk->sk_stamp = skb->tstamp;
+}
 
 /**
  * sock_tx_timestamp - checks whether the outgoing packet is to be time stamped
diff --git a/net/socket.c b/net/socket.c
index 9822081..cb7c1f6 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -655,13 +655,13 @@ inline void sock_recv_drops(struct msghdr *msg, struct sock *sk, struct sk_buff
 			sizeof(__u32), &skb->dropcount);
 }
 
-void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
+void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 	struct sk_buff *skb)
 {
 	sock_recv_timestamp(msg, sk, skb);
 	sock_recv_drops(msg, sk, skb);
 }
-EXPORT_SYMBOL_GPL(sock_recv_ts_and_drops);
+EXPORT_SYMBOL_GPL(__sock_recv_ts_and_drops);
 
 static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
 				       struct msghdr *msg, size_t size, int flags)


