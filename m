From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 3/4] ipv6: Add gro functions to sit_offloads
Date: Mon, 19 Oct 2015 19:04:01 -0700
Message-ID: <1445306641.30896.42.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438621878-1113072-1-git-send-email-tom@herbertland.com>
	 <1438621878-1113072-4-git-send-email-tom@herbertland.com>
	 <CAEP_g=8tCkyRfPYARV4pqA7g0w6tQvioTnWLtFescv+3OS4JLw@mail.gmail.com>
	 <1445009029.25595.16.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jerry Chu <hkchu@google.com>, Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, kernel-team@fb.com,
	Wolfgang Walter <linux@stwm.de>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33114 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbbJTCEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 22:04:04 -0400
Received: by pabrc13 with SMTP id rc13so4535875pab.0
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 19:04:03 -0700 (PDT)
In-Reply-To: <1445009029.25595.16.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-16 at 08:23 -0700, Eric Dumazet wrote:

> What about the following more complete patch ?
> 
> We properly set skb->encapsulation and inner network header as some NIC
> drivers depend on it. Our GSO should also work properly I think.
> 
> Wolfgang, could you please test it ? (this is a patch on top of David
> Miller net-next tree)
> 
> Both Google and Facebook are eager to get proper GRO/SIT support ;)
> 
> Thanks !
> 
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index 08b62047c67f..eeca943f12dc 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -264,6 +264,9 @@ static int ipv6_gro_complete(struct sk_buff *skb, int nhoff)
>  	struct ipv6hdr *iph = (struct ipv6hdr *)(skb->data + nhoff);
>  	int err = -ENOSYS;
>  
> +	if (skb->encapsulation)
> +		skb_set_inner_network_header(skb, nhoff);
> +
>  	iph->payload_len = htons(skb->len - nhoff - sizeof(*iph));
>  
>  	rcu_read_lock();
> @@ -280,6 +283,13 @@ out_unlock:
>  	return err;
>  }
>  
> +static int sit_gro_complete(struct sk_buff *skb, int nhoff)
> +{
> +	skb->encapsulation = 1;
> +	skb_shinfo(skb)->gso_type |= SKB_GSO_SIT;
> +	return ipv6_gro_complete(skb, nhoff);
> +}
> +
>  static struct packet_offload ipv6_packet_offload __read_mostly = {
>  	.type = cpu_to_be16(ETH_P_IPV6),
>  	.callbacks = {
> @@ -292,6 +302,8 @@ static struct packet_offload ipv6_packet_offload __read_mostly = {
>  static const struct net_offload sit_offload = {
>  	.callbacks = {
>  		.gso_segment	= ipv6_gso_segment,
> +		.gro_receive    = ipv6_gro_receive,
> +		.gro_complete   = sit_gro_complete,
>  	},
>  };
>  
> 

FYI, I've tested this patch and confirm it works properly.

I will therefore submit an official patch.

I'll also submit a patch against dummy device to add missing features.
