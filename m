From: Matt Mackall <mpm@selenic.com>
Subject: Re: Followup to netpoll issues
Date: Fri, 7 Jan 2005 14:07:23 -0800
Message-ID: <20050107220723.GB2940@waste.org>
References: <1105045914.7687.3.camel@tigger> <20050106234610.GT2940@waste.org> <20050107011547.GE27896@electric-eye.fr.zoreil.com> <20050107170118.GU2940@waste.org> <20050107214254.GA17317@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Broadbent <markb@wetlettuce.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20050107214254.GA17317@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jan 07, 2005 at 10:42:54PM +0100, Francois Romieu wrote:
> Matt Mackall <mpm@selenic.com> :
> [...]
> > printk("debug: at point A");
> > do_something_that_sends_a_packet_B();
> > printk("debug: at point C");
> > 
> > Depending on locking and queueing, we might see on our network dump B,
> > A, C, and wrongly conclude that whatever did B was not between A and C.
> > That's a bad way for printk to work.
> 
> I completely agree that it is not perfect.
> 
> However netconsole is currently unable to guarantee that you will
> always see both A and B (currently = assuming the skb is dropped
> when netconsole fails trylock as suggested by Jamal). So there is
> an issue with the reliability of the delivery as well.

Indeed, and we can't really do much about it generally as we're on a
lossy media. But I think that's less misleading than potential
reordering. I acknowledge that packets can get reordered on the wire
potentially as well but for typical LAN segments, this will be uncommon.

> I won't push harder on the queuing side as I believe that it will
> be possible to add it as an extra choice to the user whatever form
> netconsole takes to stop deadlocking.

I might be willing to compromise on a queue depth of one. Much simpler
code, much less effort to paper over bugs that should be fixed in a
different way.

But then we've got to have a way to disable it for kgdb-over-ethernet
or netdump, where the delayed work simply won't get processed because
the box is stopped. Admittedly trying to trace your way into the
network driver is asking for a beating here, but the general issue is
that netpoll clients can stop interrupt processing and netpoll should
tell such clients that the packets its trying to send aren't going
anywhere rather than quietly scheduling them for later delivery, see?
 
> [...]
> > The bugs I'm talking about are identical to the xmit_lock deadlock
> > except with locks we can't see outside the driver. In other words,
> 
> Right, it's clearer now. Thanks for the reminder.
> 
> User space takes device's private lock -> printks -> netconsole.write
> -> hard_start_xmit -> device's private lock -> splat. Same thing from
> interrupt context (in_irq() can probably help though).
> 
> So we ought to check rtnl_sem as well (dev_base_lock anyone ?).
> 
> /me scratches neck...
> 
> > this patch addresses the easy part of larger problem by adding a bunch
> > of complexity that doesn't help in the larger problem. To me, that's a
> > hint that it's the wrong fix.
> 
> Too big. It won't bite. :o)
> 
> [...]
> > > I am not convinced that people will be satisfied with a rule which
> > > states that printk _from anywhere_ are lost as soon as a CPU enters
> > > in the xmit_lock zone but, hey, it's just me.
> > 
> > It should only be dropped on the CPU holding the lock, with a loud
> > warning to follow shortly.
> 
> Sorry if I was not clear: "from anywhere" meant printk issued from
> any part of the kernel which can interrupt the xmit_locked section
> of a qdisc_run(), i.e. printk from irq handlers. 

Hrmm. Yes, that's uglier than I realized.

Perhaps there's a way to use the existing IRQ handler reentrancy
avoidance to detect that we might be about to recurse on a lock.

> If I read correctly the suggested design, the remaining CPUs should
> loop in netpoll_send_skb() when they notice that they can not take
> the lock and that their CPU do not own it, right ?

Yep.

-- 
Mathematics is the supreme nostalgia of our time.
