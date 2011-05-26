From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Fri, 27 May 2011 00:01:32 +0200
Message-ID: <1306447292.2543.32.camel@edumazet-laptop>
References: <201104250033.03401.maxi@daemonizer.de>
	 <1303878240.2699.41.camel@edumazet-laptop>
	 <1303878771.2699.44.camel@edumazet-laptop>
	 <201104271352.00601.maxi@daemonizer.de>
	 <20110512211033.GA3468@dev1756.snc6.facebook.com>
	 <1305234953.2831.2.camel@edumazet-laptop>
	 <20110524213327.GA3917@dev1756.snc6.facebook.com>
	 <1306291469.3305.11.camel@edumazet-laptop>
	 <20110525060609.GA32244@dev1756.snc6.facebook.com>
	 <1306305331.3305.22.camel@edumazet-laptop>  <4DDEAA3C.7020502@fb.com>
	 <1306439246.2543.10.camel@edumazet-laptop>  <4DDECA9B.8080206@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maximilian Engelhardt <maxi@daemonizer.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>
To: Arun Sharma <asharma@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61738 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754440Ab1EZWBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 18:01:36 -0400
In-Reply-To: <4DDECA9B.8080206@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 26 mai 2011 =C3=A0 14:48 -0700, Arun Sharma a =C3=A9crit :
> On 5/26/11 12:47 PM, Eric Dumazet wrote:
>=20
> > You dont get the problem. Problem is : We can do the empty() test o=
nly
> > if protected by the lock.
> >
> > If not locked, result can be wrong. [ false positive or negative ]
> >
>=20
>=20
> Agreed. Failing to unlink from unused list when we should have sounds=
 wrong.
>=20
> >> The list modification under unused_peers.lock looks generally safe=
=2E But
> >> the control flow (based on refcnt) done outside the lock might hav=
e races.
> >>
> >
> > "might" is not a good word when dealing with this ;)
>=20
> Potential race in the current code:
>=20
> initial refcnt =3D 1
>=20
>         T1:                                        T2
>=20
> atomic_dec_and_lock(refcnt)
> // refcnt =3D=3D 0
>=20
>                                         atomic_add_unless(refcnt)
>                                         unlink_from_unused()
>=20
> list_add_tail(unused)
>                                         // T2 using "unused" entry
>=20
>=20
> > Did you test my fix ?
>=20
> I could try it on one or two machines - but it won't tell us anything=
=20
> for weeks if not months. Unfortunately my next window to try a new=20
> kernel on a large enough sample is several months away.
>=20
> >
> > Its doing the right thing : Using refcnt as the only marker to say =
if
> > the item must be removed from unused list (and lock the central loc=
k
> > protecting this list only when needed)
> >
> > Since we already must do an atomic operation on refcnt, using
> > atomic_inc_return [ or similar full barrier op ] is enough to tell =
us
> > the truth.
>=20
> Yeah - using the refcnt seems better than list_empty(), but I'm not s=
ure=20
> that your patch addresses the race above.

It does.

It becomes

        T1:                                        T2
>=20
> atomic_dec_and_lock(refcnt)
> // refcnt =3D=3D 0
>=20
>                          newref =3D atomic_add_unless_and_return(refc=
nt)
>=20
> list_add_tail(unused)
  unlock();
>                                        =20
> 			   if (newref =3D=3D 1) {
				   lock()
                                   unlink_from_unused()
				   unlock()
			   }



