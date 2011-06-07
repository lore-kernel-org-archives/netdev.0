From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/40] e1000e: log when swflag is cleared unexpectedly on ICH/PCH devices
Date: Tue,  7 Jun 2011 05:32:38 -0700
Message-ID: <1307449995-9458-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:54890 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753221Ab1FGMdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 08:33:20 -0400
In-Reply-To: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Since EXTCNF_CTRL.SWFLAG (used in the ownership arbitration of shared
resources, e.g. the PHY shared between the s/w, f/w, and h/w clients)
can be cleared by any of those clients, log a debug message when
software attempts to clear it and it is already cleared unexpectedly.
And since the swflag is cleared by a hardware reset, the driver does
not need to do that, but the mutex acquired when the bit is set must
still be cleared.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ich8lan.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index dcd5db5..dddd0b3 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -889,8 +889,13 @@ static void e1000_release_swflag_ich8lan(struct e1000_hw *hw)
 	u32 extcnf_ctrl;
 
 	extcnf_ctrl = er32(EXTCNF_CTRL);
-	extcnf_ctrl &= ~E1000_EXTCNF_CTRL_SWFLAG;
-	ew32(EXTCNF_CTRL, extcnf_ctrl);
+
+	if (extcnf_ctrl & E1000_EXTCNF_CTRL_SWFLAG) {
+		extcnf_ctrl &= ~E1000_EXTCNF_CTRL_SWFLAG;
+		ew32(EXTCNF_CTRL, extcnf_ctrl);
+	} else {
+		e_dbg("Semaphore unexpectedly released by sw/fw/hw\n");
+	}
 
 	mutex_unlock(&swflag_mutex);
 }
@@ -3066,7 +3071,7 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	msleep(20);
 
 	if (!ret_val)
-		e1000_release_swflag_ich8lan(hw);
+		mutex_unlock(&swflag_mutex);
 
 	if (ctrl & E1000_CTRL_PHY_RST) {
 		ret_val = hw->phy.ops.get_cfg_done(hw);
-- 
1.7.5.2

