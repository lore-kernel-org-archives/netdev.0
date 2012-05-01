From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 08/10] atl1c: do MAC-reset when PHY link down
Date: Tue, 1 May 2012 09:38:56 +0800
Message-ID: <1335836338-9425-9-git-send-email-xiong@qca.qualcomm.com>
References: <1335836338-9425-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1335836338-9425-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There may be tx-skbs still pending in HW when PHY link down.
Reset MAC will make the DMA engine go to the start point.
and release all pending skbs.
Note: Reset MAC will clear any interrupt status and mask.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   74 ++++++++++++++--------
 1 files changed, 47 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index b95ef45..e6c62d0 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -60,6 +60,10 @@ static void atl1c_clean_rx_irq(struct atl1c_adapter *adapter,
 		   int *work_done, int work_to_do);
 static int atl1c_up(struct atl1c_adapter *adapter);
 static void atl1c_down(struct atl1c_adapter *adapter);
+static int atl1c_reset_mac(struct atl1c_hw *hw);
+static void atl1c_reset_dma_ring(struct atl1c_adapter *adapter);
+static int atl1c_configure(struct atl1c_adapter *adapter);
+static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter);
 
 static const u16 atl1c_pay_load_size[] = {
 	128, 256, 512, 1024, 2048, 4096,
@@ -256,14 +260,16 @@ static void atl1c_check_link_status(struct atl1c_adapter *adapter)
 
 	if ((phy_data & BMSR_LSTATUS) == 0) {
 		/* link down */
+		netif_carrier_off(netdev);
+		netif_stop_queue(netdev);
 		hw->hibernate = true;
-		if (atl1c_stop_mac(hw) != 0)
+		if (atl1c_reset_mac(hw) != 0)
 			if (netif_msg_hw(adapter))
-				dev_warn(&pdev->dev, "stop mac failed\n");
+				dev_warn(&pdev->dev, "reset mac failed\n");
 		atl1c_set_aspm(hw, SPEED_0);
 		atl1c_post_phy_linkchg(hw, SPEED_0);
-		netif_carrier_off(netdev);
-		netif_stop_queue(netdev);
+		atl1c_reset_dma_ring(adapter);
+		atl1c_configure(adapter);
 	} else {
 		/* Link Up */
 		hw->hibernate = false;
@@ -341,8 +347,11 @@ static void atl1c_common_task(struct work_struct *work)
 	}
 
 	if (test_and_clear_bit(ATL1C_WORK_EVENT_LINK_CHANGE,
-		&adapter->work_event))
+		&adapter->work_event)) {
+		atl1c_irq_disable(adapter);
 		atl1c_check_link_status(adapter);
+		atl1c_irq_enable(adapter);
+	}
 }
 
 
@@ -1230,9 +1239,6 @@ static int atl1c_reset_mac(struct atl1c_hw *hw)
 	struct pci_dev *pdev = adapter->pdev;
 	u32 ctrl_data = 0;
 
-	AT_WRITE_REG(hw, REG_IMR, 0);
-	AT_WRITE_REG(hw, REG_ISR, ISR_DIS_INT);
-
 	atl1c_stop_mac(hw);
 	/*
 	 * Issue Soft Reset to the MAC.  This will reset the chip's
@@ -1371,7 +1377,7 @@ static void atl1c_set_aspm(struct atl1c_hw *hw, u16 link_speed)
  *
  * Configure the Tx /Rx unit of the MAC after a reset.
  */
-static int atl1c_configure(struct atl1c_adapter *adapter)
+static int atl1c_configure_mac(struct atl1c_adapter *adapter)
 {
 	struct atl1c_hw *hw = &adapter->hw;
 	u32 master_ctrl_data = 0;
@@ -1434,6 +1440,25 @@ static int atl1c_configure(struct atl1c_adapter *adapter)
 	return 0;
 }
 
+static int atl1c_configure(struct atl1c_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	int num;
+
+	atl1c_init_ring_ptrs(adapter);
+	atl1c_set_multi(netdev);
+	atl1c_restore_vlan(adapter);
+
+	num = atl1c_alloc_rx_buffer(adapter);
+	if (unlikely(num == 0))
+		return -ENOMEM;
+
+	if (atl1c_configure_mac(adapter))
+		return -EIO;
+
+	return 0;
+}
+
 static void atl1c_update_hw_stats(struct atl1c_adapter *adapter)
 {
 	u16 hw_reg_addr = 0;
@@ -2194,41 +2219,38 @@ static int atl1c_request_irq(struct atl1c_adapter *adapter)
 	return err;
 }
 
+
+static void atl1c_reset_dma_ring(struct atl1c_adapter *adapter)
+{
+	/* release tx-pending skbs and reset tx/rx ring index */
+	atl1c_clean_tx_ring(adapter, atl1c_trans_normal);
+	atl1c_clean_tx_ring(adapter, atl1c_trans_high);
+	atl1c_clean_rx_ring(adapter);
+}
+
 static int atl1c_up(struct atl1c_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	int num;
 	int err;
 
 	netif_carrier_off(netdev);
-	atl1c_init_ring_ptrs(adapter);
-	atl1c_set_multi(netdev);
-	atl1c_restore_vlan(adapter);
 
-	num = atl1c_alloc_rx_buffer(adapter);
-	if (unlikely(num == 0)) {
-		err = -ENOMEM;
-		goto err_alloc_rx;
-	}
-
-	if (atl1c_configure(adapter)) {
-		err = -EIO;
+	err = atl1c_configure(adapter);
+	if (unlikely(err))
 		goto err_up;
-	}
 
 	err = atl1c_request_irq(adapter);
 	if (unlikely(err))
 		goto err_up;
 
+	atl1c_check_link_status(adapter);
 	clear_bit(__AT_DOWN, &adapter->flags);
 	napi_enable(&adapter->napi);
 	atl1c_irq_enable(adapter);
-	atl1c_check_link_status(adapter);
 	netif_start_queue(netdev);
 	return err;
 
 err_up:
-err_alloc_rx:
 	atl1c_clean_rx_ring(adapter);
 	return err;
 }
@@ -2254,9 +2276,7 @@ static void atl1c_down(struct atl1c_adapter *adapter)
 
 	adapter->link_speed = SPEED_0;
 	adapter->link_duplex = -1;
-	atl1c_clean_tx_ring(adapter, atl1c_trans_normal);
-	atl1c_clean_tx_ring(adapter, atl1c_trans_high);
-	atl1c_clean_rx_ring(adapter);
+	atl1c_reset_dma_ring(adapter);
 }
 
 /*
-- 
1.7.7
