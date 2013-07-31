From: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
Subject: [PATCH 2/2] igb: Expose RSS indirection table for ethtool
Date: Wed, 31 Jul 2013 11:43:32 +0300
Message-ID: <1375260212-19351-2-git-send-email-laura.vasilescu@rosedu.org>
References: <1375260212-19351-1-git-send-email-laura.vasilescu@rosedu.org>
Cc: carolyn.wyborny@intel.com, anjali.singhai@intel.com,
	jeffrey.t.kirsher@intel.com, alexander.h.duyck@intel.com,
	Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:37524 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755043Ab3GaInh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 04:43:37 -0400
Received: by mail-qa0-f45.google.com with SMTP id l18so2876152qak.18
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 01:43:36 -0700 (PDT)
In-Reply-To: <1375260212-19351-1-git-send-email-laura.vasilescu@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
---
 drivers/net/ethernet/intel/igb/igb.h         |    3 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c |   87 ++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/igb_main.c    |   28 +++------
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
index 85fe7b5..3e1e51e 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2771,6 +2771,90 @@ static void igb_ethtool_complete(struct net_device *netdev)
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
@@ -2804,6 +2888,9 @@ static const struct ethtool_ops igb_ethtool_ops = {
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
index 00f5d96..600b80d 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3096,7 +3096,7 @@ static void igb_setup_mrqc(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 mrqc, rxcsum;
-	u32 j, num_rx_queues, shift = 0;
+	u32 j, num_rx_queues;
 	static const u32 rsskey[10] = { 0xDA565A6D, 0xC20E5B25, 0x3D256741,
 					0xB08FA343, 0xCB2BCAD0, 0xB4307BAE,
 					0xA32DCB77, 0x0CF23080, 0x3BB7426A,
@@ -3109,35 +3109,21 @@ static void igb_setup_mrqc(struct igb_adapter *adapter)
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
1.7.10.4
