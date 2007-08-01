From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Lksctp-developers] [PATCH] SCTP: drop SACK if ctsn is not less
 than the next tsn of assoc
Date: Wed, 01 Aug 2007 09:06:13 -0400
Message-ID: <46B08545.8030707@hp.com>
References: <18087.57737.908842.337891@zeus.sw.starentnetworks.com>		<46AEBE2B.1060702@cn.fujitsu.com>		<20070731113709.GA28333@hmsreliant.homelinux.net>	<1185902894.8234.5.camel@localhost.localdomain>	<46AFDC97.6080909@cn.fujitsu.com> <46AFFAB7.8050503@hp.com> <46B05EA9.4090507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	lksctp-developers@lists.sourceforge.net,
	Sridhar Samudrala <sri@us.ibm.com>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:41928 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761576AbXHANGz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2007 09:06:55 -0400
In-Reply-To: <46B05EA9.4090507@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a little better.

One suggestion.  The new function you create is almost exactly like
sctp_sf_violation_chunklen() with the exception of the error string.
Can you extract the common parts into a single function so that
we don't have duplication of code.

Thanks
-vlad

Wei Yongjun wrote:
>>   
>> This is an interesting case, but I am not sure that simply discarding
>> the SACK is the right thing.
>>
>> The peer in this case is violating the protocol whereby he is trying to
>> advance the cumulative tsn ack to a point beyond the max tsn currently
>> sent. I would vote for terminating the association in this case since
>> either the peer is a mis-behaved implementation, or the association is
>> under attack.
> I have modify the patch to abort the association with protocol violation 
> error cause, and new patch is come on. May be this patch is correct.^_^
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> --- net/sctp/sm_statefuns.c.orig	2007-07-29 18:11:01.000000000 -0400
> +++ net/sctp/sm_statefuns.c	2007-07-31 00:29:16.000000000 -0400
> @@ -104,6 +104,13 @@ static sctp_disposition_t sctp_sf_violat
>  				     void *arg,
>  				     sctp_cmd_seq_t *commands);
>  
> +static sctp_disposition_t sctp_sf_violation_ctsn(
> +				     const struct sctp_endpoint *ep,
> +				     const struct sctp_association *asoc,
> +				     const sctp_subtype_t type,
> +				     void *arg,
> +				     sctp_cmd_seq_t *commands);
> +
>  /* Small helper function that checks if the chunk length
>   * is of the appropriate length.  The 'required_length' argument
>   * is set to be the size of a specific chunk we are testing.
> @@ -2880,6 +2887,13 @@ sctp_disposition_t sctp_sf_eat_sack_6_2(
>  		return SCTP_DISPOSITION_DISCARD;
>  	}
>  
> +	/* If Cumulative TSN Ack beyond the max tsn currently
> +	 * send, terminating the association and respond to the 
> +	 * sender with an ABORT.
> +	 */
> +	if (!TSN_lt(ctsn, asoc->next_tsn))
> +		return sctp_sf_violation_ctsn(ep, asoc, type, arg, commands);
> +
>  	/* Return this SACK for further processing.  */
>  	sctp_add_cmd_sf(commands, SCTP_CMD_PROCESS_SACK, SCTP_SACKH(sackh));
>  
> @@ -3756,6 +3770,68 @@ nomem:
>  	return SCTP_DISPOSITION_NOMEM;
>  }
>  
> +/*
> + * Handle a protocol violation when the peer trying to advance the 
> + * cumulative tsn ack to a point beyond the max tsn currently sent.
> + *
> + * We inform the other end by sending an ABORT with a Protocol Violation
> + * error code.
> + *
> + * Section: Not specified
> + * Verification Tag:  Nothing to do
> + * Inputs
> + * (endpoint, asoc, chunk)
> + *
> + * Outputs
> + * (reply_msg, msg_up, counters)
> + *
> + * Generate an  ABORT chunk and terminate the association.
> + */
> +static sctp_disposition_t sctp_sf_violation_ctsn(
> +				     const struct sctp_endpoint *ep,
> +				     const struct sctp_association *asoc,
> +				     const sctp_subtype_t type,
> +				     void *arg,
> +				     sctp_cmd_seq_t *commands)
> +{
> +	struct sctp_chunk *chunk =  arg;
> +	struct sctp_chunk *abort = NULL;
> +	char err_str[] = "The cumulative tsn ack beyond the max tsn currently sent:";
> +
> +	/* Make the abort chunk. */
> +	abort = sctp_make_abort_violation(asoc, chunk, err_str,
> +					  sizeof(err_str));
> +	if (!abort)
> +		goto nomem;
> +
> +	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
> +	SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
> +
> +	if (asoc->state <= SCTP_STATE_COOKIE_ECHOED) {
> +		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
> +				SCTP_TO(SCTP_EVENT_TIMEOUT_T1_INIT));
> +		sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
> +				SCTP_ERROR(ECONNREFUSED));
> +		sctp_add_cmd_sf(commands, SCTP_CMD_INIT_FAILED,
> +				SCTP_PERR(SCTP_ERROR_PROTO_VIOLATION));
> +	} else {
> +		sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
> +				SCTP_ERROR(ECONNABORTED));
> +		sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_FAILED,
> +				SCTP_PERR(SCTP_ERROR_PROTO_VIOLATION));
> +		SCTP_DEC_STATS(SCTP_MIB_CURRESTAB);
> +	}
> +
> +	sctp_add_cmd_sf(commands, SCTP_CMD_DISCARD_PACKET, SCTP_NULL());
> +
> +	SCTP_INC_STATS(SCTP_MIB_ABORTEDS);
> +
> +	return SCTP_DISPOSITION_ABORT;
> +
> +nomem:
> +	return SCTP_DISPOSITION_NOMEM;
> +}
> +
>  /***************************************************************************
>   * These are the state functions for handling primitive (Section 10) events.
>   ***************************************************************************/
> 
> 
> 

