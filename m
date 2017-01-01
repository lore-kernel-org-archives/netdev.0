From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 25/27] sctp: add rfc6525 section 5.2.7
Date: Sun,  1 Jan 2017 19:20:42 +0800
Message-ID: <880e62cecc950ad9b5dad09ae581e5e6f92ecf46.1483269426.git.lucien.xin@gmail.com>
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
 <470b9f2b5248e0c1870c501f262a1887be66509b.1483269426.git.lucien.xin@gmail.com>
 <105630d2f9a54de9c3ce49988452d2b111c71b3d.1483269426.git.lucien.xin@gmail.com>
 <19ee2333d24194c0a4b3e724a1a738873ca27445.1483269426.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33670 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932066AbdAALYM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:24:12 -0500
In-Reply-To: <19ee2333d24194c0a4b3e724a1a738873ca27445.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to implement Receiver-Side Procedures for the
Re-configuration Response Parameter in section 5.2.7.

sctp_process_strreset_resp would process the response for any
kind of reconf request, and the stream reconf is applied only
when the response result is success.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h |   4 ++
 net/sctp/stream.c     | 163 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 167 insertions(+)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index b8ca767..7c2f956 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -301,6 +301,10 @@ struct sctp_chunk *sctp_process_strreset_addstrm_in(
 				struct sctp_association *asoc,
 				union sctp_params param,
 				struct sctp_ulpevent **evp);
+struct sctp_chunk *sctp_process_strreset_resp(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp);
 
 /* Prototypes for statetable processing. */
 
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index a2b248b..ae64de2 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -398,3 +398,166 @@ struct sctp_chunk *sctp_process_strreset_addstrm_in(
 out:
 	return sctp_make_strreset_resp(asoc, result, request_seq);
 }
+
+struct sctp_chunk *sctp_process_strreset_resp(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp)
+{
+	struct sctp_strreset_resp *resp = param.v;
+	struct sctp_strreset_req *req;
+	struct sctp_transport *t;
+	__u16 i, nums, flags = 0;
+	__u32 result;
+
+	req = sctp_chunk_lookup_strreset_param(
+				asoc, ntohl(resp->response_seq));
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
+	if (req->param_hdr.type == SCTP_PARAM_RESET_OUT_REQUEST) {
+		struct sctp_strreset_outreq *outreq;
+		__u16 *str_p = NULL;
+
+		outreq = (struct sctp_strreset_outreq *)req;
+		nums = (ntohs(outreq->param_hdr.length) - sizeof(*outreq)) / 2;
+
+		if (nums) {
+			str_p = outreq->list_of_streams;
+			for (i = 0; i < nums; i++)
+				str_p[i] = ntohs(str_p[i]);
+		}
+
+		if (result == SCTP_STRRESET_PERFORMED) {
+			if (nums) {
+				str_p = outreq->list_of_streams;
+				for (i = 0; i < nums; i++, str_p++)
+					asoc->streamout[*str_p].ssn = 0;
+			} else {
+				for (i = 0; i < asoc->streamoutcnt; i++)
+					asoc->streamout[i].ssn = 0;
+			}
+
+			flags = SCTP_STREAM_RESET_OUTGOING_SSN;
+		}
+
+		for (i = 0; i < asoc->streamoutcnt; i++)
+			asoc->streamout[i].state = SCTP_STREAM_OPEN;
+
+		*evp = sctp_ulpevent_make_stream_reset_event(asoc, flags,
+			nums, str_p, GFP_ATOMIC);
+	} else if (req->param_hdr.type == SCTP_PARAM_RESET_IN_REQUEST) {
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
+		if (nums) {
+			str_p = inreq->list_of_streams;
+			for (i = 0; i < nums; i++)
+				str_p[i] = ntohs(str_p[i]);
+		}
+
+		str_p = inreq->list_of_streams;
+		*evp = sctp_ulpevent_make_stream_reset_event(asoc, flags,
+			nums, str_p, GFP_ATOMIC);
+	} else if (req->param_hdr.type == SCTP_PARAM_RESET_TSN_REQUEST) {
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
+			for (i = 0; i < asoc->streamoutcnt; i++)
+				asoc->streamout[i].ssn = 0;
+			for (i = 0; i < asoc->streamincnt; i++)
+				asoc->streamin[i].ssn = 0;
+		}
+
+		for (i = 0; i < asoc->streamoutcnt; i++)
+			asoc->streamout[i].state = SCTP_STREAM_OPEN;
+
+		*evp = sctp_ulpevent_make_assoc_reset_event(asoc, flags,
+			stsn, rtsn, GFP_ATOMIC);
+	} else if (req->param_hdr.type == SCTP_PARAM_RESET_ADD_OUT_STREAMS) {
+		struct sctp_strreset_addstrm *addstrm;
+		__u16 number;
+
+		addstrm = (struct sctp_strreset_addstrm *)req;
+		nums = ntohs(addstrm->number_of_streams);
+		number = asoc->streamoutcnt - nums;
+
+		if (result == SCTP_STRRESET_PERFORMED)
+			for (i = number; i < asoc->streamoutcnt; i++)
+				asoc->streamout[i].state = SCTP_STREAM_OPEN;
+		else
+			asoc->streamoutcnt = number;
+
+		*evp = sctp_ulpevent_make_stream_change_event(asoc, flags,
+			0, nums, GFP_ATOMIC);
+	} else if (req->param_hdr.type == SCTP_PARAM_RESET_ADD_IN_STREAMS) {
+		struct sctp_strreset_addstrm *addstrm;
+
+		addstrm = (struct sctp_strreset_addstrm *)req;
+		nums = ntohs(addstrm->number_of_streams);
+
+		if (result != SCTP_STRRESET_PERFORMED)
+			asoc->streamincnt = asoc->streamincnt - nums;
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
