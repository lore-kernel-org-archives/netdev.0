From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/13] ixgbe: Use 1TC DCB instead of disabling DCB for MSI and legacy interrupts
Date: Sat, 21 Jul 2012 16:09:01 -0700
Message-ID: <1342912142-11130-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:53992 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042Ab2GUXJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2012 19:09:13 -0400
In-Reply-To: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that we can use 1TC DCB in the case of MSI and
legacy interrupts.  The advantage to this is that it allows us to fully
support FCoE w/ DCB instead of having to drop to link flow control only
when using these interrupt modes.

Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |   18 +++++++++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    6 ------
 2 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 29a2a85..17ecbce 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -1065,11 +1065,27 @@ static void ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 			return;
 	}
 
-	adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
+	/* disable DCB if number of TCs exceeds 1 */
+	if (netdev_get_num_tc(adapter->netdev) > 1) {
+		e_err(probe, "num TCs exceeds number of queues - disabling DCB\n");
+		netdev_reset_tc(adapter->netdev);
 
+		if (adapter->hw.mac.type == ixgbe_mac_82598EB)
+			adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
+
+		adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
+		adapter->temp_dcb_cfg.pfc_mode_enable = false;
+		adapter->dcb_cfg.pfc_mode_enable = false;
+	}
+	adapter->dcb_cfg.num_tcs.pg_tcs = 1;
+	adapter->dcb_cfg.num_tcs.pfc_tcs = 1;
+
+	/* disable SR-IOV */
 	ixgbe_disable_sriov(adapter);
 
+	/* disable RSS */
 	adapter->ring_feature[RING_F_RSS].limit = 1;
+
 	ixgbe_set_num_queues(adapter);
 	adapter->num_q_vectors = 1;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3069981..3b6784c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6703,12 +6703,6 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	/* Multiple traffic classes requires multiple queues */
-	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED)) {
-		e_err(drv, "Enable failed, needs MSI-X\n");
-		return -EINVAL;
-	}
-
 	/* Hardware supports up to 8 traffic classes */
 	if (tc > adapter->dcb_cfg.num_tcs.pg_tcs ||
 	    (hw->mac.type == ixgbe_mac_82598EB &&
-- 
1.7.10.4
