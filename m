From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: et131x: use phydev from struct net_device
Date: Fri, 17 Jun 2016 23:32:14 +0200
Message-ID: <1466199135-13459-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: mark.einon@gmail.com, davem@davemloft.net, andrew@lunn.ch,
	mugunthanvnm@ti.com, felipe.balbi@linux.intel.com,
	f.fainelli@gmail.com, fw@strlen.de, wuninsu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/agere/et131x.c |   48 +++++++++++++---------------------
 1 files changed, 18 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet/agere/et131x.c
index 30defe6..d194992 100644
--- a/drivers/net/ethernet/agere/et131x.c
+++ b/drivers/net/ethernet/agere/et131x.c
@@ -440,7 +440,6 @@ struct et131x_adapter {
 	struct net_device *netdev;
 	struct pci_dev *pdev;
 	struct mii_bus *mii_bus;
-	struct phy_device *phydev;
 	struct napi_struct napi;
 
 	/* Flags that indicate current state of the adapter */
@@ -864,7 +863,7 @@ static void et1310_config_mac_regs2(struct et131x_adapter *adapter)
 {
 	int32_t delay = 0;
 	struct mac_regs __iomem *mac = &adapter->regs->mac;
-	struct phy_device *phydev = adapter->phydev;
+	struct phy_device *phydev = adapter->netdev->phydev;
 	u32 cfg1;
 	u32 cfg2;
 	u32 ifctrl;
@@ -1035,7 +1034,7 @@ static void et1310_setup_device_for_unicast(struct et131x_adapter *adapter)
 static void et1310_config_rxmac_regs(struct et131x_adapter *adapter)
 {
 	struct rxmac_regs __iomem *rxmac = &adapter->regs->rxmac;
-	struct phy_device *phydev = adapter->phydev;
+	struct phy_device *phydev = adapter->netdev->phydev;
 	u32 sa_lo;
 	u32 sa_hi = 0;
 	u32 pf_ctrl = 0;
@@ -1230,7 +1229,7 @@ out:
 
 static int et131x_mii_read(struct et131x_adapter *adapter, u8 reg, u16 *value)
 {
-	struct phy_device *phydev = adapter->phydev;
+	struct phy_device *phydev = adapter->netdev->phydev;
 
 	if (!phydev)
 		return -EIO;
@@ -1311,7 +1310,7 @@ static void et1310_phy_read_mii_bit(struct et131x_adapter *adapter,
 
 static void et1310_config_flow_control(struct et131x_adapter *adapter)
 {
-	struct phy_device *phydev = adapter->phydev;
+	struct phy_device *phydev = adapter->netdev->phydev;
 
 	if (phydev->duplex == DUPLEX_HALF) {
 		adapter->flow = FLOW_NONE;
@@ -1456,7 +1455,7 @@ static int et131x_mdio_write(struct mii_bus *bus, int phy_addr,
 static void et1310_phy_power_switch(struct et131x_adapter *adapter, bool down)
 {
 	u16 data;
-	struct  phy_device *phydev = adapter->phydev;
+	struct  phy_device *phydev = adapter->netdev->phydev;
 
 	et131x_mii_read(adapter, MII_BMCR, &data);
 	data &= ~BMCR_PDOWN;
@@ -1469,7 +1468,7 @@ static void et1310_phy_power_switch(struct et131x_adapter *adapter, bool down)
 static void et131x_xcvr_init(struct et131x_adapter *adapter)
 {
 	u16 lcr2;
-	struct  phy_device *phydev = adapter->phydev;
+	struct  phy_device *phydev = adapter->netdev->phydev;
 
 	/* Set the LED behavior such that LED 1 indicates speed (off =
 	 * 10Mbits, blink = 100Mbits, on = 1000Mbits) and LED 2 indicates
@@ -2111,7 +2110,7 @@ static int et131x_init_recv(struct et131x_adapter *adapter)
 /* et131x_set_rx_dma_timer - Set the heartbeat timer according to line rate */
 static void et131x_set_rx_dma_timer(struct et131x_adapter *adapter)
 {
-	struct phy_device *phydev = adapter->phydev;
+	struct phy_device *phydev = adapter->netdev->phydev;
 
 	/* For version B silicon, we do not use the RxDMA timer for 10 and 100
 	 * Mbits/s line rates. We do not enable and RxDMA interrupt coalescing.
@@ -2426,7 +2425,7 @@ static int nic_send_packet(struct et131x_adapter *adapter, struct tcb *tcb)
 	struct sk_buff *skb = tcb->skb;
 	u32 nr_frags = skb_shinfo(skb)->nr_frags + 1;
 	struct skb_frag_struct *frags = &skb_shinfo(skb)->frags[0];
-	struct phy_device *phydev = adapter->phydev;
+	struct phy_device *phydev = adapter->netdev->phydev;
 	dma_addr_t dma_addr;
 	struct tx_ring *tx_ring = &adapter->tx_ring;
 
@@ -2794,17 +2793,13 @@ static void et131x_handle_send_pkts(struct et131x_adapter *adapter)
 static int et131x_get_settings(struct net_device *netdev,
 			       struct ethtool_cmd *cmd)
 {
-	struct et131x_adapter *adapter = netdev_priv(netdev);
-
-	return phy_ethtool_gset(adapter->phydev, cmd);
+	return phy_ethtool_gset(netdev->phydev, cmd);
 }
 
 static int et131x_set_settings(struct net_device *netdev,
 			       struct ethtool_cmd *cmd)
 {
-	struct et131x_adapter *adapter = netdev_priv(netdev);
-
-	return phy_ethtool_sset(adapter->phydev, cmd);
+	return phy_ethtool_sset(netdev->phydev, cmd);
 }
 
 static int et131x_get_regs_len(struct net_device *netdev)
@@ -3098,7 +3093,7 @@ err_out:
 static void et131x_error_timer_handler(unsigned long data)
 {
 	struct et131x_adapter *adapter = (struct et131x_adapter *)data;
-	struct phy_device *phydev = adapter->phydev;
+	struct phy_device *phydev = adapter->netdev->phydev;
 
 	if (et1310_in_phy_coma(adapter)) {
 		/* Bring the device immediately out of coma, to
@@ -3168,7 +3163,7 @@ static int et131x_adapter_memory_alloc(struct et131x_adapter *adapter)
 static void et131x_adjust_link(struct net_device *netdev)
 {
 	struct et131x_adapter *adapter = netdev_priv(netdev);
-	struct  phy_device *phydev = adapter->phydev;
+	struct  phy_device *phydev = netdev->phydev;
 
 	if (!phydev)
 		return;
@@ -3287,7 +3282,6 @@ static int et131x_mii_probe(struct net_device *netdev)
 
 	phydev->advertising = phydev->supported;
 	phydev->autoneg = AUTONEG_ENABLE;
-	adapter->phydev = phydev;
 
 	phy_attached_info(phydev);
 
@@ -3323,7 +3317,7 @@ static void et131x_pci_remove(struct pci_dev *pdev)
 
 	unregister_netdev(netdev);
 	netif_napi_del(&adapter->napi);
-	phy_disconnect(adapter->phydev);
+	phy_disconnect(netdev->phydev);
 	mdiobus_unregister(adapter->mii_bus);
 	mdiobus_free(adapter->mii_bus);
 
@@ -3338,20 +3332,16 @@ static void et131x_pci_remove(struct pci_dev *pdev)
 
 static void et131x_up(struct net_device *netdev)
 {
-	struct et131x_adapter *adapter = netdev_priv(netdev);
-
 	et131x_enable_txrx(netdev);
-	phy_start(adapter->phydev);
+	phy_start(netdev->phydev);
 }
 
 static void et131x_down(struct net_device *netdev)
 {
-	struct et131x_adapter *adapter = netdev_priv(netdev);
-
 	/* Save the timestamp for the TX watchdog, prevent a timeout */
 	netif_trans_update(netdev);
 
-	phy_stop(adapter->phydev);
+	phy_stop(netdev->phydev);
 	et131x_disable_txrx(netdev);
 }
 
@@ -3684,12 +3674,10 @@ static int et131x_close(struct net_device *netdev)
 static int et131x_ioctl(struct net_device *netdev, struct ifreq *reqbuf,
 			int cmd)
 {
-	struct et131x_adapter *adapter = netdev_priv(netdev);
-
-	if (!adapter->phydev)
+	if (!netdev->phydev)
 		return -EINVAL;
 
-	return phy_mii_ioctl(adapter->phydev, reqbuf, cmd);
+	return phy_mii_ioctl(netdev->phydev, reqbuf, cmd);
 }
 
 /* et131x_set_packet_filter - Configures the Rx Packet filtering */
@@ -4073,7 +4061,7 @@ out:
 	return rc;
 
 err_phy_disconnect:
-	phy_disconnect(adapter->phydev);
+	phy_disconnect(netdev->phydev);
 err_mdio_unregister:
 	mdiobus_unregister(adapter->mii_bus);
 err_mdio_free:
-- 
1.7.4.4
