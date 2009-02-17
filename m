From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netlink: add NETLINK_BROADCAST_ERROR socket option
Date: Tue, 17 Feb 2009 15:18:46 +0100
Message-ID: <499AC746.5070403@trash.net>
References: <20090217135602.25864.20453.stgit@Decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57217 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521AbZBQOSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 09:18:49 -0500
In-Reply-To: <20090217135602.25864.20453.stgit@Decadence>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> @@ -973,7 +974,7 @@ static inline int do_one_broadcast(struct sock *sk,
>  	if (!net_eq(sock_net(sk), p->net))
>  		goto out;
>  
> -	if (p->failure) {
> +	if ((nlk->flags & NETLINK_BROADCAST_SEND_ERROR) && p->failure) {
>  		netlink_overrun(sk);
>  		goto out;
>  	}
 >
> @@ -994,13 +995,15 @@ static inline int do_one_broadcast(struct sock *sk,
>  	if (p->skb2 == NULL) {
>  		netlink_overrun(sk);
>  		/* Clone failed. Notify ALL listeners. */
> -		p->failure = 1;
> +		if (nlk->flags & NETLINK_BROADCAST_SEND_ERROR)
> +			p->failure = 1;

Almost :) If we didn't manage to clone, we can't deliver to *any*
socket, so the check in the first chunk above is incorrect. It
needs to always call netlink_overrun(), additionally it needs to
set delivery_failure when the SEND_ERROR flag is present.

Something like this:

  	if (p->failure) {
  +		if (nlk->flags & NETLINK_BROADCAST_SEND_ERROR)
  +			p->delivery_failure = 1;
   		netlink_overrun(sk);
   		goto out;
   	}

>  	} else if (sk_filter(sk, p->skb2)) {
>  		kfree_skb(p->skb2);
>  		p->skb2 = NULL;
>  	} else if ((val = netlink_broadcast_deliver(sk, p->skb2)) < 0) {
>  		netlink_overrun(sk);
> -		p->delivery_failure = 1;
> +		if (nlk->flags & NETLINK_BROADCAST_SEND_ERROR)
> +			p->delivery_failure = 1;
>  	} else {
>  		p->congested |= val;
>  		p->delivered = 1;

