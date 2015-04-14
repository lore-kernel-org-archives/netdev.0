From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/25] fm10k: use hw->mac.max_queues for stats
Date: Tue, 14 Apr 2015 16:50:55 -0700
Message-ID: <1429055471-401-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62596 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753923AbbDNXvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:22 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even though it shouldn't strictly matter, don't count queue stats higher
than the max_queues value stored for this mac. This ensures that we
don't attempt to check queues which don't belong to use in VFs. This
shouldn't be a visible change, as the VFs should see zero for queues
which don't belong to them.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 18 +++++++++++-------
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     |  2 +-
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 478e67b..cbfaf94 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -98,12 +98,11 @@ static const struct fm10k_stats fm10k_gstrings_stats[] = {
 
 #define FM10K_GLOBAL_STATS_LEN ARRAY_SIZE(fm10k_gstrings_stats)
 
-#define FM10K_QUEUE_STATS_LEN \
-	  (MAX_QUEUES * 2 * (sizeof(struct fm10k_queue_stats) / sizeof(u64)))
+#define FM10K_QUEUE_STATS_LEN(_n) \
+	( (_n) * 2 * (sizeof(struct fm10k_queue_stats) / sizeof(u64)))
 
-#define FM10K_STATS_LEN (FM10K_GLOBAL_STATS_LEN + \
-			 FM10K_NETDEV_STATS_LEN + \
-			 FM10K_QUEUE_STATS_LEN)
+#define FM10K_STATIC_STATS_LEN (FM10K_GLOBAL_STATS_LEN + \
+				FM10K_NETDEV_STATS_LEN)
 
 static const char fm10k_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Mailbox test (on/offline)"
@@ -155,11 +154,16 @@ static void fm10k_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 
 static int fm10k_get_sset_count(struct net_device *dev, int sset)
 {
+	struct fm10k_intfc *interface = netdev_priv(dev);
+	struct fm10k_hw *hw = &interface->hw;
+	int stats_len = FM10K_STATIC_STATS_LEN;
+
 	switch (sset) {
 	case ETH_SS_TEST:
 		return FM10K_TEST_LEN;
 	case ETH_SS_STATS:
-		return FM10K_STATS_LEN;
+		stats_len += FM10K_QUEUE_STATS_LEN(hw->mac.max_queues);
+		return stats_len;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -369,7 +373,7 @@ static void fm10k_get_drvinfo(struct net_device *dev,
 	strncpy(info->bus_info, pci_name(interface->pdev),
 		sizeof(info->bus_info) - 1);
 
-	info->n_stats = FM10K_STATS_LEN;
+	info->n_stats = fm10k_get_sset_count(dev, ETH_SS_STATS);
 
 	info->regdump_len = fm10k_get_regs_len(dev);
 }
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 9d9dce6..879124b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -360,7 +360,7 @@ void fm10k_update_stats(struct fm10k_intfc *interface)
 
 	hw->mac.ops.update_hw_stats(hw, &interface->stats);
 
-	for (i = 0; i < FM10K_MAX_QUEUES_PF; i++) {
+	for (i = 0; i < hw->mac.max_queues; i++) {
 		struct fm10k_hw_stats_q *q = &interface->stats.q[i];
 
 		tx_bytes_nic += q->tx_bytes.count;
-- 
1.9.3
