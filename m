From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next 4/6] sctp: avoid identifying address family many times for a chunk
Date: Wed, 13 Jul 2016 15:08:58 -0300
Message-ID: <fbb12a05b430078b0b53ff33ed4a5a557edd3fb6.1468432819.git.marcelo.leitner@gmail.com>
References: <cover.1468432819.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53277 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752339AbcGMSJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 14:09:52 -0400
In-Reply-To: <cover.1468432819.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Identifying address family operations during rx path is not something
expensive but it's ugly to the eye to have it done multiple times,
specially when we already validated it during initial rx processing.

This patch takes advantage of the now shared sctp_input_cb and make the
pointer to the operations readily available.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/sctp/structs.h |  1 +
 net/sctp/input.c           |  1 +
 net/sctp/inqueue.c         |  1 +
 net/sctp/sm_make_chunk.c   | 20 ++++----------------
 net/sctp/sm_statefuns.c    |  7 ++-----
 5 files changed, 9 insertions(+), 21 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index f6f201de6fa46b3ca203c00f4970ca408edb6930..ce93c4b10d2620a3ac4c9efe39a86e5d231b51c2 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1104,6 +1104,7 @@ struct sctp_input_cb {
 #endif
 	} header;
 	struct sctp_chunk *chunk;
+	struct sctp_af *af;
 };
 #define SCTP_INPUT_CB(__skb)	((struct sctp_input_cb *)&((__skb)->cb[0]))
 
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 7a327ff71f08985f6ebb963d5cdc9540b23d0666..30d72f7707b6df5b41679bbfc5e595d5a11130ea 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -140,6 +140,7 @@ int sctp_rcv(struct sk_buff *skb)
 	af = sctp_get_af_specific(family);
 	if (unlikely(!af))
 		goto discard_it;
+	SCTP_INPUT_CB(skb)->af = af;
 
 	/* Initialize local addresses for lookups. */
 	af->from_skb(&src, skb, 1);
diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
index 147d975b04559f7858b040b1f04dbc559ef2ec78..8fc773f9b59a8a9ad123dd132cfa5b7f916732b6 100644
--- a/net/sctp/inqueue.c
+++ b/net/sctp/inqueue.c
@@ -224,6 +224,7 @@ new_skb:
 				*head_cb = SCTP_INPUT_CB(chunk->head_skb);
 
 			cb->chunk = head_cb->chunk;
+			cb->af = head_cb->af;
 		}
 	}
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 1c96f4740e67397e5f8b7134cffd4d0840220245..8c77b87a8565cb4f82c09cea65557dc9c8d1138f 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -108,14 +108,9 @@ static void sctp_control_set_owner_w(struct sctp_chunk *chunk)
 /* What was the inbound interface for this chunk? */
 int sctp_chunk_iif(const struct sctp_chunk *chunk)
 {
-	struct sctp_af *af;
-	int iif = 0;
-
-	af = sctp_get_af_specific(ipver2af(ip_hdr(chunk->skb)->version));
-	if (af)
-		iif = af->skb_iif(chunk->skb);
+	struct sk_buff *skb = chunk->skb;
 
-	return iif;
+	return SCTP_INPUT_CB(skb)->af->skb_iif(skb);
 }
 
 /* RFC 2960 3.3.2 Initiation (INIT) (1)
@@ -1600,7 +1595,6 @@ struct sctp_association *sctp_make_temp_asoc(const struct sctp_endpoint *ep,
 	struct sctp_association *asoc;
 	struct sk_buff *skb;
 	sctp_scope_t scope;
-	struct sctp_af *af;
 
 	/* Create the bare association.  */
 	scope = sctp_scope(sctp_source(chunk));
@@ -1610,16 +1604,10 @@ struct sctp_association *sctp_make_temp_asoc(const struct sctp_endpoint *ep,
 	asoc->temp = 1;
 	skb = chunk->skb;
 	/* Create an entry for the source address of the packet.  */
-	af = sctp_get_af_specific(ipver2af(ip_hdr(skb)->version));
-	if (unlikely(!af))
-		goto fail;
-	af->from_skb(&asoc->c.peer_addr, skb, 1);
+	SCTP_INPUT_CB(skb)->af->from_skb(&asoc->c.peer_addr, skb, 1);
+
 nodata:
 	return asoc;
-
-fail:
-	sctp_association_free(asoc);
-	return NULL;
 }
 
 /* Build a cookie representing asoc.
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 5aabf42065e2fba9388350996310b77c58369395..b7c1f7f3c8388400e51e3fbdbe099bc354559913 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -6119,13 +6119,10 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 	 */
 
 	if (!chunk->ecn_ce_done) {
-		struct sctp_af *af;
+		struct sctp_af *af = SCTP_INPUT_CB(chunk->skb)->af;
 		chunk->ecn_ce_done = 1;
 
-		af = sctp_get_af_specific(
-			ipver2af(ip_hdr(chunk->skb)->version));
-
-		if (af && af->is_ce(sctp_gso_headskb(chunk->skb)) &&
+		if (af->is_ce(sctp_gso_headskb(chunk->skb)) &&
 		    asoc->peer.ecn_capable) {
 			/* Do real work as sideffect. */
 			sctp_add_cmd_sf(commands, SCTP_CMD_ECN_CE,
-- 
2.7.4
