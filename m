From: mleitner@redhat.com
Subject: [PATCH] sctp: allow authenticating DATA chunks that are bundled with COOKIE_ECHO
Date: Thu, 11 Jun 2015 14:49:46 -0300
Message-ID: <ca8fca62141ed9e108170919cdc12bdb09cdda73.1434043704.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44536 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754269AbbFKRuD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 13:50:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Currently, we can ask to authenticate DATA chunks and we can send DATA
chunks on the same packet as COOKIE_ECHO, but if you try to combine
both, the DATA chunk will be sent unauthenticated and peer won't accept
it, leading to a communication failure.

This happens because even though the data was queued after it was
requested to authenticate DATA chunks, it was also queued before we
could know that remote peer can handle authenticating, so
sctp_auth_send_cid() returns false.

The fix is whenever we set up an active key, re-check send queue for
chunks that now should be authenticated. As a result, such packet will
now contain COOKIE_ECHO + AUTH + DATA chunks, in that order.

Reported-by: Liu Wei <weliu@redhat.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/auth.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index fb7976aee61c84f38aecdc5c5f0d8be20e577fa9..4f15b7d730e13d6aaa58ba7a28262c9831afea95 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -381,13 +381,14 @@ nomem:
 }
 
 
-/* Public interface to creat the association shared key.
+/* Public interface to create the association shared key.
  * See code above for the algorithm.
  */
 int sctp_auth_asoc_init_active_key(struct sctp_association *asoc, gfp_t gfp)
 {
 	struct sctp_auth_bytes	*secret;
 	struct sctp_shared_key *ep_key;
+	struct sctp_chunk *chunk;
 
 	/* If we don't support AUTH, or peer is not capable
 	 * we don't need to do anything.
@@ -410,6 +411,14 @@ int sctp_auth_asoc_init_active_key(struct sctp_association *asoc, gfp_t gfp)
 	sctp_auth_key_put(asoc->asoc_shared_key);
 	asoc->asoc_shared_key = secret;
 
+	/* Update send queue in case any chunk already in there now
+	 * needs authenticating
+	 */
+	list_for_each_entry(chunk, &asoc->outqueue.out_chunk_list, list) {
+		if (sctp_auth_send_cid(chunk->chunk_hdr->type, asoc))
+			chunk->auth = 1;
+	}
+
 	return 0;
 }
 
-- 
2.4.1
