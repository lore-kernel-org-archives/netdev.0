From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 2/5][SCTP]: Cleanup nomem handling in the state functions.
Date: Fri, 18 Aug 2006 11:22:33 -0700
Message-ID: <1155925353.20802.26.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:33978 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S964914AbWHRS2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 14:28:41 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7IISeEA008193
	for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 14:28:40 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7IISeXf295242
	for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 14:28:40 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7IISeqN009712
	for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 14:28:40 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Cleanup nomem handling in the state functions.

This patch cleans up the "nomem" conditions that may occur during the
processing by the state machine functions. In most cases we delay adding
side-effect commands until all memory allocations are done.

Signed-off-by: Vladislav Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---

 net/sctp/sm_statefuns.c |  159 +++++++++++++++++++++++++----------------------
 1 files changed, 86 insertions(+), 73 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index f956c92..0f2dfa2 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -187,10 +187,9 @@ sctp_disposition_t sctp_sf_do_4_C(const 
 	 */
 	ev = sctp_ulpevent_make_assoc_change(asoc, 0, SCTP_SHUTDOWN_COMP,
 					     0, 0, 0, GFP_ATOMIC);
-	if (!ev)
-		goto nomem;
-
-	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(ev));
+	if (ev)
+		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
+			        SCTP_ULPEVENT(ev));
 
 	/* Upon reception of the SHUTDOWN COMPLETE chunk the endpoint
 	 * will verify that it is in SHUTDOWN-ACK-SENT state, if it is
@@ -215,9 +214,6 @@ sctp_disposition_t sctp_sf_do_4_C(const 
 	sctp_add_cmd_sf(commands, SCTP_CMD_DELETE_TCB, SCTP_NULL());
 
 	return SCTP_DISPOSITION_DELETE_TCB;
-
-nomem:
-	return SCTP_DISPOSITION_NOMEM;
 }
 
 /*
@@ -347,8 +343,6 @@ sctp_disposition_t sctp_sf_do_5_1B_init(
 			       GFP_ATOMIC))
 		goto nomem_init;
 
-	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_ASOC, SCTP_ASOC(new_asoc));
-
 	/* B) "Z" shall respond immediately with an INIT ACK chunk.  */
 
 	/* If there are errors need to be reported for unknown parameters,
@@ -360,11 +354,11 @@ sctp_disposition_t sctp_sf_do_5_1B_init(
 			sizeof(sctp_chunkhdr_t);
 
 	if (sctp_assoc_set_bind_addr_from_ep(new_asoc, GFP_ATOMIC) < 0)
-		goto nomem_ack;
+		goto nomem_init;
 
 	repl = sctp_make_init_ack(new_asoc, chunk, GFP_ATOMIC, len);
 	if (!repl)
-		goto nomem_ack;
+		goto nomem_init;
 
 	/* If there are errors need to be reported for unknown parameters,
 	 * include them in the outgoing INIT ACK as "Unrecognized parameter"
@@ -388,6 +382,8 @@ sctp_disposition_t sctp_sf_do_5_1B_init(
 		sctp_chunk_free(err_chunk);
 	}
 
+	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_ASOC, SCTP_ASOC(new_asoc));
+
 	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(repl));
 
 	/*
@@ -400,12 +396,11 @@ sctp_disposition_t sctp_sf_do_5_1B_init(
 
 	return SCTP_DISPOSITION_DELETE_TCB;
 
-nomem_ack:
-	if (err_chunk)
-		sctp_chunk_free(err_chunk);
 nomem_init:
 	sctp_association_free(new_asoc);
 nomem:
+	if (err_chunk)
+		sctp_chunk_free(err_chunk);
 	return SCTP_DISPOSITION_NOMEM;
 }
 
@@ -600,7 +595,7 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(co
 	struct sctp_association *new_asoc;
 	sctp_init_chunk_t *peer_init;
 	struct sctp_chunk *repl;
-	struct sctp_ulpevent *ev;
+	struct sctp_ulpevent *ev, *ai_ev = NULL;
 	int error = 0;
 	struct sctp_chunk *err_chk_p;
 
@@ -659,20 +654,10 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(co
 		};
 	}
 
-	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_ASOC, SCTP_ASOC(new_asoc));
-	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_STATE,
-			SCTP_STATE(SCTP_STATE_ESTABLISHED));
-	SCTP_INC_STATS(SCTP_MIB_CURRESTAB);
-	SCTP_INC_STATS(SCTP_MIB_PASSIVEESTABS);
-	sctp_add_cmd_sf(commands, SCTP_CMD_HB_TIMERS_START, SCTP_NULL());
-
-	if (new_asoc->autoclose)
-		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_START,
-				SCTP_TO(SCTP_EVENT_TIMEOUT_AUTOCLOSE));
 
-	sctp_add_cmd_sf(commands, SCTP_CMD_TRANSMIT, SCTP_NULL());
-
-	/* Re-build the bind address for the association is done in
+	/* Delay state machine commands until later.
+	 *
+	 * Re-build the bind address for the association is done in
 	 * the sctp_unpack_cookie() already.
 	 */
 	/* This is a brand-new association, so these are not yet side
@@ -687,9 +672,7 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(co
 
 	repl = sctp_make_cookie_ack(new_asoc, chunk);
 	if (!repl)
-		goto nomem_repl;
-
-	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(repl));
+		goto nomem_init;
 
 	/* RFC 2960 5.1 Normal Establishment of an Association
 	 *
@@ -704,28 +687,53 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(co
 	if (!ev)
 		goto nomem_ev;
 
-	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(ev));
-
 	/* Sockets API Draft Section 5.3.1.6 	
 	 * When a peer sends a Adaption Layer Indication parameter , SCTP
 	 * delivers this notification to inform the application that of the
 	 * peers requested adaption layer.
 	 */
 	if (new_asoc->peer.adaption_ind) {
-		ev = sctp_ulpevent_make_adaption_indication(new_asoc,
+		ai_ev = sctp_ulpevent_make_adaption_indication(new_asoc,
 							    GFP_ATOMIC);
-		if (!ev)
-			goto nomem_ev;
+		if (!ai_ev)
+			goto nomem_aiev;
+	}
 
+	/* Add all the state machine commands now since we've created
+	 * everything.  This way we don't introduce memory corruptions
+	 * during side-effect processing and correclty count established
+	 * associations.
+	 */
+	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_ASOC, SCTP_ASOC(new_asoc));
+	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_STATE,
+			SCTP_STATE(SCTP_STATE_ESTABLISHED));
+	SCTP_INC_STATS(SCTP_MIB_CURRESTAB);
+	SCTP_INC_STATS(SCTP_MIB_PASSIVEESTABS);
+	sctp_add_cmd_sf(commands, SCTP_CMD_HB_TIMERS_START, SCTP_NULL());
+
+	if (new_asoc->autoclose)
+		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_START,
+				SCTP_TO(SCTP_EVENT_TIMEOUT_AUTOCLOSE));
+
+	sctp_add_cmd_sf(commands, SCTP_CMD_TRANSMIT, SCTP_NULL());
+
+	/* This will send the COOKIE ACK */
+	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(repl));
+
+	/* Queue the ASSOC_CHANGE event */
+	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(ev));
+
+	/* Send up the Adaptation Layer Indication event */
+	if (ai_ev)
 		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
-				SCTP_ULPEVENT(ev));
-	}
+				SCTP_ULPEVENT(ai_ev));
 
 	return SCTP_DISPOSITION_CONSUME;
 
+nomem_aiev:
+	sctp_ulpevent_free(ev);
 nomem_ev:
 	sctp_chunk_free(repl);
-nomem_repl:
 nomem_init:
 	sctp_association_free(new_asoc);
 nomem:
@@ -1360,10 +1368,8 @@ static sctp_disposition_t sctp_sf_do_une
 	if (!sctp_process_init(new_asoc, chunk->chunk_hdr->type,
 			       sctp_source(chunk),
 			       (sctp_init_chunk_t *)chunk->chunk_hdr,
-			       GFP_ATOMIC)) {
-		retval = SCTP_DISPOSITION_NOMEM;
-		goto nomem_init;
-	}
+			       GFP_ATOMIC))
+		goto nomem;
 
 	/* Make sure no new addresses are being added during the
 	 * restart.   Do not do this check for COOKIE-WAIT state,
@@ -1374,7 +1380,7 @@ static sctp_disposition_t sctp_sf_do_une
 		if (!sctp_sf_check_restart_addrs(new_asoc, asoc, chunk,
 						 commands)) {
 			retval = SCTP_DISPOSITION_CONSUME;
-			goto cleanup_asoc;
+			goto nomem_retval;
 		}
 	}
 
@@ -1430,17 +1436,17 @@ static sctp_disposition_t sctp_sf_do_une
 	sctp_add_cmd_sf(commands, SCTP_CMD_DELETE_TCB, SCTP_NULL());
 	retval = SCTP_DISPOSITION_CONSUME;
 
+	return retval;
+
+nomem:
+	retval = SCTP_DISPOSITION_NOMEM;
+nomem_retval:
+	if (new_asoc)
+		sctp_association_free(new_asoc);
 cleanup:
 	if (err_chunk)
 		sctp_chunk_free(err_chunk);
 	return retval;
-nomem:
-	retval = SCTP_DISPOSITION_NOMEM;
-	goto cleanup;
-nomem_init:
-cleanup_asoc:
-	sctp_association_free(new_asoc);
-	goto cleanup;
 }
 
 /*
@@ -1611,15 +1617,10 @@ static sctp_disposition_t sctp_sf_do_dup
 	 */
 	sctp_add_cmd_sf(commands, SCTP_CMD_PURGE_OUTQUEUE, SCTP_NULL());
 
-	/* Update the content of current association. */
-	sctp_add_cmd_sf(commands, SCTP_CMD_UPDATE_ASSOC, SCTP_ASOC(new_asoc));
-
 	repl = sctp_make_cookie_ack(new_asoc, chunk);
 	if (!repl)
 		goto nomem;
 
-	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(repl));
-
 	/* Report association restart to upper layer. */
 	ev = sctp_ulpevent_make_assoc_change(asoc, 0, SCTP_RESTART, 0,
 					     new_asoc->c.sinit_num_ostreams,
@@ -1628,6 +1629,9 @@ static sctp_disposition_t sctp_sf_do_dup
 	if (!ev)
 		goto nomem_ev;
 
+	/* Update the content of current association. */
+	sctp_add_cmd_sf(commands, SCTP_CMD_UPDATE_ASSOC, SCTP_ASOC(new_asoc));
+	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(repl));
 	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(ev));
 	return SCTP_DISPOSITION_CONSUME;
 
@@ -1751,7 +1755,7 @@ static sctp_disposition_t sctp_sf_do_dup
 					sctp_cmd_seq_t *commands,
 					struct sctp_association *new_asoc)
 {
-	struct sctp_ulpevent *ev = NULL;
+	struct sctp_ulpevent *ev = NULL, *ai_ev = NULL;
 	struct sctp_chunk *repl;
 
 	/* Clarification from Implementor's Guide:
@@ -1778,29 +1782,25 @@ static sctp_disposition_t sctp_sf_do_dup
 		 * SCTP user upon reception of a valid COOKIE
 		 * ECHO chunk.
 		 */
-		ev = sctp_ulpevent_make_assoc_change(new_asoc, 0,
+		ev = sctp_ulpevent_make_assoc_change(asoc, 0,
 					     SCTP_COMM_UP, 0,
-					     new_asoc->c.sinit_num_ostreams,
-					     new_asoc->c.sinit_max_instreams,
+					     asoc->c.sinit_num_ostreams,
+					     asoc->c.sinit_max_instreams,
                                              GFP_ATOMIC);
 		if (!ev)
 			goto nomem;
-		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
-				SCTP_ULPEVENT(ev));
 
 		/* Sockets API Draft Section 5.3.1.6
 		 * When a peer sends a Adaption Layer Indication parameter,
 		 * SCTP delivers this notification to inform the application
 		 * that of the peers requested adaption layer.
 		 */
-		if (new_asoc->peer.adaption_ind) {
-			ev = sctp_ulpevent_make_adaption_indication(new_asoc,
+		if (asoc->peer.adaption_ind) {
+			ai_ev = sctp_ulpevent_make_adaption_indication(asoc,
 								 GFP_ATOMIC);
-			if (!ev)
+			if (!ai_ev)
 				goto nomem;
 
-			sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
-					SCTP_ULPEVENT(ev));
 		}
 	}
 	sctp_add_cmd_sf(commands, SCTP_CMD_TRANSMIT, SCTP_NULL());
@@ -1809,12 +1809,21 @@ static sctp_disposition_t sctp_sf_do_dup
 	if (!repl)
 		goto nomem;
 
+	if (ev)
+		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
+				SCTP_ULPEVENT(ev));
+	if (ai_ev)
+		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
+					SCTP_ULPEVENT(ai_ev));
+
 	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(repl));
 	sctp_add_cmd_sf(commands, SCTP_CMD_TRANSMIT, SCTP_NULL());
 
 	return SCTP_DISPOSITION_CONSUME;
 
 nomem:
+	if (ai_ev)
+		sctp_ulpevent_free(ai_ev);
 	if (ev)
 		sctp_ulpevent_free(ev);
 	return SCTP_DISPOSITION_NOMEM;
@@ -3019,7 +3028,6 @@ sctp_disposition_t sctp_sf_do_9_2_final(
 	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
 		return sctp_sf_violation_chunklen(ep, asoc, type, arg,
 						  commands);
-
 	/* 10.2 H) SHUTDOWN COMPLETE notification
 	 *
 	 * When SCTP completes the shutdown procedures (section 9.2) this
@@ -3030,6 +3038,14 @@ sctp_disposition_t sctp_sf_do_9_2_final(
 	if (!ev)
 		goto nomem;
 
+	/* ...send a SHUTDOWN COMPLETE chunk to its peer, */
+	reply = sctp_make_shutdown_complete(asoc, chunk);
+	if (!reply)
+		goto nomem_chunk;
+
+	/* Do all the commands now (after allocation), so that we
+	 * have consistent state if memory allocation failes
+	 */
 	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(ev));
 
 	/* Upon the receipt of the SHUTDOWN ACK, the SHUTDOWN sender shall
@@ -3041,11 +3057,6 @@ sctp_disposition_t sctp_sf_do_9_2_final(
 	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
 			SCTP_TO(SCTP_EVENT_TIMEOUT_T5_SHUTDOWN_GUARD));
 
-	/* ...send a SHUTDOWN COMPLETE chunk to its peer, */
-	reply = sctp_make_shutdown_complete(asoc, chunk);
-	if (!reply)
-		goto nomem;
-
 	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_STATE,
 			SCTP_STATE(SCTP_STATE_CLOSED));
 	SCTP_INC_STATS(SCTP_MIB_SHUTDOWNS);
@@ -3056,6 +3067,8 @@ sctp_disposition_t sctp_sf_do_9_2_final(
 	sctp_add_cmd_sf(commands, SCTP_CMD_DELETE_TCB, SCTP_NULL());
 	return SCTP_DISPOSITION_DELETE_TCB;
 
+nomem_chunk:
+	sctp_ulpevent_free(ev);
 nomem:
 	return SCTP_DISPOSITION_NOMEM;
 }


