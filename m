From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: dev->destructor
Date: Mon, 05 May 2003 15:18:29 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030505051854.5C31F2C05E@lists.samba.org>
References: <20030502.204628.35664814.davem@redhat.com>
Cc: kuznet@ms2.inr.ac.ru, shemminger@osdl.org, netdev@oss.sgi.com,
   acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Fri, 02 May 2003 20:46:28 MST."
             <20030502.204628.35664814.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030502.204628.35664814.davem@redhat.com> you write:
> I think it can work Rusty, in short you create 1 freeze thread
> per cpu.  You wake up all the freeze threads on non-local cpus,
> and they indicate their presence via some bitmask.

This code is already in module.c.  I'm glad you like it though 8).

But we disable local irqs as well: this is what I call a "bogolock"
(the read-side of a bogolock is prempt_disable()/preempt_enable(): you
could temporarily disable preemption and force the scheduler to run
every preempted thread, and remove this).

> This means the local master cpu executes the unload sequence.  It may
> sleep in order to yield to, for example, semaphore holders, it may
> also sleep to yield to kswapd and friends for the sake of memory
> allocation.  I mean... consider all the situations and please try to
> find some hole in this.  We can make all try_to_*() sleep at this
> time too... this in particular needs more thought.

Well, it's a big task.  Holding interrupts disabled for unbounded time
on CPUs needs to be thought about, but I think can be fixed.  try_xxx
can be called from interrupt context: you really want to get rid of
interrupts, too...

During previous discussions, I called this "return to primordial
soup": back to like during init.  Ideally, only userspace context (no
interrupts, timers, bottom halves), and life is easy.

> To make these freeze threads globally useful, we allow them to
> run atomicity commands.  The two defined commands are "local_irq_*()"
> and "local_bh_*()", two bitmasks control this and the freeze threads
> check the bits in their spin loops.

Something like this?

	/* Tell all freeze threads to disable bottom halves. */
	void global_bh_disable(void);
	void global_bh_enable(void);

	/* Tell all freeze threads to disable interrupts halves. */
	void global_irq_disable(void);
	void global_irq_enable(void);

> Do you see?  Maybe... it is nearly Nirvana! :-)))))

Yes, but I worry it might be an illusion 8)

> Our ability to implement this changes the rest of the conversation,
> so let us resolve this first.

Yes, but it's a big IF.  I think it might be easier to make all
unregistrations runnable in interrupt context 8(

Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
