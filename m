From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/6] sfc: Implement generic features interface
Date: Sun, 03 Apr 2011 20:51:21 +0100
Message-ID: <1301860281.2935.25.camel@localhost>
References: <1301859889.2935.23.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:9831 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753271Ab1DCTvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 15:51:25 -0400
In-Reply-To: <1301859889.2935.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   17 ++++++++-
 drivers/net/sfc/ethtool.c    |   78 ------------------------------------------
 drivers/net/sfc/net_driver.h |    2 -
 drivers/net/sfc/rx.c         |    2 +-
 4 files changed, 16 insertions(+), 83 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index d890679..98da250 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1874,6 +1874,17 @@ static void efx_set_multicast_list(struct net_device *net_dev)
 	/* Otherwise efx_start_port() will do this */
 }
 
+static int efx_set_features(struct net_device *net_dev, u32 data)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+
+	/* If disabling RX n-tuple filtering, clear existing filters */
+	if (net_dev->features & ~data & NETIF_F_NTUPLE)
+		efx_filter_clear_rx(efx, EFX_FILTER_PRI_MANUAL);
+
+	return 0;
+}
+
 static const struct net_device_ops efx_netdev_ops = {
 	.ndo_open		= efx_net_open,
 	.ndo_stop		= efx_net_stop,
@@ -1885,6 +1896,7 @@ static const struct net_device_ops efx_netdev_ops = {
 	.ndo_change_mtu		= efx_change_mtu,
 	.ndo_set_mac_address	= efx_set_mac_address,
 	.ndo_set_multicast_list = efx_set_multicast_list,
+	.ndo_set_features	= efx_set_features,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = efx_netpoll,
 #endif
@@ -2269,7 +2281,6 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	strlcpy(efx->name, pci_name(pci_dev), sizeof(efx->name));
 
 	efx->net_dev = net_dev;
-	efx->rx_checksum_enabled = true;
 	spin_lock_init(&efx->stats_lock);
 	mutex_init(&efx->mac_lock);
 	efx->mac_op = type->default_mac_ops;
@@ -2452,12 +2463,14 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 		return -ENOMEM;
 	net_dev->features |= (type->offload_features | NETIF_F_SG |
 			      NETIF_F_HIGHDMA | NETIF_F_TSO |
-			      NETIF_F_GRO);
+			      NETIF_F_GRO | NETIF_F_RXCSUM);
 	if (type->offload_features & NETIF_F_V6_CSUM)
 		net_dev->features |= NETIF_F_TSO6;
 	/* Mask for features that also apply to VLAN devices */
 	net_dev->vlan_features |= (NETIF_F_ALL_CSUM | NETIF_F_SG |
 				   NETIF_F_HIGHDMA | NETIF_F_TSO);
+	/* All offloads can be toggled */
+	net_dev->hw_features = net_dev->features & ~NETIF_F_HIGHDMA;
 	efx = netdev_priv(net_dev);
 	pci_set_drvdata(pci_dev, efx);
 	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 807178e..0d55439 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -518,72 +518,6 @@ static void efx_ethtool_get_stats(struct net_device *net_dev,
 	}
 }
 
-static int efx_ethtool_set_tso(struct net_device *net_dev, u32 enable)
-{
-	struct efx_nic *efx __attribute__ ((unused)) = netdev_priv(net_dev);
-	u32 features;
-
-	features = NETIF_F_TSO;
-	if (efx->type->offload_features & NETIF_F_V6_CSUM)
-		features |= NETIF_F_TSO6;
-
-	if (enable)
-		net_dev->features |= features;
-	else
-		net_dev->features &= ~features;
-
-	return 0;
-}
-
-static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 enable)
-{
-	struct efx_nic *efx = netdev_priv(net_dev);
-	u32 features = efx->type->offload_features & NETIF_F_ALL_CSUM;
-
-	if (enable)
-		net_dev->features |= features;
-	else
-		net_dev->features &= ~features;
-
-	return 0;
-}
-
-static int efx_ethtool_set_rx_csum(struct net_device *net_dev, u32 enable)
-{
-	struct efx_nic *efx = netdev_priv(net_dev);
-
-	/* No way to stop the hardware doing the checks; we just
-	 * ignore the result.
-	 */
-	efx->rx_checksum_enabled = !!enable;
-
-	return 0;
-}
-
-static u32 efx_ethtool_get_rx_csum(struct net_device *net_dev)
-{
-	struct efx_nic *efx = netdev_priv(net_dev);
-
-	return efx->rx_checksum_enabled;
-}
-
-static int efx_ethtool_set_flags(struct net_device *net_dev, u32 data)
-{
-	struct efx_nic *efx = netdev_priv(net_dev);
-	u32 supported = (efx->type->offload_features &
-			 (ETH_FLAG_RXHASH | ETH_FLAG_NTUPLE));
-	int rc;
-
-	rc = ethtool_op_set_flags(net_dev, data, supported);
-	if (rc)
-		return rc;
-
-	if (!(data & ETH_FLAG_NTUPLE))
-		efx_filter_clear_rx(efx, EFX_FILTER_PRI_MANUAL);
-
-	return 0;
-}
-
 static void efx_ethtool_self_test(struct net_device *net_dev,
 				  struct ethtool_test *test, u64 *data)
 {
@@ -1070,18 +1004,6 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.set_ringparam		= efx_ethtool_set_ringparam,
 	.get_pauseparam         = efx_ethtool_get_pauseparam,
 	.set_pauseparam         = efx_ethtool_set_pauseparam,
-	.get_rx_csum		= efx_ethtool_get_rx_csum,
-	.set_rx_csum		= efx_ethtool_set_rx_csum,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
-	/* Need to enable/disable IPv6 too */
-	.set_tx_csum		= efx_ethtool_set_tx_csum,
-	.get_sg			= ethtool_op_get_sg,
-	.set_sg			= ethtool_op_set_sg,
-	.get_tso		= ethtool_op_get_tso,
-	/* Need to enable/disable TSO-IPv6 too */
-	.set_tso		= efx_ethtool_set_tso,
-	.get_flags		= ethtool_op_get_flags,
-	.set_flags		= efx_ethtool_set_flags,
 	.get_sset_count		= efx_ethtool_get_sset_count,
 	.self_test		= efx_ethtool_self_test,
 	.get_strings		= efx_ethtool_get_strings,
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 215d5c5..f0f8ca5 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -681,7 +681,6 @@ struct efx_filter_state;
  * @port_inhibited: If set, the netif_carrier is always off. Hold the mac_lock
  * @port_initialized: Port initialized?
  * @net_dev: Operating system network device. Consider holding the rtnl lock
- * @rx_checksum_enabled: RX checksumming enabled
  * @stats_buffer: DMA buffer for statistics
  * @mac_op: MAC interface
  * @phy_type: PHY type
@@ -771,7 +770,6 @@ struct efx_nic {
 
 	bool port_initialized;
 	struct net_device *net_dev;
-	bool rx_checksum_enabled;
 
 	struct efx_buffer stats_buffer;
 
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index fb402c5..b7dc891 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -605,7 +605,7 @@ void __efx_rx_packet(struct efx_channel *channel,
 		skb_record_rx_queue(skb, channel->channel);
 	}
 
-	if (unlikely(!efx->rx_checksum_enabled))
+	if (unlikely(!(efx->net_dev->features & NETIF_F_RXCSUM)))
 		checksummed = false;
 
 	if (likely(checksummed || rx_buf->is_page)) {
-- 
1.5.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

