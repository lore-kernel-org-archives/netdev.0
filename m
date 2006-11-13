From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Mon, 13 Nov 2006 13:54:58 +0300
Message-ID: <20061113105458.GA8182@2ka.mipt.ru>
References: <11630606361046@2ka.mipt.ru> <45564EA5.6020607@redhat.com>
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
Received: from relay.2ka.mipt.ru ([194.85.82.65]:3530 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1754435AbWKMLFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Nov 2006 06:05:03 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <45564EA5.6020607@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 11, 2006 at 02:28:53PM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >Generic event handling mechanism.
> >[...]
>=20
> Sorry for the delay again.  Kernel work is simply not my highest prio=
rity.
>=20
> I've collected my comments on some parts of the patch.  I haven't gon=
e=20
> through every part of the patch yet.  Sorry for the length.

No problem.

> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> - basic ring buffer problem: the kevent_copy_ring_buffer function sto=
res
>   the event in the ring buffer without disregard of the current conte=
nt.
>=20
>   + if dequeued entries larger than number of ring buffer entries
>     events immediately get overwritten without passing anything to
>     userlevel
>=20
>   + as with the old approach, the ring buffer is basically unusable w=
ith
>     multiple threads/processes.  A thread calling kevent_wait might
>     cause entries another thread is still working on to be overwritte=
n.
>=20
> Possible solution:
>=20
> a) it would be possible to have a "used" flag in each ring buffer ent=
ry.
>    That's too expensive, I guess.
>=20
> b) kevent_wait needs another parameter which specifies the which is t=
he
>    last (i.e., least recently added) entry in the ring buffer.
>    Everything between this entry and the current head (in ->kidx) is
>    occupied.  If multiple threads arrive in kevent_wait the highest i=
dx
>    (with wrap around possibly lowest) is used.
>=20
>    kevent_wait will not try to move more entries into the ring buffer
>    if ->kidx and the higest index passed in to any kevent_wait call
>    is equal (i.e., the ring buffer is full).
>=20
>    There is one issue, though, and that is that a system call is need=
ed
>    to signal to the kernel that more entries in the ring buffer are
>    processed and that they can be refilled.  This goes against the
>    kernel filling the ring buffer automatically (see below)

If thread calls kevent_wait() it means it has processed previous entrie=
s,=20
one can call kevent_wait() with $num parameter as zero, which
means that thread does not want any new events, so nothing will be
copied.
=20
> Threads should be able to (not necessarily forced to) use the
> interfaces like this:
>=20
> - by default all threads are "parked" in the kevent_wait syscall.
>=20
>=20
> - If an event occurs one thread might be woken (depending on the 'num=
'
>   parameter)
>=20
> - the woken thread(s) work on all the events in the ring buffer and
>   then call kevent_wait() again.
>=20
> This requires that the threads can independently call kevent_wait()
> and that they can independently retrieve events from the ring buffer
> without fear the entry gets overwritten before it is retrieved.
> Atomically retrieving entries from the ring buffer can be implemented
> at userlevel.  Either the ring buffer is writable and a field in each
> ring buffer entry can be used as a 'handled' flag.  Obviously this ca=
n
> be done with atomic compare-and-exchange.  If the ring buffer is not
> writable then, as part of the userlevel wrapper around the event
> handling interfaces, another array is created which contains the use
> flags for each ring buffer entry.  This is less elegant and probably
> slower.

Writable ring buffer does not sound too good to me - what if one thread
will overwrite the whole ring buffer so kernel's indexes can be screwed=
?

Ring buffer processed not in FIFO order is wrong idea - ring buffer can
be potentially very big and searching there for the entry, which was
been marked as 'free' by userspace is not a solution at all - userspace
in that case must provide ukevent so fast tree search would be used,
(and although it is already possible) it requires userspace to make
additional syscalls which is not what we want.

So kevent ring buffer is designed in the following way: all entries can
be processed _only_ in fifo order, i.e. they can be read in any order
threads want, but when one thread calls kevent_wait(num), $num requeste=
d
from the begining can be overwritten - kernel does not know how many
users reads those $num events from the begining, and even if they have
some flag that 'do not touch me, someone reads me', how and when those
entries will be reused? Kernel does not store bitmask or any other type
of objects to show that holes in the ring buffer are free - it works in
=46IFO order since it the fastest mode.

As a solution I can create folowing scheme:
there are two syscalls (or one with a switch) which get events and
commits them.

kevent_wait() becomes a syscall which waits until number of events or
one of them becomes ready and just copies them into ring buffer and
returns. kevent_wait() will fail with special error code when ring
buffer is full.

kevent_commit() frees requested number of events _from the beginning_,
i.e. from special index, visible from userspace. Userspace can create
special counters for events (and even put them into read-only ring=20
buffer overwriting some fields of kevent, especially if we will increas=
e
it's size) and only call kevent_commit() when all events have zero usag=
e
counter.

I disagree that having possibility to have holes in the ring buffer is =
a
good idea at all - it requires much more complex protocol, which will
fill and reuse that holes, and the main disavantge - it requires to
transfer much more information from userspace to kernelspace to free th=
e
ring entry in the hole - in that case it is already possible just to
call kevent_ctl(KEVENT_REMOVE) and do not wash the brain with new
approach at all.

> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> - implementing the kevent_wait syscall the proposed way means we are
>   missing out on one possible optimization.  The ring buffer is
>   currently only filled on kevent_wait calls.  I expect that in reall=
y
>   high traffic situations requests are coming in at a higher rate tha=
n
>   the can be processed.  At least for periods of time.  If such
>   situations it would be nice to not have to call into the kernel at
>   all.  If the kernel would deliver into the ring buffer on its own
>   this would be possible.

Well, it can be done on behalf of workqueue or dedicated thread which
will bring up appropriate mm context, although it means that userspace
can not handle the load it requested, which is a bad sign...

>   If the argument against this is that kevent_get_event should be
>   possible the answer is...
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> - the kevent_get_event syscall is not  needed at all.  All reporting
>   should be done using a ring buffer.  There really is not reason to
>   keep two interfaces around  which serve the same purpose.  Making
>   the argument the kevent_get_event is so much easier to use is not
>   valid.  The exposed interface to access the ring buffer will be eas=
y,
>   too.  In the OLS paper I more or wait hinted at the interfaces.  I
>   think they should be like this (names are irrelevant):

Well, kevent_get_events() _is_ much easier to use. And actually having
only that interface it is possible to implement ring buffer with any
kind or protocol for its controlling - userspace can have a wrapper
which will call kevent_get_events() with pointer which shows to the
place in the shared ring buffer where to place new events, that wrapper
can handle essentially any kind of flags/parameters which are suitable
for that ring buffer implementation.
But since we started to implement ring buffer as a additional feature o=
f
kevent, let's find the way all people will be happy with before removin=
g
something which was proven to work correctly.

> ec_t ec_create(unsigned flags);
> int ec_destroy(ec_t ec);
> int ec_poll_event(ec_t ec, event_data_t *d);
> int ec_wait_event(ec_t ec, event_data_t *d);
> int ec_timedwait_event(ec_t ec, event_data_t *d, struct timespec *to)=
;
>=20
> The latter three interfaces are the interesting ones.  We have to get
> the data out of the ring buffer as quickly as possible.  So the
> interfaces require passing in a reference to an object which can hold
> the data.  The 'poll' variant won't delay, the other two will.

The last three are exactly kevent_get_events() with different set of
parameters - it is possible to get events without sleeping, it is
possible to wait until at least something is ready and it is possible t=
o
sleep for timeout.

> We need separate create and destroy functions since there will always
> be a userlevel component of the data structures.  The create variant
> can allocate the ring buffer and the other memory needed ('handled'
> flags, tail pointers, ...) and destroy free all resources.
>=20
> These interfaces are fast and easy to use.  At least as easy as the
> kevent_get_event syscall.  And all transparently implemented on top o=
f
> the ring buffer.  So, please let's drop the unneeded syscall.

They all already imeplemented. Just all above, and it was done several
months ago already. No need to reinvent what is already there.
Even if we will decide to remove kevent_get_events() in favour of ring
buffer-only implementation, winting-for-event syscall will be
essentially kevent_get_events() without pointer to the place where to
put events.
And I will not repeat, that it is (and was from the beginning for about
10 months already) to implement ring buffer using kevent_get_events().

I agree that having special syscall to initialize kevent is a good idea=
,
and initial kevent implementation had it, but it was removed due to API
cleanup work by Cristoph Hellwing.
So I again see the same problem as several months ago when there are
many people who have opposite views on API, and I as author do not know
who is right...

Can we all agree that initialization syscall is a good idea?

> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> - another optimization I am thinking about is optimizing the thread
>   wakeup and ring buffer use for cache line use.  I.e., if we know
>   an event was queued on a specific CPU then the wakeup function
>   should take this into account.  I.e., if any of the threads
>   waiting was/will be scheduled on the same CPU it should be
>   preferred.

Do you have _any_ kind of benchmarks with epoll() which would show that
it is feasible? ukevent is one cache line (well, 2 cache lines on old
CPUs), which can be setup way too far away from the time when it is
ready, and CPU which origianlly set that up can be busy, so we will los=
e
performance waiting until CPU becomes free instead of calling other
thread on different CPU.

So I'm asking is there at least some data except theoretical thoughts?

>   With the current simple form of a ring buffer this isn't sufficient=
,
>   though.  Reading all entries in the ring buffer until finding the
>   one written by the CPU in question is not helpful.  We'd need a
>   mechanism to point the thread to the entry in question.  One
>   possibility to do this is to return the ring buffer entry as the
>   return value of the kevent_wait() syscall.  This works fine if the
>   thread only works for one event (which I guess will be 99.999% of
>   all uses).  An extension could be to extend the ukevent structure t=
o
>   contain an index of the next entry written the same CPU.
>=20
>   Another problem this entails is false sharing of the ring buffer
>   entries.  This would probably require to pad the ukevent structure
>   to 64 bytes.  It's not that much more, 40 bytes so far, it's
>   also more future-safe.  The alternative is to allocate have per-CPU
>   regions in the ring buffer.  With hotplug CPUs this is just plain
>   silly.
>=20
>   I think this optimization has the potential to help quite a bit,
>   especially for large machines.

I think again that complete removal of ring buffer and its
implementation in userspace wrapper and kevent_get_events() is a good
idea. But probably I'm alone thinking in that direction, so let's think
about ring buffer in kernelspace.

It is possible to specify CPU id in kevent (not in ukevent, i.e. not
in shared by userspace structure, but in it's kernel representation),
and then check if currently active CPU is the same or not, but what if
it is not the same CPU? Entry order is important, since application can
take advantage of synchronization, so idea to skip some entries is bad.

> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> - we absolutely need an interface to signal the kernel that a thread,
>   just woken from kevent_wait, cannot handle the events.  I.e., the
>   events are in the ring buffer but all the other threads are in the
>   kernel in their kevent_wait calls.  The new syscall would wake up
>   one or more threads to handle the events.
>=20
>   This syscall is for instance necessary if the thread calling
>   kevent_wait is canceled.  It might also be needed when a thread
>   requested more than one event and realizes processing an entry
>   takes a long time and that another thread might work on the other
>   items in the meantime.

Hmm, send a signal to other thread when glibc cancells given one...
This problem points me to the idea of userspace thread implementation I
have in mind, but it is another story.

It is management task - kernel should not even know about someone has
died and can not process events it requested.
Userspace can open a control pipe (and setup a kevent handler for it)=20
and glibc will write there a byte thus awakening some other thread.
It can be done in userspace and should be done in userspace.

If you insist I will create userspace kevent handling - userspace will
be able to request kevents and mark them as ready.
=20
>   Al Viro pointed out another possible solution which also could solv=
e
>   the "handled" flag problem and concurrency in use of the ring buffe=
r.
>=20
>   The idea is to require the kevent_wait() syscall to signal which en=
try
>   in the ring buffer is handled or not handled.  This means:
>=20
>   + the kernel knows at any time which entries in the buffer are free
>     and which are not
>=20
>   + concurrent filling of the ring buffer is no problem anymore since
>     entries are not discarded until told
>=20
>   + by not waiting for event (num parameter =3D=3D 0) the syscall can=
 be
>     used to discard entries to free up the ring buffer before continu=
ing
>     to work on more entries.  And, as per the requirement above, it c=
an
>     be used to tell the kernel that certain entries are *NOT* handled
>     and need to be sent to another thread.  This would be useful in t=
he
>     thread cancellation case.
>=20
>   This seems like a nice approach.

But unfortunately theory and practice are different in a real world.
Kernel has millions of entries in _linear_ ring buffer, how do you thin=
k
they should be handled without complex protocol between userspace and
kernelspace? In that protocol userspace is required to transfer some
information to kernelspace so it could find the entry (i.e. per entry
field ! ), and then it should have a tree or other mechanism to store
free and used chunks of entries...

You probably did not see my network tree allocator patches I posted in
lkml@, netdev@ and linux-mm@ lists - it is quite big chunk of code whic=
h
handles exactly that, but you do not want to implement it in glibc I
think...

So, do not overdesign.

And as a side note, btw - _all_ above can be implemented in userspace.

> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> - why no syscall to create kevent queue?  With dynamic /dev this migh=
t
>   be a problem and it's really not much additional code.  What about
>   programs which want to use these interfaces before /dev is set up?

It was there - Cristoph Hellwig removed it in his API cleanup patch, so
far it was not needed at all (and is not needed for now).
That application can create /dev file by itself if it wants... Just a
though.

> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> - still: the syscall should use a struct timespec* timeout parameter
>   and not nanosecs.  There are at least three timeout modes which
>   are wanted:
>=20
>   + relative, unconditionally wait that long
>=20
>   + relative, aborted in case of large enough settimeofday() or NTP
>     adjustment
>=20
>   + absolute timeout.  Probably even with selecting which clock ot us=
e.
>     This mode requires a timespec value parameter
>=20
>=20
>   We have all this code already in the futex syscall.  It just needs =
to
>   be generalized or copied and adjusted.

Will we discuss it for death?

Kevent does not need to have absolute timeout.

Because timeout specified there is always related to the start of
syscall, since it is a timeout which specifies maximum time frame
syscall can live.

All such timeouts _ARE_ relative and should be relative since it is
correct.

> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> - still: no signal mask parameter in the kevent_wait (and get_event)
>   syscall.  Regardless of what one thinks about signals, they are use=
d
>   and integrating the kevent interface into existing code requires
>   this functionality.  And it's not only about receiving signals.
>   The signal mask parameter can also be used to _prevent_ signals fro=
m
>   being delivered in that time.

I created kevent_signal notifications - it allows user to setup any set
of interested signals before call to kevent_get_events() and friends.

No need to solve a problem with operation way when there is tactical an=
d
strategical ones - kevent signal is that way which allows not to use
workarounds for interfaces which do not support handling of different
types of events except file descriptors.

> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> - the KEVENT_REQ_WAKEUP_ONE functionality is good and needed.  But I
>   would reverse the default.  I cannot see many places where you want
>   all threads to be woken.  Introduce KEVENT_REQ_WAKEUP_ALL instead.

I.e. to wake up only first thread always and in addon those threads
which have specified flag set? Ok, will put into todo foer the next
release.

> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> - there is really no reason to invent yet another timer implementatio=
n.
>   We have the POSIX timers which are feature rich and nicely
>   implemented.  All that is needed is to implement SIGEV_KEVENT as a
>   notification mechanism.  The timer is registered as part of the
>   timer_create() syscalls.

=46eel free to add any interface you like - it is as simple as call for
kevent_user_add_ukevent() in userspace.

> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
>=20
> I haven't yet looked at the other event sources.  I think the above i=
s
> enough for now.

It looks like you generate ideas (or move them into different
implementation layer) faster than I implement them :)
And I almost silently stay behind with the fact that it is possbile to
implement _all_ above ring buffer things in userspace with
kevent_get_events() and this functionality is there for almost a year :=
)

Let's solve problem in order of theirs appearance - what do you think
about above interface for ring buffer?
=20
> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
