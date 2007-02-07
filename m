From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Thu, 08 Feb 2007 06:52:06 +0900 (JST)
Message-ID: <20070208.065206.107341055.yoshfuji@linux-ipv6.org>
References: <20070206200915.GC10707@hmsreliant.homelinux.net>
	<45C8EF75.6070506@hp.com>
	<20070207205503.GB20804@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54160 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161436AbXBGVum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 16:50:42 -0500
In-Reply-To: <20070207205503.GB20804@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070207205503.GB20804@hmsreliant.homelinux.net> (at Wed, 7 Feb 2007 15:55:03 -0500), Neil Horman <nhorman@tuxdriver.com> says:

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
>  	}
>  
>  	return 0;

Sorry, this is still not correct if the source address is already
specified.  I think they should be placed just betwee laste "}" and
"return 0;", no?


I still have a question.  Now, who will install the kernel route for
the incoming packet?  Can we get packet for our unicast address during
optimistic DAD period?

--yoshfuji
