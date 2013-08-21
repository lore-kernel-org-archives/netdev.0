From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  11/15] igb: Expose RSS indirection table for ethtool
Date: Wed, 21 Aug 2013 01:23:32 -0700
Message-ID: <1377073416-7872-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377073416-7872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2670 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751716Ab3HUIXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 04:23:53 -0400
In-Reply-To: <1377073416-7872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>

This patch adds the ethtool callbacks necessary to change the RETA
indirection table from userspace.

In order to achieve this, we add the indirection table field (rss_indir_tbl)
in the board specific data structure (struct igb_adapter) to preserve the
values across hardware resets.

The indirection table must be initialized with default values in the
following cases:
	* at module init time
	* when the number of RX queues changes.
For this reason we add a new field (rss_indir_tbl_init) in igb_adapter
that keeps track of the number of RX queues. Whenever the number of RX
queues changes, the rss_indir_tbl is modified and initialized with default
values. The rss_indir_tbl_init is updated accordingly.

Signed-off-by: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |  3 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 87 ++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/igb_main.c    | 28 +++------
 3 files changed, 97 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 5a2659b..c1fae7a 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -446,6 +446,8 @@ struct igb_adapter {
 	struct i2c_algo_bit_data i2c_algo;
 	struct i2c_adapter i2c_adap;
 	struct i2c_client *i2c_client;
+	u32 rss_indir_tbl_init;
+	u8 rss_indir_tbl[IGB_RETA_SIZE];
 };
 
 #define IGB_FLAG_HAS_MSI		(1 << 0)
@@ -482,6 +484,7 @@ extern int igb_up(struct igb_adapter *);
 extern void igb_down(struct igb_adapter *);
 extern void igb_reinit_locked(struct igb_adapter *);
 extern void igb_reset(struct igb_adapter *);
+extern void igb_write_rss_indir_tbl(struct igb_adapter *);
 extern int igb_set_spd_dplx(struct igb_adapter *, u32, u8);
 extern int igb_setup_tx_resources(struct igb_ring *);
 extern int igb_setup_rx_resources(struct igb_ring *);
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 03137e2..036221d 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2784,6 +2784,90 @@ static void igb_ethtool_complete(struct net_device *netdev)
 	pm_runtime_put(&adapter->pdev->dev);
 }
 
+static u32 igb_get_rxfh_indir_size(struct net_device *netdev)
+{
+	return IGB_RETA_SIZE;
+}
+
+static int igb_get_rxfh_indir(struct net_device *netdev, u32 *indir)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	int i;
+
+	for (i = 0; i < IGB_RETA_SIZE; i++)
+		indir[i] = adapter->rss_indir_tbl[i];
+
+	return 0;
+}
+
+void igb_write_rss_indir_tbl(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 reg = E1000_RETA(0);
+	u32 shift = 0;
+	int i = 0;
+
+	switch (hw->mac.type) {
+	case e1000_82575:
+		shift = 6;
+		break;
+	case e1000_82576:
+		/* 82576 supports 2 RSS queues for SR-IOV */
+		if (adapter->vfs_allocated_count)
+			shift = 3;
+		break;
+	default:
+		break;
+	}
+
+	while (i < IGB_RETA_SIZE) {
+		u32 val = 0;
+		int j;
+
+		for (j = 3; j >= 0; j--) {
+			val <<= 8;
+			val |= adapter->rss_indir_tbl[i + j];
+		}
+
+		wr32(reg, val << shift);
+		reg += 4;
+		i += 4;
+	}
+}
+
+static int igb_set_rxfh_indir(struct net_device *netdev, const u32 *indir)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	int i;
+	u32 num_queues;
+
+	num_queues = adapter->rss_queues;
+
+	switch (hw->mac.type) {
+	case e1000_82576:
+		/* 82576 supports 2 RSS queues for SR-IOV */
+		if (adapter->vfs_allocated_count)
+			num_queues = 2;
+		break;
+	default:
+		break;
+	}
+
+	/* Verify user input. */
+	for (i = 0; i < IGB_RETA_SIZE; i++)
+		if (indir[i] > num_queues)
+			return -EINVAL;
+
+
+	for (i = 0; i < IGB_RETA_SIZE; i++)
+		adapter->rss_indir_tbl[i] = indir[i];
+
+	igb_write_rss_indir_tbl(adapter);
+
+	return 0;
+}
+
 static const struct ethtool_ops igb_ethtool_ops = {
 	.get_settings		= igb_get_settings,
 	.set_settings		= igb_set_settings,
@@ -2817,6 +2901,9 @@ static const struct ethtool_ops igb_ethtool_ops = {
 	.set_eee		= igb_set_eee,
 	.get_module_info	= igb_get_module_info,
 	.get_module_eeprom	= igb_get_module_eeprom,
+	.get_rxfh_indir_size	= igb_get_rxfh_indir_size,
+	.get_rxfh_indir		= igb_get_rxfh_indir,
+	.set_rxfh_indir		= igb_set_rxfh_indir,
 	.begin			= igb_ethtool_begin,
 	.complete		= igb_ethtool_complete,
 };
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 1acd9c0..df33c4b 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3126,7 +3126,7 @@ static void igb_setup_mrqc(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 mrqc, rxcsum;
-	u32 j, num_rx_queues, shift = 0;
+	u32 j, num_rx_queues;
 	static const u32 rsskey[10] = { 0xDA565A6D, 0xC20E5B25, 0x3D256741,
 					0xB08FA343, 0xCB2BCAD0, 0xB4307BAE,
 					0xA32DCB77, 0x0CF23080, 0x3BB7426A,
@@ -3139,35 +3139,21 @@ static void igb_setup_mrqc(struct igb_adapter *adapter)
 	num_rx_queues = adapter->rss_queues;
 
 	switch (hw->mac.type) {
-	case e1000_82575:
-		shift = 6;
-		break;
 	case e1000_82576:
 		/* 82576 supports 2 RSS queues for SR-IOV */
-		if (adapter->vfs_allocated_count) {
-			shift = 3;
+		if (adapter->vfs_allocated_count)
 			num_rx_queues = 2;
-		}
 		break;
 	default:
 		break;
 	}
 
-	/* Populate the indirection table 4 entries at a time.  To do this
-	 * we are generating the results for n and n+2 and then interleaving
-	 * those with the results with n+1 and n+3.
-	 */
-	for (j = 0; j < IGB_RETA_SIZE / 4; j++) {
-		/* first pass generates n and n+2 */
-		u32 base = ((j * 0x00040004) + 0x00020000) * num_rx_queues;
-		u32 reta = (base & 0x07800780) >> (7 - shift);
-
-		/* second pass generates n+1 and n+3 */
-		base += 0x00010001 * num_rx_queues;
-		reta |= (base & 0x07800780) << (1 + shift);
-
-		wr32(E1000_RETA(j), reta);
+	if (adapter->rss_indir_tbl_init != num_rx_queues) {
+		for (j = 0; j < IGB_RETA_SIZE; j++)
+			adapter->rss_indir_tbl[j] = (j * num_rx_queues) / IGB_RETA_SIZE;
+		adapter->rss_indir_tbl_init = num_rx_queues;
 	}
+	igb_write_rss_indir_tbl(adapter);
 
 	/* Disable raw packet checksumming so that RSS hash is placed in
 	 * descriptor on writeback.  No need to enable TCP/UDP/IP checksum
-- 
1.8.3.1
