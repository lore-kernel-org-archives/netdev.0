From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] net-timestamp: optimize sock_tx_timestamp default path
Date: Mon,  8 Sep 2014 19:27:04 -0400
Message-ID: <1410218824-18296-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:64378 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755009AbaIHX1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 19:27:10 -0400
Received: by mail-ob0-f202.google.com with SMTP id wp18so2700130obc.5
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 16:27:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Few packets have timestamping enabled. Exit sock_tx_timestamp quickly
in this common case.

Packets are only possibly timestamped if one of
SOF_TIMESTAMPING_(SOFTWARE|RAW_HARDWARE) is enabled.

Signed-off-by: Willem de Bruijn <willemb@google.com>

----

I have one more short timestamping patch after this, to remove
SOCK_TIMESTAMPING_RX_SOFTWARE and simplify the receive timestamp
path a bit. I have not forgotten about the timestamp cookies: once
these smaller changes are in, I'll take another look at that. It
is a more complex change, and I didn't want to block these in the
meantime.
---
 include/net/sock.h | 8 +++++++-
 net/socket.c       | 4 ++--
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 049ab1b..245136e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2199,6 +2199,8 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 		sk->sk_stamp = skb->tstamp;
 }
 
+void __sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags);
+
 /**
  * sock_tx_timestamp - checks whether the outgoing packet is to be time stamped
  * @sk:		socket sending this packet
@@ -2206,7 +2208,11 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
  *
  * Note : callers should take care of initial *tx_flags value (usually 0)
  */
-void sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags);
+static inline void sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags)
+{
+	if (unlikely(sk->sk_tsflags & SOF_TIMESTAMPING_MASK))
+		__sock_tx_timestamp(sk, tx_flags);
+}
 
 /**
  * sk_eat_skb - Release a skb if it is no longer needed
diff --git a/net/socket.c b/net/socket.c
index 2e2586e..2d1c2c8 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -610,7 +610,7 @@ void sock_release(struct socket *sock)
 }
 EXPORT_SYMBOL(sock_release);
 
-void sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags)
+void __sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags)
 {
 	u8 flags = *tx_flags;
 
@@ -631,7 +631,7 @@ void sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags)
 
 	*tx_flags = flags;
 }
-EXPORT_SYMBOL(sock_tx_timestamp);
+EXPORT_SYMBOL(__sock_tx_timestamp);
 
 static inline int __sock_sendmsg_nosec(struct kiocb *iocb, struct socket *sock,
 				       struct msghdr *msg, size_t size)
-- 
2.1.0.rc2.206.gedb03e5
