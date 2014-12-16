From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH 1/5] e1000e: reset MAC-PHY interconnect on 82577/82578
Date: Tue, 16 Dec 2014 18:28:16 +0800
Message-ID: <1418725700-31465-2-git-send-email-Yanjun.Zhu@windriver.com>
References: <1418725700-31465-1-git-send-email-Yanjun.Zhu@windriver.com>
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, w@1wt.eu, zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:54845 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbaLPK2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 05:28:39 -0500
Received: by mail-pd0-f174.google.com with SMTP id fp1so13660595pdb.33
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 02:28:39 -0800 (PST)
In-Reply-To: <1418725700-31465-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.x kernels require a similar logic change as commit 6dfaa76 
[e1000e: reset MAC-PHY interconnect on 82577/82578] introduces
for newer kernels.

During Sx->S0 transitions, the interconnect between the MAC and PHY on
82577/82578 can remain in SMBus mode instead of transitioning to the
PCIe-like mode required during normal operation.  Toggling the LANPHYPC
Value bit essentially resets the interconnect forcing it to the correct
mode.

after review of all intel drivers, found several instances where
drivers had the incorrect pattern of:
memory mapped write();
delay();

which should always be:
memory mapped write();
write flush(); /* aka memory mapped read */
delay();

explanation:
The reason for including the flush is that writes can be held
(posted) in PCI/PCIe bridges, but the read always has to complete
synchronously and therefore has to flush all pending writes to a
device.  If a write is held and followed by a delay, the delay
means nothing because the write may not have reached hardware
(maybe even not until the next read)

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 drivers/net/e1000e/defines.h |  2 ++
 drivers/net/e1000e/ich8lan.c | 20 ++++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 1190167..52283a6 100644
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
index de39f9a..020657c 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -88,6 +88,8 @@
 
 
 #define E1000_ICH_FWSM_RSPCIPHY	0x00000040 /* Reset PHY on PCI Reset */
+/* FW established a valid mode */ 
+#define E1000_ICH_FWSM_FW_VALID                0x00008000
 
 #define E1000_ICH_MNG_IAMT_MODE		0x2
 
@@ -260,6 +262,7 @@ static inline void __ew32flash(struct e1000_hw *hw, unsigned long reg, u32 val)
 static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
+	u32 ctrl;
 	s32 ret_val = 0;
 
 	phy->addr                     = 1;
@@ -274,6 +277,23 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 	phy->ops.write_phy_reg_locked = e1000_write_phy_reg_hv_locked;
 	phy->autoneg_mask             = AUTONEG_ADVERTISE_SPEED_DEFAULT;
 
+	if (!(er32(FWSM) & E1000_ICH_FWSM_FW_VALID)) {
+		/*
+		 * The MAC-PHY interconnect may still be in SMBus mode
+		 * after Sx->S0.  Toggle the LANPHYPC Value bit to force
+		 * the interconnect to PCIe mode, but only if there is no
+		 * firmware present otherwise firmware will have done it.
+		*/
+		ctrl = er32(CTRL);
+		ctrl |=  E1000_CTRL_LANPHYPC_OVERRIDE;
+		ctrl &= ~E1000_CTRL_LANPHYPC_VALUE;
+		ew32(CTRL, ctrl);
+		e1e_flush();
+		udelay(10);
+		ctrl &= ~E1000_CTRL_LANPHYPC_OVERRIDE;
+		ew32(CTRL, ctrl);
+		msleep(50);
+	}
 	/*
 	 * Reset the PHY before any acccess to it.  Doing so, ensures that
 	 * the PHY is in a known good state before we read/write PHY registers.
-- 
1.9.1
