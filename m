From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 12/15] ethernet/ibm: use core min/max MTU checking
Date: Mon, 17 Oct 2016 15:54:14 -0400
Message-ID: <20161017195417.48259-13-jarod@redhat.com>
References: <20161017195417.48259-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Douglas Miller <dougmill@linux.vnet.ibm.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017195417.48259-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ehea: min_mtu 68, max_mtu 9022
- remove ehea_change_mtu, it's now redundant

emac: min_mtu 46, max_mtu 1500 or whatever gets read from OF

CC: netdev@vger.kernel.org
CC: Douglas Miller <dougmill@linux.vnet.ibm.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c | 13 ++++---------
 drivers/net/ethernet/ibm/emac/core.c      |  9 +++++----
 2 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 54efa9a..e9719ba 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -1981,14 +1981,6 @@ static void ehea_set_multicast_list(struct net_device *dev)
 	ehea_update_bcmc_registrations();
 }
 
-static int ehea_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu < 68) || (new_mtu > EHEA_MAX_PACKET_SIZE))
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 static void xmit_common(struct sk_buff *skb, struct ehea_swqe *swqe)
 {
 	swqe->tx_control |= EHEA_SWQE_IMM_DATA_PRESENT | EHEA_SWQE_CRC;
@@ -2968,7 +2960,6 @@ static const struct net_device_ops ehea_netdev_ops = {
 	.ndo_set_mac_address	= ehea_set_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_rx_mode	= ehea_set_multicast_list,
-	.ndo_change_mtu		= ehea_change_mtu,
 	.ndo_vlan_rx_add_vid	= ehea_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= ehea_vlan_rx_kill_vid,
 	.ndo_tx_timeout		= ehea_tx_watchdog,
@@ -3041,6 +3032,10 @@ static struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 			NETIF_F_IP_CSUM;
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
 
+	/* MTU range: 68 - 9022 */
+	dev->min_mtu = ETH_MIN_MTU;
+	dev->max_mtu = EHEA_MAX_PACKET_SIZE;
+
 	INIT_WORK(&port->reset_task, ehea_reset_port);
 	INIT_DELAYED_WORK(&port->stats_work, ehea_update_stats);
 
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 5d804a5..52a69c9 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -1099,9 +1099,6 @@ static int emac_change_mtu(struct net_device *ndev, int new_mtu)
 	struct emac_instance *dev = netdev_priv(ndev);
 	int ret = 0;
 
-	if (new_mtu < EMAC_MIN_MTU || new_mtu > dev->max_mtu)
-		return -EINVAL;
-
 	DBG(dev, "change_mtu(%d)" NL, new_mtu);
 
 	if (netif_running(ndev)) {
@@ -2564,7 +2561,7 @@ static int emac_init_config(struct emac_instance *dev)
 	if (emac_read_uint_prop(np, "cell-index", &dev->cell_index, 1))
 		return -ENXIO;
 	if (emac_read_uint_prop(np, "max-frame-size", &dev->max_mtu, 0))
-		dev->max_mtu = 1500;
+		dev->max_mtu = ETH_DATA_LEN;
 	if (emac_read_uint_prop(np, "rx-fifo-size", &dev->rx_fifo_size, 0))
 		dev->rx_fifo_size = 2048;
 	if (emac_read_uint_prop(np, "tx-fifo-size", &dev->tx_fifo_size, 0))
@@ -2890,6 +2887,10 @@ static int emac_probe(struct platform_device *ofdev)
 		ndev->netdev_ops = &emac_netdev_ops;
 	ndev->ethtool_ops = &emac_ethtool_ops;
 
+	/* MTU range: 46 - 1500 or whatever is in OF */
+	ndev->min_mtu = EMAC_MIN_MTU;
+	ndev->max_mtu = dev->max_mtu;
+
 	netif_carrier_off(ndev);
 
 	err = register_netdev(ndev);
-- 
2.10.0
