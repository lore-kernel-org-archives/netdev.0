From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next] sctp: remove the old ttl expires policy
Date: Mon, 10 Oct 2016 18:19:58 -0300
Message-ID: <20161010211958.GA2945@localhost.localdomain>
References: <db5df5806c3c0b7c37ab9039a906664a33c74563.1475898016.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
        davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56856 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751522AbcJJVUB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Oct 2016 17:20:01 -0400
Content-Disposition: inline
In-Reply-To: <db5df5806c3c0b7c37ab9039a906664a33c74563.1475898016.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 08, 2016 at 11:40:16AM +0800, Xin Long wrote:
> The prsctp polices include ttl expires policy already, we should remove
> the old ttl expires codes, and just adjust the new polices' codes to be
> compatible with the old one for users.
> 
> This patch is to remove all the old expires codes, and if prsctp polices
> are not set, it will still set msg's expires_at and check the expires in
> sctp_check_abandoned.
> 
> Note that asoc->prsctp_enable is set by default, so users can't feel any
> difference even if they use the old expires api in userspace.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  include/net/sctp/structs.h |  1 -
>  net/sctp/chunk.c           | 32 ++++++++------------------------
>  net/sctp/output.c          |  3 ---
>  3 files changed, 8 insertions(+), 28 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 11c3bf2..61732e9 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -530,7 +530,6 @@ struct sctp_datamsg {
>  	/* Did the messenge fail to send? */
>  	int send_error;
>  	u8 send_failed:1,
> -	   can_abandon:1,   /* can chunks from this message can be abandoned. */
>  	   can_delay;	    /* should this message be Nagle delayed */
>  };
>  
> diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
> index 7a1cdf4..615f0dd 100644
> --- a/net/sctp/chunk.c
> +++ b/net/sctp/chunk.c
> @@ -52,7 +52,6 @@ static void sctp_datamsg_init(struct sctp_datamsg *msg)
>  	atomic_set(&msg->refcnt, 1);
>  	msg->send_failed = 0;
>  	msg->send_error = 0;
> -	msg->can_abandon = 0;
>  	msg->can_delay = 1;
>  	msg->expires_at = 0;
>  	INIT_LIST_HEAD(&msg->chunks);
> @@ -182,20 +181,11 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
>  	/* Note: Calculate this outside of the loop, so that all fragments
>  	 * have the same expiration.
>  	 */
> -	if (sinfo->sinfo_timetolive) {
> -		/* sinfo_timetolive is in milliseconds */
> +	if (asoc->peer.prsctp_capable && sinfo->sinfo_timetolive &&
> +	    (SCTP_PR_TTL_ENABLED(sinfo->sinfo_flags) ||
> +	     !SCTP_PR_POLICY(sinfo->sinfo_flags)))
>  		msg->expires_at = jiffies +
>  				    msecs_to_jiffies(sinfo->sinfo_timetolive);
> -		msg->can_abandon = 1;
> -
> -		pr_debug("%s: msg:%p expires_at:%ld jiffies:%ld\n", __func__,
> -			 msg, msg->expires_at, jiffies);
> -	}
> -
> -	if (asoc->peer.prsctp_capable &&
> -	    SCTP_PR_TTL_ENABLED(sinfo->sinfo_flags))
> -		msg->expires_at =
> -			jiffies + msecs_to_jiffies(sinfo->sinfo_timetolive);
>  
>  	/* This is the biggest possible DATA chunk that can fit into
>  	 * the packet
> @@ -354,18 +344,8 @@ errout:
>  /* Check whether this message has expired. */
>  int sctp_chunk_abandoned(struct sctp_chunk *chunk)
>  {
> -	if (!chunk->asoc->peer.prsctp_capable ||
> -	    !SCTP_PR_POLICY(chunk->sinfo.sinfo_flags)) {
> -		struct sctp_datamsg *msg = chunk->msg;
> -
> -		if (!msg->can_abandon)
> -			return 0;
> -
> -		if (time_after(jiffies, msg->expires_at))
> -			return 1;
> -
> +	if (!chunk->asoc->peer.prsctp_capable)
>  		return 0;
> -	}
>  
>  	if (SCTP_PR_TTL_ENABLED(chunk->sinfo.sinfo_flags) &&
>  	    time_after(jiffies, chunk->msg->expires_at)) {
> @@ -378,6 +358,10 @@ int sctp_chunk_abandoned(struct sctp_chunk *chunk)
>  		   chunk->sent_count > chunk->sinfo.sinfo_timetolive) {
>  		chunk->asoc->abandoned_sent[SCTP_PR_INDEX(RTX)]++;
>  		return 1;
> +	} else if (!SCTP_PR_POLICY(chunk->sinfo.sinfo_flags) &&
> +		   chunk->msg->expires_at &&
> +		   time_after(jiffies, chunk->msg->expires_at)) {
> +		return 1;
>  	}
>  	/* PRIO policy is processed by sendmsg, not here */
>  
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 2a5c189..f0af831 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -865,9 +865,6 @@ static void sctp_packet_append_data(struct sctp_packet *packet,
>  		rwnd = 0;
>  
>  	asoc->peer.rwnd = rwnd;
> -	/* Has been accepted for transmission. */
> -	if (!asoc->peer.prsctp_capable)
> -		chunk->msg->can_abandon = 0;
>  	sctp_chunk_assign_tsn(chunk);
>  	sctp_chunk_assign_ssn(chunk);
>  }
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
