From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/2] ixgb: make sure jumbos stay enabled after reset
Date: Fri, 14 Dec 2007 11:48:29 -0800
Message-ID: <20071214194829.15478.2510.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	jesse.brandeburg@intel.com, matheos.worku@sun.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41062 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765044AbXLNTxV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 14:53:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <matheos.worku@sun.com>

Currently a device reset (ethtool -r ethX) would cause the
adapter to fall back to regular MTU sizes.

Signed-off-by: Matheos Worku <matheos.worku@sun.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 3021234..bf9085f 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -320,10 +320,22 @@ ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog)
 void
 ixgb_reset(struct ixgb_adapter *adapter)
 {
+	struct ixgb_hw *hw = &adapter->hw;
 
-	ixgb_adapter_stop(&adapter->hw);
-	if(!ixgb_init_hw(&adapter->hw))
+	ixgb_adapter_stop(hw);
+	if (!ixgb_init_hw(hw))
 		DPRINTK(PROBE, ERR, "ixgb_init_hw failed.\n");
+
+	/* restore frame size information */
+	IXGB_WRITE_REG(hw, MFS, hw->max_frame_size << IXGB_MFS_SHIFT);
+	if (hw->max_frame_size >
+	    IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH) {
+		u32 ctrl0 = IXGB_READ_REG(hw, CTRL0);
+		if (!(ctrl0 & IXGB_CTRL0_JFE)) {
+			ctrl0 |= IXGB_CTRL0_JFE;
+			IXGB_WRITE_REG(hw, CTRL0, ctrl0);
+		}
+	}
 }
 
 /**

