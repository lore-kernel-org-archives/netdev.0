From: John Wright <john.wright@hp.com>
Subject: [PATCH 2/4] bnx2x: Use request_firmware()
Date: Sat,  4 Apr 2009 16:15:13 -0600
Message-ID: <1238883314-13140-2-git-send-email-john.wright@hp.com>
References: <1238883314-13140-1-git-send-email-john.wright@hp.com>
Cc: Eilon Greenstein <eilong@broadcom.com>,
	John Wright <john.wright@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:11048 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753698AbZDDWPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2009 18:15:23 -0400
In-Reply-To: <1238883314-13140-1-git-send-email-john.wright@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the driver use a firmware image for all of the data
that was previously in bnx2x_init_values.h, except for some constants
that were indexes into the init_ops array.  That dependency will be
removed in the next patch.

Signed-off-by: John Wright <john.wright@hp.com>
---
 drivers/net/Kconfig      |    1 +
 drivers/net/bnx2x.h      |   19 ++++++++
 drivers/net/bnx2x_init.h |  116 ++++++++++++++++++++++++++++++----------------
 drivers/net/bnx2x_main.c |   75 +++++++++++++++++++++++++++++
 4 files changed, 171 insertions(+), 40 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index e5ffc1c..ff3ad89 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2620,6 +2620,7 @@ config TEHUTI
 config BNX2X
 	tristate "Broadcom NetXtremeII 10Gb support"
 	depends on PCI
+	select FW_LOADER
 	select ZLIB_INFLATE
 	select LIBCRC32C
 	help
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index a329bee..dea9b80 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -965,8 +965,27 @@ struct bnx2x {
 	int			gunzip_outlen;
 #define FW_BUF_SIZE			0x8000
 
+	const struct firmware	*firmware;
 };
 
+struct bnx2x_fw_file_section {
+	u32 len;
+	u32 offset;
+};
+
+struct bnx2x_fw_file {
+	struct bnx2x_fw_file_section init_ops;
+	struct bnx2x_fw_file_section init_ops_offsets;
+	struct bnx2x_fw_file_section init_data;
+	struct bnx2x_fw_file_section tsem_int_table_data;
+	struct bnx2x_fw_file_section tsem_pram_data;
+	struct bnx2x_fw_file_section usem_int_table_data;
+	struct bnx2x_fw_file_section usem_pram_data;
+	struct bnx2x_fw_file_section csem_int_table_data;
+	struct bnx2x_fw_file_section csem_pram_data;
+	struct bnx2x_fw_file_section xsem_int_table_data;
+	struct bnx2x_fw_file_section xsem_pram_data;
+};
 
 #define BNX2X_MAX_QUEUES(bp)	(IS_E1HMF(bp) ? (MAX_CONTEXT / E1HVN_MAX) : \
 						 MAX_CONTEXT)
diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index 39ba293..50fff14 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -221,35 +221,40 @@ static void bnx2x_init_wr_64(struct bnx2x *bp, u32 addr, const u32 *data,
 #define IF_IS_PRAM_ADDR(base, addr) \
 			if (((base) <= (addr)) && ((base) + 0x40000 >= (addr)))
 
-static const u32 *bnx2x_sel_blob(u32 addr, const u32 *data, int is_e1)
+static const u32 *bnx2x_sel_blob(struct bnx2x *bp, u32 addr, const u32 *data)
 {
+	const struct bnx2x_fw_file *fw_file;
+	const struct bnx2x_fw_file_section *section = NULL;
+
+	fw_file = (struct bnx2x_fw_file *)(bp->firmware->data);
+
 	IF_IS_INT_TABLE_ADDR(TSEM_REG_INT_TABLE, addr)
-		data = is_e1 ? tsem_int_table_data_e1 :
-			       tsem_int_table_data_e1h;
+		section = &fw_file->tsem_int_table_data;
 	else
 		IF_IS_INT_TABLE_ADDR(CSEM_REG_INT_TABLE, addr)
-			data = is_e1 ? csem_int_table_data_e1 :
-				       csem_int_table_data_e1h;
+			section = &fw_file->csem_int_table_data;
 	else
 		IF_IS_INT_TABLE_ADDR(USEM_REG_INT_TABLE, addr)
-			data = is_e1 ? usem_int_table_data_e1 :
-				       usem_int_table_data_e1h;
+			section = &fw_file->usem_int_table_data;
 	else
 		IF_IS_INT_TABLE_ADDR(XSEM_REG_INT_TABLE, addr)
-			data = is_e1 ? xsem_int_table_data_e1 :
-				       xsem_int_table_data_e1h;
+			section = &fw_file->xsem_int_table_data;
 	else
 		IF_IS_PRAM_ADDR(TSEM_REG_PRAM, addr)
-			data = is_e1 ? tsem_pram_data_e1 : tsem_pram_data_e1h;
+			section = &fw_file->tsem_pram_data;
 	else
 		IF_IS_PRAM_ADDR(CSEM_REG_PRAM, addr)
-			data = is_e1 ? csem_pram_data_e1 : csem_pram_data_e1h;
+			section = &fw_file->csem_pram_data;
 	else
 		IF_IS_PRAM_ADDR(USEM_REG_PRAM, addr)
-			data = is_e1 ? usem_pram_data_e1 : usem_pram_data_e1h;
+			section = &fw_file->usem_pram_data;
 	else
 		IF_IS_PRAM_ADDR(XSEM_REG_PRAM, addr)
-			data = is_e1 ? xsem_pram_data_e1 : xsem_pram_data_e1h;
+			section = &fw_file->xsem_pram_data;
+
+	if (section)
+		data = (u32 *)(bp->firmware->data +
+			       le32_to_cpu(section->offset));
 
 	return data;
 }
@@ -257,37 +262,19 @@ static const u32 *bnx2x_sel_blob(u32 addr, const u32 *data, int is_e1)
 static void bnx2x_init_wr_wb(struct bnx2x *bp, u32 addr, const u32 *data,
 			     u32 len, int gunzip, int is_e1, u32 blob_off)
 {
+	/* Assumes data contains 32-bit little endian values */
 	int offset = 0;
 
-	data = bnx2x_sel_blob(addr, data, is_e1) + blob_off;
+	data = bnx2x_sel_blob(bp, addr, data) + blob_off;
 
 	if (gunzip) {
 		int rc;
-#ifdef __BIG_ENDIAN
-		int i, size;
-		u32 *temp;
-
-		temp = kmalloc(len, GFP_KERNEL);
-		size = (len / 4) + ((len % 4) ? 1 : 0);
-		for (i = 0; i < size; i++)
-			temp[i] = swab32(data[i]);
-		data = temp;
-#endif
 		rc = bnx2x_gunzip(bp, (u8 *)data, len);
 		if (rc) {
 			BNX2X_ERR("gunzip failed ! rc %d\n", rc);
-#ifdef __BIG_ENDIAN
-			kfree(temp);
-#endif
 			return;
 		}
 		len = bp->gunzip_outlen;
-#ifdef __BIG_ENDIAN
-		kfree(temp);
-		for (i = 0; i < len; i++)
-			((u32 *)bp->gunzip_buf)[i] =
-					swab32(((u32 *)bp->gunzip_buf)[i]);
-#endif
 	} else {
 		if ((len * 4) > FW_BUF_SIZE) {
 			BNX2X_ERR("LARGE DMAE OPERATION ! "
@@ -296,6 +283,11 @@ static void bnx2x_init_wr_wb(struct bnx2x *bp, u32 addr, const u32 *data,
 		}
 		memcpy(bp->gunzip_buf, data, len * 4);
 	}
+#ifdef __BIG_ENDIAN
+	for (i = 0; i < len; i++)
+		((u32 *)bp->gunzip_buf)[i] =
+				swab32(((u32 *)bp->gunzip_buf)[i]);
+#endif
 
 	if (bp->dmae_ready) {
 		while (len > DMAE_LEN32_WR_MAX) {
@@ -310,15 +302,24 @@ static void bnx2x_init_wr_wb(struct bnx2x *bp, u32 addr, const u32 *data,
 		bnx2x_init_ind_wr(bp, addr, bp->gunzip_buf, len);
 }
 
-static void bnx2x_init_block(struct bnx2x *bp, u32 op_start, u32 op_end)
+static int bnx2x_init_block(struct bnx2x *bp, u32 op_start, u32 op_end)
 {
 	int is_e1       = CHIP_IS_E1(bp);
 	int is_e1h      = CHIP_IS_E1H(bp);
 	int is_emul_e1h = (CHIP_REV_IS_EMUL(bp) && is_e1h);
 	int hw_wr, i;
+	const struct raw_op *init_ops;
 	union init_op *op;
-	u32 op_type, addr, len;
+	u32 op_type, addr, len, offset;
 	const u32 *data, *data_base;
+	const struct bnx2x_fw_file *fw_file;
+#ifdef __BIG_ENDIAN
+	union init_op real_op;
+	int j;
+	u32 *pos;
+#endif
+
+	fw_file = (struct bnx2x_fw_file *)bp->firmware->data;
 
 	if (CHIP_REV_IS_FPGA(bp))
 		hw_wr = OP_WR_FPGA;
@@ -327,14 +328,28 @@ static void bnx2x_init_block(struct bnx2x *bp, u32 op_start, u32 op_end)
 	else
 		hw_wr = OP_WR_ASIC;
 
-	if (is_e1)
-		data_base = init_data_e1;
-	else /* CHIP_IS_E1H(bp) */
-		data_base = init_data_e1h;
+	/* Grab the init ops from the firmware */
+	len = le32_to_cpu(fw_file->init_ops.len);
+	offset = le32_to_cpu(fw_file->init_ops.offset);
+	if (!len || !offset || len + offset > bp->firmware->size)
+		return -EINVAL;
+	init_ops = (struct raw_op *)(bp->firmware->data + offset);
 
-	for (i = op_start; i < op_end; i++) {
+	len = le32_to_cpu(fw_file->init_data.len);
+	offset = le32_to_cpu(fw_file->init_data.offset);
+	if (!len || !offset || len + offset > bp->firmware->size)
+		return -EINVAL;
+	data_base = (u32 *)(bp->firmware->data + offset);
 
+	for (i = op_start; i < op_end; i++) {
+#ifdef __BIG_ENDIAN
+		op = (union init_op *)&real_op;
+		pos = (u32 *)&init_ops[i];
+		for (j = 0; j < sizeof(union init_op) / 4; j++)
+			((u32 *)op)[j] = le32_to_cpu(pos[j]);
+#else
 		op = (union init_op *)&(init_ops[i]);
+#endif
 
 		op_type = op->str_wr.op;
 		addr = op->str_wr.offset;
@@ -364,6 +379,22 @@ static void bnx2x_init_block(struct bnx2x *bp, u32 op_start, u32 op_end)
 				op_type = OP_WR;
 		}
 
+#ifdef __BIG_ENDIAN
+		switch (op_type) {
+		case OP_SW:
+		case OP_SI:
+		case OP_WR_64:
+			pos = kmalloc(len * 4, GFP_KERNEL);
+			for (i = 0; i < len; i++)
+				pos[i] = le32_to_cpu(data[i]);
+			data = pos;
+			break;
+		default:
+			pos = NULL;
+			break;
+		}
+#endif
+
 		switch (op_type) {
 		case OP_RD:
 			REG_RD(bp, addr);
@@ -400,7 +431,12 @@ static void bnx2x_init_block(struct bnx2x *bp, u32 op_start, u32 op_end)
 #endif
 			break;
 		}
+#ifdef __BIG_ENDIAN
+	kfree(pos);
+#endif
 	}
+
+	return 0;
 }
 
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 00a78e8..2723172 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -49,6 +49,7 @@
 #include <linux/prefetch.h>
 #include <linux/zlib.h>
 #include <linux/io.h>
+#include <linux/firmware.h>
 
 
 #include "bnx2x.h"
@@ -58,6 +59,8 @@
 #define DRV_MODULE_VERSION	"1.48.105"
 #define DRV_MODULE_RELDATE	"2009/03/02"
 #define BNX2X_BC_VER		0x040200
+#define FW_FILE_E1		"bnx2x-e1-1.48.105.fw"
+#define FW_FILE_E1H		"bnx2x-e1h-1.48.105.fw"
 
 /* Time in jiffies before concluding the transmitter is hung */
 #define TX_TIMEOUT		(5*HZ)
@@ -70,6 +73,8 @@ MODULE_AUTHOR("Eliezer Tamir");
 MODULE_DESCRIPTION("Broadcom NetXtreme II BCM57710/57711/57711E Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
+MODULE_FIRMWARE(FW_FILE_E1);
+MODULE_FIRMWARE(FW_FILE_E1H);
 
 static int multi_mode = 1;
 module_param(multi_mode, int, 0);
@@ -11083,6 +11088,68 @@ static int __devinit bnx2x_get_pcie_speed(struct bnx2x *bp)
 	return val;
 }
 
+static int __devinit bnx2x_check_firmware(const struct firmware *firmware)
+{
+	const struct bnx2x_fw_file *fw_file;
+	const struct bnx2x_fw_file_section *sections;
+	const u32 *ops_offsets;
+	u32 offset, len, num_ops;
+	int i;
+
+	if (firmware->size < sizeof(struct bnx2x_fw_file))
+		return -EINVAL;
+
+	fw_file = (struct bnx2x_fw_file *)firmware->data;
+	sections = (struct bnx2x_fw_file_section *)fw_file;
+
+	/* Make sure none of the offsets and sizes make us read beyond
+	 * the end of the firmware data */
+	for (i = 0; i < sizeof(*fw_file) / sizeof(*sections); i++) {
+		offset = le32_to_cpu(sections[i].offset);
+		len = le32_to_cpu(sections[i].len);
+		if (offset + len > firmware->size)
+			return -EINVAL;
+	}
+
+	/* Likewise for the init_ops offsets */
+	offset = le32_to_cpu(fw_file->init_ops_offsets.offset);
+	ops_offsets = (u32 *)(firmware->data + offset);
+	num_ops = le32_to_cpu(fw_file->init_ops.len) / sizeof(struct raw_op);
+
+	for (i = 0; i < le32_to_cpu(fw_file->init_ops_offsets.len) / 4; i++) {
+		if (le32_to_cpu(ops_offsets[i]) >= num_ops)
+			return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int __devinit bnx2x_request_firmware(struct bnx2x *bp,
+					    struct device *dev)
+{
+	const char *fw_file = CHIP_IS_E1(bp) ? FW_FILE_E1 : FW_FILE_E1H;
+	int rc;
+
+	rc = request_firmware(&bp->firmware, fw_file, dev);
+	if (rc) {
+		printk(KERN_ERR PFX "Can't load firmware file %s\n", fw_file);
+		goto request_firmware_exit;
+	}
+
+	rc = bnx2x_check_firmware(bp->firmware);
+	if (rc) {
+		printk(KERN_ERR PFX "Corrupt firmware file %s\n", fw_file);
+		goto request_firmware_exit;
+	}
+
+	return 0;
+
+request_firmware_exit:
+	release_firmware(bp->firmware);
+
+	return rc;
+}
+
 static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
@@ -11116,6 +11183,12 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	if (rc)
 		goto init_one_exit;
 
+	rc = bnx2x_request_firmware(bp, &pdev->dev);
+	if (rc) {
+		printk(KERN_ERR PFX "Error loading firmware\n");
+		goto init_one_exit;
+	}
+
 	rc = register_netdev(dev);
 	if (rc) {
 		dev_err(&pdev->dev, "Cannot register net device\n");
@@ -11163,6 +11236,8 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 
 	unregister_netdev(dev);
 
+	release_firmware(bp->firmware);
+
 	if (bp->regview)
 		iounmap(bp->regview);
 
-- 
1.5.6.5

