From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] ixgbe: Make ixgbe_setup_tc usable even when DCB is not enabled
Date: Sat, 16 Feb 2013 00:33:29 -0800
Message-ID: <1361003616-3422-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:21658 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752476Ab3BPIdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 03:33:47 -0500
In-Reply-To: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The ixgbe_setup_tc code is essentially the same code we need any time we have
to update the number of queues.  As such I am making it available always and
just stripping the DCB specific bits out when DCB is disabled instead of
stripping the entire function.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Reviewed-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 19 +++++++------------
 2 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 5213563..b91f9b6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -700,8 +700,8 @@ extern bool ixgbe_verify_lesm_fw_enabled_82599(struct ixgbe_hw *hw);
 extern void ixgbe_set_rx_mode(struct net_device *netdev);
 #ifdef CONFIG_IXGBE_DCB
 extern void ixgbe_set_rx_drop_en(struct ixgbe_adapter *adapter);
-extern int ixgbe_setup_tc(struct net_device *dev, u8 tc);
 #endif
+extern int ixgbe_setup_tc(struct net_device *dev, u8 tc);
 extern void ixgbe_tx_ctxtdesc(struct ixgbe_ring *, u32, u32, u32, u32);
 extern void ixgbe_do_reset(struct net_device *netdev);
 #ifdef CONFIG_IXGBE_HWMON
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 872d7aa..aea252a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6812,6 +6812,7 @@ static void ixgbe_set_prio_tc_map(struct ixgbe_adapter *adapter)
 	}
 }
 
+#endif /* CONFIG_IXGBE_DCB */
 /**
  * ixgbe_setup_tc - configure net_device for multiple traffic classes
  *
@@ -6837,6 +6838,7 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 		ixgbe_close(dev);
 	ixgbe_clear_interrupt_scheme(adapter);
 
+#ifdef CONFIG_IXGBE_DCB
 	if (tc) {
 		netdev_set_num_tc(dev, tc);
 		ixgbe_set_prio_tc_map(adapter);
@@ -6859,31 +6861,24 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 		adapter->dcb_cfg.pfc_mode_enable = false;
 	}
 
-	ixgbe_init_interrupt_scheme(adapter);
 	ixgbe_validate_rtr(adapter, tc);
+
+#endif /* CONFIG_IXGBE_DCB */
+	ixgbe_init_interrupt_scheme(adapter);
+
 	if (netif_running(dev))
-		ixgbe_open(dev);
+		return ixgbe_open(dev);
 
 	return 0;
 }
 
-#endif /* CONFIG_IXGBE_DCB */
 #ifdef CONFIG_PCI_IOV
 void ixgbe_sriov_reinit(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 
 	rtnl_lock();
-#ifdef CONFIG_IXGBE_DCB
 	ixgbe_setup_tc(netdev, netdev_get_num_tc(netdev));
-#else
-	if (netif_running(netdev))
-		ixgbe_close(netdev);
-	ixgbe_clear_interrupt_scheme(adapter);
-	ixgbe_init_interrupt_scheme(adapter);
-	if (netif_running(netdev))
-		ixgbe_open(netdev);
-#endif
 	rtnl_unlock();
 }
 
-- 
1.7.11.7
