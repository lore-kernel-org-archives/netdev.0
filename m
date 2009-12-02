From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/9] e1000e: guard against buffer overflow in
	cable length tables
Date: Tue, 01 Dec 2009 17:47:02 -0800
Message-ID: <20091202014701.396.84437.stgit@localhost.localdomain>
References: <20091202014641.396.57708.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:53365
	"EHLO QMTA12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752408AbZLBBrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 20:47:13 -0500
In-Reply-To: <20091202014641.396.57708.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/es2lan.c |   17 +++++++++++++----
 drivers/net/e1000e/phy.c    |   14 +++++++++++---
 2 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 3ff932f..3f435c1 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -99,6 +99,8 @@
  */
 static const u16 e1000_gg82563_cable_length_table[] =
 	 { 0, 60, 115, 150, 150, 60, 115, 150, 180, 180, 0xFF };
+#define GG82563_CABLE_LENGTH_TABLE_SIZE \
+		ARRAY_SIZE(e1000_gg82563_cable_length_table)
 
 static s32 e1000_setup_copper_link_80003es2lan(struct e1000_hw *hw);
 static s32 e1000_acquire_swfw_sync_80003es2lan(struct e1000_hw *hw, u16 mask);
@@ -694,20 +696,27 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 static s32 e1000_get_cable_length_80003es2lan(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
-	s32 ret_val;
+	s32 ret_val = 0;
 	u16 phy_data, index;
 
 	ret_val = e1e_rphy(hw, GG82563_PHY_DSP_DISTANCE, &phy_data);
 	if (ret_val)
-		return ret_val;
+		goto out;
 
 	index = phy_data & GG82563_DSPD_CABLE_LENGTH;
+
+	if (index >= GG82563_CABLE_LENGTH_TABLE_SIZE - 5) {
+		ret_val = -E1000_ERR_PHY;
+		goto out;
+	}
+
 	phy->min_cable_length = e1000_gg82563_cable_length_table[index];
-	phy->max_cable_length = e1000_gg82563_cable_length_table[index+5];
+	phy->max_cable_length = e1000_gg82563_cable_length_table[index + 5];
 
 	phy->cable_length = (phy->min_cable_length + phy->max_cable_length) / 2;
 
-	return 0;
+out:
+	return ret_val;
 }
 
 /**
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 5cd01c6..9ce4997 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -44,6 +44,8 @@ static s32 e1000_access_phy_debug_regs_hv(struct e1000_hw *hw, u32 offset,
 /* Cable length tables */
 static const u16 e1000_m88_cable_length_table[] =
 	{ 0, 50, 80, 110, 140, 140, E1000_CABLE_LENGTH_UNDEFINED };
+#define M88E1000_CABLE_LENGTH_TABLE_SIZE \
+		ARRAY_SIZE(e1000_m88_cable_length_table)
 
 static const u16 e1000_igp_2_cable_length_table[] =
 	{ 0, 0, 0, 0, 0, 0, 0, 0, 3, 5, 8, 11, 13, 16, 18, 21, 0, 0, 0, 3,
@@ -1717,15 +1719,21 @@ s32 e1000e_get_cable_length_m88(struct e1000_hw *hw)
 
 	ret_val = e1e_rphy(hw, M88E1000_PHY_SPEC_STATUS, &phy_data);
 	if (ret_val)
-		return ret_val;
+		goto out;
 
 	index = (phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
-		M88E1000_PSSR_CABLE_LENGTH_SHIFT;
+	        M88E1000_PSSR_CABLE_LENGTH_SHIFT;
+	if (index >= M88E1000_CABLE_LENGTH_TABLE_SIZE - 1) {
+		ret_val = -E1000_ERR_PHY;
+		goto out;
+	}
+
 	phy->min_cable_length = e1000_m88_cable_length_table[index];
-	phy->max_cable_length = e1000_m88_cable_length_table[index+1];
+	phy->max_cable_length = e1000_m88_cable_length_table[index + 1];
 
 	phy->cable_length = (phy->min_cable_length + phy->max_cable_length) / 2;
 
+out:
 	return ret_val;
 }
 

