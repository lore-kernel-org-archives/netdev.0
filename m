From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 01/12] tipc: change socket buffer overflow
 control to respect sk_rcvbuf
Date: Fri, 31 May 2013 09:36:42 -0400
Message-ID: <20130531133642.GA2727@hmsreliant.think-freely.org>
References: <1369942577-39563-1-git-send-email-paul.gortmaker@windriver.com>
 <1369942577-39563-2-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45637 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791Ab3EaNgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 09:36:50 -0400
Content-Disposition: inline
In-Reply-To: <1369942577-39563-2-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 03:36:06PM -0400, Paul Gortmaker wrote:
> From: Jon Maloy <jon.maloy@ericsson.com>
> 
> As per feedback from the netdev community, we change the buffer
> overflow protection algorithm in receiving sockets so that it
> always respects the nominal upper limit set in sk_rcvbuf.
> 
> Instead of scaling up from a small sk_rcvbuf value, which leads to
> violation of the configured sk_rcvbuf limit, we now calculate the
> weighted per-message limit by scaling down from a much bigger value,
> still in the same field, according to the importance priority of the
> received message.
> 
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>  net/tipc/socket.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> index 515ce38..2dfabc7 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -1,7 +1,7 @@
>  /*
>   * net/tipc/socket.c: TIPC socket API
>   *
> - * Copyright (c) 2001-2007, 2012 Ericsson AB
> + * Copyright (c) 2001-2007, 2012-2013, Ericsson AB
>   * Copyright (c) 2004-2008, 2010-2012, Wind River Systems
>   * All rights reserved.
>   *
> @@ -203,6 +203,7 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol,
>  
>  	sock_init_data(sock, sk);
>  	sk->sk_backlog_rcv = backlog_rcv;
> +	sk->sk_rcvbuf = CONN_OVERLOAD_LIMIT;
The last time Jon and I discussed this, I thought the consensus was to export
sk_rcvbuf via its own sysctl, or tie it to sysctl_rmem (while requiring a
protocol specific minimum on top of that), so administrators on memory
constrained systems didn't wonder why their sysctl changes weren't being
honored.

>  	sk->sk_data_ready = tipc_data_ready;
>  	sk->sk_write_space = tipc_write_space;
>  	tipc_sk(sk)->p = tp_ptr;
> @@ -1233,10 +1234,10 @@ static u32 filter_connect(struct tipc_sock *tsock, struct sk_buff **buf)
>   * For all connectionless messages, by default new queue limits are
>   * as belows:
>   *
> - * TIPC_LOW_IMPORTANCE       (5MB)
> - * TIPC_MEDIUM_IMPORTANCE    (10MB)
> - * TIPC_HIGH_IMPORTANCE      (20MB)
> - * TIPC_CRITICAL_IMPORTANCE  (40MB)
> + * TIPC_LOW_IMPORTANCE       (4 MB)
> + * TIPC_MEDIUM_IMPORTANCE    (8 MB)
> + * TIPC_HIGH_IMPORTANCE      (16 MB)
> + * TIPC_CRITICAL_IMPORTANCE  (32 MB)
>   *
>   * Returns overload limit according to corresponding message importance
>   */
> @@ -1248,7 +1249,7 @@ static unsigned int rcvbuf_limit(struct sock *sk, struct sk_buff *buf)
>  	if (msg_connected(msg))
>  		limit = CONN_OVERLOAD_LIMIT;
>  	else
> -		limit = sk->sk_rcvbuf << (msg_importance(msg) + 5);
> +		limit = sk->sk_rcvbuf >> 4 << msg_importance(msg);
I still don't like this.  I would much prefer that the minimum sk_rcvbuf value
were defaulted to a value such that:
sk->sk_rcvbuf >> 4 << msg_importance(TIPC_CRITICAL_IMPORTANCE) = sk->sk_rcvbuf
i.e. that the minimum sk_rcvbuf size allowed was equal to the size needed to
hold the maximum number of critical messages TIPC required, and have less
important messages be a fraction of that.  that, in conjunction with the above
default setting would allow for administrative tunability, while still giving
you the receive space you need I think.

This is much better than what you have there currently though.

Regards
Neil
>  	return limit;
>  }
>  
> -- 
> 1.8.1.2
> 
> 
