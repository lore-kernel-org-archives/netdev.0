From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] SCTP: Fix Protocol violation when receiving a error length
 INIT ACK
Date: Thu, 27 Mar 2008 15:55:21 -0400
Message-ID: <47EBFBA9.40609@hp.com>
References: <47E73E83.9000301@cn.fujitsu.com> <47E74B17.40907@cn.fujitsu.com> <47E87290.2080205@cn.fujitsu.com> <47E883B9.5040907@cn.fujitsu.com> <47E8A566.6060405@cn.fujitsu.com> <47E915E3.2040501@hp.com> <47EAFB12.9040800@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yjwei@cn.fujitsu.com>,
	netdev <netdev@vger.kernel.org>,
	lksctp-dev <lksctp-developers@lists.sourceforge.net>,
	David Miller <davem@davemloft.net>
To: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:1336 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758027AbYC0TzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 15:55:24 -0400
In-Reply-To: <47EAFB12.9040800@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gui Jianfeng wrote:
> Vlad Yasevich wrote:
>> There is a side-effect to this patch that now we will completely ignore
>> the verification
>> tag in the INIT-ACK regardless of the violation.
>>
>> In particular, if the INIT-ACK contains all the fixed parameters but
>> violates structure
>> in some variable parameters, we'll currently use the Initiate Tag from
>> the INIT-ACK in
>> the ABORT.   We should not be changing this behavior.
>>
>> The simple hack is to add some conditional code into the the different
>> violation functions, but
>> I'd like to see if there is a cleaner way to solve this.
>  
> Vlad,
>   The problem you said has been addressed, this is a new patch. Just treat 
>   an INIT-ACK received during COOKIE-WAIT as a special case. this patch will
>   not break the normal behavior.

Ok.  One minor style thing.

> 
> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
> ---
>  include/net/sctp/command.h |    1 +
>  net/sctp/outqueue.c        |    3 +++
>  net/sctp/sm_sideeffect.c   |    5 ++++-
>  net/sctp/sm_statefuns.c    |   18 ++++++++++++++++++
>  4 files changed, 26 insertions(+), 1 deletions(-)
> 
> diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
> index 10ae2da..35b1e83 100644
> --- a/include/net/sctp/command.h
> +++ b/include/net/sctp/command.h
> @@ -104,6 +104,7 @@ typedef enum {
>  	SCTP_CMD_ADAPTATION_IND, /* generate and send adaptation event */
>  	SCTP_CMD_ASSOC_SHKEY,    /* generate the association shared keys */
>  	SCTP_CMD_T1_RETRAN,	 /* Mark for retransmission after T1 timeout  */
> +	SCTP_CMD_UPDATE_INITTAG, /* Update peer inittag */
>  	SCTP_CMD_LAST
>  } sctp_verb_t;
>  
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 1bb3c5c..c071446 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -793,6 +793,9 @@ int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
>  			break;
>  
>  		case SCTP_CID_ABORT:
> +			if (sctp_test_T_bit(chunk)) {
> +				packet->vtag = asoc->c.my_vtag;
> +			}
>  		case SCTP_CID_SACK:
>  		case SCTP_CID_HEARTBEAT:
>  		case SCTP_CID_HEARTBEAT_ACK:
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index 28eb38e..2dbc7bd 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -1536,7 +1536,10 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>  			error = sctp_auth_asoc_init_active_key(asoc,
>  						GFP_ATOMIC);
>  			break;
> -
> +		case SCTP_CMD_UPDATE_INITTAG:
> +			asoc->peer.i.init_tag = cmd->obj.u32;
> +			break;
> +			
>  		default:
>  			printk(KERN_WARNING "Impossible command: %u, %p\n",
>  			       cmd->verb, cmd->obj.ptr);
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index f2ed647..b3ed52c 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -4144,6 +4144,24 @@ static sctp_disposition_t sctp_sf_abort_violation(
>  		goto nomem;
>  
>  	if (asoc) {
> +		/* Treat INIT-ACK as a special case during COOKIE-WAIT. */
> +		if (chunk->chunk_hdr->type == SCTP_CID_INIT_ACK 
> +		    && !asoc->peer.i.init_tag) {
                ^^^^^^^^^

The '&&' usually goes at the end of the line.

> +			sctp_initack_chunk_t *initack;
> +
> +			initack = (sctp_initack_chunk_t *)chunk->chunk_hdr;
> +			if (!sctp_chunk_length_valid(chunk, 
> +						     sizeof(sctp_initack_chunk_t)))
> +				abort->chunk_hdr->flags |= SCTP_CHUNK_FLAG_T;
> +			else {
> +				unsigned int inittag;
> +				
> +				inittag = ntohl(initack->init_hdr.init_tag);
> +				sctp_add_cmd_sf(commands, SCTP_CMD_UPDATE_INITTAG,
> +						SCTP_U32(inittag));
> +			}
> +		}
> +
>  		sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
>  		SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
>  

Can you also resend with a clean patch description.

Thanks
-vlad
