From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 11/12] sfc: Allow for additional checksum offload features
Date: Sat, 28 Nov 2009 15:36:19 +0000
Message-ID: <1259422579.3709.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:59185 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473AbZK1PgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 10:36:16 -0500
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
index f5e8111..f4eba45 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2117,7 +2117,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	net_dev = alloc_etherdev(sizeof(*efx));
 	if (!net_dev)
 		return -ENOMEM;
-	net_dev->features |= (NETIF_F_IP_CSUM | NETIF_F_SG |
+	net_dev->features |= (type->offload_features | NETIF_F_SG |
 			      NETIF_F_HIGHDMA | NETIF_F_TSO |
 			      NETIF_F_GRO);
 	/* Mask for features that also apply to VLAN devices */
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 5d2e186..b3d0485 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -451,6 +451,19 @@ static void efx_ethtool_get_stats(struct net_device *net_dev,
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
@@ -733,7 +746,8 @@ const struct ethtool_ops efx_ethtool_ops = {
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
index 539d022..2096753 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -3250,6 +3250,7 @@ struct efx_nic_type falcon_a1_nic_type = {
 	.phys_addr_channels = 4,
 	.tx_dc_base = 0x130000,
 	.rx_dc_base = 0x100000,
+	.offload_features = NETIF_F_IP_CSUM,
 };
 
 struct efx_nic_type falcon_b0_nic_type = {
@@ -3275,5 +3276,6 @@ struct efx_nic_type falcon_b0_nic_type = {
 				   * channels */
 	.tx_dc_base = 0x130000,
 	.rx_dc_base = 0x100000,
+	.offload_features = NETIF_F_IP_CSUM,
 };
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 30fb21e..90f6a2a 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -859,6 +859,8 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
  *	descriptors
  * @tx_dc_base: Base address in SRAM of TX queue descriptor caches
  * @rx_dc_base: Base address in SRAM of RX queue descriptor caches
+ * @offload_features: net_device feature flags for protocol offload
+ *	features implemented in hardware
  */
 struct efx_nic_type {
 	struct efx_mac_operations *default_mac_ops;
@@ -876,6 +878,7 @@ struct efx_nic_type {
 	unsigned int phys_addr_channels;
 	unsigned int tx_dc_base;
 	unsigned int rx_dc_base;
+	unsigned long offload_features;
 };
 
 /**************************************************************************
-- 
1.6.5.3




-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

