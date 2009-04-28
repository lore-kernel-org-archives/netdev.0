From: <jie.yang@atheros.com>
Subject: [PATCH net-next] atl1c: disable L1/L0s when link detected
Date: Tue, 28 Apr 2009 13:42:03 +0800
Message-ID: <1240897323258-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Jie Yang <jie.yang@atheros.com>
To: <davem@davemloft.net>, <bjoern.kiefer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atheros.com ([12.36.123.2]:10500 "EHLO mail.atheros.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750965AbZD1FmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 01:42:09 -0400
Received: from mail.atheros.com ([10.10.20.105])
	by sidewinder.atheros.com
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 22:42:09 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jie Yang <jie.yang@atheros.com>

Disable L1/L0s when link detected. We enable L1/L0s when link connected
before, but there is some hareware error on some platform. So just diable
this feature when link connected. This feature is about power saving.

Signed-off-by: Jie Yang <jie.yang@atheros.com>
---
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index deb7b53..8b17278 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -220,11 +220,11 @@ static void atl1c_check_link_status(struct atl1c_adapter *adapter)
 		/* link down */
 		if (netif_carrier_ok(netdev)) {
 			hw->hibernate = true;
-			atl1c_set_aspm(hw, false);
 			if (atl1c_stop_mac(hw) != 0)
 				if (netif_msg_hw(adapter))
 					dev_warn(&pdev->dev,
 						"stop mac failed\n");
+			atl1c_set_aspm(hw, false);
 		}
 		netif_carrier_off(netdev);
 	} else {
@@ -240,10 +240,10 @@ static void atl1c_check_link_status(struct atl1c_adapter *adapter)
 		    adapter->link_duplex != duplex) {
 			adapter->link_speed  = speed;
 			adapter->link_duplex = duplex;
+			atl1c_set_aspm(hw, true);
 			atl1c_enable_tx_ctrl(hw);
 			atl1c_enable_rx_ctrl(hw);
 			atl1c_setup_mac_ctrl(adapter);
-			atl1c_set_aspm(hw, true);
 			if (netif_msg_link(adapter))
 				dev_info(&pdev->dev,
 					"%s: %s NIC Link is Up<%d Mbps %s>\n",
@@ -1242,9 +1242,7 @@ static void atl1c_set_aspm(struct atl1c_hw *hw, bool linkup)
 
 	AT_READ_REG(hw, REG_PM_CTRL, &pm_ctrl_data);
 
-	pm_ctrl_data &= PM_CTRL_SERDES_PD_EX_L1;
-	pm_ctrl_data |= ~PM_CTRL_SERDES_BUDS_RX_L1_EN;
-	pm_ctrl_data |= ~PM_CTRL_SERDES_L1_EN;
+	pm_ctrl_data &= ~PM_CTRL_SERDES_PD_EX_L1;
 	pm_ctrl_data &=  ~(PM_CTRL_L1_ENTRY_TIMER_MASK <<
 			PM_CTRL_L1_ENTRY_TIMER_SHIFT);
 
@@ -1254,19 +1252,11 @@ static void atl1c_set_aspm(struct atl1c_hw *hw, bool linkup)
 		pm_ctrl_data |= PM_CTRL_SERDES_PLL_L1_EN;
 		pm_ctrl_data &= ~PM_CTRL_CLK_SWH_L1;
 
-		if (hw->ctrl_flags & ATL1C_ASPM_L1_SUPPORT) {
-			pm_ctrl_data |= AT_ASPM_L1_TIMER <<
-				PM_CTRL_L1_ENTRY_TIMER_SHIFT;
-			pm_ctrl_data |= PM_CTRL_ASPM_L1_EN;
-		} else
-			pm_ctrl_data &= ~PM_CTRL_ASPM_L1_EN;
-
-		if (hw->ctrl_flags & ATL1C_ASPM_L0S_SUPPORT)
-			pm_ctrl_data |= PM_CTRL_ASPM_L0S_EN;
-		else
-			pm_ctrl_data &= ~PM_CTRL_ASPM_L0S_EN;
-
+		pm_ctrl_data |= PM_CTRL_SERDES_BUDS_RX_L1_EN;
+		pm_ctrl_data |= PM_CTRL_SERDES_L1_EN;
 	} else {
+		pm_ctrl_data &= ~PM_CTRL_SERDES_BUDS_RX_L1_EN;
+		pm_ctrl_data &= ~PM_CTRL_SERDES_L1_EN;
 		pm_ctrl_data &= ~PM_CTRL_ASPM_L0S_EN;
 		pm_ctrl_data &= ~PM_CTRL_SERDES_PLL_L1_EN;
 

