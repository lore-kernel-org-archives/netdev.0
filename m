From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Mon, 27 Nov 2006 11:12:21 -0800
Message-ID: <456B3895.9090207@redhat.com>
References: <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <4563FD53.7030307@redhat.com> <20061122103828.GA11480@2ka.mipt.ru> <4564CD97.20909@redhat.com> <20061123121838.GC20294@2ka.mipt.ru> <45661F50.9020007@redhat.com> <20061124105725.GD13600@2ka.mipt.ru>
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
Received: from mx1.redhat.com ([66.187.233.31]:16073 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S933257AbWK0TNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 14:13:18 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061124105725.GD13600@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> It just sets hrtimer with abs time and sleeps - it can achieve the sa=
me
> goals using similar to wait_event() mechanism.

I don't follow.  Of course it is somehow possible to wait until an=20
absolute deadline.  But it's not part of the parameter list and hence=20
easily and _quickly_ usable.


>>> Btw, do you propose to change all users of wait_event()?
>> Which users?
>=20
> Any users which use wait_event() or schedule_timeout(). Futex for
> example - it perfectly ok lives with relative timeouts provided to
> schedule_timeout() - the same (roughly saying of course) is done in k=
event.

No, it does not live perfectly OK with relative timeouts.  The userleve=
l=20
implementation is actually wrong because of this in subtle ways.  Some=20
futex interfaces take absolute timeouts and they have to be interrupted=
=20
if the realtime clock is set forward.

Also, the calls are complicated and slow because the userlevel wrapper=20
has to call clock_gettime/gettimeofday before each futex syscall.  If=20
the kernel would accept absolute timeouts as well we would save a=20
syscall and have actually a correct implementation.


> I think I said already several times that absolute timeouts are not
> related to syscall execution process. But you seems to not hear me an=
d
> insist.

Because you're wrong.  For your use cases it might not be but it's not=20
true in general.  And your interface is preventing it from being=20
implemented forever.


> Ok, I will change waiting syscalls to have 'flags' parameter and 'str=
uct
> timespec' as timeout parameter. Special bit in flags will result in
> additional timer setup which will fire after absolute timeout and wil=
l
> wake up those who wait...

Thanks a lot.


>>> kevent signal registering is atomic with respect to other kevent
>>> syscalls: control syscalls are protected by mutex and waiting sysca=
lls
>>> work with queue, which is protected by appropriate lock.
>> It is about atomicity wrt to the signal mask manipulation which woul=
d=20
>> have to precede the kevent_wait call and the call itself (and=20
>> registering a signal for kevent delivery).  This is not atomic.
>=20
> If signal mask is updated from userspace it should be done through
> kevent - add/remove different kevent signals.

Indeed, this is what I've been saying and why ppoll/pselect/epoll_pwait=
=20
take the sigset_t parameter.

Adding the signal mask to the queued events (e.g., the signal events)=20
does not work.  First of all it's slow, you'd have to find and combine=20
all mask at least every time a signal event is added/removed.  Then how=
=20
do you combine them, OR or AND?  Not all threads might want/need the=20
same signal mask.

These are just some of the usability problems.  The only clean and=20
usable solution is really to OPTIONALLY pass in the signal mask.  Nobod=
y=20
forces anybody to use this feature.  Pass a NULL pointer and nothing=20
happens, this is how the other syscalls also work.


> The whole signal mask was added by POSXI exactly for that single
> practical race in the event dispatching mechanism, which can not hand=
le
> other types of events like signals.

No.  How should this argument make sense ?  Signals cannot be used in=20
the current event handling and are therefore used for something=20
completely different.  And they will have to be used like this for many=
=20
applications (.e., thread cancellation, setuid/setgid implementation, e=
tc).

That fact that the new event handling can handle signals is orthogonal=20
(and good).  But it does not supersede the old signal use, it's=20
something new.  The old uses are still valid.

BTW: there is a little design decision which has to be made: if a signa=
l=20
is registered with kevent and this signal is sent to a specific thread=20
instead of the process (tkill and tgkill), what should happen?  I'm=20
currently leaning toward failing the tkill/tgkill syscall if delivery o=
f=20
the signal requires posting to an event queue.


> There is major contradiction here - you say that programmers will use
> old-style signal delivery and want me to add signal mask to prevent t=
hat
> delivery, so signals would be in blocked mask,

That's one thing you can do.  You also can unblock signals.


> when I say that current kevent=20
> signal delivery does not update pending signal mask, which is the sam=
e as
> putting signals into blocked mask, you say that it is not what is
> required.

=46irst, what is "pending signal mask"?  There is one signal mask per=20
thread.  And "pending" refers to thread delivery (either per-process or=
=20
per-thread) which is not the signal mask (well, for non-RT signals it=20
can be a bitmap but this still is no mask).

Second, I'm not talking about signal delivery.  Yes, sigaction allows t=
o=20
specify how the signal mask is to be changed when a signal is delivered=
=2E=20
  But this is not what I'm talk about.  I'm talking about the signal=20
mask used for the duration of the kevent_wait syscall, regardless of=20
whether signals are waited for or delivered.



> Signal queue is replaced with kevent queue, and it is in sync with al=
l
> other kevents.

But the signal mask is something completely different and completely=20
independent from the signal queue.  There is nothing in the kevent=20
interface to replace that functionality.  Nor should this be possible=20
with the events; only a sigset_t parameter to kevent_wait makes sense.


> Having sigmask parameter is the same as creating kevent signal delive=
ry.

No, no, no.  Not at all.

>> Surely you don't suggest keeping your original timer patch?
>=20
> Of course not - kevent timers are more scalable than posix timers (th=
e=20
> latter uses idr, which is slower than balanced binary tree, since it
> looks like it uses similar to radix tree algo), POSIX interface is=20
> much-much-much more unconvenient to use than simple add/wait.

I assume you misread the question.  You agree to drop the patch and the=
n=20
  go on listing things why you think it's better to keep them.  I don't=
=20
think these arguments are in any way sufficient.  The interface is=20
already too big and this is 100% duplicate functionality.  If there are=
=20
performance problems with the POSIX timer implementation (and I have ye=
t=20
to see indications) it should be fixed instead of worked around.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
