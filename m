From: "David S. Miller" <davem@redhat.com>
Subject: Re: dev->destructor
Date: Fri, 02 May 2003 13:48:04 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030502.134804.78707298.davem@redhat.com>
References: <200305020406.IAA10719@sex.inr.ac.ru>
	<20030502065752.516742C04C@lists.samba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, shemminger@osdl.org, netdev@oss.sgi.com,
   acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: rusty@rustcorp.com.au
In-Reply-To: <20030502065752.516742C04C@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Rusty Russell <rusty@rustcorp.com.au>
   Date: Fri, 02 May 2003 15:25:15 +1000

   If this is true, I think you can use the module reference count only,
   and your code will be faster, too.  I can prepare the patch for you
   later tonight, to see how it looks.
   
And where do we get the counter from when dev->owner is NULL
(ie. non-modular)?  We need the reference counting regardless of
whether the device is implemented statically in the kernel or modular.

Do you propose to attach dummy struct module to non-modular case?
I am curious...

   Alexey, you are using a module but don't want to reference count it.
   I made module reference counts very cheap so you don't have to worry,
   but you still are trying to cheat 8)
   
Understood.

I think even stronger part of Alexey's argument is that all of
this "if (x->owner)" all over the place takes away some of the
gains of compiling things statically into the kernel.  Why extra
branches all over the place?

   You want to be very tricky and count all ways into the module,
   instead.  Clearly this is mathematically possible, but in practice
   very tricky.  And all solutions I have seen which do this are ugly,
   and leave us with "remove may not succeed, it may hang forever, and
   you won't know, and you can't replace the module and need to reboot if
   it happens". 8(
   
As long as I can Control-C rmmod when it waits like this, which would
be the case, what is the problem?

Also, not only is this mathematically possible it is DONE already.
Hmmm, there seems to be massive disconnect here between what we
understand here and what you appear to.  Let me try to describe it
in detail.

All reasonable protocol code must do exactly this.  Any module which
does not properly keep track of the objects it is creating has
problems bigger than proper module handling.

It is not "very tricky", but rather "required".

Look at it this way, when module kmalloc's something does it
immediately forget about this?  This seems to be what you suggest, and
it is a dangerous way to think!

No, rather, it remembers that it did this, either by setting '1'
to refcount of this object, or attaching it to some hash table, list,
tree, or other global data structure it maintains.  Any time this
object is attached somewhere else, reference count is incremented.
Anytime it is detached or destroyed, refcount is decremented and final
decrement to zero makes final killing of this object.  It is ABCs of
programming. :-)

Apply this to every dynamic object created by a module, and the end
result is that it makes the work of counting all internal references.
Ergo, module refcounting is superfluous.  Look, once external view
into module (ie. socket operations, superblock ops, netdev registry)
is removed, all that remains to reference object is exactly these
objects.  It is the only different part about modules
vs. non-modules.

After threading the networking and adding true refcounting to sockets
I will never forget these rules. :-)

   Better, I think, to make CONFIG_MODULE_UNLOAD=n, and make
   CONFIG_MODULE_FORCE_UNLOAD work even if CONFIG_MODULE_UNLOAD=n.
   
As much as I'd like to be able to accept that behavior,
it's too much breakage.  So many people periodically make
rmmod attempts to unload unused modules, distributions even
make this by default (or at least used to).

Let's look at this aspect of behavior:

1) Some people think that -EBUSY return is unexpected.
   I fall into this category.

2) It is argued that some other people think the "wait until
   unloadable" behavior is unexpected.

But nobody would be surprised if rmmod told them:

====================
Trying to unload %s, waiting for all references to go away.
Perhaps you have programs running which still reference this
module?  (Hit Ctrl-C to interrupt unload to go and remove
those references)
====================

nobody would ask what does this mean. :-)

In fact, what IF rmmod was able to know it was unloading a filesystem
and therefore could walk the mount list to find mounted instances of
this filesystem and print that to the user in the rmmod message?  Or
for network protocols to print the socket list of
sockets/routes/devices open to that module and even making 'lsof' to
print process name/pid holding open such sockets?

I bet even Linus himself would exclaim "wow, that's nice."

Compare this to "-EBUSY". :-)))))))))

And I want to mention that in some cases you have to "wait".  The best
example are TCP_TIME_WAIT sockets.  Even after users downs all the
interfaces, and closes all the sockets, these remnants must remain for
their full life of 60 seconds.

I really am concerned at both sides, both user observed behavior and
kernel side correctness.
