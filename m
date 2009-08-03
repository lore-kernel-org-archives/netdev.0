From: <jie.yang@atheros.com>
Subject: [Patch net-next]atl11:set MAX_TX_OFFLOAD_THRESH to 6k from 9k and fix spelling error
Date: Mon, 3 Aug 2009 13:43:52 +0800
Message-ID: <1249278232896-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atheros.com ([12.36.123.2]:55149 "EHLO mail.atheros.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751352AbZHCFnu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Aug 2009 01:43:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Set MAX_TX_OFFLOAD_THRESH to 6k from 9k, when mtu large then MAX_TX_OFFLOAD_THRESH
   just disable NETIF_F_TSO6, NETIF_F_TSO, NETIF_F_HW_CSUM.

2. Fix spelling error, change REG_TWSI_CTRL to REG_TXQ_CTRL.

Signed-off-by: jie yang <jie.yang>@atheros.com
---

diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
index 2a1120a..07b2880 100644
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -74,7 +74,7 @@
 
 #define AT_RX_BUF_SIZE     (ETH_FRAME_LEN + VLAN_HLEN + ETH_FCS_LEN)
 #define MAX_JUMBO_FRAME_SIZE   (9*1024)
-#define MAX_TX_OFFLOAD_THRESH  (9*1024)
+#define MAX_TX_OFFLOAD_THRESH  (6*1024)
 
 #define AT_MAX_RECEIVE_QUEUE    4
 #define AT_DEF_RECEIVE_QUEUE   1
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 1d601ce..13cb551 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -474,15 +474,19 @@ static int atl1c_change_mtu(struct net_device *netdev, int new_mtu)
        netdev->mtu = new_mtu;
        adapter->hw.max_frame_size = new_mtu;
        atl1c_set_rxbufsize(adapter, netdev);
+       if (max_frame >= MAX_TX_OFFLOAD_THRESH)
+           netdev->features &= ~(NETIF_F_TSO6 | NETIF_F_TSO | NETIF_F_HW_CSUM);
+       else
+           netdev->features |= (NETIF_F_TSO6 | NETIF_F_TSO | NETIF_F_HW_CSUM);
        atl1c_down(adapter);
        atl1c_up(adapter);
        clear_bit(__AT_RESETTING, &adapter->flags);
        if (adapter->hw.ctrl_flags & ATL1C_FPGA_VERSION) {
            u32 phy_data;
 
-           AT_READ_REG(&adapter->hw, 0x1414, &phy_data);
-           phy_data |= 0x10000000;
-           AT_WRITE_REG(&adapter->hw, 0x1414, phy_data);
+           AT_READ_REG(&adapter->hw, REG_MDIO_CTRL, &phy_data);
+           phy_data |= MDIO_AP_EN;
+           AT_WRITE_REG(&adapter->hw, REG_MDIO_CTRL, phy_data);
        }
 
    }
@@ -1132,7 +1136,7 @@ static int atl1c_stop_mac(struct atl1c_hw *hw)
 
    AT_READ_REG(hw, REG_TXQ_CTRL, &data);
    data &= ~TXQ_CTRL_EN;
-   AT_WRITE_REG(hw, REG_TWSI_CTRL, data);
+   AT_WRITE_REG(hw, REG_TXQ_CTRL, data);
 
    atl1c_wait_until_idle(hw);
 
@@ -1265,8 +1269,9 @@ static void atl1c_set_aspm(struct atl1c_hw *hw, bool linkup)
        else
            pm_ctrl_data &= ~PM_CTRL_ASPM_L1_EN;
    }
-
    AT_WRITE_REG(hw, REG_PM_CTRL, pm_ctrl_data);
+
+   return;
 }
 
 static void atl1c_setup_mac_ctrl(struct atl1c_adapter *adapter)

