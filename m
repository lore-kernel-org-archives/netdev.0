From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v5] sctp: be more restrictive in transport selection on
 bundled sacks
Date: Fri, 29 Jun 2012 16:19:43 -0400
Message-ID: <4FEE0DDF.60604@gmail.com>
References: <1340742704-2192-1-git-send-email-nhorman@tuxdriver.com> <1341000929-22933-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f42.google.com ([209.85.213.42]:53360 "EHLO
	mail-yw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932189Ab2F2UTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 16:19:48 -0400
In-Reply-To: <1341000929-22933-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/29/2012 04:15 PM, Neil Horman wrote:
> It was noticed recently that when we send data on a transport, its possible that
> we might bundle a sack that arrived on a different transport.  While this isn't
> a major problem, it does go against the SHOULD requirement in section 6.4 of RFC
> 2960:
>
>   An endpoint SHOULD transmit reply chunks (e.g., SACK, HEARTBEAT ACK,
>     etc.) to the same destination transport address from which it
>     received the DATA or control chunk to which it is replying.  This
>     rule should also be followed if the endpoint is bundling DATA chunks
>     together with the reply chunk.
>
> This patch seeks to correct that.  It restricts the bundling of sack operations
> to only those transports which have moved the ctsn of the association forward
> since the last sack.  By doing this we guarantee that we only bundle outbound
> saks on a transport that has received a chunk since the last sack.  This brings
> us into stricter compliance with the RFC.
>
> Vlad had initially suggested that we strictly allow only sack bundling on the
> transport that last moved the ctsn forward.  While this makes sense, I was
> concerned that doing so prevented us from bundling in the case where we had
> received chunks that moved the ctsn on multiple transports.  In those cases, the
> RFC allows us to select any of the transports having received chunks to bundle
> the sack on.  so I've modified the approach to allow for that, by adding a state
> variable to each transport that tracks weather it has moved the ctsn since the
> last sack.  This I think keeps our behavior (and performance), close enough to
> our current profile that I think we can do this without a sysctl knob to
> enable/disable it.
>
> Signed-off-by: Neil Horman<nhorman@tuxdriver.com>
> CC: Vlad Yaseivch<vyasevich@gmail.com>
> CC: David S. Miller<davem@davemloft.net>
> CC: linux-sctp@vger.kernel.org
> Reported-by: Michele Baldessari<michele@redhat.com>
> Reported-by: sorin serban<sserban@redhat.com>
>

Thanks Neil.  Looks good.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
> Change Notes:
> V2)
> 	* Removed unused variable as per Dave M. Request
> 	* Delayed rwnd adjustment until we are sure we will sack (Vlad Y.)
> V3)
> 	* Switched test to use pkt->transport rather than chunk->transport
> 	* Modified detection of sacka-able transport.  Instead of just setting
> 	  and clearning a flag, we now mark each transport and association with
> 	  a sack generation tag.  We increment the associations generation on
> 	  every sack, and assign that generation tag to every transport that
> 	  updates the ctsn.  This prevents us from having to iterate over a for
> 	  loop on every sack, which is much more scalable.
> V4)
> 	* Fixed up wrapping comment and logic
> V5)
> 	* Simplified wrap logic further per request from vlad
> ---
>   include/net/sctp/structs.h |    4 ++++
>   include/net/sctp/tsnmap.h  |    3 ++-
>   net/sctp/associola.c       |    1 +
>   net/sctp/output.c          |    9 +++++++--
>   net/sctp/sm_make_chunk.c   |   17 +++++++++++++++++
>   net/sctp/sm_sideeffect.c   |    2 +-
>   net/sctp/transport.c       |    2 ++
>   net/sctp/tsnmap.c          |    6 +++++-
>   net/sctp/ulpevent.c        |    3 ++-
>   net/sctp/ulpqueue.c        |    2 +-
>   10 files changed, 42 insertions(+), 7 deletions(-)
>
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index e4652fe..fecdf31 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -912,6 +912,9 @@ struct sctp_transport {
>   		/* Is this structure kfree()able? */
>   		malloced:1;
>
> +	/* Has this transport moved the ctsn since we last sacked */
> +	__u32 sack_generation;
> +
>   	struct flowi fl;
>
>   	/* This is the peer's IP address and port. */
> @@ -1584,6 +1587,7 @@ struct sctp_association {
>   		 */
>   		__u8    sack_needed;     /* Do we need to sack the peer? */
>   		__u32	sack_cnt;
> +		__u32	sack_generation;
>
>   		/* These are capabilities which our peer advertised.  */
>   		__u8	ecn_capable:1,	    /* Can peer do ECN? */
> diff --git a/include/net/sctp/tsnmap.h b/include/net/sctp/tsnmap.h
> index e7728bc..2c5d2b4 100644
> --- a/include/net/sctp/tsnmap.h
> +++ b/include/net/sctp/tsnmap.h
> @@ -117,7 +117,8 @@ void sctp_tsnmap_free(struct sctp_tsnmap *map);
>   int sctp_tsnmap_check(const struct sctp_tsnmap *, __u32 tsn);
>
>   /* Mark this TSN as seen.  */
> -int sctp_tsnmap_mark(struct sctp_tsnmap *, __u32 tsn);
> +int sctp_tsnmap_mark(struct sctp_tsnmap *, __u32 tsn,
> +		     struct sctp_transport *trans);
>
>   /* Mark this TSN and all lower as seen. */
>   void sctp_tsnmap_skip(struct sctp_tsnmap *map, __u32 tsn);
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 5bc9ab1..b16517e 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -271,6 +271,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
>   	 */
>   	asoc->peer.sack_needed = 1;
>   	asoc->peer.sack_cnt = 0;
> +	asoc->peer.sack_generation = 1;
>
>   	/* Assume that the peer will tell us if he recognizes ASCONF
>   	 * as part of INIT exchange.
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index f1b7d4b..0de6cd5 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -240,14 +240,19 @@ static sctp_xmit_t sctp_packet_bundle_sack(struct sctp_packet *pkt,
>   	 */
>   	if (sctp_chunk_is_data(chunk)&&  !pkt->has_sack&&
>   	!pkt->has_cookie_echo) {
> -		struct sctp_association *asoc;
>   		struct timer_list *timer;
> -		asoc = pkt->transport->asoc;
> +		struct sctp_association *asoc = pkt->transport->asoc;
> +
>   		timer =&asoc->timers[SCTP_EVENT_TIMEOUT_SACK];
>
>   		/* If the SACK timer is running, we have a pending SACK */
>   		if (timer_pending(timer)) {
>   			struct sctp_chunk *sack;
> +
> +			if (pkt->transport->sack_generation !=
> +			    pkt->transport->asoc->peer.sack_generation)
> +				return retval;
> +
>   			asoc->a_rwnd = asoc->rwnd;
>   			sack = sctp_make_sack(asoc);
>   			if (sack) {
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index a85eeeb..6486cac 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -734,8 +734,10 @@ struct sctp_chunk *sctp_make_sack(const struct sctp_association *asoc)
>   	int len;
>   	__u32 ctsn;
>   	__u16 num_gabs, num_dup_tsns;
> +	struct sctp_association *aptr = (struct sctp_association *)asoc;
>   	struct sctp_tsnmap *map = (struct sctp_tsnmap *)&asoc->peer.tsn_map;
>   	struct sctp_gap_ack_block gabs[SCTP_MAX_GABS];
> +	struct sctp_transport *trans;
>
>   	memset(gabs, 0, sizeof(gabs));
>   	ctsn = sctp_tsnmap_get_ctsn(map);
> @@ -805,6 +807,21 @@ struct sctp_chunk *sctp_make_sack(const struct sctp_association *asoc)
>   		sctp_addto_chunk(retval, sizeof(__u32) * num_dup_tsns,
>   				 sctp_tsnmap_get_dups(map));
>
> +	/*
> +	 * Once we have a sack generated, check to see what our sack
> +	 * generation is, if its 0, reset the transports to 0, and reset
> +	 * the association generation to 1
> +	 *
> +	 * The idea is that zero is never used as a valid generation for the
> +	 * association so no transport will match after a wrap event like this,
> +	 * Until the next sack
> +	 */
> +	if (++aptr->peer.sack_generation == 0) {
> +		list_for_each_entry(trans,&asoc->peer.transport_addr_list,
> +				    transports)
> +			trans->sack_generation = 0;
> +		aptr->peer.sack_generation = 1;
> +	}
>   nodata:
>   	return retval;
>   }
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index c96d1a8..8716da1 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -1268,7 +1268,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>   		case SCTP_CMD_REPORT_TSN:
>   			/* Record the arrival of a TSN.  */
>   			error = sctp_tsnmap_mark(&asoc->peer.tsn_map,
> -						 cmd->obj.u32);
> +						 cmd->obj.u32, NULL);
>   			break;
>
>   		case SCTP_CMD_REPORT_FWDTSN:
> diff --git a/net/sctp/transport.c b/net/sctp/transport.c
> index b026ba0..1dcceb6 100644
> --- a/net/sctp/transport.c
> +++ b/net/sctp/transport.c
> @@ -68,6 +68,8 @@ static struct sctp_transport *sctp_transport_init(struct sctp_transport *peer,
>   	peer->af_specific = sctp_get_af_specific(addr->sa.sa_family);
>   	memset(&peer->saddr, 0, sizeof(union sctp_addr));
>
> +	peer->sack_generation = 0;
> +
>   	/* From 6.3.1 RTO Calculation:
>   	 *
>   	 * C1) Until an RTT measurement has been made for a packet sent to the
> diff --git a/net/sctp/tsnmap.c b/net/sctp/tsnmap.c
> index f1e40ceb..b5fb7c4 100644
> --- a/net/sctp/tsnmap.c
> +++ b/net/sctp/tsnmap.c
> @@ -114,7 +114,8 @@ int sctp_tsnmap_check(const struct sctp_tsnmap *map, __u32 tsn)
>
>
>   /* Mark this TSN as seen.  */
> -int sctp_tsnmap_mark(struct sctp_tsnmap *map, __u32 tsn)
> +int sctp_tsnmap_mark(struct sctp_tsnmap *map, __u32 tsn,
> +		     struct sctp_transport *trans)
>   {
>   	u16 gap;
>
> @@ -133,6 +134,9 @@ int sctp_tsnmap_mark(struct sctp_tsnmap *map, __u32 tsn)
>   		 */
>   		map->max_tsn_seen++;
>   		map->cumulative_tsn_ack_point++;
> +		if (trans)
> +			trans->sack_generation =
> +				trans->asoc->peer.sack_generation;
>   		map->base_tsn++;
>   	} else {
>   		/* Either we already have a gap, or about to record a gap, so
> diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
> index 8a84017..33d8947 100644
> --- a/net/sctp/ulpevent.c
> +++ b/net/sctp/ulpevent.c
> @@ -715,7 +715,8 @@ struct sctp_ulpevent *sctp_ulpevent_make_rcvmsg(struct sctp_association *asoc,
>   	 * can mark it as received so the tsn_map is updated correctly.
>   	 */
>   	if (sctp_tsnmap_mark(&asoc->peer.tsn_map,
> -			     ntohl(chunk->subh.data_hdr->tsn)))
> +			     ntohl(chunk->subh.data_hdr->tsn),
> +			     chunk->transport))
>   		goto fail_mark;
>
>   	/* First calculate the padding, so we don't inadvertently
> diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
> index f2d1de7..f5a6a4f 100644
> --- a/net/sctp/ulpqueue.c
> +++ b/net/sctp/ulpqueue.c
> @@ -1051,7 +1051,7 @@ void sctp_ulpq_renege(struct sctp_ulpq *ulpq, struct sctp_chunk *chunk,
>   	if (chunk&&  (freed>= needed)) {
>   		__u32 tsn;
>   		tsn = ntohl(chunk->subh.data_hdr->tsn);
> -		sctp_tsnmap_mark(&asoc->peer.tsn_map, tsn);
> +		sctp_tsnmap_mark(&asoc->peer.tsn_map, tsn, chunk->transport);
>   		sctp_ulpq_tail_data(ulpq, chunk, gfp);
>
>   		sctp_ulpq_partial_delivery(ulpq, chunk, gfp);
