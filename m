From: kuznet@ms2.inr.ac.ru
Subject: Re: dev->destructor
Date: Fri, 2 May 2003 08:06:51 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200305020406.IAA10719@sex.inr.ac.ru>
References: <20030501.000058.39187964.davem@redhat.com>
Mime-Version: 1.0
Cc: shemminger@osdl.org, netdev@oss.sgi.com, acme@conectiva.com.br,
   rusty@rustcorp.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20030501.000058.39187964.davem@redhat.com> from "David S. Miller" at May 1, 3 00:00:58 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> None of destructors kill reference to device object, and I mean none
> of them.  It is why I thought the idea works.

When you call unregister_something() you hold a reference to this
something, and you have no idea how much of the references
you hold. This is invisible when unregister_something() is called
from a single place sort of cleanup_module().


> Also, holding RTNL semaphore does not block potential holders
> of device reference.  Or does it?

When that branch with waiting inside unregister() exists you can't hold
any reference when grabbing this semaphore. That's why dev_ioctl()
takes the semaphore first.

It is damnly inconvenient, fragile, et cetera and such bugs do exist.
That's why unregister_netdev() is logically wrong function: it takes
dev as argument, so any sane programmer would assume caller holds
a reference. But he can't. So, call of the function is allowed
only from contexts where device is presumed to be held, i.e. from
cleanup_module() and from no other places.


> Your idea, as I understand it, is to add callback to module that
> freezes module then at some time in the future makes indication
> that module is clean and may be unloaded safely.

Yes, the description is mostly right.


> Question is, where to make this?  It cannot be in the module
> itself of course, that would create race condition similar to
> one which exists today making this exercise quite pointless :-)

Probably, you should look at the most first module implementation. :-)
Desite of it was horrible (like almost everything in kernel that days)
it was logically correct.

rmmod deleted module not depending on refcnt and module body was destroyed
later, when refcnt reached zero. See?

So, that cleanup_module() is replaced with shutdown() and a destructor
is added to allow to cleanup something but memory, if it is necessary.

And to handle the situation when we do not want to use module refcnt,
a predicate to ask module for readiness to kill is added. I think
it can be combined to destructor, so that for such modules destructor
can return -EAGAIN. Well, when refcnt is zero you can try to destroy module
and it might disagree.


> Note the problem.  If between the unregister_foo() and re-register of
> foo in the failure path, someone asks to open a "foo" it will fail.
> Those semantics absolutely stink.

It is not a problem at all comparing to real ones. :-)


> Rusty went on to describe that this is one of the reasons for the
> current "enable refcounts" scheme with try_module_get().

Rusty forgot that crippling xxx_get() is million times more painful. :-)

He also forgot that in 99% of cases there is a single registry and
this registry must be self-consistent, so all the work is already done
and module.c just invades area out of its competence.

Anyway, this approach is legal and the simplest one, I understand this.
It can be used optionally. Only, frankly speaking, I do not see any
applications for this, because when more than one registry exists,
module is surely so complicated that tracking references is painful
enough to forget about this. Anyway, we always know number of sockets et al.,
so why to count them in more than one place?

netdevices is the simplest example, but it shows the most didctively
that all the ocurences of module_** there are illegal. We want
to register/unregister them dynamically, we have to do all the job not
depending on modules. We have to do our own refcounting. And incorrect
design of modules only prevents to make final small step to make this
right. Well, the key moment is that while device is registered, its
module refcnt is not zero logically, but we can't unload the module
in this case, so we have to do funny try_* each lookup.

Alexey
