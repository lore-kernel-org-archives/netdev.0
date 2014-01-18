From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] ipcomp: Convert struct xt_ipcomp spis into
 16bits
Date: Sat, 18 Jan 2014 13:24:37 +0100
Message-ID: <20140118122437.GA4309@localhost>
References: <1390011374-21760-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33869 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752017AbaARMYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Jan 2014 07:24:53 -0500
Content-Disposition: inline
In-Reply-To: <1390011374-21760-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 18, 2014 at 10:16:14AM +0800, Fan Du wrote:
> sparse warnings: (new ones prefixed by >>)
> 
> >> >> net/netfilter/xt_ipcomp.c:63:26: sparse: restricted __be16 degrades to integer
> >> >> net/netfilter/xt_ipcomp.c:63:26: sparse: cast to restricted __be32
> 
> Fix this by using 16bits long spi, as IPcomp CPI is only valid for 16bits.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>  include/uapi/linux/netfilter/xt_ipcomp.h |    2 +-
>  net/netfilter/xt_ipcomp.c                |    4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/uapi/linux/netfilter/xt_ipcomp.h b/include/uapi/linux/netfilter/xt_ipcomp.h
> index 45c7e40..ca82ebb 100644
> --- a/include/uapi/linux/netfilter/xt_ipcomp.h
> +++ b/include/uapi/linux/netfilter/xt_ipcomp.h
> @@ -4,7 +4,7 @@
>  #include <linux/types.h>
>  
>  struct xt_ipcomp {
> -	__u32 spis[2];	/* Security Parameter Index */
> +	__u16 spis[2];	/* Security Parameter Index */

This changes the binary interface so it break userspace (iptables
needs to be recompiled), we're still in time to make such change as
this is net-next stuff, but what I understand from the patch
description is that this aims to fix a sparse warning, which is a bit
of intrusive change.

Didn't you find any way to fix this without change the layout of
xt_ipcomp?

>  	__u8 invflags;	/* Inverse flags */
>  	__u8 hdrres;	/* Test of the Reserved Filed */
>  };
> diff --git a/net/netfilter/xt_ipcomp.c b/net/netfilter/xt_ipcomp.c
> index a4c7561..5542cb2 100644
> --- a/net/netfilter/xt_ipcomp.c
> +++ b/net/netfilter/xt_ipcomp.c
> @@ -29,7 +29,7 @@ MODULE_DESCRIPTION("Xtables: IPv4/6 IPsec-IPComp SPI match");
>  
>  /* Returns 1 if the spi is matched by the range, 0 otherwise */
>  static inline bool
> -spi_match(u_int32_t min, u_int32_t max, u_int32_t spi, bool invert)
> +spi_match(u_int16_t min, u_int16_t max, u_int16_t spi, bool invert)
>  {
>  	bool r;
>  	pr_debug("spi_match:%c 0x%x <= 0x%x <= 0x%x\n",
> @@ -60,7 +60,7 @@ static bool comp_mt(const struct sk_buff *skb, struct xt_action_param *par)
>  	}
>  
>  	return spi_match(compinfo->spis[0], compinfo->spis[1],
> -			 ntohl(chdr->cpi << 16),
> +			 ntohl(chdr->cpi),
>  			 !!(compinfo->invflags & XT_IPCOMP_INV_SPI));
>  }
>  
> -- 
> 1.7.9.5
> 
