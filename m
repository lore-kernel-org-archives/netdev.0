From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next 1/5] ipv6: addrconf: cleanup locking in
 ipv6_add_addr
Date: Sun, 15 Oct 2017 10:50:52 +0300
Message-ID: <20171015075052.GA10604@shredder.mtl.com>
References: <1507935733-18950-1-git-send-email-dsahern@gmail.com>
 <1507935733-18950-2-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        kjlx@templeofstupid.com, davem@davemloft.net,
        yoshfuji@linux-ipv6.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:47399 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751321AbdJOHu4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 03:50:56 -0400
Content-Disposition: inline
In-Reply-To: <1507935733-18950-2-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 13, 2017 at 04:02:09PM -0700, David Ahern wrote:
> ipv6_add_addr is called in process context with rtnl lock held
> (e.g., manual config of an address) or during softirq processing
> (e.g., autoconf and address from a router advertisement).
> 
> Currently, ipv6_add_addr calls rcu_read_lock_bh shortly after entry
> and does not call unlock until exit, minus the call around the address
> validator notifier. Similarly, addrconf_hash_lock is taken after the
> validator notifier and held until exit. This forces the allocation of
> inet6_ifaddr to always be atomic.
> 
> Refactor ipv6_add_addr as follows:
> 1. add an input boolean to discriminate the call path (process context
>    or softirq). This new flag controls whether the alloc can be done
>    with GFP_KERNEL or GFP_ATOMIC.
> 
> 2. Move the rcu_read_lock_bh and unlock calls only around functions that
>    do rcu updates.
> 
> 3. Remove the in6_dev_hold and put added by 3ad7d2468f79f ("Ipvlan should
>    return an error when an address is already in use."). This was done
>    presumably because rcu_read_unlock_bh needs to be called before calling
>    the validator. Since rcu_read_lock is not needed before the validator
>    runs revert the hold and put added by 3ad7d2468f79f and only do the
>    hold when setting ifp->idev.
> 
> 4. move duplicate address check and insertion of new address in the global
>    address hash into a helper. The helper is called after an ifa is
>    allocated and filled in.
> 
> This allows the ifa for manually configured addresses to be done with
> GFP_KERNEL and reduces the overall amount of time with rcu_read_lock held
> and hash table spinlock held.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

[...]

> @@ -1073,21 +1085,19 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
>  
>  	in6_ifa_hold(ifa);
>  	write_unlock(&idev->lock);
> -out2:
> +
>  	rcu_read_unlock_bh();
>  
> -	if (likely(err == 0))
> -		inet6addr_notifier_call_chain(NETDEV_UP, ifa);
> -	else {
> +	inet6addr_notifier_call_chain(NETDEV_UP, ifa);
> +out:
> +	if (unlikely(err < 0)) {
> +		if (rt)
> +			ip6_rt_put(rt);

I believe 'rt' needs to be set to NULL after addrconf_dst_alloc()
fails.

>  		kfree(ifa);
> -		in6_dev_put(idev);
>  		ifa = ERR_PTR(err);
>  	}
>  
>  	return ifa;
> -out:
> -	spin_unlock(&addrconf_hash_lock);
> -	goto out2;
>  }
