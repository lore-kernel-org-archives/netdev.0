From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next v2 3/3] net: sctp: Add partial support for MSG_MORE
 on SCTP
Date: Fri, 11 Jul 2014 16:11:53 -0400
Message-ID: <53C04509.70304@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1726EEB7@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "'davem@davemloft.net'" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:43967 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755138AbaGKUL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 16:11:56 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1726EEB7@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/09/2014 04:29 AM, David Laight wrote:
> If MSG_MORE is set then buffer sends as if Nagle were enabled.
> The first data chunk is still sent on its own, but subsequent chunks
> will be bundled and full packets sent.
> Full MSG_MORE support would require a timout (preferably configurable
> per-socket) to send the last chunk(s), instead of sending them
> when there is nothing outstanding.
> 
> Signed-off-by: David Laight <david.laight@aculab.com>
> ---
>  include/net/sctp/structs.h |  6 +++++-
>  net/sctp/output.c          | 12 ++++++++++--
>  net/sctp/socket.c          | 18 +++++++++++++++---
>  3 files changed, 30 insertions(+), 6 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 0dfcc92..629346f 100644
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
> +	__u8 tx_delay;
>  	__u8 disable_fragments;
>  	__u8 v4mapped;
>  	__u8 frag_interleave;
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 7f28a8e..df7889c 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -679,14 +679,22 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
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
> +	if (sctp_sk(asoc->base.sk)->tx_delay == SCTP_F_TX_NODELAY)
> +		/* Nagle disabled and MSG_MORE unset */
>  		return SCTP_XMIT_OK;
>  
>  	if (!sctp_packet_empty(packet))
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index fee06b9..4a9f760 100644
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
> +		sp->tx_delay |= SCTP_F_TX_MSG_MORE;
> +	else
> +		sp->tx_delay &= ~SCTP_F_TX_MSG_MORE;
> +

This is ok for 1-1 sockets, but it doesn't really work for 1-many sockets.  If one of
the associations uses MSG_MORE while another does not, we'll see some interesting
side-effects on the wire.

-vlad

>  	/* Break the message into multiple chunks of maximum size. */
>  	datamsg = sctp_datamsg_from_user(asoc, sinfo, msg, msg_len);
>  	if (IS_ERR(datamsg)) {
> @@ -2821,7 +2833,7 @@ static int sctp_setsockopt_nodelay(struct sock *sk, char __user *optval,
>  	if (get_user(val, (int __user *)optval))
>  		return -EFAULT;
>  
> -	sctp_sk(sk)->nodelay = (val == 0) ? 0 : 1;
> +	sctp_sk(sk)->tx_delay = val == 0 ? SCTP_F_TX_NAGLE : SCTP_F_TX_NODELAY;
>  	return 0;
>  }
>  
> @@ -3968,7 +3980,7 @@ static int sctp_init_sock(struct sock *sk)
>  	sp->disable_fragments = 0;
>  
>  	/* Enable Nagle algorithm by default.  */
> -	sp->nodelay           = 0;
> +	sp->tx_delay          = SCTP_F_TX_NAGLE;
>  
>  	/* Enable by default. */
>  	sp->v4mapped          = 1;
> @@ -5020,7 +5032,7 @@ static int sctp_getsockopt_nodelay(struct sock *sk, int len,
>  		return -EINVAL;
>  
>  	len = sizeof(int);
> -	val = (sctp_sk(sk)->nodelay == 1);
> +	val = sctp_sk(sk)->tx_delay & SCTP_F_TX_NAGLE ? 0 : 1;
>  	if (put_user(len, optlen))
>  		return -EFAULT;
>  	if (copy_to_user(optval, &val, len))
> 
