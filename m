From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next v3 3/3] net: sctp: Add support for MSG_MORE on
 SCTP
Date: Tue, 22 Jul 2014 09:23:01 -0400
Message-ID: <53CE65B5.3090903@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1727AF02@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:41411 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755821AbaGVNXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 09:23:04 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1727AF02@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2014 04:59 AM, David Laight wrote:
> If MSG_MORE is set then the data chunk will be buffered until either
> a full packet would be generated, or something causes a chunk to be
> sent (eg data without MSG_MORE or a heartbeat).

heartbeat will not cause a data flush.  Only SACKs do that as they control
congestion and flow.

That's might actually be a good solution to the problem of the an incorrectly
using MSG_MORE.  When a SACK drops inflight to 0, clear MSG_MORE from the
association thus allowing any queued data (even less then MTU) to be flushed.

This way, when the data flow just starts, you can use MSG_MORE to control
bundling.  However, the app stops sending, even if it forgot to clear MSG_MORE,
we'll clear it ourselves once inflight drops to 0.

> 
> The MSG_MORE flag is saved 'per association' along with a copy
> of the SCTP_NODELAY/Nagle flag.
> 
> It is expected that an application will only set MSG_MORE when it
> has an additional data chunk ready to send. The sends could be done
> with a single sendmmsg() system call.

Is that really true?  If the application has 5 messages and it sends all
5 with the sendmmsg(), then MSG_MORE will never get cleared and a flush
would not get triggered.


> 
> Signed-off-by: David Laight <david.laight@aculab.com>
> ---
> 
> Resend with corrected subject line.
> 
> Changes from v2:
> - MSG_MORE is now saved per association (not per socket)
> - The first data chunk is also not sent
> 
>  include/net/sctp/structs.h |  9 ++++++++-
>  net/sctp/endpointola.c     |  3 +++
>  net/sctp/output.c          | 16 ++++++++++++----
>  net/sctp/socket.c          | 24 +++++++++++++++++++++---
>  4 files changed, 44 insertions(+), 8 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 0dfcc92..441320a 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -209,7 +209,11 @@ struct sctp_sock {
>  	struct sctp_assocparams assocparams;
>  	int user_frag;
>  	__u32 autoclose;
> -	__u8 nodelay;
> +
> +#define	SCTP_F_TX_NODELAY	0
> +#define	SCTP_F_TX_NAGLE		1	/* SCTP_NODELAY not set */
> +#define	SCTP_F_TX_MSG_MORE	2	/* MSG_MORE set on last send */

Why SCTP_F_TX and not just SCTP_TX_?  What does the _F stand for?

> +	__u8 tx_delay;
>  	__u8 disable_fragments;
>  	__u8 v4mapped;
>  	__u8 frag_interleave;
> @@ -1581,6 +1585,9 @@ struct sctp_association {
>  	/* Flag that path mtu update is pending */
>  	__u8   pmtu_pending;
>  
> +	/* SCTP_F_TX_xxx, Nagle copied from socket */
> +	__u8 tx_delay;
> +
>  	/* Association : The smallest PMTU discovered for all of the
>  	 * PMTU	       : peer's transport addresses.
>  	 */
> diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
> index 3d9f429..077220f 100644
> --- a/net/sctp/endpointola.c
> +++ b/net/sctp/endpointola.c
> @@ -221,6 +221,9 @@ void sctp_endpoint_add_asoc(struct sctp_endpoint *ep,
>  	/* Increment the backlog value for a TCP-style listening socket. */
>  	if (sctp_style(sk, TCP) && sctp_sstate(sk, LISTENING))
>  		sk->sk_ack_backlog++;
> +
> +	/* Cache SCTP_NODELAY (aka Nagle) state */
> +	asoc->tx_delay = sctp_sk(sk)->tx_delay;

state inheritance like this is usually done in sctp_assocociation_init().

>  }
>  
>  /* Free the endpoint structure.  Delay cleanup until
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 7f28a8e..275a1ab 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -679,22 +679,30 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
>  	    flight_size >= transport->cwnd)
>  		return SCTP_XMIT_RWND_FULL;
>  
> +	/* If MSG_MORE is set we probably shouldn't create a new message.
> +	 * However unless we also implement a timeout (preferable settable
> +	 * as a socket option) then data could easily be left unsent.
> +	 * Instead we ignore MSG_MORE on the first data chunk.
> +	 * This makes the implementation of MSG_MORE the same as the
> +	 * implementation of Nagle.
> +	 */
> +
>  	/* Nagle's algorithm to solve small-packet problem:
>  	 * Inhibit the sending of new chunks when new outgoing data arrives
>  	 * if any previously transmitted data on the connection remains
>  	 * unacknowledged.
>  	 */
>  
> -	if (sctp_sk(asoc->base.sk)->nodelay)
> -		/* Nagle disabled */
> +	if (asoc->tx_delay == SCTP_F_TX_NODELAY)
> +		/* Nagle disabled and MSG_MORE unset */
>  		return SCTP_XMIT_OK;
>  
>  	if (!sctp_packet_empty(packet))
>  		/* Append to packet */
>  		return SCTP_XMIT_OK;
>  
> -	if (inflight == 0)
> -		/* Nothing unacked */
> +	if (inflight == 0 && !(asoc->tx_delay & SCTP_F_TX_MSG_MORE))
> +		/* Nothing unacked and application isn't going to send more */
>  		return SCTP_XMIT_OK;
>  	
>  	if (!sctp_state(asoc, ESTABLISHED))
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index fee06b9..73a421d 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -1927,6 +1927,18 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
>  		pr_debug("%s: we associated primitively\n", __func__);
>  	}
>  
> +	/* Setting MSG_MORE currently has the same effect as enabling Nagle.
> +	 * This means that the user can't force bundling of the first two data
> +	 * chunks.  It does mean that all the data chunks will be sent
> +	 * without an extra timer.
> +	 * It is enough to save the last value since any data sent with
> +	 * MSG_MORE clear will already have been sent (subject to flow control).
> +	 */
> +	if (msg->msg_flags & MSG_MORE)
> +		asoc->tx_delay |= SCTP_F_TX_MSG_MORE;
> +	else
> +		asoc->tx_delay &= ~SCTP_F_TX_MSG_MORE;
> +
>  	/* Break the message into multiple chunks of maximum size. */
>  	datamsg = sctp_datamsg_from_user(asoc, sinfo, msg, msg_len);
>  	if (IS_ERR(datamsg)) {
> @@ -2814,6 +2826,7 @@ static int sctp_setsockopt_primary_addr(struct sock *sk, char __user *optval,
>  static int sctp_setsockopt_nodelay(struct sock *sk, char __user *optval,
>  				   unsigned int optlen)
>  {
> +	struct sctp_association *asoc;
>  	int val;
>  
>  	if (optlen < sizeof(int))
> @@ -2821,7 +2834,12 @@ static int sctp_setsockopt_nodelay(struct sock *sk, char __user *optval,
>  	if (get_user(val, (int __user *)optval))
>  		return -EFAULT;
>  
> -	sctp_sk(sk)->nodelay = (val == 0) ? 0 : 1;
> +	val = val == 0 ? SCTP_F_TX_NAGLE : SCTP_F_TX_NODELAY;
> +	sctp_sk(sk)->tx_delay = val;
> +
> +	/* Update cached value on each asoc (clears SCTP_F_TX_MSG_MORE) */
> +	list_for_each_entry(asoc, &sctp_sk(sk)->ep->asocs, asocs)
> +		asoc->tx_delay = val;
>  	return 0;
>  }
>  
> @@ -3968,7 +3986,7 @@ static int sctp_init_sock(struct sock *sk)
>  	sp->disable_fragments = 0;
>  
>  	/* Enable Nagle algorithm by default.  */
> -	sp->nodelay           = 0;
> +	sp->tx_delay          = SCTP_F_TX_NAGLE;
>  
>  	/* Enable by default. */
>  	sp->v4mapped          = 1;
> @@ -5020,7 +5038,7 @@ static int sctp_getsockopt_nodelay(struct sock *sk, int len,
>  		return -EINVAL;
>  
>  	len = sizeof(int);
> -	val = (sctp_sk(sk)->nodelay == 1);
> +	val = sctp_sk(sk)->tx_delay & SCTP_F_TX_NAGLE ? 0 : 1;
>  	if (put_user(len, optlen))
>  		return -EFAULT;
>  	if (copy_to_user(optval, &val, len))
> 
