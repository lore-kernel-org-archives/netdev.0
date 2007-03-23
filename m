From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 5/6] [SCTP] Implement sac_info field in SCTP_ASSOC_CHANGE notification.
Date: Fri, 23 Mar 2007 09:52:51 -0400
Message-ID: <11746579732849-git-send-email-vladislav.yasevich@hp.com>
References: <1174657972645-git-send-email-vladislav.yasevich@hp.com>
Cc: sri@us.ibm.com, lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:49225 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422909AbXCWNw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 09:52:56 -0400
In-Reply-To: <1174657972645-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As stated in the sctp socket api draft:

   sac_info: variable

   If the sac_state is SCTP_COMM_LOST and an ABORT chunk was received
   for this association, sac_info[] contains the complete ABORT chunk as
   defined in the SCTP specification RFC2960 [RFC2960] section 3.3.7.

We now save received ABORT chunks into the sac_info field and pass that
to the user.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/ulpevent.h |    1 +
 include/net/sctp/user.h     |    1 +
 net/sctp/sm_sideeffect.c    |   11 +++++++--
 net/sctp/sm_statefuns.c     |   14 ++++++------
 net/sctp/ulpevent.c         |   49 ++++++++++++++++++++++++++++++++++++------
 5 files changed, 59 insertions(+), 17 deletions(-)

diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index 2923e3d..de88ed5 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -89,6 +89,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_assoc_change(
 	__u16 error,
 	__u16 outbound,
 	__u16 inbound,
+	struct sctp_chunk *chunk,
 	gfp_t gfp);
 
 struct sctp_ulpevent *sctp_ulpevent_make_peer_addr_change(
diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 80b7afe..1b3153c 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -217,6 +217,7 @@ struct sctp_assoc_change {
 	__u16 sac_outbound_streams;
 	__u16 sac_inbound_streams;
 	sctp_assoc_t sac_assoc_id;
+	__u8 sac_info[0];
 };
 
 /*
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 1355674..0a1a197 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -464,7 +464,7 @@ static void sctp_cmd_init_failed(sctp_cmd_seq_t *commands,
 	struct sctp_ulpevent *event;
 
 	event = sctp_ulpevent_make_assoc_change(asoc,0, SCTP_CANT_STR_ASSOC,
-						(__u16)error, 0, 0,
+						(__u16)error, 0, 0, NULL,
 						GFP_ATOMIC);
 
 	if (event)
@@ -492,8 +492,13 @@ static void sctp_cmd_assoc_failed(sctp_cmd_seq_t *commands,
 	/* Cancel any partial delivery in progress. */
 	sctp_ulpq_abort_pd(&asoc->ulpq, GFP_ATOMIC);
 
-	event = sctp_ulpevent_make_assoc_change(asoc, 0, SCTP_COMM_LOST,
-						(__u16)error, 0, 0,
+	if (event_type == SCTP_EVENT_T_CHUNK && subtype.chunk == SCTP_CID_ABORT)
+		event = sctp_ulpevent_make_assoc_change(asoc, 0, SCTP_COMM_LOST,
+						(__u16)error, 0, 0, chunk,
+						GFP_ATOMIC);
+	else
+		event = sctp_ulpevent_make_assoc_change(asoc, 0, SCTP_COMM_LOST,
+						(__u16)error, 0, 0, NULL,
 						GFP_ATOMIC);
 	if (event)
 		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index c85b517..cceaf90 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -186,7 +186,7 @@ sctp_disposition_t sctp_sf_do_4_C(const struct sctp_endpoint *ep,
 	 * notification is passed to the upper layer.
 	 */
 	ev = sctp_ulpevent_make_assoc_change(asoc, 0, SCTP_SHUTDOWN_COMP,
-					     0, 0, 0, GFP_ATOMIC);
+					     0, 0, 0, NULL, GFP_ATOMIC);
 	if (ev)
 		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
 				SCTP_ULPEVENT(ev));
@@ -661,7 +661,7 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(const struct sctp_endpoint *ep,
 	ev = sctp_ulpevent_make_assoc_change(new_asoc, 0, SCTP_COMM_UP, 0,
 					     new_asoc->c.sinit_num_ostreams,
 					     new_asoc->c.sinit_max_instreams,
-					     GFP_ATOMIC);
+					     NULL, GFP_ATOMIC);
 	if (!ev)
 		goto nomem_ev;
 
@@ -790,7 +790,7 @@ sctp_disposition_t sctp_sf_do_5_1E_ca(const struct sctp_endpoint *ep,
 	ev = sctp_ulpevent_make_assoc_change(asoc, 0, SCTP_COMM_UP,
 					     0, asoc->c.sinit_num_ostreams,
 					     asoc->c.sinit_max_instreams,
-					     GFP_ATOMIC);
+					     NULL, GFP_ATOMIC);
 
 	if (!ev)
 		goto nomem;
@@ -1625,7 +1625,7 @@ static sctp_disposition_t sctp_sf_do_dupcook_a(const struct sctp_endpoint *ep,
 	ev = sctp_ulpevent_make_assoc_change(asoc, 0, SCTP_RESTART, 0,
 					     new_asoc->c.sinit_num_ostreams,
 					     new_asoc->c.sinit_max_instreams,
-					     GFP_ATOMIC);
+					     NULL, GFP_ATOMIC);
 	if (!ev)
 		goto nomem_ev;
 
@@ -1691,7 +1691,7 @@ static sctp_disposition_t sctp_sf_do_dupcook_b(const struct sctp_endpoint *ep,
 	ev = sctp_ulpevent_make_assoc_change(asoc, 0, SCTP_COMM_UP, 0,
 					     new_asoc->c.sinit_num_ostreams,
 					     new_asoc->c.sinit_max_instreams,
-					     GFP_ATOMIC);
+					     NULL, GFP_ATOMIC);
 	if (!ev)
 		goto nomem_ev;
 
@@ -1786,7 +1786,7 @@ static sctp_disposition_t sctp_sf_do_dupcook_d(const struct sctp_endpoint *ep,
 					     SCTP_COMM_UP, 0,
 					     asoc->c.sinit_num_ostreams,
 					     asoc->c.sinit_max_instreams,
-					     GFP_ATOMIC);
+                                             NULL, GFP_ATOMIC);
 		if (!ev)
 			goto nomem;
 
@@ -3035,7 +3035,7 @@ sctp_disposition_t sctp_sf_do_9_2_final(const struct sctp_endpoint *ep,
 	 * notification is passed to the upper layer.
 	 */
 	ev = sctp_ulpevent_make_assoc_change(asoc, 0, SCTP_SHUTDOWN_COMP,
-					     0, 0, 0, GFP_ATOMIC);
+					     0, 0, 0, NULL, GFP_ATOMIC);
 	if (!ev)
 		goto nomem;
 
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 2e11bc8..d1a0e67 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -131,19 +131,54 @@ static inline void sctp_ulpevent_release_owner(struct sctp_ulpevent *event)
 struct sctp_ulpevent  *sctp_ulpevent_make_assoc_change(
 	const struct sctp_association *asoc,
 	__u16 flags, __u16 state, __u16 error, __u16 outbound,
-	__u16 inbound, gfp_t gfp)
+	__u16 inbound, struct sctp_chunk *chunk, gfp_t gfp)
 {
 	struct sctp_ulpevent *event;
 	struct sctp_assoc_change *sac;
 	struct sk_buff *skb;
 
-	event = sctp_ulpevent_new(sizeof(struct sctp_assoc_change),
+	/* If the lower layer passed in the chunk, it will be
+	 * an ABORT, so we need to include it in the sac_info.
+	 */
+	if (chunk) {
+		/* sctp_inqu_pop() has allready pulled off the chunk
+		 * header.  We need to put it back temporarily
+		 */
+		skb_push(chunk->skb, sizeof(sctp_chunkhdr_t));
+
+		/* Copy the chunk data to a new skb and reserve enough
+		 * head room to use as notification.
+		 */
+		skb = skb_copy_expand(chunk->skb,
+				      sizeof(struct sctp_assoc_change), 0, gfp);
+
+		if (!skb)
+		    	goto fail;
+
+		/* put back the chunk header now that we have a copy */
+		skb_pull(chunk->skb, sizeof(sctp_chunkhdr_t));
+
+		/* Embed the event fields inside the cloned skb.  */
+		event = sctp_skb2event(skb);
+		sctp_ulpevent_init(event, MSG_NOTIFICATION, skb->truesize);
+
+		/* Include the notification structure */
+		sac = (struct sctp_assoc_change *)
+			skb_push(skb, sizeof(struct sctp_assoc_change));
+
+		/* Trim the buffer to the right length.  */
+		skb_trim(skb, sizeof(struct sctp_assoc_change) +
+			 ntohs(chunk->chunk_hdr->length));
+	} else {
+		event = sctp_ulpevent_new(sizeof(struct sctp_assoc_change),
 				  MSG_NOTIFICATION, gfp);
-	if (!event)
-		goto fail;
-	skb = sctp_event2skb(event);
-	sac = (struct sctp_assoc_change *)
-		skb_put(skb, sizeof(struct sctp_assoc_change));
+		if (!event)
+			goto fail;
+
+		skb = sctp_event2skb(event);
+		sac = (struct sctp_assoc_change *) skb_put(skb,
+					sizeof(struct sctp_assoc_change));
+	}
 
 	/* Socket Extensions for SCTP
 	 * 5.3.1.1 SCTP_ASSOC_CHANGE
-- 
1.5.0.3.438.gc49b2

