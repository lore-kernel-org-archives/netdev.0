From: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
Subject: [PATCH 07/10] mtd: Add SAM Flash driver
Date: Fri,  7 Oct 2016 18:18:35 +0300
Message-ID: <1475853518-22264-8-git-send-email-pantelis.antoniou@konsulko.com>
References: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com>
Cc: Linus Walleij <linus.walleij@linaro.org>,
        Alexandre Courbot <gnurou@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Frank Rowand <frowand.list@gmail.com>,
        Wolfram Sang <wsa@the-dreams.de>,
        David Woodhouse <dwmw2@infradead.org>,
        Brian Norris <computersforpeace@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Wim Van Sebroeck <wim@iguana.be>,
        Peter Rosin <peda@axentia.se>,
        Debjit Ghosh <dghosh@juniper.net>,
        Georgi Vlaev <gvlaev@juniper.net>,
        Guenter Roeck <linux@roeck-us.net>,
        Maryam Seraj <mseraj@juniper.net>,
        Pantelis Antoniou <pantelis.antoniou@konsulko.com>,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-gpio@vger.kernel.org, linux-i2c@vger.kernel.org,
        linux-mtd@lists.infradead.org, li
To: Lee Jones <lee.jones@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:38096 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932609AbcJGPVM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 11:21:12 -0400
Received: by mail-wm0-f52.google.com with SMTP id i130so45896088wmg.1
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2016 08:21:11 -0700 (PDT)
In-Reply-To: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <groeck@juniper.net>

Add driver for the flash block in Juniper's SAM FPGA.

This driver is used for updating the Altera's EPCS(64,256)
configuration flash devices via a Juniper defined hardware
interface.

Signed-off-by: Georgi Vlaev <gvlaev@juniper.net>
Signed-off-by: Guenter Roeck <groeck@juniper.net>
[Ported from Juniper kernel]
Signed-off-by: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
---
 drivers/mtd/devices/Kconfig     |  11 +
 drivers/mtd/devices/Makefile    |   1 +
 drivers/mtd/devices/sam-flash.c | 642 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 654 insertions(+)
 create mode 100644 drivers/mtd/devices/sam-flash.c

diff --git a/drivers/mtd/devices/Kconfig b/drivers/mtd/devices/Kconfig
index d4255fb..f5a9032 100644
--- a/drivers/mtd/devices/Kconfig
+++ b/drivers/mtd/devices/Kconfig
@@ -144,6 +144,17 @@ config MTD_LART
 	  not need any mapping/chip driver for LART. This one does it all
 	  for you, so go disable all of those if you enabled some of them (:
 
+config MTD_SAM_FLASH
+	tristate "Juniper SAM Flash driver"
+	depends on MFD_JUNIPER_SAM || MFD_JUNIPER_CBC
+	default y if MFD_JUNIPER_SAM
+	help
+	  This enables the flash driver for the SAM FPGA which is present
+	  on relevant Juniper platforms.
+
+	  This driver can also be built as a module. When it is so the name of
+	  the module is flash-sam.
+
 config JNX_PMB_NVRAM
 	tristate "Juniper FPC PMB NVRAM Driver"
 	depends on (PTXPMB_COMMON || JNX_PTX_NGPMB)
diff --git a/drivers/mtd/devices/Makefile b/drivers/mtd/devices/Makefile
index b407c5fc..7556311 100644
--- a/drivers/mtd/devices/Makefile
+++ b/drivers/mtd/devices/Makefile
@@ -18,6 +18,7 @@ obj-$(CONFIG_MTD_BCM47XXSFLASH)	+= bcm47xxsflash.o
 obj-$(CONFIG_MTD_ST_SPI_FSM)    += st_spi_fsm.o
 obj-$(CONFIG_MTD_POWERNV_FLASH)	+= powernv_flash.o
 
+obj-$(CONFIG_MTD_SAM_FLASH)	+= sam-flash.o
 obj-$(CONFIG_JNX_PMB_NVRAM)     += jnx_pmb_nvram.o
 
 CFLAGS_docg3.o			+= -I$(src)
diff --git a/drivers/mtd/devices/sam-flash.c b/drivers/mtd/devices/sam-flash.c
new file mode 100644
index 0000000..5f071e6
--- /dev/null
+++ b/drivers/mtd/devices/sam-flash.c
@@ -0,0 +1,642 @@
+/*
+ * Copyright (C) 2012 Juniper networks
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/pci.h>
+#include <linux/errno.h>
+#include <linux/of_device.h>
+#include <linux/of_platform.h>
+#include <linux/of_gpio.h>
+#include <linux/io.h>
+#include <linux/module.h>
+#include <linux/delay.h>
+
+#include <linux/mtd/mtd.h>
+#include <linux/mtd/partitions.h>
+
+#define SAM_FLASH_DEBUG_ENABLED
+#undef  T5E_MAX_FLASH_READ_WAIT_TIME_FIXED
+#define SAM_FLASH_IF_READ_MAX_SIZE		32	/* 256?! */
+
+#define SAM_FLASH_BASE		0x300
+
+#define ADDR_REG(x)		((x)->membase + SAM_FLASH_BASE + 0x000)
+#define COUNTER_REG(x)		((x)->membase + SAM_FLASH_BASE + 0x004)
+#define CONTROL_REG(x)		((x)->membase + SAM_FLASH_BASE + 0x008)
+#define STATUS_REG(x)		((x)->membase + SAM_FLASH_BASE + 0x00c)
+#define WRITE_DATA_REG(x)	((x)->membase + SAM_FLASH_BASE + 0x100)
+#define READ_DATA_REG(x)	((x)->membase + SAM_FLASH_BASE + 0x200)
+
+static int sam_flash_if_read_max_size = SAM_FLASH_IF_READ_MAX_SIZE;
+module_param(sam_flash_if_read_max_size, int, S_IRUSR | S_IRGRP | S_IWUSR);
+MODULE_PARM_DESC(sam_flash_if_read_max_size,
+		 "maximum read size done by SAM flash IF");
+
+#ifdef SAM_FLASH_DEBUG_ENABLED
+
+static int sam_flash_debug;
+module_param(sam_flash_debug, int, S_IRUSR | S_IRGRP | S_IWUSR);
+MODULE_PARM_DESC(sam_flash_debug, "enable debugging information");
+
+#define SAM_FLASH_DEBUG(dev, fmt, args...)			\
+	do {							\
+		if (sam_flash_debug) {				\
+			dev_info(dev, fmt, ## args);		\
+		}						\
+	} while (0)
+#else /* SAM_FLASH_DEBUG_ENABLED */
+#define SAM_FLASH_DEBUG(dev, fmt, args...)      {}
+#endif /* SAM_FLASH_DEBUG_ENABLED */
+
+/*
+ *  Ref: pfe/common/toolkis/flash/altera_epcs_as.h
+ */
+#define EPCS_EXT_STS_ID(sts)		((u8)((sts >> 8) & 0xff))
+#define EPCS_EXT_STS_RDSTS(sts)		((u8)((sts >> 16) & 0xff))
+#define EPCS_EXT_STS_SID(sts)		((u8)((sts >> 24) & 0xff))
+/* EPCS Device "read status" bits */
+#define EPCS_STS_WIP_BIT		0x01
+#define EPCS_STS_WLE_BIT		0x02
+#define EPCS_STS_BP_BITS(status)	((status >> 2) & 0x7)
+
+/*
+ *  Ref: pfe/common/toolkis/flash/altera_epcs_as.h
+ */
+#define EPCS64_S_ID			0x16
+#define EPCS64_NAME			"Altera EPCS64"
+#define EPCS64_SECT_SZ_SHIFT		16
+#define EPCS64_SECTOR_SIZE		(1 << EPCS64_SECT_SZ_SHIFT)
+#define EPCS64_SECTORS			128
+#define EPCS64_ADDR_TO_SECTOR(_addr)	((_addr) >> EPCS64_SECT_SZ_SHIFT)
+#define EPCS64_PAGE_SIZE		256
+#define EPCS64_PAGES			32768
+#define EPCS64_SIZE			(EPCS64_PAGE_SIZE * EPCS64_PAGES)
+#define EPCS64_MIN_SECT(bp_bits)	(EPCS64_SECTORS - (1 << bp_bits))
+
+/*
+ *  Ref: pfe/common/toolkis/flash/altera_epcs_as.h
+ *  timeout for busy:   t5e-pic/t5e_flash.c
+ */
+#define EPCS_TIMEOUT_BUSY		1
+#define EPCS_TIMEOUT_SINGLE_BYTE_READ	3
+#define EPCS_TIMEOUT_READ_ID		3
+#define EPCS_TIMEOUT_READ_STATUS	3
+
+/*
+ *  Ref: pfe/common/toolkis/flash/altera_epcs_as.h
+ *  timeout for waiting completion:   t5e-pic/t5e_flash.c
+ */
+#define EPCS_RD_TIMEO		20
+#define EPCS_WR_TIMEO		25
+#define EPCS_BLK_WR_TIMEO	25
+#define EPCS_SC_ER_TIMEO	(10 * 1000)
+#define EPCS_SC_PRT_TIMEO	35
+#define EPCS_CH_ER_TIMEO	(200 * 1000)
+/* */
+#define EPCS_STS_BSY_BIT	0x01
+#define EPCS_ILLEGAL_WR_BIT	0x02
+#define EPCS_ILLEGAL_RD_BIT	0x04
+#define EPCS_ILLEGAL		(EPCS_ILLEGAL_WR_BIT | EPCS_ILLEGAL_RD_BIT)
+#define EPCS_STATUS_BUSY(s)	((s) & EPCS_STS_BSY_BIT)
+
+/*
+ *  Ref t5e-pic/t5e_flash.c
+ */
+#define EPCS_BUSY_POLLING_START_DELAY		100	/* us */
+#define EPCS_BUSY_POLLING_START_DELAY_CNT	10
+#define EPCS_BUSY_POLLING_DELAY		(EPCS_BUSY_POLLING_START_DELAY_CNT * \
+					 EPCS_BUSY_POLLING_START_DELAY)
+
+/*
+ * FPGA flash control register: t5e-pic/t5e_fpga.h
+ */
+#define SAM_FLASH_IF_CONTROL_READ_SID		0x00000080
+#define SAM_FLASH_IF_CONTROL_CHIP_ERASE		0x00000040
+#define SAM_FLASH_IF_CONTROL_SECTOR_ERASE	0x00000020
+#define SAM_FLASH_IF_CONTROL_SECTOR_PROTECT	0x00000010
+#define SAM_FLASH_IF_CONTROL_READ_STATUS	0x00000008
+#define SAM_FLASH_IF_CONTROL_READ_ID		0x00000004
+#define SAM_FLASH_IF_CONTROL_WRITE		0x00000002
+#define SAM_FLASH_IF_CONTROL_READ		0x00000001
+#define SAM_FLASH_IF_WRITE_REG_SIZE		sizeof(u32)
+#define SAM_FLASH_IF_READ_REG_SIZE		sizeof(u32)
+
+struct sam_flash_info {
+	const char *name;
+	u8 device_id;
+	size_t flash_size;
+	size_t page_size;
+	size_t nr_pages;
+	size_t nr_sectors;
+	size_t erasesize;
+	size_t writesize;
+	size_t writebufsize;
+};
+
+static struct sam_flash_info sam_flash_info_db[] = {
+	{
+		.name = EPCS64_NAME,
+		.device_id = EPCS64_S_ID,
+		.flash_size = EPCS64_SIZE,
+		.page_size = EPCS64_PAGE_SIZE,
+		.nr_pages = EPCS64_PAGES,
+		.nr_sectors = EPCS64_SECTORS,
+		.erasesize = EPCS64_SECTOR_SIZE,
+		.writesize = 4,
+		.writebufsize = 4,
+	},
+};
+
+#define SAM_FLASH_INFO_DB_SIZE	ARRAY_SIZE(sam_flash_info_db)
+
+/**
+ * struct sam_flash - SAM FLASH private data structure.
+ * @membase:		PCI base address of Memory mapped I/O register.
+ * @reg:		Memory mapped PCH GPIO register list.
+ * @dev:		Pointer to device structure.
+ */
+struct sam_flash {
+	void __iomem *membase;
+	struct mutex lock;
+	struct device *dev;
+	struct sam_flash_info *info;
+	struct mtd_info mtd_info;
+};
+
+#define mtd_to_sam_flash(mtd) container_of(mtd, struct sam_flash, mtd_info)
+
+static bool sam_flash_if_busy(struct sam_flash *sam_flash, int retry)
+{
+	u32 status;
+
+	do {
+		status = ioread32(STATUS_REG(sam_flash));
+		if (!EPCS_STATUS_BUSY(status))
+			return false;
+		if (retry <= 1)
+			return true;
+		usleep_range(50, 100);
+	} while (--retry >= 0);
+
+	return true;
+}
+
+static int
+sam_flash_if_busy_wait(struct sam_flash *sam_flash, unsigned int max_wait_msec)
+{
+	unsigned long timeout;
+	u32 status;
+
+	timeout = jiffies + msecs_to_jiffies(max_wait_msec);
+	udelay(50);
+
+	do {
+		status = ioread32(STATUS_REG(sam_flash));
+		if (!EPCS_STATUS_BUSY(status))
+			return 0;
+
+		if (status & EPCS_ILLEGAL)
+			return -EACCES;
+
+		usleep_range(50, 100);
+	} while (time_before(jiffies, timeout));
+
+	return -ETIMEDOUT;
+}
+
+static int
+sam_flash_mem_read(struct sam_flash *sam_flash, u32 offset,
+		   u8 *data, size_t len)
+{
+	struct sam_flash_info *info = sam_flash->info;
+	void __iomem *io_addr;
+	u32 io_data;
+	int i, cnt;
+
+	if (offset >= info->flash_size || offset + len > info->flash_size)
+		return -EINVAL;
+
+	if (sam_flash_if_busy(sam_flash, EPCS_TIMEOUT_BUSY))
+		return -ETIMEDOUT;
+
+	iowrite32(len - 1, COUNTER_REG(sam_flash));
+	iowrite32(offset, ADDR_REG(sam_flash));
+
+	/* trigger the read */
+	iowrite32(SAM_FLASH_IF_CONTROL_READ, CONTROL_REG(sam_flash));
+	ioread32(CONTROL_REG(sam_flash));
+
+	/*
+	 * Before we start polling the busy bit, wait for some time,
+	 * so that, the busy bit will go high
+	 */
+#ifdef T5E_MAX_FLASH_READ_WAIT_TIME_FIXED
+	udelay(50);
+#else /* T5E_MAX_FLASH_READ_WAIT_TIME_FIXED */
+	udelay(50 * ((len >> 2) + 1));	/* 50 usec every 4 bytes */
+#endif /* T5E_MAX_FLASH_READ_WAIT_TIME_FIXED */
+
+	if (sam_flash_if_busy(sam_flash, EPCS_TIMEOUT_SINGLE_BYTE_READ))
+		return -ETIMEDOUT;
+
+	io_data = ioread32(COUNTER_REG(sam_flash));
+	if (io_data != len - 1)
+		return -EIO;
+
+	SAM_FLASH_DEBUG(sam_flash->dev,
+			"%s BYTE_CNT: len: %u, io_data: %u.\n",
+			__func__, (unsigned int)len, io_data);
+
+	io_addr = READ_DATA_REG(sam_flash);
+	for (cnt = 0; cnt < len; io_addr += sizeof(u32)) {
+		io_data = ioread32(io_addr);
+		for (i = 0; i < sizeof(u32) && cnt < len; i++, cnt++)
+			*(data++) = (io_data >> (i << 3)) & 0xff;
+	}
+
+	return 0;
+}
+
+static int sam_flash_read_sid(struct sam_flash *sam_flash)
+{
+	u32 io_data;
+
+	iowrite32(SAM_FLASH_IF_CONTROL_READ_SID, CONTROL_REG(sam_flash));
+	ioread32(CONTROL_REG(sam_flash));
+
+	/*
+	 * Before we start polling the busy bit, wait for some time
+	 * to ensure that busy bit is high.
+	 */
+	udelay(EPCS_BUSY_POLLING_DELAY);
+	if (sam_flash_if_busy(sam_flash, EPCS_TIMEOUT_READ_ID))
+		return -ETIMEDOUT;
+
+	io_data = ioread32(STATUS_REG(sam_flash));
+
+	return EPCS_EXT_STS_SID(io_data);
+}
+
+static struct sam_flash_info *sam_flash_get_info(struct sam_flash *sam_flash)
+{
+	struct sam_flash_info *info;
+	u8 sid;
+	int idx;
+
+	sid = sam_flash_read_sid(sam_flash);
+	if (sid < 0)
+		return ERR_PTR(sid);
+
+	info = ERR_PTR(-EINVAL);
+	for (idx = 0; idx < SAM_FLASH_INFO_DB_SIZE; idx++) {
+		if (sam_flash_info_db[idx].device_id == sid) {
+			info = &sam_flash_info_db[idx];
+			break;
+		}
+	}
+	return info;
+}
+
+static inline int sam_flash_get_page_num(struct sam_flash *sam_flash,
+					 u32 offset)
+{
+	return offset / sam_flash->info->page_size;
+}
+
+static int sam_flash_mem_write(struct sam_flash *sam_flash, u32 offset,
+			       const u8 *data, size_t len)
+{
+	struct sam_flash_info *info = sam_flash->info;
+	int status, bytes_in_reg, cnt, cnt2;
+	int start_page, end_page;
+	void __iomem *io_addr;
+	u32 io_data;
+	const u8 *buf;
+
+	start_page = sam_flash_get_page_num(sam_flash, offset);
+	end_page = sam_flash_get_page_num(sam_flash, offset + len - 1);
+
+	/*
+	 *  Based on Altera EPCS Device Datasheet,
+	 *  Writing with multiple byte must be in the __SAME__ page.
+	 *  Not sure if SAM FPGA takes that so ...
+	 */
+	if (len > info->page_size ||
+	    start_page != end_page ||
+	    start_page >= info->nr_pages) {
+		dev_err(sam_flash->dev, "Bad write length / offset\n");
+		return -EINVAL;
+	}
+
+	/* check if FPGA is ready to accept new command */
+	if (sam_flash_if_busy(sam_flash, EPCS_TIMEOUT_BUSY)) {
+		dev_err(sam_flash->dev, "chip is busy\n");
+		return -ETIMEDOUT;
+	}
+
+	iowrite32(len - 1, COUNTER_REG(sam_flash));
+
+	/* copy the data to WRITE_DATA register */
+	io_addr = WRITE_DATA_REG(sam_flash);
+	for (buf = data, cnt = 0; cnt < len;) {
+		bytes_in_reg = len - cnt;
+		if (bytes_in_reg > SAM_FLASH_IF_WRITE_REG_SIZE)
+			bytes_in_reg = SAM_FLASH_IF_WRITE_REG_SIZE;
+		io_data = 0;
+		for (cnt2 = 0; cnt2 < bytes_in_reg; cnt2++, buf++)
+			io_data |= *buf << (cnt2 << 3);
+
+		iowrite32(io_data, io_addr);
+		cnt += bytes_in_reg;
+		io_addr += bytes_in_reg;
+	}
+
+	iowrite32(offset, ADDR_REG(sam_flash));
+	/* trigger the write */
+	iowrite32(SAM_FLASH_IF_CONTROL_WRITE, CONTROL_REG(sam_flash));
+	ioread32(CONTROL_REG(sam_flash));
+
+	status = sam_flash_if_busy_wait(sam_flash, EPCS_WR_TIMEO);
+	return status;
+}
+
+static int sam_flash_mem_is_protected(struct sam_flash *sam_flash,
+				      u32 offset, size_t len)
+{
+	struct sam_flash_info *info = sam_flash->info;
+	u32 flash_status;
+	u32 sector;
+	u32 io_data;
+	int status = 0;
+
+	iowrite32(SAM_FLASH_IF_CONTROL_READ_STATUS, CONTROL_REG(sam_flash));
+	if (sam_flash_if_busy(sam_flash, EPCS_TIMEOUT_READ_ID))
+		return -ETIMEDOUT;
+
+	io_data = ioread32(STATUS_REG(sam_flash));
+	flash_status = EPCS_EXT_STS_RDSTS(io_data);
+	sector = EPCS64_ADDR_TO_SECTOR(offset);
+	if (EPCS_STS_BP_BITS(flash_status) &&
+	    sector < info->erasesize &&
+	    sector >= EPCS64_MIN_SECT(EPCS_STS_BP_BITS(flash_status))) {
+		status = -EACCES;
+		SAM_FLASH_DEBUG(sam_flash->dev,
+				"%s offset: 0x%x, len: %u: PROTECTED(0x%x): %d.\n",
+				__func__, offset, (unsigned int)len,
+				flash_status, status);
+	}
+
+	return status;
+}
+
+static int sam_flash_erase_sector(struct sam_flash *sam_flash, u32 offset)
+{
+	iowrite32(offset, ADDR_REG(sam_flash));
+	iowrite32(SAM_FLASH_IF_CONTROL_SECTOR_ERASE, CONTROL_REG(sam_flash));
+
+	return sam_flash_if_busy_wait(sam_flash, EPCS_SC_ER_TIMEO);
+}
+
+static int sam_flash_erase(struct mtd_info *mtd_info,
+			   struct erase_info *erase_info)
+{
+	struct sam_flash *sam_flash = mtd_to_sam_flash(mtd_info);
+	u32 len, start, end, offset;
+	int status = 0;
+
+	len = (u32) erase_info->len;
+	start = (u32) erase_info->addr;
+	end = start + len - 1;
+
+	offset = start;
+	mutex_lock(&sam_flash->lock);
+	erase_info->state = MTD_ERASE_DONE;
+	while (offset < end) {
+		status = sam_flash_erase_sector(sam_flash, offset);
+		if (status) {
+			erase_info->state = MTD_ERASE_FAILED;
+			break;
+		}
+		offset += mtd_info->erasesize;
+	}
+	mutex_unlock(&sam_flash->lock);
+
+	mtd_erase_callback(erase_info);
+
+	return status;
+}
+
+static int sam_flash_read(struct mtd_info *mtd_info, loff_t from, size_t len,
+			  size_t *retlen, unsigned char *buf)
+{
+	struct sam_flash *sam_flash = mtd_to_sam_flash(mtd_info);
+	int cnt, max_cnt;
+	int status = 0;
+
+	*retlen = 0;
+
+	max_cnt = len / sam_flash_if_read_max_size;
+	if (len % sam_flash_if_read_max_size != 0)
+		max_cnt++;
+	mutex_lock(&sam_flash->lock);
+	for (cnt = 0; cnt < max_cnt; cnt++) {
+		u32 from2;
+		size_t len2;
+		u8 *buf2;
+
+		from2 = from + *retlen;
+		buf2 = buf + *retlen;
+		len2 = len - *retlen;
+		if (len2 > sam_flash_if_read_max_size)
+			len2 = sam_flash_if_read_max_size;
+
+		status = sam_flash_mem_read(sam_flash, from2, buf2, len2);
+		if (status != 0) {
+			dev_err(sam_flash->dev,
+				"RD: cnt: %04d(%04d): from: %u(%u), len: %u(%u) failed: %d.\n",
+				cnt, max_cnt, from2, (u32) from,
+				(unsigned int)len2, (unsigned int)len, status);
+			break;
+		}
+		*retlen += len2;
+	}
+	mutex_unlock(&sam_flash->lock);
+
+	return status;
+}
+
+static int sam_flash_write(struct mtd_info *mtd_info, loff_t to,
+			   size_t len, size_t *retlen, const unsigned char *buf)
+{
+	struct sam_flash *sam_flash = mtd_to_sam_flash(mtd_info);
+	int status, done, to_be_done;
+
+	mutex_lock(&sam_flash->lock);
+	status = sam_flash_mem_is_protected(sam_flash, to, len);
+	if (status)
+		goto abort;
+
+	for (done = 0; done < len; done += to_be_done) {
+		to_be_done = to & (sam_flash->info->page_size - 1);
+		if (to_be_done == 0) {
+			/* 'to' is page aligned */
+			to_be_done = len - done;
+			if (to_be_done > sam_flash->info->page_size)
+				to_be_done = sam_flash->info->page_size;
+		} else {
+			to_be_done = sam_flash->info->page_size - to_be_done;
+		}
+
+		SAM_FLASH_DEBUG(sam_flash->dev,
+				"%s to: 0x%x, buf: 0x%p, to_be_done: %d, done: %d, len: %d.\n",
+				__func__,
+				(u32) to, buf, to_be_done,
+				done, (unsigned int)len);
+		status = sam_flash_mem_write(sam_flash, to, buf, to_be_done);
+		if (status) {
+			dev_err(sam_flash->dev,
+				"WR: failed to 0x%x, buf: 0x%p, done: %d(%d), to_be_done: %d: %d.\n",
+				(u32)to, buf, done, (unsigned int)len,
+				to_be_done, status);
+			break;
+		}
+
+		to += to_be_done;
+		buf += to_be_done;
+	}
+
+	if (!status)
+		*retlen = len;
+
+abort:
+	mutex_unlock(&sam_flash->lock);
+	return status;
+}
+
+static int sam_flash_mtd_attach(struct platform_device *pdev,
+				struct sam_flash *sam_flash)
+{
+	struct mtd_part_parser_data ppdata = {};
+	struct sam_flash_info *info;
+	struct device *dev = sam_flash->dev;
+	struct mtd_info *mtd_info;
+	int ret;
+
+	info = sam_flash_get_info(sam_flash);
+	if (IS_ERR(info))
+		return PTR_ERR(info);
+
+	sam_flash->info = info;
+
+	mtd_info = &sam_flash->mtd_info;
+	mtd_info->name = dev_name(dev);
+	mtd_info->type = MTD_NORFLASH;
+	mtd_info->flags = MTD_CAP_NORFLASH;
+	mtd_info->erasesize = info->erasesize;
+	mtd_info->writesize = info->writesize;
+	mtd_info->writebufsize = info->writebufsize;
+	mtd_info->size = info->flash_size;
+	mtd_info->_erase = sam_flash_erase;
+	mtd_info->_read = sam_flash_read;
+	mtd_info->_write = sam_flash_write;
+
+	ret = mtd_device_parse_register(mtd_info, NULL, &ppdata, NULL, 0);
+	if (ret) {
+		dev_err(dev, "mtd_device_parse_register returned %d\n", ret);
+		return ret;
+	}
+
+	dev_info(dev,
+		 "ATTACH: name: \"%s\" type: %d, flags: 0x%x.\n",
+		 mtd_info->name, mtd_info->type, mtd_info->flags);
+	dev_info(dev,
+		 "ATTACH: erasesize: %d, writesize: %d, writebufsize: %d\n",
+		 mtd_info->erasesize, mtd_info->writesize,
+		 mtd_info->writebufsize);
+	dev_info(dev,
+		 "ATTACH: size: %llu.%u(%llu KB).\n",
+		 mtd_info->size,
+		 (unsigned int)info->flash_size,
+		 (long long)mtd_info->size >> 10);
+
+	return 0;
+}
+
+static int sam_flash_probe(struct platform_device *pdev)
+{
+	struct device *dev = &pdev->dev;
+	struct sam_flash *sam_flash;
+	struct resource *res;
+
+	sam_flash = devm_kzalloc(dev, sizeof(*sam_flash), GFP_KERNEL);
+	if (sam_flash == NULL)
+		return -ENOMEM;
+
+	sam_flash->dev = dev;
+	platform_set_drvdata(pdev, sam_flash);
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res)
+		return -ENOMEM;
+
+	sam_flash->membase = devm_ioremap(dev, res->start, resource_size(res));
+	if (!sam_flash->membase)
+		return -ENOMEM;
+
+	mutex_init(&sam_flash->lock);
+
+	return sam_flash_mtd_attach(pdev, sam_flash);
+}
+
+static int sam_flash_remove(struct platform_device *pdev)
+{
+	struct sam_flash *sam_flash = platform_get_drvdata(pdev);
+
+	mtd_device_unregister(&sam_flash->mtd_info);
+
+	return 0;
+}
+
+static const struct of_device_id sam_flash_ids[] = {
+	{ .compatible = "jnx,flash-sam", },
+	{ },
+};
+
+MODULE_DEVICE_TABLE(of, sam_flash_ids);
+
+static struct platform_driver sam_flash_driver = {
+	.driver = {
+		   .name = "flash-sam",
+		   .owner = THIS_MODULE,
+		   .of_match_table = sam_flash_ids,
+		   },
+	.probe = sam_flash_probe,
+	.remove = sam_flash_remove,
+};
+
+static int __init sam_flash_init(void)
+{
+	return platform_driver_register(&sam_flash_driver);
+}
+
+static void __exit sam_flash_exit(void)
+{
+	platform_driver_unregister(&sam_flash_driver);
+}
+
+module_init(sam_flash_init);
+module_exit(sam_flash_exit);
+
+MODULE_DESCRIPTION("SAM-FPGA FLASH Driver");
+MODULE_LICENSE("GPL");
-- 
1.9.1
