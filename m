From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] udp: Simplify __udp*_lib_mcast_deliver.
Date: Tue, 15 Jul 2014 17:14:31 -0700 (PDT)
Message-ID: <20140715.171431.1611412835087664432.davem@davemloft.net>
References: <1405377039-10082-1-git-send-email-drheld@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, willemb@google.com
To: drheld@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45987 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759722AbaGPAOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 20:14:34 -0400
In-Reply-To: <1405377039-10082-1-git-send-email-drheld@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Held <drheld@google.com>
Date: Mon, 14 Jul 2014 18:30:38 -0400

>  	spin_lock(&hslot->lock);
> -	sk = sk_nulls_head(&hslot->head);
> -	dif = skb->dev->ifindex;
> -	sk = udp_v4_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
> -	while (sk) {
> -		stack[count++] = sk;
> -		sk = udp_v4_mcast_next(net, sk_nulls_next(sk), uh->dest,
> -				       daddr, uh->source, saddr, dif);
> -		if (unlikely(count == ARRAY_SIZE(stack))) {
> -			if (!sk)
> -				break;
> -			flush_stack(stack, count, skb, ~0);
> -			count = 0;
> +	sk_nulls_for_each(sk, node, &hslot->head) {
> +		if (__udp_is_mcast_sock(net, sk,
> +					uh->dest, daddr,
> +					uh->source, saddr,
> +					dif, hnum)) {
> +			stack[count++] = sk;
> +			if (unlikely(count == ARRAY_SIZE(stack))) {
> +				flush_stack(stack, count, skb, ~0);
> +				count = 0;
> +			}
>  		}
>  	}

I think you are changing the logic of the loop in the edge case.

If we have exactly ARRAY_SIZE(stack) sockets to process, the old code
performs the flush_stack() outside of the hslot->lock, but with your
change we'll do it inside the lock.

The tradeoff here is reducing hslot->lock hold times vs. avoiding
taking a hold on all the sockets in the stack[] array.

I just wanted to point this out and make sure you are aware of and
are ok with this.
