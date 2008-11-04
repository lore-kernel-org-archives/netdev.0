From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3/6] sfc: Expose flash region storing boot code as MTD
Date: Tue, 4 Nov 2008 20:34:28 +0000
Message-ID: <20081104203427.GZ7331@solarflare.com>
References: <20081104203117.GW7331@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-mtd@lists.infradead.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:60144 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752798AbYKDUei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 15:34:38 -0500
Content-Disposition: inline
In-Reply-To: <20081104203117.GW7331@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The boot code that appears as a PCI expansion ROM on the SFC4000 is
stored in flash.  Expose this as a standard MTD device to allow for
in-place upgrades.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/Kconfig      |    8 ++
 drivers/net/sfc/Makefile     |    1 +
 drivers/net/sfc/efx.c        |    7 +
 drivers/net/sfc/efx.h        |   10 ++
 drivers/net/sfc/ethtool.c    |    4 +
 drivers/net/sfc/falcon.c     |   17 ++-
 drivers/net/sfc/mtd.c        |  268 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/net_driver.h |    2 +
 drivers/net/sfc/spi.h        |   17 +++-
 9 files changed, 327 insertions(+), 7 deletions(-)
 create mode 100644 drivers/net/sfc/mtd.c

diff --git a/drivers/net/sfc/Kconfig b/drivers/net/sfc/Kconfig
index 3be13b5..3e25fb3 100644
--- a/drivers/net/sfc/Kconfig
+++ b/drivers/net/sfc/Kconfig
@@ -12,3 +12,11 @@ config SFC
 
 	  To compile this driver as a module, choose M here.  The module
 	  will be called sfc.
+config SFC_MTD
+	bool "Solarflare Solarstorm SFC4000 flash MTD support"
+	depends on SFC && MTD
+	default y
+	help
+	  This exposes the on-board flash memory as an MTD device (e.g.
+          /dev/mtd1).  This makes it possible to upload new boot code
+          to the NIC.
diff --git a/drivers/net/sfc/Makefile b/drivers/net/sfc/Makefile
index c8f5704..e507daa 100644
--- a/drivers/net/sfc/Makefile
+++ b/drivers/net/sfc/Makefile
@@ -1,5 +1,6 @@
 sfc-y			+= efx.o falcon.o tx.o rx.o falcon_xmac.o \
 			   selftest.o ethtool.o xfp_phy.o \
 			   mdio_10g.o tenxpress.o boards.o sfe4001.o
+sfc-$(CONFIG_SFC_MTD)	+= mtd.o
 
 obj-$(CONFIG_SFC)	+= sfc.o
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 5b05789..f913937 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1459,6 +1459,7 @@ static int efx_netdev_event(struct notifier_block *this,
 		struct efx_nic *efx = netdev_priv(net_dev);
 
 		strcpy(efx->name, net_dev->name);
+		efx_mtd_rename(efx);
 	}
 
 	return NOTIFY_DONE;
@@ -1550,6 +1551,7 @@ void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 
 	efx_stop_all(efx);
 	mutex_lock(&efx->mac_lock);
+	mutex_lock(&efx->spi_lock);
 
 	rc = falcon_xmac_get_settings(efx, ecmd);
 	if (rc)
@@ -1582,6 +1584,7 @@ int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd, bool ok)
 			EFX_ERR(efx, "could not restore PHY settings\n");
 	}
 
+	mutex_unlock(&efx->spi_lock);
 	mutex_unlock(&efx->mac_lock);
 
 	if (ok) {
@@ -1777,6 +1780,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	memset(efx, 0, sizeof(*efx));
 	spin_lock_init(&efx->biu_lock);
 	spin_lock_init(&efx->phy_lock);
+	mutex_init(&efx->spi_lock);
 	INIT_WORK(&efx->reset_work, efx_reset_work);
 	INIT_DELAYED_WORK(&efx->monitor_work, efx_monitor);
 	efx->pci_dev = pci_dev;
@@ -1911,6 +1915,8 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 	if (!efx)
 		return;
 
+	efx_mtd_remove(efx);
+
 	/* Mark the NIC as fini, then stop the interface */
 	rtnl_lock();
 	efx->state = STATE_FINI;
@@ -2077,6 +2083,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 
 	EFX_LOG(efx, "initialisation successful\n");
 
+	efx_mtd_probe(efx); /* allowed to fail */
 	return 0;
 
  fail5:
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index d02937b..dd0d45b 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -58,6 +58,16 @@ extern int efx_port_dummy_op_int(struct efx_nic *efx);
 extern void efx_port_dummy_op_void(struct efx_nic *efx);
 extern void efx_port_dummy_op_blink(struct efx_nic *efx, bool blink);
 
+/* MTD */
+#ifdef CONFIG_SFC_MTD
+extern int efx_mtd_probe(struct efx_nic *efx);
+extern void efx_mtd_rename(struct efx_nic *efx);
+extern void efx_mtd_remove(struct efx_nic *efx);
+#else
+static inline int efx_mtd_probe(struct efx_nic *efx) { return 0; }
+static inline void efx_mtd_rename(struct efx_nic *efx) {}
+static inline void efx_mtd_remove(struct efx_nic *efx) {}
+#endif
 
 extern unsigned int efx_monitor_interval;
 
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index df0579e..abd8fcd 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -554,8 +554,10 @@ static int efx_ethtool_get_eeprom(struct net_device *net_dev,
 	size_t len;
 	int rc;
 
+	mutex_lock(&efx->spi_lock);
 	rc = falcon_spi_read(spi, eeprom->offset + EFX_EEPROM_BOOTCONFIG_START,
 			     eeprom->len, &len, buf);
+	mutex_unlock(&efx->spi_lock);
 	eeprom->magic = EFX_ETHTOOL_EEPROM_MAGIC;
 	eeprom->len = len;
 	return rc;
@@ -572,8 +574,10 @@ static int efx_ethtool_set_eeprom(struct net_device *net_dev,
 	if (eeprom->magic != EFX_ETHTOOL_EEPROM_MAGIC)
 		return -EINVAL;
 
+	mutex_lock(&efx->spi_lock);
 	rc = falcon_spi_write(spi, eeprom->offset + EFX_EEPROM_BOOTCONFIG_START,
 			      eeprom->len, &len, buf);
+	mutex_unlock(&efx->spi_lock);
 	eeprom->len = len;
 	return rc;
 }
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 3f74cef..71e0bed 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1628,9 +1628,9 @@ static int falcon_spi_wait(struct efx_nic *efx)
 	}
 }
 
-static int falcon_spi_cmd(const struct efx_spi_device *spi,
-			  unsigned int command, int address,
-			  const void *in, void *out, unsigned int len)
+int falcon_spi_cmd(const struct efx_spi_device *spi,
+		   unsigned int command, int address,
+		   const void *in, void *out, unsigned int len)
 {
 	struct efx_nic *efx = spi->efx;
 	bool addressed = (address >= 0);
@@ -1641,6 +1641,7 @@ static int falcon_spi_cmd(const struct efx_spi_device *spi,
 	/* Input validation */
 	if (len > FALCON_SPI_MAX_LEN)
 		return -EINVAL;
+	BUG_ON(!mutex_is_locked(&efx->spi_lock));
 
 	/* Check SPI not currently being accessed */
 	rc = falcon_spi_wait(efx);
@@ -1699,8 +1700,7 @@ efx_spi_munge_command(const struct efx_spi_device *spi,
 	return command | (((address >> 8) & spi->munge_address) << 3);
 }
 
-
-static int falcon_spi_fast_wait(const struct efx_spi_device *spi)
+int falcon_spi_fast_wait(const struct efx_spi_device *spi)
 {
 	u8 status;
 	int i, rc;
@@ -2259,7 +2259,9 @@ int falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 	nvconfig = region + NVCONFIG_OFFSET;
 
 	spi = efx->spi_flash ? efx->spi_flash : efx->spi_eeprom;
+	mutex_lock(&efx->spi_lock);
 	rc = falcon_spi_read(spi, 0, FALCON_NVCONFIG_END, NULL, region);
+	mutex_unlock(&efx->spi_lock);
 	if (rc) {
 		EFX_ERR(efx, "Failed to read %s\n",
 			efx->spi_flash ? "flash" : "EEPROM");
@@ -2555,6 +2557,11 @@ static int falcon_spi_device_init(struct efx_nic *efx,
 			SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_ADDR_LEN);
 		spi_device->munge_address = (spi_device->size == 1 << 9 &&
 					     spi_device->addr_len == 1);
+		spi_device->erase_command =
+			SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_ERASE_CMD);
+		spi_device->erase_size =
+			1 << SPI_DEV_TYPE_FIELD(device_type,
+						SPI_DEV_TYPE_ERASE_SIZE);
 		spi_device->block_size =
 			1 << SPI_DEV_TYPE_FIELD(device_type,
 						SPI_DEV_TYPE_BLOCK_SIZE);
diff --git a/drivers/net/sfc/mtd.c b/drivers/net/sfc/mtd.c
new file mode 100644
index 0000000..a1e6c28
--- /dev/null
+++ b/drivers/net/sfc/mtd.c
@@ -0,0 +1,268 @@
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
+#include <linux/delay.h>
+
+#define EFX_DRIVER_NAME "sfc_mtd"
+#include "net_driver.h"
+#include "spi.h"
+
+#define EFX_SPI_VERIFY_BUF_LEN 16
+
+struct efx_mtd {
+	const struct efx_spi_device *spi;
+	struct mtd_info mtd;
+	char name[IFNAMSIZ + 20];
+};
+
+/* SPI utilities */
+
+static int efx_spi_slow_wait(struct efx_mtd *efx_mtd, bool uninterruptible)
+{
+	const struct efx_spi_device *spi = efx_mtd->spi;
+	struct efx_nic *efx = spi->efx;
+	u8 status;
+	int rc, i;
+
+	/* Wait up to 4s for flash/EEPROM to finish a slow operation. */
+	for (i = 0; i < 40; i++) {
+		__set_current_state(uninterruptible ?
+				    TASK_UNINTERRUPTIBLE : TASK_INTERRUPTIBLE);
+		schedule_timeout(HZ / 10);
+		rc = falcon_spi_cmd(spi, SPI_RDSR, -1, NULL,
+				    &status, sizeof(status));
+		if (rc)
+			return rc;
+		if (!(status & SPI_STATUS_NRDY))
+			return 0;
+		if (signal_pending(current))
+			return -EINTR;
+	}
+	EFX_ERR(efx, "timed out waiting for %s\n", efx_mtd->name);
+	return -ETIMEDOUT;
+}
+
+static int efx_spi_unlock(const struct efx_spi_device *spi)
+{
+	const u8 unlock_mask = (SPI_STATUS_BP2 | SPI_STATUS_BP1 |
+				SPI_STATUS_BP0);
+	u8 status;
+	int rc;
+
+	rc = falcon_spi_cmd(spi, SPI_RDSR, -1, NULL, &status, sizeof(status));
+	if (rc)
+		return rc;
+
+	if (!(status & unlock_mask))
+		return 0; /* already unlocked */
+
+	rc = falcon_spi_cmd(spi, SPI_WREN, -1, NULL, NULL, 0);
+	if (rc)
+		return rc;
+	rc = falcon_spi_cmd(spi, SPI_SST_EWSR, -1, NULL, NULL, 0);
+	if (rc)
+		return rc;
+
+	status &= ~unlock_mask;
+	rc = falcon_spi_cmd(spi, SPI_WRSR, -1, &status, NULL, sizeof(status));
+	if (rc)
+		return rc;
+	rc = falcon_spi_fast_wait(spi);
+	if (rc)
+		return rc;
+
+	return 0;
+}
+
+static int efx_spi_erase(struct efx_mtd *efx_mtd, loff_t start, size_t len)
+{
+	const struct efx_spi_device *spi = efx_mtd->spi;
+	unsigned pos, block_len;
+	u8 empty[EFX_SPI_VERIFY_BUF_LEN];
+	u8 buffer[EFX_SPI_VERIFY_BUF_LEN];
+	int rc;
+
+	if (len != spi->erase_size)
+		return -EINVAL;
+
+	if (spi->erase_command == 0)
+		return -EOPNOTSUPP;
+
+	rc = efx_spi_unlock(spi);
+	if (rc)
+		return rc;
+	rc = falcon_spi_cmd(spi, SPI_WREN, -1, NULL, NULL, 0);
+	if (rc)
+		return rc;
+	rc = falcon_spi_cmd(spi, spi->erase_command, start, NULL, NULL, 0);
+	if (rc)
+		return rc;
+	rc = efx_spi_slow_wait(efx_mtd, false);
+
+	/* Verify the entire region has been wiped */
+	memset(empty, 0xff, sizeof(empty));
+	for (pos = 0; pos < len; pos += block_len) {
+		block_len = min(len - pos, sizeof(buffer));
+		rc = falcon_spi_read(spi, start + pos, block_len, NULL, buffer);
+		if (rc)
+			return rc;
+		if (memcmp(empty, buffer, block_len))
+			return -EIO;
+
+		/* Avoid locking up the system */
+		cond_resched();
+		if (signal_pending(current))
+			return -EINTR;
+	}
+
+	return rc;
+}
+
+/* MTD interface */
+
+static int efx_mtd_read(struct mtd_info *mtd, loff_t start, size_t len,
+			size_t *retlen, u8 *buffer)
+{
+	struct efx_mtd *efx_mtd = mtd->priv;
+	const struct efx_spi_device *spi = efx_mtd->spi;
+	struct efx_nic *efx = spi->efx;
+	int rc;
+
+	rc = mutex_lock_interruptible(&efx->spi_lock);
+	if (rc)
+		return rc;
+	rc = falcon_spi_read(spi, FALCON_FLASH_BOOTCODE_START + start,
+			     len, retlen, buffer);
+	mutex_unlock(&efx->spi_lock);
+	return rc;
+}
+
+static int efx_mtd_erase(struct mtd_info *mtd, struct erase_info *erase)
+{
+	struct efx_mtd *efx_mtd = mtd->priv;
+	struct efx_nic *efx = efx_mtd->spi->efx;
+	int rc;
+
+	rc = mutex_lock_interruptible(&efx->spi_lock);
+	if (rc)
+		return rc;
+	rc = efx_spi_erase(efx_mtd, FALCON_FLASH_BOOTCODE_START + erase->addr,
+			   erase->len);
+	mutex_unlock(&efx->spi_lock);
+
+	if (rc == 0) {
+		erase->state = MTD_ERASE_DONE;
+	} else {
+		erase->state = MTD_ERASE_FAILED;
+		erase->fail_addr = 0xffffffff;
+	}
+	mtd_erase_callback(erase);
+	return rc;
+}
+
+static int efx_mtd_write(struct mtd_info *mtd, loff_t start,
+			 size_t len, size_t *retlen, const u8 *buffer)
+{
+	struct efx_mtd *efx_mtd = mtd->priv;
+	const struct efx_spi_device *spi = efx_mtd->spi;
+	struct efx_nic *efx = spi->efx;
+	int rc;
+
+	rc = mutex_lock_interruptible(&efx->spi_lock);
+	if (rc)
+		return rc;
+	rc = falcon_spi_write(spi, FALCON_FLASH_BOOTCODE_START + start,
+			      len, retlen, buffer);
+	mutex_unlock(&efx->spi_lock);
+	return rc;
+}
+
+static void efx_mtd_sync(struct mtd_info *mtd)
+{
+	struct efx_mtd *efx_mtd = mtd->priv;
+	struct efx_nic *efx = efx_mtd->spi->efx;
+	int rc;
+
+	mutex_lock(&efx->spi_lock);
+	rc = efx_spi_slow_wait(efx_mtd, true);
+	mutex_unlock(&efx->spi_lock);
+
+	if (rc)
+		EFX_ERR(efx, "%s sync failed (%d)\n", efx_mtd->name, rc);
+	return;
+}
+
+void efx_mtd_remove(struct efx_nic *efx)
+{
+	if (efx->spi_flash && efx->spi_flash->mtd) {
+		struct efx_mtd *efx_mtd = efx->spi_flash->mtd;
+		int rc;
+
+		for (;;) {
+			rc = del_mtd_device(&efx_mtd->mtd);
+			if (rc != -EBUSY)
+				break;
+			ssleep(1);
+		}
+		WARN_ON(rc);
+		kfree(efx_mtd);
+	}
+}
+
+void efx_mtd_rename(struct efx_nic *efx)
+{
+	if (efx->spi_flash && efx->spi_flash->mtd) {
+		struct efx_mtd *efx_mtd = efx->spi_flash->mtd;
+		snprintf(efx_mtd->name, sizeof(efx_mtd->name),
+			 "%s sfc_flash_bootrom", efx->name);
+	}
+}
+
+int efx_mtd_probe(struct efx_nic *efx)
+{
+	struct efx_spi_device *spi = efx->spi_flash;
+	struct efx_mtd *efx_mtd;
+
+	if (!spi || spi->size <= FALCON_FLASH_BOOTCODE_START)
+		return -ENODEV;
+
+	efx_mtd = kzalloc(sizeof(*efx_mtd), GFP_KERNEL);
+	if (!efx_mtd)
+		return -ENOMEM;
+
+	efx_mtd->spi = spi;
+	spi->mtd = efx_mtd;
+
+	efx_mtd->mtd.type = MTD_NORFLASH;
+	efx_mtd->mtd.flags = MTD_CAP_NORFLASH;
+	efx_mtd->mtd.size = spi->size - FALCON_FLASH_BOOTCODE_START;
+	efx_mtd->mtd.erasesize = spi->erase_size;
+	efx_mtd->mtd.writesize = 1;
+	efx_mtd_rename(efx);
+
+	efx_mtd->mtd.owner = THIS_MODULE;
+	efx_mtd->mtd.priv = efx_mtd;
+	efx_mtd->mtd.name = efx_mtd->name;
+	efx_mtd->mtd.erase = efx_mtd_erase;
+	efx_mtd->mtd.read = efx_mtd_read;
+	efx_mtd->mtd.write = efx_mtd_write;
+	efx_mtd->mtd.sync = efx_mtd_sync;
+
+	if (add_mtd_device(&efx_mtd->mtd)) {
+		kfree(efx_mtd);
+		spi->mtd = NULL;
+		/* add_mtd_device() returns 1 if the MTD table is full */
+		return -ENOMEM;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index cdb11fa..c953eb1 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -655,6 +655,7 @@ union efx_multicast_hash {
  *	This field will be %NULL if no flash device is present.
  * @spi_eeprom: SPI EEPROM device
  *	This field will be %NULL if no EEPROM device is present.
+ * @spi_lock: SPI bus lock
  * @n_rx_nodesc_drop_cnt: RX no descriptor drop count
  * @nic_data: Hardware dependant state
  * @mac_lock: MAC access lock. Protects @port_enabled, @phy_mode,
@@ -731,6 +732,7 @@ struct efx_nic {
 
 	struct efx_spi_device *spi_flash;
 	struct efx_spi_device *spi_eeprom;
+	struct mutex spi_lock;
 
 	unsigned n_rx_nodesc_drop_cnt;
 
diff --git a/drivers/net/sfc/spi.h b/drivers/net/sfc/spi.h
index b73f86c..c4aca13 100644
--- a/drivers/net/sfc/spi.h
+++ b/drivers/net/sfc/spi.h
@@ -25,6 +25,7 @@
 #define SPI_WRDI 0x04		/* Reset write enable latch */
 #define SPI_RDSR 0x05		/* Read status register */
 #define SPI_WREN 0x06		/* Set write enable latch */
+#define SPI_SST_EWSR 0x50	/* SST: Enable write to status register */
 
 #define SPI_STATUS_WPEN 0x80	/* Write-protect pin enabled */
 #define SPI_STATUS_BP2 0x10	/* Block protection bit 2 */
@@ -36,6 +37,7 @@
 /**
  * struct efx_spi_device - an Efx SPI (Serial Peripheral Interface) device
  * @efx:		The Efx controller that owns this device
+ * @mtd:		MTD state
  * @device_id:		Controller's id for the device
  * @size:		Size (in bytes)
  * @addr_len:		Number of address bytes in read/write commands
@@ -44,20 +46,30 @@
  *	use bit 3 of the command byte as address bit A8, rather
  *	than having a two-byte address.  If this flag is set, then
  *	commands should be munged in this way.
+ * @erase_command:	Erase command (or 0 if sector erase not needed).
+ * @erase_size:		Erase sector size (in bytes)
+ *	Erase commands affect sectors with this size and alignment.
+ *	This must be a power of two.
  * @block_size:		Write block size (in bytes).
  *	Write commands are limited to blocks with this size and alignment.
- * @read:		Read function for the device
- * @write:		Write function for the device
  */
 struct efx_spi_device {
 	struct efx_nic *efx;
+#ifdef CONFIG_SFC_MTD
+	void *mtd;
+#endif
 	int device_id;
 	unsigned int size;
 	unsigned int addr_len;
 	unsigned int munge_address:1;
+	u8 erase_command;
+	unsigned int erase_size;
 	unsigned int block_size;
 };
 
+int falcon_spi_cmd(const struct efx_spi_device *spi, unsigned int command,
+		   int address, const void* in, void *out, unsigned int len);
+int falcon_spi_fast_wait(const struct efx_spi_device *spi);
 int falcon_spi_read(const struct efx_spi_device *spi, loff_t start,
 		    size_t len, size_t *retlen, u8 *buffer);
 int falcon_spi_write(const struct efx_spi_device *spi, loff_t start,
@@ -77,6 +89,7 @@ int falcon_spi_write(const struct efx_spi_device *spi, loff_t start,
  * be absent or truncated depending on the devices used.
  */
 #define FALCON_NVCONFIG_END 0x400U
+#define FALCON_FLASH_BOOTCODE_START 0x8000U
 #define EFX_EEPROM_BOOTCONFIG_START 0x800U
 #define EFX_EEPROM_BOOTCONFIG_END 0x1800U
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
