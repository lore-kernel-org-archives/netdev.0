From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Tue, 21 Nov 2006 08:58:49 -0800
Message-ID: <45633049.2000209@redhat.com>
References: <11630606361046@2ka.mipt.ru> <45564EA5.6020607@redhat.com> <20061113105458.GA8182@2ka.mipt.ru> <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1031096AbWKURC5@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061121095302.GA15210@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
>> You don't want to have a channel like this.  The userlevel code does=
n't=20
>> know which threads are waiting in the kernel on the event queue.  An=
d it=20
>> seems to be much more complicated then simply have an kevent call wh=
ich=20
>> tells the kernel "wake up N or 1 more threads since I cannot handle =
it".=20
>>  Basically a futex_wake()-like call.
>=20
> Kernel does not know about any threads which waits for events, it onl=
y
> has queue of events, it can only wake those who was parked in
> kevent_get_events() or kevent_wait(), but syscall will return only wh=
en
> condition it waits on is true, i.e. when there is new event in the re=
ady
> queue and/or ring buffer has empty slots, but kernel will wake them u=
p
> in any case if those conditions are true.
>=20
> How should it know which syscall should be interrupted when special s=
yscall
> is called?

It's not about interrupting any threads.

The issue is that the wakeup of a thread from the kevent_wait call=20
constitutes an "event notification".  If, as it should be, only one=20
thread is woken than this information mustn't get lost.  If the woken=20
thread cannot work on the events it got notified for, then it must tell=
=20
the kernel about it so that, *if* there are other threads waiting in=20
kevent_wait, one of those other threads can be woken.

What is needed is a simple "wake another thread waiting on this event=20
queue" syscall.  Yes, in theory we could open an additional pipe with=20
each event queue and use it for waking threads, but this is influencing=
=20
the ABI through the use of a file descriptor.  It's much better to have=
=20
an explicit way to do this.


> No AIO, but syscall.
> Only syscall time matters.
> Syscall starts, it sould be sometime stopped. When it should be stopp=
ed?
> It should be stopped after some time after it was started!
>=20
> I still do not understand how will you use absolute timeout values
> there. Please exaplain.

What is there to explain?  If you are waiting for events which must=20
coincide with real-world events you'll naturally will want to formulate=
=20
something like "wait for X until 10:15h".  You cannot formulate this=20
correctly with relative timeouts since the realtime clock might be adju=
sted.


> futex_wait() uses relative timeouts:
>  static int futex_wait(u32 __user *uaddr, u32 val, unsigned long time=
)
>=20
> Kernel use relative timeouts.

Look again.  This time at the implementation.  For FUTEX_LOCK_PI the=20
timeout is an absolute timeout.

> We have not have such symmetry.
> Other event handling interfaces can not work with events, which do no=
t
> have file descriptor behind them. Kevent can and works.
> Signals are just usual events.
>=20
> You request to get events - and you get them.
> You request to not get events during syscall - you remove events.

None of this matches what I'm talking about.  If you want to block a=20
signal for the duration of the kevent_wait call this is nothing you can=
=20
do by registering an event.

Registering events has nothing to do with signal masks.  They are not=20
modified.  It is the program's responsibility to set the mask up=20
correctly.  Just like sigwaitinfo() etc expect all signals which are=20
waited on to be blocked.

The signal mask handling is orthogonal to all this and must be explicit=
=2E=20
  In some cases explicit pthread_sigmask/sigprocmask calls.  But this i=
s=20
not atomic if a signal must be masked/unmasked for the *_wait call.=20
This is why we have variants like pselect/ppoll/epoll_pwait which=20
explicitly and *atomically* change the signal mask for the duration of=20
the call.


> Btw, please point me to the discussion about real life usefullness of
> that parameter for epoll. I read thread where sys_pepoll() was
> intruduced, but except some theoretical handwaving about possible
> usefullness there are no real signs of that requirement.

Don't search for epoll_pwait, it's not widely used yet.  Search for=20
pselect, which is standardized.  You'll find plenty of uses of that=20
interface.  The number is certainly depressed in the moment since until=
=20
recently there was no correct implementation on Linux.  And the=20
interface is mostly used in real-time contexts where signals are more=20
commonly used.


> What is the ground research or extended explaination about
> blocking/unblocking some signals during syscall execution?

Why is this even a question?  Have you done programming with signals?=20
You hatred of signals makes me think this isn't the case.

You might want to unblock a signal on a *_wait call if it can be used t=
o=20
interrupt the wait but you don't want this to happen during when the=20
thread is working on a request.

You might want to block a signal, for instance, around a sigwaitinfo=20
call or, in this case, a kevent_wait call where the signal might be=20
delivered to the queue.

There are countless possibilities.  Signals are very flexible.


> There are _no_ additional syscalls.
> I just introduced new case for event type.

Which is a new syscall.  All demultiplexer cases are no syscalls.=20
Which, BTW, implies that unrecognized types should actually cause a=20
ENOSYS return value (this affects kevent_break).  We've been over this=20
many times.  If EINVAL is return this case cannot be distinguished from=
=20
invalid parameters.  This is crucial for future extensions where=20
userland (esp glibc) needs to be able to determine whether a new featur=
e=20
is supported on the system.


> You _need_ it to be done, since any kernel kevent user must have
> enqueue/dequeue/callback callbacks. It is just an implementation of t=
hat
> callbacks.

I don't question that.  But there is no need to add the callback.  It=20
extends the kernel ABI/API.  And for what?  A vastly inferior timer=20
implementation compared to the POSIX timers.  And this while all that=20
needs to be done is to extend the POSIX timer code slightly to handle=20
SIGEV_KEVENT in addition to the other notification methods currently=20
used.  If you do it right then the code can be shared with the file AIO=
=20
code which currently is circulated as well and which uses parts of the=20
POSIX timer infrastructure.


> Btw, how POSIX API should be extended to allow to queue events - queu=
e
> is required (which is created when user calls kevent_init() or
> previoisly opened /dev/kevent), how should it be accessed, since it i=
s
> just a file descriptor in process task_struct.

I've explained this multiple times.  The struct sigevent structure need=
s=20
to be extended to get a new part in the union.  Something like

   struct {
     int kevent_fd;
     void *data;
   } _sigev_kevent;

Then define SIGEV_KEVENT as a value distinct from the other SIGEV_=20
values.  In the code which handles setup of timers (the timer_create=20
syscall), recognize SIGEV_KEVENT and handle it appropriately.  I.e.,=20
call into the code to register the event source, just like you'd do wit=
h=20
the current interface.  Then add the code to post an event to the event=
=20
queue where currently signals would be sent et voil=C3=A0.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
