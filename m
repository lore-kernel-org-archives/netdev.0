From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Fri, 26 Jan 2007 09:13:31 +0900 (JST)
Message-ID: <20070126.091331.22638713.yoshfuji@linux-ipv6.org>
References: <20070125133340.GA8891@hmsreliant.homelinux.net>
	<45B8E60B.7080809@hp.com>
	<20070125194500.GB8891@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:46657 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030504AbXAZAMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 19:12:19 -0500
In-Reply-To: <20070125194500.GB8891@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070125194500.GB8891@hmsreliant.homelinux.net> (at Thu, 25 Jan 2007 14:45:00 -0500), Neil Horman <nhorman@tuxdriver.com> says:

> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 2a7e461..46f91ee 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -830,7 +830,8 @@ retry:
>  	ift = !max_addresses ||
>  	      ipv6_count_addresses(idev) < max_addresses ? 
>  		ipv6_add_addr(idev, &addr, tmp_plen,
> -			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, IFA_F_TEMPORARY) : NULL;
> +			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, 
> +			      IFA_F_TEMPORARY|IFA_F_OPTIMISTIC) : NULL;
>  	if (!ift || IS_ERR(ift)) {
>  		in6_ifa_put(ifp);
>  		in6_dev_put(idev);

If optimistic_dad is disabled, flags should be IFA_F_TEMPORARY,
not IFA_F_TEMPORARY|IFA_F_OPTIMISTIC.

Another idea is to use IFA_F_OPTIMISTIC not
IFA_F_OPTIMISTIC|IFA_F_TENTATIVE until the DAD has been finished.

> @@ -1027,15 +1029,17 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
:
> +			/* Rule 3: Avoid deprecated and optimistic address */
>  			if (hiscore.rule < 3) {
>  				if (ipv6_saddr_preferred(hiscore.addr_type) ||
> -				    !(ifa_result->flags & IFA_F_DEPRECATED))
> +				    ((!(ifa_result->flags & IFA_F_DEPRECATED)) && 
> +				    (!(ifa_result->flags & IFA_F_OPTIMISTIC))))
>  					hiscore.attrs |= IPV6_SADDR_SCORE_PREFERRED;
>  				hiscore.rule++;

                                    ((ifa_result->flags & (IFA_F_DEPRECATED|IFA_F_OPTIMISTIC)) == 0)

>  			}
>  			if (ipv6_saddr_preferred(score.addr_type) ||
> -			    !(ifa->flags & IFA_F_DEPRECATED)) {
> +			    ((!(ifa->flags & IFA_F_DEPRECATED)) &&
> +			    (!(ifa_result->flags & IFA_F_OPTIMISTIC)))) {
>  				score.attrs |= IPV6_SADDR_SCORE_PREFERRED;
>  				if (!(hiscore.attrs & IPV6_SADDR_SCORE_PREFERRED)) {
>  					score.rule = 3;

ditto.

> @@ -2123,7 +2133,8 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, struct in6_addr *addr
>  {
>  	struct inet6_ifaddr * ifp;
>  
> -	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
> +	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, 
> +		            IFA_F_PERMANENT|IFA_F_OPTIMISTIC);
>  	if (!IS_ERR(ifp)) {
>  		addrconf_dad_start(ifp, 0);
>  		in6_ifa_put(ifp);

Please do not always put IFA_F_OPTIMISTIC.

>  
> +	/*
> +	 * Optimistic nodes need to joing the anycast address
> +	 * right away
> +	 */
> +	if (ifp->flags & IFA_F_OPTIMISTIC)
> +		addrconf_join_anycast(ifp);
> +
>  	if (ifp->prefix_len != 128 && (ifp->flags&IFA_F_PERMANENT))
>  		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev, 0,
>  					flags);

Should we join anycast even if the node is a host (not a router)?!

When you add a call to "addrconf_join_anycast()", 
you must consider when to leave this.


> @@ -2573,6 +2594,18 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
>  		addrconf_dad_stop(ifp);
>  		return;
>  	}
> +
> +	/*
> +	 * Forwarding devices (routers) should not use
> +	 * optimistic addresses
> +	 * Nor should interfaces that don't know the 
> +	 * Source address for their default gateway
> +	 * RFC 4429 Sec 3.3
> +	 */
> +	if ((ipv6_devconf.forwarding) ||
> +	   (ifp->rt == NULL))
> +		ifp->flags &= ~IFA_F_OPTIMISTIC;
> +
>  	addrconf_dad_kick(ifp);
>  	spin_unlock_bh(&ifp->lock);
>  out:

Please test this condition when you are adding the
address.

BTW, you have not implemented the later condition,
right?   Sefault gatewa is not tested.

> index 6a9f616..fcd22e3 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -498,7 +498,21 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
>          msg->icmph.icmp6_unused = 0;
>          msg->icmph.icmp6_router    = router;
>          msg->icmph.icmp6_solicited = solicited;
> -        msg->icmph.icmp6_override  = override;
> +	if (!ifp || !(ifp->flags & IFA_F_OPTIMISTIC))
> +		msg->icmph.icmp6_override  = override;
> +	else {
> +		/*
> +		 * We must clear the override flag on all
> +		 * neighbor advertisements from source 
> +		 * addresses that are OPTIMISTIC - RFC 4429
> +		 * section 2.2
> +		 */
> +		if (override)
> +			printk(KERN_WARNING
> +				"Disallowing override flag for OPTIMISTIC addr\n");
> +		msg->icmph.icmp6_override = 0;
> +	}
> +

Ifp is already put.  Please clear "override" in the code
where we try getting temporary source address for NS.

> @@ -622,9 +637,20 @@ void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
> +	/*
> +	 * Check the source address.  If its OPTIMISTIC
> +	 * and addr_len is non-zero (implying the sllao option)
> +	 * then don't send the RS (RFC 4429, section 2.2)
> +	 */
> +	ifp = ipv6_get_ifaddr(saddr, dev, 1);
> +
> +	if ((!ifp) || ((ifp->flags & IFA_F_OPTIMISTIC) && dev->addr_len))
> +		return;
> +
>  	ndisc_flow_init(&fl, NDISC_ROUTER_SOLICITATION, saddr, daddr,
>  			dev->ifindex);
>  

I disagree. Please send RS in other way.
Choose another address, or send it without SLLAO.

--yoshfuji
