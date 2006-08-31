From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take14 0/3] kevent: Generic event handling mechanism.
Date: Thu, 31 Aug 2006 11:58:52 +0400
Message-ID: <20060831075852.GB21660@2ka.mipt.ru>
References: <11564996832717@2ka.mipt.ru> <44F208A5.4050308@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:64206 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751228AbWHaICd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 04:02:33 -0400
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <44F208A5.4050308@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Sorry ofr long delay - I was on small vacations.

On Sun, Aug 27, 2006 at 02:03:33PM -0700, Ulrich Drepper (drepper@redha=
t.com) wrote:
> [Sorry for the length, but I want to be clear.]
>=20
> As promised, before Monday (at least my time), here are my thoughts o=
n
> the proposed kevent interfaces.  Not necessarily well ordered:
>=20
>=20
> - one point of critique which applied to many proposals over the year=
s:
>   multiplexer syscalls a bad, really bad.  They are more complicated
>   to use at userlevel and in the kernel.  We've seen more than once t=
hat
>   unimplemented functions are not reported correctly with ENOSYS.  Ju=
st
>   use individual syscalls.  Adding them is cheap and probably overall
>   less expensive than the multiplexer.

Can you convince Christoph?
I do not care about interfaces, but until several people agree on it, I
will not change anything.

> Events to wait for are basically all those with syscalls which can
> potentially block indefinitely:
>=20
> - file descriptor
> - POSIX message queues (these are in fact file descriptors but
>   let's make it legitimate)
> - timer expiration
> - signals (just as sigwait, not normal delivery instead of a handler)
> - futexes (needs a lot more investigation)
> - SysV message queues
> - SysV semaphores
> - bind socket operations (Alan brought this up in a different context=
)
> - delays (nanosleep/clock_nanosleep, could be done using timers but t=
he
>   overhead would likely be too high)
> - process state change (waitpid, wait4, waitid etc)
> - file locking (flock, lockf)
> -

You completely miss AIO here (I talk not about POSIX AIO).

> We might also want to think about
>=20
> - msync/fsync: Today's wait/no-wait option doesn't allow us to work o=
n
>   other things if the sync takes time and we need a real notification
>   (i.e., if no-wait cannot be used)
>=20
>=20
> The reporting must of course provide the userlevel code with enough
> information to identify the request.  For submitting requests we need
> such identification, too, so having unique identifiers for all the
> different event types is necessary.  So some extend this is what the
> KEVENT_TIMER_FIRED, KEVENT_SOCKET_RECV, etc constants do.  But they
> should be more generic in their names since we need to use them also
> when registering the even.  I.e., KEVENT_EVENT_TIMER or so is more
> appropriate.

There are such identifiers.
We have _two_ levels of id=20
 - event type (KEVENT_EVENT_TIMER,
KEVENT_EVENT_POLL, KEVENT_EVENT_AIO and so one, but they are called
without _EVENT_ inside), which is type of origin for given events
 - events itself - timer fired, data received, client accepted and so
   on.

> Often (most of the time) this ID and the actual descriptor (file
> descriptor, message queue descriptor, signal number, etc) is not
> sufficient.  In the POSIX API we therefore usually have a cookie valu=
e
> which the userlevel code can provide and which is returned unchanged =
as
> part of the notification.  See the sigev_value member of struct
> sigevent.  I think this is the best approach: is compact and it gives
> all the flexibility needed.  Userlevel code will store a value or mor=
e
> often a pointer in the cookie and can then access additional informat=
ion
> based of the cookie.

kevents have such "cookies".

> I know there is a controversy around using pointer-sized values in
> kernel structures which are exposed to userlevel.  It should be possi=
ble
> to work around this.  We can simply always use 64-bit values and when
> the data structure is exposed to 32-bit userland code only the first =
or
> second 32-bit word of the structure is exposed with the name.  The ot=
her
> word is padding.  If planned in from the beginning this should not ca=
use
> any problems at all.

I use union of two 32bit values and pointer to simplify userspace.
It was planned and implemented already.

> Looking at the current struct mukevent, I don't think it is sufficien=
t.
>  We need more room for the various types of events.  And we shouldn't
> prevent future innovative uses.  I suggest to create records of a fix=
ed
> size with sufficient room.  Maybe 32 bytes are sufficient but I'd lea=
ve
> this open for can until the very end.  Members of the structure must =
be
> - ID if the type of event; type int
> - descriptor (file descriptor, SysV msg descriptors etc); type int
> - user-provided cookie; type uint64_t
> That's only 16 bytes so far but we'll likely need more for some uses.

I use there only id provided by user, it is not his cookie, but it was
done to make strucutre as small as possible.
Think about size of the mapped buffer when there are several kevent
queues - it is all mapped and thus pinned memory.
It of course can be extended.

> Next, the current interfaces once again fail to learn from a mistake =
we
> made and which got corrected for the other interfaces.  We need to be
> able to change the signal mask around the delay atomically.  Just lik=
e
> we have ppoll for poll, pselect for select (and hopefully soon also
> epoll_pwait for epoll_wait) we need to have this feature in the new
> interfaces.

We able to change kevents atomically.
=20
> I read the description Nicholas Miell produced (the example programs
> aren't available, accessing the URL fails for me) and looked over the
> last patch (take 14).
>=20
> The biggest problem I see so far is the integration into the existing
> interfaces.  kevent notification *really* should be usable as a new
> sigevent type.  Whether the POSIX interfaces are liked by kernel folk=
s
> or not, they are what the majority of the userlevel programmers use.
> The mechanism is easily extensible.  I've described this in my paper.=
  I
> cannot comment on the complexity of the kernel side but I'd imagine i=
t's
> not much more difficult, just different from what is implemented now.
> Let's learn for a change from the mistakes of the past.  The new and
> innovative AIO interfaces never took off because their implementation
> differs so much from the POSIX interfaces.  People are interested in
> portable code.  So, please, let's introduce SIGEV_KEVENT.  Then we
> magically get timer notification etc for free.

Well, I rarely talk about what other people want, but if you strongly
feel, that all posix crap is better than epoll interface, then I can no=
t
agree with you.

It is possible to create additional one using any POSIX API you like,
but I strongly insist on having possibility to use lightweight syscall
interface too.

> The ring buffer interface is not described in Nicholas' description.
> I'm looking at the sources and am a bit baffled.  For instance, the
> kevent_user_ring_add_event function simply adds an event without
> determining whether this overwrites an undelivered entry.  One single
> index into the buffer isn't sufficient for this anyway.  So let me as=
k
> some questions:
>=20
> - how is userlevel code supposed to locate events in the buffer?  We
>   can maintain a separate pointer for the ring buffer (in a separate
>   location, which might actually be good for CPU cache reasons).  But
>   this cannot solve all problems.  E.g., if the read pointer is
>   initialized to zero (as is the write pointer), the ring buffer fits=
 N
>   entries, if now N+1 entries arrive before the first event is handle=
d
>   by the userlevel code, how does the userland code know that all rin=
g
>   buffer entries are valid?  If the code supposed to always scan the
>   entire buffer?

Ring buffer _always_ has space for new events until queue is not filled=
=2E
So if userspace do not read for too much time it's events and eventuall=
y
tries to add new one, it will fail early.

> - we need to signal the ring buffer overflow in some form to the
>   userlevel code.  What proposals have been made for this?  Signals
>   are the old and tried mechanism.  I.e., one would be allowed to
>   associate a signal with each kevent descriptor and receive overflow
>   notifications this way.  When rt signals are used we event can get
>   the kevent descriptor and the possible a user cookie delivered.
>   Something like this is needed in case such a kevent queue is used
>   in library code where we cannot rely on being the only user for an
>   event.

There is no overflow - I do not want to introduce another signal queue
overflow crap here.
And once again - no signals.

> I must admit I haven't spent too much time thinking about the ideal r=
ing
> buffer interface.  At OLS there were quite a few people (like Zach) w=
ho
> said they did.  So, let's solicit advice.  I think the kernel AIO
> interface can also provide some info on what not to do.

Sure, I would like to see different design if it is ready.

> One aspect of the interface I did think about: the delay syscall.  I
> already mentioned the signal mask issue above.  The interface already
> has a timeout value (good!).  But we need to specify the semantics qu=
ite
> detailed to avoid problems.
>=20
> What I mean by that is the problem we are facing if there is more tha=
n
> one thread waiting for events.  If no event is available all threads =
use
> the delay syscall.  If now an event becomes available, what do we do?
> Do we want exactly one thread?  This is a problem.  The thread might =
not
> be working on the event after it gets woken (e.g., because the thread
> gets canceled).  The result is that there is an event available and n=
o
> other thread gets woken.  This can be avoided by requiring that if a
> thread, which got woken from a delay syscall, doesn't use the event, =
it
> has to wake another thread.  But how do we do this?

I can reformulate your words in a different manner. PLease correct me i=
f
I'm wrong.

You basically want to deliver the same event to several users.
But how do you want to achive it with network buffers for example.
When several threads reads from the same socket, they do not obtain the
same data.
So I disagree that we need to deliver some events to several threads. I=
f
you need to wake up several ones when one network socket is ready (I
seriously doubt you want), create per-thread kevent queue and put that
socket into them.
You want to wake several threads on timeout - create per-thread queue
and put there an event.

The more simple interface is, the less problems we will catch when some
tricky configuration is used.

> One possibility I could see is that the delay syscall returns the eve=
nt
> which caused the thread to be woken.  This event is _not_ also report=
ed
> in the ring buffer.  Then, if the thread does not use the event, it
> simply requeues it.  This will then implicitly wake another delayed t=
hread.
>=20
> Which brings me to the second point about the current kevent_get_even=
ts
> syscall.  I don't think the min_nr parameter is useful.  Probably we
> should not even allow the kevent queue to be used with different max_=
nr
> parameters in different thread.  If you'd allow this, how would the
> event notification be handled?  A waiter with a smaller required numb=
er
> of events would always be woken first.  I think the number of require=
d
> events should be a property of the kevent object.  Then the code woul=
d
> create different kevent object if the requirement is different.  At t=
he
> very least I'd declare it an error if at any time there are two or mo=
re
> threads delayed which have different requirements on the number of
> events.  This could provide all the flexibility needed while preventi=
ng
> some of the mistakes one can make.
=20
min_nr is used to specify special case "wake up when at least one event=
=20
is ready and get all ready ones".
=20
> In summary, I don't think we're at the point where the current
> interfaces are usable.  I'd like to see them redesigned and
> reimplemented.  The bad news is that I'll not be able to help with th=
e
> coding.  The somewhat good news is that I can given some more
> recommendations.  In general I still think the text from my OLS paper
> applies:

I can do it.
But I will not, until other core developers acks your proposals.
As I described above I disagree with most of them.
=20
> - one syscall to create a kevent queue.  Using a special filesystem l=
ike
>   take 14 does is OK.  But who do you pass parameters like the maximu=
m
>   number of expected outstanding events?  I think a dedicated syscall=
 is
>   better.  It also works more reliably since /proc might not be yet

There are no "expected outstanding events", I think it can be a problem=
=2E
Currently there is absolute maximum of events, which can not be
increased in real-time.

>   mounted when the first user of the interface is started.  The resul=
t
>   should be a file descriptor.  At least an object which can be handl=
ed
>   like a file descriptor when it comes to transmitting it over Unix
>   domain sockets.  Questions to answer: what happens if you use the
>   descriptor with any other interface but the kevent interfaces (I th=
ink
>   all such calls like dup, read, write, ... should fail).
>
>   int kevent_init (int num);

Kevent always provides file descriptor (which is "poll"able) as result
of either opening of special file (like in the latest patchset), or
using special filesystem (which was removed by Christoph).

> - one system call to create the userlevel ring buffer.  Simply
>   overloading the mmap operation for the special kevent filesystem ca=
n
>   work so no separate syscall is needed in that case.  We need to
>   nail down the semantics, though.  What happens if more than one mma=
p
>   call is made?  Does only the last one count?  Does the second one
>   fail?  Will mremap() work to increase/descrease the size?  Will
>   mremap() be allowed to be called with MREMAP_MAYMOVE?  What if mmap=
()
>   is called from different processes (in the POSIX sense, i.e., from
>   different address spaces)?
>=20
>   Either
>=20
>    mmap(...)
>=20
>   Or
>=20
>    int kevent_map_ringbuf (int kfd, size_t num)

Each subsequent mmap will mmap existing buffers, first one mmap can
create that buffer.
=20
> - one interface to set additional parameters.  This is likely mostly =
to
>   make the interfaces safe for the future.  Perhaps the number of eve=
nts
>   needed per delay call should be set this way.
>=20
>     int kevent_ctl (int kfd, int cmd, ...)
>=20
>=20
> - one interface to shut the kevent down.  This might be overkill.  We
>   should be able to use munmap() and close().  If a real interface fo=
r
>   this would be created it should look like this
>=20
>    int kevent_destroy (int kfd, void *ringbuf, size_t num)
>=20
>   I find this rather more cumbersome.  Just use close and munmap.
>=20
>=20
> - one interface to submit requests.
>=20
>     int kevent_submit (int kfd, struct kevent_event *ev, int flags,
>                        struct timespec *timeout)
>=20
>   Maybe the flags parameter isn't needed, it's just another way to ma=
ke
>   sure we won't regret the design later.  If the ring buffer can fill=
 up
>   and this is detected by the kernel (unlike what happens in take 14)

Just a repeat - with current buffer implementation it can not happen -
maximum  queue length is a limit for buffer size.

>   then the calling thread could be delayed undefinitely.  Maybe we ev=
en
>   have a deadlock if there is only one thread.  If only a wait/no-wai=
t
>   mode is needed, then use only a flags parameter and no timeout
>   parameter.
>=20
>   A special variant should be if ev =3D=3D NULL the call is taken as =
a
>   request to wake one or more delayed threads.

Well, you propose three different syscalls for threee operations. I use
one with multiplexer. I do not have strong opinion on how it must be
done, but I created a policy for such changes - until other developers
ack such changes, nothing will be done.
=20
> - one interface to delay threads until the next event becomes availab=
le.
>   No data is transfered along with the call.  The event data must be
>   read from the ring buffer:
>=20
>     int kevent_wait (int kfd, unsigned ringstate,
>                      const struct timespec *timeout,
>                      const sigset_t *sigmask)

Yes, I agree, this is good syscall.
Except signals (no signals, that's the rule) and variable sized timespe=
c
structure. What about putting there u64 number of nanoseconds?

>   Wait-mode can be implemented by recognizing timeout=3D=3DNULL.  no-=
wait
>   mode is implemented using timeout->tv_sec=3D=3Dtimeout->tv_nsec=3D=3D=
0.  If
>   sigset_t is NULL the signal mask is not changed.
>=20
>   The ringstate parameter is also not present in the take 14 proposal=
=2E
>   Something like it is necessary to prevent the thread from going to
>   sleep while there are events in the ring buffer.  It would be very
>   wasteful if the kernel would have to keep track of outstanding
>   events.  This would also mean then handling events would require
>   a system call, exactly what the ring buffer approach should prevent=
=2E

It is possible to put there a number of the last "acked" kevent, so
kernel will remove all events which were placed into the buffer before
and including this one.

>   I think the sequence for waiting for an event should be like this:
>=20
>     + get current ring state
>     + check whether any outstanding event in ring buffer
>     + if yes, copy data out of ring buffer, mark ring buffer record
>       as unused (atomically).
>     + if no, call kevent_wait with ring state value
>
>   When the kernel delivers a new event it does:
>=20
>     + find place to store event
>     + change ring state (might be a simple counter)

What about following:
userspace:
 - check ring index, if it differs from stored in userspace, then there
   are events between old stored index and new one just read.
 - copy events
 - call kevent_wait() or other method to show kernel that all events
   upto provided in syscall numbers are processed, and thus kernel can
   remove them and put there new ones.

kernelspace:
 - when new kevent is added, it guarantees that there is a place for it
   in kernel ring buffer
 - when event is ready it is copied into mapped buffer and index of the
   "last ready" is increased (it is fully atomic operation)
 - when userspace calls kevent_wait() kernel get ring index from
   syscall, searches for all events upto provided number and free them
   (or rearm)
  =20

Except kevent_wait() imeplementation it is how it is implemented right
now.

>   The kevent_wait implementation in the kernel would then as the firs=
t
>   thing determine whether the ring state changed.  If yes, the syscal=
l
>   returns immediate with -ENWOULDBLOCK.  Otherwise it is queued for
>   waiting.
>=20
>   With these steps and the requirement that all ring buffer entries a=
re
>   processed FIFO we can
>   a) avoid syscalls to avoid freeing ring buffer entries
>   b) detect overflows in the ring buffer
>   c) can maintain the read pointer at userlevel while the kernel can
>      maintain the write pointer into the buffer

As shown above it is already implemented.
=20
> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View, CA =E2=9D=96
>=20



--=20
	Evgeniy Polyakov
