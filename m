From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2/2] sctp: fix kernel panic with ERROR chunk containing too many error causes
Date: Mon,  2 Mar 2009 11:46:51 -0500
Message-ID: <1236012411-17841-3-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:1370 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754820AbZCBQrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 11:47:01 -0500
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

If ERROR chunk is received with too many error causes in ESTABLISHED
state, the kernel get panic.

This is because sctp limit the max length of cmds to 14, but while
ERROR chunk is received, one error cause will add around 2 cmds by
sctp_add_cmd_sf(). So many error causes will fill the limit of cmds
and panic.

This patch fixed the problem.

This bug can be test by SCTP Conformance Test Suite
<http://networktest.sourceforge.net/>.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_sideeffect.c |   60 +++++++++++++++++++++++++++------------------
 net/sctp/sm_statefuns.c  |   16 +----------
 2 files changed, 38 insertions(+), 38 deletions(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index e1d6076..b5495ae 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -787,36 +787,48 @@ static void sctp_cmd_process_operr(sctp_cmd_seq_t *cmds,
 				   struct sctp_association *asoc,
 				   struct sctp_chunk *chunk)
 {
-	struct sctp_operr_chunk *operr_chunk;
 	struct sctp_errhdr *err_hdr;
+	struct sctp_ulpevent *ev;
 
-	operr_chunk = (struct sctp_operr_chunk *)chunk->chunk_hdr;
-	err_hdr = &operr_chunk->err_hdr;
+	while (chunk->chunk_end > chunk->skb->data) {
+		err_hdr = (struct sctp_errhdr *)(chunk->skb->data);
 
-	switch (err_hdr->cause) {
-	case SCTP_ERROR_UNKNOWN_CHUNK:
-	{
-		struct sctp_chunkhdr *unk_chunk_hdr;
+		ev = sctp_ulpevent_make_remote_error(asoc, chunk, 0,
+						     GFP_ATOMIC);
+		if (!ev)
+			return;
 
-		unk_chunk_hdr = (struct sctp_chunkhdr *)err_hdr->variable;
-		switch (unk_chunk_hdr->type) {
-		/* ADDIP 4.1 A9) If the peer responds to an ASCONF with an
-		 * ERROR chunk reporting that it did not recognized the ASCONF
-		 * chunk type, the sender of the ASCONF MUST NOT send any
-		 * further ASCONF chunks and MUST stop its T-4 timer.
-		 */
-		case SCTP_CID_ASCONF:
-			asoc->peer.asconf_capable = 0;
-			sctp_add_cmd_sf(cmds, SCTP_CMD_TIMER_STOP,
+		sctp_ulpq_tail_event(&asoc->ulpq, ev);
+
+		switch (err_hdr->cause) {
+		case SCTP_ERROR_UNKNOWN_CHUNK:
+		{
+			sctp_chunkhdr_t *unk_chunk_hdr;
+
+			unk_chunk_hdr = (sctp_chunkhdr_t *)err_hdr->variable;
+			switch (unk_chunk_hdr->type) {
+			/* ADDIP 4.1 A9) If the peer responds to an ASCONF with
+			 * an ERROR chunk reporting that it did not recognized
+			 * the ASCONF chunk type, the sender of the ASCONF MUST
+			 * NOT send any further ASCONF chunks and MUST stop its
+			 * T-4 timer.
+			 */
+			case SCTP_CID_ASCONF:
+				if (asoc->peer.asconf_capable == 0)
+					break;
+
+				asoc->peer.asconf_capable = 0;
+				sctp_add_cmd_sf(cmds, SCTP_CMD_TIMER_STOP,
 					SCTP_TO(SCTP_EVENT_TIMEOUT_T4_RTO));
+				break;
+			default:
+				break;
+			}
 			break;
+		}
 		default:
 			break;
 		}
-		break;
-	}
-	default:
-		break;
 	}
 }
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 3a0cd07..f88dfde 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3163,7 +3163,6 @@ sctp_disposition_t sctp_sf_operr_notify(const struct sctp_endpoint *ep,
 					sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
-	struct sctp_ulpevent *ev;
 
 	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
@@ -3173,21 +3172,10 @@ sctp_disposition_t sctp_sf_operr_notify(const struct sctp_endpoint *ep,
 		return sctp_sf_violation_chunklen(ep, asoc, type, arg,
 						  commands);
 
-	while (chunk->chunk_end > chunk->skb->data) {
-		ev = sctp_ulpevent_make_remote_error(asoc, chunk, 0,
-						     GFP_ATOMIC);
-		if (!ev)
-			goto nomem;
+	sctp_add_cmd_sf(commands, SCTP_CMD_PROCESS_OPERR,
+			SCTP_CHUNK(chunk));
 
-		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
-				SCTP_ULPEVENT(ev));
-		sctp_add_cmd_sf(commands, SCTP_CMD_PROCESS_OPERR,
-				SCTP_CHUNK(chunk));
-	}
 	return SCTP_DISPOSITION_CONSUME;
-
-nomem:
-	return SCTP_DISPOSITION_NOMEM;
 }
 
 /*
-- 
1.5.4.3

