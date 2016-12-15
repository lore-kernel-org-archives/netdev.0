From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] ixgbe: update the rss key on h/w, when ethtool ask for it.
Date: Thu, 15 Dec 2016 15:20:34 +0100
Message-ID: <1aee550aa286aa44265236441b42f8aab77ae864.1481796580.git.pabeni@redhat.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40014 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755300AbcLOOWD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 09:22:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently ixgbe_set_rxfh() updates the rss_key copy in the driver
memory, but does not push the new value into the h/w. This commit
add a new helper for the latter operation and call it in
ixgbe_set_rxfh(), so that the h/w rss key value can be really
updated via ethtool.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  4 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 19 ++++++++++++++++---
 3 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index ef81c3d..8fb9fbf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -1026,6 +1026,7 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 				  struct ixgbe_adapter *adapter,
 				  struct ixgbe_ring *tx_ring);
 u32 ixgbe_rss_indir_tbl_entries(struct ixgbe_adapter *adapter);
+void ixgbe_store_key(struct ixgbe_adapter *adapter);
 void ixgbe_store_reta(struct ixgbe_adapter *adapter);
 s32 ixgbe_negotiate_fc(struct ixgbe_hw *hw, u32 adv_reg, u32 lp_reg,
 		       u32 adv_sym, u32 adv_asm, u32 lp_sym, u32 lp_asm);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index fd192bf..e40f9ce 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -3003,8 +3003,10 @@ static int ixgbe_set_rxfh(struct net_device *netdev, const u32 *indir,
 	}
 
 	/* Fill out the rss hash key */
-	if (key)
+	if (key) {
 		memcpy(adapter->rss_key, key, ixgbe_get_rxfh_key_size(netdev));
+		ixgbe_store_key(adapter);
+	}
 
 	ixgbe_store_reta(adapter);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1e2f39e..0c23ab8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3411,6 +3411,21 @@ u32 ixgbe_rss_indir_tbl_entries(struct ixgbe_adapter *adapter)
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
@@ -3475,7 +3490,6 @@ static void ixgbe_store_vfreta(struct ixgbe_adapter *adapter)
 
 static void ixgbe_setup_reta(struct ixgbe_adapter *adapter)
 {
-	struct ixgbe_hw *hw = &adapter->hw;
 	u32 i, j;
 	u32 reta_entries = ixgbe_rss_indir_tbl_entries(adapter);
 	u16 rss_i = adapter->ring_feature[RING_F_RSS].indices;
@@ -3488,8 +3502,7 @@ static void ixgbe_setup_reta(struct ixgbe_adapter *adapter)
 		rss_i = 4;
 
 	/* Fill out hash function seeds */
-	for (i = 0; i < 10; i++)
-		IXGBE_WRITE_REG(hw, IXGBE_RSSRK(i), adapter->rss_key[i]);
+	ixgbe_store_key(adapter);
 
 	/* Fill out redirection table */
 	memset(adapter->rss_indir_tbl, 0, sizeof(adapter->rss_indir_tbl));
-- 
1.8.3.1
