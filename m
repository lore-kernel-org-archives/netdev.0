From: "Roberts, Lee A." <lee.roberts@hp.com>
Subject: [PATCH 1/4 v2] sctp: fix association hangs due to off-by-one errors
 in sctp_tsnmap_grow()
Date: Thu, 21 Feb 2013 17:57:46 +0000
Message-ID: <D64EC45690EF85409BA6C4730E0162244310DF62@G4W3231.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lee A. Roberts <lee.roberts@hp.com>

Resolve SCTP association hangs observed during SCTP stress
testing.  Observable symptoms include communications hangs
with data being held in the association lobby (ordering)
queue.  Close examination of reassembly/ordering queues shows
duplicated packets.

In sctp_tsnmap_mark(), correct off-by-one error when calculating
gap value for tsnmap.

In sctp_tsnmap_grow(), correct off-by-one error when copying
and resizing the tsnmap.  If max_tsn_seen is in the LSB of the
word, this bit can be lost, causing the corresponding packet
to be transmitted again and to be entered as a duplicate into
the SCTP reassembly/ordering queues.

Patch applies to linux-3.8 kernel.

Signed-off-by: Lee A. Roberts <lee.roberts@hp.com>
---
 net/sctp/tsnmap.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -uprN -X linux-3.8-vanilla/Documentation/dontdiff linux-3.8-vanilla/net/sctp/tsnmap.c linux-3.8-SCTP+1/net/sctp/tsnmap.c
--- linux-3.8-vanilla/net/sctp/tsnmap.c	2013-02-18 16:58:34.000000000 -0700
+++ linux-3.8-SCTP+1/net/sctp/tsnmap.c	2013-02-21 10:44:15.985075048 -0700
@@ -122,7 +122,7 @@ int sctp_tsnmap_mark(struct sctp_tsnmap
 	if (TSN_lt(tsn, map->base_tsn))
 		return 0;
 
-	gap = tsn - map->base_tsn;
+	gap = tsn - map->cumulative_tsn_ack_point;
 
 	if (gap >= map->len && !sctp_tsnmap_grow(map, gap))
 		return -ENOMEM;
@@ -369,14 +369,15 @@ static int sctp_tsnmap_grow(struct sctp_
 	if (gap >= SCTP_TSN_MAP_SIZE)
 		return 0;
 
-	inc = ALIGN((gap - map->len),BITS_PER_LONG) + SCTP_TSN_MAP_INCREMENT;
+	inc = ALIGN((gap - map->len), BITS_PER_LONG) + SCTP_TSN_MAP_INCREMENT;
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
