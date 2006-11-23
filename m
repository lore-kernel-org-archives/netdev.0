From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Thu, 23 Nov 2006 14:23:12 -0800
Message-ID: <45661F50.9020007@redhat.com>
References: <20061113105458.GA8182@2ka.mipt.ru> <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <4563FD53.7030307@redhat.com> <20061122103828.GA11480@2ka.mipt.ru> <4564CD97.20909@redhat.com> <20061123121838.GC20294@2ka.mipt.ru>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934187AbWKWWYB@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061123121838.GC20294@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Wed, Nov 22, 2006 at 02:22:15PM -0800, Ulrich Drepper (drepper@red=
hat.com) wrote:
> Timeouts are not about AIO or any other event types (there are a lot =
of
> them already as you can see), it is only about syscall itself.
> Please point me to _any_ syscall out there which uses absolute time
> (except settimeofday() and similar syscalls).

futex(FUTEX_LOCK_PI).


> Btw, do you propose to change all users of wait_event()?

Which users?


> Interface is not restricted, it is just different from what you want =
it
> to be, and you did not show why it requires changes.

No, it is restricted because I cannot express something like an absolut=
e=20
timeout/deadline.  If the parameter would be a struct timespec* then at=
=20
any time we can implement either relative timeouts w/ and w/out=20
observance of settimeofday/ntp and absolute timeouts.  This is what=20
makes the interface generic and unrestricted while your current version=
=20
cannot be used for the latter.


> kevent signal registering is atomic with respect to other kevent
> syscalls: control syscalls are protected by mutex and waiting syscall=
s
> work with queue, which is protected by appropriate lock.

It is about atomicity wrt to the signal mask manipulation which would=20
have to precede the kevent_wait call and the call itself (and=20
registering a signal for kevent delivery).  This is not atomic.


> Let me formulate signal problem here, please point me if it is correc=
t
> or not.

There are a myriad of different scenarios, it makes no sense to pick=20
one.  The interface must be generic to cover them all, I don't know how=
=20
often I have to repeat this.


> User registers some async signal notifications and calls poll() waiti=
ng
> for some file descriptors to became ready. When it is interrupted the=
re
> is no knowledge about what really happend first - signal was delivere=
d
> or file descriptor was ready.

The order is unimportant.  You change the signal mask, for instance, if=
=20
the time when a thread is waiting in poll() is the only time when a=20
signal can be handled.  Or vice versa, it's the time when signals are=20
not wanted.  And these are per-thread decisions.

Signal handlers and kevent registrations for signals are process-wide=20
decisions.  And furthermore: with kevent delivered signals there is no=20
signal mask anymore (at least you seem to not check it).  Even if this=20
would be done it doesn't change the fact that you cannot use signals th=
e=20
way many programs want to.

=46act is that without a signal queue you cannot implement the above=20
cases.  You cannot block/unblock a signal for a specific thread.  You=20
also cannot work together with signals which cannot be delivered throug=
h=20
kevent.  This is the case for existing code in a program which happens=20
to use also kevent and it is the case if there is more than one possibl=
e=20
recipient.  With kevent signals can be attached to one kevent queue onl=
y=20
but the recipients (different threads or only different parts of a=20
program) need not use the same kevent queue.

I've said from the start that you cannot possibly expect that programs=20
are not using signal delivery in the current form.  And the complete=20
loss of blocking signals for individual threads makes the kevent-based=20
signal delivery incomplete (in a non-fixable form) anyway.


> In case it is, let me explain why this situation can not happen with
> kevent: since signals are not delivered in the old way, but instead t=
hey
> are queued into the same queue where file descriptors are, and queuei=
ng
> is atomic, and pending signal mask is not updated, user will only rea=
d
> one event after another, which automatically (since delivery is atomi=
c)
> means that what first was read, that was first happend.

This really has nothing to do with the problem.



> I posted a patch to implement kevent support for posix timers, it is
> quite simple in existing model. No need to remove anything,

Surely you don't suggest keeping your original timer patch?


> I implemented it to return -enosys for the case, when event type is
> smaller than maximum allowed and no subsystem is registered, and -ein=
val=20
> for the case, when requested type is higher.

What is the "maximum allowed"?  ENOSYS must be returned for all values=20
which could potentially in future be used as a valid type value.  If yo=
u=20
limit the values which are treated this way you are setting a fixed=20
upper limit for the type values which _ever_ can be used.


> It is not about generalization, but about those who do practical work
> and those who prefer to spread theoretical thoughts, which result in
> several month of unused empty discussions.

I've told you, then don't work on these parts.  I'll get the changes I=20
think are needed implemented by somebody else or I'll do it myself.  If=
=20
you say that only those you implement something have a say in the way=20
this is done then this is fine with me.  But you have to realize that=20
you're not the one who will make all the final decisions.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
