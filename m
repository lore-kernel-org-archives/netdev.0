From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] ipv4: fix wildcard search with inet_confirm_addr()
Date: Fri, 8 Nov 2013 23:24:08 +0200 (EET)
Message-ID: <alpine.LFD.2.03.1311082258430.1811@ssi.bg>
References: <1383921428-4313-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:35103 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757460Ab3KHV0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 16:26:22 -0500
In-Reply-To: <1383921428-4313-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 8 Nov 2013, Nicolas Dichtel wrote:

> Help of this function says: "in_dev: only on this interface, 0=any interface",
> but in fact the code supposes that it will never be NULL.
> 
> Note that this function was never called with in_dev == NULL, but it's exported
> and may be used by an external module.

	The initial idea was that arp_ignore=3 can provide
dev=NULL. Later argument was changed to in_dev but we should
allow the NULL value. As you are going to change the arguments
may be we can partially revert commit 
39a6d06300128d32f361f4f790beba0ca83730eb, i.e. to add the
missing in_dev = NULL in arp_ignore() and also revert this change:

-       if (in_dev != NULL)
+       if (scope != RT_SCOPE_LINK)

> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> 
> This bug was spotted by code review.
> 
>  drivers/net/bonding/bonding.h | 10 +++-------
>  include/linux/inetdevice.h    |  3 ++-
>  net/ipv4/arp.c                |  3 ++-
>  net/ipv4/devinet.c            |  8 ++++----
>  4 files changed, 11 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
> index 03cf3fd14490..448895e90ccb 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -407,15 +407,11 @@ static inline bool bond_is_slave_inactive(struct slave *slave)
>  
>  static inline __be32 bond_confirm_addr(struct net_device *dev, __be32 dst, __be32 local)
>  {
> -	struct in_device *in_dev;
> -	__be32 addr = 0;
> +	__be32 addr;
>  
>  	rcu_read_lock();
> -	in_dev = __in_dev_get_rcu(dev);
> -
> -	if (in_dev)
> -		addr = inet_confirm_addr(in_dev, dst, local, RT_SCOPE_HOST);
> -
> +	addr = inet_confirm_addr(dev_net(dev), __in_dev_get_rcu(dev), dst,
> +				 local, RT_SCOPE_HOST);

	As in_dev = NULL should be allowed, above change
will not be needed, we should keep the 'if (in_dev)' there.

>  	rcu_read_unlock();
>  	return addr;
>  }
> diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
> index 79640e015a86..5870f7060917 100644
> --- a/include/linux/inetdevice.h
> +++ b/include/linux/inetdevice.h
> @@ -164,7 +164,8 @@ extern int		devinet_ioctl(struct net *net, unsigned int cmd, void __user *);
>  extern void		devinet_init(void);
>  extern struct in_device	*inetdev_by_index(struct net *, int);
>  extern __be32		inet_select_addr(const struct net_device *dev, __be32 dst, int scope);
> -extern __be32		inet_confirm_addr(struct in_device *in_dev, __be32 dst, __be32 local, int scope);
> +__be32 inet_confirm_addr(struct net *net, struct in_device *in_dev, __be32 dst,
> +			 __be32 local, int scope);
>  extern struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, __be32 prefix, __be32 mask);
>  
>  static __inline__ int inet_ifa_match(__be32 addr, struct in_ifaddr *ifa)
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 7808093cede6..fc5ebc7e1962 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -408,7 +408,8 @@ static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
>  	default:
>  		return 0;
>  	}
> -	return !inet_confirm_addr(in_dev, sip, tip, scope);
> +	return !inet_confirm_addr(dev_net(in_dev->dev), in_dev, sip, tip,
> +				  scope);

	We will need initial struct net *net = dev_net(in_dev->dev)
because later we will set in_dev to NULL for arp_ignore=3.
Then we will provide 'net' to inet_confirm_addr.

>  }
>  
>  static int arp_filter(__be32 sip, __be32 tip, struct net_device *dev)
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index a1b5bcbd04ae..47cdb035f817 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -1236,22 +1236,22 @@ static __be32 confirm_addr_indev(struct in_device *in_dev, __be32 dst,
>  
>  /*
>   * Confirm that local IP address exists using wildcards:
> + * - net: netns to check, cannot be NULL
>   * - in_dev: only on this interface, 0=any interface

	NULL is better than 0

>   * - dst: only in the same subnet as dst, 0=any dst
>   * - local: address, 0=autoselect the local address
>   * - scope: maximum allowed scope value for the local address
>   */
> -__be32 inet_confirm_addr(struct in_device *in_dev,
> +__be32 inet_confirm_addr(struct net *net, struct in_device *in_dev,
>  			 __be32 dst, __be32 local, int scope)
>  {
>  	__be32 addr = 0;
>  	struct net_device *dev;
> -	struct net *net;
>  
>  	if (scope != RT_SCOPE_LINK)

	Use if (in_dev)

> -		return confirm_addr_indev(in_dev, dst, local, scope);
> +		return in_dev ? confirm_addr_indev(in_dev, dst, local, scope) :
> +				0;

	We will not need the above change.

> -	net = dev_net(in_dev->dev);
>  	rcu_read_lock();
>  	for_each_netdev_rcu(net, dev) {
>  		in_dev = __in_dev_get_rcu(dev);
> -- 
> 1.8.4.1

Regards

--
Julian Anastasov <ja@ssi.bg>
