From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next] sctp: uncork the old asoc before changing to
 the new one
Date: Tue, 20 Jun 2017 12:43:03 -0300
Message-ID: <20170620154303.GB18138@localhost.localdomain>
References: <99205651b831cf7fd7b847f9b5c904fbf57ce416.1497945715.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42128 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750859AbdFTPnR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 11:43:17 -0400
Content-Disposition: inline
In-Reply-To: <99205651b831cf7fd7b847f9b5c904fbf57ce416.1497945715.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 20, 2017 at 04:01:55PM +0800, Xin Long wrote:
> local_cork is used to decide if it should uncork asoc outq after processing
> some cmds, and it is set when replying or sending msgs. local_cork should
> always have the same value with current asoc q->cork in some way.
> 
> The thing is when changing to a new asoc by cmd SET_ASOC, local_cork may
> not be consistent with the current asoc any more. The cmd seqs can be:
> 
>   SCTP_CMD_UPDATE_ASSOC (asoc)
>   SCTP_CMD_REPLY (asoc)
>   SCTP_CMD_SET_ASOC (new_asoc)
>   SCTP_CMD_DELETE_TCB (new_asoc)
>   SCTP_CMD_SET_ASOC (asoc)
>   SCTP_CMD_REPLY (asoc)
> 
> The 1st REPLY makes OLD asoc q->cork and local_cork both are 1, and the cmd
> DELETE_TCB clears NEW asoc q->cork and local_cork. After asoc goes back to
> OLD asoc, q->cork is still 1 while local_cork is 0. The 2nd REPLY will not
> set local_cork because q->cork is already set and it can't be uncorked and
> sent out because of this.
> 
> To keep local_cork consistent with the current asoc q->cork, this patch is
> to uncork the old asoc if local_cork is set before changing to the new one.
> 
> Note that the above cmd seqs will be used in the next patch when updating
> asoc and handling errors in it.
> 
> Suggested-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/sm_sideeffect.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index 25384fa..7623566 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -1748,6 +1748,10 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>  			break;
>  
>  		case SCTP_CMD_SET_ASOC:
> +			if (asoc && local_cork) {
> +				sctp_outq_uncork(&asoc->outqueue, gfp);
> +				local_cork = 0;
> +			}
>  			asoc = cmd->obj.asoc;
>  			break;
>  
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
