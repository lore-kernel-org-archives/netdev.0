From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 3/3] netxen: fix firmware download
Date: Tue, 28 Apr 2009 18:29:11 -0700
Message-ID: <1240968551-13186-3-git-send-email-dhananjay@netxen.com>
References: <1240968551-13186-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:33180 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755990AbZD2B3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 21:29:16 -0400
In-Reply-To: <1240968551-13186-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o hold the firmware in memory across suspend, since filesystem
  may not be up after resuming.
o reset the chip after requesting firmware, to minimize downtime
  for NC-SI.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    9 ++-
 drivers/net/netxen/netxen_nic_hw.c   |  195 ---------------------------------
 drivers/net/netxen/netxen_nic_init.c |  196 ++++++++++++++++++++++++++++++++++
 drivers/net/netxen/netxen_nic_main.c |   23 +++--
 4 files changed, 216 insertions(+), 207 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 16f5e22..8dacfbb 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -42,6 +42,7 @@
 #include <linux/in.h>
 #include <linux/tcp.h>
 #include <linux/skbuff.h>
+#include <linux/firmware.h>
 
 #include <linux/ethtool.h>
 #include <linux/mii.h>
@@ -1255,8 +1256,6 @@ struct netxen_adapter {
 	u32 flags;
 	u32 irq;
 	u32 temp;
-	u32 fw_major;
-	u32 fw_version;
 
 	struct netxen_adapter_stats stats;
 
@@ -1295,6 +1294,10 @@ struct netxen_adapter {
 	struct net_device_stats net_stats;
 
 	nx_nic_intr_coalesce_t coal;
+
+	u32 fw_major;
+	u32 fw_version;
+	const struct firmware *fw;
 };
 
 /*
@@ -1376,6 +1379,8 @@ void netxen_free_adapter_offload(struct netxen_adapter *adapter);
 int netxen_initialize_adapter_offload(struct netxen_adapter *adapter);
 int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val);
 int netxen_load_firmware(struct netxen_adapter *adapter);
+void netxen_request_firmware(struct netxen_adapter *adapter);
+void netxen_release_firmware(struct netxen_adapter *adapter);
 int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose);
 
 int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp);
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index db53d9c..9f5ced3 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -32,7 +32,6 @@
 #include "netxen_nic_hw.h"
 #include "netxen_nic_phan_reg.h"
 
-#include <linux/firmware.h>
 #include <net/ip.h>
 
 #define MASK(n) ((1ULL<<(n))-1)
@@ -1016,200 +1015,6 @@ netxen_nic_pci_set_crbwindow_2M(struct netxen_adapter *adapter, ulong *off)
 		(ulong)adapter->ahw.pci_base0;
 }
 
-static int
-netxen_do_load_firmware(struct netxen_adapter *adapter, const char *fwname,
-		const struct firmware *fw)
-{
-	u64 *ptr64;
-	u32 i, flashaddr, size;
-	struct pci_dev *pdev = adapter->pdev;
-
-	if (fw)
-		dev_info(&pdev->dev, "loading firmware from file %s\n", fwname);
-	else
-		dev_info(&pdev->dev, "loading firmware from flash\n");
-
-	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
-		NXWR32(adapter, NETXEN_ROMUSB_GLB_CAS_RST, 1);
-
-	if (fw) {
-		__le64 data;
-
-		size = (NETXEN_IMAGE_START - NETXEN_BOOTLD_START) / 8;
-
-		ptr64 = (u64 *)&fw->data[NETXEN_BOOTLD_START];
-		flashaddr = NETXEN_BOOTLD_START;
-
-		for (i = 0; i < size; i++) {
-			data = cpu_to_le64(ptr64[i]);
-			adapter->pci_mem_write(adapter, flashaddr, &data, 8);
-			flashaddr += 8;
-		}
-
-		size = *(u32 *)&fw->data[NX_FW_SIZE_OFFSET];
-		size = (__force u32)cpu_to_le32(size) / 8;
-
-		ptr64 = (u64 *)&fw->data[NETXEN_IMAGE_START];
-		flashaddr = NETXEN_IMAGE_START;
-
-		for (i = 0; i < size; i++) {
-			data = cpu_to_le64(ptr64[i]);
-
-			if (adapter->pci_mem_write(adapter,
-						flashaddr, &data, 8))
-				return -EIO;
-
-			flashaddr += 8;
-		}
-	} else {
-		u32 data;
-
-		size = (NETXEN_IMAGE_START - NETXEN_BOOTLD_START) / 4;
-		flashaddr = NETXEN_BOOTLD_START;
-
-		for (i = 0; i < size; i++) {
-			if (netxen_rom_fast_read(adapter,
-					flashaddr, (int *)&data) != 0)
-				return -EIO;
-
-			if (adapter->pci_mem_write(adapter,
-						flashaddr, &data, 4))
-				return -EIO;
-
-			flashaddr += 4;
-		}
-	}
-	msleep(1);
-
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-		NXWR32(adapter, NETXEN_ROMUSB_GLB_SW_RESET, 0x80001d);
-	else {
-		NXWR32(adapter, NETXEN_ROMUSB_GLB_CHIP_CLK_CTRL, 0x3fff);
-		NXWR32(adapter, NETXEN_ROMUSB_GLB_CAS_RST, 0);
-	}
-
-	return 0;
-}
-
-static int
-netxen_validate_firmware(struct netxen_adapter *adapter, const char *fwname,
-		const struct firmware *fw)
-{
-	__le32 val;
-	u32 major, minor, build, ver, min_ver, bios;
-	struct pci_dev *pdev = adapter->pdev;
-
-	if (fw->size < NX_FW_MIN_SIZE)
-		return -EINVAL;
-
-	val = cpu_to_le32(*(u32 *)&fw->data[NX_FW_MAGIC_OFFSET]);
-	if ((__force u32)val != NETXEN_BDINFO_MAGIC)
-		return -EINVAL;
-
-	val = cpu_to_le32(*(u32 *)&fw->data[NX_FW_VERSION_OFFSET]);
-	major = (__force u32)val & 0xff;
-	minor = ((__force u32)val >> 8) & 0xff;
-	build = (__force u32)val >> 16;
-
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-		min_ver = NETXEN_VERSION_CODE(4, 0, 216);
-	else
-		min_ver = NETXEN_VERSION_CODE(3, 4, 216);
-
-	ver = NETXEN_VERSION_CODE(major, minor, build);
-
-	if ((major > _NETXEN_NIC_LINUX_MAJOR) || (ver < min_ver)) {
-		dev_err(&pdev->dev,
-				"%s: firmware version %d.%d.%d unsupported\n",
-				fwname, major, minor, build);
-		return -EINVAL;
-	}
-
-	val = cpu_to_le32(*(u32 *)&fw->data[NX_BIOS_VERSION_OFFSET]);
-	netxen_rom_fast_read(adapter, NX_BIOS_VERSION_OFFSET, (int *)&bios);
-	if ((__force u32)val != bios) {
-		dev_err(&pdev->dev, "%s: firmware bios is incompatible\n",
-				fwname);
-		return -EINVAL;
-	}
-
-	/* check if flashed firmware is newer */
-	if (netxen_rom_fast_read(adapter,
-			NX_FW_VERSION_OFFSET, (int *)&val))
-		return -EIO;
-	major = (__force u32)val & 0xff;
-	minor = ((__force u32)val >> 8) & 0xff;
-	build = (__force u32)val >> 16;
-	if (NETXEN_VERSION_CODE(major, minor, build) > ver)
-		return -EINVAL;
-
-	NXWR32(adapter, NETXEN_CAM_RAM(0x1fc), NETXEN_BDINFO_MAGIC);
-	return 0;
-}
-
-static char *fw_name[] = { "nxromimg.bin", "nx3fwct.bin", "nx3fwmn.bin" };
-
-int netxen_load_firmware(struct netxen_adapter *adapter)
-{
-	u32 capability, flashed_ver;
-	const struct firmware *fw;
-	int fw_type;
-	struct pci_dev *pdev = adapter->pdev;
-	int rc = 0;
-
-	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
-		fw_type = NX_P2_MN_ROMIMAGE;
-		goto request_fw;
-	} else {
-		fw_type = NX_P3_CT_ROMIMAGE;
-		goto request_fw;
-	}
-
-request_mn:
-	capability = 0;
-
-	netxen_rom_fast_read(adapter,
-			NX_FW_VERSION_OFFSET, (int *)&flashed_ver);
-	if (flashed_ver >= NETXEN_VERSION_CODE(4, 0, 220)) {
-		capability = NXRD32(adapter, NX_PEG_TUNE_CAPABILITY);
-		if (capability & NX_PEG_TUNE_MN_PRESENT) {
-			fw_type = NX_P3_MN_ROMIMAGE;
-			goto request_fw;
-		}
-	}
-
-request_fw:
-	rc = request_firmware(&fw, fw_name[fw_type], &pdev->dev);
-	if (rc != 0) {
-		if (fw_type == NX_P3_CT_ROMIMAGE) {
-			msleep(1);
-			goto request_mn;
-		}
-
-		fw = NULL;
-		goto load_fw;
-	}
-
-	rc = netxen_validate_firmware(adapter, fw_name[fw_type], fw);
-	if (rc != 0) {
-		release_firmware(fw);
-
-		if (fw_type == NX_P3_CT_ROMIMAGE) {
-			msleep(1);
-			goto request_mn;
-		}
-
-		fw = NULL;
-	}
-
-load_fw:
-	rc = netxen_do_load_firmware(adapter, fw_name[fw_type], fw);
-
-	if (fw)
-		release_firmware(fw);
-	return rc;
-}
-
 int
 netxen_nic_hw_write_wx_128M(struct netxen_adapter *adapter, ulong off, u32 data)
 {
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 363ef70..d182167 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -683,6 +683,202 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 	return 0;
 }
 
+int
+netxen_load_firmware(struct netxen_adapter *adapter)
+{
+	u64 *ptr64;
+	u32 i, flashaddr, size;
+	const struct firmware *fw = adapter->fw;
+
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
+		NXWR32(adapter, NETXEN_ROMUSB_GLB_CAS_RST, 1);
+
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
+
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
+	}
+	msleep(1);
+
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		NXWR32(adapter, NETXEN_ROMUSB_GLB_SW_RESET, 0x80001d);
+	else {
+		NXWR32(adapter, NETXEN_ROMUSB_GLB_CHIP_CLK_CTRL, 0x3fff);
+		NXWR32(adapter, NETXEN_ROMUSB_GLB_CAS_RST, 0);
+	}
+
+	return 0;
+}
+
+static int
+netxen_validate_firmware(struct netxen_adapter *adapter, const char *fwname)
+{
+	__le32 val;
+	u32 major, minor, build, ver, min_ver, bios;
+	struct pci_dev *pdev = adapter->pdev;
+	const struct firmware *fw = adapter->fw;
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
+	/* check if flashed firmware is newer */
+	if (netxen_rom_fast_read(adapter,
+			NX_FW_VERSION_OFFSET, (int *)&val))
+		return -EIO;
+	major = (__force u32)val & 0xff;
+	minor = ((__force u32)val >> 8) & 0xff;
+	build = (__force u32)val >> 16;
+	if (NETXEN_VERSION_CODE(major, minor, build) > ver)
+		return -EINVAL;
+
+	NXWR32(adapter, NETXEN_CAM_RAM(0x1fc), NETXEN_BDINFO_MAGIC);
+	return 0;
+}
+
+static char *fw_name[] = { "nxromimg.bin", "nx3fwct.bin", "nx3fwmn.bin" };
+
+void netxen_request_firmware(struct netxen_adapter *adapter)
+{
+	u32 capability, flashed_ver;
+	int fw_type;
+	struct pci_dev *pdev = adapter->pdev;
+	int rc = 0;
+
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+		fw_type = NX_P2_MN_ROMIMAGE;
+		goto request_fw;
+	} else {
+		fw_type = NX_P3_CT_ROMIMAGE;
+		goto request_fw;
+	}
+
+request_mn:
+	capability = 0;
+
+	netxen_rom_fast_read(adapter,
+			NX_FW_VERSION_OFFSET, (int *)&flashed_ver);
+	if (flashed_ver >= NETXEN_VERSION_CODE(4, 0, 220)) {
+		capability = NXRD32(adapter, NX_PEG_TUNE_CAPABILITY);
+		if (capability & NX_PEG_TUNE_MN_PRESENT) {
+			fw_type = NX_P3_MN_ROMIMAGE;
+			goto request_fw;
+		}
+	}
+
+request_fw:
+	rc = request_firmware(&adapter->fw, fw_name[fw_type], &pdev->dev);
+	if (rc != 0) {
+		if (fw_type == NX_P3_CT_ROMIMAGE) {
+			msleep(1);
+			goto request_mn;
+		}
+
+		adapter->fw = NULL;
+		goto done;
+	}
+
+	rc = netxen_validate_firmware(adapter, fw_name[fw_type]);
+	if (rc != 0) {
+		release_firmware(adapter->fw);
+
+		if (fw_type == NX_P3_CT_ROMIMAGE) {
+			msleep(1);
+			goto request_mn;
+		}
+
+		adapter->fw = NULL;
+		goto done;
+	}
+
+done:
+	if (adapter->fw)
+		dev_info(&pdev->dev, "loading firmware from file %s\n",
+				fw_name[fw_type]);
+	else
+		dev_info(&pdev->dev, "loading firmware from flash\n");
+}
+
+
+void
+netxen_release_firmware(struct netxen_adapter *adapter)
+{
+	if (adapter->fw)
+		release_firmware(adapter->fw);
+}
+
 int netxen_initialize_adapter_offload(struct netxen_adapter *adapter)
 {
 	uint64_t addr;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 07959fe..5d79c19 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -654,19 +654,17 @@ err_out:
 }
 
 static int
-netxen_start_firmware(struct netxen_adapter *adapter)
+netxen_start_firmware(struct netxen_adapter *adapter, int request_fw)
 {
 	int val, err, first_boot;
 	struct pci_dev *pdev = adapter->pdev;
 
 	int first_driver = 0;
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
-		if (adapter->ahw.pci_func == 0)
-			first_driver = 1;
-	} else {
-		if (adapter->portnum == 0)
-			first_driver = 1;
-	}
+
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
+		first_driver = (adapter->portnum == 0);
+	else
+		first_driver = (adapter->ahw.pci_func == 0);
 
 	if (!first_driver)
 		return 0;
@@ -679,6 +677,9 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 		return err;
 	}
 
+	if (request_fw)
+		netxen_request_firmware(adapter);
+
 	if (first_boot != 0x55555555) {
 		NXWR32(adapter, CRB_CMDPEG_STATE, 0);
 		netxen_pinit_from_rom(adapter, 0);
@@ -1014,7 +1015,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		break;
 	}
 
-	err = netxen_start_firmware(adapter);
+	err = netxen_start_firmware(adapter, 1);
 	if (err)
 		goto err_out_iounmap;
 
@@ -1125,6 +1126,8 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 	netxen_cleanup_pci_map(adapter);
 
+	netxen_release_firmware(adapter);
+
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
@@ -1176,7 +1179,7 @@ netxen_nic_resume(struct pci_dev *pdev)
 
 	adapter->curr_window = 255;
 
-	err = netxen_start_firmware(adapter);
+	err = netxen_start_firmware(adapter, 0);
 	if (err) {
 		dev_err(&pdev->dev, "failed to start firmware\n");
 		return err;
-- 
1.6.0.2

