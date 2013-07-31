From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 01/12] tile: support rx_dropped/rx_errors in tilepro net driver
Date: Wed, 31 Jul 2013 11:05:04 -0400
Message-ID: <ecfde04771bfa44566d4c1183269259217553a96.1375283105.git.cmetcalf@tilera.com>
References: <cover.1374609948.git.cmetcalf@tilera.com>
	<cover.1375283104.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1375283104.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilepro.c | 41 ++++++++++++++-----------------------
 1 file changed, 15 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 782e95b..63fd9cc 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -776,6 +776,7 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 	netio_pkt_t *pkt = (netio_pkt_t *)((unsigned long) &qsp[1] + index);
 
 	netio_pkt_metadata_t *metadata = NETIO_PKT_METADATA(pkt);
+	netio_pkt_status_t pkt_status = NETIO_PKT_STATUS_M(metadata, pkt);
 
 	/* Extract the packet size.  FIXME: Shouldn't the second line */
 	/* get subtracted?  Mostly moot, since it should be "zero". */
@@ -808,40 +809,25 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 #endif /* TILE_NET_DUMP_PACKETS */
 
 #ifdef TILE_NET_VERIFY_INGRESS
-	if (!NETIO_PKT_L4_CSUM_CORRECT_M(metadata, pkt) &&
-	    NETIO_PKT_L4_CSUM_CALCULATED_M(metadata, pkt)) {
-		/* Bug 6624: Includes UDP packets with a "zero" checksum. */
-		pr_warning("Bad L4 checksum on %d byte packet.\n", len);
-	}
-	if (!NETIO_PKT_L3_CSUM_CORRECT_M(metadata, pkt) &&
-	    NETIO_PKT_L3_CSUM_CALCULATED_M(metadata, pkt)) {
+	if (pkt_status == NETIO_PKT_STATUS_OVERSIZE && len >= 64) {
 		dump_packet(buf, len, "rx");
-		panic("Bad L3 checksum.");
-	}
-	switch (NETIO_PKT_STATUS_M(metadata, pkt)) {
-	case NETIO_PKT_STATUS_OVERSIZE:
-		if (len >= 64) {
-			dump_packet(buf, len, "rx");
-			panic("Unexpected OVERSIZE.");
-		}
-		break;
-	case NETIO_PKT_STATUS_BAD:
-		pr_warning("Unexpected BAD %ld byte packet.\n", len);
+		panic("Unexpected OVERSIZE.");
 	}
 #endif
 
 	filter = 0;
 
-	/* ISSUE: Filter TCP packets with "bad" checksums? */
-
-	if (!(dev->flags & IFF_UP)) {
+	if (pkt_status == NETIO_PKT_STATUS_BAD) {
+		/* Handle CRC error and hardware truncation. */
+		filter = 2;
+	} else if (!(dev->flags & IFF_UP)) {
 		/* Filter packets received before we're up. */
 		filter = 1;
-	} else if (NETIO_PKT_STATUS_M(metadata, pkt) == NETIO_PKT_STATUS_BAD) {
+	} else if (NETIO_PKT_ETHERTYPE_RECOGNIZED_M(metadata, pkt) &&
+		   pkt_status == NETIO_PKT_STATUS_UNDERSIZE) {
 		/* Filter "truncated" packets. */
-		filter = 1;
+		filter = 2;
 	} else if (!(dev->flags & IFF_PROMISC)) {
-		/* FIXME: Implement HW multicast filter. */
 		if (!is_multicast_ether_addr(buf)) {
 			/* Filter packets not for our address. */
 			const u8 *mine = dev->dev_addr;
@@ -851,9 +837,12 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 
 	u64_stats_update_begin(&stats->syncp);
 
-	if (filter) {
+	if (filter != 0) {
 
-		/* ISSUE: Update "drop" statistics? */
+		if (filter == 1)
+			stats->rx_dropped++;
+		else
+			stats->rx_errors++;
 
 		tile_net_provide_linux_buffer(info, va, small);
 
-- 
1.8.3.1
