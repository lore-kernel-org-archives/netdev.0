From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 6/7] sctp: implement receiver-side procedures for the Reconf Response Parameter
Date: Fri, 10 Mar 2017 12:11:11 +0800
Message-ID: <6be290927b01181a7dc18ebef5c0a0f5de62fd82.1489118815.git.lucien.xin@gmail.com>
References: <cover.1489118815.git.lucien.xin@gmail.com>
 <7bf94990cf77044e0286adc2f393af4c9010213c.1489118815.git.lucien.xin@gmail.com>
 <f224235b4621ea3a182e959873f6fe0ba78e5416.1489118815.git.lucien.xin@gmail.com>
 <70b0da1e9de612702d0ddcdeab67e56b6d11fd78.1489118815.git.lucien.xin@gmail.com>
 <f73e5ede81d0eeccdf955eb7d77eadcda5166c9e.1489118815.git.lucien.xin@gmail.com>
 <7def0879be34d7e8a8bc1f11cc62ae8570bfcf26.1489118815.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36545 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754321AbdCJEML (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 23:12:11 -0500
In-Reply-To: <7def0879be34d7e8a8bc1f11cc62ae8570bfcf26.1489118815.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1489118815.git.lucien.xin@gmail.com>
References: <cover.1489118815.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to implement Receiver-Side Procedures for the
Re-configuration Response Parameter in rfc6525 section 5.2.7.

sctp_process_strreset_resp would process the response for any
kind of reconf request, and the stream reconf is applied only
when the response result is success.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h   |   4 ++
 net/sctp/sm_statefuns.c |   6 +-
 net/sctp/stream.c       | 154 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 161 insertions(+), 3 deletions(-)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index e0d9825..47113f2 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -305,6 +305,10 @@ struct sctp_chunk *sctp_process_strreset_addstrm_in(
 				struct sctp_association *asoc,
 				union sctp_params param,
 				struct sctp_ulpevent **evp);
+struct sctp_chunk *sctp_process_strreset_resp(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp);
 
 /* Prototypes for statetable processing. */
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index a8687a7..ab1374f 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3881,9 +3881,9 @@ sctp_disposition_t sctp_sf_do_reconf(struct net *net,
 		else if (param.p->type == SCTP_PARAM_RESET_ADD_IN_STREAMS)
 			reply = sctp_process_strreset_addstrm_in(
 				(struct sctp_association *)asoc, param, &ev);
-		/* More handles for other types will be added here, by now it
-		 * just ignores other types.
-		 */
+		else if (param.p->type == SCTP_PARAM_RESET_RESPONSE)
+			reply = sctp_process_strreset_resp(
+				(struct sctp_association *)asoc, param, &ev);
 
 		if (ev)
 			sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 1c925db..961d0a1 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -675,3 +675,157 @@ struct sctp_chunk *sctp_process_strreset_addstrm_in(
 
 	return chunk;
 }
+
+struct sctp_chunk *sctp_process_strreset_resp(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp)
+{
+	struct sctp_strreset_resp *resp = param.v;
+	struct sctp_stream *stream = asoc->stream;
+	struct sctp_transport *t;
+	__u16 i, nums, flags = 0;
+	sctp_paramhdr_t *req;
+	__u32 result;
+
+	req = sctp_chunk_lookup_strreset_param(asoc, resp->response_seq, 0);
+	if (!req)
+		return NULL;
+
+	result = ntohl(resp->result);
+	if (result != SCTP_STRRESET_PERFORMED) {
+		/* if in progress, do nothing but retransmit */
+		if (result == SCTP_STRRESET_IN_PROGRESS)
+			return NULL;
+		else if (result == SCTP_STRRESET_DENIED)
+			flags = SCTP_STREAM_RESET_DENIED;
+		else
+			flags = SCTP_STREAM_RESET_FAILED;
+	}
+
+	if (req->type == SCTP_PARAM_RESET_OUT_REQUEST) {
+		struct sctp_strreset_outreq *outreq;
+		__u16 *str_p = NULL;
+
+		outreq = (struct sctp_strreset_outreq *)req;
+		nums = (ntohs(outreq->param_hdr.length) - sizeof(*outreq)) / 2;
+
+		if (result == SCTP_STRRESET_PERFORMED) {
+			if (nums) {
+				str_p = outreq->list_of_streams;
+				for (i = 0; i < nums; i++)
+					stream->out[ntohs(str_p[i])].ssn = 0;
+			} else {
+				for (i = 0; i < stream->outcnt; i++)
+					stream->out[i].ssn = 0;
+			}
+
+			flags = SCTP_STREAM_RESET_OUTGOING_SSN;
+		}
+
+		for (i = 0; i < stream->outcnt; i++)
+			stream->out[i].state = SCTP_STREAM_OPEN;
+
+		*evp = sctp_ulpevent_make_stream_reset_event(asoc, flags,
+			nums, str_p, GFP_ATOMIC);
+	} else if (req->type == SCTP_PARAM_RESET_IN_REQUEST) {
+		struct sctp_strreset_inreq *inreq;
+		__u16 *str_p = NULL;
+
+		/* if the result is performed, it's impossible for inreq */
+		if (result == SCTP_STRRESET_PERFORMED)
+			return NULL;
+
+		inreq = (struct sctp_strreset_inreq *)req;
+		nums = (ntohs(inreq->param_hdr.length) - sizeof(*inreq)) / 2;
+
+		str_p = inreq->list_of_streams;
+		*evp = sctp_ulpevent_make_stream_reset_event(asoc, flags,
+			nums, str_p, GFP_ATOMIC);
+	} else if (req->type == SCTP_PARAM_RESET_TSN_REQUEST) {
+		struct sctp_strreset_resptsn *resptsn;
+		__u32 stsn, rtsn;
+
+		/* check for resptsn, as sctp_verify_reconf didn't do it*/
+		if (ntohs(param.p->length) != sizeof(*resptsn))
+			return NULL;
+
+		resptsn = (struct sctp_strreset_resptsn *)resp;
+		stsn = ntohl(resptsn->senders_next_tsn);
+		rtsn = ntohl(resptsn->receivers_next_tsn);
+
+		if (result == SCTP_STRRESET_PERFORMED) {
+			__u32 mtsn = sctp_tsnmap_get_max_tsn_seen(
+						&asoc->peer.tsn_map);
+
+			sctp_ulpq_reasm_flushtsn(&asoc->ulpq, mtsn);
+			sctp_ulpq_abort_pd(&asoc->ulpq, GFP_ATOMIC);
+
+			sctp_tsnmap_init(&asoc->peer.tsn_map,
+					 SCTP_TSN_MAP_INITIAL,
+					 stsn, GFP_ATOMIC);
+
+			sctp_outq_free(&asoc->outqueue);
+
+			asoc->next_tsn = rtsn;
+			asoc->ctsn_ack_point = asoc->next_tsn - 1;
+			asoc->adv_peer_ack_point = asoc->ctsn_ack_point;
+
+			for (i = 0; i < stream->outcnt; i++)
+				stream->out[i].ssn = 0;
+			for (i = 0; i < stream->incnt; i++)
+				stream->in[i].ssn = 0;
+		}
+
+		for (i = 0; i < stream->outcnt; i++)
+			stream->out[i].state = SCTP_STREAM_OPEN;
+
+		*evp = sctp_ulpevent_make_assoc_reset_event(asoc, flags,
+			stsn, rtsn, GFP_ATOMIC);
+	} else if (req->type == SCTP_PARAM_RESET_ADD_OUT_STREAMS) {
+		struct sctp_strreset_addstrm *addstrm;
+		__u16 number;
+
+		addstrm = (struct sctp_strreset_addstrm *)req;
+		nums = ntohs(addstrm->number_of_streams);
+		number = stream->outcnt - nums;
+
+		if (result == SCTP_STRRESET_PERFORMED)
+			for (i = number; i < stream->outcnt; i++)
+				stream->out[i].state = SCTP_STREAM_OPEN;
+		else
+			stream->outcnt = number;
+
+		*evp = sctp_ulpevent_make_stream_change_event(asoc, flags,
+			0, nums, GFP_ATOMIC);
+	} else if (req->type == SCTP_PARAM_RESET_ADD_IN_STREAMS) {
+		struct sctp_strreset_addstrm *addstrm;
+
+		/* if the result is performed, it's impossible for addstrm in
+		 * request.
+		 */
+		if (result == SCTP_STRRESET_PERFORMED)
+			return NULL;
+
+		addstrm = (struct sctp_strreset_addstrm *)req;
+		nums = ntohs(addstrm->number_of_streams);
+
+		*evp = sctp_ulpevent_make_stream_change_event(asoc, flags,
+			nums, 0, GFP_ATOMIC);
+	}
+
+	asoc->strreset_outstanding--;
+	asoc->strreset_outseq++;
+
+	/* remove everything for this reconf request */
+	if (!asoc->strreset_outstanding) {
+		t = asoc->strreset_chunk->transport;
+		if (del_timer(&t->reconf_timer))
+			sctp_transport_put(t);
+
+		sctp_chunk_put(asoc->strreset_chunk);
+		asoc->strreset_chunk = NULL;
+	}
+
+	return NULL;
+}
-- 
2.1.0
