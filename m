From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next] sctp: support per-association stats via a new
 SCTP_GET_ASSOC_STATS call
Date: Fri, 26 Oct 2012 16:00:05 -0400
Message-ID: <508AEBC5.6090909@gmail.com>
References: <1351258973-17227-1-git-send-email-michele@acksyn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Michele Baldessari <michele@acksyn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:39100 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966279Ab2JZUAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 16:00:09 -0400
In-Reply-To: <1351258973-17227-1-git-send-email-michele@acksyn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2012 09:42 AM, Michele Baldessari wrote:
> The current SCTP stack is lacking an API to have per association
> statistics. This is a kernel implementation modeled after OpenSolaris'
> SCTP_GET_ASSOC_STATS.
>
> Userspace part will follow on lksctp if/when there is a general ACK on this.
>
> Signed-off-by: Michele Baldessari <michele@acksyn.org>
> Acked-by: Thomas Graf <tgraf@suug.ch>
> ---
>   include/net/sctp/sctp.h    |  3 +++
>   include/net/sctp/structs.h | 39 +++++++++++++++++++++++++++
>   include/net/sctp/user.h    | 26 ++++++++++++++++++
>   net/sctp/associola.c       | 20 ++++++++++++++
>   net/sctp/endpointola.c     |  5 +++-
>   net/sctp/input.c           |  5 ++--
>   net/sctp/output.c          |  5 ++++
>   net/sctp/outqueue.c        | 12 +++++++++
>   net/sctp/sm_sideeffect.c   |  2 ++
>   net/sctp/sm_statefuns.c    | 12 +++++++--
>   net/sctp/socket.c          | 67 ++++++++++++++++++++++++++++++++++++++++++++++
>   net/sctp/transport.c       |  2 ++
>   12 files changed, 193 insertions(+), 5 deletions(-)
>
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index 9c6414f..e2248de 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -272,6 +272,9 @@ struct sctp_mib {
>           unsigned long   mibs[SCTP_MIB_MAX];
>   };
>
> +#define SCTP_MAX_RTO(asoc, transport)				\
> +	(asoc)->max_obs_rto = max((__u64)(transport)->rto,	\
> +			(asoc)->max_obs_rto);
>
>   /* Print debugging messages.  */
>   #if SCTP_DEBUG
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 64158aa..8afcb57 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -1829,6 +1829,45 @@ struct sctp_association {
>
>   	__u8 need_ecne:1,	/* Need to send an ECNE Chunk? */
>   	     temp:1;		/* Is it a temporary association? */
> +
> +	/* Total In and Out SACKs received and sent */
> +	__u64 isacks;
> +	__u64 osacks;
> +
> +	/* Total In and Out packets received and sent */
> +	__u64 opackets;
> +	__u64 ipackets;
> +
> +	/* Total retransmitted chunks and packets */
> +	__u64 rtxchunks;
> +	__u64 rtxpackets;

rtxpackes don't make sense as Neil already pointed out.

> +
> +	/* TSN received > next expected */
> +	__u64 outseqtsns;

the name is confusing.  One could interpret it as outgoing sequential 
tsns...

> +
> +	/* Duplicate Chunks received */
> +	__u64 idupchunks;

Do you need dups sent too?  Could be a usefull statistics.

> +
> +	/* Gap Ack Blocks received */
> +	__u64 gapcnt;
> +
> +	/* Unordered data chunks sent and received */
> +	__u64 ouodchunks;
> +	__u64 iuodchunks;
> +
> +	/* Ordered data chunks sent and received */
> +	__u64 oodchunks;
> +	__u64 iodchunks;
> +
> +	/* Control chunks sent and received */
> +	__u64 octrlchunks;
> +	__u64 ictrlchunks;
> +
> +	/* Maximum observed rto in the association. Value is unchanged
> +	 * when read and the max rto did not change
> +	 */
> +	__u64 max_obs_rto;
> +	__u64 max_prev_obs_rto;

One thing I'd say is that this grows an already large structure rather 
significantly.  Could we perhaps put it in its own structure?

>   };
>
>
> diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
> index 1b02d7a..c1715e2 100644
> --- a/include/net/sctp/user.h
> +++ b/include/net/sctp/user.h
> @@ -94,6 +94,7 @@ typedef __s32 sctp_assoc_t;
>   #define SCTP_GET_ASSOC_ID_LIST	29	/* Read only */
>   #define SCTP_AUTO_ASCONF       30
>   #define SCTP_PEER_ADDR_THLDS	31
> +#define SCTP_GET_ASSOC_STATS	32	/* Read only */
>
>   /* Internal Socket Options. Some of the sctp library functions are
>    * implemented using these socket options.
> @@ -719,6 +720,31 @@ struct sctp_getaddrs {
>   	__u8			addrs[0]; /*output, variable size*/
>   };
>
> +/* A socket user request obtained via SCTP_GET_ASSOC_STATS that retrieves
> + * local per endpoint association stats. All stats are counts except
> + * sas_maxrto, which is the max value since the last user request for
> + * stats on this endpoint.
> + */
> +struct sctp_assoc_stats {
> +	sctp_assoc_t	sas_assoc_id;    /* Input */
> +	__u64		sas_rtxchunks;   /* Retransmitted Chunks */
> +	__u64		sas_gapcnt;      /* Gap Acknowledgements Received */
> +	__u64		sas_outseqtsns;  /* TSN received > next expected */
> +	__u64		sas_osacks;	 /* SACKs sent */
> +	__u64		sas_isacks;	 /* SACKs received */
> +	__u64		sas_octrlchunks; /* Control chunks sent */
> +	__u64		sas_ictrlchunks; /* Control chunks received */
> +	__u64		sas_oodchunks;	 /* Ordered data chunks sent */
> +	__u64		sas_iodchunks;	 /* Ordered data chunks received */
> +	__u64		sas_ouodchunks;  /* Unordered data chunks sent */
> +	__u64		sas_iuodchunks;  /* Unordered data chunks received */
> +	__u64		sas_idupchunks;  /* Dups received (ordered+unordered) */
> +	__u64		sas_opackets;	 /* Packets sent */
> +	__u64		sas_ipackets;	 /* Packets received */
> +	__u64		sas_rtxpackets;  /* Packets retransmitted */
> +	__u64		sas_maxrto;      /* Maximum Observed RTO for period */
> +};
> +
>   /* These are bit fields for msghdr->msg_flags.  See section 5.1.  */
>   /* On user space Linux, these live in <bits/socket.h> as an enum.  */
>   enum sctp_msg_flags {
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index b1ef3bc..8560048 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -321,6 +321,25 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
>   	asoc->default_timetolive = sp->default_timetolive;
>   	asoc->default_rcv_context = sp->default_rcv_context;
>
> +	/* SCTP_GET_ASSOC_STATS COUNTERS */
> +	asoc->isacks = 0;
> +	asoc->osacks = 0;
> +	asoc->opackets = 0;
> +	asoc->ipackets = 0;
> +	asoc->rtxpackets = 0;
> +	asoc->rtxchunks = 0;
> +	asoc->outseqtsns = 0;
> +	asoc->idupchunks = 0;
> +	asoc->gapcnt = 0;
> +	asoc->ouodchunks = 0;
> +	asoc->iuodchunks = 0;
> +	asoc->oodchunks = 0;
> +	asoc->iodchunks = 0;
> +	asoc->octrlchunks = 0;
> +	asoc->ictrlchunks = 0;
> +	asoc->max_obs_rto = 0;
> +	asoc->max_prev_obs_rto = 0;
> +
>   	/* AUTH related initializations */
>   	INIT_LIST_HEAD(&asoc->endpoint_shared_keys);
>   	err = sctp_auth_asoc_copy_shkeys(ep, asoc, gfp);
> @@ -760,6 +779,7 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
>
>   	/* Set the transport's RTO.initial value */
>   	peer->rto = asoc->rto_initial;
> +	SCTP_MAX_RTO(asoc, peer);
>
>   	/* Set the peer's active state. */
>   	peer->state = peer_state;
> diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
> index 1859e2b..b89731e 100644
> --- a/net/sctp/endpointola.c
> +++ b/net/sctp/endpointola.c
> @@ -480,8 +480,11 @@ normal:
>   		 */
>   		if (asoc && sctp_chunk_is_data(chunk))
>   			asoc->peer.last_data_from = chunk->transport;
> -		else
> +		else {
>   			SCTP_INC_STATS(sock_net(ep->base.sk), SCTP_MIB_INCTRLCHUNKS);
> +			if (asoc)
> +				asoc->ictrlchunks++;
> +		}
>
>   		if (chunk->transport)
>   			chunk->transport->last_time_heard = jiffies;
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index 8bd3c27..3c32ca5 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -285,9 +285,10 @@ int sctp_rcv(struct sk_buff *skb)
>   	sctp_bh_unlock_sock(sk);
>
>   	/* Release the asoc/ep ref we took in the lookup calls. */
> -	if (asoc)
> +	if (asoc) {
> +		asoc->ipackets++;
>   		sctp_association_put(asoc);

This should probably be done under lock.  Doing it without a lock will
cause you to potentially miscount.

> -	else
> +	} else
>   		sctp_endpoint_put(ep);
>
>   	return 0;
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 4e90188bf..ca5ce50 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -311,6 +311,8 @@ static sctp_xmit_t __sctp_packet_append_chunk(struct sctp_packet *packet,
>
>   	    case SCTP_CID_SACK:
>   		packet->has_sack = 1;
> +		if (chunk->asoc)
> +			chunk->asoc->osacks++;
>   		break;
>
>   	    case SCTP_CID_AUTH:
> @@ -591,6 +593,9 @@ int sctp_packet_transmit(struct sctp_packet *packet)
>   		asoc->peer.last_sent_to = tp;
>   	}
>
> +	if (asoc)
> +		asoc->opackets++;
> +

Testing for assoc again.  Can you fold that into the check just above 
that already checks the assoc.

>   	if (has_data) {
>   		struct timer_list *timer;
>   		unsigned long timeout;
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 1b4a7f8..569ee3a 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -667,6 +667,8 @@ redo:
>   				chunk->fast_retransmit = SCTP_DONT_FRTX;
>
>   			q->empty = 0;
> +			if (q->asoc)
> +				q->asoc->rtxchunks++;

You can't have a queue without association so check for association is 
not necessary.

>   			break;
>   		}
>
> @@ -678,6 +680,10 @@ redo:
>   			break;
>   	}
>
> +	if (q->asoc)
> +		q->asoc->rtxpackets++;
> +
> +

Ditto.

>   	/* If we are here due to a retransmit timeout or a fast
>   	 * retransmit and if there are any chunks left in the retransmit
>   	 * queue that could not fit in the PMTU sized packet, they need
> @@ -883,6 +889,7 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
>   				 */
>   				sctp_transport_reset_timers(transport);
>   			}
> +			asoc->octrlchunks++;
>   			break;

You will count the chunk even if it was not transmitted.  See the
!= SCTP_XMIT_OK code just above this.

>
>   		default:
> @@ -1055,6 +1062,10 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
>   				 */
>   				if (asoc->state == SCTP_STATE_SHUTDOWN_PENDING)
>   					chunk->chunk_hdr->flags |= SCTP_DATA_SACK_IMM;
> +				if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
> +					asoc->ouodchunks++;
> +				else
> +					asoc->oodchunks++;

This is inconsistent with how you treat control chunks.  You could these 
when they are simply queued to the output queue.  You could control 
chunks when they are taken from the control queue and transmitted. 
Please make these consistent.

>
>   				break;
>
> @@ -1162,6 +1173,7 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_chunk *chunk)
>
>   	sack_ctsn = ntohl(sack->cum_tsn_ack);
>   	gap_ack_blocks = ntohs(sack->num_gap_ack_blocks);
> +	asoc->gapcnt += gap_ack_blocks;
>   	/*
>   	 * SFR-CACC algorithm:
>   	 * On receipt of a SACK the sender SHOULD execute the
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index 6773d78..ed49431 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -542,6 +542,7 @@ static void sctp_do_8_2_transport_strike(sctp_cmd_seq_t *commands,
>   	 */
>   	if (!is_hb || transport->hb_sent) {
>   		transport->rto = min((transport->rto * 2), transport->asoc->rto_max);
> +		SCTP_MAX_RTO(asoc, transport);
>   	}
>   }
>
> @@ -1330,6 +1331,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>
>   		case SCTP_CMD_PROCESS_SACK:
>   			/* Process an inbound SACK.  */
> +			asoc->isacks++;

You are going to count SHUTDOWNs as SACKs.


>   			error = sctp_cmd_process_sack(commands, asoc,
>   						      cmd->obj.ptr);
>   			break;
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index b6adef8..4f94432 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -6127,9 +6127,13 @@ static int sctp_eat_data(const struct sctp_association *asoc,
>   		/* The TSN is too high--silently discard the chunk and
>   		 * count on it getting retransmitted later.
>   		 */
> +		if (chunk->asoc)
> +			chunk->asoc->outseqtsns++;
>   		return SCTP_IERROR_HIGH_TSN;
>   	} else if (tmp > 0) {
>   		/* This is a duplicate.  Record it.  */
> +		if (chunk->asoc)
> +			chunk->asoc->idupchunks++;
>   		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_DUP, SCTP_U32(tsn));
>   		return SCTP_IERROR_DUP_TSN;

The REPORT_DUP command already records all the dups we got.  Why not 
simply update the idupchunks whenever we respond with a SACK at the end 
of the packet?  Dup TSNs force a sack to be sent.

This way you are not constantly updating the value if the packet 
contains lots of small duplicate chunks.

>   	}
> @@ -6226,10 +6230,14 @@ static int sctp_eat_data(const struct sctp_association *asoc,
>   	/* Note: Some chunks may get overcounted (if we drop) or overcounted
>   	 * if we renege and the chunk arrives again.
>   	 */
> -	if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
> +	if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED) {
>   		SCTP_INC_STATS(net, SCTP_MIB_INUNORDERCHUNKS);
> -	else {
> +		if (chunk->asoc)
> +			chunk->asoc->iuodchunks++;
> +	} else {
>   		SCTP_INC_STATS(net, SCTP_MIB_INORDERCHUNKS);
> +		if (chunk->asoc)
> +			chunk->asoc->iodchunks++;
>   		ordered = 1;
>   	}
>
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 59d16ea..ca6d0a1 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -610,6 +610,7 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
>   				    2*asoc->pathmtu, 4380));
>   				trans->ssthresh = asoc->peer.i.a_rwnd;
>   				trans->rto = asoc->rto_initial;
> +				SCTP_MAX_RTO(asoc, trans);
>   				trans->rtt = trans->srtt = trans->rttvar = 0;
>   				sctp_transport_route(trans, NULL,
>   				    sctp_sk(asoc->base.sk));
> @@ -5632,6 +5633,69 @@ static int sctp_getsockopt_paddr_thresholds(struct sock *sk,
>   	return 0;
>   }
>
> +/*
> + * SCTP_GET_ASSOC_STATS
> + *
> + * This option retrieves local per endpoint statistics. It is modeled
> + * after OpenSolaris' implementation
> + */
> +static int sctp_getsockopt_assoc_stats(struct sock *sk, int len,
> +				       char __user *optval,
> +				       int __user *optlen)
> +{
> +	struct sctp_assoc_stats sas;
> +	struct sctp_association *asoc = NULL;
> +
> +	if (len < sizeof(struct sctp_assoc_stats))
> +		return -EINVAL;

This will make it very hard to grow the structure if there
is a need for more data.  We should probably allow partial
retrieval of data.


-vlad

> +
> +	len = sizeof(struct sctp_assoc_stats);
> +	if (copy_from_user(&sas, optval, len))
> +		return -EFAULT;
> +
> +	asoc = sctp_id2assoc(sk, sas.sas_assoc_id);
> +	if (!asoc)
> +		return -EINVAL;
> +
> +	sas.sas_rtxchunks = asoc->rtxchunks;
> +	sas.sas_gapcnt = asoc->gapcnt;
> +	sas.sas_outseqtsns = asoc->outseqtsns;
> +	sas.sas_osacks = asoc->osacks;
> +	sas.sas_isacks = asoc->isacks;
> +	sas.sas_octrlchunks = asoc->octrlchunks;
> +	sas.sas_ictrlchunks = asoc->ictrlchunks;
> +	sas.sas_oodchunks = asoc->oodchunks;
> +	sas.sas_iodchunks = asoc->iodchunks;
> +	sas.sas_ouodchunks = asoc->ouodchunks;
> +	sas.sas_iuodchunks = asoc->iuodchunks;
> +	sas.sas_idupchunks = asoc->idupchunks;
> +	sas.sas_opackets = asoc->opackets;
> +	sas.sas_ipackets = asoc->ipackets;
> +	sas.sas_rtxpackets = asoc->rtxpackets;
> +
> +	if (asoc->max_obs_rto == 0) /* unchanged during obervation period */
> +		sas.sas_maxrto = asoc->max_prev_obs_rto;
> +	else /* record new period maximum */
> +		sas.sas_maxrto = asoc->max_obs_rto;
> +
> +	/* Record the value sent to the user this period */
> +	asoc->max_prev_obs_rto = sas.sas_maxrto;
> +
> +	/* Mark beginning of a new observation period */
> +	asoc->max_obs_rto = 0;
> +
> +	if (put_user(len, optlen))
> +		return -EFAULT;
> +
> +	SCTP_DEBUG_PRINTK("sctp_getsockopt_assoc_stat(%d): %d\n",
> +			  len, sas.sas_assoc_id);
> +
> +	if (copy_to_user(optval, &sas, len))
> +		return -EFAULT;
> +
> +	return 0;
> +}
> +
>   SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
>   				char __user *optval, int __user *optlen)
>   {
> @@ -5773,6 +5837,9 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
>   	case SCTP_PEER_ADDR_THLDS:
>   		retval = sctp_getsockopt_paddr_thresholds(sk, optval, len, optlen);
>   		break;
> +	case SCTP_GET_ASSOC_STATS:
> +		retval = sctp_getsockopt_assoc_stats(sk, len, optval, optlen);
> +		break;
>   	default:
>   		retval = -ENOPROTOOPT;
>   		break;
> diff --git a/net/sctp/transport.c b/net/sctp/transport.c
> index 953c21e..dd20f6f 100644
> --- a/net/sctp/transport.c
> +++ b/net/sctp/transport.c
> @@ -350,6 +350,7 @@ void sctp_transport_update_rto(struct sctp_transport *tp, __u32 rtt)
>
>   	/* 6.3.1 C3) After the computation, update RTO <- SRTT + 4 * RTTVAR. */
>   	tp->rto = tp->srtt + (tp->rttvar << 2);
> +	SCTP_MAX_RTO(tp->asoc, tp);
>
>   	/* 6.3.1 C6) Whenever RTO is computed, if it is less than RTO.Min
>   	 * seconds then it is rounded up to RTO.Min seconds.
> @@ -620,6 +621,7 @@ void sctp_transport_reset(struct sctp_transport *t)
>   	t->burst_limited = 0;
>   	t->ssthresh = asoc->peer.i.a_rwnd;
>   	t->rto = asoc->rto_initial;
> +	SCTP_MAX_RTO(asoc, t);
>   	t->rtt = 0;
>   	t->srtt = 0;
>   	t->rttvar = 0;
>
