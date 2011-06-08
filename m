From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/12] e1000e: disable far-end loopback mode on ESB2
Date: Wed,  8 Jun 2011 15:56:29 -0700
Message-ID: <1307573800-24868-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307573800-24868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:3609 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754103Ab1FHW4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 18:56:44 -0400
In-Reply-To: <1307573800-24868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The ESB2 LAN includes a debug feature that enables far-end loopback (FELB)
of the SerDes/Kumeran interface.  This feature is activated when receiving
a sequence of symbols that includes a reserved codeword.  On a perfect
link, FELB would never be activated.  In the presence of bit errors, there
is a very small, but non-zero, probability of FELB being activated.

If the FELB is activated, the SerDes link becomes non-functional and must
be reset.  It could also corrupt the switching tables in the switch since
the ESB2 is transmitting packets with a different source MAC address.

This patch disables the FELB feature.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/es2lan.c |    8 ++++++++
 drivers/net/e1000e/hw.h     |    1 +
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index f4bbeb2..c0ecb2d 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -836,6 +836,7 @@ static s32 e1000_init_hw_80003es2lan(struct e1000_hw *hw)
 	struct e1000_mac_info *mac = &hw->mac;
 	u32 reg_data;
 	s32 ret_val;
+	u16 kum_reg_data;
 	u16 i;
 
 	e1000_initialize_hw_bits_80003es2lan(hw);
@@ -861,6 +862,13 @@ static s32 e1000_init_hw_80003es2lan(struct e1000_hw *hw)
 	/* Setup link and flow control */
 	ret_val = e1000e_setup_link(hw);
 
+	/* Disable IBIST slave mode (far-end loopback) */
+	e1000_read_kmrn_reg_80003es2lan(hw, E1000_KMRNCTRLSTA_INBAND_PARAM,
+					&kum_reg_data);
+	kum_reg_data |= E1000_KMRNCTRLSTA_IBIST_DISABLE;
+	e1000_write_kmrn_reg_80003es2lan(hw, E1000_KMRNCTRLSTA_INBAND_PARAM,
+					 kum_reg_data);
+
 	/* Set the transmit descriptor write-back policy */
 	reg_data = er32(TXDCTL(0));
 	reg_data = (reg_data & ~E1000_TXDCTL_WTHRESH) |
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 6c2fa83..dde584f 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -312,6 +312,7 @@ enum e1e_registers {
 #define E1000_KMRNCTRLSTA_DIAG_OFFSET	0x3    /* Kumeran Diagnostic */
 #define E1000_KMRNCTRLSTA_TIMEOUTS	0x4    /* Kumeran Timeouts */
 #define E1000_KMRNCTRLSTA_INBAND_PARAM	0x9    /* Kumeran InBand Parameters */
+#define E1000_KMRNCTRLSTA_IBIST_DISABLE	0x0200 /* Kumeran IBIST Disable */
 #define E1000_KMRNCTRLSTA_DIAG_NELPBK	0x1000 /* Nearend Loopback mode */
 #define E1000_KMRNCTRLSTA_K1_CONFIG	0x7
 #define E1000_KMRNCTRLSTA_K1_ENABLE	0x0002
-- 
1.7.5.2

