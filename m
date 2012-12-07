From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/5] ixgbe: check whether thermal sensor is enabled.
Date: Thu,  6 Dec 2012 22:11:32 -0800
Message-ID: <1354860695-27039-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1354860695-27039-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4860 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756Ab2LGGLt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 01:11:49 -0500
In-Reply-To: <1354860695-27039-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The X540's internal thermal sensor should not be enabled for all devices, but
only those devices which enable it in the NVM image. It is expected that
actively cooled devices will have it enabled, but passively cooled devices might
not want it enabled. This is due to passively cooled devices operating very near
the thermal threshold, sometimes within the margin of error of the thermal
sensor. Thus these devices may not be good candidates for using the thermal
sensor.

This patch uses the enabled bit in the FWSM register to check whether we should
be enabling the thermal sensor, and only sets the THERMAL_SENSOR_CAPABLE flag
for those devices which have it enabled.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 5 ++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h | 2 ++
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b7bc22b..fb165b6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4467,6 +4467,7 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned int rss;
+	u32 fwsm;
 #ifdef CONFIG_IXGBE_DCB
 	int j;
 	struct tc_configuration *tc;
@@ -4490,7 +4491,9 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		adapter->max_q_vectors = MAX_Q_VECTORS_82598;
 		break;
 	case ixgbe_mac_X540:
-		adapter->flags2 |= IXGBE_FLAG2_TEMP_SENSOR_CAPABLE;
+		fwsm = IXGBE_READ_REG(hw, IXGBE_FWSM);
+		if (fwsm & IXGBE_FWSM_TS_ENABLED)
+			adapter->flags2 |= IXGBE_FLAG2_TEMP_SENSOR_CAPABLE;
 	case ixgbe_mac_82599EB:
 		adapter->max_q_vectors = MAX_Q_VECTORS_82599;
 		adapter->flags2 |= IXGBE_FLAG2_RSC_CAPABLE;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index cab302a..9cd8a13 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1954,6 +1954,8 @@ enum {
 #define IXGBE_MRQC_RSS_FIELD_IPV6_EX_UDP 0x01000000
 #define IXGBE_MRQC_L3L4TXSWEN            0x00008000
 
+#define IXGBE_FWSM_TS_ENABLED	0x1
+
 /* Queue Drop Enable */
 #define IXGBE_QDE_ENABLE     0x00000001
 #define IXGBE_QDE_IDX_MASK   0x00007F00
-- 
1.7.11.7
