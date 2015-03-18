From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net] ipv6: skip __ipv6_select_ident when there is no skb_dst
Date: Wed, 18 Mar 2015 10:04:10 -0400
Message-ID: <550985DA.3070703@redhat.com>
References: <1426686735-6129-1-git-send-email-sd@queasysnail.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matt@mattgrant.net.nz
To: Sabrina Dubroca <sd@queasysnail.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51839 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756385AbbCROEM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2015 10:04:12 -0400
In-Reply-To: <1426686735-6129-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/18/2015 09:52 AM, Sabrina Dubroca wrote:
> Matt Grant reported frequent crashes in ipv6_select_ident when
> udp6_ufo_fragment is called from openvswitch on a skb that doesn't
> have a dst_entry set.
> 
> Skip __ipv6_select_ident in case of a NULL rt.
> 
> Fixes: 0508c07f5e0c ("ipv6: Select fragment id during UFO segmentation if not set.")
> Cc: Vladislav Yasevich <vyasevic@redhat.com>
> Reported-by: Matt Grant <matt@mattgrant.net.nz>
> Tested-by: Matt Grant <matt@mattgrant.net.nz>
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---
> David, can you queue it for stable (3.19)?
> 
>  net/ipv6/output_core.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
> index 74581f706c4d..52b1bc76d5c5 100644
> --- a/net/ipv6/output_core.c
> +++ b/net/ipv6/output_core.c
> @@ -62,12 +62,14 @@ EXPORT_SYMBOL_GPL(ipv6_proxy_select_ident);
>  void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
>  {
>  	static u32 ip6_idents_hashrnd __read_mostly;
> -	u32 id;
> +	u32 id = 0;
>  
>  	net_get_random_once(&ip6_idents_hashrnd, sizeof(ip6_idents_hashrnd));
>  
> -	id = __ipv6_select_ident(ip6_idents_hashrnd, &rt->rt6i_dst.addr,
> -				 &rt->rt6i_src.addr);
> +	if (rt)
> +		id = __ipv6_select_ident(ip6_idents_hashrnd, &rt->rt6i_dst.addr,
> +					 &rt->rt6i_src.addr);
> +
>  	fhdr->identification = htonl(id);
>  }
>  EXPORT_SYMBOL(ipv6_select_ident);
> 

Hi Sabrina

This would result in us using id 0 which is not what we want to do.

In this case, udp6_ufo_fragment() should be calling ipv6_proxy_select_ident() so that
the fragment id is properly generated.

-vlad
