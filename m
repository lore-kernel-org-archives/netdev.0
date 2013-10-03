From: Andrea Merello <andrea.merello@gmail.com>
Subject: [PATCH] atl1e: enable support for NETIF_F_RXALL and NETIF_F_RXCRC features
Date: Thu,  3 Oct 2013 21:18:37 +0200
Message-ID: <1380827917-22992-1-git-send-email-andrea.merello@gmail.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andrea Merello <andrea.merello@gmail.com>
To: jie.yang@atheros.com, xiong.huang@atheros.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch allows (optionally, via ethtool) the atl1e NIC to:
- Receive bad frames (runt, bad-fcs, etc..)
- Receive full frames without stripping the FCS.

This has been tested on my board by injecting runt and bad-fcs
frames with a FPGA-based device.

The particular scenario of receiving very short frames (<4 bytes)
without passing FCS to the upper layer has been also tested:
This could be potentially dangerous because the driver performs a
4 byte subtraction on the frame length, but I finally have NOT
added anything to avoid this because it seems the NIC always
discards frames so much short..
If someone still have some reason to worry about this, please
tell me.. I will add an explicit SW check..

Signed-off-by: Andrea Merello <andrea.merello@gmail.com>
---
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c | 46 ++++++++++++++++++++++---
 1 file changed, 42 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 1966444..7a73f3a 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -313,6 +313,34 @@ static void atl1e_set_multi(struct net_device *netdev)
 	}
 }
 
+static void __atl1e_rx_mode(netdev_features_t features, u32 *mac_ctrl_data)
+{
+
+	if (features & NETIF_F_RXALL) {
+		/* enable RX of ALL frames */
+		*mac_ctrl_data |= MAC_CTRL_DBG;
+	} else {
+		/* disable RX of ALL frames */
+		*mac_ctrl_data &= ~MAC_CTRL_DBG;
+	}
+}
+
+static void atl1e_rx_mode(struct net_device *netdev,
+	netdev_features_t features)
+{
+	struct atl1e_adapter *adapter = netdev_priv(netdev);
+	u32 mac_ctrl_data = 0;
+
+	netdev_dbg(adapter->netdev, "%s\n", __func__);
+
+	atl1e_irq_disable(adapter);
+	mac_ctrl_data = AT_READ_REG(&adapter->hw, REG_MAC_CTRL);
+	__atl1e_rx_mode(features, &mac_ctrl_data);
+	AT_WRITE_REG(&adapter->hw, REG_MAC_CTRL, mac_ctrl_data);
+	atl1e_irq_enable(adapter);
+}
+
+
 static void __atl1e_vlan_mode(netdev_features_t features, u32 *mac_ctrl_data)
 {
 	if (features & NETIF_F_HW_VLAN_CTAG_RX) {
@@ -394,6 +422,10 @@ static int atl1e_set_features(struct net_device *netdev,
 	if (changed & NETIF_F_HW_VLAN_CTAG_RX)
 		atl1e_vlan_mode(netdev, features);
 
+	if (changed & NETIF_F_RXALL)
+		atl1e_rx_mode(netdev, features);
+
+
 	return 0;
 }
 
@@ -1057,7 +1089,8 @@ static void atl1e_setup_mac_ctrl(struct atl1e_adapter *adapter)
 		value |= MAC_CTRL_PROMIS_EN;
 	if (netdev->flags & IFF_ALLMULTI)
 		value |= MAC_CTRL_MC_ALL_EN;
-
+	if (netdev->features & NETIF_F_RXALL)
+		value |= MAC_CTRL_DBG;
 	AT_WRITE_REG(hw, REG_MAC_CTRL, value);
 }
 
@@ -1405,7 +1438,8 @@ static void atl1e_clean_rx_irq(struct atl1e_adapter *adapter, u8 que,
 			rx_page_desc[que].rx_nxseq++;
 
 			/* error packet */
-			if (prrs->pkt_flag & RRS_IS_ERR_FRAME) {
+			if ((prrs->pkt_flag & RRS_IS_ERR_FRAME) &&
+			    !(netdev->features & NETIF_F_RXALL)) {
 				if (prrs->err_flag & (RRS_ERR_BAD_CRC |
 					RRS_ERR_DRIBBLE | RRS_ERR_CODE |
 					RRS_ERR_TRUNC)) {
@@ -1418,7 +1452,10 @@ static void atl1e_clean_rx_irq(struct atl1e_adapter *adapter, u8 que,
 			}
 
 			packet_size = ((prrs->word1 >> RRS_PKT_SIZE_SHIFT) &
-					RRS_PKT_SIZE_MASK) - 4; /* CRC */
+					RRS_PKT_SIZE_MASK);
+			if (likely(!(netdev->features & NETIF_F_RXFCS)))
+				packet_size -= 4; /* CRC */
+
 			skb = netdev_alloc_skb_ip_align(netdev, packet_size);
 			if (skb == NULL)
 				goto skip_pkt;
@@ -2245,7 +2282,8 @@ static int atl1e_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
 			      NETIF_F_HW_VLAN_CTAG_RX;
 	netdev->features = netdev->hw_features | NETIF_F_LLTX |
 			   NETIF_F_HW_VLAN_CTAG_TX;
-
+	/* not enabled by default */
+	netdev->hw_features |= NETIF_F_RXALL | NETIF_F_RXFCS;
 	return 0;
 }
 
-- 
1.8.1.2
