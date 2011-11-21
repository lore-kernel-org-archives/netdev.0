From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] 3.2-rc2: BUG kmalloc-8: Redzone overwritten
Date: Mon, 21 Nov 2011 11:21:55 +0100
Message-ID: <1321870915.2552.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1321866845.3831.7.camel@lappy>
	 <1321870529.2552.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>,
 Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg
 <penberg@kernel.org>, linux-mm <linux-mm@kvack.org>,  linux-kernel
 <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1321870529.2552.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le lundi 21 novembre 2011 =C3=A0 11:15 +0100, Eric Dumazet a =C3=A9crit :

>=20
> Hmm, trinity tries to crash decnet ;)
>=20
> Maybe we should remove this decnet stuff for good instead of tracking
> all bugs just for the record. Is there anybody still using decnet ?
>=20
> For example dn_start_slow_timer() starts a timer without holding a
> reference on struct sock, this is highly suspect.
>=20
> [PATCH] decnet: proper socket refcounting
>=20
> Better use sk_reset_timer() / sk_stop_timer() helpers to make sure we
> dont access already freed/reused memory later.
>=20
> Reported-by: Sasha Levin <levinsasha928@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Hmm, I forgot to remove the sock_hold(sk) call from dn_slow_timer(),
here is V2 :

[PATCH] decnet: proper socket refcounting

Better use sk_reset_timer() / sk_stop_timer() helpers to make sure we
dont access already freed/reused memory later.

Reported-by: Sasha Levin <levinsasha928@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
V2: remove sock_hold(sk) call from dn_slow_timer()

 net/decnet/dn_timer.c |   17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

diff --git a/net/decnet/dn_timer.c b/net/decnet/dn_timer.c
index 67f691b..d9c150c 100644
--- a/net/decnet/dn_timer.c
+++ b/net/decnet/dn_timer.c
@@ -36,16 +36,13 @@ static void dn_slow_timer(unsigned long arg);
=20
 void dn_start_slow_timer(struct sock *sk)
 {
-	sk->sk_timer.expires	=3D jiffies + SLOW_INTERVAL;
-	sk->sk_timer.function	=3D dn_slow_timer;
-	sk->sk_timer.data	=3D (unsigned long)sk;
-
-	add_timer(&sk->sk_timer);
+	setup_timer(&sk->sk_timer, dn_slow_timer, (unsigned long)sk);
+	sk_reset_timer(sk, &sk->sk_timer, jiffies + SLOW_INTERVAL);
 }
=20
 void dn_stop_slow_timer(struct sock *sk)
 {
-	del_timer(&sk->sk_timer);
+	sk_stop_timer(sk, &sk->sk_timer);
 }
=20
 static void dn_slow_timer(unsigned long arg)
@@ -53,12 +50,10 @@ static void dn_slow_timer(unsigned long arg)
 	struct sock *sk =3D (struct sock *)arg;
 	struct dn_scp *scp =3D DN_SK(sk);
=20
-	sock_hold(sk);
 	bh_lock_sock(sk);
=20
 	if (sock_owned_by_user(sk)) {
-		sk->sk_timer.expires =3D jiffies + HZ / 10;
-		add_timer(&sk->sk_timer);
+		sk_reset_timer(sk, &sk->sk_timer, jiffies + HZ / 10);
 		goto out;
 	}
=20
@@ -100,9 +95,7 @@ static void dn_slow_timer(unsigned long arg)
 			scp->keepalive_fxn(sk);
 	}
=20
-	sk->sk_timer.expires =3D jiffies + SLOW_INTERVAL;
-
-	add_timer(&sk->sk_timer);
+	sk_reset_timer(sk, &sk->sk_timer, jiffies + SLOW_INTERVAL);
 out:
 	bh_unlock_sock(sk);
 	sock_put(sk);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
