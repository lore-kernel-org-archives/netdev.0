From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: dev->destructor
Date: Wed, 07 May 2003 12:50:07 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030507035148.2C97F2C0C4@lists.samba.org>
References: <20030506.072338.39479306.davem@redhat.com>
Cc: shemminger@osdl.org, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Tue, 06 May 2003 07:23:38 MST."
             <20030506.072338.39479306.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030506.072338.39479306.davem@redhat.com> you write:
>    From: Rusty Russell <rusty@rustcorp.com.au>
>    Date: Tue, 06 May 2003 14:18:36 +1000
>    
>    It's logically consistent to make it implicit, and cuts out some
>    code in the unload path.
>    
>    How's this?
> 
> This looks fine to me.
> 
> How hard would it be to make this completely consistent in that
> no module code is ever invoked with modcount == 0?  By this I mean
> keeping the implicit reference after modload succeeds, and then
> calling ->cleanup() is valid once the count drops to '1'.

I had to think hard about this 8).

There's nothing *wrong* with leaving the refcount at 1: it's just a
matter of adjusting various checks for 0 to 1 (including the BUG()
Stephen hit), and subbing 1 in /proc/modules...

But that's a sideshow: you'd *still* want an extra refcount around the
call to module_init().  Because it's the module state being
MODULE_STATE_COMING which stops the module from being unloaded,
ie. holds the extra reference count.  Once init is finished, module
state goes to MODULE_STATE_LIVE, and the reference must be dropped.

Now, grabbing a similar reference when deleting a module might make
sense, but it's actually kinda pointless when you look at the code.

Hope that clarifies,
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
