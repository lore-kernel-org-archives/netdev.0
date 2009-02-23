From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 2/5] netxen: firmware download support
Date: Sun, 22 Feb 2009 23:42:13 -0800
Message-ID: <1235374936-28778-2-git-send-email-dhananjay@netxen.com>
References: <1235374936-28778-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:42590 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752845AbZBWHmV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2009 02:42:21 -0500
In-Reply-To: <1235374936-28778-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    9 ++
 drivers/net/netxen/netxen_nic_hdr.h  |    3 +
 drivers/net/netxen/netxen_nic_hw.c   |  175 +++++++++++++++++++++++++++++++--
 drivers/net/netxen/netxen_nic_main.c |  125 ++++++++++++------------
 4 files changed, 238 insertions(+), 74 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index f4dd9ac..b726182 100644
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
index b2f67b9..aef39e7 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -35,7 +35,7 @@
 #include "netxen_nic_hw.h"
 #include "netxen_nic_phan_reg.h"
 
-
+#include <linux/firmware.h>
 #include <net/ip.h>
 
 #define MASK(n) ((1ULL<<(n))-1)
@@ -951,24 +951,69 @@ netxen_nic_pci_set_crbwindow_2M(struct netxen_adapter *adapter, ulong *off)
 		(ulong)adapter->ahw.pci_base0;
 }
 
-int netxen_load_firmware(struct netxen_adapter *adapter)
+static int
+netxen_do_load_firmware(struct netxen_adapter *adapter, const char *fwname,
+		const struct firmware *fw)
 {
-	int i;
-	u32 data, size = 0;
-	u32 flashaddr = NETXEN_BOOTLD_START;
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
+
+			if (adapter->pci_mem_write(adapter,
+						flashaddr, &data, 8))
+				return -EIO;
+
+			flashaddr += 8;
+		}
+	} else {
+		u32 data;
+
+		size = (NETXEN_IMAGE_START - NETXEN_BOOTLD_START) / 4;
+		flashaddr = NETXEN_BOOTLD_START;
 
-		adapter->pci_mem_write(adapter, flashaddr, &data, 4);
-		flashaddr += 4;
+		for (i = 0; i < size; i++) {
+			if (netxen_rom_fast_read(adapter,
+					flashaddr, (int *)&data) != 0)
+				return -EIO;
+
+			if (adapter->pci_mem_write(adapter,
+						flashaddr, &data, 4))
+				return -EIO;
+
+			flashaddr += 4;
+		}
 	}
 	msleep(1);
 
@@ -985,6 +1030,114 @@ int netxen_load_firmware(struct netxen_adapter *adapter)
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
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index f1811ca..fd13ec7 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -457,18 +457,65 @@ static const struct net_device_ops netxen_netdev_ops = {
 #endif
 };
 
-/*
- * netxen_nic_probe()
- *
- * The Linux system will invoke this after identifying the vendor ID and
- * device Id in the pci_tbl supported by this module.
- *
- * A quad port card has one operational PCI config space, (function 0),
- * which is used to access all four ports.
- *
- * This routine will initialize the adapter, and setup the global parameters
- * along with the port's specific structure.
- */
+static int
+netxen_start_firmware(struct netxen_adapter *adapter)
+{
+	int val, err, first_boot;
+	struct pci_dev *pdev = adapter->pdev;
+
+	first_boot = adapter->pci_read_normalize(adapter,
+			NETXEN_CAM_RAM(0x1fc));
+
+	err = netxen_check_hw_init(adapter, first_boot);
+	if (err) {
+		dev_err(&pdev->dev, "error in init HW init sequence\n");
+		return err;
+	}
+
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		netxen_set_port_mode(adapter);
+
+	if (first_boot != 0x55555555) {
+		adapter->pci_write_normalize(adapter,
+					CRB_CMDPEG_STATE, 0);
+		netxen_pinit_from_rom(adapter, 0);
+		msleep(1);
+	}
+	netxen_load_firmware(adapter);
+
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+
+		/* Initialize multicast addr pool owners */
+		val = 0x7654;
+		if (adapter->ahw.board_type == NETXEN_NIC_XGBE)
+			val |= 0x0f000000;
+		netxen_crb_writelit_adapter(adapter,
+				NETXEN_MAC_ADDR_CNTL_REG, val);
+
+	}
+
+	err = netxen_initialize_adapter_offload(adapter);
+	if (err)
+		return err;
+
+	/*
+	 * Tell the hardware our version number.
+	 */
+	val = (_NETXEN_NIC_LINUX_MAJOR << 16)
+		| ((_NETXEN_NIC_LINUX_MINOR << 8))
+		| (_NETXEN_NIC_LINUX_SUBVERSION);
+	adapter->pci_write_normalize(adapter, CRB_DRIVER_VERSION, val);
+
+	/* Handshake with the card before we register the devices. */
+	err = netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
+	if (err) {
+		netxen_free_adapter_offload(adapter);
+		return err;
+	}
+
+	return 0;
+}
+
 static int __devinit
 netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -484,7 +531,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	u8 __iomem *db_ptr = NULL;
 	unsigned long mem_base, mem_len, db_base, db_len = 0, pci_len0 = 0;
 	int i = 0, err;
-	int first_driver, first_boot;
+	int first_driver;
 	u32 val;
 	int pci_func_id = PCI_FUNC(pdev->devfn);
 	struct netxen_legacy_intr_set *legacy_intrp;
@@ -731,56 +778,10 @@ skip_doorbell:
 	}
 
 	if (first_driver) {
-		first_boot = adapter->pci_read_normalize(adapter,
-				NETXEN_CAM_RAM(0x1fc));
-
-		err = netxen_check_hw_init(adapter, first_boot);
-		if (err) {
-			printk(KERN_ERR "%s: error in init HW init sequence\n",
-					netxen_nic_driver_name);
-			goto err_out_iounmap;
-		}
-
-		if (NX_IS_REVISION_P3(revision_id))
-			netxen_set_port_mode(adapter);
-
-		if (first_boot != 0x55555555) {
-			adapter->pci_write_normalize(adapter,
-						CRB_CMDPEG_STATE, 0);
-			netxen_pinit_from_rom(adapter, 0);
-			msleep(1);
-		}
-		netxen_load_firmware(adapter);
-
-		if (NX_IS_REVISION_P2(revision_id)) {
-
-			/* Initialize multicast addr pool owners */
-			val = 0x7654;
-			if (adapter->ahw.board_type == NETXEN_NIC_XGBE)
-				val |= 0x0f000000;
-			netxen_crb_writelit_adapter(adapter,
-					NETXEN_MAC_ADDR_CNTL_REG, val);
-
-		}
-
-		err = netxen_initialize_adapter_offload(adapter);
+		err = netxen_start_firmware(adapter);
 		if (err)
 			goto err_out_iounmap;
-
-		/*
-		 * Tell the hardware our version number.
-		 */
-		i = (_NETXEN_NIC_LINUX_MAJOR << 16)
-			| ((_NETXEN_NIC_LINUX_MINOR << 8))
-			| (_NETXEN_NIC_LINUX_SUBVERSION);
-		adapter->pci_write_normalize(adapter, CRB_DRIVER_VERSION, i);
-
-		/* Handshake with the card before we register the devices. */
-		err = netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
-		if (err)
-			goto err_out_free_offload;
-
-	}	/* first_driver */
+	}
 
 	netxen_nic_flash_print(adapter);
 
@@ -885,14 +886,12 @@ err_out_disable_msi:
 	if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
 		pci_disable_msi(pdev);
 
-err_out_free_offload:
 	if (first_driver)
 		netxen_free_adapter_offload(adapter);
 
 err_out_iounmap:
 	if (db_ptr)
 		iounmap(db_ptr);
-
 	if (mem_ptr0)
 		iounmap(mem_ptr0);
 	if (mem_ptr1)
-- 
1.6.0.2

