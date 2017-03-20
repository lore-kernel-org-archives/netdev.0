From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: out_qlen should be updated when pruning unsent
 queue
Date: Mon, 20 Mar 2017 15:43:11 -0300
Message-ID: <20170320184311.GE23553@localhost.localdomain>
References: <16cb6e6d2ef47481123bc3ff1b99e8abf5334d14.1489838639.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57670 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932757AbdCTSnZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 14:43:25 -0400
Content-Disposition: inline
In-Reply-To: <16cb6e6d2ef47481123bc3ff1b99e8abf5334d14.1489838639.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 18, 2017 at 08:03:59PM +0800, Xin Long wrote:
> This patch is to fix the issue that sctp_prsctp_prune_sent forgot
> to update q->out_qlen when removing a chunk from unsent queue.
> 
> Fixes: 8dbdf1f5b09c ("sctp: implement prsctp PRIO policy")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/outqueue.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index db352e5..025ccff 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -382,17 +382,18 @@ static int sctp_prsctp_prune_sent(struct sctp_association *asoc,
>  }
>  
>  static int sctp_prsctp_prune_unsent(struct sctp_association *asoc,
> -				    struct sctp_sndrcvinfo *sinfo,
> -				    struct list_head *queue, int msg_len)
> +				    struct sctp_sndrcvinfo *sinfo, int msg_len)
>  {
> +	struct sctp_outq *q = &asoc->outqueue;
>  	struct sctp_chunk *chk, *temp;
>  
> -	list_for_each_entry_safe(chk, temp, queue, list) {
> +	list_for_each_entry_safe(chk, temp, &q->out_chunk_list, list) {
>  		if (!SCTP_PR_PRIO_ENABLED(chk->sinfo.sinfo_flags) ||
>  		    chk->sinfo.sinfo_timetolive <= sinfo->sinfo_timetolive)
>  			continue;
>  
>  		list_del_init(&chk->list);
> +		q->out_qlen -= chk->skb->len;
>  		asoc->sent_cnt_removable--;
>  		asoc->abandoned_unsent[SCTP_PR_INDEX(PRIO)]++;
>  
> @@ -431,9 +432,7 @@ void sctp_prsctp_prune(struct sctp_association *asoc,
>  			return;
>  	}
>  
> -	sctp_prsctp_prune_unsent(asoc, sinfo,
> -				 &asoc->outqueue.out_chunk_list,
> -				 msg_len);
> +	sctp_prsctp_prune_unsent(asoc, sinfo, msg_len);
>  }
>  
>  /* Mark all the eligible packets on a transport for retransmission.  */
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
