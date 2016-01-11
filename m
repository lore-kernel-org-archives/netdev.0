From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: fix use-after-free in pr_debug statement
Date: Mon, 11 Jan 2016 12:00:03 -0500
Message-ID: <5693DF93.1070808@gmail.com>
References: <566AF20F.9060504@gmail.com>
 <51dffdfdb37c240ff7e9b0b2a93433f217fa4d2c.1452257700.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, dvyukov@google.com,
	eric.dumazet@gmail.com, syzkaller@googlegroups.com, kcc@google.com,
	glider@google.com, sasha.levin@oracle.com
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:35569 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759116AbcAKRAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 12:00:07 -0500
In-Reply-To: <51dffdfdb37c240ff7e9b0b2a93433f217fa4d2c.1452257700.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2016 08:00 AM, Marcelo Ricardo Leitner wrote:
> Couldn't get syzkaller working over here, so I still need your help on
> testing this. I expect this will be the last cycle, though.
> 
> If it does generate another trace, I'll need the reproducer too because
> I can't find anything else just with code review.
> 
> Thanks

Looks to me like you got all of them.

> 
> --8<--
> 
> Dmitry Vyukov reported a use-after-free in the code expanded by the
> macro debug_post_sfx, which is caused by the use of the asoc pointer
> after it was freed within sctp_side_effect() scope.
> 
> This patch fixes it by allowing sctp_side_effect to clear that asoc
> pointer when the TCB is freed.
> 
> As Vlad explained, we also have to cover the SCTP_DISPOSITION_ABORT case
> because it will trigger DELETE_TCB too on that same loop.
> 
> Also, there were places issuing SCTP_CMD_INIT_FAILED and ASSOC_FAILED
> but returning SCTP_DISPOSITION_CONSUME, which would fool the scheme
> above. Fix it by returning SCTP_DISPOSITION_ABORT instead.
> 
> The macro is already prepared to handle such NULL pointer.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Thanks
-vlad

> ---
>  net/sctp/sm_sideeffect.c | 11 ++++++-----
>  net/sctp/sm_statefuns.c  | 17 ++++-------------
>  2 files changed, 10 insertions(+), 18 deletions(-)
> 
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index 4f170ad38ff4f7d345d8e3a3fee7d691df64d9cb..2e21384697c2a6a5fd045142bcd9c39992d3867f 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -63,7 +63,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>  static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
>  			     sctp_state_t state,
>  			     struct sctp_endpoint *ep,
> -			     struct sctp_association *asoc,
> +			     struct sctp_association **asoc,
>  			     void *event_arg,
>  			     sctp_disposition_t status,
>  			     sctp_cmd_seq_t *commands,
> @@ -1125,7 +1125,7 @@ int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
>  	debug_post_sfn();
>  
>  	error = sctp_side_effects(event_type, subtype, state,
> -				  ep, asoc, event_arg, status,
> +				  ep, &asoc, event_arg, status,
>  				  &commands, gfp);
>  	debug_post_sfx();
>  
> @@ -1138,7 +1138,7 @@ int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
>  static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
>  			     sctp_state_t state,
>  			     struct sctp_endpoint *ep,
> -			     struct sctp_association *asoc,
> +			     struct sctp_association **asoc,
>  			     void *event_arg,
>  			     sctp_disposition_t status,
>  			     sctp_cmd_seq_t *commands,
> @@ -1153,7 +1153,7 @@ static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
>  	 * disposition SCTP_DISPOSITION_CONSUME.
>  	 */
>  	if (0 != (error = sctp_cmd_interpreter(event_type, subtype, state,
> -					       ep, asoc,
> +					       ep, *asoc,
>  					       event_arg, status,
>  					       commands, gfp)))
>  		goto bail;
> @@ -1176,11 +1176,12 @@ static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
>  		break;
>  
>  	case SCTP_DISPOSITION_DELETE_TCB:
> +	case SCTP_DISPOSITION_ABORT:
>  		/* This should now be a command. */
> +		*asoc = NULL;
>  		break;
>  
>  	case SCTP_DISPOSITION_CONSUME:
> -	case SCTP_DISPOSITION_ABORT:
>  		/*
>  		 * We should no longer have much work to do here as the
>  		 * real work has been done as explicit commands above.
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index 22c2bf367d7e8c7025065f33eabfd7e93a7f4021..f1f08c8f277bd8719299d1ed21eb23e36d55f7e2 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -2976,7 +2976,7 @@ sctp_disposition_t sctp_sf_eat_data_6_2(struct net *net,
>  		SCTP_INC_STATS(net, SCTP_MIB_IN_DATA_CHUNK_DISCARDS);
>  		goto discard_force;
>  	case SCTP_IERROR_NO_DATA:
> -		goto consume;
> +		return SCTP_DISPOSITION_ABORT;
>  	case SCTP_IERROR_PROTO_VIOLATION:
>  		return sctp_sf_abort_violation(net, ep, asoc, chunk, commands,
>  			(u8 *)chunk->subh.data_hdr, sizeof(sctp_datahdr_t));
> @@ -3043,9 +3043,6 @@ discard_noforce:
>  		sctp_add_cmd_sf(commands, SCTP_CMD_GEN_SACK, force);
>  
>  	return SCTP_DISPOSITION_DISCARD;
> -consume:
> -	return SCTP_DISPOSITION_CONSUME;
> -
>  }
>  
>  /*
> @@ -3093,7 +3090,7 @@ sctp_disposition_t sctp_sf_eat_data_fast_4_4(struct net *net,
>  	case SCTP_IERROR_BAD_STREAM:
>  		break;
>  	case SCTP_IERROR_NO_DATA:
> -		goto consume;
> +		return SCTP_DISPOSITION_ABORT;
>  	case SCTP_IERROR_PROTO_VIOLATION:
>  		return sctp_sf_abort_violation(net, ep, asoc, chunk, commands,
>  			(u8 *)chunk->subh.data_hdr, sizeof(sctp_datahdr_t));
> @@ -3119,7 +3116,6 @@ sctp_disposition_t sctp_sf_eat_data_fast_4_4(struct net *net,
>  				SCTP_TO(SCTP_EVENT_TIMEOUT_T2_SHUTDOWN));
>  	}
>  
> -consume:
>  	return SCTP_DISPOSITION_CONSUME;
>  }
>  
> @@ -4825,9 +4821,6 @@ sctp_disposition_t sctp_sf_do_9_1_prm_abort(
>  	 * if necessary to fill gaps.
>  	 */
>  	struct sctp_chunk *abort = arg;
> -	sctp_disposition_t retval;
> -
> -	retval = SCTP_DISPOSITION_CONSUME;
>  
>  	if (abort)
>  		sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
> @@ -4845,7 +4838,7 @@ sctp_disposition_t sctp_sf_do_9_1_prm_abort(
>  	SCTP_INC_STATS(net, SCTP_MIB_ABORTEDS);
>  	SCTP_DEC_STATS(net, SCTP_MIB_CURRESTAB);
>  
> -	return retval;
> +	return SCTP_DISPOSITION_ABORT;
>  }
>  
>  /* We tried an illegal operation on an association which is closed.  */
> @@ -4960,12 +4953,10 @@ sctp_disposition_t sctp_sf_cookie_wait_prm_abort(
>  	sctp_cmd_seq_t *commands)
>  {
>  	struct sctp_chunk *abort = arg;
> -	sctp_disposition_t retval;
>  
>  	/* Stop T1-init timer */
>  	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
>  			SCTP_TO(SCTP_EVENT_TIMEOUT_T1_INIT));
> -	retval = SCTP_DISPOSITION_CONSUME;
>  
>  	if (abort)
>  		sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
> @@ -4985,7 +4976,7 @@ sctp_disposition_t sctp_sf_cookie_wait_prm_abort(
>  	sctp_add_cmd_sf(commands, SCTP_CMD_INIT_FAILED,
>  			SCTP_PERR(SCTP_ERROR_USER_ABORT));
>  
> -	return retval;
> +	return SCTP_DISPOSITION_ABORT;
>  }
>  
>  /*
> 
