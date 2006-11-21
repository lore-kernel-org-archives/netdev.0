From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Tue, 21 Nov 2006 12:53:02 +0300
Message-ID: <20061121095302.GA15210@2ka.mipt.ru>
References: <11630606361046@2ka.mipt.ru> <45564EA5.6020607@redhat.com> <20061113105458.GA8182@2ka.mipt.ru> <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com>
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
Received: from relay.2ka.mipt.ru ([194.85.82.65]:15010 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030808AbWKUKIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Nov 2006 05:08:04 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <4562102B.5010503@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 20, 2006 at 12:29:31PM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >It is exactly how previous ring buffer (in mapped area though) was
> >implemented.
>=20
> Not any of those I saw.  The one I looked at always started again at=20
> index 0 to fill the ring buffer.  I'll wait for the next implementati=
on.

That what I'm talking about - there are at least 4 (!) different ring
buffer implementations, most of them were not even looked at.
But new version is ready, I will complete testing stage and will relese
'take25' soon today.

=46or those who like 'real-world benchmark and so on' I created a patch
for the latest stable lighttpd version and test it with kevent.
=20
> >>That's something the application should be make a call about.  It's=
 not=20
> >>always (or even mostly) the case that the ordering of the notificat=
ion=20
> >>is important.  Furthermore, this would also require the kernel to=20
> >>enforce an ordering.  This is expensive on SMP machines.  A locally=
=20
> >>generated event (i.e., source and the thread reporting the event) c=
an be=20
> >>delivered faster than an event created on another CPU.
> >
> >How come? If signal was delivered earlier than data arrived, userspa=
ce
> >should get signal before data - that is the rule. Ordering is mainta=
ined
> >not for event insertion, but for marking them ready - it is atomic, =
so
> >who first starts to mark even ready, that event will be read first f=
rom
> >the ready queue.
>=20
> This is as far as the kernel is concerned.  Queue them in the order t=
hey=20
> arrive.
>=20
> I'm talking about the userlevel side.  *If* (and it needs to be verif=
ied=20
> that this has an advantage) a CPU creates an event for, e.g., a read=20
> event and then a number of threads could be notified about the event.=
=20
> When the kernel has to wake up a thread it'll look whether any thread=
 is=20
> scheduled on the same CPU which generated the event.  Then the thread=
,=20
> upon waking up, can be told about the entry in the ring buffer which =
can=20
> be accessed first best (due to caching).  This entry needs not be the=
=20
> first available in the ring buffer but that's a problem the userlevel=
=20
> code has to worry about.

Ok, I've understood.
=20
> >Then I propose userspace notifications - each new thread can registe=
r
> >'wake me up when userspace event 1 is ready' and 'event 1' will be
> >marked as ready by glibc when it removes the thread.
>=20
> You don't want to have a channel like this.  The userlevel code doesn=
't=20
> know which threads are waiting in the kernel on the event queue.  And=
 it=20
> seems to be much more complicated then simply have an kevent call whi=
ch=20
> tells the kernel "wake up N or 1 more threads since I cannot handle i=
t".=20
>  Basically a futex_wake()-like call.

Kernel does not know about any threads which waits for events, it only
has queue of events, it can only wake those who was parked in
kevent_get_events() or kevent_wait(), but syscall will return only when
condition it waits on is true, i.e. when there is new event in the read=
y
queue and/or ring buffer has empty slots, but kernel will wake them up
in any case if those conditions are true.

How should it know which syscall should be interrupted when special sys=
call
is called?
=20
> >>Of course it does.  Just because you don't see a need for it for yo=
ur=20
> >>applications right now it doesn't mean it's not a valid use.
> >
> >Please explain why glibc AIO uses relatinve timeouts then :)
>=20
> You are still completely focused on AIO.  We are talking here about a=
=20
> new generic event handling.  It is not tied to AIO.  We will add all=20
> kinds of events, e.g., hopefully futex support and many others.  And=20
> even for AIO it's relevant.
>=20
> As I said, relative timeouts are unable to cope with settimeofday cal=
ls=20
> or ntp adjustments.  AIO is certainly usable in situations where=20
> timeouts are related to wall clock time.

No AIO, but syscall.
Only syscall time matters.
Syscall starts, it sould be sometime stopped. When it should be stopped=
?
It should be stopped after some time after it was started!

I still do not understand how will you use absolute timeout values
there. Please exaplain.

> >It has nothing with implementation - it is logic. Something starts a=
nd
> >it has its maximum lifetime, but not something starts and should be
> >stopped Jan 1, 2008.
>=20
> It is an implementation detail.  Look at the PI futex support.  It ha=
s=20
> timeouts which can be cut short (or increased) due to wall clock chan=
ges.

futex_wait() uses relative timeouts:
 static int futex_wait(u32 __user *uaddr, u32 val, unsigned long time)

Kernel use relative timeouts.

Only special syscalls, which work with absolute time, have absolute
timeouts (like settimeofday).

> >>The opposite case is equally impossible to emulate: unblocking a si=
gnal=20
> >>just for the duration of the syscall.  These are all possible and u=
sed=20
> >>cases.
> >=20
> >Add and remove appropriate kevent - it is as simple as call for one
> >function.
>=20
> No, it's not.  The kevent stuff handles only the kevent handler (i.e.=
,=20
> the replacement for calling the signal handler).  It cannot set signa=
l=20
> masks.  I am talking about signal masks here.  And don't suggest "I c=
an=20
> add another kevent feature where I can register signal masks".  This=20
> would be ridiculous since it's not an event source.  Just add the=20
> parameter and every base is covered and, at least equally important, =
we=20
> have symmetry between the event handling interfaces.
=20
We have not have such symmetry.
Other event handling interfaces can not work with events, which do not
have file descriptor behind them. Kevent can and works.
Signals are just usual events.

You request to get events - and you get them.
You request to not get events during syscall - you remove events.

Btw, please point me to the discussion about real life usefullness of
that parameter for epoll. I read thread where sys_pepoll() was
intruduced, but except some theoretical handwaving about possible
usefullness there are no real signs of that requirement.

What is the ground research or extended explaination about
blocking/unblocking some signals during syscall execution?

> >>No, that's not what I mean.  There is no need for the special=20
> >>timer-related part of your patch.  Instead the existing POSIX timer=
=20
> >>syscalls should be modified to handle SIGEV_KEVENT notification.  A=
gain,=20
> >>keep the interface as small as possible.  Plus, the POSIX timer=20
> >>interface is very flexible.  You don't want to duplicate all that=20
> >>functionality.
> >
> >Interface is already there with kevent_ctl(KEVENT_ADD), I just creat=
ed
> >additional entry, which describes timers enqueue/dequeue callbacks
>=20
> New multiplexers cases are additional syscalls.  This is unnecessary=20
> code.  Increased kernel interface and such.  We have the POSIX timer=20
> interfaces which are feature-rich and standardized *and* can be trivi=
all=20
> extended (at least from the userlevel interface POV) to use event=20
> queues.  If you don't want to do this, fine, I'll try to get it made.=
=20
> But drop the timer part of your patches.

There are _no_ additional syscalls.
I just introduced new case for event type.
You _need_ it to be done, since any kernel kevent user must have
enqueue/dequeue/callback callbacks. It is just an implementation of tha=
t
callbacks.
I made the work, one can create any interfaces (additional syscalls or
anything else) on top of that.

Due to the fact that kevent was designed as generic event handling
mechanism it is possible to work will all types of events using the sam=
e
interface, which was created 10 month ago: kevent add, remove and so
on... There is nothing special for timers there - it is separate file
which does _not_ have any interfaces accessible outside kevent core (i.=
e.
syscalls or exported symbols).

Btw, how POSIX API should be extended to allow to queue events - queue
is required (which is created when user calls kevent_init() or
previoisly opened /dev/kevent), how should it be accessed, since it is
just a file descriptor in process task_struct.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
