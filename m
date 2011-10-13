From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/11] igb: Loopback functionality supports for i350 devices
Date: Thu, 13 Oct 2011 00:15:11 -0700
Message-ID: <1318490112-5092-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318490112-5092-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10144 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753347Ab1JMHPW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Oct 2011 03:15:22 -0400
In-Reply-To: <1318490112-5092-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This patch adds VMDq loopback pf support for i350 devices. The patch
is necessary since the register that enabled loopback was moved and
renamed from DTXSWC to TXSWC.

Signed-off-by: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c |   29 ++++++++++++++++++++-----
 drivers/net/ethernet/intel/igb/e1000_regs.h  |    1 +
 2 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 3771bd2..6580cea 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -1580,14 +1580,31 @@ void igb_vmdq_set_anti_spoofing_pf(struct e1000_hw *hw, bool enable, int pf)
  **/
 void igb_vmdq_set_loopback_pf(struct e1000_hw *hw, bool enable)
 {
-	u32 dtxswc = rd32(E1000_DTXSWC);
+	u32 dtxswc;
+
+	switch (hw->mac.type) {
+	case e1000_82576:
+		dtxswc = rd32(E1000_DTXSWC);
+		if (enable)
+			dtxswc |= E1000_DTXSWC_VMDQ_LOOPBACK_EN;
+		else
+			dtxswc &= ~E1000_DTXSWC_VMDQ_LOOPBACK_EN;
+		wr32(E1000_DTXSWC, dtxswc);
+		break;
+	case e1000_i350:
+		dtxswc = rd32(E1000_TXSWC);
+		if (enable)
+			dtxswc |= E1000_DTXSWC_VMDQ_LOOPBACK_EN;
+		else
+			dtxswc &= ~E1000_DTXSWC_VMDQ_LOOPBACK_EN;
+		wr32(E1000_TXSWC, dtxswc);
+		break;
+	default:
+		/* Currently no other hardware supports loopback */
+		break;
+	}
 
-	if (enable)
-		dtxswc |= E1000_DTXSWC_VMDQ_LOOPBACK_EN;
-	else
-		dtxswc &= ~E1000_DTXSWC_VMDQ_LOOPBACK_EN;
 
-	wr32(E1000_DTXSWC, dtxswc);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index 0990f6d..0a860bc 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -318,6 +318,7 @@
 #define E1000_RPLOLR    0x05AF0 /* Replication Offload - RW */
 #define E1000_UTA       0x0A000 /* Unicast Table Array - RW */
 #define E1000_IOVTCL    0x05BBC /* IOV Control Register */
+#define E1000_TXSWC     0x05ACC /* Tx Switch Control */
 /* These act per VF so an array friendly macro is used */
 #define E1000_P2VMAILBOX(_n)   (0x00C00 + (4 * (_n)))
 #define E1000_VMBMEM(_n)       (0x00800 + (64 * (_n)))
-- 
1.7.6.4
