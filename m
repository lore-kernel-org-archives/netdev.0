From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net 1/6] sctp: remove the unnecessary state check in
 sctp_outq_tail
Date: Thu, 8 Sep 2016 10:27:01 -0400
Message-ID: <20160908142701.GC16608@hmsreliant.think-freely.org>
References: <cover.1473326067.git.lucien.xin@gmail.com>
 <1718155e984f63995d1be9b053c58aa1a645718e.1473326067.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52134 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758560AbcIHO1V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 10:27:21 -0400
Content-Disposition: inline
In-Reply-To: <1718155e984f63995d1be9b053c58aa1a645718e.1473326067.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 08, 2016 at 05:31:45PM +0800, Xin Long wrote:
> Data Chunks are only sent by sctp_primitive_SEND, in which sctp checks
> the asoc's state through statetable before calling sctp_outq_tail. So
> there's no need to do it again in sctp_outq_tail.
> 
> This patch is to remove it from sctp_outq_tail.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
This doesn't seem safe to me.  The send operation is handled in side effect
processing off a queue that might have operations queued ahead of it, which
affect the associations state.  I think you need to keep this check in place

Neil

> ---
>  net/sctp/outqueue.c | 53 ++++++++++++++---------------------------------------
>  1 file changed, 14 insertions(+), 39 deletions(-)
> 
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 72e54a4..da2418b 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -299,50 +299,25 @@ int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk, gfp_t gfp)
>  	 * immediately.
>  	 */
>  	if (sctp_chunk_is_data(chunk)) {
> -		/* Is it OK to queue data chunks?  */
> -		/* From 9. Termination of Association
> -		 *
> -		 * When either endpoint performs a shutdown, the
> -		 * association on each peer will stop accepting new
> -		 * data from its user and only deliver data in queue
> -		 * at the time of sending or receiving the SHUTDOWN
> -		 * chunk.
> -		 */
> -		switch (q->asoc->state) {
> -		case SCTP_STATE_CLOSED:
> -		case SCTP_STATE_SHUTDOWN_PENDING:
> -		case SCTP_STATE_SHUTDOWN_SENT:
> -		case SCTP_STATE_SHUTDOWN_RECEIVED:
> -		case SCTP_STATE_SHUTDOWN_ACK_SENT:
> -			/* Cannot send after transport endpoint shutdown */
> -			error = -ESHUTDOWN;
> -			break;
> -
> -		default:
> -			pr_debug("%s: outqueueing: outq:%p, chunk:%p[%s])\n",
> -				 __func__, q, chunk, chunk && chunk->chunk_hdr ?
> -				 sctp_cname(SCTP_ST_CHUNK(chunk->chunk_hdr->type)) :
> -				 "illegal chunk");
> -
> -			sctp_chunk_hold(chunk);
> -			sctp_outq_tail_data(q, chunk);
> -			if (chunk->asoc->prsctp_enable &&
> -			    SCTP_PR_PRIO_ENABLED(chunk->sinfo.sinfo_flags))
> -				chunk->asoc->sent_cnt_removable++;
> -			if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
> -				SCTP_INC_STATS(net, SCTP_MIB_OUTUNORDERCHUNKS);
> -			else
> -				SCTP_INC_STATS(net, SCTP_MIB_OUTORDERCHUNKS);
> -			break;
> -		}
> +		pr_debug("%s: outqueueing: outq:%p, chunk:%p[%s])\n",
> +			 __func__, q, chunk, chunk && chunk->chunk_hdr ?
> +			 sctp_cname(SCTP_ST_CHUNK(chunk->chunk_hdr->type)) :
> +			 "illegal chunk");
> +
> +		sctp_chunk_hold(chunk);
> +		sctp_outq_tail_data(q, chunk);
> +		if (chunk->asoc->prsctp_enable &&
> +		    SCTP_PR_PRIO_ENABLED(chunk->sinfo.sinfo_flags))
> +			chunk->asoc->sent_cnt_removable++;
> +		if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
> +			SCTP_INC_STATS(net, SCTP_MIB_OUTUNORDERCHUNKS);
> +		else
> +			SCTP_INC_STATS(net, SCTP_MIB_OUTORDERCHUNKS);
>  	} else {
>  		list_add_tail(&chunk->list, &q->control_chunk_list);
>  		SCTP_INC_STATS(net, SCTP_MIB_OUTCTRLCHUNKS);
>  	}
>  
> -	if (error < 0)
> -		return error;
> -
>  	if (!q->cork)
>  		error = sctp_outq_flush(q, 0, gfp);
>  
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
