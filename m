From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: sock: make sock_tx_timestamp void
Date: Sun, 14 Apr 2013 20:08:13 +0200
Message-ID: <2856df883c4653d360c44718151f37682621b577.1365962139.git.dborkman@redhat.com>
References: <cover.1365962139.git.dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52143 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752208Ab3DNSIY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Apr 2013 14:08:24 -0400
In-Reply-To: <cover.1365962139.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, sock_tx_timestamp() always returns 0. The comment that
describes the sock_tx_timestamp() function wrongly says that it
returns an error when an invalid argument is passed (from commit
20d4947353be, ``net: socket infrastructure for SO_TIMESTAMPING'').
Make the function void, so that we can also remove all the unneeded
if conditions that check for such a _non-existant_ error case in the
output path.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sock.h     |  5 ++---
 net/can/raw.c          |  5 ++---
 net/ipv4/ping.c        |  5 ++---
 net/ipv4/udp.c         |  6 +++---
 net/ipv6/ip6_output.c  |  7 ++-----
 net/packet/af_packet.c | 10 ++++------
 net/socket.c           |  3 +--
 7 files changed, 16 insertions(+), 25 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 08f05f9..5c97b0f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2159,10 +2159,9 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
  * @sk:		socket sending this packet
  * @tx_flags:	filled with instructions for time stamping
  *
- * Currently only depends on SOCK_TIMESTAMPING* flags. Returns error code if
- * parameters are invalid.
+ * Currently only depends on SOCK_TIMESTAMPING* flags.
  */
-extern int sock_tx_timestamp(struct sock *sk, __u8 *tx_flags);
+extern void sock_tx_timestamp(struct sock *sk, __u8 *tx_flags);
 
 /**
  * sk_eat_skb - Release a skb if it is no longer needed
diff --git a/net/can/raw.c b/net/can/raw.c
index c1764e4..1085e65 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -711,9 +711,8 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
 	if (err < 0)
 		goto free_skb;
-	err = sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
-	if (err < 0)
-		goto free_skb;
+
+	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
 
 	skb->dev = dev;
 	skb->sk  = sk;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 2e91006..7d93d62 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -514,9 +514,8 @@ static int ping_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.opt = NULL;
 	ipc.oif = sk->sk_bound_dev_if;
 	ipc.tx_flags = 0;
-	err = sock_tx_timestamp(sk, &ipc.tx_flags);
-	if (err)
-		return err;
+
+	sock_tx_timestamp(sk, &ipc.tx_flags);
 
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7117d14..2722db0 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -902,9 +902,9 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.addr = inet->inet_saddr;
 
 	ipc.oif = sk->sk_bound_dev_if;
-	err = sock_tx_timestamp(sk, &ipc.tx_flags);
-	if (err)
-		return err;
+
+	sock_tx_timestamp(sk, &ipc.tx_flags);
+
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
 		if (err)
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 155eccf..d2eedf1 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1224,11 +1224,8 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	}
 
 	/* For UDP, check if TX timestamp is enabled */
-	if (sk->sk_type == SOCK_DGRAM) {
-		err = sock_tx_timestamp(sk, &tx_flags);
-		if (err)
-			goto error;
-	}
+	if (sk->sk_type == SOCK_DGRAM)
+		sock_tx_timestamp(sk, &tx_flags);
 
 	/*
 	 * Let's try using as much space as possible.
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 8e4644f..77d71f8 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1505,9 +1505,8 @@ retry:
 	skb->dev = dev;
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
-	err = sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
-	if (err < 0)
-		goto out_unlock;
+
+	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
 
 	if (unlikely(extra_len == 4))
 		skb->no_fcs = 1;
@@ -2312,9 +2311,8 @@ static int packet_snd(struct socket *sock,
 	err = skb_copy_datagram_from_iovec(skb, offset, msg->msg_iov, 0, len);
 	if (err)
 		goto out_free;
-	err = sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
-	if (err < 0)
-		goto out_free;
+
+	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
 
 	if (!gso_type && (len > dev->mtu + reserve + extra_len)) {
 		/* Earlier code assumed this would be a VLAN pkt,
diff --git a/net/socket.c b/net/socket.c
index 88f759a..36883fe 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -600,7 +600,7 @@ void sock_release(struct socket *sock)
 }
 EXPORT_SYMBOL(sock_release);
 
-int sock_tx_timestamp(struct sock *sk, __u8 *tx_flags)
+void sock_tx_timestamp(struct sock *sk, __u8 *tx_flags)
 {
 	*tx_flags = 0;
 	if (sock_flag(sk, SOCK_TIMESTAMPING_TX_HARDWARE))
@@ -609,7 +609,6 @@ int sock_tx_timestamp(struct sock *sk, __u8 *tx_flags)
 		*tx_flags |= SKBTX_SW_TSTAMP;
 	if (sock_flag(sk, SOCK_WIFI_STATUS))
 		*tx_flags |= SKBTX_WIFI_STATUS;
-	return 0;
 }
 EXPORT_SYMBOL(sock_tx_timestamp);
 
-- 
1.7.11.7
