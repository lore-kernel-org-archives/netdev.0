From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/12] ixgbe: Set Drop_EN bit when multiple Rx queues are present w/o flow control
Date: Wed,  9 May 2012 23:46:45 -0700
Message-ID: <1336632413-19135-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22833 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752333Ab2EJGq7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 02:46:59 -0400
In-Reply-To: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The drop enable bit can be used to improve the performance of the adapter
in the case of multiple queues being present.  This performance gain is due
to the fact that some slower CPUs can cause the FIFO to backfill preventing
faster CPUs from receiving additional work.  By setting the drop enable bit
we prevent this and instead just drop the packets that would have been
bound for the slower CPU.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |    5 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |   59 ++++++++++++++++++++++-
 3 files changed, 64 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 425f864..2262bf7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -652,6 +652,7 @@ extern void ixgbe_atr_compute_perfect_hash_82599(union ixgbe_atr_input *input,
 						 union ixgbe_atr_input *mask);
 extern void ixgbe_set_rx_mode(struct net_device *netdev);
 #ifdef CONFIG_IXGBE_DCB
+extern void ixgbe_set_rx_drop_en(struct ixgbe_adapter *adapter);
 extern int ixgbe_setup_tc(struct net_device *dev, u8 tc);
 #endif
 extern void ixgbe_tx_ctxtdesc(struct ixgbe_ring *, u32, u32, u32, u32);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index 7f2fa69..5164a21 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -395,6 +395,9 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		} else {
 			hw->mac.ops.fc_enable(hw);
 		}
+
+		ixgbe_set_rx_drop_en(adapter);
+
 		ret = DCB_HW_CHG;
 	}
 
@@ -641,6 +644,8 @@ static int ixgbe_dcbnl_ieee_setpfc(struct net_device *dev,
 	else
 		err = hw->mac.ops.fc_enable(hw);
 
+	ixgbe_set_rx_drop_en(adapter);
+
 	return err;
 }
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0915e77..1693ec3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2771,6 +2771,61 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 		ixgbe_configure_tx_ring(adapter, adapter->tx_ring[i]);
 }
 
+static void ixgbe_enable_rx_drop(struct ixgbe_adapter *adapter,
+				 struct ixgbe_ring *ring)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u8 reg_idx = ring->reg_idx;
+	u32 srrctl = IXGBE_READ_REG(hw, IXGBE_SRRCTL(reg_idx));
+
+	srrctl |= IXGBE_SRRCTL_DROP_EN;
+
+	IXGBE_WRITE_REG(hw, IXGBE_SRRCTL(reg_idx), srrctl);
+}
+
+static void ixgbe_disable_rx_drop(struct ixgbe_adapter *adapter,
+				  struct ixgbe_ring *ring)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u8 reg_idx = ring->reg_idx;
+	u32 srrctl = IXGBE_READ_REG(hw, IXGBE_SRRCTL(reg_idx));
+
+	srrctl &= ~IXGBE_SRRCTL_DROP_EN;
+
+	IXGBE_WRITE_REG(hw, IXGBE_SRRCTL(reg_idx), srrctl);
+}
+
+#ifdef CONFIG_IXGBE_DCB
+void ixgbe_set_rx_drop_en(struct ixgbe_adapter *adapter)
+#else
+static void ixgbe_set_rx_drop_en(struct ixgbe_adapter *adapter)
+#endif
+{
+	int i;
+	bool pfc_en = adapter->dcb_cfg.pfc_mode_enable;
+
+	if (adapter->ixgbe_ieee_pfc)
+		pfc_en |= !!(adapter->ixgbe_ieee_pfc->pfc_en);
+
+	/*
+	 * We should set the drop enable bit if:
+	 *  SR-IOV is enabled
+	 *   or
+	 *  Number of Rx queues > 1 and flow control is disabled
+	 *
+	 *  This allows us to avoid head of line blocking for security
+	 *  and performance reasons.
+	 */
+	if (adapter->num_vfs || (adapter->num_rx_queues > 1 &&
+	    !(adapter->hw.fc.current_mode & ixgbe_fc_tx_pause) && !pfc_en)) {
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			ixgbe_enable_rx_drop(adapter, adapter->rx_ring[i]);
+	} else {
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			ixgbe_disable_rx_drop(adapter, adapter->rx_ring[i]);
+	}
+}
+
 #define IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT 2
 
 static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
@@ -5276,8 +5331,10 @@ static void ixgbe_watchdog_update_link(struct ixgbe_adapter *adapter)
 	if (adapter->ixgbe_ieee_pfc)
 		pfc_en |= !!(adapter->ixgbe_ieee_pfc->pfc_en);
 
-	if (link_up && !((adapter->flags & IXGBE_FLAG_DCB_ENABLED) && pfc_en))
+	if (link_up && !((adapter->flags & IXGBE_FLAG_DCB_ENABLED) && pfc_en)) {
 		hw->mac.ops.fc_enable(hw);
+		ixgbe_set_rx_drop_en(adapter);
+	}
 
 	if (link_up ||
 	    time_after(jiffies, (adapter->link_check_timeout +
-- 
1.7.7.6
