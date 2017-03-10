From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 2/7] sctp: implement receiver-side procedures for the SSN/TSN Reset Request Parameter
Date: Fri, 10 Mar 2017 12:11:07 +0800
Message-ID: <f224235b4621ea3a182e959873f6fe0ba78e5416.1489118815.git.lucien.xin@gmail.com>
References: <cover.1489118815.git.lucien.xin@gmail.com>
 <7bf94990cf77044e0286adc2f393af4c9010213c.1489118815.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35689 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753202AbdCJELi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 23:11:38 -0500
In-Reply-To: <7bf94990cf77044e0286adc2f393af4c9010213c.1489118815.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1489118815.git.lucien.xin@gmail.com>
References: <cover.1489118815.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to implement Receiver-Side Procedures for the SSN/TSN
Reset Request Parameter described in rfc6525 section 6.2.4.

The process is kind of complicate, it's wonth having some comments
from section 6.2.4 in the codes.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h   |  4 +++
 net/sctp/sm_statefuns.c |  3 ++
 net/sctp/stream.c       | 79 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 86 insertions(+)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index b6f682e..2629d66 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -293,6 +293,10 @@ struct sctp_chunk *sctp_process_strreset_inreq(
 				struct sctp_association *asoc,
 				union sctp_params param,
 				struct sctp_ulpevent **evp);
+struct sctp_chunk *sctp_process_strreset_tsnreq(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp);
 
 /* Prototypes for statetable processing. */
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index e03bb1a..6982064 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3872,6 +3872,9 @@ sctp_disposition_t sctp_sf_do_reconf(struct net *net,
 		else if (param.p->type == SCTP_PARAM_RESET_IN_REQUEST)
 			reply = sctp_process_strreset_inreq(
 				(struct sctp_association *)asoc, param, &ev);
+		else if (param.p->type == SCTP_PARAM_RESET_TSN_REQUEST)
+			reply = sctp_process_strreset_tsnreq(
+				(struct sctp_association *)asoc, param, &ev);
 		/* More handles for other types will be added here, by now it
 		 * just ignores other types.
 		 */
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 1c6cc04..7e993b0 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -477,3 +477,82 @@ struct sctp_chunk *sctp_process_strreset_inreq(
 
 	return chunk;
 }
+
+struct sctp_chunk *sctp_process_strreset_tsnreq(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp)
+{
+	__u32 init_tsn = 0, next_tsn = 0, max_tsn_seen;
+	struct sctp_strreset_tsnreq *tsnreq = param.v;
+	struct sctp_stream *stream = asoc->stream;
+	__u32 result = SCTP_STRRESET_DENIED;
+	__u32 request_seq;
+	__u16 i;
+
+	request_seq = ntohl(tsnreq->request_seq);
+	if (request_seq > asoc->strreset_inseq) {
+		result = SCTP_STRRESET_ERR_BAD_SEQNO;
+		goto out;
+	} else if (request_seq == asoc->strreset_inseq) {
+		asoc->strreset_inseq++;
+	}
+
+	if (!(asoc->strreset_enable & SCTP_ENABLE_RESET_ASSOC_REQ))
+		goto out;
+
+	if (asoc->strreset_outstanding) {
+		result = SCTP_STRRESET_ERR_IN_PROGRESS;
+		goto out;
+	}
+
+	/* G3: The same processing as though a SACK chunk with no gap report
+	 *     and a cumulative TSN ACK of the Sender's Next TSN minus 1 were
+	 *     received MUST be performed.
+	 */
+	max_tsn_seen = sctp_tsnmap_get_max_tsn_seen(&asoc->peer.tsn_map);
+	sctp_ulpq_reasm_flushtsn(&asoc->ulpq, max_tsn_seen);
+	sctp_ulpq_abort_pd(&asoc->ulpq, GFP_ATOMIC);
+
+	/* G1: Compute an appropriate value for the Receiver's Next TSN -- the
+	 *     TSN that the peer should use to send the next DATA chunk.  The
+	 *     value SHOULD be the smallest TSN not acknowledged by the
+	 *     receiver of the request plus 2^31.
+	 */
+	init_tsn = sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map) + (1 << 31);
+	sctp_tsnmap_init(&asoc->peer.tsn_map, SCTP_TSN_MAP_INITIAL,
+			 init_tsn, GFP_ATOMIC);
+
+	/* G4: The same processing as though a FWD-TSN chunk (as defined in
+	 *     [RFC3758]) with all streams affected and a new cumulative TSN
+	 *     ACK of the Receiver's Next TSN minus 1 were received MUST be
+	 *     performed.
+	 */
+	sctp_outq_free(&asoc->outqueue);
+
+	/* G2: Compute an appropriate value for the local endpoint's next TSN,
+	 *     i.e., the next TSN assigned by the receiver of the SSN/TSN reset
+	 *     chunk.  The value SHOULD be the highest TSN sent by the receiver
+	 *     of the request plus 1.
+	 */
+	next_tsn = asoc->next_tsn;
+	asoc->ctsn_ack_point = next_tsn - 1;
+	asoc->adv_peer_ack_point = asoc->ctsn_ack_point;
+
+	/* G5:  The next expected and outgoing SSNs MUST be reset to 0 for all
+	 *      incoming and outgoing streams.
+	 */
+	for (i = 0; i < stream->outcnt; i++)
+		stream->out[i].ssn = 0;
+	for (i = 0; i < stream->incnt; i++)
+		stream->in[i].ssn = 0;
+
+	result = SCTP_STRRESET_PERFORMED;
+
+	*evp = sctp_ulpevent_make_assoc_reset_event(asoc, 0, init_tsn,
+						    next_tsn, GFP_ATOMIC);
+
+out:
+	return sctp_make_strreset_tsnresp(asoc, result, request_seq,
+					  next_tsn, init_tsn);
+}
-- 
2.1.0
