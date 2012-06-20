From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 13:03:26 +0200
Message-ID: <1340190206.4604.862.camel@edumazet-glaptop>
References: <20120619.214657.1345825814176201681.davem@davemloft.net>
	 <1340171940.4604.799.camel@edumazet-glaptop>
	 <20120619.231412.1236237191660427779.davem@davemloft.net>
	 <20120620.031543.1511134879638711616.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40068 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037Ab2FTLDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 07:03:31 -0400
Received: by bkcji2 with SMTP id ji2so6020559bkc.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 04:03:30 -0700 (PDT)
In-Reply-To: <20120620.031543.1511134879638711616.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 03:15 -0700, David Miller wrote:

> Here's what I have so far, the ipv6 implementation we get nearly for
> free :-)
> 
> Initially I tried to use ->gro_complete() for this as it was more
> natural, but we abort before we get there for a lot of cases where we
> want to use the early demux and cached route (ACKs, FINs, sub-mss
> sized packets, etc.)
> 

Seems very good, I only have one remark :


>  /*
>   *	From tcp_input.c
>   */
> @@ -2576,6 +2530,7 @@ void tcp4_proc_exit(void)
>  struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>  {
>  	const struct iphdr *iph = skb_gro_network_header(skb);
> +	struct sk_buff **pp;
>  
>  	switch (skb->ip_summed) {
>  	case CHECKSUM_COMPLETE:
> @@ -2591,7 +2546,36 @@ struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>  		return NULL;
>  	}
>  
> -	return tcp_gro_receive(head, skb);
> +	pp = tcp_gro_receive(head, skb);
> +
> +	if (!NAPI_GRO_CB(skb)->same_flow) {
> +		const struct tcphdr *th = tcp_hdr(skb);
> +		struct net_device *dev = skb->dev;
> +		struct sock *sk;
> +
> +		sk = __inet_lookup_established(dev_net(dev), &tcp_hashinfo,
> +					       iph->saddr, th->source,
> +					       iph->daddr, th->dest,
> +					       dev->ifindex);
> +		if (sk) {
> +			skb_orphan(skb);
> +			skb->sk = sk;
> +			skb->destructor = sock_edemux;
> +			if (!skb_dst(skb) &&

I am not sure we need the skb_dst(skb) test here, it should be NULL
anyway in GRO layer ? (loopback device don't use GRO ;) )

> +			    sk->sk_state != TCP_TIME_WAIT) {
> +				struct dst_entry *dst = sk->sk_rx_dst;
> +				if (dst)
> +					dst = dst_check(dst, 0);
> +				if (dst) {
> +					struct rtable *rt = (struct rtable *) dst;
> +
> +					if (rt->rt_iif == dev->ifindex)
> +						skb_dst_set_noref(skb, dst);
> +				}
> +			}
> +		}
> +	}
> +	return pp;
>  }
>  
>  int tcp4_gro_complete(struct sk_buff *skb)
