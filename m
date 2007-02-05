From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Mon, 5 Feb 2007 13:37:38 -0500
Message-ID: <20070205183738.GA484@hmsreliant.homelinux.net>
References: <20070130.072536.129403235.yoshfuji@linux-ipv6.org> <20070130130208.GA3723@hmsreliant.homelinux.net> <20070131.011629.84005028.yoshfuji@linux-ipv6.org> <20070131205443.GA12237@hmsreliant.homelinux.net> <20070202190634.GA29001@hmsreliant.homelinux.net> <45C3ACE1.8010800@hp.com> <45C3B59A.6010802@hp.com> <45C3CFF1.3040600@hp.com> <20070203150536.GB32659@hmsreliant.homelinux.net> <45C76A83.5070608@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org>,
	sri@us.ibm.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, kaber@coreworks.de,
	netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2690 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933327AbXBESpr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 13:45:47 -0500
Content-Disposition: inline
In-Reply-To: <45C76A83.5070608@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 05, 2007 at 12:33:55PM -0500, Brian Haley wrote:
> >Please, if you think you can find a way for us to do optimistic dad flags 
> >as
> >opt-in, rather than masked out, I'm all for it.  Thanks!
> 
> This patch should apply on-top of yours, if you want I can send the 
> whole thing out too.  I've only compile-tested it, so don't know if it 
> behaves the same as your original.
> 
> -Brian
> 
Thank you brian, I'll look over and incorporate this into my new tree as I'm
fixing up the anycast hole Vlad brought up

Thanks & Regards
Neil

> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index c341371..ddac8b0 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -593,13 +593,8 @@ ipv6_add_addr(struct inet6_dev *idev, co
>  	ifa->cstamp = ifa->tstamp = jiffies;
>  
>  	ifa->rt = rt;
> -#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
> -	if (!idev->cnf.optimistic_dad || ipv6_devconf.forwarding ||
> -	   (ifa->rt->rt6i_nexthop == NULL))
> +	if (rt->rt6i_nexthop == NULL)
>  		ifa->flags &= ~IFA_F_OPTIMISTIC;
> -#else
> -	ifa->flags &= ~IFA_F_OPTIMISTIC;
> -#endif
>  	ifa->idev = idev;
>  	in6_dev_hold(idev);
>  	/* For caller */
> @@ -776,6 +771,7 @@ static int ipv6_create_tempaddr(struct i
>  	int tmp_plen;
>  	int ret = 0;
>  	int max_addresses;
> +	u32 addr_flags;
>  
>  	write_lock(&idev->lock);
>  	if (ift) {
> @@ -833,11 +829,17 @@ retry:
>  	spin_unlock_bh(&ifp->lock);
>  
>  	write_unlock(&idev->lock);
> +
> +	addr_flags = IFA_F_TEMPORARY;
> +	/* set in addrconf_prefix_rcv() */
> +	if (ifp->flags & IFA_F_OPTIMISTIC)
> +		addr_flags |= IFA_F_OPTIMISTIC;
> +
>  	ift = !max_addresses ||
>  	      ipv6_count_addresses(idev) < max_addresses ? 
>  		ipv6_add_addr(idev, &addr, tmp_plen,
>  			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, 
> -			      IFA_F_TEMPORARY|IFA_F_OPTIMISTIC) : NULL;
> +			      addr_flags) : NULL;
>  	if (!ift || IS_ERR(ift)) {
>  		in6_ifa_put(ifp);
>  		in6_dev_put(idev);
> @@ -1746,6 +1748,13 @@ ok:
>  
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
> @@ -1753,7 +1762,8 @@ ok:
>  			if (!max_addresses ||
>  			    ipv6_count_addresses(in6_dev) < max_addresses)
>  				ifp = ipv6_add_addr(in6_dev, &addr, pinfo->prefix_len,
> -						    addr_type&IPV6_ADDR_SCOPE_MASK, 0);
> +						    addr_type&IPV6_ADDR_SCOPE_MASK,
> +						    addr_flags);
>  
>  			if (!ifp || IS_ERR(ifp)) {
>  				in6_dev_put(in6_dev);
> @@ -1762,10 +1772,6 @@ ok:
>  
>  			update_lft = create = 1;
>  			ifp->cstamp = jiffies;
> -#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
> -			if (ifp->idev->cnf.optimistic_dad)
> -				ifp->flags |= IFA_F_OPTIMISTIC;
> -#endif
>  			addrconf_dad_start(ifp, RTF_ADDRCONF|RTF_PREFIX_RT);
>  		}
>  
> @@ -2141,9 +2147,16 @@ static void init_loopback(struct net_dev
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
> -	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, 
> -		            IFA_F_PERMANENT|IFA_F_OPTIMISTIC);
> +	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, addr_flags);
>  	if (!IS_ERR(ifp)) {
>  		addrconf_dad_start(ifp, 0);
>  		in6_ifa_put(ifp);

