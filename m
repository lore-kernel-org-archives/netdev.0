From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Thu, 26 May 2011 21:47:26 +0200
Message-ID: <1306439246.2543.10.camel@edumazet-laptop>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maximilian Engelhardt <maxi@daemonizer.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>
To: Arun Sharma <asharma@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DDEAA3C.7020502@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 26 mai 2011 =C3=A0 12:30 -0700, Arun Sharma a =C3=A9crit :
> On 5/24/11 11:35 PM, Eric Dumazet wrote:
>=20
> >> Another possibility is to do the list_empty() check twice. Once wi=
thout
> >> taking the lock and again with the spinlock held.
> >>
> >
> > Why ?
> >
>=20
> Part of the problem is that I don't have a precise understanding of t=
he=20
> race condition that's causing the list to become corrupted.
>=20
> All I know is that doing it under the lock fixes it. If it's slowing=20
> things down, we do a check outside the lock (since it's cheap). But i=
f=20
> we get the wrong answer, we verify it again under the lock.
>=20

You dont get the problem. Problem is : We can do the empty() test only
if protected by the lock.

If not locked, result can be wrong. [ false positive or negative ]


> > list_del_init(&p->unused); (done under lock of course) is safe, you=
 can
> > call it twice, no problem.
>=20
> Doing it twice is not a problem. But doing it when we shouldn't be do=
ing=20
> it could be the problem.
>=20
> The list modification under unused_peers.lock looks generally safe. B=
ut=20
> the control flow (based on refcnt) done outside the lock might have r=
aces.
>=20

"might" is not a good word when dealing with this ;)

> Eg: inet_putpeer() might find the refcnt go to zero, but before it ad=
ds=20
> it to the unused list, another thread may be doing inet_getpeer() and=
=20
> set refcnt to 1. In the end, we end up with a node that's potentially=
 in=20
> use, but ends up on the unused list.
>=20

Did you test my fix ?

Its doing the right thing : Using refcnt as the only marker to say if
the item must be removed from unused list (and lock the central lock
protecting this list only when needed)

Since we already must do an atomic operation on refcnt, using
atomic_inc_return [ or similar full barrier op ] is enough to tell us
the truth.
