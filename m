From: Joe Perches <joe@perches.com>
Subject: [RFC patch] sctp: sctp_generate_fwdtsn: Initialize sctp_fwdtsn_skip
 array, neatening
Date: Thu, 02 Jul 2015 14:54:56 -0700
Message-ID: <1435874096.2487.51.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0107.hostedemail.com ([216.40.44.107]:42320 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753018AbbGBVzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 17:55:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's not clear to me that the sctp_fwdtsn_skip array is
always initialized when used.

It is appropriate to initialize the array to 0?

This patch initializes the array too 0 and moves the
local variables into the blocks where used.

It also does some miscellaneous neatening by using
continue; and unindenting the following block and
using ARRAY_SIZE rather than 10 to decouple the
array declaration size from a constant.
---
 net/sctp/outqueue.c | 90 ++++++++++++++++++++++++++---------------------------
 1 file changed, 44 insertions(+), 46 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 7e8f0a1..4c80d7b 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -1684,13 +1684,9 @@ static inline int sctp_get_skip_pos(struct sctp_fwdtsn_skip *skiplist,
 static void sctp_generate_fwdtsn(struct sctp_outq *q, __u32 ctsn)
 {
 	struct sctp_association *asoc = q->asoc;
-	struct sctp_chunk *ftsn_chunk = NULL;
-	struct sctp_fwdtsn_skip ftsn_skip_arr[10];
-	int nskips = 0;
-	int skip_pos = 0;
-	__u32 tsn;
-	struct sctp_chunk *chunk;
 	struct list_head *lchunk, *temp;
+	struct sctp_fwdtsn_skip ftsn_skip_arr[10] = {};
+	int nskips = 0;
 
 	if (!asoc->peer.prsctp_capable)
 		return;
@@ -1726,9 +1722,11 @@ static void sctp_generate_fwdtsn(struct sctp_outq *q, __u32 ctsn)
 	 * "Advanced.Peer.Ack.Point" from 102 to 104 locally.
 	 */
 	list_for_each_safe(lchunk, temp, &q->abandoned) {
-		chunk = list_entry(lchunk, struct sctp_chunk,
-					transmitted_list);
-		tsn = ntohl(chunk->subh.data_hdr->tsn);
+		struct sctp_chunk *chunk = list_entry(lchunk, struct sctp_chunk,
+						      transmitted_list);
+		sctp_datahdr_t *data_hdr = chunk->subh.data_hdr;
+		__u32 tsn = ntohl(data_hdr->tsn);
+		int skip_pos;
 
 		/* Remove any chunks in the abandoned queue that are acked by
 		 * the ctsn.
@@ -1736,52 +1734,52 @@ static void sctp_generate_fwdtsn(struct sctp_outq *q, __u32 ctsn)
 		if (TSN_lte(tsn, ctsn)) {
 			list_del_init(lchunk);
 			sctp_chunk_free(chunk);
-		} else {
-			if (TSN_lte(tsn, asoc->adv_peer_ack_point+1)) {
-				asoc->adv_peer_ack_point = tsn;
-				if (chunk->chunk_hdr->flags &
-					 SCTP_DATA_UNORDERED)
-					continue;
-				skip_pos = sctp_get_skip_pos(&ftsn_skip_arr[0],
-						nskips,
-						chunk->subh.data_hdr->stream);
-				ftsn_skip_arr[skip_pos].stream =
-					chunk->subh.data_hdr->stream;
-				ftsn_skip_arr[skip_pos].ssn =
-					 chunk->subh.data_hdr->ssn;
-				if (skip_pos == nskips)
-					nskips++;
-				if (nskips == 10)
-					break;
-			} else
-				break;
+			continue;
 		}
+
+		if (!TSN_lte(tsn, asoc->adv_peer_ack_point + 1))
+			break;
+
+		asoc->adv_peer_ack_point = tsn;
+		if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
+			continue;
+
+		skip_pos = sctp_get_skip_pos(ftsn_skip_arr, nskips,
+					     data_hdr->stream);
+		ftsn_skip_arr[skip_pos].stream = data_hdr->stream;
+		ftsn_skip_arr[skip_pos].ssn = data_hdr->ssn;
+		if (skip_pos == nskips)
+			nskips++;
+		if (nskips == ARRAY_SIZE(ftsn_skip_arr))
+			break;
 	}
 
 	/* PR-SCTP C3) If, after step C1 and C2, the "Advanced.Peer.Ack.Point"
-	 * is greater than the Cumulative TSN ACK carried in the received
-	 * SACK, the data sender MUST send the data receiver a FORWARD TSN
-	 * chunk containing the latest value of the
-	 * "Advanced.Peer.Ack.Point".
+	 * is greater than the Cumulative TSN ACK carried in the received SACK,
+	 * the data sender MUST send the data receiver a FORWARD TSN chunk
+	 * containing the latest value of the "Advanced.Peer.Ack.Point".
 	 *
 	 * C4) For each "abandoned" TSN the sender of the FORWARD TSN SHOULD
 	 * list each stream and sequence number in the forwarded TSN. This
-	 * information will enable the receiver to easily find any
-	 * stranded TSN's waiting on stream reorder queues. Each stream
-	 * SHOULD only be reported once; this means that if multiple
-	 * abandoned messages occur in the same stream then only the
-	 * highest abandoned stream sequence number is reported. If the
-	 * total size of the FORWARD TSN does NOT fit in a single MTU then
-	 * the sender of the FORWARD TSN SHOULD lower the
-	 * Advanced.Peer.Ack.Point to the last TSN that will fit in a
+	 * information will enable the receiver to easily find any stranded
+	 * TSN's waiting on stream reorder queues. Each stream SHOULD only be
+	 * reported once; this means that if multiple abandoned messages occur
+	 * in the same stream then only the highest abandoned stream sequence
+	 * number is reported. If the total size of the FORWARD TSN does NOT
+	 * fit in a single MTU then the sender of the FORWARD TSN SHOULD lower
+	 * the Advanced.Peer.Ack.Point to the last TSN that will fit in a
 	 * single MTU.
 	 */
-	if (asoc->adv_peer_ack_point > ctsn)
-		ftsn_chunk = sctp_make_fwdtsn(asoc, asoc->adv_peer_ack_point,
-					      nskips, &ftsn_skip_arr[0]);
+	if (asoc->adv_peer_ack_point > ctsn) {
+		struct sctp_chunk *ftsn_chunk;
 
-	if (ftsn_chunk) {
-		list_add_tail(&ftsn_chunk->list, &q->control_chunk_list);
-		SCTP_INC_STATS(sock_net(asoc->base.sk), SCTP_MIB_OUTCTRLCHUNKS);
+		ftsn_chunk = sctp_make_fwdtsn(asoc, asoc->adv_peer_ack_point,
+					      nskips, ftsn_skip_arr);
+		if (ftsn_chunk) {
+			list_add_tail(&ftsn_chunk->list,
+				      &q->control_chunk_list);
+			SCTP_INC_STATS(sock_net(asoc->base.sk),
+				       SCTP_MIB_OUTCTRLCHUNKS);
+		}
 	}
 }
