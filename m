From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2 net-next 1/3] net: sctp: Open out the check for Nagle
Date: Fri, 11 Jul 2014 16:01:04 -0400
Message-ID: <53C04280.8020809@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1726EEB9@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "'davem@davemloft.net'" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:61072 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbaGKUBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 16:01:08 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1726EEB9@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/09/2014 04:29 AM, David Laight wrote:
> The check for Nagle contains 6 separate checks all of which must be true
> before a data packet is delayed.
> Separate out each into its own 'if (test) return SCTP_XMIT_OK' so that
> the reasons can be individually described.
> 
> Also return directly with SCTP_XMIT_RWND_FULL.
> Delete the now-unused 'retval' variable and 'finish' label from
> sctp_packet_can_append_data().
> 
> Signed-off-by: David Laight <david.laight@aculab.com>
> ---
>  net/sctp/output.c | 69 +++++++++++++++++++++++++++++--------------------------
>  1 file changed, 36 insertions(+), 33 deletions(-)
> 
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 0f4d15f..553ba1d 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -633,7 +633,6 @@ nomem:
>  static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
>  					   struct sctp_chunk *chunk)
>  {
> -	sctp_xmit_t retval = SCTP_XMIT_OK;
>  	size_t datasize, rwnd, inflight, flight_size;
>  	struct sctp_transport *transport = packet->transport;
>  	struct sctp_association *asoc = transport->asoc;
> @@ -658,15 +657,11 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
>  
>  	datasize = sctp_data_size(chunk);
>  
> -	if (datasize > rwnd) {
> -		if (inflight > 0) {
> -			/* We have (at least) one data chunk in flight,
> -			 * so we can't fall back to rule 6.1 B).
> -			 */
> -			retval = SCTP_XMIT_RWND_FULL;
> -			goto finish;
> -		}
> -	}
> +	if (datasize > rwnd && inflight > 0)
> +		/* We have (at least) one data chunk in flight,
> +		 * so we can't fall back to rule 6.1 B).
> +		 */
> +		return SCTP_XMIT_RWND_FULL;
>  
>  	/* RFC 2960 6.1  Transmission of DATA Chunks
>  	 *
> @@ -680,36 +675,44 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
>  	 *    When a Fast Retransmit is being performed the sender SHOULD
>  	 *    ignore the value of cwnd and SHOULD NOT delay retransmission.
>  	 */
> -	if (chunk->fast_retransmit != SCTP_NEED_FRTX)
> -		if (flight_size >= transport->cwnd) {
> -			retval = SCTP_XMIT_RWND_FULL;
> -			goto finish;
> -		}
> +	if (chunk->fast_retransmit != SCTP_NEED_FRTX &&
> +	    flight_size >= transport->cwnd)
> +		return SCTP_XMIT_RWND_FULL;
>  
>  	/* Nagle's algorithm to solve small-packet problem:
>  	 * Inhibit the sending of new chunks when new outgoing data arrives
>  	 * if any previously transmitted data on the connection remains
>  	 * unacknowledged.
>  	 */
> -	if (!sctp_sk(asoc->base.sk)->nodelay && sctp_packet_empty(packet) &&
> -	    inflight && sctp_state(asoc, ESTABLISHED)) {
> -		unsigned int max = transport->pathmtu - packet->overhead;
> -		unsigned int len = chunk->skb->len + q->out_qlen;
> -
> -		/* Check whether this chunk and all the rest of pending
> -		 * data will fit or delay in hopes of bundling a full
> -		 * sized packet.
> -		 * Don't delay large message writes that may have been
> -		 * fragmeneted into small peices.
> -		 */
> -		if ((len < max) && chunk->msg->can_delay) {
> -			retval = SCTP_XMIT_NAGLE_DELAY;
> -			goto finish;
> -		}
> -	}
>  
> -finish:
> -	return retval;
> +	if (sctp_sk(asoc->base.sk)->nodelay)
> +		/* Nagle disabled */
> +		return SCTP_XMIT_OK;
> +
> +	if (!sctp_packet_empty(packet))
> +		/* Append to packet */
> +		return SCTP_XMIT_OK;
> +
> +	if (inflight != 0)
> +		/* Nothing unacked */
> +		return SCTP_XMIT_OK;

This doesn't look right.  First, the comment doesn't match the condition.
Second, when we have stuff in-flight we might be affected be Nagle.  Thus,
I think the condition should be:
       if (!inflight)

Then the commend and logic holds.

-vlad

> +	
> +	if (!sctp_state(asoc, ESTABLISHED))
> +		return SCTP_XMIT_OK;
> +
> +	/* Check whether this chunk and all the rest of pending data will fit
> +	 * or delay in hopes of bundling a full sized packet.
> +	 */
> +	if (chunk->skb->len + q->out_qlen >= transport->pathmtu - packet->overhead)
> +		/* Enough data queued to fill a packet */
> +		return SCTP_XMIT_OK;
> +
> +	/* Don't delay large message writes that may have been fragmented */
> +	if (!chunk->msg->can_delay)
> +		return SCTP_XMIT_OK;
> +
> +	/* Defer until all data acked or packet full */
> +	return SCTP_XMIT_NAGLE_DELAY;
>  }
>  
>  /* This private function does management things when adding DATA chunk */
> 
