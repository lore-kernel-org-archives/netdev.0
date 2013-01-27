From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] e1000e: fix ethtool offline register test for I217
Date: Sun, 27 Jan 2013 02:39:40 -0800
Message-ID: <1359283193-2043-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26342 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756433Ab3A0Kj4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2013 05:39:56 -0500
In-Reply-To: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The SHRAH[9] register on I217 has a different R/W bit-mask than RAR and
SHRAL/H registers.  Set R/W bit-mask appropriately for SHRAH[9] when
testing the R/W ability of the register.  Also, fix the error message log
format so that it does not provide misleading information (i.e. the logged
register address could be incorrect).

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c | 25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index f268cbc..ceff1bf 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -760,8 +760,9 @@ static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data,
 				      (test[pat] & write));
 		val = E1000_READ_REG_ARRAY(&adapter->hw, reg, offset);
 		if (val != (test[pat] & write & mask)) {
-			e_err("pattern test reg %04X failed: got 0x%08X expected 0x%08X\n",
-			      reg + offset, val, (test[pat] & write & mask));
+			e_err("pattern test failed (reg 0x%05X): got 0x%08X expected 0x%08X\n",
+			      reg + (offset << 2), val,
+			      (test[pat] & write & mask));
 			*data = reg;
 			return 1;
 		}
@@ -776,7 +777,7 @@ static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data,
 	__ew32(&adapter->hw, reg, write & mask);
 	val = __er32(&adapter->hw, reg);
 	if ((write & mask) != (val & mask)) {
-		e_err("set/check reg %04X test failed: got 0x%08X expected 0x%08X\n",
+		e_err("set/check test failed (reg 0x%05X): got 0x%08X expected 0x%08X\n",
 		      reg, (val & mask), (write & mask));
 		*data = reg;
 		return 1;
@@ -884,12 +885,20 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 		    E1000_FWSM_WLOCK_MAC_SHIFT;
 
 	for (i = 0; i < mac->rar_entry_count; i++) {
-		/* Cannot test write-protected SHRAL[n] registers */
-		if ((wlock_mac == 1) || (wlock_mac && (i > wlock_mac)))
-			continue;
+		if (mac->type == e1000_pch_lpt) {
+			/* Cannot test write-protected SHRAL[n] registers */
+			if ((wlock_mac == 1) || (wlock_mac && (i > wlock_mac)))
+				continue;
+
+			/* SHRAH[9] different than the others */
+			if (i == 10)
+				mask |= (1 << 30);
+			else
+				mask &= ~(1 << 30);
+		}
 
-		REG_PATTERN_TEST_ARRAY(E1000_RA, ((i << 1) + 1),
-				       mask, 0xFFFFFFFF);
+		REG_PATTERN_TEST_ARRAY(E1000_RA, ((i << 1) + 1), mask,
+				       0xFFFFFFFF);
 	}
 
 	for (i = 0; i < mac->mta_reg_count; i++)
-- 
1.7.11.7
