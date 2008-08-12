From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Tue, 12 Aug 2008 20:09:27 +0200
Message-ID: <20080812180927.GA3180@ami.dom.local>
References: <20080810190458.GA7279@ami.dom.local> <20080811100126.GA6401@ff.dom.local> <20080811232657.GQ6762@linux.vnet.ibm.com> <20080812063622.GA5066@ff.dom.local> <20080812134224.GC6909@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, emil.s.tantilov@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:30550 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbYHLSJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 14:09:37 -0400
Received: by nf-out-0910.google.com with SMTP id d3so908995nfc.21
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 11:09:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080812134224.GC6909@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 06:42:24AM -0700, Paul E. McKenney wrote:
> On Tue, Aug 12, 2008 at 06:36:22AM +0000, Jarek Poplawski wrote:
...
> > >From net/sched/sch_generic.c:
> > 
> > void __qdisc_run(struct Qdisc *q)
> > {
> >         unsigned long start_time = jiffies;
> > 
> >         while (qdisc_restart(q)) {
> >                 /*
> >                  * Postpone processing if
> >                  * 1. another process needs the CPU;
> >                  * 2. we've been doing it for too long.
> >                  */
> >                 if (need_resched() || jiffies != start_time) {
> >                         __netif_schedule(q);
> > 
> > This function is run from dev_queue_xmit() (net/core/dev.c) under
> > rcu_read_lock_bh(), and this "q" pointer is passed here for later use
> > (reading) by softirq run net_tx_action(). Alas in net/ RCU primitives
> > are probably omitted in a few places...
> 
> If I understand this code, one way to handle it would be to increment
> q->refcnt before passing to netif_schedule(), then decrementing it
> (within an RCU read-side critical section) in the softirq handler.
> 
> There are probably other ways to handle this as well.

I understand this similarly (but I'm still trying to find out what's
wrong with reading this again in a separate read-side section).

David gave some additional explanations (which BTW don't look to me
like very "orthodox" RCU) in this thread:
http://marc.info/?l=linux-netdev&m=121851847805942&w=2

Thanks,
Jarek P.
