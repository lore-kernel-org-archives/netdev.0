From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: dev->destructor
Date: Fri, 02 May 2003 15:25:15 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030502065752.516742C04C@lists.samba.org>
References: <200305020406.IAA10719@sex.inr.ac.ru>
Cc: davem@redhat.com (David S. Miller), shemminger@osdl.org,
   netdev@oss.sgi.com, acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-reply-to: Your message of "Fri, 02 May 2003 08:06:51 +0400."
             <200305020406.IAA10719@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <200305020406.IAA10719@sex.inr.ac.ru> you write:
> Hello!

Hi Alexey!

> It is damnly inconvenient, fragile, et cetera and such bugs do exist.
> That's why unregister_netdev() is logically wrong function: it takes
> dev as argument, so any sane programmer would assume caller holds
> a reference. But he can't. So, call of the function is allowed
> only from contexts where device is presumed to be held, i.e. from
> cleanup_module() and from no other places.

If this is true, I think you can use the module reference count only,
and your code will be faster, too.  I can prepare the patch for you
later tonight, to see how it looks.

> netdevices is the simplest example, but it shows the most didctively
> that all the ocurences of module_** there are illegal. We want
> to register/unregister them dynamically, we have to do all the job not
> depending on modules. We have to do our own refcounting. And incorrect
> design of modules only prevents to make final small step to make this
> right. Well, the key moment is that while device is registered, its
> module refcnt is not zero logically, but we can't unload the module
> in this case, so we have to do funny try_* each lookup.

Alexey, you are using a module but don't want to reference count it.
I made module reference counts very cheap so you don't have to worry,
but you still are trying to cheat 8)

You want to be very tricky and count all ways into the module,
instead.  Clearly this is mathematically possible, but in practice
very tricky.  And all solutions I have seen which do this are ugly,
and leave us with "remove may not succeed, it may hang forever, and
you won't know, and you can't replace the module and need to reboot if
it happens". 8(

Better, I think, to make CONFIG_MODULE_UNLOAD=n, and make
CONFIG_MODULE_FORCE_UNLOAD work even if CONFIG_MODULE_UNLOAD=n.

Hope that clarifies?
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
