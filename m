From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 7/9] e1000e: add debug messages
Date: Tue, 01 Dec 2009 17:53:07 -0800
Message-ID: <20091202015250.592.56893.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:32983
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753168AbZLBBxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 20:53:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Add some helpful debug messages.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |    4 +++-
 drivers/net/e1000e/phy.c     |   26 ++++++++++++++++++++------
 2 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 1ce2bf9..6efb77f 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -314,8 +314,10 @@ static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 		phy->ops.write_reg = e1000e_write_phy_reg_bm;
 		phy->ops.read_reg  = e1000e_read_phy_reg_bm;
 		ret_val = e1000e_determine_phy_address(hw);
-		if (ret_val)
+		if (ret_val) {
+			e_dbg("Cannot determine PHY addr. Erroring out\n");
 			return ret_val;
+		}
 	}
 
 	phy->id = 0;
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 1bc09b2..3e5940a 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -2472,7 +2472,7 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 	/* Gig must be disabled for MDIO accesses to page 800 */
 	if ((hw->mac.type == e1000_pchlan) &&
 	   (!(er32(PHY_CTRL) & E1000_PHY_CTRL_GBE_DISABLE)))
-		e_dbg("Attempting to access page 800 while gig enabled\n");
+		e_dbg("Attempting to access page 800 while gig enabled.\n");
 
 	/* All operations in this function are phy address 1 */
 	hw->phy.addr = 1;
@@ -2482,20 +2482,26 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 	                          (BM_WUC_ENABLE_PAGE << IGP_PAGE_SHIFT));
 
 	ret_val = e1000e_read_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, &phy_reg);
-	if (ret_val)
+	if (ret_val) {
+		e_dbg("Could not read PHY page 769\n");
 		goto out;
+	}
 
 	/* First clear bit 4 to avoid a power state change */
 	phy_reg &= ~(BM_WUC_HOST_WU_BIT);
 	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, phy_reg);
-	if (ret_val)
+	if (ret_val) {
+		e_dbg("Could not clear PHY page 769 bit 4\n");
 		goto out;
+	}
 
 	/* Write bit 2 = 1, and clear bit 4 to 769_17 */
 	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ENABLE_REG,
 	                                    phy_reg | BM_WUC_ENABLE_BIT);
-	if (ret_val)
+	if (ret_val) {
+		e_dbg("Could not write PHY page 769 bit 2\n");
 		goto out;
+	}
 
 	/* Select page 800 */
 	ret_val = e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT,
@@ -2503,8 +2509,10 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 
 	/* Write the page 800 offset value using opcode 0x11 */
 	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ADDRESS_OPCODE, reg);
-	if (ret_val)
+	if (ret_val) {
+		e_dbg("Could not write address opcode to page 800\n");
 		goto out;
+	}
 
 	if (read) {
 	        /* Read the page 800 value using opcode 0x12 */
@@ -2516,8 +2524,10 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 						    *data);
 	}
 
-	if (ret_val)
+	if (ret_val) {
+		e_dbg("Could not access data value from page 800\n");
 		goto out;
+	}
 
 	/*
 	 * Restore 769_17.2 to its original value
@@ -2528,6 +2538,10 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 
 	/* Clear 769_17.2 */
 	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, phy_reg);
+	if (ret_val) {
+		e_dbg("Could not clear PHY page 769 bit 2\n");
+		goto out;
+	}
 
 out:
 	return ret_val;

