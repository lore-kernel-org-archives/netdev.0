From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/2] ixgbe: update the rss key on h/w, when ethtool ask for it
Date: Thu,  2 Mar 2017 18:24:47 -0800
Message-ID: <20170303022448.79638-2-jeffrey.t.kirsher@intel.com>
References: <20170303022448.79638-1-jeffrey.t.kirsher@intel.com>
Cc: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43918 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751473AbdCCCZL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Mar 2017 21:25:11 -0500
In-Reply-To: <20170303022448.79638-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>

Currently ixgbe_set_rxfh() updates the rss_key copy in the driver
memory, but does not push the new value into the h/w. This commit
add a new helper for the latter operation and call it in
ixgbe_set_rxfh(), so that the h/w rss key value can be really
updated via ethtool.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  4 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 19 ++++++++++++++++---
 3 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index a2cc43d28888..7a951b116821 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -929,6 +929,7 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 				  struct ixgbe_adapter *adapter,
 				  struct ixgbe_ring *tx_ring);
 u32 ixgbe_rss_indir_tbl_entries(struct ixgbe_adapter *adapter);
+void ixgbe_store_key(struct ixgbe_adapter *adapter);
 void ixgbe_store_reta(struct ixgbe_adapter *adapter);
 s32 ixgbe_negotiate_fc(struct ixgbe_hw *hw, u32 adv_reg, u32 lp_reg,
 		       u32 adv_sym, u32 adv_asm, u32 lp_sym, u32 lp_asm);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index a7574c7b12af..90fa5bf23d1b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2998,8 +2998,10 @@ static int ixgbe_set_rxfh(struct net_device *netdev, const u32 *indir,
 	}
 
 	/* Fill out the rss hash key */
-	if (key)
+	if (key) {
 		memcpy(adapter->rss_key, key, ixgbe_get_rxfh_key_size(netdev));
+		ixgbe_store_key(adapter);
+	}
 
 	ixgbe_store_reta(adapter);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 060cdce8058f..67ab13fd163c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3474,6 +3474,21 @@ u32 ixgbe_rss_indir_tbl_entries(struct ixgbe_adapter *adapter)
 }
 
 /**
+ * ixgbe_store_key - Write the RSS key to HW
+ * @adapter: device handle
+ *
+ * Write the RSS key stored in adapter.rss_key to HW.
+ */
+void ixgbe_store_key(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int i;
+
+	for (i = 0; i < 10; i++)
+		IXGBE_WRITE_REG(hw, IXGBE_RSSRK(i), adapter->rss_key[i]);
+}
+
+/**
  * ixgbe_store_reta - Write the RETA table to HW
  * @adapter: device handle
  *
@@ -3538,7 +3553,6 @@ static void ixgbe_store_vfreta(struct ixgbe_adapter *adapter)
 
 static void ixgbe_setup_reta(struct ixgbe_adapter *adapter)
 {
-	struct ixgbe_hw *hw = &adapter->hw;
 	u32 i, j;
 	u32 reta_entries = ixgbe_rss_indir_tbl_entries(adapter);
 	u16 rss_i = adapter->ring_feature[RING_F_RSS].indices;
@@ -3551,8 +3565,7 @@ static void ixgbe_setup_reta(struct ixgbe_adapter *adapter)
 		rss_i = 4;
 
 	/* Fill out hash function seeds */
-	for (i = 0; i < 10; i++)
-		IXGBE_WRITE_REG(hw, IXGBE_RSSRK(i), adapter->rss_key[i]);
+	ixgbe_store_key(adapter);
 
 	/* Fill out redirection table */
 	memset(adapter->rss_indir_tbl, 0, sizeof(adapter->rss_indir_tbl));
-- 
2.12.0
