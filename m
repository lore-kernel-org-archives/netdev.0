From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [patch 2/7] CAN: Add PF_CAN core module
Date: Fri, 18 May 2007 07:33:59 -0700
Message-ID: <20070518143359.GA8876@linux.vnet.ibm.com>
References: <20070516145100.29877.0@janus.isnogud.escape.de> <20070516145121.29877.2@janus.isnogud.escape.de> <20070518005948.GA11737@linux.vnet.ibm.com> <464D6F85.9090202@hartkopp.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:38046 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752992AbXEROeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 May 2007 10:34:01 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4IEY1gm018021
	for <netdev@vger.kernel.org>; Fri, 18 May 2007 10:34:01 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4IEY14x529048
	for <netdev@vger.kernel.org>; Fri, 18 May 2007 10:34:01 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4IEY0QL014877
	for <netdev@vger.kernel.org>; Fri, 18 May 2007 10:34:01 -0400
Content-Disposition: inline
In-Reply-To: <464D6F85.9090202@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 18, 2007 at 11:19:01AM +0200, Oliver Hartkopp wrote:
> Hi Urs, Hello Paul,
> 
> i assume Paul refers to the can_rx_delete_all() function that adds each 
> receive list entry for rcu removal using the can_rx_delete RCU callback, 
> right?
> 
> So the idea would be to create a second RCU callback - e.g. 
> can_rx_delete_list() - that removes the complete list inside the RCU 
> callback?!?
> The list removal would therefore be processed inside this new 
> can_rx_delete_list() in RCU context and not inside can_rx_delete_all().
> 
> @Paul: Was this your intention?

My intention was that the list-removing be placed into can_rcv_lists_delete(),
perhaps as follows:

static void can_rx_delete_all(struct hlist_head *rl)
{
	struct receiver *r;
	struct hlist_node *n;

	hlist_for_each_entry(r, n, rl, list) {
		hlist_del(&r->list);
		kmem_cache_free(rcv_cache, r);
	}
}

static void can_rcv_lists_delete(struct rcu_head *rp)
{
	struct dev_rcv_lists *d = container_of(rp, struct dev_rcv_lists, rcu);

	/* remove all receivers hooked at this netdevice */
	can_rx_delete_all(&d->rx_err);
	can_rx_delete_all(&d->rx_all);
	can_rx_delete_all(&d->rx_fil);
	can_rx_delete_all(&d->rx_inv);
	can_rx_delete_all(&d->rx_eff);
	for (i = 0; i < 2048; i++)
		can_rx_delete_all(&d->rx_sff[i]);
	kfree(d);
}

Then the code in can_notifier() can reduce to the following:

	if (d) {
		hlist_del_rcu(&d->list);

		/* used to be a string of can_rx_delete_all(). */
	} else
		printk(KERN_ERR "can: notifier: receive list not "
		       "found for dev %s\n", dev->name);

	spin_lock_bh(&rcv_lists_lock);

	if (d) {
		call_rcu(&d->rcu, can_rcv_lists_delete);
	}

This moves the traversal work into the callback function.  This is not
a problem for CONFIG_PREEMPT_RT and non-CONFIG_PREEMPT, but not sure
about CONFIG_PREEMPT.

But it sure has the potential to cut down on a bunch of call_rcu()
work...

						Thanx, Paul

> Best regards,
> Oliver
> 
> Paul E. McKenney wrote:
> >On Wed, May 16, 2007 at 04:51:02PM +0200, Urs Thuermann wrote:
> >  
> >>This patch adds the CAN core functionality but no protocols or drivers.
> >>No protocol implementations are included here.  They come as separate
> >>patches.  Protocol numbers are already in include/linux/can.h.
> >>    
> >
> >Interesting!  One question called out below -- why do call_rcu() on each
> >piece of the struct dev_rcv_lists, instead of doing call_rcu() on the
> >whole thing and having the RCU callback free up the pieces?  Given that
> >all the pieces are call_rcu()ed separately, there had better not be
> >persistent pointers to the pieces, right?
> >
> >Doing it in one chunk would make the code a bit simpler and also reduce
> >the RCU overhead a bit.
> >
> >Or am I missing something subtle here?
> >
> >						Thanx, Paul
