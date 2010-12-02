From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 10/17] sfc: Move SPI state to struct
 falcon_nic_data
Date: Thu, 02 Dec 2010 23:47:29 +0000
Message-ID: <1291333649.3259.33.camel@bwh-desktop>
References: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:13087 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932318Ab0LBXrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:47:33 -0500
In-Reply-To: <1291333490.3259.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only have direct access to SPI on Falcon, so move all this state
out of struct efx_nic.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    4 --
 drivers/net/sfc/falcon.c     |   91 ++++++++++++++++++-----------------------
 drivers/net/sfc/mtd.c        |   29 ++++++++------
 drivers/net/sfc/net_driver.h |    8 ----
 drivers/net/sfc/nic.h        |    7 +++
 drivers/net/sfc/spi.h        |    5 ++
 6 files changed, 69 insertions(+), 75 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index b4580c4..6aed6ac 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1961,7 +1961,6 @@ void efx_reset_down(struct efx_nic *efx, enum reset_type method)
 
 	efx_stop_all(efx);
 	mutex_lock(&efx->mac_lock);
-	mutex_lock(&efx->spi_lock);
 
 	efx_fini_channels(efx);
 	if (efx->port_initialized && method != RESET_TYPE_INVISIBLE)
@@ -2003,7 +2002,6 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 	efx_init_channels(efx);
 	efx_restore_filters(efx);
 
-	mutex_unlock(&efx->spi_lock);
 	mutex_unlock(&efx->mac_lock);
 
 	efx_start_all(efx);
@@ -2013,7 +2011,6 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 fail:
 	efx->port_initialized = false;
 
-	mutex_unlock(&efx->spi_lock);
 	mutex_unlock(&efx->mac_lock);
 
 	return rc;
@@ -2202,7 +2199,6 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	memset(efx, 0, sizeof(*efx));
 	spin_lock_init(&efx->biu_lock);
 	mutex_init(&efx->mdio_lock);
-	mutex_init(&efx->spi_lock);
 #ifdef CONFIG_SFC_MTD
 	INIT_LIST_HEAD(&efx->mtd_list);
 #endif
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index fe15084..ca59f7e 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -254,7 +254,6 @@ int falcon_spi_cmd(struct efx_nic *efx, const struct efx_spi_device *spi,
 	/* Input validation */
 	if (len > FALCON_SPI_MAX_LEN)
 		return -EINVAL;
-	BUG_ON(!mutex_is_locked(&efx->spi_lock));
 
 	/* Check that previous command is not still running */
 	rc = falcon_spi_poll(efx);
@@ -888,6 +887,7 @@ static void falcon_remove_port(struct efx_nic *efx)
 static int
 falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 {
+	struct falcon_nic_data *nic_data = efx->nic_data;
 	struct falcon_nvconfig *nvconfig;
 	struct efx_spi_device *spi;
 	void *region;
@@ -895,8 +895,11 @@ falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 	__le16 *word, *limit;
 	u32 csum;
 
-	spi = efx->spi_flash ? efx->spi_flash : efx->spi_eeprom;
-	if (!spi)
+	if (efx_spi_present(&nic_data->spi_flash))
+		spi = &nic_data->spi_flash;
+	else if (efx_spi_present(&nic_data->spi_eeprom))
+		spi = &nic_data->spi_eeprom;
+	else
 		return -EINVAL;
 
 	region = kmalloc(FALCON_NVCONFIG_END, GFP_KERNEL);
@@ -904,12 +907,13 @@ falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 		return -ENOMEM;
 	nvconfig = region + FALCON_NVCONFIG_OFFSET;
 
-	mutex_lock(&efx->spi_lock);
+	mutex_lock(&nic_data->spi_lock);
 	rc = falcon_spi_read(efx, spi, 0, FALCON_NVCONFIG_END, NULL, region);
-	mutex_unlock(&efx->spi_lock);
+	mutex_unlock(&nic_data->spi_lock);
 	if (rc) {
 		netif_err(efx, hw, efx->net_dev, "Failed to read %s\n",
-			  efx->spi_flash ? "flash" : "EEPROM");
+			  efx_spi_present(&nic_data->spi_flash) ?
+			  "flash" : "EEPROM");
 		rc = -EIO;
 		goto out;
 	}
@@ -1011,7 +1015,7 @@ static int falcon_b0_test_registers(struct efx_nic *efx)
 
 /* Resets NIC to known state.  This routine must be called in process
  * context and is allowed to sleep. */
-static int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
+static int __falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
 {
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	efx_oword_t glb_ctl_reg_ker;
@@ -1107,6 +1111,18 @@ fail5:
 	return rc;
 }
 
+static int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	int rc;
+
+	mutex_lock(&nic_data->spi_lock);
+	rc = __falcon_reset_hw(efx, method);
+	mutex_unlock(&nic_data->spi_lock);
+
+	return rc;
+}
+
 static void falcon_monitor(struct efx_nic *efx)
 {
 	bool link_changed;
@@ -1188,16 +1204,11 @@ static int falcon_reset_sram(struct efx_nic *efx)
 	return -ETIMEDOUT;
 }
 
-static int falcon_spi_device_init(struct efx_nic *efx,
-				  struct efx_spi_device **spi_device_ret,
+static void falcon_spi_device_init(struct efx_nic *efx,
+				  struct efx_spi_device *spi_device,
 				  unsigned int device_id, u32 device_type)
 {
-	struct efx_spi_device *spi_device;
-
 	if (device_type != 0) {
-		spi_device = kzalloc(sizeof(*spi_device), GFP_KERNEL);
-		if (!spi_device)
-			return -ENOMEM;
 		spi_device->device_id = device_id;
 		spi_device->size =
 			1 << SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_SIZE);
@@ -1214,25 +1225,14 @@ static int falcon_spi_device_init(struct efx_nic *efx,
 			1 << SPI_DEV_TYPE_FIELD(device_type,
 						SPI_DEV_TYPE_BLOCK_SIZE);
 	} else {
-		spi_device = NULL;
+		spi_device->size = 0;
 	}
-
-	kfree(*spi_device_ret);
-	*spi_device_ret = spi_device;
-	return 0;
-}
-
-static void falcon_remove_spi_devices(struct efx_nic *efx)
-{
-	kfree(efx->spi_eeprom);
-	efx->spi_eeprom = NULL;
-	kfree(efx->spi_flash);
-	efx->spi_flash = NULL;
 }
 
 /* Extract non-volatile configuration */
 static int falcon_probe_nvconfig(struct efx_nic *efx)
 {
+	struct falcon_nic_data *nic_data = efx->nic_data;
 	struct falcon_nvconfig *nvconfig;
 	int rc;
 
@@ -1242,24 +1242,20 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 
 	rc = falcon_read_nvram(efx, nvconfig);
 	if (rc)
-		goto fail1;
+		goto out;
 
 	efx->phy_type = nvconfig->board_v2.port0_phy_type;
 	efx->mdio.prtad = nvconfig->board_v2.port0_phy_addr;
 
 	if (le16_to_cpu(nvconfig->board_struct_ver) >= 3) {
-		rc = falcon_spi_device_init(
-			efx, &efx->spi_flash, FFE_AB_SPI_DEVICE_FLASH,
+		falcon_spi_device_init(
+			efx, &nic_data->spi_flash, FFE_AB_SPI_DEVICE_FLASH,
 			le32_to_cpu(nvconfig->board_v3
 				    .spi_device_type[FFE_AB_SPI_DEVICE_FLASH]));
-		if (rc)
-			goto fail2;
-		rc = falcon_spi_device_init(
-			efx, &efx->spi_eeprom, FFE_AB_SPI_DEVICE_EEPROM,
+		falcon_spi_device_init(
+			efx, &nic_data->spi_eeprom, FFE_AB_SPI_DEVICE_EEPROM,
 			le32_to_cpu(nvconfig->board_v3
 				    .spi_device_type[FFE_AB_SPI_DEVICE_EEPROM]));
-		if (rc)
-			goto fail2;
 	}
 
 	/* Read the MAC addresses */
@@ -1270,15 +1266,7 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 
 	rc = falcon_probe_board(efx,
 				le16_to_cpu(nvconfig->board_v2.board_revision));
-	if (rc)
-		goto fail2;
-
-	kfree(nvconfig);
-	return 0;
-
- fail2:
-	falcon_remove_spi_devices(efx);
- fail1:
+out:
 	kfree(nvconfig);
 	return rc;
 }
@@ -1286,6 +1274,7 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 /* Probe all SPI devices on the NIC */
 static void falcon_probe_spi_devices(struct efx_nic *efx)
 {
+	struct falcon_nic_data *nic_data = efx->nic_data;
 	efx_oword_t nic_stat, gpio_ctl, ee_vpd_cfg;
 	int boot_dev;
 
@@ -1314,12 +1303,14 @@ static void falcon_probe_spi_devices(struct efx_nic *efx)
 		efx_writeo(efx, &ee_vpd_cfg, FR_AB_EE_VPD_CFG0);
 	}
 
+	mutex_init(&nic_data->spi_lock);
+
 	if (boot_dev == FFE_AB_SPI_DEVICE_FLASH)
-		falcon_spi_device_init(efx, &efx->spi_flash,
+		falcon_spi_device_init(efx, &nic_data->spi_flash,
 				       FFE_AB_SPI_DEVICE_FLASH,
 				       default_flash_type);
 	if (boot_dev == FFE_AB_SPI_DEVICE_EEPROM)
-		falcon_spi_device_init(efx, &efx->spi_eeprom,
+		falcon_spi_device_init(efx, &nic_data->spi_eeprom,
 				       FFE_AB_SPI_DEVICE_EEPROM,
 				       large_eeprom_type);
 }
@@ -1384,7 +1375,7 @@ static int falcon_probe_nic(struct efx_nic *efx)
 	}
 
 	/* Now we can reset the NIC */
-	rc = falcon_reset_hw(efx, RESET_TYPE_ALL);
+	rc = __falcon_reset_hw(efx, RESET_TYPE_ALL);
 	if (rc) {
 		netif_err(efx, probe, efx->net_dev, "failed to reset NIC\n");
 		goto fail3;
@@ -1442,7 +1433,6 @@ static int falcon_probe_nic(struct efx_nic *efx)
 	BUG_ON(i2c_del_adapter(&board->i2c_adap));
 	memset(&board->i2c_adap, 0, sizeof(board->i2c_adap));
  fail5:
-	falcon_remove_spi_devices(efx);
 	efx_nic_free_buffer(efx, &efx->irq_status);
  fail4:
  fail3:
@@ -1596,10 +1586,9 @@ static void falcon_remove_nic(struct efx_nic *efx)
 	BUG_ON(rc);
 	memset(&board->i2c_adap, 0, sizeof(board->i2c_adap));
 
-	falcon_remove_spi_devices(efx);
 	efx_nic_free_buffer(efx, &efx->irq_status);
 
-	falcon_reset_hw(efx, RESET_TYPE_ALL);
+	__falcon_reset_hw(efx, RESET_TYPE_ALL);
 
 	/* Release the second function after the reset */
 	if (nic_data->pci_dev2) {
diff --git a/drivers/net/sfc/mtd.c b/drivers/net/sfc/mtd.c
index d44c745..d386274 100644
--- a/drivers/net/sfc/mtd.c
+++ b/drivers/net/sfc/mtd.c
@@ -321,14 +321,15 @@ static int falcon_mtd_read(struct mtd_info *mtd, loff_t start,
 	struct efx_mtd *efx_mtd = mtd->priv;
 	const struct efx_spi_device *spi = efx_mtd->spi;
 	struct efx_nic *efx = efx_mtd->efx;
+	struct falcon_nic_data *nic_data = efx->nic_data;
 	int rc;
 
-	rc = mutex_lock_interruptible(&efx->spi_lock);
+	rc = mutex_lock_interruptible(&nic_data->spi_lock);
 	if (rc)
 		return rc;
 	rc = falcon_spi_read(efx, spi, part->offset + start, len,
 			     retlen, buffer);
-	mutex_unlock(&efx->spi_lock);
+	mutex_unlock(&nic_data->spi_lock);
 	return rc;
 }
 
@@ -337,13 +338,14 @@ static int falcon_mtd_erase(struct mtd_info *mtd, loff_t start, size_t len)
 	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
 	struct efx_mtd *efx_mtd = mtd->priv;
 	struct efx_nic *efx = efx_mtd->efx;
+	struct falcon_nic_data *nic_data = efx->nic_data;
 	int rc;
 
-	rc = mutex_lock_interruptible(&efx->spi_lock);
+	rc = mutex_lock_interruptible(&nic_data->spi_lock);
 	if (rc)
 		return rc;
 	rc = efx_spi_erase(part, part->offset + start, len);
-	mutex_unlock(&efx->spi_lock);
+	mutex_unlock(&nic_data->spi_lock);
 	return rc;
 }
 
@@ -354,14 +356,15 @@ static int falcon_mtd_write(struct mtd_info *mtd, loff_t start,
 	struct efx_mtd *efx_mtd = mtd->priv;
 	const struct efx_spi_device *spi = efx_mtd->spi;
 	struct efx_nic *efx = efx_mtd->efx;
+	struct falcon_nic_data *nic_data = efx->nic_data;
 	int rc;
 
-	rc = mutex_lock_interruptible(&efx->spi_lock);
+	rc = mutex_lock_interruptible(&nic_data->spi_lock);
 	if (rc)
 		return rc;
 	rc = falcon_spi_write(efx, spi, part->offset + start, len,
 			      retlen, buffer);
-	mutex_unlock(&efx->spi_lock);
+	mutex_unlock(&nic_data->spi_lock);
 	return rc;
 }
 
@@ -370,11 +373,12 @@ static int falcon_mtd_sync(struct mtd_info *mtd)
 	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
 	struct efx_mtd *efx_mtd = mtd->priv;
 	struct efx_nic *efx = efx_mtd->efx;
+	struct falcon_nic_data *nic_data = efx->nic_data;
 	int rc;
 
-	mutex_lock(&efx->spi_lock);
+	mutex_lock(&nic_data->spi_lock);
 	rc = efx_spi_slow_wait(part, true);
-	mutex_unlock(&efx->spi_lock);
+	mutex_unlock(&nic_data->spi_lock);
 	return rc;
 }
 
@@ -387,14 +391,15 @@ static struct efx_mtd_ops falcon_mtd_ops = {
 
 static int falcon_mtd_probe(struct efx_nic *efx)
 {
+	struct falcon_nic_data *nic_data = efx->nic_data;
 	struct efx_spi_device *spi;
 	struct efx_mtd *efx_mtd;
 	int rc = -ENODEV;
 
 	ASSERT_RTNL();
 
-	spi = efx->spi_flash;
-	if (spi && spi->size > FALCON_FLASH_BOOTCODE_START) {
+	spi = &nic_data->spi_flash;
+	if (efx_spi_present(spi) && spi->size > FALCON_FLASH_BOOTCODE_START) {
 		efx_mtd = kzalloc(sizeof(*efx_mtd) + sizeof(efx_mtd->part[0]),
 				  GFP_KERNEL);
 		if (!efx_mtd)
@@ -419,8 +424,8 @@ static int falcon_mtd_probe(struct efx_nic *efx)
 		}
 	}
 
-	spi = efx->spi_eeprom;
-	if (spi && spi->size > EFX_EEPROM_BOOTCONFIG_START) {
+	spi = &nic_data->spi_eeprom;
+	if (efx_spi_present(spi) && spi->size > EFX_EEPROM_BOOTCONFIG_START) {
 		efx_mtd = kzalloc(sizeof(*efx_mtd) + sizeof(efx_mtd->part[0]),
 				  GFP_KERNEL);
 		if (!efx_mtd)
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 0a7e26d..e5ee2d5 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -657,11 +657,6 @@ struct efx_filter_state;
  *	to verify that an interrupt has occurred.
  * @irq_zero_count: Number of legacy IRQs seen with queue flags == 0
  * @fatal_irq_level: IRQ level (bit number) used for serious errors
- * @spi_flash: SPI flash device
- *	This field will be %NULL if no flash device is present (or for Siena).
- * @spi_eeprom: SPI EEPROM device
- *	This field will be %NULL if no EEPROM device is present (or for Siena).
- * @spi_lock: SPI bus lock
  * @mtd_list: List of MTDs attached to the NIC
  * @n_rx_nodesc_drop_cnt: RX no descriptor drop count
  * @nic_data: Hardware dependant state
@@ -746,9 +741,6 @@ struct efx_nic {
 	unsigned irq_zero_count;
 	unsigned fatal_irq_level;
 
-	struct efx_spi_device *spi_flash;
-	struct efx_spi_device *spi_eeprom;
-	struct mutex spi_lock;
 #ifdef CONFIG_SFC_MTD
 	struct list_head mtd_list;
 #endif
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index 0438dc9..2a0fff3 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -15,6 +15,7 @@
 #include "net_driver.h"
 #include "efx.h"
 #include "mcdi.h"
+#include "spi.h"
 
 /*
  * Falcon hardware control
@@ -113,6 +114,9 @@ struct falcon_board {
  * @stats_pending: Is there a pending DMA of MAC statistics.
  * @stats_timer: A timer for regularly fetching MAC statistics.
  * @stats_dma_done: Pointer to the flag which indicates DMA completion.
+ * @spi_flash: SPI flash device
+ * @spi_eeprom: SPI EEPROM device
+ * @spi_lock: SPI bus lock
  */
 struct falcon_nic_data {
 	struct pci_dev *pci_dev2;
@@ -121,6 +125,9 @@ struct falcon_nic_data {
 	bool stats_pending;
 	struct timer_list stats_timer;
 	u32 *stats_dma_done;
+	struct efx_spi_device spi_flash;
+	struct efx_spi_device spi_eeprom;
+	struct mutex spi_lock;
 };
 
 static inline struct falcon_board *falcon_board(struct efx_nic *efx)
diff --git a/drivers/net/sfc/spi.h b/drivers/net/sfc/spi.h
index 8bf4fce..879b7f6 100644
--- a/drivers/net/sfc/spi.h
+++ b/drivers/net/sfc/spi.h
@@ -61,6 +61,11 @@ struct efx_spi_device {
 	unsigned int block_size;
 };
 
+static inline bool efx_spi_present(const struct efx_spi_device *spi)
+{
+	return spi->size != 0;
+}
+
 int falcon_spi_cmd(struct efx_nic *efx,
 		   const struct efx_spi_device *spi, unsigned int command,
 		   int address, const void* in, void *out, size_t len);
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

