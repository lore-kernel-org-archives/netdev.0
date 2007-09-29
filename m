From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: MSI interrupts and disable_irq
Date: Fri, 28 Sep 2007 20:08:01 -0700
Message-ID: <20070928200801.28f9bab7@freepuppy.rosehill>
References: <46FC15A9.1070803@nvidia.com>
	<46FDBCB4.9090802@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757387AbXI2DId@vger.kernel.org>
In-Reply-To: <46FDBCB4.9090802@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Sep 2007 22:47:16 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Ayaz Abdulla wrote:
> > I am trying to track down a forcedeth driver issue described by bug 9047 
> > in bugzilla (2.6.23-rc7-git1 forcedeth w/ MCP55 oops under heavy load). 
> > I added a patch to synchronize the timer handlers so that one handler 
> > doesn't accidently enable the IRQ while another timer handler is running 
> > (see attachment 'Add timer lock' in bug report) and for other processing 
> > protection.
> > 
> > However, the system still had an Oops. So I added a lock around the 
> > nv_rx_process_optimized() and the Oops has not happened (see attachment 
> > 'New patch for locking' in bug report). This would imply a 
> > synchronization issue. However, the only callers of that function are 
> > the IRQ handler and the timer handlers (in non-NAPI case). The timer 
> > handlers  use disable_irq so that the IRQ handler does not contend with 
> > them. It looks as if disable_irq is not working properly.
> > 
> > This issue repros only with MSI interrupt and not legacy INTx 
> > interrupts. Any ideas?
> 
> (added linux-kernel to CC, since I think it's more of a general kernel 
> issue)
> 
> To be brutally frank, I always thought this disable_irq() mess was a 
> hack both ugly and fragile.  This disable_irq() work that appeared in a 
> couple net drivers was correct at the time, so I didn't feel I had the 
> justification to reject it, but it still gave me a bad feeling.
> 
> I think the scenario you outline is an illustration of the approach's 
> fragility:  disable_irq() is a heavy hammer that originated with INTx, 
> and it relies on a chip-specific disable method (kernel/irq/manage.c) 
> that practically guarantees behavior will vary across MSI/INTx/etc.
> 
> Practices like forcedeth's unique locking work for a time, but it should 
> be a warning sign any time you stray from the normal spin_lock_irqsave() 
> method of synchronization.
> 
> Based on your report, it is certainly possible that there is a problem 
> with MSI's desc->chip->disable() method...  but I would actually 
> recommend working around the problem by making the forcedeth locking 
> more standardized by removing all those disable_irq() hacks.
> 
> Using spinlocks like other net drivers (note: avoid NETIF_F_LLTX 
> drivers) has a high probability of both fixing your current problem, and 
> giving forcedeth a more stable foundation for the long term.  In my 
> humble opinion :)
> 

I'll try and clean it up if the author doesn't get to it first.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
