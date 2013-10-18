From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [patch net REPOST 2/3] ip6_output: do skb ufo init for peeked
 non ufo skb as well
Date: Fri, 18 Oct 2013 22:44:43 +0400
Message-ID: <5261819B.8020801@cogentembedded.com>
References: <1382116431-28758-1-git-send-email-jiri@resnulli.us> <1382116431-28758-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	hannes@stressinduktion.or, jdmason@kudzu.us,
	yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, herbert@gondor.apana.org.au
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:47261 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756535Ab3JRSpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 14:45:44 -0400
Received: by mail-la0-f46.google.com with SMTP id eh20so1062090lab.5
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 11:45:43 -0700 (PDT)
In-Reply-To: <1382116431-28758-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/18/2013 09:13 PM, Jiri Pirko wrote:

> Now, if user application does:
> sendto len<mtu flag MSG_MORE
> sendto len>mtu flag 0
> The skb is not treated as fragmented one because it is not initialized
> that way. So move the initialization to fix this.

> introduced by:
> commit e89e9cf539a28df7d0eb1d0a545368e9920b34ac "[IPv4/IPv6]: UFO Scatter-gather approach"

> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   net/ipv6/ip6_output.c | 26 ++++++++++++++------------
>   1 file changed, 14 insertions(+), 12 deletions(-)

> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index a54c45c..c6cfa2f 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
[...]
> @@ -1036,20 +1035,23 @@ static inline int ip6_ufo_append_data(struct sock *sk,
>   		skb->transport_header = skb->network_header + fragheaderlen;
>
>   		skb->protocol = htons(ETH_P_IPV6);
> -		skb->ip_summed = CHECKSUM_PARTIAL;
>   		skb->csum = 0;
>
> -		/* Specify the length of each IPv6 datagram fragment.
> -		 * It has to be a multiple of 8.
> -		 */
> -		skb_shinfo(skb)->gso_size = (mtu - fragheaderlen -
> -					     sizeof(struct frag_hdr)) & ~7;
> -		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
> -		ipv6_select_ident(&fhdr, rt);
> -		skb_shinfo(skb)->ip6_frag_id = fhdr.identification;
>   		__skb_queue_tail(&sk->sk_write_queue, skb);
> -	}
> +	} else if (skb_is_gso(skb))
> +		goto append;

    According to Documentation/CodingStyle, there should be {} in both arms of 
*if* statement if there's {} in one of them.

WBR, Sergei
