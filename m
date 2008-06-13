From: Robert Stonehouse <rstonehouse@solarflare.com>
Subject: [RFC][PATCH 2/2] Making use of VNICs in the sfc driver
Date: Fri, 13 Jun 2008 21:13:12 +0100
Message-ID: <4852D4D8.8020000@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:41644 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753683AbYFMU1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 16:27:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 drivers/net/sfc/Kconfig         |    8 +
 drivers/net/sfc/Makefile        |    3 +
 drivers/net/sfc/driverlink.c    |    4 +-
 drivers/net/sfc/efx.c           |    1 +
 drivers/net/sfc/falcon.c        |  181 ++++++++++--
 drivers/net/sfc/falcon_hwdefs.h |   21 ++
 drivers/net/sfc/mtd.c           |  592 +++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/net_driver.h    |    9 +
 drivers/net/sfc/spi.h           |   98 +++++++
 9 files changed, 887 insertions(+), 30 deletions(-)
 create mode 100644 drivers/net/sfc/mtd.c

diff --git a/drivers/net/sfc/Kconfig b/drivers/net/sfc/Kconfig
index 3be13b5..0603ead 100644
--- a/drivers/net/sfc/Kconfig
+++ b/drivers/net/sfc/Kconfig
@@ -12,3 +12,11 @@ config SFC

 	  To compile this driver as a module, choose M here.  The module
 	  will be called sfc.
+
+config SFC_MTD
+	depends on SFC && MTD && MTD_PARTITIONS
+	tristate "Solarflare Solarstorm SFC4000 flash/EEPROM support"
+	help
+	  This module exposes the on-board flash and/or EEPROM memory as
+	  MTD devices (e.g. /dev/mtd1).  This makes it possible to upload a
+	  new boot ROM to the NIC.
diff --git a/drivers/net/sfc/Makefile b/drivers/net/sfc/Makefile
index aa3bff7..738649a 100644
--- a/drivers/net/sfc/Makefile
+++ b/drivers/net/sfc/Makefile
@@ -3,3 +3,6 @@ sfc-y			+= efx.o falcon.o tx.o rx.o falcon_xmac.o \
 			   mdio_10g.o tenxpress.o boards.o sfe4001.o \
 			   driverlink.o
 obj-$(CONFIG_SFC)	+= sfc.o
+
+sfc_mtd-y		+= mtd.o
+obj-$(CONFIG_SFC_MTD)	+= sfc_mtd.o
diff --git a/drivers/net/sfc/driverlink.c b/drivers/net/sfc/driverlink.c
index 93f29d5..6c33aeb 100644
--- a/drivers/net/sfc/driverlink.c
+++ b/drivers/net/sfc/driverlink.c
@@ -80,7 +80,7 @@ static void efx_dl_try_add_device(struct efx_nic *efx,
 {
 	struct efx_dl_handle *efx_handle;
 	struct efx_dl_device *efx_dev;
-	int rc;
+	int rc = -ENODEV;

 	/* Allocate and initialise new efx_dl_device structure */
 	efx_handle = kzalloc(sizeof(*efx_handle), GFP_KERNEL);
@@ -107,7 +107,7 @@ static void efx_dl_try_add_device(struct efx_nic *efx,
 	return;

  fail:
-	EFX_INFO(efx, "%s driverlink client skipped\n", driver->name);
+	EFX_INFO(efx, "%s driverlink client skipped rc=%d\n", driver->name, rc);

 	kfree(efx_handle);
 }
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 0e153cb..f3f62ea 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1871,6 +1871,7 @@ static int efx_init_struct(struct efx_nic *efx, struct
efx_nic_type *type,
 	memset(efx, 0, sizeof(*efx));
 	spin_lock_init(&efx->biu_lock);
 	spin_lock_init(&efx->phy_lock);
+	mutex_init(&efx->spi_lock);
 	INIT_WORK(&efx->reset_work, efx_reset_work);
 	INIT_DELAYED_WORK(&efx->monitor_work, efx_monitor);
 	efx->pci_dev = pci_dev;
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 959e06a..23287e2 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1688,7 +1688,6 @@ void falcon_fini_interrupt(struct efx_nic *efx)
  *
  **************************************************************************
  */
-
 #define FALCON_SPI_MAX_LEN sizeof(efx_oword_t)

 /* Wait for SPI command completion */
@@ -1712,44 +1711,116 @@ static int falcon_spi_wait(struct efx_nic *efx)
 }

 static int
-falcon_spi_read(struct efx_nic *efx, int device_id, unsigned int command,
-		unsigned int address, unsigned int addr_len,
-		void *data, unsigned int len)
+falcon_spi_read(const struct efx_spi_device *spi, struct efx_nic *efx,
+		unsigned int command, int address, void *data, unsigned int len)
 {
+	int addressed = (address >= 0);
 	efx_oword_t reg;
 	int rc;

-	BUG_ON(len > FALCON_SPI_MAX_LEN);
+	/* Input validation */
+	if (len > FALCON_SPI_MAX_LEN)
+		return -EINVAL;
+
+	/* Acquire SPI lock */
+	mutex_lock(&efx->spi_lock);

 	/* Check SPI not currently being accessed */
 	rc = falcon_spi_wait(efx);
-	if (rc)
-		return rc;
+	if (rc) {
+		goto out;
+	}

-	/* Program address register */
-	EFX_POPULATE_OWORD_1(reg, EE_SPI_HADR_ADR, address);
-	falcon_write(efx, &reg, EE_SPI_HADR_REG_KER);
+	/* Program address register, if we have an address */
+	if (addressed) {
+		EFX_POPULATE_OWORD_1(reg, EE_SPI_HADR_ADR, address);
+		falcon_write(efx, &reg, EE_SPI_HADR_REG_KER);
+	}

 	/* Issue read command */
 	EFX_POPULATE_OWORD_7(reg,
 			     EE_SPI_HCMD_CMD_EN, 1,
-			     EE_SPI_HCMD_SF_SEL, device_id,
+			     EE_SPI_HCMD_SF_SEL, spi->device_id,
 			     EE_SPI_HCMD_DABCNT, len,
 			     EE_SPI_HCMD_READ, EE_SPI_READ,
 			     EE_SPI_HCMD_DUBCNT, 0,
-			     EE_SPI_HCMD_ADBCNT, addr_len,
+			     EE_SPI_HCMD_ADBCNT,
+			     (addressed ? spi->addr_len : 0),
 			     EE_SPI_HCMD_ENC, command);
 	falcon_write(efx, &reg, EE_SPI_HCMD_REG_KER);

 	/* Wait for read to complete */
 	rc = falcon_spi_wait(efx);
 	if (rc)
-		return rc;
+		goto out;

 	/* Read data */
 	falcon_read(efx, &reg, EE_SPI_HDATA_REG_KER);
 	memcpy(data, &reg, len);
-	return 0;
+
+ out:
+	/* Release SPI lock */
+	mutex_unlock(&efx->spi_lock);
+
+	return rc;
+}
+
+static int
+falcon_spi_write(const struct efx_spi_device *spi, struct efx_nic *efx,
+		 unsigned int command, int address, const void *data,
+		 unsigned int len)
+{
+	int addressed = (address >= 0);
+	efx_oword_t reg;
+	int rc;
+
+	/* Input validation */
+	if (len > (addressed ? efx_spi_write_limit(spi, address)
+		   : FALCON_SPI_MAX_LEN))
+		return -EINVAL;
+
+	/* Acquire SPI lock */
+	mutex_lock(&efx->spi_lock);
+
+	/* Check SPI not currently being accessed */
+	rc = falcon_spi_wait(efx);
+	if (rc)
+		goto out;
+
+	/* Program address register, if we have an address */
+	if (addressed) {
+		EFX_POPULATE_OWORD_1(reg, EE_SPI_HADR_ADR, address);
+		falcon_write(efx, &reg, EE_SPI_HADR_REG_KER);
+	}
+
+	/* Program data register, if we have data */
+	if (data) {
+		memcpy(&reg, data, len);
+		falcon_write(efx, &reg, EE_SPI_HDATA_REG_KER);
+	}
+
+	/* Issue write command */
+	EFX_POPULATE_OWORD_7(reg,
+			     EE_SPI_HCMD_CMD_EN, 1,
+			     EE_SPI_HCMD_SF_SEL, spi->device_id,
+			     EE_SPI_HCMD_DABCNT, len,
+			     EE_SPI_HCMD_READ, EE_SPI_WRITE,
+			     EE_SPI_HCMD_DUBCNT, 0,
+			     EE_SPI_HCMD_ADBCNT,
+			     (addressed ? spi->addr_len : 0),
+			     EE_SPI_HCMD_ENC, command);
+	falcon_write(efx, &reg, EE_SPI_HCMD_REG_KER);
+
+	/* Wait for write to complete */
+	rc = falcon_spi_wait(efx);
+	if (rc)
+		goto out;
+
+ out:
+	/* Release SPI lock */
+	mutex_unlock(&efx->spi_lock);
+
+	return rc;
 }

 /**************************************************************************
@@ -2325,40 +2396,86 @@ static int falcon_reset_sram(struct efx_nic *efx)
 	return -ETIMEDOUT;
 }

+static void falcon_spi_device_init(struct efx_spi_device **spi_device_ret,
+				   unsigned int device_id, u32 device_type)
+{
+	struct efx_spi_device *spi_device;
+
+	if (device_type != 0) {
+		spi_device = kmalloc(sizeof(*spi_device), GFP_KERNEL);
+		if (!spi_device)
+			return;
+		spi_device->device_id = device_id;
+		spi_device->size =
+			1 << SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_SIZE);
+		spi_device->addr_len =
+			SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_ADDR_LEN);
+		spi_device->munge_address = (spi_device->size == 1 << 9 &&
+					     spi_device->addr_len == 1);
+		spi_device->erase_command =
+			SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_ERASE_CMD);
+		spi_device->erase_size =
+			1 << SPI_DEV_TYPE_FIELD(device_type,
+						SPI_DEV_TYPE_ERASE_SIZE);
+		spi_device->block_size =
+			1 << SPI_DEV_TYPE_FIELD(device_type,
+						SPI_DEV_TYPE_BLOCK_SIZE);
+		spi_device->read = falcon_spi_read;
+		spi_device->write = falcon_spi_write;
+	} else {
+		spi_device = NULL;
+	}
+
+	kfree(*spi_device_ret);
+	*spi_device_ret = spi_device;
+}
+
 /* Extract non-volatile configuration */
 static int falcon_probe_nvconfig(struct efx_nic *efx)
 {
 	struct falcon_nvconfig *nvconfig;
+	struct efx_spi_device *spi;
 	efx_oword_t nic_stat;
-	int device_id;
-	unsigned addr_len;
 	size_t offset, len;
 	int magic_num, struct_ver, board_rev;
-	int rc;
+	int rc = 0;
+
+	nvconfig = kmalloc(sizeof(*nvconfig), GFP_KERNEL);
+	if (!nvconfig)
+	  return -ENOMEM;

 	/* Find the boot device. */
 	falcon_read(efx, &nic_stat, NIC_STAT_REG);
 	if (EFX_OWORD_FIELD(nic_stat, SF_PRST)) {
-		device_id = EE_SPI_FLASH;
-		addr_len = 3;
+	  u32 devtype =					/* Atmel AT25F1024 */
+	    (17 << SPI_DEV_TYPE_SIZE_LBN)		/* 128KB */
+	    | (3 << SPI_DEV_TYPE_ADDR_LEN_LBN)		/* 24 bit */
+	    | (0x52 << SPI_DEV_TYPE_ERASE_CMD_LBN)
+	    | (15 << SPI_DEV_TYPE_ERASE_SIZE_LBN)	/* 32KB */
+	    | (8 << SPI_DEV_TYPE_BLOCK_SIZE_LBN);	/* 256B */
+	  falcon_spi_device_init(&efx->spi_flash, EE_SPI_FLASH, devtype);
 	} else if (EFX_OWORD_FIELD(nic_stat, EE_PRST)) {
-		device_id = EE_SPI_EEPROM;
-		addr_len = 2;
+	  u32 devtype =					/* Atmel AT25040 */
+	    (9 << SPI_DEV_TYPE_SIZE_LBN)		/* 512 B */
+	    | (2 << SPI_DEV_TYPE_ADDR_LEN_LBN)		/* 9-bit address */
+	    | (3 << SPI_DEV_TYPE_BLOCK_SIZE_LBN);	/* 8 B write block */
+	  falcon_spi_device_init(&efx->spi_eeprom, EE_SPI_EEPROM, devtype);
 	} else {
 		return -ENODEV;
 	}

-	nvconfig = kmalloc(sizeof(*nvconfig), GFP_KERNEL);
-
+	spi = efx->spi_flash ? efx->spi_flash : efx->spi_eeprom;
 	/* Read the whole configuration structure into memory. */
-	for (offset = 0; offset < sizeof(*nvconfig); offset += len) {
+	for (offset = 0; offset < sizeof(*nvconfig) && !rc; offset += len) {
 		len = min(sizeof(*nvconfig) - offset,
 			  (size_t) FALCON_SPI_MAX_LEN);
-		rc = falcon_spi_read(efx, device_id, SPI_READ,
-				     NVCONFIG_BASE + offset, addr_len,
+		rc = falcon_spi_read(spi, efx, SPI_READ, NVCONFIG_BASE + offset,
 				     (char *)nvconfig + offset, len);
-		if (rc)
+		if (rc) {
+			EFX_ERR(efx, "Reading of %s failed rc=%d\n",
+				efx->spi_flash ? "flash" : "eeprom", rc);
 			goto out;
+		}
 	}

 	/* Read the MAC addresses */
@@ -2376,12 +2493,20 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 		board_rev = 0;
 	} else {
 		struct falcon_nvconfig_board_v2 *v2 = &nvconfig->board_v2;
+		struct falcon_nvconfig_board_v3 *v3 = &nvconfig->board_v3;

 		efx->phy_type = v2->port0_phy_type;
 		efx->mii.phy_id = v2->port0_phy_addr;
 		board_rev = le16_to_cpu(v2->board_revision);
+		if (struct_ver >= 3) {
+		  __le32 fl = v3->spi_device_type[EE_SPI_FLASH];
+		  __le32 ee = v3->spi_device_type[EE_SPI_EEPROM];
+		  falcon_spi_device_init(&efx->spi_flash, EE_SPI_FLASH,
+					 le32_to_cpu(fl));
+		  falcon_spi_device_init(&efx->spi_eeprom, EE_SPI_EEPROM,
+					 le32_to_cpu(ee));
+		}
 	}
-
 	EFX_LOG(efx, "PHY is %d phy_id %d\n", efx->phy_type, efx->mii.phy_id);

 	efx_set_board_info(efx, board_rev);
diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
index 6d00311..d20bc65 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -1127,6 +1127,25 @@ struct falcon_nvconfig_board_v2 {
 	__le16 board_revision;
 } __packed;

+/* Board configuration v3 extra information */
+struct falcon_nvconfig_board_v3 {
+	__le32 spi_device_type[2];
+} __packed;
+
+/* Bit numbers for spi_device_type */
+#define SPI_DEV_TYPE_SIZE_LBN 0
+#define SPI_DEV_TYPE_SIZE_WIDTH 5
+#define SPI_DEV_TYPE_ADDR_LEN_LBN 6
+#define SPI_DEV_TYPE_ADDR_LEN_WIDTH 2
+#define SPI_DEV_TYPE_ERASE_CMD_LBN 8
+#define SPI_DEV_TYPE_ERASE_CMD_WIDTH 8
+#define SPI_DEV_TYPE_ERASE_SIZE_LBN 16
+#define SPI_DEV_TYPE_ERASE_SIZE_WIDTH 5
+#define SPI_DEV_TYPE_BLOCK_SIZE_LBN 24
+#define SPI_DEV_TYPE_BLOCK_SIZE_WIDTH 5
+#define SPI_DEV_TYPE_FIELD(type, field) \
+	(((type) >> EFX_LOW_BIT(field)) & EFX_MASK32(field))
+
 #define NVCONFIG_BASE 0x300
 #define NVCONFIG_BOARD_MAGIC_NUM 0xFA1C
 struct falcon_nvconfig {
@@ -1144,6 +1163,8 @@ struct falcon_nvconfig {
 	__le16 board_struct_ver;
 	__le16 board_checksum;
 	struct falcon_nvconfig_board_v2 board_v2;
+	efx_oword_t ee_base_page_reg;			/* 0x3B0 */
+	struct falcon_nvconfig_board_v3 board_v3;	/* 0x3C0 */
 } __packed;

 #endif /* EFX_FALCON_HWDEFS_H */
diff --git a/drivers/net/sfc/mtd.c b/drivers/net/sfc/mtd.c
new file mode 100644
index 0000000..a043754
--- /dev/null
+++ b/drivers/net/sfc/mtd.c
@@ -0,0 +1,592 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/module.h>
+#include <linux/mtd/mtd.h>
+#include <linux/mtd/partitions.h>
+#include <linux/delay.h>
+
+#define EFX_DRIVER_NAME "sfc_mtd"
+#include "driverlink_api.h"
+#include "driverlink.h"
+#include "net_driver.h"
+#include "spi.h"
+
+/*
+ * Flash and EEPROM (MTD) device driver
+ *
+ * This file provides a separate kernel module (sfc_mtd) which
+ * exposes the flash and EEPROM devices present on Solarflare NICs as
+ * MTD devices, enabling you to reflash the boot ROM code (or use the
+ * remaining space on the flash as a jffs2 filesystem, should you want
+ * to do so).
+ */
+
+#define EFX_MTD_VERIFY_BUF_LEN 16
+#define EFX_MAX_PARTITIONS 2
+#define EFX_FLASH_BOOTROM_OFFSET 0x8000U
+
+/* Write enable for EEPROM/flash configuration area
+ *
+ * Normally, writes to parts of non-volatile storage which contain
+ * critical configuration are disabled to prevent accidents.  This
+ * parameter allows enabling of such writes.
+ */
+static unsigned int efx_allow_nvconfig_writes;
+
+struct efx_mtd {
+	struct mtd_info mtd;
+	struct mtd_partition part[EFX_MAX_PARTITIONS];
+	char part_name[EFX_MAX_PARTITIONS][32];
+	char name[32];
+	struct efx_dl_device *efx_dev;
+	struct efx_nic *efx;
+	/* This must be held when using *spi; it guards against races
+	 * with device reset and between sequences of dependent
+	 * commands. */
+	struct semaphore access_lock;
+	struct efx_spi_device *spi;
+};
+
+/* SPI utilities */
+
+static int efx_spi_fast_wait(struct efx_mtd *efx_mtd)
+{
+	struct efx_spi_device *spi = efx_mtd->spi;
+	u8 status;
+	int i, rc;
+
+	/* Wait up to 1000us for flash/EEPROM to finish a fast operation. */
+	for (i = 0; i < 50; i++) {
+		udelay(20);
+
+		rc = spi->read(spi, efx_mtd->efx, SPI_RDSR, -1,
+			       &status, sizeof(status));
+		if (rc)
+			return rc;
+		if (!(status & SPI_STATUS_NRDY))
+			return 0;
+	}
+	EFX_ERR(efx_mtd->efx, "timed out waiting for %s last status=0x%02x\n",
+		efx_mtd->name, status);
+	return -ETIMEDOUT;
+}
+
+static int efx_spi_slow_wait(struct efx_mtd *efx_mtd, int uninterruptible)
+{
+	struct efx_spi_device *spi = efx_mtd->spi;
+	u8 status;
+	int rc, i;
+
+	/* Wait up to 4s for flash/EEPROM to finish a slow operation. */
+	for (i = 0; i < 40; i++) {
+		__set_current_state(uninterruptible ?
+				    TASK_UNINTERRUPTIBLE : TASK_INTERRUPTIBLE);
+		schedule_timeout(HZ / 10);
+		rc = spi->read(spi, efx_mtd->efx, SPI_RDSR, -1,
+			       &status, sizeof(status));
+		if (rc)
+			return rc;
+		if (!(status & SPI_STATUS_NRDY))
+			return 0;
+		if (signal_pending(current))
+			return -EINTR;
+	}
+	EFX_ERR(efx_mtd->efx, "timed out waiting for %s\n", efx_mtd->name);
+	return -ETIMEDOUT;
+}
+
+static int
+efx_spi_write_enable(struct efx_mtd *efx_mtd)
+{
+	struct efx_spi_device *spi = efx_mtd->spi;
+
+	return spi->write(spi, efx_mtd->efx, SPI_WREN, -1, NULL, 0);
+}
+
+static int efx_spi_unlock(struct efx_mtd *efx_mtd)
+{
+	struct efx_spi_device *spi = efx_mtd->spi;
+	const u8 unlock_mask = (SPI_STATUS_BP2 | SPI_STATUS_BP1 |
+				     SPI_STATUS_BP0);
+	u8 status;
+	int rc;
+
+	rc = spi->read(spi, efx_mtd->efx, SPI_RDSR, -1, &status,
+		       sizeof(status));
+	if (rc)
+		return rc;
+
+	if (!(status & unlock_mask))
+		return 0; /* already unlocked */
+
+	rc = efx_spi_write_enable(efx_mtd);
+	if (rc)
+		return rc;
+	rc = spi->write(spi, efx_mtd->efx, SPI_SST_EWSR, -1, NULL, 0);
+	if (rc)
+		return rc;
+
+	status &= ~unlock_mask;
+	rc = spi->write(spi, efx_mtd->efx, SPI_WRSR, -1, &status,
+			sizeof(status));
+	if (rc)
+		return rc;
+	rc = efx_spi_fast_wait(efx_mtd);
+	if (rc)
+		return rc;
+
+	return 0;
+}
+
+/* Dummy device used in case of a failed reset */
+
+static int efx_spi_dummy_read(const struct efx_spi_device *spi,
+			      struct efx_nic *efx, unsigned int command,
+			      int address, void *data, unsigned int len)
+{
+	return -EIO;
+}
+
+static int efx_spi_dummy_write(const struct efx_spi_device *spi,
+			       struct efx_nic *efx, unsigned int command,
+			       int address, const void *data, unsigned int len)
+{
+	return -EIO;
+}
+
+static struct efx_spi_device efx_spi_dummy_device = {
+	.block_size	= 1,
+	.erase_command	= 0xff,
+	.read		= efx_spi_dummy_read,
+	.write		= efx_spi_dummy_write,
+};
+
+/* MTD interface */
+
+static int efx_mtd_read(struct mtd_info *mtd, loff_t start, size_t len,
+			size_t *retlen, u8 *buffer)
+{
+	struct efx_mtd *efx_mtd = mtd->priv;
+	struct efx_spi_device *spi;
+	unsigned int command;
+	unsigned int block_len;
+	unsigned int pos = 0;
+	int rc;
+
+	rc = down_interruptible(&efx_mtd->access_lock);
+	if (rc)
+		goto out;
+	spi = efx_mtd->spi;
+
+	while (pos < len) {
+		block_len = min((unsigned int)len - pos,
+				efx_spi_read_limit(spi, start + pos));
+		command = efx_spi_munge_command(spi, SPI_READ, start + pos);
+		rc = spi->read(spi, efx_mtd->efx, command, start + pos,
+			       buffer + pos, block_len);
+		if (rc)
+			break;
+		pos += block_len;
+
+		/* Avoid locking up the system */
+		cond_resched();
+		if (signal_pending(current)) {
+			rc = -EINTR;
+			break;
+		}
+	}
+
+	up(&efx_mtd->access_lock);
+out:
+	*retlen = pos;
+	return rc;
+}
+
+/* Check that device contents match buffer.  If repeat is true, buffer
+ * contains a pattern of length EFX_MTD_VERIFY_BUF_LEN which the
+ * device contents should match repeatedly.
+ */
+static int efx_mtd_verify(struct mtd_info *mtd, loff_t start,
+			  size_t len, const u8 *buffer, int repeat)
+{
+	u8 verify_buffer[EFX_MTD_VERIFY_BUF_LEN];
+	unsigned int block_len;
+	size_t read_len;
+	unsigned int pos = 0;
+	int rc = 0;
+
+	while (pos < len) {
+		block_len = min(len - pos, sizeof(verify_buffer));
+		rc = efx_mtd_read(mtd, start + pos, block_len, &read_len,
+				  verify_buffer);
+		if (rc)
+			return rc;
+		if (memcmp(repeat ? buffer : buffer + pos, verify_buffer,
+			   block_len))
+			return -EIO;
+		pos += block_len;
+	}
+
+	return 0;
+}
+
+static int efx_mtd_erase(struct mtd_info *mtd, struct erase_info *erase)
+{
+	struct efx_mtd *efx_mtd = mtd->priv;
+	struct efx_spi_device *spi;
+	u8 empty[EFX_MTD_VERIFY_BUF_LEN];
+	int rc;
+
+	if (erase->len != mtd->erasesize) {
+		rc = -EINVAL;
+		goto out;
+	}
+
+	rc = down_interruptible(&efx_mtd->access_lock);
+	if (rc)
+		goto out;
+	spi = efx_mtd->spi;
+	if (spi->erase_command == 0) {
+		rc = -EOPNOTSUPP;
+		goto out_up;
+	}
+
+	rc = efx_spi_unlock(efx_mtd);
+	if (rc)
+		goto out_up;
+	rc = efx_spi_write_enable(efx_mtd);
+	if (rc)
+		goto out_up;
+	rc = spi->write(spi, efx_mtd->efx, spi->erase_command, erase->addr,
+			NULL, 0);
+	if (rc)
+		goto out_up;
+	rc = efx_spi_slow_wait(efx_mtd, 0);
+
+out_up:
+	up(&efx_mtd->access_lock);
+	if (rc)
+		goto out;
+
+	memset(empty, 0xff, sizeof(empty));
+	rc = efx_mtd_verify(mtd, erase->addr, erase->len, empty, 1);
+
+out:
+	if (rc == 0) {
+		erase->state = MTD_ERASE_DONE;
+	} else {
+		erase->state = MTD_ERASE_FAILED;
+#if !defined(EFX_USE_KCOMPAT) || defined(EFX_USE_MTD_ERASE_FAIL_ADDR)
+		erase->fail_addr = 0xffffffff;
+#endif
+	}
+	mtd_erase_callback(erase);
+	return rc;
+}
+
+static int efx_mtd_write(struct mtd_info *mtd, loff_t start,
+			 size_t len, size_t *retlen, const u8 *buffer)
+{
+	struct efx_mtd *efx_mtd = mtd->priv;
+	struct efx_spi_device *spi;
+	unsigned int command;
+	unsigned int block_len;
+	unsigned int pos = 0;
+	int rc;
+
+	rc = down_interruptible(&efx_mtd->access_lock);
+	if (rc)
+		goto out;
+	spi = efx_mtd->spi;
+
+	rc = efx_spi_unlock(efx_mtd);
+	if (rc)
+		goto out_up;
+
+	while (pos < len) {
+		rc = efx_spi_write_enable(efx_mtd);
+		if (rc)
+			break;
+
+		block_len = min((unsigned int)len - pos,
+				efx_spi_write_limit(spi, start + pos));
+		command = efx_spi_munge_command(spi, SPI_WRITE, start + pos);
+		rc = spi->write(spi, efx_mtd->efx, command, start + pos,
+				buffer + pos, block_len);
+		if (rc)
+			break;
+		pos += block_len;
+
+		rc = efx_spi_fast_wait(efx_mtd);
+		if (rc)
+			break;
+
+		/* Avoid locking up the system */
+		cond_resched();
+		if (signal_pending(current)) {
+			rc = -EINTR;
+			break;
+		}
+	}
+
+out_up:
+	up(&efx_mtd->access_lock);
+	if (rc == 0)
+		rc = efx_mtd_verify(mtd, start, len, buffer, 0);
+out:
+	*retlen = pos;
+	return rc;
+}
+
+static void efx_mtd_sync(struct mtd_info *mtd)
+{
+	struct efx_mtd *efx_mtd = mtd->priv;
+	int rc;
+
+	down(&efx_mtd->access_lock);
+	rc = efx_spi_slow_wait(efx_mtd, 1);
+	if (rc)
+		EFX_ERR(efx_mtd->efx, "%s sync failed (%d)\n",
+			efx_mtd->name, rc);
+	up(&efx_mtd->access_lock);
+}
+
+/* Driverlink interface */
+
+static void efx_mtd_reset_suspend(struct efx_dl_device *efx_dev)
+{
+	struct efx_mtd *efx_mtd = efx_dev->priv;
+
+	if (!efx_mtd)
+		return;
+
+	/* Acquire lock to ensure that any in-progress operations have
+	 * completed, and no new ones can start.
+	 */
+	down(&efx_mtd->access_lock);
+}
+
+static void efx_mtd_reset_resume(struct efx_dl_device *efx_dev, int ok)
+{
+	struct efx_mtd *efx_mtd = efx_dev->priv;
+
+	if (!efx_mtd)
+		return;
+
+	/* If device reset failed already, or SPI device doesn't
+	 * become ready, disable device.
+	 */
+	if (!ok || efx_spi_slow_wait(efx_mtd, 1) != 0) {
+		efx_mtd->spi = &efx_spi_dummy_device;
+		EFX_ERR(efx_mtd->efx, "%s disabled after failed reset\n",
+			efx_mtd->name);
+	}
+
+	up(&efx_mtd->access_lock);
+}
+
+static void efx_mtd_remove(struct efx_dl_device *efx_dev)
+{
+	struct efx_mtd *efx_mtd = efx_dev->priv;
+
+	del_mtd_partitions(&efx_mtd->mtd);
+	kfree(efx_mtd);
+	efx_dev->priv = NULL;
+}
+
+static __devinit int efx_mtd_register(struct efx_mtd *efx_mtd,
+				      struct efx_dl_device *efx_dev,
+				      struct efx_nic *efx,
+				      struct efx_spi_device *spi,
+				      const char *type_name,
+				      const char **part_type_name,
+				      unsigned int num_parts)
+{
+	int i;
+
+	efx_dev->priv = efx_mtd;
+
+	efx_mtd->efx_dev = efx_dev;
+	efx_mtd->efx = efx;
+	efx_mtd->spi = spi;
+	sema_init(&efx_mtd->access_lock, 1);
+
+	efx_mtd->mtd.size = spi->size;
+	efx_mtd->mtd.erasesize = spi->erase_size;
+#if !defined(EFX_USE_KCOMPAT) || defined(EFX_USE_MTD_WRITESIZE)
+	efx_mtd->mtd.writesize = 1;
+#endif
+	if (snprintf(efx_mtd->name, sizeof(efx_mtd->name),
+		     "%s %s", efx->name, type_name) >=
+	    sizeof(efx_mtd->name))
+		return -ENAMETOOLONG;
+
+	efx_mtd->mtd.priv = efx_mtd;
+	efx_mtd->mtd.name = efx_mtd->name;
+	efx_mtd->mtd.erase = efx_mtd_erase;
+	efx_mtd->mtd.read = efx_mtd_read;
+	efx_mtd->mtd.write = efx_mtd_write;
+	efx_mtd->mtd.sync = efx_mtd_sync;
+
+	for (i = 0; i < num_parts; i++) {
+		efx_mtd->part[i].name = efx_mtd->part_name[i];
+		if (snprintf(efx_mtd->part_name[i],
+			     sizeof(efx_mtd->part_name[i]),
+			     "%s %s", efx->name, part_type_name[i]) >=
+		    sizeof(efx_mtd->part_name[i]))
+			return -ENAMETOOLONG;
+
+		if (efx_allow_nvconfig_writes)
+			efx_mtd->part[i].mask_flags &= ~MTD_WRITEABLE;
+	}
+
+	return add_mtd_partitions(&efx_mtd->mtd, efx_mtd->part, num_parts);
+}
+
+static int __devinit
+efx_flash_probe(struct efx_dl_device *efx_dev,
+		const struct net_device *net_dev,
+		const struct efx_dl_device_info *dev_info,
+		const char *silicon_rev)
+{
+	struct efx_nic *efx = efx_dl_get_nic(efx_dev);
+	struct efx_mtd *efx_mtd;
+	const char *part_type_name[2];
+	unsigned int num_parts;
+	int rc;
+
+	if (!efx->spi_flash)
+		return -ENODEV;
+
+	efx_mtd = kzalloc(sizeof(*efx_mtd), GFP_KERNEL);
+	if (!efx_mtd)
+		return -ENOMEM;
+
+	efx_mtd->mtd.type = MTD_NORFLASH;
+	efx_mtd->mtd.flags = MTD_CAP_NORFLASH;
+
+	part_type_name[0] = "sfc_flash_config";
+	efx_mtd->part[0].offset = 0;
+	efx_mtd->part[0].size = min(efx->spi_flash->size,
+				    EFX_FLASH_BOOTROM_OFFSET);
+	efx_mtd->part[0].mask_flags = MTD_WRITEABLE;
+
+	if (efx->spi_flash->size <= EFX_FLASH_BOOTROM_OFFSET) {
+		num_parts = 1;
+	} else {
+		part_type_name[1] = "sfc_flash_bootrom";
+		efx_mtd->part[1].offset = EFX_FLASH_BOOTROM_OFFSET;
+		efx_mtd->part[1].size = (efx->spi_flash->size
+					 - EFX_FLASH_BOOTROM_OFFSET);
+		num_parts = 2;
+	}
+
+	rc = efx_mtd_register(efx_mtd, efx_dev, efx, efx->spi_flash,
+			      "sfc_flash", part_type_name, num_parts);
+	if (rc)
+		kfree(efx_mtd);
+	return rc;
+}
+
+static struct efx_dl_driver efx_flash_driver = {
+	.name		= "sfc_flash",
+	.probe		= efx_flash_probe,
+	.remove		= efx_mtd_remove,
+	.reset_suspend	= efx_mtd_reset_suspend,
+	.reset_resume	= efx_mtd_reset_resume,
+};
+
+static int __devinit
+efx_eeprom_probe(struct efx_dl_device *efx_dev,
+		 const struct net_device *net_dev,
+		 const struct efx_dl_device_info *dev_info,
+		 const char *silicon_rev)
+{
+	struct efx_nic *efx = efx_dl_get_nic(efx_dev);
+	struct efx_mtd *efx_mtd;
+	const char *type_name;
+	const char *part_type_name[1];
+	int rc;
+
+	if (!efx->spi_eeprom)
+		return -ENODEV;
+
+	efx_mtd = kzalloc(sizeof(*efx_mtd), GFP_KERNEL);
+	if (!efx_mtd)
+		return -ENOMEM;
+
+	efx_mtd->mtd.type = MTD_RAM;
+	efx_mtd->mtd.flags = MTD_CAP_RAM;
+
+	efx_mtd->part[0].offset = 0;
+	efx_mtd->part[0].size = efx->spi_eeprom->size;
+	efx_mtd->part[0].mask_flags = MTD_WRITEABLE;
+
+	if (efx->spi_eeprom->size <= 0x200) {
+		type_name = "sfc_small_eeprom";
+		part_type_name[0] = "sfc_small_config";
+	} else {
+		type_name = "sfc_large_eeprom";
+		part_type_name[0] = "sfc_large_config";
+	}
+
+	rc = efx_mtd_register(efx_mtd, efx_dev, efx, efx->spi_eeprom,
+			      type_name, part_type_name, 1);
+	if (rc)
+		kfree(efx_mtd);
+	return rc;
+}
+
+static struct efx_dl_driver efx_eeprom_driver = {
+	.name		= "sfc_eeprom",
+	.probe		= efx_eeprom_probe,
+	.remove		= efx_mtd_remove,
+	.reset_suspend	= efx_mtd_reset_suspend,
+	.reset_resume	= efx_mtd_reset_resume,
+};
+
+/* Kernel module interface */
+
+#ifdef EFX_NOT_UPSTREAM
+module_param(efx_allow_nvconfig_writes, uint, 0644);
+MODULE_PARM_DESC(efx_allow_nvconfig_writes,
+		 "Allow writes to non-volatile configuration");
+#endif /* EFX_NOT_UPSTREAM */
+
+static int __init efx_mtd_init_module(void)
+{
+	int rc;
+
+	rc = efx_dl_register_driver(&efx_flash_driver);
+	if (rc)
+		return rc;
+	rc = efx_dl_register_driver(&efx_eeprom_driver);
+	if (rc) {
+		efx_dl_unregister_driver(&efx_flash_driver);
+		return rc;
+	}
+
+	return 0;
+}
+
+static void __exit efx_mtd_exit_module(void)
+{
+	efx_dl_unregister_driver(&efx_eeprom_driver);
+	efx_dl_unregister_driver(&efx_flash_driver);
+}
+
+module_init(efx_mtd_init_module);
+module_exit(efx_mtd_exit_module);
+
+MODULE_AUTHOR("Michael Brown <mbrown@fensystems.co.uk> and "
+	      "Solarflare Communications");
+MODULE_DESCRIPTION("SFC MTD driver");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 2a84468..9a32fea 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -640,6 +640,11 @@ union efx_multicast_hash {
  *	This register is written with the SMP processor ID whenever an
  *	interrupt is handled.  It is used by falcon_test_interrupt()
  *	to verify that an interrupt has occurred.
+ * @spi_flash: SPI flash device
+ *	This field will be %NULL if no flash device is present.
+ * @spi_eeprom: SPI EEPROM device
+ *	This field will be %NULL if no EEPROM device is present.
+ * @spi_lock: SPI bus lock
  * @n_rx_nodesc_drop_cnt: RX no descriptor drop count
  * @nic_data: Hardware dependant state
  * @mac_lock: MAC access lock. Protects @port_enabled, efx_monitor() and
@@ -716,6 +721,10 @@ struct efx_nic {
 	struct efx_buffer irq_status;
 	volatile signed int last_irq_cpu;

+	struct efx_spi_device *spi_flash;
+	struct efx_spi_device *spi_eeprom;
+	struct mutex spi_lock;
+
 	unsigned n_rx_nodesc_drop_cnt;

 	struct falcon_nic_data *nic_data;
diff --git a/drivers/net/sfc/spi.h b/drivers/net/sfc/spi.h
index 34412f3..bd9bde7 100644
--- a/drivers/net/sfc/spi.h
+++ b/drivers/net/sfc/spi.h
@@ -68,4 +68,102 @@
 /* Device busy flag */
 #define SPI_STATUS_NRDY 0x01

+/**************************************************************************
+ *
+ * Efx SPI devices
+ *
+ **************************************************************************
+ */
+
+/**
+ * struct efx_spi_device - an Efx SPI (Serial Peripheral Interface) device
+ * @device_id:		Controller's id for the device
+ * @size:		Size (in bytes)
+ * @addr_len:		Number of address bytes in read/write commands
+ * @munge_address:	Flag whether addresses should be munged.
+ *	Some devices with 9-bit addresses (e.g. AT25040A EEPROM)
+ *	use bit 3 of the command byte as address bit A8, rather
+ *	than having a two-byte address.  If this flag is set, then
+ *	commands should be munged in this way.
+ * @erase_command:	Erase command (or 0 if sector erase not needed).
+ * @erase_size:		Erase sector size (in bytes)
+ *	Erase commands affect sectors with this size and alignment.
+ *	This must be a power of two.
+ * @block_size:		Write block size (in bytes).
+ *	Write commands are limited to blocks with this size and alignment.
+ * @read:		Read function for the device
+ * @write:		Write function for the device
+ */
+struct efx_spi_device {
+	int device_id;
+	unsigned int size;
+	unsigned int addr_len;
+	unsigned int munge_address:1;
+	u8 erase_command;
+	unsigned int erase_size;
+	unsigned int block_size;
+	int (*read) (const struct efx_spi_device *spi,
+		     struct efx_nic *efx, unsigned int command,
+		     int address, void *data, unsigned int len);
+	int (*write) (const struct efx_spi_device *spi,
+		      struct efx_nic *efx, unsigned int command,
+		      int address, const void *data, unsigned int len);
+};
+
+/* Maximum length for SPI read or write through Falcon */
+#define FALCON_SPI_MAX_LEN sizeof(efx_oword_t)
+
+/**
+ * efx_spi_write_limit - calculate maximum permitted length for write
+ * @spi:		SPI device description
+ * @start:		Starting address
+ *
+ * Return the maximum length for a write starting at the given address
+ * in the device.
+ *
+ * SPI writes must not cross block boundaries.  Devices tend
+ * to wrap addresses at block boundaries; e.g. trying to write 5 bytes
+ * starting at offset 14 with a block size of 16 might write
+ * {14,15,0,1,2} rather than {14,15,16,17,18}.
+ */
+static inline unsigned int
+efx_spi_write_limit(const struct efx_spi_device *spi, unsigned int start)
+{
+	return min(FALCON_SPI_MAX_LEN,
+		   (spi->block_size - (start & (spi->block_size - 1))));
+}
+
+/**
+ * efx_spi_read_limit - calculate maximum permitted length for read
+ * @spi:		SPI device description
+ * @start:		Starting address
+ *
+ * Return the maximum length for a read starting at the given address
+ * in the device.
+ */
+static inline unsigned int
+efx_spi_read_limit(const struct efx_spi_device *spi __attribute__ ((unused)),
+		   unsigned int start __attribute__ ((unused)))
+{
+	return FALCON_SPI_MAX_LEN;
+}
+
+/**
+ * efx_spi_munge_command - adjust command as necessary for given address
+ * @spi:		SPI device description
+ * @command:		Normal SPI command
+ * @address:		Address for command
+ *
+ * Some devices with 9-bit addresses (e.g. AT25040A EEPROM) use bit 3
+ * of the command byte as address bit A8, rather than having a
+ * two-byte address.  This function calculates the appropriate command
+ * byte for the device, taking this munging into account.
+ */
+static inline u8 efx_spi_munge_command(const struct efx_spi_device *spi,
+					    const u8 command,
+					    const unsigned int address)
+{
+	return (command | (((address >> 8) & spi->munge_address) << 3));
+}
+
 #endif /* EFX_SPI_H */
-- 
1.5.3.7

