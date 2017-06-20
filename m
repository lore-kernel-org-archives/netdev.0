From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next] sctp: handle errors when updating asoc
Date: Tue, 20 Jun 2017 16:05:11 +0800
Message-ID: <a6aa86ed657155e13c72c246b79cf297159a8765.1497945911.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:32931 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751021AbdFTIFV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 04:05:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's a bad thing not to handle errors when updating asoc. The memory
allocation failure in any of the functions called in sctp_assoc_update()
would cause sctp to work unexpectedly.

This patch is to fix it by aborting the asoc and reporting the error when
any of these functions fails.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h |  4 ++--
 net/sctp/associola.c       | 25 ++++++++++++++-----------
 net/sctp/sm_sideeffect.c   | 24 +++++++++++++++++++++++-
 3 files changed, 39 insertions(+), 14 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 5051317..e26763b 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1953,8 +1953,8 @@ struct sctp_transport *sctp_assoc_is_match(struct sctp_association *,
 					   const union sctp_addr *,
 					   const union sctp_addr *);
 void sctp_assoc_migrate(struct sctp_association *, struct sock *);
-void sctp_assoc_update(struct sctp_association *old,
-		       struct sctp_association *new);
+int sctp_assoc_update(struct sctp_association *old,
+		      struct sctp_association *new);
 
 __u32 sctp_association_get_next_tsn(struct sctp_association *);
 
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 72b07dd..757be41 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1112,8 +1112,8 @@ void sctp_assoc_migrate(struct sctp_association *assoc, struct sock *newsk)
 }
 
 /* Update an association (possibly from unexpected COOKIE-ECHO processing).  */
-void sctp_assoc_update(struct sctp_association *asoc,
-		       struct sctp_association *new)
+int sctp_assoc_update(struct sctp_association *asoc,
+		      struct sctp_association *new)
 {
 	struct sctp_transport *trans;
 	struct list_head *pos, *temp;
@@ -1124,8 +1124,10 @@ void sctp_assoc_update(struct sctp_association *asoc,
 	asoc->peer.sack_needed = new->peer.sack_needed;
 	asoc->peer.auth_capable = new->peer.auth_capable;
 	asoc->peer.i = new->peer.i;
-	sctp_tsnmap_init(&asoc->peer.tsn_map, SCTP_TSN_MAP_INITIAL,
-			 asoc->peer.i.initial_tsn, GFP_ATOMIC);
+
+	if (!sctp_tsnmap_init(&asoc->peer.tsn_map, SCTP_TSN_MAP_INITIAL,
+			      asoc->peer.i.initial_tsn, GFP_ATOMIC))
+		return -ENOMEM;
 
 	/* Remove any peer addresses not present in the new association. */
 	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
@@ -1169,11 +1171,11 @@ void sctp_assoc_update(struct sctp_association *asoc,
 	} else {
 		/* Add any peer addresses from the new association. */
 		list_for_each_entry(trans, &new->peer.transport_addr_list,
-				transports) {
-			if (!sctp_assoc_lookup_paddr(asoc, &trans->ipaddr))
-				sctp_assoc_add_peer(asoc, &trans->ipaddr,
-						    GFP_ATOMIC, trans->state);
-		}
+				    transports)
+			if (!sctp_assoc_lookup_paddr(asoc, &trans->ipaddr) &&
+			    !sctp_assoc_add_peer(asoc, &trans->ipaddr,
+						 GFP_ATOMIC, trans->state))
+				return -ENOMEM;
 
 		asoc->ctsn_ack_point = asoc->next_tsn - 1;
 		asoc->adv_peer_ack_point = asoc->ctsn_ack_point;
@@ -1182,7 +1184,8 @@ void sctp_assoc_update(struct sctp_association *asoc,
 			sctp_stream_update(&asoc->stream, &new->stream);
 
 		/* get a new assoc id if we don't have one yet. */
-		sctp_assoc_set_id(asoc, GFP_ATOMIC);
+		if (sctp_assoc_set_id(asoc, GFP_ATOMIC))
+			return -ENOMEM;
 	}
 
 	/* SCTP-AUTH: Save the peer parameters from the new associations
@@ -1200,7 +1203,7 @@ void sctp_assoc_update(struct sctp_association *asoc,
 	asoc->peer.peer_hmacs = new->peer.peer_hmacs;
 	new->peer.peer_hmacs = NULL;
 
-	sctp_auth_asoc_init_active_key(asoc, GFP_ATOMIC);
+	return sctp_auth_asoc_init_active_key(asoc, GFP_ATOMIC);
 }
 
 /* Update the retran path for sending a retransmitted packet.
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 7623566..dfe1fcb 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -818,6 +818,28 @@ static void sctp_cmd_setup_t2(sctp_cmd_seq_t *cmds,
 	asoc->timeouts[SCTP_EVENT_TIMEOUT_T2_SHUTDOWN] = t->rto;
 }
 
+static void sctp_cmd_assoc_update(sctp_cmd_seq_t *cmds,
+				  struct sctp_association *asoc,
+				  struct sctp_association *new)
+{
+	struct net *net = sock_net(asoc->base.sk);
+	struct sctp_chunk *abort;
+
+	if (!sctp_assoc_update(asoc, new))
+		return;
+
+	abort = sctp_make_abort(asoc, NULL, sizeof(sctp_errhdr_t));
+	if (abort) {
+		sctp_init_cause(abort, SCTP_ERROR_RSRC_LOW, 0);
+		sctp_add_cmd_sf(cmds, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
+	}
+	sctp_add_cmd_sf(cmds, SCTP_CMD_SET_SK_ERR, SCTP_ERROR(ECONNABORTED));
+	sctp_add_cmd_sf(cmds, SCTP_CMD_ASSOC_FAILED,
+			SCTP_PERR(SCTP_ERROR_RSRC_LOW));
+	SCTP_INC_STATS(net, SCTP_MIB_ABORTEDS);
+	SCTP_DEC_STATS(net, SCTP_MIB_CURRESTAB);
+}
+
 /* Helper function to change the state of an association. */
 static void sctp_cmd_new_state(sctp_cmd_seq_t *cmds,
 			       struct sctp_association *asoc,
@@ -1294,7 +1316,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 			break;
 
 		case SCTP_CMD_UPDATE_ASSOC:
-		       sctp_assoc_update(asoc, cmd->obj.asoc);
+		       sctp_cmd_assoc_update(commands, asoc, cmd->obj.asoc);
 		       break;
 
 		case SCTP_CMD_PURGE_OUTQUEUE:
-- 
2.1.0
