From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] i40e: use pf data structure directly in i40e_ptp_rx_hang
Date: Wed, 31 May 2017 03:48:54 -0700
Message-ID: <20170531104856.47929-8-jeffrey.t.kirsher@intel.com>
References: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:32543 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751134AbdEaKtD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 06:49:03 -0400
In-Reply-To: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

There's no reason to pass a *vsi pointer if we already have the *pf
pointer in the only location where we call this function. Lets update
the signature and directly pass the *pf data structure pointer.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c  | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index aa46ae016539..f4465afe1fe1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -956,7 +956,7 @@ bool i40e_dcb_need_reconfig(struct i40e_pf *pf,
 			    struct i40e_dcbx_config *old_cfg,
 			    struct i40e_dcbx_config *new_cfg);
 #endif /* CONFIG_I40E_DCB */
-void i40e_ptp_rx_hang(struct i40e_vsi *vsi);
+void i40e_ptp_rx_hang(struct i40e_pf *pf);
 void i40e_ptp_tx_hwtstamp(struct i40e_pf *pf);
 void i40e_ptp_rx_hwtstamp(struct i40e_pf *pf, struct sk_buff *skb, u8 index);
 void i40e_ptp_set_increment(struct i40e_pf *pf);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d5c9c9e06ff5..c019dec988e3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6372,7 +6372,7 @@ static void i40e_watchdog_subtask(struct i40e_pf *pf)
 				i40e_update_veb_stats(pf->veb[i]);
 	}
 
-	i40e_ptp_rx_hang(pf->vsi[pf->lan_vsi]);
+	i40e_ptp_rx_hang(pf);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index aead71a92a60..cb81e16d0874 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -269,6 +269,7 @@ static u32 i40e_ptp_get_rx_events(struct i40e_pf *pf)
 
 /**
  * i40e_ptp_rx_hang - Detect error case when Rx timestamp registers are hung
+ * @pf: The PF private data structure
  * @vsi: The VSI with the rings relevant to 1588
  *
  * This watchdog task is scheduled to detect error case where hardware has
@@ -276,9 +277,8 @@ static u32 i40e_ptp_get_rx_events(struct i40e_pf *pf)
  * particular error is rare but leaves the device in a state unable to timestamp
  * any future packets.
  **/
-void i40e_ptp_rx_hang(struct i40e_vsi *vsi)
+void i40e_ptp_rx_hang(struct i40e_pf *pf)
 {
-	struct i40e_pf *pf = vsi->back;
 	struct i40e_hw *hw = &pf->hw;
 	unsigned int i, cleared = 0;
 
-- 
2.12.2
