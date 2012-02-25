From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/11] e1000e: rename e1000e_reload_nvm() and call as function pointer
Date: Fri, 24 Feb 2012 21:50:00 -0800
Message-ID: <1330149000-25907-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330149000-25907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17253 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753444Ab2BYFuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Feb 2012 00:50:06 -0500
In-Reply-To: <1330149000-25907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Rename e1000e_reload_nvm() to e1000e_reload_nvm_generic() to signify the
function is used for more than one MAC-family type, and set and use it as a
MAC ops function pointer to be consistent with the driver design.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |    1 +
 drivers/net/ethernet/intel/e1000e/82571.c       |    1 +
 drivers/net/ethernet/intel/e1000e/e1000.h       |    2 +-
 drivers/net/ethernet/intel/e1000e/hw.h          |    1 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |    3 ++-
 drivers/net/ethernet/intel/e1000e/nvm.c         |    4 ++--
 6 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
index 6e58e94..bac9dda 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -1457,6 +1457,7 @@ static const struct e1000_nvm_operations es2_nvm_ops = {
 	.acquire		= e1000_acquire_nvm_80003es2lan,
 	.read			= e1000e_read_nvm_eerd,
 	.release		= e1000_release_nvm_80003es2lan,
+	.reload			= e1000e_reload_nvm_generic,
 	.update			= e1000e_update_nvm_checksum_generic,
 	.valid_led_default	= e1000e_valid_led_default,
 	.validate		= e1000e_validate_nvm_checksum_generic,
diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 7f44ab76..086dad7 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -1989,6 +1989,7 @@ static const struct e1000_nvm_operations e82571_nvm_ops = {
 	.acquire		= e1000_acquire_nvm_82571,
 	.read			= e1000e_read_nvm_eerd,
 	.release		= e1000_release_nvm_82571,
+	.reload			= e1000e_reload_nvm_generic,
 	.update			= e1000_update_nvm_checksum_82571,
 	.valid_led_default	= e1000_valid_led_default_82571,
 	.validate		= e1000_validate_nvm_checksum_82571,
diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 9f3a268..86cdd47 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -684,7 +684,7 @@ extern s32 e1000e_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg);
 extern s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 extern s32 e1000e_validate_nvm_checksum_generic(struct e1000_hw *hw);
 extern void e1000e_release_nvm(struct e1000_hw *hw);
-extern void e1000e_reload_nvm(struct e1000_hw *hw);
+extern void e1000e_reload_nvm_generic(struct e1000_hw *hw);
 extern s32 e1000_read_mac_addr_generic(struct e1000_hw *hw);
 
 static inline s32 e1000e_read_mac_addr(struct e1000_hw *hw)
diff --git a/drivers/net/ethernet/intel/e1000e/hw.h b/drivers/net/ethernet/intel/e1000e/hw.h
index 50e114b..f82ecf5 100644
--- a/drivers/net/ethernet/intel/e1000e/hw.h
+++ b/drivers/net/ethernet/intel/e1000e/hw.h
@@ -830,6 +830,7 @@ struct e1000_nvm_operations {
 	s32  (*acquire)(struct e1000_hw *);
 	s32  (*read)(struct e1000_hw *, u16, u16, u16 *);
 	void (*release)(struct e1000_hw *);
+	void (*reload)(struct e1000_hw *);
 	s32  (*update)(struct e1000_hw *);
 	s32  (*valid_led_default)(struct e1000_hw *, u16 *);
 	s32  (*validate)(struct e1000_hw *);
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index df91c42..8e9af62 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -2609,7 +2609,7 @@ release:
 	 * until after the next adapter reset.
 	 */
 	if (!ret_val) {
-		e1000e_reload_nvm(hw);
+		nvm->ops.reload(hw);
 		usleep_range(10000, 20000);
 	}
 
@@ -4043,6 +4043,7 @@ static const struct e1000_nvm_operations ich8_nvm_ops = {
 	.acquire		= e1000_acquire_nvm_ich8lan,
 	.read		 	= e1000_read_nvm_ich8lan,
 	.release		= e1000_release_nvm_ich8lan,
+	.reload			= e1000e_reload_nvm_generic,
 	.update			= e1000_update_nvm_checksum_ich8lan,
 	.valid_led_default	= e1000_valid_led_default_ich8lan,
 	.validate		= e1000_validate_nvm_checksum_ich8lan,
diff --git a/drivers/net/ethernet/intel/e1000e/nvm.c b/drivers/net/ethernet/intel/e1000e/nvm.c
index 24b7930..a969f1a 100644
--- a/drivers/net/ethernet/intel/e1000e/nvm.c
+++ b/drivers/net/ethernet/intel/e1000e/nvm.c
@@ -625,13 +625,13 @@ s32 e1000e_update_nvm_checksum_generic(struct e1000_hw *hw)
 }
 
 /**
- *  e1000e_reload_nvm - Reloads EEPROM
+ *  e1000e_reload_nvm_generic - Reloads EEPROM
  *  @hw: pointer to the HW structure
  *
  *  Reloads the EEPROM by setting the "Reinitialize from EEPROM" bit in the
  *  extended control register.
  **/
-void e1000e_reload_nvm(struct e1000_hw *hw)
+void e1000e_reload_nvm_generic(struct e1000_hw *hw)
 {
 	u32 ctrl_ext;
 
-- 
1.7.7.6
