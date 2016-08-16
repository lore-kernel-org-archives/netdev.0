From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net] sctp: linearize early if it's not GSO
Date: Tue, 16 Aug 2016 19:35:33 -0300
Message-ID: <a4bc263e62ced9f5790932f11e7d829c36566808.1471386679.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42660 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753566AbcHPWf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 18:35:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because otherwise when crc computation is still needed it's way more
expensive than on a linear buffer to the point that it affects
performance.

It's so expensive that netperf test gives a perf output as below:

Overhead  Shared Object        Symbol
  69,44%  [kernel]             [k] gf2_matrix_square
   2,84%  [kernel]             [k] crc32_generic_combine.part.0
   2,78%  [kernel]             [k] _raw_spin_lock_bh

And performance goes from 2Gbit/s to 0.5Gbit/s on this test. Doing the
linearization before checksumming is enough to restore it.

Fixes: 3acb50c18d8d ("sctp: delay as much as possible skb_linearize")
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---

Please consider this to -stable too as v4.7 performance is affected.
Thanks

 net/sctp/input.c   | 11 +++++++----
 net/sctp/inqueue.c | 13 -------------
 2 files changed, 7 insertions(+), 17 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index c182db7d691ff44a52923fb36c9170e49c141c04..69444d32ecda6cd1a4924911172feba89c5ae976 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -119,7 +119,13 @@ int sctp_rcv(struct sk_buff *skb)
 		       skb_transport_offset(skb))
 		goto discard_it;
 
-	if (!pskb_may_pull(skb, sizeof(struct sctphdr)))
+	/* If the packet is fragmented and we need to do crc checking,
+	 * it's better to just linearize it otherwise crc computing
+	 * takes longer.
+	 */
+	if ((!(skb_shinfo(skb)->gso_type & SKB_GSO_SCTP) &&
+	     skb_linearize(skb)) ||
+	    !pskb_may_pull(skb, sizeof(struct sctphdr)))
 		goto discard_it;
 
 	/* Pull up the IP header. */
@@ -1177,9 +1183,6 @@ static struct sctp_association *__sctp_rcv_lookup_harder(struct net *net,
 	if ((skb_shinfo(skb)->gso_type & SKB_GSO_SCTP) == SKB_GSO_SCTP)
 		return NULL;
 
-	if (skb_linearize(skb))
-		return NULL;
-
 	ch = (sctp_chunkhdr_t *) skb->data;
 
 	/* The code below will attempt to walk the chunk and extract
diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
index c30ddb0f31907f57c5ce85b00dbe04260ca1cb2e..6437aa97cfd79f14c633499c2b131389204c435b 100644
--- a/net/sctp/inqueue.c
+++ b/net/sctp/inqueue.c
@@ -170,19 +170,6 @@ next_chunk:
 
 		chunk = list_entry(entry, struct sctp_chunk, list);
 
-		/* Linearize if it's not GSO */
-		if ((skb_shinfo(chunk->skb)->gso_type & SKB_GSO_SCTP) != SKB_GSO_SCTP &&
-		    skb_is_nonlinear(chunk->skb)) {
-			if (skb_linearize(chunk->skb)) {
-				__SCTP_INC_STATS(dev_net(chunk->skb->dev), SCTP_MIB_IN_PKT_DISCARDS);
-				sctp_chunk_free(chunk);
-				goto next_chunk;
-			}
-
-			/* Update sctp_hdr as it probably changed */
-			chunk->sctp_hdr = sctp_hdr(chunk->skb);
-		}
-
 		if ((skb_shinfo(chunk->skb)->gso_type & SKB_GSO_SCTP) == SKB_GSO_SCTP) {
 			/* GSO-marked skbs but without frags, handle
 			 * them normally
-- 
2.7.4
