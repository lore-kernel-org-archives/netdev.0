From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 05/12] sfc: Allow for additional checksum offload features
Date: Mon, 30 Nov 2009 01:11:02 +0000
Message-ID: <1259543462.3709.89.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:46685 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136AbZK3BK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:10:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    2 +-
 drivers/net/sfc/ethtool.c    |   16 +++++++++++++++-
 drivers/net/sfc/falcon.c     |    2 ++
 drivers/net/sfc/net_driver.h |    3 +++
 4 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 4fe6d63..c49d364 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2179,7 +2179,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	net_dev = alloc_etherdev(sizeof(*efx));
 	if (!net_dev)
 		return -ENOMEM;
-	net_dev->features |= (NETIF_F_IP_CSUM | NETIF_F_SG |
+	net_dev->features |= (type->offload_features | NETIF_F_SG |
 			      NETIF_F_HIGHDMA | NETIF_F_TSO |
 			      NETIF_F_GRO);
 	/* Mask for features that also apply to VLAN devices */
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 08a9db9..0a79ec7 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -468,6 +468,19 @@ static void efx_ethtool_get_stats(struct net_device *net_dev,
 	}
 }
 
+static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 enable)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	unsigned long features = efx->type->offload_features & NETIF_F_ALL_CSUM;
+
+	if (enable)
+		net_dev->features |= features;
+	else
+		net_dev->features &= ~features;
+
+	return 0;
+}
+
 static int efx_ethtool_set_rx_csum(struct net_device *net_dev, u32 enable)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
@@ -813,7 +826,8 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.get_rx_csum		= efx_ethtool_get_rx_csum,
 	.set_rx_csum		= efx_ethtool_set_rx_csum,
 	.get_tx_csum		= ethtool_op_get_tx_csum,
-	.set_tx_csum		= ethtool_op_set_tx_csum,
+	/* Need to enable/disable IPv6 too */
+	.set_tx_csum		= efx_ethtool_set_tx_csum,
 	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
 	.get_tso		= ethtool_op_get_tso,
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 950de84..f77bbbe 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -3304,6 +3304,7 @@ struct efx_nic_type falcon_a1_nic_type = {
 	.phys_addr_channels = 4,
 	.tx_dc_base = 0x130000,
 	.rx_dc_base = 0x100000,
+	.offload_features = NETIF_F_IP_CSUM,
 	.reset_world_flags = ETH_RESET_IRQ,
 };
 
@@ -3351,6 +3352,7 @@ struct efx_nic_type falcon_b0_nic_type = {
 				   * channels */
 	.tx_dc_base = 0x130000,
 	.rx_dc_base = 0x100000,
+	.offload_features = NETIF_F_IP_CSUM,
 	.reset_world_flags = ETH_RESET_IRQ,
 };
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index e1534ba..96d3f00 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -864,6 +864,8 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
  *	descriptors
  * @tx_dc_base: Base address in SRAM of TX queue descriptor caches
  * @rx_dc_base: Base address in SRAM of RX queue descriptor caches
+ * @offload_features: net_device feature flags for protocol offload
+ *	features implemented in hardware
  * @reset_world_flags: Flags for additional components covered by
  *	reset method RESET_TYPE_WORLD
  */
@@ -904,6 +906,7 @@ struct efx_nic_type {
 	unsigned int phys_addr_channels;
 	unsigned int tx_dc_base;
 	unsigned int rx_dc_base;
+	unsigned long offload_features;
 	u32 reset_world_flags;
 };
 
-- 
1.6.5.3




-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

