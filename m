From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take19 0/4] kevent: Generic event handling mechanism.
Date: Sun, 15 Oct 2006 15:43:39 -0700
Message-ID: <4532B99B.9030403@redhat.com>
References: <115a6230591036@2ka.mipt.ru> <11587449471424@2ka.mipt.ru> <20060927150957.GA18116@2ka.mipt.ru> <a36005b50610032150x8233feqe556fd93bcb5dc73@mail.gmail.com> <20061004045527.GB32267@2ka.mipt.ru> <452363C5.1020505@redhat.com> <20061004074821.GA22688@2ka.mipt.ru> <4523ED6C.9080902@redhat.com> <20061005090214.GB1015@2ka.mipt.ru> <45251A83.9060901@redhat.com> <20061006083620.GA28009@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Drepper <drepper@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:11983 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932174AbWJOWpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2006 18:45:05 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061006083620.GA28009@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> In context you have cut, one updated signal mask between calls to eve=
nt
> delivery mechanism (using for example signal()), so it has exactly th=
e
> same price.

No, it does not.  If the signal mask is recomputed by the program for=20
each new wait call then you have a lot more work to do when the signal=20
mask is implicitly specified.


> I created it just because I think that POSIX workaround to add signal=
s
> into the syscall parameters is not good enough.

Not good enough?  It does exactly what it is supposed to do.  What can=20
there be "not good enough"?


> You again cut my explanation on why just pure timeout is used.
> We start a syscall, which can block forever, so we want to limit it's
> time, and we add special parameter to show how long this syscall shou=
ld
> run. Timeout is not about how long we should sleep (which indeed can =
be
> absolute), but how long syscall should run - which is related to the=20
> time syscall started.

I know very well what a timeout is.  But the way the timeout can be=20
specified can vary.  It is often useful (as for select, poll) to specif=
y=20
relative timeouts.

But there are equally useful uses where the timeout is needed at a=20
specific point in time.  Without a syscall interface which can have a=20
absolute timeout parameter we'd have to write as a poor approximation a=
t=20
userlever

     clock_gettime (CLOCK_REALTIME, &ts);
     struct timespec rel;
     rel.tv_sec =3D abstmo.tv_sec - ts.tv_sec;
     rel.tv_nsec =3D abstmo.tv_sec - ts.tv_nsec;
     if (rel.tv_nsec < 0) {
       rel.tv_nsec +=3D 1000000000;
       --rel.tv_sec;
     }
     if (rel.tv_sec < 0)
       inttmo =3D -1;  // or whatever is used for return immediately
     else
       inttmo =3D rel.tv_sec * UINT64_C(1000000000) + rel.tv_nsec;

      wait(..., inttmo, ...)


Not only is this much more expensive to do at userlevel, it is also=20
inadequate because calls to settimeofday() do  not cause a recomputatio=
n=20
of the timeout.

See Ingo's RT futex stuff as an example for a kernel interface which=20
does it right.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
