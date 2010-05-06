From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/2] e1000e: reset MAC-PHY interconnect on
	82577/82578 during Sx->S0
Date: Thu, 06 May 2010 01:00:06 -0700
Message-ID: <20100506075959.8910.13493.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:50401
	"EHLO qmta13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751165Ab0EFIAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 04:00:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

During Sx->S0 transitions, the interconnect between the MAC and PHY on
82577/82578 can remain in SMBus mode instead of transitioning to the
PCIe-like mode required during normal operation.  Toggling the LANPHYPC
Value bit essentially resets the interconnect forcing it to the correct
mode.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/defines.h |    2 ++
 drivers/net/e1000e/ich8lan.c |   20 ++++++++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index e301e26..7f760aa 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -214,6 +214,8 @@
 #define E1000_CTRL_SPD_1000 0x00000200  /* Force 1Gb */
 #define E1000_CTRL_FRCSPD   0x00000800  /* Force Speed */
 #define E1000_CTRL_FRCDPX   0x00001000  /* Force Duplex */
+#define E1000_CTRL_LANPHYPC_OVERRIDE 0x00010000 /* SW control of LANPHYPC */
+#define E1000_CTRL_LANPHYPC_VALUE    0x00020000 /* SW value of LANPHYPC */
 #define E1000_CTRL_SWDPIN0  0x00040000  /* SWDPIN 0 value */
 #define E1000_CTRL_SWDPIN1  0x00080000  /* SWDPIN 1 value */
 #define E1000_CTRL_SWDPIO0  0x00400000  /* SWDPIN 0 Input or output */
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 5059c22..0bfef8e 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -83,6 +83,8 @@
 
 
 #define E1000_ICH_FWSM_RSPCIPHY	0x00000040 /* Reset PHY on PCI Reset */
+/* FW established a valid mode */
+#define E1000_ICH_FWSM_FW_VALID		0x00008000
 
 #define E1000_ICH_MNG_IAMT_MODE		0x2
 
@@ -259,6 +261,7 @@ static inline void __ew32flash(struct e1000_hw *hw, unsigned long reg, u32 val)
 static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
+	u32 ctrl;
 	s32 ret_val = 0;
 
 	phy->addr                     = 1;
@@ -274,6 +277,23 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 	phy->ops.power_down           = e1000_power_down_phy_copper_ich8lan;
 	phy->autoneg_mask             = AUTONEG_ADVERTISE_SPEED_DEFAULT;
 
+	if (!(er32(FWSM) & E1000_ICH_FWSM_FW_VALID)) {
+		/*
+		 * The MAC-PHY interconnect may still be in SMBus mode
+		 * after Sx->S0.  Toggle the LANPHYPC Value bit to force
+		 * the interconnect to PCIe mode, but only if there is no
+		 * firmware present otherwise firmware will have done it.
+		 */
+		ctrl = er32(CTRL);
+		ctrl |=  E1000_CTRL_LANPHYPC_OVERRIDE;
+		ctrl &= ~E1000_CTRL_LANPHYPC_VALUE;
+		ew32(CTRL, ctrl);
+		udelay(10);
+		ctrl &= ~E1000_CTRL_LANPHYPC_OVERRIDE;
+		ew32(CTRL, ctrl);
+		msleep(50);
+	}
+
 	phy->id = e1000_phy_unknown;
 	ret_val = e1000e_get_phy_id(hw);
 	if (ret_val)

