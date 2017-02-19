From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/13] i40e: Fix Adaptive ITR enabling
Date: Sat, 18 Feb 2017 22:33:34 -0800
Message-ID: <20170219063341.8039-7-jeffrey.t.kirsher@intel.com>
References: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52390 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750945AbdBSGeN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Feb 2017 01:34:13 -0500
In-Reply-To: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes a bug introduced with the addition of the per queue
ITR feature support in ethtool.  With that addition, there were
functions added which converted the ITR settings to binary values.
The IS_ENABLED macros that run on those values check whether a bit
is set or not and with the value being binary, the bit check always
returned ITR disabled which prevents any updating of the ITR rate.
This patch fixes the problem by changing the functions to return the
current ITR value instead and renaming it to better reflect
its function.  These functions now provide a value which will be
accurately asessed and update the ITR as intended.

Change-ID: I14f1d088d052e27f652aaa3113e186415ddea1fc
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 12 ++++++------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 12 ++++++------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 09f09ea7a5e5..4dc993bb16bf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1864,14 +1864,14 @@ static u32 i40e_buildreg_itr(const int type, const u16 itr)
 
 /* a small macro to shorten up some long lines */
 #define INTREG I40E_PFINT_DYN_CTLN
-static inline int get_rx_itr_enabled(struct i40e_vsi *vsi, int idx)
+static inline int get_rx_itr(struct i40e_vsi *vsi, int idx)
 {
-	return !!(vsi->rx_rings[idx]->rx_itr_setting);
+	return vsi->rx_rings[idx]->rx_itr_setting;
 }
 
-static inline int get_tx_itr_enabled(struct i40e_vsi *vsi, int idx)
+static inline int get_tx_itr(struct i40e_vsi *vsi, int idx)
 {
-	return !!(vsi->tx_rings[idx]->tx_itr_setting);
+	return vsi->tx_rings[idx]->tx_itr_setting;
 }
 
 /**
@@ -1897,8 +1897,8 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 	 */
 	rxval = txval = i40e_buildreg_itr(I40E_ITR_NONE, 0);
 
-	rx_itr_setting = get_rx_itr_enabled(vsi, idx);
-	tx_itr_setting = get_tx_itr_enabled(vsi, idx);
+	rx_itr_setting = get_rx_itr(vsi, idx);
+	tx_itr_setting = get_tx_itr(vsi, idx);
 
 	if (q_vector->itr_countdown > 0 ||
 	    (!ITR_IS_DYNAMIC(rx_itr_setting) &&
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index b758846d4dc5..7cd28ef6e714 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1324,18 +1324,18 @@ static u32 i40e_buildreg_itr(const int type, const u16 itr)
 
 /* a small macro to shorten up some long lines */
 #define INTREG I40E_VFINT_DYN_CTLN1
-static inline int get_rx_itr_enabled(struct i40e_vsi *vsi, int idx)
+static inline int get_rx_itr(struct i40e_vsi *vsi, int idx)
 {
 	struct i40evf_adapter *adapter = vsi->back;
 
-	return !!(adapter->rx_rings[idx].rx_itr_setting);
+	return adapter->rx_rings[idx].rx_itr_setting;
 }
 
-static inline int get_tx_itr_enabled(struct i40e_vsi *vsi, int idx)
+static inline int get_tx_itr(struct i40e_vsi *vsi, int idx)
 {
 	struct i40evf_adapter *adapter = vsi->back;
 
-	return !!(adapter->tx_rings[idx].tx_itr_setting);
+	return adapter->tx_rings[idx].tx_itr_setting;
 }
 
 /**
@@ -1361,8 +1361,8 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 	 */
 	rxval = txval = i40e_buildreg_itr(I40E_ITR_NONE, 0);
 
-	rx_itr_setting = get_rx_itr_enabled(vsi, idx);
-	tx_itr_setting = get_tx_itr_enabled(vsi, idx);
+	rx_itr_setting = get_rx_itr(vsi, idx);
+	tx_itr_setting = get_tx_itr(vsi, idx);
 
 	if (q_vector->itr_countdown > 0 ||
 	    (!ITR_IS_DYNAMIC(rx_itr_setting) &&
-- 
2.11.0
