From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] inet6: Fix paramater issue of inet6_csk_xmit
Date: Sun, 03 Aug 2008 21:03:08 -0400
Message-ID: <4896554C.3040404@hp.com>
References: <48929C5B.5030108@cn.fujitsu.com> <E1KOqf7-0004lB-00@gondolin.me.apana.org.au> <20080801.021825.51896743.davem@davemloft.net> <20080801092548.GA18424@gondor.apana.org.au> <20080801115041.GA19124@gondor.apana.org.au> <20080801131453.GA19851@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, yjwei@cn.fujitsu.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:24846 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbYHDBDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 21:03:15 -0400
In-Reply-To: <20080801131453.GA19851@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert

Herbert Xu wrote:
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 535a18f..ab1c472 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -524,8 +524,7 @@ static inline void sctp_ssn_skip(struct sctp_stream *stream, __u16 id,
>   */
>  struct sctp_af {
>  	int		(*sctp_xmit)	(struct sk_buff *skb,
> -					 struct sctp_transport *,
> -					 int ipfragok);
> +					 struct sctp_transport *);
>  	int		(*setsockopt)	(struct sock *sk,
>  					 int level,
>  					 int optname,
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index a238d68..11dab07 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -195,8 +195,7 @@ out:
>  }
>  
>  /* Based on tcp_v6_xmit() in tcp_ipv6.c. */
> -static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport,
> -			int ipfragok)
> +static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
>  {
>  	struct sock *sk = skb->sk;
>  	struct ipv6_pinfo *np = inet6_sk(sk);
> @@ -231,7 +230,10 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport,
>  
>  	SCTP_INC_STATS(SCTP_MIB_OUTSCTPPACKS);
>  
> -	return ip6_xmit(sk, skb, &fl, np->opt, ipfragok);
> +	if (!(tp->param_flags & SPP_PMTUD_ENABLE))
> +		skb->local_df = 1;
> +

s/tp/transport.  Otherwise, will not compile.

> +	return ip6_xmit(sk, skb, &fl, np->opt, 0);
>  }
>  
>  /* Returns the dst cache entry for the given source and destination ip
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 4568464..0dc4a7d 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -586,10 +586,8 @@ int sctp_packet_transmit(struct sctp_packet *packet)
>  	SCTP_DEBUG_PRINTK("***sctp_transmit_packet*** skb len %d\n",
>  			  nskb->len);
>  
> -	if (tp->param_flags & SPP_PMTUD_ENABLE)
> -		(*tp->af_specific->sctp_xmit)(nskb, tp, packet->ipfragok);
> -	else
> -		(*tp->af_specific->sctp_xmit)(nskb, tp, 1);
> +	nskb->local_df = packet->ipfragok;
> +	(*tp->af_specific->sctp_xmit)(nskb, tp);
>  
>  out:
>  	packet->size = packet->overhead;
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index a6e0818..80b8efb 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -862,16 +862,25 @@ static int sctp_inet_supported_addrs(const struct sctp_sock *opt,
>  
>  /* Wrapper routine that calls the ip transmit routine. */
>  static inline int sctp_v4_xmit(struct sk_buff *skb,
> -			       struct sctp_transport *transport, int ipfragok)
> +			       struct sctp_transport *transport)
>  {
> +	struct inet_sock *inet = inet_sk(skb->sk);
> +
>  	SCTP_DEBUG_PRINTK("%s: skb:%p, len:%d, "
>  			  "src:%u.%u.%u.%u, dst:%u.%u.%u.%u\n",
>  			  __func__, skb, skb->len,
>  			  NIPQUAD(skb->rtable->rt_src),
>  			  NIPQUAD(skb->rtable->rt_dst));
>  
> +	/*
> +	 * You'd think with a protocol this big they could afford
> +	 * a struct sock per transport.
> +	 */

Please change this comment to be descriptive of the code, or just
remove it.

> +	inet->pmtudisc = transport->param_flags & SPP_PMTUD_ENABLE ?
> +			 IP_PMTUDISC_DO : IP_PMTUDISC_DONT;
> +
>  	SCTP_INC_STATS(SCTP_MIB_OUTSCTPPACKS);
> -	return ip_queue_xmit(skb, ipfragok);
> +	return ip_queue_xmit(skb, 0);
>  }
>  
>  static struct sctp_af sctp_af_inet;
> 
> Cheers,

Otherwise, all of my tests have passed.

Thanks
-vlad
