From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH] sctp: fix panic when sending auth chunks
Date: Thu,  7 Jul 2016 09:39:29 -0300
Message-ID: <433dedb6a14cd5bd59ad2f82579d872b97171727.1467894889.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39936 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750968AbcGGMkG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2016 08:40:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we introduced GSO support, if using auth the auth chunk was being
left queued on the packet even after the final segment was generated.
Later on sctp_transmit_packet it calls sctp_packet_reset, which zeroed
the packet len while not accounting for this left-over. This caused more
space to be used the next packet due to the chunk still being queued,
but space which wasn't allocated as its size wasn't accounted.

The fix is to only queue it back when we know that we are going to
generate another segment.

Fixes: 90017accff61 ("sctp: Add GSO support")
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/output.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 1541a91d6d9de13927951a6215c423ea0ffa13dc..2e9223bb1b3a47386e8164a5a63400899fbf301f 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -582,9 +582,7 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 			 */
 			pkt_size -= WORD_ROUND(chunk->skb->len);
 
-			if (chunk == packet->auth && !list_empty(&packet->chunk_list))
-				list_add(&chunk->list, &packet->chunk_list);
-			else if (!sctp_chunk_is_data(chunk))
+			if (!sctp_chunk_is_data(chunk) && chunk != packet->auth)
 				sctp_chunk_free(chunk);
 
 			if (!pkt_size)
@@ -605,6 +603,18 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 						 (struct sctp_auth_chunk *)auth,
 						 gfp);
 
+		if (packet->auth) {
+			if (!list_empty(&packet->chunk_list)) {
+				/* We will generate more packets, so re-queue
+				 * auth chunk.
+				 */
+				list_add(&chunk->list, &packet->chunk_list);
+			} else {
+				sctp_chunk_free(packet->auth);
+				packet->auth = NULL;
+			}
+		}
+
 		if (!gso)
 			break;
 
@@ -735,6 +745,8 @@ err:
 	}
 	goto out;
 nomem:
+	if (packet->auth && list_empty(&packet->auth->list))
+		sctp_chunk_free(packet->auth);
 	err = -ENOMEM;
 	goto err;
 }
-- 
2.7.4
