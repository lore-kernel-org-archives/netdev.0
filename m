From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 03/17] sfc: Add efx_nic member with fixed netdev
 features
Date: Wed, 15 Jun 2016 17:43:20 +0100
Message-ID: <df02d496-ce4f-33f2-e4b9-6a6bdd7481ad@solarflare.com>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:30509 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752760AbcFOQu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:50:28 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

It allows to change set of fixed features on datapath reset.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        | 18 ++++++++++++++----
 drivers/net/ethernet/sfc/net_driver.h |  3 +++
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 097f363..2eecd28 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -600,6 +600,7 @@ fail:
  */
 static void efx_start_datapath(struct efx_nic *efx)
 {
+	netdev_features_t old_features = efx->net_dev->features;
 	bool old_rx_scatter = efx->rx_scatter;
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
@@ -644,6 +645,15 @@ static void efx_start_datapath(struct efx_nic *efx)
 			  efx->rx_dma_len, efx->rx_page_buf_step,
 			  efx->rx_bufs_per_page, efx->rx_pages_per_batch);
 
+	/* Restore previously fixed features in hw_features and remove
+	 * features which are fixed now
+	 */
+	efx->net_dev->hw_features |= efx->net_dev->features;
+	efx->net_dev->hw_features &= ~efx->fixed_features;
+	efx->net_dev->features |= efx->fixed_features;
+	if (efx->net_dev->features != old_features)
+		netdev_features_change(efx->net_dev);
+
 	/* RX filters may also have scatter-enabled flags */
 	if (efx->rx_scatter != old_rx_scatter)
 		efx->type->filter_update_rx_scatter(efx);
@@ -3147,17 +3157,17 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
 		return -ENOMEM;
 	efx = netdev_priv(net_dev);
 	efx->type = (const struct efx_nic_type *) entry->driver_data;
+	efx->fixed_features |= NETIF_F_HIGHDMA;
 	net_dev->features |= (efx->type->offload_features | NETIF_F_SG |
-			      NETIF_F_HIGHDMA | NETIF_F_TSO |
-			      NETIF_F_RXCSUM);
+			      NETIF_F_TSO | NETIF_F_RXCSUM);
 	if (efx->type->offload_features & (NETIF_F_IPV6_CSUM | NETIF_F_HW_CSUM))
 		net_dev->features |= NETIF_F_TSO6;
 	/* Mask for features that also apply to VLAN devices */
 	net_dev->vlan_features |= (NETIF_F_HW_CSUM | NETIF_F_SG |
 				   NETIF_F_HIGHDMA | NETIF_F_ALL_TSO |
 				   NETIF_F_RXCSUM);
-	/* All offloads can be toggled */
-	net_dev->hw_features = net_dev->features & ~NETIF_F_HIGHDMA;
+	net_dev->features |= efx->fixed_features;
+	net_dev->hw_features = net_dev->features & ~efx->fixed_features;
 	pci_set_drvdata(pci_dev, efx);
 	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
 	rc = efx_init_struct(efx, pci_dev, net_dev);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 77cd23c..26abb5c 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -868,6 +868,7 @@ struct vfdi_status;
  *	be held to modify it.
  * @port_initialized: Port initialized?
  * @net_dev: Operating system network device. Consider holding the rtnl lock
+ * @fixed_features: Features which cannot be turned off
  * @stats_buffer: DMA buffer for statistics
  * @phy_type: PHY type
  * @phy_op: PHY interface
@@ -1007,6 +1008,8 @@ struct efx_nic {
 	bool port_initialized;
 	struct net_device *net_dev;
 
+	netdev_features_t fixed_features;
+
 	struct efx_buffer stats_buffer;
 	u64 rx_nodesc_drops_total;
 	u64 rx_nodesc_drops_while_down;
