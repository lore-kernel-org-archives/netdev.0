From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/1] e1000: remove dead e1000_init_eeprom_params
 calls.
Date: Fri, 24 Jul 2015 23:40:36 +0200
Message-ID: <20150724214036.GA29524@electric-eye.fr.zoreil.com>
References: <20150714202311.GA5189@192-168-0-3.rdsnet.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joern Engel <joern@logfs.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39746 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083AbbGXVk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 17:40:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device probe method e1000_probe calls e1000_init_eeprom_params
itself so there's no reason to call it again from e1000_do_write_eeprom
or e1000_do_read_eeprom.

The sentence above assumes that e1000_init_eeprom_params is effective
but it's mostly dependant on "hw->mac_type": safe as e1000_probe bails
out early if it can't set mac_type (see e1000_init_hw_struct, then
e1000_set_mac_type).

Btw, if effective, the removed paths would had been deadlock prone when
e1000_eeprom_spi was set:
-> e1000_write_eeprom (takes e1000_eeprom_lock)
   -> e1000_do_write_eeprom
      -> e1000_init_eeprom_params
         -> e1000_read_eeprom (takes e1000_eeprom_lock)

(same narrative with e1000_read_eeprom -> e1000_do_read_eeprom etc.)

As a final note, the candidate deadlock above can't happen in e1000_probe
due to the way eeprom->word_size is set / tested.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---

Untested. I have found it while looking at Joern's patch.

 drivers/net/ethernet/intel/e1000/e1000_hw.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
index 45c8c864..b1af0d6 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.c
@@ -3900,10 +3900,6 @@ static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
 		return E1000_SUCCESS;
 	}
 
-	/* If eeprom is not yet detected, do so now */
-	if (eeprom->word_size == 0)
-		e1000_init_eeprom_params(hw);
-
 	/* A check for invalid values:  offset too large, too many words, and
 	 * not enough words.
 	 */
@@ -4074,10 +4070,6 @@ static s32 e1000_do_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
 		return E1000_SUCCESS;
 	}
 
-	/* If eeprom is not yet detected, do so now */
-	if (eeprom->word_size == 0)
-		e1000_init_eeprom_params(hw);
-
 	/* A check for invalid values:  offset too large, too many words, and
 	 * not enough words.
 	 */
-- 
2.4.3
