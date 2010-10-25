From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netlink: fix netlink_change_ngroups()
Date: Sun, 24 Oct 2010 21:14:56 -0700
Message-ID: <20101025041456.GB3087@linux.vnet.ibm.com>
References: <1287930430.2658.805.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:54000 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750742Ab0JYEPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Oct 2010 00:15:03 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o9P47eH1021859
	for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 00:07:40 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9P4ExcN106504
	for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 00:14:59 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9P4Ew3a030068
	for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 00:14:59 -0400
Content-Disposition: inline
In-Reply-To: <1287930430.2658.805.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 24, 2010 at 04:27:10PM +0200, Eric Dumazet wrote:
> commit 6c04bb18ddd633 (netlink: use call_rcu for netlink_change_ngroups)
> used a somewhat convoluted and racy way to perform call_rcu().
> 
> The old block of memory is freed after a grace period, but the rcu_head
> used to track it is located in new block.
> 
> This can clash if we call two times or more netlink_change_ngroups(),
> and a block is freed before another. call_rcu() called on different cpus
> makes no guarantee in order of callbacks.
> 
> Fix this using a more standard way of handling this : Each block of
> memory contains its own rcu_head, so that no 'use after free' can
> happens.

Good catch, Eric!!!  I believe this needs to be mentioned in the RCU
docs, will get it in there.

							Thanx, Paul

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Johannes Berg <johannes@sipsolutions.net>
> CC: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> ---
>  net/netlink/af_netlink.c |   65 +++++++++++++------------------------
>  1 files changed, 24 insertions(+), 41 deletions(-)
> 
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index cd96ed3..478181d 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -83,9 +83,9 @@ struct netlink_sock {
>  	struct module		*module;
>  };
> 
> -struct listeners_rcu_head {
> -	struct rcu_head rcu_head;
> -	void *ptr;
> +struct listeners {
> +	struct rcu_head		rcu;
> +	unsigned long		masks[0];
>  };
> 
>  #define NETLINK_KERNEL_SOCKET	0x1
> @@ -119,7 +119,7 @@ struct nl_pid_hash {
>  struct netlink_table {
>  	struct nl_pid_hash hash;
>  	struct hlist_head mc_list;
> -	unsigned long *listeners;
> +	struct listeners __rcu *listeners;
>  	unsigned int nl_nonroot;
>  	unsigned int groups;
>  	struct mutex *cb_mutex;
> @@ -338,7 +338,7 @@ netlink_update_listeners(struct sock *sk)
>  			if (i < NLGRPLONGS(nlk_sk(sk)->ngroups))
>  				mask |= nlk_sk(sk)->groups[i];
>  		}
> -		tbl->listeners[i] = mask;
> +		tbl->listeners->masks[i] = mask;
>  	}
>  	/* this function is only called with the netlink table "grabbed", which
>  	 * makes sure updates are visible before bind or setsockopt return. */
> @@ -936,7 +936,7 @@ EXPORT_SYMBOL(netlink_unicast);
>  int netlink_has_listeners(struct sock *sk, unsigned int group)
>  {
>  	int res = 0;
> -	unsigned long *listeners;
> +	struct listeners *listeners;
> 
>  	BUG_ON(!netlink_is_kernel(sk));
> 
> @@ -944,7 +944,7 @@ int netlink_has_listeners(struct sock *sk, unsigned int group)
>  	listeners = rcu_dereference(nl_table[sk->sk_protocol].listeners);
> 
>  	if (group - 1 < nl_table[sk->sk_protocol].groups)
> -		res = test_bit(group - 1, listeners);
> +		res = test_bit(group - 1, listeners->masks);
> 
>  	rcu_read_unlock();
> 
> @@ -1498,7 +1498,7 @@ netlink_kernel_create(struct net *net, int unit, unsigned int groups,
>  	struct socket *sock;
>  	struct sock *sk;
>  	struct netlink_sock *nlk;
> -	unsigned long *listeners = NULL;
> +	struct listeners *listeners = NULL;
> 
>  	BUG_ON(!nl_table);
> 
> @@ -1523,8 +1523,7 @@ netlink_kernel_create(struct net *net, int unit, unsigned int groups,
>  	if (groups < 32)
>  		groups = 32;
> 
> -	listeners = kzalloc(NLGRPSZ(groups) + sizeof(struct listeners_rcu_head),
> -			    GFP_KERNEL);
> +	listeners = kzalloc(sizeof(*listeners) + NLGRPSZ(groups), GFP_KERNEL);
>  	if (!listeners)
>  		goto out_sock_release;
> 
> @@ -1541,7 +1540,7 @@ netlink_kernel_create(struct net *net, int unit, unsigned int groups,
>  	netlink_table_grab();
>  	if (!nl_table[unit].registered) {
>  		nl_table[unit].groups = groups;
> -		nl_table[unit].listeners = listeners;
> +		rcu_assign_pointer(nl_table[unit].listeners, listeners);
>  		nl_table[unit].cb_mutex = cb_mutex;
>  		nl_table[unit].module = module;
>  		nl_table[unit].registered = 1;
> @@ -1572,43 +1571,28 @@ netlink_kernel_release(struct sock *sk)
>  EXPORT_SYMBOL(netlink_kernel_release);
> 
> 
> -static void netlink_free_old_listeners(struct rcu_head *rcu_head)
> +static void listeners_free_rcu(struct rcu_head *head)
>  {
> -	struct listeners_rcu_head *lrh;
> -
> -	lrh = container_of(rcu_head, struct listeners_rcu_head, rcu_head);
> -	kfree(lrh->ptr);
> +	kfree(container_of(head, struct listeners, rcu));
>  }
> 
>  int __netlink_change_ngroups(struct sock *sk, unsigned int groups)
>  {
> -	unsigned long *listeners, *old = NULL;
> -	struct listeners_rcu_head *old_rcu_head;
> +	struct listeners *new, *old;
>  	struct netlink_table *tbl = &nl_table[sk->sk_protocol];
> 
>  	if (groups < 32)
>  		groups = 32;
> 
>  	if (NLGRPSZ(tbl->groups) < NLGRPSZ(groups)) {
> -		listeners = kzalloc(NLGRPSZ(groups) +
> -				    sizeof(struct listeners_rcu_head),
> -				    GFP_ATOMIC);
> -		if (!listeners)
> +		new = kzalloc(sizeof(*new) + NLGRPSZ(groups), GFP_ATOMIC);
> +		if (!new)
>  			return -ENOMEM;
> -		old = tbl->listeners;
> -		memcpy(listeners, old, NLGRPSZ(tbl->groups));
> -		rcu_assign_pointer(tbl->listeners, listeners);
> -		/*
> -		 * Free the old memory after an RCU grace period so we
> -		 * don't leak it. We use call_rcu() here in order to be
> -		 * able to call this function from atomic contexts. The
> -		 * allocation of this memory will have reserved enough
> -		 * space for struct listeners_rcu_head at the end.
> -		 */
> -		old_rcu_head = (void *)(tbl->listeners +
> -					NLGRPLONGS(tbl->groups));
> -		old_rcu_head->ptr = old;
> -		call_rcu(&old_rcu_head->rcu_head, netlink_free_old_listeners);
> +		old = rcu_dereference_raw(tbl->listeners);
> +		memcpy(new->masks, old->masks, NLGRPSZ(tbl->groups));
> +		rcu_assign_pointer(tbl->listeners, new);
> +
> +		call_rcu(&old->rcu, listeners_free_rcu);
>  	}
>  	tbl->groups = groups;
> 
> @@ -2104,18 +2088,17 @@ static void __net_exit netlink_net_exit(struct net *net)
> 
>  static void __init netlink_add_usersock_entry(void)
>  {
> -	unsigned long *listeners;
> +	struct listeners *listeners;
>  	int groups = 32;
> 
> -	listeners = kzalloc(NLGRPSZ(groups) + sizeof(struct listeners_rcu_head),
> -			    GFP_KERNEL);
> +	listeners = kzalloc(sizeof(*listeners) + NLGRPSZ(groups), GFP_KERNEL);
>  	if (!listeners)
> -		panic("netlink_add_usersock_entry: Cannot allocate listneres\n");
> +		panic("netlink_add_usersock_entry: Cannot allocate listeners\n");
> 
>  	netlink_table_grab();
> 
>  	nl_table[NETLINK_USERSOCK].groups = groups;
> -	nl_table[NETLINK_USERSOCK].listeners = listeners;
> +	rcu_assign_pointer(nl_table[NETLINK_USERSOCK].listeners, listeners);
>  	nl_table[NETLINK_USERSOCK].module = THIS_MODULE;
>  	nl_table[NETLINK_USERSOCK].registered = 1;
> 
> 
> 
