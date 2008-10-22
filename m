From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 4/4] sctp: Fix to handle SHUTDOWN in SHUTDOWN_RECEIVED state
Date: Tue, 21 Oct 2008 22:08:47 -0400
Message-ID: <1224641327-11913-5-git-send-email-vladislav.yasevich@hp.com>
References: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:13723 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbYJVCIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 22:08:54 -0400
In-Reply-To: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

Once an endpoint has reached the SHUTDOWN-RECEIVED state,
it MUST NOT send a SHUTDOWN in response to a ULP request.
The Cumulative TSN Ack of the received SHUTDOWN chunk
MUST be processed.

This patch fix to process Cumulative TSN Ack of the received
SHUTDOWN chunk in SHUTDOWN_RECEIVED state.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/sm.h    |    1 +
 net/sctp/sm_statefuns.c  |   45 +++++++++++++++++++++++++++++++++++++++++++++
 net/sctp/sm_statetable.c |    2 +-
 3 files changed, 47 insertions(+), 1 deletions(-)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 029a54a..c1dd893 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -125,6 +125,7 @@ sctp_state_fn_t sctp_sf_beat_8_3;
 sctp_state_fn_t sctp_sf_backbeat_8_3;
 sctp_state_fn_t sctp_sf_do_9_2_final;
 sctp_state_fn_t sctp_sf_do_9_2_shutdown;
+sctp_state_fn_t sctp_sf_do_9_2_shut_ctsn;
 sctp_state_fn_t sctp_sf_do_ecn_cwr;
 sctp_state_fn_t sctp_sf_do_ecne;
 sctp_state_fn_t sctp_sf_ootb;
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 12f6217..a6a0ea7 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2608,6 +2608,51 @@ out:
 	return disposition;
 }
 
+/*
+ * sctp_sf_do_9_2_shut_ctsn
+ *
+ * Once an endpoint has reached the SHUTDOWN-RECEIVED state,
+ * it MUST NOT send a SHUTDOWN in response to a ULP request.
+ * The Cumulative TSN Ack of the received SHUTDOWN chunk
+ * MUST be processed.
+ */
+sctp_disposition_t sctp_sf_do_9_2_shut_ctsn(const struct sctp_endpoint *ep,
+					   const struct sctp_association *asoc,
+					   const sctp_subtype_t type,
+					   void *arg,
+					   sctp_cmd_seq_t *commands)
+{
+	struct sctp_chunk *chunk = arg;
+	sctp_shutdownhdr_t *sdh;
+
+	if (!sctp_vtag_verify(chunk, asoc))
+		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
+
+	/* Make sure that the SHUTDOWN chunk has a valid length. */
+	if (!sctp_chunk_length_valid(chunk,
+				      sizeof(struct sctp_shutdown_chunk_t)))
+		return sctp_sf_violation_chunklen(ep, asoc, type, arg,
+						  commands);
+
+	sdh = (sctp_shutdownhdr_t *)chunk->skb->data;
+
+	/* If Cumulative TSN Ack beyond the max tsn currently
+	 * send, terminating the association and respond to the
+	 * sender with an ABORT.
+	 */
+	if (!TSN_lt(ntohl(sdh->cum_tsn_ack), asoc->next_tsn))
+		return sctp_sf_violation_ctsn(ep, asoc, type, arg, commands);
+
+	/* verify, by checking the Cumulative TSN Ack field of the
+	 * chunk, that all its outstanding DATA chunks have been
+	 * received by the SHUTDOWN sender.
+	 */
+	sctp_add_cmd_sf(commands, SCTP_CMD_PROCESS_CTSN,
+			SCTP_BE32(sdh->cum_tsn_ack));
+
+	return SCTP_DISPOSITION_CONSUME;
+}
+
 /* RFC 2960 9.2
  * If an endpoint is in SHUTDOWN-ACK-SENT state and receives an INIT chunk
  * (e.g., if the SHUTDOWN COMPLETE was lost) with source and destination
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index a5b5590..5c8186d 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -270,7 +270,7 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
 	TYPE_SCTP_FUNC(sctp_sf_do_9_2_shutdown_ack), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	TYPE_SCTP_FUNC(sctp_sf_do_9_2_shut_ctsn), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
 	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 } /* TYPE_SCTP_SHUTDOWN */
-- 
1.5.3.5

