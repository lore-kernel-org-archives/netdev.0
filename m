From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH net-next 10/10] ipv6: Create percpu rt6_info
Date: Mon, 13 Apr 2015 12:59:44 +0200
Message-ID: <20150413105944.GE8928@secunet.com>
References: <1428717576-1040383-1-git-send-email-kafai@fb.com>
 <1428717576-1040383-11-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56915 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753666AbbDMK7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 06:59:52 -0400
Content-Disposition: inline
In-Reply-To: <1428717576-1040383-11-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 10, 2015 at 06:59:36PM -0700, Martin KaFai Lau wrote:

> diff --git a/include/uapi/linux/ipv6_route.h b/include/uapi/linux/ipv6_route.h
> index 2be7bd1..f6598d1 100644
> --- a/include/uapi/linux/ipv6_route.h
> +++ b/include/uapi/linux/ipv6_route.h
> @@ -34,6 +34,7 @@
>  #define RTF_PREF(pref)	((pref) << 27)
>  #define RTF_PREF_MASK	0x18000000
>  
> +#define RTF_PCPU	0x40000000

This percpu flag is something internal, should IMO not be added
to the uapi.

> @@ -1978,8 +2100,13 @@ static void ip6_rt_copy_init(struct rt6_info *rt,
>  static struct rt6_info *ip6_rt_cache_alloc(struct rt6_info *ort,
>  					   const struct in6_addr *dest)
>  {
> -	struct rt6_info *rt = ip6_dst_alloc(dev_net(ort->dst.dev), ort->dst.dev,
> -					    0, ort->rt6i_table);
> +	struct rt6_info *rt;
> +
> +	if (ort->rt6i_flags & RTF_PCPU)
> +		ort = (struct rt6_info *)ort->dst.from;
> +
> +	rt = __ip6_dst_alloc(dev_net(ort->dst.dev), ort->dst.dev,
> +			     0, ort->rt6i_table);

Why don't you allocate the percpu resources for cached routes?
I think using ip6_dst_alloc() would be better here, cached routes
could benefit from this too. And in particular rt6_release() tries
to free the percpu resources unconditionally when the route is removed
from the fib tree. This crashes if the percpu resources are not allocated.

The rest of the patchset looks good.

Thanks!
