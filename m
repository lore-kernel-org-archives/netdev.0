From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] netlink: wake up netlink listeners sooner
Date: Wed, 21 Dec 2011 18:00:11 -0500 (EST)
Message-ID: <20111221.180011.42058520996715557.davem@davemloft.net>
References: <20111221134944.52223cdf@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56456 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848Ab1LUXAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 18:00:15 -0500
In-Reply-To: <20111221134944.52223cdf@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 21 Dec 2011 13:49:44 -0800

> @@ -960,7 +960,7 @@ static int netlink_broadcast_deliver(str
>  		skb_set_owner_r(skb, sk);
>  		skb_queue_tail(&sk->sk_receive_queue, skb);
>  		sk->sk_data_ready(sk, skb->len);
> -		return atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf;
> +		return atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf / 2;
>  	}

Please mirror the logic we use in the generic socket code to do this
on the send side, namely use something like:

		return (atomic_read(&sk->sk_rmem_alloc) << 1) > sk->sk_rcvbuf;

because sk_rcvbuf is an int and this "/ 2" expression will generate a
really silly sequence of multiple shifts, adds, and comparisons in
order to handle negative values correctly.
