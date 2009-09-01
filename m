From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/3] ixgbe: Properly disable DCB arbiters prior to
	applying changes
Date: Tue, 01 Sep 2009 16:49:56 -0700
Message-ID: <20090901234955.4617.9623.stgit@localhost.localdomain>
References: <20090901234916.4617.73579.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:58433 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755384AbZIAXuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 19:50:11 -0400
In-Reply-To: <20090901234916.4617.73579.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

When disabling the Rx and Tx data arbiters prior to configuration changes,
the arbiters were not being shut down properly.  This can create a race
in the DCB hardware blocks, and potentially hang the arbiters.  Also, the
Tx descriptor arbiter shouldn't be disabled when applying configuration
changes; disabling this arbiter can cause a Tx hang.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_82599.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index 589f62c..ec8a252 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -145,8 +145,12 @@ s32 ixgbe_dcb_config_rx_arbiter_82599(struct ixgbe_hw *hw,
 	u32    credit_max    = 0;
 	u8     i             = 0;
 
-	/* Disable the arbiter before changing parameters */
-	IXGBE_WRITE_REG(hw, IXGBE_RTRPCS, IXGBE_RTRPCS_ARBDIS);
+	/*
+	 * Disable the arbiter before changing parameters
+	 * (always enable recycle mode; WSP)
+	 */
+	reg = IXGBE_RTRPCS_RRM | IXGBE_RTRPCS_RAC | IXGBE_RTRPCS_ARBDIS;
+	IXGBE_WRITE_REG(hw, IXGBE_RTRPCS, reg);
 
 	/* Map all traffic classes to their UP, 1 to 1 */
 	reg = 0;
@@ -194,9 +198,6 @@ s32 ixgbe_dcb_config_tx_desc_arbiter_82599(struct ixgbe_hw *hw,
 	u32    reg, max_credits;
 	u8     i;
 
-	/* Disable the arbiter before changing parameters */
-	IXGBE_WRITE_REG(hw, IXGBE_RTTDCS, IXGBE_RTTDCS_ARBDIS);
-
 	/* Clear the per-Tx queue credits; we use per-TC instead */
 	for (i = 0; i < 128; i++) {
 		IXGBE_WRITE_REG(hw, IXGBE_RTTDQSEL, i);
@@ -244,8 +245,14 @@ s32 ixgbe_dcb_config_tx_data_arbiter_82599(struct ixgbe_hw *hw,
 	u32 reg;
 	u8 i;
 
-	/* Disable the arbiter before changing parameters */
-	IXGBE_WRITE_REG(hw, IXGBE_RTTPCS, IXGBE_RTTPCS_ARBDIS);
+	/*
+	 * Disable the arbiter before changing parameters
+	 * (always enable recycle mode; SP; arb delay)
+	 */
+	reg = IXGBE_RTTPCS_TPPAC | IXGBE_RTTPCS_TPRM |
+	      (IXGBE_RTTPCS_ARBD_DCB << IXGBE_RTTPCS_ARBD_SHIFT) |
+	      IXGBE_RTTPCS_ARBDIS;
+	IXGBE_WRITE_REG(hw, IXGBE_RTTPCS, reg);
 
 	/* Map all traffic classes to their UP, 1 to 1 */
 	reg = 0;

