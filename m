From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next v3] tipc: sk_recv_queue size check only for
 connectionless sockets
Date: Mon, 10 Dec 2012 13:22:21 -0500
Message-ID: <20121210182221.GE23628@hmsreliant.think-freely.org>
References: <1355131380-8542-1-git-send-email-ying.xue@windriver.com>
 <50C5B5B5.9060004@ericsson.com>
 <50C60496.5040800@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ying Xue <ying.xue@windriver.com>, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39744 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487Ab2LJSWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 13:22:32 -0500
Content-Disposition: inline
In-Reply-To: <50C60496.5040800@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 10, 2012 at 10:49:42AM -0500, Jon Maloy wrote:
> On 12/10/2012 05:13 AM, Jon Maloy wrote:
> > On 12/10/2012 04:23 AM, Ying Xue wrote:
> >> The sk_receive_queue limit control is currently performed for all
> >> arriving messages, disregarding socket and message type. But for
> >> connectionless sockets this check is redundant, since the protocol
> >> flow already makes queue overflow impossible.
> >>
> >> We move the sk_receive_queue limit control so that it's only performed
> >> for connectionless sockets, i.e. SOCK_RDM and SOCK_DGRAM type sockets.
> >>
> >> However, as Neil Horman specified, we cannot simply force the socket
> >> receive queue limit against connectionless sockets as it may create a
> >> DoS vulnerability. For example, if a sender floods a receiver with
> >> messages containing an invalid set of message importance bits or
> >> CRITICAL importance, we will queue messages indefinitely.
> >>
> >> To avoid DoS attack, socket receive queue will be marked as overflow
> >> if we receive messages with invalid message importances, meanwhile,
> >> we also set one new threshold for CRITICAL importance messages.
> >>
> >> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> >> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> >> Cc: Neil Horman <nhorman@tuxdriver.com>
> >> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> >> ---
> >> v3 changes:
> >>  - set new threshold for CRITICAL message
> >>  - defined an importance factor table to avoid multiplication and
> >>    division operations in rx_queue_full().
> >>  - changed return value of rx_queue_full() from integer to boolean.
> >>
> >>  net/tipc/socket.c |   44 +++++++++++++++++++-------------------------
> >>  1 files changed, 19 insertions(+), 25 deletions(-)
> >>
> >> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> >> index 9b4e483..a18a757 100644
> >> --- a/net/tipc/socket.c
> >> +++ b/net/tipc/socket.c
> >> @@ -43,7 +43,7 @@
> >>  #define SS_LISTENING	-1	/* socket is listening */
> >>  #define SS_READY	-2	/* socket is connectionless */
> >>  
> >> -#define OVERLOAD_LIMIT_BASE	10000
> >> +#define OVERLOAD_LIMIT_BASE	5000
> >>  #define CONN_TIMEOUT_DEFAULT	8000	/* default connect timeout = 8s */
> >>  
> >>  struct tipc_sock {
> >> @@ -73,6 +73,13 @@ static struct proto tipc_proto;
> >>  
> >>  static int sockets_enabled;
> >>  
> >> +static const u32 msg_importance_factor[] = {
> >> +	OVERLOAD_LIMIT_BASE,		/* TIPC_LOW_IMPORTANCE limit */
> >> +	OVERLOAD_LIMIT_BASE * 2,	/* TIPC_MEDIUM_IMPORTANCE limit */
> >> +	OVERLOAD_LIMIT_BASE * 100,	/* TIPC_HIGH_IMPORTANCE limit */
> >> +	OVERLOAD_LIMIT_BASE * 200	/* TIPC_CRITICAL_IMPORTANCE limit */
> >> +	};
> >> +
> >>  /*
> >>   * Revised TIPC socket locking policy:
> >>   *
> >> @@ -1158,28 +1165,17 @@ static void tipc_data_ready(struct sock *sk, int len)
> >>   * rx_queue_full - determine if receive queue can accept another message
> >>   * @msg: message to be added to queue
> >>   * @queue_size: current size of queue
> >> - * @base: nominal maximum size of queue
> >>   *
> >> - * Returns 1 if queue is unable to accept message, 0 otherwise
> >> + * Returns true if queue is unable to accept message, false otherwise
> >>   */
> >> -static int rx_queue_full(struct tipc_msg *msg, u32 queue_size, u32 base)
> >> +static bool rx_queue_full(struct tipc_msg *msg, u32 queue_size)
> >>  {
> >> -	u32 threshold;
> >>  	u32 imp = msg_importance(msg);
> >>  
> >> -	if (imp == TIPC_LOW_IMPORTANCE)
> >> -		threshold = base;
> >> -	else if (imp == TIPC_MEDIUM_IMPORTANCE)
> >> -		threshold = base * 2;
> >> -	else if (imp == TIPC_HIGH_IMPORTANCE)
> >> -		threshold = base * 100;
> >> -	else
> >> -		return 0;
> >> +	if (unlikely(imp > TIPC_CRITICAL_IMPORTANCE))
> >> +		return true;
> > 
> > This test is not necessary. Such messages have already been filtered out
> > in tipc_recv_msg() at link level.
> > The test msg_isdata(), which determines if a message should be sent up to
> > the port/socket level, is  also an implicit test that 
> > importance < TIPC_CRITICAL_IMPORTANCE.
> 
> (importance <= TIPC_CRITICAL_IMPORTANCE), of course.
> This is an effect of the co-location of the user and importance fields in the
> TIPC header. I.e., the importance is in reality coded into the value of
> the user field.
> 
> To clarify (and improve) my previous suggestion, what I had in mind
> was something like this:
> 
> 
>                 recv_q_len = skb_queue_len(&sk->sk_receive_queue);
> -               if (unlikely(recv_q_len >= (OVERLOAD_LIMIT_BASE / 2))) {
> -                       if (rx_queue_full(msg, recv_q_len,
> -                           OVERLOAD_LIMIT_BASE / 2))
> -                               return TIPC_ERR_OVERLOAD;
> -               }
> +               imp = msg_importance(msg);
> +               if (unlikely(recv_q_len > (OVERLOAD_LIMIT_BASE << (imp << 1))))
> +                       return TIPC_ERR_OVERLOAD;                 
>         } else {
>                 if (msg_mcast(msg))
>                         return TIPC_ERR_NO_PORT;
> 
> No need for any separate function at all, and guaranteed inline.
> This will probably translate to one single shift-instruction extra,
> and no memor access, since the compiler merge (imp << 1) with the 
> shift operation used to read imp from the header.
> 
> 
> The limits for message rejection become the following,
> given an OVERLOAD_LIMIT_BASE of 10000:
> 
> TIP_LOW_IMPORTANCE:       10000    (previously 10000)
> TIPC_MEDIUM_IMPORTANCE    40000    (previously 20000)
> TIPC_MEDIUM_IMPORTANCE    1600000  (previously 1000000)
> TIPC_CRITICAL_IMPORTANCE  25600000 (previously no limit)
> 
> ///jon
> 
Sure, this will work nicely as well.
Neil
