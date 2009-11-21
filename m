From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 08/23] e1000e: disable K1 on PCH LOM when in PHY
	loopback mode
Date: Sat, 21 Nov 2009 01:24:11 -0800
Message-ID: <20091121092410.5715.80171.stgit@localhost.localdomain>
References: <20091121092126.5715.41618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:50194
	"EHLO QMTA12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752516AbZKUJYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:24:22 -0500
In-Reply-To: <20091121092126.5715.41618.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When performing the ethtool PHY loopback test on PCH-based LOMs (82577 and
82578), disable K1 (a MAC-PHY interconnect low power mode) otherwise
packets might get corrupted.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/e1000.h   |    1 +
 drivers/net/e1000e/ethtool.c |    4 ++++
 drivers/net/e1000e/ich8lan.c |    3 +--
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 00989c5..a6c6803 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -485,6 +485,7 @@ extern void e1000e_set_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw,
 extern void e1000e_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw);
 extern void e1000e_gig_downshift_workaround_ich8lan(struct e1000_hw *hw);
 extern void e1000e_disable_gig_wol_ich8lan(struct e1000_hw *hw);
+extern s32 e1000_configure_k1_ich8lan(struct e1000_hw *hw, bool k1_enable);
 
 extern s32 e1000e_check_for_copper_link(struct e1000_hw *hw);
 extern s32 e1000e_check_for_fiber_link(struct e1000_hw *hw);
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 67e06fd..fd79214 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1260,6 +1260,10 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 
 	hw->mac.autoneg = 0;
 
+	/* Workaround: K1 must be disabled for stable 1Gbps operation */
+	if (hw->mac.type == e1000_pchlan)
+		e1000_configure_k1_ich8lan(hw, false);
+
 	if (hw->phy.type == e1000_phy_m88) {
 		/* Auto-MDI/MDIX Off */
 		e1e_wphy(hw, M88E1000_PHY_SPEC_CTRL, 0x0808);
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 51ddb04..bd9002e 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -224,7 +224,6 @@ static s32 e1000_led_off_pchlan(struct e1000_hw *hw);
 static s32 e1000_set_lplu_state_pchlan(struct e1000_hw *hw, bool active);
 static void e1000_lan_init_done_ich8lan(struct e1000_hw *hw);
 static s32  e1000_k1_gig_workaround_hv(struct e1000_hw *hw, bool link);
-static s32 e1000_configure_k1_ich8lan(struct e1000_hw *hw, bool k1_enable);
 
 static inline u16 __er16flash(struct e1000_hw *hw, unsigned long reg)
 {
@@ -1023,7 +1022,7 @@ out:
  *
  *  Success returns 0, Failure returns -E1000_ERR_PHY (-2)
  **/
-static s32 e1000_configure_k1_ich8lan(struct e1000_hw *hw, bool k1_enable)
+s32 e1000_configure_k1_ich8lan(struct e1000_hw *hw, bool k1_enable)
 {
 	s32 ret_val = 0;
 	u32 ctrl_reg = 0;

