From: Ben Greear <greearb@candelatech.com>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Wed, 03 Jan 2007 15:35:20 -0800
Message-ID: <459C3DB8.6090603@candelatech.com>
References: <OF68896635.077F2C1B-ON88257258.007F0BD8-88257258.007F8A72@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jarkao2@o2.pl, NetDev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:49216 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932182AbXACXfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 18:35:52 -0500
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF68896635.077F2C1B-ON88257258.007F0BD8-88257258.007F8A72@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens wrote:
> Ben,
>         Here's a patch that I think will fix it, assuming the receive is 
> on the
> same device as the initialization. Can you try this out?

We are attempting to reproduce this now...as soon as we can reproduce,
I'll apply this and see if that fixes the problem.  This race is evidently
quite difficult to hit, so I'm not sure how long this will take.

Perhaps someone like DaveM could review the patch for logical correctness
and go ahead and apply anyway if it is more correct?  I confuse myself often
enough trying to deal with the network stack locking that I should probably
not be the final arbiter of this patch :)

Thanks,
Ben

> 
>                                                 +-DLS
> [inline for viewing, attached for applying]
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> 
> diff -ruNp linux-2.6.19.1/net/ipv4/devinet.c 
> linux-2.6.19.1T1/net/ipv4/devinet.c
> --- linux-2.6.19.1/net/ipv4/devinet.c   2006-12-11 11:32:53.000000000 
> -0800
> +++ linux-2.6.19.1T1/net/ipv4/devinet.c 2007-01-03 14:37:56.000000000 
> -0800
> @@ -165,9 +165,8 @@ struct in_device *inetdev_init(struct ne
>                               NET_IPV4_NEIGH, "ipv4", NULL, NULL);
>  #endif
>  
> -       /* Account for reference dev->ip_ptr */
> +       /* Account for reference dev->ip_ptr (below) */
>         in_dev_hold(in_dev);
> -       rcu_assign_pointer(dev->ip_ptr, in_dev);
>  
>  #ifdef CONFIG_SYSCTL
>         devinet_sysctl_register(in_dev, &in_dev->cnf);
> @@ -176,6 +175,8 @@ struct in_device *inetdev_init(struct ne
>         if (dev->flags & IFF_UP)
>                 ip_mc_up(in_dev);
>  out:
> +       /* we can receive as soon as ip_ptr is set -- do this last */
> +       rcu_assign_pointer(dev->ip_ptr, in_dev);
>         return in_dev;
>  out_kfree:
>         kfree(in_dev);
> diff -ruNp linux-2.6.19.1/net/ipv6/addrconf.c 
> linux-2.6.19.1T1/net/ipv6/addrconf.c
> --- linux-2.6.19.1/net/ipv6/addrconf.c  2006-12-11 11:32:53.000000000 
> -0800
> +++ linux-2.6.19.1T1/net/ipv6/addrconf.c        2007-01-03 
> 14:47:07.000000000 -0800
> @@ -413,8 +413,6 @@ static struct inet6_dev * ipv6_add_dev(s
>         if (netif_carrier_ok(dev))
>                 ndev->if_flags |= IF_READY;
>  
> -       /* protected by rtnl_lock */
> -       rcu_assign_pointer(dev->ip6_ptr, ndev);
>  
>         ipv6_mc_init_dev(ndev);
>         ndev->tstamp = jiffies;
> @@ -425,6 +423,8 @@ static struct inet6_dev * ipv6_add_dev(s
>                               NULL);
>         addrconf_sysctl_register(ndev, &ndev->cnf);
>  #endif
> +       /* protected by rtnl_lock */
> +       rcu_assign_pointer(dev->ip6_ptr, ndev);
>         return ndev;
>  }
>  


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

