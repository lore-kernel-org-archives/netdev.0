From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2] sctp: Clean up type-punning in sctp_cmd_t union
Date: Fri, 26 Oct 2012 15:12:54 -0400
Message-ID: <508AE0B6.2020506@gmail.com>
References: <1351198075-20385-1-git-send-email-nhorman@tuxdriver.com> <1351258876-32078-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:55397 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966076Ab2JZTM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 15:12:57 -0400
In-Reply-To: <1351258876-32078-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2012 09:41 AM, Neil Horman wrote:
> Lots of points in the sctp_cmd_interpreter function treat the sctp_cmd_t arg as
> a void pointer, even though they are written as various other types.  Theres no
> need for this as doing so just leads to possible type-punning issues that could
> cause crashes, and if we remain type-consistent we can actually just remove the
> void * member of the union entirely.
>
> Change Notes:
>
> v2)
> 	* Dropped chunk that modified SCTP_NULL to create a marker pattern
> 	 should anyone try to use a SCTP_NULL() assigned sctp_arg_t, Assigning
> 	 to .zero provides the same effect and should be faster, per Vlad Y.
>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com
> CC: Vlad Yasevich <vyasevich@gmail.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> CC: "David S. Miller" <davem@davemloft.net>
> CC: linux-sctp@vger.kernel.org
> ---
>   include/net/sctp/command.h  |  4 +---
>   include/net/sctp/ulpqueue.h |  2 +-
>   net/sctp/sm_sideeffect.c    | 45 ++++++++++++++++++++++-----------------------
>   net/sctp/ulpqueue.c         |  3 +--
>   4 files changed, 25 insertions(+), 29 deletions(-)
>
> diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
> index 712b3be..8d52cd7 100644
> --- a/include/net/sctp/command.h
> +++ b/include/net/sctp/command.h
> @@ -131,7 +131,6 @@ typedef union {
>   	sctp_state_t state;
>   	sctp_event_timeout_t to;
>   	unsigned long zero;
> -	void *ptr;
>   	struct sctp_chunk *chunk;
>   	struct sctp_association *asoc;
>   	struct sctp_transport *transport;
> @@ -156,7 +155,7 @@ typedef union {
>    */
>   static inline sctp_arg_t SCTP_NULL(void)
>   {
> -	sctp_arg_t retval; retval.ptr = NULL; return retval;
> +	sctp_arg_t retval = { .zero = 0UL}; return retval;
>   }
>   static inline sctp_arg_t SCTP_NOFORCE(void)
>   {
> @@ -181,7 +180,6 @@ SCTP_ARG_CONSTRUCTOR(ERROR,     int, error)
>   SCTP_ARG_CONSTRUCTOR(PERR,      __be16, err)	/* protocol error */
>   SCTP_ARG_CONSTRUCTOR(STATE,	sctp_state_t, state)
>   SCTP_ARG_CONSTRUCTOR(TO,	sctp_event_timeout_t, to)
> -SCTP_ARG_CONSTRUCTOR(PTR,	void *, ptr)
>   SCTP_ARG_CONSTRUCTOR(CHUNK,	struct sctp_chunk *, chunk)
>   SCTP_ARG_CONSTRUCTOR(ASOC,	struct sctp_association *, asoc)
>   SCTP_ARG_CONSTRUCTOR(TRANSPORT,	struct sctp_transport *, transport)
> diff --git a/include/net/sctp/ulpqueue.h b/include/net/sctp/ulpqueue.h
> index 2e5ee0d..ff1b8ba7 100644
> --- a/include/net/sctp/ulpqueue.h
> +++ b/include/net/sctp/ulpqueue.h
> @@ -72,7 +72,7 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *, struct sctp_ulpevent *ev);
>   void sctp_ulpq_renege(struct sctp_ulpq *, struct sctp_chunk *, gfp_t);
>
>   /* Perform partial delivery. */
> -void sctp_ulpq_partial_delivery(struct sctp_ulpq *, struct sctp_chunk *, gfp_t);
> +void sctp_ulpq_partial_delivery(struct sctp_ulpq *, gfp_t);
>
>   /* Abort the partial delivery. */
>   void sctp_ulpq_abort_pd(struct sctp_ulpq *, gfp_t);
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index 6773d78..6eecf7e 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -1268,14 +1268,14 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>   				sctp_outq_uncork(&asoc->outqueue);
>   				local_cork = 0;
>   			}
> -			asoc = cmd->obj.ptr;
> +			asoc = cmd->obj.asoc;
>   			/* Register with the endpoint.  */
>   			sctp_endpoint_add_asoc(ep, asoc);
>   			sctp_hash_established(asoc);
>   			break;
>
>   		case SCTP_CMD_UPDATE_ASSOC:
> -		       sctp_assoc_update(asoc, cmd->obj.ptr);
> +		       sctp_assoc_update(asoc, cmd->obj.asoc);
>   		       break;
>
>   		case SCTP_CMD_PURGE_OUTQUEUE:
> @@ -1315,7 +1315,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>   			break;
>
>   		case SCTP_CMD_PROCESS_FWDTSN:
> -			sctp_cmd_process_fwdtsn(&asoc->ulpq, cmd->obj.ptr);
> +			sctp_cmd_process_fwdtsn(&asoc->ulpq, cmd->obj.chunk);
>   			break;
>
>   		case SCTP_CMD_GEN_SACK:
> @@ -1331,7 +1331,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>   		case SCTP_CMD_PROCESS_SACK:
>   			/* Process an inbound SACK.  */
>   			error = sctp_cmd_process_sack(commands, asoc,
> -						      cmd->obj.ptr);
> +						      cmd->obj.chunk);
>   			break;
>
>   		case SCTP_CMD_GEN_INIT_ACK:
> @@ -1352,15 +1352,15 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>   			 * layer which will bail.
>   			 */
>   			error = sctp_cmd_process_init(commands, asoc, chunk,
> -						      cmd->obj.ptr, gfp);
> +						      cmd->obj.init, gfp);
>   			break;
>
>   		case SCTP_CMD_GEN_COOKIE_ECHO:
>   			/* Generate a COOKIE ECHO chunk.  */
>   			new_obj = sctp_make_cookie_echo(asoc, chunk);
>   			if (!new_obj) {
> -				if (cmd->obj.ptr)
> -					sctp_chunk_free(cmd->obj.ptr);
> +				if (cmd->obj.chunk)
> +					sctp_chunk_free(cmd->obj.chunk);
>   				goto nomem;
>   			}
>   			sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
> @@ -1369,9 +1369,9 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>   			/* If there is an ERROR chunk to be sent along with
>   			 * the COOKIE_ECHO, send it, too.
>   			 */
> -			if (cmd->obj.ptr)
> +			if (cmd->obj.chunk)
>   				sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
> -						SCTP_CHUNK(cmd->obj.ptr));
> +						SCTP_CHUNK(cmd->obj.chunk));
>
>   			if (new_obj->transport) {
>   				new_obj->transport->init_sent_count++;
> @@ -1417,18 +1417,18 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>   		case SCTP_CMD_CHUNK_ULP:
>   			/* Send a chunk to the sockets layer.  */
>   			SCTP_DEBUG_PRINTK("sm_sideff: %s %p, %s %p.\n",
> -					  "chunk_up:", cmd->obj.ptr,
> +					  "chunk_up:", cmd->obj.chunk,
>   					  "ulpq:", &asoc->ulpq);
> -			sctp_ulpq_tail_data(&asoc->ulpq, cmd->obj.ptr,
> +			sctp_ulpq_tail_data(&asoc->ulpq, cmd->obj.chunk,
>   					    GFP_ATOMIC);
>   			break;
>
>   		case SCTP_CMD_EVENT_ULP:
>   			/* Send a notification to the sockets layer.  */
>   			SCTP_DEBUG_PRINTK("sm_sideff: %s %p, %s %p.\n",
> -					  "event_up:",cmd->obj.ptr,
> +					  "event_up:",cmd->obj.ulpevent,
>   					  "ulpq:",&asoc->ulpq);
> -			sctp_ulpq_tail_event(&asoc->ulpq, cmd->obj.ptr);
> +			sctp_ulpq_tail_event(&asoc->ulpq, cmd->obj.ulpevent);
>   			break;
>
>   		case SCTP_CMD_REPLY:
> @@ -1438,12 +1438,12 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>   				local_cork = 1;
>   			}
>   			/* Send a chunk to our peer.  */
> -			error = sctp_outq_tail(&asoc->outqueue, cmd->obj.ptr);
> +			error = sctp_outq_tail(&asoc->outqueue, cmd->obj.chunk);
>   			break;
>
>   		case SCTP_CMD_SEND_PKT:
>   			/* Send a full packet to our peer.  */
> -			packet = cmd->obj.ptr;
> +			packet = cmd->obj.packet;
>   			sctp_packet_transmit(packet);
>   			sctp_ootb_pkt_free(packet);
>   			break;
> @@ -1480,7 +1480,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>   			break;
>
>   		case SCTP_CMD_SETUP_T2:
> -			sctp_cmd_setup_t2(commands, asoc, cmd->obj.ptr);
> +			sctp_cmd_setup_t2(commands, asoc, cmd->obj.chunk);
>   			break;
>
>   		case SCTP_CMD_TIMER_START_ONCE:
> @@ -1514,7 +1514,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>   			break;
>
>   		case SCTP_CMD_INIT_CHOOSE_TRANSPORT:
> -			chunk = cmd->obj.ptr;
> +			chunk = cmd->obj.chunk;
>   			t = sctp_assoc_choose_alter_transport(asoc,
>   						asoc->init_last_sent_to);
>   			asoc->init_last_sent_to = t;
> @@ -1665,17 +1665,16 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>   			break;
>
>   		case SCTP_CMD_PART_DELIVER:
> -			sctp_ulpq_partial_delivery(&asoc->ulpq, cmd->obj.ptr,
> -						   GFP_ATOMIC);
> +			sctp_ulpq_partial_delivery(&asoc->ulpq, GFP_ATOMIC);
>   			break;
>
>   		case SCTP_CMD_RENEGE:
> -			sctp_ulpq_renege(&asoc->ulpq, cmd->obj.ptr,
> +			sctp_ulpq_renege(&asoc->ulpq, cmd->obj.chunk,
>   					 GFP_ATOMIC);
>   			break;
>
>   		case SCTP_CMD_SETUP_T4:
> -			sctp_cmd_setup_t4(commands, asoc, cmd->obj.ptr);
> +			sctp_cmd_setup_t4(commands, asoc, cmd->obj.chunk);
>   			break;
>
>   		case SCTP_CMD_PROCESS_OPERR:
> @@ -1734,8 +1733,8 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>   			break;
>
>   		default:
> -			pr_warn("Impossible command: %u, %p\n",
> -				cmd->verb, cmd->obj.ptr);
> +			pr_warn("Impossible command: %u\n",
> +				cmd->verb);
>   			break;
>   		}
>
> diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
> index 360d869..ada1746 100644
> --- a/net/sctp/ulpqueue.c
> +++ b/net/sctp/ulpqueue.c
> @@ -997,7 +997,6 @@ static __u16 sctp_ulpq_renege_frags(struct sctp_ulpq *ulpq, __u16 needed)
>
>   /* Partial deliver the first message as there is pressure on rwnd. */
>   void sctp_ulpq_partial_delivery(struct sctp_ulpq *ulpq,
> -				struct sctp_chunk *chunk,
>   				gfp_t gfp)
>   {
>   	struct sctp_ulpevent *event;
> @@ -1060,7 +1059,7 @@ void sctp_ulpq_renege(struct sctp_ulpq *ulpq, struct sctp_chunk *chunk,
>   		sctp_tsnmap_mark(&asoc->peer.tsn_map, tsn, chunk->transport);
>   		sctp_ulpq_tail_data(ulpq, chunk, gfp);
>
> -		sctp_ulpq_partial_delivery(ulpq, chunk, gfp);
> +		sctp_ulpq_partial_delivery(ulpq, gfp);
>   	}
>
>   	sk_mem_reclaim(asoc->base.sk);
>
