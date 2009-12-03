From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 3/6] tg3: Add some VPD preprocessor constants
Date: Thu, 3 Dec 2009 10:36:22 -0800
Message-ID: <1259865385-7773-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2995 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755767AbZLCSkd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 13:40:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cleans up the VPD code by creating preprocessor definitions
and using them in the place of hardcoded constants.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c       |   15 ++++++++-------
 drivers/net/tg3.h       |   10 ++++++++--
 include/linux/ethtool.h |    3 ++-
 3 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0e6c553..5302cf9 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12434,7 +12434,7 @@ skip_phy_reset:
 
 static void __devinit tg3_read_partno(struct tg3 *tp)
 {
-	unsigned char vpd_data[256];   /* in little-endian format */
+	unsigned char vpd_data[TG3_NVM_VPD_LEN];   /* in little-endian format */
 	unsigned int i;
 	u32 magic;
 
@@ -12443,14 +12443,14 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 		goto out_not_found;
 
 	if (magic == TG3_EEPROM_MAGIC) {
-		for (i = 0; i < 256; i += 4) {
+		for (i = 0; i < TG3_NVM_VPD_LEN; i += 4) {
 			u32 tmp;
 
 			/* The data is in little-endian format in NVRAM.
 			 * Use the big-endian read routines to preserve
 			 * the byte order as it exists in NVRAM.
 			 */
-			if (tg3_nvram_read_be32(tp, 0x100 + i, &tmp))
+			if (tg3_nvram_read_be32(tp, TG3_NVM_VPD_OFF + i, &tmp))
 				goto out_not_found;
 
 			memcpy(&vpd_data[i], &tmp, sizeof(tmp));
@@ -12459,7 +12459,7 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 		int vpd_cap;
 
 		vpd_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_VPD);
-		for (i = 0; i < 256; i += 4) {
+		for (i = 0; i < TG3_NVM_VPD_LEN; i += 4) {
 			u32 tmp, j = 0;
 			__le32 v;
 			u16 tmp16;
@@ -12484,7 +12484,7 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 	}
 
 	/* Now parse and find the part number. */
-	for (i = 0; i < 254; ) {
+	for (i = 0; i < TG3_NVM_VPD_LEN - 2; ) {
 		unsigned char val = vpd_data[i];
 		unsigned int block_end;
 
@@ -12503,7 +12503,7 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 			      (vpd_data[i + 2] << 8)));
 		i += 3;
 
-		if (block_end > 256)
+		if (block_end > TG3_NVM_VPD_LEN)
 			goto out_not_found;
 
 		while (i < (block_end - 2)) {
@@ -12512,7 +12512,8 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 				int partno_len = vpd_data[i + 2];
 
 				i += 3;
-				if (partno_len > 24 || (partno_len + i) > 256)
+				if (partno_len > TG3_BPN_SIZE ||
+				    (partno_len + i) > TG3_NVM_VPD_LEN)
 					goto out_not_found;
 
 				memcpy(tp->board_part_number,
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 6a2c310..cd30889 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1821,6 +1821,11 @@
 
 #define TG3_OTP_DEFAULT			0x286c1640
 
+
+/* Hardware Legacy NVRAM layout */
+#define TG3_NVM_VPD_OFF			0x100
+#define TG3_NVM_VPD_LEN			256
+
 /* Hardware Selfboot NVRAM layout */
 #define TG3_NVM_HWSB_CFG1		0x00000004
 #define  TG3_NVM_HWSB_CFG1_MAJMSK	0xf8000000
@@ -2893,8 +2898,9 @@ struct tg3 {
 	u32				led_ctrl;
 	u32				phy_otp;
 
-	char				board_part_number[24];
-#define TG3_VER_SIZE 32
+#define TG3_BPN_SIZE			24
+	char				board_part_number[TG3_BPN_SIZE];
+#define TG3_VER_SIZE			ETHTOOL_FWVERS_LEN
 	char				fw_ver[TG3_VER_SIZE];
 	u32				nic_sram_data_cfg;
 	u32				pci_clock_ctrl;
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index bcaa0e0..ef4a2d8 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -49,13 +49,14 @@ static inline __u32 ethtool_cmd_speed(struct ethtool_cmd *ep)
 	return (ep->speed_hi << 16) | ep->speed;
 }
 
+#define ETHTOOL_FWVERS_LEN	32
 #define ETHTOOL_BUSINFO_LEN	32
 /* these strings are set to whatever the driver author decides... */
 struct ethtool_drvinfo {
 	__u32	cmd;
 	char	driver[32];	/* driver short name, "tulip", "eepro100" */
 	char	version[32];	/* driver version string */
-	char	fw_version[32];	/* firmware version string, if applicable */
+	char	fw_version[ETHTOOL_FWVERS_LEN];	/* firmware version string */
 	char	bus_info[ETHTOOL_BUSINFO_LEN];	/* Bus info for this IF. */
 				/* For PCI devices, use pci_name(pci_dev). */
 	char	reserved1[32];
-- 
1.6.4.4


