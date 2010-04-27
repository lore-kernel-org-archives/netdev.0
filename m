From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Tue, 27 Apr 2010 14:59:04 -0700 (PDT)
Message-ID: <20100427.145904.67907652.davem@davemloft.net>
References: <1271709121.3845.94.camel@edumazet-laptop>
	<20100419.141947.129754682.davem@davemloft.net>
	<1272271271.2346.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43277
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754879Ab0D0V67 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 17:58:59 -0400
In-Reply-To: <1272271271.2346.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 26 Apr 2010 10:41:11 +0200

> Le lundi 19 avril 2010 =E0 14:19 -0700, David Miller a =E9crit :
>=20
>>=20
>> I was thinking also about how we could compute rxhash in the
>> loopback driver :-)
>=20
> This would be easy if rxhash was not a "struct inet_sock" field but a
> "struct sock" one
>=20
> sock_alloc_send_pskb() (or skb_set_owner_w())
>=20
> skb->rxhash =3D sk->rxhash;

Agreed.  I'll commit the following to net-next-2.6 after some build
testing.

net: Make RFS socket operations not be inet specific.

Idea from Eric Dumazet.

As for placement inside of struct sock, I tried to choose a place
that otherwise has a 32-bit hole on 64-bit systems.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index c1d4295..1653de5 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -102,7 +102,6 @@ struct rtable;
  * @uc_ttl - Unicast TTL
  * @inet_sport - Source port
  * @inet_id - ID counter for DF pkts
- * @rxhash - flow hash received from netif layer
  * @tos - TOS
  * @mc_ttl - Multicasting TTL
  * @is_icsk - is this an inet_connection_sock?
@@ -126,9 +125,6 @@ struct inet_sock {
 	__u16			cmsg_flags;
 	__be16			inet_sport;
 	__u16			inet_id;
-#ifdef CONFIG_RPS
-	__u32			rxhash;
-#endif
=20
 	struct ip_options	*opt;
 	__u8			tos;
@@ -224,37 +220,4 @@ static inline __u8 inet_sk_flowi_flags(const struc=
t sock *sk)
 	return inet_sk(sk)->transparent ? FLOWI_FLAG_ANYSRC : 0;
 }
=20
-static inline void inet_rps_record_flow(const struct sock *sk)
-{
-#ifdef CONFIG_RPS
-	struct rps_sock_flow_table *sock_flow_table;
-
-	rcu_read_lock();
-	sock_flow_table =3D rcu_dereference(rps_sock_flow_table);
-	rps_record_sock_flow(sock_flow_table, inet_sk(sk)->rxhash);
-	rcu_read_unlock();
-#endif
-}
-
-static inline void inet_rps_reset_flow(const struct sock *sk)
-{
-#ifdef CONFIG_RPS
-	struct rps_sock_flow_table *sock_flow_table;
-
-	rcu_read_lock();
-	sock_flow_table =3D rcu_dereference(rps_sock_flow_table);
-	rps_reset_sock_flow(sock_flow_table, inet_sk(sk)->rxhash);
-	rcu_read_unlock();
-#endif
-}
-
-static inline void inet_rps_save_rxhash(struct sock *sk, u32 rxhash)
-{
-#ifdef CONFIG_RPS
-	if (unlikely(inet_sk(sk)->rxhash !=3D rxhash)) {
-		inet_rps_reset_flow(sk);
-		inet_sk(sk)->rxhash =3D rxhash;
-	}
-#endif
-}
 #endif	/* _INET_SOCK_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index ef2f875..cf12b1e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -198,6 +198,7 @@ struct sock_common {
   *	@sk_rcvlowat: %SO_RCVLOWAT setting
   *	@sk_rcvtimeo: %SO_RCVTIMEO setting
   *	@sk_sndtimeo: %SO_SNDTIMEO setting
+  *	@sk_rxhash: flow hash received from netif layer
   *	@sk_filter: socket filtering instructions
   *	@sk_protinfo: private area, net family specific, when not using sl=
ab
   *	@sk_timer: sock cleanup timer
@@ -278,6 +279,9 @@ struct sock {
 	int			sk_gso_type;
 	unsigned int		sk_gso_max_size;
 	int			sk_rcvlowat;
+#ifdef CONFIG_RPS
+	__u32			sk_rxhash;
+#endif
 	unsigned long 		sk_flags;
 	unsigned long	        sk_lingertime;
 	struct sk_buff_head	sk_error_queue;
@@ -629,6 +633,40 @@ static inline int sk_backlog_rcv(struct sock *sk, =
struct sk_buff *skb)
 	return sk->sk_backlog_rcv(sk, skb);
 }
=20
+static inline void sock_rps_record_flow(const struct sock *sk)
+{
+#ifdef CONFIG_RPS
+	struct rps_sock_flow_table *sock_flow_table;
+
+	rcu_read_lock();
+	sock_flow_table =3D rcu_dereference(rps_sock_flow_table);
+	rps_record_sock_flow(sock_flow_table, sk->sk_rxhash);
+	rcu_read_unlock();
+#endif
+}
+
+static inline void sock_rps_reset_flow(const struct sock *sk)
+{
+#ifdef CONFIG_RPS
+	struct rps_sock_flow_table *sock_flow_table;
+
+	rcu_read_lock();
+	sock_flow_table =3D rcu_dereference(rps_sock_flow_table);
+	rps_reset_sock_flow(sock_flow_table, sk->sk_rxhash);
+	rcu_read_unlock();
+#endif
+}
+
+static inline void sock_rps_save_rxhash(struct sock *sk, u32 rxhash)
+{
+#ifdef CONFIG_RPS
+	if (unlikely(sk->sk_rxhash !=3D rxhash)) {
+		sock_rps_reset_flow(sk);
+		sk->sk_rxhash =3D rxhash;
+	}
+#endif
+}
+
 #define sk_wait_event(__sk, __timeo, __condition)			\
 	({	int __rc;						\
 		release_sock(__sk);					\
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9f52880..c6c43bc 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -419,7 +419,7 @@ int inet_release(struct socket *sock)
 	if (sk) {
 		long timeout;
=20
-		inet_rps_reset_flow(sk);
+		sock_rps_reset_flow(sk);
=20
 		/* Applications forget to leave groups before exiting */
 		ip_mc_drop_socket(sk);
@@ -722,7 +722,7 @@ int inet_sendmsg(struct kiocb *iocb, struct socket =
*sock, struct msghdr *msg,
 {
 	struct sock *sk =3D sock->sk;
=20
-	inet_rps_record_flow(sk);
+	sock_rps_record_flow(sk);
=20
 	/* We may need to bind the socket. */
 	if (!inet_sk(sk)->inet_num && inet_autobind(sk))
@@ -737,7 +737,7 @@ static ssize_t inet_sendpage(struct socket *sock, s=
truct page *page, int offset,
 {
 	struct sock *sk =3D sock->sk;
=20
-	inet_rps_record_flow(sk);
+	sock_rps_record_flow(sk);
=20
 	/* We may need to bind the socket. */
 	if (!inet_sk(sk)->inet_num && inet_autobind(sk))
@@ -755,7 +755,7 @@ int inet_recvmsg(struct kiocb *iocb, struct socket =
*sock, struct msghdr *msg,
 	int addr_len =3D 0;
 	int err;
=20
-	inet_rps_record_flow(sk);
+	sock_rps_record_flow(sk);
=20
 	err =3D sk->sk_prot->recvmsg(iocb, sk, msg, size, flags & MSG_DONTWAI=
T,
 				   flags & ~MSG_DONTWAIT, &addr_len);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4d6717d..771f814 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1672,7 +1672,7 @@ process:
=20
 	skb->dev =3D NULL;
=20
-	inet_rps_save_rxhash(sk, skb->rxhash);
+	sock_rps_save_rxhash(sk, skb->rxhash);
=20
 	bh_lock_sock_nested(sk);
 	ret =3D 0;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 776c844..63eb56b 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1217,7 +1217,7 @@ int udp_disconnect(struct sock *sk, int flags)
 	sk->sk_state =3D TCP_CLOSE;
 	inet->inet_daddr =3D 0;
 	inet->inet_dport =3D 0;
-	inet_rps_save_rxhash(sk, 0);
+	sock_rps_save_rxhash(sk, 0);
 	sk->sk_bound_dev_if =3D 0;
 	if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK))
 		inet_reset_saddr(sk);
@@ -1262,7 +1262,7 @@ static int __udp_queue_rcv_skb(struct sock *sk, s=
truct sk_buff *skb)
 	int rc;
=20
 	if (inet_sk(sk)->inet_daddr)
-		inet_rps_save_rxhash(sk, skb->rxhash);
+		sock_rps_save_rxhash(sk, skb->rxhash);
=20
 	rc =3D sock_queue_rcv_skb(sk, skb);
 	if (rc < 0) {
