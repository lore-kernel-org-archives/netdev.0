From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2.6.25 8/9] SCTP: Implement ADD-IP special case processing for ABORT chunk
Date: Mon, 17 Dec 2007 16:32:48 -0500
Message-ID: <1197927169-5106-9-git-send-email-vladislav.yasevich@hp.com>
References: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:15317 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759947AbXLQVcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 16:32:55 -0500
In-Reply-To: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ADD-IP spec has a special case for processing ABORTs:
    F4) ... One special consideration is that ABORT
        Chunks arriving destined to the IP address being deleted MUST be
        ignored (see Section 5.3.1 for further details).

Check if the address we received on is in the DEL state, and if
so, ignore the ABORT.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |    2 +
 net/sctp/bind_addr.c       |   26 ++++++++++++++++++++++
 net/sctp/sm_statefuns.c    |   52 ++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 76 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 32e6591..27e9cf5 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1200,6 +1200,8 @@ int sctp_add_bind_addr(struct sctp_bind_addr *, union sctp_addr *,
 int sctp_del_bind_addr(struct sctp_bind_addr *, union sctp_addr *);
 int sctp_bind_addr_match(struct sctp_bind_addr *, const union sctp_addr *,
 			 struct sctp_sock *);
+int sctp_bind_addr_state(const struct sctp_bind_addr *bp,
+			 const union sctp_addr *addr);
 union sctp_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
 					const union sctp_addr	*addrs,
 					int			addrcnt,
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index 4326611..13fbfb4 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -353,6 +353,32 @@ int sctp_bind_addr_match(struct sctp_bind_addr *bp,
 	return match;
 }
 
+/* Get the state of the entry in the bind_addr_list */
+int sctp_bind_addr_state(const struct sctp_bind_addr *bp,
+			 const union sctp_addr *addr)
+{
+	struct sctp_sockaddr_entry *laddr;
+	struct sctp_af *af;
+	int state = -1;
+
+	af = sctp_get_af_specific(addr->sa.sa_family);
+	if (unlikely(!af))
+		return state;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(laddr, &bp->address_list, list) {
+		if (!laddr->valid)
+			continue;
+		if (af->cmp_addr(&laddr->a, addr)) {
+			state = laddr->state;
+			break;
+		}
+	}
+	rcu_read_unlock();
+
+	return state;
+}
+
 /* Find the first address in the bind address list that is not present in
  * the addrs packed array.
  */
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 8fe2e61..eed47c6 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -143,6 +143,12 @@ static sctp_ierror_t sctp_sf_authenticate(const struct sctp_endpoint *ep,
 				    const sctp_subtype_t type,
 				    struct sctp_chunk *chunk);
 
+static sctp_disposition_t __sctp_sf_do_9_1_abort(const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const sctp_subtype_t type,
+					void *arg,
+					sctp_cmd_seq_t *commands);
+
 /* Small helper function that checks if the chunk length
  * is of the appropriate length.  The 'required_length' argument
  * is set to be the size of a specific chunk we are testing.
@@ -2095,11 +2101,20 @@ sctp_disposition_t sctp_sf_shutdown_pending_abort(
 	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_abort_chunk_t)))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
 
+	/* ADD-IP: Special case for ABORT chunks
+	 * F4)  One special consideration is that ABORT Chunks arriving
+	 * destined to the IP address being deleted MUST be
+	 * ignored (see Section 5.3.1 for further details).
+	 */
+	if (SCTP_ADDR_DEL ==
+		    sctp_bind_addr_state(&asoc->base.bind_addr, &chunk->dest))
+		return sctp_sf_discard_chunk(ep, asoc, type, arg, commands);
+
 	/* Stop the T5-shutdown guard timer.  */
 	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
 			SCTP_TO(SCTP_EVENT_TIMEOUT_T5_SHUTDOWN_GUARD));
 
-	return sctp_sf_do_9_1_abort(ep, asoc, type, arg, commands);
+	return __sctp_sf_do_9_1_abort(ep, asoc, type, arg, commands);
 }
 
 /*
@@ -2131,6 +2146,15 @@ sctp_disposition_t sctp_sf_shutdown_sent_abort(const struct sctp_endpoint *ep,
 	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_abort_chunk_t)))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
 
+	/* ADD-IP: Special case for ABORT chunks
+	 * F4)  One special consideration is that ABORT Chunks arriving
+	 * destined to the IP address being deleted MUST be
+	 * ignored (see Section 5.3.1 for further details).
+	 */
+	if (SCTP_ADDR_DEL ==
+		    sctp_bind_addr_state(&asoc->base.bind_addr, &chunk->dest))
+		return sctp_sf_discard_chunk(ep, asoc, type, arg, commands);
+
 	/* Stop the T2-shutdown timer. */
 	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
 			SCTP_TO(SCTP_EVENT_TIMEOUT_T2_SHUTDOWN));
@@ -2139,7 +2163,7 @@ sctp_disposition_t sctp_sf_shutdown_sent_abort(const struct sctp_endpoint *ep,
 	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
 			SCTP_TO(SCTP_EVENT_TIMEOUT_T5_SHUTDOWN_GUARD));
 
-	return sctp_sf_do_9_1_abort(ep, asoc, type, arg, commands);
+	return __sctp_sf_do_9_1_abort(ep, asoc, type, arg, commands);
 }
 
 /*
@@ -2366,8 +2390,6 @@ sctp_disposition_t sctp_sf_do_9_1_abort(const struct sctp_endpoint *ep,
 					sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
-	unsigned len;
-	__be16 error = SCTP_ERROR_NO_ERROR;
 
 	if (!sctp_vtag_verify_either(chunk, asoc))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
@@ -2385,6 +2407,28 @@ sctp_disposition_t sctp_sf_do_9_1_abort(const struct sctp_endpoint *ep,
 	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_abort_chunk_t)))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
 
+	/* ADD-IP: Special case for ABORT chunks
+	 * F4)  One special consideration is that ABORT Chunks arriving
+	 * destined to the IP address being deleted MUST be
+	 * ignored (see Section 5.3.1 for further details).
+	 */
+	if (SCTP_ADDR_DEL ==
+		    sctp_bind_addr_state(&asoc->base.bind_addr, &chunk->dest))
+		return sctp_sf_discard_chunk(ep, asoc, type, arg, commands);
+
+	return __sctp_sf_do_9_1_abort(ep, asoc, type, arg, commands);
+}
+
+static sctp_disposition_t __sctp_sf_do_9_1_abort(const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const sctp_subtype_t type,
+					void *arg,
+					sctp_cmd_seq_t *commands)
+{
+	struct sctp_chunk *chunk = arg;
+	unsigned len;
+	__be16 error = SCTP_ERROR_NO_ERROR;
+
 	/* See if we have an error cause code in the chunk.  */
 	len = ntohs(chunk->chunk_hdr->length);
 	if (len >= sizeof(struct sctp_chunkhdr) + sizeof(struct sctp_errhdr))
-- 
1.5.3.5

