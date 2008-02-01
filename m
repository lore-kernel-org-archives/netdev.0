From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/8] ixgbe: remove obsolete irq_sem,
	add driver state checking code
Date: Fri, 01 Feb 2008 15:58:41 -0800
Message-ID: <20080201235841.31474.49421.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:53533 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756639AbYBAX6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 18:58:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>

After testing we confirmed that the irq_sem can safely be
removed from ixgbe.

Add strict state checking code to various ethtool parts to
properly protect against races between various driver reset
paths.

Signed-off-by: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    2 +
 drivers/net/ixgbe/ixgbe_ethtool.c |   29 ++++++++----------
 drivers/net/ixgbe/ixgbe_main.c    |   60 ++++++++++++++++++++++---------------
 3 files changed, 49 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index a021a6e..7dd9a03 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -174,7 +174,6 @@ struct ixgbe_adapter {
 	struct vlan_group *vlgrp;
 	u16 bd_number;
 	u16 rx_buf_len;
-	atomic_t irq_sem;
 	struct work_struct reset_task;
 
 	/* TX */
@@ -244,6 +243,7 @@ extern const char ixgbe_driver_version[];
 
 extern int ixgbe_up(struct ixgbe_adapter *adapter);
 extern void ixgbe_down(struct ixgbe_adapter *adapter);
+extern void ixgbe_reinit_locked(struct ixgbe_adapter *adapter);
 extern void ixgbe_reset(struct ixgbe_adapter *adapter);
 extern void ixgbe_update_stats(struct ixgbe_adapter *adapter);
 extern void ixgbe_set_ethtool_ops(struct net_device *netdev);
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 3635344..9f3cdb8 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -179,12 +179,10 @@ static int ixgbe_set_pauseparam(struct net_device *netdev,
 
 	hw->fc.original_type = hw->fc.type;
 
-	if (netif_running(adapter->netdev)) {
-		ixgbe_down(adapter);
-		ixgbe_up(adapter);
-	} else {
+	if (netif_running(netdev))
+		ixgbe_reinit_locked(adapter);
+	else
 		ixgbe_reset(adapter);
-	}
 
 	return 0;
 }
@@ -203,12 +201,10 @@ static int ixgbe_set_rx_csum(struct net_device *netdev, u32 data)
 	else
 		adapter->flags &= ~IXGBE_FLAG_RX_CSUM_ENABLED;
 
-	if (netif_running(netdev)) {
-		ixgbe_down(adapter);
-		ixgbe_up(adapter);
-	} else {
+	if (netif_running(netdev))
+		ixgbe_reinit_locked(adapter);
+	else
 		ixgbe_reset(adapter);
-	}
 
 	return 0;
 }
@@ -662,7 +658,10 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 		return 0;
 	}
 
-	if (netif_running(adapter->netdev))
+	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
+		msleep(1);
+
+	if (netif_running(netdev))
 		ixgbe_down(adapter);
 
 	/*
@@ -733,6 +732,7 @@ err_setup:
 	if (netif_running(adapter->netdev))
 		ixgbe_up(adapter);
 
+	clear_bit(__IXGBE_RESETTING, &adapter->state);
 	return err;
 }
 
@@ -820,11 +820,8 @@ static int ixgbe_nway_reset(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	if (netif_running(netdev)) {
-		ixgbe_down(adapter);
-		ixgbe_reset(adapter);
-		ixgbe_up(adapter);
-	}
+	if (netif_running(netdev))
+		ixgbe_reinit_locked(adapter);
 
 	return 0;
 }
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 3732dd6..28bb203 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -535,7 +535,9 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			mod_timer(&adapter->watchdog_timer, jiffies);
 	}
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, IXGBE_EIMS_OTHER);
+
+	if (!test_bit(__IXGBE_DOWN, &adapter->state))
+		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMS_OTHER);
 
 	return IRQ_HANDLED;
 }
@@ -713,7 +715,6 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
 		/* Disable interrupts and register for poll. The flush of the
 		 * posted write is intentionally left out. */
-		atomic_inc(&adapter->irq_sem);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, ~0);
 		__netif_rx_schedule(netdev, &adapter->napi);
 	}
@@ -801,7 +802,6 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
  **/
 static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
 {
-	atomic_inc(&adapter->irq_sem);
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, ~0);
 	IXGBE_WRITE_FLUSH(&adapter->hw);
 	synchronize_irq(adapter->pdev->irq);
@@ -813,15 +813,13 @@ static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
  **/
 static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
 {
-	if (atomic_dec_and_test(&adapter->irq_sem)) {
-		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIAC,
-					(IXGBE_EIMS_ENABLE_MASK &
-					 ~(IXGBE_EIMS_OTHER | IXGBE_EIMS_LSC)));
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS,
-				IXGBE_EIMS_ENABLE_MASK);
-		IXGBE_WRITE_FLUSH(&adapter->hw);
-	}
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIAC,
+				(IXGBE_EIMS_ENABLE_MASK &
+				 ~(IXGBE_EIMS_OTHER | IXGBE_EIMS_LSC)));
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS,
+			IXGBE_EIMS_ENABLE_MASK);
+	IXGBE_WRITE_FLUSH(&adapter->hw);
 }
 
 /**
@@ -1040,7 +1038,8 @@ static void ixgbe_vlan_rx_register(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	u32 ctrl;
 
-	ixgbe_irq_disable(adapter);
+	if (!test_bit(__IXGBE_DOWN, &adapter->state))
+		ixgbe_irq_disable(adapter);
 	adapter->vlgrp = grp;
 
 	if (grp) {
@@ -1051,7 +1050,8 @@ static void ixgbe_vlan_rx_register(struct net_device *netdev,
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_VLNCTRL, ctrl);
 	}
 
-	ixgbe_irq_enable(adapter);
+	if (!test_bit(__IXGBE_DOWN, &adapter->state))
+		ixgbe_irq_enable(adapter);
 }
 
 static void ixgbe_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
@@ -1066,9 +1066,13 @@ static void ixgbe_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	ixgbe_irq_disable(adapter);
+	if (!test_bit(__IXGBE_DOWN, &adapter->state))
+		ixgbe_irq_disable(adapter);
+
 	vlan_group_set_device(adapter->vlgrp, vid, NULL);
-	ixgbe_irq_enable(adapter);
+
+	if (!test_bit(__IXGBE_DOWN, &adapter->state))
+		ixgbe_irq_enable(adapter);
 
 	/* remove VID from filter table */
 	ixgbe_set_vfta(&adapter->hw, vid, 0, false);
@@ -1224,6 +1228,16 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	return 0;
 }
 
+void ixgbe_reinit_locked(struct ixgbe_adapter *adapter)
+{
+	WARN_ON(in_interrupt());
+	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
+		msleep(1);
+	ixgbe_down(adapter);
+	ixgbe_up(adapter);
+	clear_bit(__IXGBE_RESETTING, &adapter->state);
+}
+
 int ixgbe_up(struct ixgbe_adapter *adapter)
 {
 	/* hardware has been reset, we need to reload some things */
@@ -1408,7 +1422,6 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	msleep(10);
 
 	napi_disable(&adapter->napi);
-	atomic_set(&adapter->irq_sem, 0);
 
 	ixgbe_irq_disable(adapter);
 
@@ -1481,7 +1494,8 @@ static int ixgbe_clean(struct napi_struct *napi, int budget)
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
 		netif_rx_complete(netdev, napi);
-		ixgbe_irq_enable(adapter);
+		if (!test_bit(__IXGBE_DOWN, &adapter->state))
+			ixgbe_irq_enable(adapter);
 	}
 
 	return work_done;
@@ -1506,8 +1520,7 @@ static void ixgbe_reset_task(struct work_struct *work)
 
 	adapter->tx_timeout_count++;
 
-	ixgbe_down(adapter);
-	ixgbe_up(adapter);
+	ixgbe_reinit_locked(adapter);
 }
 
 /**
@@ -1590,7 +1603,6 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		return -ENOMEM;
 	}
 
-	atomic_set(&adapter->irq_sem, 1);
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
 	return 0;
@@ -1828,10 +1840,8 @@ static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 
 	netdev->mtu = new_mtu;
 
-	if (netif_running(netdev)) {
-		ixgbe_down(adapter);
-		ixgbe_up(adapter);
-	}
+	if (netif_running(netdev))
+		ixgbe_reinit_locked(adapter);
 
 	return 0;
 }

