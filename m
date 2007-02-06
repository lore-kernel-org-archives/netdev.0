From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Tue, 06 Feb 2007 10:24:05 +0900 (JST)
Message-ID: <20070206.102405.86919923.yoshfuji@linux-ipv6.org>
References: <45C3B22B.4020400@hp.com>
	<20070203150301.GA32659@hmsreliant.homelinux.net>
	<20070205205651.GB484@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53616 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965439AbXBFBWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 20:22:45 -0500
In-Reply-To: <20070205205651.GB484@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <20070205205651.GB484@hmsreliant.homelinux.net> (at Mon, 5 Feb 2007 15:56:51 -0500), Neil Horman <nhorman@tuxdriver.com> says:


>  		if (ifp == NULL && valid_lft) {
>  			int max_addresses = in6_dev->cnf.max_addresses;
> +			u32 addr_flags = 0;
> +
> +#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
> +			if (in6_dev->cnf.optimistic_dad &&
> +			    !ipv6_devconf.forwarding)
> +				addr_flags = IFA_F_OPTIMISTIC;
> +#endif
>  
>  			/* Do not allow to create too much of autoconfigured
>  			 * addresses; this would be too easy way to crash kernel.
> @@ -1742,7 +1762,8 @@ ok:
>  			if (!max_addresses ||
>  			    ipv6_count_addresses(in6_dev) < max_addresses)
>  				ifp = ipv6_add_addr(in6_dev, &addr, pinfo->prefix_len,
> -						    addr_type&IPV6_ADDR_SCOPE_MASK, 0);
> +						    addr_type&IPV6_ADDR_SCOPE_MASK,
> +						    addr_flags);
>  
>  			if (!ifp || IS_ERR(ifp)) {
>  				in6_dev_put(in6_dev);
> @@ -1945,7 +1966,11 @@ static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen,
>  		ifp->prefered_lft = prefered_lft;
>  		ifp->tstamp = jiffies;
>  		spin_unlock_bh(&ifp->lock);
> -
> +		/*
> +		 * Note that section 3.1 of RFC 4429 indicates
> +		 * That the Optimistic flag should not be set for
> +		 * manually configured addresses
> +		 */
>  		addrconf_dad_start(ifp, 0);
>  		in6_ifa_put(ifp);
>  		addrconf_verify(0);
> @@ -2122,8 +2147,16 @@ static void init_loopback(struct net_device *dev)
>  static void addrconf_add_linklocal(struct inet6_dev *idev, struct in6_addr *addr)
>  {
>  	struct inet6_ifaddr * ifp;
> +	u32 addr_flags = IFA_F_PERMANENT;
> +
> +#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
> +	if (idev->cnf.optimistic_dad &&
> +	    !ipv6_devconf.forwarding)
> +		addr_flags |= IFA_F_OPTIMISTIC;
> +#endif
> +
>  
> -	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
> +	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, addr_flags);
>  	if (!IS_ERR(ifp)) {
>  		addrconf_dad_start(ifp, 0);
>  		in6_ifa_put(ifp);
> @@ -2190,7 +2223,7 @@ ipv6_inherit_linklocal(struct inet6_dev *idev, struct net_device *link_dev)
>  {
>  	struct in6_addr lladdr;
>  
> -	if (!ipv6_get_lladdr(link_dev, &lladdr)) {
> +	if (!ipv6_get_lladdr(link_dev, &lladdr, IFA_F_TENTATIVE)) {
>  		addrconf_add_linklocal(idev, &lladdr);
>  		return 0;
>  	}
> @@ -2527,7 +2560,11 @@ static void addrconf_dad_kick(struct inet6_ifaddr *ifp)
>  	unsigned long rand_num;
>  	struct inet6_dev *idev = ifp->idev;
>  
> -	rand_num = net_random() % (idev->cnf.rtr_solicit_delay ? : 1);
> +	if (ifp->flags & IFA_F_OPTIMISTIC)
> +		rand_num = 0;
> +	else
> +		rand_num = net_random() % (idev->cnf.rtr_solicit_delay ? : 1);
> +
>  	ifp->probes = idev->cnf.dad_transmits;
>  	addrconf_mod_timer(ifp, AC_DAD, rand_num);
>  }
> @@ -2553,7 +2590,7 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
>  	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
>  	    !(ifp->flags&IFA_F_TENTATIVE) ||
>  	    ifp->flags & IFA_F_NODAD) {
> -		ifp->flags &= ~IFA_F_TENTATIVE;
> +		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
>  		spin_unlock_bh(&ifp->lock);
>  		read_unlock_bh(&idev->lock);
>  
> @@ -2573,6 +2610,14 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
>  		addrconf_dad_stop(ifp);
>  		return;
>  	}
> +
> +	/*
> +	 * Optimistic nodes need to join the anycast address
> +	 * right away
> +	 */
> +	if (ifp->flags & IFA_F_OPTIMISTIC)
> +		addrconf_join_anycast(ifp);
> +
>  	addrconf_dad_kick(ifp);
>  	spin_unlock_bh(&ifp->lock);
>  out:
> @@ -2597,7 +2642,7 @@ static void addrconf_dad_timer(unsigned long data)
>  		 * DAD was successful
>  		 */
>  
> -		ifp->flags &= ~IFA_F_TENTATIVE;
> +		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
>  		spin_unlock_bh(&ifp->lock);
>  		read_unlock_bh(&idev->lock);
>  
> @@ -2627,6 +2672,9 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
>  	 *	Configure the address for reception. Now it is valid.
>  	 */
>  
> +	if (ifp->flags & IFA_F_OPTIMISTIC)
> +		addrconf_leave_anycast(ifp);
> +
>  	ipv6_ifa_notify(RTM_NEWADDR, ifp);
>  
>  	/* If added prefix is link local and forwarding is off,
> @@ -3398,6 +3446,9 @@ static void inline ipv6_store_devconf(struct ipv6_devconf *cnf,
>  #endif
>  #endif
>  	array[DEVCONF_PROXY_NDP] = cnf->proxy_ndp;
> +#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
> +	array[DEVCONF_OPTIMISTIC_DAD] = cnf->optimistic_dad;
> +#endif
>  }
>  
>  static inline size_t inet6_if_nlmsg_size(void)
> @@ -3605,11 +3656,18 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
>  	switch (event) {
>  	case RTM_NEWADDR:
>  		ip6_ins_rt(ifp->rt);
> -		if (ifp->idev->cnf.forwarding)
> +		/*
> +		 * Note that optimistic addresses
> +		 * join anycast at the start of DAD, not here
> +		 * like non-optimistic addresses
> +		 */
> +		if ((ifp->idev->cnf.forwarding) &&
> +		    (!(ifp->flags & IFA_F_OPTIMISTIC)))
>  			addrconf_join_anycast(ifp);
>  		break;
>  	case RTM_DELADDR:
> -		if (ifp->idev->cnf.forwarding)
> +		if ((ifp->idev->cnf.forwarding) ||
> +		    (ifp->flags & IFA_F_OPTIMISTIC))
>  			addrconf_leave_anycast(ifp);
>  		addrconf_leave_solict(ifp->idev, &ifp->addr);
>  		dst_hold(&ifp->rt->u.dst);
> @@ -3917,6 +3975,17 @@ static struct addrconf_sysctl_table
>  			.mode		=	0644,
>  			.proc_handler	=	&proc_dointvec,
>  		},
> +#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
> +		{
> +			.ctl_name	=	NET_IPV6_OPTIMISTIC_DAD,
> +			.procname       =       "optimistic_dad",
> +			.data           =       &ipv6_devconf.optimistic_dad,
> +			.maxlen         =       sizeof(int),
> +			.mode           =       0644,
> +			.proc_handler   =       &proc_dointvec,
> +
> +		},
> +#endif
>  		{
>  			.ctl_name	=	0,	/* sentinel */
>  		}
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 7b7bd44..cf32b50 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -848,13 +848,43 @@ static int ip6_dst_lookup_tail(struct sock *sk,
>  			       struct dst_entry **dst, struct flowi *fl)
>  {
>  	int err;
> -
> +#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
> +	struct inet6_ifaddr *ifp;
> +	struct flowi gateway_fl;
> +#endif
>  	if (*dst == NULL)
>  		*dst = ip6_route_output(sk, fl);
>  
>  	if ((err = (*dst)->error))
>  		goto out_err_release;
>  
> +#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
> +	/*
> +	 * Here if the dst entry we've looked up 
> +	 * has a neighbour entry that is in the INCOMPLETE
> +	 * state and the src address from the flow is 
> +	 * marked as OPTIMISTIC, we release the found 
> +	 * dst entry and replace it instead with the 
> +	 * dst entry of the nexthop router
> +	 */
> +	if (((*dst)->neighbour->nud_state == NUD_INCOMPLETE) ||
> +	    ((*dst)->neighbour->nud_state == NUD_FAILED)) {
> +		ifp = ipv6_get_ifaddr(&fl->fl6_src, (*dst)->dev, 1);
> +
> +		if (ifp && ifp->flags & IFA_F_OPTIMISTIC) {
> +			/*
> +			 * We need to get the dst entry for the 
> +			 * default router instead
> +			 */
> +			dst_release(*dst);
> +			memcpy(&gateway_fl, fl, sizeof(struct flowi));
> +			memset(&gateway_fl.fl6_dst, 0, sizeof(struct in6_addr));
> +			*dst = ip6_route_output(sk, &gateway_fl);
> +			if ((err = (*dst)->error))
> +				goto out_err_release;				
> +		}
> +	}
> +#endif
>  	if (ipv6_addr_any(&fl->fl6_src)) {
>  		err = ipv6_get_saddr(*dst, &fl->fl6_dst, &fl->fl6_src);
>  		if (err)

This is not correct.
Please put that "ifdef" after source address selection
(just after the "if" statement just after this "#endif")
and check IFA_F_OPTIMISTIC of source address.

You can say,
  !((*dst)->neighbour->nud_state & NUD_VALID)
instead of 
  ((*dst)->neighbour->nud_state == NUD_INCOMPLETE) ||
  ((*dst)->neighbour->nud_state == NUD_FAILED)
.

> @@ -498,7 +500,8 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
>          msg->icmph.icmp6_unused = 0;
>          msg->icmph.icmp6_router    = router;
>          msg->icmph.icmp6_solicited = solicited;
> -        msg->icmph.icmp6_override  = override;
> +	msg->icmph.icmp6_override  = override;
> +
>  
>          /* Set the target address. */
>  	ipv6_addr_copy(&msg->target, solicited_addr);

Why do you "change" this?

> @@ -540,13 +543,16 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
:
>  			return;
>  		saddr = &addr_buf;
>  	}
>  
> +
>  	ndisc_flow_init(&fl, NDISC_NEIGHBOUR_SOLICITATION, saddr, daddr,
>  			dev->ifindex);
>  

ditto

> @@ -559,7 +565,8 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
>  		return;
>  
>  	len = sizeof(struct icmp6hdr) + sizeof(struct in6_addr);
> -	send_llinfo = dev->addr_len && !ipv6_addr_any(saddr);
> +	send_llinfo = (dev->addr_len && !ipv6_addr_any(saddr)); 
> +
>  	if (send_llinfo)
>  		len += ndisc_opt_addr_space(dev);
>  

ditto.

> @@ -622,9 +629,21 @@ void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
>          struct sk_buff *skb;
>          struct icmp6hdr *hdr;
>  	__u8 * opt;
> +	struct inet6_ifaddr *ifp;
> +	int include_sllao_option = 1;

int send_sllao = 1;

>          int len;
>  	int err;
>  
> +	/*
> +	 * Check the source address.  If its OPTIMISTIC
> +	 * and addr_len is non-zero (implying the sllao option)
> +	 * then don't send the RS (RFC 4429, section 2.2)
> +	 */
> +	ifp = ipv6_get_ifaddr(saddr, dev, 1);
> +
> +	if ((!ifp) || ((ifp->flags & IFA_F_OPTIMISTIC) && dev->addr_len))
> +		include_sllao_option=0;
> +
>  	ndisc_flow_init(&fl, NDISC_ROUTER_SOLICITATION, saddr, daddr,
>  			dev->ifindex);
>  

if (!dev->addr_len || !ifp || ifp->IFA_F_OPTIMISTIC)
        send_sllao = 0;

> @@ -664,7 +683,7 @@ void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
>  
>  	opt = (u8*) (hdr + 1);
>  
> -	if (dev->addr_len)
> +	if (dev->addr_len && include_sllao_option)
>  		ndisc_fill_addr_option(opt, ND_OPT_SOURCE_LL_ADDR, dev->dev_addr,
>  				       dev->addr_len, dev->type);
>  

if (send_sllao)
	ndisc_fill_addr_option(...)

Please adjust allocation space as well.

--yoshfuji
