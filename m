From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/12] IXGBE: Set the SW prio_tc values at initialization to the HW setting.
Date: Tue, 21 May 2013 15:03:20 -0700
Message-ID: <1369173800-20326-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Amir Hanania <amir.hanania@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:9532 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751604Ab3EUWDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 18:03:36 -0400
In-Reply-To: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Hanania <amir.hanania@intel.com>

Set the SW prio_tc values at initialization to the HW setting.
Setting the SW prio_tc default values to be the HW setting by reading the
rtrup2tc register. For any TC change we need to reset the device.
This will remove the need to reset the device at the first
time we call ixgbe_dcbnl_ieee_setets.

Signed-off-by: Amir Hanania <amir.hanania@intel.com>
Tested-by: Jack Morgan<jack.morgan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c       | 23 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h       |  2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c    |  3 +++
 4 files changed, 29 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
index 1f2c805..e055e00 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
@@ -380,3 +380,26 @@ s32 ixgbe_dcb_hw_ets_config(struct ixgbe_hw *hw,
 	}
 	return 0;
 }
+
+static void ixgbe_dcb_read_rtrup2tc_82599(struct ixgbe_hw *hw, u8 *map)
+{
+	u32 reg, i;
+
+	reg = IXGBE_READ_REG(hw, IXGBE_RTRUP2TC);
+	for (i = 0; i < MAX_USER_PRIORITY; i++)
+		map[i] = IXGBE_RTRUP2TC_UP_MASK &
+			(reg >> (i * IXGBE_RTRUP2TC_UP_SHIFT));
+	return;
+}
+
+void ixgbe_dcb_read_rtrup2tc(struct ixgbe_hw *hw, u8 *map)
+{
+	switch (hw->mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		ixgbe_dcb_read_rtrup2tc_82599(hw, map);
+		break;
+	default:
+		break;
+	}
+}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h
index 1634de8..fc0a2dd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h
@@ -159,6 +159,8 @@ s32 ixgbe_dcb_hw_ets_config(struct ixgbe_hw *hw, u16 *refill, u16 *max,
 s32 ixgbe_dcb_hw_pfc_config(struct ixgbe_hw *hw, u8 pfc_en, u8 *tc_prio);
 s32 ixgbe_dcb_hw_config(struct ixgbe_hw *, struct ixgbe_dcb_config *);
 
+void ixgbe_dcb_read_rtrup2tc(struct ixgbe_hw *hw, u8 *map);
+
 /* DCB definitions for credit calculation */
 #define DCB_CREDIT_QUANTUM	64   /* DCB Quantum */
 #define MAX_CREDIT_REFILL       511  /* 0x1FF * 64B = 32704B */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h
index a4ef076..d71d9ce 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h
@@ -45,6 +45,7 @@
 
 /* Receive UP2TC mapping */
 #define IXGBE_RTRUP2TC_UP_SHIFT 3
+#define IXGBE_RTRUP2TC_UP_MASK	7
 /* Transmit UP2TC mapping */
 #define IXGBE_RTTUP2TC_UP_SHIFT 3
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index f3d68f9..edd89a1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -554,6 +554,9 @@ static int ixgbe_dcbnl_ieee_setets(struct net_device *dev,
 		for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
 			adapter->ixgbe_ieee_ets->prio_tc[i] =
 				IEEE_8021QAZ_MAX_TCS;
+		/* if possible update UP2TC mappings from HW */
+		ixgbe_dcb_read_rtrup2tc(&adapter->hw,
+					adapter->ixgbe_ieee_ets->prio_tc);
 	}
 
 	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
-- 
1.7.11.7
