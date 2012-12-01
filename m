From: Michele Baldessari <michele@acksyn.org>
Subject: Re: [PATCH v3 net-next] sctp: Add support to per-association
 statistics via a new SCTP_GET_ASSOC_STATS call
Date: Sat, 1 Dec 2012 15:36:42 +0100
Message-ID: <20121201143642.GA14332@marquez.int.rhx>
References: <1354131552-24889-1-git-send-email-michele@acksyn.org>
 <50B79BE5.7000500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palahniuk.acksyn.org ([5.9.7.26]:38490 "EHLO
	palahniuk.acksyn.org" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751644Ab2LAOgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 09:36:52 -0500
Content-Disposition: inline
In-Reply-To: <50B79BE5.7000500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad,

On Thu, Nov 29, 2012 at 12:31:17PM -0500, Vlad Yasevich wrote:
> On 11/28/2012 02:39 PM, Michele Baldessari wrote:
> 
> >diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
> >index 397296f..7edc89d 100644
> >--- a/net/sctp/inqueue.c
> >+++ b/net/sctp/inqueue.c
> >@@ -105,6 +105,9 @@ void sctp_inq_push(struct sctp_inq *q, struct sctp_chunk *chunk)
> >  	 */
> >  	list_add_tail(&chunk->list, &q->in_chunk_list);
> >  	q->immediate.func(&q->immediate);
> >+
> >+	if (chunk->asoc)
> >+		chunk->asoc->stats.ipackets++;
> 
> you may want to consider putting this before the immediate.func()
> call, so that you record an incoming packet before it's fully
> processed.  This
> would mimic the behavior of the rest of the stats you are collecting, as
> you typically increment the stat and then process the data.

ok, makes sense.

> >  }
> >
> >  /* Peek at the next chunk on the inqeue. */
> 
> >
> >+/*
> >+ * SCTP_GET_ASSOC_STATS
> >+ *
> >+ * This option retrieves local per endpoint statistics. It is modeled
> >+ * after OpenSolaris' implementation
> >+ */
> >+static int sctp_getsockopt_assoc_stats(struct sock *sk, int len,
> >+				       char __user *optval,
> >+				       int __user *optlen)
> >+{
> >+	struct sctp_assoc_stats sas;
> >+	struct sctp_association *asoc = NULL;
> >+
> >+	/* User must provide at least the assoc id */
> >+	if (len < sizeof(sctp_assoc_t))
> >+		return -EINVAL;
> >+
> >+	if (copy_from_user(&sas, optval, len))
> >+		return -EFAULT;
> >+
> >+	asoc = sctp_id2assoc(sk, sas.sas_assoc_id);
> >+	if (!asoc)
> >+		return -EINVAL;
> >+
> >+	sas.sas_rtxchunks = asoc->stats.rtxchunks;
> >+	sas.sas_gapcnt = asoc->stats.gapcnt;
> >+	sas.sas_outofseqtsns = asoc->stats.outofseqtsns;
> >+	sas.sas_osacks = asoc->stats.osacks;
> >+	sas.sas_isacks = asoc->stats.isacks;
> >+	sas.sas_octrlchunks = asoc->stats.octrlchunks;
> >+	sas.sas_ictrlchunks = asoc->stats.ictrlchunks;
> >+	sas.sas_oodchunks = asoc->stats.oodchunks;
> >+	sas.sas_iodchunks = asoc->stats.iodchunks;
> >+	sas.sas_ouodchunks = asoc->stats.ouodchunks;
> >+	sas.sas_iuodchunks = asoc->stats.iuodchunks;
> >+	sas.sas_idupchunks = asoc->stats.idupchunks;
> >+	sas.sas_opackets = asoc->stats.opackets;
> >+	sas.sas_ipackets = asoc->stats.ipackets;
> >+
> >+	/* New high max rto observed, will return 0 if not a single
> >+	 * RTO update took place. obs_rto_ipaddr will be bogus
> >+	 * in such a case
> >+	 */
> >+	sas.sas_maxrto = asoc->stats.max_obs_rto;
> >+	memcpy(&sas.sas_obs_rto_ipaddr, &asoc->stats.obs_rto_ipaddr,
> >+		sizeof(struct sockaddr_storage));
> >+
> >+	/* Mark beginning of a new observation period */
> >+	asoc->stats.max_obs_rto = 0;
> 
> Ok.  That's better.  If there are 2 fast queries you get 0 on the
> second, but that still feels a bit strange to me.  I think resetting
> max_obs_rto to rto_min might make more sense.  rto_min is the low bound
> and rto can't go below that.  So, on the next rto measurement, that'll
> be the smallest value of max_obs_rto.  IMO, it might be better to reset
> the max_obs_rto to rto_min, so that
>  1) We always see a valid rto value in the field.
>  2) We can more easily see the variances in rto over time.
> 
> What do you think?

I agree, it makes more sense (will send an updated version shortly)

thanks,
Michele
-- 
Michele Baldessari            <michele@acksyn.org>
C2A5 9DA3 9961 4FFB E01B  D0BC DDD4 DCCB 7515 5C6D
