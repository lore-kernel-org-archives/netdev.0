From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v2] net-timestamp: optimize sock_tx_timestamp default path
Date: Mon,  8 Sep 2014 19:58:58 -0400
Message-ID: <1410220738-6395-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f201.google.com ([209.85.213.201]:54624 "EHLO
	mail-ig0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753651AbaIIAEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 20:04:39 -0400
Received: by mail-ig0-f201.google.com with SMTP id h3so2722090igd.4
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 17:04:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Few packets have timestamping enabled. Exit sock_tx_timestamp quickly
in this common case.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/net/sock.h | 10 +++++++++-
 net/socket.c       |  7 ++-----
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 049ab1b..515a4d0 100644
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
@@ -2206,7 +2208,13 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
  *
  * Note : callers should take care of initial *tx_flags value (usually 0)
  */
-void sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags);
+static inline void sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags)
+{
+	if (unlikely(sk->sk_tsflags))
+		__sock_tx_timestamp(sk, tx_flags);
+	if (unlikely(sock_flag(sk, SOCK_WIFI_STATUS)))
+		*tx_flags |= SKBTX_WIFI_STATUS;
+}
 
 /**
  * sk_eat_skb - Release a skb if it is no longer needed
diff --git a/net/socket.c b/net/socket.c
index 2e2586e..d40f522 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -610,7 +610,7 @@ void sock_release(struct socket *sock)
 }
 EXPORT_SYMBOL(sock_release);
 
-void sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags)
+void __sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags)
 {
 	u8 flags = *tx_flags;
 
@@ -626,12 +626,9 @@ void sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags)
 	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_ACK)
 		flags |= SKBTX_ACK_TSTAMP;
 
-	if (sock_flag(sk, SOCK_WIFI_STATUS))
-		flags |= SKBTX_WIFI_STATUS;
-
 	*tx_flags = flags;
 }
-EXPORT_SYMBOL(sock_tx_timestamp);
+EXPORT_SYMBOL(__sock_tx_timestamp);
 
 static inline int __sock_sendmsg_nosec(struct kiocb *iocb, struct socket *sock,
 				       struct msghdr *msg, size_t size)
-- 
2.1.0.rc2.206.gedb03e5
