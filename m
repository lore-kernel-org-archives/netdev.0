From: Matt Mackall <mpm@selenic.com>
Subject: Re: Followup to netpoll issues
Date: Fri, 7 Jan 2005 09:01:18 -0800
Message-ID: <20050107170118.GU2940@waste.org>
References: <1105045914.7687.3.camel@tigger> <20050106234610.GT2940@waste.org> <20050107011547.GE27896@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Broadbent <markb@wetlettuce.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20050107011547.GE27896@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jan 07, 2005 at 02:15:47AM +0100, Francois Romieu wrote:
> Matt Mackall <mpm@selenic.com> :
> [...]
> > I've tinkered with this idea as well, but I'm not convinced it's the
> > right idea. All current netpoll users (netconsole, kgdb, netdump) are
> > intrinsically concerned with timeliness of delivery. Queueing packets
>                           ^^^^^^^^^^^^^^^
> (as well as with reliability of the delivery maybe)

> > for later delivery simply doesn't work with the latter two and might
> > mislead with the former (eg netconsole message and other network
> > traffic could be reordered).
> 
> If kernel/printk.c::vprintk can not take the console semaphore, I
> would say that messages are reordered with regard to the order in
> which xmit_lock has been taken even without Mark's patch.
> 
> So what do you exactly mean by "reordered" ?

printk("debug: at point A");
do_something_that_sends_a_packet_B();
printk("debug: at point C");

Depending on locking and queueing, we might see on our network dump B,
A, C, and wrongly conclude that whatever did B was not between A and C.
That's a bad way for printk to work.

> > Also note that there's a closely related class of deadlock that we
> > can't detect: netconsole-induced recursion on driver-private locks. We
> > haven't actually seen one of these yet and haven't attempted to audit
> > for them, but my plan all along has been to treat it as a bug and
> > hoist offending printks out of the locked regions. Note that this is
> > really a netconsole-specific problem as the other netpoll clients are
> > unlikely to have such usage patterns.
> 
> Is is still a problem if Mark turns the spinlock in tx_retry_wq() into
> an irq safe trylock ?
> 
> (driver-private bugs could/will be inherited but fixing these is not
> netconsole's job).

The bugs I'm talking about are identical to the xmit_lock deadlock
except with locks we can't see outside the driver. In other words,
this patch addresses the easy part of larger problem by adding a bunch
of complexity that doesn't help in the larger problem. To me, that's a
hint that it's the wrong fix.

> > Since the xmit_lock is so similar, it seems things that hit it ought
> > to get the same treatment. So the rule becomes: no printk with network
> > driver locks held (public or private). This is obviously broken in the
> > face of oopsing in the driver, but netconsole can't be expected to
> > work under such conditions anyway.
> 
> I am not convinced that people will be satisfied with a rule which
> states that printk _from anywhere_ are lost as soon as a CPU enters
> in the xmit_lock zone but, hey, it's just me.

It should only be dropped on the CPU holding the lock, with a loud
warning to follow shortly.

> Objection against Ccing further messages to netdev ? It is better indexed
> than our mailboxes.

Nope.

-- 
Mathematics is the supreme nostalgia of our time.
