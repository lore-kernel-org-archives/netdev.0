From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 04/10] bnxt_en: Added support for Secure Firmware Update
Date: Mon, 19 Sep 2016 03:58:03 -0400
Message-ID: <1474271889-8229-5-git-send-email-michael.chan@broadcom.com>
References: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36268 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754116AbcISH62 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 03:58:28 -0400
Received: by mail-pf0-f177.google.com with SMTP id q2so28220995pfj.3
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 00:58:28 -0700 (PDT)
In-Reply-To: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Swindell <Rob.Swindell@broadcom.com>

Using Ethtool flashdev command, entire NVM package (*.pkg) files
may now be staged into the "update" area of the NVM and subsequently
verified and installed by the firmware using the newly introduced
command: NVM_INSTALL_UPDATE.

We also introduce use of the new firmware command FW_SET_TIME so that the
NVM-resident package installation log contains valid time-stamps.

Signed-off-by: Rob Swindell <Rob.Swindell@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  24 ++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |   1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 155 ++++++++++++++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h  |  16 ++-
 4 files changed, 182 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index f6b4f34..f0a9d23 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -32,6 +32,7 @@
 #include <linux/mii.h>
 #include <linux/if.h>
 #include <linux/if_vlan.h>
+#include <linux/rtc.h>
 #include <net/ip.h>
 #include <net/tcp.h>
 #include <net/udp.h>
@@ -4314,6 +4315,27 @@ hwrm_ver_get_exit:
 	return rc;
 }
 
+int bnxt_hwrm_fw_set_time(struct bnxt *bp)
+{
+	struct hwrm_fw_set_time_input req = {0};
+	struct rtc_time tm;
+	struct timeval tv;
+
+	if (bp->hwrm_spec_code < 0x10400)
+		return -EOPNOTSUPP;
+
+	do_gettimeofday(&tv);
+	rtc_time_to_tm(tv.tv_sec, &tm);
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FW_SET_TIME, -1, -1);
+	req.year = cpu_to_le16(1900 + tm.tm_year);
+	req.month = 1 + tm.tm_mon;
+	req.day = tm.tm_mday;
+	req.hour = tm.tm_hour;
+	req.minute = tm.tm_min;
+	req.second = tm.tm_sec;
+	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+}
+
 static int bnxt_hwrm_port_qstats(struct bnxt *bp)
 {
 	int rc;
@@ -6811,6 +6833,8 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rc)
 		goto init_err;
 
+	bnxt_hwrm_fw_set_time(bp);
+
 	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
 			   NETIF_F_TSO | NETIF_F_TSO6 |
 			   NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_GRE |
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 012cc51..41033d0 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1220,6 +1220,7 @@ int bnxt_hwrm_set_coal(struct bnxt *);
 int bnxt_hwrm_func_qcaps(struct bnxt *);
 int bnxt_hwrm_set_pause(struct bnxt *);
 int bnxt_hwrm_set_link_setting(struct bnxt *, bool, bool);
+int bnxt_hwrm_fw_set_time(struct bnxt *);
 int bnxt_open_nic(struct bnxt *, bool, bool);
 int bnxt_close_nic(struct bnxt *, bool, bool);
 int bnxt_get_max_rings(struct bnxt *, int *, int *, bool);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index b83e174..4a430b6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -21,6 +21,8 @@
 #include "bnxt_nvm_defs.h"	/* NVRAM content constant and structure defs */
 #include "bnxt_fw_hdr.h"	/* Firmware hdr constant and structure defs */
 #define FLASH_NVRAM_TIMEOUT	((HWRM_CMD_TIMEOUT) * 100)
+#define FLASH_PACKAGE_TIMEOUT	((HWRM_CMD_TIMEOUT) * 200)
+#define INSTALL_PACKAGE_TIMEOUT	((HWRM_CMD_TIMEOUT) * 200)
 
 static char *bnxt_get_pkgver(struct net_device *dev, char *buf, size_t buflen);
 
@@ -1028,6 +1030,10 @@ static u32 bnxt_get_link(struct net_device *dev)
 	return bp->link_info.link_up;
 }
 
+static int bnxt_find_nvram_item(struct net_device *dev, u16 type, u16 ordinal,
+				u16 ext, u16 *index, u32 *item_length,
+				u32 *data_length);
+
 static int bnxt_flash_nvram(struct net_device *dev,
 			    u16 dir_type,
 			    u16 dir_ordinal,
@@ -1179,7 +1185,6 @@ static int bnxt_flash_firmware(struct net_device *dev,
 			   (unsigned long)calculated_crc);
 		return -EINVAL;
 	}
-	/* TODO: Validate digital signature (RSA-encrypted SHA-256 hash) here */
 	rc = bnxt_flash_nvram(dev, dir_type, BNX_DIR_ORDINAL_FIRST,
 			      0, 0, fw_data, fw_size);
 	if (rc == 0)	/* Firmware update successful */
@@ -1188,6 +1193,57 @@ static int bnxt_flash_firmware(struct net_device *dev,
 	return rc;
 }
 
+static int bnxt_flash_microcode(struct net_device *dev,
+				u16 dir_type,
+				const u8 *fw_data,
+				size_t fw_size)
+{
+	struct bnxt_ucode_trailer *trailer;
+	u32 calculated_crc;
+	u32 stored_crc;
+	int rc = 0;
+
+	if (fw_size < sizeof(struct bnxt_ucode_trailer)) {
+		netdev_err(dev, "Invalid microcode file size: %u\n",
+			   (unsigned int)fw_size);
+		return -EINVAL;
+	}
+	trailer = (struct bnxt_ucode_trailer *)(fw_data + (fw_size -
+						sizeof(*trailer)));
+	if (trailer->sig != cpu_to_le32(BNXT_UCODE_TRAILER_SIGNATURE)) {
+		netdev_err(dev, "Invalid microcode trailer signature: %08X\n",
+			   le32_to_cpu(trailer->sig));
+		return -EINVAL;
+	}
+	if (le16_to_cpu(trailer->dir_type) != dir_type) {
+		netdev_err(dev, "Expected microcode type: %d, read: %d\n",
+			   dir_type, le16_to_cpu(trailer->dir_type));
+		return -EINVAL;
+	}
+	if (le16_to_cpu(trailer->trailer_length) <
+		sizeof(struct bnxt_ucode_trailer)) {
+		netdev_err(dev, "Invalid microcode trailer length: %d\n",
+			   le16_to_cpu(trailer->trailer_length));
+		return -EINVAL;
+	}
+
+	/* Confirm the CRC32 checksum of the file: */
+	stored_crc = le32_to_cpu(*(__le32 *)(fw_data + fw_size -
+					     sizeof(stored_crc)));
+	calculated_crc = ~crc32(~0, fw_data, fw_size - sizeof(stored_crc));
+	if (calculated_crc != stored_crc) {
+		netdev_err(dev,
+			   "CRC32 (%08lX) does not match calculated: %08lX\n",
+			   (unsigned long)stored_crc,
+			   (unsigned long)calculated_crc);
+		return -EINVAL;
+	}
+	rc = bnxt_flash_nvram(dev, dir_type, BNX_DIR_ORDINAL_FIRST,
+			      0, 0, fw_data, fw_size);
+
+	return rc;
+}
+
 static bool bnxt_dir_type_is_ape_bin_format(u16 dir_type)
 {
 	switch (dir_type) {
@@ -1206,7 +1262,7 @@ static bool bnxt_dir_type_is_ape_bin_format(u16 dir_type)
 	return false;
 }
 
-static bool bnxt_dir_type_is_unprotected_exec_format(u16 dir_type)
+static bool bnxt_dir_type_is_other_exec_format(u16 dir_type)
 {
 	switch (dir_type) {
 	case BNX_DIR_TYPE_AVS:
@@ -1227,7 +1283,7 @@ static bool bnxt_dir_type_is_unprotected_exec_format(u16 dir_type)
 static bool bnxt_dir_type_is_executable(u16 dir_type)
 {
 	return bnxt_dir_type_is_ape_bin_format(dir_type) ||
-		bnxt_dir_type_is_unprotected_exec_format(dir_type);
+		bnxt_dir_type_is_other_exec_format(dir_type);
 }
 
 static int bnxt_flash_firmware_from_file(struct net_device *dev,
@@ -1237,10 +1293,6 @@ static int bnxt_flash_firmware_from_file(struct net_device *dev,
 	const struct firmware  *fw;
 	int			rc;
 
-	if (dir_type != BNX_DIR_TYPE_UPDATE &&
-	    bnxt_dir_type_is_executable(dir_type) == false)
-		return -EINVAL;
-
 	rc = request_firmware(&fw, filename, &dev->dev);
 	if (rc != 0) {
 		netdev_err(dev, "Error %d requesting firmware file: %s\n",
@@ -1249,6 +1301,8 @@ static int bnxt_flash_firmware_from_file(struct net_device *dev,
 	}
 	if (bnxt_dir_type_is_ape_bin_format(dir_type) == true)
 		rc = bnxt_flash_firmware(dev, dir_type, fw->data, fw->size);
+	else if (bnxt_dir_type_is_other_exec_format(dir_type) == true)
+		rc = bnxt_flash_microcode(dev, dir_type, fw->data, fw->size);
 	else
 		rc = bnxt_flash_nvram(dev, dir_type, BNX_DIR_ORDINAL_FIRST,
 				      0, 0, fw->data, fw->size);
@@ -1257,10 +1311,83 @@ static int bnxt_flash_firmware_from_file(struct net_device *dev,
 }
 
 static int bnxt_flash_package_from_file(struct net_device *dev,
-					char *filename)
+					char *filename, u32 install_type)
 {
-	netdev_err(dev, "packages are not yet supported\n");
-	return -EINVAL;
+	struct bnxt *bp = netdev_priv(dev);
+	struct hwrm_nvm_install_update_output *resp = bp->hwrm_cmd_resp_addr;
+	struct hwrm_nvm_install_update_input install = {0};
+	const struct firmware *fw;
+	u32 item_len;
+	u16 index;
+	int rc;
+
+	bnxt_hwrm_fw_set_time(bp);
+
+	if (bnxt_find_nvram_item(dev, BNX_DIR_TYPE_UPDATE,
+				 BNX_DIR_ORDINAL_FIRST, BNX_DIR_EXT_NONE,
+				 &index, &item_len, NULL) != 0) {
+		netdev_err(dev, "PKG update area not created in nvram\n");
+		return -ENOBUFS;
+	}
+
+	rc = request_firmware(&fw, filename, &dev->dev);
+	if (rc != 0) {
+		netdev_err(dev, "PKG error %d requesting file: %s\n",
+			   rc, filename);
+		return rc;
+	}
+
+	if (fw->size > item_len) {
+		netdev_err(dev, "PKG insufficient update area in nvram: %lu",
+			   (unsigned long)fw->size);
+		rc = -EFBIG;
+	} else {
+		dma_addr_t dma_handle;
+		u8 *kmem;
+		struct hwrm_nvm_modify_input modify = {0};
+
+		bnxt_hwrm_cmd_hdr_init(bp, &modify, HWRM_NVM_MODIFY, -1, -1);
+
+		modify.dir_idx = cpu_to_le16(index);
+		modify.len = cpu_to_le32(fw->size);
+
+		kmem = dma_alloc_coherent(&bp->pdev->dev, fw->size,
+					  &dma_handle, GFP_KERNEL);
+		if (!kmem) {
+			netdev_err(dev,
+				   "dma_alloc_coherent failure, length = %u\n",
+				   (unsigned int)fw->size);
+			rc = -ENOMEM;
+		} else {
+			memcpy(kmem, fw->data, fw->size);
+			modify.host_src_addr = cpu_to_le64(dma_handle);
+
+			rc = hwrm_send_message(bp, &modify, sizeof(modify),
+					       FLASH_PACKAGE_TIMEOUT);
+			dma_free_coherent(&bp->pdev->dev, fw->size, kmem,
+					  dma_handle);
+		}
+	}
+	release_firmware(fw);
+	if (rc)
+		return rc;
+
+	if ((install_type & 0xffff) == 0)
+		install_type >>= 16;
+	bnxt_hwrm_cmd_hdr_init(bp, &install, HWRM_NVM_INSTALL_UPDATE, -1, -1);
+	install.install_type = cpu_to_le32(install_type);
+
+	rc = hwrm_send_message(bp, &install, sizeof(install),
+			       INSTALL_PACKAGE_TIMEOUT);
+	if (rc)
+		return -EOPNOTSUPP;
+
+	if (resp->result) {
+		netdev_err(dev, "PKG install error = %d, problem_item = %d\n",
+			   (s8)resp->result, (int)resp->problem_item);
+		return -ENOPKG;
+	}
+	return 0;
 }
 
 static int bnxt_flash_device(struct net_device *dev,
@@ -1271,8 +1398,10 @@ static int bnxt_flash_device(struct net_device *dev,
 		return -EINVAL;
 	}
 
-	if (flash->region == ETHTOOL_FLASH_ALL_REGIONS)
-		return bnxt_flash_package_from_file(dev, flash->data);
+	if (flash->region == ETHTOOL_FLASH_ALL_REGIONS ||
+	    flash->region > 0xffff)
+		return bnxt_flash_package_from_file(dev, flash->data,
+						    flash->region);
 
 	return bnxt_flash_firmware_from_file(dev, flash->region, flash->data);
 }
@@ -1516,7 +1645,7 @@ static int bnxt_set_eeprom(struct net_device *dev,
 
 	/* Create or re-write an NVM item: */
 	if (bnxt_dir_type_is_executable(type) == true)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 	ext = eeprom->magic & 0xffff;
 	ordinal = eeprom->offset >> 16;
 	attr = eeprom->offset & 0xffff;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h
index 82bf44a..cad30dd 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h
@@ -11,6 +11,7 @@
 #define __BNXT_FW_HDR_H__
 
 #define BNXT_FIRMWARE_BIN_SIGNATURE     0x1a4d4342	/* "BCM"+0x1a */
+#define BNXT_UCODE_TRAILER_SIGNATURE	0x726c7254	/* "Trlr" */
 
 enum SUPPORTED_FAMILY {
 	DEVICE_5702_3_4_FAMILY,		/* 0  - Denali, Vinson, K2 */
@@ -85,7 +86,7 @@ enum SUPPORTED_MEDIA {
 
 struct bnxt_fw_header {
 	__le32 signature;	/* constains the constant value of
-				 * BNXT_Firmware_Bin_Signatures
+				 * BNXT_FIRMWARE_BIN_SIGNATURE
 				 */
 	u8 flags;		/* reserved for ChiMP use */
 	u8 code_type;		/* enum SUPPORTED_CODE */
@@ -102,4 +103,17 @@ struct bnxt_fw_header {
 	u8 major_ver;
 };
 
+/* Microcode and pre-boot software/firmware trailer: */
+struct bnxt_ucode_trailer {
+	u8 rsa_sig[256];
+	__le16 flags;
+	u8 version_format;
+	u8 version_length;
+	u8 version[16];
+	__le16 dir_type;
+	__le16 trailer_length;
+	__le32 sig;		/* BNXT_UCODE_TRAILER_SIGNATURE */
+	__le32 chksum;		/* CRC-32 */
+};
+
 #endif
-- 
1.8.3.1
