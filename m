From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCH 7/8] macb: support statistics for GEM devices
Date: Thu, 10 Mar 2011 10:10:42 +0000
Message-ID: <1299751843-9743-8-git-send-email-jamie@jamieiles.com>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
Cc: nicolas.ferre@atmel.com, Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44704 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262Ab1CJKLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 05:11:04 -0500
Received: by mail-wy0-f174.google.com with SMTP id 21so1289486wya.19
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 02:11:03 -0800 (PST)
In-Reply-To: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GEM devices have a different number of statistics registers and they
are at a different offset to MACB devices.  Make the statistics
collection method dependent on device type.

Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 drivers/net/macb.c |   57 +++++++++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/macb.h |   54 ++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 107 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index dbc6e7ea..2965405 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -291,8 +291,8 @@ err_out:
 static void macb_update_stats(struct macb *bp)
 {
 	u32 __iomem *reg = bp->regs + MACB_PFR;
-	u32 *p = &bp->hw_stats.rx_pause_frames;
-	u32 *end = &bp->hw_stats.tx_pause_frames + 1;
+	u32 *p = &bp->hw_stats.macb.rx_pause_frames;
+	u32 *end = &bp->hw_stats.macb.tx_pause_frames + 1;
 
 	WARN_ON((unsigned long)(end - p - 1) != (MACB_TPF - MACB_PFR) / 4);
 
@@ -1002,11 +1002,62 @@ static int macb_close(struct net_device *dev)
 	return 0;
 }
 
+static void gem_update_stats(struct macb *bp)
+{
+	u32 __iomem *reg = bp->regs + GEM_OTX;
+	u32 *p = &bp->hw_stats.gem.tx_octets_31_0;
+	u32 *end = &bp->hw_stats.gem.rx_udp_checksum_errors + 1;
+
+	for (; p < end; p++, reg++)
+		*p += __raw_readl(reg);
+}
+
+static struct net_device_stats *gem_get_stats(struct macb *bp)
+{
+	struct gem_stats *hwstat = &bp->hw_stats.gem;
+	struct net_device_stats *nstat = &bp->stats;
+
+	gem_update_stats(bp);
+
+	nstat->rx_errors = (hwstat->rx_frame_check_sequence_errors +
+			    hwstat->rx_alignment_errors +
+			    hwstat->rx_resource_errors +
+			    hwstat->rx_overruns +
+			    hwstat->rx_oversize_frames +
+			    hwstat->rx_jabbers +
+			    hwstat->rx_undersized_frames +
+			    hwstat->rx_length_field_frame_errors);
+	nstat->tx_errors = (hwstat->tx_late_collisions +
+			    hwstat->tx_excessive_collisions +
+			    hwstat->tx_underrun +
+			    hwstat->tx_carrier_sense_errors);
+	nstat->multicast = hwstat->rx_multicast_frames;
+	nstat->collisions = (hwstat->tx_single_collision_frames +
+			     hwstat->tx_multiple_collision_frames +
+			     hwstat->tx_excessive_collisions);
+	nstat->rx_length_errors = (hwstat->rx_oversize_frames +
+				   hwstat->rx_jabbers +
+				   hwstat->rx_undersized_frames +
+				   hwstat->rx_length_field_frame_errors);
+	nstat->rx_over_errors = hwstat->rx_resource_errors;
+	nstat->rx_crc_errors = hwstat->rx_frame_check_sequence_errors;
+	nstat->rx_frame_errors = hwstat->rx_alignment_errors;
+	nstat->rx_fifo_errors = hwstat->rx_overruns;
+	nstat->tx_aborted_errors = hwstat->tx_excessive_collisions;
+	nstat->tx_carrier_errors = hwstat->tx_carrier_sense_errors;
+	nstat->tx_fifo_errors = hwstat->tx_underrun;
+
+	return nstat;
+}
+
 static struct net_device_stats *macb_get_stats(struct net_device *dev)
 {
 	struct macb *bp = netdev_priv(dev);
 	struct net_device_stats *nstat = &bp->stats;
-	struct macb_stats *hwstat = &bp->hw_stats;
+	struct macb_stats *hwstat = &bp->hw_stats.macb;
+
+	if (bp->is_gem)
+		return gem_get_stats(bp);
 
 	/* read stats from hardware */
 	macb_update_stats(bp);
diff --git a/drivers/net/macb.h b/drivers/net/macb.h
index 4cd1e41..bc2e2c0 100644
--- a/drivers/net/macb.h
+++ b/drivers/net/macb.h
@@ -63,6 +63,7 @@
 /* GEM register offsets. */
 #define GEM_SA1B				0x0088
 #define GEM_SA1T				0x008C
+#define GEM_OTX					0x0100
 
 /* Bitfields in NCR */
 #define MACB_LB_OFFSET				0
@@ -390,6 +391,54 @@ struct macb_stats {
 	u32	tx_pause_frames;
 };
 
+struct gem_stats {
+	u32	tx_octets_31_0;
+	u32	tx_octets_47_32;
+	u32	tx_frames;
+	u32	tx_broadcast_frames;
+	u32	tx_multicast_frames;
+	u32	tx_pause_frames;
+	u32	tx_64_byte_frames;
+	u32	tx_65_127_byte_frames;
+	u32	tx_128_255_byte_frames;
+	u32	tx_256_511_byte_frames;
+	u32	tx_512_1023_byte_frames;
+	u32	tx_1024_1518_byte_frames;
+	u32	tx_greater_than_1518_byte_frames;
+	u32	tx_underrun;
+	u32	tx_single_collision_frames;
+	u32	tx_multiple_collision_frames;
+	u32	tx_excessive_collisions;
+	u32	tx_late_collisions;
+	u32	tx_deferred_frames;
+	u32	tx_carrier_sense_errors;
+	u32	rx_octets_31_0;
+	u32	rx_octets_47_32;
+	u32	rx_frames;
+	u32	rx_broadcast_frames;
+	u32	rx_multicast_frames;
+	u32	rx_pause_frames;
+	u32	rx_64_byte_frames;
+	u32	rx_65_127_byte_frames;
+	u32	rx_128_255_byte_frames;
+	u32	rx_256_511_byte_frames;
+	u32	rx_512_1023_byte_frames;
+	u32	rx_1024_1518_byte_frames;
+	u32	rx_greater_than_1518_byte_frames;
+	u32	rx_undersized_frames;
+	u32	rx_oversize_frames;
+	u32	rx_jabbers;
+	u32	rx_frame_check_sequence_errors;
+	u32	rx_length_field_frame_errors;
+	u32	rx_symbol_errors;
+	u32	rx_alignment_errors;
+	u32	rx_resource_errors;
+	u32	rx_overruns;
+	u32	rx_ip_header_checksum_errors;
+	u32	rx_tcp_checksum_errors;
+	u32	rx_udp_checksum_errors;
+};
+
 struct macb {
 	void __iomem		*regs;
 	int			is_gem;
@@ -409,7 +458,10 @@ struct macb {
 	struct net_device	*dev;
 	struct napi_struct	napi;
 	struct net_device_stats	stats;
-	struct macb_stats	hw_stats;
+	union {
+		struct macb_stats	macb;
+		struct gem_stats	gem;
+	}			hw_stats;
 
 	dma_addr_t		rx_ring_dma;
 	dma_addr_t		tx_ring_dma;
-- 
1.7.4

