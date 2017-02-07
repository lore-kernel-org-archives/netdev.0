From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next] sctp: avoid list_del_init if it's freeing the memory right away
Date: Tue,  7 Feb 2017 17:03:21 -0200
Message-ID: <e1b3b9b24f39ee82a3131a39a0413231ba54bc7c.1486494022.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:34640 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754472AbdBGTDc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 14:03:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no reason to use list_del_init() in these places as we are
going to free/destroy the memory in a few lines below.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/associola.c     | 14 ++++----------
 net/sctp/auth.c          |  8 ++------
 net/sctp/chunk.c         |  4 ++--
 net/sctp/outqueue.c      | 14 +++++++-------
 net/sctp/sm_make_chunk.c |  3 +--
 5 files changed, 16 insertions(+), 27 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index e50dc6d7543fd6acfa7442f3a9ee575203c7718d..7eb9dacfa53a438b20a34319cf01c6c9a591f0c3 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1638,25 +1638,19 @@ int sctp_assoc_set_id(struct sctp_association *asoc, gfp_t gfp)
 static void sctp_assoc_free_asconf_queue(struct sctp_association *asoc)
 {
 	struct sctp_chunk *asconf;
-	struct sctp_chunk *tmp;
 
-	list_for_each_entry_safe(asconf, tmp, &asoc->addip_chunk_list, list) {
-		list_del_init(&asconf->list);
+	list_for_each_entry(asconf, &asoc->addip_chunk_list, list)
 		sctp_chunk_free(asconf);
-	}
 }
 
 /* Free asconf_ack cache */
 static void sctp_assoc_free_asconf_acks(struct sctp_association *asoc)
 {
 	struct sctp_chunk *ack;
-	struct sctp_chunk *tmp;
 
-	list_for_each_entry_safe(ack, tmp, &asoc->asconf_ack_list,
-				transmitted_list) {
-		list_del_init(&ack->transmitted_list);
+	list_for_each_entry(ack, &asoc->asconf_ack_list,
+			    transmitted_list)
 		sctp_chunk_free(ack);
-	}
 }
 
 /* Clean up the ASCONF_ACK queue */
@@ -1674,7 +1668,7 @@ void sctp_assoc_clean_asconf_ack_cache(const struct sctp_association *asoc)
 				htonl(asoc->peer.addip_serial))
 			break;
 
-		list_del_init(&ack->transmitted_list);
+		list_del(&ack->transmitted_list);
 		sctp_chunk_free(ack);
 	}
 }
diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index f99d4855d3de34e0f0b1bf027a87dde3ad91a522..3db3c95c5b4c32011864f4862a446fd9aca9680c 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -109,7 +109,6 @@ struct sctp_shared_key *sctp_auth_shkey_create(__u16 key_id, gfp_t gfp)
 /* Free the shared key structure */
 static void sctp_auth_shkey_free(struct sctp_shared_key *sh_key)
 {
-	BUG_ON(!list_empty(&sh_key->key_list));
 	sctp_auth_key_put(sh_key->key);
 	sh_key->key = NULL;
 	kfree(sh_key);
@@ -123,11 +122,8 @@ void sctp_auth_destroy_keys(struct list_head *keys)
 	struct sctp_shared_key *ep_key;
 	struct sctp_shared_key *tmp;
 
-	if (list_empty(keys))
-		return;
-
 	key_for_each_safe(ep_key, tmp, keys) {
-		list_del_init(&ep_key->key_list);
+		list_del(&ep_key->key_list);
 		sctp_auth_shkey_free(ep_key);
 	}
 }
@@ -948,7 +944,7 @@ int sctp_auth_del_key_id(struct sctp_endpoint *ep,
 		return -EINVAL;
 
 	/* Delete the shared key */
-	list_del_init(&key->key_list);
+	list_del(&key->key_list);
 	sctp_auth_shkey_free(key);
 
 	return 0;
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index e3621cb4827fadb5f5cb41ebe8455dfa3300a765..4c05a51dd53435c0c9c000a7d662758d65c05772 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -97,7 +97,7 @@ static void sctp_datamsg_destroy(struct sctp_datamsg *msg)
 
 	/* Release all references. */
 	list_for_each_safe(pos, temp, &msg->chunks) {
-		list_del_init(pos);
+		list_del(pos);
 		chunk = list_entry(pos, struct sctp_chunk, frag_list);
 		/* Check whether we _really_ need to notify. */
 		if (notify < 0) {
@@ -289,7 +289,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 
 errout:
 	list_for_each_safe(pos, temp, &msg->chunks) {
-		list_del_init(pos);
+		list_del(pos);
 		chunk = list_entry(pos, struct sctp_chunk, frag_list);
 		sctp_chunk_free(chunk);
 	}
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 65abe22d869167b13193e8b057572d9d8f84625c..80d2203af69d8711e611d5ea53e2283364019586 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -231,7 +231,7 @@ static void __sctp_outq_teardown(struct sctp_outq *q)
 
 	/* Throw away chunks that have been gap ACKed.  */
 	list_for_each_safe(lchunk, temp, &q->sacked) {
-		list_del_init(lchunk);
+		list_del(lchunk);
 		chunk = list_entry(lchunk, struct sctp_chunk,
 				   transmitted_list);
 		sctp_chunk_fail(chunk, q->error);
@@ -240,7 +240,7 @@ static void __sctp_outq_teardown(struct sctp_outq *q)
 
 	/* Throw away any chunks in the retransmit queue. */
 	list_for_each_safe(lchunk, temp, &q->retransmit) {
-		list_del_init(lchunk);
+		list_del(lchunk);
 		chunk = list_entry(lchunk, struct sctp_chunk,
 				   transmitted_list);
 		sctp_chunk_fail(chunk, q->error);
@@ -249,7 +249,7 @@ static void __sctp_outq_teardown(struct sctp_outq *q)
 
 	/* Throw away any chunks that are in the abandoned queue. */
 	list_for_each_safe(lchunk, temp, &q->abandoned) {
-		list_del_init(lchunk);
+		list_del(lchunk);
 		chunk = list_entry(lchunk, struct sctp_chunk,
 				   transmitted_list);
 		sctp_chunk_fail(chunk, q->error);
@@ -266,7 +266,7 @@ static void __sctp_outq_teardown(struct sctp_outq *q)
 
 	/* Throw away any leftover control chunks. */
 	list_for_each_entry_safe(chunk, tmp, &q->control_chunk_list, list) {
-		list_del_init(&chunk->list);
+		list_del(&chunk->list);
 		sctp_chunk_free(chunk);
 	}
 }
@@ -392,7 +392,7 @@ static int sctp_prsctp_prune_unsent(struct sctp_association *asoc,
 		    chk->sinfo.sinfo_timetolive <= sinfo->sinfo_timetolive)
 			continue;
 
-		list_del_init(&chk->list);
+		list_del(&chk->list);
 		asoc->sent_cnt_removable--;
 		asoc->abandoned_unsent[SCTP_PR_INDEX(PRIO)]++;
 
@@ -1329,7 +1329,7 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_chunk *chunk)
 				    transmitted_list);
 		tsn = ntohl(tchunk->subh.data_hdr->tsn);
 		if (TSN_lte(tsn, ctsn)) {
-			list_del_init(&tchunk->transmitted_list);
+			list_del(&tchunk->transmitted_list);
 			if (asoc->peer.prsctp_capable &&
 			    SCTP_PR_PRIO_ENABLED(chunk->sinfo.sinfo_flags))
 				asoc->sent_cnt_removable--;
@@ -1828,7 +1828,7 @@ static void sctp_generate_fwdtsn(struct sctp_outq *q, __u32 ctsn)
 		 * the ctsn.
 		 */
 		if (TSN_lte(tsn, ctsn)) {
-			list_del_init(lchunk);
+			list_del(lchunk);
 			sctp_chunk_free(chunk);
 		} else {
 			if (TSN_lte(tsn, asoc->adv_peer_ack_point+1)) {
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index ad3445b3408eac9791ee5645b55da68ee14e20b1..d984d88f1f283bdc6f259a115739e19a24eee396 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1437,7 +1437,6 @@ static struct sctp_chunk *sctp_make_control(const struct sctp_association *asoc,
 static void sctp_chunk_destroy(struct sctp_chunk *chunk)
 {
 	BUG_ON(!list_empty(&chunk->list));
-	list_del_init(&chunk->transmitted_list);
 
 	consume_skb(chunk->skb);
 	consume_skb(chunk->auth_chunk);
@@ -3505,7 +3504,7 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
 	}
 
 	/* Free the cached last sent asconf chunk. */
-	list_del_init(&asconf->transmitted_list);
+	list_del(&asconf->transmitted_list);
 	sctp_chunk_free(asconf);
 	asoc->addip_last_asconf = NULL;
 
-- 
2.9.3
