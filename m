From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Followup to netpoll issues
Date: Fri, 7 Jan 2005 22:42:54 +0100
Message-ID: <20050107214254.GA17317@electric-eye.fr.zoreil.com>
References: <1105045914.7687.3.camel@tigger> <20050106234610.GT2940@waste.org> <20050107011547.GE27896@electric-eye.fr.zoreil.com> <20050107170118.GU2940@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Broadbent <markb@wetlettuce.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
Content-Disposition: inline
In-Reply-To: <20050107170118.GU2940@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matt Mackall <mpm@selenic.com> :
[...]
> printk("debug: at point A");
> do_something_that_sends_a_packet_B();
> printk("debug: at point C");
> 
> Depending on locking and queueing, we might see on our network dump B,
> A, C, and wrongly conclude that whatever did B was not between A and C.
> That's a bad way for printk to work.

I completely agree that it is not perfect.

However netconsole is currently unable to guarantee that you will
always see both A and B (currently = assuming the skb is dropped
when netconsole fails trylock as suggested by Jamal). So there is
an issue with the reliability of the delivery as well.

I won't push harder on the queuing side as I believe that it will
be possible to add it as an extra choice to the user whatever form
netconsole takes to stop deadlocking.

[...]
> The bugs I'm talking about are identical to the xmit_lock deadlock
> except with locks we can't see outside the driver. In other words,

Right, it's clearer now. Thanks for the reminder.

User space takes device's private lock -> printks -> netconsole.write
-> hard_start_xmit -> device's private lock -> splat. Same thing from
interrupt context (in_irq() can probably help though).

So we ought to check rtnl_sem as well (dev_base_lock anyone ?).

/me scratches neck...

> this patch addresses the easy part of larger problem by adding a bunch
> of complexity that doesn't help in the larger problem. To me, that's a
> hint that it's the wrong fix.

Too big. It won't bite. :o)

[...]
> > I am not convinced that people will be satisfied with a rule which
> > states that printk _from anywhere_ are lost as soon as a CPU enters
> > in the xmit_lock zone but, hey, it's just me.
> 
> It should only be dropped on the CPU holding the lock, with a loud
> warning to follow shortly.

Sorry if I was not clear: "from anywhere" meant printk issued from
any part of the kernel which can interrupt the xmit_locked section
of a qdisc_run(), i.e. printk from irq handlers. 

If I read correctly the suggested design, the remaining CPUs should
loop in netpoll_send_skb() when they notice that they can not take
the lock and that their CPU do not own it, right ?

--
Ueimor
