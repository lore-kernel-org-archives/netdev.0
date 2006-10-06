From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 3/6] 2.6.18: sb1250-mac: Phylib IRQ handling fixes
Date: Fri, 6 Oct 2006 08:03:23 -0700
Message-ID: <20061006080323.185f2b58.akpm@osdl.org>
References: <Pine.LNX.4.64N.0610031509380.4642@blysk.ds.pg.gda.pl>
	<20061005234310.6c8042b5.akpm@osdl.org>
	<Pine.LNX.4.64N.0610061152340.22053@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
To: "Maciej W. Rozycki" <macro@linux-mips.org>
In-Reply-To: <Pine.LNX.4.64N.0610061152340.22053@blysk.ds.pg.gda.pl>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Fri, 6 Oct 2006 12:26:22 +0100 (BST)
"Maciej W. Rozycki" <macro@linux-mips.org> wrote:

> On Thu, 5 Oct 2006, Andrew Morton wrote:
> 
> > > 2. The driver uses schedule_work() for handling interrupts, but does not 
> > >    make sure any pending work scheduled thus has been completed before 
> > >    driver's structures get freed from memory.  This is especially 
> > >    important as interrupts may keep arriving if the line is shared with 
> > >    another PHY.
> > > 
> > >    The solution is to ignore phy_interrupt() calls if the reported device 
> > >    has already been halted and calling flush_scheduled_work() from 
> > >    phy_stop_interrupts() (but guarded with current_is_keventd() in case 
> > >    the function has been called through keventd from the MAC device's 
> > >    close call to avoid a deadlock on the netlink lock).
> > > 
> > 
> > eww, hack.
> > 
> > Also not module-friendly:
> > 
> > WARNING: "current_is_keventd" [drivers/net/phy/libphy.ko] undefined!
> > 
> > Does this
> > 
> > static void flush_cpu_workqueue(struct cpu_workqueue_struct *cwq)
> > {
> > 	if (cwq->thread == current) {
> > 		/*
> > 		 * Probably keventd trying to flush its own queue. So simply run
> > 		 * it by hand rather than deadlocking.
> > 		 */
> > 		run_workqueue(cwq);
> > 
> > not work???
> 
>  It does, too well even! -- in the case I am trying to take care of we are 
> run with "rtnl_mutex" held as a result of rtnl_lock() called from 
> unregister_netdev() and there is some work already in the workqueue 
> (linkwatch_event(), apparently) wanting to acquire the same lock.  Hence a 
> deadlock.

I don't get it.  If some code does

	rtnl_lock();
	flush_scheduled_work();

and there's some work scheduled which does rtnl_lock() then it'll deadlock.

But it'll deadlock whether or not the caller of flush_scheduled_work() is
keventd.

Calling flush_scheduled_work() under locks is generally a bad idea.

>  It seems problematic elsewhere as well -- see tg3.c -- but a 
> different way to deal with it has been found there.
> 
>  I am not that fond of this solution, but at least it works, unlike 
> calling flush_scheduled_work() here, which deadlocks the current CPU in my 
> system instantly.  Any suggestions as to how to do this differently?  
> Perhaps linkwatch_event() should be scheduled differently (using a 
> separate workqueue?)...

I'd have thought that was still deadlockable.  Could you describe the
deadlock more completely please?
