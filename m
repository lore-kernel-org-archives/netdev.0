From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net] ipv6: call ipv6_proxy_select_ident instead of ipv6_select_ident
 in udp6_ufo_fragment
Date: Thu, 19 Mar 2015 08:37:49 -0400
Message-ID: <550AC31D.2080900@redhat.com>
References: <20150319101036.GA10040@kria> <1426760552-10535-1-git-send-email-sd@queasysnail.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matt@mattgrant.net.nz
To: Sabrina Dubroca <sd@queasysnail.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7745 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751511AbbCSMiN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 08:38:13 -0400
In-Reply-To: <1426760552-10535-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/19/2015 06:22 AM, Sabrina Dubroca wrote:
> Matt Grant reported frequent crashes in ipv6_select_ident when
> udp6_ufo_fragment is called from openvswitch on a skb that doesn't
> have a dst_entry set.
> 
> ipv6_proxy_select_ident generates the frag_id without using the dst
> associated with the skb.  This approach was suggested by Vladislav
> Yasevich.
> 
> Fixes: 0508c07f5e0c ("ipv6: Select fragment id during UFO segmentation if not set.")
> Cc: Vladislav Yasevich <vyasevic@redhat.com>
> Reported-by: Matt Grant <matt@mattgrant.net.nz>
> Tested-by: Matt Grant <matt@mattgrant.net.nz>
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Acked-by: Vladislav Yasevich <vyasevic@redhat.com>

-vlad

> ---
> David, can you queue this for stable/3.19?  Thanks.
> 
>  net/ipv6/udp_offload.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
> index ab889bb16b3c..be2c0ba82c85 100644
> --- a/net/ipv6/udp_offload.c
> +++ b/net/ipv6/udp_offload.c
> @@ -112,11 +112,9 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
>  		fptr = (struct frag_hdr *)(skb_network_header(skb) + unfrag_ip6hlen);
>  		fptr->nexthdr = nexthdr;
>  		fptr->reserved = 0;
> -		if (skb_shinfo(skb)->ip6_frag_id)
> -			fptr->identification = skb_shinfo(skb)->ip6_frag_id;
> -		else
> -			ipv6_select_ident(fptr,
> -					  (struct rt6_info *)skb_dst(skb));
> +		if (!skb_shinfo(skb)->ip6_frag_id)
> +			ipv6_proxy_select_ident(skb);
> +		fptr->identification = skb_shinfo(skb)->ip6_frag_id;
>  
>  		/* Fragment the skb. ipv6 header and the remaining fields of the
>  		 * fragment header are updated in ipv6_gso_segment()
> 
