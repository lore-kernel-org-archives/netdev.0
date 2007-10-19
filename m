From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 3/7] tg3: Add management FW version to ethtool report
Date: Fri, 19 Oct 2007 14:36:49 -0700
Message-ID: <1192829810.22064.557.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3016 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755745AbXJSVhG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 17:37:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch appends the management firmware version to the bootcode
firmware string reported through ethtool.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 66682b8..68472ce 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10821,9 +10821,24 @@ out_not_found:
 		strcpy(tp->board_part_number, "none");
 }
 
+static int __devinit tg3_fw_img_is_valid(struct tg3 *tp, u32 offset)
+{
+	u32 val;
+
+	if (tg3_nvram_read_swab(tp, offset, &val) ||
+	    (val & 0xfc000000) != 0x0c000000 ||
+	    tg3_nvram_read_swab(tp, offset + 4, &val) ||
+	    val != 0)
+		return 0;
+
+	return 1;
+}
+
 static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 {
 	u32 val, offset, start;
+	u32 ver_offset;
+	int i, bcnt;
 
 	if (tg3_nvram_read_swab(tp, 0, &val))
 		return;
@@ -10836,29 +10851,71 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 		return;
 
 	offset = tg3_nvram_logical_addr(tp, offset);
-	if (tg3_nvram_read_swab(tp, offset, &val))
+
+	if (!tg3_fw_img_is_valid(tp, offset) ||
+	    tg3_nvram_read_swab(tp, offset + 8, &ver_offset))
 		return;
 
-	if ((val & 0xfc000000) == 0x0c000000) {
-		u32 ver_offset, addr;
-		int i;
+	offset = offset + ver_offset - start;
+	for (i = 0; i < 16; i += 4) {
+		if (tg3_nvram_read(tp, offset + i, &val))
+			return;
+
+		val = le32_to_cpu(val);
+		memcpy(tp->fw_ver + i, &val, 4);
+	}
 
-		if (tg3_nvram_read_swab(tp, offset + 4, &val) ||
-		    tg3_nvram_read_swab(tp, offset + 8, &ver_offset))
+	if (!(tp->tg3_flags & TG3_FLAG_ENABLE_ASF) ||
+	     (tp->tg3_flags & TG3_FLG3_ENABLE_APE))
+		return;
+
+	for (offset = TG3_NVM_DIR_START;
+	     offset < TG3_NVM_DIR_END;
+	     offset += TG3_NVM_DIRENT_SIZE) {
+		if (tg3_nvram_read_swab(tp, offset, &val))
 			return;
 
-		if (val != 0)
+		if ((val >> TG3_NVM_DIRTYPE_SHIFT) == TG3_NVM_DIRTYPE_ASFINI)
+			break;
+	}
+
+	if (offset == TG3_NVM_DIR_END)
+		return;
+
+	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+		start = 0x08000000;
+	else if (tg3_nvram_read_swab(tp, offset - 4, &start))
+		return;
+
+	if (tg3_nvram_read_swab(tp, offset + 4, &offset) ||
+	    !tg3_fw_img_is_valid(tp, offset) ||
+	    tg3_nvram_read_swab(tp, offset + 8, &val))
+		return;
+
+	offset += val - start;
+
+	bcnt = strlen(tp->fw_ver);
+
+	tp->fw_ver[bcnt++] = ',';
+	tp->fw_ver[bcnt++] = ' ';
+
+	for (i = 0; i < 4; i++) {
+		if (tg3_nvram_read(tp, offset, &val))
 			return;
 
-		addr = offset + ver_offset - start;
-		for (i = 0; i < 16; i += 4) {
-			if (tg3_nvram_read(tp, addr + i, &val))
-				return;
+		val = le32_to_cpu(val);
+		offset += sizeof(val);
 
-			val = cpu_to_le32(val);
-			memcpy(tp->fw_ver + i, &val, 4);
+		if (bcnt > TG3_VER_SIZE - sizeof(val)) {
+			memcpy(&tp->fw_ver[bcnt], &val, TG3_VER_SIZE - bcnt);
+			break;
 		}
+
+		memcpy(&tp->fw_ver[bcnt], &val, sizeof(val));
+		bcnt += sizeof(val);
 	}
+
+	tp->fw_ver[TG3_VER_SIZE - 1] = 0;
 }
 
 static struct pci_dev * __devinit tg3_find_peer(struct tg3 *);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 6dbdad2..495a1df 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1540,6 +1540,12 @@
 #define TG3_EEPROM_MAGIC_HW		0xabcd
 #define TG3_EEPROM_MAGIC_HW_MSK		0xffff
 
+#define TG3_NVM_DIR_START		0x18
+#define TG3_NVM_DIR_END			0x78
+#define TG3_NVM_DIRENT_SIZE		0xc
+#define TG3_NVM_DIRTYPE_SHIFT		24
+#define TG3_NVM_DIRTYPE_ASFINI		1
+
 /* 32K Window into NIC internal memory */
 #define NIC_SRAM_WIN_BASE		0x00008000
 
@@ -2418,7 +2424,8 @@ struct tg3 {
 	u32				pci_cmd;
 
 	char				board_part_number[24];
-	char				fw_ver[16];
+#define TG3_VER_SIZE 32
+	char				fw_ver[TG3_VER_SIZE];
 	u32				nic_sram_data_cfg;
 	u32				pci_clock_ctrl;
 	struct pci_dev			*pdev_peer;


