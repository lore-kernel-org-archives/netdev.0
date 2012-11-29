From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v3 net-next] sctp: Add support to per-association statistics
 via a new SCTP_GET_ASSOC_STATS call
Date: Thu, 29 Nov 2012 12:31:17 -0500
Message-ID: <50B79BE5.7000500@gmail.com>
References: <1354131552-24889-1-git-send-email-michele@acksyn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Michele Baldessari <michele@acksyn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:48585 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518Ab2K2RbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 12:31:22 -0500
In-Reply-To: <1354131552-24889-1-git-send-email-michele@acksyn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2012 02:39 PM, Michele Baldessari wrote:

> diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
> index 397296f..7edc89d 100644
> --- a/net/sctp/inqueue.c
> +++ b/net/sctp/inqueue.c
> @@ -105,6 +105,9 @@ void sctp_inq_push(struct sctp_inq *q, struct sctp_chunk *chunk)
>   	 */
>   	list_add_tail(&chunk->list, &q->in_chunk_list);
>   	q->immediate.func(&q->immediate);
> +
> +	if (chunk->asoc)
> +		chunk->asoc->stats.ipackets++;

you may want to consider putting this before the immediate.func() call, 
so that you record an incoming packet before it's fully processed.  This
would mimic the behavior of the rest of the stats you are collecting, as
you typically increment the stat and then process the data.

>   }
>
>   /* Peek at the next chunk on the inqeue. */

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
> +	/* User must provide at least the assoc id */
> +	if (len < sizeof(sctp_assoc_t))
> +		return -EINVAL;
> +
> +	if (copy_from_user(&sas, optval, len))
> +		return -EFAULT;
> +
> +	asoc = sctp_id2assoc(sk, sas.sas_assoc_id);
> +	if (!asoc)
> +		return -EINVAL;
> +
> +	sas.sas_rtxchunks = asoc->stats.rtxchunks;
> +	sas.sas_gapcnt = asoc->stats.gapcnt;
> +	sas.sas_outofseqtsns = asoc->stats.outofseqtsns;
> +	sas.sas_osacks = asoc->stats.osacks;
> +	sas.sas_isacks = asoc->stats.isacks;
> +	sas.sas_octrlchunks = asoc->stats.octrlchunks;
> +	sas.sas_ictrlchunks = asoc->stats.ictrlchunks;
> +	sas.sas_oodchunks = asoc->stats.oodchunks;
> +	sas.sas_iodchunks = asoc->stats.iodchunks;
> +	sas.sas_ouodchunks = asoc->stats.ouodchunks;
> +	sas.sas_iuodchunks = asoc->stats.iuodchunks;
> +	sas.sas_idupchunks = asoc->stats.idupchunks;
> +	sas.sas_opackets = asoc->stats.opackets;
> +	sas.sas_ipackets = asoc->stats.ipackets;
> +
> +	/* New high max rto observed, will return 0 if not a single
> +	 * RTO update took place. obs_rto_ipaddr will be bogus
> +	 * in such a case
> +	 */
> +	sas.sas_maxrto = asoc->stats.max_obs_rto;
> +	memcpy(&sas.sas_obs_rto_ipaddr, &asoc->stats.obs_rto_ipaddr,
> +		sizeof(struct sockaddr_storage));
> +
> +	/* Mark beginning of a new observation period */
> +	asoc->stats.max_obs_rto = 0;

Ok.  That's better.  If there are 2 fast queries you get 0 on the 
second, but that still feels a bit strange to me.  I think resetting
max_obs_rto to rto_min might make more sense.  rto_min is the low bound
and rto can't go below that.  So, on the next rto measurement, that'll
be the smallest value of max_obs_rto.  IMO, it might be better to reset
the max_obs_rto to rto_min, so that
  1) We always see a valid rto value in the field.
  2) We can more easily see the variances in rto over time.

What do you think?

-vlad
> +
> +	/* Allow the struct to grow and fill in as much as possible */
> +	len = min_t(size_t, len, sizeof(sas));
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
> @@ -5776,6 +5842,9 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
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
> index 953c21e..8c6920d 100644
> --- a/net/sctp/transport.c
> +++ b/net/sctp/transport.c
> @@ -350,6 +350,7 @@ void sctp_transport_update_rto(struct sctp_transport *tp, __u32 rtt)
>
>   	/* 6.3.1 C3) After the computation, update RTO <- SRTT + 4 * RTTVAR. */
>   	tp->rto = tp->srtt + (tp->rttvar << 2);
> +	sctp_max_rto(tp->asoc, tp);
>
>   	/* 6.3.1 C6) Whenever RTO is computed, if it is less than RTO.Min
>   	 * seconds then it is rounded up to RTO.Min seconds.
> @@ -620,6 +621,7 @@ void sctp_transport_reset(struct sctp_transport *t)
>   	t->burst_limited = 0;
>   	t->ssthresh = asoc->peer.i.a_rwnd;
>   	t->rto = asoc->rto_initial;
> +	sctp_max_rto(asoc, t);
>   	t->rtt = 0;
>   	t->srtt = 0;
>   	t->rttvar = 0;
>
