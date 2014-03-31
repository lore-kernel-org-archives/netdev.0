From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] net: sched: dev_deactivate_many(): use msleep(1) instead
 of yield() to wait for outstanding qdisc_run callsb
Date: Mon, 31 Mar 2014 23:49:16 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1403312333100.14882@ionos.tec.linutronix.de>
References: <1393976987-23555-1-git-send-email-mkl@pengutronix.de> <20140306.160622.59358366688518505.davem@davemloft.net> <1394392160.15968.13.camel@deadeye.wl.decadent.org.uk> <20140309.185338.2057082497431220324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ben@decadent.org.uk, mkl@pengutronix.de,
	linux-rt-users <linux-rt-users@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	kernel@pengutronix.de, Peter Zijlstra <peterz@infradead.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140309.185338.2057082497431220324.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 9 Mar 2014, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Sun, 09 Mar 2014 19:09:20 +0000
> 
> > On Thu, 2014-03-06 at 16:06 -0500, David Miller wrote:
> >> From: Marc Kleine-Budde <mkl@pengutronix.de>
> >> Date: Wed,  5 Mar 2014 00:49:47 +0100
> >> 
> >> > @@ -839,7 +839,7 @@ void dev_deactivate_many(struct list_head *head)
> >> >       /* Wait for outstanding qdisc_run calls. */
> >> >       list_for_each_entry(dev, head, unreg_list)
> >> >               while (some_qdisc_is_busy(dev))
> >> > -                     yield();
> >> > +                     msleep(1)
> >> >  }
> >> 
> >> I don't understand this.
> >> 
> >> yield() should really _mean_ yield.
> >> 
> >> The intent of a yield() call, like this one here, is unambiguously
> >> that the current thread cannot do anything until some other thread
> >> gets onto the cpu and makes forward progress.
> >>
> >> Therefore it should allow lower priority threads to run, not just
> >> equal or higher priority ones.
> > 
> > Until when?
> > 
> > yield() is not a sensible operation in a preemptive multitasking system,
> > regardless of RT.
> 
> To me it means "I've got nothing to do if other tasks want to run right
> now"  Yes, I even see it having this meaning when an RT task executes
> it.
> 
> How else can you interpret the intent above?

The problem is that the semantics of yield() are a complete disaster.

yield() only works by some definiton of "works" when the involved
parties are in the same scheduling class.

You can yield from one SCHED_OTHER task to another SCHED_OTHER task,
but yield() does not guarantee any progress. It might work for some
scenarios of yield from one SCHED_FIFO task to another SCHED_FIFO task
even better than in the SCHED_OTHER case, but there is no guarantee
that it works at all.

But yielding across scheduling classes cannot work ever. Not even in
mainline.

That's not a RT sepcific issue, it's just one of these problems which
are unearthed by RT because it does not follow the bog standard
scheduling class and priority assignements of your favourite distro
setup.

Once you tune a few knobs on a mainline kernel, you can provoke the
same issue. It's that simple.

yield() should die both in kernel and user space.

Thanks,

	tglx
