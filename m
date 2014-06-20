From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next] sctp: Add partially support for MSG_MORE to
 SCTP.
Date: Fri, 20 Jun 2014 18:10:45 -0400
Message-ID: <53A4B165.6050504@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1725FB90@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:51877 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966137AbaFTWKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 18:10:49 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725FB90@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/20/2014 12:24 PM, David Laight wrote:
> If MSG_MORE is set then buffer sends as if Nagle were enabled.
> The first data chunk is still sent on its own, but subsequent chunks
> will be bundled and full packets sent.
> Full MSG_MORE support would require a timeout (preferably configurable
> per-socket) to send the last chunk(s), instead of sending them
> when there is nothing outstanding.
> 

Instead of using 1 and 2, can you define them as flags please

Thanks
-vlad

> Signed-off-by: David Laight <david.laight@aculab.com>
> ---
>  net/sctp/output.c |  7 ++++++-
>  net/sctp/socket.c | 14 +++++++++++++-
>  2 files changed, 19 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 0f4d15f..9486229 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -690,8 +690,13 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
>  	 * Inhibit the sending of new chunks when new outgoing data arrives
>  	 * if any previously transmitted data on the connection remains
>  	 * unacknowledged.
> +	 * If nodelay is clear or MSG_MORE is set then perform the Nagle delay.
> +	 * (MSG_MORE from the last sendmsg is saved as 'nodelay & 2'.)
> +	 * This is a partial implementation of MSG_MORE since MSG_MORE should
> +	 * also delay the first packet. However that would need a timeout be
> +	 * added to force the data to be finally sent.
>  	 */
> -	if (!sctp_sk(asoc->base.sk)->nodelay && sctp_packet_empty(packet) &&
> +	if (sctp_sk(asoc->base.sk)->nodelay != 1 && sctp_packet_empty(packet) &&
>  	    inflight && sctp_state(asoc, ESTABLISHED)) {
>  		unsigned int max = transport->pathmtu - packet->overhead;
>  		unsigned int len = chunk->skb->len + q->out_qlen;
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index fee06b9..484c34e 100644
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
> +		sp->nodelay |= 2;
> +	else
> +		sp->nodelay &= ~2;
> +
>  	/* Break the message into multiple chunks of maximum size. */
>  	datamsg = sctp_datamsg_from_user(asoc, sinfo, msg, msg_len);
>  	if (IS_ERR(datamsg)) {
> @@ -5020,7 +5032,7 @@ static int sctp_getsockopt_nodelay(struct sock *sk, int len,
>  		return -EINVAL;
>  
>  	len = sizeof(int);
> -	val = (sctp_sk(sk)->nodelay == 1);
> +	val = sctp_sk(sk)->nodelay & 1;
>  	if (put_user(len, optlen))
>  		return -EFAULT;
>  	if (copy_to_user(optval, &val, len))
> 
