From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 8/9] tg3: Dynamically allocate VPD data memory
Date: Wed, 15 Sep 2010 12:00:00 -0700
Message-ID: <1284577201-6117-9-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1189 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755097Ab0IOTBB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 15:01:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch eases stack pressure by dynamically allocating the memory
used to temporarily store VPD data.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a4fbe4f..0d0deaa 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12415,14 +12415,18 @@ skip_phy_reset:
 
 static void __devinit tg3_read_vpd(struct tg3 *tp)
 {
-	u8 vpd_data[TG3_NVM_VPD_LEN];
+	u8 *vpd_data;
 	unsigned int block_end, rosize, len;
 	int j, i = 0;
 	u32 magic;
 
 	if ((tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) ||
 	    tg3_nvram_read(tp, 0x0, &magic))
-		goto out_not_found;
+		goto out_no_vpd;
+
+	vpd_data = kmalloc(TG3_NVM_VPD_LEN, GFP_KERNEL);
+	if (!vpd_data)
+		goto out_no_vpd;
 
 	if (magic == TG3_EEPROM_MAGIC) {
 		for (i = 0; i < TG3_NVM_VPD_LEN; i += 4) {
@@ -12506,9 +12510,12 @@ partno:
 
 	memcpy(tp->board_part_number, &vpd_data[i], len);
 
-	return;
-
 out_not_found:
+	kfree(vpd_data);
+	if (!tp->board_part_number[0])
+		return;
+
+out_no_vpd:
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		strcpy(tp->board_part_number, "BCM95906");
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 &&
-- 
1.7.1


