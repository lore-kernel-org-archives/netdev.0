From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH V2 net-next 1/3] ipv6: add the IPV6_FL_F_REFLECT flag to IPV6_FL_A_GET
Date: Wed, 15 Jan 2014 23:47:26 +0100
Message-ID: <20140115224726.GH19945@order.stressinduktion.org>
References: <1389785403-6401-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40828 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbaAOWr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 17:47:27 -0500
Content-Disposition: inline
In-Reply-To: <1389785403-6401-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 12:30:01PM +0100, Florent Fourcot wrote:
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index ffd5fa8..f61bedc 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -483,6 +483,8 @@ static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
>  				    &ireq->ir_v6_rmt_addr);
>  
>  		fl6->daddr = ireq->ir_v6_rmt_addr;
> +		if (np->repflow)
> +			fl6->flowlabel = np->flow_label;
>  		skb_set_queue_mapping(skb, queue_mapping);
>  		err = ip6_xmit(sk, skb, fl6, np->opt, np->tclass);
>  		err = net_xmit_eval(err);
> @@ -1000,6 +1002,8 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
>  	ireq = inet_rsk(req);
>  	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
>  	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
> +	if (np->repflow)
> +		np->flow_label = ip6_flowlabel(ipv6_hdr(skb));
>  	if (!want_cookie || tmp_opt.tstamp_ok)
>  		TCP_ECN_create_request(req, skb, sock_net(sk));
>  
> @@ -1138,6 +1142,8 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
>  		newnp->mcast_oif   = inet6_iif(skb);
>  		newnp->mcast_hops  = ipv6_hdr(skb)->hop_limit;
>  		newnp->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(skb));
> +		if (np->repflow)
> +			newnp->flow_label = ip6_flowlabel(ipv6_hdr(skb));

Just asking:

Was there a specific reason you did not use np->flow_label here and just
mirroring the flowlabel from the first packet of the connection for the
whole connection?

I don't know if it makes a difference, but maybe it was done on purpose?

Otherwise looks good.

>  		/*
>  		 * No need to charge this sock to the relevant IPv6 refcnt debug socks count
> @@ -1218,6 +1224,8 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
>  	newnp->mcast_oif  = inet6_iif(skb);
>  	newnp->mcast_hops = ipv6_hdr(skb)->hop_limit;
>  	newnp->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(skb));
> +	if (np->repflow)
> +		newnp->flow_label = ip6_flowlabel(ipv6_hdr(skb));
>  
>  	/* Clone native IPv6 options from listening socket (if any)
>  
> @@ -1429,6 +1437,8 @@ ipv6_pktoptions:
>  			np->mcast_hops = ipv6_hdr(opt_skb)->hop_limit;
>  		if (np->rxopt.bits.rxflow || np->rxopt.bits.rxtclass)
>  			np->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(opt_skb));
> +		if (np->repflow)
> +			np->flow_label = ip6_flowlabel(ipv6_hdr(opt_skb));
>  		if (ipv6_opt_accepted(sk, opt_skb)) {
>  			skb_set_owner_r(opt_skb, sk);
>  			opt_skb = xchg(&np->pktoptions, opt_skb);
> -- 
> 1.8.5.2
