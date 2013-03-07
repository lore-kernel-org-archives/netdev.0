From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 1/6] tg3: Add new FW_TSO flag
Date: Wed, 6 Mar 2013 19:02:29 -0800
Message-ID: <1362625354-15095-2-git-send-email-nsujir@broadcom.com>
References: <1362625354-15095-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Matt Carlson" <mcarlson@broadcom.com>,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4291 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753945Ab3CGDDR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 22:03:17 -0500
In-Reply-To: <1362625354-15095-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Carlson <mcarlson@broadcom.com>

tg3 used the fw_needed member loosely as a synonym for firmware TSO. Now
that the 57766 needs firmware download support, fw_needed can no longer be
used like this. This patch creates a new FW_TSO flag and changes the
code to use it.

Also rearrange all the TSO flags together in the enum.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 11 +++++------
 drivers/net/ethernet/broadcom/tg3.h |  5 +++--
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index fdb9b56..f6ebcaa 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3618,9 +3618,7 @@ static int tg3_load_tso_firmware(struct tg3 *tp)
 	unsigned long cpu_base, cpu_scratch_base, cpu_scratch_size;
 	int err, i;
 
-	if (tg3_flag(tp, HW_TSO_1) ||
-	    tg3_flag(tp, HW_TSO_2) ||
-	    tg3_flag(tp, HW_TSO_3))
+	if (!tg3_flag(tp, FW_TSO))
 		return 0;
 
 	fw_data = (void *)tp->fw->data;
@@ -15293,7 +15291,8 @@ static int tg3_get_invariants(struct tg3 *tp, const struct pci_device_id *ent)
 	} else if (tg3_asic_rev(tp) != ASIC_REV_5700 &&
 		   tg3_asic_rev(tp) != ASIC_REV_5701 &&
 		   tg3_chip_rev_id(tp) != CHIPREV_ID_5705_A0) {
-			tg3_flag_set(tp, TSO_BUG);
+		tg3_flag_set(tp, FW_TSO);
+		tg3_flag_set(tp, TSO_BUG);
 		if (tg3_asic_rev(tp) == ASIC_REV_5705)
 			tp->fw_needed = FIRMWARE_TG3TSO5;
 		else
@@ -15304,7 +15303,7 @@ static int tg3_get_invariants(struct tg3 *tp, const struct pci_device_id *ent)
 	if (tg3_flag(tp, HW_TSO_1) ||
 	    tg3_flag(tp, HW_TSO_2) ||
 	    tg3_flag(tp, HW_TSO_3) ||
-	    tp->fw_needed) {
+	    tg3_flag(tp, FW_TSO)) {
 		/* For firmware TSO, assume ASF is disabled.
 		 * We'll disable TSO later if we discover ASF
 		 * is enabled in tg3_get_eeprom_hw_cfg().
@@ -15591,7 +15590,7 @@ static int tg3_get_invariants(struct tg3 *tp, const struct pci_device_id *ent)
 	 */
 	tg3_get_eeprom_hw_cfg(tp);
 
-	if (tp->fw_needed && tg3_flag(tp, ENABLE_ASF)) {
+	if (tg3_flag(tp, FW_TSO) && tg3_flag(tp, ENABLE_ASF)) {
 		tg3_flag_clear(tp, TSO_CAPABLE);
 		tg3_flag_clear(tp, TSO_BUG);
 		tp->fw_needed = NULL;
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 8d7d4c2..eb41b6f 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3009,17 +3009,18 @@ enum TG3_FLAGS {
 	TG3_FLAG_JUMBO_CAPABLE,
 	TG3_FLAG_CHIP_RESETTING,
 	TG3_FLAG_INIT_COMPLETE,
-	TG3_FLAG_TSO_BUG,
 	TG3_FLAG_MAX_RXPEND_64,
-	TG3_FLAG_TSO_CAPABLE,
 	TG3_FLAG_PCI_EXPRESS, /* BCM5785 + pci_is_pcie() */
 	TG3_FLAG_ASF_NEW_HANDSHAKE,
 	TG3_FLAG_HW_AUTONEG,
 	TG3_FLAG_IS_NIC,
 	TG3_FLAG_FLASH,
+	TG3_FLAG_FW_TSO,
 	TG3_FLAG_HW_TSO_1,
 	TG3_FLAG_HW_TSO_2,
 	TG3_FLAG_HW_TSO_3,
+	TG3_FLAG_TSO_CAPABLE,
+	TG3_FLAG_TSO_BUG,
 	TG3_FLAG_ICH_WORKAROUND,
 	TG3_FLAG_1SHOT_MSI,
 	TG3_FLAG_NO_FWARE_REPORTED,
-- 
1.8.1.4
