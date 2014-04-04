From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] net: sched: dev_deactivate_many(): use msleep(1) instead
 of yield() to wait for outstanding qdisc_run callsb
Date: Fri, 4 Apr 2014 17:19:42 +0200
Message-ID: <20140404151942.GI10526@twins.programming.kicks-ass.net>
References: <1393976987-23555-1-git-send-email-mkl@pengutronix.de>
 <20140306.160622.59358366688518505.davem@davemloft.net>
 <1394392160.15968.13.camel@deadeye.wl.decadent.org.uk>
 <20140309.185338.2057082497431220324.davem@davemloft.net>
 <alpine.DEB.2.02.1403312333100.14882@ionos.tec.linutronix.de>
 <20140402110743.GG27965@twins.programming.kicks-ass.net>
 <1396437459.3989.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>, ben@decadent.org.uk,
	mkl@pengutronix.de,
	linux-rt-users <linux-rt-users@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1396437459.3989.39.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 02, 2014 at 04:17:39AM -0700, Eric Dumazet wrote:
> On Wed, 2014-04-02 at 13:07 +0200, Peter Zijlstra wrote:
> > On Mon, Mar 31, 2014 at 11:49:16PM +0200, Thomas Gleixner wrote:
> > > > >> The intent of a yield() call, like this one here, is unambiguously
> > > > >> that the current thread cannot do anything until some other thread
> > > > >> gets onto the cpu and makes forward progress.
> > 
> > Yeah; like Thomas said; that's not what yield() does -- or can do.
> > 
> > yield() only says 'I don't know what to do, you figure it out', but then
> > fails to provide enough information to actually do something sensible.
> > 
> > It cannot put the task to sleep; because it doesn't pair with a wakeup;
> > and therefore the task stays an eligible/runnable task from a scheduler
> > pov.
> > 
> > The scheduler is therefore entirely in its right to pick this task
> > again; and pretty much has to under many circumstances.
> > 
> > yield() does not, and can not, guarantee forward progress - ever.
> > 
> > Use wait_event() and assorted bits to wait for an actual event. That is
> > a sleep paired with a wakeup and thus has progress guarantees.
> 
> Why wouldn't it be safe to redefine yield as msleep(1) ?

Because it violates what POSIX says what yield() should do. There is a
semi valid use-case for yield between RR/FIFO tasks of the same
priority. Changing yield to do msleep(1) would break that.

The kernel actually used to rely on that particular semantics; but I
think we took that out because it was fragile as heck.

> net/ipv4/tcp_output.c seems to also use yield().
> 
> 
>                 /* Socket is locked, keep trying until memory is available. */
>                 for (;;) {
>                         skb = alloc_skb_fclone(MAX_TCP_HEADER,
>                                                sk->sk_allocation);
>                         if (skb)
>                                 break;
>                         yield();
>                 }

Yeah, that's crap code too.

Furthermore, changing the network code to use msleep(1) instead of
yield() doesn't make it less crap than it was, just functional crap
instead of broken crap.

The proper way to fix the dev_deactivate_many() is to use wait_event(),
polling for that state is just daft. Afaict there is no reason the qdisc
code could not do a wakeup whenever that condition changes.

And the above loop in tcp_output() is a plain memory deadlock, you
should not loop on allocations like that. If the allocation fails;
propagate the error.

Given that this function must not fail; one should pre-allocate proper
reserves, not simply loop until it works. The loop might be holding up
the work required to release memory.
