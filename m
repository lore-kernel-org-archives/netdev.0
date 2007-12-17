From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2.6.25 6/9] SCTP: Update ASCONF processing to conform to spec.
Date: Mon, 17 Dec 2007 16:32:46 -0500
Message-ID: <1197927169-5106-7-git-send-email-vladislav.yasevich@hp.com>
References: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:15321 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761331AbXLQVcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 16:32:55 -0500
In-Reply-To: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The processing of the ASCONF chunks has changed a lot in the
spec.  New items are:
    1. A list of ASCONF-ACK chunks is now cached
    2. The source of the packet is used in response.
    3. New handling for unexpect ASCONF chunks.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |   24 +++++++++-------
 net/sctp/associola.c       |   58 ++++++++++++++++++++++++++++++++++++++-
 net/sctp/outqueue.c        |   29 ++++++++++++++++++-
 net/sctp/sm_make_chunk.c   |   12 +++-----
 net/sctp/sm_statefuns.c    |   64 ++++++++++++++++++++++++++++---------------
 5 files changed, 143 insertions(+), 44 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index fb9b7e7..39e74d7 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -744,6 +744,7 @@ struct sctp_chunk {
 	__u8 tsn_missing_report; /* Data chunk missing counter. */
 	__u8 data_accepted; 	/* At least 1 chunk in this packet accepted */
 	__u8 auth;		/* IN: was auth'ed | OUT: needs auth */
+	__u8 has_asconf;	/* IN: have seen an asconf before */
 };
 
 void sctp_chunk_hold(struct sctp_chunk *);
@@ -1785,20 +1786,16 @@ struct sctp_association {
 	 */
 	struct sctp_chunk *addip_last_asconf;
 
-	/* ADDIP Section 4.2 Upon reception of an ASCONF Chunk.
+	/* ADDIP Section 5.2 Upon reception of an ASCONF Chunk.
 	 *
-	 * IMPLEMENTATION NOTE: As an optimization a receiver may wish
-	 * to save the last ASCONF-ACK for some predetermined period
-	 * of time and instead of re-processing the ASCONF (with the
-	 * same serial number) it may just re-transmit the
-	 * ASCONF-ACK. It may wish to use the arrival of a new serial
-	 * number to discard the previously saved ASCONF-ACK or any
-	 * other means it may choose to expire the saved ASCONF-ACK.
+	 * This is needed to implement itmes E1 - E4 of the updated
+	 * spec.  Here is the justification:
 	 *
-	 * [This is our saved ASCONF-ACK.  We invalidate it when a new
-	 * ASCONF serial number arrives.]
+	 * Since the peer may bundle multiple ASCONF chunks toward us,
+	 * we now need the ability to cache multiple ACKs.  The section
+	 * describes in detail how they are cached and cleaned up.
 	 */
-	struct sctp_chunk *addip_last_asconf_ack;
+	struct list_head asconf_ack_list;
 
 	/* These ASCONF chunks are waiting to be sent.
 	 *
@@ -1947,6 +1944,11 @@ int sctp_assoc_set_bind_addr_from_cookie(struct sctp_association *,
 					 struct sctp_cookie*,
 					 gfp_t gfp);
 int sctp_assoc_set_id(struct sctp_association *, gfp_t);
+void sctp_assoc_clean_asconf_ack_cache(const struct sctp_association *asoc);
+struct sctp_chunk *sctp_assoc_lookup_asconf_ack(
+					const struct sctp_association *asoc,
+					__be32 serial);
+
 
 int sctp_cmp_addr_exact(const union sctp_addr *ss1,
 			const union sctp_addr *ss2);
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 61bebb9..a016e78 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -61,6 +61,7 @@
 
 /* Forward declarations for internal functions. */
 static void sctp_assoc_bh_rcv(struct work_struct *work);
+static void sctp_assoc_free_asconf_acks(struct sctp_association *asoc);
 
 
 /* 1st Level Abstractions. */
@@ -242,6 +243,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	asoc->addip_serial = asoc->c.initial_tsn;
 
 	INIT_LIST_HEAD(&asoc->addip_chunk_list);
+	INIT_LIST_HEAD(&asoc->asconf_ack_list);
 
 	/* Make an empty list of remote transport addresses.  */
 	INIT_LIST_HEAD(&asoc->peer.transport_addr_list);
@@ -431,8 +433,7 @@ void sctp_association_free(struct sctp_association *asoc)
 	asoc->peer.transport_count = 0;
 
 	/* Free any cached ASCONF_ACK chunk. */
-	if (asoc->addip_last_asconf_ack)
-		sctp_chunk_free(asoc->addip_last_asconf_ack);
+	sctp_assoc_free_asconf_acks(asoc);
 
 	/* Free any cached ASCONF chunk. */
 	if (asoc->addip_last_asconf)
@@ -1485,3 +1486,56 @@ retry:
 	asoc->assoc_id = (sctp_assoc_t) assoc_id;
 	return error;
 }
+
+/* Free asconf_ack cache */
+static void sctp_assoc_free_asconf_acks(struct sctp_association *asoc)
+{
+	struct sctp_chunk *ack;
+	struct sctp_chunk *tmp;
+
+	list_for_each_entry_safe(ack, tmp, &asoc->asconf_ack_list,
+				transmitted_list) {
+		list_del_init(&ack->transmitted_list);
+		sctp_chunk_free(ack);
+	}
+}
+
+/* Clean up the ASCONF_ACK queue */
+void sctp_assoc_clean_asconf_ack_cache(const struct sctp_association *asoc)
+{
+	struct sctp_chunk *ack;
+	struct sctp_chunk *tmp;
+
+	/* We can remove all the entries from the queue upto
+	 * the "Peer-Sequence-Number".
+	 */
+	list_for_each_entry_safe(ack, tmp, &asoc->asconf_ack_list,
+				transmitted_list) {
+		if (ack->subh.addip_hdr->serial ==
+				htonl(asoc->peer.addip_serial))
+			break;
+
+		list_del_init(&ack->transmitted_list);
+		sctp_chunk_free(ack);
+	}
+}
+
+/* Find the ASCONF_ACK whose serial number matches ASCONF */
+struct sctp_chunk *sctp_assoc_lookup_asconf_ack(
+					const struct sctp_association *asoc,
+					__be32 serial)
+{
+	struct sctp_chunk *ack = NULL;
+
+	/* Walk through the list of cached ASCONF-ACKs and find the
+	 * ack chunk whose serial number matches that of the request.
+	 */
+	list_for_each_entry(ack, &asoc->asconf_ack_list, transmitted_list) {
+		if (ack->subh.addip_hdr->serial == serial) {
+			sctp_chunk_hold(ack);
+			break;
+		}
+	}
+
+	return ack;
+}
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index fa76f23..a42af86 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -716,7 +716,29 @@ int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 		new_transport = chunk->transport;
 
 		if (!new_transport) {
-			new_transport = asoc->peer.active_path;
+			/*
+			 * If we have a prior transport pointer, see if
+			 * the destination address of the chunk
+			 * matches the destination address of the
+			 * current transport.  If not a match, then
+			 * try to look up the transport with a given
+			 * destination address.  We do this because
+			 * after processing ASCONFs, we may have new
+			 * transports created.
+			 */
+			if (transport &&
+			    sctp_cmp_addr_exact(&chunk->dest,
+						&transport->ipaddr))
+					new_transport = transport;
+			else
+				new_transport = sctp_assoc_lookup_paddr(asoc,
+								&chunk->dest);
+
+			/* if we still don't have a new transport, then
+			 * use the current active path.
+			 */
+			if (!new_transport)
+				new_transport = asoc->peer.active_path;
 		} else if ((new_transport->state == SCTP_INACTIVE) ||
 			   (new_transport->state == SCTP_UNCONFIRMED)) {
 			/* If the chunk is Heartbeat or Heartbeat Ack,
@@ -729,9 +751,12 @@ int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 			 * address of the IP datagram containing the
 			 * HEARTBEAT chunk to which this ack is responding.
 			 * ...
+			 *
+			 * ASCONF_ACKs also must be sent to the source.
 			 */
 			if (chunk->chunk_hdr->type != SCTP_CID_HEARTBEAT &&
-			    chunk->chunk_hdr->type != SCTP_CID_HEARTBEAT_ACK)
+			    chunk->chunk_hdr->type != SCTP_CID_HEARTBEAT_ACK &&
+			    chunk->chunk_hdr->type != SCTP_CID_ASCONF_ACK)
 				new_transport = asoc->peer.active_path;
 		}
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 62af33d..257236c 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1269,6 +1269,9 @@ nodata:
 /* Release the memory occupied by a chunk.  */
 static void sctp_chunk_destroy(struct sctp_chunk *chunk)
 {
+	BUG_ON(!list_empty(&chunk->list));
+	list_del_init(&chunk->transmitted_list);
+
 	/* Free the chunk skb data and the SCTP_chunk stub itself. */
 	dev_kfree_skb(chunk->skb);
 
@@ -1279,9 +1282,6 @@ static void sctp_chunk_destroy(struct sctp_chunk *chunk)
 /* Possibly, free the chunk.  */
 void sctp_chunk_free(struct sctp_chunk *chunk)
 {
-	BUG_ON(!list_empty(&chunk->list));
-	list_del_init(&chunk->transmitted_list);
-
 	/* Release our reference on the message tracker. */
 	if (chunk->msg)
 		sctp_datamsg_put(chunk->msg);
@@ -2974,11 +2974,9 @@ done:
 	 * after freeing the reference to old asconf ack if any.
 	 */
 	if (asconf_ack) {
-		if (asoc->addip_last_asconf_ack)
-			sctp_chunk_free(asoc->addip_last_asconf_ack);
-
 		sctp_chunk_hold(asconf_ack);
-		asoc->addip_last_asconf_ack = asconf_ack;
+		list_add_tail(&asconf_ack->transmitted_list,
+			      &asoc->asconf_ack_list);
 	}
 
 	return asconf_ack;
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 859be75..8fe2e61 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3424,48 +3424,68 @@ sctp_disposition_t sctp_sf_do_asconf(const struct sctp_endpoint *ep,
 
 	/* Verify the ASCONF chunk before processing it. */
 	if (!sctp_verify_asconf(asoc,
-	    (sctp_paramhdr_t *)((void *)addr_param + length),
-	    (void *)chunk->chunk_end,
-	    &err_param))
+			    (sctp_paramhdr_t *)((void *)addr_param + length),
+			    (void *)chunk->chunk_end,
+			    &err_param))
 		return sctp_sf_violation_paramlen(ep, asoc, type,
-			   (void *)&err_param, commands);
+						  (void *)&err_param, commands);
 
-	/* ADDIP 4.2 C1) Compare the value of the serial number to the value
+	/* ADDIP 5.2 E1) Compare the value of the serial number to the value
 	 * the endpoint stored in a new association variable
 	 * 'Peer-Serial-Number'.
 	 */
 	if (serial == asoc->peer.addip_serial + 1) {
-		/* ADDIP 4.2 C2) If the value found in the serial number is
-		 * equal to the ('Peer-Serial-Number' + 1), the endpoint MUST
-		 * do V1-V5.
+		/* If this is the first instance of ASCONF in the packet,
+		 * we can clean our old ASCONF-ACKs.
+		 */
+		if (!chunk->has_asconf)
+			sctp_assoc_clean_asconf_ack_cache(asoc);
+
+		/* ADDIP 5.2 E4) When the Sequence Number matches the next one
+		 * expected, process the ASCONF as described below and after
+		 * processing the ASCONF Chunk, append an ASCONF-ACK Chunk to
+		 * the response packet and cache a copy of it (in the event it
+		 * later needs to be retransmitted).
+		 *
+		 * Essentially, do V1-V5.
 		 */
 		asconf_ack = sctp_process_asconf((struct sctp_association *)
 						 asoc, chunk);
 		if (!asconf_ack)
 			return SCTP_DISPOSITION_NOMEM;
-	} else if (serial == asoc->peer.addip_serial) {
-		/* ADDIP 4.2 C3) If the value found in the serial number is
-		 * equal to the value stored in the 'Peer-Serial-Number'
-		 * IMPLEMENTATION NOTE: As an optimization a receiver may wish
-		 * to save the last ASCONF-ACK for some predetermined period of
-		 * time and instead of re-processing the ASCONF (with the same
-		 * serial number) it may just re-transmit the ASCONF-ACK.
+	} else if (serial < asoc->peer.addip_serial + 1) {
+		/* ADDIP 5.2 E2)
+		 * If the value found in the Sequence Number is less than the
+		 * ('Peer- Sequence-Number' + 1), simply skip to the next
+		 * ASCONF, and include in the outbound response packet
+		 * any previously cached ASCONF-ACK response that was
+		 * sent and saved that matches the Sequence Number of the
+		 * ASCONF.  Note: It is possible that no cached ASCONF-ACK
+		 * Chunk exists.  This will occur when an older ASCONF
+		 * arrives out of order.  In such a case, the receiver
+		 * should skip the ASCONF Chunk and not include ASCONF-ACK
+		 * Chunk for that chunk.
 		 */
-		if (asoc->addip_last_asconf_ack)
-			asconf_ack = asoc->addip_last_asconf_ack;
-		else
+		asconf_ack = sctp_assoc_lookup_asconf_ack(asoc, hdr->serial);
+		if (!asconf_ack)
 			return SCTP_DISPOSITION_DISCARD;
 	} else {
-		/* ADDIP 4.2 C4) Otherwise, the ASCONF Chunk is discarded since
+		/* ADDIP 5.2 E5) Otherwise, the ASCONF Chunk is discarded since
 		 * it must be either a stale packet or from an attacker.
 		 */
 		return SCTP_DISPOSITION_DISCARD;
 	}
 
-	/* ADDIP 4.2 C5) In both cases C2 and C3 the ASCONF-ACK MUST be sent
-	 * back to the source address contained in the IP header of the ASCONF
-	 * being responded to.
+	/* ADDIP 5.2 E6)  The destination address of the SCTP packet
+	 * containing the ASCONF-ACK Chunks MUST be the source address of
+	 * the SCTP packet that held the ASCONF Chunks.
+	 *
+	 * To do this properly, we'll set the destination address of the chunk
+	 * and at the transmit time, will try look up the transport to use.
+	 * Since ASCONFs may be bundled, the correct transport may not be
+	 * created untill we process the entire packet, thus this workaround.
 	 */
+	asconf_ack->dest = chunk->source;
 	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(asconf_ack));
 
 	return SCTP_DISPOSITION_CONSUME;
-- 
1.5.3.5

