From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] e1000: avoid potential deadlock in e1000_do_[read|write]_eeprom()
Date: Sat, 21 Dec 2013 02:25:20 +0400
Message-ID: <1387578320-26525-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If eeprom->word_size is zero, e1000_do_[read|write]_eeprom() invoke
e1000_init_eeprom_params() to reinit eeprom params.
That is not a good idea since e1000_init_eeprom_params() calls
e1000_read_eeprom() if eeprom->type is e1000_eeprom_spi.
That means a deadlock on e1000_eeprom_lock.

At the same time it is unclear if the reinit is needed at all.
e1000_init_eeprom_params() is called from probe, so
it should succeed before any activities of the module start.

The patch suggests to remove the try to reinit eeprom params.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/ethernet/intel/e1000/e1000_hw.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
index 2879b9631e15..a0317348ebde 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.c
@@ -3982,10 +3982,6 @@ static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
 		return E1000_SUCCESS;
 	}
 
-	/* If eeprom is not yet detected, do so now */
-	if (eeprom->word_size == 0)
-		e1000_init_eeprom_params(hw);
-
 	/* A check for invalid values:  offset too large, too many words, and
 	 * not enough words.
 	 */
@@ -4162,10 +4158,6 @@ static s32 e1000_do_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
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
1.8.3.2
