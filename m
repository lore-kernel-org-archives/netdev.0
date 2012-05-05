From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/4] ixgbe: dcb: IEEE PFC stats and reset logic incorrect
Date: Sat,  5 May 2012 05:38:13 -0700
Message-ID: <1336221493-913-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336221493-913-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42294 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755508Ab2EEMiS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 May 2012 08:38:18 -0400
In-Reply-To: <1336221493-913-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

PFC stats are only tabulated when PFC is enabled. However in IEEE
mode the ieee_pfc pfc_tc bits were not checked and the calculation
was aborted.

This results in statistics not being reported through ethtool and
possible a false Tx hang occurring when receiving pause frames.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |    7 +++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |    6 +++++-
 2 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index 652e4b0..2feacf6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -662,6 +662,13 @@ static int ixgbe_dcbnl_ieee_setpfc(struct net_device *dev,
 			return -ENOMEM;
 	}
 
+	if (pfc->pfc_en) {
+		adapter->last_lfc_mode = adapter->hw.fc.current_mode;
+		adapter->hw.fc.current_mode = ixgbe_fc_pfc;
+	} else {
+		adapter->hw.fc.current_mode = adapter->last_lfc_mode;
+	}
+
 	prio_tc = adapter->ixgbe_ieee_ets->prio_tc;
 	memcpy(adapter->ixgbe_ieee_pfc, pfc, sizeof(*adapter->ixgbe_ieee_pfc));
 	return ixgbe_dcb_hw_pfc_config(&adapter->hw, pfc->pfc_en, prio_tc);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b2daff3..4048c9d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -637,7 +637,11 @@ static void ixgbe_update_xoff_received(struct ixgbe_adapter *adapter)
 			clear_bit(__IXGBE_HANG_CHECK_ARMED,
 				  &adapter->tx_ring[i]->state);
 		return;
-	} else if (!(adapter->dcb_cfg.pfc_mode_enable))
+	} else if (((adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE) &&
+		    !(adapter->dcb_cfg.pfc_mode_enable)) ||
+		   ((adapter->dcbx_cap & DCB_CAP_DCBX_VER_IEEE) &&
+		    adapter->ixgbe_ieee_pfc &&
+		    !(adapter->ixgbe_ieee_pfc->pfc_en)))
 		return;
 
 	/* update stats for each tc, only valid with PFC enabled */
-- 
1.7.7.6
