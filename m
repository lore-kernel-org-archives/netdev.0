From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 12/12] ixgbe: convert to ethtool set_phys_id
Date: Wed, 27 Apr 2011 02:34:51 -0700
Message-ID: <1303896891-16006-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:13920 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755991Ab1D0JfE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 05:35:04 -0400
In-Reply-To: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Based on the original patch submitted by Stephen Hemminger.

This patch makes the following changes:
- Change ETHTOOL_ID_INACTIVE return value to 2 (blinks/sec)
- Fix restoring of IXGBE_LEDCTL

CC: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h         |    1 +
 drivers/net/ixgbe/ixgbe_ethtool.c |   29 +++++++++++++++++------------
 2 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 8d46802..37ff531 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -461,6 +461,7 @@ struct ixgbe_adapter {
 	u16 eeprom_version;
 
 	int node;
+	u32 led_reg;
 	struct work_struct check_overtemp_task;
 	u32 interrupt_event;
 	char lsc_int_name[IFNAMSIZ + 9];
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index bd7524e..7279345 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2003,25 +2003,30 @@ static int ixgbe_nway_reset(struct net_device *netdev)
 	return 0;
 }
 
-static int ixgbe_phys_id(struct net_device *netdev, u32 data)
+static int ixgbe_set_phys_id(struct net_device *netdev,
+			     enum ethtool_phys_id_state state)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
-	u32 i;
 
-	if (!data || data > 300)
-		data = 300;
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		adapter->led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
+		return 2;
 
-	for (i = 0; i < (data * 1000); i += 400) {
+	case ETHTOOL_ID_ON:
 		hw->mac.ops.led_on(hw, IXGBE_LED_ON);
-		msleep_interruptible(200);
+		break;
+
+	case ETHTOOL_ID_OFF:
 		hw->mac.ops.led_off(hw, IXGBE_LED_ON);
-		msleep_interruptible(200);
-	}
+		break;
 
-	/* Restore LED settings */
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_LEDCTL, led_reg);
+	case ETHTOOL_ID_INACTIVE:
+		/* Restore LED settings */
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_LEDCTL, adapter->led_reg);
+		break;
+	}
 
 	return 0;
 }
@@ -2469,7 +2474,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_tso                = ixgbe_set_tso,
 	.self_test              = ixgbe_diag_test,
 	.get_strings            = ixgbe_get_strings,
-	.phys_id                = ixgbe_phys_id,
+	.set_phys_id            = ixgbe_set_phys_id,
 	.get_sset_count         = ixgbe_get_sset_count,
 	.get_ethtool_stats      = ixgbe_get_ethtool_stats,
 	.get_coalesce           = ixgbe_get_coalesce,
-- 
1.7.4.4

