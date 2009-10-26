From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/5] e1000e: clear PHY wakeup bit after LCD reset on
	82577/82578
Date: Mon, 26 Oct 2009 14:22:47 -0700
Message-ID: <20091026212242.9682.25442.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:47419 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752315AbZJZV0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 17:26:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Performing a dummy read of the PHY Wakeup Control (WUC) register clears the
wakeup enable bit set by an PHY reset.  If this bit remains set, link
problems may occur.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index aa0ab0e..ead6651 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -844,7 +844,7 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 	u32 i;
 	u32 data, cnf_size, cnf_base_addr, sw_cfg_mask;
 	s32 ret_val;
-	u16 word_addr, reg_data, reg_addr, phy_page = 0;
+	u16 reg, word_addr, reg_data, reg_addr, phy_page = 0;
 
 	ret_val = e1000e_phy_hw_reset_generic(hw);
 	if (ret_val)
@@ -859,6 +859,10 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 			return ret_val;
 	}
 
+	/* Dummy read to clear the phy wakeup bit after lcd reset */
+	if (hw->mac.type == e1000_pchlan)
+		e1e_rphy(hw, BM_WUC, &reg);
+
 	/*
 	 * Initialize the PHY from the NVM on ICH platforms.  This
 	 * is needed due to an issue where the NVM configuration is
@@ -2229,6 +2233,7 @@ static s32 e1000_get_bus_info_ich8lan(struct e1000_hw *hw)
  **/
 static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 {
+	u16 reg;
 	u32 ctrl, icr, kab;
 	s32 ret_val;
 
@@ -2304,6 +2309,9 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 			hw_dbg(hw, "Auto Read Done did not complete\n");
 		}
 	}
+	/* Dummy read to clear the phy wakeup bit after lcd reset */
+	if (hw->mac.type == e1000_pchlan)
+		e1e_rphy(hw, BM_WUC, &reg);
 
 	/*
 	 * For PCH, this write will make sure that any noise

