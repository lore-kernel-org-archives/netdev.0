From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Tue, 06 Feb 2007 16:13:25 -0500
Message-ID: <45C8EF75.6070506@hp.com>
References: <45C3B22B.4020400@hp.com> <20070203150301.GA32659@hmsreliant.homelinux.net> <20070205205651.GB484@hmsreliant.homelinux.net> <20070206.102405.86919923.yoshfuji@linux-ipv6.org> <20070206125144.GB10707@hmsreliant.homelinux.net> <20070206200915.GC10707@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:58645 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030194AbXBFW3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 17:29:51 -0500
In-Reply-To: <20070206200915.GC10707@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Neil

a few comments.  sorry, just can't resist... :)


> @@ -2627,6 +2673,9 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
>  	 *	Configure the address for reception. Now it is valid.
>  	 */
>  
> +	if (ifp->flags & IFA_F_OPTIMISTIC)
> +		addrconf_leave_anycast(ifp);
> +
>  	ipv6_ifa_notify(RTM_NEWADDR, ifp);

Since we are no longer doing anycast, remove the above.

> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 7b7bd44..b8a5261 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -857,6 +857,34 @@ static int ip6_dst_lookup_tail(struct sock *sk,
>  
>  	if (ipv6_addr_any(&fl->fl6_src)) {
>  		err = ipv6_get_saddr(*dst, &fl->fl6_dst, &fl->fl6_src);
> +#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
> +		/*
> +		 * Here if the dst entry we've looked up 
> +		 * has a neighbour entry that is in the INCOMPLETE
> +		 * state and the src address from the flow is 
> +		 * marked as OPTIMISTIC, we release the found 
> +		 * dst entry and replace it instead with the 
> +		 * dst entry of the nexthop router
> +		 */
> +		if (!((*dst)->neighbour->nud_state & NUD_VALID)) {
> +			struct inet6_ifaddr *ifp;
> +			struct flowi fl_gw;
> +			ifp = ipv6_get_ifaddr(&fl->fl6_src, (*dst)->dev, 1);
> +
> +			if (ifp && ifp->flags & IFA_F_OPTIMISTIC) {
> +				/*
> +				 * We need to get the dst entry for the 
> +				 * default router instead
> +				 */
> +				dst_release(*dst);
> +				memcpy(&fl_gw, fl, sizeof(struct flowi));
> +				memset(&fl_gw.fl6_dst, 0, sizeof(struct in6_addr));
> +				*dst = ip6_route_output(sk, &fl_gw);
> +				if ((err = (*dst)->error))
> +					goto out_err_release;				
> +			}
> +		}
> +#endif
>  		if (err)
>  			goto out_err_release;

This actually doesn't look right....  What if ipv6_get_saddr returned an error?
I think the new code should go after the 'goto out_err_release;'...
That way, we do optimistic checks if we have a valid source address.

>  	}
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 882cde4..9c5273c 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -1411,7 +1411,7 @@ static struct sk_buff *mld_newpack(struct net_device *dev, int size)
>  
>  	skb_reserve(skb, LL_RESERVED_SPACE(dev));
>  
> -	if (ipv6_get_lladdr(dev, &addr_buf)) {
> +	if (ipv6_get_lladdr(dev, &addr_buf, IFA_F_TENTATIVE)) {
>  		/* <draft-ietf-magma-mld-source-05.txt>:
>  		 * use unspecified address as the source address 
>  		 * when a valid link-local address is not available.
> @@ -1789,7 +1789,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
>  
>  	skb_reserve(skb, LL_RESERVED_SPACE(dev));
>  
> -	if (ipv6_get_lladdr(dev, &addr_buf)) {
> +	if (ipv6_get_lladdr(dev, &addr_buf, IFA_F_TENTATIVE)) {
>  		/* <draft-ietf-magma-mld-source-05.txt>:
>  		 * use unspecified address as the source address 
>  		 * when a valid link-local address is not available.
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 39bb658..7400805 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -447,6 +447,8 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
>  	ifp = ipv6_get_ifaddr(solicited_addr, dev, 1);
>   	if (ifp) {
>  		src_addr = solicited_addr;
> +		if (ifp->flags & IFA_F_OPTIMISTIC)
> +			override = 0;
>  		in6_ifa_put(ifp);
>  	} else {
>  		if (ipv6_dev_get_saddr(dev, daddr, &tmpaddr))
> @@ -500,6 +502,7 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
>          msg->icmph.icmp6_solicited = solicited;
>          msg->icmph.icmp6_override  = override;
>  
> +

Empty line...

>          /* Set the target address. */
>  	ipv6_addr_copy(&msg->target, solicited_addr);
>  
> @@ -542,7 +545,8 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
>  	int send_llinfo;
>  
>  	if (saddr == NULL) {
> -		if (ipv6_get_lladdr(dev, &addr_buf))
> +		if (ipv6_get_lladdr(dev, &addr_buf, 
> +				   (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)))
>  			return;
>  		saddr = &addr_buf;
>  	}
> @@ -559,7 +563,7 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
>  		return;
>  
>  	len = sizeof(struct icmp6hdr) + sizeof(struct in6_addr);
> -	send_llinfo = dev->addr_len && !ipv6_addr_any(saddr);
> +	send_llinfo = dev->addr_len && !ipv6_addr_any(saddr); 

space to tab conversion???

>  	if (send_llinfo)
>  		len += ndisc_opt_addr_space(dev);
>  
> @@ -622,9 +626,29 @@ void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
>          struct sk_buff *skb;
>          struct icmp6hdr *hdr;
>  	__u8 * opt;
> +	struct inet6_ifaddr *ifp;
> +	int send_sllao = 1;
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
> +	/*
> +	 * According to section 2.2 of RFC 4429, we must not 
> +	 * send router solicitations with a sllao from 
> +	 * optimistic addresses, but we may send the solicitation
> +	 * if we don't include the sallo.  So here we check
> +	 * if our address is optimistic, and if so, we
> +	 * supress the inclusion of the sllao.
> +	 */ 
> +	if (!dev->addr_len || !ifp || (ifp->flags & IFA_F_OPTIMISTIC))
> +		send_sllao=0;
> +
>  	ndisc_flow_init(&fl, NDISC_ROUTER_SOLICITATION, saddr, daddr,
>  			dev->ifindex);
>  
> @@ -637,7 +661,7 @@ void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
>  		return;
>  
>  	len = sizeof(struct icmp6hdr);
> -	if (dev->addr_len)
> +	if (dev->addr_len && send_sllao)
>  		len += ndisc_opt_addr_space(dev);
>  
>          skb = sock_alloc_send_skb(sk,
> @@ -664,7 +688,7 @@ void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
>  
>  	opt = (u8*) (hdr + 1);
>  
> -	if (dev->addr_len)
> +	if (dev->addr_len && send_sllao)
>  		ndisc_fill_addr_option(opt, ND_OPT_SOURCE_LL_ADDR, dev->dev_addr,
>  				       dev->addr_len, dev->type);
>  
> @@ -746,6 +770,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  	int dad = ipv6_addr_any(saddr);
>  	int inc;
>  	int is_router;
> +	int type;

'type' is unused.

>  
>  	if (ipv6_addr_is_multicast(&msg->target)) {
>  		ND_PRINTK2(KERN_WARNING 
> @@ -796,28 +821,39 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  	inc = ipv6_addr_is_multicast(daddr);
>  
>  	if ((ifp = ipv6_get_ifaddr(&msg->target, dev, 1)) != NULL) {
> -		if (ifp->flags & IFA_F_TENTATIVE) {
> -			/* Address is tentative. If the source
> -			   is unspecified address, it is someone
> -			   does DAD, otherwise we ignore solicitations
> -			   until DAD timer expires.
> -			 */
> -			if (!dad)
> +
> +		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
> +			if (dad) {
> +				if (dev->type == ARPHRD_IEEE802_TR) {
> +					unsigned char *sadr = skb->mac.raw;
> +					if (((sadr[8] ^ dev->dev_addr[0]) & 0x7f) == 0 &&
> +					    sadr[9] == dev->dev_addr[1] &&
> +					    sadr[10] == dev->dev_addr[2] &&
> +					    sadr[11] == dev->dev_addr[3] &&
> +					    sadr[12] == dev->dev_addr[4] &&
> +					    sadr[13] == dev->dev_addr[5]) {
> +						/* looped-back to us */
> +						goto out;
> +					}
> +				}
> +
> +				/*
> +				 * We are colliding with another node
> +				 * who is doing DAD
> +				 * so fail our DAD process
> +				 */
> +				addrconf_dad_failure(ifp);
>  				goto out;
> -			if (dev->type == ARPHRD_IEEE802_TR) {
> -				unsigned char *sadr = skb->mac.raw;
> -				if (((sadr[8] ^ dev->dev_addr[0]) & 0x7f) == 0 &&
> -				    sadr[9] == dev->dev_addr[1] &&
> -				    sadr[10] == dev->dev_addr[2] &&
> -				    sadr[11] == dev->dev_addr[3] &&
> -				    sadr[12] == dev->dev_addr[4] &&
> -				    sadr[13] == dev->dev_addr[5]) {
> -					/* looped-back to us */
> +			} else {
> +				/*
> +				 * This is not a dad solicitation.
> +				 * If we are an optimistic node, 
> +				 * we should respond.  
> +				 * Otherwise, we should ignore it. 
> +				 */
> +				if (!(ifp->flags & IFA_F_OPTIMISTIC))
>  					goto out;
> -				}
>  			}
> -			addrconf_dad_failure(ifp); 
> -			return;
>  		}
>  
>  		idev = ifp->idev;
> @@ -1406,7 +1442,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
>  
>  	dev = skb->dev;
>  
> -	if (ipv6_get_lladdr(dev, &saddr_buf)) {
> +	if (ipv6_get_lladdr(dev, &saddr_buf, IFA_F_TENTATIVE)) {
>  		ND_PRINTK2(KERN_WARNING
>  			   "ICMPv6 Redirect: no link-local address on %s\n",
>  			   dev->name);
> 

Regards
-vlad
