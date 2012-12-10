From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH net-next v3] tipc: sk_recv_queue size
 check only for connectionless sockets
Date: Mon, 10 Dec 2012 05:13:09 -0500
Message-ID: <50C5B5B5.9060004@ericsson.com>
References: <1355131380-8542-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net,
	nhorman@tuxdriver.com, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1355131380-8542-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 12/10/2012 04:23 AM, Ying Xue wrote:
> The sk_receive_queue limit control is currently performed for all
> arriving messages, disregarding socket and message type. But for
> connectionless sockets this check is redundant, since the protocol
> flow already makes queue overflow impossible.
> 
> We move the sk_receive_queue limit control so that it's only performed
> for connectionless sockets, i.e. SOCK_RDM and SOCK_DGRAM type sockets.
> 
> However, as Neil Horman specified, we cannot simply force the socket
> receive queue limit against connectionless sockets as it may create a
> DoS vulnerability. For example, if a sender floods a receiver with
> messages containing an invalid set of message importance bits or
> CRITICAL importance, we will queue messages indefinitely.
> 
> To avoid DoS attack, socket receive queue will be marked as overflow
> if we receive messages with invalid message importances, meanwhile,
> we also set one new threshold for CRITICAL importance messages.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
> v3 changes:
>  - set new threshold for CRITICAL message
>  - defined an importance factor table to avoid multiplication and
>    division operations in rx_queue_full().
>  - changed return value of rx_queue_full() from integer to boolean.
> 
>  net/tipc/socket.c |   44 +++++++++++++++++++-------------------------
>  1 files changed, 19 insertions(+), 25 deletions(-)
> 
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> index 9b4e483..a18a757 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -43,7 +43,7 @@
>  #define SS_LISTENING	-1	/* socket is listening */
>  #define SS_READY	-2	/* socket is connectionless */
>  
> -#define OVERLOAD_LIMIT_BASE	10000
> +#define OVERLOAD_LIMIT_BASE	5000
>  #define CONN_TIMEOUT_DEFAULT	8000	/* default connect timeout = 8s */
>  
>  struct tipc_sock {
> @@ -73,6 +73,13 @@ static struct proto tipc_proto;
>  
>  static int sockets_enabled;
>  
> +static const u32 msg_importance_factor[] = {
> +	OVERLOAD_LIMIT_BASE,		/* TIPC_LOW_IMPORTANCE limit */
> +	OVERLOAD_LIMIT_BASE * 2,	/* TIPC_MEDIUM_IMPORTANCE limit */
> +	OVERLOAD_LIMIT_BASE * 100,	/* TIPC_HIGH_IMPORTANCE limit */
> +	OVERLOAD_LIMIT_BASE * 200	/* TIPC_CRITICAL_IMPORTANCE limit */
> +	};
> +
>  /*
>   * Revised TIPC socket locking policy:
>   *
> @@ -1158,28 +1165,17 @@ static void tipc_data_ready(struct sock *sk, int len)
>   * rx_queue_full - determine if receive queue can accept another message
>   * @msg: message to be added to queue
>   * @queue_size: current size of queue
> - * @base: nominal maximum size of queue
>   *
> - * Returns 1 if queue is unable to accept message, 0 otherwise
> + * Returns true if queue is unable to accept message, false otherwise
>   */
> -static int rx_queue_full(struct tipc_msg *msg, u32 queue_size, u32 base)
> +static bool rx_queue_full(struct tipc_msg *msg, u32 queue_size)
>  {
> -	u32 threshold;
>  	u32 imp = msg_importance(msg);
>  
> -	if (imp == TIPC_LOW_IMPORTANCE)
> -		threshold = base;
> -	else if (imp == TIPC_MEDIUM_IMPORTANCE)
> -		threshold = base * 2;
> -	else if (imp == TIPC_HIGH_IMPORTANCE)
> -		threshold = base * 100;
> -	else
> -		return 0;
> +	if (unlikely(imp > TIPC_CRITICAL_IMPORTANCE))
> +		return true;

This test is not necessary. Such messages have already been filtered out
in tipc_recv_msg() at link level.
The test msg_isdata(), which determines if a message should be sent up to
the port/socket level, is  also an implicit test that 
importance < TIPC_CRITICAL_IMPORTANCE.


>  
> -	if (msg_connected(msg))
> -		threshold *= 4;
> -
> -	return queue_size >= threshold;
> +	return queue_size >= msg_importance_factor[imp];

Ok. Less optimal than my suggestion, but also lower risk until we know
the consequences of changing the multiplication factors.

>  }
>  
>  /**
> @@ -1275,7 +1271,6 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
>  {
>  	struct socket *sock = sk->sk_socket;
>  	struct tipc_msg *msg = buf_msg(buf);
> -	u32 recv_q_len;
>  	u32 res = TIPC_OK;
>  
>  	/* Reject message if it is wrong sort of message for socket */
> @@ -1285,19 +1280,18 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
>  	if (sock->state == SS_READY) {
>  		if (msg_connected(msg))
>  			return TIPC_ERR_NO_PORT;
> +		/* Reject SOCK_DGRAM and SOCK_RDM message if there isn't room
> +		 * to queue it
> +		 */
> +		if (unlikely(rx_queue_full(msg,
> +			     skb_queue_len(&sk->sk_receive_queue))))
> +			return TIPC_ERR_OVERLOAD;
>  	} else {
>  		res = filter_connect(tipc_sk(sk), &buf);
>  		if (res != TIPC_OK || buf == NULL)
>  			return res;
>  	}
>  
> -	/* Reject message if there isn't room to queue it */
> -	recv_q_len = skb_queue_len(&sk->sk_receive_queue);
> -	if (unlikely(recv_q_len >= (OVERLOAD_LIMIT_BASE / 2))) {
> -		if (rx_queue_full(msg, recv_q_len, OVERLOAD_LIMIT_BASE / 2))
> -			return TIPC_ERR_OVERLOAD;
> -	}
> -
>  	/* Enqueue message (finally!) */
>  	TIPC_SKB_CB(buf)->handle = 0;
>  	__skb_queue_tail(&sk->sk_receive_queue, buf);
> 


------------------------------------------------------------------------------
LogMeIn Rescue: Anywhere, Anytime Remote support for IT. Free Trial
Remotely access PCs and mobile devices and provide instant support
Improve your efficiency, and focus on delivering more value-add services
Discover what IT Professionals Know. Rescue delivers
http://p.sf.net/sfu/logmein_12329d2d
