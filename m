From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/7] inet: add ireq_state field to
 inet_request_sock
Date: Thu, 12 Mar 2015 18:41:04 -0400 (EDT)
Message-ID: <20150312.184104.1561012099436884851.davem@davemloft.net>
References: <1426197016-14482-1-git-send-email-edumazet@google.com>
	<1426197016-14482-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbbCLWlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 18:41:06 -0400
In-Reply-To: <1426197016-14482-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Thu, 12 Mar 2015 14:50:11 -0700

> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index 6bcaa33cd804..8febaeb12f6d 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -403,6 +403,9 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
>  	ireq = inet_rsk(req);
>  	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
>  	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
> +	write_pnet(&ireq->ireq_net, sock_net(sk));
> +	ireq->ireq_state = TCP_NEW_SYN_RECV;
> +	atomic64_set(&ireq->ir_cookie, 0);
>  
>  	if (ipv6_opt_accepted(sk, skb, IP6CB(skb)) ||
>  	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
 ...
> diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
> index 7337fc7947e2..d8b4fed2a9b6 100644
> --- a/net/ipv6/syncookies.c
> +++ b/net/ipv6/syncookies.c
> @@ -196,6 +196,8 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
>  	ireq = inet_rsk(req);
>  	treq = tcp_rsk(req);
>  	treq->listener = NULL;
> +	write_pnet(&ireq->ireq_net, sock_net(sk));
> +	ireq->ireq_state = TCP_NEW_SYN_RECV;
>  
>  	if (security_inet_conn_request(sk, skb, req))
>  		goto out_free;

The write_pnet() and atomic64_set() calls in these hunks seem
completely unrelated to this change, and are in fact bug fixes.
