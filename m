From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/6] e1000e: read of PHY register may access wrong
	page on 82578
Date: Thu, 19 Nov 2009 14:34:40 -0800
Message-ID: <20091119223439.29164.40960.stgit@localhost.localdomain>
References: <20091119223406.29164.22513.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:44867 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756296AbZKSWfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 17:35:00 -0500
In-Reply-To: <20091119223406.29164.22513.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Remove unnecessary workaround that mistakenly does not perform a page
select operation for PHY registers 29 and 30 (assuming these are the PHY
debug port address and data registers) on 82578 which can cause reads
of the Transmit with No Carrier Sense statistics register on page 778 to be
read from an incorrect page.  Also error out if the page select operation
fails.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/phy.c |   46 ++++++++++++++++++++++------------------------
 1 files changed, 22 insertions(+), 24 deletions(-)

diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 03175b3..8189d00 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -2658,19 +2658,18 @@ static s32 __e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data,
 		page = 0;
 
 	if (reg > MAX_PHY_MULTI_PAGE_REG) {
-		if ((hw->phy.type != e1000_phy_82578) ||
-		    ((reg != I82578_ADDR_REG) &&
-		     (reg != I82578_ADDR_REG + 1))) {
-			u32 phy_addr = hw->phy.addr;
+		u32 phy_addr = hw->phy.addr;
 
-			hw->phy.addr = 1;
+		hw->phy.addr = 1;
 
-			/* Page is shifted left, PHY expects (page x 32) */
-			ret_val = e1000e_write_phy_reg_mdic(hw,
-			                             IGP01E1000_PHY_PAGE_SELECT,
-			                             (page << IGP_PAGE_SHIFT));
-			hw->phy.addr = phy_addr;
-		}
+		/* Page is shifted left, PHY expects (page x 32) */
+		ret_val = e1000e_write_phy_reg_mdic(hw,
+					     IGP01E1000_PHY_PAGE_SELECT,
+					     (page << IGP_PAGE_SHIFT));
+		hw->phy.addr = phy_addr;
+
+		if (ret_val)
+			goto out;
 	}
 
 	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & reg,
@@ -2678,7 +2677,7 @@ static s32 __e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data,
 out:
 	/* Revert to MDIO fast mode, if applicable */
 	if ((hw->phy.type == e1000_phy_82577) && in_slow_mode)
-		ret_val = e1000_set_mdio_slow_mode_hv(hw, false);
+		ret_val |= e1000_set_mdio_slow_mode_hv(hw, false);
 
 	if (!locked)
 		hw->phy.ops.release_phy(hw);
@@ -2784,19 +2783,18 @@ static s32 __e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data,
 	}
 
 	if (reg > MAX_PHY_MULTI_PAGE_REG) {
-		if ((hw->phy.type != e1000_phy_82578) ||
-		    ((reg != I82578_ADDR_REG) &&
-		     (reg != I82578_ADDR_REG + 1))) {
-			u32 phy_addr = hw->phy.addr;
+		u32 phy_addr = hw->phy.addr;
 
-			hw->phy.addr = 1;
+		hw->phy.addr = 1;
 
-			/* Page is shifted left, PHY expects (page x 32) */
-			ret_val = e1000e_write_phy_reg_mdic(hw,
-			                             IGP01E1000_PHY_PAGE_SELECT,
-			                             (page << IGP_PAGE_SHIFT));
-			hw->phy.addr = phy_addr;
-		}
+		/* Page is shifted left, PHY expects (page x 32) */
+		ret_val = e1000e_write_phy_reg_mdic(hw,
+					     IGP01E1000_PHY_PAGE_SELECT,
+					     (page << IGP_PAGE_SHIFT));
+		hw->phy.addr = phy_addr;
+
+		if (ret_val)
+			goto out;
 	}
 
 	ret_val = e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & reg,
@@ -2805,7 +2803,7 @@ static s32 __e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data,
 out:
 	/* Revert to MDIO fast mode, if applicable */
 	if ((hw->phy.type == e1000_phy_82577) && in_slow_mode)
-		ret_val = e1000_set_mdio_slow_mode_hv(hw, false);
+		ret_val |= e1000_set_mdio_slow_mode_hv(hw, false);
 
 	if (!locked)
 		hw->phy.ops.release_phy(hw);

