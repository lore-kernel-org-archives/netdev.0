From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: dev->destructor
Date: Sat, 03 May 2003 14:07:41 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030503040949.804182C003@lists.samba.org>
References: <20030502.134804.78707298.davem@redhat.com>
Cc: kuznet@ms2.inr.ac.ru, shemminger@osdl.org, netdev@oss.sgi.com,
   acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Fri, 02 May 2003 13:48:04 MST."
             <20030502.134804.78707298.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030502.134804.78707298.davem@redhat.com> you write:
>    From: Rusty Russell <rusty@rustcorp.com.au>
>    Date: Fri, 02 May 2003 15:25:15 +1000
> 
>    If this is true, I think you can use the module reference count only,
>    and your code will be faster, too.  I can prepare the patch for you
>    later tonight, to see how it looks.
>    
> And where do we get the counter from when dev->owner is NULL
> (ie. non-modular)?  We need the reference counting regardless of
> whether the device is implemented statically in the kernel or modular.

But Alexey said you can only call unregister_netdev from module
unload, ie. if not a module, it can't be unloaded, hence no refcount
needed.  I wrote the above paragraph because I'm not sure if I
understood Alexey correctly?

>    Alexey, you are using a module but don't want to reference count it.
>    I made module reference counts very cheap so you don't have to worry,
>    but you still are trying to cheat 8)
>    
> Understood.
> 
> I think even stronger part of Alexey's argument is that all of
> this "if (x->owner)" all over the place takes away some of the
> gains of compiling things statically into the kernel.  Why extra
> branches all over the place?

Agreed.  I have considered removing that, and making THIS_MODULE equal
a dummy module struct for the core kernel.  I think that would be a
win (we've already established that the actual refcount is cheap,
possibly cheaper than the branch in practice).

BTW, we should look at making local_inc() etc. a first-class citizen:
it has uses outside modules.

> As long as I can Control-C rmmod when it waits like this, which would
> be the case, what is the problem?

If you can, and the device is still usable afterwards, it would be
nirvana 8)

[ Refcounting tutorial skipped: I went through the same pain with
  early conntrack code, and learned to refcount everything now 8) ]

> Look, once external view into module (ie. socket operations,
> superblock ops, netdev registry) is removed, all that remains to
> reference object is exactly these objects.  It is the only different
> part about modules vs. non-modules.

This argument applies to all objects.  If you reference count
everything which holds a reference to an object, you can infer the
reference count of the object from the sum of reference counts of its
referees.

In practice, as you pointed out in an earlier mail (I think sockets
were your example), doing this proves to be extremely painful.  And
we're feeling the pain now.

The module functions, and all its data, are objects.  For convenience,
size, and speed, we don't reference count them separately.

OK, so why doesn't, say, struct netdevice grab the module refcount on
registration (as is logical), and drop it on unregistration?  Because
the module holds a reference to the struct device, so now you have a
classic circular reference count problem: the module reference count
will never fall to zero.  That's why we grab a reference just before
use.

You can, of course, do two-stage module cleanup (ie. first stage with
refcounts non-zero), but the user wants clean "remove or fail to
remove" semantics, so half-way through the cleanup you realize it's
still in use, and restore things: now you have the spurious failure
problem where it was half-unregistered for a while, and AFAICT you
have to rewrite 1400 modules's cleanup routines.

I imagined schemes where the kernel would be basically stopped during
module remove, so the half-remove and unremove would appear atomic.
I shied away from implementing such a monster without deadlock, but it
might be possible.  Then we would truly have nirvana 8)

> Trying to unload %s, waiting for all references to go away.
> Perhaps you have programs running which still reference this
> module?  (Hit Ctrl-C to interrupt unload to go and remove
> those references)
> ====================
> 
> nobody would ask what does this mean. :-)

Please, implement such a thing.  I was unable to, without introducing
spurious failure in the components, *and* rewriting every
module_cleanup function 8( Hence rmmod does not wait by default, but
says "module is busy".

> And I want to mention that in some cases you have to "wait".  The best
> example are TCP_TIME_WAIT sockets.  Even after users downs all the
> interfaces, and closes all the sockets, these remnants must remain for
> their full life of 60 seconds.

Yes, certainly.  The two-stage unload provided by rmmod --wait ensures
that the reference count decreases to zero (it makes try_module_get
fail).  This was my desire if unloading security modules or some
netfilter modules was going to be reasonable.

> I really am concerned at both sides, both user observed behavior and
> kernel side correctness.

There are shades of correctness, too.  Not jumping into a module which
has gone away is probably the most important.  Having finite unload
time is also nice.  Not having spurious failures because someone tried
to unload a module is nice too.

Roman Zippel suggested (among other things) that every unregister fail
when busy, and that modules the reinitialize.  This gives the spurious
failure problem, and means rewriting every unregister interface in the
kernel, every module cleanup function, and dealing with the case where
you're cleaning up a failed initialization and your unregister failed.

Adam Richter suggested the module or interface register with a central
repository to say "this modules uses this interface", then you can
atomically freeze all the module interfaces (say they all share a
single lock) and see if it's in use, but you can't really call the
module's cleanup routine, so you have to atomically deactivate all
these registrations before dropping the lock, and that's the same as
try_module_get().

As you know, I love radical change.  But I want be make sure we're
going to end up somewhere we like at the end of it, which is why I
didn't do it.  Anyway, putting the module loader in the kernel was
enough to sate my appetite for change 8)

Thanks!
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
