From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next] sctp: reuse sent_count to avoid retransmitted
 chunks for RTT measurements
Date: Mon, 10 Oct 2016 14:48:25 -0300
Message-ID: <20161010174825.GC2958@localhost.localdomain>
References: <b68194a4735a1ea5a652c13540df5d68e3c4b305.1475897765.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
        davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48080 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752316AbcJJRsa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Oct 2016 13:48:30 -0400
Content-Disposition: inline
In-Reply-To: <b68194a4735a1ea5a652c13540df5d68e3c4b305.1475897765.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 08, 2016 at 11:36:05AM +0800, Xin Long wrote:
> Now sctp uses chunk->resent to record if a chunk is retransmitted, for
> RTT measurements with retransmitted DATA chunks. chunk->sent_count was
> introduced to record how many times one chunk has been sent for prsctp
> RTX policy before. We actually can know if one chunk is retransmitted
> by checking chunk->sent_count is greater than 1.
> 
> This patch is to remove resent from sctp_chunk and reuse sent_count
> to avoid retransmitted chunks for RTT measurements.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  include/net/sctp/structs.h | 2 +-
>  net/sctp/output.c          | 3 ++-
>  net/sctp/outqueue.c        | 4 +---
>  3 files changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 11c3bf2..27a933e 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -641,7 +641,6 @@ struct sctp_chunk {
>  #define SCTP_NEED_FRTX 0x1
>  #define SCTP_DONT_FRTX 0x2
>  	__u16	rtt_in_progress:1,	/* This chunk used for RTT calc? */
> -		resent:1,		/* Has this chunk ever been resent. */
>  		has_tsn:1,		/* Does this chunk have a TSN yet? */
>  		has_ssn:1,		/* Does this chunk have a SSN yet? */
>  		singleton:1,		/* Only chunk in the packet? */
> @@ -656,6 +655,7 @@ struct sctp_chunk {
>  		fast_retransmit:2;	/* Is this chunk fast retransmitted? */
>  };
>  
> +#define sctp_chunk_retransmitted(chunk)	(chunk->sent_count > 1)
>  void sctp_chunk_hold(struct sctp_chunk *);
>  void sctp_chunk_put(struct sctp_chunk *);
>  int sctp_user_addto_chunk(struct sctp_chunk *chunk, int len,
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 2a5c189..84f66d5 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -552,7 +552,8 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  				 * for a given destination transport address.
>  				 */
>  
> -				if (!chunk->resent && !tp->rto_pending) {
> +				if (!sctp_chunk_retransmitted(chunk) &&
> +				    !tp->rto_pending) {
>  					chunk->rtt_in_progress = 1;
>  					tp->rto_pending = 1;
>  				}
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 5825853..e540826 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -507,8 +507,6 @@ void sctp_retransmit_mark(struct sctp_outq *q,
>  				transport->rto_pending = 0;
>  			}
>  
> -			chunk->resent = 1;
> -
>  			/* Move the chunk to the retransmit queue. The chunks
>  			 * on the retransmit queue are always kept in order.
>  			 */
> @@ -1439,7 +1437,7 @@ static void sctp_check_transmitted(struct sctp_outq *q,
>  				 * instance).
>  				 */
>  				if (!tchunk->tsn_gap_acked &&
> -				    !tchunk->resent &&
> +				    !sctp_chunk_retransmitted(tchunk) &&
>  				    tchunk->rtt_in_progress) {
>  					tchunk->rtt_in_progress = 0;
>  					rtt = jiffies - tchunk->sent_at;
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
