From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take19 0/4] kevent: Generic event handling mechanism.
Date: Mon, 16 Oct 2006 14:38:48 +0400
Message-ID: <20061016103848.GE17735@2ka.mipt.ru>
References: <20061004045527.GB32267@2ka.mipt.ru> <452363C5.1020505@redhat.com> <20061004074821.GA22688@2ka.mipt.ru> <4523ED6C.9080902@redhat.com> <20061005090214.GB1015@2ka.mipt.ru> <45251A83.9060901@redhat.com> <20061006083620.GA28009@2ka.mipt.ru> <4532B99B.9030403@redhat.com> <20061016072321.GA17735@2ka.mipt.ru> <45335814.6000903@redhat.com>
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
Received: from relay.2ka.mipt.ru ([194.85.82.65]:61917 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751493AbWJPKjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 06:39:49 -0400
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <45335814.6000903@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 16, 2006 at 02:59:48AM -0700, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >One can set number of events before the syscall and do not remove th=
em
> >after syscall. It can be updated if there is need for that.
>=20
> Nobody doubts that it is possible.  But it is
>=20
> a) potentially much expensive
>=20
> and
>=20
> b) an alien concept
>=20
> to have the signal mask to set during the wait call implicitly.=20
> Conceptually it doesn't even make sense.  This is no event to wait fo=
r.=20
>  It a parameter for the specific wait call, just like the timeout.  A=
nd=20
> I fortunately haven't seen you proposing to pass the timeout value=20
> implicitly.

Because timeout has it's meaning for syscall processing, but signals ar=
e
completely separated objects. Why do you want to allow to queue signals
_and_ add 'temporal' signal mask for syscall? Just use one way - queue
them all.
=20
> >>Not good enough?  It does exactly what it is supposed to do.  What =
can=20
> >>there be "not good enough"?
> >
> >Not to move signals into special case of events. If poll() can not w=
ork
> >with them it does not mean, that they need to be specified as additi=
onal
> >syscall parameter, instead change poll() to work with them, which ca=
n be
> >easily done with kevents.
>=20
> You still seem to be completely missing the point.  The signal mask i=
s=20
> no event to wait for.  It has nothing to do with this that ppoll() ta=
kes=20
> the signal mask as a parameter.  The signal mask is a parameter for t=
he=20
> wait call just like the timeout, not more and not less.

That's where we have different opinioins (among others places :) - I do
not agree that signals are parameters for syscall, I insist that is is
usual events. ppoll() shows us that there is no difference between
signal reported as usual user - syscall returns and we can check if
something was changed (signal was delivered or even was fired), it does
not differ from the case when syscall returns and we check what event i=
t
reports first - ready signal or some other event.
=20
> >Do not mix warm and soft - waiting for some period is not equal to
> >syscall timeout. Waiting is possible with timer kevent user (althoug=
h
> >only relative timeout, can be changed to support both, not a big
> >problem).
>=20
> That's what I'm saying all the time.  Of course it can be supported.=20
> But for this the timeout parameter must be a timespec pointer.  Whate=
ver=20
> you could possibly mean by "do not mix warm and soft" I cannot possib=
ly=20
> imagine.  Fact is that both relative and absolute timeouts are useful=
=2E=20
> And that for absolute timeouts the change of the clock has to be take=
n=20
> into account.

They are usefull for special waiting, but not for waiting when syscall
is called. The former is supported by timer notifications, the latter -
by syscall parameter. We can add support for absolute timer
notifications as addon to relative ones. But using there timeval
structure is not accessible, since it has different sizes on different
arches, so there will be problems with 32/64 arches like x86_64.
Instead it is possible to use u32/u32 structure for sec/nsec, like what
is used for relative timeouts.
=20
> >I'm quite sure that absolute timeouts are very usefull, but not as i=
n
> >the case of waiting for syscall completeness. In any way, kevent can=
 be
> >extended to support absolute timeouts in it's timer notifications.
>=20
> That's not the same.  If you argue that then the syscall should have =
no=20
> timeout parameter at all.  Fact is that setting up a timer is not for=
=20
> free.  Since the timeout is used all the time having a timeout parame=
ter=20
> is the right answer.  And if you do this then do it right just like=20
> every other syscall other than poll: use a timespec object.  This giv=
es=20
> flexibility without measurable cost.

It does not introduce any flexibility, since syscall does not have a
parameter to specify absolute or relative timeout has been provided.
That's one.
I do argue that syscall must have timout parameter, since it is related
to syscall behaviour but not to events syscall is working with - which =
is
completely different things: syscall must be interrupted after some tim=
e
to allow to fail operation or perform other tasks, but timer event can
be fired in any time in the future, syscall should not care about
underlaying events. That's two.
You say "every other syscall other than poll" - but even aio_suspend()
and friends use relative timeouts (although glibc converts them into=20
absolute to be used with pthread_cond_timedwait), so why do you propose=
=20
to use wariable sized structure (even if it is transferred almost for=20
free in syscall) instead of usual timeout specified in=20
seconds/nanoseconds/anything? That's three.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
