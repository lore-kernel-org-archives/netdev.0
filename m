From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 4/8] SCTP: Implete SCTP-AUTH parameter processing
Date: Fri, 14 Sep 2007 14:44:55 -0400
Message-ID: <11897954992330-git-send-email-vladislav.yasevich@hp.com>
References: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>
To: lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:33815 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753343AbXINSpB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 14:45:01 -0400
In-Reply-To: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement processing for the CHUNKS, RANDOM, and HMAC parameters and
deal with how this parameters are effected by association restarts.
In particular, during unexpeted INIT processing, we need to reply with
parameters from the original INIT chunk.  Also, after restart, we need
to update the old association with new peer parameters and change the
association shared keys.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/command.h |    1 +
 net/sctp/associola.c       |   21 ++++++-
 net/sctp/sm_make_chunk.c   |  162 +++++++++++++++++++++++++++++++++++++++++++-
 net/sctp/sm_sideeffect.c   |    5 ++
 net/sctp/sm_statefuns.c    |   35 ++++++++++
 5 files changed, 220 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index f56c8d6..b873336 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -102,6 +102,7 @@ typedef enum {
 	SCTP_CMD_SET_SK_ERR,	 /* Set sk_err */
 	SCTP_CMD_ASSOC_CHANGE,	 /* generate and send assoc_change event */
 	SCTP_CMD_ADAPTATION_IND, /* generate and send adaptation event */
+	SCTP_CMD_ASSOC_SHKEY,    /* generate the association shared keys */
 	SCTP_CMD_LAST
 } sctp_verb_t;
 
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index b96c132..09e592b 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -416,6 +416,9 @@ void sctp_association_free(struct sctp_association *asoc)
 
 	/* Free peer's cached cookie. */
 	kfree(asoc->peer.cookie);
+	kfree(asoc->peer.peer_random);
+	kfree(asoc->peer.peer_chunks);
+	kfree(asoc->peer.peer_hmacs);
 
 	/* Release the transport structures. */
 	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
@@ -1149,7 +1152,23 @@ void sctp_assoc_update(struct sctp_association *asoc,
 		}
 	}
 
-	/* SCTP-AUTH: XXX something needs to be done here*/
+	/* SCTP-AUTH: Save the peer parameters from the new assocaitions
+	 * and also move the association shared keys over
+	 */
+	kfree(asoc->peer.peer_random);
+	asoc->peer.peer_random = new->peer.peer_random;
+	new->peer.peer_random = NULL;
+
+	kfree(asoc->peer.peer_chunks);
+	asoc->peer.peer_chunks = new->peer.peer_chunks;
+	new->peer.peer_chunks = NULL;
+
+	kfree(asoc->peer.peer_hmacs);
+	asoc->peer.peer_hmacs = new->peer.peer_hmacs;
+	new->peer.peer_hmacs = NULL;
+
+	sctp_auth_key_put(asoc->asoc_shared_key);
+	sctp_auth_asoc_init_active_key(asoc, GFP_ATOMIC);
 }
 
 /* Update the retran path for sending a retransmitted packet.
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index db70448..cd4eb21 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -182,6 +182,8 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	sctp_supported_ext_param_t ext_param;
 	int num_ext = 0;
 	__u8 extensions[3];
+	sctp_paramhdr_t *auth_chunks = NULL,
+			*auth_hmacs = NULL;
 
 	/* RFC 2960 3.3.2 Initiation (INIT) (1)
 	 *
@@ -214,8 +216,6 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	 *  An implementation supporting this extension [ADDIP] MUST list
 	 *  the ASCONF,the ASCONF-ACK, and the AUTH  chunks in its INIT and
 	 *  INIT-ACK parameters.
-	 *  XXX: We don't support AUTH just yet, so don't list it.  AUTH
-	 *  support should add it.
 	 */
 	if (sctp_addip_enable) {
 		extensions[num_ext] = SCTP_CID_ASCONF;
@@ -226,6 +226,29 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	chunksize += sizeof(aiparam);
 	chunksize += vparam_len;
 
+	/* Account for AUTH related parameters */
+	if (sctp_auth_enable) {
+		/* Add random parameter length*/
+		chunksize += sizeof(asoc->c.auth_random);
+
+		/* Add HMACS parameter length if any were defined */
+		auth_hmacs = (sctp_paramhdr_t *)asoc->c.auth_hmacs;
+		if (auth_hmacs->length)
+			chunksize += ntohs(auth_hmacs->length);
+		else
+			auth_hmacs = NULL;
+
+		/* Add CHUNKS parameter length */
+		auth_chunks = (sctp_paramhdr_t *)asoc->c.auth_chunks;
+		if (auth_chunks->length)
+			chunksize += ntohs(auth_chunks->length);
+		else
+			auth_hmacs = NULL;
+
+		extensions[num_ext] = SCTP_CID_AUTH;
+		num_ext += 1;
+	}
+
 	/* If we have any extensions to report, account for that */
 	if (num_ext)
 		chunksize += sizeof(sctp_supported_ext_param_t) + num_ext;
@@ -285,6 +308,17 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	aiparam.adaptation_ind = htonl(sp->adaptation_ind);
 	sctp_addto_chunk(retval, sizeof(aiparam), &aiparam);
 
+	/* Add SCTP-AUTH chunks to the parameter list */
+	if (sctp_auth_enable) {
+		sctp_addto_chunk(retval, sizeof(asoc->c.auth_random),
+				 asoc->c.auth_random);
+		if (auth_hmacs)
+			sctp_addto_chunk(retval, ntohs(auth_hmacs->length),
+					auth_hmacs);
+		if (auth_chunks)
+			sctp_addto_chunk(retval, ntohs(auth_chunks->length),
+					auth_chunks);
+	}
 nodata:
 	kfree(addrs.v);
 	return retval;
@@ -305,6 +339,9 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	sctp_supported_ext_param_t ext_param;
 	int num_ext = 0;
 	__u8 extensions[3];
+	sctp_paramhdr_t *auth_chunks = NULL,
+			*auth_hmacs = NULL,
+			*auth_random = NULL;
 
 	retval = NULL;
 
@@ -350,6 +387,26 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	chunksize += sizeof(ext_param) + num_ext;
 	chunksize += sizeof(aiparam);
 
+	if (asoc->peer.auth_capable) {
+		auth_random = (sctp_paramhdr_t *)asoc->c.auth_random;
+		chunksize += ntohs(auth_random->length);
+
+		auth_hmacs = (sctp_paramhdr_t *)asoc->c.auth_hmacs;
+		if (auth_hmacs->length)
+			chunksize += ntohs(auth_hmacs->length);
+		else
+			auth_hmacs = NULL;
+
+		auth_chunks = (sctp_paramhdr_t *)asoc->c.auth_chunks;
+		if (auth_chunks->length)
+			chunksize += ntohs(auth_chunks->length);
+		else
+			auth_chunks = NULL;
+
+		extensions[num_ext] = SCTP_CID_AUTH;
+		num_ext += 1;
+	}
+
 	/* Now allocate and fill out the chunk.  */
 	retval = sctp_make_chunk(asoc, SCTP_CID_INIT_ACK, 0, chunksize);
 	if (!retval)
@@ -381,6 +438,17 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	aiparam.adaptation_ind = htonl(sctp_sk(asoc->base.sk)->adaptation_ind);
 	sctp_addto_chunk(retval, sizeof(aiparam), &aiparam);
 
+	if (asoc->peer.auth_capable) {
+		sctp_addto_chunk(retval, ntohs(auth_random->length),
+				 auth_random);
+		if (auth_hmacs)
+			sctp_addto_chunk(retval, ntohs(auth_hmacs->length),
+					auth_hmacs);
+		if (auth_chunks)
+			sctp_addto_chunk(retval, ntohs(auth_chunks->length),
+					auth_chunks);
+	}
+
 	/* We need to remove the const qualifier at this point.  */
 	retval->asoc = (struct sctp_association *) asoc;
 
@@ -1736,6 +1804,12 @@ static void sctp_process_ext_param(struct sctp_association *asoc,
 				!asoc->peer.prsctp_capable)
 				    asoc->peer.prsctp_capable = 1;
 			    break;
+		    case SCTP_CID_AUTH:
+			    /* if the peer reports AUTH, assume that he
+			     * supports AUTH.
+			     */
+			    asoc->peer.auth_capable = 1;
+			    break;
 		    case SCTP_CID_ASCONF:
 		    case SCTP_CID_ASCONF_ACK:
 			    /* don't need to do anything for ASCONF */
@@ -1871,7 +1945,42 @@ static int sctp_verify_param(const struct sctp_association *asoc,
 	case SCTP_PARAM_FWD_TSN_SUPPORT:
 		if (sctp_prsctp_enable)
 			break;
+		goto fallthrough;
+
+	case SCTP_PARAM_RANDOM:
+		if (!sctp_auth_enable)
+			goto fallthrough;
+
+		/* SCTP-AUTH: Secion 6.1
+		 * If the random number is not 32 byte long the association
+		 * MUST be aborted.  The ABORT chunk SHOULD contain the error
+		 * cause 'Protocol Violation'.
+		 */
+		if (SCTP_AUTH_RANDOM_LENGTH !=
+			ntohs(param.p->length) - sizeof(sctp_paramhdr_t))
+			return sctp_process_inv_paramlength(asoc, param.p,
+							chunk, err_chunk);
+		break;
+
+	case SCTP_PARAM_CHUNKS:
+		if (!sctp_auth_enable)
+			goto fallthrough;
+
+		/* SCTP-AUTH: Section 3.2
+		 * The CHUNKS parameter MUST be included once in the INIT or
+		 *  INIT-ACK chunk if the sender wants to receive authenticated
+		 *  chunks.  Its maximum length is 260 bytes.
+		 */
+		if (260 < ntohs(param.p->length))
+			return sctp_process_inv_paramlength(asoc, param.p,
+							chunk, err_chunk);
+		break;
+
+	case SCTP_PARAM_HMAC_ALGO:
+		if (!sctp_auth_enable)
+			break;
 		/* Fall Through */
+fallthrough:
 	default:
 		SCTP_DEBUG_PRINTK("Unrecognized param: %d for chunk %d.\n",
 				ntohs(param.p->type), cid);
@@ -1976,13 +2085,19 @@ int sctp_process_init(struct sctp_association *asoc, sctp_cid_t cid,
 	}
 
 	/* Process the initialization parameters.  */
-
 	sctp_walk_params(param, peer_init, init_hdr.params) {
 
 		if (!sctp_process_param(asoc, param, peer_addr, gfp))
 			goto clean_up;
 	}
 
+	/* AUTH: After processing the parameters, make sure that we
+	 * have all the required info to potentially do authentications.
+	 */
+	if (asoc->peer.auth_capable && (!asoc->peer.peer_random ||
+					!asoc->peer.peer_hmacs))
+		asoc->peer.auth_capable = 0;
+
 	/* Walk list of transports, removing transports in the UNKNOWN state. */
 	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
 		transport = list_entry(pos, struct sctp_transport, transports);
@@ -2222,6 +2337,47 @@ static int sctp_process_param(struct sctp_association *asoc,
 			break;
 		}
 		/* Fall Through */
+		goto fall_through;
+
+	case SCTP_PARAM_RANDOM:
+		if (!sctp_auth_enable)
+			goto fall_through;
+
+		/* Save peer's random parameter */
+		asoc->peer.peer_random = kmemdup(param.p,
+					    ntohs(param.p->length), gfp);
+		if (!asoc->peer.peer_random) {
+			retval = 0;
+			break;
+		}
+		break;
+
+	case SCTP_PARAM_HMAC_ALGO:
+		if (!sctp_auth_enable)
+			goto fall_through;
+
+		/* Save peer's HMAC list */
+		asoc->peer.peer_hmacs = kmemdup(param.p,
+					    ntohs(param.p->length), gfp);
+		if (!asoc->peer.peer_hmacs) {
+			retval = 0;
+			break;
+		}
+
+		/* Set the default HMAC the peer requested*/
+		sctp_auth_asoc_set_default_hmac(asoc, param.hmac_algo);
+		break;
+
+	case SCTP_PARAM_CHUNKS:
+		if (!sctp_auth_enable)
+			goto fall_through;
+
+		asoc->peer.peer_chunks = kmemdup(param.p,
+					    ntohs(param.p->length), gfp);
+		if (!asoc->peer.peer_chunks)
+			retval = 0;
+		break;
+fall_through:
 	default:
 		/* Any unrecognized parameters should have been caught
 		 * and handled by sctp_verify_param() which should be
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 8d78900..bbdc938 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1524,6 +1524,11 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 			sctp_cmd_adaptation_ind(commands, asoc);
 			break;
 
+		case SCTP_CMD_ASSOC_SHKEY:
+			error = sctp_auth_asoc_init_active_key(asoc,
+						GFP_ATOMIC);
+			break;
+
 		default:
 			printk(KERN_WARNING "Impossible command: %u, %p\n",
 			       cmd->verb, cmd->obj.ptr);
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index faa1381..7d8e92f 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -524,6 +524,11 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,
 	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_STATE,
 			SCTP_STATE(SCTP_STATE_COOKIE_ECHOED));
 
+	/* SCTP-AUTH: genereate the assocition shared keys so that
+	 * we can potentially signe the COOKIE-ECHO.
+	 */
+	sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_SHKEY, SCTP_NULL());
+
 	/* 5.1 C) "A" shall then send the State Cookie received in the
 	 * INIT ACK chunk in a COOKIE ECHO chunk, ...
 	 */
@@ -661,6 +666,14 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(const struct sctp_endpoint *ep,
 			       peer_init, GFP_ATOMIC))
 		goto nomem_init;
 
+	/* SCTP-AUTH:  Now that we've populate required fields in
+	 * sctp_process_init, set up the assocaition shared keys as
+	 * necessary so that we can potentially authenticate the ACK
+	 */
+	error = sctp_auth_asoc_init_active_key(new_asoc, GFP_ATOMIC);
+	if (error)
+		goto nomem_init;
+
 	repl = sctp_make_cookie_ack(new_asoc, chunk);
 	if (!repl)
 		goto nomem_init;
@@ -1222,6 +1235,26 @@ static void sctp_tietags_populate(struct sctp_association *new_asoc,
 	new_asoc->c.initial_tsn         = asoc->c.initial_tsn;
 }
 
+static void sctp_auth_params_populate(struct sctp_association *new_asoc,
+				    const struct sctp_association *asoc)
+{
+	/* Only perform this if AUTH extension is enabled */
+	if (!sctp_auth_enable)
+		return;
+
+	/* We need to provide the same parameter information as
+	 * was in the original INIT.  This means that we need to copy
+	 * the HMACS, CHUNKS, and RANDOM parameter from the original
+	 * assocaition.
+	 */
+	memcpy(new_asoc->c.auth_random, asoc->c.auth_random,
+		sizeof(asoc->c.auth_random));
+	memcpy(new_asoc->c.auth_hmacs, asoc->c.auth_hmacs,
+		sizeof(asoc->c.auth_hmacs));
+	memcpy(new_asoc->c.auth_chunks, asoc->c.auth_chunks,
+		sizeof(asoc->c.auth_chunks));
+}
+
 /*
  * Compare vtag/tietag values to determine unexpected COOKIE-ECHO
  * handling action.
@@ -1379,6 +1412,8 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 
 	sctp_tietags_populate(new_asoc, asoc);
 
+	sctp_auth_params_populate(new_asoc, asoc);
+
 	/* B) "Z" shall respond immediately with an INIT ACK chunk.  */
 
 	/* If there are errors need to be reported for unknown parameters,
-- 
1.5.2.4

