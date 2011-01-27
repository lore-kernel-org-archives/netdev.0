From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next-2.6] net: fix dev_seq_next()
Date: Thu, 27 Jan 2011 11:33:23 -0800
Message-ID: <20110127193323.GK2084@linux.vnet.ibm.com>
References: <1296101282.1783.54.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:33971 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751423Ab1A0Td1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jan 2011 14:33:27 -0500
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0RJOALn007321
	for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 14:24:21 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 100E5728068
	for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 14:33:26 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0RJXPYa329552
	for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 14:33:25 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0RJXP52031231
	for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 14:33:25 -0500
Content-Disposition: inline
In-Reply-To: <1296101282.1783.54.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 27, 2011 at 05:08:02AM +0100, Eric Dumazet wrote:
> Paul, the following comment in include/linux/rculist.h is misleading :
> 
> "Why is there no list_empty_rcu()?  Because list_empty() serves this
> purpose..."
> 
> This is probably why I made the error ;)
> 
> list_empty() has a meaning only if state cannot change right after its
> use.
> 
> In an rcu_read_lock() section, state _can_ change, so there is no way
> list_empty() can be used at all.

My apologies for my messup!!!

So, there are two things that I need to fix:

1.	There needs to be a list_empty_rcu() which contains an
	rcu_access_pointer() in order to keep sparse happy.

2.	The comment at the beginning of include/linux/rculist.h
	needs to warn that the return value from this new
	list_empty_rcu() API can become instantly obsolete,
	so the caller must either hold the update-side lock
	or be prepared to deal with obsolete values.

Or am I missing something?

							Thanx, Paul

> Thanks
> 
> [PATCH net-next-2.6] net: fix dev_seq_next()
> 
> Commit c6d14c84566d (net: Introduce for_each_netdev_rcu() iterator)
> added a race in dev_seq_next().
> 
> The rcu_dereference() call should be done _before_ testing the end of
> list, or we might return a wrong net_device if a concurrent thread
> changes net_device list under us.
> 
> Note : discovered thanks to a sparse warning :
> 
> net/core/dev.c:3919:9: error: incompatible types in comparison expression
> (different address spaces)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> ---
> Given this was discovered by code analysis rather than a bug report, I
> prepared a patch for net-next-2.6. Once fully tested, this could be
> backported to 2.6.33
> 
>  include/linux/netdevice.h |    9 ++++++++-
>  net/core/dev.c            |   11 +++++++----
>  2 files changed, 15 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 8858422..c7d7074 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1447,7 +1447,7 @@ static inline struct net_device *next_net_device_rcu(struct net_device *dev)
>  	struct net *net;
> 
>  	net = dev_net(dev);
> -	lh = rcu_dereference(dev->dev_list.next);
> +	lh = rcu_dereference(list_next_rcu(&dev->dev_list));
>  	return lh == &net->dev_base_head ? NULL : net_device_entry(lh);
>  }
> 
> @@ -1457,6 +1457,13 @@ static inline struct net_device *first_net_device(struct net *net)
>  		net_device_entry(net->dev_base_head.next);
>  }
> 
> +static inline struct net_device *first_net_device_rcu(struct net *net)
> +{
> +	struct list_head *lh = rcu_dereference(list_next_rcu(&net->dev_base_head));
> +
> +	return lh == &net->dev_base_head ? NULL : net_device_entry(lh);
> +}
> +
>  extern int 			netdev_boot_setup_check(struct net_device *dev);
>  extern unsigned long		netdev_boot_base(const char *prefix, int unit);
>  extern struct net_device *dev_getbyhwaddr_rcu(struct net *net, unsigned short type,
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 1b4c07f..ddd5df2 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4051,12 +4051,15 @@ void *dev_seq_start(struct seq_file *seq, loff_t *pos)
> 
>  void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>  {
> -	struct net_device *dev = (v == SEQ_START_TOKEN) ?
> -				  first_net_device(seq_file_net(seq)) :
> -				  next_net_device((struct net_device *)v);
> +	struct net_device *dev = v;
> +
> +	if (v == SEQ_START_TOKEN)
> +		dev = first_net_device_rcu(seq_file_net(seq));
> +	else
> +		dev = next_net_device_rcu(dev);
> 
>  	++*pos;
> -	return rcu_dereference(dev);
> +	return dev;
>  }
> 
>  void dev_seq_stop(struct seq_file *seq, void *v)
> 
> 
