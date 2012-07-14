From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/7] e1000e: Program the correct register for ITR when using MSI-X.
Date: Sat, 14 Jul 2012 16:07:00 -0700
Message-ID: <1342307225-28917-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342307225-28917-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:31575 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752196Ab2GNXHd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2012 19:07:33 -0400
In-Reply-To: <1342307225-28917-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

When configuring interrupt throttling on 82574 in MSI-X mode, we need to
be programming the EITR registers instead of the ITR register.

-rc2: Renamed e1000_write_itr() to e1000e_write_itr(), fixed whitespace
      issues, and removed unnecessary !! operation.
-rc3: Reduced the scope of the loop variable in e1000e_write_itr().

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h   |    1 +
 drivers/net/ethernet/intel/e1000e/ethtool.c |    5 ++---
 drivers/net/ethernet/intel/e1000e/netdev.c  |   32 +++++++++++++++++++++++----
 3 files changed, 31 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 6e6fffb..cd15332 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -514,6 +514,7 @@ extern void e1000e_set_interrupt_capability(struct e1000_adapter *adapter);
 extern void e1000e_reset_interrupt_capability(struct e1000_adapter *adapter);
 extern void e1000e_get_hw_control(struct e1000_adapter *adapter);
 extern void e1000e_release_hw_control(struct e1000_adapter *adapter);
+extern void e1000e_write_itr(struct e1000_adapter *adapter, u32 itr);
 
 extern unsigned int copybreak;
 
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 905e214..105d554 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -1897,7 +1897,6 @@ static int e1000_set_coalesce(struct net_device *netdev,
 			      struct ethtool_coalesce *ec)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	struct e1000_hw *hw = &adapter->hw;
 
 	if ((ec->rx_coalesce_usecs > E1000_MAX_ITR_USECS) ||
 	    ((ec->rx_coalesce_usecs > 4) &&
@@ -1916,9 +1915,9 @@ static int e1000_set_coalesce(struct net_device *netdev,
 	}
 
 	if (adapter->itr_setting != 0)
-		ew32(ITR, 1000000000 / (adapter->itr * 256));
+		e1000e_write_itr(adapter, adapter->itr);
 	else
-		ew32(ITR, 0);
+		e1000e_write_itr(adapter, 0);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index ca477e8..95b2453 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2474,6 +2474,30 @@ set_itr_now:
 }
 
 /**
+ * e1000e_write_itr - write the ITR value to the appropriate registers
+ * @adapter: address of board private structure
+ * @itr: new ITR value to program
+ *
+ * e1000e_write_itr determines if the adapter is in MSI-X mode
+ * and, if so, writes the EITR registers with the ITR value.
+ * Otherwise, it writes the ITR value into the ITR register.
+ **/
+void e1000e_write_itr(struct e1000_adapter *adapter, u32 itr)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 new_itr = itr ? 1000000000 / (itr * 256) : 0;
+
+	if (adapter->msix_entries) {
+		int vector;
+
+		for (vector = 0; vector < adapter->num_vectors; vector++)
+			writel(new_itr, hw->hw_addr + E1000_EITR_82574(vector));
+	} else {
+		ew32(ITR, new_itr);
+	}
+}
+
+/**
  * e1000_alloc_queues - Allocate memory for all rings
  * @adapter: board private structure to initialize
  **/
@@ -3059,7 +3083,7 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	/* irq moderation */
 	ew32(RADV, adapter->rx_abs_int_delay);
 	if ((adapter->itr_setting != 0) && (adapter->itr != 0))
-		ew32(ITR, 1000000000 / (adapter->itr * 256));
+		e1000e_write_itr(adapter, adapter->itr);
 
 	ctrl_ext = er32(CTRL_EXT);
 	/* Auto-Mask interrupts upon ICR access */
@@ -3486,14 +3510,14 @@ void e1000e_reset(struct e1000_adapter *adapter)
 				dev_info(&adapter->pdev->dev,
 					"Interrupt Throttle Rate turned off\n");
 				adapter->flags2 |= FLAG2_DISABLE_AIM;
-				ew32(ITR, 0);
+				e1000e_write_itr(adapter, 0);
 			}
 		} else if (adapter->flags2 & FLAG2_DISABLE_AIM) {
 			dev_info(&adapter->pdev->dev,
 				 "Interrupt Throttle Rate turned on\n");
 			adapter->flags2 &= ~FLAG2_DISABLE_AIM;
 			adapter->itr = 20000;
-			ew32(ITR, 1000000000 / (adapter->itr * 256));
+			e1000e_write_itr(adapter, adapter->itr);
 		}
 	}
 
@@ -4576,7 +4600,7 @@ link_up:
 			    adapter->gorc - adapter->gotc) / 10000;
 		u32 itr = goc > 0 ? (dif * 6000 / goc + 2000) : 8000;
 
-		ew32(ITR, 1000000000 / (itr * 256));
+		e1000e_write_itr(adapter, itr);
 	}
 
 	/* Cause software interrupt to ensure Rx ring is cleaned */
-- 
1.7.10.4
