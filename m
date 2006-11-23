From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Thu, 23 Nov 2006 15:18:40 +0300
Message-ID: <20061123121838.GC20294@2ka.mipt.ru>
References: <20061113105458.GA8182@2ka.mipt.ru> <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <4563FD53.7030307@redhat.com> <20061122103828.GA11480@2ka.mipt.ru> <4564CD97.20909@redhat.com>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757351AbWKWMUk@vger.kernel.org>
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <4564CD97.20909@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 22, 2006 at 02:22:15PM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> >I repeate - timeout is needed to tell kernel the maximum possible
> >timeframe syscall can live. When you will tell me why you want sysca=
ll
> >to be interrupted when some absolute time is on the clock instead of
> >having special event for that, then ok.
>=20
> This goes together with...
>=20
>=20
> >I think I know why you want absolute time there - because glibc conv=
erts
> >most of the timeouts to absolute time since posix waiting
> >pthread_cond_timedwait() works only with it.
>=20
> I did not make the decision to use absolute timeouts/deadlines.  This=
 is=20
> what is needed in many situations.  It's the more general way to spec=
ify=20
> delays.  These are real-world requirements which were taken into acco=
unt=20
> when designing the interfaces.
>=20
> For most cases I would agree that when doing AIO you need relative=20
> timeouts.  But the event handling is not about AIO alone.  It's all=20
> kinds of events and some/many are wall clock related.  And it is=20
> definitely necessary in some situations to be able to interrupt if th=
e=20
> clock jumps ahead.  If a program deals with devices in the real world=
=20
> this be crucial.  The new event handling must be generic enough to=20
> accommodate all these uses and using struct timespec* plus eventually=
=20
> flags does not add any measurable overhead so there is no reason to n=
ot=20
> do it right.

Timeouts are not about AIO or any other event types (there are a lot of
them already as you can see), it is only about syscall itself.
Please point me to _any_ syscall out there which uses absolute time
(except settimeofday() and similar syscalls).
=20
> >Kevent convert it to jiffies since it uses wait_event() and friends,
> >jiffies do not carry information about clocks to be used.
>=20
> Then this points to a place in the implementation which needs changin=
g.=20
>  The interface cannot be restricted just because the implementation=20
> currently allow this to be implemented.

Btw, do you propose to change all users of wait_event()?

Interface is not restricted, it is just different from what you want it
to be, and you did not show why it requires changes.

Btw, there are _no_ interfaces similar to 'wait event with absolute
times' in kernel.
=20
> >	/* Short-circuit ignored signals.  */
> >	if (sig_ignored(p, sig)) {
> >		ret =3D 1;
> >		goto out;
> >	}
> >=20
> >almost the same happens when signal is delivered using kevent (speci=
al
> >case) - pending mask is not updated.
>=20
> Yes, and how do you set the signal mask atomically wrt to registering=
=20
> and unregistering signals with kevent and the syscall itself?  You=20
> cannot.  But this is exactly which is resolved by adding the signal m=
ask=20
> parameter.

kevent signal registering is atomic with respect to other kevent
syscalls: control syscalls are protected by mutex and waiting syscalls
work with queue, which is protected by appropriate lock.

> Programs which don't need the functionality simply pass a NULL pointe=
r=20
> and the cost is once again not measurable.  But don't restrict the=20
> functionality just because you don't see a use for this in your small=
 world.
>=20
> Yes, we could (later again) add new syscalls.  But this is plain stup=
id.=20
>  I would love to never have the epoll_wait or select syscall and just=
=20
> have epoll_pwait and pselect since the functionality is a superset.  =
We=20
> have a larger kernel ABI.  Here we can stop making the same mistake a=
gain.
>=20
> For the userlevel side we might even have separate intterfaces, one w=
ith=20
> one without signal mask parameter.  But that's userlevel, both functi=
ons=20
> would use the same syscall.

Let me formulate signal problem here, please point me if it is correct
or not.

User registers some async signal notifications and calls poll() waiting
for some file descriptors to became ready. When it is interrupted there
is no knowledge about what really happend first - signal was delivered
or file descriptor was ready.

Is it correct?

In case it is, let me explain why this situation can not happen with
kevent: since signals are not delivered in the old way, but instead the=
y
are queued into the same queue where file descriptors are, and queueing
is atomic, and pending signal mask is not updated, user will only read
one event after another, which automatically (since delivery is atomic)
means that what first was read, that was first happend.

So, why in the latter situation we need to specify signal mask, which
will block some signals from _async_ delivery, since there is _no_ asyn=
c
delivery?

> >>There are other scenarios like this.  Fact is, signal mask handling=
 is=20
> >>necessary and it cannot be folded into the event handling, it's=20
> >>orthogonal.
> >
> >You have too narrow look.
> >Look broader - pselect() has signal mask to prevent race between asy=
nc
> >signal delivery and file descriptor readiness. With kevent both that
> >events are delivered through the same queue, so there is no race, so
> >kevent syscalls do not need that workaround for 20 years-old design,
> >which can not handle different than fd events.
>=20
> Your failure to understand to signal model leads to wrong conclusions=
=2E=20
> There are races, several of them, and you cannot do anything without=20
> signal mask parameters.  I've explained this before.

Please refer to my above explaination, point me in that example what we
are talking about. It seems we do not understand each other.
=20
> >>Avoiding these callbacks would help reducing the kernel interface,=20
> >>especially for this useless since inferior timer implementation.
> >
> >You completely do not want to understand how kevent works and why th=
ey=20
> >are needed, if you would try to think that there are different than=20
> >yours opinions, then probably we could have some progress.
>=20
> I think I know very well how they work meanwhile.

If that would be true, I would be very happy. Definitely.
=20
> >Those callbacks are neededto support different types of objects, whi=
ch
> >can produce events, with the same interface.
>=20
> Yes, but it is not necessary to expose all the different types in the=
=20
> userlevel APIs.  That's the issue.  Reduce the exposure of kernel=20
> functionality to userlevel APIs.
>=20
> If you integrate the timer handling into the POSIX timer syscalls the=
=20
> callbacks in your timer patch might not need be there.  At least the=20
> enqueue callback, if I remember correctly.  All enqueue operations ar=
e=20
> initiated by timer_create calls which can call the function directly.=
=20
> Removing the callback from the list used by add_ctl will reduce the=20
> exposed interface.

I posted a patch to implement kevent support for posix timers, it is
quite simple in existing model. No need to remove anything, that allows
to have flexibility and create different usage models others than what
is required by fairly small part of the users.

> >>>I can replace with -ENOSYS if you like.
> >>It's necessary since we must be able to distinguish the errors.
> >
> >And what if user requests bogus event type - is it invalid condition=
 or
> >normal, but not handled (thus enosys)?
>=20
> It's ENOSYS.  Just like for system calls.  You cannot distinguish=20
> completely invalid values from values which are correct only on later=
=20
> kernels.  But: the first use is a bug while the later is not a bug an=
d=20
> needed to write robust and well performing apps.  The former's proble=
ms=20
> therefore are unimportant.

I implemented it to return -enosys for the case, when event type is
smaller than maximum allowed and no subsystem is registered, and -einva=
l=20
for the case, when requested type is higher.

> >Well, then I claim that I do not know 'thing or two about interfaces=
 of
> >the runtime programs expect to use', but instead I write those progr=
amms
> >and I know my needs. And POSIX interfaces are the last one I prefer =
to
> >use.
>=20
> Well, there it is.  You look out for yourself while I make sure that =
all=20
> the bases I can think of are covered.
>=20
> Again, if you don't want to work on the generalization, fine.  That's=
=20
> your right.  Nobody will think bad of you for doing this.  But don't=20
> expect that a) I'll not try to change it and b) I'll not object to th=
e=20
> changes being accepted as they are.

It is not about generalization, but about those who do practical work
and those who prefer to spread theoretical thoughts, which result in
several month of unused empty discussions.

> >What if it will not be called POSIX AIO, but instead some kind of 't=
rue
> >AIO' or 'real AIO' or maybe 'alternative AIO'? :)
> >It is quite sure that POSIX AIO interfaces will unlikely to be appli=
ed
> >there...
>=20
> Programmers don't like specialized OS-specific interfaces.  AIO users=
=20
> who put up with libaio are rare.  The same will happen with any other=
=20
> approach.  The Samba use is symptomatic: they need portability even i=
f=20
> this costs a minute percentage of performance compared to a highly=20
> specialized implementation.

Do not say for everyone - it is not a some kind of feodalism with the
only opinion allowed - respect those who do not like/do not want what=20
you propose them to use.

> There might be some aspects of POSIX AIO which could be implemented=20
> better on Linux.  But the important part in the name is the 'P'.

I will create completely different model, POSIX completely is not
designed for that - that model allows to specify set of tasks performed
on object completely asycnhronous to user before object is returned -
for example specify destination socket and filename, so async sendfile
will asynchronously open file, transfer it to remote destination and
probably even close (or return file descriptor). The same can be applie=
d
to aio read/write.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
