From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC PATCH net-next 00/11] net: remove disable_irq() from
 ->ndo_poll_controller
Date: Fri, 12 Dec 2014 23:01:28 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1412122242180.16494@nanos>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net> <20141209.214433.7463087833083181.davem@davemloft.net> <20141211214537.GA4159@kria>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	peterz@infradead.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:37381 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbaLLWBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 17:01:37 -0500
In-Reply-To: <20141211214537.GA4159@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Dec 2014, Sabrina Dubroca wrote:
> 2014-12-09, 21:44:33 -0500, David Miller wrote:
> > 
> > Adding a new spinlock to every interrupt service routine is
> > simply a non-starter.
> > 
> > You will certainly have to find a way to fix this in a way
> > that doesn't involve adding any new overhead to the normal
> > operational paths of these drivers.
> 
> Okay. Here is another idea.
> 
> Since the issue is with the wait_event() part of synchronize_irq(),
> and it only takes care of threaded handlers, maybe we could try not
> waiting for threaded handlers.
> 
> Introduce disable_irq_nosleep() that returns true if it successfully
> synchronized against all handlers (there was no threaded handler
> running), false if it left some threads running.  And in
> ->ndo_poll_controller, only call the interrupt handler if
> synchronization was successful.
> 
> Both users of the poll controllers retry their action (alloc/xmit an
> skb) several times, with calls to the device's poll controller between
> attempts.  And hopefully, if the first attempt fails, we will still
> manage to get through?

Hopefully is not a good starting point. Is the poll controller
definitely retrying? Otherwise you might end up with the following:

Interrupt line is shared between your network device and a
device which requested a threaded interrupt handler.

  CPU0	       		   	    CPU1
  interrupt()
    your_device_handler()
      return NONE;
    shared_device_handler()
      return WAKE_THREAD;
      --> atomic_inc(threads_active);
				    poll()
				      disable_irq_nosleep()
					sync_hardirq()
					return atomic_read(threads_active);

So if you do not have a reliable retry then you might just go into a
stale state. And this can happen if the interrupt type is edge because
we do not disable the interrupt when we wakeup the thread for obvious
reasons.

Aside of that I think that something like this is a reasonable
approach to the problem.

The only other nitpicks I have are:

    - The name of the function sucks, though my tired braain can't
      come up with something reasonable right now

    - The lack of extensive documentation how this interface is
      supposed to be used and the pitfals of abusage, both in the
      function documentation and the changelog.

      Merlily copying the existing documentation of the other
      interface is not sufficient.

Thanks,

	tglx
