From: Zach Brown <zach.brown@ni.com>
Subject: [PATCH 2/2] net: macb: Add ethtool get_ringparam and set_ringparam functionality
Date: Wed, 19 Oct 2016 09:56:58 -0500
Message-ID: <1476889018-8357-3-git-send-email-zach.brown@ni.com>
References: <1476889018-8357-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
To: <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476889018-8357-1-git-send-email-zach.brown@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some applications want to tune the size of the macb rx/tx ring buffers.
The ethtool set_ringparam function is the standard way of doing it.

Signed-off-by: Zach Brown <zach.brown@ni.com>
---
 drivers/net/ethernet/cadence/macb.c | 59 +++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 644975d..e1847ce 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -37,11 +37,16 @@

 #define MACB_RX_BUFFER_SIZE	128
 #define RX_BUFFER_MULTIPLE	64  /* bytes */
+
 #define DEFAULT_RX_RING_SIZE	512 /* must be power of 2 */
+#define MIN_RX_RING_SIZE	64
+#define MAX_RX_RING_SIZE	8192
 #define RX_RING_BYTES(bp)	(sizeof(struct macb_dma_desc)	\
 				 * (bp)->rx_ring_size)

 #define DEFAULT_TX_RING_SIZE	512 /* must be power of 2 */
+#define MIN_TX_RING_SIZE	64
+#define MAX_TX_RING_SIZE	4096
 #define TX_RING_BYTES(bp)	(sizeof(struct macb_dma_desc)	\
 				 * (bp)->tx_ring_size)

@@ -2211,6 +2216,56 @@ static int macb_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	return 0;
 }

+static void macb_get_ringparam(struct net_device *netdev,
+			       struct ethtool_ringparam *ring)
+{
+	struct macb *bp = netdev_priv(netdev);
+
+	ring->rx_max_pending = MAX_RX_RING_SIZE;
+	ring->tx_max_pending = MAX_TX_RING_SIZE;
+
+	ring->rx_pending = bp->rx_ring_size;
+	ring->tx_pending = bp->tx_ring_size;
+}
+
+static int macb_set_ringparam(struct net_device *netdev,
+			      struct ethtool_ringparam *ring)
+{
+	struct macb *bp = netdev_priv(netdev);
+	u32 new_rx_size, new_tx_size;
+	unsigned int reset = 0;
+
+	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
+		return -EINVAL;
+
+	new_rx_size = clamp_t(u32, ring->rx_pending,
+			      MIN_RX_RING_SIZE, MAX_RX_RING_SIZE);
+	new_rx_size = roundup_pow_of_two(new_rx_size);
+
+	new_tx_size = clamp_t(u32, ring->tx_pending,
+			      MIN_TX_RING_SIZE, MAX_TX_RING_SIZE);
+	new_tx_size = roundup_pow_of_two(new_tx_size);
+
+	if ((new_tx_size == bp->tx_ring_size) &&
+	    (new_rx_size == bp->rx_ring_size)) {
+		/* nothing to do */
+		return 0;
+	}
+
+	if (netif_running(bp->dev)) {
+		reset = 1;
+		macb_close(bp->dev);
+	}
+
+	bp->rx_ring_size = new_rx_size;
+	bp->tx_ring_size = new_tx_size;
+
+	if (reset)
+		macb_open(bp->dev);
+
+	return 0;
+}
+
 static const struct ethtool_ops macb_ethtool_ops = {
 	.get_regs_len		= macb_get_regs_len,
 	.get_regs		= macb_get_regs,
@@ -2220,6 +2275,8 @@ static const struct ethtool_ops macb_ethtool_ops = {
 	.set_wol		= macb_set_wol,
 	.get_link_ksettings     = phy_ethtool_get_link_ksettings,
 	.set_link_ksettings     = phy_ethtool_set_link_ksettings,
+	.get_ringparam		= macb_get_ringparam,
+	.set_ringparam		= macb_set_ringparam,
 };

 static const struct ethtool_ops gem_ethtool_ops = {
@@ -2232,6 +2289,8 @@ static const struct ethtool_ops gem_ethtool_ops = {
 	.get_sset_count		= gem_get_sset_count,
 	.get_link_ksettings     = phy_ethtool_get_link_ksettings,
 	.set_link_ksettings     = phy_ethtool_set_link_ksettings,
+	.get_ringparam		= macb_get_ringparam,
+	.set_ringparam		= macb_set_ringparam,
 };

 static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
--
2.7.4
