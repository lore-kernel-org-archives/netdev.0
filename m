From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 4/6] e1000e: prevent NVM corruption on sectors larger
	than 4K
Date: Wed, 01 Jul 2009 16:28:32 -0700
Message-ID: <20090701232832.20555.91938.stgit@localhost.localdomain>
References: <20090701232731.20555.63487.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:50198
	"EHLO QMTA15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752983AbZGAX2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 19:28:45 -0400
In-Reply-To: <20090701232731.20555.63487.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Limit NVM writes to 4K sections to prevent NVM corruption on larger
sector allocations (up to 64K).

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index bf9b97d..0e0755f 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -338,6 +338,7 @@ static s32 e1000_init_nvm_params_ich8lan(struct e1000_hw *hw)
 {
 	struct e1000_nvm_info *nvm = &hw->nvm;
 	struct e1000_dev_spec_ich8lan *dev_spec = &hw->dev_spec.ich8lan;
+	union ich8_hws_flash_status hsfsts;
 	u32 gfpreg;
 	u32 sector_base_addr;
 	u32 sector_end_addr;
@@ -374,6 +375,20 @@ static s32 e1000_init_nvm_params_ich8lan(struct e1000_hw *hw)
 	/* Adjust to word count */
 	nvm->flash_bank_size /= sizeof(u16);
 
+	/*
+	 * Make sure the flash bank size does not overwrite the 4k
+	 * sector ranges. We may have 64k allotted to us but we only care
+	 * about the first 2 4k sectors. Therefore, if we have anything less
+	 * than 64k set in the HSFSTS register, we will reduce the bank size
+	 * down to 4k and let the rest remain unused. If berasesz == 3, then
+	 * we are working in 64k mode. Otherwise we are not.
+	 */
+	if (nvm->flash_bank_size > E1000_ICH8_SHADOW_RAM_WORDS) {
+		hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
+		if (hsfsts.hsf_status.berasesz != 3)
+			nvm->flash_bank_size = E1000_ICH8_SHADOW_RAM_WORDS;
+	}
+
 	nvm->word_size = E1000_ICH8_SHADOW_RAM_WORDS;
 
 	/* Clear shadow ram */
@@ -1932,7 +1947,7 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 		break;
 	case 1:
 		sector_size = ICH_FLASH_SEG_SIZE_4K;
-		iteration = flash_bank_size / ICH_FLASH_SEG_SIZE_4K;
+		iteration = 1;
 		break;
 	case 2:
 		if (hw->mac.type == e1000_ich9lan) {
@@ -1944,7 +1959,7 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 		break;
 	case 3:
 		sector_size = ICH_FLASH_SEG_SIZE_64K;
-		iteration = flash_bank_size / ICH_FLASH_SEG_SIZE_64K;
+		iteration = 1;
 		break;
 	default:
 		return -E1000_ERR_NVM;

