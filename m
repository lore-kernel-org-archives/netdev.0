From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH v2 4/4] net: ethoc: implement ethtool get/set ring parameters
Date: Fri, 31 Jan 2014 09:41:07 +0400
Message-ID: <1391146867-30508-5-git-send-email-jcmvbkbc@gmail.com>
References: <1391146867-30508-1-git-send-email-jcmvbkbc@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Marc Gauthier <marc@cadence.com>,
	Max Filippov <jcmvbkbc@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:62680 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751863AbaAaFvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 00:51:18 -0500
In-Reply-To: <1391146867-30508-1-git-send-email-jcmvbkbc@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TX and RX rings share memory and descriptors. Maximal number of
descriptors reported is one less than the total available nuber of
descriptors. For the set operation the requested number of TX descriptors
is rounded down to the nearest power of two (driver logic requirement).

Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
Changes v1->v2:
- fix set_ringparam: check ring sizes, change ring sizes on the fly.

 drivers/net/ethernet/ethoc.c | 51 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 5da32a7..f9c1cf5 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -180,6 +180,7 @@ MODULE_PARM_DESC(buffer_size, "DMA buffer allocation size");
  * @membase:	pointer to buffer memory region
  * @dma_alloc:	dma allocated buffer size
  * @io_region_size:	I/O memory region size
+ * @num_bd:	number of buffer descriptors
  * @num_tx:	number of send buffers
  * @cur_tx:	last send buffer written
  * @dty_tx:	last buffer actually sent
@@ -200,6 +201,7 @@ struct ethoc {
 	int dma_alloc;
 	resource_size_t io_region_size;
 
+	unsigned int num_bd;
 	unsigned int num_tx;
 	unsigned int cur_tx;
 	unsigned int dty_tx;
@@ -930,12 +932,60 @@ static void ethoc_get_regs(struct net_device *dev, struct ethtool_regs *regs,
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
+	if (ring->tx_pending < 1 || ring->rx_pending < 1 ||
+	    ring->tx_pending + ring->rx_pending > priv->num_bd)
+		return -EINVAL;
+	if (ring->rx_mini_pending || ring->rx_jumbo_pending)
+		return -EINVAL;
+
+	if (netif_running(dev)) {
+		netif_tx_disable(dev);
+		ethoc_disable_rx_and_tx(priv);
+		ethoc_disable_irq(priv, INT_MASK_TX | INT_MASK_RX);
+		synchronize_irq(dev->irq);
+	}
+
+	priv->num_tx = rounddown_pow_of_two(ring->tx_pending);
+	priv->num_rx = ring->rx_pending;
+	ethoc_init_ring(priv, dev->mem_start);
+
+	if (netif_running(dev)) {
+		ethoc_enable_irq(priv, INT_MASK_TX | INT_MASK_RX);
+		ethoc_enable_rx_and_tx(priv);
+		netif_wake_queue(dev);
+	}
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
 
@@ -1065,6 +1115,7 @@ static int ethoc_probe(struct platform_device *pdev)
 		ret = -ENODEV;
 		goto error;
 	}
+	priv->num_bd = num_bd;
 	/* num_tx must be a power of two */
 	priv->num_tx = rounddown_pow_of_two(num_bd >> 1);
 	priv->num_rx = num_bd - priv->num_tx;
-- 
1.8.1.4
