From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH 4/4] net: ethoc: implement ethtool get/set ring parameters
Date: Wed, 29 Jan 2014 23:56:37 +0400
Message-ID: <1391025397-14965-5-git-send-email-jcmvbkbc@gmail.com>
References: <1391025397-14965-1-git-send-email-jcmvbkbc@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Marc Gauthier <marc@cadence.com>,
	Max Filippov <jcmvbkbc@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391025397-14965-1-git-send-email-jcmvbkbc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TX and RX rings share memory and descriptors. Maximal number of
descriptors reported is one less than the total available nuber of
descriptors. For the set operation the requested number of TX descriptors
is rounded down to the nearest power of two (driver logic requirement), the
rest are RX descriptors. If less RX descriptors is requested the rest is
left unused.

Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
 drivers/net/ethernet/ethoc.c | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 0bf297b..c873946 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -181,6 +181,7 @@ MODULE_PARM_DESC(buffer_size, "DMA buffer allocation size");
  * @membase:	pointer to buffer memory region
  * @dma_alloc:	dma allocated buffer size
  * @io_region_size:	I/O memory region size
+ * @num_bd:	number of buffer descriptors
  * @num_tx:	number of send buffers
  * @cur_tx:	last send buffer written
  * @dty_tx:	last buffer actually sent
@@ -201,6 +202,7 @@ struct ethoc {
 	int dma_alloc;
 	resource_size_t io_region_size;
 
+	unsigned int num_bd;
 	unsigned int num_tx;
 	unsigned int cur_tx;
 	unsigned int dty_tx;
@@ -940,12 +942,44 @@ static void ethoc_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		regs_buff[i] = ethoc_read(priv, i * sizeof(u32));
 }
 
+static void ethoc_get_ringparam(struct net_device *dev,
+				struct ethtool_ringparam *ring)
+{
+	struct ethoc *priv = netdev_priv(dev);
+
+	ring->rx_max_pending = priv->num_bd - 1;
+	ring->rx_mini_max_pending = 0;
+	ring->rx_jumbo_max_pending = 0;
+	ring->tx_max_pending = priv->num_bd - 1;
+
+	ring->rx_pending = priv->num_rx;
+	ring->rx_mini_pending = 0;
+	ring->rx_jumbo_pending = 0;
+	ring->tx_pending = priv->num_tx;
+}
+
+static int ethoc_set_ringparam(struct net_device *dev,
+			       struct ethtool_ringparam *ring)
+{
+	struct ethoc *priv = netdev_priv(dev);
+
+	if (netif_running(dev))
+		return -EBUSY;
+	priv->num_tx = rounddown_pow_of_two(ring->tx_pending);
+	priv->num_rx = priv->num_bd - priv->num_tx;
+	if (priv->num_rx > ring->rx_pending)
+		priv->num_rx = ring->rx_pending;
+	return 0;
+}
+
 const struct ethtool_ops ethoc_ethtool_ops = {
 	.get_settings = ethoc_get_settings,
 	.set_settings = ethoc_set_settings,
 	.get_regs_len = ethoc_get_regs_len,
 	.get_regs = ethoc_get_regs,
 	.get_link = ethtool_op_get_link,
+	.get_ringparam = ethoc_get_ringparam,
+	.set_ringparam = ethoc_set_ringparam,
 	.get_ts_info = ethtool_op_get_ts_info,
 };
 
@@ -1077,6 +1111,7 @@ static int ethoc_probe(struct platform_device *pdev)
 		ret = -ENODEV;
 		goto error;
 	}
+	priv->num_bd = num_bd;
 	/* num_tx must be a power of two */
 	priv->num_tx = rounddown_pow_of_two(num_bd >> 1);
 	priv->num_rx = num_bd - priv->num_tx;
-- 
1.8.1.4
