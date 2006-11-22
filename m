From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Tue, 21 Nov 2006 23:33:39 -0800
Message-ID: <4563FD53.7030307@redhat.com>
References: <11630606361046@2ka.mipt.ru> <45564EA5.6020607@redhat.com> <20061113105458.GA8182@2ka.mipt.ru> <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
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
Received: from mx1.redhat.com ([66.187.233.31]:9436 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1756956AbWKVHeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 02:34:17 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061121174334.GA25518@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Threads are parked in syscalls - which one should be interrupted?

It doesn't matter, use the same policy you use when waking a thread in=20
case of an event.  This is not about waking a specific thread, it's=20
about not dropping the event notification.


> And what if there were no threads waiting in syscalls?

This is fine, do nothing.  It means that the other threads are about to=
=20
read the ring buffer and will pick up the event.


The case which must be avoided is that of all threads being in the=20
kernel, one threads gets woken, and then is canceled.  Without notifyin=
g=20
the kernel about the cancellation and in the absence of further events=20
notifications the process is deadlocked.

A second case which should be avoided is that there is a thread waiting=
=20
when a thread gets canceled and there are one or more addition threads=20
around, but not in the kernel.  But those other threads might not get t=
o=20
the ring buffer anytime soon, so handling the event is unnecessarily=20
delayed.


> It has completely nothing with syscall.
> You register a timer to wait until 10:15 that is all.

That's a nonsense argument.  In this case you would not add any timeout=
=20
parameter at all.  Of course nobody would want that since it's simply=20
too slow.  Stop thinking about the absolute timeout as an exceptional=20
case, it might very well not be for some problems.

Beside, I've already mentioned another case where a struct timespec*=20
parameter is needed.  There are even two different relative timeouts:=20
using the monotonis clock or using the realtime clock.   The latter is=20
affected by gettimeofday and ntp.


>>> Kernel use relative timeouts.
>> Look again.  This time at the implementation.  For FUTEX_LOCK_PI the=
=20
>> timeout is an absolute timeout.
>=20
> How come? It just uses timespec.

Correct, it's using the value passed in.


>> The signal mask handling is orthogonal to all this and must be expli=
cit.=20
>>  In some cases explicit pthread_sigmask/sigprocmask calls.  But this=
 is=20
>> not atomic if a signal must be masked/unmasked for the *_wait call.=20
>> This is why we have variants like pselect/ppoll/epoll_pwait which=20
>> explicitly and *atomically* change the signal mask for the duration =
of=20
>> the call.
>=20
> You probably missed kevent signal patch - signal will not be delivere=
d
> (in special cases) since it will not be copied into signal mask. Syst=
em=20
> just will not know that it happend. Completely. Like putting it into
> blocked mask.


I don't really understand what you want to say here.

I looked over the patch and I don't think I miss anything.  You just=20
deliver the signal as an event.  No signal mask handling at all.  This=20
is exactly the problem.


> But it is completely irrelevant with kevent signals - there is no rac=
e
> for that case when signal is delivered through file descriptor.

Of course there is a race.  You might not want the signal delivered.=20
This is what the signal mask is for.  Of the other way around, as I've=20
said before.


> It is much better to not know how thing works, then to not be possibl=
e
> to understand how new things can work.

Well, this explains why you don't understand signal masks at all.


> Add kevent signal and do not process that event.

That's not only a horrible hack, it does not work.  If I want to ignore=
=20
a signal for the duration of the call, while you have it occasionally=20
blocked for the rest of the program you would have to register the=20
kevent for the signal, unblock the signal, the kevent_wait call, reset=20
the mask, remove the kevent for the signal..  Otherwise it would not be=
=20
delivered to be ignored.  And then you have a race, the same race=20
pselect is designed to prevent.  In fact, you have two races.

There are other scenarios like this.  Fact is, signal mask handling is=20
necessary and it cannot be folded into the event handling, it's orthogo=
nal.


> Having special type of kevent signal is the same as putting signal in=
to
> blocked mask, but signal event will be marked as ready - to indicate
> that condition was there.
> There will not be any race in that case.

Nonsense on all counts.


> I think I am a bit blind, probably parts of Leonids are still getting
> into my brain, but there is one syscall called kevent_ctl() which add=
s
> different events, including timer, signal, socket and others.

You are searching for callbacks and if none is found you return EINVAL.=
=20
  This is exactly the same as if you'd create separate syscalls.=20
Perhaps even worse, I really don't like demultiplexers, separate=20
syscalls are much cleaner.

Avoiding these callbacks would help reducing the kernel interface,=20
especially for this useless since inferior timer implementation.


> I can replace with -ENOSYS if you like.

It's necessary since we must be able to distinguish the errors.


> No one asked and pain me to create kevent, but it is done.
> Probably no the way some people wanted, but it always happend,=20
> it is really not that bad.

Nobody says that the work isn't appreciated.  But if you don't want it=20
to be critiqued, don't publish it.  If you don't want to mask any more=20
changes, fine, say so.  I'll find somebody else to do it or will do it=20
myself.

I claim that I know a thing or two about interfaces of the runtime=20
programs expect to use.  And I know POSIX and the way the interfaces ar=
e=20
designed and how they interact.


> Ulrich, tell me the truth, will you kill me if I say that I have an e=
ntry=20
> in TODO to implement different AIO design (details for interested rea=
ders=20
> can be found in my blog), and then present it to community? :))

I don't care about the kernel implementation as long as the interface i=
s=20
compatible with what I need for the POSIX AIO implementation.  The=20
currently proposed code is going in that direction.  Any implementation=
=20
which like Ben's old one does not allow POSIX AIO to be implemented I=20
will of oppose.


>> Then define SIGEV_KEVENT as a value distinct from the other SIGEV_=20
>> values.  In the code which handles setup of timers (the timer_create=
=20
>> syscall), recognize SIGEV_KEVENT and handle it appropriately.  I.e.,=
=20
>> call into the code to register the event source, just like you'd do =
with=20
>> the current interface.  Then add the code to post an event to the ev=
ent=20
>> queue where currently signals would be sent et voil=C3=A0.
>=20
> Ok, I see.
> It is doable and simple.
> I will try to implement it tomorrow.

Thanks, that's progress.  And yes, I imagine it's not hard which is why=
=20
the currently proposed timer interface is so unnecessary.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
