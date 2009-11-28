From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 28/32] sfc: Extend MTD driver for use with new NICs
Date: Sat, 28 Nov 2009 03:51:54 +0000
Message-ID: <1259380314.2811.62.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42771 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753932AbZK1Dvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:51:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In new NICs flash is managed by firmware and we will use high-level
operations on partitions rather than direct SPI commands.  Add support
for multiple MTD partitions per flash device and remove the direct
link between MTD and SPI devices.  Maintain a list of MTD partitions
in struct efx_nic.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    3 +
 drivers/net/sfc/ethtool.c    |    6 +-
 drivers/net/sfc/falcon.c     |   32 ++---
 drivers/net/sfc/mtd.c        |  312 +++++++++++++++++++++++++++++-------------
 drivers/net/sfc/net_driver.h |    8 +-
 drivers/net/sfc/spi.h        |   18 +--
 6 files changed, 255 insertions(+), 124 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index fec11d6..c49d364 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1977,6 +1977,9 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	spin_lock_init(&efx->biu_lock);
 	mutex_init(&efx->mdio_lock);
 	mutex_init(&efx->spi_lock);
+#ifdef CONFIG_SFC_MTD
+	INIT_LIST_HEAD(&efx->mtd_list);
+#endif
 	INIT_WORK(&efx->reset_work, efx_reset_work);
 	INIT_DELAYED_WORK(&efx->monitor_work, efx_monitor);
 	efx->pci_dev = pci_dev;
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 5c18ca5..0a79ec7 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -580,7 +580,8 @@ static int efx_ethtool_get_eeprom(struct net_device *net_dev,
 	rc = mutex_lock_interruptible(&efx->spi_lock);
 	if (rc)
 		return rc;
-	rc = falcon_spi_read(spi, eeprom->offset + EFX_EEPROM_BOOTCONFIG_START,
+	rc = falcon_spi_read(efx, spi,
+			     eeprom->offset + EFX_EEPROM_BOOTCONFIG_START,
 			     eeprom->len, &len, buf);
 	mutex_unlock(&efx->spi_lock);
 
@@ -603,7 +604,8 @@ static int efx_ethtool_set_eeprom(struct net_device *net_dev,
 	rc = mutex_lock_interruptible(&efx->spi_lock);
 	if (rc)
 		return rc;
-	rc = falcon_spi_write(spi, eeprom->offset + EFX_EEPROM_BOOTCONFIG_START,
+	rc = falcon_spi_write(efx, spi,
+			      eeprom->offset + EFX_EEPROM_BOOTCONFIG_START,
 			      eeprom->len, &len, buf);
 	mutex_unlock(&efx->spi_lock);
 
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 0a7c3d2..f77bbbe 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1640,11 +1640,10 @@ static int falcon_spi_wait(struct efx_nic *efx)
 	}
 }
 
-int falcon_spi_cmd(const struct efx_spi_device *spi,
+int falcon_spi_cmd(struct efx_nic *efx, const struct efx_spi_device *spi,
 		   unsigned int command, int address,
 		   const void *in, void *out, size_t len)
 {
-	struct efx_nic *efx = spi->efx;
 	bool addressed = (address >= 0);
 	bool reading = (out != NULL);
 	efx_oword_t reg;
@@ -1713,15 +1712,15 @@ efx_spi_munge_command(const struct efx_spi_device *spi,
 }
 
 /* Wait up to 10 ms for buffered write completion */
-int falcon_spi_wait_write(const struct efx_spi_device *spi)
+int
+falcon_spi_wait_write(struct efx_nic *efx, const struct efx_spi_device *spi)
 {
-	struct efx_nic *efx = spi->efx;
 	unsigned long timeout = jiffies + 1 + DIV_ROUND_UP(HZ, 100);
 	u8 status;
 	int rc;
 
 	for (;;) {
-		rc = falcon_spi_cmd(spi, SPI_RDSR, -1, NULL,
+		rc = falcon_spi_cmd(efx, spi, SPI_RDSR, -1, NULL,
 				    &status, sizeof(status));
 		if (rc)
 			return rc;
@@ -1737,8 +1736,8 @@ int falcon_spi_wait_write(const struct efx_spi_device *spi)
 	}
 }
 
-int falcon_spi_read(const struct efx_spi_device *spi, loff_t start,
-		    size_t len, size_t *retlen, u8 *buffer)
+int falcon_spi_read(struct efx_nic *efx, const struct efx_spi_device *spi,
+		    loff_t start, size_t len, size_t *retlen, u8 *buffer)
 {
 	size_t block_len, pos = 0;
 	unsigned int command;
@@ -1748,7 +1747,7 @@ int falcon_spi_read(const struct efx_spi_device *spi, loff_t start,
 		block_len = min(len - pos, FALCON_SPI_MAX_LEN);
 
 		command = efx_spi_munge_command(spi, SPI_READ, start + pos);
-		rc = falcon_spi_cmd(spi, command, start + pos, NULL,
+		rc = falcon_spi_cmd(efx, spi, command, start + pos, NULL,
 				    buffer + pos, block_len);
 		if (rc)
 			break;
@@ -1767,8 +1766,9 @@ int falcon_spi_read(const struct efx_spi_device *spi, loff_t start,
 	return rc;
 }
 
-int falcon_spi_write(const struct efx_spi_device *spi, loff_t start,
-		     size_t len, size_t *retlen, const u8 *buffer)
+int
+falcon_spi_write(struct efx_nic *efx, const struct efx_spi_device *spi,
+		 loff_t start, size_t len, size_t *retlen, const u8 *buffer)
 {
 	u8 verify_buffer[FALCON_SPI_MAX_LEN];
 	size_t block_len, pos = 0;
@@ -1776,24 +1776,24 @@ int falcon_spi_write(const struct efx_spi_device *spi, loff_t start,
 	int rc = 0;
 
 	while (pos < len) {
-		rc = falcon_spi_cmd(spi, SPI_WREN, -1, NULL, NULL, 0);
+		rc = falcon_spi_cmd(efx, spi, SPI_WREN, -1, NULL, NULL, 0);
 		if (rc)
 			break;
 
 		block_len = min(len - pos,
 				falcon_spi_write_limit(spi, start + pos));
 		command = efx_spi_munge_command(spi, SPI_WRITE, start + pos);
-		rc = falcon_spi_cmd(spi, command, start + pos,
+		rc = falcon_spi_cmd(efx, spi, command, start + pos,
 				    buffer + pos, NULL, block_len);
 		if (rc)
 			break;
 
-		rc = falcon_spi_wait_write(spi);
+		rc = falcon_spi_wait_write(efx, spi);
 		if (rc)
 			break;
 
 		command = efx_spi_munge_command(spi, SPI_READ, start + pos);
-		rc = falcon_spi_cmd(spi, command, start + pos,
+		rc = falcon_spi_cmd(efx, spi, command, start + pos,
 				    NULL, verify_buffer, block_len);
 		if (memcmp(verify_buffer, buffer + pos, block_len)) {
 			rc = -EIO;
@@ -2352,7 +2352,7 @@ falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 	nvconfig = region + FALCON_NVCONFIG_OFFSET;
 
 	mutex_lock(&efx->spi_lock);
-	rc = falcon_spi_read(spi, 0, FALCON_NVCONFIG_END, NULL, region);
+	rc = falcon_spi_read(efx, spi, 0, FALCON_NVCONFIG_END, NULL, region);
 	mutex_unlock(&efx->spi_lock);
 	if (rc) {
 		EFX_ERR(efx, "Failed to read %s\n",
@@ -2710,8 +2710,6 @@ static int falcon_spi_device_init(struct efx_nic *efx,
 		spi_device->block_size =
 			1 << SPI_DEV_TYPE_FIELD(device_type,
 						SPI_DEV_TYPE_BLOCK_SIZE);
-
-		spi_device->efx = efx;
 	} else {
 		spi_device = NULL;
 	}
diff --git a/drivers/net/sfc/mtd.c b/drivers/net/sfc/mtd.c
index 820c233..3121e24 100644
--- a/drivers/net/sfc/mtd.c
+++ b/drivers/net/sfc/mtd.c
@@ -11,26 +11,58 @@
 #include <linux/module.h>
 #include <linux/mtd/mtd.h>
 #include <linux/delay.h>
+#include <linux/rtnetlink.h>
 
 #define EFX_DRIVER_NAME "sfc_mtd"
 #include "net_driver.h"
 #include "spi.h"
 #include "efx.h"
+#include "falcon.h"
 
 #define EFX_SPI_VERIFY_BUF_LEN 16
 
-struct efx_mtd {
-	const struct efx_spi_device *spi;
+struct efx_mtd_partition {
 	struct mtd_info mtd;
+	size_t offset;
+	const char *type_name;
 	char name[IFNAMSIZ + 20];
 };
 
+struct efx_mtd_ops {
+	int (*read)(struct mtd_info *mtd, loff_t start, size_t len,
+		    size_t *retlen, u8 *buffer);
+	int (*erase)(struct mtd_info *mtd, loff_t start, size_t len);
+	int (*write)(struct mtd_info *mtd, loff_t start, size_t len,
+		     size_t *retlen, const u8 *buffer);
+	int (*sync)(struct mtd_info *mtd);
+};
+
+struct efx_mtd {
+	struct list_head node;
+	struct efx_nic *efx;
+	const struct efx_spi_device *spi;
+	const char *name;
+	const struct efx_mtd_ops *ops;
+	size_t n_parts;
+	struct efx_mtd_partition part[0];
+};
+
+#define efx_for_each_partition(part, efx_mtd)			\
+	for ((part) = &(efx_mtd)->part[0];			\
+	     (part) != &(efx_mtd)->part[(efx_mtd)->n_parts];	\
+	     (part)++)
+
+#define to_efx_mtd_partition(mtd)				\
+	container_of(mtd, struct efx_mtd_partition, mtd)
+
+static int falcon_mtd_probe(struct efx_nic *efx);
+
 /* SPI utilities */
 
 static int efx_spi_slow_wait(struct efx_mtd *efx_mtd, bool uninterruptible)
 {
 	const struct efx_spi_device *spi = efx_mtd->spi;
-	struct efx_nic *efx = spi->efx;
+	struct efx_nic *efx = efx_mtd->efx;
 	u8 status;
 	int rc, i;
 
@@ -39,7 +71,7 @@ static int efx_spi_slow_wait(struct efx_mtd *efx_mtd, bool uninterruptible)
 		__set_current_state(uninterruptible ?
 				    TASK_UNINTERRUPTIBLE : TASK_INTERRUPTIBLE);
 		schedule_timeout(HZ / 10);
-		rc = falcon_spi_cmd(spi, SPI_RDSR, -1, NULL,
+		rc = falcon_spi_cmd(efx, spi, SPI_RDSR, -1, NULL,
 				    &status, sizeof(status));
 		if (rc)
 			return rc;
@@ -52,32 +84,35 @@ static int efx_spi_slow_wait(struct efx_mtd *efx_mtd, bool uninterruptible)
 	return -ETIMEDOUT;
 }
 
-static int efx_spi_unlock(const struct efx_spi_device *spi)
+static int
+efx_spi_unlock(struct efx_nic *efx, const struct efx_spi_device *spi)
 {
 	const u8 unlock_mask = (SPI_STATUS_BP2 | SPI_STATUS_BP1 |
 				SPI_STATUS_BP0);
 	u8 status;
 	int rc;
 
-	rc = falcon_spi_cmd(spi, SPI_RDSR, -1, NULL, &status, sizeof(status));
+	rc = falcon_spi_cmd(efx, spi, SPI_RDSR, -1, NULL,
+			    &status, sizeof(status));
 	if (rc)
 		return rc;
 
 	if (!(status & unlock_mask))
 		return 0; /* already unlocked */
 
-	rc = falcon_spi_cmd(spi, SPI_WREN, -1, NULL, NULL, 0);
+	rc = falcon_spi_cmd(efx, spi, SPI_WREN, -1, NULL, NULL, 0);
 	if (rc)
 		return rc;
-	rc = falcon_spi_cmd(spi, SPI_SST_EWSR, -1, NULL, NULL, 0);
+	rc = falcon_spi_cmd(efx, spi, SPI_SST_EWSR, -1, NULL, NULL, 0);
 	if (rc)
 		return rc;
 
 	status &= ~unlock_mask;
-	rc = falcon_spi_cmd(spi, SPI_WRSR, -1, &status, NULL, sizeof(status));
+	rc = falcon_spi_cmd(efx, spi, SPI_WRSR, -1, &status,
+			    NULL, sizeof(status));
 	if (rc)
 		return rc;
-	rc = falcon_spi_wait_write(spi);
+	rc = falcon_spi_wait_write(efx, spi);
 	if (rc)
 		return rc;
 
@@ -87,6 +122,7 @@ static int efx_spi_unlock(const struct efx_spi_device *spi)
 static int efx_spi_erase(struct efx_mtd *efx_mtd, loff_t start, size_t len)
 {
 	const struct efx_spi_device *spi = efx_mtd->spi;
+	struct efx_nic *efx = efx_mtd->efx;
 	unsigned pos, block_len;
 	u8 empty[EFX_SPI_VERIFY_BUF_LEN];
 	u8 buffer[EFX_SPI_VERIFY_BUF_LEN];
@@ -98,13 +134,14 @@ static int efx_spi_erase(struct efx_mtd *efx_mtd, loff_t start, size_t len)
 	if (spi->erase_command == 0)
 		return -EOPNOTSUPP;
 
-	rc = efx_spi_unlock(spi);
+	rc = efx_spi_unlock(efx, spi);
 	if (rc)
 		return rc;
-	rc = falcon_spi_cmd(spi, SPI_WREN, -1, NULL, NULL, 0);
+	rc = falcon_spi_cmd(efx, spi, SPI_WREN, -1, NULL, NULL, 0);
 	if (rc)
 		return rc;
-	rc = falcon_spi_cmd(spi, spi->erase_command, start, NULL, NULL, 0);
+	rc = falcon_spi_cmd(efx, spi, spi->erase_command, start, NULL,
+			    NULL, 0);
 	if (rc)
 		return rc;
 	rc = efx_spi_slow_wait(efx_mtd, false);
@@ -113,7 +150,8 @@ static int efx_spi_erase(struct efx_mtd *efx_mtd, loff_t start, size_t len)
 	memset(empty, 0xff, sizeof(empty));
 	for (pos = 0; pos < len; pos += block_len) {
 		block_len = min(len - pos, sizeof(buffer));
-		rc = falcon_spi_read(spi, start + pos, block_len, NULL, buffer);
+		rc = falcon_spi_read(efx, spi, start + pos, block_len,
+				     NULL, buffer);
 		if (rc)
 			return rc;
 		if (memcmp(empty, buffer, block_len))
@@ -130,140 +168,228 @@ static int efx_spi_erase(struct efx_mtd *efx_mtd, loff_t start, size_t len)
 
 /* MTD interface */
 
-static int efx_mtd_read(struct mtd_info *mtd, loff_t start, size_t len,
-			size_t *retlen, u8 *buffer)
+static int efx_mtd_erase(struct mtd_info *mtd, struct erase_info *erase)
+{
+	struct efx_mtd *efx_mtd = mtd->priv;
+	int rc;
+
+	rc = efx_mtd->ops->erase(mtd, erase->addr, erase->len);
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
+static void efx_mtd_sync(struct mtd_info *mtd)
+{
+	struct efx_mtd *efx_mtd = mtd->priv;
+	struct efx_nic *efx = efx_mtd->efx;
+	int rc;
+
+	rc = efx_mtd->ops->sync(mtd);
+	if (rc)
+		EFX_ERR(efx, "%s sync failed (%d)\n", efx_mtd->name, rc);
+}
+
+static void efx_mtd_remove_partition(struct efx_mtd_partition *part)
+{
+	int rc;
+
+	for (;;) {
+		rc = del_mtd_device(&part->mtd);
+		if (rc != -EBUSY)
+			break;
+		ssleep(1);
+	}
+	WARN_ON(rc);
+}
+
+static void efx_mtd_remove_device(struct efx_mtd *efx_mtd)
+{
+	struct efx_mtd_partition *part;
+
+	efx_for_each_partition(part, efx_mtd)
+		efx_mtd_remove_partition(part);
+	list_del(&efx_mtd->node);
+	kfree(efx_mtd);
+}
+
+static void efx_mtd_rename_device(struct efx_mtd *efx_mtd)
+{
+	struct efx_mtd_partition *part;
+
+	efx_for_each_partition(part, efx_mtd)
+		snprintf(part->name, sizeof(part->name),
+			 "%s %s", efx_mtd->efx->name,
+			 part->type_name);
+}
+
+static int efx_mtd_probe_device(struct efx_nic *efx, struct efx_mtd *efx_mtd)
+{
+	struct efx_mtd_partition *part;
+
+	efx_mtd->efx = efx;
+
+	efx_mtd_rename_device(efx_mtd);
+
+	efx_for_each_partition(part, efx_mtd) {
+		part->mtd.writesize = 1;
+
+		part->mtd.owner = THIS_MODULE;
+		part->mtd.priv = efx_mtd;
+		part->mtd.name = part->name;
+		part->mtd.erase = efx_mtd_erase;
+		part->mtd.read = efx_mtd->ops->read;
+		part->mtd.write = efx_mtd->ops->write;
+		part->mtd.sync = efx_mtd_sync;
+
+		if (add_mtd_device(&part->mtd))
+			goto fail;
+	}
+
+	list_add(&efx_mtd->node, &efx->mtd_list);
+	return 0;
+
+fail:
+	while (part != &efx_mtd->part[0]) {
+		--part;
+		efx_mtd_remove_partition(part);
+	}
+	/* add_mtd_device() returns 1 if the MTD table is full */
+	return -ENOMEM;
+}
+
+void efx_mtd_remove(struct efx_nic *efx)
 {
+	struct efx_mtd *efx_mtd, *next;
+
+	WARN_ON(efx_dev_registered(efx));
+
+	list_for_each_entry_safe(efx_mtd, next, &efx->mtd_list, node)
+		efx_mtd_remove_device(efx_mtd);
+}
+
+void efx_mtd_rename(struct efx_nic *efx)
+{
+	struct efx_mtd *efx_mtd;
+
+	ASSERT_RTNL();
+
+	list_for_each_entry(efx_mtd, &efx->mtd_list, node)
+		efx_mtd_rename_device(efx_mtd);
+}
+
+int efx_mtd_probe(struct efx_nic *efx)
+{
+	return falcon_mtd_probe(efx);
+}
+
+/* Implementation of MTD operations for Falcon */
+
+static int falcon_mtd_read(struct mtd_info *mtd, loff_t start,
+			   size_t len, size_t *retlen, u8 *buffer)
+{
+	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
 	struct efx_mtd *efx_mtd = mtd->priv;
 	const struct efx_spi_device *spi = efx_mtd->spi;
-	struct efx_nic *efx = spi->efx;
+	struct efx_nic *efx = efx_mtd->efx;
 	int rc;
 
 	rc = mutex_lock_interruptible(&efx->spi_lock);
 	if (rc)
 		return rc;
-	rc = falcon_spi_read(spi, FALCON_FLASH_BOOTCODE_START + start,
-			     len, retlen, buffer);
+	rc = falcon_spi_read(efx, spi, part->offset + start, len,
+			     retlen, buffer);
 	mutex_unlock(&efx->spi_lock);
 	return rc;
 }
 
-static int efx_mtd_erase(struct mtd_info *mtd, struct erase_info *erase)
+static int falcon_mtd_erase(struct mtd_info *mtd, loff_t start, size_t len)
 {
+	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
 	struct efx_mtd *efx_mtd = mtd->priv;
-	struct efx_nic *efx = efx_mtd->spi->efx;
+	struct efx_nic *efx = efx_mtd->efx;
 	int rc;
 
 	rc = mutex_lock_interruptible(&efx->spi_lock);
 	if (rc)
 		return rc;
-	rc = efx_spi_erase(efx_mtd, FALCON_FLASH_BOOTCODE_START + erase->addr,
-			   erase->len);
+	rc = efx_spi_erase(efx_mtd, part->offset + start, len);
 	mutex_unlock(&efx->spi_lock);
-
-	if (rc == 0) {
-		erase->state = MTD_ERASE_DONE;
-	} else {
-		erase->state = MTD_ERASE_FAILED;
-		erase->fail_addr = 0xffffffff;
-	}
-	mtd_erase_callback(erase);
 	return rc;
 }
 
-static int efx_mtd_write(struct mtd_info *mtd, loff_t start,
-			 size_t len, size_t *retlen, const u8 *buffer)
+static int falcon_mtd_write(struct mtd_info *mtd, loff_t start,
+			    size_t len, size_t *retlen, const u8 *buffer)
 {
+	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
 	struct efx_mtd *efx_mtd = mtd->priv;
 	const struct efx_spi_device *spi = efx_mtd->spi;
-	struct efx_nic *efx = spi->efx;
+	struct efx_nic *efx = efx_mtd->efx;
 	int rc;
 
 	rc = mutex_lock_interruptible(&efx->spi_lock);
 	if (rc)
 		return rc;
-	rc = falcon_spi_write(spi, FALCON_FLASH_BOOTCODE_START + start,
-			      len, retlen, buffer);
+	rc = falcon_spi_write(efx, spi, part->offset + start, len,
+			      retlen, buffer);
 	mutex_unlock(&efx->spi_lock);
 	return rc;
 }
 
-static void efx_mtd_sync(struct mtd_info *mtd)
+static int falcon_mtd_sync(struct mtd_info *mtd)
 {
 	struct efx_mtd *efx_mtd = mtd->priv;
-	struct efx_nic *efx = efx_mtd->spi->efx;
+	struct efx_nic *efx = efx_mtd->efx;
 	int rc;
 
 	mutex_lock(&efx->spi_lock);
 	rc = efx_spi_slow_wait(efx_mtd, true);
 	mutex_unlock(&efx->spi_lock);
-
-	if (rc)
-		EFX_ERR(efx, "%s sync failed (%d)\n", efx_mtd->name, rc);
-	return;
-}
-
-void efx_mtd_remove(struct efx_nic *efx)
-{
-	if (efx->spi_flash && efx->spi_flash->mtd) {
-		struct efx_mtd *efx_mtd = efx->spi_flash->mtd;
-		int rc;
-
-		for (;;) {
-			rc = del_mtd_device(&efx_mtd->mtd);
-			if (rc != -EBUSY)
-				break;
-			ssleep(1);
-		}
-		WARN_ON(rc);
-		kfree(efx_mtd);
-	}
+	return rc;
 }
 
-void efx_mtd_rename(struct efx_nic *efx)
-{
-	if (efx->spi_flash && efx->spi_flash->mtd) {
-		struct efx_mtd *efx_mtd = efx->spi_flash->mtd;
-		snprintf(efx_mtd->name, sizeof(efx_mtd->name),
-			 "%s sfc_flash_bootrom", efx->name);
-	}
-}
+static struct efx_mtd_ops falcon_mtd_ops = {
+	.read	= falcon_mtd_read,
+	.erase	= falcon_mtd_erase,
+	.write	= falcon_mtd_write,
+	.sync	= falcon_mtd_sync,
+};
 
-int efx_mtd_probe(struct efx_nic *efx)
+static int falcon_mtd_probe(struct efx_nic *efx)
 {
 	struct efx_spi_device *spi = efx->spi_flash;
 	struct efx_mtd *efx_mtd;
+	int rc;
+
+	ASSERT_RTNL();
 
 	if (!spi || spi->size <= FALCON_FLASH_BOOTCODE_START)
 		return -ENODEV;
 
-	efx_mtd = kzalloc(sizeof(*efx_mtd), GFP_KERNEL);
+	efx_mtd = kzalloc(sizeof(*efx_mtd) + sizeof(efx_mtd->part[0]),
+			  GFP_KERNEL);
 	if (!efx_mtd)
 		return -ENOMEM;
 
 	efx_mtd->spi = spi;
-	spi->mtd = efx_mtd;
-
-	efx_mtd->mtd.type = MTD_NORFLASH;
-	efx_mtd->mtd.flags = MTD_CAP_NORFLASH;
-	efx_mtd->mtd.size = spi->size - FALCON_FLASH_BOOTCODE_START;
-	efx_mtd->mtd.erasesize = spi->erase_size;
-	efx_mtd->mtd.writesize = 1;
-	efx_mtd_rename(efx);
-
-	efx_mtd->mtd.owner = THIS_MODULE;
-	efx_mtd->mtd.priv = efx_mtd;
-	efx_mtd->mtd.name = efx_mtd->name;
-	efx_mtd->mtd.erase = efx_mtd_erase;
-	efx_mtd->mtd.read = efx_mtd_read;
-	efx_mtd->mtd.write = efx_mtd_write;
-	efx_mtd->mtd.sync = efx_mtd_sync;
-
-	if (add_mtd_device(&efx_mtd->mtd)) {
+	efx_mtd->name = "flash";
+	efx_mtd->ops = &falcon_mtd_ops;
+
+	efx_mtd->n_parts = 1;
+	efx_mtd->part[0].mtd.type = MTD_NORFLASH;
+	efx_mtd->part[0].mtd.flags = MTD_CAP_NORFLASH;
+	efx_mtd->part[0].mtd.size = spi->size - FALCON_FLASH_BOOTCODE_START;
+	efx_mtd->part[0].mtd.erasesize = spi->erase_size;
+	efx_mtd->part[0].offset = FALCON_FLASH_BOOTCODE_START;
+	efx_mtd->part[0].type_name = "sfc_flash_bootrom";
+
+	rc = efx_mtd_probe_device(efx, efx_mtd);
+	if (rc)
 		kfree(efx_mtd);
-		spi->mtd = NULL;
-		/* add_mtd_device() returns 1 if the MTD table is full */
-		return -ENOMEM;
-	}
-
-	return 0;
+	return rc;
 }
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 4ec6ef3..96d3f00 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -674,10 +674,11 @@ union efx_multicast_hash {
  *	interrupt is handled.  It is used by falcon_test_interrupt()
  *	to verify that an interrupt has occurred.
  * @spi_flash: SPI flash device
- *	This field will be %NULL if no flash device is present.
+ *	This field will be %NULL if no flash device is present (or for Siena).
  * @spi_eeprom: SPI EEPROM device
- *	This field will be %NULL if no EEPROM device is present.
+ *	This field will be %NULL if no EEPROM device is present (or for Siena).
  * @spi_lock: SPI bus lock
+ * @mtd_list: List of MTDs attached to the NIC
  * @n_rx_nodesc_drop_cnt: RX no descriptor drop count
  * @nic_data: Hardware dependant state
  * @mac_lock: MAC access lock. Protects @port_enabled, @phy_mode,
@@ -759,6 +760,9 @@ struct efx_nic {
 	struct efx_spi_device *spi_flash;
 	struct efx_spi_device *spi_eeprom;
 	struct mutex spi_lock;
+#ifdef CONFIG_SFC_MTD
+	struct list_head mtd_list;
+#endif
 
 	unsigned n_rx_nodesc_drop_cnt;
 
diff --git a/drivers/net/sfc/spi.h b/drivers/net/sfc/spi.h
index 1b1ceb4..8bf4fce 100644
--- a/drivers/net/sfc/spi.h
+++ b/drivers/net/sfc/spi.h
@@ -36,8 +36,6 @@
 
 /**
  * struct efx_spi_device - an Efx SPI (Serial Peripheral Interface) device
- * @efx:		The Efx controller that owns this device
- * @mtd:		MTD state
  * @device_id:		Controller's id for the device
  * @size:		Size (in bytes)
  * @addr_len:		Number of address bytes in read/write commands
@@ -54,10 +52,6 @@
  *	Write commands are limited to blocks with this size and alignment.
  */
 struct efx_spi_device {
-	struct efx_nic *efx;
-#ifdef CONFIG_SFC_MTD
-	void *mtd;
-#endif
 	int device_id;
 	unsigned int size;
 	unsigned int addr_len;
@@ -67,12 +61,16 @@ struct efx_spi_device {
 	unsigned int block_size;
 };
 
-int falcon_spi_cmd(const struct efx_spi_device *spi, unsigned int command,
+int falcon_spi_cmd(struct efx_nic *efx,
+		   const struct efx_spi_device *spi, unsigned int command,
 		   int address, const void* in, void *out, size_t len);
-int falcon_spi_wait_write(const struct efx_spi_device *spi);
-int falcon_spi_read(const struct efx_spi_device *spi, loff_t start,
+int falcon_spi_wait_write(struct efx_nic *efx,
+			  const struct efx_spi_device *spi);
+int falcon_spi_read(struct efx_nic *efx,
+		    const struct efx_spi_device *spi, loff_t start,
 		    size_t len, size_t *retlen, u8 *buffer);
-int falcon_spi_write(const struct efx_spi_device *spi, loff_t start,
+int falcon_spi_write(struct efx_nic *efx,
+		     const struct efx_spi_device *spi, loff_t start,
 		     size_t len, size_t *retlen, const u8 *buffer);
 
 /*


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

