From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/5] e1000e: 82577/82578 requires a different method
	to configure LPLU
Date: Mon, 26 Oct 2009 14:23:25 -0700
Message-ID: <20091026212325.9682.22270.stgit@localhost.localdomain>
References: <20091026212242.9682.25442.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:59657
	"EHLO QMTA14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753725AbZJZV07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 17:26:59 -0400
In-Reply-To: <20091026212242.9682.25442.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Unlike previous ICHx-based parts, the PCH-based parts (82577/82578) require
LPLU (Low Power Link Up, or "reverse auto-negotiation") to be configured in
the PHY rather than the MAC.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   40 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index fb2222d..2451dc8 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -124,6 +124,11 @@
 
 #define SW_FLAG_TIMEOUT    1000 /* SW Semaphore flag timeout in milliseconds */
 
+/* OEM Bits Phy Register */
+#define HV_OEM_BITS            PHY_REG(768, 25)
+#define HV_OEM_BITS_LPLU       0x0004 /* Low Power Link Up */
+#define HV_OEM_BITS_RESTART_AN 0x0400 /* Restart Auto-negotiation */
+
 /* ICH GbE Flash Hardware Sequencing Flash Status Register bit breakdown */
 /* Offset 04h HSFSTS */
 union ich8_hws_flash_status {
@@ -202,6 +207,7 @@ static s32 e1000_setup_led_pchlan(struct e1000_hw *hw);
 static s32 e1000_cleanup_led_pchlan(struct e1000_hw *hw);
 static s32 e1000_led_on_pchlan(struct e1000_hw *hw);
 static s32 e1000_led_off_pchlan(struct e1000_hw *hw);
+static s32 e1000_set_lplu_state_pchlan(struct e1000_hw *hw, bool active);
 
 static inline u16 __er16flash(struct e1000_hw *hw, unsigned long reg)
 {
@@ -244,6 +250,8 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 
 	phy->ops.check_polarity       = e1000_check_polarity_ife_ich8lan;
 	phy->ops.read_phy_reg         = e1000_read_phy_reg_hv;
+	phy->ops.set_d0_lplu_state    = e1000_set_lplu_state_pchlan;
+	phy->ops.set_d3_lplu_state    = e1000_set_lplu_state_pchlan;
 	phy->ops.write_phy_reg        = e1000_write_phy_reg_hv;
 	phy->autoneg_mask             = AUTONEG_ADVERTISE_SPEED_DEFAULT;
 
@@ -1060,6 +1068,38 @@ static s32 e1000_check_polarity_ife_ich8lan(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000_set_lplu_state_pchlan - Set Low Power Link Up state
+ *  @hw: pointer to the HW structure
+ *  @active: true to enable LPLU, false to disable
+ *
+ *  Sets the LPLU state according to the active flag.  For PCH, if OEM write
+ *  bit are disabled in the NVM, writing the LPLU bits in the MAC will not set
+ *  the phy speed. This function will manually set the LPLU bit and restart
+ *  auto-neg as hw would do. D3 and D0 LPLU will call the same function
+ *  since it configures the same bit.
+ **/
+static s32 e1000_set_lplu_state_pchlan(struct e1000_hw *hw, bool active)
+{
+	s32 ret_val = 0;
+	u16 oem_reg;
+
+	ret_val = e1e_rphy(hw, HV_OEM_BITS, &oem_reg);
+	if (ret_val)
+		goto out;
+
+	if (active)
+		oem_reg |= HV_OEM_BITS_LPLU;
+	else
+		oem_reg &= ~HV_OEM_BITS_LPLU;
+
+	oem_reg |= HV_OEM_BITS_RESTART_AN;
+	ret_val = e1e_wphy(hw, HV_OEM_BITS, oem_reg);
+
+out:
+	return ret_val;
+}
+
+/**
  *  e1000_set_d0_lplu_state_ich8lan - Set Low Power Linkup D0 state
  *  @hw: pointer to the HW structure
  *  @active: TRUE to enable LPLU, FALSE to disable

