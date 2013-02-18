From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 2/3] tipc: byte-based overload control on socket
 receive queue
Date: Mon, 18 Feb 2013 09:47:57 -0500
Message-ID: <20130218144757.GA26199@hmsreliant.think-freely.org>
References: <1360969067-29956-1-git-send-email-paul.gortmaker@windriver.com>
 <1360969067-29956-3-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39712 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853Ab3BROsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 09:48:14 -0500
Content-Disposition: inline
In-Reply-To: <1360969067-29956-3-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 15, 2013 at 05:57:46PM -0500, Paul Gortmaker wrote:
> From: Ying Xue <ying.xue@windriver.com>
> 
> Change overload control to be purely byte-based, using
> sk->sk_rmem_alloc as byte counter, and compare it to a calculated
> upper limit for the socket receive queue.
> 
> For all connection messages, irrespective of message importance,
> the overload limit is set to a constant value (i.e, 67MB). This
> limit should normally never be reached because of the lower
> limit used by the flow control algorithm, and is there only
> as a last resort in case a faulty peer doesn't respect the send
> window limit.
> 
> For datagram messages, message importance is taken into account
> when calculating the overload limit. The calculation is based
> on sk->sk_rcvbuf, and is hence configurable via the socket option
> SO_RCVBUF.
> 
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

This looks alot better, thank you.  I still have a few questions though.  See
inline.

> ---
>  net/tipc/socket.c | 77 ++++++++++++++++++++++++++++---------------------------
>  1 file changed, 39 insertions(+), 38 deletions(-)
> 
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> index f6ceecd..cbe2f6e 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -43,7 +43,8 @@
>  #define SS_LISTENING	-1	/* socket is listening */
>  #define SS_READY	-2	/* socket is connectionless */
>  
> -#define OVERLOAD_LIMIT_BASE	10000
> +#define CONN_OVERLOAD_LIMIT	((TIPC_FLOW_CONTROL_WIN * 2 + 1) * \
> +				SKB_TRUESIZE(TIPC_MAX_USER_MSG_SIZE))
>  #define CONN_TIMEOUT_DEFAULT	8000	/* default connect timeout = 8s */
>  
>  struct tipc_sock {
> @@ -202,7 +203,6 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol,
>  
>  	sock_init_data(sock, sk);
>  	sk->sk_backlog_rcv = backlog_rcv;
> -	sk->sk_rcvbuf = TIPC_FLOW_CONTROL_WIN * 2 * TIPC_MAX_USER_MSG_SIZE * 2;
>  	sk->sk_data_ready = tipc_data_ready;
>  	sk->sk_write_space = tipc_write_space;
>  	tipc_sk(sk)->p = tp_ptr;
> @@ -1142,34 +1142,6 @@ static void tipc_data_ready(struct sock *sk, int len)
>  }
>  
>  /**
> - * rx_queue_full - determine if receive queue can accept another message
> - * @msg: message to be added to queue
> - * @queue_size: current size of queue
> - * @base: nominal maximum size of queue
> - *
> - * Returns 1 if queue is unable to accept message, 0 otherwise
> - */
> -static int rx_queue_full(struct tipc_msg *msg, u32 queue_size, u32 base)
> -{
> -	u32 threshold;
> -	u32 imp = msg_importance(msg);
> -
> -	if (imp == TIPC_LOW_IMPORTANCE)
> -		threshold = base;
> -	else if (imp == TIPC_MEDIUM_IMPORTANCE)
> -		threshold = base * 2;
> -	else if (imp == TIPC_HIGH_IMPORTANCE)
> -		threshold = base * 100;
> -	else
> -		return 0;
> -
> -	if (msg_connected(msg))
> -		threshold *= 4;
> -
> -	return queue_size >= threshold;
> -}
> -
> -/**
>   * filter_connect - Handle all incoming messages for a connection-based socket
>   * @tsock: TIPC socket
>   * @msg: message
> @@ -1247,6 +1219,36 @@ static u32 filter_connect(struct tipc_sock *tsock, struct sk_buff **buf)
>  }
>  
>  /**
> + * rcvbuf_limit - get proper overload limit of socket receive queue
> + * @sk: socket
> + * @buf: message
> + *
> + * For all connection oriented messages, irrespective of importance,
> + * the default overload value (i.e. 67MB) is set as limit.
> + *
> + * For all connectionless messages, by default new queue limits are
> + * as belows:
> + *
> + * TIPC_LOW_IMPORTANCE       (5MB)
> + * TIPC_MEDIUM_IMPORTANCE    (10MB)
> + * TIPC_HIGH_IMPORTANCE      (20MB)
> + * TIPC_CRITICAL_IMPORTANCE  (40MB)
> + *
> + * Returns overload limit according to corresponding message importance
> + */
> +static unsigned int rcvbuf_limit(struct sock *sk, struct sk_buff *buf)
> +{
> +	struct tipc_msg *msg = buf_msg(buf);
> +	unsigned int limit;
> +
> +	if (msg_connected(msg))
> +		limit = CONN_OVERLOAD_LIMIT;
This still strikes me as a bit wierd.  If you really can't tolerate the default
rmem settings in proc, have you considered separating the rmem and wmem values
out into their own sysctls?  Decnet is an example of a protocol that does this
IIRC.  If you did that, then you wouldn't be mysteriously violating the
sk_rcvbuf value that gets set on all new sockets (and you could make this
legitimately tunable).

> +	else
> +		limit = sk->sk_rcvbuf << (msg_importance(msg) + 5);
Same here.  You're using sk_rcvbuf as a base value, rather than a maximum value.
It seems to me, sk_rcvbuf should be the maximum backlog at which you will store
incomming messages.  You can discard lower importance messages at fractions of
sk_rcvbuf if you need to.  If you create separate rmem and wmem sysctls you can
still make the queue limits you document above work, and you won't violate the
receive buffer value set in the socket.

You might also consider looking into adding support for memory accounting, so
that you can play a little more fast and loose with memory limits on an
individual socket when the system as a whole isn't under pressure (tcp and sctp
aer good examples of this).

Neil
