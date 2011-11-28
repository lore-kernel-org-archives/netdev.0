From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: tcp_sendmsg() wrong access to
 sk_route_caps
Date: Mon, 28 Nov 2011 17:04:58 +0100
Message-ID: <1322496298.2292.76.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1322476067.2292.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1322477197.2024.4.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:50439 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443Ab1K1QFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 11:05:02 -0500
Received: by qadc14 with SMTP id c14so1291064qad.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 08:05:01 -0800 (PST)
In-Reply-To: <1322477197.2024.4.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 novembre 2011 =C3=A0 02:46 -0800, Joe Perches a =C3=A9crit =
:
> On Mon, 2011-11-28 at 11:27 +0100, Eric Dumazet wrote:
> > Now sk_route_caps is u64, its dangerous to use an integer to store
> > result of an AND operator. It wont work if NETIF_F_SG is moved on t=
he
> > upper part of u64.
>=20
> trivial comment below.

Well, not trivial at all ;)

>=20
> > diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> []
> > @@ -917,9 +917,9 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock=
 *sk, struct msghdr *msg,
> >  	struct iovec *iov;
> >  	struct tcp_sock *tp =3D tcp_sk(sk);
> >  	struct sk_buff *skb;
> > -	int iovlen, flags;
> > +	int iovlen, flags, err, copied;
> >  	int mss_now, size_goal;
> > -	int sg, err, copied;
> > +	bool sg;
> >  	long timeo;
> > =20
> >  	lock_sock(sk);
> > @@ -946,7 +946,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock=
 *sk, struct msghdr *msg,
> >  	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
> >  		goto out_err;
> > =20
> > -	sg =3D sk->sk_route_caps & NETIF_F_SG;
> > +	sg =3D !!(sk->sk_route_caps & NETIF_F_SG);
>=20
> As sg is now bool, using !! is unnecessary.
>=20
> A commit was done recently to remove one.
> 3ad9b358e03fd9dbf6705721490c811b666b0fe2
>=20

Hmm... I find it dangerous and error prone. Obviously not at the time w=
e
commit such changes, but later, because a future reader might be fooled=
=2E

Using !!(expr) is pretty clear about the potential problem, and
generates no extra code if a bool is used for the target.
