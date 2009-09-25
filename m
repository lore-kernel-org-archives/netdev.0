From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 11/13] e1000: drop unused functionality for eeprom
	write/read
Date: Fri, 25 Sep 2009 15:20:11 -0700
Message-ID: <20090925222011.26715.87880.stgit@localhost.localdomain>
References: <20090925221613.26715.66796.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:60011
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753072AbZIYWU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 18:20:28 -0400
In-Reply-To: <20090925221613.26715.66796.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

eerd and eewr don't exist on pre PCIe devices

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_hw.c |  121 +-----------------------------------------
 drivers/net/e1000/e1000_hw.h |    2 -
 2 files changed, 3 insertions(+), 120 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 6aba883..50114cd 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -49,11 +49,6 @@ static s32 e1000_id_led_init(struct e1000_hw *hw);
 static void e1000_init_rx_addrs(struct e1000_hw *hw);
 static s32 e1000_phy_igp_get_info(struct e1000_hw *hw,
 				  struct e1000_phy_info *phy_info);
-static s32 e1000_read_eeprom_eerd(struct e1000_hw *hw, u16 offset, u16 words,
-				  u16 *data);
-static s32 e1000_write_eeprom_eewr(struct e1000_hw *hw, u16 offset, u16 words,
-				   u16 *data);
-static s32 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd);
 static s32 e1000_phy_m88_get_info(struct e1000_hw *hw,
 				  struct e1000_phy_info *phy_info);
 static s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active);
@@ -3339,8 +3334,6 @@ s32 e1000_init_eeprom_params(struct e1000_hw *hw)
 		eeprom->opcode_bits = 3;
 		eeprom->address_bits = 6;
 		eeprom->delay_usec = 50;
-		eeprom->use_eerd = false;
-		eeprom->use_eewr = false;
 		break;
 	case e1000_82540:
 	case e1000_82545:
@@ -3357,8 +3350,6 @@ s32 e1000_init_eeprom_params(struct e1000_hw *hw)
 			eeprom->word_size = 64;
 			eeprom->address_bits = 6;
 		}
-		eeprom->use_eerd = false;
-		eeprom->use_eewr = false;
 		break;
 	case e1000_82541:
 	case e1000_82541_rev_2:
@@ -3387,8 +3378,6 @@ s32 e1000_init_eeprom_params(struct e1000_hw *hw)
 				eeprom->address_bits = 6;
 			}
 		}
-		eeprom->use_eerd = false;
-		eeprom->use_eewr = false;
 		break;
 	default:
 		break;
@@ -3773,15 +3762,9 @@ static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
 	 * directly. In this case, we need to acquire the EEPROM so that
 	 * FW or other port software does not interrupt.
 	 */
-	if (!hw->eeprom.use_eerd) {
-		/* Prepare the EEPROM for bit-bang reading */
-		if (e1000_acquire_eeprom(hw) != E1000_SUCCESS)
-			return -E1000_ERR_EEPROM;
-	}
-
-	/* Eerd register EEPROM access requires no eeprom aquire/release */
-	if (eeprom->use_eerd)
-		return e1000_read_eeprom_eerd(hw, offset, words, data);
+	/* Prepare the EEPROM for bit-bang reading */
+	if (e1000_acquire_eeprom(hw) != E1000_SUCCESS)
+		return -E1000_ERR_EEPROM;
 
 	/* Set up the SPI or Microwire EEPROM for bit-bang reading.  We have
 	 * acquired the EEPROM at this point, so any returns should release it */
@@ -3837,101 +3820,6 @@ static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
 }
 
 /**
- * Reads a 16 bit word from the EEPROM using the EERD register.
- *
- * @hw: Struct containing variables accessed by shared code
- * offset - offset of  word in the EEPROM to read
- * data - word read from the EEPROM
- * words - number of words to read
- */
-static s32 e1000_read_eeprom_eerd(struct e1000_hw *hw, u16 offset, u16 words,
-				  u16 *data)
-{
-	u32 i, eerd = 0;
-	s32 error = 0;
-
-	for (i = 0; i < words; i++) {
-		eerd = ((offset + i) << E1000_EEPROM_RW_ADDR_SHIFT) +
-		    E1000_EEPROM_RW_REG_START;
-
-		ew32(EERD, eerd);
-		error = e1000_poll_eerd_eewr_done(hw, E1000_EEPROM_POLL_READ);
-
-		if (error) {
-			break;
-		}
-		data[i] = (er32(EERD) >> E1000_EEPROM_RW_REG_DATA);
-
-	}
-
-	return error;
-}
-
-/**
- * Writes a 16 bit word from the EEPROM using the EEWR register.
- *
- * @hw: Struct containing variables accessed by shared code
- * offset - offset of  word in the EEPROM to read
- * data - word read from the EEPROM
- * words - number of words to read
- */
-static s32 e1000_write_eeprom_eewr(struct e1000_hw *hw, u16 offset, u16 words,
-				   u16 *data)
-{
-	u32 register_value = 0;
-	u32 i = 0;
-	s32 error = 0;
-
-	for (i = 0; i < words; i++) {
-		register_value = (data[i] << E1000_EEPROM_RW_REG_DATA) |
-		    ((offset + i) << E1000_EEPROM_RW_ADDR_SHIFT) |
-		    E1000_EEPROM_RW_REG_START;
-
-		error = e1000_poll_eerd_eewr_done(hw, E1000_EEPROM_POLL_WRITE);
-		if (error) {
-			break;
-		}
-
-		ew32(EEWR, register_value);
-
-		error = e1000_poll_eerd_eewr_done(hw, E1000_EEPROM_POLL_WRITE);
-
-		if (error) {
-			break;
-		}
-	}
-
-	return error;
-}
-
-/**
- * Polls the status bit (bit 1) of the EERD to determine when the read is done.
- *
- * @hw: Struct containing variables accessed by shared code
- */
-static s32 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd)
-{
-	u32 attempts = 100000;
-	u32 i, reg = 0;
-	s32 done = E1000_ERR_EEPROM;
-
-	for (i = 0; i < attempts; i++) {
-		if (eerd == E1000_EEPROM_POLL_READ)
-			reg = er32(EERD);
-		else
-			reg = er32(EEWR);
-
-		if (reg & E1000_EEPROM_RW_REG_DONE) {
-			done = E1000_SUCCESS;
-			break;
-		}
-		udelay(5);
-	}
-
-	return done;
-}
-
-/**
  * e1000_validate_eeprom_checksum - Verifies that the EEPROM has a valid checksum
  * @hw: Struct containing variables accessed by shared code
  *
@@ -4031,9 +3919,6 @@ static s32 e1000_do_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
 		return -E1000_ERR_EEPROM;
 	}
 
-	if (eeprom->use_eewr)
-		return e1000_write_eeprom_eewr(hw, offset, words, data);
-
 	/* Prepare the EEPROM for writing  */
 	if (e1000_acquire_eeprom(hw) != E1000_SUCCESS)
 		return -E1000_ERR_EEPROM;
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 4bfdf32..2e42341 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -256,8 +256,6 @@ struct e1000_eeprom_info {
 	u16 address_bits;
 	u16 delay_usec;
 	u16 page_size;
-	bool use_eerd;
-	bool use_eewr;
 };
 
 /* Flex ASF Information */

