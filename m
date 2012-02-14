From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 04/10] tg3: Fix NVRAM page writes on newer
 devices
Date: Mon, 13 Feb 2012 17:20:11 -0800
Message-ID: <1329182417-28223-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3515 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751720Ab2BNBVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 20:21:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On newer devices, the hardware expects the NVRAM address register
to be written only once per NVRAM page.  To do otherwise causes NVRAM
corruption.  This patch fixes the problem.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index cb17885..67b6d61 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3140,8 +3140,6 @@ static int tg3_nvram_write_block_buffered(struct tg3 *tp, u32 offset, u32 len,
 
 		phy_addr = tg3_nvram_phys_addr(tp, offset);
 
-		tw32(NVRAM_ADDR, phy_addr);
-
 		nvram_cmd = NVRAM_CMD_GO | NVRAM_CMD_DONE | NVRAM_CMD_WR;
 
 		if (page_off == 0 || i == 0)
@@ -3152,6 +3150,11 @@ static int tg3_nvram_write_block_buffered(struct tg3 *tp, u32 offset, u32 len,
 		if (i == (len - 4))
 			nvram_cmd |= NVRAM_CMD_LAST;
 
+		if ((nvram_cmd & NVRAM_CMD_FIRST) ||
+		    !tg3_flag(tp, FLASH) ||
+		    !tg3_flag(tp, 57765_PLUS))
+			tw32(NVRAM_ADDR, phy_addr);
+
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5752 &&
 		    !tg3_flag(tp, 5755_PLUS) &&
 		    (tp->nvram_jedecnum == JEDEC_ST) &&
-- 
1.7.3.4
