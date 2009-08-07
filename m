From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] e1000e: fix acquisition of SW/FW/HW semaphore for
	ICHx parts
Date: Fri, 07 Aug 2009 10:41:37 -0700
Message-ID: <20090807174136.31114.96240.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:38099 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754063AbZHGRly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 13:41:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

For ICHx parts, write the EXTCNF_CTRL.SWFLAG bit once when trying to
acquire the SW/FW/HW semaphore instead of multiple times to prevent the
hardware from having problems (especially for systems with manageability
enabled), and extend the timeout for the hardware to set the SWFLAG bit.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   44 ++++++++++++++++++++++++++++++------------
 1 files changed, 31 insertions(+), 13 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index d56c747..dd61e7e 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -594,8 +594,8 @@ static DEFINE_MUTEX(nvm_mutex);
  **/
 static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 {
-	u32 extcnf_ctrl;
-	u32 timeout = PHY_CFG_TIMEOUT;
+	u32 extcnf_ctrl, timeout = PHY_CFG_TIMEOUT;
+	s32 ret_val = 0;
 
 	might_sleep();
 
@@ -603,28 +603,46 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 
 	while (timeout) {
 		extcnf_ctrl = er32(EXTCNF_CTRL);
+		if (!(extcnf_ctrl & E1000_EXTCNF_CTRL_SWFLAG))
+			break;
 
-		if (!(extcnf_ctrl & E1000_EXTCNF_CTRL_SWFLAG)) {
-			extcnf_ctrl |= E1000_EXTCNF_CTRL_SWFLAG;
-			ew32(EXTCNF_CTRL, extcnf_ctrl);
+		mdelay(1);
+		timeout--;
+	}
+
+	if (!timeout) {
+		hw_dbg(hw, "SW/FW/HW has locked the resource for too long.\n");
+		ret_val = -E1000_ERR_CONFIG;
+		goto out;
+	}
+
+	timeout = PHY_CFG_TIMEOUT * 2;
+
+	extcnf_ctrl |= E1000_EXTCNF_CTRL_SWFLAG;
+	ew32(EXTCNF_CTRL, extcnf_ctrl);
+
+	while (timeout) {
+		extcnf_ctrl = er32(EXTCNF_CTRL);
+		if (extcnf_ctrl & E1000_EXTCNF_CTRL_SWFLAG)
+			break;
 
-			extcnf_ctrl = er32(EXTCNF_CTRL);
-			if (extcnf_ctrl & E1000_EXTCNF_CTRL_SWFLAG)
-				break;
-		}
 		mdelay(1);
 		timeout--;
 	}
 
 	if (!timeout) {
-		hw_dbg(hw, "FW or HW has locked the resource for too long.\n");
+		hw_dbg(hw, "Failed to acquire the semaphore.\n");
 		extcnf_ctrl &= ~E1000_EXTCNF_CTRL_SWFLAG;
 		ew32(EXTCNF_CTRL, extcnf_ctrl);
-		mutex_unlock(&nvm_mutex);
-		return -E1000_ERR_CONFIG;
+		ret_val = -E1000_ERR_CONFIG;
+		goto out;
 	}
 
-	return 0;
+out:
+	if (ret_val)
+		mutex_unlock(&nvm_mutex);
+
+	return ret_val;
 }
 
 /**

