From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: remove dst refcount false sharing for
 prequeue mode
Date: Mon, 08 Sep 2014 14:21:43 -0700 (PDT)
Message-ID: <20140908.142143.807176983873922125.davem@davemloft.net>
References: <1410014704.11872.16.camel@edumazet-glaptop2.roam.corp.google.com>
	<1410017237.11872.31.camel@edumazet-glaptop2.roam.corp.google.com>
	<1410188767.11872.110.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755279AbaIHVVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 17:21:44 -0400
In-Reply-To: <1410188767.11872.110.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 08 Sep 2014 08:06:07 -0700

> @@ -1559,7 +1559,17 @@ bool tcp_prequeue(struct sock *sk, struct sk_buff *skb)
>  	    skb_queue_len(&tp->ucopy.prequeue) == 0)
>  		return false;
>  
> -	skb_dst_force(skb);
> +	/* Before escaping RCU protected region, we need to take care of skb
> +	 * dst. Prequeue is only enabled for established sockets.
> +	 * For such sockets, we might need the skb dst only to set sk->sk_rx_dst
> +	 * Instead of doing full sk_rx_dst validity here, let's perform
> +	 * an optimistic check.
> +	 */
> +	if (likely(sk->sk_rx_dst))
> +		skb_dst_drop(skb);
> +	else
> +		skb_dst_force(skb);
> +

This might not be a strong enough test.

We have to also make all of the checks that would cause the input
path to invalidate sk->sk_rx_dst too.

Otherwise, if it does, we'll crash when we try to do a dst_hold()
on skb_dst(skb) in sk->sk_rx_dst_set().
