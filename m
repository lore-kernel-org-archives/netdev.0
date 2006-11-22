From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Wed, 22 Nov 2006 14:22:15 -0800
Message-ID: <4564CD97.20909@redhat.com>
References: <11630606361046@2ka.mipt.ru> <45564EA5.6020607@redhat.com> <20061113105458.GA8182@2ka.mipt.ru> <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <4563FD53.7030307@redhat.com> <20061122103828.GA11480@2ka.mipt.ru>
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
Received: from mx1.redhat.com ([66.187.233.31]:39554 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1757084AbWKVW0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 17:26:20 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061122103828.GA11480@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Event notification is not dropped - [...]

Since you said you added the new syscall I'll leave this alone.


> I repeate - timeout is needed to tell kernel the maximum possible
> timeframe syscall can live. When you will tell me why you want syscal=
l
> to be interrupted when some absolute time is on the clock instead of
> having special event for that, then ok.

This goes together with...


> I think I know why you want absolute time there - because glibc conve=
rts
> most of the timeouts to absolute time since posix waiting
> pthread_cond_timedwait() works only with it.

I did not make the decision to use absolute timeouts/deadlines.  This i=
s=20
what is needed in many situations.  It's the more general way to specif=
y=20
delays.  These are real-world requirements which were taken into accoun=
t=20
when designing the interfaces.

=46or most cases I would agree that when doing AIO you need relative=20
timeouts.  But the event handling is not about AIO alone.  It's all=20
kinds of events and some/many are wall clock related.  And it is=20
definitely necessary in some situations to be able to interrupt if the=20
clock jumps ahead.  If a program deals with devices in the real world=20
this be crucial.  The new event handling must be generic enough to=20
accommodate all these uses and using struct timespec* plus eventually=20
flags does not add any measurable overhead so there is no reason to not=
=20
do it right.


> Kevent convert it to jiffies since it uses wait_event() and friends,
> jiffies do not carry information about clocks to be used.

Then this points to a place in the implementation which needs changing.=
=20
  The interface cannot be restricted just because the implementation=20
currently allow this to be implemented.


> 	/* Short-circuit ignored signals.  */
> 	if (sig_ignored(p, sig)) {
> 		ret =3D 1;
> 		goto out;
> 	}
> =20
> almost the same happens when signal is delivered using kevent (specia=
l
> case) - pending mask is not updated.

Yes, and how do you set the signal mask atomically wrt to registering=20
and unregistering signals with kevent and the syscall itself?  You=20
cannot.  But this is exactly which is resolved by adding the signal mas=
k=20
parameter.

Programs which don't need the functionality simply pass a NULL pointer=20
and the cost is once again not measurable.  But don't restrict the=20
functionality just because you don't see a use for this in your small w=
orld.

Yes, we could (later again) add new syscalls.  But this is plain stupid=
=2E=20
  I would love to never have the epoll_wait or select syscall and just=20
have epoll_pwait and pselect since the functionality is a superset.  We=
=20
have a larger kernel ABI.  Here we can stop making the same mistake aga=
in.

=46or the userlevel side we might even have separate intterfaces, one w=
ith=20
one without signal mask parameter.  But that's userlevel, both function=
s=20
would use the same syscall.


>> There are other scenarios like this.  Fact is, signal mask handling =
is=20
>> necessary and it cannot be folded into the event handling, it's orth=
ogonal.
>=20
> You have too narrow look.
> Look broader - pselect() has signal mask to prevent race between asyn=
c
> signal delivery and file descriptor readiness. With kevent both that
> events are delivered through the same queue, so there is no race, so
> kevent syscalls do not need that workaround for 20 years-old design,
> which can not handle different than fd events.

Your failure to understand to signal model leads to wrong conclusions.=20
There are races, several of them, and you cannot do anything without=20
signal mask parameters.  I've explained this before.


>> Avoiding these callbacks would help reducing the kernel interface,=20
>> especially for this useless since inferior timer implementation.
>=20
> You completely do not want to understand how kevent works and why the=
y=20
> are needed, if you would try to think that there are different than=20
> yours opinions, then probably we could have some progress.

I think I know very well how they work meanwhile.


> Those callbacks are neededto support different types of objects, whic=
h
> can produce events, with the same interface.

Yes, but it is not necessary to expose all the different types in the=20
userlevel APIs.  That's the issue.  Reduce the exposure of kernel=20
functionality to userlevel APIs.

If you integrate the timer handling into the POSIX timer syscalls the=20
callbacks in your timer patch might not need be there.  At least the=20
enqueue callback, if I remember correctly.  All enqueue operations are=20
initiated by timer_create calls which can call the function directly.=20
Removing the callback from the list used by add_ctl will reduce the=20
exposed interface.


>>> I can replace with -ENOSYS if you like.
>> It's necessary since we must be able to distinguish the errors.
>=20
> And what if user requests bogus event type - is it invalid condition =
or
> normal, but not handled (thus enosys)?

It's ENOSYS.  Just like for system calls.  You cannot distinguish=20
completely invalid values from values which are correct only on later=20
kernels.  But: the first use is a bug while the later is not a bug and=20
needed to write robust and well performing apps.  The former's problems=
=20
therefore are unimportant.


> Well, then I claim that I do not know 'thing or two about interfaces =
of
> the runtime programs expect to use', but instead I write those progra=
mms
> and I know my needs. And POSIX interfaces are the last one I prefer t=
o
> use.

Well, there it is.  You look out for yourself while I make sure that al=
l=20
the bases I can think of are covered.

Again, if you don't want to work on the generalization, fine.  That's=20
your right.  Nobody will think bad of you for doing this.  But don't=20
expect that a) I'll not try to change it and b) I'll not object to the=20
changes being accepted as they are.


> What if it will not be called POSIX AIO, but instead some kind of 'tr=
ue
> AIO' or 'real AIO' or maybe 'alternative AIO'? :)
> It is quite sure that POSIX AIO interfaces will unlikely to be applie=
d
> there...

Programmers don't like specialized OS-specific interfaces.  AIO users=20
who put up with libaio are rare.  The same will happen with any other=20
approach.  The Samba use is symptomatic: they need portability even if=20
this costs a minute percentage of performance compared to a highly=20
specialized implementation.

There might be some aspects of POSIX AIO which could be implemented=20
better on Linux.  But the important part in the name is the 'P'.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
