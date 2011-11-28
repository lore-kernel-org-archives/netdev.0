From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: tcp_sendmsg() wrong access to sk_route_caps
Date: Mon, 28 Nov 2011 11:27:47 +0100
Message-ID: <1322476067.2292.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:61176 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048Ab1K1K1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 05:27:50 -0500
Received: by qadc14 with SMTP id c14so1024528qad.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 02:27:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now sk_route_caps is u64, its dangerous to use an integer to store
result of an AND operator. It wont work if NETIF_F_SG is moved on the
upper part of u64.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/ipv4/tcp.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 50c3596..ecbc89a 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -891,7 +891,7 @@ EXPORT_SYMBOL(tcp_sendpage);
 #define TCP_PAGE(sk)	(sk->sk_sndmsg_page)
 #define TCP_OFF(sk)	(sk->sk_sndmsg_off)
=20
-static inline int select_size(const struct sock *sk, int sg)
+static inline int select_size(const struct sock *sk, bool sg)
 {
 	const struct tcp_sock *tp =3D tcp_sk(sk);
 	int tmp =3D tp->mss_cache;
@@ -917,9 +917,9 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk=
, struct msghdr *msg,
 	struct iovec *iov;
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
-	int iovlen, flags;
+	int iovlen, flags, err, copied;
 	int mss_now, size_goal;
-	int sg, err, copied;
+	bool sg;
 	long timeo;
=20
 	lock_sock(sk);
@@ -946,7 +946,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk=
, struct msghdr *msg,
 	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
 		goto out_err;
=20
-	sg =3D sk->sk_route_caps & NETIF_F_SG;
+	sg =3D !!(sk->sk_route_caps & NETIF_F_SG);
=20
 	while (--iovlen >=3D 0) {
 		size_t seglen =3D iov->iov_len;
