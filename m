From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 6/7] sctp: add reconf chunk process
Date: Fri, 17 Feb 2017 12:45:42 +0800
Message-ID: <c226e65af5c013263d702ee4ee3fb1a7c6cac32f.1487306585.git.lucien.xin@gmail.com>
References: <cover.1487306585.git.lucien.xin@gmail.com>
 <f01759c2f5ab1be572d95480d6d4e7e94431d2b8.1487306585.git.lucien.xin@gmail.com>
 <3ee883ca4dd0ef75baa9ca5bfd9642d28160c10b.1487306585.git.lucien.xin@gmail.com>
 <07abdfdccbb39c94418b7a7887e82c5c12adf0c7.1487306585.git.lucien.xin@gmail.com>
 <3b70615422bf6d43013332d4b37c70160a0c1d32.1487306585.git.lucien.xin@gmail.com>
 <c90e5eac92a42c0d9ab69f7362fc6debf5512bad.1487306585.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34502 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932390AbdBQEqq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 23:46:46 -0500
In-Reply-To: <c90e5eac92a42c0d9ab69f7362fc6debf5512bad.1487306585.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1487306585.git.lucien.xin@gmail.com>
References: <cover.1487306585.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add a function to process the incoming reconf chunk,
in which it verifies the chunk, and traverses the param and process
it with the right function one by one.

sctp_sf_do_reconf would be the process function of reconf chunk event.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h   |  1 +
 net/sctp/sm_statefuns.c | 54 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index ca9fbfb..b6f682e 100644
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
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index d8798dd..e03bb1a 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3834,6 +3834,60 @@ sctp_disposition_t sctp_sf_do_asconf_ack(struct net *net,
 	return SCTP_DISPOSITION_DISCARD;
 }
 
+/* RE-CONFIG Section 5.2 Upon reception of an RECONF Chunk. */
+sctp_disposition_t sctp_sf_do_reconf(struct net *net,
+				     const struct sctp_endpoint *ep,
+				     const struct sctp_association *asoc,
+				     const sctp_subtype_t type, void *arg,
+				     sctp_cmd_seq_t *commands)
+{
+	struct sctp_paramhdr *err_param = NULL;
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
+		struct sctp_chunk *reply = NULL;
+		struct sctp_ulpevent *ev = NULL;
+
+		if (param.p->type == SCTP_PARAM_RESET_OUT_REQUEST)
+			reply = sctp_process_strreset_outreq(
+				(struct sctp_association *)asoc, param, &ev);
+		else if (param.p->type == SCTP_PARAM_RESET_IN_REQUEST)
+			reply = sctp_process_strreset_inreq(
+				(struct sctp_association *)asoc, param, &ev);
+		/* More handles for other types will be added here, by now it
+		 * just ignores other types.
+		 */
+
+		if (ev)
+			sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
+					SCTP_ULPEVENT(ev));
+
+		if (reply)
+			sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
+					SCTP_CHUNK(reply));
+	}
+
+	return SCTP_DISPOSITION_CONSUME;
+}
+
 /*
  * PR-SCTP Section 3.6 Receiver Side Implementation of PR-SCTP
  *
-- 
2.1.0
