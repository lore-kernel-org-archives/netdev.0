From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 4/8] e1000e: fix check for manageability on
	ICHx/PCH
Date: Wed, 16 Jun 2010 16:27:05 -0700
Message-ID: <20100616232703.4834.61224.stgit@localhost.localdomain>
References: <20100616232523.4834.84849.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:47049 "EHLO
	qmta07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755488Ab0FPX1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 19:27:25 -0400
In-Reply-To: <20100616232523.4834.84849.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Do not check for all the bits in E1000_FWSM_MODE_MASK when checking for
manageability on 82577/82578; only check if iAMT is enabled.  Both of the
manageability checks (for 82577/82578 and ICHx) must check the firmware
valid bit too since the other bits are only valid when the latter is set.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   31 +++++++++++++++++++++++++++----
 1 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 70cd681..7e2f98c 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -226,6 +226,8 @@ static void e1000_power_down_phy_copper_ich8lan(struct e1000_hw *hw);
 static void e1000_lan_init_done_ich8lan(struct e1000_hw *hw);
 static s32  e1000_k1_gig_workaround_hv(struct e1000_hw *hw, bool link);
 static s32 e1000_set_mdio_slow_mode_hv(struct e1000_hw *hw);
+static bool e1000_check_mng_mode_ich8lan(struct e1000_hw *hw);
+static bool e1000_check_mng_mode_pchlan(struct e1000_hw *hw);
 
 static inline u16 __er16flash(struct e1000_hw *hw, unsigned long reg)
 {
@@ -515,6 +517,8 @@ static s32 e1000_init_mac_params_ich8lan(struct e1000_adapter *adapter)
 	case e1000_ich8lan:
 	case e1000_ich9lan:
 	case e1000_ich10lan:
+		/* check management mode */
+		mac->ops.check_mng_mode = e1000_check_mng_mode_ich8lan;
 		/* ID LED init */
 		mac->ops.id_led_init = e1000e_id_led_init;
 		/* setup LED */
@@ -526,6 +530,8 @@ static s32 e1000_init_mac_params_ich8lan(struct e1000_adapter *adapter)
 		mac->ops.led_off = e1000_led_off_ich8lan;
 		break;
 	case e1000_pchlan:
+		/* check management mode */
+		mac->ops.check_mng_mode = e1000_check_mng_mode_pchlan;
 		/* ID LED init */
 		mac->ops.id_led_init = e1000_id_led_init_pchlan;
 		/* setup LED */
@@ -774,7 +780,7 @@ static void e1000_release_swflag_ich8lan(struct e1000_hw *hw)
  *  e1000_check_mng_mode_ich8lan - Checks management mode
  *  @hw: pointer to the HW structure
  *
- *  This checks if the adapter has manageability enabled.
+ *  This checks if the adapter has any manageability enabled.
  *  This is a function pointer entry point only called by read/write
  *  routines for the PHY and NVM parts.
  **/
@@ -783,9 +789,26 @@ static bool e1000_check_mng_mode_ich8lan(struct e1000_hw *hw)
 	u32 fwsm;
 
 	fwsm = er32(FWSM);
+	return (fwsm & E1000_ICH_FWSM_FW_VALID) &&
+	       ((fwsm & E1000_FWSM_MODE_MASK) ==
+		(E1000_ICH_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT));
+}
 
-	return (fwsm & E1000_FWSM_MODE_MASK) ==
-		(E1000_ICH_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT);
+/**
+ *  e1000_check_mng_mode_pchlan - Checks management mode
+ *  @hw: pointer to the HW structure
+ *
+ *  This checks if the adapter has iAMT enabled.
+ *  This is a function pointer entry point only called by read/write
+ *  routines for the PHY and NVM parts.
+ **/
+static bool e1000_check_mng_mode_pchlan(struct e1000_hw *hw)
+{
+	u32 fwsm;
+
+	fwsm = er32(FWSM);
+	return (fwsm & E1000_ICH_FWSM_FW_VALID) &&
+	       (fwsm & (E1000_ICH_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT));
 }
 
 /**
@@ -3396,7 +3419,7 @@ static void e1000_clear_hw_cntrs_ich8lan(struct e1000_hw *hw)
 
 static struct e1000_mac_operations ich8_mac_ops = {
 	.id_led_init		= e1000e_id_led_init,
-	.check_mng_mode		= e1000_check_mng_mode_ich8lan,
+	/* check_mng_mode dependent on mac type */
 	.check_for_link		= e1000_check_for_copper_link_ich8lan,
 	/* cleanup_led dependent on mac type */
 	.clear_hw_cntrs		= e1000_clear_hw_cntrs_ich8lan,

