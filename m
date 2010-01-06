From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] igmp: fix ip_mc_sf_allow race [v3]
Date: Wed, 6 Jan 2010 08:40:27 -0800
Message-ID: <20100106164027.GB6824@linux.vnet.ibm.com>
References: <4B42E252.1080405@gmail.com> <1262724742-5232-1-git-send-email-fleitner@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Flavio Leitner <fleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:53303 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755055Ab0AFQke (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2010 11:40:34 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o06GVQ9k026663
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2010 11:31:26 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o06GeWQm130414
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2010 11:40:32 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o06GeVf9019504
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2010 11:40:32 -0500
Content-Disposition: inline
In-Reply-To: <1262724742-5232-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 05, 2010 at 06:52:22PM -0200, Flavio Leitner wrote:
> Almost all igmp functions accessing inet->mc_list are protected by
> rtnl_lock(), but there is one exception which is ip_mc_sf_allow(),
> so there is a chance of either ip_mc_drop_socket or ip_mc_leave_group
> remove an entry while ip_mc_sf_allow is running causing a crash.

Looks like a good start from an RCU perspective, though I don't claim
to understand networking locking design.  A couple of questions below.

							Thanx, Paul

> Signed-off-by: Flavio Leitner <fleitner@redhat.com>
> ---
>  include/linux/igmp.h |    1 +
>  net/ipv4/igmp.c      |   58 +++++++++++++++++++++++++++++++++++++------------
>  2 files changed, 45 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/igmp.h b/include/linux/igmp.h
> index 724c27e..9cccd16 100644
> --- a/include/linux/igmp.h
> +++ b/include/linux/igmp.h
> @@ -170,6 +170,7 @@ struct ip_mc_socklist {
>  	struct ip_mreqn		multi;
>  	unsigned int		sfmode;		/* MCAST_{INCLUDE,EXCLUDE} */
>  	struct ip_sf_socklist	*sflist;
> +	struct rcu_head		rcu;
>  };
> 
>  struct ip_sf_list {
> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index 76c0840..61ff685 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -1799,7 +1799,7 @@ int ip_mc_join_group(struct sock *sk , struct ip_mreqn *imr)
>  	iml->next = inet->mc_list;
>  	iml->sflist = NULL;
>  	iml->sfmode = MCAST_EXCLUDE;
> -	inet->mc_list = iml;
> +	rcu_assign_pointer(inet->mc_list, iml);
>  	ip_mc_inc_group(in_dev, addr);
>  	err = 0;
>  done:
> @@ -1825,6 +1825,17 @@ static int ip_mc_leave_src(struct sock *sk, struct ip_mc_socklist *iml,
>  	return err;
>  }
> 
> +
> +static void ip_mc_socklist_reclaim(struct rcu_head *rp)
> +{
> +	struct ip_mc_socklist *iml;
> +
> +	iml = container_of(rp, struct ip_mc_socklist, rcu);
> +	/* sk_omem_alloc should have been decreased by the caller*/
> +	kfree(iml);
> +}
> +
> +
>  /*
>   *	Ask a socket to leave a group.
>   */
> @@ -1854,12 +1865,15 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
> 
>  		(void) ip_mc_leave_src(sk, iml, in_dev);

Suppose some other CPU invokes ip_mc_sf_allow() at this point.  Will that
CPU be OK with the current state of the structure pointed to by iml?
If not, some of the above code might need to be deferred to follow the
grace period.

> -		*imlp = iml->next;
> +		rcu_assign_pointer(*imlp, iml->next);
> 
>  		if (in_dev)
>  			ip_mc_dec_group(in_dev, group);
> +
>  		rtnl_unlock();
> -		sock_kfree_s(sk, iml, sizeof(*iml));
> +		/* decrease mem now to avoid the memleak warning */
> +		atomic_sub(sizeof(*iml), &sk->sk_omem_alloc);
> +		call_rcu(&iml->rcu, ip_mc_socklist_reclaim);
>  		return 0;
>  	}
>  	if (!in_dev)
> @@ -2209,30 +2223,40 @@ int ip_mc_sf_allow(struct sock *sk, __be32 loc_addr, __be32 rmt_addr, int dif)
>  	struct ip_mc_socklist *pmc;
>  	struct ip_sf_socklist *psl;
>  	int i;
> +	int ret;
> 
> +	ret = 1;
>  	if (!ipv4_is_multicast(loc_addr))
> -		return 1;
> +		goto out;
> 
> -	for (pmc=inet->mc_list; pmc; pmc=pmc->next) {
> +	rcu_read_lock();
> +	for (pmc=rcu_dereference(inet->mc_list); pmc; pmc=rcu_dereference(pmc->next)) {
>  		if (pmc->multi.imr_multiaddr.s_addr == loc_addr &&
>  		    pmc->multi.imr_ifindex == dif)
>  			break;
>  	}
> +	ret = inet->mc_all;
>  	if (!pmc)
> -		return inet->mc_all;
> +		goto unlock;
>  	psl = pmc->sflist;
> +	ret = (pmc->sfmode == MCAST_EXCLUDE);
>  	if (!psl)
> -		return pmc->sfmode == MCAST_EXCLUDE;
> +		goto unlock;
> 
>  	for (i=0; i<psl->sl_count; i++) {
>  		if (psl->sl_addr[i] == rmt_addr)
>  			break;
>  	}
> +	ret = 0;
>  	if (pmc->sfmode == MCAST_INCLUDE && i >= psl->sl_count)
> -		return 0;
> +		goto unlock;
>  	if (pmc->sfmode == MCAST_EXCLUDE && i < psl->sl_count)
> -		return 0;
> -	return 1;
> +		goto unlock;
> +	ret = 1;
> +unlock:
> +	rcu_read_unlock();
> +out:
> +	return ret;
>  }
> 
>  /*
> @@ -2245,13 +2269,17 @@ void ip_mc_drop_socket(struct sock *sk)
>  	struct ip_mc_socklist *iml;
>  	struct net *net = sock_net(sk);
> 
> -	if (inet->mc_list == NULL)
> +	rcu_read_lock();
> +	if (rcu_dereference(inet->mc_list) == NULL) {
> +		rcu_read_unlock();
>  		return;
> +	}
> +	rcu_read_unlock();

I don't understand what rcu_read_lock() is protecting here.  The
test is still unstable -- just after finding inet->mc_list non-NULL,
ip_mc_leave_group() might cause it to become NULL.

Is there a need to protect sock_net(sk)?  (I don't believe so, but then
again, I don't claim to understand locking in Linux networking.)
If there is no need, it should be possible to drop the rcu_read_lock(),
rcu_read_unlock(), and rcu_dereference() above.  (You might want them
for documentation purposes, as they aren't hurting anything, just
wondering what the intent is.)

>  	rtnl_lock();
> -	while ((iml = inet->mc_list) != NULL) {
> +	while ((iml = rcu_dereference(inet->mc_list)) != NULL) {
>  		struct in_device *in_dev;
> -		inet->mc_list = iml->next;
> +		rcu_assign_pointer(inet->mc_list, iml->next);
> 
>  		in_dev = inetdev_by_index(net, iml->multi.imr_ifindex);
>  		(void) ip_mc_leave_src(sk, iml, in_dev);
> @@ -2259,7 +2287,9 @@ void ip_mc_drop_socket(struct sock *sk)
>  			ip_mc_dec_group(in_dev, iml->multi.imr_multiaddr.s_addr);
>  			in_dev_put(in_dev);
>  		}
> -		sock_kfree_s(sk, iml, sizeof(*iml));
> +		/* decrease mem now to avoid the memleak warning */
> +		atomic_sub(sizeof(*iml), &sk->sk_omem_alloc);
> +		call_rcu(&iml->rcu, ip_mc_socklist_reclaim);
>  	}
>  	rtnl_unlock();
>  }
> -- 
> 1.6.2.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
