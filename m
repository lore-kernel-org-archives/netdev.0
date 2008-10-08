From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 2/2] sctp: shrink sctp_tsnmap some more by removing gabs array
Date: Wed,  8 Oct 2008 16:27:50 -0400
Message-ID: <1223497670-519-3-git-send-email-vladislav.yasevich@hp.com>
References: <1223497670-519-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:32675 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561AbYJHU14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 16:27:56 -0400
In-Reply-To: <1223497670-519-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The gabs array in the sctp_tsnmap structure is only used
in one place, sctp_make_sack().  As such, carrying the
array around in the sctp_tsnmap and thus directly in
the sctp_association is rather pointless since most
of the time it's just taking up space.  Now, let
sctp_make_sack create and populate it and then throw
it away when it's done.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/tsnmap.h |   14 +++-----------
 net/sctp/sm_make_chunk.c  |    6 ++++--
 net/sctp/tsnmap.c         |   15 ++++++++-------
 3 files changed, 15 insertions(+), 20 deletions(-)

diff --git a/include/net/sctp/tsnmap.h b/include/net/sctp/tsnmap.h
index 6dabbee..4aabc5a 100644
--- a/include/net/sctp/tsnmap.h
+++ b/include/net/sctp/tsnmap.h
@@ -94,11 +94,8 @@ struct sctp_tsnmap {
 	 * every SACK.  Store up to SCTP_MAX_DUP_TSNS worth of
 	 * information.
 	 */
-	__be32 dup_tsns[SCTP_MAX_DUP_TSNS];
 	__u16 num_dup_tsns;
-
-	/* Record gap ack block information here.  */
-	struct sctp_gap_ack_block gabs[SCTP_MAX_GABS];
+	__be32 dup_tsns[SCTP_MAX_DUP_TSNS];
 };
 
 struct sctp_tsnmap_iter {
@@ -151,17 +148,12 @@ static inline __be32 *sctp_tsnmap_get_dups(struct sctp_tsnmap *map)
 }
 
 /* How many gap ack blocks do we have recorded? */
-__u16 sctp_tsnmap_num_gabs(struct sctp_tsnmap *map);
+__u16 sctp_tsnmap_num_gabs(struct sctp_tsnmap *map,
+			   struct sctp_gap_ack_block *gabs);
 
 /* Refresh the count on pending data. */
 __u16 sctp_tsnmap_pending(struct sctp_tsnmap *map);
 
-/* Return pointer to gap ack blocks as needed by SACK. */
-static inline struct sctp_gap_ack_block *sctp_tsnmap_get_gabs(struct sctp_tsnmap *map)
-{
-	return map->gabs;
-}
-
 /* Is there a gap in the TSN map?  */
 static inline int sctp_tsnmap_has_gap(const struct sctp_tsnmap *map)
 {
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 6dd9b3e..fd8acb4 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -702,12 +702,14 @@ struct sctp_chunk *sctp_make_sack(const struct sctp_association *asoc)
 	__u32 ctsn;
 	__u16 num_gabs, num_dup_tsns;
 	struct sctp_tsnmap *map = (struct sctp_tsnmap *)&asoc->peer.tsn_map;
+	struct sctp_gap_ack_block gabs[SCTP_MAX_GABS];
 
+	memset(gabs, 0, sizeof(gabs));
 	ctsn = sctp_tsnmap_get_ctsn(map);
 	SCTP_DEBUG_PRINTK("sackCTSNAck sent:  0x%x.\n", ctsn);
 
 	/* How much room is needed in the chunk? */
-	num_gabs = sctp_tsnmap_num_gabs(map);
+	num_gabs = sctp_tsnmap_num_gabs(map, gabs);
 	num_dup_tsns = sctp_tsnmap_num_dups(map);
 
 	/* Initialize the SACK header.  */
@@ -763,7 +765,7 @@ struct sctp_chunk *sctp_make_sack(const struct sctp_association *asoc)
 	/* Add the gap ack block information.   */
 	if (num_gabs)
 		sctp_addto_chunk(retval, sizeof(__u32) * num_gabs,
-				 sctp_tsnmap_get_gabs(map));
+				 gabs);
 
 	/* Add the duplicate TSN information.  */
 	if (num_dup_tsns)
diff --git a/net/sctp/tsnmap.c b/net/sctp/tsnmap.c
index 142ed7c..35c73e8 100644
--- a/net/sctp/tsnmap.c
+++ b/net/sctp/tsnmap.c
@@ -335,10 +335,11 @@ void sctp_tsnmap_renege(struct sctp_tsnmap *map, __u32 tsn)
 }
 
 /* How many gap ack blocks do we have recorded? */
-__u16 sctp_tsnmap_num_gabs(struct sctp_tsnmap *map)
+__u16 sctp_tsnmap_num_gabs(struct sctp_tsnmap *map,
+			   struct sctp_gap_ack_block *gabs)
 {
 	struct sctp_tsnmap_iter iter;
-	int gabs = 0;
+	int ngaps = 0;
 
 	/* Refresh the gap ack information. */
 	if (sctp_tsnmap_has_gap(map)) {
@@ -348,14 +349,14 @@ __u16 sctp_tsnmap_num_gabs(struct sctp_tsnmap *map)
 						&start,
 						&end)) {
 
-			map->gabs[gabs].start = htons(start);
-			map->gabs[gabs].end = htons(end);
-			gabs++;
-			if (gabs >= SCTP_MAX_GABS)
+			gabs[ngaps].start = htons(start);
+			gabs[ngaps].end = htons(end);
+			ngaps++;
+			if (ngaps >= SCTP_MAX_GABS)
 				break;
 		}
 	}
-	return gabs;
+	return ngaps;
 }
 
 static int sctp_tsnmap_grow(struct sctp_tsnmap *map, u16 gap)
-- 
1.5.3.5

