From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: use right in and out stream cnt
Date: Fri, 31 Mar 2017 15:25:24 -0300
Message-ID: <20170331182524.GD5879@localhost.localdomain>
References: <046f41fee71d352458eccf900bcef54e24cb8aa8.1490954248.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net, Neil Horman <nhorman@tuxdriver.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37154 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933313AbdCaSZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 31 Mar 2017 14:25:28 -0400
Content-Disposition: inline
In-Reply-To: <046f41fee71d352458eccf900bcef54e24cb8aa8.1490954248.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 31, 2017 at 05:57:28PM +0800, Xin Long wrote:
> Since sctp reconf was added in sctp, the real cnt of in/out stream
> have not been c.sinit_max_instreams and c.sinit_num_ostreams any
> more.
> 
> This patch is to replace them with stream->in/outcnt.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/outqueue.c     |  3 +--
>  net/sctp/proc.c         |  4 ++--
>  net/sctp/sm_statefuns.c |  6 +++---
>  net/sctp/socket.c       | 10 +++++-----
>  4 files changed, 11 insertions(+), 12 deletions(-)
> 
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 025ccff..8081476 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -1026,8 +1026,7 @@ static void sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
>  			/* RFC 2960 6.5 Every DATA chunk MUST carry a valid
>  			 * stream identifier.
>  			 */
> -			if (chunk->sinfo.sinfo_stream >=
> -			    asoc->c.sinit_num_ostreams) {
> +			if (chunk->sinfo.sinfo_stream >= asoc->stream->outcnt) {
>  
>  				/* Mark as failed send. */
>  				sctp_chunk_fail(chunk, SCTP_ERROR_INV_STRM);
> diff --git a/net/sctp/proc.c b/net/sctp/proc.c
> index 206377f..a0b29d4 100644
> --- a/net/sctp/proc.c
> +++ b/net/sctp/proc.c
> @@ -361,8 +361,8 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
>  	sctp_seq_dump_remote_addrs(seq, assoc);
>  	seq_printf(seq, "\t%8lu %5d %5d %4d %4d %4d %8d "
>  		   "%8d %8d %8d %8d",
> -		assoc->hbinterval, assoc->c.sinit_max_instreams,
> -		assoc->c.sinit_num_ostreams, assoc->max_retrans,
> +		assoc->hbinterval, assoc->stream->incnt,
> +		assoc->stream->outcnt, assoc->max_retrans,
>  		assoc->init_retries, assoc->shutdown_retries,
>  		assoc->rtx_data_chunks,
>  		atomic_read(&sk->sk_wmem_alloc),
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index e03bb1a..24c6ccc 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -3946,7 +3946,7 @@ sctp_disposition_t sctp_sf_eat_fwd_tsn(struct net *net,
>  
>  	/* Silently discard the chunk if stream-id is not valid */
>  	sctp_walk_fwdtsn(skip, chunk) {
> -		if (ntohs(skip->stream) >= asoc->c.sinit_max_instreams)
> +		if (ntohs(skip->stream) >= asoc->stream->incnt)
>  			goto discard_noforce;
>  	}
>  
> @@ -4017,7 +4017,7 @@ sctp_disposition_t sctp_sf_eat_fwd_tsn_fast(
>  
>  	/* Silently discard the chunk if stream-id is not valid */
>  	sctp_walk_fwdtsn(skip, chunk) {
> -		if (ntohs(skip->stream) >= asoc->c.sinit_max_instreams)
> +		if (ntohs(skip->stream) >= asoc->stream->incnt)
>  			goto gen_shutdown;
>  	}
>  
> @@ -6353,7 +6353,7 @@ static int sctp_eat_data(const struct sctp_association *asoc,
>  	 * and discard the DATA chunk.
>  	 */
>  	sid = ntohs(data_hdr->stream);
> -	if (sid >= asoc->c.sinit_max_instreams) {
> +	if (sid >= asoc->stream->incnt) {
>  		/* Mark tsn as received even though we drop it */
>  		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_TSN, SCTP_U32(tsn));
>  
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index baa269a..12fbae2 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -1920,7 +1920,7 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
>  	}
>  
>  	/* Check for invalid stream. */
> -	if (sinfo->sinfo_stream >= asoc->c.sinit_num_ostreams) {
> +	if (sinfo->sinfo_stream >= asoc->stream->outcnt) {
>  		err = -EINVAL;
>  		goto out_free;
>  	}
> @@ -4461,8 +4461,8 @@ int sctp_get_sctp_info(struct sock *sk, struct sctp_association *asoc,
>  	info->sctpi_rwnd = asoc->a_rwnd;
>  	info->sctpi_unackdata = asoc->unack_data;
>  	info->sctpi_penddata = sctp_tsnmap_pending(&asoc->peer.tsn_map);
> -	info->sctpi_instrms = asoc->c.sinit_max_instreams;
> -	info->sctpi_outstrms = asoc->c.sinit_num_ostreams;
> +	info->sctpi_instrms = asoc->stream->incnt;
> +	info->sctpi_outstrms = asoc->stream->outcnt;
>  	list_for_each(pos, &asoc->base.inqueue.in_chunk_list)
>  		info->sctpi_inqueue++;
>  	list_for_each(pos, &asoc->outqueue.out_chunk_list)
> @@ -4691,8 +4691,8 @@ static int sctp_getsockopt_sctp_status(struct sock *sk, int len,
>  	status.sstat_unackdata = asoc->unack_data;
>  
>  	status.sstat_penddata = sctp_tsnmap_pending(&asoc->peer.tsn_map);
> -	status.sstat_instrms = asoc->c.sinit_max_instreams;
> -	status.sstat_outstrms = asoc->c.sinit_num_ostreams;
> +	status.sstat_instrms = asoc->stream->incnt;
> +	status.sstat_outstrms = asoc->stream->outcnt;
>  	status.sstat_fragmentation_point = asoc->frag_point;
>  	status.sstat_primary.spinfo_assoc_id = sctp_assoc2id(transport->asoc);
>  	memcpy(&status.sstat_primary.spinfo_address, &transport->ipaddr,
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
