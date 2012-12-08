From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 2/9] tipc: eliminate aggregate sk_receive_queue
 limit
Date: Sat, 8 Dec 2012 09:07:27 -0500
Message-ID: <20121208140727.GA6214@hmsreliant.think-freely.org>
References: <1354929558-16948-1-git-send-email-paul.gortmaker@windriver.com>
 <1354929558-16948-3-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48817 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754269Ab2LHOHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2012 09:07:41 -0500
Content-Disposition: inline
In-Reply-To: <1354929558-16948-3-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 07, 2012 at 08:19:11PM -0500, Paul Gortmaker wrote:
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
> As a result, the atomic variable tipc_queue_size is now unused
> and so it can be deleted.  There is a getsockopt call that used
> to allow reading it; we retain that but just return zero for
> maximum compatibility.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> [PG: phase out tipc_queue_size as pointed out by Neil Horman]
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>  net/tipc/socket.c | 23 ++++-------------------
>  1 file changed, 4 insertions(+), 19 deletions(-)
> 
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> index 1a720c8..848be69 100644
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
> @@ -73,8 +73,6 @@ static struct proto tipc_proto;
>  
>  static int sockets_enabled;
>  
> -static atomic_t tipc_queue_size = ATOMIC_INIT(0);
> -
>  /*
>   * Revised TIPC socket locking policy:
>   *
> @@ -128,7 +126,6 @@ static atomic_t tipc_queue_size = ATOMIC_INIT(0);
>  static void advance_rx_queue(struct sock *sk)
>  {
>  	kfree_skb(__skb_dequeue(&sk->sk_receive_queue));
> -	atomic_dec(&tipc_queue_size);
>  }
>  
>  /**
> @@ -140,10 +137,8 @@ static void discard_rx_queue(struct sock *sk)
>  {
>  	struct sk_buff *buf;
>  
> -	while ((buf = __skb_dequeue(&sk->sk_receive_queue))) {
> -		atomic_dec(&tipc_queue_size);
> +	while ((buf = __skb_dequeue(&sk->sk_receive_queue)))
>  		kfree_skb(buf);
> -	}
>  }
>  
>  /**
> @@ -155,10 +150,8 @@ static void reject_rx_queue(struct sock *sk)
>  {
>  	struct sk_buff *buf;
>  
> -	while ((buf = __skb_dequeue(&sk->sk_receive_queue))) {
> +	while ((buf = __skb_dequeue(&sk->sk_receive_queue)))
>  		tipc_reject_msg(buf, TIPC_ERR_NO_PORT);
> -		atomic_dec(&tipc_queue_size);
> -	}
>  }
>  
>  /**
> @@ -280,7 +273,6 @@ static int release(struct socket *sock)
>  		buf = __skb_dequeue(&sk->sk_receive_queue);
>  		if (buf == NULL)
>  			break;
> -		atomic_dec(&tipc_queue_size);
>  		if (TIPC_SKB_CB(buf)->handle != 0)
>  			kfree_skb(buf);
>  		else {
> @@ -1241,11 +1233,6 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
>  	}
>  
>  	/* Reject message if there isn't room to queue it */
> -	recv_q_len = (u32)atomic_read(&tipc_queue_size);
> -	if (unlikely(recv_q_len >= OVERLOAD_LIMIT_BASE)) {
> -		if (rx_queue_full(msg, recv_q_len, OVERLOAD_LIMIT_BASE))
> -			return TIPC_ERR_OVERLOAD;
> -	}
>  	recv_q_len = skb_queue_len(&sk->sk_receive_queue);
>  	if (unlikely(recv_q_len >= (OVERLOAD_LIMIT_BASE / 2))) {
>  		if (rx_queue_full(msg, recv_q_len, OVERLOAD_LIMIT_BASE / 2))
> @@ -1254,7 +1241,6 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
>  
>  	/* Enqueue message (finally!) */
>  	TIPC_SKB_CB(buf)->handle = 0;
> -	atomic_inc(&tipc_queue_size);
>  	__skb_queue_tail(&sk->sk_receive_queue, buf);
>  
>  	/* Initiate connection termination for an incoming 'FIN' */
> @@ -1578,7 +1564,6 @@ restart:
>  		/* Disconnect and send a 'FIN+' or 'FIN-' message to peer */
>  		buf = __skb_dequeue(&sk->sk_receive_queue);
>  		if (buf) {
> -			atomic_dec(&tipc_queue_size);
>  			if (TIPC_SKB_CB(buf)->handle != 0) {
>  				kfree_skb(buf);
>  				goto restart;
> @@ -1717,7 +1702,7 @@ static int getsockopt(struct socket *sock,
>  		/* no need to set "res", since already 0 at this point */
>  		break;
>  	case TIPC_NODE_RECVQ_DEPTH:
> -		value = (u32)atomic_read(&tipc_queue_size);
> +		value = 0; /* was tipc_queue_size, now obsolete */
>  		break;
>  	case TIPC_SOCK_RECVQ_DEPTH:
>  		value = skb_queue_len(&sk->sk_receive_queue);
> -- 
> 1.7.12.1
> 
> 
Thank you, looks good
Acked-by: Neil Horman <nhorman@tuxdriver.com>
