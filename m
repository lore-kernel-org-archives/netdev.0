From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] cls_flow: add sanity check for the packet length
Date: Wed, 04 Aug 2010 09:39:43 -0400
Message-ID: <1280929183.5669.7.camel@bigi>
References: <1280905687-8463-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:50875 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756262Ab0HDNju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 09:39:50 -0400
Received: by yxg6 with SMTP id 6so1977915yxg.19
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 06:39:49 -0700 (PDT)
In-Reply-To: <1280905687-8463-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-08-04 at 15:08 +0800, Changli Gao wrote: 
> The packet length should be checked before the packet data is dereferenced.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  include/linux/skbuff.h |    6 ++--
>  net/sched/cls_flow.c   |   69 +++++++++++++++++++++++++++++++++----------------
>  2 files changed, 50 insertions(+), 25 deletions(-)
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index d20d9e7..3f0ac50 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -1210,12 +1210,12 @@ static inline unsigned char *pskb_pull(struct sk_buff *skb, unsigned int len)
>  	return unlikely(len > skb->len) ? NULL : __pskb_pull(skb, len);
>  }
>  
> -static inline int pskb_may_pull(struct sk_buff *skb, unsigned int len)
> +static inline bool pskb_may_pull(struct sk_buff *skb, unsigned int len)
>  {
>  	if (likely(len <= skb_headlen(skb)))
> -		return 1;
> +		return true;
>  	if (unlikely(len > skb->len))
> -		return 0;
> +		return false;
>  	return __pskb_pull_tail(skb, len - skb_headlen(skb)) != NULL;
>  }

Above is a different patch?

> diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
> index f73542d..d63a374 100644
> --- a/net/sched/cls_flow.c
> +++ b/net/sched/cls_flow.c
> @@ -65,37 +65,48 @@ static inline u32 addr_fold(void *addr)
>  	return (a & 0xFFFFFFFF) ^ (BITS_PER_LONG > 32 ? a >> 32 : 0);
>  }
>  
> -static u32 flow_get_src(const struct sk_buff *skb)
> +static inline bool flow_pskb_may_pull(struct sk_buff *skb, unsigned int len)
> +{
> +	return pskb_may_pull(skb, skb_network_offset(skb) + len);
> +}

network_pskb_may_pull() would make it more generic (probably in
skbuff.h) and reused everywhere you need skb_network_offset


> +static u32 flow_get_src(struct sk_buff *skb)
>  {
>  	switch (skb->protocol) {
>  	case htons(ETH_P_IP):
> -		return ntohl(ip_hdr(skb)->saddr);
> +		return flow_pskb_may_pull(skb, sizeof(struct iphdr)) ?
> +		       ntohl(ip_hdr(skb)->saddr) : 0;
>  	case htons(ETH_P_IPV6):
> -		return ntohl(ipv6_hdr(skb)->saddr.s6_addr32[3]);
> +		return flow_pskb_may_pull(skb, sizeof(struct ipv6hdr)) ?
> +		       ntohl(ipv6_hdr(skb)->saddr.s6_addr32[3]) : 0;
>  	default:


BTW - does returning zero above make sense or is returning the default below better?

>  		return addr_fold(skb->sk);

Same comment applies in all other switch statements..

cheers,
jamal

