From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH] bnx2: Use request_firmware()
Date: Thu, 19 Mar 2009 22:29:07 +0000
Message-ID: <1237501747.4126.10.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-alEyMB5BNzbB6RTKrIBR"
Cc: Michael Chan <mchan@broadcom.com>,
	Bastian Blank <waldi@debian.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51092 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761841AbZCSW3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 18:29:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-alEyMB5BNzbB6RTKrIBR
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Based on a patch for Debian by Bastian Blank <waldi@debian.org>.

This patch contains the code changes for review, but should not be
applied.  The complete patch, which is about 1 MB in size and therefore
too large for the mailing list, is at:
<http://womble.decadent.org.uk/tmp/0001-bnx2-Use-request_firmware.patch>.

Ben.

---
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 45403e6..0769f09 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2206,6 +2206,7 @@ config BNX2
 	tristate "Broadcom NetXtremeII support"
 	depends on PCI
 	select CRC32
+	select FW_LOADER
 	select ZLIB_INFLATE
 	help
 	  This driver supports Broadcom NetXtremeII gigabit Ethernet cards.
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 8466d35..54e9c06 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -46,12 +46,11 @@
 #include <linux/crc32.h>
 #include <linux/prefetch.h>
 #include <linux/cache.h>
-#include <linux/zlib.h>
+#include <linux/firmware.h>
 #include <linux/log2.h>
=20
 #include "bnx2.h"
 #include "bnx2_fw.h"
-#include "bnx2_fw2.h"
=20
 #define FW_BUF_SIZE		0x10000
=20
@@ -59,6 +58,8 @@
 #define PFX DRV_MODULE_NAME	": "
 #define DRV_MODULE_VERSION	"1.9.2"
 #define DRV_MODULE_RELDATE	"Feb 11, 2009"
+#define FW_FILE_06		"bnx2-06-4.6.16.fw"
+#define FW_FILE_09		"bnx2-09-4.6.15.fw"
=20
 #define RUN_AT(x) (jiffies + (x))
=20
@@ -72,6 +73,8 @@ MODULE_AUTHOR("Michael Chan <mchan@broadcom.com>");
 MODULE_DESCRIPTION("Broadcom NetXtreme II BCM5706/5708/5709/5716 Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
+MODULE_FIRMWARE(FW_FILE_06);
+MODULE_FIRMWARE(FW_FILE_09);
=20
 static int disable_msi =3D 0;
=20
@@ -3391,24 +3394,91 @@ bnx2_set_rx_mode(struct net_device *dev)
 	spin_unlock_bh(&bp->phy_lock);
 }
=20
-static void
-load_rv2p_fw(struct bnx2 *bp, __le32 *rv2p_code, u32 rv2p_code_len,
-	u32 rv2p_proc)
+static int
+check_fw_section(const struct firmware *fw,
+		 const struct bnx2_fw_file_section *section,
+		 u32 alignment, bool non_empty)
+{
+	u32 offset =3D be32_to_cpu(section->offset);
+	u32 len =3D be32_to_cpu(section->len);
+
+	if ((offset =3D=3D 0 && len !=3D 0) || offset >=3D fw->size || offset & 3=
)
+		return -EINVAL;
+	if ((non_empty && len =3D=3D 0) || len > fw->size - offset ||
+	    len & (alignment - 1))
+		return -EINVAL;
+	return 0;
+}
+
+static int
+check_fw_entry(const struct firmware *fw,
+	       const struct bnx2_fw_file_entry *entry)
+{
+	if (check_fw_section(fw, &entry->text, 4, false) ||
+	    check_fw_section(fw, &entry->data, 4, false) ||
+	    entry->bss.len & 3 ||
+	    entry->sbss.len & 3 ||
+	    check_fw_section(fw, &entry->rodata, 4, false))
+		return -EINVAL;
+	return 0;
+}
+
+static int
+bnx2_request_firmware(struct bnx2 *bp)
 {
+	const struct bnx2_fw_file *fw;
+	const char *fw_file;
+	int rc;
+
+	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709)
+		fw_file =3D FW_FILE_09;
+	else
+		fw_file =3D FW_FILE_06;
+
+	rc =3D request_firmware(&bp->firmware, fw_file, &bp->pdev->dev);
+	if (rc) {
+		printk(KERN_ERR PFX "Can't load firmware file \"%s\"\n",
+		       fw_file);
+		return rc;
+	}
+
+	fw =3D (const struct bnx2_fw_file *)bp->firmware->data;
+	if (bp->firmware->size < sizeof(*fw) ||
+	    check_fw_entry(bp->firmware, &fw->com) ||
+	    check_fw_entry(bp->firmware, &fw->cp) ||
+	    check_fw_entry(bp->firmware, &fw->rxp) ||
+	    check_fw_entry(bp->firmware, &fw->tpat) ||
+	    check_fw_entry(bp->firmware, &fw->txp) ||
+	    check_fw_section(bp->firmware, &fw->rv2p_proc1, 8, true) ||
+	    check_fw_section(bp->firmware, &fw->rv2p_proc2, 8, true)) {
+		printk(KERN_ERR PFX "Firmware file \"%s\" is invalid\n",
+		       fw_file);
+		release_firmware(bp->firmware);
+		bp->firmware =3D NULL;
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int
+load_rv2p_fw(struct bnx2 *bp, u32 rv2p_proc,
+	     const struct bnx2_fw_file_section *fw_section)
+{
+	u32 rv2p_code_len, file_offset;
+	__be32 *rv2p_code;
 	int i;
 	u32 val;
=20
-	if (rv2p_proc =3D=3D RV2P_PROC2 && CHIP_NUM(bp) =3D=3D CHIP_NUM_5709) {
-		val =3D le32_to_cpu(rv2p_code[XI_RV2P_PROC2_MAX_BD_PAGE_LOC]);
-		val &=3D ~XI_RV2P_PROC2_BD_PAGE_SIZE_MSK;
-		val |=3D XI_RV2P_PROC2_BD_PAGE_SIZE;
-		rv2p_code[XI_RV2P_PROC2_MAX_BD_PAGE_LOC] =3D cpu_to_le32(val);
-	}
+	rv2p_code_len =3D be32_to_cpu(fw_section->len);
+	file_offset =3D be32_to_cpu(fw_section->offset);
+
+	rv2p_code =3D (__be32 *)(bp->firmware->data + file_offset);
=20
 	for (i =3D 0; i < rv2p_code_len; i +=3D 8) {
-		REG_WR(bp, BNX2_RV2P_INSTR_HIGH, le32_to_cpu(*rv2p_code));
+		REG_WR(bp, BNX2_RV2P_INSTR_HIGH, be32_to_cpu(*rv2p_code));
 		rv2p_code++;
-		REG_WR(bp, BNX2_RV2P_INSTR_LOW, le32_to_cpu(*rv2p_code));
+		REG_WR(bp, BNX2_RV2P_INSTR_LOW, be32_to_cpu(*rv2p_code));
 		rv2p_code++;
=20
 		if (rv2p_proc =3D=3D RV2P_PROC1) {
@@ -3428,14 +3498,18 @@ load_rv2p_fw(struct bnx2 *bp, __le32 *rv2p_code, u3=
2 rv2p_code_len,
 	else {
 		REG_WR(bp, BNX2_RV2P_COMMAND, BNX2_RV2P_COMMAND_PROC2_RESET);
 	}
+
+	return 0;
 }
=20
 static int
-load_cpu_fw(struct bnx2 *bp, const struct cpu_reg *cpu_reg, struct fw_info=
 *fw)
+load_cpu_fw(struct bnx2 *bp, const struct cpu_reg *cpu_reg,
+	    const struct bnx2_fw_file_entry *fw_entry)
 {
+	u32 addr, len, file_offset;
+	__be32 *data;
 	u32 offset;
 	u32 val;
-	int rc;
=20
 	/* Halt the CPU. */
 	val =3D bnx2_reg_rd_ind(bp, cpu_reg->mode);
@@ -3444,64 +3518,81 @@ load_cpu_fw(struct bnx2 *bp, const struct cpu_reg *=
cpu_reg, struct fw_info *fw)
 	bnx2_reg_wr_ind(bp, cpu_reg->state, cpu_reg->state_value_clear);
=20
 	/* Load the Text area. */
-	offset =3D cpu_reg->spad_base + (fw->text_addr - cpu_reg->mips_view_base)=
;
-	if (fw->gz_text) {
-		int j;
+	addr =3D be32_to_cpu(fw_entry->text.addr);
+	len =3D be32_to_cpu(fw_entry->text.len);
+	file_offset =3D be32_to_cpu(fw_entry->text.offset);
+	data =3D (__be32 *)(bp->firmware->data + file_offset);
=20
-		rc =3D zlib_inflate_blob(fw->text, FW_BUF_SIZE, fw->gz_text,
-				       fw->gz_text_len);
-		if (rc < 0)
-			return rc;
+	offset =3D cpu_reg->spad_base + (addr - cpu_reg->mips_view_base);
+	if (len) {
+		int j;
=20
-		for (j =3D 0; j < (fw->text_len / 4); j++, offset +=3D 4) {
-			bnx2_reg_wr_ind(bp, offset, le32_to_cpu(fw->text[j]));
+		for (j =3D 0; j < (len / 4); j++, offset +=3D 4) {
+			bnx2_reg_wr_ind(bp, offset, be32_to_cpu(data[j]));
 	        }
 	}
=20
 	/* Load the Data area. */
-	offset =3D cpu_reg->spad_base + (fw->data_addr - cpu_reg->mips_view_base)=
;
-	if (fw->data) {
+	addr =3D be32_to_cpu(fw_entry->data.addr);
+	len =3D be32_to_cpu(fw_entry->data.len);
+	file_offset =3D be32_to_cpu(fw_entry->data.offset);
+	data =3D (__be32 *)(bp->firmware->data + file_offset);
+
+	offset =3D cpu_reg->spad_base + (addr - cpu_reg->mips_view_base);
+	if (len) {
 		int j;
=20
-		for (j =3D 0; j < (fw->data_len / 4); j++, offset +=3D 4) {
-			bnx2_reg_wr_ind(bp, offset, fw->data[j]);
+		for (j =3D 0; j < (len / 4); j++, offset +=3D 4) {
+			bnx2_reg_wr_ind(bp, offset, be32_to_cpu(data[j]));
 		}
 	}
=20
 	/* Load the SBSS area. */
-	offset =3D cpu_reg->spad_base + (fw->sbss_addr - cpu_reg->mips_view_base)=
;
-	if (fw->sbss_len) {
+	addr =3D be32_to_cpu(fw_entry->sbss.addr);
+	len =3D be32_to_cpu(fw_entry->sbss.len);
+
+	offset =3D cpu_reg->spad_base + (addr - cpu_reg->mips_view_base);
+	if (len) {
 		int j;
=20
-		for (j =3D 0; j < (fw->sbss_len / 4); j++, offset +=3D 4) {
+		for (j =3D 0; j < (len / 4); j++, offset +=3D 4) {
 			bnx2_reg_wr_ind(bp, offset, 0);
 		}
 	}
=20
 	/* Load the BSS area. */
-	offset =3D cpu_reg->spad_base + (fw->bss_addr - cpu_reg->mips_view_base);
-	if (fw->bss_len) {
+	addr =3D be32_to_cpu(fw_entry->bss.addr);
+	len =3D be32_to_cpu(fw_entry->bss.len);
+
+	offset =3D cpu_reg->spad_base + (addr - cpu_reg->mips_view_base);
+	if (len) {
 		int j;
=20
-		for (j =3D 0; j < (fw->bss_len/4); j++, offset +=3D 4) {
+		for (j =3D 0; j < (len / 4); j++, offset +=3D 4) {
 			bnx2_reg_wr_ind(bp, offset, 0);
 		}
 	}
=20
 	/* Load the Read-Only area. */
-	offset =3D cpu_reg->spad_base +
-		(fw->rodata_addr - cpu_reg->mips_view_base);
-	if (fw->rodata) {
+	addr =3D be32_to_cpu(fw_entry->rodata.addr);
+	len =3D be32_to_cpu(fw_entry->rodata.len);
+	file_offset =3D be32_to_cpu(fw_entry->rodata.offset);
+	data =3D (__be32 *)(bp->firmware->data + file_offset);
+
+	offset =3D cpu_reg->spad_base + (addr - cpu_reg->mips_view_base);
+	if (len) {
 		int j;
=20
-		for (j =3D 0; j < (fw->rodata_len / 4); j++, offset +=3D 4) {
-			bnx2_reg_wr_ind(bp, offset, fw->rodata[j]);
+		for (j =3D 0; j < (len / 4); j++, offset +=3D 4) {
+			bnx2_reg_wr_ind(bp, offset, be32_to_cpu(data[j]));
 		}
 	}
=20
 	/* Clear the pre-fetch instruction. */
 	bnx2_reg_wr_ind(bp, cpu_reg->inst, 0);
-	bnx2_reg_wr_ind(bp, cpu_reg->pc, fw->start_addr);
+
+	val =3D be32_to_cpu(fw_entry->start_addr);
+	bnx2_reg_wr_ind(bp, cpu_reg->pc, val);
=20
 	/* Start the CPU. */
 	val =3D bnx2_reg_rd_ind(bp, cpu_reg->mode);
@@ -3515,95 +3606,38 @@ load_cpu_fw(struct bnx2 *bp, const struct cpu_reg *=
cpu_reg, struct fw_info *fw)
 static int
 bnx2_init_cpus(struct bnx2 *bp)
 {
-	struct fw_info *fw;
-	int rc, rv2p_len;
-	void *text, *rv2p;
+	const struct bnx2_fw_file *fw =3D
+		(const struct bnx2_fw_file *)bp->firmware->data;
+	int rc;
=20
 	/* Initialize the RV2P processor. */
-	text =3D vmalloc(FW_BUF_SIZE);
-	if (!text)
-		return -ENOMEM;
-	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709) {
-		rv2p =3D bnx2_xi_rv2p_proc1;
-		rv2p_len =3D sizeof(bnx2_xi_rv2p_proc1);
-	} else {
-		rv2p =3D bnx2_rv2p_proc1;
-		rv2p_len =3D sizeof(bnx2_rv2p_proc1);
-	}
-	rc =3D zlib_inflate_blob(text, FW_BUF_SIZE, rv2p, rv2p_len);
-	if (rc < 0)
-		goto init_cpu_err;
-
-	load_rv2p_fw(bp, text, rc /* =3D=3D len */, RV2P_PROC1);
-
-	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709) {
-		rv2p =3D bnx2_xi_rv2p_proc2;
-		rv2p_len =3D sizeof(bnx2_xi_rv2p_proc2);
-	} else {
-		rv2p =3D bnx2_rv2p_proc2;
-		rv2p_len =3D sizeof(bnx2_rv2p_proc2);
-	}
-	rc =3D zlib_inflate_blob(text, FW_BUF_SIZE, rv2p, rv2p_len);
-	if (rc < 0)
-		goto init_cpu_err;
-
-	load_rv2p_fw(bp, text, rc /* =3D=3D len */, RV2P_PROC2);
+	load_rv2p_fw(bp, RV2P_PROC1, &fw->rv2p_proc1);
+	load_rv2p_fw(bp, RV2P_PROC2, &fw->rv2p_proc2);
=20
 	/* Initialize the RX Processor. */
-	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709)
-		fw =3D &bnx2_rxp_fw_09;
-	else
-		fw =3D &bnx2_rxp_fw_06;
-
-	fw->text =3D text;
-	rc =3D load_cpu_fw(bp, &cpu_reg_rxp, fw);
+	rc =3D load_cpu_fw(bp, &cpu_reg_rxp, &fw->rxp);
 	if (rc)
 		goto init_cpu_err;
=20
 	/* Initialize the TX Processor. */
-	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709)
-		fw =3D &bnx2_txp_fw_09;
-	else
-		fw =3D &bnx2_txp_fw_06;
-
-	fw->text =3D text;
-	rc =3D load_cpu_fw(bp, &cpu_reg_txp, fw);
+	rc =3D load_cpu_fw(bp, &cpu_reg_txp, &fw->txp);
 	if (rc)
 		goto init_cpu_err;
=20
 	/* Initialize the TX Patch-up Processor. */
-	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709)
-		fw =3D &bnx2_tpat_fw_09;
-	else
-		fw =3D &bnx2_tpat_fw_06;
-
-	fw->text =3D text;
-	rc =3D load_cpu_fw(bp, &cpu_reg_tpat, fw);
+	rc =3D load_cpu_fw(bp, &cpu_reg_tpat, &fw->tpat);
 	if (rc)
 		goto init_cpu_err;
=20
 	/* Initialize the Completion Processor. */
-	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709)
-		fw =3D &bnx2_com_fw_09;
-	else
-		fw =3D &bnx2_com_fw_06;
-
-	fw->text =3D text;
-	rc =3D load_cpu_fw(bp, &cpu_reg_com, fw);
+	rc =3D load_cpu_fw(bp, &cpu_reg_com, &fw->com);
 	if (rc)
 		goto init_cpu_err;
=20
 	/* Initialize the Command Processor. */
-	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709)
-		fw =3D &bnx2_cp_fw_09;
-	else
-		fw =3D &bnx2_cp_fw_06;
-
-	fw->text =3D text;
-	rc =3D load_cpu_fw(bp, &cpu_reg_cp, fw);
+	rc =3D load_cpu_fw(bp, &cpu_reg_cp, &fw->cp);
=20
 init_cpu_err:
-	vfree(text);
 	return rc;
 }
=20
@@ -7807,6 +7841,10 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci=
_device_id *ent)
=20
 	pci_set_drvdata(pdev, dev);
=20
+	rc =3D bnx2_request_firmware(bp);
+	if (rc)
+		goto error;
+
 	memcpy(dev->dev_addr, bp->mac_addr, 6);
 	memcpy(dev->perm_addr, bp->mac_addr, 6);
=20
@@ -7823,13 +7861,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci=
_device_id *ent)
=20
 	if ((rc =3D register_netdev(dev))) {
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
=20
 	printk(KERN_INFO "%s: %s (%c%d) %s found at mem %lx, "
@@ -7843,6 +7875,15 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci=
_device_id *ent)
 		bp->pdev->irq, dev->dev_addr);
=20
 	return 0;
+
+error:
+	if (bp->regview)
+		iounmap(bp->regview);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	pci_set_drvdata(pdev, NULL);
+	free_netdev(dev);
+	return rc;
 }
=20
 static void __devexit
@@ -7855,6 +7896,8 @@ bnx2_remove_one(struct pci_dev *pdev)
=20
 	unregister_netdev(dev);
=20
+	release_firmware(bp->firmware);
+
 	if (bp->regview)
 		iounmap(bp->regview);
=20
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 704cbbc..e630ef3 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6885,6 +6885,7 @@ struct bnx2 {
=20
 	u32			idle_chk_status_idx;
=20
+	const struct firmware	*firmware;
 };
=20
 #define REG_RD(bp, offset)					\
@@ -6915,42 +6916,29 @@ struct cpu_reg {
 	u32 mips_view_base;
 };
=20
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
+};
+
+struct bnx2_fw_file_entry {
+	__be32 start_addr;
+	struct bnx2_fw_file_section text;
+	struct bnx2_fw_file_section data;
+	struct bnx2_fw_file_section sbss;
+	struct bnx2_fw_file_section bss;
+	struct bnx2_fw_file_section rodata;
+};
+
+struct bnx2_fw_file {
+	struct bnx2_fw_file_entry com;
+	struct bnx2_fw_file_entry cp;
+	struct bnx2_fw_file_entry rxp;
+	struct bnx2_fw_file_entry tpat;
+	struct bnx2_fw_file_entry txp;
+	struct bnx2_fw_file_section rv2p_proc1;
+	struct bnx2_fw_file_section rv2p_proc2;
 };
=20
 #define RV2P_PROC1                              0
diff --git a/firmware/Makefile b/firmware/Makefile
index aa2e02d..3235d60 100644
--- a/firmware/Makefile
+++ b/firmware/Makefile
@@ -31,6 +31,7 @@ fw-shipped-$(CONFIG_ADAPTEC_STARFIRE) +=3D adaptec/starfi=
re_rx.bin \
 					 adaptec/starfire_tx.bin
 fw-shipped-$(CONFIG_ATARI_DSP56K) +=3D dsp56k/bootstrap.bin
 fw-shipped-$(CONFIG_ATM_AMBASSADOR) +=3D atmsar11.fw
+fw-shipped-$(CONFIG_BNX2) +=3D bnx2-06-4.6.16.fw bnx2-09-4.6.15.fw
 fw-shipped-$(CONFIG_CASSINI) +=3D sun/cassini.bin
 fw-shipped-$(CONFIG_COMPUTONE) +=3D intelliport2.bin
 fw-shipped-$(CONFIG_CHELSIO_T3) +=3D cxgb3/t3b_psram-1.1.0.bin \
diff --git a/firmware/WHENCE b/firmware/WHENCE
index ea4fc2e..f42e6ad 100644
--- a/firmware/WHENCE
+++ b/firmware/WHENCE
@@ -493,3 +493,21 @@ Licence:
 Found in hex form in kernel source.
=20
 --------------------------------------------------------------------------
+
+Driver: BNX2 - Broadcom NetXtremeII
+
+File: bnx2-06-4.6.16.fw
+File: bnx2-09-4.6.15.fw
+
+Licence:
+
+ This file contains firmware data derived from proprietary unpublished
+ source code, Copyright (c) 2004, 2005, 2006, 2007 Broadcom Corporation.
+
+ Permission is hereby granted for the distribution of this firmware data
+ in hexadecimal or equivalent format, provided this copyright notice is
+ accompanying it.
+
+Found in hex form in kernel source.
+
+--------------------------------------------------------------------------


--=-alEyMB5BNzbB6RTKrIBR
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBJwscv79ZNCRIGYgcRAsNWAJ4s2CfBsr87JjQn66eWUsHkV0iwsQCgp133
lMUgrmGhZZ3/XCZ/YV6pffM=
=RURk
-----END PGP SIGNATURE-----

--=-alEyMB5BNzbB6RTKrIBR--
