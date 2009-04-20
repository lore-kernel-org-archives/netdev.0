From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 3/8] tg3: Handle NVRAM absent cases
Date: Mon, 20 Apr 2009 09:57:14 -0700
Message-ID: <1240247956.7015@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2380 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909AbZDTRTB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 13:19:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some 57780 ASIC revision parts do not have NVRAM.  Code the driver so
that it is tolerant of this configuration.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   36 ++++++++++++++++++++++++++++++++----
 drivers/net/tg3.h |    1 +
 2 files changed, 33 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e4fa02c..9b04954 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8544,6 +8544,9 @@ static int tg3_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	u32 i, offset, len, b_offset, b_count;
 	__be32 val;
 
+	if (tp->tg3_flags3 & TG3_FLG3_NO_NVRAM)
+		return -EINVAL;
+
 	if (tp->link_config.phy_is_low_power)
 		return -EAGAIN;
 
@@ -8609,7 +8612,8 @@ static int tg3_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	if (tp->link_config.phy_is_low_power)
 		return -EAGAIN;
 
-	if (eeprom->magic != TG3_EEPROM_MAGIC)
+	if ((tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) ||
+	    eeprom->magic != TG3_EEPROM_MAGIC)
 		return -EINVAL;
 
 	offset = eeprom->offset;
@@ -9206,6 +9210,9 @@ static int tg3_test_nvram(struct tg3 *tp)
 	__be32 *buf;
 	int i, j, k, err = 0, size;
 
+	if (tp->tg3_flags3 & TG3_FLG3_NO_NVRAM)
+		return 0;
+
 	if (tg3_nvram_read(tp, 0, &magic) != 0)
 		return -EIO;
 
@@ -10188,7 +10195,8 @@ static void __devinit tg3_get_nvram_size(struct tg3 *tp)
 {
 	u32 val;
 
-	if (tg3_nvram_read(tp, 0, &val) != 0)
+	if ((tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) ||
+	    tg3_nvram_read(tp, 0, &val) != 0)
 		return;
 
 	/* Selfboot format */
@@ -10570,6 +10578,7 @@ static void __devinit tg3_get_57780_nvram_info(struct tg3 *tp)
 		}
 		break;
 	default:
+		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM;
 		return;
 	}
 
@@ -11370,7 +11379,8 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 	unsigned int i;
 	u32 magic;
 
-	if (tg3_nvram_read(tp, 0x0, &magic))
+	if ((tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) ||
+	    tg3_nvram_read(tp, 0x0, &magic))
 		goto out_not_found;
 
 	if (magic == TG3_EEPROM_MAGIC) {
@@ -11462,6 +11472,15 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 out_not_found:
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		strcpy(tp->board_part_number, "BCM95906");
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 &&
+		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57780)
+		strcpy(tp->board_part_number, "BCM57780");
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 &&
+		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57760)
+		strcpy(tp->board_part_number, "BCM57760");
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 &&
+		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57790)
+		strcpy(tp->board_part_number, "BCM57790");
 	else
 		strcpy(tp->board_part_number, "none");
 }
@@ -11672,6 +11691,14 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 {
 	u32 val;
 
+	if (tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) {
+		tp->fw_ver[0] = 's';
+		tp->fw_ver[1] = 'b';
+		tp->fw_ver[2] = '\0';
+
+		return;
+	}
+
 	if (tg3_nvram_read(tp, 0, &val))
 		return;
 
@@ -12459,7 +12486,8 @@ static int __devinit tg3_get_device_address(struct tg3 *tp)
 	}
 	if (!addr_ok) {
 		/* Next, try NVRAM. */
-		if (!tg3_nvram_read_be32(tp, mac_offset + 0, &hi) &&
+		if (!(tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) &&
+		    !tg3_nvram_read_be32(tp, mac_offset + 0, &hi) &&
 		    !tg3_nvram_read_be32(tp, mac_offset + 4, &lo)) {
 			memcpy(&dev->dev_addr[0], ((char *)&hi) + 2, 2);
 			memcpy(&dev->dev_addr[2], (char *)&lo, sizeof(lo));
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index ca71a49..afbabf2 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2636,6 +2636,7 @@ struct tg3 {
 #define TG3_FLG3_CLKREQ_BUG		0x00000800
 #define TG3_FLG3_PHY_ENABLE_APD		0x00001000
 #define TG3_FLG3_5755_PLUS		0x00002000
+#define TG3_FLG3_NO_NVRAM		0x00004000
 
 	struct timer_list		timer;
 	u16				timer_counter;
-- 
1.6.0.6


