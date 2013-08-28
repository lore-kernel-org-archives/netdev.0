From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 01/16] sfc: Move NIC-type-specific MTD partition
 date into separate structures
Date: Wed, 28 Aug 2013 16:16:34 +0100
Message-ID: <1377702994.2264.23.camel@bwh-desktop.uk.level5networks.com>
References: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17094 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753618Ab3H1PQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 11:16:37 -0400
In-Reply-To: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mtd.c | 197 +++++++++++++++++++++++------------------
 1 file changed, 112 insertions(+), 85 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mtd.c b/drivers/net/ethernet/sfc/mtd.c
index ba6c87a..f5819c7 100644
--- a/drivers/net/ethernet/sfc/mtd.c
+++ b/drivers/net/ethernet/sfc/mtd.c
@@ -27,23 +27,19 @@
 struct efx_mtd_partition {
 	struct list_head node;
 	struct mtd_info mtd;
-	union {
-		struct {
-			bool updating;
-			u8 nvram_type;
-			u16 fw_subtype;
-		} mcdi;
-		struct {
-			const struct falcon_spi_device *spi;
-			size_t offset;
-		} falcon;
-	};
 	const char *dev_type_name;
 	const char *type_name;
 	char name[IFNAMSIZ + 20];
 };
 
+struct falcon_mtd_partition {
+	struct efx_mtd_partition common;
+	const struct falcon_spi_device *spi;
+	size_t offset;
+};
+
 struct efx_mtd_ops {
+	void (*rename)(struct efx_mtd_partition *part);
 	int (*read)(struct mtd_info *mtd, loff_t start, size_t len,
 		    size_t *retlen, u8 *buffer);
 	int (*erase)(struct mtd_info *mtd, loff_t start, size_t len);
@@ -55,16 +51,19 @@ struct efx_mtd_ops {
 #define to_efx_mtd_partition(mtd)				\
 	container_of(mtd, struct efx_mtd_partition, mtd)
 
+#define to_falcon_mtd_partition(mtd)				\
+	container_of(mtd, struct falcon_mtd_partition, common.mtd)
+
 static int falcon_mtd_probe(struct efx_nic *efx);
 static int siena_mtd_probe(struct efx_nic *efx);
 
 /* SPI utilities */
 
 static int
-falcon_spi_slow_wait(struct efx_mtd_partition *part, bool uninterruptible)
+falcon_spi_slow_wait(struct falcon_mtd_partition *part, bool uninterruptible)
 {
-	const struct falcon_spi_device *spi = part->falcon.spi;
-	struct efx_nic *efx = part->mtd.priv;
+	const struct falcon_spi_device *spi = part->spi;
+	struct efx_nic *efx = part->common.mtd.priv;
 	u8 status;
 	int rc, i;
 
@@ -83,7 +82,7 @@ falcon_spi_slow_wait(struct efx_mtd_partition *part, bool uninterruptible)
 			return -EINTR;
 	}
 	pr_err("%s: timed out waiting for %s\n",
-	       part->name, part->dev_type_name);
+	       part->common.name, part->common.dev_type_name);
 	return -ETIMEDOUT;
 }
 
@@ -123,10 +122,10 @@ falcon_spi_unlock(struct efx_nic *efx, const struct falcon_spi_device *spi)
 }
 
 static int
-falcon_spi_erase(struct efx_mtd_partition *part, loff_t start, size_t len)
+falcon_spi_erase(struct falcon_mtd_partition *part, loff_t start, size_t len)
 {
-	const struct falcon_spi_device *spi = part->falcon.spi;
-	struct efx_nic *efx = part->mtd.priv;
+	const struct falcon_spi_device *spi = part->spi;
+	struct efx_nic *efx = part->common.mtd.priv;
 	unsigned pos, block_len;
 	u8 empty[FALCON_SPI_VERIFY_BUF_LEN];
 	u8 buffer[FALCON_SPI_VERIFY_BUF_LEN];
@@ -218,22 +217,18 @@ static void efx_mtd_rename_partition(struct efx_mtd_partition *part)
 {
 	struct efx_nic *efx = part->mtd.priv;
 
-	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0)
-		snprintf(part->name, sizeof(part->name), "%s %s:%02x",
-			 efx->name, part->type_name, part->mcdi.fw_subtype);
-	else
-		snprintf(part->name, sizeof(part->name), "%s %s",
-			 efx->name, part->type_name);
+	efx->mtd_ops->rename(part);
 }
 
-static int efx_mtd_add(struct efx_nic *efx,
-		       struct efx_mtd_partition *parts, size_t n_parts)
+static int efx_mtd_add(struct efx_nic *efx, struct efx_mtd_partition *parts,
+		       size_t n_parts, size_t sizeof_part)
 {
 	struct efx_mtd_partition *part;
 	size_t i;
 
 	for (i = 0; i < n_parts; i++) {
-		part = &parts[i];
+		part = (struct efx_mtd_partition *)((char *)parts +
+						    i * sizeof_part);
 
 		part->mtd.writesize = 1;
 
@@ -257,8 +252,11 @@ static int efx_mtd_add(struct efx_nic *efx,
 	return 0;
 
 fail:
-	while (i--)
-		efx_mtd_remove_partition(&parts[i]);
+	while (i--) {
+		part = (struct efx_mtd_partition *)((char *)parts +
+						    i * sizeof_part);
+		efx_mtd_remove_partition(part);
+	}
 	/* Failure is unlikely here, but probably means we're out of memory */
 	return -ENOMEM;
 }
@@ -301,10 +299,18 @@ int efx_mtd_probe(struct efx_nic *efx)
 
 /* Implementation of MTD operations for Falcon */
 
+static void falcon_mtd_rename(struct efx_mtd_partition *part)
+{
+	struct efx_nic *efx = part->mtd.priv;
+
+	snprintf(part->name, sizeof(part->name), "%s %s",
+		 efx->name, part->type_name);
+}
+
 static int falcon_mtd_read(struct mtd_info *mtd, loff_t start,
 			   size_t len, size_t *retlen, u8 *buffer)
 {
-	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
+	struct falcon_mtd_partition *part = to_falcon_mtd_partition(mtd);
 	struct efx_nic *efx = mtd->priv;
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	int rc;
@@ -312,7 +318,7 @@ static int falcon_mtd_read(struct mtd_info *mtd, loff_t start,
 	rc = mutex_lock_interruptible(&nic_data->spi_lock);
 	if (rc)
 		return rc;
-	rc = falcon_spi_read(efx, part->falcon.spi, part->falcon.offset + start,
+	rc = falcon_spi_read(efx, part->spi, part->offset + start,
 			     len, retlen, buffer);
 	mutex_unlock(&nic_data->spi_lock);
 	return rc;
@@ -320,7 +326,7 @@ static int falcon_mtd_read(struct mtd_info *mtd, loff_t start,
 
 static int falcon_mtd_erase(struct mtd_info *mtd, loff_t start, size_t len)
 {
-	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
+	struct falcon_mtd_partition *part = to_falcon_mtd_partition(mtd);
 	struct efx_nic *efx = mtd->priv;
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	int rc;
@@ -328,7 +334,7 @@ static int falcon_mtd_erase(struct mtd_info *mtd, loff_t start, size_t len)
 	rc = mutex_lock_interruptible(&nic_data->spi_lock);
 	if (rc)
 		return rc;
-	rc = falcon_spi_erase(part, part->falcon.offset + start, len);
+	rc = falcon_spi_erase(part, part->offset + start, len);
 	mutex_unlock(&nic_data->spi_lock);
 	return rc;
 }
@@ -336,7 +342,7 @@ static int falcon_mtd_erase(struct mtd_info *mtd, loff_t start, size_t len)
 static int falcon_mtd_write(struct mtd_info *mtd, loff_t start,
 			    size_t len, size_t *retlen, const u8 *buffer)
 {
-	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
+	struct falcon_mtd_partition *part = to_falcon_mtd_partition(mtd);
 	struct efx_nic *efx = mtd->priv;
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	int rc;
@@ -344,15 +350,15 @@ static int falcon_mtd_write(struct mtd_info *mtd, loff_t start,
 	rc = mutex_lock_interruptible(&nic_data->spi_lock);
 	if (rc)
 		return rc;
-	rc = falcon_spi_write(efx, part->falcon.spi,
-			      part->falcon.offset + start, len, retlen, buffer);
+	rc = falcon_spi_write(efx, part->spi, part->offset + start,
+			      len, retlen, buffer);
 	mutex_unlock(&nic_data->spi_lock);
 	return rc;
 }
 
 static int falcon_mtd_sync(struct mtd_info *mtd)
 {
-	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
+	struct falcon_mtd_partition *part = to_falcon_mtd_partition(mtd);
 	struct efx_nic *efx = mtd->priv;
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	int rc;
@@ -364,6 +370,7 @@ static int falcon_mtd_sync(struct mtd_info *mtd)
 }
 
 static const struct efx_mtd_ops falcon_mtd_ops = {
+	.rename	= falcon_mtd_rename,
 	.read	= falcon_mtd_read,
 	.erase	= falcon_mtd_erase,
 	.write	= falcon_mtd_write,
@@ -373,7 +380,7 @@ static const struct efx_mtd_ops falcon_mtd_ops = {
 static int falcon_mtd_probe(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data = efx->nic_data;
-	struct efx_mtd_partition *parts;
+	struct falcon_mtd_partition *parts;
 	struct falcon_spi_device *spi;
 	size_t n_parts;
 	int rc = -ENODEV;
@@ -388,33 +395,33 @@ static int falcon_mtd_probe(struct efx_nic *efx)
 
 	spi = &nic_data->spi_flash;
 	if (falcon_spi_present(spi) && spi->size > FALCON_FLASH_BOOTCODE_START) {
-		parts[n_parts].falcon.spi = spi;
-		parts[n_parts].falcon.offset = FALCON_FLASH_BOOTCODE_START;
-		parts[n_parts].dev_type_name = "flash";
-		parts[n_parts].type_name = "sfc_flash_bootrom";
-		parts[n_parts].mtd.type = MTD_NORFLASH;
-		parts[n_parts].mtd.flags = MTD_CAP_NORFLASH;
-		parts[n_parts].mtd.size = spi->size - FALCON_FLASH_BOOTCODE_START;
-		parts[n_parts].mtd.erasesize = spi->erase_size;
+		parts[n_parts].spi = spi;
+		parts[n_parts].offset = FALCON_FLASH_BOOTCODE_START;
+		parts[n_parts].common.dev_type_name = "flash";
+		parts[n_parts].common.type_name = "sfc_flash_bootrom";
+		parts[n_parts].common.mtd.type = MTD_NORFLASH;
+		parts[n_parts].common.mtd.flags = MTD_CAP_NORFLASH;
+		parts[n_parts].common.mtd.size = spi->size - FALCON_FLASH_BOOTCODE_START;
+		parts[n_parts].common.mtd.erasesize = spi->erase_size;
 		n_parts++;
 	}
 
 	spi = &nic_data->spi_eeprom;
 	if (falcon_spi_present(spi) && spi->size > FALCON_EEPROM_BOOTCONFIG_START) {
-		parts[n_parts].falcon.spi = spi;
-		parts[n_parts].falcon.offset = FALCON_EEPROM_BOOTCONFIG_START;
-		parts[n_parts].dev_type_name = "EEPROM";
-		parts[n_parts].type_name = "sfc_bootconfig";
-		parts[n_parts].mtd.type = MTD_RAM;
-		parts[n_parts].mtd.flags = MTD_CAP_RAM;
-		parts[n_parts].mtd.size =
+		parts[n_parts].spi = spi;
+		parts[n_parts].offset = FALCON_EEPROM_BOOTCONFIG_START;
+		parts[n_parts].common.dev_type_name = "EEPROM";
+		parts[n_parts].common.type_name = "sfc_bootconfig";
+		parts[n_parts].common.mtd.type = MTD_RAM;
+		parts[n_parts].common.mtd.flags = MTD_CAP_RAM;
+		parts[n_parts].common.mtd.size =
 			min(spi->size, FALCON_EEPROM_BOOTCONFIG_END) -
 			FALCON_EEPROM_BOOTCONFIG_START;
-		parts[n_parts].mtd.erasesize = spi->erase_size;
+		parts[n_parts].common.mtd.erasesize = spi->erase_size;
 		n_parts++;
 	}
 
-	rc = efx_mtd_add(efx, parts, n_parts);
+	rc = efx_mtd_add(efx, &parts[0].common, n_parts, sizeof(*parts));
 	if (rc)
 		kfree(parts);
 	return rc;
@@ -422,10 +429,30 @@ static int falcon_mtd_probe(struct efx_nic *efx)
 
 /* Implementation of MTD operations for Siena */
 
+struct efx_mcdi_mtd_partition {
+	struct efx_mtd_partition common;
+	bool updating;
+	u8 nvram_type;
+	u16 fw_subtype;
+};
+
+#define to_efx_mcdi_mtd_partition(mtd)				\
+	container_of(mtd, struct efx_mcdi_mtd_partition, common.mtd)
+
+static void siena_mtd_rename(struct efx_mtd_partition *part)
+{
+	struct efx_mcdi_mtd_partition *mcdi_part =
+		container_of(part, struct efx_mcdi_mtd_partition, common);
+	struct efx_nic *efx = part->mtd.priv;
+
+	snprintf(part->name, sizeof(part->name), "%s %s:%02x",
+		 efx->name, part->type_name, mcdi_part->fw_subtype);
+}
+
 static int siena_mtd_read(struct mtd_info *mtd, loff_t start,
 			  size_t len, size_t *retlen, u8 *buffer)
 {
-	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
+	struct efx_mcdi_mtd_partition *part = to_efx_mcdi_mtd_partition(mtd);
 	struct efx_nic *efx = mtd->priv;
 	loff_t offset = start;
 	loff_t end = min_t(loff_t, start + len, mtd->size);
@@ -434,7 +461,7 @@ static int siena_mtd_read(struct mtd_info *mtd, loff_t start,
 
 	while (offset < end) {
 		chunk = min_t(size_t, end - offset, EFX_MCDI_NVRAM_LEN_MAX);
-		rc = efx_mcdi_nvram_read(efx, part->mcdi.nvram_type, offset,
+		rc = efx_mcdi_nvram_read(efx, part->nvram_type, offset,
 					 buffer, chunk);
 		if (rc)
 			goto out;
@@ -448,25 +475,25 @@ out:
 
 static int siena_mtd_erase(struct mtd_info *mtd, loff_t start, size_t len)
 {
-	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
+	struct efx_mcdi_mtd_partition *part = to_efx_mcdi_mtd_partition(mtd);
 	struct efx_nic *efx = mtd->priv;
 	loff_t offset = start & ~((loff_t)(mtd->erasesize - 1));
 	loff_t end = min_t(loff_t, start + len, mtd->size);
-	size_t chunk = part->mtd.erasesize;
+	size_t chunk = part->common.mtd.erasesize;
 	int rc = 0;
 
-	if (!part->mcdi.updating) {
-		rc = efx_mcdi_nvram_update_start(efx, part->mcdi.nvram_type);
+	if (!part->updating) {
+		rc = efx_mcdi_nvram_update_start(efx, part->nvram_type);
 		if (rc)
 			goto out;
-		part->mcdi.updating = true;
+		part->updating = true;
 	}
 
 	/* The MCDI interface can in fact do multiple erase blocks at once;
 	 * but erasing may be slow, so we make multiple calls here to avoid
 	 * tripping the MCDI RPC timeout. */
 	while (offset < end) {
-		rc = efx_mcdi_nvram_erase(efx, part->mcdi.nvram_type, offset,
+		rc = efx_mcdi_nvram_erase(efx, part->nvram_type, offset,
 					  chunk);
 		if (rc)
 			goto out;
@@ -479,23 +506,23 @@ out:
 static int siena_mtd_write(struct mtd_info *mtd, loff_t start,
 			   size_t len, size_t *retlen, const u8 *buffer)
 {
-	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
+	struct efx_mcdi_mtd_partition *part = to_efx_mcdi_mtd_partition(mtd);
 	struct efx_nic *efx = mtd->priv;
 	loff_t offset = start;
 	loff_t end = min_t(loff_t, start + len, mtd->size);
 	size_t chunk;
 	int rc = 0;
 
-	if (!part->mcdi.updating) {
-		rc = efx_mcdi_nvram_update_start(efx, part->mcdi.nvram_type);
+	if (!part->updating) {
+		rc = efx_mcdi_nvram_update_start(efx, part->nvram_type);
 		if (rc)
 			goto out;
-		part->mcdi.updating = true;
+		part->updating = true;
 	}
 
 	while (offset < end) {
 		chunk = min_t(size_t, end - offset, EFX_MCDI_NVRAM_LEN_MAX);
-		rc = efx_mcdi_nvram_write(efx, part->mcdi.nvram_type, offset,
+		rc = efx_mcdi_nvram_write(efx, part->nvram_type, offset,
 					  buffer, chunk);
 		if (rc)
 			goto out;
@@ -509,19 +536,20 @@ out:
 
 static int siena_mtd_sync(struct mtd_info *mtd)
 {
-	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
+	struct efx_mcdi_mtd_partition *part = to_efx_mcdi_mtd_partition(mtd);
 	struct efx_nic *efx = mtd->priv;
 	int rc = 0;
 
-	if (part->mcdi.updating) {
-		part->mcdi.updating = false;
-		rc = efx_mcdi_nvram_update_finish(efx, part->mcdi.nvram_type);
+	if (part->updating) {
+		part->updating = false;
+		rc = efx_mcdi_nvram_update_finish(efx, part->nvram_type);
 	}
 
 	return rc;
 }
 
 static const struct efx_mtd_ops siena_mtd_ops = {
+	.rename	= siena_mtd_rename,
 	.read	= siena_mtd_read,
 	.erase	= siena_mtd_erase,
 	.write	= siena_mtd_write,
@@ -550,7 +578,7 @@ static const struct siena_nvram_type_info siena_nvram_types[] = {
 };
 
 static int siena_mtd_probe_partition(struct efx_nic *efx,
-				     struct efx_mtd_partition *part,
+				     struct efx_mcdi_mtd_partition *part,
 				     unsigned int type)
 {
 	const struct siena_nvram_type_info *info;
@@ -573,20 +601,20 @@ static int siena_mtd_probe_partition(struct efx_nic *efx,
 	if (protected)
 		return -ENODEV; /* hide it */
 
-	part->mcdi.nvram_type = type;
-	part->dev_type_name = "Siena NVRAM manager";
-	part->type_name = info->name;
+	part->nvram_type = type;
+	part->common.dev_type_name = "Siena NVRAM manager";
+	part->common.type_name = info->name;
 
-	part->mtd.type = MTD_NORFLASH;
-	part->mtd.flags = MTD_CAP_NORFLASH;
-	part->mtd.size = size;
-	part->mtd.erasesize = erase_size;
+	part->common.mtd.type = MTD_NORFLASH;
+	part->common.mtd.flags = MTD_CAP_NORFLASH;
+	part->common.mtd.size = size;
+	part->common.mtd.erasesize = erase_size;
 
 	return 0;
 }
 
 static int siena_mtd_get_fw_subtypes(struct efx_nic *efx,
-				     struct efx_mtd_partition *parts,
+				     struct efx_mcdi_mtd_partition *parts,
 				     size_t n_parts)
 {
 	uint16_t fw_subtype_list[
@@ -599,15 +627,14 @@ static int siena_mtd_get_fw_subtypes(struct efx_nic *efx,
 		return rc;
 
 	for (i = 0; i < n_parts; i++)
-		parts[i].mcdi.fw_subtype =
-			fw_subtype_list[parts[i].mcdi.nvram_type];
+		parts[i].fw_subtype = fw_subtype_list[parts[i].nvram_type];
 
 	return 0;
 }
 
 static int siena_mtd_probe(struct efx_nic *efx)
 {
-	struct efx_mtd_partition *parts;
+	struct efx_mcdi_mtd_partition *parts;
 	u32 nvram_types;
 	unsigned int type;
 	size_t n_parts;
@@ -645,7 +672,7 @@ static int siena_mtd_probe(struct efx_nic *efx)
 	if (rc)
 		goto fail;
 
-	rc = efx_mtd_add(efx, parts, n_parts);
+	rc = efx_mtd_add(efx, &parts[0].common, n_parts, sizeof(*parts));
 fail:
 	if (rc)
 		kfree(parts);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
