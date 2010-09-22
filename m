From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix a lockdep splat
Date: Thu, 23 Sep 2010 00:43:39 +0200
Message-ID: <1285195419.2380.39.camel@edumazet-laptop>
References: <201006242053.IAG26562.JHQFFOMSVFtOLO@I-love.SAKURA.ne.jp>
	 <201009072132.FHA93457.MHOJFQOOFLVStF@I-love.SAKURA.ne.jp>
	 <201009210651.o8L6pbkP038129@www262.sakura.ne.jp>
	 <1285055760.2617.27.camel@edumazet-laptop>
	 <201009210910.o8L9Anaf071504@www262.sakura.ne.jp>
	 <1285061757.2617.176.camel@edumazet-laptop>
	 <1285064011.2617.238.camel@edumazet-laptop>
	 <201009220714.o8M7Ebps067361@www262.sakura.ne.jp>
	 <1285144306.2639.90.camel@edumazet-laptop>
	 <1285144471.2639.96.camel@edumazet-laptop>
	 <1285144681.2639.102.camel@edumazet-laptop>
	 <201009220858.o8M8w8s3094017@www262.sakura.ne.jp>
	 <1285176935.2639.453.camel@edumazet-laptop>
	 <1285184088.2380.18.camel@edumazet-laptop>  <4C9A7F7F.5010507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	David Miller <davem@davemloft.net>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37788 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365Ab0IVWnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 18:43:47 -0400
In-Reply-To: <4C9A7F7F.5010507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 23 septembre 2010 =C3=A0 00:13 +0200, Jarek Poplawski a =C3=A9=
crit :
> Eric Dumazet wrote:
> > [PATCH] net: fix a lockdep splat
> >=20
> > We have for each socket :
> >=20
> > One spinlock (sk_slock.slock)
> > One rwlock (sk_callback_lock)
> >=20
> > Possible scenarios are :
> >=20
> > (A) (this is used in net/sunrpc/xprtsock.c)
> > read_lock(&sk->sk_callback_lock) (without blocking BH)
> > <BH>
> > spin_lock(&sk->sk_slock.slock);
> > ...
> > read_lock(&sk->sk_callback_lock);
> > ...
> >=20
> >=20
> > (B)
> > write_lock_bh(&sk->sk_callback_lock)
> > stuff
> > write_unlock_bh(&sk->sk_callback_lock)
> >=20
> >=20
> > (C)
> > spin_lock_bh(&sk->sk_slock)
> > ...
> > write_lock_bh(&sk->sk_callback_lock)
> > stuff
> > write_unlock_bh(&sk->sk_callback_lock)
> > spin_unlock_bh(&sk->sk_slock)
> >=20
> > This (C) case conflicts with (A) :
> >=20
> > CPU1 [A]                         CPU2 [C]
> > read_lock(callback_lock)
> > <BH>                             spin_lock_bh(slock)
> > <wait to spin_lock(slock)>
> >                                  <wait to write_lock_bh(callback_lo=
ck)>
> >=20
> > We have one problematic (C) use case in inet_csk_listen_stop() :
> >=20
> > local_bh_disable();
> > bh_lock_sock(child); // spin_lock_bh(&sk->sk_slock)
> > WARN_ON(sock_owned_by_user(child));
> > ...
> > sock_orphan(child); // write_lock_bh(&sk->sk_callback_lock)
> >=20
> > lockdep is not happy with this, as reported by Tetsuo Handa
> >=20
> > This patch makes sure inet_csk_listen_stop() uses following lock or=
der :
> >=20
> > write_lock_bh(&sk->sk_callback_lock)
> > spin_lock(&sk->sk_slock)
> > ...
> > spin_unlock(&sk->sk_slock)
> > write_unlock_bh(&sk->sk_callback_lock)
>=20
> IMHO this order conflicts with (A) too (but I'm not sure lockdep
> tracks that):
> =20

It should... thats strange I did not hit it in my tests

> CPU1 [A]                         CPU2 [C-reversed]
> ...				write_lock_bh(callback_lock)
> <BH>                            =20
> spin_lock(slock)
> 				<wait to spin_lock(slock)>
> <wait to read_lock(callback_lock)>
>=20


Oh well, you're right. I tried to avoid the _bh everywhere but it seems
buggy too.


> My proposal is to BH protect read_lock(sk_callback_lock) everywhere (=
it's
> done by netfilter in a few places already).
>=20

Yes... its a bit strange we never hit this lockdep splat before...

I tried to track recent changes but really I am mystified ???

Thanks !

[PATCH v2] net: fix a lockdep splat

We have for each socket :

One spinlock (sk_slock.slock)
One rwlock (sk_callback_lock)

Possible scenarios are :

(A) (this is used in net/sunrpc/xprtsock.c)
read_lock(&sk->sk_callback_lock) (without blocking BH)
<BH>
spin_lock(&sk->sk_slock.slock);
=2E..
read_lock(&sk->sk_callback_lock);
=2E..


(B)
write_lock_bh(&sk->sk_callback_lock)
stuff
write_unlock_bh(&sk->sk_callback_lock)


(C)
spin_lock_bh(&sk->sk_slock)
=2E..
write_lock_bh(&sk->sk_callback_lock)
stuff
write_unlock_bh(&sk->sk_callback_lock)
spin_unlock_bh(&sk->sk_slock)

This (C) case conflicts with (A) :

CPU1 [A]                         CPU2 [C]
read_lock(callback_lock)
<BH>                             spin_lock_bh(slock)
<wait to spin_lock(slock)>
                                 <wait to write_lock_bh(callback_lock)>

We have one problematic (C) use case in inet_csk_listen_stop() :

local_bh_disable();
bh_lock_sock(child); // spin_lock_bh(&sk->sk_slock)
WARN_ON(sock_owned_by_user(child));
=2E..
sock_orphan(child); // write_lock_bh(&sk->sk_callback_lock)

lockdep is not happy with this, as reported by Tetsuo Handa

It seems only way to deal with this is to use read_lock_bh(callbacklock=
)
everywhere.

Thanks to Jarek for pointing a bug in my first attempt and suggesting
this solution.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Jarek Poplawski <jarkao2@gmail.com>
---
 net/core/sock.c       |    8 ++++----
 net/rds/tcp_connect.c |    4 ++--
 net/rds/tcp_listen.c  |    4 ++--
 net/rds/tcp_recv.c    |    4 ++--
 net/rds/tcp_send.c    |    4 ++--
 net/sunrpc/xprtsock.c |   28 ++++++++++++++--------------
 6 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index b05b9b6..ef30e9d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1351,9 +1351,9 @@ int sock_i_uid(struct sock *sk)
 {
 	int uid;
=20
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	uid =3D sk->sk_socket ? SOCK_INODE(sk->sk_socket)->i_uid : 0;
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 	return uid;
 }
 EXPORT_SYMBOL(sock_i_uid);
@@ -1362,9 +1362,9 @@ unsigned long sock_i_ino(struct sock *sk)
 {
 	unsigned long ino;
=20
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	ino =3D sk->sk_socket ? SOCK_INODE(sk->sk_socket)->i_ino : 0;
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 	return ino;
 }
 EXPORT_SYMBOL(sock_i_ino);
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index c397524..c519939 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -43,7 +43,7 @@ void rds_tcp_state_change(struct sock *sk)
 	struct rds_connection *conn;
 	struct rds_tcp_connection *tc;
=20
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	conn =3D sk->sk_user_data;
 	if (conn =3D=3D NULL) {
 		state_change =3D sk->sk_state_change;
@@ -68,7 +68,7 @@ void rds_tcp_state_change(struct sock *sk)
 			break;
 	}
 out:
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 	state_change(sk);
 }
=20
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 975183f..27844f2 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -114,7 +114,7 @@ void rds_tcp_listen_data_ready(struct sock *sk, int=
 bytes)
=20
 	rdsdebug("listen data ready sk %p\n", sk);
=20
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	ready =3D sk->sk_user_data;
 	if (ready =3D=3D NULL) { /* check for teardown race */
 		ready =3D sk->sk_data_ready;
@@ -131,7 +131,7 @@ void rds_tcp_listen_data_ready(struct sock *sk, int=
 bytes)
 		queue_work(rds_wq, &rds_tcp_listen_work);
=20
 out:
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 	ready(sk, bytes);
 }
=20
diff --git a/net/rds/tcp_recv.c b/net/rds/tcp_recv.c
index 1aba687..e437974 100644
--- a/net/rds/tcp_recv.c
+++ b/net/rds/tcp_recv.c
@@ -324,7 +324,7 @@ void rds_tcp_data_ready(struct sock *sk, int bytes)
=20
 	rdsdebug("data ready sk %p bytes %d\n", sk, bytes);
=20
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	conn =3D sk->sk_user_data;
 	if (conn =3D=3D NULL) { /* check for teardown race */
 		ready =3D sk->sk_data_ready;
@@ -338,7 +338,7 @@ void rds_tcp_data_ready(struct sock *sk, int bytes)
 	if (rds_tcp_read_sock(conn, GFP_ATOMIC, KM_SOFTIRQ0) =3D=3D -ENOMEM)
 		queue_delayed_work(rds_wq, &conn->c_recv_w, 0);
 out:
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 	ready(sk, bytes);
 }
=20
diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
index a28b895..2f012a0 100644
--- a/net/rds/tcp_send.c
+++ b/net/rds/tcp_send.c
@@ -224,7 +224,7 @@ void rds_tcp_write_space(struct sock *sk)
 	struct rds_connection *conn;
 	struct rds_tcp_connection *tc;
=20
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	conn =3D sk->sk_user_data;
 	if (conn =3D=3D NULL) {
 		write_space =3D sk->sk_write_space;
@@ -244,7 +244,7 @@ void rds_tcp_write_space(struct sock *sk)
 		queue_delayed_work(rds_wq, &conn->c_send_w, 0);
=20
 out:
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
=20
 	/*
 	 * write_space is only called when data leaves tcp's send queue if
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index b6309db..fe9306b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -800,7 +800,7 @@ static void xs_udp_data_ready(struct sock *sk, int =
len)
 	u32 _xid;
 	__be32 *xp;
=20
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	dprintk("RPC:       xs_udp_data_ready...\n");
 	if (!(xprt =3D xprt_from_sock(sk)))
 		goto out;
@@ -852,7 +852,7 @@ static void xs_udp_data_ready(struct sock *sk, int =
len)
  dropit:
 	skb_free_datagram(sk, skb);
  out:
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 }
=20
 static inline void xs_tcp_read_fraghdr(struct rpc_xprt *xprt, struct x=
dr_skb_reader *desc)
@@ -1229,7 +1229,7 @@ static void xs_tcp_data_ready(struct sock *sk, in=
t bytes)
=20
 	dprintk("RPC:       xs_tcp_data_ready...\n");
=20
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	if (!(xprt =3D xprt_from_sock(sk)))
 		goto out;
 	if (xprt->shutdown)
@@ -1248,7 +1248,7 @@ static void xs_tcp_data_ready(struct sock *sk, in=
t bytes)
 		read =3D tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv);
 	} while (read > 0);
 out:
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 }
=20
 /*
@@ -1301,7 +1301,7 @@ static void xs_tcp_state_change(struct sock *sk)
 {
 	struct rpc_xprt *xprt;
=20
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	if (!(xprt =3D xprt_from_sock(sk)))
 		goto out;
 	dprintk("RPC:       xs_tcp_state_change client %p...\n", xprt);
@@ -1313,7 +1313,7 @@ static void xs_tcp_state_change(struct sock *sk)
=20
 	switch (sk->sk_state) {
 	case TCP_ESTABLISHED:
-		spin_lock_bh(&xprt->transport_lock);
+		spin_lock(&xprt->transport_lock);
 		if (!xprt_test_and_set_connected(xprt)) {
 			struct sock_xprt *transport =3D container_of(xprt,
 					struct sock_xprt, xprt);
@@ -1327,7 +1327,7 @@ static void xs_tcp_state_change(struct sock *sk)
=20
 			xprt_wake_pending_tasks(xprt, -EAGAIN);
 		}
-		spin_unlock_bh(&xprt->transport_lock);
+		spin_unlock(&xprt->transport_lock);
 		break;
 	case TCP_FIN_WAIT1:
 		/* The client initiated a shutdown of the socket */
@@ -1365,7 +1365,7 @@ static void xs_tcp_state_change(struct sock *sk)
 		xs_sock_mark_closed(xprt);
 	}
  out:
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 }
=20
 /**
@@ -1376,7 +1376,7 @@ static void xs_error_report(struct sock *sk)
 {
 	struct rpc_xprt *xprt;
=20
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	if (!(xprt =3D xprt_from_sock(sk)))
 		goto out;
 	dprintk("RPC:       %s client %p...\n"
@@ -1384,7 +1384,7 @@ static void xs_error_report(struct sock *sk)
 			__func__, xprt, sk->sk_err);
 	xprt_wake_pending_tasks(xprt, -EAGAIN);
 out:
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 }
=20
 static void xs_write_space(struct sock *sk)
@@ -1416,13 +1416,13 @@ static void xs_write_space(struct sock *sk)
  */
 static void xs_udp_write_space(struct sock *sk)
 {
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
=20
 	/* from net/core/sock.c:sock_def_write_space */
 	if (sock_writeable(sk))
 		xs_write_space(sk);
=20
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 }
=20
 /**
@@ -1437,13 +1437,13 @@ static void xs_udp_write_space(struct sock *sk)
  */
 static void xs_tcp_write_space(struct sock *sk)
 {
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
=20
 	/* from net/core/stream.c:sk_stream_write_space */
 	if (sk_stream_wspace(sk) >=3D sk_stream_min_wspace(sk))
 		xs_write_space(sk);
=20
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 }
=20
 static void xs_udp_do_set_buffer_size(struct rpc_xprt *xprt)


