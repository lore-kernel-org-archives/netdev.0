From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Wed, 01 Apr 2009 11:01:45 -0700
Message-ID: <1238608905.18617.272.camel@HP1>
References: <1237501747.4126.10.camel@deadeye.i.decadent.org.uk>
 <1237503884.16140.23.camel@HP1>
 <20090319232541.GA19262@wavehammer.waldi.eu.org>
 <20090320.155030.164080684.davem@davemloft.net>
 <1237844879.18617.20.camel@HP1>
 <20090323223238.GB29609@wavehammer.waldi.eu.org>
 <1237850931.18617.39.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"davem@davemloft.org" <davem@davemloft.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Bastian Blank" <waldi@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2711 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933272AbZDASHG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2009 14:07:06 -0400
In-Reply-To: <1237850931.18617.39.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've made some minor changes to Bastian and Ben's patch.  I've separated
the mips firmware from the non-mips firmware, added code to fix up the
non-mips firmware with the host CPU's page size, and other minor
changes.  If there are no issues, I'll send the entire patch with the
ihex files when net-next opens up.

Thanks again to Bastian and Ben.  Here's the new patch that excludes the
firmware ihex files for review.

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index ad446db..fed551b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -46,19 +46,20 @@
 #include <linux/crc32.h>
 #include <linux/prefetch.h>
 #include <linux/cache.h>
-#include <linux/zlib.h>
+#include <linux/firmware.h>
 #include <linux/log2.h>
 
 #include "bnx2.h"
 #include "bnx2_fw.h"
-#include "bnx2_fw2.h"
-
-#define FW_BUF_SIZE		0x10000
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
 #define DRV_MODULE_VERSION	"1.9.3"
 #define DRV_MODULE_RELDATE	"March 17, 2009"
+#define FW_MIPS_FILE_06		"bnx2-mips-06-4.6.16.fw"
+#define FW_RV2P_FILE_06		"bnx2-rv2p-06-4.6.16.fw"
+#define FW_MIPS_FILE_09		"bnx2-mips-09-4.6.15.fw"
+#define FW_RV2P_FILE_09		"bnx2-rv2p-09-4.6.15.fw"
 
 #define RUN_AT(x) (jiffies + (x))
 
@@ -72,6 +73,10 @@ MODULE_AUTHOR("Michael Chan <mchan@broadcom.com>");
 MODULE_DESCRIPTION("Broadcom NetXtreme II BCM5706/5708/5709/5716 Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
+MODULE_FIRMWARE(FW_MIPS_FILE_06);
+MODULE_FIRMWARE(FW_RV2P_FILE_06);
+MODULE_FIRMWARE(FW_MIPS_FILE_09);
+MODULE_FIRMWARE(FW_RV2P_FILE_09);
 
 static int disable_msi = 0;
 
@@ -3391,33 +3396,143 @@ bnx2_set_rx_mode(struct net_device *dev)
 	spin_unlock_bh(&bp->phy_lock);
 }
 
-static void
-load_rv2p_fw(struct bnx2 *bp, __le32 *rv2p_code, u32 rv2p_code_len,
-	u32 rv2p_proc)
+static int __devinit
+check_fw_section(const struct firmware *fw,
+		 const struct bnx2_fw_file_section *section,
+		 u32 alignment, bool non_empty)
+{
+	u32 offset = be32_to_cpu(section->offset);
+	u32 len = be32_to_cpu(section->len);
+
+	if ((offset == 0 && len != 0) || offset >= fw->size || offset & 3)
+		return -EINVAL;
+	if ((non_empty && len == 0) || len > fw->size - offset ||
+	    len & (alignment - 1))
+		return -EINVAL;
+	return 0;
+}
+
+static int __devinit
+check_mips_fw_entry(const struct firmware *fw,
+		    const struct bnx2_mips_fw_file_entry *entry)
+{
+	if (check_fw_section(fw, &entry->text, 4, true) ||
+	    check_fw_section(fw, &entry->data, 4, false) ||
+	    check_fw_section(fw, &entry->rodata, 4, false))
+		return -EINVAL;
+	return 0;
+}
+
+static int __devinit
+bnx2_request_firmware(struct bnx2 *bp)
 {
+	const char *mips_fw_file, *rv2p_fw_file;
+	const struct bnx2_mips_fw_file *mips;
+	const struct bnx2_rv2p_fw_file *rv2p;
+	int rc;
+
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		mips_fw_file = FW_MIPS_FILE_09;
+		rv2p_fw_file = FW_RV2P_FILE_09;
+	} else {
+		mips_fw_file = FW_MIPS_FILE_06;
+		rv2p_fw_file = FW_RV2P_FILE_06;
+	}
+
+	rc = request_firmware(&bp->mips_firmware, mips_fw_file, &bp->pdev->dev);
+	if (rc) {
+		printk(KERN_ERR PFX "Can't load firmware file \"%s\"\n",
+		       mips_fw_file);
+		return rc;
+	}
+
+	rc = request_firmware(&bp->rv2p_firmware, rv2p_fw_file, &bp->pdev->dev);
+	if (rc) {
+		printk(KERN_ERR PFX "Can't load firmware file \"%s\"\n",
+		       rv2p_fw_file);
+		return rc;
+	}
+	mips = (const struct bnx2_mips_fw_file *) bp->mips_firmware->data;
+	rv2p = (const struct bnx2_rv2p_fw_file *) bp->rv2p_firmware->data;
+	if (bp->mips_firmware->size < sizeof(*mips) ||
+	    check_mips_fw_entry(bp->mips_firmware, &mips->com) ||
+	    check_mips_fw_entry(bp->mips_firmware, &mips->cp) ||
+	    check_mips_fw_entry(bp->mips_firmware, &mips->rxp) ||
+	    check_mips_fw_entry(bp->mips_firmware, &mips->tpat) ||
+	    check_mips_fw_entry(bp->mips_firmware, &mips->txp)) {
+		printk(KERN_ERR PFX "Firmware file \"%s\" is invalid\n",
+		       mips_fw_file);
+		return -EINVAL;
+	}
+	if (bp->rv2p_firmware->size < sizeof(*rv2p) ||
+	    check_fw_section(bp->rv2p_firmware, &rv2p->proc1.rv2p, 8, true) ||
+	    check_fw_section(bp->rv2p_firmware, &rv2p->proc2.rv2p, 8, true)) {
+		printk(KERN_ERR PFX "Firmware file \"%s\" is invalid\n",
+		       rv2p_fw_file);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static u32
+rv2p_fw_fixup(u32 rv2p_proc, int idx, u32 loc, u32 rv2p_code)
+{
+	switch (idx) {
+	case RV2P_P1_FIXUP_PAGE_SIZE_IDX:
+		rv2p_code &= ~RV2P_BD_PAGE_SIZE_MSK;
+		rv2p_code |= RV2P_BD_PAGE_SIZE;
+		break;
+	}
+	return rv2p_code;
+}
+
+static int
+load_rv2p_fw(struct bnx2 *bp, u32 rv2p_proc,
+	     const struct bnx2_rv2p_fw_file_entry *fw_entry)
+{
+	u32 rv2p_code_len, file_offset;
+	__be32 *rv2p_code;
 	int i;
-	u32 val;
+	u32 val, cmd, addr;
+
+	rv2p_code_len = be32_to_cpu(fw_entry->rv2p.len);
+	file_offset = be32_to_cpu(fw_entry->rv2p.offset);
+
+	rv2p_code = (__be32 *)(bp->rv2p_firmware->data + file_offset);
 
-	if (rv2p_proc == RV2P_PROC2 && CHIP_NUM(bp) == CHIP_NUM_5709) {
-		val = le32_to_cpu(rv2p_code[XI_RV2P_PROC2_MAX_BD_PAGE_LOC]);
-		val &= ~XI_RV2P_PROC2_BD_PAGE_SIZE_MSK;
-		val |= XI_RV2P_PROC2_BD_PAGE_SIZE;
-		rv2p_code[XI_RV2P_PROC2_MAX_BD_PAGE_LOC] = cpu_to_le32(val);
+	if (rv2p_proc == RV2P_PROC1) {
+		cmd = BNX2_RV2P_PROC1_ADDR_CMD_RDWR;
+		addr = BNX2_RV2P_PROC1_ADDR_CMD;
+	} else {
+		cmd = BNX2_RV2P_PROC2_ADDR_CMD_RDWR;
+		addr = BNX2_RV2P_PROC2_ADDR_CMD;
 	}
 
 	for (i = 0; i < rv2p_code_len; i += 8) {
-		REG_WR(bp, BNX2_RV2P_INSTR_HIGH, le32_to_cpu(*rv2p_code));
+		REG_WR(bp, BNX2_RV2P_INSTR_HIGH, be32_to_cpu(*rv2p_code));
 		rv2p_code++;
-		REG_WR(bp, BNX2_RV2P_INSTR_LOW, le32_to_cpu(*rv2p_code));
+		REG_WR(bp, BNX2_RV2P_INSTR_LOW, be32_to_cpu(*rv2p_code));
 		rv2p_code++;
 
-		if (rv2p_proc == RV2P_PROC1) {
-			val = (i / 8) | BNX2_RV2P_PROC1_ADDR_CMD_RDWR;
-			REG_WR(bp, BNX2_RV2P_PROC1_ADDR_CMD, val);
-		}
-		else {
-			val = (i / 8) | BNX2_RV2P_PROC2_ADDR_CMD_RDWR;
-			REG_WR(bp, BNX2_RV2P_PROC2_ADDR_CMD, val);
+		val = (i / 8) | cmd;
+		REG_WR(bp, addr, val);
+	}
+
+	rv2p_code = (__be32 *)(bp->rv2p_firmware->data + file_offset);
+	for (i = 0; i < 8; i++) {
+		u32 loc, code;
+
+		loc = be32_to_cpu(fw_entry->fixup[i]);
+		if (loc && ((loc * 4) < rv2p_code_len)) {
+			code = be32_to_cpu(*(rv2p_code + loc - 1));
+			REG_WR(bp, BNX2_RV2P_INSTR_HIGH, code);
+			code = be32_to_cpu(*(rv2p_code + loc));
+			code = rv2p_fw_fixup(rv2p_proc, i, loc, code);
+			REG_WR(bp, BNX2_RV2P_INSTR_LOW, code);
+
+			val = (loc / 2) | cmd;
+			REG_WR(bp, addr, val);
 		}
 	}
 
@@ -3428,14 +3543,18 @@ load_rv2p_fw(struct bnx2 *bp, __le32 *rv2p_code, u32 rv2p_code_len,
 	else {
 		REG_WR(bp, BNX2_RV2P_COMMAND, BNX2_RV2P_COMMAND_PROC2_RESET);
 	}
+
+	return 0;
 }
 
 static int
-load_cpu_fw(struct bnx2 *bp, const struct cpu_reg *cpu_reg, struct fw_info *fw)
+load_cpu_fw(struct bnx2 *bp, const struct cpu_reg *cpu_reg,
+	    const struct bnx2_mips_fw_file_entry *fw_entry)
 {
+	u32 addr, len, file_offset;
+	__be32 *data;
 	u32 offset;
 	u32 val;
-	int rc;
 
 	/* Halt the CPU. */
 	val = bnx2_reg_rd_ind(bp, cpu_reg->mode);
@@ -3444,64 +3563,52 @@ load_cpu_fw(struct bnx2 *bp, const struct cpu_reg *cpu_reg, struct fw_info *fw)
 	bnx2_reg_wr_ind(bp, cpu_reg->state, cpu_reg->state_value_clear);
 
 	/* Load the Text area. */
-	offset = cpu_reg->spad_base + (fw->text_addr - cpu_reg->mips_view_base);
-	if (fw->gz_text) {
-		int j;
-
-		rc = zlib_inflate_blob(fw->text, FW_BUF_SIZE, fw->gz_text,
-				       fw->gz_text_len);
-		if (rc < 0)
-			return rc;
+	addr = be32_to_cpu(fw_entry->text.addr);
+	len = be32_to_cpu(fw_entry->text.len);
+	file_offset = be32_to_cpu(fw_entry->text.offset);
+	data = (__be32 *)(bp->mips_firmware->data + file_offset);
 
-		for (j = 0; j < (fw->text_len / 4); j++, offset += 4) {
-			bnx2_reg_wr_ind(bp, offset, le32_to_cpu(fw->text[j]));
-	        }
-	}
-
-	/* Load the Data area. */
-	offset = cpu_reg->spad_base + (fw->data_addr - cpu_reg->mips_view_base);
-	if (fw->data) {
+	offset = cpu_reg->spad_base + (addr - cpu_reg->mips_view_base);
+	if (len) {
 		int j;
 
-		for (j = 0; j < (fw->data_len / 4); j++, offset += 4) {
-			bnx2_reg_wr_ind(bp, offset, fw->data[j]);
-		}
+		for (j = 0; j < (len / 4); j++, offset += 4)
+			bnx2_reg_wr_ind(bp, offset, be32_to_cpu(data[j]));
 	}
 
-	/* Load the SBSS area. */
-	offset = cpu_reg->spad_base + (fw->sbss_addr - cpu_reg->mips_view_base);
-	if (fw->sbss_len) {
-		int j;
-
-		for (j = 0; j < (fw->sbss_len / 4); j++, offset += 4) {
-			bnx2_reg_wr_ind(bp, offset, 0);
-		}
-	}
+	/* Load the Data area. */
+	addr = be32_to_cpu(fw_entry->data.addr);
+	len = be32_to_cpu(fw_entry->data.len);
+	file_offset = be32_to_cpu(fw_entry->data.offset);
+	data = (__be32 *)(bp->mips_firmware->data + file_offset);
 
-	/* Load the BSS area. */
-	offset = cpu_reg->spad_base + (fw->bss_addr - cpu_reg->mips_view_base);
-	if (fw->bss_len) {
+	offset = cpu_reg->spad_base + (addr - cpu_reg->mips_view_base);
+	if (len) {
 		int j;
 
-		for (j = 0; j < (fw->bss_len/4); j++, offset += 4) {
-			bnx2_reg_wr_ind(bp, offset, 0);
-		}
+		for (j = 0; j < (len / 4); j++, offset += 4)
+			bnx2_reg_wr_ind(bp, offset, be32_to_cpu(data[j]));
 	}
 
 	/* Load the Read-Only area. */
-	offset = cpu_reg->spad_base +
-		(fw->rodata_addr - cpu_reg->mips_view_base);
-	if (fw->rodata) {
+	addr = be32_to_cpu(fw_entry->rodata.addr);
+	len = be32_to_cpu(fw_entry->rodata.len);
+	file_offset = be32_to_cpu(fw_entry->rodata.offset);
+	data = (__be32 *)(bp->mips_firmware->data + file_offset);
+
+	offset = cpu_reg->spad_base + (addr - cpu_reg->mips_view_base);
+	if (len) {
 		int j;
 
-		for (j = 0; j < (fw->rodata_len / 4); j++, offset += 4) {
-			bnx2_reg_wr_ind(bp, offset, fw->rodata[j]);
-		}
+		for (j = 0; j < (len / 4); j++, offset += 4)
+			bnx2_reg_wr_ind(bp, offset, be32_to_cpu(data[j]));
 	}
 
 	/* Clear the pre-fetch instruction. */
 	bnx2_reg_wr_ind(bp, cpu_reg->inst, 0);
-	bnx2_reg_wr_ind(bp, cpu_reg->pc, fw->start_addr);
+
+	val = be32_to_cpu(fw_entry->start_addr);
+	bnx2_reg_wr_ind(bp, cpu_reg->pc, val);
 
 	/* Start the CPU. */
 	val = bnx2_reg_rd_ind(bp, cpu_reg->mode);
@@ -3515,95 +3622,40 @@ load_cpu_fw(struct bnx2 *bp, const struct cpu_reg *cpu_reg, struct fw_info *fw)
 static int
 bnx2_init_cpus(struct bnx2 *bp)
 {
-	struct fw_info *fw;
-	int rc, rv2p_len;
-	void *text, *rv2p;
+	const struct bnx2_mips_fw_file *mips_fw =
+		(const struct bnx2_mips_fw_file *) bp->mips_firmware->data;
+	const struct bnx2_rv2p_fw_file *rv2p_fw =
+		(const struct bnx2_rv2p_fw_file *) bp->rv2p_firmware->data;
+	int rc;
 
 	/* Initialize the RV2P processor. */
-	text = vmalloc(FW_BUF_SIZE);
-	if (!text)
-		return -ENOMEM;
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
-		rv2p = bnx2_xi_rv2p_proc1;
-		rv2p_len = sizeof(bnx2_xi_rv2p_proc1);
-	} else {
-		rv2p = bnx2_rv2p_proc1;
-		rv2p_len = sizeof(bnx2_rv2p_proc1);
-	}
-	rc = zlib_inflate_blob(text, FW_BUF_SIZE, rv2p, rv2p_len);
-	if (rc < 0)
-		goto init_cpu_err;
-
-	load_rv2p_fw(bp, text, rc /* == len */, RV2P_PROC1);
-
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
-		rv2p = bnx2_xi_rv2p_proc2;
-		rv2p_len = sizeof(bnx2_xi_rv2p_proc2);
-	} else {
-		rv2p = bnx2_rv2p_proc2;
-		rv2p_len = sizeof(bnx2_rv2p_proc2);
-	}
-	rc = zlib_inflate_blob(text, FW_BUF_SIZE, rv2p, rv2p_len);
-	if (rc < 0)
-		goto init_cpu_err;
-
-	load_rv2p_fw(bp, text, rc /* == len */, RV2P_PROC2);
+	load_rv2p_fw(bp, RV2P_PROC1, &rv2p_fw->proc1);
+	load_rv2p_fw(bp, RV2P_PROC2, &rv2p_fw->proc2);
 
 	/* Initialize the RX Processor. */
-	if (CHIP_NUM(bp) == CHIP_NUM_5709)
-		fw = &bnx2_rxp_fw_09;
-	else
-		fw = &bnx2_rxp_fw_06;
-
-	fw->text = text;
-	rc = load_cpu_fw(bp, &cpu_reg_rxp, fw);
+	rc = load_cpu_fw(bp, &cpu_reg_rxp, &mips_fw->rxp);
 	if (rc)
 		goto init_cpu_err;
 
 	/* Initialize the TX Processor. */
-	if (CHIP_NUM(bp) == CHIP_NUM_5709)
-		fw = &bnx2_txp_fw_09;
-	else
-		fw = &bnx2_txp_fw_06;
-
-	fw->text = text;
-	rc = load_cpu_fw(bp, &cpu_reg_txp, fw);
+	rc = load_cpu_fw(bp, &cpu_reg_txp, &mips_fw->txp);
 	if (rc)
 		goto init_cpu_err;
 
 	/* Initialize the TX Patch-up Processor. */
-	if (CHIP_NUM(bp) == CHIP_NUM_5709)
-		fw = &bnx2_tpat_fw_09;
-	else
-		fw = &bnx2_tpat_fw_06;
-
-	fw->text = text;
-	rc = load_cpu_fw(bp, &cpu_reg_tpat, fw);
+	rc = load_cpu_fw(bp, &cpu_reg_tpat, &mips_fw->tpat);
 	if (rc)
 		goto init_cpu_err;
 
 	/* Initialize the Completion Processor. */
-	if (CHIP_NUM(bp) == CHIP_NUM_5709)
-		fw = &bnx2_com_fw_09;
-	else
-		fw = &bnx2_com_fw_06;
-
-	fw->text = text;
-	rc = load_cpu_fw(bp, &cpu_reg_com, fw);
+	rc = load_cpu_fw(bp, &cpu_reg_com, &mips_fw->com);
 	if (rc)
 		goto init_cpu_err;
 
 	/* Initialize the Command Processor. */
-	if (CHIP_NUM(bp) == CHIP_NUM_5709)
-		fw = &bnx2_cp_fw_09;
-	else
-		fw = &bnx2_cp_fw_06;
-
-	fw->text = text;
-	rc = load_cpu_fw(bp, &cpu_reg_cp, fw);
+	rc = load_cpu_fw(bp, &cpu_reg_cp, &mips_fw->cp);
 
 init_cpu_err:
-	vfree(text);
 	return rc;
 }
 
@@ -7807,6 +7859,10 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, dev);
 
+	rc = bnx2_request_firmware(bp);
+	if (rc)
+		goto error;
+
 	memcpy(dev->dev_addr, bp->mac_addr, 6);
 	memcpy(dev->perm_addr, bp->mac_addr, 6);
 
@@ -7823,13 +7879,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	if ((rc = register_netdev(dev))) {
 		dev_err(&pdev->dev, "Cannot register net device\n");
-		if (bp->regview)
-			iounmap(bp->regview);
-		pci_release_regions(pdev);
-		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
-		free_netdev(dev);
-		return rc;
+		goto error;
 	}
 
 	printk(KERN_INFO "%s: %s (%c%d) %s found at mem %lx, "
@@ -7843,6 +7893,20 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		bp->pdev->irq, dev->dev_addr);
 
 	return 0;
+
+error:
+	if (bp->mips_firmware)
+		release_firmware(bp->mips_firmware);
+	if (bp->rv2p_firmware)
+		release_firmware(bp->rv2p_firmware);
+
+	if (bp->regview)
+		iounmap(bp->regview);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	pci_set_drvdata(pdev, NULL);
+	free_netdev(dev);
+	return rc;
 }
 
 static void __devexit
@@ -7855,6 +7919,11 @@ bnx2_remove_one(struct pci_dev *pdev)
 
 	unregister_netdev(dev);
 
+	if (bp->mips_firmware)
+		release_firmware(bp->mips_firmware);
+	if (bp->rv2p_firmware)
+		release_firmware(bp->rv2p_firmware);
+
 	if (bp->regview)
 		iounmap(bp->regview);
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 704cbbc..5b570e1 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6885,6 +6885,8 @@ struct bnx2 {
 
 	u32			idle_chk_status_idx;
 
+	const struct firmware	*mips_firmware;
+	const struct firmware	*rv2p_firmware;
 };
 
 #define REG_RD(bp, offset)					\
@@ -6915,44 +6917,41 @@ struct cpu_reg {
 	u32 mips_view_base;
 };
 
-struct fw_info {
-	const u32 ver_major;
-	const u32 ver_minor;
-	const u32 ver_fix;
-
-	const u32 start_addr;
-
-	/* Text section. */
-	const u32 text_addr;
-	const u32 text_len;
-	const u32 text_index;
-	__le32 *text;
-	u8 *gz_text;
-	const u32 gz_text_len;
-
-	/* Data section. */
-	const u32 data_addr;
-	const u32 data_len;
-	const u32 data_index;
-	const u32 *data;
-
-	/* SBSS section. */
-	const u32 sbss_addr;
-	const u32 sbss_len;
-	const u32 sbss_index;
-
-	/* BSS section. */
-	const u32 bss_addr;
-	const u32 bss_len;
-	const u32 bss_index;
-
-	/* Read-only section. */
-	const u32 rodata_addr;
-	const u32 rodata_len;
-	const u32 rodata_index;
-	const u32 *rodata;
+struct bnx2_fw_file_section {
+	__be32 addr;
+	__be32 len;
+	__be32 offset;
 };
 
+struct bnx2_mips_fw_file_entry {
+	__be32 start_addr;
+	struct bnx2_fw_file_section text;
+	struct bnx2_fw_file_section data;
+	struct bnx2_fw_file_section rodata;
+};
+
+struct bnx2_rv2p_fw_file_entry {
+	struct bnx2_fw_file_section rv2p;
+	__be32 fixup[8];
+};
+
+struct bnx2_mips_fw_file {
+	struct bnx2_mips_fw_file_entry com;
+	struct bnx2_mips_fw_file_entry cp;
+	struct bnx2_mips_fw_file_entry rxp;
+	struct bnx2_mips_fw_file_entry tpat;
+	struct bnx2_mips_fw_file_entry txp;
+};
+
+struct bnx2_rv2p_fw_file {
+	struct bnx2_rv2p_fw_file_entry proc1;
+	struct bnx2_rv2p_fw_file_entry proc2;
+};
+
+#define RV2P_P1_FIXUP_PAGE_SIZE_IDX		0
+#define RV2P_BD_PAGE_SIZE_MSK			0xffff
+#define RV2P_BD_PAGE_SIZE			((BCM_PAGE_SIZE / 16) - 1)
+
 #define RV2P_PROC1                              0
 #define RV2P_PROC2                              1
 



