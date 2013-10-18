From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [patch net REPOST 3/3] ip_output: do skb ufo init for peeked
 non ufo skb as well
Date: Fri, 18 Oct 2013 22:45:42 +0400
Message-ID: <526181D6.6050107@cogentembedded.com>
References: <1382116431-28758-1-git-send-email-jiri@resnulli.us> <1382116431-28758-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	hannes@stressinduktion.or, jdmason@kudzu.us,
	yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, herbert@gondor.apana.org.au
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:54468 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757017Ab3JRSqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 14:46:43 -0400
Received: by mail-lb0-f172.google.com with SMTP id c11so2957557lbj.17
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 11:46:41 -0700 (PDT)
In-Reply-To: <1382116431-28758-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
>   net/ipv4/ip_output.c | 14 +++++++++-----
>   1 file changed, 9 insertions(+), 5 deletions(-)

> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index a04d872..bd21c5d 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -772,15 +772,19 @@ static inline int ip_ufo_append_data(struct sock *sk,
>   		/* initialize protocol header pointer */
>   		skb->transport_header = skb->network_header + fragheaderlen;
>
> -		skb->ip_summed = CHECKSUM_PARTIAL;
>   		skb->csum = 0;
>
> -		/* specify the length of each IP datagram fragment */
> -		skb_shinfo(skb)->gso_size = maxfraglen - fragheaderlen;
> -		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
> +
>   		__skb_queue_tail(queue, skb);
> -	}
> +	} else if (skb_is_gso(skb))
> +		goto append;

    Same comment on the necessity of {} here.

WBR, Sergei
