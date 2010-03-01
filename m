From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2] net: add accounting for socket backlog
Date: Mon, 01 Mar 2010 12:43:48 +0100
Message-ID: <1267443828.3039.7.camel@edumazet-laptop>
References: <1267176464-426-1-git-send-email-yi.zhu@intel.com>
	 <1267335071.9082.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:65428 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949Ab0CALnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 06:43:53 -0500
Received: by bwz1 with SMTP id 1so282544bwz.21
        for <netdev@vger.kernel.org>; Mon, 01 Mar 2010 03:43:52 -0800 (PST)
In-Reply-To: <1267335071.9082.56.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 28 f=C3=A9vrier 2010 =C3=A0 06:31 +0100, Eric Dumazet a =C3=
=A9crit :

> I am afraid sk_backlog_rcv() is not always called with lock held, and
> not always called to process backlog (see TCP ucopy.prequeue)
>=20
> If you take a look at __release_sock() for example, we make the backl=
og
> private to the process before handling it (outside of lock_sock())
>=20
> Therefore, I suggest doing the 'substraction' outside of
> sk_backlog_rcv().
>=20
> diff --git a/net/core/sock.c b/net/core/sock.c
> index e1f6f22..57271cb 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1520,6 +1520,7 @@ static void __release_sock(struct sock *sk)
> =20
>         do {
>                 sk->sk_backlog.head =3D sk->sk_backlog.tail =3D NULL;
> +               sk->sk_backlog.len =3D 0;
>                 bh_unlock_sock(sk);
> =20
>                 do {
>=20
>=20

Thinking again about this, doing this zero initialization at the very
end of __release_sock() solves the problem of potential infinite loop i=
n
__release_sock(). Since producer will hit the backlog limit.

Thanks

diff --git a/net/core/sock.c b/net/core/sock.c
index 305cba4..544cf4a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1542,6 +1542,11 @@ static void __release_sock(struct sock *sk)
=20
 		bh_lock_sock(sk);
 	} while ((skb =3D sk->sk_backlog.head) !=3D NULL);
+	/*
+	 * Doing this zeroing at the end of this function guarantee we can no=
t
+	 * loop forever while a wild producer attempts to flood us
+	 */
+	sk->sk_backlog.len =3D 0;
 }
=20
 /**





