From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Tue, 12 Aug 2008 06:36:22 +0000
Message-ID: <20080812063622.GA5066@ff.dom.local>
References: <20080810190458.GA7279@ami.dom.local> <20080811100126.GA6401@ff.dom.local> <20080811232657.GQ6762@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, emil.s.tantilov@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:7038 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbYHLGgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 02:36:32 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1255452fgg.17
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2008 23:36:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080811232657.GQ6762@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 04:26:57PM -0700, Paul E. McKenney wrote:
> On Mon, Aug 11, 2008 at 10:01:26AM +0000, Jarek Poplawski wrote:
> > On 10-08-2008 21:04, Jarek Poplawski wrote:
> > ...
> > > Hmm.. Actually, it's completely unreasonable. Let's forget this.
> > 
> > But accidentally it might even sometimes work here...
> > 
> > Currently, the most suspicious place to me seems to be
> > __netif_schedule(). Is it legal to store RCU protected pointers out of
> > rcu_read_lock() sections?
> 
> Yes, but:
> 
> 1.	You need to use one of the update-side primitives to do the
> 	store: rcu_assign_pointer(), list_add_rcu(), etc.
> 
> 2.	There has to be some way for multiple updaters to coordinate,
> 	for example:
> 
> 	a.	Only a single task is permitted to update.
> 
> 	b.	Locking is used to coordinate among multiple updaters
> 		(so that only one such updater may proceed at a given
> 		time).
> 
> 	c.	Atomic operations are used to coordinate multiple
> 		updaters.  Here be dragons, go for (a) or (b)
> 		instead unless you have an extremely good reason
> 		-and- you have both a proof of correctness and
> 		a totally brutal and malign test suite.
> 
> The main reason to update RCU-protected pointers within rcu_read_lock()
> regions is when sharing code between RCU readers and updaters, or when
> an RCU reader can see the need to do an update.

Sure, but I'm concerned here with pure RCU reading:

>From net/sched/sch_generic.c:

void __qdisc_run(struct Qdisc *q)
{
        unsigned long start_time = jiffies;

        while (qdisc_restart(q)) {
                /*
                 * Postpone processing if
                 * 1. another process needs the CPU;
                 * 2. we've been doing it for too long.
                 */
                if (need_resched() || jiffies != start_time) {
                        __netif_schedule(q);

This function is run from dev_queue_xmit() (net/core/dev.c) under
rcu_read_lock_bh(), and this "q" pointer is passed here for later use
(reading) by softirq run net_tx_action(). Alas in net/ RCU primitives
are probably omitted in a few places...

Thanks for the explanation,
Jarek P.

                        break;
                }
        }

        clear_bit(__QDISC_STATE_RUNNING, &q->state);
}
