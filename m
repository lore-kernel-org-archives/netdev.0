From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 1/2 net-next] net: add a limit parameter to sk_add_backlog()
Date: Mon, 23 Apr 2012 11:34:26 +0200
Message-ID: <1335173666.3293.78.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Rick Jones <rick.jones2@hp.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54264 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754415Ab2DWJeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 05:34:31 -0400
Received: by bkcik5 with SMTP id ik5so8413239bkc.19
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 02:34:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

sk_add_backlog() & sk_rcvqueues_full() hard coded sk_rcvbuf as the
memory limit. We need to make this limit a parameter for TCP use.

No functional change expected in this patch, all callers still using th=
e
old sk_rcvbuf limit.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Rick Jones <rick.jones2@hp.com>
---
 include/net/sock.h  |   10 ++++++----
 net/core/sock.c     |    4 ++--
 net/ipv4/tcp_ipv4.c |    2 +-
 net/ipv4/udp.c      |    4 ++--
 net/ipv6/tcp_ipv6.c |    2 +-
 net/ipv6/udp.c      |    8 ++++----
 net/llc/llc_conn.c  |    2 +-
 net/sctp/input.c    |    4 ++--
 net/tipc/socket.c   |    2 +-
 net/x25/x25_dev.c   |    2 +-
 10 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 4cdb9b3..4e9d01e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -709,17 +709,19 @@ static inline void __sk_add_backlog(struct sock *=
sk, struct sk_buff *skb)
  * Do not take into account this skb truesize,
  * to allow even a single big packet to come.
  */
-static inline bool sk_rcvqueues_full(const struct sock *sk, const stru=
ct sk_buff *skb)
+static inline bool sk_rcvqueues_full(const struct sock *sk, const stru=
ct sk_buff *skb,
+				     unsigned int limit)
 {
 	unsigned int qsize =3D sk->sk_backlog.len + atomic_read(&sk->sk_rmem_=
alloc);
=20
-	return qsize > sk->sk_rcvbuf;
+	return qsize > limit;
 }
=20
 /* The per-socket spinlock must be held here. */
-static inline __must_check int sk_add_backlog(struct sock *sk, struct =
sk_buff *skb)
+static inline __must_check int sk_add_backlog(struct sock *sk, struct =
sk_buff *skb,
+					      unsigned int limit)
 {
-	if (sk_rcvqueues_full(sk, skb))
+	if (sk_rcvqueues_full(sk, skb, limit))
 		return -ENOBUFS;
=20
 	__sk_add_backlog(sk, skb);
diff --git a/net/core/sock.c b/net/core/sock.c
index 679c5bb..0431aaf 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -389,7 +389,7 @@ int sk_receive_skb(struct sock *sk, struct sk_buff =
*skb, const int nested)
=20
 	skb->dev =3D NULL;
=20
-	if (sk_rcvqueues_full(sk, skb)) {
+	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf)) {
 		atomic_inc(&sk->sk_drops);
 		goto discard_and_relse;
 	}
@@ -406,7 +406,7 @@ int sk_receive_skb(struct sock *sk, struct sk_buff =
*skb, const int nested)
 		rc =3D sk_backlog_rcv(sk, skb);
=20
 		mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
-	} else if (sk_add_backlog(sk, skb)) {
+	} else if (sk_add_backlog(sk, skb, sk->sk_rcvbuf)) {
 		bh_unlock_sock(sk);
 		atomic_inc(&sk->sk_drops);
 		goto discard_and_relse;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0883921..917607e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1752,7 +1752,7 @@ process:
 			if (!tcp_prequeue(sk, skb))
 				ret =3D tcp_v4_do_rcv(sk, skb);
 		}
-	} else if (unlikely(sk_add_backlog(sk, skb))) {
+	} else if (unlikely(sk_add_backlog(sk, skb, sk->sk_rcvbuf))) {
 		bh_unlock_sock(sk);
 		NET_INC_STATS_BH(net, LINUX_MIB_TCPBACKLOGDROP);
 		goto discard_and_relse;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 3430e8f..279fd08 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1479,7 +1479,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_=
buff *skb)
 		goto drop;
=20
=20
-	if (sk_rcvqueues_full(sk, skb))
+	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf))
 		goto drop;
=20
 	rc =3D 0;
@@ -1488,7 +1488,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_=
buff *skb)
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk))
 		rc =3D __udp_queue_rcv_skb(sk, skb);
-	else if (sk_add_backlog(sk, skb)) {
+	else if (sk_add_backlog(sk, skb, sk->sk_rcvbuf)) {
 		bh_unlock_sock(sk);
 		goto drop;
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 8044f6a..b04e6d8 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1654,7 +1654,7 @@ process:
 			if (!tcp_prequeue(sk, skb))
 				ret =3D tcp_v6_do_rcv(sk, skb);
 		}
-	} else if (unlikely(sk_add_backlog(sk, skb))) {
+	} else if (unlikely(sk_add_backlog(sk, skb, sk->sk_rcvbuf))) {
 		bh_unlock_sock(sk);
 		NET_INC_STATS_BH(net, LINUX_MIB_TCPBACKLOGDROP);
 		goto discard_and_relse;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 37b0699..d39bbc9 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -611,14 +611,14 @@ static void flush_stack(struct sock **stack, unsi=
gned int count,
=20
 		sk =3D stack[i];
 		if (skb1) {
-			if (sk_rcvqueues_full(sk, skb1)) {
+			if (sk_rcvqueues_full(sk, skb1, sk->sk_rcvbuf)) {
 				kfree_skb(skb1);
 				goto drop;
 			}
 			bh_lock_sock(sk);
 			if (!sock_owned_by_user(sk))
 				udpv6_queue_rcv_skb(sk, skb1);
-			else if (sk_add_backlog(sk, skb1)) {
+			else if (sk_add_backlog(sk, skb1, sk->sk_rcvbuf)) {
 				kfree_skb(skb1);
 				bh_unlock_sock(sk);
 				goto drop;
@@ -790,14 +790,14 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct ud=
p_table *udptable,
=20
 	/* deliver */
=20
-	if (sk_rcvqueues_full(sk, skb)) {
+	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf)) {
 		sock_put(sk);
 		goto discard;
 	}
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk))
 		udpv6_queue_rcv_skb(sk, skb);
-	else if (sk_add_backlog(sk, skb)) {
+	else if (sk_add_backlog(sk, skb, sk->sk_rcvbuf)) {
 		atomic_inc(&sk->sk_drops);
 		bh_unlock_sock(sk);
 		sock_put(sk);
diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index ba137a6..0d0d416 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -828,7 +828,7 @@ void llc_conn_handler(struct llc_sap *sap, struct s=
k_buff *skb)
 	else {
 		dprintk("%s: adding to backlog...\n", __func__);
 		llc_set_backlog_type(skb, LLC_PACKET);
-		if (sk_add_backlog(sk, skb))
+		if (sk_add_backlog(sk, skb, sk->sk_rcvbuf))
 			goto drop_unlock;
 	}
 out:
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 80f71af..80564fe 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -342,7 +342,7 @@ int sctp_backlog_rcv(struct sock *sk, struct sk_buf=
f *skb)
 		sctp_bh_lock_sock(sk);
=20
 		if (sock_owned_by_user(sk)) {
-			if (sk_add_backlog(sk, skb))
+			if (sk_add_backlog(sk, skb, sk->sk_rcvbuf))
 				sctp_chunk_free(chunk);
 			else
 				backloged =3D 1;
@@ -376,7 +376,7 @@ static int sctp_add_backlog(struct sock *sk, struct=
 sk_buff *skb)
 	struct sctp_ep_common *rcvr =3D chunk->rcvr;
 	int ret;
=20
-	ret =3D sk_add_backlog(sk, skb);
+	ret =3D sk_add_backlog(sk, skb, sk->sk_rcvbuf);
 	if (!ret) {
 		/* Hold the assoc/ep while hanging on the backlog queue.
 		 * This way, we know structures we need will not disappear
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index c19fc4a..6d4991e 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1330,7 +1330,7 @@ static u32 dispatch(struct tipc_port *tport, stru=
ct sk_buff *buf)
 	if (!sock_owned_by_user(sk)) {
 		res =3D filter_rcv(sk, buf);
 	} else {
-		if (sk_add_backlog(sk, buf))
+		if (sk_add_backlog(sk, buf, sk->sk_rcvbuf))
 			res =3D TIPC_ERR_OVERLOAD;
 		else
 			res =3D TIPC_OK;
diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
index f0ce862..a8a2363 100644
--- a/net/x25/x25_dev.c
+++ b/net/x25/x25_dev.c
@@ -58,7 +58,7 @@ static int x25_receive_data(struct sk_buff *skb, stru=
ct x25_neigh *nb)
 		if (!sock_owned_by_user(sk)) {
 			queued =3D x25_process_rx_frame(sk, skb);
 		} else {
-			queued =3D !sk_add_backlog(sk, skb);
+			queued =3D !sk_add_backlog(sk, skb, sk->sk_rcvbuf);
 		}
 		bh_unlock_sock(sk);
 		sock_put(sk);
