From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] igb: add function to get maximum RSS queues
Date: Fri, 28 Jul 2017 15:03:26 +0800
Message-ID: <1501225406-43554-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:15971 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751958AbdG1HNE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 03:13:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new function igb_get_max_rss_queues() to get maximum
RSS queues, this will reduce duplicate code and facilitate future
maintenance.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |  1 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 32 +---------------------------
 drivers/net/ethernet/intel/igb/igb_main.c    | 12 +++++++++--
 3 files changed, 12 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 06ffb2b..ca94eff 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -684,6 +684,7 @@ void igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector, void *va,
 int igb_ptp_set_ts_config(struct net_device *netdev, struct ifreq *ifr);
 int igb_ptp_get_ts_config(struct net_device *netdev, struct ifreq *ifr);
 void igb_set_flag_queue_pairs(struct igb_adapter *, const u32);
+unsigned int igb_get_max_rss_queues(struct igb_adapter *);
 #ifdef CONFIG_IGB_HWMON
 void igb_sysfs_exit(struct igb_adapter *adapter);
 int igb_sysfs_init(struct igb_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index d06a8db..606e676 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -3338,37 +3338,7 @@ static int igb_set_rxfh(struct net_device *netdev, const u32 *indir,
 
 static unsigned int igb_max_channels(struct igb_adapter *adapter)
 {
-	struct e1000_hw *hw = &adapter->hw;
-	unsigned int max_combined = 0;
-
-	switch (hw->mac.type) {
-	case e1000_i211:
-		max_combined = IGB_MAX_RX_QUEUES_I211;
-		break;
-	case e1000_82575:
-	case e1000_i210:
-		max_combined = IGB_MAX_RX_QUEUES_82575;
-		break;
-	case e1000_i350:
-		if (!!adapter->vfs_allocated_count) {
-			max_combined = 1;
-			break;
-		}
-		/* fall through */
-	case e1000_82576:
-		if (!!adapter->vfs_allocated_count) {
-			max_combined = 2;
-			break;
-		}
-		/* fall through */
-	case e1000_82580:
-	case e1000_i354:
-	default:
-		max_combined = IGB_MAX_RX_QUEUES;
-		break;
-	}
-
-	return max_combined;
+	return igb_get_max_rss_queues(adapter);
 }
 
 static void igb_get_channels(struct net_device *netdev,
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index ec62410..e6cc6b5 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3026,10 +3026,10 @@ static void igb_probe_vfs(struct igb_adapter *adapter)
 #endif /* CONFIG_PCI_IOV */
 }
 
-static void igb_init_queue_configuration(struct igb_adapter *adapter)
+unsigned int igb_get_max_rss_queues(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	u32 max_rss_queues;
+	unsigned int max_rss_queues;
 
 	/* Determine the maximum number of RSS queues supported. */
 	switch (hw->mac.type) {
@@ -3060,6 +3060,14 @@ static void igb_init_queue_configuration(struct igb_adapter *adapter)
 		break;
 	}
 
+	return max_rss_queues;
+}
+
+static void igb_init_queue_configuration(struct igb_adapter *adapter)
+{
+	u32 max_rss_queues;
+
+	max_rss_queues = igb_get_max_rss_queues(adapter);
 	adapter->rss_queues = min_t(u32, max_rss_queues, num_online_cpus());
 
 	igb_set_flag_queue_pairs(adapter, max_rss_queues);
-- 
1.8.3.1
