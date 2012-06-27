From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH v2] sctp: be more restrictive in transport selection on bundled sacks
Date: Wed, 27 Jun 2012 10:23:23 -0400
Message-ID: <1340807003-23139-1-git-send-email-nhorman@tuxdriver.com>
References: <1340742704-2192-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yaseivch <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55687 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756758Ab2F0OXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 10:23:44 -0400
In-Reply-To: <1340742704-2192-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was noticed recently that when we send data on a transport, its possible that
we might bundle a sack that arrived on a different transport.  While this isn't
a major problem, it does go against the SHOULD requirement in section 6.4 of RFC
2960:

 An endpoint SHOULD transmit reply chunks (e.g., SACK, HEARTBEAT ACK,
   etc.) to the same destination transport address from which it
   received the DATA or control chunk to which it is replying.  This
   rule should also be followed if the endpoint is bundling DATA chunks
   together with the reply chunk.

This patch seeks to correct that.  It restricts the bundling of sack operations
to only those transports which have moved the ctsn of the association forward
since the last sack.  By doing this we guarantee that we only bundle outbound
saks on a transport that has received a chunk since the last sack.  This brings
us into stricter compliance with the RFC.

Vlad had initially suggested that we strictly allow only sack bundling on the
transport that last moved the ctsn forward.  While this makes sense, I was
concerned that doing so prevented us from bundling in the case where we had
received chunks that moved the ctsn on multiple transports.  In those cases, the
RFC allows us to select any of the transports having received chunks to bundle
the sack on.  so I've modified the approach to allow for that, by adding a state
variable to each transport that tracks weather it has moved the ctsn since the
last sack.  This I think keeps our behavior (and performance), close enough to
our current profile that I think we can do this without a sysctl knob to
enable/disable it.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Vlad Yaseivch <vyasevich@gmail.com>
CC: David S. Miller <davem@davemloft.net>
Reported-by: Michele Baldessari <michele@redhat.com>
Reported-by: sorin serban <sserban@redhat.com>

---
Change Notes:
V2)
	* Removed unused variable as per Dave M. Request
	* Delayed rwnd adjustment until we are sure we will sack (Vlad Y.)
---
 include/net/sctp/structs.h |    5 ++++-
 include/net/sctp/tsnmap.h  |    3 ++-
 net/sctp/output.c          |   10 +++++++---
 net/sctp/sm_make_chunk.c   |    7 +++++++
 net/sctp/sm_sideeffect.c   |    2 +-
 net/sctp/tsnmap.c          |    5 ++++-
 net/sctp/ulpevent.c        |    3 ++-
 net/sctp/ulpqueue.c        |    2 +-
 8 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index e4652fe..712bf09 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -910,7 +910,10 @@ struct sctp_transport {
 		pmtu_pending:1,
 
 		/* Is this structure kfree()able? */
-		malloced:1;
+		malloced:1,
+
+		/* Has this transport moved the ctsn since we last sacked */
+		moved_ctsn:1;
 
 	struct flowi fl;
 
diff --git a/include/net/sctp/tsnmap.h b/include/net/sctp/tsnmap.h
index e7728bc..2c5d2b4 100644
--- a/include/net/sctp/tsnmap.h
+++ b/include/net/sctp/tsnmap.h
@@ -117,7 +117,8 @@ void sctp_tsnmap_free(struct sctp_tsnmap *map);
 int sctp_tsnmap_check(const struct sctp_tsnmap *, __u32 tsn);
 
 /* Mark this TSN as seen.  */
-int sctp_tsnmap_mark(struct sctp_tsnmap *, __u32 tsn);
+int sctp_tsnmap_mark(struct sctp_tsnmap *, __u32 tsn,
+		     struct sctp_transport *trans);
 
 /* Mark this TSN and all lower as seen. */
 void sctp_tsnmap_skip(struct sctp_tsnmap *map, __u32 tsn);
diff --git a/net/sctp/output.c b/net/sctp/output.c
index f1b7d4b..6c8cb9e 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -240,17 +240,21 @@ static sctp_xmit_t sctp_packet_bundle_sack(struct sctp_packet *pkt,
 	 */
 	if (sctp_chunk_is_data(chunk) && !pkt->has_sack &&
 	    !pkt->has_cookie_echo) {
-		struct sctp_association *asoc;
 		struct timer_list *timer;
-		asoc = pkt->transport->asoc;
+		struct sctp_association *asoc = pkt->transport->asoc;
+
 		timer = &asoc->timers[SCTP_EVENT_TIMEOUT_SACK];
 
 		/* If the SACK timer is running, we have a pending SACK */
 		if (timer_pending(timer)) {
 			struct sctp_chunk *sack;
-			asoc->a_rwnd = asoc->rwnd;
+
+			if (chunk->transport && !chunk->transport->moved_ctsn)
+				return retval;
+
 			sack = sctp_make_sack(asoc);
 			if (sack) {
+				asoc->a_rwnd = asoc->rwnd;
 				retval = sctp_packet_append_chunk(pkt, sack);
 				asoc->peer.sack_needed = 0;
 				if (del_timer(timer))
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index a85eeeb..805babe 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -736,6 +736,7 @@ struct sctp_chunk *sctp_make_sack(const struct sctp_association *asoc)
 	__u16 num_gabs, num_dup_tsns;
 	struct sctp_tsnmap *map = (struct sctp_tsnmap *)&asoc->peer.tsn_map;
 	struct sctp_gap_ack_block gabs[SCTP_MAX_GABS];
+	struct sctp_transport *trans;
 
 	memset(gabs, 0, sizeof(gabs));
 	ctsn = sctp_tsnmap_get_ctsn(map);
@@ -805,6 +806,12 @@ struct sctp_chunk *sctp_make_sack(const struct sctp_association *asoc)
 		sctp_addto_chunk(retval, sizeof(__u32) * num_dup_tsns,
 				 sctp_tsnmap_get_dups(map));
 
+	/*
+	 * Once we have a sack generated, clear the moved_tsn information
+	 * from all the transports
+	 */
+	list_for_each_entry(trans, &asoc->peer.transport_addr_list, transports)
+		trans->moved_ctsn = 0;
 nodata:
 	return retval;
 }
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index c96d1a8..8716da1 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1268,7 +1268,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 		case SCTP_CMD_REPORT_TSN:
 			/* Record the arrival of a TSN.  */
 			error = sctp_tsnmap_mark(&asoc->peer.tsn_map,
-						 cmd->obj.u32);
+						 cmd->obj.u32, NULL);
 			break;
 
 		case SCTP_CMD_REPORT_FWDTSN:
diff --git a/net/sctp/tsnmap.c b/net/sctp/tsnmap.c
index f1e40ceb..619c638 100644
--- a/net/sctp/tsnmap.c
+++ b/net/sctp/tsnmap.c
@@ -114,7 +114,8 @@ int sctp_tsnmap_check(const struct sctp_tsnmap *map, __u32 tsn)
 
 
 /* Mark this TSN as seen.  */
-int sctp_tsnmap_mark(struct sctp_tsnmap *map, __u32 tsn)
+int sctp_tsnmap_mark(struct sctp_tsnmap *map, __u32 tsn,
+		     struct sctp_transport *trans)
 {
 	u16 gap;
 
@@ -133,6 +134,8 @@ int sctp_tsnmap_mark(struct sctp_tsnmap *map, __u32 tsn)
 		 */
 		map->max_tsn_seen++;
 		map->cumulative_tsn_ack_point++;
+		if (trans)
+			trans->moved_ctsn = 1;
 		map->base_tsn++;
 	} else {
 		/* Either we already have a gap, or about to record a gap, so
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 8a84017..33d8947 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -715,7 +715,8 @@ struct sctp_ulpevent *sctp_ulpevent_make_rcvmsg(struct sctp_association *asoc,
 	 * can mark it as received so the tsn_map is updated correctly.
 	 */
 	if (sctp_tsnmap_mark(&asoc->peer.tsn_map,
-			     ntohl(chunk->subh.data_hdr->tsn)))
+			     ntohl(chunk->subh.data_hdr->tsn),
+			     chunk->transport))
 		goto fail_mark;
 
 	/* First calculate the padding, so we don't inadvertently
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index f2d1de7..f5a6a4f 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -1051,7 +1051,7 @@ void sctp_ulpq_renege(struct sctp_ulpq *ulpq, struct sctp_chunk *chunk,
 	if (chunk && (freed >= needed)) {
 		__u32 tsn;
 		tsn = ntohl(chunk->subh.data_hdr->tsn);
-		sctp_tsnmap_mark(&asoc->peer.tsn_map, tsn);
+		sctp_tsnmap_mark(&asoc->peer.tsn_map, tsn, chunk->transport);
 		sctp_ulpq_tail_data(ulpq, chunk, gfp);
 
 		sctp_ulpq_partial_delivery(ulpq, chunk, gfp);
-- 
1.7.7.6
