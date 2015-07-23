From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] ixgbevf: add support for reporting RSS key and hash table for X550
Date: Thu, 23 Jul 2015 06:52:30 -0700
Message-ID: <1437659564-48822-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:11915 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752615AbbGWNwt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 09:52:49 -0400
In-Reply-To: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch extends the reporting of the RSS key and hash table by
adding support for X550 VFs. The difference is that X550 VFs have
their own registers for RSS key and indirection table, so there is
no need to query the PF.

The RSS key and indirection table are stored in the adapter structure
during the configuration of VFRSSRK and VFRETA which in turn can be
used in ethtool for reporting.

The logic for writing VFRETA is also changed to make sure that the
indirection table is reported correctly.

In addition this patch adds defines for the VFRETA entries and number
of VFRSSRK registers as well as some whitespace cleanups.

Reported-by: Vlad Zolotarov <vladz@cloudius-systems.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      | 51 +++++++++++++----------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  9 +++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 21 ++++++----
 3 files changed, 47 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index b2f5b16..d3e5f5b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -813,22 +813,15 @@ static u32 ixgbevf_get_rxfh_indir_size(struct net_device *netdev)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 
-	/* We support this operation only for 82599 and x540 at the moment */
-	if (adapter->hw.mac.type < ixgbe_mac_X550_vf)
-		return IXGBEVF_82599_RETA_SIZE;
+	if (adapter->hw.mac.type >= ixgbe_mac_X550_vf)
+		return IXGBEVF_X550_VFRETA_SIZE;
 
-	return 0;
+	return IXGBEVF_82599_RETA_SIZE;
 }
 
 static u32 ixgbevf_get_rxfh_key_size(struct net_device *netdev)
 {
-	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
-
-	/* We support this operation only for 82599 and x540 at the moment */
-	if (adapter->hw.mac.type < ixgbe_mac_X550_vf)
-		return IXGBEVF_RSS_HASH_KEY_SIZE;
-
-	return 0;
+	return IXGBEVF_RSS_HASH_KEY_SIZE;
 }
 
 static int ixgbevf_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
@@ -840,21 +833,33 @@ static int ixgbevf_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
 	if (hfunc)
 		*hfunc = ETH_RSS_HASH_TOP;
 
-	/* If neither indirection table nor hash key was requested - just
-	 * return a success avoiding taking any locks.
-	 */
-	if (!indir && !key)
-		return 0;
+	if (adapter->hw.mac.type >= ixgbe_mac_X550_vf) {
+		if (key)
+			memcpy(key, adapter->rss_key, sizeof(adapter->rss_key));
 
-	spin_lock_bh(&adapter->mbx_lock);
-	if (indir)
-		err = ixgbevf_get_reta_locked(&adapter->hw, indir,
-					      adapter->num_rx_queues);
+		if (indir) {
+			int i;
 
-	if (!err && key)
-		err = ixgbevf_get_rss_key_locked(&adapter->hw, key);
+			for (i = 0; i < IXGBEVF_X550_VFRETA_SIZE; i++)
+				indir[i] = adapter->rss_indir_tbl[i];
+		}
+	} else {
+		/* If neither indirection table nor hash key was requested
+		 *  - just return a success avoiding taking any locks.
+		 */
+		if (!indir && !key)
+			return 0;
 
-	spin_unlock_bh(&adapter->mbx_lock);
+		spin_lock_bh(&adapter->mbx_lock);
+		if (indir)
+			err = ixgbevf_get_reta_locked(&adapter->hw, indir,
+						      adapter->num_rx_queues);
+
+		if (!err && key)
+			err = ixgbevf_get_rss_key_locked(&adapter->hw, key);
+
+		spin_unlock_bh(&adapter->mbx_lock);
+	}
 
 	return err;
 }
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 775d089..04c7ec8 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -144,9 +144,11 @@ struct ixgbevf_ring {
 
 #define MAX_RX_QUEUES IXGBE_VF_MAX_RX_QUEUES
 #define MAX_TX_QUEUES IXGBE_VF_MAX_TX_QUEUES
-#define IXGBEVF_MAX_RSS_QUEUES	2
-#define IXGBEVF_82599_RETA_SIZE	128
+#define IXGBEVF_MAX_RSS_QUEUES		2
+#define IXGBEVF_82599_RETA_SIZE		128	/* 128 entries */
+#define IXGBEVF_X550_VFRETA_SIZE	64	/* 64 entries */
 #define IXGBEVF_RSS_HASH_KEY_SIZE	40
+#define IXGBEVF_VFRSSRK_REGS		10	/* 10 registers for RSS key */
 
 #define IXGBEVF_DEFAULT_TXD	1024
 #define IXGBEVF_DEFAULT_RXD	512
@@ -447,6 +449,9 @@ struct ixgbevf_adapter {
 
 	spinlock_t mbx_lock;
 	unsigned long last_reset;
+
+	u32 rss_key[IXGBEVF_VFRSSRK_REGS];
+	u8 rss_indir_tbl[IXGBEVF_X550_VFRETA_SIZE];
 };
 
 enum ixbgevf_state_t {
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index b2c86f1..88298a3 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1696,22 +1696,25 @@ static void ixgbevf_setup_vfmrqc(struct ixgbevf_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 vfmrqc = 0, vfreta = 0;
-	u32 rss_key[10];
 	u16 rss_i = adapter->num_rx_queues;
-	int i, j;
+	u8 i, j;
 
 	/* Fill out hash function seeds */
-	netdev_rss_key_fill(rss_key, sizeof(rss_key));
-	for (i = 0; i < 10; i++)
-		IXGBE_WRITE_REG(hw, IXGBE_VFRSSRK(i), rss_key[i]);
+	netdev_rss_key_fill(adapter->rss_key, sizeof(adapter->rss_key));
+	for (i = 0; i < IXGBEVF_VFRSSRK_REGS; i++)
+		IXGBE_WRITE_REG(hw, IXGBE_VFRSSRK(i), adapter->rss_key[i]);
 
-	/* Fill out redirection table */
-	for (i = 0, j = 0; i < 64; i++, j++) {
+	for (i = 0, j = 0; i < IXGBEVF_X550_VFRETA_SIZE; i++, j++) {
 		if (j == rss_i)
 			j = 0;
-		vfreta = (vfreta << 8) | (j * 0x1);
-		if ((i & 3) == 3)
+
+		adapter->rss_indir_tbl[i] = j;
+
+		vfreta |= j << (i & 0x3) * 8;
+		if ((i & 3) == 3) {
 			IXGBE_WRITE_REG(hw, IXGBE_VFRETA(i >> 2), vfreta);
+			vfreta = 0;
+		}
 	}
 
 	/* Perform hash on these packet types */
-- 
2.4.3
