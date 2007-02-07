From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Wed, 07 Feb 2007 16:19:47 -0500
Message-ID: <45CA4273.9000802@hp.com>
References: <45C3B22B.4020400@hp.com> <20070203150301.GA32659@hmsreliant.homelinux.net> <20070205205651.GB484@hmsreliant.homelinux.net> <20070206.102405.86919923.yoshfuji@linux-ipv6.org> <20070206125144.GB10707@hmsreliant.homelinux.net> <20070206200915.GC10707@hmsreliant.homelinux.net> <45C8EF75.6070506@hp.com> <20070207205503.GB20804@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:46029 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422783AbXBGVTw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 16:19:52 -0500
In-Reply-To: <20070207205503.GB20804@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Darn... and it was looking so good...


> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 7b7bd44..8a1ea96 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -859,6 +859,34 @@ static int ip6_dst_lookup_tail(struct sock *sk,
>  		err = ipv6_get_saddr(*dst, &fl->fl6_dst, &fl->fl6_src);
>  		if (err)
>  			goto out_err_release;
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

You are leaking an 'ifp' ref.  ipv6_get_ifaddr() does in6_ifa_hold(ifp).  You
need do in6_ifa_put(ifp), when you are done with the ifp.



> @@ -622,9 +625,29 @@ void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
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
> +	 * if we don't include the sllao.  So here we check
> +	 * if our address is optimistic, and if so, we
> +	 * supress the inclusion of the sllao.
> +	 */ 
> +	if (!dev->addr_len || !ifp || (ifp->flags & IFA_F_OPTIMISTIC))
> +		send_sllao=0;
> +

Ditto.


-vlad
