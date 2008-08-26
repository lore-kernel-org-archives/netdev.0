From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 06/13] ixgbe: disable flow control by default
Date: Tue, 26 Aug 2008 04:27:10 -0700
Message-ID: <20080826112710.15787.57636.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:37405 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755188AbYHZL1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:27:11 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099738rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:27:11 -0700 (PDT)
In-Reply-To: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Since the adapter cannot tell what the remote end's flow control capability
is through auto-neg, we must turn off flow control by default.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h        |    6 +++---
 drivers/net/ixgbe/ixgbe_common.c |   17 +++++++++++++++++
 drivers/net/ixgbe/ixgbe_main.c   |   15 ++++++---------
 3 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 956914a..496a91a 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -69,12 +69,12 @@
 
 /* flow control */
 #define IXGBE_DEFAULT_FCRTL		0x10000
-#define IXGBE_MIN_FCRTL			      0
+#define IXGBE_MIN_FCRTL			   0x40
 #define IXGBE_MAX_FCRTL			0x7FF80
 #define IXGBE_DEFAULT_FCRTH		0x20000
-#define IXGBE_MIN_FCRTH			      0
+#define IXGBE_MIN_FCRTH			  0x600
 #define IXGBE_MAX_FCRTH			0x7FFF0
-#define IXGBE_DEFAULT_FCPAUSE		 0x6800  /* may be too long */
+#define IXGBE_DEFAULT_FCPAUSE		 0xFFFF
 #define IXGBE_MIN_FCPAUSE		      0
 #define IXGBE_MAX_FCPAUSE		 0xFFFF
 
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index a9f4d0e..9c0d0a1 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1065,6 +1065,13 @@ s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
 	rmcs_reg &= ~(IXGBE_RMCS_TFCE_PRIORITY | IXGBE_RMCS_TFCE_802_3X);
 
 	/*
+	 * 10 gig parts do not have a word in the EEPROM to determine the
+	 * default flow control setting, so we explicitly set it to full.
+	 */
+	if (hw->fc.type == ixgbe_fc_default)
+		hw->fc.type = ixgbe_fc_full;
+
+	/*
 	 * We want to save off the original Flow Control configuration just in
 	 * case we get disconnected and then reconnected into a different hub
 	 * or switch with different Flow Control capabilities.
@@ -1117,6 +1124,16 @@ s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
 	IXGBE_WRITE_REG(hw, IXGBE_RMCS, rmcs_reg);
 
 	/*
+	 * Check for invalid software configuration, zeros are completely
+	 * invalid for all parameters used past this point, and if we enable
+	 * flow control with zero water marks, we blast flow control packets.
+	 */
+	if (!hw->fc.low_water || !hw->fc.high_water || !hw->fc.pause_time) {
+		hw_dbg(hw, "Flow control structure initialized incorrectly\n");
+		return IXGBE_ERR_INVALID_LINK_SETTINGS;
+	}
+
+	/*
 	 * We need to set up the Receive Threshold high and low water
 	 * marks as well as (optionally) enabling the transmission of
 	 * XON frames.
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b5a9b9d..cba7a38 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2446,8 +2446,12 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->tx_eitr = 1;
 
 	/* default flow control settings */
-	hw->fc.original_type = ixgbe_fc_full;
-	hw->fc.type = ixgbe_fc_full;
+	hw->fc.original_type = ixgbe_fc_none;
+	hw->fc.type = ixgbe_fc_none;
+	hw->fc.high_water = IXGBE_DEFAULT_FCRTH;
+	hw->fc.low_water = IXGBE_DEFAULT_FCRTL;
+	hw->fc.pause_time = IXGBE_DEFAULT_FCPAUSE;
+	hw->fc.send_xon = true;
 
 	/* select 10G link by default */
 	hw->mac.link_mode_select = IXGBE_AUTOC_LMS_10G_LINK_NO_AN;
@@ -3587,13 +3591,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	INIT_WORK(&adapter->reset_task, ixgbe_reset_task);
 
-	/* initialize default flow control settings */
-	hw->fc.original_type = ixgbe_fc_full;
-	hw->fc.type = ixgbe_fc_full;
-	hw->fc.high_water = IXGBE_DEFAULT_FCRTH;
-	hw->fc.low_water = IXGBE_DEFAULT_FCRTL;
-	hw->fc.pause_time = IXGBE_DEFAULT_FCPAUSE;
-
 	err = ixgbe_init_interrupt_scheme(adapter);
 	if (err)
 		goto err_sw_init;

