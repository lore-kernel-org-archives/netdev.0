From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Tue, 21 Nov 2006 20:43:34 +0300
Message-ID: <20061121174334.GA25518@2ka.mipt.ru>
References: <11630606361046@2ka.mipt.ru> <45564EA5.6020607@redhat.com> <20061113105458.GA8182@2ka.mipt.ru> <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com>
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
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59558 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S966971AbWKURua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Nov 2006 12:50:30 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <45633049.2000209@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 21, 2006 at 08:58:49AM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >>You don't want to have a channel like this.  The userlevel code doe=
sn't=20
> >>know which threads are waiting in the kernel on the event queue.  A=
nd it=20
> >>seems to be much more complicated then simply have an kevent call w=
hich=20
> >>tells the kernel "wake up N or 1 more threads since I cannot handle=
 it".=20
> >> Basically a futex_wake()-like call.
> >
> >Kernel does not know about any threads which waits for events, it on=
ly
> >has queue of events, it can only wake those who was parked in
> >kevent_get_events() or kevent_wait(), but syscall will return only w=
hen
> >condition it waits on is true, i.e. when there is new event in the r=
eady
> >queue and/or ring buffer has empty slots, but kernel will wake them =
up
> >in any case if those conditions are true.
> >
> >How should it know which syscall should be interrupted when special =
syscall
> >is called?
>=20
> It's not about interrupting any threads.
>
> The issue is that the wakeup of a thread from the kevent_wait call=20
> constitutes an "event notification".  If, as it should be, only one=20
> thread is woken than this information mustn't get lost.  If the woken=
=20
> thread cannot work on the events it got notified for, then it must te=
ll=20
> the kernel about it so that, *if* there are other threads waiting in=20
> kevent_wait, one of those other threads can be woken.
>=20
> What is needed is a simple "wake another thread waiting on this event=
=20
> queue" syscall.  Yes, in theory we could open an additional pipe with=
=20
> each event queue and use it for waking threads, but this is influenci=
ng=20
> the ABI through the use of a file descriptor.  It's much better to ha=
ve=20
> an explicit way to do this.

Threads are parked in syscalls - which one should be interrupted?
And what if there were no threads waiting in syscalls?

> >No AIO, but syscall.
> >Only syscall time matters.
> >Syscall starts, it sould be sometime stopped. When it should be stop=
ped?
> >It should be stopped after some time after it was started!
> >
> >I still do not understand how will you use absolute timeout values
> >there. Please exaplain.
>=20
> What is there to explain?  If you are waiting for events which must=20
> coincide with real-world events you'll naturally will want to formula=
te=20
> something like "wait for X until 10:15h".  You cannot formulate this=20
> correctly with relative timeouts since the realtime clock might be ad=
justed.

It has completely nothing with syscall.
You register a timer to wait until 10:15 that is all.

You do not ask to sleep in read() until some time, because read() has
nothing in common with that time and event.

But actually it becomes stupid discussion, don't you think?
What do you think about putting there timespec and a small warning in
dmesg about absolute timeout? When someone will report it I will
publically say that you were right and it is correct to have possibilit=
y
to have absolute timeouts for syscalls? :)
=20
> >futex_wait() uses relative timeouts:
> > static int futex_wait(u32 __user *uaddr, u32 val, unsigned long tim=
e)
> >
> >Kernel use relative timeouts.
>=20
> Look again.  This time at the implementation.  For FUTEX_LOCK_PI the=20
> timeout is an absolute timeout.

How come? It just uses timespec.

> >We have not have such symmetry.
> >Other event handling interfaces can not work with events, which do n=
ot
> >have file descriptor behind them. Kevent can and works.
> >Signals are just usual events.
> >
> >You request to get events - and you get them.
> >You request to not get events during syscall - you remove events.
>=20
> None of this matches what I'm talking about.  If you want to block a=20
> signal for the duration of the kevent_wait call this is nothing you c=
an=20
> do by registering an event.
>=20
> Registering events has nothing to do with signal masks.  They are not=
=20
> modified.  It is the program's responsibility to set the mask up=20
> correctly.  Just like sigwaitinfo() etc expect all signals which are=20
> waited on to be blocked.
>=20
> The signal mask handling is orthogonal to all this and must be explic=
it.=20
>  In some cases explicit pthread_sigmask/sigprocmask calls.  But this =
is=20
> not atomic if a signal must be masked/unmasked for the *_wait call.=20
> This is why we have variants like pselect/ppoll/epoll_pwait which=20
> explicitly and *atomically* change the signal mask for the duration o=
f=20
> the call.

You probably missed kevent signal patch - signal will not be delivered
(in special cases) since it will not be copied into signal mask. System=
=20
just will not know that it happend. Completely. Like putting it into
blocked mask.

> >Btw, please point me to the discussion about real life usefullness o=
f
> >that parameter for epoll. I read thread where sys_pepoll() was
> >intruduced, but except some theoretical handwaving about possible
> >usefullness there are no real signs of that requirement.
>=20
> Don't search for epoll_pwait, it's not widely used yet.  Search for=20
> pselect, which is standardized.  You'll find plenty of uses of that=20
> interface.  The number is certainly depressed in the moment since unt=
il=20
> recently there was no correct implementation on Linux.  And the=20
> interface is mostly used in real-time contexts where signals are more=
=20
> commonly used.

I found this:

=2E.. document a pselect() call intended to
remove the race condition that is present when one wants
to wait on either a signal or some file descriptor.
(See also Stevens, Unix Network Programming, Volume 1, 2nd Ed.,
1998, p. 168 and the pselect.2 man page released today.)
Glibc 2.0 has a bad version (wrong number of parameters)
and glibc 2.1 a better version, but the whole purpose
of pselect is to avoid the race, and glibc cannot do that,
one needs kernel support.=20


But it is completely irrelevant with kevent signals - there is no race
for that case when signal is delivered through file descriptor.

> >What is the ground research or extended explaination about
> >blocking/unblocking some signals during syscall execution?
>=20
> Why is this even a question?  Have you done programming with signals?=
=20
> You hatred of signals makes me think this isn't the case.

It is much better to not know how thing works, then to not be possible
to understand how new things can work.

> You might want to unblock a signal on a *_wait call if it can be used=
 to=20
> interrupt the wait but you don't want this to happen during when the=20
> thread is working on a request.

Add kevent signal and do not process that event.

> You might want to block a signal, for instance, around a sigwaitinfo=20
> call or, in this case, a kevent_wait call where the signal might be=20
> delivered to the queue.

Having special type of kevent signal is the same as putting signal into
blocked mask, but signal event will be marked as ready - to indicate
that condition was there.
There will not be any race in that case.

> There are countless possibilities.  Signals are very flexible.

That is why we want to get them through synchronous queue? :)

> >There are _no_ additional syscalls.
> >I just introduced new case for event type.
>=20
> Which is a new syscall.  All demultiplexer cases are no syscalls.=20

I think I am a bit blind, probably parts of Leonids are still getting
into my brain, but there is one syscall called kevent_ctl() which adds
different events, including timer, signal, socket and others.

> Which, BTW, implies that unrecognized types should actually cause a=20
> ENOSYS return value (this affects kevent_break).  We've been over thi=
s=20
> many times.  If EINVAL is return this case cannot be distinguished fr=
om=20
> invalid parameters.  This is crucial for future extensions where=20
> userland (esp glibc) needs to be able to determine whether a new feat=
ure=20
> is supported on the system.

I can replace with -ENOSYS if you like.

> >You _need_ it to be done, since any kernel kevent user must have
> >enqueue/dequeue/callback callbacks. It is just an implementation of =
that
> >callbacks.
>=20
> I don't question that.  But there is no need to add the callback.  It=
=20

No one asked and pain me to create kevent, but it is done.
Probably no the way some people wanted, but it always happend,=20
it is really not that bad.

Kevent subsystem operates with structures which can be added into
completely different objects in the system - inodes, files - anything.
And to say to that object about new events there are special callbacks =
-
enqueue and dequeue. Callback which has extremely unusual name 'callbac=
k'
is invoked when object, where event is linked, has something to report =
-
new data, fired alarm or anything else, so it calls kevent's ->callback
and if return value is positive, kevent is marked as ready.
It allows to have event with different sets of interests for the same
type of the main object - for example socket can have read and write
callbacks.

So you must have them.
As you probably saw, kevent_timer_callback() just returns 1.

> extends the kernel ABI/API.  And for what?  A vastly inferior timer=20
> implementation compared to the POSIX timers.  And this while all that=
=20
> needs to be done is to extend the POSIX timer code slightly to handle=
=20
> SIGEV_KEVENT in addition to the other notification methods currently=20
> used.  If you do it right then the code can be shared with the file A=
IO=20
> code which currently is circulated as well and which uses parts of th=
e=20
> POSIX timer infrastructure.

Ulrich, tell me the truth, will you kill me if I say that I have an ent=
ry=20
in TODO to implement different AIO design (details for interested reade=
rs=20
can be found in my blog), and then present it to community? :))
=20
> >Btw, how POSIX API should be extended to allow to queue events - que=
ue
> >is required (which is created when user calls kevent_init() or
> >previoisly opened /dev/kevent), how should it be accessed, since it =
is
> >just a file descriptor in process task_struct.
>=20
> I've explained this multiple times.  The struct sigevent structure ne=
eds=20
> to be extended to get a new part in the union.  Something like
>=20
>   struct {
>     int kevent_fd;
>     void *data;
>   } _sigev_kevent;
>=20
> Then define SIGEV_KEVENT as a value distinct from the other SIGEV_=20
> values.  In the code which handles setup of timers (the timer_create=20
> syscall), recognize SIGEV_KEVENT and handle it appropriately.  I.e.,=20
> call into the code to register the event source, just like you'd do w=
ith=20
> the current interface.  Then add the code to post an event to the eve=
nt=20
> queue where currently signals would be sent et voil=C3=A0.

Ok, I see.
It is doable and simple.
I will try to implement it tomorrow.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
