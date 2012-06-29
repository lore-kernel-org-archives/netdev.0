From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v3] sctp: be more restrictive in transport selection on
 bundled sacks
Date: Fri, 29 Jun 2012 14:43:10 -0400
Message-ID: <20120629184310.GA24604@hmsreliant.think-freely.org>
References: <1340742704-2192-1-git-send-email-nhorman@tuxdriver.com>
 <1340987696-19205-1-git-send-email-nhorman@tuxdriver.com>
 <4FEDF420.50507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57196 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756036Ab2F2SnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 14:43:20 -0400
Content-Disposition: inline
In-Reply-To: <4FEDF420.50507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 29, 2012 at 02:29:52PM -0400, Vlad Yasevich wrote:
> On 06/29/2012 12:34 PM, Neil Horman wrote:
> >It was noticed recently that when we send data on a transport, its possible that
> >we might bundle a sack that arrived on a different transport.  While this isn't
> >a major problem, it does go against the SHOULD requirement in section 6.4 of RFC
> >2960:
> >
> >  An endpoint SHOULD transmit reply chunks (e.g., SACK, HEARTBEAT ACK,
> >    etc.) to the same destination transport address from which it
> >    received the DATA or control chunk to which it is replying.  This
> >    rule should also be followed if the endpoint is bundling DATA chunks
> >    together with the reply chunk.
> >
> >This patch seeks to correct that.  It restricts the bundling of sack operations
> >to only those transports which have moved the ctsn of the association forward
> >since the last sack.  By doing this we guarantee that we only bundle outbound
> >saks on a transport that has received a chunk since the last sack.  This brings
> >us into stricter compliance with the RFC.
> >
> >Vlad had initially suggested that we strictly allow only sack bundling on the
> >transport that last moved the ctsn forward.  While this makes sense, I was
> >concerned that doing so prevented us from bundling in the case where we had
> >received chunks that moved the ctsn on multiple transports.  In those cases, the
> >RFC allows us to select any of the transports having received chunks to bundle
> >the sack on.  so I've modified the approach to allow for that, by adding a state
> >variable to each transport that tracks weather it has moved the ctsn since the
> >last sack.  This I think keeps our behavior (and performance), close enough to
> >our current profile that I think we can do this without a sysctl knob to
> >enable/disable it.
> >
> >Signed-off-by: Neil Horman<nhorman@tuxdriver.com>
> >CC: Vlad Yaseivch<vyasevich@gmail.com>
> >CC: David S. Miller<davem@davemloft.net>
> >Reported-by: Michele Baldessari<michele@redhat.com>
> >Reported-by: sorin serban<sserban@redhat.com>
> >
> >---
> >Change Notes:
> >V2)
> >	* Removed unused variable as per Dave M. Request
> >	* Delayed rwnd adjustment until we are sure we will sack (Vlad Y.)
> >V3)
> >	* Switched test to use pkt->transport rather than chunk->transport
> >	* Modified detection of sacka-able transport.  Instead of just setting
> >	  and clearning a flag, we now mark each transport and association with
> >	  a sack generation tag.  We increment the associations generation on
> >	  every sack, and assign that generation tag to every transport that
> >	  updates the ctsn.  This prevents us from having to iterate over a for
> >	  loop on every sack, which is much more scalable.
> >---
> >  include/net/sctp/structs.h |    4 ++++
> >  include/net/sctp/tsnmap.h  |    3 ++-
> >  net/sctp/associola.c       |    1 +
> >  net/sctp/output.c          |    9 +++++++--
> >  net/sctp/sm_make_chunk.c   |   10 ++++++++++
> >  net/sctp/sm_sideeffect.c   |    2 +-
> >  net/sctp/transport.c       |    2 ++
> >  net/sctp/tsnmap.c          |    6 +++++-
> >  net/sctp/ulpevent.c        |    3 ++-
> >  net/sctp/ulpqueue.c        |    2 +-
> >  10 files changed, 35 insertions(+), 7 deletions(-)
> >
> >diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> >index e4652fe..fecdf31 100644
> >--- a/include/net/sctp/structs.h
> >+++ b/include/net/sctp/structs.h
> >@@ -912,6 +912,9 @@ struct sctp_transport {
> >  		/* Is this structure kfree()able? */
> >  		malloced:1;
> >
> >+	/* Has this transport moved the ctsn since we last sacked */
> >+	__u32 sack_generation;
> >+
> >  	struct flowi fl;
> >
> >  	/* This is the peer's IP address and port. */
> >@@ -1584,6 +1587,7 @@ struct sctp_association {
> >  		 */
> >  		__u8    sack_needed;     /* Do we need to sack the peer? */
> >  		__u32	sack_cnt;
> >+		__u32	sack_generation;
> >
> >  		/* These are capabilities which our peer advertised.  */
> >  		__u8	ecn_capable:1,	    /* Can peer do ECN? */
> >diff --git a/include/net/sctp/tsnmap.h b/include/net/sctp/tsnmap.h
> >index e7728bc..2c5d2b4 100644
> >--- a/include/net/sctp/tsnmap.h
> >+++ b/include/net/sctp/tsnmap.h
> >@@ -117,7 +117,8 @@ void sctp_tsnmap_free(struct sctp_tsnmap *map);
> >  int sctp_tsnmap_check(const struct sctp_tsnmap *, __u32 tsn);
> >
> >  /* Mark this TSN as seen.  */
> >-int sctp_tsnmap_mark(struct sctp_tsnmap *, __u32 tsn);
> >+int sctp_tsnmap_mark(struct sctp_tsnmap *, __u32 tsn,
> >+		     struct sctp_transport *trans);
> >
> >  /* Mark this TSN and all lower as seen. */
> >  void sctp_tsnmap_skip(struct sctp_tsnmap *map, __u32 tsn);
> >diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> >index 5bc9ab1..6c66adb 100644
> >--- a/net/sctp/associola.c
> >+++ b/net/sctp/associola.c
> >@@ -271,6 +271,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
> >  	 */
> >  	asoc->peer.sack_needed = 1;
> >  	asoc->peer.sack_cnt = 0;
> >+	asoc->peer.sack_generation=0;
> >
> >  	/* Assume that the peer will tell us if he recognizes ASCONF
> >  	 * as part of INIT exchange.
> >diff --git a/net/sctp/output.c b/net/sctp/output.c
> >index f1b7d4b..0de6cd5 100644
> >--- a/net/sctp/output.c
> >+++ b/net/sctp/output.c
> >@@ -240,14 +240,19 @@ static sctp_xmit_t sctp_packet_bundle_sack(struct sctp_packet *pkt,
> >  	 */
> >  	if (sctp_chunk_is_data(chunk)&&  !pkt->has_sack&&
> >  	!pkt->has_cookie_echo) {
> >-		struct sctp_association *asoc;
> >  		struct timer_list *timer;
> >-		asoc = pkt->transport->asoc;
> >+		struct sctp_association *asoc = pkt->transport->asoc;
> >+
> >  		timer =&asoc->timers[SCTP_EVENT_TIMEOUT_SACK];
> >
> >  		/* If the SACK timer is running, we have a pending SACK */
> >  		if (timer_pending(timer)) {
> >  			struct sctp_chunk *sack;
> >+
> >+			if (pkt->transport->sack_generation !=
> >+			    pkt->transport->asoc->peer.sack_generation)
> >+				return retval;
> >+
> >  			asoc->a_rwnd = asoc->rwnd;
> >  			sack = sctp_make_sack(asoc);
> >  			if (sack) {
> >diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> >index a85eeeb..ffa2a8e 100644
> >--- a/net/sctp/sm_make_chunk.c
> >+++ b/net/sctp/sm_make_chunk.c
> >@@ -736,6 +736,7 @@ struct sctp_chunk *sctp_make_sack(const struct sctp_association *asoc)
> >  	__u16 num_gabs, num_dup_tsns;
> >  	struct sctp_tsnmap *map = (struct sctp_tsnmap *)&asoc->peer.tsn_map;
> >  	struct sctp_gap_ack_block gabs[SCTP_MAX_GABS];
> >+	struct sctp_transport *trans;
> >
> >  	memset(gabs, 0, sizeof(gabs));
> >  	ctsn = sctp_tsnmap_get_ctsn(map);
> >@@ -805,6 +806,15 @@ struct sctp_chunk *sctp_make_sack(const struct sctp_association *asoc)
> >  		sctp_addto_chunk(retval, sizeof(__u32) * num_dup_tsns,
> >  				 sctp_tsnmap_get_dups(map));
> >
> >+	/*
> >+	 * Once we have a sack generated, clear the moved_tsn information
> >+	 * from all the transports
> >+	 */
> >+	if (!asoc->peer.sack_generation)
> >+		list_for_each_entry(trans,&asoc->peer.transport_addr_list,
> >+				    transports)
> >+			trans->sack_generation = UINT_MAX;
> >+	((struct sctp_association *)asoc)->peer.sack_generation++;
> 
> Two points here:
> 1) The commend no longer matches the code
Crud, missed that, I'll fix it.

> 2) Why special case the peer.sack_generations == 0 and set the
> transport to UNIT_MAX?
> 
To avoid wrapping problems leading to erroneous bundling errors.  Consider a
long lived connection with two trasports (A and B).

If all traffic is sent on A for a long time (generating UINT_MAX sacks), and the
peer chooses that moment to send data on transport B, its possible that we will
bundle a sack with that data chunk erroneously, because the associations
sack_generation has wrapped, and now matches with the transports, even though we
never received data on transport B.  The special casing ensures that we never
hit that problem.

Neil
