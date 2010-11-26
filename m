From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: Simple kernel attack using socketpair. easy, 100%
 reproductiblle, works under guest. no way to protect :(
Date: Fri, 26 Nov 2010 09:59:11 +0100
Message-ID: <1290761951.2855.33.camel@edumazet-laptop>
References: <AANLkTikCeddPFRGojPGuB6oq3xGYgovtm8r4=WhjEDpe@mail.gmail.com>
	 <1290666501.2798.84.camel@edumazet-laptop>
	 <AANLkTik8Fxmd-KwGw498fMyONfVNteFcfCmz+9-V_QZh@mail.gmail.com>
	 <1290668246.2798.93.camel@edumazet-laptop>
	 <AANLkTinQa8BCH-k0m=ndu4u8L-kCiD00jYjKvsvoxK2E@mail.gmail.com>
	 <AANLkTin3SAdiRR4eda3SDdDV4XfKTqH5Z0a7Pih2O4jZ@mail.gmail.com>
	 <1290672978.2798.151.camel@edumazet-laptop>
	 <AANLkTi=NTFXXY42nh+j3xM4n-NTPaz=fWKmAY=MpsHze@mail.gmail.com>
	 <1290694299.2858.330.camel@edumazet-laptop>
	 <4CEF64A4.5080802@cn.fujitsu.com> <1290759748.2855.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?=D0=9C=D0=B0=D1=80=D0=BA_?=
	 =?UTF-8?Q?=D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3?=
	<socketpair@gmail.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55536 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753959Ab0KZI7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 03:59:16 -0500
Received: by wwa36 with SMTP id 36so1833706wwa.1
        for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 00:59:14 -0800 (PST)
In-Reply-To: <1290759748.2855.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 26 novembre 2010 =C3=A0 09:22 +0100, Eric Dumazet a =C3=A9c=
rit :
> Le vendredi 26 novembre 2010 =C3=A0 15:41 +0800, Shan Wei a =C3=A9cri=
t :
> > Eric Dumazet wrote, at 11/25/2010 10:11 PM:
> > > @@ -1845,6 +1871,7 @@ static int unix_stream_recvmsg(struct kiocb=
 *iocb, struct socket *sock,
> > >  		unix_state_lock(sk);
> > >  		skb =3D skb_dequeue(&sk->sk_receive_queue);
> > >  		if (skb =3D=3D NULL) {
> > > +			unix_sk(sk)->recursion_level =3D 0;
> >=20
> > For SOCK_SEQPACKET type, no need to clear recursion_level counter?
> > =20
> >=20
>=20
> There is no need actually to clear it at all.
>=20
> If an application has a complex setup with a dependence tree of unix
> sockets, it will break if messages are not read fast enough.
>=20
> So, maybe I should remove this line so that underlying problem comes
> into surface immediately, rather than while in stress load.
>=20
>=20

The whole sendfd feature is fundamentally flawed, since its not a "give
this file to another user", but "give a pointer to file structure"

As soon as you can pass af_unix sockets, you cannot know if the
intransit "refs to file structure" are going to be consumed by one or
other user. So a per user limit is not possible.

I am not sure it is fixable at all, unless adding a complete graph
structure between af_unix sockets that used the sendfd() mechanism.
(Its a NxN relationship... pretty hard to track)

Yes, we can add limits (global wide), but they could break legacy apps,
and a single user could lock in one fd all the tokens.



