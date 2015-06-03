From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/9] e1000e: fix legacy interrupt handling in i219
Date: Wed,  3 Jun 2015 04:27:53 -0700
Message-ID: <1433330876-2658-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:24080 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753607AbbFCL2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 07:28:06 -0400
In-Reply-To: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanir Lubetkin <yanirx.lubetkin@intel.com>

This fix handles a hardware issue that prevented i219 from
working in legacy interrupts mode (IntMode=0)

Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.h |  5 ++++-
 drivers/net/ethernet/intel/e1000e/netdev.c  | 14 ++++++++++++++
 drivers/net/ethernet/intel/e1000e/regs.h    |  1 +
 3 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.h b/drivers/net/ethernet/intel/e1000e/ich8lan.h
index 1500536..193c445 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.h
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.h
@@ -98,8 +98,11 @@
 #define E1000_FEXTNVM6_K1_OFF_ENABLE	0x80000000
 /* bit for disabling packet buffer read */
 #define E1000_FEXTNVM7_DISABLE_PB_READ	0x00040000
-
+#define E1000_FEXTNVM7_SIDE_CLK_UNGATE	0x00000004
 #define E1000_FEXTNVM7_DISABLE_SMB_PERST	0x00000020
+#define E1000_FEXTNVM9_IOSFSB_CLKGATE_DIS	0x00000800
+#define E1000_FEXTNVM9_IOSFSB_CLKREQ_DIS	0x00001000
+#define E1000_FEXTNVM11_DISABLE_PB_READ		0x00000200
 #define E1000_FEXTNVM11_DISABLE_MULR_FIX	0x00002000
 
 /* bit24: RXDCTL thresholds granularity: 0 - cache lines, 1 - descriptors */
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 4f029b6..5f94fdf 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4120,6 +4120,20 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		phy_data &= ~IGP02E1000_PM_SPD;
 		e1e_wphy(hw, IGP02E1000_PHY_POWER_MGMT, phy_data);
 	}
+	if (hw->mac.type == e1000_pch_spt && adapter->int_mode == 0) {
+		u32 reg;
+
+		/* Fextnvm7 @ 0xe4[2] = 1 */
+		reg = er32(FEXTNVM7);
+		reg |= E1000_FEXTNVM7_SIDE_CLK_UNGATE;
+		ew32(FEXTNVM7, reg);
+		/* Fextnvm9 @ 0x5bb4[13:12] = 11 */
+		reg = er32(FEXTNVM9);
+		reg |= E1000_FEXTNVM9_IOSFSB_CLKGATE_DIS |
+		       E1000_FEXTNVM9_IOSFSB_CLKREQ_DIS;
+		ew32(FEXTNVM9, reg);
+	}
+
 }
 
 int e1000e_up(struct e1000_adapter *adapter)
diff --git a/drivers/net/ethernet/intel/e1000e/regs.h b/drivers/net/ethernet/intel/e1000e/regs.h
index 200a312..110e27e 100644
--- a/drivers/net/ethernet/intel/e1000e/regs.h
+++ b/drivers/net/ethernet/intel/e1000e/regs.h
@@ -38,6 +38,7 @@
 #define E1000_FEXTNVM4	0x00024	/* Future Extended NVM 4 - RW */
 #define E1000_FEXTNVM6	0x00010	/* Future Extended NVM 6 - RW */
 #define E1000_FEXTNVM7	0x000E4	/* Future Extended NVM 7 - RW */
+#define E1000_FEXTNVM9	0x5BB4  /* Future Extended NVM 9 - RW */
 #define E1000_FEXTNVM11	0x5BBC  /* Future Extended NVM 11 - RW */
 #define E1000_PCIEANACFG	0x00F18	/* PCIE Analog Config */
 #define E1000_FCT	0x00030	/* Flow Control Type - RW */
-- 
2.1.0
