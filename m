From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Fri, 24 Nov 2006 13:57:25 +0300
Message-ID: <20061124105725.GD13600@2ka.mipt.ru>
References: <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <4563FD53.7030307@redhat.com> <20061122103828.GA11480@2ka.mipt.ru> <4564CD97.20909@redhat.com> <20061123121838.GC20294@2ka.mipt.ru> <45661F50.9020007@redhat.com>
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
Received: from relay.2ka.mipt.ru ([194.85.82.65]:7606 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1756249AbWKXK6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Nov 2006 05:58:49 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <45661F50.9020007@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 23, 2006 at 02:23:12PM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >On Wed, Nov 22, 2006 at 02:22:15PM -0800, Ulrich Drepper=20
> >(drepper@redhat.com) wrote:
> >Timeouts are not about AIO or any other event types (there are a lot=
 of
> >them already as you can see), it is only about syscall itself.
> >Please point me to _any_ syscall out there which uses absolute time
> >(except settimeofday() and similar syscalls).
>=20
> futex(FUTEX_LOCK_PI).

It just sets hrtimer with abs time and sleeps - it can achieve the same
goals using similar to wait_event() mechanism.
=20
> >Btw, do you propose to change all users of wait_event()?
>=20
> Which users?

Any users which use wait_event() or schedule_timeout(). Futex for
example - it perfectly ok lives with relative timeouts provided to
schedule_timeout() - the same (roughly saying of course) is done in kev=
ent.

> >Interface is not restricted, it is just different from what you want=
 it
> >to be, and you did not show why it requires changes.
>=20
> No, it is restricted because I cannot express something like an absol=
ute=20
> timeout/deadline.  If the parameter would be a struct timespec* then =
at=20
> any time we can implement either relative timeouts w/ and w/out=20
> observance of settimeofday/ntp and absolute timeouts.  This is what=20
> makes the interface generic and unrestricted while your current versi=
on=20
> cannot be used for the latter.

I think I said already several times that absolute timeouts are not
related to syscall execution process. But you seems to not hear me and
insist.

Ok, I will change waiting syscalls to have 'flags' parameter and 'struc=
t
timespec' as timeout parameter. Special bit in flags will result in
additional timer setup which will fire after absolute timeout and will
wake up those who wait...
=20
> >kevent signal registering is atomic with respect to other kevent
> >syscalls: control syscalls are protected by mutex and waiting syscal=
ls
> >work with queue, which is protected by appropriate lock.
>=20
> It is about atomicity wrt to the signal mask manipulation which would=
=20
> have to precede the kevent_wait call and the call itself (and=20
> registering a signal for kevent delivery).  This is not atomic.

If signal mask is updated from userspace it should be done through
kevent - add/remove different kevent signals. Signal mask of pending
signals is not updated for special kevent signals.

> >Let me formulate signal problem here, please point me if it is corre=
ct
> >or not.
>=20
> There are a myriad of different scenarios, it makes no sense to pick=20
> one.  The interface must be generic to cover them all, I don't know h=
ow=20
> often I have to repeat this.

The whole signal mask was added by POSXI exactly for that single
practical race in the event dispatching mechanism, which can not handle
other types of events like signals.
=20
> >User registers some async signal notifications and calls poll() wait=
ing
> >for some file descriptors to became ready. When it is interrupted th=
ere
> >is no knowledge about what really happend first - signal was deliver=
ed
> >or file descriptor was ready.
>=20
> The order is unimportant.  You change the signal mask, for instance, =
if=20
> the time when a thread is waiting in poll() is the only time when a=20
> signal can be handled.  Or vice versa, it's the time when signals are=
=20
> not wanted.  And these are per-thread decisions.
>=20
> Signal handlers and kevent registrations for signals are process-wide=
=20
> decisions.  And furthermore: with kevent delivered signals there is n=
o=20
> signal mask anymore (at least you seem to not check it).  Even if thi=
s=20
> would be done it doesn't change the fact that you cannot use signals =
the=20
> way many programs want to.

There is major contradiction here - you say that programmers will use
old-style signal delivery and want me to add signal mask to prevent tha=
t
delivery, so signals would be in blocked mask, when I say that current =
kevent=20
signal delivery does not update pending signal mask, which is the same =
as
putting signals into blocked mask, you say that it is not what is
required.

> Fact is that without a signal queue you cannot implement the above=20
> cases.  You cannot block/unblock a signal for a specific thread.  You=
=20
> also cannot work together with signals which cannot be delivered thro=
ugh=20
> kevent.  This is the case for existing code in a program which happen=
s=20
> to use also kevent and it is the case if there is more than one possi=
ble=20
> recipient.  With kevent signals can be attached to one kevent queue o=
nly=20
> but the recipients (different threads or only different parts of a=20
> program) need not use the same kevent queue.

Signal queue is replaced with kevent queue, and it is in sync with all
other kevents.
Programmers which want to use kevents will use kevents (if miracle will
happend and we agree that kevent is good for inclusion), and programmer=
s
will know how kevent signal delivery works.

> I've said from the start that you cannot possibly expect that program=
s=20
> are not using signal delivery in the current form.  And the complete=20
> loss of blocking signals for individual threads makes the kevent-base=
d=20
> signal delivery incomplete (in a non-fixable form) anyway.

Having sigmask parameter is the same as creating kevent signal delivery=
=2E

And, btw, programmers can change signal mask before calling syscall,
since in the syscall there is a gap between start and sigprocmask()
call.

> >In case it is, let me explain why this situation can not happen with
> >kevent: since signals are not delivered in the old way, but instead =
they
> >are queued into the same queue where file descriptors are, and queue=
ing
> >is atomic, and pending signal mask is not updated, user will only re=
ad
> >one event after another, which automatically (since delivery is atom=
ic)
> >means that what first was read, that was first happend.
>=20
> This really has nothing to do with the problem.

It is the only practical example of the need for that signal mask.
And it can be perfectly handled by kevent.

> >I posted a patch to implement kevent support for posix timers, it is
> >quite simple in existing model. No need to remove anything,
>=20
> Surely you don't suggest keeping your original timer patch?

Of course not - kevent timers are more scalable than posix timers (the=20
latter uses idr, which is slower than balanced binary tree, since it
looks like it uses similar to radix tree algo), POSIX interface is=20
much-much-much more unconvenient to use than simple add/wait.
=20
> >I implemented it to return -enosys for the case, when event type is
> >smaller than maximum allowed and no subsystem is registered, and -ei=
nval=20
> >for the case, when requested type is higher.
>=20
> What is the "maximum allowed"?  ENOSYS must be returned for all value=
s=20
> which could potentially in future be used as a valid type value.  If =
you=20
> limit the values which are treated this way you are setting a fixed=20
> upper limit for the type values which _ever_ can be used.

Upper limit is for current version - when new type is added limit is
increased - just like maximum number of syscalls.
Ok, I will use -ENOSYS for all cases.
=20
> >It is not about generalization, but about those who do practical wor=
k
> >and those who prefer to spread theoretical thoughts, which result in
> >several month of unused empty discussions.
>=20
> I've told you, then don't work on these parts.  I'll get the changes =
I=20
> think are needed implemented by somebody else or I'll do it myself.  =
If=20
> you say that only those you implement something have a say in the way=
=20
> this is done then this is fine with me.  But you have to realize that=
=20
> you're not the one who will make all the final decisions.

Because our void discussion seems to never end, which puts kevent into
hung state - I definitely prefer final words made by kernel maintainers=
=20
about inclusion or declining of the kevents, but they keep silence sinc=
e
they look for not only my decision as author, but also different
opinions of the potential users.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
