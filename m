From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 ( possibly?caused
 by netem)
Date: Thu, 9 Jul 2009 16:15:28 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.0907091601120.24704@localhost.localdomain>
References: <200907031326.21822.andres@anarazel.de> <200907071811.27570.andres@anarazel.de> <20090708080852.GC3148@ami.dom.local> <200907090023.18040.andres@anarazel.de> <20090708224828.GD3666@ami.dom.local> <alpine.LFD.2.00.0907090956490.24704@localhost.localdomain>
 <20090709104412.GA3651@ami.dom.local> <alpine.LFD.2.00.0907091401040.24704@localhost.localdomain> <20090709132256.GB3651@ami.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andres Freund <andres@anarazel.de>,
	Joao Correia <joaomiguelcorreia@gmail.com>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Peter Zijlstra <peterz@infradead.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:40863 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757499AbZGIOPr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 10:15:47 -0400
In-Reply-To: <20090709132256.GB3651@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 9 Jul 2009, Jarek Poplawski wrote:
> On Thu, Jul 09, 2009 at 02:03:50PM +0200, Thomas Gleixner wrote:
> > On Thu, 9 Jul 2009, Jarek Poplawski wrote:
> > > > 
> > > > I have the feeling that the code relies on some implicit cpu
> > > > boundness, which is not longer guaranteed with the timer migration
> > > > changes, but that's a question for the network experts.
> > > 
> > > As a matter of fact, I've just looked at this __netif_schedule(),
> > > which really is cpu bound, so you might be 100% right.
> > 
> > So the watchdog is the one which causes the trouble. The patch below
> > should fix this.
> 
> I hope so. On the other hand it seems it should work with this
> migration yet, so it probably needs additional debugging.

Right. I just provided the patch to narrow down the problem, but
please test the fix of the hrtimer migration code which I sent out a
bit earlier: http://lkml.org/lkml/2009/7/9/150

It fixes a possible endless loop in the timer code which is related to
the migration changes. Looking at the backtraces of the spinlock
lockup I think that is what you hit.

       spin_lock(root_lock);
       qdisc_run(q);
	 __qdisc_run(q);
	   dequeue_skb(q);
             q->dequeue(q);
               qdisc_watchdog_schedule();
                 hrtimer_start();
                   switch_hrtimer_base(); <- loops forever

Now the other CPU is stuck in dev_xmit() spin_lock(root_lock)

Thanks,

	tglx
