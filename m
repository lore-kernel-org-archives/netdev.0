From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/18] ixgbe: Fix FCRTH value in VM-to-VM loopback mode
Date: Wed, 23 Sep 2015 23:59:39 -0700
Message-ID: <1443077981-55791-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36281 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932687AbbIXG7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 02:59:55 -0400
In-Reply-To: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

The 82599 and X540 datasheets require that FCRTH be "set" for Tx
switching (VM-to-VM loopback) but it did not previously specify what
the value should be set to. It has now been determined that
the correct value is RXPBSIZE - (24*1024).

This setting is also required for later devices.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    | 7 ++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c | 8 +++++++-
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 98e1ddd..ce61b36 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -2164,10 +2164,11 @@ s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw)
 			/*
 			 * In order to prevent Tx hangs when the internal Tx
 			 * switch is enabled we must set the high water mark
-			 * to the maximum FCRTH value.  This allows the Tx
-			 * switch to function even under heavy Rx workloads.
+			 * to the Rx packet buffer size - 24KB.  This allows
+			 * the Tx switch to function even under heavy Rx
+			 * workloads.
 			 */
-			fcrth = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(i)) - 32;
+			fcrth = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(i)) - 24576;
 		}
 
 		IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(i), fcrth);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
index 3b932fe..23277ab 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
@@ -259,7 +259,13 @@ s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw, u8 pfc_en, u8 *prio_tc)
 			fcrtl = (hw->fc.low_water[i] << 10) | IXGBE_FCRTL_XONE;
 			IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(i), fcrtl);
 		} else {
-			reg = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(i)) - 32;
+			/* In order to prevent Tx hangs when the internal Tx
+			 * switch is enabled we must set the high water mark
+			 * to the Rx packet buffer size - 24KB.  This allows
+			 * the Tx switch to function even under heavy Rx
+			 * workloads.
+			 */
+			reg = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(i)) - 24576;
 			IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(i), 0);
 		}
 
-- 
2.4.3
