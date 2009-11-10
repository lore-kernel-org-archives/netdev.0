From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 01/10] netdev: add netdev_continue_rcu
Date: Tue, 10 Nov 2009 11:39:45 -0800
Message-ID: <20091110193945.GU8424@linux.vnet.ibm.com>
References: <20091110175446.280423729@vyatta.com> <20091110175647.200655064@vyatta.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:40726 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754394AbZKJTja (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 14:39:30 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e6.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nAAJj6OA031579
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 14:45:06 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAAJdZx1050202
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 14:39:35 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAAJdZKB010650
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 14:39:35 -0500
Content-Disposition: inline
In-Reply-To: <20091110175647.200655064@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2009 at 09:54:47AM -0800, Stephen Hemminger wrote:
> This adds an RCU macro for continuing search, useful for some
> network devices like vlan.

Looks good!!!

Of course, you need to either have a single RCU read-side critical section
cover all the chained list_for_each_entry_continue_rcu() invocations, or
you need to do something (e.g., reference count) to make sure that the
element in question doesn't disappear in the meantime, right?

							Thanx, Paul

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/include/linux/netdevice.h	2009-11-09 22:19:08.511480873 -0800
> +++ b/include/linux/netdevice.h	2009-11-10 09:27:17.973376267 -0800
> @@ -1079,6 +1079,8 @@ extern rwlock_t				dev_base_lock;		/* De
>  		list_for_each_entry_safe(d, n, &(net)->dev_base_head, dev_list)
>  #define for_each_netdev_continue(net, d)		\
>  		list_for_each_entry_continue(d, &(net)->dev_base_head, dev_list)
> +#define for_each_netdev_continue_rcu(net, d)		\
> +	list_for_each_entry_continue_rcu(d, &(net)->dev_base_head, dev_list)
>  #define net_device_entry(lh)	list_entry(lh, struct net_device, dev_list)
> 
>  static inline struct net_device *next_net_device(struct net_device *dev)
> --- a/include/linux/rculist.h	2009-11-09 22:19:08.529480859 -0800
> +++ b/include/linux/rculist.h	2009-11-10 09:27:17.974376609 -0800
> @@ -262,6 +262,20 @@ static inline void list_splice_init_rcu(
>  		(pos) = rcu_dereference((pos)->next))
> 
>  /**
> + * list_for_each_entry_continue_rcu - continue iteration over list of given type
> + * @pos:	the type * to use as a loop cursor.
> + * @head:	the head for your list.
> + * @member:	the name of the list_struct within the struct.
> + *
> + * Continue to iterate over list of given type, continuing after
> + * the current position.
> + */
> +#define list_for_each_entry_continue_rcu(pos, head, member) 		\
> +	for (pos = list_entry_rcu(pos->member.next, typeof(*pos), member); \
> +	     prefetch(pos->member.next), &pos->member != (head);	\
> +	     pos = list_entry_rcu(pos->member.next, typeof(*pos), member))
> +
> +/**
>   * hlist_del_rcu - deletes entry from hash list without re-initialization
>   * @n: the element to delete from the hash list.
>   *
> 
> -- 
> 
