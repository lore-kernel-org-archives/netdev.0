From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 7/9] sctp: fix to check the source address of
 COOKIE-ECHO chunk
Date: Wed, 20 Apr 2011 15:30:51 +0800
Message-ID: <4DAE8BAB.6010607@cn.fujitsu.com>
References: <4DAE8A27.3040007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62124 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752924Ab1DTHas (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 03:30:48 -0400
In-Reply-To: <4DAE8A27.3040007@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP does not check whether the source address of COOKIE-ECHO
chunk is the original address of INIT chunk or part of the any
address parameters saved in COOKIE in CLOSED state. So even if
the COOKIE-ECHO chunk is from any address but with correct COOKIE,
the COOKIE-ECHO chunk still be accepted. If the COOKIE is not from
a valid address, the assoc should not be established.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |    2 +-
 net/sctp/sm_make_chunk.c   |   26 +++++++++++++++++++++-----
 net/sctp/sm_sideeffect.c   |    3 +--
 net/sctp/sm_statefuns.c    |   14 +++++---------
 4 files changed, 28 insertions(+), 17 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 0f6e60a..5c9bada 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1400,7 +1400,7 @@ int sctp_has_association(const union sctp_addr *laddr,
 int sctp_verify_init(const struct sctp_association *asoc, sctp_cid_t,
 		     sctp_init_chunk_t *peer_init, struct sctp_chunk *chunk,
 		     struct sctp_chunk **err_chunk);
-int sctp_process_init(struct sctp_association *, sctp_cid_t cid,
+int sctp_process_init(struct sctp_association *, struct sctp_chunk *chunk,
 		      const union sctp_addr *peer,
 		      sctp_init_chunk_t *init, gfp_t gfp);
 __u32 sctp_generate_tag(const struct sctp_endpoint *);
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index f87ccb1..a7b65e9 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2242,14 +2242,17 @@ int sctp_verify_init(const struct sctp_association *asoc,
  * Returns 0 on failure, else success.
  * FIXME:  This is an association method.
  */
-int sctp_process_init(struct sctp_association *asoc, sctp_cid_t cid,
+int sctp_process_init(struct sctp_association *asoc, struct sctp_chunk *chunk,
 		      const union sctp_addr *peer_addr,
 		      sctp_init_chunk_t *peer_init, gfp_t gfp)
 {
 	union sctp_params param;
 	struct sctp_transport *transport;
 	struct list_head *pos, *temp;
+	struct sctp_af *af;
+	union sctp_addr addr;
 	char *cookie;
+	int src_match = 0;
 
 	/* We must include the address that the INIT packet came from.
 	 * This is the only address that matters for an INIT packet.
@@ -2261,18 +2264,31 @@ int sctp_process_init(struct sctp_association *asoc, sctp_cid_t cid,
 	 * added as the primary transport.  The source address seems to
 	 * be a a better choice than any of the embedded addresses.
 	 */
-	if (peer_addr) {
-		if(!sctp_assoc_add_peer(asoc, peer_addr, gfp, SCTP_ACTIVE))
-			goto nomem;
-	}
+	if(!sctp_assoc_add_peer(asoc, peer_addr, gfp, SCTP_ACTIVE))
+		goto nomem;
+
+	if (sctp_cmp_addr_exact(sctp_source(chunk), peer_addr))
+		src_match = 1;
 
 	/* Process the initialization parameters.  */
 	sctp_walk_params(param, peer_init, init_hdr.params) {
+		if (!src_match && (param.p->type == SCTP_PARAM_IPV4_ADDRESS ||
+		    param.p->type == SCTP_PARAM_IPV6_ADDRESS)) {
+			af = sctp_get_af_specific(param_type2af(param.p->type));
+			af->from_addr_param(&addr, param.addr,
+					    chunk->sctp_hdr->source, 0);
+			if (sctp_cmp_addr_exact(sctp_source(chunk), &addr))
+				src_match = 1;
+		}
 
 		if (!sctp_process_param(asoc, param, peer_addr, gfp))
 			goto clean_up;
 	}
 
+	/* source address of chunk may not match any valid address */
+	if (!src_match)
+		goto clean_up;
+
 	/* AUTH: After processing the parameters, make sure that we
 	 * have all the required info to potentially do authentications.
 	 */
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 3b80fe2..d612ca1 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -595,8 +595,7 @@ static int sctp_cmd_process_init(sctp_cmd_seq_t *commands,
 	 * fail during INIT processing (due to malloc problems),
 	 * just return the error and stop processing the stack.
 	 */
-	if (!sctp_process_init(asoc, chunk->chunk_hdr->type,
-			       sctp_source(chunk), peer_init, gfp))
+	if (!sctp_process_init(asoc, chunk, sctp_source(chunk), peer_init, gfp))
 		error = -ENOMEM;
 	else
 		error = 0;
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index ad3b43b..ab94932 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -393,8 +393,7 @@ sctp_disposition_t sctp_sf_do_5_1B_init(const struct sctp_endpoint *ep,
 		goto nomem_init;
 
 	/* The call, sctp_process_init(), can fail on memory allocation.  */
-	if (!sctp_process_init(new_asoc, chunk->chunk_hdr->type,
-			       sctp_source(chunk),
+	if (!sctp_process_init(new_asoc, chunk, sctp_source(chunk),
 			       (sctp_init_chunk_t *)chunk->chunk_hdr,
 			       GFP_ATOMIC))
 		goto nomem_init;
@@ -725,7 +724,7 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(const struct sctp_endpoint *ep,
 	 */
 	peer_init = &chunk->subh.cookie_hdr->c.peer_init[0];
 
-	if (!sctp_process_init(new_asoc, chunk->chunk_hdr->type,
+	if (!sctp_process_init(new_asoc, chunk,
 			       &chunk->subh.cookie_hdr->c.peer_addr,
 			       peer_init, GFP_ATOMIC))
 		goto nomem_init;
@@ -1464,8 +1463,7 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 	 * Verification Tag and Peers Verification tag into a reserved
 	 * place (local tie-tag and per tie-tag) within the state cookie.
 	 */
-	if (!sctp_process_init(new_asoc, chunk->chunk_hdr->type,
-			       sctp_source(chunk),
+	if (!sctp_process_init(new_asoc, chunk, sctp_source(chunk),
 			       (sctp_init_chunk_t *)chunk->chunk_hdr,
 			       GFP_ATOMIC))
 		goto nomem;
@@ -1694,8 +1692,7 @@ static sctp_disposition_t sctp_sf_do_dupcook_a(const struct sctp_endpoint *ep,
 	 */
 	peer_init = &chunk->subh.cookie_hdr->c.peer_init[0];
 
-	if (!sctp_process_init(new_asoc, chunk->chunk_hdr->type,
-			       sctp_source(chunk), peer_init,
+	if (!sctp_process_init(new_asoc, chunk, sctp_source(chunk), peer_init,
 			       GFP_ATOMIC))
 		goto nomem;
 
@@ -1780,8 +1777,7 @@ static sctp_disposition_t sctp_sf_do_dupcook_b(const struct sctp_endpoint *ep,
 	 * side effects--it is safe to run them here.
 	 */
 	peer_init = &chunk->subh.cookie_hdr->c.peer_init[0];
-	if (!sctp_process_init(new_asoc, chunk->chunk_hdr->type,
-			       sctp_source(chunk), peer_init,
+	if (!sctp_process_init(new_asoc, chunk, sctp_source(chunk), peer_init,
 			       GFP_ATOMIC))
 		goto nomem;
 
-- 
1.6.5.2


