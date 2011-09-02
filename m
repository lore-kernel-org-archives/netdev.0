From: Carolyn Wyborny <carolyn.wyborny@intel.com>
Subject: [RFC, 2/2] igb:  Implementation of ethtool priv_flags for igb driver.
Date: Fri,  2 Sep 2011 13:50:31 -0700
Message-ID: <1314996631-4773-2-git-send-email-carolyn.wyborny@intel.com>
References: <1314996631-4773-1-git-send-email-carolyn.wyborny@intel.com>
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56428 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755816Ab1IBUvN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Sep 2011 16:51:13 -0400
In-Reply-To: <1314996631-4773-1-git-send-email-carolyn.wyborny@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds igb driver support for the ethtool private flags
interface. Two features are initially configured for private flags
support as an example for use with the implementation in ethtoool
application.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |    2 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c |   28 ++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/igb_main.c    |    1 +
 3 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index bb47ed1..a8be3eb 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -360,6 +360,7 @@ struct igb_adapter {
 	u32 rss_queues;
 	u32 wvbr;
 	int node;
+	u32 pflags;
 };
 
 #define IGB_FLAG_HAS_MSI           (1 << 0)
@@ -367,6 +368,7 @@ struct igb_adapter {
 #define IGB_FLAG_QUAD_PORT_A       (1 << 2)
 #define IGB_FLAG_QUEUE_PAIRS       (1 << 3)
 #define IGB_FLAG_DMAC              (1 << 4)
+#define IGB_FLAG_EEE               (1 << 5)
 
 /* DMA Coalescing defines */
 #define IGB_MIN_TXPBSIZE           20408
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 64fb4ef..3a251c7 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -696,6 +696,9 @@ static void igb_get_drvinfo(struct net_device *netdev,
 	drvinfo->testinfo_len = IGB_TEST_LEN;
 	drvinfo->regdump_len = igb_get_regs_len(netdev);
 	drvinfo->eedump_len = igb_get_eeprom_len(netdev);
+#ifdef ETHTOOL_GPFLAGS
+	drvinfo->n_priv_flags = 2;
+#endif
 }
 
 static void igb_get_ringparam(struct net_device *netdev,
@@ -2171,6 +2174,29 @@ static void igb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 	}
 }
 
+static int igb_set_pflags(struct net_device *netdev, u32 data)
+{
+	u32 supported_flags = IGB_FLAG_EEE;
+	struct igb_adapter *adapter = netdev_priv(netdev);
+
+	if (data & supported_flags) {
+		adapter->pflags = data;
+	} else {
+		printk(KERN_INFO, "set_pflags:flag not supported..");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static u32 igb_get_pflags(struct net_device *netdev)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+
+	return adapter->pflags;
+
+}
+
 static const struct ethtool_ops igb_ethtool_ops = {
 	.get_settings           = igb_get_settings,
 	.set_settings           = igb_set_settings,
@@ -2197,6 +2223,8 @@ static const struct ethtool_ops igb_ethtool_ops = {
 	.get_ethtool_stats      = igb_get_ethtool_stats,
 	.get_coalesce           = igb_get_coalesce,
 	.set_coalesce           = igb_set_coalesce,
+	.get_priv_flags         = igb_get_pflags,
+	.set_priv_flags         = igb_set_pflags,
 };
 
 void igb_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 289861c..a534f32 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2175,6 +2175,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	switch (hw->mac.type) {
 	case e1000_i350:
 		igb_set_eee_i350(hw);
+		adapter->pflags |= IGB_FLAG_EEE;
 		break;
 	default:
 		break;
-- 
1.7.4.4
