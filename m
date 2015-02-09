From: Eyal Birger <eyal.birger@gmail.com>
Subject: [PATCH net-next 1/3] net: Rename sock_recv_ts_and_drops() to sock_cmsg_recv()
Date: Mon,  9 Feb 2015 20:15:21 +0200
Message-ID: <1423505723-2281-2-git-send-email-eyal.birger@gmail.com>
References: <1423505723-2281-1-git-send-email-eyal.birger@gmail.com>
Cc: edumazet@google.com, netdev@vger.kernel.org,
	Eyal Birger <eyal.birger@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:43409 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933674AbbBISPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 13:15:41 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so2951396wiv.2
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 10:15:40 -0800 (PST)
In-Reply-To: <1423505723-2281-1-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sock_recv_ts_and_drops() - as its name suggests - allows receiving timestamp
information and drop statistics.
Generalize the function name in preparation for adding additional ancillary
information.

Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
---
 include/net/sock.h           | 6 +++---
 net/atm/common.c             | 2 +-
 net/bluetooth/af_bluetooth.c | 4 ++--
 net/can/bcm.c                | 2 +-
 net/can/raw.c                | 2 +-
 net/ieee802154/socket.c      | 4 ++--
 net/ipv4/raw.c               | 2 +-
 net/ipv4/udp.c               | 2 +-
 net/ipv6/raw.c               | 2 +-
 net/ipv6/udp.c               | 2 +-
 net/key/af_key.c             | 2 +-
 net/packet/af_packet.c       | 2 +-
 net/rxrpc/ar-recvmsg.c       | 2 +-
 net/sctp/socket.c            | 2 +-
 net/socket.c                 | 6 +++---
 15 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index e138245..412cab78 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2113,10 +2113,10 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 		__sock_recv_wifi_status(msg, sk, skb);
 }
 
-void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
+void __sock_cmsg_recv(struct msghdr *msg, struct sock *sk,
 			      struct sk_buff *skb);
 
-static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
+static inline void sock_cmsg_recv(struct msghdr *msg, struct sock *sk,
 					  struct sk_buff *skb)
 {
 #define FLAGS_TS_OR_DROPS ((1UL << SOCK_RXQ_OVFL)			| \
@@ -2125,7 +2125,7 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 			   SOF_TIMESTAMPING_RAW_HARDWARE)
 
 	if (sk->sk_flags & FLAGS_TS_OR_DROPS || sk->sk_tsflags & TSFLAGS_ANY)
-		__sock_recv_ts_and_drops(msg, sk, skb);
+		__sock_cmsg_recv(msg, sk, skb);
 	else
 		sk->sk_stamp = skb->tstamp;
 }
diff --git a/net/atm/common.c b/net/atm/common.c
index b84057e..611b1c2 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -557,7 +557,7 @@ int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	error = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (error)
 		return error;
-	sock_recv_ts_and_drops(msg, sk, skb);
+	sock_cmsg_recv(msg, sk, skb);
 
 	if (!(flags & MSG_PEEK)) {
 		pr_debug("%d -= %d\n", atomic_read(&sk->sk_rmem_alloc),
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index ce22e0c..4bdcbc9 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -241,7 +241,7 @@ int bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	skb_reset_transport_header(skb);
 	err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (err == 0) {
-		sock_recv_ts_and_drops(msg, sk, skb);
+		sock_cmsg_recv(msg, sk, skb);
 
 		if (bt_sk(sk)->skb_msg_name)
 			bt_sk(sk)->skb_msg_name(skb, msg->msg_name,
@@ -339,7 +339,7 @@ int bt_sock_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 		copied += chunk;
 		size   -= chunk;
 
-		sock_recv_ts_and_drops(msg, sk, skb);
+		sock_cmsg_recv(msg, sk, skb);
 
 		if (!(flags & MSG_PEEK)) {
 			int skb_len = skb_headlen(skb);
diff --git a/net/can/bcm.c b/net/can/bcm.c
index ee9ffd9..f741f29 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1559,7 +1559,7 @@ static int bcm_recvmsg(struct kiocb *iocb, struct socket *sock,
 		return err;
 	}
 
-	sock_recv_ts_and_drops(msg, sk, skb);
+	sock_cmsg_recv(msg, sk, skb);
 
 	if (msg->msg_name) {
 		__sockaddr_check_size(sizeof(struct sockaddr_can));
diff --git a/net/can/raw.c b/net/can/raw.c
index 00c13ef..549b871 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -754,7 +754,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct socket *sock,
 		return err;
 	}
 
-	sock_recv_ts_and_drops(msg, sk, skb);
+	sock_cmsg_recv(msg, sk, skb);
 
 	if (msg->msg_name) {
 		__sockaddr_check_size(sizeof(struct sockaddr_can));
diff --git a/net/ieee802154/socket.c b/net/ieee802154/socket.c
index 2878d8c..41ac5fa 100644
--- a/net/ieee802154/socket.c
+++ b/net/ieee802154/socket.c
@@ -348,7 +348,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (err)
 		goto done;
 
-	sock_recv_ts_and_drops(msg, sk, skb);
+	sock_cmsg_recv(msg, sk, skb);
 
 	if (flags & MSG_TRUNC)
 		copied = skb->len;
@@ -739,7 +739,7 @@ static int dgram_recvmsg(struct kiocb *iocb, struct sock *sk,
 	if (err)
 		goto done;
 
-	sock_recv_ts_and_drops(msg, sk, skb);
+	sock_cmsg_recv(msg, sk, skb);
 
 	if (saddr) {
 		saddr->family = AF_IEEE802154;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index f027a70..a28a83b 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -740,7 +740,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (err)
 		goto done;
 
-	sock_recv_ts_and_drops(msg, sk, skb);
+	sock_cmsg_recv(msg, sk, skb);
 
 	/* Copy the address. */
 	if (sin) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 97ef1f8b..07b1394 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1318,7 +1318,7 @@ try_again:
 		UDP_INC_STATS_USER(sock_net(sk),
 				UDP_MIB_INDATAGRAMS, is_udplite);
 
-	sock_recv_ts_and_drops(msg, sk, skb);
+	sock_cmsg_recv(msg, sk, skb);
 
 	/* Copy the address. */
 	if (sin) {
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index dae7f1a..882c997 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -510,7 +510,7 @@ static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 		*addr_len = sizeof(*sin6);
 	}
 
-	sock_recv_ts_and_drops(msg, sk, skb);
+	sock_cmsg_recv(msg, sk, skb);
 
 	if (np->rxopt.all)
 		ip6_datagram_recv_ctl(sk, msg, skb);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d048d46..be0cfae 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -469,7 +469,7 @@ try_again:
 					UDP_MIB_INDATAGRAMS, is_udplite);
 	}
 
-	sock_recv_ts_and_drops(msg, sk, skb);
+	sock_cmsg_recv(msg, sk, skb);
 
 	/* Copy the address. */
 	if (msg->msg_name) {
diff --git a/net/key/af_key.c b/net/key/af_key.c
index f8ac939..e03ba49 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3658,7 +3658,7 @@ static int pfkey_recvmsg(struct kiocb *kiocb,
 	if (err)
 		goto out_free;
 
-	sock_recv_ts_and_drops(msg, sk, skb);
+	sock_cmsg_recv(msg, sk, skb);
 
 	err = (flags & MSG_TRUNC) ? skb->len : copied;
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9c28cec..6033520 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2982,7 +2982,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (err)
 		goto out_free;
 
-	sock_recv_ts_and_drops(msg, sk, skb);
+	sock_cmsg_recv(msg, sk, skb);
 
 	if (msg->msg_name) {
 		/* If the address length field is there to be filled
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index 4575485..323b1c7 100644
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -150,7 +150,7 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
 				       &call->conn->trans->peer->srx, len);
 				msg->msg_namelen = len;
 			}
-			sock_recv_ts_and_drops(msg, &rx->sk, skb);
+			sock_cmsg_recv(msg, &rx->sk, skb);
 		}
 
 		/* receive the message */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index aafe94b..27835aa 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2108,7 +2108,7 @@ static int sctp_recvmsg(struct kiocb *iocb, struct sock *sk,
 	if (err)
 		goto out_free;
 
-	sock_recv_ts_and_drops(msg, sk, skb);
+	sock_cmsg_recv(msg, sk, skb);
 	if (sctp_ulpevent_is_notification(event)) {
 		msg->msg_flags |= MSG_NOTIFICATION;
 		sp->pf->event_msgname(event, msg->msg_name, addr_len);
diff --git a/net/socket.c b/net/socket.c
index bbedbfc..17be338 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -736,13 +736,13 @@ static inline void sock_recv_drops(struct msghdr *msg, struct sock *sk,
 			sizeof(__u32), &skb->dropcount);
 }
 
-void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
-	struct sk_buff *skb)
+void __sock_cmsg_recv(struct msghdr *msg, struct sock *sk,
+		      struct sk_buff *skb)
 {
 	sock_recv_timestamp(msg, sk, skb);
 	sock_recv_drops(msg, sk, skb);
 }
-EXPORT_SYMBOL_GPL(__sock_recv_ts_and_drops);
+EXPORT_SYMBOL_GPL(__sock_cmsg_recv);
 
 static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
 				       struct msghdr *msg, size_t size, int flags)
-- 
2.1.4
