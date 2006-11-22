From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Wed, 22 Nov 2006 13:38:28 +0300
Message-ID: <20061122103828.GA11480@2ka.mipt.ru>
References: <11630606361046@2ka.mipt.ru> <45564EA5.6020607@redhat.com> <20061113105458.GA8182@2ka.mipt.ru> <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <4563FD53.7030307@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Alexander Viro <aviro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:46026 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1755628AbWKVKjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 05:39:32 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <4563FD53.7030307@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 21, 2006 at 11:33:39PM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >Threads are parked in syscalls - which one should be interrupted?
>=20
> It doesn't matter, use the same policy you use when waking a thread i=
n=20
> case of an event.  This is not about waking a specific thread, it's=20
> about not dropping the event notification.

Event notification is not dropped - thread was awakened, kernel task is
completed. Kernel does not know and should not have such knowledge abou=
t
the fact that selected thread was not good enough. If you want to wakeu=
p
another thread - create another event, that is why I proposed userspace
notifications, which I actually do not like.
=20
> >And what if there were no threads waiting in syscalls?
>=20
> This is fine, do nothing.  It means that the other threads are about =
to=20
> read the ring buffer and will pick up the event.
>=20
>=20
> The case which must be avoided is that of all threads being in the=20
> kernel, one threads gets woken, and then is canceled.  Without notify=
ing=20
> the kernel about the cancellation and in the absence of further event=
s=20
> notifications the process is deadlocked.
>=20
> A second case which should be avoided is that there is a thread waiti=
ng=20
> when a thread gets canceled and there are one or more addition thread=
s=20
> around, but not in the kernel.  But those other threads might not get=
 to=20
> the ring buffer anytime soon, so handling the event is unnecessarily=20
> delayed.

If those threads are not in the kernel, kernel can not wake hem up.
But if there is an event 'wake me up when thread has died' or something
like that, when new threads will try to sleep in syscall, they will be
immediately awakened, since that event will be ready.
=20
> >It has completely nothing with syscall.
> >You register a timer to wait until 10:15 that is all.
>=20
> That's a nonsense argument.  In this case you would not add any timeo=
ut=20
> parameter at all.  Of course nobody would want that since it's simply=
=20
> too slow.  Stop thinking about the absolute timeout as an exceptional=
=20
> case, it might very well not be for some problems.

I repeate - timeout is needed to tell kernel the maximum possible
timeframe syscall can live. When you will tell me why you want syscall
to be interrupted when some absolute time is on the clock instead of
having special event for that, then ok.

I think I know why you want absolute time there - because glibc convert=
s
most of the timeouts to absolute time since posix waiting
pthread_cond_timedwait() works only with it.

> Beside, I've already mentioned another case where a struct timespec*=20
> parameter is needed.  There are even two different relative timeouts:=
=20
> using the monotonis clock or using the realtime clock.   The latter i=
s=20
> affected by gettimeofday and ntp.

Kevent convert it to jiffies since it uses wait_event() and friends,
jiffies do not carry information about clocks to be used.
=20
> >>>Kernel use relative timeouts.
> >>Look again.  This time at the implementation.  For FUTEX_LOCK_PI th=
e=20
> >>timeout is an absolute timeout.
> >
> >How come? It just uses timespec.
>=20
> Correct, it's using the value passed in.
>=20
>=20
> >>The signal mask handling is orthogonal to all this and must be expl=
icit.=20
> >> In some cases explicit pthread_sigmask/sigprocmask calls.  But thi=
s is=20
> >>not atomic if a signal must be masked/unmasked for the *_wait call.=
=20
> >>This is why we have variants like pselect/ppoll/epoll_pwait which=20
> >>explicitly and *atomically* change the signal mask for the duration=
 of=20
> >>the call.
> >
> >You probably missed kevent signal patch - signal will not be deliver=
ed
> >(in special cases) since it will not be copied into signal mask. Sys=
tem=20
> >just will not know that it happend. Completely. Like putting it into
> >blocked mask.
>=20
>=20
> I don't really understand what you want to say here.
>=20
> I looked over the patch and I don't think I miss anything.  You just=20
> deliver the signal as an event.  No signal mask handling at all.  Thi=
s=20
> is exactly the problem.

Have you seen specific_send_sig_info():

	/* Short-circuit ignored signals.  */
	if (sig_ignored(p, sig)) {
		ret =3D 1;
		goto out;
	}
=20
almost the same happens when signal is delivered using kevent (special
case) - pending mask is not updated.

> >But it is completely irrelevant with kevent signals - there is no ra=
ce
> >for that case when signal is delivered through file descriptor.
>=20
> Of course there is a race.  You might not want the signal delivered.=20
> This is what the signal mask is for.  Of the other way around, as I'v=
e=20
> said before.

Then ignore that event - there is no race between signal delivery and
other descriptors reading, and it _is_ when signal is delivered no
through the same queue but asynchronously with mask update.

> >It is much better to not know how thing works, then to not be possib=
le
> >to understand how new things can work.
>=20
> Well, this explains why you don't understand signal masks at all.

Nice :)
I at least try to do something to solve this problem, instead of blindl=
y
saying the same again and again without even trying to hear and
understand what others say.

> >Add kevent signal and do not process that event.
>=20
> That's not only a horrible hack, it does not work.  If I want to igno=
re=20
> a signal for the duration of the call, while you have it occasionally=
=20
> blocked for the rest of the program you would have to register the=20
> kevent for the signal, unblock the signal, the kevent_wait call, rese=
t=20
> the mask, remove the kevent for the signal..  Otherwise it would not =
be=20
> delivered to be ignored.  And then you have a race, the same race=20
> pselect is designed to prevent.  In fact, you have two races.
>=20
> There are other scenarios like this.  Fact is, signal mask handling i=
s=20
> necessary and it cannot be folded into the event handling, it's ortho=
gonal.

You have too narrow look.
Look broader - pselect() has signal mask to prevent race between async
signal delivery and file descriptor readiness. With kevent both that
events are delivered through the same queue, so there is no race, so
kevent syscalls do not need that workaround for 20 years-old design,
which can not handle different than fd events.

> >Having special type of kevent signal is the same as putting signal i=
nto
> >blocked mask, but signal event will be marked as ready - to indicate
> >that condition was there.
> >There will not be any race in that case.
>=20
> Nonsense on all counts.
>
>
> >I think I am a bit blind, probably parts of Leonids are still gettin=
g
> >into my brain, but there is one syscall called kevent_ctl() which ad=
ds
> >different events, including timer, signal, socket and others.
>=20
> You are searching for callbacks and if none is found you return EINVA=
L.=20
>  This is exactly the same as if you'd create separate syscalls.=20
> Perhaps even worse, I really don't like demultiplexers, separate=20
> syscalls are much cleaner.
>=20
> Avoiding these callbacks would help reducing the kernel interface,=20
> especially for this useless since inferior timer implementation.

You completely do not want to understand how kevent works and why they=20
are needed, if you would try to think that there are different than=20
yours opinions, then probably we could have some progress.

Those callbacks are neededto support different types of objects, which
can produce events, with the same interface.
=20
> >I can replace with -ENOSYS if you like.
>=20
> It's necessary since we must be able to distinguish the errors.

And what if user requests bogus event type - is it invalid condition or
normal, but not handled (thus enosys)?

> >No one asked and pain me to create kevent, but it is done.
> >Probably no the way some people wanted, but it always happend,=20
> >it is really not that bad.
>=20
> Nobody says that the work isn't appreciated.  But if you don't want i=
t=20
> to be critiqued, don't publish it.  If you don't want to mask any mor=
e=20
> changes, fine, say so.  I'll find somebody else to do it or will do i=
t=20
> myself.

I greatly appreciate critics, really. But when it comes to 'this
sucks because it sucks, no matter if it is completely different way,
it still sucks because others sucked there too' I can not say it is=20
critics, it becomes nonsence.

> I claim that I know a thing or two about interfaces of the runtime=20
> programs expect to use.  And I know POSIX and the way the interfaces =
are=20
> designed and how they interact.

Well, then I claim that I do not know 'thing or two about interfaces of
the runtime programs expect to use', but instead I write those programm=
s
and I know my needs. And POSIX interfaces are the last one I prefer to
use.

We are on the different positions - theoretical thoughs about world
hapinness, and practical usage. I do not say that only one of that
approaches must exist, they both can live together, but it requires tha=
t
people from both sides not only tried to say, that other part is stupid
and do not know something or anything, but instead tried to listen and =
get=20
into account that.
=20
> >Ulrich, tell me the truth, will you kill me if I say that I have an =
entry=20
> >in TODO to implement different AIO design (details for interested re=
aders=20
> >can be found in my blog), and then present it to community? :))
>=20
> I don't care about the kernel implementation as long as the interface=
 is=20
> compatible with what I need for the POSIX AIO implementation.  The=20
> currently proposed code is going in that direction.  Any implementati=
on=20
> which like Ben's old one does not allow POSIX AIO to be implemented I=
=20
> will of oppose.

What if it will not be called POSIX AIO, but instead some kind of 'true
AIO' or 'real AIO' or maybe 'alternative AIO'? :)
It is quite sure that POSIX AIO interfaces will unlikely to be applied
there...

> >>Then define SIGEV_KEVENT as a value distinct from the other SIGEV_=20
> >>values.  In the code which handles setup of timers (the timer_creat=
e=20
> >>syscall), recognize SIGEV_KEVENT and handle it appropriately.  I.e.=
,=20
> >>call into the code to register the event source, just like you'd do=
 with=20
> >>the current interface.  Then add the code to post an event to the e=
vent=20
> >>queue where currently signals would be sent et voil=C3=A0.
> >
> >Ok, I see.
> >It is doable and simple.
> >I will try to implement it tomorrow.
>=20
> Thanks, that's progress.  And yes, I imagine it's not hard which is w=
hy=20
> the currently proposed timer interface is so unnecessary.

It is the first techical but not political problem we cought in this
endless discussion, I separated it in different subthread already.
Let's try to think more about it there.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
