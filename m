From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 16/16] sfc: Eliminate struct efx_mtd
Date: Tue, 27 Aug 2013 21:51:01 +0100
Message-ID: <1377636661.13272.90.camel@bwh-desktop.uk.level5networks.com>
References: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6222 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754064Ab3H0UvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:51:04 -0400
In-Reply-To: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we use struct efx_mtd to represent a physical NVRAM device
and struct efx_mtd_partition to represent a partition on that device.
But this only really makes sense for Falcon, as we don't know or care
whether MC-managed NVRAM partitions are on one or more physical
devices.  It complicates iteration and provides little benefit.
Therefore:

- Replace the pointer to efx_mtd in mtd_info::priv with a pointer to efx_nic
- Move the falcon_spi_device pointer into the union in struct efx_mtd_partition
- Move the device name to efx_mtd_partition::dev_type_name
- Move the efx_mtd_ops pointer to efx_nic::mtd_ops
- Make efx_nic::mtd_list a list of partitions

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mtd.c        | 279 +++++++++++++++-------------------
 drivers/net/ethernet/sfc/net_driver.h |   1 +
 2 files changed, 120 insertions(+), 160 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mtd.c b/drivers/net/ethernet/sfc/mtd.c
index e4b35c6..ba6c87a 100644
--- a/drivers/net/ethernet/sfc/mtd.c
+++ b/drivers/net/ethernet/sfc/mtd.c
@@ -25,6 +25,7 @@
 #define FALCON_SPI_VERIFY_BUF_LEN 16
 
 struct efx_mtd_partition {
+	struct list_head node;
 	struct mtd_info mtd;
 	union {
 		struct {
@@ -32,8 +33,12 @@ struct efx_mtd_partition {
 			u8 nvram_type;
 			u16 fw_subtype;
 		} mcdi;
-		size_t offset;
+		struct {
+			const struct falcon_spi_device *spi;
+			size_t offset;
+		} falcon;
 	};
+	const char *dev_type_name;
 	const char *type_name;
 	char name[IFNAMSIZ + 20];
 };
@@ -47,21 +52,6 @@ struct efx_mtd_ops {
 	int (*sync)(struct mtd_info *mtd);
 };
 
-struct efx_mtd {
-	struct list_head node;
-	struct efx_nic *efx;
-	const struct falcon_spi_device *spi;
-	const char *name;
-	const struct efx_mtd_ops *ops;
-	size_t n_parts;
-	struct efx_mtd_partition part[0];
-};
-
-#define efx_for_each_partition(part, efx_mtd)			\
-	for ((part) = &(efx_mtd)->part[0];			\
-	     (part) != &(efx_mtd)->part[(efx_mtd)->n_parts];	\
-	     (part)++)
-
 #define to_efx_mtd_partition(mtd)				\
 	container_of(mtd, struct efx_mtd_partition, mtd)
 
@@ -73,9 +63,8 @@ static int siena_mtd_probe(struct efx_nic *efx);
 static int
 falcon_spi_slow_wait(struct efx_mtd_partition *part, bool uninterruptible)
 {
-	struct efx_mtd *efx_mtd = part->mtd.priv;
-	const struct falcon_spi_device *spi = efx_mtd->spi;
-	struct efx_nic *efx = efx_mtd->efx;
+	const struct falcon_spi_device *spi = part->falcon.spi;
+	struct efx_nic *efx = part->mtd.priv;
 	u8 status;
 	int rc, i;
 
@@ -93,7 +82,8 @@ falcon_spi_slow_wait(struct efx_mtd_partition *part, bool uninterruptible)
 		if (signal_pending(current))
 			return -EINTR;
 	}
-	pr_err("%s: timed out waiting for %s\n", part->name, efx_mtd->name);
+	pr_err("%s: timed out waiting for %s\n",
+	       part->name, part->dev_type_name);
 	return -ETIMEDOUT;
 }
 
@@ -135,9 +125,8 @@ falcon_spi_unlock(struct efx_nic *efx, const struct falcon_spi_device *spi)
 static int
 falcon_spi_erase(struct efx_mtd_partition *part, loff_t start, size_t len)
 {
-	struct efx_mtd *efx_mtd = part->mtd.priv;
-	const struct falcon_spi_device *spi = efx_mtd->spi;
-	struct efx_nic *efx = efx_mtd->efx;
+	const struct falcon_spi_device *spi = part->falcon.spi;
+	struct efx_nic *efx = part->mtd.priv;
 	unsigned pos, block_len;
 	u8 empty[FALCON_SPI_VERIFY_BUF_LEN];
 	u8 buffer[FALCON_SPI_VERIFY_BUF_LEN];
@@ -185,10 +174,10 @@ falcon_spi_erase(struct efx_mtd_partition *part, loff_t start, size_t len)
 
 static int efx_mtd_erase(struct mtd_info *mtd, struct erase_info *erase)
 {
-	struct efx_mtd *efx_mtd = mtd->priv;
+	struct efx_nic *efx = mtd->priv;
 	int rc;
 
-	rc = efx_mtd->ops->erase(mtd, erase->addr, erase->len);
+	rc = efx->mtd_ops->erase(mtd, erase->addr, erase->len);
 	if (rc == 0) {
 		erase->state = MTD_ERASE_DONE;
 	} else {
@@ -202,13 +191,13 @@ static int efx_mtd_erase(struct mtd_info *mtd, struct erase_info *erase)
 static void efx_mtd_sync(struct mtd_info *mtd)
 {
 	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
-	struct efx_mtd *efx_mtd = mtd->priv;
+	struct efx_nic *efx = mtd->priv;
 	int rc;
 
-	rc = efx_mtd->ops->sync(mtd);
+	rc = efx->mtd_ops->sync(mtd);
 	if (rc)
 		pr_err("%s: %s sync failed (%d)\n",
-		       part->name, efx_mtd->name, rc);
+		       part->name, part->dev_type_name, rc);
 }
 
 static void efx_mtd_remove_partition(struct efx_mtd_partition *part)
@@ -222,86 +211,84 @@ static void efx_mtd_remove_partition(struct efx_mtd_partition *part)
 		ssleep(1);
 	}
 	WARN_ON(rc);
+	list_del(&part->node);
 }
 
-static void efx_mtd_remove_device(struct efx_mtd *efx_mtd)
-{
-	struct efx_mtd_partition *part;
-
-	efx_for_each_partition(part, efx_mtd)
-		efx_mtd_remove_partition(part);
-	list_del(&efx_mtd->node);
-	kfree(efx_mtd);
-}
-
-static void efx_mtd_rename_device(struct efx_mtd *efx_mtd)
+static void efx_mtd_rename_partition(struct efx_mtd_partition *part)
 {
-	struct efx_mtd_partition *part;
+	struct efx_nic *efx = part->mtd.priv;
 
-	efx_for_each_partition(part, efx_mtd)
-		if (efx_nic_rev(efx_mtd->efx) >= EFX_REV_SIENA_A0)
-			snprintf(part->name, sizeof(part->name),
-				 "%s %s:%02x", efx_mtd->efx->name,
-				 part->type_name, part->mcdi.fw_subtype);
-		else
-			snprintf(part->name, sizeof(part->name),
-				 "%s %s", efx_mtd->efx->name,
-				 part->type_name);
+	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0)
+		snprintf(part->name, sizeof(part->name), "%s %s:%02x",
+			 efx->name, part->type_name, part->mcdi.fw_subtype);
+	else
+		snprintf(part->name, sizeof(part->name), "%s %s",
+			 efx->name, part->type_name);
 }
 
-static int efx_mtd_probe_device(struct efx_nic *efx, struct efx_mtd *efx_mtd)
+static int efx_mtd_add(struct efx_nic *efx,
+		       struct efx_mtd_partition *parts, size_t n_parts)
 {
 	struct efx_mtd_partition *part;
+	size_t i;
 
-	efx_mtd->efx = efx;
+	for (i = 0; i < n_parts; i++) {
+		part = &parts[i];
 
-	efx_mtd_rename_device(efx_mtd);
-
-	efx_for_each_partition(part, efx_mtd) {
 		part->mtd.writesize = 1;
 
 		part->mtd.owner = THIS_MODULE;
-		part->mtd.priv = efx_mtd;
+		part->mtd.priv = efx;
 		part->mtd.name = part->name;
 		part->mtd._erase = efx_mtd_erase;
-		part->mtd._read = efx_mtd->ops->read;
-		part->mtd._write = efx_mtd->ops->write;
+		part->mtd._read = efx->mtd_ops->read;
+		part->mtd._write = efx->mtd_ops->write;
 		part->mtd._sync = efx_mtd_sync;
 
+		efx_mtd_rename_partition(part);
+
 		if (mtd_device_register(&part->mtd, NULL, 0))
 			goto fail;
+
+		/* Add to list in order - efx_mtd_remove() depends on this */
+		list_add_tail(&part->node, &efx->mtd_list);
 	}
 
-	list_add(&efx_mtd->node, &efx->mtd_list);
 	return 0;
 
 fail:
-	while (part != &efx_mtd->part[0]) {
-		--part;
-		efx_mtd_remove_partition(part);
-	}
+	while (i--)
+		efx_mtd_remove_partition(&parts[i]);
 	/* Failure is unlikely here, but probably means we're out of memory */
 	return -ENOMEM;
 }
 
 void efx_mtd_remove(struct efx_nic *efx)
 {
-	struct efx_mtd *efx_mtd, *next;
+	struct efx_mtd_partition *parts, *part, *next;
 
 	WARN_ON(efx_dev_registered(efx));
 
-	list_for_each_entry_safe(efx_mtd, next, &efx->mtd_list, node)
-		efx_mtd_remove_device(efx_mtd);
+	if (list_empty(&efx->mtd_list))
+		return;
+
+	parts = list_first_entry(&efx->mtd_list, struct efx_mtd_partition,
+				 node);
+
+	list_for_each_entry_safe(part, next, &efx->mtd_list, node)
+		efx_mtd_remove_partition(part);
+
+	kfree(parts);
 }
 
 void efx_mtd_rename(struct efx_nic *efx)
 {
-	struct efx_mtd *efx_mtd;
+	struct efx_mtd_partition *part;
 
 	ASSERT_RTNL();
 
-	list_for_each_entry(efx_mtd, &efx->mtd_list, node)
-		efx_mtd_rename_device(efx_mtd);
+	list_for_each_entry(part, &efx->mtd_list, node)
+		efx_mtd_rename_partition(part);
 }
 
 int efx_mtd_probe(struct efx_nic *efx)
@@ -318,17 +305,15 @@ static int falcon_mtd_read(struct mtd_info *mtd, loff_t start,
 			   size_t len, size_t *retlen, u8 *buffer)
 {
 	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
-	struct efx_mtd *efx_mtd = mtd->priv;
-	const struct falcon_spi_device *spi = efx_mtd->spi;
-	struct efx_nic *efx = efx_mtd->efx;
+	struct efx_nic *efx = mtd->priv;
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	int rc;
 
 	rc = mutex_lock_interruptible(&nic_data->spi_lock);
 	if (rc)
 		return rc;
-	rc = falcon_spi_read(efx, spi, part->offset + start, len,
-			     retlen, buffer);
+	rc = falcon_spi_read(efx, part->falcon.spi, part->falcon.offset + start,
+			     len, retlen, buffer);
 	mutex_unlock(&nic_data->spi_lock);
 	return rc;
 }
@@ -336,15 +321,14 @@ static int falcon_mtd_read(struct mtd_info *mtd, loff_t start,
 static int falcon_mtd_erase(struct mtd_info *mtd, loff_t start, size_t len)
 {
 	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
-	struct efx_mtd *efx_mtd = mtd->priv;
-	struct efx_nic *efx = efx_mtd->efx;
+	struct efx_nic *efx = mtd->priv;
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	int rc;
 
 	rc = mutex_lock_interruptible(&nic_data->spi_lock);
 	if (rc)
 		return rc;
-	rc = falcon_spi_erase(part, part->offset + start, len);
+	rc = falcon_spi_erase(part, part->falcon.offset + start, len);
 	mutex_unlock(&nic_data->spi_lock);
 	return rc;
 }
@@ -353,17 +337,15 @@ static int falcon_mtd_write(struct mtd_info *mtd, loff_t start,
 			    size_t len, size_t *retlen, const u8 *buffer)
 {
 	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
-	struct efx_mtd *efx_mtd = mtd->priv;
-	const struct falcon_spi_device *spi = efx_mtd->spi;
-	struct efx_nic *efx = efx_mtd->efx;
+	struct efx_nic *efx = mtd->priv;
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	int rc;
 
 	rc = mutex_lock_interruptible(&nic_data->spi_lock);
 	if (rc)
 		return rc;
-	rc = falcon_spi_write(efx, spi, part->offset + start, len,
-			      retlen, buffer);
+	rc = falcon_spi_write(efx, part->falcon.spi,
+			      part->falcon.offset + start, len, retlen, buffer);
 	mutex_unlock(&nic_data->spi_lock);
 	return rc;
 }
@@ -371,8 +353,7 @@ static int falcon_mtd_write(struct mtd_info *mtd, loff_t start,
 static int falcon_mtd_sync(struct mtd_info *mtd)
 {
 	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
-	struct efx_mtd *efx_mtd = mtd->priv;
-	struct efx_nic *efx = efx_mtd->efx;
+	struct efx_nic *efx = mtd->priv;
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	int rc;
 
@@ -392,66 +373,50 @@ static const struct efx_mtd_ops falcon_mtd_ops = {
 static int falcon_mtd_probe(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data = efx->nic_data;
+	struct efx_mtd_partition *parts;
 	struct falcon_spi_device *spi;
-	struct efx_mtd *efx_mtd;
+	size_t n_parts;
 	int rc = -ENODEV;
 
 	ASSERT_RTNL();
 
+	efx->mtd_ops = &falcon_mtd_ops;
+
+	/* Allocate space for maximum number of partitions */
+	parts = kcalloc(2, sizeof(*parts), GFP_KERNEL);
+	n_parts = 0;
+
 	spi = &nic_data->spi_flash;
 	if (falcon_spi_present(spi) && spi->size > FALCON_FLASH_BOOTCODE_START) {
-		efx_mtd = kzalloc(sizeof(*efx_mtd) + sizeof(efx_mtd->part[0]),
-				  GFP_KERNEL);
-		if (!efx_mtd)
-			return -ENOMEM;
-
-		efx_mtd->spi = spi;
-		efx_mtd->name = "flash";
-		efx_mtd->ops = &falcon_mtd_ops;
-
-		efx_mtd->n_parts = 1;
-		efx_mtd->part[0].mtd.type = MTD_NORFLASH;
-		efx_mtd->part[0].mtd.flags = MTD_CAP_NORFLASH;
-		efx_mtd->part[0].mtd.size = spi->size - FALCON_FLASH_BOOTCODE_START;
-		efx_mtd->part[0].mtd.erasesize = spi->erase_size;
-		efx_mtd->part[0].offset = FALCON_FLASH_BOOTCODE_START;
-		efx_mtd->part[0].type_name = "sfc_flash_bootrom";
-
-		rc = efx_mtd_probe_device(efx, efx_mtd);
-		if (rc) {
-			kfree(efx_mtd);
-			return rc;
-		}
+		parts[n_parts].falcon.spi = spi;
+		parts[n_parts].falcon.offset = FALCON_FLASH_BOOTCODE_START;
+		parts[n_parts].dev_type_name = "flash";
+		parts[n_parts].type_name = "sfc_flash_bootrom";
+		parts[n_parts].mtd.type = MTD_NORFLASH;
+		parts[n_parts].mtd.flags = MTD_CAP_NORFLASH;
+		parts[n_parts].mtd.size = spi->size - FALCON_FLASH_BOOTCODE_START;
+		parts[n_parts].mtd.erasesize = spi->erase_size;
+		n_parts++;
 	}
 
 	spi = &nic_data->spi_eeprom;
 	if (falcon_spi_present(spi) && spi->size > FALCON_EEPROM_BOOTCONFIG_START) {
-		efx_mtd = kzalloc(sizeof(*efx_mtd) + sizeof(efx_mtd->part[0]),
-				  GFP_KERNEL);
-		if (!efx_mtd)
-			return -ENOMEM;
-
-		efx_mtd->spi = spi;
-		efx_mtd->name = "EEPROM";
-		efx_mtd->ops = &falcon_mtd_ops;
-
-		efx_mtd->n_parts = 1;
-		efx_mtd->part[0].mtd.type = MTD_RAM;
-		efx_mtd->part[0].mtd.flags = MTD_CAP_RAM;
-		efx_mtd->part[0].mtd.size =
+		parts[n_parts].falcon.spi = spi;
+		parts[n_parts].falcon.offset = FALCON_EEPROM_BOOTCONFIG_START;
+		parts[n_parts].dev_type_name = "EEPROM";
+		parts[n_parts].type_name = "sfc_bootconfig";
+		parts[n_parts].mtd.type = MTD_RAM;
+		parts[n_parts].mtd.flags = MTD_CAP_RAM;
+		parts[n_parts].mtd.size =
 			min(spi->size, FALCON_EEPROM_BOOTCONFIG_END) -
 			FALCON_EEPROM_BOOTCONFIG_START;
-		efx_mtd->part[0].mtd.erasesize = spi->erase_size;
-		efx_mtd->part[0].offset = FALCON_EEPROM_BOOTCONFIG_START;
-		efx_mtd->part[0].type_name = "sfc_bootconfig";
-
-		rc = efx_mtd_probe_device(efx, efx_mtd);
-		if (rc) {
-			kfree(efx_mtd);
-			return rc;
-		}
+		parts[n_parts].mtd.erasesize = spi->erase_size;
+		n_parts++;
 	}
 
+	rc = efx_mtd_add(efx, parts, n_parts);
+	if (rc)
+		kfree(parts);
 	return rc;
 }
 
@@ -461,8 +426,7 @@ static int siena_mtd_read(struct mtd_info *mtd, loff_t start,
 			  size_t len, size_t *retlen, u8 *buffer)
 {
 	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
-	struct efx_mtd *efx_mtd = mtd->priv;
-	struct efx_nic *efx = efx_mtd->efx;
+	struct efx_nic *efx = mtd->priv;
 	loff_t offset = start;
 	loff_t end = min_t(loff_t, start + len, mtd->size);
 	size_t chunk;
@@ -485,8 +449,7 @@ out:
 static int siena_mtd_erase(struct mtd_info *mtd, loff_t start, size_t len)
 {
 	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
-	struct efx_mtd *efx_mtd = mtd->priv;
-	struct efx_nic *efx = efx_mtd->efx;
+	struct efx_nic *efx = mtd->priv;
 	loff_t offset = start & ~((loff_t)(mtd->erasesize - 1));
 	loff_t end = min_t(loff_t, start + len, mtd->size);
 	size_t chunk = part->mtd.erasesize;
@@ -517,8 +480,7 @@ static int siena_mtd_write(struct mtd_info *mtd, loff_t start,
 			   size_t len, size_t *retlen, const u8 *buffer)
 {
 	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
-	struct efx_mtd *efx_mtd = mtd->priv;
-	struct efx_nic *efx = efx_mtd->efx;
+	struct efx_nic *efx = mtd->priv;
 	loff_t offset = start;
 	loff_t end = min_t(loff_t, start + len, mtd->size);
 	size_t chunk;
@@ -548,8 +510,7 @@ out:
 static int siena_mtd_sync(struct mtd_info *mtd)
 {
 	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
-	struct efx_mtd *efx_mtd = mtd->priv;
-	struct efx_nic *efx = efx_mtd->efx;
+	struct efx_nic *efx = mtd->priv;
 	int rc = 0;
 
 	if (part->mcdi.updating) {
@@ -589,11 +550,9 @@ static const struct siena_nvram_type_info siena_nvram_types[] = {
 };
 
 static int siena_mtd_probe_partition(struct efx_nic *efx,
-				     struct efx_mtd *efx_mtd,
-				     unsigned int part_id,
+				     struct efx_mtd_partition *part,
 				     unsigned int type)
 {
-	struct efx_mtd_partition *part = &efx_mtd->part[part_id];
 	const struct siena_nvram_type_info *info;
 	size_t size, erase_size;
 	bool protected;
@@ -615,6 +574,7 @@ static int siena_mtd_probe_partition(struct efx_nic *efx,
 		return -ENODEV; /* hide it */
 
 	part->mcdi.nvram_type = type;
+	part->dev_type_name = "Siena NVRAM manager";
 	part->type_name = info->name;
 
 	part->mtd.type = MTD_NORFLASH;
@@ -626,55 +586,54 @@ static int siena_mtd_probe_partition(struct efx_nic *efx,
 }
 
 static int siena_mtd_get_fw_subtypes(struct efx_nic *efx,
-				     struct efx_mtd *efx_mtd)
+				     struct efx_mtd_partition *parts,
+				     size_t n_parts)
 {
-	struct efx_mtd_partition *part;
 	uint16_t fw_subtype_list[
 		MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_MAXNUM];
+	size_t i;
 	int rc;
 
 	rc = efx_mcdi_get_board_cfg(efx, NULL, fw_subtype_list, NULL);
 	if (rc)
 		return rc;
 
-	efx_for_each_partition(part, efx_mtd)
-		part->mcdi.fw_subtype = fw_subtype_list[part->mcdi.nvram_type];
+	for (i = 0; i < n_parts; i++)
+		parts[i].mcdi.fw_subtype =
+			fw_subtype_list[parts[i].mcdi.nvram_type];
 
 	return 0;
 }
 
 static int siena_mtd_probe(struct efx_nic *efx)
 {
-	struct efx_mtd *efx_mtd;
-	int rc = -ENODEV;
+	struct efx_mtd_partition *parts;
 	u32 nvram_types;
 	unsigned int type;
+	size_t n_parts;
+	int rc;
 
 	ASSERT_RTNL();
 
+	efx->mtd_ops = &siena_mtd_ops;
+
 	rc = efx_mcdi_nvram_types(efx, &nvram_types);
 	if (rc)
 		return rc;
 
-	efx_mtd = kzalloc(sizeof(*efx_mtd) +
-			  hweight32(nvram_types) * sizeof(efx_mtd->part[0]),
-			  GFP_KERNEL);
-	if (!efx_mtd)
+	parts = kcalloc(hweight32(nvram_types), sizeof(*parts), GFP_KERNEL);
+	if (!parts)
 		return -ENOMEM;
 
-	efx_mtd->name = "Siena NVRAM manager";
-
-	efx_mtd->ops = &siena_mtd_ops;
-
 	type = 0;
-	efx_mtd->n_parts = 0;
+	n_parts = 0;
 
 	while (nvram_types != 0) {
 		if (nvram_types & 1) {
-			rc = siena_mtd_probe_partition(efx, efx_mtd,
-						       efx_mtd->n_parts, type);
+			rc = siena_mtd_probe_partition(efx, &parts[n_parts],
+						       type);
 			if (rc == 0)
-				efx_mtd->n_parts++;
+				n_parts++;
 			else if (rc != -ENODEV)
 				goto fail;
 		}
@@ -682,14 +641,14 @@ static int siena_mtd_probe(struct efx_nic *efx)
 		nvram_types >>= 1;
 	}
 
-	rc = siena_mtd_get_fw_subtypes(efx, efx_mtd);
+	rc = siena_mtd_get_fw_subtypes(efx, parts, n_parts);
 	if (rc)
 		goto fail;
 
-	rc = efx_mtd_probe_device(efx, efx_mtd);
+	rc = efx_mtd_add(efx, parts, n_parts);
 fail:
 	if (rc)
-		kfree(efx_mtd);
+		kfree(parts);
 	return rc;
 }
 
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 555dd01..958ede1 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -868,6 +868,7 @@ struct efx_nic {
 	struct delayed_work selftest_work;
 
 #ifdef CONFIG_SFC_MTD
+	const struct efx_mtd_ops *mtd_ops;
 	struct list_head mtd_list;
 #endif
 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
