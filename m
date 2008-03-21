From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-2.6.26] fib_trie: RCU optimizations
Date: Fri, 21 Mar 2008 09:01:03 -0700
Message-ID: <20080321160103.GG9618@linux.vnet.ibm.com>
References: <20080321075521.49347370@extreme>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:58925 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754278AbYCUQBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 12:01:12 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2LG14Dq026706
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 12:01:04 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2LG148E170820
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 10:01:04 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2LG14US013200
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 10:01:04 -0600
Content-Disposition: inline
In-Reply-To: <20080321075521.49347370@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 21, 2008 at 07:55:21AM -0700, Stephen Hemminger wrote:
> Small performance improvements.
> 
> Eliminate unneeded barrier on deletion. The first pointer to update
> the head of the list is ordered by the second call to rcu_assign_pointer.
> See hlist_add_after_rcu or comparision.
> 
> Move rcu_derference to the loop check (like hlist_for_each_rcu), and
> add a prefetch.

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Justification below.

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/net/ipv4/route.c	2008-03-19 08:45:32.000000000 -0700
> +++ b/net/ipv4/route.c	2008-03-19 08:54:57.000000000 -0700
> @@ -977,8 +977,8 @@ restart:
>  			 * must be visible to another weakly ordered CPU before
>  			 * the insertion at the start of the hash chain.
>  			 */
> -			rcu_assign_pointer(rth->u.dst.rt_next,
> -					   rt_hash_table[hash].chain);
> +			rth->u.dst.rt_next = rt_hash_table[hash].chain;
> +

This is OK because it is finalizing a deletion.  If this were instead
an insertion, this would of course be grossly illegal and dangerous.

>  			/*
>  			 * Since lookup is lockfree, the update writes
>  			 * must be ordered for consistency on SMP.
> @@ -2076,8 +2076,9 @@ int ip_route_input(struct sk_buff *skb, 
>  	hash = rt_hash(daddr, saddr, iif);
> 
>  	rcu_read_lock();
> -	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
> -	     rth = rcu_dereference(rth->u.dst.rt_next)) {
> +	for (rth = rt_hash_table[hash].chain; rcu_dereference(rth);
> +	     rth = rth->u.dst.rt_next) {
> +		prefetch(rth->u.dst.rt_next);
>  		if (rth->fl.fl4_dst == daddr &&
>  		    rth->fl.fl4_src == saddr &&
>  		    rth->fl.iif == iif &&

Works, though I would guess that increasingly aggressive compiler
optimization will eventually force us to change the list.h macros
to look like what you had to begin with...  Sigh!!!
