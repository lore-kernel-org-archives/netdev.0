From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 04/12] ixgbe: add support for 64k EEPROM for 82599
Date: Wed, 27 Apr 2011 02:34:43 -0700
Message-ID: <1303896891-16006-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14485 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755999Ab1D0Je7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 05:34:59 -0400
In-Reply-To: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

82599 supports up to 32k EEPROM addressing via EERD register. If we
wish to address larger EEPROM this have to be done via serial interface.
This patch adds function ixgbe_read_eeprom_82599 which selects the best
method to read the EEPROM.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82599.c |   31 ++++++++++++++++++++++++++++++-
 1 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index b341ed8..d521baf 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -2064,6 +2064,35 @@ out:
 	return lesm_enabled;
 }
 
+/**
+ *  ixgbe_read_eeprom_82599 - Read EEPROM word using
+ *  fastest available method
+ *
+ *  @hw: pointer to hardware structure
+ *  @offset: offset of  word in the EEPROM to read
+ *  @data: word read from the EEPROM
+ *
+ *  Reads a 16 bit word from the EEPROM
+ **/
+static s32 ixgbe_read_eeprom_82599(struct ixgbe_hw *hw,
+				   u16 offset, u16 *data)
+{
+	struct ixgbe_eeprom_info *eeprom = &hw->eeprom;
+	s32 ret_val = IXGBE_ERR_CONFIG;
+
+	/*
+	 * If EEPROM is detected and can be addressed using 14 bits,
+	 * use EERD otherwise use bit bang
+	 */
+	if ((eeprom->type == ixgbe_eeprom_spi) &&
+	    (offset <= IXGBE_EERD_MAX_ADDR))
+		ret_val = ixgbe_read_eerd_generic(hw, offset, data);
+	else
+		ret_val = ixgbe_read_eeprom_bit_bang_generic(hw, offset, data);
+
+	return ret_val;
+}
+
 static struct ixgbe_mac_operations mac_ops_82599 = {
 	.init_hw                = &ixgbe_init_hw_generic,
 	.reset_hw               = &ixgbe_reset_hw_82599,
@@ -2110,7 +2139,7 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 
 static struct ixgbe_eeprom_operations eeprom_ops_82599 = {
 	.init_params		= &ixgbe_init_eeprom_params_generic,
-	.read			= &ixgbe_read_eerd_generic,
+	.read			= &ixgbe_read_eeprom_82599,
 	.write			= &ixgbe_write_eeprom_generic,
 	.calc_checksum		= &ixgbe_calc_eeprom_checksum_generic,
 	.validate_checksum	= &ixgbe_validate_eeprom_checksum_generic,
-- 
1.7.4.4

