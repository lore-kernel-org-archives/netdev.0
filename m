From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 08/14] ixgbe: clear correct counters for flow control on 82599
Date: Mon,  7 Mar 2011 18:25:02 -0800
Message-ID: <1299551108-23663-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37667 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755917Ab1CHC0G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 21:26:06 -0500
In-Reply-To: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

The 82599 was not correctly having some of it's counters cleared for flow
control.  This change corrects that.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_common.c |   34 +++++++++++++++++++++++++++-------
 drivers/net/ixgbe/ixgbe_type.h   |    2 ++
 2 files changed, 29 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 94a5621..85cc301 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -136,17 +136,29 @@ s32 ixgbe_clear_hw_cntrs_generic(struct ixgbe_hw *hw)
 	IXGBE_READ_REG(hw, IXGBE_MRFC);
 	IXGBE_READ_REG(hw, IXGBE_RLEC);
 	IXGBE_READ_REG(hw, IXGBE_LXONTXC);
-	IXGBE_READ_REG(hw, IXGBE_LXONRXC);
 	IXGBE_READ_REG(hw, IXGBE_LXOFFTXC);
-	IXGBE_READ_REG(hw, IXGBE_LXOFFRXC);
+	if (hw->mac.type >= ixgbe_mac_82599EB) {
+		IXGBE_READ_REG(hw, IXGBE_LXONRXCNT);
+		IXGBE_READ_REG(hw, IXGBE_LXOFFRXCNT);
+	} else {
+		IXGBE_READ_REG(hw, IXGBE_LXONRXC);
+		IXGBE_READ_REG(hw, IXGBE_LXOFFRXC);
+	}
 
 	for (i = 0; i < 8; i++) {
 		IXGBE_READ_REG(hw, IXGBE_PXONTXC(i));
-		IXGBE_READ_REG(hw, IXGBE_PXONRXC(i));
 		IXGBE_READ_REG(hw, IXGBE_PXOFFTXC(i));
-		IXGBE_READ_REG(hw, IXGBE_PXOFFRXC(i));
+		if (hw->mac.type >= ixgbe_mac_82599EB) {
+			IXGBE_READ_REG(hw, IXGBE_PXONRXCNT(i));
+			IXGBE_READ_REG(hw, IXGBE_PXOFFRXCNT(i));
+		} else {
+			IXGBE_READ_REG(hw, IXGBE_PXONRXC(i));
+			IXGBE_READ_REG(hw, IXGBE_PXOFFRXC(i));
+		}
 	}
-
+	if (hw->mac.type >= ixgbe_mac_82599EB)
+		for (i = 0; i < 8; i++)
+			IXGBE_READ_REG(hw, IXGBE_PXON2OFFCNT(i));
 	IXGBE_READ_REG(hw, IXGBE_PRC64);
 	IXGBE_READ_REG(hw, IXGBE_PRC127);
 	IXGBE_READ_REG(hw, IXGBE_PRC255);
@@ -184,9 +196,17 @@ s32 ixgbe_clear_hw_cntrs_generic(struct ixgbe_hw *hw)
 	IXGBE_READ_REG(hw, IXGBE_BPTC);
 	for (i = 0; i < 16; i++) {
 		IXGBE_READ_REG(hw, IXGBE_QPRC(i));
-		IXGBE_READ_REG(hw, IXGBE_QBRC(i));
 		IXGBE_READ_REG(hw, IXGBE_QPTC(i));
-		IXGBE_READ_REG(hw, IXGBE_QBTC(i));
+		if (hw->mac.type >= ixgbe_mac_82599EB) {
+			IXGBE_READ_REG(hw, IXGBE_QBRC_L(i));
+			IXGBE_READ_REG(hw, IXGBE_QBRC_H(i));
+			IXGBE_READ_REG(hw, IXGBE_QBTC_L(i));
+			IXGBE_READ_REG(hw, IXGBE_QBTC_H(i));
+			IXGBE_READ_REG(hw, IXGBE_QPRDC(i));
+		} else {
+			IXGBE_READ_REG(hw, IXGBE_QBRC(i));
+			IXGBE_READ_REG(hw, IXGBE_QBTC(i));
+		}
 	}
 
 	return 0;
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 013751d..13a45c7 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -659,6 +659,8 @@
 #define IXGBE_QPTC(_i) (0x06030 + ((_i) * 0x40)) /* 16 of these */
 #define IXGBE_QBRC(_i) (0x01034 + ((_i) * 0x40)) /* 16 of these */
 #define IXGBE_QBTC(_i) (0x06034 + ((_i) * 0x40)) /* 16 of these */
+#define IXGBE_QBRC_L(_i) (0x01034 + ((_i) * 0x40)) /* 16 of these */
+#define IXGBE_QBRC_H(_i) (0x01038 + ((_i) * 0x40)) /* 16 of these */
 #define IXGBE_QPRDC(_i) (0x01430 + ((_i) * 0x40)) /* 16 of these */
 #define IXGBE_QBTC_L(_i) (0x08700 + ((_i) * 0x8)) /* 16 of these */
 #define IXGBE_QBTC_H(_i) (0x08704 + ((_i) * 0x8)) /* 16 of these */
-- 
1.7.4

