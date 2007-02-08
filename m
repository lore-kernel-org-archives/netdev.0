From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Fri, 09 Feb 2007 02:10:37 +0900 (JST)
Message-ID: <20070209.021037.04063577.yoshfuji@linux-ipv6.org>
References: <20070207205503.GB20804@hmsreliant.homelinux.net>
	<20070208.072620.63000777.yoshfuji@linux-ipv6.org>
	<20070208164151.GB27267@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54219 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965723AbXBHRJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 12:09:15 -0500
In-Reply-To: <20070208164151.GB27267@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070208164151.GB27267@hmsreliant.homelinux.net> (at Thu, 8 Feb 2007 11:41:52 -0500), Neil Horman <nhorman@tuxdriver.com> says:

> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 7b7bd44..07a5f4d 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -859,6 +859,40 @@ static int ip6_dst_lookup_tail(struct sock *sk,
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
> +			int redirect;
> +
> +			ifp = ipv6_get_ifaddr(&fl->fl6_src, (*dst)->dev, 1);
> +
> +			redirect = (ifp && ifp->flags & IFA_F_OPTIMISTIC);
> +			if (ifp)
> +				in6_ifa_put(ifp);
> +
> +			if (redirect) {
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

These should be placed

>  	}

here. No?


> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 39bb658..9656018 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
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
>  	ndisc_flow_init(&fl, NDISC_ROUTER_SOLICITATION, saddr, daddr,
>  			dev->ifindex);
>  

Still leaking ifp.  Something like this?

int send_sllao = dev->addr_len;

#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
if (send_sllao) {
  struct inet6_ifaddr *ifp = ipv6_get_ifaddr(saddr, dev, 1);
  if (ifp) {
     if (ifp->flags & IFA_F_OPTIMISTIC)
       send_sllao = 0;
     in6_ifa_put(ifp);
  } else
     send_sllao = 0;
}
#endif

--yoshfuji
