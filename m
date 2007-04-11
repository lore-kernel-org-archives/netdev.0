From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [SCTP] Initialization collision problem
Date: Wed, 11 Apr 2007 10:45:07 -0400
Message-ID: <461CF473.7010307@hp.com>
References: <5F14EEE91CB6694A86535A0A028D9C5501555FEF@tx14exm60.ds.mot.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090703030501060409060605"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Isaula Oscar-QOI000 <Oscar.Isaula@motorola.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:44676 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752879AbXDKOpM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 10:45:12 -0400
In-Reply-To: <5F14EEE91CB6694A86535A0A028D9C5501555FEF@tx14exm60.ds.mot.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090703030501060409060605
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi Oscar

Isaula Oscar-QOI000 wrote:
> I ran into a problem where LKSCTP is reporting a SCTM_COMM_UP indication
> to the User application but is giving back a value of zero for the
> assoc_id.
> 
> Attached are the SCTP debugs for the period in question.
> 
> A couple of things that I would like to note about my setup. One is that
> I'm running Kernel version 2.6.10 (I know is old but I can't move to a
> newer version due to custom drivers). The second thing is that the link
> between the two SCTP node is a very noisy and some messages are getting
> lost (i.e. the INIT_ACK from the peer in this particular case).
> 

Can you give this patch a try and let me know if this fixes your issue?

Thanks
-vlad

--------------090703030501060409060605
Content-Type: text/plain;
 name="oscar_patch.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="oscar_patch.txt"

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 4e0e224..7a426d3 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -97,6 +97,8 @@ typedef enum {
 	SCTP_CMD_DEL_NON_PRIMARY, /* Removes non-primary peer transports. */
 	SCTP_CMD_T3_RTX_TIMERS_STOP, /* Stops T3-rtx pending timers */
 	SCTP_CMD_FORCE_PRIM_RETRAN,  /* Forces retrans. over primary path. */
+	SCTP_CMD_ASSOC_CHANGE,	 /* generate and send assoc_change event */
+	SCTP_CMD_ADAPTATION_IND, /* generate and send adaptation event */
 	SCTP_CMD_LAST
 } sctp_verb_t;
 
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 3bd04bc..4742fdd 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1732,6 +1732,7 @@ void sctp_assoc_set_primary(struct sctp_association *,
 int sctp_assoc_set_bind_addr_from_ep(struct sctp_association *, int);
 int sctp_assoc_set_bind_addr_from_cookie(struct sctp_association *,
 					 struct sctp_cookie*, int gfp);
+int sctp_assoc_set_id(struct sctp_association *, int);
 
 int sctp_cmp_addr_exact(const union sctp_addr *ss1,
 			const union sctp_addr *ss2);
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 498a713..09fd31e 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -987,6 +987,13 @@ void sctp_assoc_update(struct sctp_association *asoc,
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
 
@@ -1222,3 +1229,25 @@ out:
 	sctp_read_unlock(&asoc->base.addr_lock);
 	return found;
 }
+
+/* Set an association id for a given association */
+int sctp_assoc_set_id(struct sctp_association *asoc, int gfp)
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
index 1f0676d..98cfbbd 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1853,7 +1853,6 @@ int sctp_process_init(struct sctp_association *asoc, sctp_cid_t cid,
 	/* Allocate storage for the negotiated streams if it is not a temporary 	 * association.
 	 */
 	if (!asoc->temp) {
-		int assoc_id;
 		int error;
 
 		asoc->ssnmap = sctp_ssnmap_new(asoc->c.sinit_max_instreams,
@@ -1861,19 +1860,9 @@ int sctp_process_init(struct sctp_association *asoc, sctp_cid_t cid,
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
index c9705de..43155c8 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -786,6 +786,33 @@ static void sctp_cmd_del_non_primary(struct sctp_association *asoc)
 	return;
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
+					    GFP_ATOMIC);
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
@@ -1353,6 +1380,14 @@ int sctp_cmd_interpreter(sctp_event_t event_type, sctp_subtype_t subtype,
 			local_cork = 0;
 			asoc->peer.retran_path = t;
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
index 7871faa..99cb9a7 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1521,7 +1521,6 @@ static sctp_disposition_t sctp_sf_do_dupcook_b(const struct sctp_endpoint *ep,
 					struct sctp_association *new_asoc)
 {
 	sctp_init_chunk_t *peer_init;
-	struct sctp_ulpevent *ev;
 	struct sctp_chunk *repl;
 
 	/* new_asoc is a brand-new association, so these are not yet
@@ -1552,34 +1551,28 @@ static sctp_disposition_t sctp_sf_do_dupcook_b(const struct sctp_endpoint *ep,
 	 * D) IMPLEMENTATION NOTE: An implementation may choose to
 	 * send the Communication Up notification to the SCTP user
 	 * upon reception of a valid COOKIE ECHO chunk.
-	 */
-	ev = sctp_ulpevent_make_assoc_change(asoc, 0, SCTP_COMM_UP, 0,
-					     new_asoc->c.sinit_num_ostreams,
-					     new_asoc->c.sinit_max_instreams,
-					     GFP_ATOMIC);
-	if (!ev)
-		goto nomem_ev;
-
-	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(ev));
+	 *
+	 * Sadly, this needs to be implemented as a side-effect, because
+	 * we are not guaranteed to have set the association id of the real
+	 * association and so these notifications need to be delayed until
+	 * the association id is allocated.
+  	 */
+  
+	sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_CHANGE, SCTP_U8(SCTP_COMM_UP));
 
 	/* Sockets API Draft Section 5.3.1.6
 	 * When a peer sends a Adaption Layer Indication parameter , SCTP
 	 * delivers this notification to inform the application that of the
 	 * peers requested adaption layer.
-	 */
-	if (asoc->peer.adaption_ind) {
-		ev = sctp_ulpevent_make_adaption_indication(asoc, GFP_ATOMIC);
-		if (!ev)
-			goto nomem_ev;
-
-		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
-				SCTP_ULPEVENT(ev));
-	}
+	 *
+	 * This also needs to be done as a side effect for the same reason as
+	 * above.
+  	 */
+	if (asoc->peer.adaptation_ind)
+		sctp_add_cmd_sf(commands, SCTP_CMD_ADAPTATION_IND, SCTP_NULL());
 
 	return SCTP_DISPOSITION_CONSUME;
 
-nomem_ev:
-	sctp_chunk_free(repl);
 nomem:
 	return SCTP_DISPOSITION_NOMEM;
 }

--------------090703030501060409060605--
