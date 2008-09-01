From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 21/52] sfc: Export boot configuration in EEPROM through ethtool
Date: Mon, 1 Sep 2008 12:47:16 +0100
Message-ID: <20080901114715.GO7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:54783 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757633AbYIALrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:47:19 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend the SPI device setup code to support this.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c       |   52 ++++++
 drivers/net/sfc/falcon.c        |  358 +++++++++++++++++++++++++++++++++------
 drivers/net/sfc/falcon_hwdefs.h |   35 ++++
 drivers/net/sfc/net_driver.h    |    7 +
 drivers/net/sfc/spi.h           |   89 +++++-----
 5 files changed, 446 insertions(+), 95 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 6142c3a..72a2eb2 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -17,6 +17,7 @@
 #include "ethtool.h"
 #include "falcon.h"
 #include "gmii.h"
+#include "spi.h"
 #include "mac.h"
 
 const char *efx_loopback_mode_names[] = {
@@ -171,6 +172,11 @@ static struct efx_ethtool_stat efx_ethtool_stats[] = {
 /* Number of ethtool statistics */
 #define EFX_ETHTOOL_NUM_STATS ARRAY_SIZE(efx_ethtool_stats)
 
+/* EEPROM range with gPXE configuration */
+#define EFX_ETHTOOL_EEPROM_MAGIC 0xEFAB
+#define EFX_ETHTOOL_EEPROM_MIN 0x100U
+#define EFX_ETHTOOL_EEPROM_MAX 0x400U
+
 /**************************************************************************
  *
  * Ethtool operations
@@ -532,6 +538,49 @@ static u32 efx_ethtool_get_link(struct net_device *net_dev)
 	return efx->link_up;
 }
 
+static int efx_ethtool_get_eeprom_len(struct net_device *net_dev)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	struct efx_spi_device *spi = efx->spi_eeprom;
+
+	if (!spi)
+		return 0;
+	return min(spi->size, EFX_ETHTOOL_EEPROM_MAX) -
+		min(spi->size, EFX_ETHTOOL_EEPROM_MIN);
+}
+
+static int efx_ethtool_get_eeprom(struct net_device *net_dev,
+				  struct ethtool_eeprom *eeprom, u8 *buf)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	struct efx_spi_device *spi = efx->spi_eeprom;
+	size_t len;
+	int rc;
+
+	rc = falcon_spi_read(spi, eeprom->offset + EFX_ETHTOOL_EEPROM_MIN,
+			     eeprom->len, &len, buf);
+	eeprom->magic = EFX_ETHTOOL_EEPROM_MAGIC;
+	eeprom->len = len;
+	return rc;
+}
+
+static int efx_ethtool_set_eeprom(struct net_device *net_dev,
+				  struct ethtool_eeprom *eeprom, u8 *buf)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	struct efx_spi_device *spi = efx->spi_eeprom;
+	size_t len;
+	int rc;
+
+	if (eeprom->magic != EFX_ETHTOOL_EEPROM_MAGIC)
+		return -EINVAL;
+
+	rc = falcon_spi_write(spi, eeprom->offset + EFX_ETHTOOL_EEPROM_MIN,
+			      eeprom->len, &len, buf);
+	eeprom->len = len;
+	return rc;
+}
+
 static int efx_ethtool_get_coalesce(struct net_device *net_dev,
 				    struct ethtool_coalesce *coalesce)
 {
@@ -653,6 +702,9 @@ struct ethtool_ops efx_ethtool_ops = {
 	.get_drvinfo		= efx_ethtool_get_drvinfo,
 	.nway_reset		= efx_ethtool_nway_reset,
 	.get_link		= efx_ethtool_get_link,
+	.get_eeprom_len		= efx_ethtool_get_eeprom_len,
+	.get_eeprom		= efx_ethtool_get_eeprom,
+	.set_eeprom		= efx_ethtool_set_eeprom,
 	.get_coalesce		= efx_ethtool_get_coalesce,
 	.set_coalesce		= efx_ethtool_set_coalesce,
 	.get_pauseparam         = efx_ethtool_get_pauseparam,
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 9a13e5c..3017639 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1620,64 +1620,195 @@ void falcon_fini_interrupt(struct efx_nic *efx)
 /* Wait for SPI command completion */
 static int falcon_spi_wait(struct efx_nic *efx)
 {
+	unsigned long timeout = jiffies + DIV_ROUND_UP(HZ, 10);
 	efx_oword_t reg;
-	int cmd_en, timer_active;
-	int count;
+	bool cmd_en, timer_active;
 
-	count = 0;
-	do {
+	for (;;) {
 		falcon_read(efx, &reg, EE_SPI_HCMD_REG_KER);
 		cmd_en = EFX_OWORD_FIELD(reg, EE_SPI_HCMD_CMD_EN);
 		timer_active = EFX_OWORD_FIELD(reg, EE_WR_TIMER_ACTIVE);
 		if (!cmd_en && !timer_active)
 			return 0;
-		udelay(10);
-	} while (++count < 10000); /* wait upto 100msec */
-	EFX_ERR(efx, "timed out waiting for SPI\n");
-	return -ETIMEDOUT;
+		if (time_after_eq(jiffies, timeout)) {
+			EFX_ERR(efx, "timed out waiting for SPI\n");
+			return -ETIMEDOUT;
+		}
+		cpu_relax();
+	}
 }
 
-static int
-falcon_spi_read(struct efx_nic *efx, int device_id, unsigned int command,
-		unsigned int address, unsigned int addr_len,
-		void *data, unsigned int len)
+static int falcon_spi_cmd(const struct efx_spi_device *spi,
+			  unsigned int command, int address,
+			  const void *in, void *out, unsigned int len)
 {
+	struct efx_nic *efx = spi->efx;
+	bool addressed = (address >= 0);
+	bool reading = (out != NULL);
 	efx_oword_t reg;
 	int rc;
 
-	BUG_ON(len > FALCON_SPI_MAX_LEN);
+	/* Input validation */
+	if (len > FALCON_SPI_MAX_LEN)
+		return -EINVAL;
 
 	/* Check SPI not currently being accessed */
 	rc = falcon_spi_wait(efx);
 	if (rc)
 		return rc;
 
-	/* Program address register */
-	EFX_POPULATE_OWORD_1(reg, EE_SPI_HADR_ADR, address);
-	falcon_write(efx, &reg, EE_SPI_HADR_REG_KER);
+	/* Program address register, if we have an address */
+	if (addressed) {
+		EFX_POPULATE_OWORD_1(reg, EE_SPI_HADR_ADR, address);
+		falcon_write(efx, &reg, EE_SPI_HADR_REG_KER);
+	}
+
+	/* Program data register, if we have data */
+	if (in != NULL) {
+		memcpy(&reg, in, len);
+		falcon_write(efx, &reg, EE_SPI_HDATA_REG_KER);
+	}
 
-	/* Issue read command */
+	/* Issue read/write command */
 	EFX_POPULATE_OWORD_7(reg,
 			     EE_SPI_HCMD_CMD_EN, 1,
-			     EE_SPI_HCMD_SF_SEL, device_id,
+			     EE_SPI_HCMD_SF_SEL, spi->device_id,
 			     EE_SPI_HCMD_DABCNT, len,
-			     EE_SPI_HCMD_READ, EE_SPI_READ,
+			     EE_SPI_HCMD_READ, reading,
 			     EE_SPI_HCMD_DUBCNT, 0,
-			     EE_SPI_HCMD_ADBCNT, addr_len,
+			     EE_SPI_HCMD_ADBCNT,
+			     (addressed ? spi->addr_len : 0),
 			     EE_SPI_HCMD_ENC, command);
 	falcon_write(efx, &reg, EE_SPI_HCMD_REG_KER);
 
-	/* Wait for read to complete */
+	/* Wait for read/write to complete */
 	rc = falcon_spi_wait(efx);
 	if (rc)
 		return rc;
 
 	/* Read data */
-	falcon_read(efx, &reg, EE_SPI_HDATA_REG_KER);
-	memcpy(data, &reg, len);
+	if (out != NULL) {
+		falcon_read(efx, &reg, EE_SPI_HDATA_REG_KER);
+		memcpy(out, &reg, len);
+	}
+
 	return 0;
 }
 
+static unsigned int
+falcon_spi_write_limit(const struct efx_spi_device *spi, unsigned int start)
+{
+	return min(FALCON_SPI_MAX_LEN,
+		   (spi->block_size - (start & (spi->block_size - 1))));
+}
+
+static inline u8
+efx_spi_munge_command(const struct efx_spi_device *spi,
+		      const u8 command, const unsigned int address)
+{
+	return command | (((address >> 8) & spi->munge_address) << 3);
+}
+
+
+static int falcon_spi_fast_wait(const struct efx_spi_device *spi)
+{
+	u8 status;
+	int i, rc;
+
+	/* Wait up to 1000us for flash/EEPROM to finish a fast operation. */
+	for (i = 0; i < 50; i++) {
+		udelay(20);
+
+		rc = falcon_spi_cmd(spi, SPI_RDSR, -1, NULL,
+				    &status, sizeof(status));
+		if (rc)
+			return rc;
+		if (!(status & SPI_STATUS_NRDY))
+			return 0;
+	}
+	EFX_ERR(spi->efx,
+		"timed out waiting for device %d last status=0x%02x\n",
+		spi->device_id, status);
+	return -ETIMEDOUT;
+}
+
+int falcon_spi_read(const struct efx_spi_device *spi, loff_t start,
+		    size_t len, size_t *retlen, u8 *buffer)
+{
+	unsigned int command, block_len, pos = 0;
+	int rc = 0;
+
+	while (pos < len) {
+		block_len = min((unsigned int)len - pos,
+				FALCON_SPI_MAX_LEN);
+
+		command = efx_spi_munge_command(spi, SPI_READ, start + pos);
+		rc = falcon_spi_cmd(spi, command, start + pos, NULL,
+				    buffer + pos, block_len);
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
+	if (retlen)
+		*retlen = pos;
+	return rc;
+}
+
+int falcon_spi_write(const struct efx_spi_device *spi, loff_t start,
+		     size_t len, size_t *retlen, const u8 *buffer)
+{
+	u8 verify_buffer[FALCON_SPI_MAX_LEN];
+	unsigned int command, block_len, pos = 0;
+	int rc = 0;
+
+	while (pos < len) {
+		rc = falcon_spi_cmd(spi, SPI_WREN, -1, NULL, NULL, 0);
+		if (rc)
+			break;
+
+		block_len = min((unsigned int)len - pos,
+				falcon_spi_write_limit(spi, start + pos));
+		command = efx_spi_munge_command(spi, SPI_WRITE, start + pos);
+		rc = falcon_spi_cmd(spi, command, start + pos,
+				    buffer + pos, NULL, block_len);
+		if (rc)
+			break;
+
+		rc = falcon_spi_fast_wait(spi);
+		if (rc)
+			break;
+
+		command = efx_spi_munge_command(spi, SPI_READ, start + pos);
+		rc = falcon_spi_cmd(spi, command, start + pos,
+				    NULL, verify_buffer, block_len);
+		if (memcmp(verify_buffer, buffer + pos, block_len)) {
+			rc = -EIO;
+			break;
+		}
+
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
+	if (retlen)
+		*retlen = pos;
+	return rc;
+}
+
 /**************************************************************************
  *
  * MAC wrapper
@@ -2251,40 +2382,66 @@ static int falcon_reset_sram(struct efx_nic *efx)
 	return -ETIMEDOUT;
 }
 
+static int falcon_spi_device_init(struct efx_nic *efx,
+				  struct efx_spi_device **spi_device_ret,
+				  unsigned int device_id, u32 device_type)
+{
+	struct efx_spi_device *spi_device;
+
+	if (device_type != 0) {
+		spi_device = kmalloc(sizeof(*spi_device), GFP_KERNEL);
+		if (!spi_device)
+			return -ENOMEM;
+		spi_device->device_id = device_id;
+		spi_device->size =
+			1 << SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_SIZE);
+		spi_device->addr_len =
+			SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_ADDR_LEN);
+		spi_device->munge_address = (spi_device->size == 1 << 9 &&
+					     spi_device->addr_len == 1);
+		spi_device->block_size =
+			1 << SPI_DEV_TYPE_FIELD(device_type,
+						SPI_DEV_TYPE_BLOCK_SIZE);
+
+		spi_device->efx = efx;
+	} else {
+		spi_device = NULL;
+	}
+
+	kfree(*spi_device_ret);
+	*spi_device_ret = spi_device;
+	return 0;
+}
+
+
+static void falcon_remove_spi_devices(struct efx_nic *efx)
+{
+	kfree(efx->spi_eeprom);
+	efx->spi_eeprom = NULL;
+	kfree(efx->spi_flash);
+	efx->spi_flash = NULL;
+}
+
 /* Extract non-volatile configuration */
 static int falcon_probe_nvconfig(struct efx_nic *efx)
 {
 	struct falcon_nvconfig *nvconfig;
-	efx_oword_t nic_stat;
-	int device_id;
-	unsigned addr_len;
-	size_t offset, len;
+	struct efx_spi_device *spi;
 	int magic_num, struct_ver, board_rev;
 	int rc;
 
-	/* Find the boot device. */
-	falcon_read(efx, &nic_stat, NIC_STAT_REG);
-	if (EFX_OWORD_FIELD(nic_stat, SF_PRST)) {
-		device_id = EE_SPI_FLASH;
-		addr_len = 3;
-	} else if (EFX_OWORD_FIELD(nic_stat, EE_PRST)) {
-		device_id = EE_SPI_EEPROM;
-		addr_len = 2;
-	} else {
-		return -ENODEV;
-	}
-
 	nvconfig = kmalloc(sizeof(*nvconfig), GFP_KERNEL);
+	if (!nvconfig)
+		return -ENOMEM;
 
 	/* Read the whole configuration structure into memory. */
-	for (offset = 0; offset < sizeof(*nvconfig); offset += len) {
-		len = min(sizeof(*nvconfig) - offset,
-			  (size_t) FALCON_SPI_MAX_LEN);
-		rc = falcon_spi_read(efx, device_id, SPI_READ,
-				     NVCONFIG_BASE + offset, addr_len,
-				     (char *)nvconfig + offset, len);
-		if (rc)
-			goto out;
+	spi = efx->spi_flash ? efx->spi_flash : efx->spi_eeprom;
+	rc = falcon_spi_read(spi, NVCONFIG_BASE, sizeof(*nvconfig),
+			     NULL, (char *)nvconfig);
+	if (rc) {
+		EFX_ERR(efx, "Failed to read %s\n", efx->spi_flash ? "flash" :
+			"EEPROM");
+		goto fail1;
 	}
 
 	/* Read the MAC addresses */
@@ -2302,17 +2459,38 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 		board_rev = 0;
 	} else {
 		struct falcon_nvconfig_board_v2 *v2 = &nvconfig->board_v2;
+		struct falcon_nvconfig_board_v3 *v3 = &nvconfig->board_v3;
 
 		efx->phy_type = v2->port0_phy_type;
 		efx->mii.phy_id = v2->port0_phy_addr;
 		board_rev = le16_to_cpu(v2->board_revision);
+
+		if (struct_ver >= 3) {
+			__le32 fl = v3->spi_device_type[EE_SPI_FLASH];
+			__le32 ee = v3->spi_device_type[EE_SPI_EEPROM];
+			rc = falcon_spi_device_init(efx, &efx->spi_flash,
+						    EE_SPI_FLASH,
+						    le32_to_cpu(fl));
+			if (rc)
+				goto fail2;
+			rc = falcon_spi_device_init(efx, &efx->spi_eeprom,
+						    EE_SPI_EEPROM,
+						    le32_to_cpu(ee));
+			if (rc)
+				goto fail2;
+		}
 	}
 
 	EFX_LOG(efx, "PHY is %d phy_id %d\n", efx->phy_type, efx->mii.phy_id);
 
 	efx_set_board_info(efx, board_rev);
 
- out:
+	kfree(nvconfig);
+	return 0;
+
+ fail2:
+	falcon_remove_spi_devices(efx);
+ fail1:
 	kfree(nvconfig);
 	return rc;
 }
@@ -2363,6 +2541,86 @@ static int falcon_probe_nic_variant(struct efx_nic *efx)
 	return 0;
 }
 
+/* Probe all SPI devices on the NIC */
+static void falcon_probe_spi_devices(struct efx_nic *efx)
+{
+	efx_oword_t nic_stat, gpio_ctl, ee_vpd_cfg;
+	bool has_flash, has_eeprom, boot_is_external;
+
+	falcon_read(efx, &gpio_ctl, GPIO_CTL_REG_KER);
+	falcon_read(efx, &nic_stat, NIC_STAT_REG);
+	falcon_read(efx, &ee_vpd_cfg, EE_VPD_CFG_REG_KER);
+
+	has_flash = EFX_OWORD_FIELD(nic_stat, SF_PRST);
+	has_eeprom = EFX_OWORD_FIELD(nic_stat, EE_PRST);
+	boot_is_external = EFX_OWORD_FIELD(gpio_ctl, BOOTED_USING_NVDEVICE);
+
+	if (has_flash) {
+		/* Default flash SPI device: Atmel AT25F1024
+		 * 128 KB, 24-bit address, 32 KB erase block,
+		 * 256 B write block
+		 */
+		u32 flash_device_type =
+			(17 << SPI_DEV_TYPE_SIZE_LBN)
+			| (3 << SPI_DEV_TYPE_ADDR_LEN_LBN)
+			| (0x52 << SPI_DEV_TYPE_ERASE_CMD_LBN)
+			| (15 << SPI_DEV_TYPE_ERASE_SIZE_LBN)
+			| (8 << SPI_DEV_TYPE_BLOCK_SIZE_LBN);
+
+		falcon_spi_device_init(efx, &efx->spi_flash,
+				       EE_SPI_FLASH, flash_device_type);
+
+		if (!boot_is_external) {
+			/* Disable VPD and set clock dividers to safe
+			 * values for initial programming.
+			 */
+			EFX_LOG(efx, "Booted from internal ASIC settings;"
+				" setting SPI config\n");
+			EFX_POPULATE_OWORD_3(ee_vpd_cfg, EE_VPD_EN, 0,
+					     /* 125 MHz / 7 ~= 20 MHz */
+					     EE_SF_CLOCK_DIV, 7,
+					     /* 125 MHz / 63 ~= 2 MHz */
+					     EE_EE_CLOCK_DIV, 63);
+			falcon_write(efx, &ee_vpd_cfg, EE_VPD_CFG_REG_KER);
+		}
+	}
+
+	if (has_eeprom) {
+		u32 eeprom_device_type;
+
+		/* If it has no flash, it must have a large EEPROM
+		 * for chip config; otherwise check whether 9-bit
+		 * addressing is used for VPD configuration
+		 */
+		if (has_flash &&
+		    (!boot_is_external ||
+		     EFX_OWORD_FIELD(ee_vpd_cfg, EE_VPD_EN_AD9_MODE))) {
+			/* Default SPI device: Atmel AT25040 or similar
+			 * 512 B, 9-bit address, 8 B write block
+			 */
+			eeprom_device_type =
+				(9 << SPI_DEV_TYPE_SIZE_LBN)
+				| (1 << SPI_DEV_TYPE_ADDR_LEN_LBN)
+				| (3 << SPI_DEV_TYPE_BLOCK_SIZE_LBN);
+		} else {
+			/* "Large" SPI device: Atmel AT25640 or similar
+			 * 8 KB, 16-bit address, 32 B write block
+			 */
+			eeprom_device_type =
+				(13 << SPI_DEV_TYPE_SIZE_LBN)
+				| (2 << SPI_DEV_TYPE_ADDR_LEN_LBN)
+				| (5 << SPI_DEV_TYPE_BLOCK_SIZE_LBN);
+		}
+
+		falcon_spi_device_init(efx, &efx->spi_eeprom,
+				       EE_SPI_EEPROM, eeprom_device_type);
+	}
+
+	EFX_LOG(efx, "flash is %s, EEPROM is %s\n",
+		(has_flash ? "present" : "absent"),
+		(has_eeprom ? "present" : "absent"));
+}
+
 int falcon_probe_nic(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data;
@@ -2413,6 +2671,8 @@ int falcon_probe_nic(struct efx_nic *efx)
 		(unsigned long long)efx->irq_status.dma_addr,
 		efx->irq_status.addr, virt_to_phys(efx->irq_status.addr));
 
+	falcon_probe_spi_devices(efx);
+
 	/* Read in the non-volatile configuration */
 	rc = falcon_probe_nvconfig(efx);
 	if (rc)
@@ -2432,6 +2692,7 @@ int falcon_probe_nic(struct efx_nic *efx)
 	return 0;
 
  fail5:
+	falcon_remove_spi_devices(efx);
 	falcon_free_buffer(efx, &efx->irq_status);
  fail4:
  fail3:
@@ -2608,6 +2869,7 @@ void falcon_remove_nic(struct efx_nic *efx)
 	rc = i2c_del_adapter(&efx->i2c_adap);
 	BUG_ON(rc);
 
+	falcon_remove_spi_devices(efx);
 	falcon_free_buffer(efx, &efx->irq_status);
 
 	falcon_reset_hw(efx, RESET_TYPE_ALL);
diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
index 6d00311..626735e 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -92,6 +92,17 @@
 /* SPI host data register */
 #define EE_SPI_HDATA_REG_KER 0x0120
 
+/* SPI/VPD config register */
+#define EE_VPD_CFG_REG_KER 0x0140
+#define EE_VPD_EN_LBN 0
+#define EE_VPD_EN_WIDTH 1
+#define EE_VPD_EN_AD9_MODE_LBN 1
+#define EE_VPD_EN_AD9_MODE_WIDTH 1
+#define EE_EE_CLOCK_DIV_LBN 112
+#define EE_EE_CLOCK_DIV_WIDTH 7
+#define EE_SF_CLOCK_DIV_LBN 120
+#define EE_SF_CLOCK_DIV_WIDTH 7
+
 /* PCIE CORE ACCESS REG */
 #define PCIE_CORE_ADDR_PCIE_DEVICE_CTRL_STAT 0x68
 #define PCIE_CORE_ADDR_PCIE_LINK_CTRL_STAT 0x70
@@ -115,6 +126,9 @@
 #define STRAP_PCIE_LBN 0
 #define STRAP_PCIE_WIDTH 1
 
+#define BOOTED_USING_NVDEVICE_LBN 3
+#define BOOTED_USING_NVDEVICE_WIDTH 1
+
 /* GPIO control register */
 #define GPIO_CTL_REG_KER 0x0210
 #define GPIO_OUTPUTS_LBN   (16)
@@ -1127,6 +1141,25 @@ struct falcon_nvconfig_board_v2 {
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
@@ -1144,6 +1177,8 @@ struct falcon_nvconfig {
 	__le16 board_struct_ver;
 	__le16 board_checksum;
 	struct falcon_nvconfig_board_v2 board_v2;
+	efx_oword_t ee_base_page_reg;			/* 0x3B0 */
+	struct falcon_nvconfig_board_v3 board_v3;
 } __packed;
 
 #endif /* EFX_FALCON_HWDEFS_H */
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 1b92186..3902757 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -638,6 +638,10 @@ union efx_multicast_hash {
  *	This register is written with the SMP processor ID whenever an
  *	interrupt is handled.  It is used by falcon_test_interrupt()
  *	to verify that an interrupt has occurred.
+ * @spi_flash: SPI flash device
+ *	This field will be %NULL if no flash device is present.
+ * @spi_eeprom: SPI EEPROM device
+ *	This field will be %NULL if no EEPROM device is present.
  * @n_rx_nodesc_drop_cnt: RX no descriptor drop count
  * @nic_data: Hardware dependant state
  * @mac_lock: MAC access lock. Protects @port_enabled, efx_monitor() and
@@ -709,6 +713,9 @@ struct efx_nic {
 	struct efx_buffer irq_status;
 	volatile signed int last_irq_cpu;
 
+	struct efx_spi_device *spi_flash;
+	struct efx_spi_device *spi_eeprom;
+
 	unsigned n_rx_nodesc_drop_cnt;
 
 	struct falcon_nic_data *nic_data;
diff --git a/drivers/net/sfc/spi.h b/drivers/net/sfc/spi.h
index 34412f3..feef619 100644
--- a/drivers/net/sfc/spi.h
+++ b/drivers/net/sfc/spi.h
@@ -19,53 +19,48 @@
  *
  *************************************************************************/
 
-/*
- * Commands common to all known devices.
- *
+#define SPI_WRSR 0x01		/* Write status register */
+#define SPI_WRITE 0x02		/* Write data to memory array */
+#define SPI_READ 0x03		/* Read data from memory array */
+#define SPI_WRDI 0x04		/* Reset write enable latch */
+#define SPI_RDSR 0x05		/* Read status register */
+#define SPI_WREN 0x06		/* Set write enable latch */
+
+#define SPI_STATUS_WPEN 0x80	/* Write-protect pin enabled */
+#define SPI_STATUS_BP2 0x10	/* Block protection bit 2 */
+#define SPI_STATUS_BP1 0x08	/* Block protection bit 1 */
+#define SPI_STATUS_BP0 0x04	/* Block protection bit 0 */
+#define SPI_STATUS_WEN 0x02	/* State of the write enable latch */
+#define SPI_STATUS_NRDY 0x01	/* Device busy flag */
+
+/**
+ * struct efx_spi_device - an Efx SPI (Serial Peripheral Interface) device
+ * @efx:		The Efx controller that owns this device
+ * @device_id:		Controller's id for the device
+ * @size:		Size (in bytes)
+ * @addr_len:		Number of address bytes in read/write commands
+ * @munge_address:	Flag whether addresses should be munged.
+ *	Some devices with 9-bit addresses (e.g. AT25040A EEPROM)
+ *	use bit 3 of the command byte as address bit A8, rather
+ *	than having a two-byte address.  If this flag is set, then
+ *	commands should be munged in this way.
+ * @block_size:		Write block size (in bytes).
+ *	Write commands are limited to blocks with this size and alignment.
+ * @read:		Read function for the device
+ * @write:		Write function for the device
  */
-
-/* Write status register */
-#define SPI_WRSR 0x01
-
-/* Write data to memory array */
-#define SPI_WRITE 0x02
-
-/* Read data from memory array */
-#define SPI_READ 0x03
-
-/* Reset write enable latch */
-#define SPI_WRDI 0x04
-
-/* Read status register */
-#define SPI_RDSR 0x05
-
-/* Set write enable latch */
-#define SPI_WREN 0x06
-
-/* SST: Enable write to status register */
-#define SPI_SST_EWSR 0x50
-
-/*
- * Status register bits.  Not all bits are supported on all devices.
- *
- */
-
-/* Write-protect pin enabled */
-#define SPI_STATUS_WPEN 0x80
-
-/* Block protection bit 2 */
-#define SPI_STATUS_BP2 0x10
-
-/* Block protection bit 1 */
-#define SPI_STATUS_BP1 0x08
-
-/* Block protection bit 0 */
-#define SPI_STATUS_BP0 0x04
-
-/* State of the write enable latch */
-#define SPI_STATUS_WEN 0x02
-
-/* Device busy flag */
-#define SPI_STATUS_NRDY 0x01
+struct efx_spi_device {
+	struct efx_nic *efx;
+	int device_id;
+	unsigned int size;
+	unsigned int addr_len;
+	unsigned int munge_address:1;
+	unsigned int block_size;
+};
+
+int falcon_spi_read(const struct efx_spi_device *spi, loff_t start,
+		    size_t len, size_t *retlen, u8 *buffer);
+int falcon_spi_write(const struct efx_spi_device *spi, loff_t start,
+		     size_t len, size_t *retlen, const u8 *buffer);
 
 #endif /* EFX_SPI_H */
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

