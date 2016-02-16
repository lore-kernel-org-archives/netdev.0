From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Tue, 16 Feb 2016 17:45:49 +0900
Message-ID: <56C2E1BD.30006@miraclelinux.com>
References: <1455402207-9217-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, hannes@stressinduktion.org
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36785 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379AbcBPIpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 03:45:52 -0500
Received: by mail-pf0-f177.google.com with SMTP id e127so101613801pfe.3
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 00:45:52 -0800 (PST)
In-Reply-To: <1455402207-9217-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

David Ahern wrote:
> Currently, all ipv6 addresses are flushed when the interface is configured
> down, including global, static addresses:
> 
>     $ ip -6 addr add dev eth1 2000:11:1:1::1/64
>     $ ip addr show dev eth1
>     3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
>         link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>         inet6 2000:11:1:1::1/64 scope global tentative
>            valid_lft forever preferred_lft forever
>     $ ip link set dev eth1 up
>     $ ip link set dev eth1 down
>     $ ip addr show dev eth1
>     3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>         link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
> 
> Add a new sysctl to make this behavior optional. The new setting defaults to
> flush all addresses to maintain backwards compatibility. When the set global
> addresses with no expire times are not flushed on an admin down:
> 
>     $ echo 1 > /proc/sys/net/ipv6/conf/eth1/keep_addr_on_down
>     $ ip -6 addr add dev eth1 2000:11:1:1::1/64
>     $ ip addr show dev eth1
>     3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>         link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>         inet6 2000:11:1:1::1/64 scope global tentative
>            valid_lft forever preferred_lft forever
>     $ ip link set dev eth1 up
>     $ ip link set dev eth1 down
>     $ ip addr show dev eth1
>     3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>         link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>         inet6 2000:11:1:1::1/64 scope global
>            valid_lft forever preferred_lft forever
>         inet6 fe80::4:11ff:fe22:3301/64 scope link
>            valid_lft forever preferred_lft forever
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> Dave: per the discussion at netconf tossing this out again. While the
>       failure semantics are not ideal it only occurs on GFP_ATOMIC
>       memory failures.
:
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index 24ce97f42d35..7ddbbb67f0db 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -1563,6 +1563,12 @@ temp_prefered_lft - INTEGER
>  	Preferred lifetime (in seconds) for temporary addresses.
>  	Default: 86400 (1 day)
>  
> +keep_addr_on_down - BOOLEAN
> +	Keep all IPv6 addresses on an interface down event. If set static
> +	global addresses with no expiration time are not flushed.
> +
> +	Default: disabled
> +

How about this:
   1: enabled
   0: system default
  -1: disabled
so that an iterface can override system-wide config?

>  max_desync_factor - INTEGER
>  	Maximum value for DESYNC_FACTOR, which is a random value
>  	that ensures that clients don't synchronize with each
> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> index 4b2267e1b7c3..7edc14fb66b6 100644
> --- a/include/linux/ipv6.h
> +++ b/include/linux/ipv6.h
> @@ -62,6 +62,7 @@ struct ipv6_devconf {
>  		struct in6_addr secret;
>  	} stable_secret;
>  	__s32		use_oif_addrs_only;
> +	__s32		keep_addr_on_down;
>  	void		*sysctl;
>  };
>  
> diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
> index 1c8b6820b694..01ba6a286a4b 100644
> --- a/include/net/if_inet6.h
> +++ b/include/net/if_inet6.h
> @@ -72,6 +72,7 @@ struct inet6_ifaddr {
>  	int			regen_count;
>  
>  	bool			tokenized;
> +	bool			user_managed;

Can't we use IFA_F_PERMANENT?

> diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
> index ec117b65d5a5..395876060f50 100644
> --- a/include/uapi/linux/ipv6.h
> +++ b/include/uapi/linux/ipv6.h
> @@ -176,6 +176,7 @@ enum {
>  	DEVCONF_IGNORE_ROUTES_WITH_LINKDOWN,
>  	DEVCONF_DROP_UNICAST_IN_L2_MULTICAST,
>  	DEVCONF_DROP_UNSOLICITED_NA,
> +	DEVCONF_KEEP_ADDR_ON_DOWN,
>  	DEVCONF_MAX
>  };
>  
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index ac0ba9e4e06b..0bcb0f538e54 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -216,6 +216,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
>  	},
>  	.use_oif_addrs_only	= 0,
>  	.ignore_routes_with_linkdown = 0,
> +	.keep_addr_on_down	= 0,
>  };
>  
>  static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
> @@ -260,6 +261,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
>  	},
>  	.use_oif_addrs_only	= 0,
>  	.ignore_routes_with_linkdown = 0,
> +	.keep_addr_on_down	= 0,
>  };
>  
>  /* Check if a valid qdisc is available */
> @@ -962,6 +964,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
>  	ifa->prefered_lft = prefered_lft;
>  	ifa->cstamp = ifa->tstamp = jiffies;
>  	ifa->tokenized = false;
> +	ifa->user_managed = false;
>  
>  	ifa->rt = rt;
>  
> @@ -2701,6 +2704,9 @@ static int inet6_addr_add(struct net *net, int ifindex,
>  			    valid_lft, prefered_lft);
>  
>  	if (!IS_ERR(ifp)) {
> +		if (!expires)
> +			ifp->user_managed = true;
> +
>  		if (!(ifa_flags & IFA_F_NOPREFIXROUTE)) {
>  			addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev,
>  					      expires, flags);
> @@ -3168,6 +3174,55 @@ static void addrconf_gre_config(struct net_device *dev)
>  }
>  #endif
>  
> +static int fixup_user_managed_addr(struct inet6_dev *idev,
> +				   struct inet6_ifaddr *ifp)
> +{
> +	if (!ifp->rt) {
> +		struct rt6_info *rt;
> +
> +		rt = addrconf_dst_alloc(idev, &ifp->addr, false);
> +		if (unlikely(IS_ERR(rt)))
> +			return PTR_ERR(rt);
> +
> +		ifp->rt = rt;
> +	}
> +
> +	if (!(ifp->flags & IFA_F_NOPREFIXROUTE)) {
> +		addrconf_prefix_route(&ifp->addr, ifp->prefix_len,
> +				      idev->dev, 0, 0);
> +	}
> +
> +	addrconf_dad_start(ifp);
> +
> +	return 0;
> +}
> +
> +static void addrconf_user_managed_addr(struct net_device *dev)
> +{
> +	struct inet6_ifaddr *ifp, *tmp;
> +	struct inet6_dev *idev;
> +
> +	idev = __in6_dev_get(dev);
> +	if (!idev)
> +		return;
> +
> +	write_lock_bh(&idev->lock);
> +
> +	list_for_each_entry_safe(ifp, tmp, &idev->addr_list, if_list) {
> +		if (ifp->user_managed &&
> +		    fixup_user_managed_addr(idev, ifp) < 0) {
> +			write_unlock_bh(&idev->lock);
> +			ipv6_del_addr(ifp);
> +			write_lock_bh(&idev->lock);
> +
> +			net_info_ratelimited("%s: Failed to add prefix route for address %pI6c; dropping\n",
> +					     idev->dev->name, &ifp->addr);
> +		}
> +	}
> +
> +	write_unlock_bh(&idev->lock);
> +}
> +
>  static int addrconf_notify(struct notifier_block *this, unsigned long event,
>  			   void *ptr)
>  {
> @@ -3253,6 +3308,8 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
>  			run_pending = 1;
>  		}
>  
> +		addrconf_user_managed_addr(dev);
> +
>  		switch (dev->type) {
>  #if IS_ENABLED(CONFIG_IPV6_SIT)
>  		case ARPHRD_SIT:
> @@ -3356,7 +3413,9 @@ static int addrconf_ifdown(struct net_device *dev, int how)
>  {
>  	struct net *net = dev_net(dev);
>  	struct inet6_dev *idev;
> -	struct inet6_ifaddr *ifa;
> +	struct inet6_ifaddr *ifa, *tmp;
> +	struct list_head del_list;
> +	int keep_addr;
>  	int state, i;
>  
>  	ASSERT_RTNL();
> @@ -3383,6 +3442,10 @@ static int addrconf_ifdown(struct net_device *dev, int how)
>  
>  	}
>  
> +	keep_addr = net->ipv6.devconf_all->keep_addr_on_down;
> +	if (!keep_addr)
> +		keep_addr = idev->cnf.keep_addr_on_down;
> +
>  	/* Step 2: clear hash table */
>  	for (i = 0; i < IN6_ADDR_HSIZE; i++) {
>  		struct hlist_head *h = &inet6_addr_lst[i];
> @@ -3391,9 +3454,12 @@ static int addrconf_ifdown(struct net_device *dev, int how)
>  restart:
>  		hlist_for_each_entry_rcu(ifa, h, addr_lst) {
>  			if (ifa->idev == idev) {
> -				hlist_del_init_rcu(&ifa->addr_lst);
>  				addrconf_del_dad_work(ifa);
> -				goto restart;
> +				if (how || !keep_addr || !ifa->user_managed) {

keep_addr <= 0

> +					hlist_del_init_rcu(&ifa->addr_lst);
> +					goto restart;
> +				}
> +
>  			}
>  		}
>  		spin_unlock_bh(&addrconf_hash_lock);
> @@ -3427,31 +3493,52 @@ static int addrconf_ifdown(struct net_device *dev, int how)
>  		write_lock_bh(&idev->lock);
>  	}
>  
> -	while (!list_empty(&idev->addr_list)) {
> -		ifa = list_first_entry(&idev->addr_list,
> -				       struct inet6_ifaddr, if_list);
> -		addrconf_del_dad_work(ifa);
> +	INIT_LIST_HEAD(&del_list);
> +	list_for_each_entry_safe(ifa, tmp, &idev->addr_list, if_list) {
> +		bool keep_ifa = false;
>  
> -		list_del(&ifa->if_list);
> +		if (!how && keep_addr && ifa->user_managed)

keep_addr > 0

etc...

> +			keep_ifa = true;
>  
> -		write_unlock_bh(&idev->lock);
> +		addrconf_del_dad_work(ifa);
>  
> +		write_unlock_bh(&idev->lock);
>  		spin_lock_bh(&ifa->lock);
> -		state = ifa->state;
> -		ifa->state = INET6_IFADDR_STATE_DEAD;
> +
> +		if (unlikely(keep_ifa)) {
> +			/* set state to skip the notifier below */
> +			state = INET6_IFADDR_STATE_DEAD;
> +			ifa->state = 0;
> +			if (!(ifa->flags & IFA_F_NODAD))
> +				ifa->flags |= IFA_F_TENTATIVE;
> +		} else {
> +			state = ifa->state;
> +			ifa->state = INET6_IFADDR_STATE_DEAD;
> +
> +			list_del(&ifa->if_list);
> +			list_add(&ifa->if_list, &del_list);
> +		}
> +
>  		spin_unlock_bh(&ifa->lock);
>  
>  		if (state != INET6_IFADDR_STATE_DEAD) {
>  			__ipv6_ifa_notify(RTM_DELADDR, ifa);
>  			inet6addr_notifier_call_chain(NETDEV_DOWN, ifa);
>  		}
> -		in6_ifa_put(ifa);
>  
>  		write_lock_bh(&idev->lock);
>  	}
>  
>  	write_unlock_bh(&idev->lock);
>  
> +	while (!list_empty(&del_list)) {
> +		ifa = list_first_entry(&del_list,
> +				       struct inet6_ifaddr, if_list);
> +		list_del(&ifa->if_list);
> +
> +		in6_ifa_put(ifa);
> +	}
> +
>  	/* Step 5: Discard anycast and multicast list */
>  	if (how) {
>  		ipv6_ac_destroy_dev(idev);
> @@ -4713,6 +4800,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
>  	array[DEVCONF_USE_OIF_ADDRS_ONLY] = cnf->use_oif_addrs_only;
>  	array[DEVCONF_DROP_UNICAST_IN_L2_MULTICAST] = cnf->drop_unicast_in_l2_multicast;
>  	array[DEVCONF_DROP_UNSOLICITED_NA] = cnf->drop_unsolicited_na;
> +	array[DEVCONF_KEEP_ADDR_ON_DOWN] = cnf->keep_addr_on_down;
>  }
>  
>  static inline size_t inet6_ifla6_size(void)
> @@ -5194,10 +5282,12 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
>  			if (rt)
>  				ip6_del_rt(rt);
>  		}
> -		dst_hold(&ifp->rt->dst);
> -
> -		ip6_del_rt(ifp->rt);
> +		if (ifp->rt) {
> +			dst_hold(&ifp->rt->dst);
>  
> +			ip6_del_rt(ifp->rt);
> +			ifp->rt = NULL;
> +		}
>  		rt_genid_bump_ipv6(net);
>  		break;
>  	}
> @@ -5801,6 +5891,14 @@ static struct addrconf_sysctl_table
>  			.proc_handler	= proc_dointvec,
>  		},
>  		{
> +			.procname       = "keep_addr_on_down",
> +			.data           = &ipv6_devconf.keep_addr_on_down,
> +			.maxlen         = sizeof(int),
> +			.mode           = 0644,
> +			.proc_handler   = proc_dointvec,
> +
> +		},
> +		{
>  			/* sentinel */
>  		}
>  	},
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
