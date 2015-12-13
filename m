From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/17] e1000: make eeprom read/write scheduler friendly
Date: Sun, 13 Dec 2015 00:31:14 -0800
Message-ID: <1449995490-17020-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joern Engel <joern@logfs.org>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Spencer Baugh <sbaugh@catern.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:35752 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751421AbbLMIlB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 03:41:01 -0500
In-Reply-To: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joern Engel <joern@logfs.org>

Code was responsible for ~150ms scheduler latencies.

Signed-off-by: Joern Engel <joern@logfs.org>
Signed-off-by: Spencer Baugh <sbaugh@catern.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_hw.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
index b1af0d6..2523e30 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.c
@@ -106,7 +106,7 @@ u16 e1000_igp_cable_length_table[IGP01E1000_AGC_LENGTH_TABLE_SIZE] = {
 	    120, 120
 };
 
-static DEFINE_SPINLOCK(e1000_eeprom_lock);
+static DEFINE_MUTEX(e1000_eeprom_lock);
 static DEFINE_SPINLOCK(e1000_phy_lock);
 
 /**
@@ -3882,9 +3882,9 @@ static s32 e1000_spi_eeprom_ready(struct e1000_hw *hw)
 s32 e1000_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
 	s32 ret;
-	spin_lock(&e1000_eeprom_lock);
+	mutex_lock(&e1000_eeprom_lock);
 	ret = e1000_do_read_eeprom(hw, offset, words, data);
-	spin_unlock(&e1000_eeprom_lock);
+	mutex_unlock(&e1000_eeprom_lock);
 	return ret;
 }
 
@@ -3968,6 +3968,7 @@ static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
 			 */
 			data[i] = e1000_shift_in_ee_bits(hw, 16);
 			e1000_standby_eeprom(hw);
+			cond_resched();
 		}
 	}
 
@@ -4052,9 +4053,9 @@ s32 e1000_update_eeprom_checksum(struct e1000_hw *hw)
 s32 e1000_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
 	s32 ret;
-	spin_lock(&e1000_eeprom_lock);
+	mutex_lock(&e1000_eeprom_lock);
 	ret = e1000_do_write_eeprom(hw, offset, words, data);
-	spin_unlock(&e1000_eeprom_lock);
+	mutex_unlock(&e1000_eeprom_lock);
 	return ret;
 }
 
@@ -4116,6 +4117,7 @@ static s32 e1000_write_eeprom_spi(struct e1000_hw *hw, u16 offset, u16 words,
 			return -E1000_ERR_EEPROM;
 
 		e1000_standby_eeprom(hw);
+		cond_resched();
 
 		/*  Send the WRITE ENABLE command (8 bit opcode )  */
 		e1000_shift_out_ee_bits(hw, EEPROM_WREN_OPCODE_SPI,
@@ -4224,6 +4226,7 @@ static s32 e1000_write_eeprom_microwire(struct e1000_hw *hw, u16 offset,
 
 		/* Recover from write */
 		e1000_standby_eeprom(hw);
+		cond_resched();
 
 		words_written++;
 	}
-- 
2.5.0
