From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 09/11] e1000e: disable jumbo frames on 82579 when MACsec enabled in EEPROM
Date: Fri, 11 Mar 2011 03:06:28 -0800
Message-ID: <1299841590-30676-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59823 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753682Ab1CKLGv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2011 06:06:51 -0500
In-Reply-To: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

If/when an OEM enables MACsec in the 82579 EEPROM, disable jumbo frames
support in the driver due to an interoperability issue in hardware that
prevents jumbo packets from being transmitted or received.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/defines.h |    1 +
 drivers/net/e1000e/ich8lan.c |    8 +++++++-
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 1314998..c516a74 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -86,6 +86,7 @@
 #define E1000_CTRL_EXT_IAME           0x08000000 /* Interrupt acknowledge Auto-mask */
 #define E1000_CTRL_EXT_INT_TIMER_CLR  0x20000000 /* Clear Interrupt timers after IMS clear */
 #define E1000_CTRL_EXT_PBA_CLR        0x80000000 /* PBA Clear */
+#define E1000_CTRL_EXT_LSECCK         0x00001000
 #define E1000_CTRL_EXT_PHYPDEN        0x00100000
 
 /* Receive Descriptor bit definitions */
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 9b434c0..ce1dbfd 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -758,7 +758,13 @@ static s32 e1000_get_variants_ich8lan(struct e1000_adapter *adapter)
 	if (rc)
 		return rc;
 
-	if (adapter->hw.phy.type == e1000_phy_ife) {
+	/*
+	 * Disable Jumbo Frame support on parts with Intel 10/100 PHY or
+	 * on parts with MACsec enabled in NVM (reflected in CTRL_EXT).
+	 */
+	if ((adapter->hw.phy.type == e1000_phy_ife) ||
+	    ((adapter->hw.mac.type >= e1000_pch2lan) &&
+	     (!(er32(CTRL_EXT) & E1000_CTRL_EXT_LSECCK)))) {
 		adapter->flags &= ~FLAG_HAS_JUMBO_FRAMES;
 		adapter->max_hw_frame_size = ETH_FRAME_LEN + ETH_FCS_LEN;
 	}
-- 
1.7.4

