From: Xander Huff <xander.huff@ni.com>
Subject: [PATCH 2/2] net/macb: improved ethtool statistics support
Date: Tue, 13 Jan 2015 16:15:51 -0600
Message-ID: <1421187351-27279-2-git-send-email-xander.huff@ni.com>
References: <1421187351-27279-1-git-send-email-xander.huff@ni.com>
Cc: jaeden.amero@ni.com, rich.tollerton@ni.com, ben.shelton@ni.com,
	brad.mouring@ni.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Xander Huff <xander.huff@ni.com>
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421187351-27279-1-git-send-email-xander.huff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently `ethtool -S` simply returns "no stats available". It
would be more useful to see what the various ethtool statistics
registers' values are. This change implements get_ethtool_stats,
get_strings, and get_sset_count functions to accomplish this.

Read all GEM statistics registers and sum them into
macb.ethtool_stats. Add the necessary infrastructure to make this
accessible via `ethtool -S`.

Update gem_update_stats to utilize ethtool_stats.

Signed-off-by: Xander Huff <xander.huff@ni.com>
---
 drivers/net/ethernet/cadence/macb.c |  55 +++++++-
 drivers/net/ethernet/cadence/macb.h | 256 ++++++++++++++++++++++++++++++++++++
 2 files changed, 307 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 3767271..dd8c202 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1827,12 +1827,23 @@ static int macb_close(struct net_device *dev)
 
 static void gem_update_stats(struct macb *bp)
 {
-	u32 __iomem *reg = bp->regs + GEM_OTX;
+	int i;
 	u32 *p = &bp->hw_stats.gem.tx_octets_31_0;
-	u32 *end = &bp->hw_stats.gem.rx_udp_checksum_errors + 1;
 
-	for (; p < end; p++, reg++)
-		*p += __raw_readl(reg);
+	for (i = 0; i < GEM_STATS_LEN; ++i, ++p) {
+		u32 offset = gem_statistics[i].offset;
+		u64 val = __raw_readl(bp->regs+offset);
+
+		bp->ethtool_stats[i] += val;
+		*p += val;
+
+		if (offset == GEM_OCTTXL || offset == GEM_OCTRXL) {
+			/* Add GEM_OCTTXH, GEM_OCTRXH */
+			val = __raw_readl(bp->regs+offset+4);
+			bp->ethtool_stats[i] += ((u64)val)<<32;
+			*(++p) += val;
+		}
+	}
 }
 
 static struct net_device_stats *gem_get_stats(struct macb *bp)
@@ -1873,6 +1884,39 @@ static struct net_device_stats *gem_get_stats(struct macb *bp)
 	return nstat;
 }
 
+static void gem_get_ethtool_stats(struct net_device *dev,
+				  struct ethtool_stats *stats, u64 *data)
+{
+	struct macb *bp;
+
+	bp = netdev_priv(dev);
+	gem_update_stats(bp);
+	memcpy(data, &bp->ethtool_stats, sizeof(u64)*GEM_STATS_LEN);
+}
+
+static int gem_get_sset_count(struct net_device *dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return GEM_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void gem_get_ethtool_strings(struct net_device *dev, u32 sset, u8 *p)
+{
+	int i;
+
+	switch (sset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < GEM_STATS_LEN; i++, p += ETH_GSTRING_LEN)
+			memcpy(p, gem_statistics[i].stat_string,
+			       ETH_GSTRING_LEN);
+		break;
+	}
+}
+
 struct net_device_stats *macb_get_stats(struct net_device *dev)
 {
 	struct macb *bp = netdev_priv(dev);
@@ -1988,6 +2032,9 @@ const struct ethtool_ops macb_ethtool_ops = {
 	.get_regs		= macb_get_regs,
 	.get_link		= ethtool_op_get_link,
 	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_ethtool_stats	= gem_get_ethtool_stats,
+	.get_strings		= gem_get_ethtool_strings,
+	.get_sset_count		= gem_get_sset_count,
 };
 EXPORT_SYMBOL_GPL(macb_ethtool_ops);
 
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 8e8c3c9..378b218 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -82,6 +82,159 @@
 #define GEM_SA4B				0x00A0 /* Specific4 Bottom */
 #define GEM_SA4T				0x00A4 /* Specific4 Top */
 #define GEM_OTX					0x0100 /* Octets transmitted */
+#define GEM_OCTTXL				0x0100 /* Octets transmitted
+							* [31:0]
+							*/
+#define GEM_OCTTXH				0x0104 /* Octets transmitted
+							* [47:32]
+							*/
+#define GEM_TXCNT				0x0108 /* Error-free Frames
+							* Transmitted counter
+							*/
+#define GEM_TXBCCNT				0x010c /* Error-free Broadcast
+							* Frames counter
+							*/
+#define GEM_TXMCCNT				0x0110 /* Error-free Multicast
+							* Frames counter
+							*/
+#define GEM_TXPAUSECNT				0x0114 /* Pause Frames
+							* Transmitted Counter
+							*/
+#define GEM_TX64CNT				0x0118 /* Error-free 64 byte
+							* Frames Transmitted
+							* counter
+							*/
+#define GEM_TX65CNT				0x011c /* Error-free 65-127 byte
+							* Frames Transmitted
+							* counter
+							*/
+#define GEM_TX128CNT				0x0120 /* Error-free 128-255
+							* byte Frames
+							* Transmitted counter
+							*/
+#define GEM_TX256CNT				0x0124 /* Error-free 256-511
+							* byte Frames
+							* transmitted counter
+							*/
+#define GEM_TX512CNT				0x0128 /* Error-free 512-1023
+							* byte Frames
+							* transmitted counter
+							*/
+#define GEM_TX1024CNT				0x012c /* Error-free 1024-1518
+							* byte Frames
+							* transmitted counter
+							*/
+#define GEM_TX1519CNT				0x0130 /* Error-free larger than
+							* 1519 byte Frames
+							* tranmitted counter
+							*/
+#define GEM_TXURUNCNT				0x0134 /* TX under run error
+							* counter
+							*/
+#define GEM_SNGLCOLLCNT				0x0138 /* Single Collision Frame
+							* Counter
+							*/
+#define GEM_MULTICOLLCNT			0x013c /* Multiple Collision
+							* Frame Counter
+							*/
+#define GEM_EXCESSCOLLCNT			0x0140 /* Excessive Collision
+							* Frame Counter
+							*/
+#define GEM_LATECOLLCNT				0x0144 /* Late Collision Frame
+							* Counter
+							*/
+#define GEM_TXDEFERCNT				0x0148 /* Deferred Transmission
+							* Frame Counter
+							*/
+#define GEM_TXCSENSECNT				0x014c /* Carrier Sense Error
+							* Counter
+							*/
+#define GEM_ORX					0x0150 /* Octets received */
+#define GEM_OCTRXL				0x0150 /* Octets received
+							* [31:0]
+							*/
+#define GEM_OCTRXH				0x0154 /* Octets received
+							* [47:32]
+							*/
+#define GEM_RXCNT				0x0158 /* Error-free Frames
+							* Received Counter
+							*/
+#define GEM_RXBROADCNT				0x015c /* Error-free Broadcast
+							* Frames Received
+							* Counter
+							*/
+#define GEM_RXMULTICNT				0x0160 /* Error-free Multicast
+							* Frames Received
+							* Counter
+							*/
+#define GEM_RXPAUSECNT				0x0164 /* Error-free Pause
+							* Frames Received
+							* Counter
+							*/
+#define GEM_RX64CNT				0x0168 /* Error-free 64 byte
+							* Frames Received
+							* Counter
+							*/
+#define GEM_RX65CNT				0x016c /* Error-free 65-127 byte
+							* Frames Received
+							* Counter
+							*/
+#define GEM_RX128CNT				0x0170 /* Error-free 128-255
+							* byte Frames Received
+							* Counter
+							*/
+#define GEM_RX256CNT				0x0174 /* Error-free 256-511
+							* byte Frames Received
+							* Counter
+							*/
+#define GEM_RX512CNT				0x0178 /* Error-free 512-1023
+							* byte Frames Received
+							* Counter
+							*/
+#define GEM_RX1024CNT				0x017c /* Error-free 1024-1518
+							* byte Frames Received
+							* Counter
+							*/
+#define GEM_RX1519CNT				0x0180 /* Error-free larger than
+							* 1519 Frames Received
+							* Counter
+							*/
+#define GEM_RXUNDRCNT				0x0184 /* Undersize Frames
+							* Received Counter
+							*/
+#define GEM_RXOVRCNT				0x0188 /* Oversize Frames
+							* Received Counter
+							*/
+#define GEM_RXJABCNT				0x018c /* Jabbers Received
+							* Counter
+							*/
+#define GEM_RXFCSCNT				0x0190 /* Frame Check Sequence
+							* Error Counter
+							*/
+#define GEM_RXLENGTHCNT				0x0194 /* Length Field Error
+							* Counter
+							*/
+#define GEM_RXSYMBCNT				0x0198 /* Symbol Error
+							* Counter
+							*/
+#define GEM_RXALIGNCNT				0x019c /* Alignment Error
+							* Counter
+							*/
+#define GEM_RXRESERRCNT				0x01a0 /* Receive Resource Error
+							* Counter
+							*/
+#define GEM_RXORCNT				0x01a4 /* Receive Overrun
+							* Counter
+							*/
+#define GEM_RXIPCCNT				0x01a8 /* IP header Checksum
+							* Error Counter
+							*/
+#define GEM_RXTCPCCNT				0x01ac /* TCP Checksum Error
+							* Counter
+							*/
+#define GEM_RXUDPCCNT				0x01b0 /* UDP Checksum Error
+							* Counter
+							*/
 #define GEM_DCFG1				0x0280 /* Design Config 1 */
 #define GEM_DCFG2				0x0284 /* Design Config 2 */
 #define GEM_DCFG3				0x0288 /* Design Config 3 */
@@ -650,6 +803,107 @@ struct gem_stats {
 	u32	rx_udp_checksum_errors;
 };
 
+/* Describes the name and offset of an individual statistic register, as
+ * returned by `ethtool -S`. Also describes which net_device_stats statistics
+ * this register should contribute to.
+ */
+struct gem_statistic {
+	char stat_string[ETH_GSTRING_LEN];
+	int offset;
+	u32 stat_bits;
+};
+
+/* Bitfield defs for net_device_stat statistics */
+#define GEM_NDS_RXERR_OFFSET		0
+#define GEM_NDS_RXLENERR_OFFSET		1
+#define GEM_NDS_RXOVERERR_OFFSET	2
+#define GEM_NDS_RXCRCERR_OFFSET		3
+#define GEM_NDS_RXFRAMEERR_OFFSET	4
+#define GEM_NDS_RXFIFOERR_OFFSET	5
+#define GEM_NDS_TXERR_OFFSET		6
+#define GEM_NDS_TXABORTEDERR_OFFSET	7
+#define GEM_NDS_TXCARRIERERR_OFFSET	8
+#define GEM_NDS_TXFIFOERR_OFFSET	9
+#define GEM_NDS_COLLISIONS_OFFSET	10
+
+#define GEM_STAT_TITLE(name, title) GEM_STAT_TITLE_BITS(name, title, 0)
+#define GEM_STAT_TITLE_BITS(name, title, bits) {	\
+	.stat_string = title,				\
+	.offset = GEM_##name,				\
+	.stat_bits = bits				\
+}
+
+/* list of gem statistic registers. The names MUST match the
+ * corresponding GEM_* definitions.
+ */
+static const struct gem_statistic gem_statistics[] = {
+	GEM_STAT_TITLE(OCTTXL, "tx_octets"), /* OCTTXH combined with OCTTXL */
+	GEM_STAT_TITLE(TXCNT, "tx_frames"),
+	GEM_STAT_TITLE(TXBCCNT, "tx_broadcast_frames"),
+	GEM_STAT_TITLE(TXMCCNT, "tx_multicast_frames"),
+	GEM_STAT_TITLE(TXPAUSECNT, "tx_pause_frames"),
+	GEM_STAT_TITLE(TX64CNT, "tx_64_byte_frames"),
+	GEM_STAT_TITLE(TX65CNT, "tx_65_127_byte_frames"),
+	GEM_STAT_TITLE(TX128CNT, "tx_128_255_byte_frames"),
+	GEM_STAT_TITLE(TX256CNT, "tx_256_511_byte_frames"),
+	GEM_STAT_TITLE(TX512CNT, "tx_512_1023_byte_frames"),
+	GEM_STAT_TITLE(TX1024CNT, "tx_1024_1518_byte_frames"),
+	GEM_STAT_TITLE(TX1519CNT, "tx_greater_than_1518_byte_frames"),
+	GEM_STAT_TITLE_BITS(TXURUNCNT, "tx_underrun",
+			    GEM_BIT(NDS_TXERR)|GEM_BIT(NDS_TXFIFOERR)),
+	GEM_STAT_TITLE_BITS(SNGLCOLLCNT, "tx_single_collision_frames",
+			    GEM_BIT(NDS_TXERR)|GEM_BIT(NDS_COLLISIONS)),
+	GEM_STAT_TITLE_BITS(MULTICOLLCNT, "tx_multiple_collision_frames",
+			    GEM_BIT(NDS_TXERR)|GEM_BIT(NDS_COLLISIONS)),
+	GEM_STAT_TITLE_BITS(EXCESSCOLLCNT, "tx_excessive_collisions",
+			    GEM_BIT(NDS_TXERR)|
+			    GEM_BIT(NDS_TXABORTEDERR)|
+			    GEM_BIT(NDS_COLLISIONS)),
+	GEM_STAT_TITLE_BITS(LATECOLLCNT, "tx_late_collisions",
+			    GEM_BIT(NDS_TXERR)|GEM_BIT(NDS_COLLISIONS)),
+	GEM_STAT_TITLE(TXDEFERCNT, "tx_deferred_frames"),
+	GEM_STAT_TITLE_BITS(TXCSENSECNT, "tx_carrier_sense_errors",
+			    GEM_BIT(NDS_TXERR)|GEM_BIT(NDS_COLLISIONS)),
+	GEM_STAT_TITLE(OCTRXL, "rx_octets"), /* OCTRXH combined with OCTRXL */
+	GEM_STAT_TITLE(RXCNT, "rx_frames"),
+	GEM_STAT_TITLE(RXBROADCNT, "rx_broadcast_frames"),
+	GEM_STAT_TITLE(RXMULTICNT, "rx_multicast_frames"),
+	GEM_STAT_TITLE(RXPAUSECNT, "rx_pause_frames"),
+	GEM_STAT_TITLE(RX64CNT, "rx_64_byte_frames"),
+	GEM_STAT_TITLE(RX65CNT, "rx_65_127_byte_frames"),
+	GEM_STAT_TITLE(RX128CNT, "rx_128_255_byte_frames"),
+	GEM_STAT_TITLE(RX256CNT, "rx_256_511_byte_frames"),
+	GEM_STAT_TITLE(RX512CNT, "rx_512_1023_byte_frames"),
+	GEM_STAT_TITLE(RX1024CNT, "rx_1024_1518_byte_frames"),
+	GEM_STAT_TITLE(RX1519CNT, "rx_greater_than_1518_byte_frames"),
+	GEM_STAT_TITLE_BITS(RXUNDRCNT, "rx_undersized_frames",
+			    GEM_BIT(NDS_RXERR)|GEM_BIT(NDS_RXLENERR)),
+	GEM_STAT_TITLE_BITS(RXOVRCNT, "rx_oversize_frames",
+			    GEM_BIT(NDS_RXERR)|GEM_BIT(NDS_RXLENERR)),
+	GEM_STAT_TITLE_BITS(RXJABCNT, "rx_jabbers",
+			    GEM_BIT(NDS_RXERR)|GEM_BIT(NDS_RXLENERR)),
+	GEM_STAT_TITLE_BITS(RXFCSCNT, "rx_frame_check_sequence_errors",
+			    GEM_BIT(NDS_RXERR)|GEM_BIT(NDS_RXCRCERR)),
+	GEM_STAT_TITLE_BITS(RXLENGTHCNT, "rx_length_field_frame_errors",
+			    GEM_BIT(NDS_RXERR)),
+	GEM_STAT_TITLE_BITS(RXSYMBCNT, "rx_symbol_errors",
+			    GEM_BIT(NDS_RXERR)|GEM_BIT(NDS_RXFRAMEERR)),
+	GEM_STAT_TITLE_BITS(RXALIGNCNT, "rx_alignment_errors",
+			    GEM_BIT(NDS_RXERR)|GEM_BIT(NDS_RXOVERERR)),
+	GEM_STAT_TITLE_BITS(RXRESERRCNT, "rx_resource_errors",
+			    GEM_BIT(NDS_RXERR)|GEM_BIT(NDS_RXOVERERR)),
+	GEM_STAT_TITLE_BITS(RXORCNT, "rx_overruns",
+			    GEM_BIT(NDS_RXERR)|GEM_BIT(NDS_RXFIFOERR)),
+	GEM_STAT_TITLE_BITS(RXIPCCNT, "rx_ip_header_checksum_errors",
+			    GEM_BIT(NDS_RXERR)),
+	GEM_STAT_TITLE_BITS(RXTCPCCNT, "rx_tcp_checksum_errors",
+			    GEM_BIT(NDS_RXERR)),
+	GEM_STAT_TITLE_BITS(RXUDPCCNT, "rx_udp_checksum_errors",
+			    GEM_BIT(NDS_RXERR)),
+};
+
+#define GEM_STATS_LEN ARRAY_SIZE(gem_statistics)
+
 struct macb;
 
 struct macb_or_gem_ops {
@@ -728,6 +982,8 @@ struct macb {
 	dma_addr_t skb_physaddr;		/* phys addr from pci_map_single */
 	int skb_length;				/* saved skb length for pci_unmap_single */
 	unsigned int		max_tx_length;
+
+	u64			ethtool_stats[GEM_STATS_LEN];
 };
 
 extern const struct ethtool_ops macb_ethtool_ops;
-- 
1.9.1
