From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: Restore 'resent' bit to avoid retransmitted chunks
 for RTT measurements
Date: Fri, 22 Nov 2013 09:18:09 -0500
Message-ID: <528F67A1.60306@gmail.com>
References: <1385109031-4246-1-git-send-email-xufeng.zhang@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Xufeng Zhang <xufeng.zhang@windriver.com>, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:62539 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755618Ab3KVOSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 09:18:13 -0500
In-Reply-To: <1385109031-4246-1-git-send-email-xufeng.zhang@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2013 03:30 AM, Xufeng Zhang wrote:
> From: Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
> 
> Currently retransmitted DATA chunks could also be used for
> RTT measurements since there are no flag to identify whether
> the transmitted DATA chunk is a new one or a retransmitted one.
> This problem is introduced by commit ae19c5486 ("sctp: remove
> 'resent' bit from the chunk") which inappropriately removed the
> 'resent' bit completely, instead of doing this, we should set 
> the resent bit only for the retransmitted DATA chunks.
> 
> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
> ---
>  include/net/sctp/structs.h |    1 +
>  net/sctp/output.c          |   23 +++++++++++++----------
>  net/sctp/outqueue.c        |    3 +++
>  net/sctp/sm_make_chunk.c   |    1 +
>  4 files changed, 18 insertions(+), 10 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 2174d8d..ea0ca5f 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -629,6 +629,7 @@ struct sctp_chunk {
>  #define SCTP_NEED_FRTX 0x1
>  #define SCTP_DONT_FRTX 0x2
>  	__u16	rtt_in_progress:1,	/* This chunk used for RTT calc? */
> +		resent:1,		/* Has this chunk ever been resent. */
>  		has_tsn:1,		/* Does this chunk have a TSN yet? */
>  		has_ssn:1,		/* Does this chunk have a SSN yet? */
>  		singleton:1,		/* Only chunk in the packet? */
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index e650978..32c214d 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -467,17 +467,20 @@ int sctp_packet_transmit(struct sctp_packet *packet)
>  	list_for_each_entry_safe(chunk, tmp, &packet->chunk_list, list) {
>  		list_del_init(&chunk->list);
>  		if (sctp_chunk_is_data(chunk)) {
> -			/* 6.3.1 C4) When data is in flight and when allowed
> -			 * by rule C5, a new RTT measurement MUST be made each
> -			 * round trip.  Furthermore, new RTT measurements
> -			 * SHOULD be made no more than once per round-trip
> -			 * for a given destination transport address.
> -			 */
> -
> -			if (!tp->rto_pending) {
> -				chunk->rtt_in_progress = 1;
> -				tp->rto_pending = 1;
> +			if (!chunk->resent) {
> +				/* 6.3.1 C4) When data is in flight and when allowed
> +				 * by rule C5, a new RTT measurement MUST be made each
> +				 * round trip.  Furthermore, new RTT measurements
> +				 * SHOULD be made no more than once per round-trip
> +				 * for a given destination transport address.
> +				 */
> +
> +				if (!tp->rto_pending) {

Could be combined as
    if (!chunk->resent && !tp->rto_pending) {

> +					chunk->rtt_in_progress = 1;
> +					tp->rto_pending = 1;
> +				}
>  			}
> +
>  			has_data = 1;
>  		}
>  
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 94df758..70f4f56 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -446,6 +446,8 @@ void sctp_retransmit_mark(struct sctp_outq *q,
>  				transport->rto_pending = 0;
>  			}
>  
> +			chunk->resent = 1;
> +
>  			/* Move the chunk to the retransmit queue. The chunks
>  			 * on the retransmit queue are always kept in order.
>  			 */
> @@ -1375,6 +1377,7 @@ static void sctp_check_transmitted(struct sctp_outq *q,
>  				 * instance).
>  				 */
>  				if (!tchunk->tsn_gap_acked &&
> +				    !tchunk->resent &&
>  				    tchunk->rtt_in_progress) {
>  					tchunk->rtt_in_progress = 0;
>  					rtt = jiffies - tchunk->sent_at;
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index fe69032..8fe89f8 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -1321,6 +1321,7 @@ struct sctp_chunk *sctp_chunkify(struct sk_buff *skb,
>  	INIT_LIST_HEAD(&retval->list);
>  	retval->skb		= skb;
>  	retval->asoc		= (struct sctp_association *)asoc;
> +	retval->resent          = 0;

Not needed due to zeroed out malloc.

-vlad

>  	retval->singleton	= 1;
>  
>  	retval->fast_retransmit = SCTP_CAN_FRTX;
> 
