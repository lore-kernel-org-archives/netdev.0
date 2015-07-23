From: Spencer Baugh <sbaugh@catern.com>
Subject: [PATCH] e1000: make eeprom read/write scheduler friendly
Date: Thu, 23 Jul 2015 14:54:34 -0700
Message-ID: <1437688476-3399-4-git-send-email-sbaugh@catern.com>
Cc: Joern Engel <joern@purestorage.com>,
	Spencer Baugh <Spencer.baugh@purestorage.com>,
	Joern Engel <joern@logfs.org>,
	Spencer Baugh <sbaugh@catern.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org (open list:INTEL ETHERNET DRIVERS),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joern Engel <joern@logfs.org>

Code was responsible for ~150ms scheduler latencies.

Signed-off-by: Joern Engel <joern@logfs.org>
Signed-off-by: Spencer Baugh <sbaugh@catern.com>
---
 drivers/net/ethernet/intel/e1000/e1000_hw.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
index 45c8c864..e74e9dd 100644
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
 
@@ -3972,6 +3972,7 @@ static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
 			 */
 			data[i] = e1000_shift_in_ee_bits(hw, 16);
 			e1000_standby_eeprom(hw);
+			cond_resched();
 		}
 	}
 
@@ -4056,9 +4057,9 @@ s32 e1000_update_eeprom_checksum(struct e1000_hw *hw)
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
 
@@ -4124,6 +4125,7 @@ static s32 e1000_write_eeprom_spi(struct e1000_hw *hw, u16 offset, u16 words,
 			return -E1000_ERR_EEPROM;
 
 		e1000_standby_eeprom(hw);
+		cond_resched();
 
 		/*  Send the WRITE ENABLE command (8 bit opcode )  */
 		e1000_shift_out_ee_bits(hw, EEPROM_WREN_OPCODE_SPI,
@@ -4232,6 +4234,7 @@ static s32 e1000_write_eeprom_microwire(struct e1000_hw *hw, u16 offset,
 
 		/* Recover from write */
 		e1000_standby_eeprom(hw);
+		cond_resched();
 
 		words_written++;
 	}
-- 
2.5.0.rc3
