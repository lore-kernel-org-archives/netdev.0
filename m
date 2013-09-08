From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] net: fix multiqueue selection
Date: Sat, 07 Sep 2013 21:08:59 -0700
Message-ID: <522BF85B.3000909@gmail.com>
References: <1378580577.26319.26.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:41805 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab3IHEI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Sep 2013 00:08:58 -0400
Received: by mail-pa0-f49.google.com with SMTP id ld10so4935404pab.22
        for <netdev@vger.kernel.org>; Sat, 07 Sep 2013 21:08:57 -0700 (PDT)
In-Reply-To: <1378580577.26319.26.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2013 12:02 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> commit 416186fbf8c5b4e4465 ("net: Split core bits of netdev_pick_tx
> into __netdev_pick_tx") added a bug that disables caching of queue
> index in the socket.
> 
> This is the source of packet reorders for TCP flows, and
> again this is happening more often when using FQ pacing.
> 
> Old code was doing 
> 
> if (queue_index != old_index)
> 	sk_tx_queue_set(sk, queue_index);
> 
> Alexander renamed the variables but forgot to change sk_tx_queue_set()
> 2nd parameter.
> 
> if (queue_index != new_index)
> 	sk_tx_queue_set(sk, queue_index);
> 
> This means we store -1 over and over in sk->sk_tx_queue_mapping
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  net/core/flow_dissector.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 0ff42f0..1929af8 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -352,7 +352,7 @@ u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
>  
>  		if (queue_index != new_index && sk &&
>  		    rcu_access_pointer(sk->sk_dst_cache))
> -			sk_tx_queue_set(sk, queue_index);
> +			sk_tx_queue_set(sk, new_index);
>  
>  		queue_index = new_index;
>  	}
> 
> 
> --

Ugh, my bad.  This is a nasty one too since the behaviour appeared to be
correct for most cases.

It looks like this needs to go into stable for 3.9 - 3.11.

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
