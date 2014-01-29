From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH v2 4/4] net: ethoc: implement ethtool operations
Date: Wed, 29 Jan 2014 10:00:18 +0400
Message-ID: <1390975218-13863-5-git-send-email-jcmvbkbc@gmail.com>
References: <1390975218-13863-1-git-send-email-jcmvbkbc@gmail.com>
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Max Filippov <jcmvbkbc@gmail.com>
To: linux-xtensa@linux-xtensa.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390975218-13863-1-git-send-email-jcmvbkbc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following methods are implemented:
- get/set settings;
- get registers length/registers;
- get link state (standard implementation);
- get/set ring parameters;
- get timestamping info (standard implementation).

Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
Changes v1->v2:
- new patch.

 drivers/net/ethernet/ethoc.c | 85 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 85 insertions(+)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 5854d41..2f8b174 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -52,6 +52,7 @@ MODULE_PARM_DESC(buffer_size, "DMA buffer allocation size");
 #define	ETH_HASH0	0x48
 #define	ETH_HASH1	0x4c
 #define	ETH_TXCTRL	0x50
+#define	ETH_END		0x54
 
 /* mode register */
 #define	MODER_RXEN	(1 <<  0) /* receive enable */
@@ -180,6 +181,7 @@ MODULE_PARM_DESC(buffer_size, "DMA buffer allocation size");
  * @membase:	pointer to buffer memory region
  * @dma_alloc:	dma allocated buffer size
  * @io_region_size:	I/O memory region size
+ * @num_bd:	number of buffer descriptors
  * @num_tx:	number of send buffers
  * @cur_tx:	last send buffer written
  * @dty_tx:	last buffer actually sent
@@ -200,6 +202,7 @@ struct ethoc {
 	int dma_alloc;
 	resource_size_t io_region_size;
 
+	unsigned int num_bd;
 	unsigned int num_tx;
 	unsigned int cur_tx;
 	unsigned int dty_tx;
@@ -900,6 +903,86 @@ out:
 	return NETDEV_TX_OK;
 }
 
+static int ethoc_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct ethoc *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phy;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_ethtool_gset(phydev, cmd);
+}
+
+static int ethoc_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct ethoc *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phy;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_ethtool_sset(phydev, cmd);
+}
+
+static int ethoc_get_regs_len(struct net_device *netdev)
+{
+	return ETH_END;
+}
+
+static void ethoc_get_regs(struct net_device *dev, struct ethtool_regs *regs,
+			   void *p)
+{
+	struct ethoc *priv = netdev_priv(dev);
+	u32 *regs_buff = p;
+	unsigned i;
+
+	regs->version = 0;
+	for (i = 0; i < ETH_END / sizeof(u32); ++i)
+		regs_buff[i] = ethoc_read(priv, i * sizeof(u32));
+}
+
+static void ethoc_get_ringparam(struct net_device *dev,
+				struct ethtool_ringparam *ring)
+{
+	struct ethoc *priv = netdev_priv(dev);
+
+	ring->rx_max_pending = priv->num_bd;
+	ring->rx_mini_max_pending = 0;
+	ring->rx_jumbo_max_pending = 0;
+	ring->tx_max_pending = priv->num_bd;
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
+const struct ethtool_ops ethoc_ethtool_ops = {
+	.get_settings = ethoc_get_settings,
+	.set_settings = ethoc_set_settings,
+	.get_regs_len = ethoc_get_regs_len,
+	.get_regs = ethoc_get_regs,
+	.get_link = ethtool_op_get_link,
+	.get_ringparam = ethoc_get_ringparam,
+	.set_ringparam = ethoc_set_ringparam,
+	.get_ts_info = ethtool_op_get_ts_info,
+};
+
 static const struct net_device_ops ethoc_netdev_ops = {
 	.ndo_open = ethoc_open,
 	.ndo_stop = ethoc_stop,
@@ -1028,6 +1111,7 @@ static int ethoc_probe(struct platform_device *pdev)
 		ret = -ENODEV;
 		goto error;
 	}
+	priv->num_bd = num_bd;
 	/* num_tx must be a power of two */
 	priv->num_tx = rounddown_pow_of_two(num_bd >> 1);
 	priv->num_rx = num_bd - priv->num_tx;
@@ -1148,6 +1232,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	netdev->netdev_ops = &ethoc_netdev_ops;
 	netdev->watchdog_timeo = ETHOC_TIMEOUT;
 	netdev->features |= 0;
+	netdev->ethtool_ops = &ethoc_ethtool_ops;
 
 	/* setup NAPI */
 	netif_napi_add(netdev, &priv->napi, ethoc_poll, 64);
-- 
1.8.1.4
