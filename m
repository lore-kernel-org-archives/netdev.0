From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] sky2: implement 64 bit stats
Date: Fri, 31 Dec 2010 17:34:27 -0800
Message-ID: <20101231173427.17f07ad3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52279 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751232Ab1AABeb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Dec 2010 20:34:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements 64 bit statistics support and fixes races when reading
counter values. The PHY counters can only be accessed 16 bits at a time,
so they are subject to carry races.

NB:
  * TX/RX counters are maintained in software because the the hardware packet count
    is only a 32 bit value.

  * Error counters are really only 32 bit.

  * Old 32 bit counter fields in dev->stats still used for some
    software counters

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/sky2.c |  100 ++++++++++++++++++++++++++++++++++-------------------
 drivers/net/sky2.h |    9 ++++
 2 files changed, 74 insertions(+), 35 deletions(-)

--- a/drivers/net/sky2.c	2010-12-29 11:22:13.557333420 -0800
+++ b/drivers/net/sky2.c	2010-12-29 14:39:35.694667578 -0800
@@ -1917,8 +1917,10 @@ static void sky2_tx_complete(struct sky2
 			netif_printk(sky2, tx_done, KERN_DEBUG, dev,
 				     "tx done %u\n", idx);
 
-			dev->stats.tx_packets++;
-			dev->stats.tx_bytes += skb->len;
+			u64_stats_update_begin(&sky2->tx_stats.syncp);
+			++sky2->tx_stats.packets;
+			sky2->tx_stats.bytes += skb->len;
+			u64_stats_update_end(&sky2->tx_stats.syncp);
 
 			re->skb = NULL;
 			dev_kfree_skb_any(skb);
@@ -2460,7 +2462,7 @@ static struct sk_buff *sky2_receive(stru
 
 	/* if length reported by DMA does not match PHY, packet was truncated */
 	if (length != count)
-		goto len_error;
+		goto error;
 
 okay:
 	if (length < copybreak)
@@ -2475,34 +2477,13 @@ resubmit:
 
 	return skb;
 
-len_error:
-	/* Truncation of overlength packets
-	   causes PHY length to not match MAC length */
-	++dev->stats.rx_length_errors;
-	if (net_ratelimit())
-		netif_info(sky2, rx_err, dev,
-			   "rx length error: status %#x length %d\n",
-			   status, length);
-	goto resubmit;
-
 error:
 	++dev->stats.rx_errors;
-	if (status & GMR_FS_RX_FF_OV) {
-		dev->stats.rx_over_errors++;
-		goto resubmit;
-	}
 
 	if (net_ratelimit())
 		netif_info(sky2, rx_err, dev,
 			   "rx error, status 0x%x length %d\n", status, length);
 
-	if (status & (GMR_FS_LONG_ERR | GMR_FS_UN_SIZE))
-		dev->stats.rx_length_errors++;
-	if (status & GMR_FS_FRAGMENT)
-		dev->stats.rx_frame_errors++;
-	if (status & GMR_FS_CRC_ERR)
-		dev->stats.rx_crc_errors++;
-
 	goto resubmit;
 }
 
@@ -2543,14 +2524,19 @@ static inline void sky2_skb_rx(const str
 static inline void sky2_rx_done(struct sky2_hw *hw, unsigned port,
 				unsigned packets, unsigned bytes)
 {
-	if (packets) {
-		struct net_device *dev = hw->dev[port];
+	struct net_device *dev = hw->dev[port];
+	struct sky2_port *sky2 = netdev_priv(dev);
 
-		dev->stats.rx_packets += packets;
-		dev->stats.rx_bytes += bytes;
-		dev->last_rx = jiffies;
-		sky2_rx_update(netdev_priv(dev), rxqaddr[port]);
-	}
+	if (packets == 0)
+		return;
+
+	u64_stats_update_begin(&sky2->rx_stats.syncp);
+	sky2->rx_stats.packets += packets;
+	sky2->rx_stats.bytes += bytes;
+	u64_stats_update_end(&sky2->rx_stats.syncp);
+
+	dev->last_rx = jiffies;
+	sky2_rx_update(netdev_priv(dev), rxqaddr[port]);
 }
 
 static void sky2_rx_checksum(struct sky2_port *sky2, u32 status)
@@ -3626,13 +3612,11 @@ static void sky2_phy_stats(struct sky2_p
 	unsigned port = sky2->port;
 	int i;
 
-	data[0] = (u64) gma_read32(hw, port, GM_TXO_OK_HI) << 32
-	    | (u64) gma_read32(hw, port, GM_TXO_OK_LO);
-	data[1] = (u64) gma_read32(hw, port, GM_RXO_OK_HI) << 32
-	    | (u64) gma_read32(hw, port, GM_RXO_OK_LO);
+	data[0] = get_stats64(hw, port, GM_TXO_OK_LO);
+	data[1] = get_stats64(hw, port, GM_RXO_OK_LO);
 
 	for (i = 2; i < count; i++)
-		data[i] = (u64) gma_read32(hw, port, sky2_stats[i].offset);
+		data[i] = get_stats32(hw, port, sky2_stats[i].offset);
 }
 
 static void sky2_set_msglevel(struct net_device *netdev, u32 value)
@@ -3750,6 +3734,51 @@ static void sky2_set_multicast(struct ne
 	gma_write16(hw, port, GM_RX_CTRL, reg);
 }
 
+static struct rtnl_link_stats64 *sky2_get_stats(struct net_device *dev,
+						struct rtnl_link_stats64 *stats)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	struct sky2_hw *hw = sky2->hw;
+	unsigned port = sky2->port;
+	unsigned int start;
+	u64 _bytes, _packets;
+
+	do {
+		start = u64_stats_fetch_begin_bh(&sky2->rx_stats.syncp);
+		_bytes = sky2->rx_stats.bytes;
+		_packets = sky2->rx_stats.packets;
+	} while (u64_stats_fetch_retry_bh(&sky2->rx_stats.syncp, start));
+
+	stats->rx_packets = _packets;
+	stats->rx_bytes = _bytes;
+
+	do {
+		start = u64_stats_fetch_begin_bh(&sky2->tx_stats.syncp);
+		_bytes = sky2->tx_stats.bytes;
+		_packets = sky2->tx_stats.packets;
+	} while (u64_stats_fetch_retry_bh(&sky2->tx_stats.syncp, start));
+
+	stats->tx_packets = _packets;
+	stats->tx_bytes = _bytes;
+
+	stats->multicast = get_stats32(hw, port, GM_RXF_MC_OK)
+		+ get_stats32(hw, port, GM_RXF_BC_OK);
+
+	stats->collisions = get_stats32(hw, port, GM_TXF_COL);
+
+	stats->rx_length_errors = get_stats32(hw, port, GM_RXF_LNG_ERR);
+	stats->rx_crc_errors = get_stats32(hw, port, GM_RXF_FCS_ERR);
+	stats->rx_frame_errors = get_stats32(hw, port, GM_RXF_SHT)
+		+ get_stats32(hw, port, GM_RXE_FRAG);
+	stats->rx_over_errors = get_stats32(hw, port, GM_RXE_FIFO_OV);
+
+	stats->rx_dropped = dev->stats.rx_dropped;
+	stats->rx_fifo_errors = dev->stats.rx_fifo_errors;
+	stats->tx_fifo_errors = dev->stats.tx_fifo_errors;
+
+	return stats;
+}
+
 /* Can have one global because blinking is controlled by
  * ethtool and that is always under RTNL mutex
  */
@@ -4524,6 +4553,7 @@ static const struct net_device_ops sky2_
 	.ndo_set_multicast_list	= sky2_set_multicast,
 	.ndo_change_mtu		= sky2_change_mtu,
 	.ndo_tx_timeout		= sky2_tx_timeout,
+	.ndo_get_stats64	= sky2_get_stats,
 #ifdef SKY2_VLAN_TAG_USED
 	.ndo_vlan_rx_register	= sky2_vlan_rx_register,
 #endif
@@ -4541,6 +4571,7 @@ static const struct net_device_ops sky2_
 	.ndo_set_multicast_list	= sky2_set_multicast,
 	.ndo_change_mtu		= sky2_change_mtu,
 	.ndo_tx_timeout		= sky2_tx_timeout,
+	.ndo_get_stats64	= sky2_get_stats,
 #ifdef SKY2_VLAN_TAG_USED
 	.ndo_vlan_rx_register	= sky2_vlan_rx_register,
 #endif
--- a/drivers/net/sky2.h	2010-12-29 11:45:50.794220257 -0800
+++ b/drivers/net/sky2.h	2010-12-29 14:36:44.010566117 -0800
@@ -2200,6 +2200,12 @@ enum flow_control {
 	FC_BOTH	= 3,
 };
 
+struct sky2_stats {
+	struct u64_stats_sync syncp;
+	u64		packets;
+	u64		bytes;
+};
+
 struct sky2_port {
 	struct sky2_hw	     *hw;
 	struct net_device    *netdev;
@@ -2209,6 +2215,8 @@ struct sky2_port {
 
 	struct tx_ring_info  *tx_ring;
 	struct sky2_tx_le    *tx_le;
+	struct sky2_stats    tx_stats;
+
 	u16		     tx_ring_size;
 	u16		     tx_cons;		/* next le to check */
 	u16		     tx_prod;		/* next le to use */
@@ -2221,6 +2229,7 @@ struct sky2_port {
 
 	struct rx_ring_info  *rx_ring ____cacheline_aligned_in_smp;
 	struct sky2_rx_le    *rx_le;
+	struct sky2_stats    rx_stats;
 
 	u16		     rx_next;		/* next re to check */
 	u16		     rx_put;		/* next le index to use */
@@ -2346,6 +2355,39 @@ static inline u32 gma_read32(struct sky2
 		| (u32) sky2_read16(hw, base+4) << 16;
 }
 
+static inline u64 gma_read64(struct sky2_hw *hw, unsigned port, unsigned reg)
+{
+	unsigned base = SK_GMAC_REG(port, reg);
+
+	return (u64) sky2_read16(hw, base)
+		| (u64) sky2_read16(hw, base+4) << 16
+		| (u64) sky2_read16(hw, base+8) << 32
+		| (u64) sky2_read16(hw, base+12) << 48;
+}
+
+/* There is no way to atomically read32 bit values from PHY, so retry */
+static inline u32 get_stats32(struct sky2_hw *hw, unsigned port, unsigned reg)
+{
+	u32 val;
+
+	do {
+		val = gma_read32(hw, port, reg);
+	} while (gma_read32(hw, port, reg) != val);
+
+	return val;
+}
+
+static inline u64 get_stats64(struct sky2_hw *hw, unsigned port, unsigned reg)
+{
+	u64 val;
+
+	do {
+		val = gma_read64(hw, port, reg);
+	} while (gma_read64(hw, port, reg) != val);
+
+	return val;
+}
+
 static inline void gma_write16(const struct sky2_hw *hw, unsigned port, int r, u16 v)
 {
 	sky2_write16(hw, SK_GMAC_REG(port,r), v);

