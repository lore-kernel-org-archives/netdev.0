From: Xander Huff <xander.huff@ni.com>
Subject: [PATCH RESEND] igb: Reset TXPBSIZE to default value
Date: Fri, 16 Jan 2015 12:59:39 -0600
Message-ID: <1421434779-20586-1-git-send-email-xander.huff@ni.com>
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeff.westfahl@ni.com, Xander Huff <xander.huff@ni.com>
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod3.natinst.com ([130.164.80.24]:55266 "EHLO ni.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752601AbbAPTBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2015 14:01:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Westfahl <jeff.westfahl@ni.com>

The TXPBSIZE register of the i210 resets to its default value only
at power-on. It doesn't reset if you reboot the system, only if you
pull power. If something (another driver, another OS, etc.) modifies
this register from its default value, the igb driver doesn't function
correctly. It detects a hang of the transmitter and continuously resets
the adapter. Here we set this value to its default when resetting the
i210 to resolve this issue.

Signed-off-by: Jeff Westfahl <jeff.westfahl@ni.com>
Signed-off-by: Xander Huff <xander.huff@ni.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c   | 4 ++++
 drivers/net/ethernet/intel/igb/e1000_defines.h | 3 +++
 drivers/net/ethernet/intel/igb/e1000_regs.h    | 1 +
 3 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 0f69ef8..855a39e 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -2238,6 +2238,10 @@ static s32 igb_reset_hw_82580(struct e1000_hw *hw)
 	wr32(E1000_TCTL, E1000_TCTL_PSP);
 	wrfl();
 
+	if (hw->mac.type == e1000_i210)
+		/* TXPBSIZE resets only on power-up. */
+		wr32(E1000_TXPBSIZE, E1000_TXPBSIZE_RESET);
+
 	usleep_range(10000, 11000);
 
 	/* Determine whether or not a global dev reset is requested */
diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index 217f813..d8e3c59 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -305,6 +305,9 @@
 #define E1000_TCTL_COLD   0x003ff000    /* collision distance */
 #define E1000_TCTL_RTLC   0x01000000    /* Re-transmit on late collision */
 
+/* Transmit Packet Buffer Size */
+#define E1000_TXPBSIZE_RESET 0x04000014
+
 /* DMA Coalescing register fields */
 #define E1000_DMACR_DMACWT_MASK         0x00003FFF /* DMA Coal Watchdog Timer */
 #define E1000_DMACR_DMACTHR_MASK        0x00FF0000 /* DMA Coal Rx Threshold */
diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index 6f0490d..7e2325b 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -60,6 +60,7 @@
 #define E1000_TCTL     0x00400  /* TX Control - RW */
 #define E1000_TCTL_EXT 0x00404  /* Extended TX Control - RW */
 #define E1000_TIPG     0x00410  /* TX Inter-packet gap -RW */
+#define E1000_TXPBSIZE 0x03404  /* Transmit Packet Buffer Size - RW */
 #define E1000_AIT      0x00458  /* Adaptive Interframe Spacing Throttle - RW */
 #define E1000_LEDCTL   0x00E00  /* LED Control - RW */
 #define E1000_LEDMUX   0x08130  /* LED MUX Control */
-- 
1.9.1
