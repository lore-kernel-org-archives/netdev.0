From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 03/14] sctp: remove the typedef sctp_errhdr_t
Date: Thu,  3 Aug 2017 15:42:11 +0800
Message-ID: <ef0bf503017711311e9fc167c4b5bfd9de885d04.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
 <8149f8b0a190eb047abfe48a7fa79ba74e4e4544.1501745729.git.lucien.xin@gmail.com>
 <457c0c30e478f1ead75d3606e17519ca23daddfc.1501745729.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33868 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751262AbdHCHnG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 03:43:06 -0400
In-Reply-To: <457c0c30e478f1ead75d3606e17519ca23daddfc.1501745729.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_errhdr_t, and replace
with struct sctp_errhdr in the places where it's using this
typedef.

It is also to use sizeof(variable) instead of sizeof(type).

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h     |  6 +++---
 include/net/sctp/sctp.h  |  8 ++++----
 net/sctp/sm_make_chunk.c | 38 ++++++++++++++++++++------------------
 net/sctp/sm_sideeffect.c |  2 +-
 net/sctp/sm_statefuns.c  | 29 +++++++++++++++--------------
 net/sctp/ulpevent.c      | 10 +++++-----
 6 files changed, 48 insertions(+), 45 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 553020c..d35bdd3 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -427,15 +427,15 @@ struct sctp_shutdown_chunk {
 
 /* RFC 2960.  Section 3.3.10 Operation Error (ERROR) (9) */
 
-typedef struct sctp_errhdr {
+struct sctp_errhdr {
 	__be16 cause;
 	__be16 length;
 	__u8  variable[0];
-} sctp_errhdr_t;
+};
 
 typedef struct sctp_operr_chunk {
 	struct sctp_chunkhdr chunk_hdr;
-	sctp_errhdr_t err_hdr;
+	struct sctp_errhdr err_hdr;
 } sctp_operr_chunk_t;
 
 /* RFC 2960 3.3.10 - Operation Error
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 45fd4c6..84650fe 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -479,13 +479,13 @@ for (pos.v = chunk->member;\
 _sctp_walk_errors((err), (chunk_hdr), ntohs((chunk_hdr)->length))
 
 #define _sctp_walk_errors(err, chunk_hdr, end)\
-for (err = (sctp_errhdr_t *)((void *)chunk_hdr + \
+for (err = (struct sctp_errhdr *)((void *)chunk_hdr + \
 	    sizeof(struct sctp_chunkhdr));\
-     ((void *)err + offsetof(sctp_errhdr_t, length) + sizeof(err->length) <=\
+     ((void *)err + offsetof(struct sctp_errhdr, length) + sizeof(err->length) <=\
       (void *)chunk_hdr + end) &&\
      (void *)err <= (void *)chunk_hdr + end - ntohs(err->length) &&\
-     ntohs(err->length) >= sizeof(sctp_errhdr_t); \
-     err = (sctp_errhdr_t *)((void *)err + SCTP_PAD4(ntohs(err->length))))
+     ntohs(err->length) >= sizeof(struct sctp_errhdr); \
+     err = (struct sctp_errhdr *)((void *)err + SCTP_PAD4(ntohs(err->length))))
 
 #define sctp_walk_fwdtsn(pos, chunk)\
 _sctp_walk_fwdtsn((pos), (chunk), ntohs((chunk)->chunk_hdr->length) - sizeof(struct sctp_fwdtsn_chunk))
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 8f1c6b6..0b2298b 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -135,14 +135,14 @@ static const struct sctp_paramhdr prsctp_param = {
 void  sctp_init_cause(struct sctp_chunk *chunk, __be16 cause_code,
 		      size_t paylen)
 {
-	sctp_errhdr_t err;
+	struct sctp_errhdr err;
 	__u16 len;
 
 	/* Cause code constants are now defined in network order.  */
 	err.cause = cause_code;
-	len = sizeof(sctp_errhdr_t) + paylen;
+	len = sizeof(err) + paylen;
 	err.length  = htons(len);
-	chunk->subh.err_hdr = sctp_addto_chunk(chunk, sizeof(sctp_errhdr_t), &err);
+	chunk->subh.err_hdr = sctp_addto_chunk(chunk, sizeof(err), &err);
 }
 
 /* A helper to initialize an op error inside a
@@ -153,19 +153,19 @@ void  sctp_init_cause(struct sctp_chunk *chunk, __be16 cause_code,
 static int sctp_init_cause_fixed(struct sctp_chunk *chunk, __be16 cause_code,
 		      size_t paylen)
 {
-	sctp_errhdr_t err;
+	struct sctp_errhdr err;
 	__u16 len;
 
 	/* Cause code constants are now defined in network order.  */
 	err.cause = cause_code;
-	len = sizeof(sctp_errhdr_t) + paylen;
+	len = sizeof(err) + paylen;
 	err.length  = htons(len);
 
 	if (skb_tailroom(chunk->skb) < len)
 		return -ENOSPC;
-	chunk->subh.err_hdr = sctp_addto_chunk_fixed(chunk,
-						     sizeof(sctp_errhdr_t),
-						     &err);
+
+	chunk->subh.err_hdr = sctp_addto_chunk_fixed(chunk, sizeof(err), &err);
+
 	return 0;
 }
 /* 3.3.2 Initiation (INIT) (1)
@@ -979,8 +979,8 @@ struct sctp_chunk *sctp_make_abort_no_data(
 	struct sctp_chunk *retval;
 	__be32 payload;
 
-	retval = sctp_make_abort(asoc, chunk, sizeof(sctp_errhdr_t)
-				 + sizeof(tsn));
+	retval = sctp_make_abort(asoc, chunk,
+				 sizeof(struct sctp_errhdr) + sizeof(tsn));
 
 	if (!retval)
 		goto no_mem;
@@ -1015,7 +1015,8 @@ struct sctp_chunk *sctp_make_abort_user(const struct sctp_association *asoc,
 	void *payload = NULL;
 	int err;
 
-	retval = sctp_make_abort(asoc, NULL, sizeof(sctp_errhdr_t) + paylen);
+	retval = sctp_make_abort(asoc, NULL,
+				 sizeof(struct sctp_errhdr) + paylen);
 	if (!retval)
 		goto err_chunk;
 
@@ -1080,8 +1081,8 @@ struct sctp_chunk *sctp_make_abort_violation(
 	struct sctp_chunk  *retval;
 	struct sctp_paramhdr phdr;
 
-	retval = sctp_make_abort(asoc, chunk, sizeof(sctp_errhdr_t) + paylen +
-					      sizeof(phdr));
+	retval = sctp_make_abort(asoc, chunk, sizeof(struct sctp_errhdr) +
+					      paylen + sizeof(phdr));
 	if (!retval)
 		goto end;
 
@@ -1104,7 +1105,7 @@ struct sctp_chunk *sctp_make_violation_paramlen(
 {
 	struct sctp_chunk *retval;
 	static const char error[] = "The following parameter had invalid length:";
-	size_t payload_len = sizeof(error) + sizeof(sctp_errhdr_t) +
+	size_t payload_len = sizeof(error) + sizeof(struct sctp_errhdr) +
 			     sizeof(*param);
 
 	retval = sctp_make_abort(asoc, chunk, payload_len);
@@ -1126,7 +1127,7 @@ struct sctp_chunk *sctp_make_violation_max_retrans(
 {
 	struct sctp_chunk *retval;
 	static const char error[] = "Association exceeded its max_retans count";
-	size_t payload_len = sizeof(error) + sizeof(sctp_errhdr_t);
+	size_t payload_len = sizeof(error) + sizeof(struct sctp_errhdr);
 
 	retval = sctp_make_abort(asoc, chunk, payload_len);
 	if (!retval)
@@ -1209,7 +1210,8 @@ static struct sctp_chunk *sctp_make_op_error_space(
 	struct sctp_chunk *retval;
 
 	retval = sctp_make_control(asoc, SCTP_CID_ERROR, 0,
-				   sizeof(sctp_errhdr_t) + size, GFP_ATOMIC);
+				   sizeof(struct sctp_errhdr) + size,
+				   GFP_ATOMIC);
 	if (!retval)
 		goto nodata;
 
@@ -2966,7 +2968,7 @@ static void sctp_add_asconf_response(struct sctp_chunk *chunk, __be32 crr_id,
 			      __be16 err_code, sctp_addip_param_t *asconf_param)
 {
 	sctp_addip_param_t 	ack_param;
-	sctp_errhdr_t		err_param;
+	struct sctp_errhdr	err_param;
 	int			asconf_param_len = 0;
 	int			err_param_len = 0;
 	__be16			response_type;
@@ -3351,7 +3353,7 @@ static __be16 sctp_get_asconf_response(struct sctp_chunk *asconf_ack,
 				      int no_err)
 {
 	sctp_addip_param_t	*asconf_ack_param;
-	sctp_errhdr_t		*err_param;
+	struct sctp_errhdr	*err_param;
 	int			length;
 	int			asconf_ack_len;
 	__be16			err_code;
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index d6e5e9e..5dda8c4 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -828,7 +828,7 @@ static void sctp_cmd_assoc_update(sctp_cmd_seq_t *cmds,
 	if (!sctp_assoc_update(asoc, new))
 		return;
 
-	abort = sctp_make_abort(asoc, NULL, sizeof(sctp_errhdr_t));
+	abort = sctp_make_abort(asoc, NULL, sizeof(struct sctp_errhdr));
 	if (abort) {
 		sctp_init_cause(abort, SCTP_ERROR_RSRC_LOW, 0);
 		sctp_add_cmd_sf(cmds, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index d4d8fab..7a2ba4c 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1233,7 +1233,7 @@ static int sctp_sf_send_restart_abort(struct net *net, union sctp_addr *ssa,
 	union sctp_addr_param *addrparm;
 	struct sctp_errhdr *errhdr;
 	struct sctp_endpoint *ep;
-	char buffer[sizeof(struct sctp_errhdr)+sizeof(union sctp_addr_param)];
+	char buffer[sizeof(*errhdr) + sizeof(*addrparm)];
 	struct sctp_af *af = sctp_get_af_specific(ssa->v4.sin_family);
 
 	/* Build the error on the stack.   We are way to malloc crazy
@@ -1244,7 +1244,7 @@ static int sctp_sf_send_restart_abort(struct net *net, union sctp_addr *ssa,
 
 	/* Copy into a parm format. */
 	len = af->to_addr_param(ssa, addrparm);
-	len += sizeof(sctp_errhdr_t);
+	len += sizeof(*errhdr);
 
 	errhdr->cause = SCTP_ERROR_RESTART;
 	errhdr->length = htons(len);
@@ -2270,7 +2270,7 @@ sctp_disposition_t sctp_sf_cookie_echoed_err(struct net *net,
 					sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
-	sctp_errhdr_t *err;
+	struct sctp_errhdr *err;
 
 	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
@@ -2337,7 +2337,7 @@ static sctp_disposition_t sctp_sf_do_5_2_6_stale(struct net *net,
 	struct sctp_chunk *chunk = arg, *reply;
 	struct sctp_cookie_preserve_param bht;
 	struct sctp_bind_addr *bp;
-	sctp_errhdr_t *err;
+	struct sctp_errhdr *err;
 	u32 stale;
 
 	if (attempts > asoc->max_init_attempts) {
@@ -2348,7 +2348,7 @@ static sctp_disposition_t sctp_sf_do_5_2_6_stale(struct net *net,
 		return SCTP_DISPOSITION_DELETE_TCB;
 	}
 
-	err = (sctp_errhdr_t *)(chunk->skb->data);
+	err = (struct sctp_errhdr *)(chunk->skb->data);
 
 	/* When calculating the time extension, an implementation
 	 * SHOULD use the RTT information measured based on the
@@ -2364,7 +2364,7 @@ static sctp_disposition_t sctp_sf_do_5_2_6_stale(struct net *net,
 	 * to give ample time to retransmit the new cookie and thus
 	 * yield a higher probability of success on the reattempt.
 	 */
-	stale = ntohl(*(__be32 *)((u8 *)err + sizeof(sctp_errhdr_t)));
+	stale = ntohl(*(__be32 *)((u8 *)err + sizeof(*err)));
 	stale = (stale * 2) / 1000;
 
 	bht.param_hdr.type = SCTP_PARAM_COOKIE_PRESERVATIVE;
@@ -2499,13 +2499,14 @@ static sctp_disposition_t __sctp_sf_do_9_1_abort(struct net *net,
 	/* See if we have an error cause code in the chunk.  */
 	len = ntohs(chunk->chunk_hdr->length);
 	if (len >= sizeof(struct sctp_chunkhdr) + sizeof(struct sctp_errhdr)) {
+		struct sctp_errhdr *err;
 
-		sctp_errhdr_t *err;
 		sctp_walk_errors(err, chunk->chunk_hdr);
 		if ((void *)err != (void *)chunk->chunk_end)
-			return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
+			return sctp_sf_pdiscard(net, ep, asoc, type, arg,
+						commands);
 
-		error = ((sctp_errhdr_t *)chunk->skb->data)->cause;
+		error = ((struct sctp_errhdr *)chunk->skb->data)->cause;
 	}
 
 	sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR, SCTP_ERROR(ECONNRESET));
@@ -2552,7 +2553,7 @@ sctp_disposition_t sctp_sf_cookie_wait_abort(struct net *net,
 	/* See if we have an error cause code in the chunk.  */
 	len = ntohs(chunk->chunk_hdr->length);
 	if (len >= sizeof(struct sctp_chunkhdr) + sizeof(struct sctp_errhdr))
-		error = ((sctp_errhdr_t *)chunk->skb->data)->cause;
+		error = ((struct sctp_errhdr *)chunk->skb->data)->cause;
 
 	return sctp_stop_t1_and_abort(net, commands, error, ECONNREFUSED, asoc,
 				      chunk->transport);
@@ -3310,7 +3311,7 @@ sctp_disposition_t sctp_sf_operr_notify(struct net *net,
 					sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
-	sctp_errhdr_t *err;
+	struct sctp_errhdr *err;
 
 	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
@@ -3433,7 +3434,7 @@ sctp_disposition_t sctp_sf_ootb(struct net *net,
 	struct sctp_chunk *chunk = arg;
 	struct sk_buff *skb = chunk->skb;
 	struct sctp_chunkhdr *ch;
-	sctp_errhdr_t *err;
+	struct sctp_errhdr *err;
 	__u8 *ch_end;
 	int ootb_shut_ack = 0;
 	int ootb_cookie_ack = 0;
@@ -3776,7 +3777,7 @@ sctp_disposition_t sctp_sf_do_asconf_ack(struct net *net,
 	if (ADDIP_SERIAL_gte(rcvd_serial, sent_serial + 1) &&
 	    !(asoc->addip_last_asconf)) {
 		abort = sctp_make_abort(asoc, asconf_ack,
-					sizeof(sctp_errhdr_t));
+					sizeof(struct sctp_errhdr));
 		if (abort) {
 			sctp_init_cause(abort, SCTP_ERROR_ASCONF_ACK, 0);
 			sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
@@ -3812,7 +3813,7 @@ sctp_disposition_t sctp_sf_do_asconf_ack(struct net *net,
 		}
 
 		abort = sctp_make_abort(asoc, asconf_ack,
-					sizeof(sctp_errhdr_t));
+					sizeof(struct sctp_errhdr));
 		if (abort) {
 			sctp_init_cause(abort, SCTP_ERROR_RSRC_LOW, 0);
 			sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 5f86c50..67abc01 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -371,19 +371,19 @@ sctp_ulpevent_make_remote_error(const struct sctp_association *asoc,
 				struct sctp_chunk *chunk, __u16 flags,
 				gfp_t gfp)
 {
-	struct sctp_ulpevent *event;
 	struct sctp_remote_error *sre;
+	struct sctp_ulpevent *event;
+	struct sctp_errhdr *ch;
 	struct sk_buff *skb;
-	sctp_errhdr_t *ch;
 	__be16 cause;
 	int elen;
 
-	ch = (sctp_errhdr_t *)(chunk->skb->data);
+	ch = (struct sctp_errhdr *)(chunk->skb->data);
 	cause = ch->cause;
-	elen = SCTP_PAD4(ntohs(ch->length)) - sizeof(sctp_errhdr_t);
+	elen = SCTP_PAD4(ntohs(ch->length)) - sizeof(*ch);
 
 	/* Pull off the ERROR header.  */
-	skb_pull(chunk->skb, sizeof(sctp_errhdr_t));
+	skb_pull(chunk->skb, sizeof(*ch));
 
 	/* Copy the skb to a new skb with room for us to prepend
 	 * notification with.
-- 
2.1.0
