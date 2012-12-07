From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 02/10] tipc: eliminate aggregate
 sk_receive_queue limit
Date: Fri, 7 Dec 2012 11:07:33 -0500
Message-ID: <20121207160733.GD29819@shamino.rdu.redhat.com>
References: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
 <1354890498-6448-3-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39899 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030757Ab2LGQHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 11:07:47 -0500
Content-Disposition: inline
In-Reply-To: <1354890498-6448-3-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 07, 2012 at 09:28:10AM -0500, Paul Gortmaker wrote:
> From: Ying Xue <ying.xue@windriver.com>
> 
> As a complement to the per-socket sk_recv_queue limit, TIPC keeps a
> global atomic counter for the sum of sk_recv_queue sizes across all
> tipc sockets. When incremented, the counter is compared to an upper
> threshold value, and if this is reached, the message is rejected
> with error code TIPC_OVERLOAD.
> 
> This check was originally meant to protect the node against
> buffer exhaustion and general CPU overload. However, all experience
> indicates that the feature not only is redundant on Linux, but even
> harmful. Users run into the limit very often, causing disturbances
> for their applications, while removing it seems to have no negative
> effects at all. We have also seen that overall performance is
> boosted significantly when this bottleneck is removed.
> 
> Furthermore, we don't see any other network protocols maintaining
> such a mechanism, something strengthening our conviction that this
> control can be eliminated.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>  net/tipc/socket.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
> 
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> index 1a720c8..a059ed0 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -2,7 +2,7 @@
>   * net/tipc/socket.c: TIPC socket API
>   *
>   * Copyright (c) 2001-2007, Ericsson AB
> - * Copyright (c) 2004-2008, 2010-2011, Wind River Systems
> + * Copyright (c) 2004-2008, 2010-2012, Wind River Systems
>   * All rights reserved.
>   *
>   * Redistribution and use in source and binary forms, with or without
> @@ -1241,11 +1241,6 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
>  	}
>  
>  	/* Reject message if there isn't room to queue it */
> -	recv_q_len = (u32)atomic_read(&tipc_queue_size);
> -	if (unlikely(recv_q_len >= OVERLOAD_LIMIT_BASE)) {
> -		if (rx_queue_full(msg, recv_q_len, OVERLOAD_LIMIT_BASE))
> -			return TIPC_ERR_OVERLOAD;
> -	}
If you're going to remove the one place that you read this variable, don't you
also want to remove the points where you increment/decrement the atomic as well,
and for that matter eliminate the definition itself?

Neil
