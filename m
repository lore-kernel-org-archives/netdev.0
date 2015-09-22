From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/17] e1000: remove dead e1000_init_eeprom_params calls
Date: Tue, 22 Sep 2015 16:54:27 -0700
Message-ID: <1442966076-14359-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62670 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934146AbbIVXyj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 19:54:39 -0400
In-Reply-To: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

The device probe method e1000_probe calls e1000_init_eeprom_params
itself so there's no reason to call it again from e1000_do_write_eeprom
or e1000_do_read_eeprom.

The sentence above assumes that e1000_init_eeprom_params is effective.
e1000_init_eeprom_params depends mostly on hw->mac_type and e1000_probe
bails out early if it can't set mac_type (see e1000_init_hw_struct, then
e1000_set_mac_type), qed.

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
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
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
