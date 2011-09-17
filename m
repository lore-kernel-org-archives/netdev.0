From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] ixgbe: make ixgbe_up and ixgbe_up_complete void functions
Date: Fri, 16 Sep 2011 19:15:45 -0700
Message-ID: <1316225752-1709-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:42810 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754328Ab1IQCP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 22:15:58 -0400
In-Reply-To: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

ixgbe_up and ixgbe_up_complete will always return 0.  Since this doesn't
provide any useful information we might as well just make them both void
and save ourselves from having to return an unused value.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   23 ++++++-----------------
 2 files changed, 7 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index bfdd42b..209286c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -547,7 +547,7 @@ extern int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
 extern char ixgbe_driver_name[];
 extern const char ixgbe_driver_version[];
 
-extern int ixgbe_up(struct ixgbe_adapter *adapter);
+extern void ixgbe_up(struct ixgbe_adapter *adapter);
 extern void ixgbe_down(struct ixgbe_adapter *adapter);
 extern void ixgbe_reinit_locked(struct ixgbe_adapter *adapter);
 extern void ixgbe_reset(struct ixgbe_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0283e12..df1ea20 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3555,7 +3555,7 @@ static void ixgbe_setup_gpie(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
 }
 
-static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
+static void ixgbe_up_complete(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	int err;
@@ -3614,8 +3614,6 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	ctrl_ext = IXGBE_READ_REG(hw, IXGBE_CTRL_EXT);
 	ctrl_ext |= IXGBE_CTRL_EXT_PFRSTD;
 	IXGBE_WRITE_REG(hw, IXGBE_CTRL_EXT, ctrl_ext);
-
-	return 0;
 }
 
 void ixgbe_reinit_locked(struct ixgbe_adapter *adapter)
@@ -3639,12 +3637,12 @@ void ixgbe_reinit_locked(struct ixgbe_adapter *adapter)
 	clear_bit(__IXGBE_RESETTING, &adapter->state);
 }
 
-int ixgbe_up(struct ixgbe_adapter *adapter)
+void ixgbe_up(struct ixgbe_adapter *adapter)
 {
 	/* hardware has been reset, we need to reload some things */
 	ixgbe_configure(adapter);
 
-	return ixgbe_up_complete(adapter);
+	ixgbe_up_complete(adapter);
 }
 
 void ixgbe_reset(struct ixgbe_adapter *adapter)
@@ -5186,17 +5184,12 @@ static int ixgbe_open(struct net_device *netdev)
 	if (err)
 		goto err_req_irq;
 
-	err = ixgbe_up_complete(adapter);
-	if (err)
-		goto err_up;
+	ixgbe_up_complete(adapter);
 
 	netif_tx_start_all_queues(netdev);
 
 	return 0;
 
-err_up:
-	ixgbe_release_hw_control(adapter);
-	ixgbe_free_irq(adapter);
 err_req_irq:
 err_setup_rx:
 	ixgbe_free_all_rx_resources(adapter);
@@ -7653,12 +7646,8 @@ static void ixgbe_io_resume(struct pci_dev *pdev)
 	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev = adapter->netdev;
 
-	if (netif_running(netdev)) {
-		if (ixgbe_up(adapter)) {
-			e_info(probe, "ixgbe_up failed after reset\n");
-			return;
-		}
-	}
+	if (netif_running(netdev))
+		ixgbe_up(adapter);
 
 	netif_device_attach(netdev);
 }
-- 
1.7.6
