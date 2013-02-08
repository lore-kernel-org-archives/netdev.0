From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/10] ixgbe: refactor initialization of feature flags
Date: Fri,  8 Feb 2013 02:39:18 -0800
Message-ID: <1360319958-10497-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1360319958-10497-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52215 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964774Ab3BHKj2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2013 05:39:28 -0500
In-Reply-To: <1360319958-10497-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch reshuffles the switch/case structure of the flag assignment to
allow for the flags to be set for each MAC type separately. This is needed
for new HW that does not have feature parity with older HW.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Jack Morgan <jack.morgan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 58 ++++++++++++++++++---------
 1 file changed, 38 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 396e280..693b158 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4479,38 +4479,56 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	hw->subsystem_vendor_id = pdev->subsystem_vendor;
 	hw->subsystem_device_id = pdev->subsystem_device;
 
-	/* Set capability flags */
+	/* Set common capability flags and settings */
 	rss = min_t(int, IXGBE_MAX_RSS_INDICES, num_online_cpus());
 	adapter->ring_feature[RING_F_RSS].limit = rss;
+	adapter->flags2 |= IXGBE_FLAG2_RSC_CAPABLE;
+	adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
+	adapter->ring_feature[RING_F_FDIR].limit = IXGBE_MAX_FDIR_INDICES;
+	adapter->max_q_vectors = MAX_Q_VECTORS_82599;
+	adapter->atr_sample_rate = 20;
+	adapter->fdir_pballoc = IXGBE_FDIR_PBALLOC_64K;
+#ifdef CONFIG_IXGBE_DCA
+	adapter->flags |= IXGBE_FLAG_DCA_CAPABLE;
+#endif
+#ifdef IXGBE_FCOE
+	adapter->flags |= IXGBE_FLAG_FCOE_CAPABLE;
+	adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
+#ifdef CONFIG_IXGBE_DCB
+	/* Default traffic class to use for FCoE */
+	adapter->fcoe.up = IXGBE_FCOE_DEFTC;
+#endif /* CONFIG_IXGBE_DCB */
+#endif /* IXGBE_FCOE */
+
+	/* Set MAC specific capability flags and exceptions */
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
+		adapter->flags2 &= ~IXGBE_FLAG2_RSC_CAPABLE;
+		adapter->flags2 &= ~IXGBE_FLAG2_RSC_ENABLED;
+
 		if (hw->device_id == IXGBE_DEV_ID_82598AT)
 			adapter->flags |= IXGBE_FLAG_FAN_FAIL_CAPABLE;
+
 		adapter->max_q_vectors = MAX_Q_VECTORS_82598;
+		adapter->ring_feature[RING_F_FDIR].limit = 0;
+		adapter->atr_sample_rate = 0;
+		adapter->fdir_pballoc = 0;
+#ifdef IXGBE_FCOE
+		adapter->flags &= ~IXGBE_FLAG_FCOE_CAPABLE;
+		adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
+#ifdef CONFIG_IXGBE_DCB
+		adapter->fcoe.up = 0;
+#endif /* IXGBE_DCB */
+#endif /* IXGBE_FCOE */
+		break;
+	case ixgbe_mac_82599EB:
+		if (hw->device_id == IXGBE_DEV_ID_82599_T3_LOM)
+			adapter->flags2 |= IXGBE_FLAG2_TEMP_SENSOR_CAPABLE;
 		break;
 	case ixgbe_mac_X540:
 		fwsm = IXGBE_READ_REG(hw, IXGBE_FWSM);
 		if (fwsm & IXGBE_FWSM_TS_ENABLED)
 			adapter->flags2 |= IXGBE_FLAG2_TEMP_SENSOR_CAPABLE;
-	case ixgbe_mac_82599EB:
-		adapter->max_q_vectors = MAX_Q_VECTORS_82599;
-		adapter->flags2 |= IXGBE_FLAG2_RSC_CAPABLE;
-		adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
-		if (hw->device_id == IXGBE_DEV_ID_82599_T3_LOM)
-			adapter->flags2 |= IXGBE_FLAG2_TEMP_SENSOR_CAPABLE;
-		/* Flow Director hash filters enabled */
-		adapter->atr_sample_rate = 20;
-		adapter->ring_feature[RING_F_FDIR].limit =
-							 IXGBE_MAX_FDIR_INDICES;
-		adapter->fdir_pballoc = IXGBE_FDIR_PBALLOC_64K;
-#ifdef IXGBE_FCOE
-		adapter->flags |= IXGBE_FLAG_FCOE_CAPABLE;
-		adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
-#ifdef CONFIG_IXGBE_DCB
-		/* Default traffic class to use for FCoE */
-		adapter->fcoe.up = IXGBE_FCOE_DEFTC;
-#endif
-#endif /* IXGBE_FCOE */
 		break;
 	default:
 		break;
-- 
1.7.11.7
