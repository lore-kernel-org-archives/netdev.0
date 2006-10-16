From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take19 0/4] kevent: Generic event handling mechanism.
Date: Mon, 16 Oct 2006 11:23:22 +0400
Message-ID: <20061016072321.GA17735@2ka.mipt.ru>
References: <20060927150957.GA18116@2ka.mipt.ru> <a36005b50610032150x8233feqe556fd93bcb5dc73@mail.gmail.com> <20061004045527.GB32267@2ka.mipt.ru> <452363C5.1020505@redhat.com> <20061004074821.GA22688@2ka.mipt.ru> <4523ED6C.9080902@redhat.com> <20061005090214.GB1015@2ka.mipt.ru> <45251A83.9060901@redhat.com> <20061006083620.GA28009@2ka.mipt.ru> <4532B99B.9030403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Drepper <drepper@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:21121 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751484AbWJPHXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 03:23:46 -0400
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <4532B99B.9030403@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 15, 2006 at 03:43:39PM -0700, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >In context you have cut, one updated signal mask between calls to ev=
ent
> >delivery mechanism (using for example signal()), so it has exactly t=
he
> >same price.
>=20
> No, it does not.  If the signal mask is recomputed by the program for=
=20
> each new wait call then you have a lot more work to do when the signa=
l=20
> mask is implicitly specified.

One can set number of events before the syscall and do not remove them
after syscall. It can be updated if there is need for that.
=20
> >I created it just because I think that POSIX workaround to add signa=
ls
> >into the syscall parameters is not good enough.
>=20
> Not good enough?  It does exactly what it is supposed to do.  What ca=
n=20
> there be "not good enough"?

Not to move signals into special case of events. If poll() can not work
with them it does not mean, that they need to be specified as additiona=
l
syscall parameter, instead change poll() to work with them, which can b=
e
easily done with kevents.
=20
> >You again cut my explanation on why just pure timeout is used.
> >We start a syscall, which can block forever, so we want to limit it'=
s
> >time, and we add special parameter to show how long this syscall sho=
uld
> >run. Timeout is not about how long we should sleep (which indeed can=
 be
> >absolute), but how long syscall should run - which is related to the=
=20
> >time syscall started.
>=20
> I know very well what a timeout is.  But the way the timeout can be=20
> specified can vary.  It is often useful (as for select, poll) to spec=
ify=20
> relative timeouts.
>=20
> But there are equally useful uses where the timeout is needed at a=20
> specific point in time.  Without a syscall interface which can have a=
=20
> absolute timeout parameter we'd have to write as a poor approximation=
 at=20
> userlever
>=20
>     clock_gettime (CLOCK_REALTIME, &ts);
>     struct timespec rel;
>     rel.tv_sec =3D abstmo.tv_sec - ts.tv_sec;
>     rel.tv_nsec =3D abstmo.tv_sec - ts.tv_nsec;
>     if (rel.tv_nsec < 0) {
>       rel.tv_nsec +=3D 1000000000;
>       --rel.tv_sec;
>     }
>     if (rel.tv_sec < 0)
>       inttmo =3D -1;  // or whatever is used for return immediately
>     else
>       inttmo =3D rel.tv_sec * UINT64_C(1000000000) + rel.tv_nsec;
>=20
>      wait(..., inttmo, ...)

Do not mix warm and soft - waiting for some period is not equal to
syscall timeout. Waiting is possible with timer kevent user (although
only relative timeout, can be changed to support both, not a big
problem).

> Not only is this much more expensive to do at userlevel, it is also=20
> inadequate because calls to settimeofday() do  not cause a recomputat=
ion=20
> of the timeout.
>=20
> See Ingo's RT futex stuff as an example for a kernel interface which=20
> does it right.

I'm quite sure that absolute timeouts are very usefull, but not as in
the case of waiting for syscall completeness. In any way, kevent can be
extended to support absolute timeouts in it's timer notifications.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
