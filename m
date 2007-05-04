From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 3/4] [SCTP] Set assoc_id correctly during INIT collision.
Date: Fri,  4 May 2007 16:22:54 -0400
Message-ID: <11783101753220-git-send-email-vladislav.yasevich@hp.com>
References: <1178310175881-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:46874 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031535AbXEDUW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 16:22:59 -0400
In-Reply-To: <1178310175881-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

During the INIT/COOKIE-ACK collision cases, it's possible to get
into a situation where the association id is not yet set at the time
of the user event generation.  As a result, user events have an
association id set to 0 which will confuse applications.

This happens if we hit case B of duplicate cookie processing.
In the particular example found and provided by Oscar Isaula
<Oscar.Isaula@motorola.com>, flow looks like this:
A				B
---- INIT------->  (lost)
	    <---------INIT------
---- INIT-ACK--->
	    <------ Cookie ECHO
---
 include/net/sctp/command.h |    2 ++
 include/net/sctp/structs.h |    1 +
 net/sctp/associola.c       |   29 +++++++++++++++++++++++++++++
 net/sctp/sm_make_chunk.c   |   15 ++-------------
 net/sctp/sm_sideeffect.c   |   35 +++++++++++++++++++++++++++++++++++
 net/sctp/sm_statefuns.c    |   29 +++++++++++------------------
 6 files changed, 80 insertions(+), 31 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 6114c4f..f56c8d6 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -100,6 +100,8 @@ typedef enum {
 	SCTP_CMD_T3_RTX_TIMERS_STOP, /* Stops T3-rtx pending timers */
 	SCTP_CMD_FORCE_PRIM_RETRAN,  /* Forces retrans. over primary path. */
 	SCTP_CMD_SET_SK_ERR,	 /* Set sk_err */
+	SCTP_CMD_ASSOC_CHANGE,	 /* generate and send assoc_change event */
+	SCTP_CMD_ADAPTATION_IND, /* generate and send adaptation event */
 	SCTP_CMD_LAST
 } sctp_verb_t;
 
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 7b4fff9..5e81984 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1857,6 +1857,7 @@ int sctp_assoc_set_bind_addr_from_ep(struct sctp_association *,
 int sctp_assoc_set_bind_addr_from_cookie(struct sctp_association *,
 					 struct sctp_cookie*,
 					 gfp_t gfp);
+int sctp_assoc_set_id(struct sctp_association *, gfp_t);
 
 int sctp_cmp_addr_exact(const union sctp_addr *ss1,
 			const union sctp_addr *ss2);
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index db73ef9..df94e3c 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1103,6 +1103,13 @@ void sctp_assoc_update(struct sctp_association *asoc,
 			asoc->ssnmap = new->ssnmap;
 			new->ssnmap = NULL;
 		}
+
+		if (!asoc->assoc_id) {
+			/* get a new association id since we don't have one
+			 * yet.
+			 */
+			sctp_assoc_set_id(asoc, GFP_ATOMIC);
+		}
 	}
 }
 
@@ -1375,3 +1382,25 @@ out:
 	sctp_read_unlock(&asoc->base.addr_lock);
 	return found;
 }
+
+/* Set an association id for a given association */
+int sctp_assoc_set_id(struct sctp_association *asoc, gfp_t gfp)
+{
+	int assoc_id;
+	int error = 0;
+retry:
+	if (unlikely(!idr_pre_get(&sctp_assocs_id, gfp)))
+		return -ENOMEM;
+
+	spin_lock_bh(&sctp_assocs_id_lock);
+	error = idr_get_new_above(&sctp_assocs_id, (void *)asoc,
+				    1, &assoc_id);
+	spin_unlock_bh(&sctp_assocs_id_lock);
+	if (error == -EAGAIN)
+		goto retry;
+	else if (error)
+		return error;
+
+	asoc->assoc_id = (sctp_assoc_t) assoc_id;
+	return error;
+}
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index be783a3..8d18f57 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1939,7 +1939,6 @@ int sctp_process_init(struct sctp_association *asoc, sctp_cid_t cid,
 	 * association.
 	 */
 	if (!asoc->temp) {
-		int assoc_id;
 		int error;
 
 		asoc->ssnmap = sctp_ssnmap_new(asoc->c.sinit_max_instreams,
@@ -1947,19 +1946,9 @@ int sctp_process_init(struct sctp_association *asoc, sctp_cid_t cid,
 		if (!asoc->ssnmap)
 			goto clean_up;
 
-	retry:
-		if (unlikely(!idr_pre_get(&sctp_assocs_id, gfp)))
+		error = sctp_assoc_set_id(asoc, gfp);
+		if (error)
 			goto clean_up;
-		spin_lock_bh(&sctp_assocs_id_lock);
-		error = idr_get_new_above(&sctp_assocs_id, (void *)asoc, 1,
-					  &assoc_id);
-		spin_unlock_bh(&sctp_assocs_id_lock);
-		if (error == -EAGAIN)
-			goto retry;
-		else if (error)
-			goto clean_up;
-
-		asoc->assoc_id = (sctp_assoc_t) assoc_id;
 	}
 
 	/* ADDIP Section 4.1 ASCONF Chunk Procedures
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index b37a7ad..d9fad4f 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -862,6 +862,33 @@ static void sctp_cmd_set_sk_err(struct sctp_association *asoc, int error)
 		sk->sk_err = error;
 }
 
+/* Helper function to generate an association change event */
+static void sctp_cmd_assoc_change(sctp_cmd_seq_t *commands,
+				 struct sctp_association *asoc,
+				 u8 state)
+{
+	struct sctp_ulpevent *ev;
+
+	ev = sctp_ulpevent_make_assoc_change(asoc, 0, state, 0,
+					    asoc->c.sinit_num_ostreams,
+					    asoc->c.sinit_max_instreams,
+					    NULL, GFP_ATOMIC);
+	if (ev)
+		sctp_ulpq_tail_event(&asoc->ulpq, ev);
+}
+
+/* Helper function to generate an adaptation indication event */
+static void sctp_cmd_adaptation_ind(sctp_cmd_seq_t *commands,
+				    struct sctp_association *asoc)
+{
+	struct sctp_ulpevent *ev;
+
+	ev = sctp_ulpevent_make_adaptation_indication(asoc, GFP_ATOMIC);
+
+	if (ev)
+		sctp_ulpq_tail_event(&asoc->ulpq, ev);
+}
+
 /* These three macros allow us to pull the debugging code out of the
  * main flow of sctp_do_sm() to keep attention focused on the real
  * functionality there.
@@ -1485,6 +1512,14 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 		case SCTP_CMD_SET_SK_ERR:
 			sctp_cmd_set_sk_err(asoc, cmd->obj.error);
 			break;
+		case SCTP_CMD_ASSOC_CHANGE:
+			sctp_cmd_assoc_change(commands, asoc,
+					      cmd->obj.u8);
+			break;
+		case SCTP_CMD_ADAPTATION_IND:
+			sctp_cmd_adaptation_ind(commands, asoc);
+			break;
+
 		default:
 			printk(KERN_WARNING "Impossible command: %u, %p\n",
 			       cmd->verb, cmd->obj.ptr);
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 9e28a5d..f02ce3d 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1656,7 +1656,6 @@ static sctp_disposition_t sctp_sf_do_dupcook_b(const struct sctp_endpoint *ep,
 					struct sctp_association *new_asoc)
 {
 	sctp_init_chunk_t *peer_init;
-	struct sctp_ulpevent *ev;
 	struct sctp_chunk *repl;
 
 	/* new_asoc is a brand-new association, so these are not yet
@@ -1687,34 +1686,28 @@ static sctp_disposition_t sctp_sf_do_dupcook_b(const struct sctp_endpoint *ep,
 	 * D) IMPLEMENTATION NOTE: An implementation may choose to
 	 * send the Communication Up notification to the SCTP user
 	 * upon reception of a valid COOKIE ECHO chunk.
+	 *
+	 * Sadly, this needs to be implemented as a side-effect, because
+	 * we are not guaranteed to have set the association id of the real
+	 * association and so these notifications need to be delayed until
+	 * the association id is allocated.
 	 */
-	ev = sctp_ulpevent_make_assoc_change(asoc, 0, SCTP_COMM_UP, 0,
-					     new_asoc->c.sinit_num_ostreams,
-					     new_asoc->c.sinit_max_instreams,
-					     NULL, GFP_ATOMIC);
-	if (!ev)
-		goto nomem_ev;
 
-	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(ev));
+	sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_CHANGE, SCTP_U8(SCTP_COMM_UP));
 
 	/* Sockets API Draft Section 5.3.1.6
 	 * When a peer sends a Adaptation Layer Indication parameter , SCTP
 	 * delivers this notification to inform the application that of the
 	 * peers requested adaptation layer.
+	 *
+	 * This also needs to be done as a side effect for the same reason as
+	 * above.
 	 */
-	if (asoc->peer.adaptation_ind) {
-		ev = sctp_ulpevent_make_adaptation_indication(asoc, GFP_ATOMIC);
-		if (!ev)
-			goto nomem_ev;
-
-		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
-				SCTP_ULPEVENT(ev));
-	}
+	if (asoc->peer.adaptation_ind)
+		sctp_add_cmd_sf(commands, SCTP_CMD_ADAPTATION_IND, SCTP_NULL());
 
 	return SCTP_DISPOSITION_CONSUME;
 
-nomem_ev:
-	sctp_chunk_free(repl);
 nomem:
 	return SCTP_DISPOSITION_NOMEM;
 }
-- 
1.5.0.3.438.gc49b2

