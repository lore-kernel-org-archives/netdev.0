From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Mon, 20 Nov 2006 11:25:01 +0300
Message-ID: <20061120082500.GA25467@2ka.mipt.ru>
References: <11630606361046@2ka.mipt.ru> <45564EA5.6020607@redhat.com> <20061113105458.GA8182@2ka.mipt.ru> <4560F07B.10608@redhat.com>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934003AbWKTI0z@vger.kernel.org>
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <4560F07B.10608@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 19, 2006 at 04:02:03PM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >>Possible solution:
> >>
> >>a) it would be possible to have a "used" flag in each ring buffer e=
ntry.
> >>   That's too expensive, I guess.
> >>
> >>b) kevent_wait needs another parameter which specifies the which is=
 the
> >>   last (i.e., least recently added) entry in the ring buffer.
> >>   Everything between this entry and the current head (in ->kidx) i=
s
> >>   occupied.  If multiple threads arrive in kevent_wait the highest=
 idx
> >>   (with wrap around possibly lowest) is used.
> >>
> >>   kevent_wait will not try to move more entries into the ring buff=
er
> >>   if ->kidx and the higest index passed in to any kevent_wait call
> >>   is equal (i.e., the ring buffer is full).
> >>
> >>   There is one issue, though, and that is that a system call is ne=
eded
> >>   to signal to the kernel that more entries in the ring buffer are
> >>   processed and that they can be refilled.  This goes against the
> >>   kernel filling the ring buffer automatically (see below)
> >
> >If thread calls kevent_wait() it means it has processed previous ent=
ries,=20
> >one can call kevent_wait() with $num parameter as zero, which
> >means that thread does not want any new events, so nothing will be
> >copied.
>=20
> This doesn't solve the problem.  You could only request new events wh=
en=20
> all previously reported events are processed.  Plus: how do you repor=
t=20
> events if the you don't allow get_event pass them on?

Userspace should itself maintain order and possibility to get event in
this implementation, kernel just returns events which were requested.
=20
> >Writable ring buffer does not sound too good to me - what if one thr=
ead
> >will overwrite the whole ring buffer so kernel's indexes can be scre=
wed?
>=20
> Agreed, there are problems.  This is why I suggested the ring buffer =
can=20
> be a structured.  Parts of it might be read-only, other parts=20
> read/write.  I don't necessarily think the 'used' flag is the right w=
ay.=20
>  And front/tail pointer solution seems to be better.
>=20
>=20
> >Ring buffer processed not in FIFO order is wrong idea
>=20
> Not necessarily, see my comments about CPU affinity in the previous m=
ail.
>=20
>=20
> >- ring buffer can
> >be potentially very big and searching there for the entry, which was
> >been marked as 'free' by userspace is not a solution at all - usersp=
ace
> >in that case must provide ukevent so fast tree search would be used,
> >(and although it is already possible) it requires userspace to make
> >additional syscalls which is not what we want.
>=20
> It is not necessary.  I've proposed to only have a fron and tail=20
> pointer.  The tail pointer is maintained by the application and passe=
d=20
> to the kernel explicitly or via shared memory.  The kernel maintains =
the=20
> front pointer.  No tree needed.

There was such implementation (in previous patchset) - sine no one
commented, I changed that.
=20
> >As a solution I can create folowing scheme:
> >there are two syscalls (or one with a switch) which get events and
> >commits them.
> >
> >kevent_wait() becomes a syscall which waits until number of events o=
r
> >one of them becomes ready and just copies them into ring buffer and
> >returns. kevent_wait() will fail with special error code when ring
> >buffer is full.
> >
> >kevent_commit() frees requested number of events _from the beginning=
_,
> >i.e. from special index, visible from userspace. Userspace can creat=
e
> >special counters for events (and even put them into read-only ring=20
> >buffer overwriting some fields of kevent, especially if we will incr=
ease
> >it's size) and only call kevent_commit() when all events have zero u=
sage
> >counter.
>=20
> Right, that's basically the front/tail pointer implementation.  That=20
> would work.  You just have to make sure that the kevent_wait() call=20
> takes the current front pointer/index as a parameter.  This way if th=
e=20
> buffer gets filled between the thread checking the ring buffer (and=20
> finding it empty) and the syscall being handled the thread is not sus=
pended.

It is exactly how previous ring buffer (in mapped area though) was
implemented.

I think I need to quickly setup my slightly used (bought on ebay) but
still working mind reader, I will try to tune it to work with your brai=
n
waves so next time I would not spent weeks changing something which
could be reused, while others keep silent :)
=20
> >I disagree that having possibility to have holes in the ring buffer =
is a
> >good idea at all - it requires much more complex protocol, which wil=
l
> >fill and reuse that holes, and the main disavantge - it requires to
> >transfer much more information from userspace to kernelspace to free=
 the
> >ring entry in the hole - in that case it is already possible just to
> >call kevent_ctl(KEVENT_REMOVE) and do not wash the brain with new
> >approach at all.
>=20
> Well, it would require more data transport of we'd use writable share=
d=20
> memory.  But I agree, it's far too complicated and might not scale wi=
th=20
> growing ring buffer sizes.
>=20
>=20
> >>- implementing the kevent_wait syscall the proposed way means we ar=
e
> >>  missing out on one possible optimization.  The ring buffer is
> >>  currently only filled on kevent_wait calls.  I expect that in rea=
lly
> >>  high traffic situations requests are coming in at a higher rate t=
han
> >>  the can be processed.  At least for periods of time.  If such
> >>  situations it would be nice to not have to call into the kernel a=
t
> >>  all.  If the kernel would deliver into the ring buffer on its own
> >>  this would be possible.
> >
> >Well, it can be done on behalf of workqueue or dedicated thread whic=
h
> >will bring up appropriate mm context,
>=20
> I think it should be done.  It's potentially a huge advantage.
>=20
>=20
> >although it means that userspace
> >can not handle the load it requested, which is a bad sign...
>=20
> I don't understand.  What is not supposed to work?  There is nothing=20
> which cannot work with automatic posting since the get_event() call d=
oes=20
> nothing but copying the event data over and wake a thread.
=20
If userspace is too slow to get events, dedicated thread or workqueue
will be busy unneded things, although they can allow to remove peaks in
the load.

> >>- the kevent_get_event syscall is not  needed at all.  All reportin=
g
> >>  should be done using a ring buffer.  There really is not reason t=
o
> >>  keep two interfaces around  which serve the same purpose.  Making
> >>  the argument the kevent_get_event is so much easier to use is not
> >>  valid.  The exposed interface to access the ring buffer will be e=
asy,
> >>  too.  In the OLS paper I more or wait hinted at the interfaces.  =
I
> >>  think they should be like this (names are irrelevant):
> >
> >Well, kevent_get_events() _is_ much easier to use. And actually havi=
ng
> >only that interface it is possible to implement ring buffer with any
> >kind or protocol for its controlling - userspace can have a wrapper
> >which will call kevent_get_events() with pointer which shows to the
> >place in the shared ring buffer where to place new events, that wrap=
per
> >can handle essentially any kind of flags/parameters which are suitab=
le
> >for that ring buffer implementation.
>=20
> That's far too slow.  The whole point behind the ring buffer is speed=
=2E=20
> And emulation would defeat the purpose.
=20
It was an example, I do not say ring-buffer maintained in kernelspace i=
s
bad idea. Actually it is possible to create several threads which will
only read events into the buffer, which will be processed by some pool =
of=20
'working' threads. There are a lot of possibilities to work with only
one syscall and create scalable system.

> >But since we started to implement ring buffer as a additional featur=
e of
> >kevent, let's find the way all people will be happy with before remo=
ving
> >something which was proven to work correctly.
>=20
> The get_event interface is basically the userlevel interface the runt=
ime=20
> (glibc probably) would provide.  Programmers don't see the complexity=
=2E
>=20
> I'm concerned about the get_event interface holding the kernel=20
> implementation back.  For instance, automatic filling the ring buffer=
=2E=20
> This would not be possible if the program is free to mix=20
> kevent_get_event and kevent_wait calls freely.  If you do away with t=
he=20
> get_event syscall the automatic ring buffer filling is possible and a=
=20
> logical extension.
=20
Yes, that is why only one should be used.
If there are several threads, then ring buffer implementation should be
used otherwise just kevent_get_events().
In theory yes, access library like glibc can provide kevent_get_events(=
)
which will read event from ring buffer, but there is no such call right
now, so kernel's kevent_get_events() looks reasonable.

> >The last three are exactly kevent_get_events() with different set of
> >parameters - it is possible to get events without sleeping, it is
> >possible to wait until at least something is ready and it is possibl=
e to
> >sleep for timeout.
>=20
> Exactly.  But these interfaces should be implemented at userlevel, no=
t=20
> at the syscall level.  It's not necessary.  The kernel interface shou=
ld=20
> be kept as small as possible and the get_event syscall is pure duplic=
ation.

I would say that ring-buffer mainpulating syscalls are duplicatino, but
it is just matter of a view :)
=20
> >They all already imeplemented. Just all above, and it was done sever=
al
> >months ago already. No need to reinvent what is already there.
> >Even if we will decide to remove kevent_get_events() in favour of ri=
ng
> >buffer-only implementation, winting-for-event syscall will be
> >essentially kevent_get_events() without pointer to the place where t=
o
> >put events.
>=20
> Right, but this limitation of the interface is important.  It means t=
he=20
> interface of the kernel is smaller: fewer possibilities for problems =
and=20
> fewer constraints if in future something should be changed (and small=
er=20
> kernel).

Ok, lets see for ring buffer implementation right now, and then we will
decide if we want to remove or to stay with kevent_get_events() syscall=
=2E
=20
> >I agree that having special syscall to initialize kevent is a good i=
dea,
> >and initial kevent implementation had it, but it was removed due to =
API
> >cleanup work by Cristoph Hellwing.
>=20
> Well, he is wrong.  If, for instance, init or any of the programs whi=
ch=20
> start first wants to use the syscall it couldn't because /dev isn't=20
> mounted.  The program might use libraries and therefore not have any=20
> influence on whether the kevent stuff is used or not.
>=20
> Yes, the /dev interface is useful for some/many other kernel interfac=
es.=20
>  But this is a core interface.  For the same reason epoll_create is a=
=20
> syscall.

Ok, I will create initialization syscall.

> >Do you have _any_ kind of benchmarks with epoll() which would show t=
hat
> >it is feasible? ukevent is one cache line (well, 2 cache lines on ol=
d
> >CPUs), which can be setup way too far away from the time when it is
> >ready, and CPU which origianlly set that up can be busy, so we will =
lose
> >performance waiting until CPU becomes free instead of calling other
> >thread on different CPU.
>=20
> If the period between the generation of the event (e.g., incoming=20
> network traffic or sent data) and the delivery of the event by waking=
 a=20
> thread is too long, it makes not too much sense.  But if the L2 cache=
=20
> hasn't hasn't been flushed it might be a big advantage.
>=20
> I think it's reasonable to only have the last queued entry for a CPU=20
> handled special.  And note, this is only ever a hint.  If an event en=
try=20
> was created by the kernel in one CPU but none of the threads which wa=
it=20
> to be waken is on that CPU, nothing has to be done.
>=20
> No, I don't have a benchmark.  But it is likely quite easily possible=
 to=20
>  create a synthetic benachmark.  Maybe with pipes.
>=20
>=20
> >It is possible to specify CPU id in kevent (not in ukevent, i.e. not
> >in shared by userspace structure, but in it's kernel representation)=
,
> >and then check if currently active CPU is the same or not, but what =
if
> >it is not the same CPU?
>=20
> Nothing special.  It's up to the userlevel wrapper code.  The CPU num=
ber=20
> would only be a hint.
>=20
>=20
> >Entry order is important, since application can
> >take advantage of synchronization, so idea to skip some entries is b=
ad.
>=20
> That's something the application should be make a call about.  It's n=
ot=20
> always (or even mostly) the case that the ordering of the notificatio=
n=20
> is important.  Furthermore, this would also require the kernel to=20
> enforce an ordering.  This is expensive on SMP machines.  A locally=20
> generated event (i.e., source and the thread reporting the event) can=
 be=20
> delivered faster than an event created on another CPU.

How come? If signal was delivered earlier than data arrived, userspace
should get signal before data - that is the rule. Ordering is maintaine=
d
not for event insertion, but for marking them ready - it is atomic, so
who first starts to mark even ready, that event will be read first from
the ready queue.
=20
> >It is management task - kernel should not even know about someone ha=
s
> >died and can not process events it requested.
>=20
> But the kernel has to be involed.
>=20
>=20
> >Userspace can open a control pipe (and setup a kevent handler for it=
)=20
> >and glibc will write there a byte thus awakening some other thread.
> >It can be done in userspace and should be done in userspace.
>=20
> That's invasive.  The problem is that no userlevel interface should h=
ave=20
> to implicitly keep file descriptors open.  This would mean the=20
> application would be influenced since suddenly a file descriptor is n=
ot=20
> available anymore.  Yes, applications shouldn't care but they=20
> unfortunately sometimes do.

Then I propose userspace notifications - each new thread can register
'wake me up when userspace event 1 is ready' and 'event 1' will be
marked as ready by glibc when it removes the thread.
=20
> >Will we discuss it for death?
> >
> >Kevent does not need to have absolute timeout.
>=20
> Of course it does.  Just because you don't see a need for it for your=
=20
> applications right now it doesn't mean it's not a valid use.

Please explain why glibc AIO uses relatinve timeouts then :)
=20
> >Because timeout specified there is always related to the start of
> >syscall, since it is a timeout which specifies maximum time frame
> >syscall can live.
>=20
> That's your current implementation.  There is absolutely no reason=20
> whatsoever why this couldn't be changed.

It has nothing with implementation - it is logic. Something starts and
it has its maximum lifetime, but not something starts and should be
stopped Jan 1, 2008. In the latter case one can setup a timer, but it
does not allow to specify maximum lifetime. If glibc posix sleeping
functions converts relatinve AIO timeouts into absolute it does not mea=
n
all should do it. It is just not needed.

> >I created kevent_signal notifications - it allows user to setup any =
set
> >of interested signals before call to kevent_get_events() and friends=
=2E
> >
> >No need to solve a problem with operation way when there is tactical=
 and
> >strategical ones
>=20
> Of course there is a need and I explained it before.  Getting signal=20
> notifications is in no way the same as changing the signal mask=20
> temporarily.  You cannot correctly emulate the case where you want to=
=20
> block a signal while in the call as reenable it afterwards.  Receivin=
g=20
> the signal as an event and then artificially raising it is not the sa=
me.=20
>  Especially timing-wise, the signal kevent might not be seen long aft=
er=20
> the syscall returns because other entries are worked on first.
>=20
> The opposite case is equally impossible to emulate: unblocking a sign=
al=20
> just for the duration of the syscall.  These are all possible and use=
d=20
> cases.
=20
Add and remove appropriate kevent - it is as simple as call for one
function.

> >>- the KEVENT_REQ_WAKEUP_ONE functionality is good and needed.  But =
I
> >>  would reverse the default.  I cannot see many places where you wa=
nt
> >>  all threads to be woken.  Introduce KEVENT_REQ_WAKEUP_ALL instead=
=2E
> >
> >I.e. to wake up only first thread always and in addon those threads
> >which have specified flag set? Ok, will put into todo foer the next
> >release.
>=20
> It's a flag for an event.  So the threads won't have the flag set.  I=
f=20
> an event is delivered with the flag set, wake all threads.  Otherwise=
=20
> just one.

Ok.
=20
> >>- there is really no reason to invent yet another timer implementat=
ion.
> >>  We have the POSIX timers which are feature rich and nicely
> >>  implemented.  All that is needed is to implement SIGEV_KEVENT as =
a
> >>  notification mechanism.  The timer is registered as part of the
> >>  timer_create() syscalls.
> >
> >Feel free to add any interface you like - it is as simple as call fo=
r
> >kevent_user_add_ukevent() in userspace.
>=20
> No, that's not what I mean.  There is no need for the special=20
> timer-related part of your patch.  Instead the existing POSIX timer=20
> syscalls should be modified to handle SIGEV_KEVENT notification.  Aga=
in,=20
> keep the interface as small as possible.  Plus, the POSIX timer=20
> interface is very flexible.  You don't want to duplicate all that=20
> functionality.

Interface is already there with kevent_ctl(KEVENT_ADD), I just created
additional entry, which describes timers enqueue/dequeue callbacks - I
have not invented new interfaces, just reused existing generic kevent
facilities. It is possible to add timer events from any other place.
=20
> >And I almost silently stay behind with the fact that it is possbile =
to
> >implement _all_ above ring buffer things in userspace with
> >kevent_get_events() and this functionality is there for almost a yea=
r :)
>=20
> Again, this defeats the purpose completely.  The ring buffer is the=20
> faster interface, especially when coupled with asynchronous filling o=
f=20
> ring buffer (i.e., without a syscal).

It is still possible to have very scalable system with it, for example
with one thread dedicated for syscall reading (with big number of event=
s
transferred in one shot syscall overhead becomes negligible) and pool o=
f
working threads. It is not about 'let's remove kernelspace ring buffer
management', but about possibilities and flexibility of the existing
model.

> >Let's solve problem in order of theirs appearance - what do you thin=
k
> >about above interface for ring buffer?
>=20
> Looks better, yes.

Ok, I will implement this new (old) ring buffer in present it in the=20
next release. I will also schedule there userspace notifications,
'wake-up-one-thread' flag changes and other small updates.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
