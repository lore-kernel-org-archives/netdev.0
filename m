From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 05/13] liquidio: Firmware image download
Date: Tue, 21 Jun 2016 22:53:07 -0700
Message-ID: <1466574795-4306-6-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0077.outbound.protection.outlook.com ([65.55.169.77]:53336
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751347AbcFVFzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 01:55:20 -0400
In-Reply-To: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch has firmware image related changes for: firmware
release upon failure, support latest firmware version and
firmware download in 4MB chunks.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 18 ++++-
 .../net/ethernet/cavium/liquidio/liquidio_common.h | 10 +--
 .../net/ethernet/cavium/liquidio/octeon_device.c   | 79 ++++++++++++----------
 3 files changed, 65 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 8310eb8..5fb1b79 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1375,6 +1375,7 @@ static int octeon_chip_specific_setup(struct octeon_device *oct)
 {
 	u32 dev_id, rev_id;
 	int ret = 1;
+	char *s;
 
 	pci_read_config_dword(oct->pci_dev, 0, &dev_id);
 	pci_read_config_dword(oct->pci_dev, 8, &rev_id);
@@ -1384,22 +1385,27 @@ static int octeon_chip_specific_setup(struct octeon_device *oct)
 	case OCTEON_CN68XX_PCIID:
 		oct->chip_id = OCTEON_CN68XX;
 		ret = lio_setup_cn68xx_octeon_device(oct);
+		s = "CN68XX";
 		break;
 
 	case OCTEON_CN66XX_PCIID:
 		oct->chip_id = OCTEON_CN66XX;
 		ret = lio_setup_cn66xx_octeon_device(oct);
+		s = "CN66XX";
 		break;
+
 	default:
+		s = "?";
 		dev_err(&oct->pci_dev->dev, "Unknown device found (dev_id: %x)\n",
 			dev_id);
 	}
 
 	if (!ret)
-		dev_info(&oct->pci_dev->dev, "CN68XX PASS%d.%d %s\n",
+		dev_info(&oct->pci_dev->dev, "%s PASS%d.%d %s Version: %s\n", s,
 			 OCTEON_MAJOR_REV(oct),
 			 OCTEON_MINOR_REV(oct),
-			 octeon_get_conf(oct)->card_name);
+			 octeon_get_conf(oct)->card_name,
+			 LIQUIDIO_VERSION);
 
 	return ret;
 }
@@ -1772,6 +1778,7 @@ static int load_firmware(struct octeon_device *oct)
 	if (ret) {
 		dev_err(&oct->pci_dev->dev, "Request firmware failed. Could not find file %s.\n.",
 			fw_name);
+		release_firmware(fw);
 		return ret;
 	}
 
@@ -1841,6 +1848,9 @@ static void if_cfg_callback(struct octeon_device *oct,
 			CVM_CAST64(resp->status));
 	ACCESS_ONCE(ctx->cond) = 1;
 
+	snprintf(oct->fw_info.liquidio_firmware_version, 32, "%s",
+		 resp->cfg_info.liquidio_firmware_version);
+
 	/* This barrier is required to be sure that the response has been
 	 * written fully before waking up the handler
 	 */
@@ -3635,6 +3645,7 @@ static void nic_starter(struct work_struct *work)
 static int octeon_device_init(struct octeon_device *octeon_dev)
 {
 	int j, ret;
+	char bootcmd[] = "\n";
 	struct octeon_device_priv *oct_priv =
 		(struct octeon_device_priv *)octeon_dev->priv;
 	atomic_set(&octeon_dev->status, OCT_DEV_BEGIN_STATE);
@@ -3767,6 +3778,9 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 		return 1;
 	}
 
+	/* Divert uboot to take commands from host instead. */
+	ret = octeon_console_send_cmd(octeon_dev, bootcmd, 50);
+
 	dev_dbg(&octeon_dev->pci_dev->dev, "Initializing consoles\n");
 	ret = octeon_init_consoles(octeon_dev);
 	if (ret) {
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 3738877..1ef9001 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -30,11 +30,10 @@
 
 #include "octeon_config.h"
 
-#define LIQUIDIO_VERSION        "1.1.9"
-#define LIQUIDIO_MAJOR_VERSION  1
-#define LIQUIDIO_MINOR_VERSION  1
-#define LIQUIDIO_MICRO_VERSION  9
-
+#define LIQUIDIO_BASE_VERSION   "1.4"
+#define LIQUIDIO_MICRO_VERSION  ".1"
+#define LIQUIDIO_PACKAGE ""
+#define LIQUIDIO_VERSION  "1.4.1"
 #define CONTROL_IQ 0
 /** Tag types used by Octeon cores in its work. */
 enum octeon_tag_type {
@@ -712,6 +711,7 @@ struct liquidio_if_cfg_info {
 	u64 iqmask; /** mask for IQs enabled for  the port */
 	u64 oqmask; /** mask for OQs enabled for the port */
 	struct oct_link_info linfo; /** initial link information */
+	char   liquidio_firmware_version[32];
 };
 
 /** Stats for each NIC port in RX direction. */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index e1ca617..bc4d6af 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -549,17 +549,19 @@ static char *get_oct_app_string(u32 app_mode)
 	return oct_dev_app_str[CVM_DRV_INVALID_APP - CVM_DRV_APP_START];
 }
 
+u8 fbuf[4 * 1024 * 1024];
+
 int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 			     size_t size)
 {
 	int ret = 0;
-	u8 *p;
-	u8 *buffer;
+	u8 *p = fbuf;
 	u32 crc32_result;
 	u64 load_addr;
 	u32 image_len;
 	struct octeon_firmware_file_header *h;
-	u32 i;
+	u32 i, rem, base_len = strlen(LIQUIDIO_BASE_VERSION);
+	char *base;
 
 	if (size < sizeof(struct octeon_firmware_file_header)) {
 		dev_err(&oct->pci_dev->dev, "Firmware file too small (%d < %d).\n",
@@ -575,19 +577,26 @@ int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 		return -EINVAL;
 	}
 
-	crc32_result =
-		crc32(~0, data,
-		      sizeof(struct octeon_firmware_file_header) -
-		      sizeof(u32)) ^ ~0U;
+	crc32_result = crc32((unsigned int)~0, data,
+			     sizeof(struct octeon_firmware_file_header) -
+			     sizeof(u32)) ^ ~0U;
 	if (crc32_result != be32_to_cpu(h->crc32)) {
 		dev_err(&oct->pci_dev->dev, "Firmware CRC mismatch (0x%08x != 0x%08x).\n",
 			crc32_result, be32_to_cpu(h->crc32));
 		return -EINVAL;
 	}
 
-	if (memcmp(LIQUIDIO_VERSION, h->version, strlen(LIQUIDIO_VERSION))) {
-		dev_err(&oct->pci_dev->dev, "Unmatched firmware version. Expected %s, got %s.\n",
-			LIQUIDIO_VERSION, h->version);
+	if (strncmp(LIQUIDIO_PACKAGE, h->version, strlen(LIQUIDIO_PACKAGE))) {
+		dev_err(&oct->pci_dev->dev, "Unmatched firmware package type. Expected %s, got %s.\n",
+			LIQUIDIO_PACKAGE, h->version);
+		return -EINVAL;
+	}
+
+	base = h->version + strlen(LIQUIDIO_PACKAGE);
+	ret = memcmp(LIQUIDIO_BASE_VERSION, base, base_len);
+	if (ret) {
+		dev_err(&oct->pci_dev->dev, "Unmatched firmware version. Expected %s.x, got %s.\n",
+			LIQUIDIO_BASE_VERSION, base);
 		return -EINVAL;
 	}
 
@@ -601,44 +610,44 @@ int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 	snprintf(oct->fw_info.liquidio_firmware_version, 32, "LIQUIDIO: %s",
 		 h->version);
 
-	buffer = kmemdup(data, size, GFP_KERNEL);
-	if (!buffer)
-		return -ENOMEM;
-
-	p = buffer + sizeof(struct octeon_firmware_file_header);
+	data += sizeof(struct octeon_firmware_file_header);
 
+	dev_info(&oct->pci_dev->dev, "%s: Loading %d images\n", __func__,
+		 be32_to_cpu(h->num_images));
 	/* load all images */
 	for (i = 0; i < be32_to_cpu(h->num_images); i++) {
 		load_addr = be64_to_cpu(h->desc[i].addr);
 		image_len = be32_to_cpu(h->desc[i].len);
 
-		/* validate the image */
-		crc32_result = crc32(~0, p, image_len) ^ ~0U;
-		if (crc32_result != be32_to_cpu(h->desc[i].crc32)) {
-			dev_err(&oct->pci_dev->dev,
-				"Firmware CRC mismatch in image %d (0x%08x != 0x%08x).\n",
-				i, crc32_result,
-				be32_to_cpu(h->desc[i].crc32));
-			ret = -EINVAL;
-			goto done_downloading;
-		}
+		dev_info(&oct->pci_dev->dev, "Loading firmware %d at %llx\n",
+			 image_len, load_addr);
 
-		/* download the image */
-		octeon_pci_write_core_mem(oct, load_addr, p, image_len);
+		/* Write in 4MB chunks*/
+		rem = image_len;
 
-		p += image_len;
-		dev_dbg(&oct->pci_dev->dev,
-			"Downloaded image %d (%d bytes) to address 0x%016llx\n",
-			i, image_len, load_addr);
+		while (rem) {
+			if (rem < (4 * 1024 * 1024))
+				size = rem;
+			else
+				size = 4 * 1024 * 1024;
+
+			memcpy(p, data, size);
+
+			/* download the image */
+			octeon_pci_write_core_mem(oct, load_addr, p, (u32)size);
+
+			data += size;
+			rem -= (u32)size;
+			load_addr += size;
+		}
 	}
+	dev_info(&oct->pci_dev->dev, "Writing boot command: %s\n",
+		 h->bootcmd);
 
 	/* Invoke the bootcmd */
 	ret = octeon_console_send_cmd(oct, h->bootcmd, 50);
 
-done_downloading:
-	kfree(buffer);
-
-	return ret;
+	return 0;
 }
 
 void octeon_free_device_mem(struct octeon_device *oct)
-- 
1.8.3.1
