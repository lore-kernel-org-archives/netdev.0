From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Sat, 20 Jan 2007 08:05:07 +0900 (JST)
Message-ID: <20070120.080507.25118874.yoshfuji@linux-ipv6.org>
References: <20070119212314.GA10748@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, kaber@coreworks.de, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:46372 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932825AbXASXED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jan 2007 18:04:03 -0500
To: nhorman@tuxdriver.com
In-Reply-To: <20070119212314.GA10748@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <20070119212314.GA10748@hmsreliant.homelinux.net> (at Fri, 19 Jan 2007 16:23:14 -0500), Neil Horman <nhorman@tuxdriver.com> says:

> Patch to Implement IPv6 RFC 4429 (Optimistic Duplicate Address Detection).  In

Good work.  We will see if this would break core and basic ipv6 code.
Dave, please hold on.

Some quick comments.

> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -110,6 +110,7 @@ struct frag_hdr {
>  /* sysctls */
>  extern int sysctl_ipv6_bindv6only;
>  extern int sysctl_mld_max_msf;
> +extern int sysctl_optimistic_dad;
>  
:
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 2a7e461..f7afb2a 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -206,6 +206,8 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
>  	.proxy_ndp		= 0,
>  };
>  
> +int sysctl_optimistic_dad = 1;
> +

Please put this into ipv6_devconf{} and make it per-interface variable.
And I think default should be kept off (0).

>  /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
>  #if 0
>  const struct in6_addr in6addr_any = IN6ADDR_ANY_INIT;
> @@ -830,7 +832,8 @@ retry:
>  	ift = !max_addresses ||
>  	      ipv6_count_addresses(idev) < max_addresses ? 
>  		ipv6_add_addr(idev, &addr, tmp_plen,
> -			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, IFA_F_TEMPORARY) : NULL;
> +			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, 
> +				IFA_F_TEMPORARY|IFA_F_OPTIMISTIC) : NULL;
>  	if (!ift || IS_ERR(ift)) {
>  		in6_ifa_put(ifp);
>  		in6_dev_put(idev);

Please align ipv6_addr_type and IFA_F_TEMPORARY

> @@ -1174,7 +1177,8 @@ int ipv6_get_saddr(struct dst_entry *dst,
>  }
>  
>  
> -int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr)
> +int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr, 
> +			unsigned char banned_flags)
>  {
>  	struct inet6_dev *idev;
>  	int err = -EADDRNOTAVAIL;

Please align "struct net_device" and "unsigned char".

> @@ -1185,7 +1189,7 @@ int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr)
>  
>  		read_lock_bh(&idev->lock);
>  		for (ifp=idev->addr_list; ifp; ifp=ifp->if_next) {
> -			if (ifp->scope == IFA_LINK && !(ifp->flags&IFA_F_TENTATIVE)) {
> +			if (ifp->scope == IFA_LINK && !(ifp->flags&banned_flags)) {
>  				ipv6_addr_copy(addr, &ifp->addr);
>  				err = 0;
>  				break;
> @@ -1742,7 +1746,7 @@ ok:

It is not your fault, but please put a space around "&".

>  			if (!max_addresses ||
>  			    ipv6_count_addresses(in6_dev) < max_addresses)
>  				ifp = ipv6_add_addr(in6_dev, &addr, pinfo->prefix_len,
> -						    addr_type&IPV6_ADDR_SCOPE_MASK, 0);
> +						    addr_type&IPV6_ADDR_SCOPE_MASK,0);
>  
>  			if (!ifp || IS_ERR(ifp)) {
>  				in6_dev_put(in6_dev);

Please do no kill space after ",".

> @@ -2123,7 +2132,8 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, struct in6_addr *addr
>  {
>  	struct inet6_ifaddr * ifp;
>  
> -	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
> +	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, 
> +		IFA_F_PERMANENT|IFA_F_OPTIMISTIC);
>  	if (!IS_ERR(ifp)) {
>  		addrconf_dad_start(ifp, 0);
>  		in6_ifa_put(ifp);

Please align idev and IFA_F_PERMANENT.

> @@ -542,7 +556,8 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
>  	int send_llinfo;
>  
>  	if (saddr == NULL) {
> -		if (ipv6_get_lladdr(dev, &addr_buf))
> +		if (ipv6_get_lladdr(dev, &addr_buf,
> +			(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)))
>  			return;
>  		saddr = &addr_buf;
>  	}

ditto... ("dev" and "(")

> +			   and optimistic) are false then we can just fail
> +			   dad now.
> +			*/
> +			type = ipv6_addr_type(saddr);			
> +			if (!((ifp->flags & IFA_F_OPTIMISTIC) && 
> +			    (type & IPV6_ADDR_UNICAST))) {
> +				addrconf_dad_failure(ifp); 
> +				return;
> +			}
>  		}
>  
>  		idev = ifp->idev;

hmm? Here, is saddr always unicast, isn't it?!

--yoshfuji
