From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: Add sysctl to toggle early demux for
 tcp and udp
Date: Wed, 22 Mar 2017 14:19:31 -0700 (PDT)
Message-ID: <20170322.141931.1498296429784499112.davem@davemloft.net>
References: <1490152810-25133-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        stephen@networkplumber.org, tom@herbertland.com
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44714 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751368AbdCVVTc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 17:19:32 -0400
In-Reply-To: <1490152810-25133-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Tue, 21 Mar 2017 21:20:10 -0600

> @@ -329,7 +329,7 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
>  		int protocol = iph->protocol;
>  
>  		ipprot = rcu_dereference(inet_protos[protocol]);
> -		if (ipprot && ipprot->early_demux) {
> +		if (ipprot && READ_ONCE(ipprot->early_demux)) {
>  			ipprot->early_demux(skb);

I think you need to use a local variable for the function pointer in conjunction
with READ_ONCE() for this to work properly:

	if (ipprot && (func = READ_ONCE(ipprot->early_demux))) {
		func(skb);
		...

> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> index aacfb4b..30d18cb 100644
> --- a/net/ipv6/ip6_input.c
> +++ b/net/ipv6/ip6_input.c
> @@ -60,7 +60,7 @@ int ip6_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
>  		const struct inet6_protocol *ipprot;
>  
>  		ipprot = rcu_dereference(inet6_protos[ipv6_hdr(skb)->nexthdr]);
> -		if (ipprot && ipprot->early_demux)
> +		if (ipprot && READ_ONCE(ipprot->early_demux))
>  			ipprot->early_demux(skb);
>  	}
>  	if (!skb_valid_dst(skb))

Likewise.
