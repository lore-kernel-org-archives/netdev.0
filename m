From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 05/13] netxen: download firmware from file
Date: Mon, 12 Jan 2009 11:23:03 -0800
Message-ID: <1231788191-23794-6-git-send-email-dhananjay@netxen.com>
References: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:56014 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756362AbZALTex (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 14:34:53 -0500
In-Reply-To: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o optimize the onboard flash access routines by reducing udelays and
  reordering some register writes.
o Add support to request firmware from filesystem, its validation
  for compability. If firmware file is not found or validation fails,
  fall back to firmware flashed on the card.
o Fail the pci probe if firmware init fails.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    9 ++
 drivers/net/netxen/netxen_nic_hdr.h  |    3 +
 drivers/net/netxen/netxen_nic_hw.c   |  170 +++++++++++++++++++++++++++++++---
 drivers/net/netxen/netxen_nic_init.c |   53 ++++++-----
 drivers/net/netxen/netxen_nic_main.c |   56 ++++++-----
 5 files changed, 227 insertions(+), 64 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 5110348..274d19f 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -712,6 +712,15 @@ typedef enum {
 	NETXEN_FIXED_START = 0x3F0000	/* backup of crbinit */
 } netxen_flash_map_t;
 
+#define NX_FW_VERSION_OFFSET	(NETXEN_USER_START+0x408)
+#define NX_FW_SIZE_OFFSET	(NETXEN_USER_START+0x40c)
+#define NX_BIOS_VERSION_OFFSET	(NETXEN_USER_START+0x83c)
+#define NX_FW_MAGIC_OFFSET	(NETXEN_BRDCFG_START+0x128)
+#define NX_FW_MIN_SIZE		(0x3fffff)
+#define NX_P2_MN_ROMIMAGE	"nxromimg.bin"
+#define NX_P3_CT_ROMIMAGE	"nx3fwct.bin"
+#define NX_P3_MN_ROMIMAGE	"nx3fwmn.bin"
+
 #define NETXEN_USER_START_OLD NETXEN_PXE_START	/* for backward compatibility */
 
 #define NETXEN_FLASH_START		(NETXEN_CRBINIT_START)
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index e80f9e3..269a1f7 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -858,6 +858,9 @@ enum {
 #define NETXEN_PORT_MODE_ADDR		(NETXEN_CAM_RAM(0x24))
 #define NETXEN_WOL_PORT_MODE		(NETXEN_CAM_RAM(0x198))
 
+#define NX_PEG_TUNE_MN_PRESENT		0x1
+#define NX_PEG_TUNE_CAPABILITY		(NETXEN_CAM_RAM(0x02c))
+
 #define NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL		(0x14)
 
 #define	ISR_MSI_INT_TRIGGER(FUNC) (NETXEN_PCIX_PS_REG(PCIX_MSI_F(FUNC)))
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index e2bb5cf..5d69997 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -35,7 +35,7 @@
 #include "netxen_nic_hw.h"
 #include "netxen_nic_phan_reg.h"
 
-
+#include <linux/firmware.h>
 #include <net/ip.h>
 
 #define MASK(n) ((1ULL<<(n))-1)
@@ -945,26 +945,62 @@ netxen_nic_pci_set_crbwindow_2M(struct netxen_adapter *adapter, ulong *off)
 		(ulong)adapter->ahw.pci_base0;
 }
 
-int netxen_load_firmware(struct netxen_adapter *adapter)
+static int
+netxen_do_load_firmware(struct netxen_adapter *adapter, const char *fwname,
+		const struct firmware *fw)
 {
-	int i;
-	u32 data, size = 0;
-	u32 flashaddr = NETXEN_BOOTLD_START, memaddr = NETXEN_BOOTLD_START;
+	u64 *ptr64;
+	u32 i, flashaddr, size;
+	struct pci_dev *pdev = adapter->pdev;
 
-	size = (NETXEN_IMAGE_START - NETXEN_BOOTLD_START)/4;
+	if (fw)
+		dev_info(&pdev->dev, "loading firmware from file %s\n", fwname);
+	else
+		dev_info(&pdev->dev, "loading firmware from flash\n");
 
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
 		adapter->pci_write_normalize(adapter,
 				NETXEN_ROMUSB_GLB_CAS_RST, 1);
 
-	for (i = 0; i < size; i++) {
-		if (netxen_rom_fast_read(adapter, flashaddr, (int *)&data) != 0)
-			return -EIO;
+	if (fw) {
+		__le64 data;
+
+		size = (NETXEN_IMAGE_START - NETXEN_BOOTLD_START) / 8;
+
+		ptr64 = (u64 *)&fw->data[NETXEN_BOOTLD_START];
+		flashaddr = NETXEN_BOOTLD_START;
+
+		for (i = 0; i < size; i++) {
+			data = cpu_to_le64(ptr64[i]);
+			adapter->pci_mem_write(adapter, flashaddr, &data, 8);
+			flashaddr += 8;
+		}
+
+		size = *(u32 *)&fw->data[NX_FW_SIZE_OFFSET];
+		size = (__force u32)cpu_to_le32(size) / 8;
+
+		ptr64 = (u64 *)&fw->data[NETXEN_IMAGE_START];
+		flashaddr = NETXEN_IMAGE_START;
+
+		for (i = 0; i < size; i++) {
+			data = cpu_to_le64(ptr64[i]);
+			adapter->pci_mem_write(adapter, flashaddr, &data, 8);
+			flashaddr += 8;
+		}
+	} else {
+		u32 data;
+
+		size = (NETXEN_IMAGE_START - NETXEN_BOOTLD_START) / 4;
+		flashaddr = NETXEN_BOOTLD_START;
+
+		for (i = 0; i < size; i++) {
+			if (netxen_rom_fast_read(adapter,
+					flashaddr, (int *)&data) != 0)
+				return -EIO;
 
-		adapter->pci_mem_write(adapter, memaddr, &data, 4);
-		flashaddr += 4;
-		memaddr += 4;
-		cond_resched();
+			adapter->pci_mem_write(adapter, flashaddr, &data, 4);
+			flashaddr += 4;
+		}
 	}
 	msleep(1);
 
@@ -981,6 +1017,114 @@ int netxen_load_firmware(struct netxen_adapter *adapter)
 	return 0;
 }
 
+static int
+netxen_validate_firmware(struct netxen_adapter *adapter, const char *fwname,
+		const struct firmware *fw)
+{
+	__le32 val;
+	u32 major, minor, build, ver, min_ver, bios;
+	struct pci_dev *pdev = adapter->pdev;
+
+	if (fw->size < NX_FW_MIN_SIZE)
+		return -EINVAL;
+
+	val = cpu_to_le32(*(u32 *)&fw->data[NX_FW_MAGIC_OFFSET]);
+	if ((__force u32)val != NETXEN_BDINFO_MAGIC)
+		return -EINVAL;
+
+	val = cpu_to_le32(*(u32 *)&fw->data[NX_FW_VERSION_OFFSET]);
+	major = (__force u32)val & 0xff;
+	minor = ((__force u32)val >> 8) & 0xff;
+	build = (__force u32)val >> 16;
+
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		min_ver = NETXEN_VERSION_CODE(4, 0, 216);
+	else
+		min_ver = NETXEN_VERSION_CODE(3, 4, 216);
+
+	ver = NETXEN_VERSION_CODE(major, minor, build);
+
+	if ((major > _NETXEN_NIC_LINUX_MAJOR) || (ver < min_ver)) {
+		dev_err(&pdev->dev,
+				"%s: firmware version %d.%d.%d unsupported\n",
+				fwname, major, minor, build);
+		return -EINVAL;
+	}
+
+	val = cpu_to_le32(*(u32 *)&fw->data[NX_BIOS_VERSION_OFFSET]);
+	netxen_rom_fast_read(adapter, NX_BIOS_VERSION_OFFSET, (int *)&bios);
+	if ((__force u32)val != bios) {
+		dev_err(&pdev->dev, "%s: firmware bios is incompatible\n",
+				fwname);
+		return -EINVAL;
+	}
+
+	netxen_nic_reg_write(adapter, NETXEN_CAM_RAM(0x1fc),
+			NETXEN_BDINFO_MAGIC);
+	return 0;
+}
+
+int netxen_load_firmware(struct netxen_adapter *adapter)
+{
+	u32 capability, flashed_ver;
+	const struct firmware *fw;
+	char *fw_name = NULL;
+	struct pci_dev *pdev = adapter->pdev;
+	int rc = 0;
+
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+		fw_name = NX_P2_MN_ROMIMAGE;
+		goto request_fw;
+	}
+
+	capability = 0;
+
+	netxen_rom_fast_read(adapter,
+			NX_FW_VERSION_OFFSET, (int *)&flashed_ver);
+	if (flashed_ver >= NETXEN_VERSION_CODE(4, 0, 220)) {
+		adapter->hw_read_wx(adapter,
+				NX_PEG_TUNE_CAPABILITY, &capability, 4);
+		if (capability & NX_PEG_TUNE_MN_PRESENT) {
+			fw_name = NX_P3_MN_ROMIMAGE;
+			goto request_fw;
+		}
+	}
+
+request_ct:
+	fw_name = NX_P3_CT_ROMIMAGE;
+
+request_fw:
+	rc = request_firmware(&fw, fw_name, &pdev->dev);
+	if (rc != 0) {
+		if (fw_name == NX_P3_MN_ROMIMAGE) {
+			msleep(1);
+			goto request_ct;
+		}
+
+		fw = NULL;
+		goto load_fw;
+	}
+
+	rc = netxen_validate_firmware(adapter, fw_name, fw);
+	if (rc != 0) {
+		release_firmware(fw);
+
+		if (fw_name == NX_P3_MN_ROMIMAGE) {
+			msleep(1);
+			goto request_ct;
+		}
+
+		fw = NULL;
+	}
+
+load_fw:
+	rc = netxen_do_load_firmware(adapter, fw_name, fw);
+
+	if (fw)
+		release_firmware(fw);
+	return rc;
+}
+
 int
 netxen_nic_hw_write_wx_128M(struct netxen_adapter *adapter,
 		ulong off, void *data, int len)
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index c0e06a6..aa8d52e 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -50,8 +50,6 @@ static unsigned int crb_addr_xform[NETXEN_MAX_CRB_XFORM];
 	crb_addr_xform[NETXEN_HW_PX_MAP_CRB_##name] = \
 	NETXEN_HW_CRB_HUB_AGT_ADR_##name << 20
 
-#define NETXEN_NIC_XDMA_RESET 0x8000ff
-
 static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 					uint32_t ctx, uint32_t ringid);
 
@@ -404,7 +402,7 @@ static long rom_lock_timeout = 10000;
 static long rom_write_timeout = 700;
 #endif
 
-static int rom_lock(struct netxen_adapter *adapter)
+static int netxen_rom_lock(struct netxen_adapter *adapter)
 {
 	int iter;
 	u32 done = 0;
@@ -439,6 +437,8 @@ static int netxen_wait_rom_done(struct netxen_adapter *adapter)
 	long timeout = 0;
 	long done = 0;
 
+	cond_resched();
+
 	while (done == 0) {
 		done = netxen_nic_reg_read(adapter, NETXEN_ROMUSB_GLB_STATUS);
 		done &= 2;
@@ -533,12 +533,9 @@ static int do_rom_fast_write(struct netxen_adapter *adapter, int addr,
 static int do_rom_fast_read(struct netxen_adapter *adapter,
 			    int addr, int *valp)
 {
-	cond_resched();
-
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
-	udelay(100);		/* prevent bursting on CRB */
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
+	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE, 0xb);
 	if (netxen_wait_rom_done(adapter)) {
 		printk("Error waiting for rom done\n");
@@ -546,7 +543,7 @@ static int do_rom_fast_read(struct netxen_adapter *adapter,
 	}
 	/* reset abyte_cnt and dummy_byte_cnt */
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
-	udelay(100);		/* prevent bursting on CRB */
+	udelay(10);
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
 
 	*valp = netxen_nic_reg_read(adapter, NETXEN_ROMUSB_ROM_RDATA);
@@ -577,7 +574,7 @@ netxen_rom_fast_read_words(struct netxen_adapter *adapter, int addr,
 {
 	int ret;
 
-	ret = rom_lock(adapter);
+	ret = netxen_rom_lock(adapter);
 	if (ret < 0)
 		return ret;
 
@@ -591,7 +588,7 @@ int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
 {
 	int ret;
 
-	if (rom_lock(adapter) != 0)
+	if (netxen_rom_lock(adapter) != 0)
 		return -EIO;
 
 	ret = do_rom_fast_read(adapter, addr, valp);
@@ -604,7 +601,7 @@ int netxen_rom_fast_write(struct netxen_adapter *adapter, int addr, int data)
 {
 	int ret = 0;
 
-	if (rom_lock(adapter) != 0) {
+	if (netxen_rom_lock(adapter) != 0) {
 		return -1;
 	}
 	ret = do_rom_fast_write(adapter, addr, data);
@@ -665,7 +662,7 @@ int netxen_rom_fast_write_words(struct netxen_adapter *adapter, int addr,
 {
 	int ret = 0;
 
-	ret = rom_lock(adapter);
+	ret = netxen_rom_lock(adapter);
 	if (ret < 0)
 		return ret;
 
@@ -698,7 +695,7 @@ static int netxen_rom_rdsr(struct netxen_adapter *adapter)
 {
 	int ret;
 
-	ret = rom_lock(adapter);
+	ret = netxen_rom_lock(adapter);
 	if (ret < 0)
 		return ret;
 
@@ -798,7 +795,7 @@ static void check_erased_flash(struct netxen_adapter *adapter, int addr)
 int netxen_rom_se(struct netxen_adapter *adapter, int addr)
 {
 	int ret = 0;
-	if (rom_lock(adapter) != 0) {
+	if (netxen_rom_lock(adapter) != 0) {
 		return -1;
 	}
 	ret = netxen_do_rom_se(adapter, addr);
@@ -884,14 +881,16 @@ int netxen_flash_unlock(struct netxen_adapter *adapter)
 int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 {
 	int addr, val;
-	int i, init_delay = 0;
+	int i, n, init_delay = 0;
 	struct crb_addr_pair *buf;
-	unsigned offset, n;
+	unsigned offset;
 	u32 off;
 
 	/* resetall */
+	netxen_rom_lock(adapter);
 	netxen_crb_writelit_adapter(adapter, NETXEN_ROMUSB_GLB_SW_RESET,
 				    0xffffffff);
+	netxen_rom_unlock(adapter);
 
 	if (verbose) {
 		if (netxen_rom_fast_read(adapter, NETXEN_BOARDTYPE, &val) == 0)
@@ -910,7 +909,7 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
 		if (netxen_rom_fast_read(adapter, 0, &n) != 0 ||
-			(n != 0xcafecafeUL) ||
+			(n != 0xcafecafe) ||
 			netxen_rom_fast_read(adapter, 4, &n) != 0) {
 			printk(KERN_ERR "%s: ERROR Reading crb_init area: "
 					"n: %08x\n", netxen_nic_driver_name, n);
@@ -975,6 +974,14 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 			/* do not reset PCI */
 			if (off == (ROMUSB_GLB + 0xbc))
 				continue;
+			if (off == (ROMUSB_GLB + 0xa8))
+				continue;
+			if (off == (ROMUSB_GLB + 0xc8)) /* core clock */
+				continue;
+			if (off == (ROMUSB_GLB + 0x24)) /* MN clock */
+				continue;
+			if (off == (ROMUSB_GLB + 0x1c)) /* MS clock */
+				continue;
 			if (off == (NETXEN_CRB_PEG_NET_1 + 0x18))
 				buf[i].data = 0x1020;
 			/* skip the function enable register */
@@ -992,23 +999,19 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 			continue;
 		}
 
+		init_delay = 1;
 		/* After writing this register, HW needs time for CRB */
 		/* to quiet down (else crb_window returns 0xffffffff) */
 		if (off == NETXEN_ROMUSB_GLB_SW_RESET) {
-			init_delay = 1;
+			init_delay = 1000;
 			if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
 				/* hold xdma in reset also */
-				buf[i].data = NETXEN_NIC_XDMA_RESET;
+				buf[i].data = 0x8000ff;
 			}
 		}
 
 		adapter->hw_write_wx(adapter, off, &buf[i].data, 4);
-
-		if (init_delay == 1) {
-			msleep(1000);
-			init_delay = 0;
-		}
-		msleep(1);
+		msleep(init_delay);
 	}
 	kfree(buf);
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 7da2b08..d2b0c59 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -280,10 +280,15 @@ static void netxen_check_options(struct netxen_adapter *adapter)
 static int
 netxen_check_hw_init(struct netxen_adapter *adapter, int first_boot)
 {
-	int ret = 0;
+	u32 val, timeout;
 
 	if (first_boot == 0x55555555) {
 		/* This is the first boot after power up */
+		adapter->pci_write_normalize(adapter,
+			NETXEN_CAM_RAM(0x1fc), NETXEN_BDINFO_MAGIC);
+
+		if (!NX_IS_REVISION_P2(adapter->ahw.revision_id))
+			return 0;
 
 		/* PCI bus master workaround */
 		adapter->hw_read_wx(adapter,
@@ -296,25 +301,29 @@ netxen_check_hw_init(struct netxen_adapter *adapter, int first_boot)
 				NETXEN_PCIE_REG(0x4), &first_boot, 4);
 		}
 
-		/* This is the first boot after power up */
 		adapter->hw_read_wx(adapter,
-			NETXEN_ROMUSB_GLB_SW_RESET, &first_boot, 4);
-		if (first_boot != 0x80000f) {
-			/* clear the register for future unloads/loads */
-			adapter->pci_write_normalize(adapter,
-					NETXEN_CAM_RAM(0x1fc), 0);
-			ret = -1;
+			NETXEN_ROMUSB_GLB_SW_RESET, &val, 4);
+		if (val != 0x80000f) {
+			return -EIO;
 		}
 
-		if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
-			/* Start P2 boot loader */
-			adapter->pci_write_normalize(adapter,
-				NETXEN_CAM_RAM(0x1fc), NETXEN_BDINFO_MAGIC);
-			adapter->pci_write_normalize(adapter,
-					NETXEN_ROMUSB_GLB_PEGTUNE_DONE, 1);
-		}
+		/* Start P2 boot loader */
+		val = adapter->pci_read_normalize(adapter,
+				NETXEN_ROMUSB_GLB_PEGTUNE_DONE);
+		adapter->pci_write_normalize(adapter,
+				NETXEN_ROMUSB_GLB_PEGTUNE_DONE, val | 0x1);
+		timeout = 0;
+		do {
+			msleep(1);
+			val = adapter->pci_read_normalize(adapter,
+					NETXEN_CAM_RAM(0x1fc));
+
+			if (++timeout > 5000)
+				return -EIO;
+
+		} while (val == NETXEN_BDINFO_MAGIC);
 	}
-	return ret;
+	return 0;
 }
 
 static void netxen_set_port_mode(struct netxen_adapter *adapter)
@@ -793,8 +802,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 						CRB_CMDPEG_STATE, 0);
 			netxen_pinit_from_rom(adapter, 0);
 			msleep(1);
-			netxen_load_firmware(adapter);
 		}
+		netxen_load_firmware(adapter);
 
 		if (NX_IS_REVISION_P3(revision_id))
 			netxen_pcie_strap_init(adapter);
@@ -807,14 +816,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 				val |= 0x0f000000;
 			netxen_crb_writelit_adapter(adapter,
 					NETXEN_MAC_ADDR_CNTL_REG, val);
-
-		}
-
-		if ((first_boot == 0x55555555) &&
-			(NX_IS_REVISION_P2(revision_id))) {
-			/* Unlock the HW, prompting the boot sequence */
-			adapter->pci_write_normalize(adapter,
-					NETXEN_ROMUSB_GLB_PEGTUNE_DONE, 1);
 		}
 
 		err = netxen_initialize_adapter_offload(adapter);
@@ -830,7 +831,9 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		adapter->pci_write_normalize(adapter, CRB_DRIVER_VERSION, i);
 
 		/* Handshake with the card before we register the devices. */
-		netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
+		err = netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
+		if (err)
+			goto err_out_free_offload;
 
 	}	/* first_driver */
 
@@ -934,6 +937,7 @@ err_out_disable_msi:
 	if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
 		pci_disable_msi(pdev);
 
+err_out_free_offload:
 	if (first_driver)
 		netxen_free_adapter_offload(adapter);
 
-- 
1.6.0.2

