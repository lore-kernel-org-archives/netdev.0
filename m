From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/18] ixgbe: Allow reduced delays during SFP detection
Date: Wed, 23 Sep 2015 23:59:25 -0700
Message-ID: <1443077981-55791-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36281 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932442AbbIXG7s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 02:59:48 -0400
In-Reply-To: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Reduce the number of retries during PHY detection. This reduces
pauses when no SFP is present. Once an SFP is detected, the normal
retry count will be used.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c | 18 ++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h |  2 ++
 2 files changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 88ade17..7a7ee9d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -1731,6 +1731,21 @@ s32 ixgbe_write_i2c_eeprom_generic(struct ixgbe_hw *hw, u8 byte_offset,
 }
 
 /**
+ * ixgbe_is_sfp_probe - Returns true if SFP is being detected
+ * @hw: pointer to hardware structure
+ * @offset: eeprom offset to be read
+ * @addr: I2C address to be read
+ */
+static bool ixgbe_is_sfp_probe(struct ixgbe_hw *hw, u8 offset, u8 addr)
+{
+	if (addr == IXGBE_I2C_EEPROM_DEV_ADDR &&
+	    offset == IXGBE_SFF_IDENTIFIER &&
+	    hw->phy.sfp_type == ixgbe_sfp_type_not_present)
+		return true;
+	return false;
+}
+
+/**
  *  ixgbe_read_i2c_byte_generic_int - Reads 8 bit word over I2C
  *  @hw: pointer to hardware structure
  *  @byte_offset: byte offset to read
@@ -1749,6 +1764,9 @@ static s32 ixgbe_read_i2c_byte_generic_int(struct ixgbe_hw *hw, u8 byte_offset,
 	u32 swfw_mask = hw->phy.phy_semaphore_mask;
 	bool nack = true;
 
+	if (ixgbe_is_sfp_probe(hw, byte_offset, dev_addr))
+		max_retry = IXGBE_SFP_DETECT_RETRIES;
+
 	*data = 0;
 
 	do {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
index 4c06484..0769b40 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
@@ -109,6 +109,8 @@
 #define IXGBE_I2C_T_SU_STO  4
 #define IXGBE_I2C_T_BUF     5
 
+#define IXGBE_SFP_DETECT_RETRIES	2
+
 #define IXGBE_TN_LASI_STATUS_REG        0x9005
 #define IXGBE_TN_LASI_STATUS_TEMP_ALARM 0x0008
 
-- 
2.4.3
