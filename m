From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH v3 02/13] tile: support rx_dropped/rx_errors in tilepro net driver
Date: Thu, 1 Aug 2013 11:36:42 -0400
Message-ID: <916f447a70a69e4ac4e118528628ee1df8f55713.1375385119.git.cmetcalf@tilera.com>
References: <20130801.113100.2059303096028571906.davem@davemloft.net>
	<cover.1375385119.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1375385119.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilepro.c | 41 ++++++++++++++-----------------------
 1 file changed, 15 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 34b43b4..327ff7b 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -772,6 +772,7 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 	netio_pkt_t *pkt = (netio_pkt_t *)((unsigned long) &qsp[1] + index);
 
 	netio_pkt_metadata_t *metadata = NETIO_PKT_METADATA(pkt);
+	netio_pkt_status_t pkt_status = NETIO_PKT_STATUS_M(metadata, pkt);
 
 	/* Extract the packet size.  FIXME: Shouldn't the second line */
 	/* get subtracted?  Mostly moot, since it should be "zero". */
@@ -804,40 +805,25 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
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
@@ -847,9 +833,12 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 
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
