From: "Lee A. Roberts" <lee.roberts@hp.com>
Subject: [PATCH v3 4/4] sctp: fix association hangs due to partial delivery errors
Date: Thu, 28 Feb 2013 07:37:30 -0700
Message-ID: <1362062250-26749-5-git-send-email-lee.roberts@hp.com>
References: <1361991273-30578-1-git-send-email-lee.roberts@hp.com>
Cc: linux-sctp@vger.kernel.org, lee.roberts@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:6899 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808Ab3B1Ogh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 09:36:37 -0500
In-Reply-To: <1361991273-30578-1-git-send-email-lee.roberts@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Lee A. Roberts" <lee.roberts@hp.com>

In sctp_ulpq_tail_data(), use return values 0,1 to indicate whether
a complete event (with MSG_EOR set) was delivered.  A return value
of -ENOMEM continues to indicate an out-of-memory condition was
encountered.

In sctp_ulpq_retrieve_partial() and sctp_ulpq_retrieve_first(),
correct message reassembly logic for SCTP partial delivery.
Change logic to ensure that as much data as possible is sent
with the initial partial delivery and that following partial
deliveries contain all available data.

In sctp_ulpq_partial_delivery(), attempt partial delivery only
if the data on the head of the reassembly queue is at or before
the cumulative TSN ACK point.

In sctp_ulpq_renege(), use the modified return values from
sctp_ulpq_tail_data() to choose whether to attempt partial
delivery or to attempt to drain the reassembly queue as a
means to reduce memory pressure.  Remove call to
sctp_tsnmap_mark(), as this is handled correctly in call to
sctp_ulpq_tail_data().

Signed-off-by: Lee A. Roberts <lee.roberts@hp.com>
---
 net/sctp/ulpqueue.c |   54 ++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 43 insertions(+), 11 deletions(-)

diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index f221fbb..482e3ea 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -106,6 +106,7 @@ int sctp_ulpq_tail_data(struct sctp_ulpq *ulpq, struct sctp_chunk *chunk,
 {
 	struct sk_buff_head temp;
 	struct sctp_ulpevent *event;
+	int event_eor = 0;
 
 	/* Create an event from the incoming chunk. */
 	event = sctp_ulpevent_make_rcvmsg(chunk->asoc, chunk, gfp);
@@ -127,10 +128,12 @@ int sctp_ulpq_tail_data(struct sctp_ulpq *ulpq, struct sctp_chunk *chunk,
 	/* Send event to the ULP.  'event' is the sctp_ulpevent for
 	 * very first SKB on the 'temp' list.
 	 */
-	if (event)
+	if (event) {
+		event_eor = (event->msg_flags & MSG_EOR) ? 1 : 0;
 		sctp_ulpq_tail_event(ulpq, event);
+	}
 
-	return 0;
+	return event_eor;
 }
 
 /* Add a new event for propagation to the ULP.  */
@@ -540,14 +543,19 @@ static struct sctp_ulpevent *sctp_ulpq_retrieve_partial(struct sctp_ulpq *ulpq)
 		ctsn = cevent->tsn;
 
 		switch (cevent->msg_flags & SCTP_DATA_FRAG_MASK) {
+		case SCTP_DATA_FIRST_FRAG:
+			if (!first_frag)
+				return NULL;
+			goto done;
 		case SCTP_DATA_MIDDLE_FRAG:
 			if (!first_frag) {
 				first_frag = pos;
 				next_tsn = ctsn + 1;
 				last_frag = pos;
-			} else if (next_tsn == ctsn)
+			} else if (next_tsn == ctsn) {
 				next_tsn++;
-			else
+				last_frag = pos;
+			} else
 				goto done;
 			break;
 		case SCTP_DATA_LAST_FRAG:
@@ -651,6 +659,14 @@ static struct sctp_ulpevent *sctp_ulpq_retrieve_first(struct sctp_ulpq *ulpq)
 			} else
 				goto done;
 			break;
+
+		case SCTP_DATA_LAST_FRAG:
+			if (!first_frag)
+				return NULL;
+			else
+				goto done;
+			break;
+
 		default:
 			return NULL;
 		}
@@ -1025,16 +1041,28 @@ void sctp_ulpq_partial_delivery(struct sctp_ulpq *ulpq,
 	struct sctp_ulpevent *event;
 	struct sctp_association *asoc;
 	struct sctp_sock *sp;
+	__u32 ctsn;
+	struct sk_buff *skb;
 
 	asoc = ulpq->asoc;
 	sp = sctp_sk(asoc->base.sk);
 
 	/* If the association is already in Partial Delivery mode
-	 * we have noting to do.
+	 * we have nothing to do.
 	 */
 	if (ulpq->pd_mode)
 		return;
 
+	/* Data must be at or below the Cumulative TSN ACK Point to
+	 * start partial delivery.
+	 */
+	skb = skb_peek(&asoc->ulpq.reasm);
+	if (skb != NULL) {
+		ctsn = sctp_skb2event(skb)->tsn;
+		if (!TSN_lte(ctsn, sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map)))
+			return;
+	}
+
 	/* If the user enabled fragment interleave socket option,
 	 * multiple associations can enter partial delivery.
 	 * Otherwise, we can only enter partial delivery if the
@@ -1077,12 +1105,16 @@ void sctp_ulpq_renege(struct sctp_ulpq *ulpq, struct sctp_chunk *chunk,
 	}
 	/* If able to free enough room, accept this chunk. */
 	if (chunk && (freed >= needed)) {
-		__u32 tsn;
-		tsn = ntohl(chunk->subh.data_hdr->tsn);
-		sctp_tsnmap_mark(&asoc->peer.tsn_map, tsn, chunk->transport);
-		sctp_ulpq_tail_data(ulpq, chunk, gfp);
-
-		sctp_ulpq_partial_delivery(ulpq, gfp);
+		int retval;
+		retval = sctp_ulpq_tail_data(ulpq, chunk, gfp);
+		/*
+		 * Enter partial delivery if chunk has not been
+		 * delivered; otherwise, drain the reassembly queue.
+		 */
+		if (retval <= 0)
+			sctp_ulpq_partial_delivery(ulpq, gfp);
+		else if (retval == 1)
+			sctp_ulpq_reasm_drain(ulpq);
 	}
 
 	sk_mem_reclaim(asoc->base.sk);
-- 
1.7.9.5
