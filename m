From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH] cleanup of the sctp state table code
Date: Mon, 13 Nov 2006 14:38:05 +0100
Message-ID: <1163425085.5968.29.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:3108 "EHLO
	amsfep14-int.chello.nl") by vger.kernel.org with ESMTP
	id S1754625AbWKMNjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 08:39:22 -0500
To: sri@us.ibm.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I noticed an insane high density of repeated characters fixable by a
simple regular expression:

  % s/{.fn = \([^,]*\),[[:space:]]\+\(\\\n[[:space:]]\+\)\?.name = "\1"}/TYPE_SCTP_FUNC(\1)/g

(NOTE: the .name for .fn = sctp_sf_do_9_2_start_shutdown didn't match)

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---

 sm_statetable.c |  696 ++++++++++++++++++++++++++------------------------------
 1 file changed, 335 insertions(+), 361 deletions(-)

diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index 8bcca56..733dd87 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -104,325 +104,322 @@ const sctp_sm_table_entry_t *sctp_sm_loo
 	};
 }
 
+#define TYPE_SCTP_FUNC(func) {.fn = func, .name = #func}
+
 #define TYPE_SCTP_DATA { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_tabort_8_4_8, .name = "sctp_sf_tabort_8_4_8"}, \
+	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_eat_data_6_2, .name = "sctp_sf_eat_data_6_2"}, \
+	TYPE_SCTP_FUNC(sctp_sf_eat_data_6_2), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_eat_data_6_2, .name = "sctp_sf_eat_data_6_2"}, \
+	TYPE_SCTP_FUNC(sctp_sf_eat_data_6_2), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_eat_data_fast_4_4, .name = "sctp_sf_eat_data_fast_4_4"}, \
+	TYPE_SCTP_FUNC(sctp_sf_eat_data_fast_4_4), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 } /* TYPE_SCTP_DATA */
 
 #define TYPE_SCTP_INIT { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_do_5_1B_init, .name = "sctp_sf_do_5_1B_init"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_1B_init), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_do_5_2_1_siminit, .name = "sctp_sf_do_5_2_1_siminit"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_2_1_siminit), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_do_5_2_1_siminit, .name = "sctp_sf_do_5_2_1_siminit"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_2_1_siminit), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_do_5_2_2_dupinit, .name = "sctp_sf_do_5_2_2_dupinit"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_2_2_dupinit), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_do_5_2_2_dupinit, .name = "sctp_sf_do_5_2_2_dupinit"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_2_2_dupinit), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_do_5_2_2_dupinit, .name = "sctp_sf_do_5_2_2_dupinit"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_2_2_dupinit), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_do_5_2_2_dupinit, .name = "sctp_sf_do_5_2_2_dupinit"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_2_2_dupinit), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_do_9_2_reshutack, .name = "sctp_sf_do_9_2_reshutack"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_9_2_reshutack), \
 } /* TYPE_SCTP_INIT */
 
 #define TYPE_SCTP_INIT_ACK { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_do_5_1C_ack, .name = "sctp_sf_do_5_1C_ack"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_1C_ack), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 } /* TYPE_SCTP_INIT_ACK */
 
 #define TYPE_SCTP_SACK { \
 	/*  SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_tabort_8_4_8, .name = "sctp_sf_tabort_8_4_8"}, \
+	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_eat_sack_6_2, .name = "sctp_sf_eat_sack_6_2"}, \
+	TYPE_SCTP_FUNC(sctp_sf_eat_sack_6_2), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_eat_sack_6_2, .name = "sctp_sf_eat_sack_6_2"}, \
+	TYPE_SCTP_FUNC(sctp_sf_eat_sack_6_2), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_eat_sack_6_2, .name = "sctp_sf_eat_sack_6_2"}, \
+	TYPE_SCTP_FUNC(sctp_sf_eat_sack_6_2), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_eat_sack_6_2, .name = "sctp_sf_eat_sack_6_2"}, \
+	TYPE_SCTP_FUNC(sctp_sf_eat_sack_6_2), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 } /* TYPE_SCTP_SACK */
 
 #define TYPE_SCTP_HEARTBEAT { \
 	/*  SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_tabort_8_4_8, .name = "sctp_sf_tabort_8_4_8"}, \
+	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_beat_8_3, .name = "sctp_sf_beat_8_3"}, \
+	TYPE_SCTP_FUNC(sctp_sf_beat_8_3), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_beat_8_3, .name = "sctp_sf_beat_8_3"}, \
+	TYPE_SCTP_FUNC(sctp_sf_beat_8_3), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_beat_8_3, .name = "sctp_sf_beat_8_3"}, \
+	TYPE_SCTP_FUNC(sctp_sf_beat_8_3), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_beat_8_3, .name = "sctp_sf_beat_8_3"}, \
+	TYPE_SCTP_FUNC(sctp_sf_beat_8_3), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_beat_8_3, .name = "sctp_sf_beat_8_3"}, \
+	TYPE_SCTP_FUNC(sctp_sf_beat_8_3), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
 	/* This should not happen, but we are nice.  */ \
-	{.fn = sctp_sf_beat_8_3, .name = "sctp_sf_beat_8_3"}, \
+	TYPE_SCTP_FUNC(sctp_sf_beat_8_3), \
 } /* TYPE_SCTP_HEARTBEAT */
 
 #define TYPE_SCTP_HEARTBEAT_ACK { \
 	/*  SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_tabort_8_4_8, .name = "sctp_sf_tabort_8_4_8"}, \
+	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_violation, .name = "sctp_sf_violation"}, \
+	TYPE_SCTP_FUNC(sctp_sf_violation), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_backbeat_8_3, .name = "sctp_sf_backbeat_8_3"}, \
+	TYPE_SCTP_FUNC(sctp_sf_backbeat_8_3), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_backbeat_8_3, .name = "sctp_sf_backbeat_8_3"}, \
+	TYPE_SCTP_FUNC(sctp_sf_backbeat_8_3), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_backbeat_8_3, .name = "sctp_sf_backbeat_8_3"}, \
+	TYPE_SCTP_FUNC(sctp_sf_backbeat_8_3), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_backbeat_8_3, .name = "sctp_sf_backbeat_8_3"}, \
+	TYPE_SCTP_FUNC(sctp_sf_backbeat_8_3), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 } /* TYPE_SCTP_HEARTBEAT_ACK */
 
 #define TYPE_SCTP_ABORT { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_pdiscard, .name = "sctp_sf_pdiscard"}, \
+	TYPE_SCTP_FUNC(sctp_sf_pdiscard), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_cookie_wait_abort, .name = "sctp_sf_cookie_wait_abort"}, \
+	TYPE_SCTP_FUNC(sctp_sf_cookie_wait_abort), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_cookie_echoed_abort, \
-	 .name = "sctp_sf_cookie_echoed_abort"}, \
+	TYPE_SCTP_FUNC(sctp_sf_cookie_echoed_abort), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_do_9_1_abort, .name = "sctp_sf_do_9_1_abort"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_9_1_abort), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_shutdown_pending_abort, \
-	.name = "sctp_sf_shutdown_pending_abort"}, \
+	TYPE_SCTP_FUNC(sctp_sf_shutdown_pending_abort), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_shutdown_sent_abort, \
-	.name = "sctp_sf_shutdown_sent_abort"}, \
+	TYPE_SCTP_FUNC(sctp_sf_shutdown_sent_abort), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_do_9_1_abort, .name = "sctp_sf_do_9_1_abort"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_9_1_abort), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_shutdown_ack_sent_abort, \
-	.name = "sctp_sf_shutdown_ack_sent_abort"}, \
+	TYPE_SCTP_FUNC(sctp_sf_shutdown_ack_sent_abort), \
 } /* TYPE_SCTP_ABORT */
 
 #define TYPE_SCTP_SHUTDOWN { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_tabort_8_4_8, .name = "sctp_sf_tabort_8_4_8"}, \
+	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_do_9_2_shutdown, .name = "sctp_sf_do_9_2_shutdown"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_9_2_shutdown), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_do_9_2_shutdown_ack, \
-	 .name = "sctp_sf_do_9_2_shutdown_ack"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_9_2_shutdown_ack), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 } /* TYPE_SCTP_SHUTDOWN */
 
 #define TYPE_SCTP_SHUTDOWN_ACK { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_do_8_5_1_E_sa, .name = "sctp_sf_do_8_5_1_E_sa"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_8_5_1_E_sa), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_do_8_5_1_E_sa, .name = "sctp_sf_do_8_5_1_E_sa"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_8_5_1_E_sa), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_violation, .name = "sctp_sf_violation"}, \
+	TYPE_SCTP_FUNC(sctp_sf_violation), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_violation, .name = "sctp_sf_violation"}, \
+	TYPE_SCTP_FUNC(sctp_sf_violation), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_do_9_2_final, .name = "sctp_sf_do_9_2_final"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_9_2_final), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_violation, .name = "sctp_sf_violation"}, \
+	TYPE_SCTP_FUNC(sctp_sf_violation), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_do_9_2_final, .name = "sctp_sf_do_9_2_final"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_9_2_final), \
 } /* TYPE_SCTP_SHUTDOWN_ACK */
 
 #define TYPE_SCTP_ERROR { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_tabort_8_4_8, .name = "sctp_sf_tabort_8_4_8"}, \
+	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_cookie_echoed_err, .name = "sctp_sf_cookie_echoed_err"}, \
+	TYPE_SCTP_FUNC(sctp_sf_cookie_echoed_err), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_operr_notify, .name = "sctp_sf_operr_notify"}, \
+	TYPE_SCTP_FUNC(sctp_sf_operr_notify), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_operr_notify, .name = "sctp_sf_operr_notify"}, \
+	TYPE_SCTP_FUNC(sctp_sf_operr_notify), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_operr_notify, .name = "sctp_sf_operr_notify"}, \
+	TYPE_SCTP_FUNC(sctp_sf_operr_notify), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 } /* TYPE_SCTP_ERROR */
 
 #define TYPE_SCTP_COOKIE_ECHO { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_do_5_1D_ce, .name = "sctp_sf_do_5_1D_ce"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_1D_ce), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_do_5_2_4_dupcook, .name = "sctp_sf_do_5_2_4_dupcook"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_2_4_dupcook), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_do_5_2_4_dupcook, .name = "sctp_sf_do_5_2_4_dupcook"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_2_4_dupcook), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_do_5_2_4_dupcook, .name = "sctp_sf_do_5_2_4_dupcook"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_2_4_dupcook), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_do_5_2_4_dupcook, .name = "sctp_sf_do_5_2_4_dupcook"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_2_4_dupcook), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_do_5_2_4_dupcook, .name = "sctp_sf_do_5_2_4_dupcook"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_2_4_dupcook), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_do_5_2_4_dupcook, .name = "sctp_sf_do_5_2_4_dupcook"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_2_4_dupcook), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_do_5_2_4_dupcook, .name = "sctp_sf_do_5_2_4_dupcook"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_2_4_dupcook), \
 } /* TYPE_SCTP_COOKIE_ECHO */
 
 #define TYPE_SCTP_COOKIE_ACK { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_do_5_1E_ca, .name = "sctp_sf_do_5_1E_ca"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_1E_ca), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 } /* TYPE_SCTP_COOKIE_ACK */
 
 #define TYPE_SCTP_ECN_ECNE { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_do_ecne, .name = "sctp_sf_do_ecne"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_ecne), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_do_ecne, .name = "sctp_sf_do_ecne"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_ecne), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_do_ecne, .name = "sctp_sf_do_ecne"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_ecne), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_do_ecne, .name = "sctp_sf_do_ecne"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_ecne), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_do_ecne, .name = "sctp_sf_do_ecne"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_ecne), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 } /* TYPE_SCTP_ECN_ECNE */
 
 #define TYPE_SCTP_ECN_CWR { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_do_ecn_cwr, .name = "sctp_sf_do_ecn_cwr"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_ecn_cwr), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_do_ecn_cwr, .name = "sctp_sf_do_ecn_cwr"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_ecn_cwr), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_do_ecn_cwr, .name = "sctp_sf_do_ecn_cwr"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_ecn_cwr), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 } /* TYPE_SCTP_ECN_CWR */
 
 #define TYPE_SCTP_SHUTDOWN_COMPLETE { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_do_4_C, .name = "sctp_sf_do_4_C"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_4_C), \
 } /* TYPE_SCTP_SHUTDOWN_COMPLETE */
 
 /* The primary index for this table is the chunk type.
@@ -450,44 +447,44 @@ static const sctp_sm_table_entry_t chunk
 
 #define TYPE_SCTP_ASCONF { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_do_asconf, .name = "sctp_sf_do_asconf"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_asconf), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 } /* TYPE_SCTP_ASCONF */
 
 #define TYPE_SCTP_ASCONF_ACK { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_do_asconf_ack, .name = "sctp_sf_do_asconf_ack"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_asconf_ack), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 } /* TYPE_SCTP_ASCONF_ACK */
 
 /* The primary index for this table is the chunk type.
@@ -500,23 +497,23 @@ static const sctp_sm_table_entry_t addip
 
 #define TYPE_SCTP_FWD_TSN { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_tabort_8_4_8, .name = "sctp_sf_tabort_8_4_8"}, \
+	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_eat_fwd_tsn, .name = "sctp_sf_eat_fwd_tsn"}, \
+	TYPE_SCTP_FUNC(sctp_sf_eat_fwd_tsn), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_eat_fwd_tsn, .name = "sctp_sf_eat_fwd_tsn"}, \
+	TYPE_SCTP_FUNC(sctp_sf_eat_fwd_tsn), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_eat_fwd_tsn_fast, .name = "sctp_sf_eat_fwd_tsn_fast"}, \
+	TYPE_SCTP_FUNC(sctp_sf_eat_fwd_tsn_fast), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_discard_chunk, .name = "sctp_sf_discard_chunk"}, \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 } /* TYPE_SCTP_FWD_TSN */
 
 /* The primary index for this table is the chunk type.
@@ -529,167 +526,150 @@ static const sctp_sm_table_entry_t prsct
 static const sctp_sm_table_entry_t
 chunk_event_table_unknown[SCTP_STATE_NUM_STATES] = {
 	/* SCTP_STATE_EMPTY */
-	{.fn = sctp_sf_ootb, .name = "sctp_sf_ootb"},
+	TYPE_SCTP_FUNC(sctp_sf_ootb),
 	/* SCTP_STATE_CLOSED */
-	{.fn = sctp_sf_tabort_8_4_8, .name = "sctp_sf_tabort_8_4_8"},
+	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8),
 	/* SCTP_STATE_COOKIE_WAIT */
-	{.fn = sctp_sf_unk_chunk, .name = "sctp_sf_unk_chunk"},
+	TYPE_SCTP_FUNC(sctp_sf_unk_chunk),
 	/* SCTP_STATE_COOKIE_ECHOED */
-	{.fn = sctp_sf_unk_chunk, .name = "sctp_sf_unk_chunk"},
+	TYPE_SCTP_FUNC(sctp_sf_unk_chunk),
 	/* SCTP_STATE_ESTABLISHED */
-	{.fn = sctp_sf_unk_chunk, .name = "sctp_sf_unk_chunk"},
+	TYPE_SCTP_FUNC(sctp_sf_unk_chunk),
 	/* SCTP_STATE_SHUTDOWN_PENDING */
-	{.fn = sctp_sf_unk_chunk, .name = "sctp_sf_unk_chunk"},
+	TYPE_SCTP_FUNC(sctp_sf_unk_chunk),
 	/* SCTP_STATE_SHUTDOWN_SENT */
-	{.fn = sctp_sf_unk_chunk, .name = "sctp_sf_unk_chunk"},
+	TYPE_SCTP_FUNC(sctp_sf_unk_chunk),
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */
-	{.fn = sctp_sf_unk_chunk, .name = "sctp_sf_unk_chunk"},
+	TYPE_SCTP_FUNC(sctp_sf_unk_chunk),
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */
-	{.fn = sctp_sf_unk_chunk, .name = "sctp_sf_unk_chunk"},
+	TYPE_SCTP_FUNC(sctp_sf_unk_chunk),
 };	/* chunk unknown */
 
 
 #define TYPE_SCTP_PRIMITIVE_ASSOCIATE  { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_do_prm_asoc, .name = "sctp_sf_do_prm_asoc"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_asoc), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_not_impl, .name = "sctp_sf_not_impl"}, \
+	TYPE_SCTP_FUNC(sctp_sf_not_impl), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_not_impl, .name = "sctp_sf_not_impl"}, \
+	TYPE_SCTP_FUNC(sctp_sf_not_impl), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_not_impl, .name = "sctp_sf_not_impl"}, \
+	TYPE_SCTP_FUNC(sctp_sf_not_impl), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_not_impl, .name = "sctp_sf_not_impl"}, \
+	TYPE_SCTP_FUNC(sctp_sf_not_impl), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_not_impl, .name = "sctp_sf_not_impl"}, \
+	TYPE_SCTP_FUNC(sctp_sf_not_impl), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_not_impl, .name = "sctp_sf_not_impl"}, \
+	TYPE_SCTP_FUNC(sctp_sf_not_impl), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_not_impl, .name = "sctp_sf_not_impl"}, \
+	TYPE_SCTP_FUNC(sctp_sf_not_impl), \
 } /* TYPE_SCTP_PRIMITIVE_ASSOCIATE */
 
 #define TYPE_SCTP_PRIMITIVE_SHUTDOWN  { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_error_closed, .name = "sctp_sf_error_closed"}, \
+	TYPE_SCTP_FUNC(sctp_sf_error_closed), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_cookie_wait_prm_shutdown, \
-	 .name = "sctp_sf_cookie_wait_prm_shutdown"}, \
+	TYPE_SCTP_FUNC(sctp_sf_cookie_wait_prm_shutdown), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_cookie_echoed_prm_shutdown, \
-	 .name = "sctp_sf_cookie_echoed_prm_shutdown"},\
+	TYPE_SCTP_FUNC(sctp_sf_cookie_echoed_prm_shutdown),\
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_do_9_2_prm_shutdown, \
-	 .name = "sctp_sf_do_9_2_prm_shutdown"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_9_2_prm_shutdown), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_ignore_primitive, .name = "sctp_sf_ignore_primitive"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ignore_primitive), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_ignore_primitive, .name = "sctp_sf_ignore_primitive"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ignore_primitive), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_ignore_primitive, .name = "sctp_sf_ignore_primitive"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ignore_primitive), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_ignore_primitive, .name = "sctp_sf_ignore_primitive"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ignore_primitive), \
 } /* TYPE_SCTP_PRIMITIVE_SHUTDOWN */
 
 #define TYPE_SCTP_PRIMITIVE_ABORT  { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_error_closed, .name = "sctp_sf_error_closed"}, \
+	TYPE_SCTP_FUNC(sctp_sf_error_closed), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_cookie_wait_prm_abort, \
-	.name = "sctp_sf_cookie_wait_prm_abort"}, \
+	TYPE_SCTP_FUNC(sctp_sf_cookie_wait_prm_abort), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_cookie_echoed_prm_abort, \
-	.name = "sctp_sf_cookie_echoed_prm_abort"}, \
+	TYPE_SCTP_FUNC(sctp_sf_cookie_echoed_prm_abort), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_do_9_1_prm_abort, \
-	.name = "sctp_sf_do_9_1_prm_abort"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_9_1_prm_abort), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_shutdown_pending_prm_abort, \
-	.name = "sctp_sf_shutdown_pending_prm_abort"}, \
+	TYPE_SCTP_FUNC(sctp_sf_shutdown_pending_prm_abort), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_shutdown_sent_prm_abort, \
-	.name = "sctp_sf_shutdown_sent_prm_abort"}, \
+	TYPE_SCTP_FUNC(sctp_sf_shutdown_sent_prm_abort), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_do_9_1_prm_abort, \
-	.name = "sctp_sf_do_9_1_prm_abort"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_9_1_prm_abort), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_shutdown_ack_sent_prm_abort, \
-	.name = "sctp_sf_shutdown_ack_sent_prm_abort"}, \
+	TYPE_SCTP_FUNC(sctp_sf_shutdown_ack_sent_prm_abort), \
 } /* TYPE_SCTP_PRIMITIVE_ABORT */
 
 #define TYPE_SCTP_PRIMITIVE_SEND  { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_error_closed, .name = "sctp_sf_error_closed"}, \
+	TYPE_SCTP_FUNC(sctp_sf_error_closed), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_do_prm_send, .name = "sctp_sf_do_prm_send"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_send), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_do_prm_send, .name = "sctp_sf_do_prm_send"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_send), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_do_prm_send, .name = "sctp_sf_do_prm_send"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_send), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_error_shutdown, .name = "sctp_sf_error_shutdown"}, \
+	TYPE_SCTP_FUNC(sctp_sf_error_shutdown), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_error_shutdown, .name = "sctp_sf_error_shutdown"}, \
+	TYPE_SCTP_FUNC(sctp_sf_error_shutdown), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_error_shutdown, .name = "sctp_sf_error_shutdown"}, \
+	TYPE_SCTP_FUNC(sctp_sf_error_shutdown), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_error_shutdown, .name = "sctp_sf_error_shutdown"}, \
+	TYPE_SCTP_FUNC(sctp_sf_error_shutdown), \
 } /* TYPE_SCTP_PRIMITIVE_SEND */
 
 #define TYPE_SCTP_PRIMITIVE_REQUESTHEARTBEAT  { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_error_closed, .name = "sctp_sf_error_closed"}, \
+	TYPE_SCTP_FUNC(sctp_sf_error_closed), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_do_prm_requestheartbeat,		      \
-	 .name = "sctp_sf_do_prm_requestheartbeat"},          \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_requestheartbeat),          \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_do_prm_requestheartbeat,		      \
-	 .name = "sctp_sf_do_prm_requestheartbeat"},          \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_requestheartbeat),          \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_do_prm_requestheartbeat,		      \
-	 .name = "sctp_sf_do_prm_requestheartbeat"},          \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_requestheartbeat),          \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_do_prm_requestheartbeat,		      \
-	 .name = "sctp_sf_do_prm_requestheartbeat"},          \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_requestheartbeat),          \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_do_prm_requestheartbeat,		      \
-	 .name = "sctp_sf_do_prm_requestheartbeat"},          \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_requestheartbeat),          \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_do_prm_requestheartbeat,		      \
-	 .name = "sctp_sf_do_prm_requestheartbeat"},          \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_requestheartbeat),          \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_do_prm_requestheartbeat,		      \
-	 .name = "sctp_sf_do_prm_requestheartbeat"},          \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_requestheartbeat),          \
 } /* TYPE_SCTP_PRIMITIVE_REQUESTHEARTBEAT */
 
 #define TYPE_SCTP_PRIMITIVE_ASCONF { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_error_closed, .name = "sctp_sf_error_closed"}, \
+	TYPE_SCTP_FUNC(sctp_sf_error_closed), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_error_closed, .name = "sctp_sf_error_closed"}, \
+	TYPE_SCTP_FUNC(sctp_sf_error_closed), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_error_closed, .name = "sctp_sf_error_closed"}, \
+	TYPE_SCTP_FUNC(sctp_sf_error_closed), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_do_prm_asconf, .name = "sctp_sf_do_prm_asconf"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_asconf), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_error_shutdown, .name = "sctp_sf_error_shutdown"}, \
+	TYPE_SCTP_FUNC(sctp_sf_error_shutdown), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_error_shutdown, .name = "sctp_sf_error_shutdown"}, \
+	TYPE_SCTP_FUNC(sctp_sf_error_shutdown), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_error_shutdown, .name = "sctp_sf_error_shutdown"}, \
+	TYPE_SCTP_FUNC(sctp_sf_error_shutdown), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_error_shutdown, .name = "sctp_sf_error_shutdown"}, \
+	TYPE_SCTP_FUNC(sctp_sf_error_shutdown), \
 } /* TYPE_SCTP_PRIMITIVE_REQUESTHEARTBEAT */
 
 /* The primary index for this table is the primitive type.
@@ -706,47 +686,44 @@ static const sctp_sm_table_entry_t primi
 
 #define TYPE_SCTP_OTHER_NO_PENDING_TSN  { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_ignore_other, .name = "sctp_sf_ignore_other"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_ignore_other, .name = "sctp_sf_ignore_other"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_ignore_other, .name = "sctp_sf_ignore_other"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_ignore_other, .name = "sctp_sf_ignore_other"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_do_9_2_start_shutdown, \
-	 .name = "sctp_do_9_2_start_shutdown"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_9_2_start_shutdown), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_ignore_other, .name = "sctp_sf_ignore_other"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_do_9_2_shutdown_ack, \
-	 .name = "sctp_sf_do_9_2_shutdown_ack"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_9_2_shutdown_ack), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_ignore_other, .name = "sctp_sf_ignore_other"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
 }
 
 #define TYPE_SCTP_OTHER_ICMP_PROTO_UNREACH  { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_ignore_other, .name = "sctp_sf_ignore_other"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_cookie_wait_icmp_abort, \
-	 .name = "sctp_sf_cookie_wait_icmp_abort"}, \
+	TYPE_SCTP_FUNC(sctp_sf_cookie_wait_icmp_abort), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_ignore_other, .name = "sctp_sf_ignore_other"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_ignore_other, .name = "sctp_sf_ignore_other"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_ignore_other, .name = "sctp_sf_ignore_other"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_ignore_other, .name = "sctp_sf_ignore_other"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_ignore_other, .name = "sctp_sf_ignore_other"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_ignore_other, .name = "sctp_sf_ignore_other"}, \
+	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
 }
 
 static const sctp_sm_table_entry_t other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_STATE_NUM_STATES] = {
@@ -756,215 +733,212 @@ static const sctp_sm_table_entry_t other
 
 #define TYPE_SCTP_EVENT_TIMEOUT_NONE { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_T1_COOKIE { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_t1_cookie_timer_expire, \
-	 .name = "sctp_sf_t1_cookie_timer_expire"}, \
+	TYPE_SCTP_FUNC(sctp_sf_t1_cookie_timer_expire), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_T1_INIT { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_t1_init_timer_expire, \
-	 .name = "sctp_sf_t1_init_timer_expire"}, \
+	TYPE_SCTP_FUNC(sctp_sf_t1_init_timer_expire), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_T2_SHUTDOWN { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_t2_timer_expire, .name = "sctp_sf_t2_timer_expire"}, \
+	TYPE_SCTP_FUNC(sctp_sf_t2_timer_expire), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_t2_timer_expire, .name = "sctp_sf_t2_timer_expire"}, \
+	TYPE_SCTP_FUNC(sctp_sf_t2_timer_expire), \
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_T3_RTX { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_do_6_3_3_rtx, .name = "sctp_sf_do_6_3_3_rtx"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_6_3_3_rtx), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_do_6_3_3_rtx, .name = "sctp_sf_do_6_3_3_rtx"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_6_3_3_rtx), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_do_6_3_3_rtx, .name = "sctp_sf_do_6_3_3_rtx"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_6_3_3_rtx), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_do_6_3_3_rtx, .name = "sctp_sf_do_6_3_3_rtx"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_6_3_3_rtx), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_T4_RTO { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_t4_timer_expire, .name = "sctp_sf_t4_timer_expire"}, \
+	TYPE_SCTP_FUNC(sctp_sf_t4_timer_expire), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_T5_SHUTDOWN_GUARD { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_t5_timer_expire, .name = "sctp_sf_t5_timer_expire"}, \
+	TYPE_SCTP_FUNC(sctp_sf_t5_timer_expire), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_t5_timer_expire, .name = "sctp_sf_t5_timer_expire"}, \
+	TYPE_SCTP_FUNC(sctp_sf_t5_timer_expire), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_HEARTBEAT { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_sendbeat_8_3, .name = "sctp_sf_sendbeat_8_3"}, \
+	TYPE_SCTP_FUNC(sctp_sf_sendbeat_8_3), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_sendbeat_8_3, .name = "sctp_sf_sendbeat_8_3"}, \
+	TYPE_SCTP_FUNC(sctp_sf_sendbeat_8_3), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_sendbeat_8_3, .name = "sctp_sf_sendbeat_8_3"}, \
+	TYPE_SCTP_FUNC(sctp_sf_sendbeat_8_3), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_SACK { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_bug, .name = "sctp_sf_bug"}, \
+	TYPE_SCTP_FUNC(sctp_sf_bug), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_do_6_2_sack, .name = "sctp_sf_do_6_2_sack"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_6_2_sack), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_do_6_2_sack, .name = "sctp_sf_do_6_2_sack"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_6_2_sack), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_do_6_2_sack, .name = "sctp_sf_do_6_2_sack"}, \
+	TYPE_SCTP_FUNC(sctp_sf_do_6_2_sack), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 }
 
 #define TYPE_SCTP_EVENT_TIMEOUT_AUTOCLOSE { \
 	/* SCTP_STATE_EMPTY */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_CLOSED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	{.fn = sctp_sf_autoclose_timer_expire, \
-	 .name = "sctp_sf_autoclose_timer_expire"}, \
+	TYPE_SCTP_FUNC(sctp_sf_autoclose_timer_expire), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
-	{.fn = sctp_sf_timer_ignore, .name = "sctp_sf_timer_ignore"}, \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 }
 
 static const sctp_sm_table_entry_t timeout_event_table[SCTP_NUM_TIMEOUT_TYPES][SCTP_STATE_NUM_STATES] = {


