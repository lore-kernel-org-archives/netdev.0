From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: dont drop MTU reduction indications
Date: Mon, 23 Jul 2012 09:48:52 +0200
Message-ID: <1343029732.2626.10234.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Tore Anderson <tore@fud.no>, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63943 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753926Ab2GWHs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 03:48:57 -0400
Received: by bkwj10 with SMTP id j10so4876598bkw.19
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 00:48:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

ICMP messages generated in output path if frame length is bigger than
mtu are actually lost because socket is owned by user (doing the xmit)

One example is the ipgre_tunnel_xmit() calling=20
icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));

We had a similar case fixed in commit a34a101e1e6 (ipv6: disable GSO on
sockets hitting dst_allfrag).

Problem of such fix is that it relied on retransmit timers, so short tc=
p
sessions paid a too big latency increase price.

This patch uses the tcp_release_cb() infrastructure so that MTU
reduction messages (ICMP messages) are not lost, and no extra delay
is added in TCP transmits.

Reported-by: Maciej =C5=BBenczykowski <maze@google.com>
Diagnosed-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Tore Anderson <tore@fud.no>
---
 include/linux/tcp.h   |    6 ++++++
 include/net/sock.h    |    1 +
 net/ipv4/tcp_ipv4.c   |   19 +++++++++++++++----
 net/ipv4/tcp_output.c |    6 +++++-
 net/ipv6/tcp_ipv6.c   |   40 ++++++++++++++++++++++++----------------
 5 files changed, 51 insertions(+), 21 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 2761856..eb125a4 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -493,6 +493,9 @@ struct tcp_sock {
 		u32		  probe_seq_start;
 		u32		  probe_seq_end;
 	} mtu_probe;
+	u32	mtu_info; /* We received an ICMP_FRAG_NEEDED / ICMPV6_PKT_TOOBIG
+			   * while socket was owned by user.
+			   */
=20
 #ifdef CONFIG_TCP_MD5SIG
 /* TCP AF-Specific parts; only used by MD5 Signature support so far */
@@ -518,6 +521,9 @@ enum tsq_flags {
 	TCP_TSQ_DEFERRED,	   /* tcp_tasklet_func() found socket was owned */
 	TCP_WRITE_TIMER_DEFERRED,  /* tcp_write_timer() found socket was owne=
d */
 	TCP_DELACK_TIMER_DEFERRED, /* tcp_delack_timer() found socket was own=
ed */
+	TCP_MTU_REDUCED_DEFERRED,  /* tcp_v{4|6}_err() could not call
+				    * tcp_v{4|6}_mtu_reduced()
+				    */
 };
=20
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
diff --git a/include/net/sock.h b/include/net/sock.h
index 88de092..e067f8c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -859,6 +859,7 @@ struct proto {
 						struct sk_buff *skb);
=20
 	void		(*release_cb)(struct sock *sk);
+	void		(*mtu_reduced)(struct sock *sk);
=20
 	/* Keeping track of sk's, looking them up, and port selection methods=
=2E */
 	void			(*hash)(struct sock *sk);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 59110ca..bc5432e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -275,12 +275,15 @@ failure:
 EXPORT_SYMBOL(tcp_v4_connect);
=20
 /*
- * This routine does path mtu discovery as defined in RFC1191.
+ * This routine reacts to ICMP_FRAG_NEEDED mtu indications as defined =
in RFC1191.
+ * It can be called through tcp_release_cb() if socket was owned by us=
er
+ * at the time tcp_v4_err() was called to handle ICMP message.
  */
-static void do_pmtu_discovery(struct sock *sk, const struct iphdr *iph=
, u32 mtu)
+static void tcp_v4_mtu_reduced(struct sock *sk)
 {
 	struct dst_entry *dst;
 	struct inet_sock *inet =3D inet_sk(sk);
+	u32 mtu =3D tcp_sk(sk)->mtu_info;
=20
 	/* We are not interested in TCP_LISTEN and open_requests (SYN-ACKs
 	 * send out by Linux are always <576bytes so they should go through
@@ -373,8 +376,12 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info=
)
 	bh_lock_sock(sk);
 	/* If too many ICMPs get dropped on busy
 	 * servers this needs to be solved differently.
+	 * We do take care of PMTU discovery (RFC1191) special case :
+	 * we can receive locally generated ICMP messages while socket is hel=
d.
 	 */
-	if (sock_owned_by_user(sk))
+	if (sock_owned_by_user(sk) &&
+	    type !=3D ICMP_DEST_UNREACH &&
+	    code !=3D ICMP_FRAG_NEEDED)
 		NET_INC_STATS_BH(net, LINUX_MIB_LOCKDROPPEDICMPS);
=20
 	if (sk->sk_state =3D=3D TCP_CLOSE)
@@ -409,8 +416,11 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info=
)
 			goto out;
=20
 		if (code =3D=3D ICMP_FRAG_NEEDED) { /* PMTU discovery (RFC1191) */
+			tp->mtu_info =3D info;
 			if (!sock_owned_by_user(sk))
-				do_pmtu_discovery(sk, iph, info);
+				tcp_v4_mtu_reduced(sk);
+			else
+				set_bit(TCP_MTU_REDUCED_DEFERRED, &tp->tsq_flags);
 			goto out;
 		}
=20
@@ -2596,6 +2606,7 @@ struct proto tcp_prot =3D {
 	.sendpage		=3D tcp_sendpage,
 	.backlog_rcv		=3D tcp_v4_do_rcv,
 	.release_cb		=3D tcp_release_cb,
+	.mtu_reduced		=3D tcp_v4_mtu_reduced,
 	.hash			=3D inet_hash,
 	.unhash			=3D inet_unhash,
 	.get_port		=3D inet_csk_get_port,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 950aebf..33cd065 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -885,7 +885,8 @@ static void tcp_tasklet_func(unsigned long data)
=20
 #define TCP_DEFERRED_ALL ((1UL << TCP_TSQ_DEFERRED) |		\
 			  (1UL << TCP_WRITE_TIMER_DEFERRED) |	\
-			  (1UL << TCP_DELACK_TIMER_DEFERRED))
+			  (1UL << TCP_DELACK_TIMER_DEFERRED) |	\
+			  (1UL << TCP_MTU_REDUCED_DEFERRED))
 /**
  * tcp_release_cb - tcp release_sock() callback
  * @sk: socket
@@ -914,6 +915,9 @@ void tcp_release_cb(struct sock *sk)
=20
 	if (flags & (1UL << TCP_DELACK_TIMER_DEFERRED))
 		tcp_delack_timer_handler(sk);
+
+	if (flags & (1UL << TCP_MTU_REDUCED_DEFERRED))
+		sk->sk_prot->mtu_reduced(sk);
 }
 EXPORT_SYMBOL(tcp_release_cb);
=20
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 0302ec3..f49476e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -315,6 +315,23 @@ failure:
 	return err;
 }
=20
+static void tcp_v6_mtu_reduced(struct sock *sk)
+{
+	struct dst_entry *dst;
+
+	if ((1 << sk->sk_state) & (TCPF_LISTEN | TCPF_CLOSE))
+		return;
+
+	dst =3D inet6_csk_update_pmtu(sk, tcp_sk(sk)->mtu_info);
+	if (!dst)
+		return;
+
+	if (inet_csk(sk)->icsk_pmtu_cookie > dst_mtu(dst)) {
+		tcp_sync_mss(sk, dst_mtu(dst));
+		tcp_simple_retransmit(sk);
+	}
+}
+
 static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt=
,
 		u8 type, u8 code, int offset, __be32 info)
 {
@@ -342,7 +359,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct =
inet6_skb_parm *opt,
 	}
=20
 	bh_lock_sock(sk);
-	if (sock_owned_by_user(sk))
+	if (sock_owned_by_user(sk) && type !=3D ICMPV6_PKT_TOOBIG)
 		NET_INC_STATS_BH(net, LINUX_MIB_LOCKDROPPEDICMPS);
=20
 	if (sk->sk_state =3D=3D TCP_CLOSE)
@@ -371,21 +388,11 @@ static void tcp_v6_err(struct sk_buff *skb, struc=
t inet6_skb_parm *opt,
 	}
=20
 	if (type =3D=3D ICMPV6_PKT_TOOBIG) {
-		struct dst_entry *dst;
-
-		if (sock_owned_by_user(sk))
-			goto out;
-		if ((1 << sk->sk_state) & (TCPF_LISTEN | TCPF_CLOSE))
-			goto out;
-
-		dst =3D inet6_csk_update_pmtu(sk, ntohl(info));
-		if (!dst)
-			goto out;
-
-		if (inet_csk(sk)->icsk_pmtu_cookie > dst_mtu(dst)) {
-			tcp_sync_mss(sk, dst_mtu(dst));
-			tcp_simple_retransmit(sk);
-		}
+		tp->mtu_info =3D ntohl(info);
+		if (!sock_owned_by_user(sk))
+			tcp_v6_mtu_reduced(sk);
+		else
+			set_bit(TCP_MTU_REDUCED_DEFERRED, &tp->tsq_flags);
 		goto out;
 	}
=20
@@ -1949,6 +1956,7 @@ struct proto tcpv6_prot =3D {
 	.sendpage		=3D tcp_sendpage,
 	.backlog_rcv		=3D tcp_v6_do_rcv,
 	.release_cb		=3D tcp_release_cb,
+	.mtu_reduced		=3D tcp_v6_mtu_reduced,
 	.hash			=3D tcp_v6_hash,
 	.unhash			=3D inet_unhash,
 	.get_port		=3D inet_csk_get_port,
