From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 1/3] qlcnic: fix flash fw version read
Date: Mon, 10 Jan 2011 02:15:21 -0800
Message-ID: <1294654523-3085-2-git-send-email-amit.salecha@qlogic.com>
References: <1294654523-3085-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:47321 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753412Ab1AJKPl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 05:15:41 -0500
In-Reply-To: <1294654523-3085-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver is reading flash fw version from defined address, this address
may be invalid. Indeed Driver should read address for fw version through
flash layout table. Flash layout table has defined region and address for
fw version address should be read from fw image region.

Driver has check for old firmware, this bug can cause driver load fail.
This patch will try to read fw version from flash image region, if that fails,
read from defined address.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |   20 ++++++++++++
 drivers/net/qlcnic/qlcnic_init.c |   63 +++++++++++++++++++++++++++++++++++++-
 2 files changed, 82 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 9c2a02d..14b6322 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -289,6 +289,26 @@ struct uni_data_desc{
 	u32	reserved[5];
 };
 
+/* Flash Defines and Structures */
+#define QLCNIC_FLT_LOCATION	0x3F1000
+#define QLCNIC_FW_IMAGE_REGION	0x74
+struct qlcnic_flt_header {
+	u16 version;
+	u16 len;
+	u16 checksum;
+	u16 reserved;
+};
+
+struct qlcnic_flt_entry {
+	u8 region;
+	u8 reserved0;
+	u8 attrib;
+	u8 reserved1;
+	u32 size;
+	u32 start_addr;
+	u32 end_add;
+};
+
 /* Magic number to let user know flash is programmed */
 #define	QLCNIC_BDINFO_MAGIC 0x12345678
 
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 9b9c7c3..a7f1d5b 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -627,12 +627,73 @@ qlcnic_setup_idc_param(struct qlcnic_adapter *adapter) {
 	return 0;
 }
 
+static int qlcnic_get_flt_entry(struct qlcnic_adapter *adapter, u8 region,
+				struct qlcnic_flt_entry *region_entry)
+{
+	struct qlcnic_flt_header flt_hdr;
+	struct qlcnic_flt_entry *flt_entry;
+	int i = 0, ret;
+	u32 entry_size;
+
+	memset(region_entry, 0, sizeof(struct qlcnic_flt_entry));
+	ret = qlcnic_rom_fast_read_words(adapter, QLCNIC_FLT_LOCATION,
+					 (u8 *)&flt_hdr,
+					 sizeof(struct qlcnic_flt_header));
+	if (ret) {
+		dev_warn(&adapter->pdev->dev,
+			 "error reading flash layout header\n");
+		return -EIO;
+	}
+
+	entry_size = flt_hdr.len - sizeof(struct qlcnic_flt_header);
+	flt_entry = (struct qlcnic_flt_entry *)vzalloc(entry_size);
+	if (flt_entry == NULL) {
+		dev_warn(&adapter->pdev->dev, "error allocating memory\n");
+		return -EIO;
+	}
+
+	ret = qlcnic_rom_fast_read_words(adapter, QLCNIC_FLT_LOCATION +
+					 sizeof(struct qlcnic_flt_header),
+					 (u8 *)flt_entry, entry_size);
+	if (ret) {
+		dev_warn(&adapter->pdev->dev,
+			 "error reading flash layout entries\n");
+		goto err_out;
+	}
+
+	while (i < (entry_size/sizeof(struct qlcnic_flt_entry))) {
+		if (flt_entry[i].region == region)
+			break;
+		i++;
+	}
+	if (i >= (entry_size/sizeof(struct qlcnic_flt_entry))) {
+		dev_warn(&adapter->pdev->dev,
+			 "region=%x not found in %d regions\n", region, i);
+		ret = -EIO;
+		goto err_out;
+	}
+	memcpy(region_entry, &flt_entry[i], sizeof(struct qlcnic_flt_entry));
+
+err_out:
+	vfree(flt_entry);
+	return ret;
+}
+
 int
 qlcnic_check_flash_fw_ver(struct qlcnic_adapter *adapter)
 {
+	struct qlcnic_flt_entry fw_entry;
 	u32 ver = -1, min_ver;
+	int ret;
 
-	qlcnic_rom_fast_read(adapter, QLCNIC_FW_VERSION_OFFSET, (int *)&ver);
+	ret = qlcnic_get_flt_entry(adapter, QLCNIC_FW_IMAGE_REGION, &fw_entry);
+	if (!ret)
+		/* 0-4:-signature,  4-8:-fw version */
+		qlcnic_rom_fast_read(adapter, fw_entry.start_addr + 4,
+				     (int *)&ver);
+	else
+		qlcnic_rom_fast_read(adapter, QLCNIC_FW_VERSION_OFFSET,
+				     (int *)&ver);
 
 	ver = QLCNIC_DECODE_VERSION(ver);
 	min_ver = QLCNIC_MIN_FW_VERSION;
-- 
1.7.3.2

