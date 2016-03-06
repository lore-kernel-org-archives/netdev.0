From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Sun, 06 Mar 2016 00:55:28 -0500 (EST)
Message-ID: <20160306.005528.536271812454698509.davem@davemloft.net>
References: <1456946361-9889-1-git-send-email-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56179 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbcCFFzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 00:55:32 -0500
In-Reply-To: <1456946361-9889-1-git-send-email-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Wed,  2 Mar 2016 11:19:21 -0800

> @@ -566,7 +567,16 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>  	if (type == ICMPV6_PKT_TOOBIG) {
>  		if (!ip6_sk_accept_pmtu(sk))
>  			goto out;
> -		ip6_sk_update_pmtu(skb, sk, info);
> +		bh_lock_sock(sk);
> +		if (sk->sk_state == TCP_ESTABLISHED &&
> +		    !sock_owned_by_user(sk) &&
> +		    ipv6_addr_equal(saddr, &sk->sk_v6_rcv_saddr) &&
> +		    ipv6_addr_equal(daddr, &sk->sk_v6_daddr) &&
> +		    uh->dest == sk->sk_dport)
> +			inet6_csk_update_pmtu(sk, ntohl(info));

If I apply this patch it will hide a bug.

Why isn't ip6_sk_update_pmtu() matching the same route as the
one attached to the socket?

I'd prefer you figure out what part of the lookup key used is
wrong, and fix that instead.

Thanks.
