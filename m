From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 22/27] sctp: add rfc6525 section 5.2.4
Date: Sun,  1 Jan 2017 19:20:39 +0800
Message-ID: <470b9f2b5248e0c1870c501f262a1887be66509b.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
 <684ad8ddd79f23844883dede4c34360ce744dfc3.1483269426.git.lucien.xin@gmail.com>
 <c752879a5af358c08da949b391416452f1322c43.1483269426.git.lucien.xin@gmail.com>
 <be8a2770ddc2381266050c9f168add9802b90a49.1483269426.git.lucien.xin@gmail.com>
 <fc046afdda34c9b262ce57400c4256b14fd1a0fb.1483269426.git.lucien.xin@gmail.com>
 <d4f1b2a4fa19457e9867b0a1f84764a7a509459a.1483269426.git.lucien.xin@gmail.com>
 <31abc54d31ef0714322f137bff43458014d7c276.1483269426.git.lucien.xin@gmail.com>
 <58860816816d6d51b062235fd54dae6540a4797a.1483269426.git.lucien.xin@gmail.com>
 <229608faf7af54c0bf908694ca8349205bbf6eab.1483269426.git.lucien.xin@gmail.com>
 <c4f16844620cd3a2aa76596df9eaadf1505fc8e6.1483269426.git.lucien.xin@gmail.com>
 <1d0b270084289945c4b42ae36d0556648a3f9b64.1483269426.git.lucien.xin@gmail.com>
 <1e4560205cff3c10868d5614b62a3db14e87ccf0.1483269426.git.lucien.xin@gmail.com>
 <91b9171cc57c0f322d103dfbbcce1b9706800805.1483269426.git.lucien.xin@gmail.com>
 <d5fb0969ea5d055dea5bdc257569530b6d2fc7c2.1483269426.git.lucien.xin@gmail.com>
 <6a74f5a3ac408f20816a8c79edd6b9922ed3b573.1483269426.git.lucien.xin@gmail.com>
 <ef7d01cf1d5826e694a08303ee0b36c00201c666.1483269426.git.lucien.xin@gmail.com>
 <86b68f131d286ee20781cb04ce9d09d477aa5232.1483269426.git.lucien.xin@gmail.com>
 <1e8e248c38fd3874cf80c4b88e4699c8a617066d.1483269426.git.lucien.xin@gmail.com>
 <3a60ce82edef82f329fe2cc4ac83e9ca21831d8b.1483269426.git.lucien.xin@gmail.com>
 <9be4c65c6bac7df0dbf51328af92727e5606dc5c.1483269426.git.lucien.xin@gmail.com>
 <b5eb3a199dded2efe517b19b5cac6ae498a6c0c8.1483269426.git.lucien.xin@gmail.com>
 <c59df697bb54348de10f8418a23e9d14bce30135.1483269426.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35506 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932079AbdAALXs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:23:48 -0500
In-Reply-To: <c59df697bb54348de10f8418a23e9d14bce30135.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to implement Receiver-Side Procedures for the SSN/TSN
Reset Request Parameter described in section 6.2.4.

The process is kinda complicate, it's wonth having comments from
section 6.2.4 in the codes.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h |  4 +++
 net/sctp/stream.c     | 76 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 80 insertions(+)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 180d017..e1b2509 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -289,6 +289,10 @@ struct sctp_chunk *sctp_process_strreset_inreq(
 				struct sctp_association *asoc,
 				union sctp_params param,
 				struct sctp_ulpevent **evp);
+struct sctp_chunk *sctp_process_strreset_tsnreq(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp);
 
 /* Prototypes for statetable processing. */
 
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 3053d06..fce4317 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -207,3 +207,79 @@ struct sctp_chunk *sctp_process_strreset_inreq(
 
 	return chunk;
 }
+
+struct sctp_chunk *sctp_process_strreset_tsnreq(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp)
+{
+	struct sctp_strreset_tsnreq *tsnreq = param.v;
+	__u32 request_seq, initial_tsn, max_tsn_seen;
+	__u32 result = SCTP_STRRESET_DENIED;
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
+	initial_tsn = sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map) + (1 << 31);
+	sctp_tsnmap_init(&asoc->peer.tsn_map, SCTP_TSN_MAP_INITIAL,
+			 initial_tsn, GFP_ATOMIC);
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
+	asoc->ctsn_ack_point = asoc->next_tsn - 1;
+	asoc->adv_peer_ack_point = asoc->ctsn_ack_point;
+
+	/* G5:  The next expected and outgoing SSNs MUST be reset to 0 for all
+	 *      incoming and outgoing streams.
+	 */
+	for (i = 0; i < asoc->streamoutcnt; i++)
+		asoc->streamout[i].ssn = 0;
+	for (i = 0; i < asoc->streamincnt; i++)
+		asoc->streamin[i].ssn = 0;
+
+	result = SCTP_STRRESET_PERFORMED;
+
+	*evp = sctp_ulpevent_make_assoc_reset_event(asoc,
+		0, initial_tsn, asoc->next_tsn, GFP_ATOMIC);
+
+out:
+	return sctp_make_strreset_tsnresp(asoc, result, request_seq,
+					  asoc->next_tsn, initial_tsn);
+}
-- 
2.1.0
