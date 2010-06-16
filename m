From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 1/9] cxgb4: dynamically determine flash size and FW image location
Date: Wed, 16 Jun 2010 15:01:08 -0700
Message-ID: <1276725676-31514-2-git-send-email-dm@chelsio.com>
References: <1276725676-31514-1-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:13797 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759306Ab0FPWBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 18:01:17 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5GM1HI2032112
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 15:01:17 -0700
In-Reply-To: <1276725676-31514-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle the larger flash memories on newer boards:

- get the size and number of sectors by probing the flash
- writes and erases can take longer, adjust the timeouts for these operations
- the FW image can be at different locations depending on flash size,
  find its location dynamically as well.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4.h   |    4 ++
 drivers/net/cxgb4/t4_hw.c   |   75 +++++++++++++++++++++++++++++++------------
 drivers/net/cxgb4/t4_hw.h   |    2 -
 drivers/net/cxgb4/t4_regs.h |    3 ++
 4 files changed, 61 insertions(+), 23 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index dd1770e..bfa1366 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -219,6 +219,10 @@ struct adapter_params {
 	struct vpd_params vpd;
 	struct pci_params pci;
 
+	unsigned int sf_size;             /* serial flash size in bytes */
+	unsigned int sf_nsec;             /* # of flash sectors */
+	unsigned int sf_fw_start;         /* start of FW image in flash */
+
 	unsigned int fw_vers;
 	unsigned int tp_vers;
 	u8 api_vers[7];
diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/cxgb4/t4_hw.c
index da272a9..5c81c55 100644
--- a/drivers/net/cxgb4/t4_hw.c
+++ b/drivers/net/cxgb4/t4_hw.c
@@ -449,12 +449,10 @@ enum {
 	SF_RD_STATUS    = 5,          /* read status register */
 	SF_WR_ENABLE    = 6,          /* enable writes */
 	SF_RD_DATA_FAST = 0xb,        /* read flash */
+	SF_RD_ID        = 0x9f,       /* read ID */
 	SF_ERASE_SECTOR = 0xd8,       /* erase sector */
 
-	FW_START_SEC = 8,             /* first flash sector for FW */
-	FW_END_SEC = 15,              /* last flash sector for FW */
-	FW_IMG_START = FW_START_SEC * SF_SEC_SIZE,
-	FW_MAX_SIZE = (FW_END_SEC - FW_START_SEC + 1) * SF_SEC_SIZE,
+	FW_MAX_SIZE = 512 * 1024,
 };
 
 /**
@@ -558,7 +556,7 @@ static int t4_read_flash(struct adapter *adapter, unsigned int addr,
 {
 	int ret;
 
-	if (addr + nwords * sizeof(u32) > SF_SIZE || (addr & 3))
+	if (addr + nwords * sizeof(u32) > adapter->params.sf_size || (addr & 3))
 		return -EINVAL;
 
 	addr = swab32(addr) | SF_RD_DATA_FAST;
@@ -596,7 +594,7 @@ static int t4_write_flash(struct adapter *adapter, unsigned int addr,
 	u32 buf[64];
 	unsigned int i, c, left, val, offset = addr & 0xff;
 
-	if (addr >= SF_SIZE || offset + n > SF_PAGE_SIZE)
+	if (addr >= adapter->params.sf_size || offset + n > SF_PAGE_SIZE)
 		return -EINVAL;
 
 	val = swab32(addr) | SF_PROG_PAGE;
@@ -614,7 +612,7 @@ static int t4_write_flash(struct adapter *adapter, unsigned int addr,
 		if (ret)
 			goto unlock;
 	}
-	ret = flash_wait_op(adapter, 5, 1);
+	ret = flash_wait_op(adapter, 8, 1);
 	if (ret)
 		goto unlock;
 
@@ -647,9 +645,8 @@ unlock:
  */
 static int get_fw_version(struct adapter *adapter, u32 *vers)
 {
-	return t4_read_flash(adapter,
-			     FW_IMG_START + offsetof(struct fw_hdr, fw_ver), 1,
-			     vers, 0);
+	return t4_read_flash(adapter, adapter->params.sf_fw_start +
+			     offsetof(struct fw_hdr, fw_ver), 1, vers, 0);
 }
 
 /**
@@ -661,8 +658,8 @@ static int get_fw_version(struct adapter *adapter, u32 *vers)
  */
 static int get_tp_version(struct adapter *adapter, u32 *vers)
 {
-	return t4_read_flash(adapter, FW_IMG_START + offsetof(struct fw_hdr,
-							      tp_microcode_ver),
+	return t4_read_flash(adapter, adapter->params.sf_fw_start +
+			     offsetof(struct fw_hdr, tp_microcode_ver),
 			     1, vers, 0);
 }
 
@@ -684,9 +681,9 @@ int t4_check_fw_version(struct adapter *adapter)
 	if (!ret)
 		ret = get_tp_version(adapter, &adapter->params.tp_vers);
 	if (!ret)
-		ret = t4_read_flash(adapter,
-			FW_IMG_START + offsetof(struct fw_hdr, intfver_nic),
-			2, api_vers, 1);
+		ret = t4_read_flash(adapter, adapter->params.sf_fw_start +
+				    offsetof(struct fw_hdr, intfver_nic),
+				    2, api_vers, 1);
 	if (ret)
 		return ret;
 
@@ -726,7 +723,7 @@ static int t4_flash_erase_sectors(struct adapter *adapter, int start, int end)
 		if ((ret = sf1_write(adapter, 1, 0, 1, SF_WR_ENABLE)) != 0 ||
 		    (ret = sf1_write(adapter, 4, 0, 1,
 				     SF_ERASE_SECTOR | (start << 8))) != 0 ||
-		    (ret = flash_wait_op(adapter, 5, 500)) != 0) {
+		    (ret = flash_wait_op(adapter, 14, 500)) != 0) {
 			dev_err(adapter->pdev_dev,
 				"erase of flash sector %d failed, error %d\n",
 				start, ret);
@@ -754,6 +751,9 @@ int t4_load_fw(struct adapter *adap, const u8 *fw_data, unsigned int size)
 	u8 first_page[SF_PAGE_SIZE];
 	const u32 *p = (const u32 *)fw_data;
 	const struct fw_hdr *hdr = (const struct fw_hdr *)fw_data;
+	unsigned int sf_sec_size = adap->params.sf_size / adap->params.sf_nsec;
+	unsigned int fw_img_start = adap->params.sf_fw_start;
+	unsigned int fw_start_sec = fw_img_start / sf_sec_size;
 
 	if (!size) {
 		dev_err(adap->pdev_dev, "FW image has no data\n");
@@ -784,8 +784,8 @@ int t4_load_fw(struct adapter *adap, const u8 *fw_data, unsigned int size)
 		return -EINVAL;
 	}
 
-	i = DIV_ROUND_UP(size, SF_SEC_SIZE);        /* # of sectors spanned */
-	ret = t4_flash_erase_sectors(adap, FW_START_SEC, FW_START_SEC + i - 1);
+	i = DIV_ROUND_UP(size, sf_sec_size);        /* # of sectors spanned */
+	ret = t4_flash_erase_sectors(adap, fw_start_sec, fw_start_sec + i - 1);
 	if (ret)
 		goto out;
 
@@ -796,11 +796,11 @@ int t4_load_fw(struct adapter *adap, const u8 *fw_data, unsigned int size)
 	 */
 	memcpy(first_page, fw_data, SF_PAGE_SIZE);
 	((struct fw_hdr *)first_page)->fw_ver = htonl(0xffffffff);
-	ret = t4_write_flash(adap, FW_IMG_START, SF_PAGE_SIZE, first_page);
+	ret = t4_write_flash(adap, fw_img_start, SF_PAGE_SIZE, first_page);
 	if (ret)
 		goto out;
 
-	addr = FW_IMG_START;
+	addr = fw_img_start;
 	for (size -= SF_PAGE_SIZE; size; size -= SF_PAGE_SIZE) {
 		addr += SF_PAGE_SIZE;
 		fw_data += SF_PAGE_SIZE;
@@ -810,7 +810,7 @@ int t4_load_fw(struct adapter *adap, const u8 *fw_data, unsigned int size)
 	}
 
 	ret = t4_write_flash(adap,
-			     FW_IMG_START + offsetof(struct fw_hdr, fw_ver),
+			     fw_img_start + offsetof(struct fw_hdr, fw_ver),
 			     sizeof(hdr->fw_ver), (const u8 *)&hdr->fw_ver);
 out:
 	if (ret)
@@ -3053,6 +3053,33 @@ static int __devinit wait_dev_ready(struct adapter *adap)
 	return t4_read_reg(adap, PL_WHOAMI) != 0xffffffff ? 0 : -EIO;
 }
 
+static int __devinit get_flash_params(struct adapter *adap)
+{
+	int ret;
+	u32 info;
+
+	ret = sf1_write(adap, 1, 1, 0, SF_RD_ID);
+	if (!ret)
+		ret = sf1_read(adap, 3, 0, 1, &info);
+	t4_write_reg(adap, SF_OP, 0);                    /* unlock SF */
+	if (ret)
+		return ret;
+
+	if ((info & 0xff) != 0x20)             /* not a Numonix flash */
+		return -EINVAL;
+	info >>= 16;                           /* log2 of size */
+	if (info >= 0x14 && info < 0x18)
+		adap->params.sf_nsec = 1 << (info - 16);
+	else if (info == 0x18)
+		adap->params.sf_nsec = 64;
+	else
+		return -EINVAL;
+	adap->params.sf_size = 1 << info;
+	adap->params.sf_fw_start =
+		t4_read_reg(adap, CIM_BOOT_CFG) & BOOTADDR_MASK;
+	return 0;
+}
+
 /**
  *	t4_prep_adapter - prepare SW and HW for operation
  *	@adapter: the adapter
@@ -3073,6 +3100,12 @@ int __devinit t4_prep_adapter(struct adapter *adapter)
 	get_pci_mode(adapter, &adapter->params.pci);
 	adapter->params.rev = t4_read_reg(adapter, PL_REV);
 
+	ret = get_flash_params(adapter);
+	if (ret < 0) {
+		dev_err(adapter->pdev_dev, "error %d identifying flash\n", ret);
+		return ret;
+	}
+
 	ret = get_vpd_params(adapter, &adapter->params.vpd);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/cxgb4/t4_hw.h b/drivers/net/cxgb4/t4_hw.h
index 0256232..f886677 100644
--- a/drivers/net/cxgb4/t4_hw.h
+++ b/drivers/net/cxgb4/t4_hw.h
@@ -57,8 +57,6 @@ enum {
 
 enum {
 	SF_PAGE_SIZE = 256,           /* serial flash page size */
-	SF_SEC_SIZE = 64 * 1024,      /* serial flash sector size */
-	SF_SIZE = SF_SEC_SIZE * 16,   /* serial flash size */
 };
 
 enum { RSP_TYPE_FLBUF, RSP_TYPE_CPL, RSP_TYPE_INTR }; /* response entry types */
diff --git a/drivers/net/cxgb4/t4_regs.h b/drivers/net/cxgb4/t4_regs.h
index 5ed5648..8fed46d 100644
--- a/drivers/net/cxgb4/t4_regs.h
+++ b/drivers/net/cxgb4/t4_regs.h
@@ -326,6 +326,9 @@
 
 #define EDC_1_BASE_ADDR 0x7980
 
+#define CIM_BOOT_CFG 0x7b00
+#define  BOOTADDR_MASK 0xffffff00U
+
 #define CIM_PF_MAILBOX_DATA 0x240
 #define CIM_PF_MAILBOX_CTRL 0x280
 #define  MBMSGVALID     0x00000008U
-- 
1.5.4

