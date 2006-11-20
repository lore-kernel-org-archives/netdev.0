From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Mon, 20 Nov 2006 12:29:31 -0800
Message-ID: <4562102B.5010503@redhat.com>
References: <11630606361046@2ka.mipt.ru> <45564EA5.6020607@redhat.com> <20061113105458.GA8182@2ka.mipt.ru> <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru>
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
Received: from mx1.redhat.com ([66.187.233.31]:50406 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S966642AbWKTUbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 15:31:17 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061120082500.GA25467@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> It is exactly how previous ring buffer (in mapped area though) was
> implemented.

Not any of those I saw.  The one I looked at always started again at=20
index 0 to fill the ring buffer.  I'll wait for the next implementation=
=2E


>> That's something the application should be make a call about.  It's =
not=20
>> always (or even mostly) the case that the ordering of the notificati=
on=20
>> is important.  Furthermore, this would also require the kernel to=20
>> enforce an ordering.  This is expensive on SMP machines.  A locally=20
>> generated event (i.e., source and the thread reporting the event) ca=
n be=20
>> delivered faster than an event created on another CPU.
>=20
> How come? If signal was delivered earlier than data arrived, userspac=
e
> should get signal before data - that is the rule. Ordering is maintai=
ned
> not for event insertion, but for marking them ready - it is atomic, s=
o
> who first starts to mark even ready, that event will be read first fr=
om
> the ready queue.

This is as far as the kernel is concerned.  Queue them in the order the=
y=20
arrive.

I'm talking about the userlevel side.  *If* (and it needs to be verifie=
d=20
that this has an advantage) a CPU creates an event for, e.g., a read=20
event and then a number of threads could be notified about the event.=20
When the kernel has to wake up a thread it'll look whether any thread i=
s=20
scheduled on the same CPU which generated the event.  Then the thread,=20
upon waking up, can be told about the entry in the ring buffer which ca=
n=20
be accessed first best (due to caching).  This entry needs not be the=20
first available in the ring buffer but that's a problem the userlevel=20
code has to worry about.


> Then I propose userspace notifications - each new thread can register
> 'wake me up when userspace event 1 is ready' and 'event 1' will be
> marked as ready by glibc when it removes the thread.

You don't want to have a channel like this.  The userlevel code doesn't=
=20
know which threads are waiting in the kernel on the event queue.  And i=
t=20
seems to be much more complicated then simply have an kevent call which=
=20
tells the kernel "wake up N or 1 more threads since I cannot handle it"=
=2E=20
  Basically a futex_wake()-like call.


>> Of course it does.  Just because you don't see a need for it for you=
r=20
>> applications right now it doesn't mean it's not a valid use.
>=20
> Please explain why glibc AIO uses relatinve timeouts then :)

You are still completely focused on AIO.  We are talking here about a=20
new generic event handling.  It is not tied to AIO.  We will add all=20
kinds of events, e.g., hopefully futex support and many others.  And=20
even for AIO it's relevant.

As I said, relative timeouts are unable to cope with settimeofday calls=
=20
or ntp adjustments.  AIO is certainly usable in situations where=20
timeouts are related to wall clock time.


> It has nothing with implementation - it is logic. Something starts an=
d
> it has its maximum lifetime, but not something starts and should be
> stopped Jan 1, 2008.

It is an implementation detail.  Look at the PI futex support.  It has=20
timeouts which can be cut short (or increased) due to wall clock change=
s.


>> The opposite case is equally impossible to emulate: unblocking a sig=
nal=20
>> just for the duration of the syscall.  These are all possible and us=
ed=20
>> cases.
> =20
> Add and remove appropriate kevent - it is as simple as call for one
> function.

No, it's not.  The kevent stuff handles only the kevent handler (i.e.,=20
the replacement for calling the signal handler).  It cannot set signal=20
masks.  I am talking about signal masks here.  And don't suggest "I can=
=20
add another kevent feature where I can register signal masks".  This=20
would be ridiculous since it's not an event source.  Just add the=20
parameter and every base is covered and, at least equally important, we=
=20
have symmetry between the event handling interfaces.


>> No, that's not what I mean.  There is no need for the special=20
>> timer-related part of your patch.  Instead the existing POSIX timer=20
>> syscalls should be modified to handle SIGEV_KEVENT notification.  Ag=
ain,=20
>> keep the interface as small as possible.  Plus, the POSIX timer=20
>> interface is very flexible.  You don't want to duplicate all that=20
>> functionality.
>=20
> Interface is already there with kevent_ctl(KEVENT_ADD), I just create=
d
> additional entry, which describes timers enqueue/dequeue callbacks

New multiplexers cases are additional syscalls.  This is unnecessary=20
code.  Increased kernel interface and such.  We have the POSIX timer=20
interfaces which are feature-rich and standardized *and* can be trivial=
l=20
extended (at least from the userlevel interface POV) to use event=20
queues.  If you don't want to do this, fine, I'll try to get it made.=20
But drop the timer part of your patches.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
