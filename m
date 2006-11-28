From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Tue, 28 Nov 2006 14:00:47 +0300
Message-ID: <20061128110047.GG15083@2ka.mipt.ru>
References: <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <4563FD53.7030307@redhat.com> <20061122103828.GA11480@2ka.mipt.ru> <4564CD97.20909@redhat.com> <20061123121838.GC20294@2ka.mipt.ru> <45661F50.9020007@redhat.com> <20061124105725.GD13600@2ka.mipt.ru> <456B3895.9090207@redhat.com>
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
Received: from relay.2ka.mipt.ru ([194.85.82.65]:21453 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S935858AbWK1LEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 06:04:14 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <456B3895.9090207@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 27, 2006 at 11:12:21AM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >It just sets hrtimer with abs time and sleeps - it can achieve the s=
ame
> >goals using similar to wait_event() mechanism.
>=20
> I don't follow.  Of course it is somehow possible to wait until an=20
> absolute deadline.  But it's not part of the parameter list and hence=
=20
> easily and _quickly_ usable.

I just described how it is implemented in futex. I will create the same
approach - hrtimer which will wakeup wait_event() with infinite timeout=
=2E
=20
> >>>Btw, do you propose to change all users of wait_event()?
> >>Which users?
> >
> >Any users which use wait_event() or schedule_timeout(). Futex for
> >example - it perfectly ok lives with relative timeouts provided to
> >schedule_timeout() - the same (roughly saying of course) is done in =
kevent.
>=20
> No, it does not live perfectly OK with relative timeouts.  The userle=
vel=20
> implementation is actually wrong because of this in subtle ways.  Som=
e=20
> futex interfaces take absolute timeouts and they have to be interrupt=
ed=20
> if the realtime clock is set forward.
>=20
> Also, the calls are complicated and slow because the userlevel wrappe=
r=20
> has to call clock_gettime/gettimeofday before each futex syscall.  If=
=20
> the kernel would accept absolute timeouts as well we would save a=20
> syscall and have actually a correct implementation.

It is only done for LOCK_PI case, which was specially created to have
absolute timeout, i.e. futex does not need it, but there is an option.

I will extend waiting syscalls to have timespec and absolute timeout,
I'm just want to stop this (I hope you agree) stupid endless arguing
about completely unimportant thing.
=20
> >I think I said already several times that absolute timeouts are not
> >related to syscall execution process. But you seems to not hear me a=
nd
> >insist.
>=20
> Because you're wrong.  For your use cases it might not be but it's no=
t=20
> true in general.  And your interface is preventing it from being=20
> implemented forever.

Because I'm right and it will not be used :)
Well, it does not matter anymore, right?
=20
> >Ok, I will change waiting syscalls to have 'flags' parameter and 'st=
ruct
> >timespec' as timeout parameter. Special bit in flags will result in
> >additional timer setup which will fire after absolute timeout and wi=
ll
> >wake up those who wait...
>=20
> Thanks a lot.

No problem - I always like to spend couple of month arguing about taste
and 'right-from-my-point-of-view' theories - doesn't it the best way to
waste the time?

=2E..

> >Having sigmask parameter is the same as creating kevent signal deliv=
ery.
>=20
> No, no, no.  Not at all.

I've dropped a lot, but let me describe signal mask problem in few
words: signal mask provided in sys_pselect() and friends is a mask of
signals, which will be put into blocked mask in the task structure in
kernel. When new signal is going to be delivered, signal number is bein=
g
checked if it is in blocked mask, and if so, signal is not put into
pending mask of signals, which ends up in not being delivered to
userspace. Kevent (with special flag) does exactly the same - but it
does not update blocked mask, but instead adds another check if signal
is in kevent set of requests, in that case signal is delivered to
userspace through kevent queue.

It is _exactly_ the same behaviour from userspace point of view
concerning race of delivery signal versus file descriptor readyness.
Exactly.

Here is code snippet:
specific_send_sig_info()
{
	...
	/* Short-circuit ignored signals.  */
	if (sig_ignored(t, sig))
		goto out;
	...
	ret =3D send_signal(sig, info, t, &t->pending);
	if (!ret && !sigismember(&t->blocked, sig))
		signal_wake_up(t, sig =3D=3D SIGKILL);
#ifdef CONFIG_KEVENT_SIGNAL
	/*
	 * Kevent allows to deliver signals through kevent queue,
	 * it is possible to setup kevent to not deliver
	 * signal through the usual way, in that case send_signal()
	 * returns 1 and signal is delivered only through kevent queue.
	 * We simulate successfull delivery notification through this hack:
	 */
	 if (ret =3D=3D 1)
	 	ret =3D 0;
#endif
out:
	return ret;
}

> >>Surely you don't suggest keeping your original timer patch?
> >
> >Of course not - kevent timers are more scalable than posix timers (t=
he=20
> >latter uses idr, which is slower than balanced binary tree, since it
> >looks like it uses similar to radix tree algo), POSIX interface is=20
> >much-much-much more unconvenient to use than simple add/wait.
>=20
> I assume you misread the question.  You agree to drop the patch and t=
hen=20
>  go on listing things why you think it's better to keep them.  I don'=
t=20
> think these arguments are in any way sufficient.  The interface is=20
> already too big and this is 100% duplicate functionality.  If there a=
re=20
> performance problems with the POSIX timer implementation (and I have =
yet=20
> to see indications) it should be fixed instead of worked around.

I do _not_ agree to drop kevent timer patch (not posix timer), since
from my point of view it is much more convenient interface, it is more
scalable, it is generic enough to be used with other kevent methods.

But anyway, we can spend awfull lot of time arguing about taste, which
is definitely _NOT_ what we want. So, there are two worlds - posix
timers and usual timers, accessible from userspace, first one through
create_timer() and friends, second one with kevent interface.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
