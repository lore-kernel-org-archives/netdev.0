From: "Lee A. Roberts" <lee.roberts@hp.com>
Subject: [PATCH v2 1/4] sctp: fix association hangs due to off-by-one errors in sctp_tsnmap_grow()
Date: Wed, 27 Feb 2013 11:54:30 -0700
Message-ID: <1361991273-30578-2-git-send-email-lee.roberts@hp.com>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
Cc: lee.roberts@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:19829 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760738Ab3B0Sxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 13:53:45 -0500
Received: from g5t0030.atlanta.hp.com (g5t0030.atlanta.hp.com [16.228.8.142])
	by g5t0009.atlanta.hp.com (Postfix) with ESMTP id 65E0B30BFE
	for <netdev@vger.kernel.org>; Wed, 27 Feb 2013 18:53:44 +0000 (UTC)
In-Reply-To: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Lee A. Roberts" <lee.roberts@hp.com>

Resolve SCTP association hangs observed during SCTP stress
testing.  Observable symptoms include communications hangs
with data being held in the association lobby (ordering)
queue.  Close examination of reassembly/ordering queues shows
duplicated packets.

In sctp_tsnmap_mark(), correct off-by-one error when calculating
size value for sctp_tsnmap_grow().

In sctp_tsnmap_grow(), correct off-by-one error when copying
and resizing the tsnmap.  If max_tsn_seen is in the LSB of the
word, this bit can be lost, causing the corresponding packet
to be transmitted again and to be entered as a duplicate into
the SCTP reassembly/ordering queues.  Change parameter name
from "gap" (zero-based index) to "size" (one-based) to enhance
code readability.

Signed-off-by: Lee A. Roberts <lee.roberts@hp.com>
---
 net/sctp/tsnmap.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/sctp/tsnmap.c b/net/sctp/tsnmap.c
index 5f25e0c..396c451 100644
--- a/net/sctp/tsnmap.c
+++ b/net/sctp/tsnmap.c
@@ -51,7 +51,7 @@
 static void sctp_tsnmap_update(struct sctp_tsnmap *map);
 static void sctp_tsnmap_find_gap_ack(unsigned long *map, __u16 off,
 				     __u16 len, __u16 *start, __u16 *end);
-static int sctp_tsnmap_grow(struct sctp_tsnmap *map, u16 gap);
+static int sctp_tsnmap_grow(struct sctp_tsnmap *map, u16 size);
 
 /* Initialize a block of memory as a tsnmap.  */
 struct sctp_tsnmap *sctp_tsnmap_init(struct sctp_tsnmap *map, __u16 len,
@@ -124,7 +124,7 @@ int sctp_tsnmap_mark(struct sctp_tsnmap *map, __u32 tsn,
 
 	gap = tsn - map->base_tsn;
 
-	if (gap >= map->len && !sctp_tsnmap_grow(map, gap))
+	if (gap >= map->len && !sctp_tsnmap_grow(map, gap + 1))
 		return -ENOMEM;
 
 	if (!sctp_tsnmap_has_gap(map) && gap == 0) {
@@ -360,23 +360,24 @@ __u16 sctp_tsnmap_num_gabs(struct sctp_tsnmap *map,
 	return ngaps;
 }
 
-static int sctp_tsnmap_grow(struct sctp_tsnmap *map, u16 gap)
+static int sctp_tsnmap_grow(struct sctp_tsnmap *map, u16 size)
 {
 	unsigned long *new;
 	unsigned long inc;
 	u16  len;
 
-	if (gap >= SCTP_TSN_MAP_SIZE)
+	if (size > SCTP_TSN_MAP_SIZE)
 		return 0;
 
-	inc = ALIGN((gap - map->len),BITS_PER_LONG) + SCTP_TSN_MAP_INCREMENT;
+	inc = ALIGN((size - map->len), BITS_PER_LONG) + SCTP_TSN_MAP_INCREMENT;
 	len = min_t(u16, map->len + inc, SCTP_TSN_MAP_SIZE);
 
 	new = kzalloc(len>>3, GFP_ATOMIC);
 	if (!new)
 		return 0;
 
-	bitmap_copy(new, map->tsn_map, map->max_tsn_seen - map->base_tsn);
+	bitmap_copy(new, map->tsn_map,
+		map->max_tsn_seen - map->cumulative_tsn_ack_point);
 	kfree(map->tsn_map);
 	map->tsn_map = new;
 	map->len = len;
-- 
1.7.9.5
