From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [patch 2/7] CAN: Add PF_CAN core module
Date: Fri, 18 May 2007 17:03:41 +0200
Message-ID: <464DC04D.9020100@hartkopp.net>
References: <20070516145100.29877.0@janus.isnogud.escape.de> <20070516145121.29877.2@janus.isnogud.escape.de> <20070518005948.GA11737@linux.vnet.ibm.com> <464D6F85.9090202@hartkopp.net> <20070518143359.GA8876@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: paulmck@linux.vnet.ibm.com, Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:46163 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755135AbXERPEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 11:04:21 -0400
In-Reply-To: <20070518143359.GA8876@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hm, this is indeed one step further, than i thought :-)
Thanks for this nifty solution!

I will doublecheck your suggestion with Urs and then we'll change it in 
our next patch update (after some more feedback on this mailing list).
Additional feedback is welcome.

Tnx & best regards,
Oliver


Paul E. McKenney wrote:
> On Fri, May 18, 2007 at 11:19:01AM +0200, Oliver Hartkopp wrote:
>   
>> Hi Urs, Hello Paul,
>>
>> i assume Paul refers to the can_rx_delete_all() function that adds each 
>> receive list entry for rcu removal using the can_rx_delete RCU callback, 
>> right?
>>
>> So the idea would be to create a second RCU callback - e.g. 
>> can_rx_delete_list() - that removes the complete list inside the RCU 
>> callback?!?
>> The list removal would therefore be processed inside this new 
>> can_rx_delete_list() in RCU context and not inside can_rx_delete_all().
>>
>> @Paul: Was this your intention?
>>     
>
> My intention was that the list-removing be placed into can_rcv_lists_delete(),
> perhaps as follows:
>
> static void can_rx_delete_all(struct hlist_head *rl)
> {
> 	struct receiver *r;
> 	struct hlist_node *n;
>
> 	hlist_for_each_entry(r, n, rl, list) {
> 		hlist_del(&r->list);
> 		kmem_cache_free(rcv_cache, r);
> 	}
> }
>
> static void can_rcv_lists_delete(struct rcu_head *rp)
> {
> 	struct dev_rcv_lists *d = container_of(rp, struct dev_rcv_lists, rcu);
>
> 	/* remove all receivers hooked at this netdevice */
> 	can_rx_delete_all(&d->rx_err);
> 	can_rx_delete_all(&d->rx_all);
> 	can_rx_delete_all(&d->rx_fil);
> 	can_rx_delete_all(&d->rx_inv);
> 	can_rx_delete_all(&d->rx_eff);
> 	for (i = 0; i < 2048; i++)
> 		can_rx_delete_all(&d->rx_sff[i]);
> 	kfree(d);
> }
>
> Then the code in can_notifier() can reduce to the following:
>
> 	if (d) {
> 		hlist_del_rcu(&d->list);
>
> 		/* used to be a string of can_rx_delete_all(). */
> 	} else
> 		printk(KERN_ERR "can: notifier: receive list not "
> 		       "found for dev %s\n", dev->name);
>
> 	spin_lock_bh(&rcv_lists_lock);
>
> 	if (d) {
> 		call_rcu(&d->rcu, can_rcv_lists_delete);
> 	}
>
> This moves the traversal work into the callback function.  This is not
> a problem for CONFIG_PREEMPT_RT and non-CONFIG_PREEMPT, but not sure
> about CONFIG_PREEMPT.
>
> But it sure has the potential to cut down on a bunch of call_rcu()
> work...
>
> 						Thanx, Paul
>   


