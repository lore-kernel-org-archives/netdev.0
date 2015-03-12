From: John <jw@nuclearfallout.net>
Subject: Re: [PATCH net] xps: must clear sender_cpu before forwarding
Date: Wed, 11 Mar 2015 22:21:32 -0700
Message-ID: <5501225C.7040205@nuclearfallout.net>
References: <5500E52C.7080603@nuclearfallout.net>	 <CANn89iLHkYc2Kay7z+v=tHMW5aYSqUf8V4f70Z-d5fUuuUXnpw@mail.gmail.com> <1426124522.11398.129.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nuclearfallout.net ([208.146.45.251]:56088 "EHLO
	mail.nuclearfallout.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbbCLFaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 01:30:39 -0400
In-Reply-To: <1426124522.11398.129.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, Eric. I will test again tomorrow.

-John

On 3/11/2015 6:42 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> John reported that my previous commit added a regression
> on his router.
>
> This is because sender_cpu & napi_id share a common location,
> so get_xps_queue() can see garbage and perform an out of bound access.
>
> We need to make sure sender_cpu is cleared before doing the transmit,
> otherwise any NIC busy poll enabled (skb_mark_napi_id()) can trigger
> this bug.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: John <jw@nuclearfallout.net>
> Bisected-by: John <jw@nuclearfallout.net>
> Fixes: 2bd82484bb4c ("xps: fix xps for stacked devices")
> ---
>   include/linux/skbuff.h |    7 +++++++
>   net/core/skbuff.c      |    2 +-
>   net/ipv4/ip_forward.c  |    1 +
>   net/ipv6/ip6_output.c  |    1 +
>   4 files changed, 10 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 30007afe70b3..f54d6659713a 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -948,6 +948,13 @@ static inline void skb_copy_hash(struct sk_buff *to, const struct sk_buff *from)
>   	to->l4_hash = from->l4_hash;
>   };
>   
> +static inline void skb_sender_cpu_clear(struct sk_buff *skb)
> +{
> +#ifdef CONFIG_XPS
> +	skb->sender_cpu = 0;
> +#endif
> +}
> +
>   #ifdef NET_SKBUFF_DATA_USES_OFFSET
>   static inline unsigned char *skb_end_pointer(const struct sk_buff *skb)
>   {
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index f80507823531..434e78e5254d 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -4173,7 +4173,7 @@ void skb_scrub_packet(struct sk_buff *skb, bool xnet)
>   	skb->ignore_df = 0;
>   	skb_dst_drop(skb);
>   	skb->mark = 0;
> -	skb->sender_cpu = 0;
> +	skb_sender_cpu_clear(skb);
>   	skb_init_secmark(skb);
>   	secpath_reset(skb);
>   	nf_reset(skb);
> diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
> index 787b3c294ce6..d9bc28ac5d1b 100644
> --- a/net/ipv4/ip_forward.c
> +++ b/net/ipv4/ip_forward.c
> @@ -67,6 +67,7 @@ static int ip_forward_finish(struct sk_buff *skb)
>   	if (unlikely(opt->optlen))
>   		ip_forward_options(skb);
>   
> +	skb_sender_cpu_clear(skb);
>   	return dst_output(skb);
>   }
>   
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 0a04a37305d5..7e80b61b51ff 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -318,6 +318,7 @@ static int ip6_forward_proxy_check(struct sk_buff *skb)
>   
>   static inline int ip6_forward_finish(struct sk_buff *skb)
>   {
> +	skb_sender_cpu_clear(skb);
>   	return dst_output(skb);
>   }
>   
>
>
