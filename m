From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 32/37] atl1c: refine start/enable code for MAC module
Date: Fri, 13 Apr 2012 08:14:57 +0800
Message-ID: <1334276102-15866-33-git-send-email-xiong@qca.qualcomm.com>
References: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:18606 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966683Ab2DMAUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 20:20:02 -0400
In-Reply-To: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

merge TXQ/RXQ/MAC start/enable code to one function as they
are started/enabled at the same time, just like stop/disable them
in the function of atl1c_stop_mac.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   89 +++++++----------------
 1 files changed, 28 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 8c2f28c..db60325 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -53,11 +53,9 @@ MODULE_LICENSE("GPL");
 MODULE_VERSION(ATL1C_DRV_VERSION);
 
 static int atl1c_stop_mac(struct atl1c_hw *hw);
-static void atl1c_enable_rx_ctrl(struct atl1c_hw *hw);
-static void atl1c_enable_tx_ctrl(struct atl1c_hw *hw);
 static void atl1c_disable_l0s_l1(struct atl1c_hw *hw);
 static void atl1c_set_aspm(struct atl1c_hw *hw, u16 link_speed);
-static void atl1c_setup_mac_ctrl(struct atl1c_adapter *adapter);
+static void atl1c_start_mac(struct atl1c_adapter *adapter);
 static void atl1c_clean_rx_irq(struct atl1c_adapter *adapter,
 		   int *work_done, int work_to_do);
 static int atl1c_up(struct atl1c_adapter *adapter);
@@ -270,9 +268,7 @@ static void atl1c_check_link_status(struct atl1c_adapter *adapter)
 			adapter->link_speed  = speed;
 			adapter->link_duplex = duplex;
 			atl1c_set_aspm(hw, speed);
-			atl1c_enable_tx_ctrl(hw);
-			atl1c_enable_rx_ctrl(hw);
-			atl1c_setup_mac_ctrl(adapter);
+			atl1c_start_mac(adapter);
 			if (netif_msg_link(adapter))
 				dev_info(&pdev->dev,
 					"%s: %s NIC Link is Up<%d Mbps %s>\n",
@@ -1130,22 +1126,36 @@ static int atl1c_stop_mac(struct atl1c_hw *hw)
 		IDLE_STATUS_TXMAC_BUSY | IDLE_STATUS_RXMAC_BUSY);
 }
 
-static void atl1c_enable_rx_ctrl(struct atl1c_hw *hw)
+static void atl1c_start_mac(struct atl1c_adapter *adapter)
 {
-	u32 data;
+	struct atl1c_hw *hw = &adapter->hw;
+	u32 mac, txq, rxq;
 
-	AT_READ_REG(hw, REG_RXQ_CTRL, &data);
-	data |= RXQ_CTRL_EN;
-	AT_WRITE_REG(hw, REG_RXQ_CTRL, data);
-}
+	hw->mac_duplex = adapter->link_duplex == FULL_DUPLEX ? true : false;
+	hw->mac_speed = adapter->link_speed == SPEED_1000 ?
+		atl1c_mac_speed_1000 : atl1c_mac_speed_10_100;
 
-static void atl1c_enable_tx_ctrl(struct atl1c_hw *hw)
-{
-	u32 data;
+	AT_READ_REG(hw, REG_TXQ_CTRL, &txq);
+	AT_READ_REG(hw, REG_RXQ_CTRL, &rxq);
+	AT_READ_REG(hw, REG_MAC_CTRL, &mac);
 
-	AT_READ_REG(hw, REG_TXQ_CTRL, &data);
-	data |= TXQ_CTRL_EN;
-	AT_WRITE_REG(hw, REG_TXQ_CTRL, data);
+	txq |= TXQ_CTRL_EN;
+	rxq |= RXQ_CTRL_EN;
+	mac |= MAC_CTRL_TX_EN | MAC_CTRL_TX_FLOW |
+	       MAC_CTRL_RX_EN | MAC_CTRL_RX_FLOW |
+	       MAC_CTRL_ADD_CRC | MAC_CTRL_PAD |
+	       MAC_CTRL_BC_EN | MAC_CTRL_SINGLE_PAUSE_EN |
+	       MAC_CTRL_HASH_ALG_CRC32;
+	if (hw->mac_duplex)
+		mac |= MAC_CTRL_DUPLX;
+	else
+		mac &= ~MAC_CTRL_DUPLX;
+	mac = FIELD_SETX(mac, MAC_CTRL_SPEED, hw->mac_speed);
+	mac = FIELD_SETX(mac, MAC_CTRL_PRMLEN, hw->preamble_len);
+
+	AT_WRITE_REG(hw, REG_TXQ_CTRL, txq);
+	AT_WRITE_REG(hw, REG_RXQ_CTRL, rxq);
+	AT_WRITE_REG(hw, REG_MAC_CTRL, mac);
 }
 
 /*
@@ -1294,49 +1304,6 @@ static void atl1c_set_aspm(struct atl1c_hw *hw, u16 link_speed)
 	return;
 }
 
-static void atl1c_setup_mac_ctrl(struct atl1c_adapter *adapter)
-{
-	struct atl1c_hw *hw = &adapter->hw;
-	struct net_device *netdev = adapter->netdev;
-	u32 mac_ctrl_data;
-
-	mac_ctrl_data = MAC_CTRL_TX_EN | MAC_CTRL_RX_EN;
-	mac_ctrl_data |= (MAC_CTRL_TX_FLOW | MAC_CTRL_RX_FLOW);
-
-	if (adapter->link_duplex == FULL_DUPLEX) {
-		hw->mac_duplex = true;
-		mac_ctrl_data |= MAC_CTRL_DUPLX;
-	}
-
-	if (adapter->link_speed == SPEED_1000)
-		hw->mac_speed = atl1c_mac_speed_1000;
-	else
-		hw->mac_speed = atl1c_mac_speed_10_100;
-
-	mac_ctrl_data |= (hw->mac_speed & MAC_CTRL_SPEED_MASK) <<
-			MAC_CTRL_SPEED_SHIFT;
-
-	mac_ctrl_data |= (MAC_CTRL_ADD_CRC | MAC_CTRL_PAD);
-	mac_ctrl_data |= ((hw->preamble_len & MAC_CTRL_PRMLEN_MASK) <<
-			MAC_CTRL_PRMLEN_SHIFT);
-
-	__atl1c_vlan_mode(netdev->features, &mac_ctrl_data);
-
-	mac_ctrl_data |= MAC_CTRL_BC_EN;
-	if (netdev->flags & IFF_PROMISC)
-		mac_ctrl_data |= MAC_CTRL_PROMIS_EN;
-	if (netdev->flags & IFF_ALLMULTI)
-		mac_ctrl_data |= MAC_CTRL_MC_ALL_EN;
-
-	mac_ctrl_data |= MAC_CTRL_SINGLE_PAUSE_EN;
-	if (hw->nic_type == athr_l1d || hw->nic_type == athr_l2c_b2 ||
-	    hw->nic_type == athr_l1d_2) {
-		mac_ctrl_data |= MAC_CTRL_SPEED_MODE_SW;
-		mac_ctrl_data |= MAC_CTRL_HASH_ALG_CRC32;
-	}
-	AT_WRITE_REG(hw, REG_MAC_CTRL, mac_ctrl_data);
-}
-
 /*
  * atl1c_configure - Configure Transmit&Receive Unit after Reset
  * @adapter: board private structure
-- 
1.7.7
