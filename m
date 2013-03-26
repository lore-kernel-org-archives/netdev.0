From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/6] igb: fix i350 anti spoofing config
Date: Tue, 26 Mar 2013 03:42:30 -0700
Message-ID: <1364294554-7967-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1364294554-7967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Lior Levy <lior.levy@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39352 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759607Ab3CZKmi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 06:42:38 -0400
In-Reply-To: <1364294554-7967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lior Levy <lior.levy@intel.com>

Fix a problem in i350 where anti spoofing configuration was written into a
wrong register.

Signed-off-by: Lior Levy <lior.levy@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 33 ++++++++++++++++------------
 1 file changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index b64542a..12b1d84 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -1818,27 +1818,32 @@ out:
  **/
 void igb_vmdq_set_anti_spoofing_pf(struct e1000_hw *hw, bool enable, int pf)
 {
-	u32 dtxswc;
+	u32 reg_val, reg_offset;
 
 	switch (hw->mac.type) {
 	case e1000_82576:
+		reg_offset = E1000_DTXSWC;
+		break;
 	case e1000_i350:
-		dtxswc = rd32(E1000_DTXSWC);
-		if (enable) {
-			dtxswc |= (E1000_DTXSWC_MAC_SPOOF_MASK |
-				   E1000_DTXSWC_VLAN_SPOOF_MASK);
-			/* The PF can spoof - it has to in order to
-			 * support emulation mode NICs */
-			dtxswc ^= (1 << pf | 1 << (pf + MAX_NUM_VFS));
-		} else {
-			dtxswc &= ~(E1000_DTXSWC_MAC_SPOOF_MASK |
-				    E1000_DTXSWC_VLAN_SPOOF_MASK);
-		}
-		wr32(E1000_DTXSWC, dtxswc);
+		reg_offset = E1000_TXSWC;
 		break;
 	default:
-		break;
+		return;
+	}
+
+	reg_val = rd32(reg_offset);
+	if (enable) {
+		reg_val |= (E1000_DTXSWC_MAC_SPOOF_MASK |
+			     E1000_DTXSWC_VLAN_SPOOF_MASK);
+		/* The PF can spoof - it has to in order to
+		 * support emulation mode NICs
+		 */
+		reg_val ^= (1 << pf | 1 << (pf + MAX_NUM_VFS));
+	} else {
+		reg_val &= ~(E1000_DTXSWC_MAC_SPOOF_MASK |
+			     E1000_DTXSWC_VLAN_SPOOF_MASK);
 	}
+	wr32(reg_offset, reg_val);
 }
 
 /**
-- 
1.7.11.7
