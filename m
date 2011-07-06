From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCHv2] sctp: Enforce retransmission limit during shutdown
Date: Wed, 06 Jul 2011 09:42:42 -0400
Message-ID: <4E146652.7010205@hp.com>
References: <20110629135704.GB10085@canuck.infradead.org> <4E0B3491.1060603@hp.com> <20110629143649.GC10085@canuck.infradead.org> <4E0B3DA1.9060200@hp.com> <20110629154814.GD10085@canuck.infradead.org> <4E0B4F71.4020108@hp.com> <20110630084933.GA24074@canuck.infradead.org> <4E0C8368.5090502@hp.com> <20110704135019.GA801@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:1847 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751760Ab1GFNms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 09:42:48 -0400
In-Reply-To: <20110704135019.GA801@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tomas

Some minor nits and one substantial issue.  See below.

On a related note, were you going to re-submit the receiver patch as well?

On 07/04/2011 09:50 AM, Thomas Graf wrote:
> 
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 1c88c89..0ae911f 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -1582,6 +1582,9 @@ static void sctp_check_transmitted(struct sctp_outq *q,
>  #endif /* SCTP_DEBUG */
>  	if (transport) {
>  		if (bytes_acked) {
> +			struct sctp_association *asoc = transport->asoc;
> +			struct timer_list *t;
> +
>  			/* We may have counted DATA that was migrated
>  			 * to this transport due to DEL-IP operation.
>  			 * Subtract those bytes, since the were never
> @@ -1600,6 +1603,17 @@ static void sctp_check_transmitted(struct sctp_outq *q,
>  			transport->error_count = 0;
>  			transport->asoc->overall_error_count = 0;
>  
> +			/*
> +			 * While in SHUTDOWN PENDING, we may have started
> +			 * the T5 shutdown guard timer after reaching the
> +			 * retransmission limit. Stop that timer as soon
> +			 * as the receiver acknowledged any data.
> +			 */
> +			t = &asoc->timers[SCTP_EVENT_TIMEOUT_T5_SHUTDOWN_GUARD];
> +			if (asoc->state == SCTP_STATE_SHUTDOWN_PENDING &&
> +			    timer_pending(t) && del_timer(t))
> +				sctp_association_put(asoc);
> +

I believe 'state' and 'timers' are in different cache lines, so might be able to optimize it
a little by checking the state prior to referencing timers array.

>  			/* Mark the destination transport address as
>  			 * active if it is not so marked.
>  			 */
> @@ -1629,10 +1643,15 @@ static void sctp_check_transmitted(struct sctp_outq *q,
>  			 * A sender is doing zero window probing when the
>  			 * receiver's advertised window is zero, and there is
>  			 * only one data chunk in flight to the receiver.
> +			 *
> +			 * Allow the association to timeout if SHUTDOWN is
> +			 * pending in case the receiver stays in zero window
> +			 * mode forever.
>  			 */
>  			if (!q->asoc->peer.rwnd &&
>  			    !list_empty(&tlist) &&
> -			    (sack_ctsn+2 == q->asoc->next_tsn)) {
> +			    (sack_ctsn+2 == q->asoc->next_tsn) &&
> +			    !(q->asoc->state >= SCTP_STATE_SHUTDOWN_PENDING)) {

Would a test for (q->asoc->state != SCTP_STATE_SHUTDOWN_PENDING) be clearer?  We only
care about the PENDING state here.

>  				SCTP_DEBUG_PRINTK("%s: SACK received for zero "
>  						  "window probe: %u\n",
>  						  __func__, sack_ctsn);
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index 534c2e5..fa92f4d6 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -670,10 +670,21 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
>  	/* 8.3 Upon the receipt of the HEARTBEAT ACK, the sender of the
>  	 * HEARTBEAT should clear the error counter of the destination
>  	 * transport address to which the HEARTBEAT was sent.
> -	 * The association's overall error count is also cleared.
>  	 */
>  	t->error_count = 0;
> -	t->asoc->overall_error_count = 0;
> +
> +	/*
> +	 * Although RFC2960 and RFC4460 specify that the overall error
> +	 * count must be cleared when a HEARTBEAT ACK is received this
> +	 * behaviour may prevent the maximum retransmission count from
> +	 * being reached while in SHUTDOWN. If the peer keeps its window
> +	 * closed not acknowledging any outstanding TSN we may rely on
> +	 * reaching the max_retrans limit via the T3-rtx timer to close
> +	 * the association which will never happen if the error count is
> +	 * reset every heartbeat interval.
> +	 */
> +	if (!(t->asoc->state >= SCTP_STATE_SHUTDOWN_PENDING))
> +		t->asoc->overall_error_count = 0;

Same here.  We only care about the PENDING state. Also, please fix the comment to reflect
the code.

>  
>  	/* Clear the hb_sent flag to signal that we had a good
>  	 * acknowledgement.
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index a297283..e6a0c35 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -5154,7 +5154,7 @@ sctp_disposition_t sctp_sf_do_9_2_start_shutdown(
>  	 * The sender of the SHUTDOWN MAY also start an overall guard timer
>  	 * 'T5-shutdown-guard' to bound the overall time for shutdown sequence.
>  	 */
> -	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_START,
> +	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_RESTART,
>  			SCTP_TO(SCTP_EVENT_TIMEOUT_T5_SHUTDOWN_GUARD));
>  
>  	if (asoc->autoclose)
> @@ -5299,14 +5299,28 @@ sctp_disposition_t sctp_sf_do_6_3_3_rtx(const struct sctp_endpoint *ep,
>  	SCTP_INC_STATS(SCTP_MIB_T3_RTX_EXPIREDS);
>  
>  	if (asoc->overall_error_count >= asoc->max_retrans) {
> -		sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
> -				SCTP_ERROR(ETIMEDOUT));
> -		/* CMD_ASSOC_FAILED calls CMD_DELETE_TCB. */
> -		sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_FAILED,
> -				SCTP_PERR(SCTP_ERROR_NO_ERROR));
> -		SCTP_INC_STATS(SCTP_MIB_ABORTEDS);
> -		SCTP_DEC_STATS(SCTP_MIB_CURRESTAB);
> -		return SCTP_DISPOSITION_DELETE_TCB;
> +		if (asoc->state == SCTP_STATE_SHUTDOWN_PENDING) {
> +			/*
> +			 * We are here likely because the receiver had its rwnd
> +			 * closed for a while and we have not been able to
> +			 * transmit the locally queued data within the maximum
> +			 * retransmission attempts limit.  Start the T5
> +			 * shutdown guard timer to give the receiver one last
> +			 * chance and some additional time to recover before
> +			 * aborting.
> +			 */
> +			sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_RESTART,
> +				SCTP_TO(SCTP_EVENT_TIMEOUT_T5_SHUTDOWN_GUARD));

This is bug.  You don't want to restart the timer every time you hit a T3-timeout.  Remember, since you fall
through here, you do another retransmission and schedule another timeout.  So next time the timeout happens,
you'll restart the SHUTDOWN_GUARD, which is not what you want.

We want to start it once if it isn't pending, and leave it running without restart if it is already pending.

-vlad

> +		} else {
> +			sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
> +					SCTP_ERROR(ETIMEDOUT));
> +			/* CMD_ASSOC_FAILED calls CMD_DELETE_TCB. */
> +			sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_FAILED,
> +					SCTP_PERR(SCTP_ERROR_NO_ERROR));
> +			SCTP_INC_STATS(SCTP_MIB_ABORTEDS);
> +			SCTP_DEC_STATS(SCTP_MIB_CURRESTAB);
> +			return SCTP_DISPOSITION_DELETE_TCB;
> +		}
>  	}
>  
>  	/* E1) For the destination address for which the timer
> diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
> index 0338dc6..7c211a7 100644
> --- a/net/sctp/sm_statetable.c
> +++ b/net/sctp/sm_statetable.c
> @@ -827,7 +827,7 @@ static const sctp_sm_table_entry_t other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_
>  	/* SCTP_STATE_ESTABLISHED */ \
>  	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
>  	/* SCTP_STATE_SHUTDOWN_PENDING */ \
> -	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
> +	TYPE_SCTP_FUNC(sctp_sf_t5_timer_expire), \
>  	/* SCTP_STATE_SHUTDOWN_SENT */ \
>  	TYPE_SCTP_FUNC(sctp_sf_t5_timer_expire), \
>  	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
> 

