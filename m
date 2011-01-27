From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2] x25: remove the BKL
Date: Thu, 27 Jan 2011 14:43:39 +0100
Message-ID: <201101271443.40007.arnd@arndb.de>
References: <1295993854-4971-1-git-send-email-arnd@arndb.de> <201101271338.39295.arnd@arndb.de> <1296134447.2614.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Hendry <andrew.hendry@gmail.com>,
	linux-kernel@vger.kernel.org, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1296134447.2614.5.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 27 January 2011, Eric Dumazet wrote:
> Le jeudi 27 janvier 2011 =C3=A0 13:38 +0100, Arnd Bergmann a =C3=A9cr=
it :
> > diff --git a/net/x25/x25_out.c b/net/x25/x25_out.c
> > index d00649f..f1a6ff1 100644
> > --- a/net/x25/x25_out.c
> > +++ b/net/x25/x25_out.c
> > @@ -68,8 +68,11 @@ int x25_output(struct sock *sk, struct sk_buff *=
skb)
> >               frontlen =3D skb_headroom(skb);
> > =20
> >               while (skb->len > 0) {
> > -                     if ((skbn =3D sock_alloc_send_skb(sk, frontle=
n + max_len,
> > -                                                     noblock, &err=
)) =3D=3D NULL){
> > +                     release_sock(sk);
> > +                     skbn =3D sock_alloc_send_skb(sk, frontlen + m=
ax_len,
> > +                                                1, &err);
> > +                     lock_sock(sk);
> > +                     if (!skbn) {
> >                               if (err =3D=3D -EWOULDBLOCK && nobloc=
k){
> >                                       kfree_skb(skb);
> >                                       return sent;
>=20
> This part looks strange :
>=20
> noblock variable became "const 1 : NOBLOCK"
>=20
> Why releasing socket if you dont block in sock_alloc_send_skb() ?

Leftover from an earlier version of the patch, thanks for catching this=
!

Originally, I wrote this as

	long timeo =3D sock_sndtimeo(sk, noblock)
	do {
		skbn =3D sock_alloc_send_skb(sk, frontlen + max_len, 1, &err);
		if (skbn)
			break;

		release_sock(sk);
		timeo =3D sock_wait_for_wmem(sk, timeo);
		lock_sock(sk);
	} while (timeo);

Then I forgot to flip it back after I noticed that other protocols also=
 just
call release_sock/lock_sock around sock_alloc_send_skb.

I think I'd better go over the whole series and see if there are more t=
hings
that got slightly broken...

	Arnd
