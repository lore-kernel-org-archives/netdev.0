From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 26/27] sctp: add sctp reconf chunk process
Date: Sun,  1 Jan 2017 19:20:43 +0800
Message-ID: <24997940f9c6ca9d4cbb8ce72741fdddcfe4ebc1.1483269426.git.lucien.xin@gmail.com>
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
 <880e62cecc950ad9b5dad09ae581e5e6f92ecf46.1483269426.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34058 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755090AbdAALYU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:24:20 -0500
In-Reply-To: <880e62cecc950ad9b5dad09ae581e5e6f92ecf46.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add a function to process the incoming reconf chunk,
in which it verifies the chunk, and traverses the param and process
it with the right function one by one.

sctp_sf_do_reconf would be the process function of reconf chunk event.

Note that to support multi-params in response chunk, it also adds a
function sctp_merge_reconf_chunk to merge two reconf chunk into one.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h    |  8 +++++
 net/sctp/sm_make_chunk.c | 94 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/sctp/sm_statefuns.c  | 68 +++++++++++++++++++++++++++++++++++
 3 files changed, 170 insertions(+)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 7c2f956..17984eb 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -135,6 +135,7 @@ sctp_state_fn_t sctp_sf_do_8_5_1_E_sa;
 sctp_state_fn_t sctp_sf_cookie_echoed_err;
 sctp_state_fn_t sctp_sf_do_asconf;
 sctp_state_fn_t sctp_sf_do_asconf_ack;
+sctp_state_fn_t sctp_sf_do_reconf;
 sctp_state_fn_t sctp_sf_do_9_2_reshutack;
 sctp_state_fn_t sctp_sf_eat_fwd_tsn;
 sctp_state_fn_t sctp_sf_eat_fwd_tsn_fast;
@@ -277,6 +278,13 @@ struct sctp_chunk *sctp_make_strreset_tsnresp(
 struct sctp_chunk *sctp_make_strreset_addstrm(
 				const struct sctp_association *asoc,
 				__u16 out, __u16 in);
+struct sctp_chunk *sctp_merge_reconf_chunk(
+				struct sctp_association *asoc,
+				struct sctp_chunk *last,
+				struct sctp_chunk *reply);
+bool sctp_verify_reconf(const struct sctp_association *asoc,
+			struct sctp_chunk *chunk,
+			struct sctp_paramhdr **errp);
 void sctp_chunk_assign_tsn(struct sctp_chunk *);
 void sctp_chunk_assign_ssn(struct sctp_chunk *);
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index f1efba6..74c3fee 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3819,3 +3819,97 @@ struct sctp_chunk *sctp_make_strreset_addstrm(
 
 	return retval;
 }
+
+struct sctp_chunk *sctp_merge_reconf_chunk(
+				struct sctp_association *asoc,
+				struct sctp_chunk *last,
+				struct sctp_chunk *reply)
+{
+	struct sctp_chunk *retval = NULL;
+	__u16 lsize, rsize;
+
+	if (!reply)
+		return last;
+
+	rsize = ntohs(reply->param_hdr.p->length);
+	lsize = ntohs(last->param_hdr.p->length);
+
+	retval = sctp_make_reconf(asoc, lsize + rsize);
+	if (!retval)
+		goto out;
+
+	sctp_addto_chunk(retval, lsize, last->param_hdr.v);
+	sctp_addto_chunk(retval, rsize, reply->param_hdr.v);
+
+out:
+	if (asoc->strreset_chunk) {
+		sctp_chunk_put(asoc->strreset_chunk);
+		asoc->strreset_chunk = retval;
+		if (asoc->strreset_chunk)
+			sctp_chunk_hold(asoc->strreset_chunk);
+	}
+
+	sctp_chunk_free(reply);
+	sctp_chunk_free(last);
+
+	return retval;
+}
+
+bool sctp_verify_reconf(const struct sctp_association *asoc,
+			struct sctp_chunk *chunk,
+			struct sctp_paramhdr **errp)
+{
+	struct sctp_reconf_chunk *hdr;
+	union sctp_params param;
+	__u16 last = 0, cnt = 0;
+
+	hdr = (struct sctp_reconf_chunk *)chunk->chunk_hdr;
+	sctp_walk_params(param, hdr, params) {
+		__u16 length = ntohs(param.p->length);
+
+		*errp = param.p;
+		if (cnt++ > 2)
+			return false;
+		switch (param.p->type) {
+		case SCTP_PARAM_RESET_OUT_REQUEST:
+			if (length < sizeof(struct sctp_strreset_outreq) ||
+			    (last && last != SCTP_PARAM_RESET_RESPONSE &&
+			     last != SCTP_PARAM_RESET_IN_REQUEST))
+				return false;
+			break;
+		case SCTP_PARAM_RESET_IN_REQUEST:
+			if (length < sizeof(struct sctp_strreset_inreq) ||
+			    (last && last != SCTP_PARAM_RESET_OUT_REQUEST))
+				return false;
+			break;
+		case SCTP_PARAM_RESET_RESPONSE:
+			if ((length != sizeof(struct sctp_strreset_resp) &&
+			     length != sizeof(struct sctp_strreset_resptsn)) ||
+			    (last && last != SCTP_PARAM_RESET_RESPONSE &&
+			     last != SCTP_PARAM_RESET_OUT_REQUEST))
+				return false;
+			break;
+		case SCTP_PARAM_RESET_TSN_REQUEST:
+			if (length !=
+			    sizeof(struct sctp_strreset_tsnreq) || last)
+				return false;
+			break;
+		case SCTP_PARAM_RESET_ADD_IN_STREAMS:
+			if (length != sizeof(struct sctp_strreset_addstrm) ||
+			    (last && last != SCTP_PARAM_RESET_ADD_OUT_STREAMS))
+				return false;
+			break;
+		case SCTP_PARAM_RESET_ADD_OUT_STREAMS:
+			if (length != sizeof(struct sctp_strreset_addstrm) ||
+			    (last && last != SCTP_PARAM_RESET_ADD_IN_STREAMS))
+				return false;
+			break;
+		default:
+			return false;
+		}
+
+		last = param.p->type;
+	}
+
+	return true;
+}
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index c06b134..4b05bd5 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3834,6 +3834,74 @@ sctp_disposition_t sctp_sf_do_asconf_ack(struct net *net,
 	return SCTP_DISPOSITION_DISCARD;
 }
 
+/* RE-CONFIG Section 5.2 Upon reception of an RECONF Chunk.  */
+sctp_disposition_t sctp_sf_do_reconf(struct net *net,
+				     const struct sctp_endpoint *ep,
+				     const struct sctp_association *asoc,
+				     const sctp_subtype_t type, void *arg,
+				     sctp_cmd_seq_t *commands)
+{
+	struct sctp_paramhdr *err_param = NULL;
+	struct sctp_chunk *reply = NULL;
+	struct sctp_chunk *last = NULL;
+	struct sctp_chunk *chunk = arg;
+	struct sctp_reconf_chunk *hdr;
+	union sctp_params param;
+
+	if (!sctp_vtag_verify(chunk, asoc)) {
+		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_BAD_TAG,
+				SCTP_NULL());
+		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
+	}
+
+	/* Make sure that the RECONF chunk has a valid length.  */
+	if (!sctp_chunk_length_valid(chunk, sizeof(*hdr)))
+		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
+						  commands);
+
+	if (!sctp_verify_reconf(asoc, chunk, &err_param))
+		return sctp_sf_violation_paramlen(net, ep, asoc, type, arg,
+						  (void *)err_param, commands);
+
+	hdr = (struct sctp_reconf_chunk *)chunk->chunk_hdr;
+	sctp_walk_params(param, hdr, params) {
+		struct sctp_ulpevent *ev = NULL;
+
+		if (param.p->type == SCTP_PARAM_RESET_OUT_REQUEST)
+			reply = sctp_process_strreset_outreq(
+				(struct sctp_association *)asoc, param, &ev);
+		else if (param.p->type == SCTP_PARAM_RESET_IN_REQUEST)
+			reply = sctp_process_strreset_inreq(
+				(struct sctp_association *)asoc, param, &ev);
+		else if (param.p->type == SCTP_PARAM_RESET_TSN_REQUEST)
+			reply = sctp_process_strreset_tsnreq(
+				(struct sctp_association *)asoc, param, &ev);
+		else if (param.p->type == SCTP_PARAM_RESET_ADD_OUT_STREAMS)
+			reply = sctp_process_strreset_addstrm_out(
+				(struct sctp_association *)asoc, param, &ev);
+		else if (param.p->type == SCTP_PARAM_RESET_ADD_IN_STREAMS)
+			reply = sctp_process_strreset_addstrm_in(
+				(struct sctp_association *)asoc, param, &ev);
+		else if (param.p->type == SCTP_PARAM_RESET_RESPONSE)
+			reply = sctp_process_strreset_resp(
+				(struct sctp_association *)asoc, param, &ev);
+
+		if (ev)
+			sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
+					SCTP_ULPEVENT(ev));
+
+		if (last)
+			reply = sctp_merge_reconf_chunk(
+				(struct sctp_association *)asoc, last, reply);
+		last = reply;
+	}
+
+	if (reply)
+		sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(reply));
+
+	return SCTP_DISPOSITION_CONSUME;
+}
+
 /*
  * PR-SCTP Section 3.6 Receiver Side Implementation of PR-SCTP
  *
-- 
2.1.0
