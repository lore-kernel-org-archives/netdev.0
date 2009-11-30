From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 10/12] sfc: Add support for SFC9000 family (2)
Date: Mon, 30 Nov 2009 01:15:41 +0000
Message-ID: <1259543741.3709.96.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:46823 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750AbZK3BPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:15:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This integrates support for the SFC9000 family of 10G Ethernet
controllers and LAN-on-motherboard chips, starting with the SFL9021
'Siena' and SFC9020 'Bethpage'.

Credit for this code is largely due to my colleagues at Solarflare:

   Guido Barzini
   Steve Hodgson
   Kieran Mansley
   Matthew Slattery
   Neil Turton

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/Kconfig       |   13 +-
 drivers/net/sfc/Makefile      |    7 +-
 drivers/net/sfc/bitfield.h    |    2 +
 drivers/net/sfc/efx.c         |   26 ++++
 drivers/net/sfc/efx.h         |    2 +
 drivers/net/sfc/enum.h        |    2 +
 drivers/net/sfc/ethtool.c     |    3 +
 drivers/net/sfc/mac.h         |    3 +
 drivers/net/sfc/mtd.c         |  267 ++++++++++++++++++++++++++++++++++++++++-
 drivers/net/sfc/net_driver.h  |   10 ++-
 drivers/net/sfc/nic.c         |   63 ++++++++--
 drivers/net/sfc/nic.h         |   23 ++++
 drivers/net/sfc/phy.h         |   17 +++
 drivers/net/sfc/workarounds.h |    5 +
 14 files changed, 414 insertions(+), 29 deletions(-)

diff --git a/drivers/net/sfc/Kconfig b/drivers/net/sfc/Kconfig
index 260aafa..a65c986 100644
--- a/drivers/net/sfc/Kconfig
+++ b/drivers/net/sfc/Kconfig
@@ -1,5 +1,5 @@
 config SFC
-	tristate "Solarflare Solarstorm SFC4000 support"
+	tristate "Solarflare Solarstorm SFC4000/SFC9000-family support"
 	depends on PCI && INET
 	select MDIO
 	select CRC32
@@ -7,15 +7,16 @@ config SFC
 	select I2C_ALGOBIT
 	help
 	  This driver supports 10-gigabit Ethernet cards based on
-	  the Solarflare Communications Solarstorm SFC4000 controller.
+	  the Solarflare Communications Solarstorm SFC4000 and
+	  SFC9000-family controllers.
 
 	  To compile this driver as a module, choose M here.  The module
 	  will be called sfc.
 config SFC_MTD
-	bool "Solarflare Solarstorm SFC4000 flash MTD support"
+	bool "Solarflare Solarstorm SFC4000/SFC9000-family MTD support"
 	depends on SFC && MTD && !(SFC=y && MTD=m)
 	default y
 	help
-	  This exposes the on-board flash memory as an MTD device (e.g.
-          /dev/mtd1).  This makes it possible to upload new boot code
-          to the NIC.
+	  This exposes the on-board flash memory as MTD devices (e.g.
+	  /dev/mtd1).  This makes it possible to upload new firmware
+	  to the NIC.
diff --git a/drivers/net/sfc/Makefile b/drivers/net/sfc/Makefile
index 223106b..1047b19 100644
--- a/drivers/net/sfc/Makefile
+++ b/drivers/net/sfc/Makefile
@@ -1,6 +1,7 @@
-sfc-y			+= efx.o nic.o falcon.o tx.o rx.o falcon_gmac.o \
-			   falcon_xmac.o selftest.o ethtool.o qt202x_phy.o \
-			   mdio_10g.o tenxpress.o falcon_boards.o
+sfc-y			+= efx.o nic.o falcon.o siena.o tx.o rx.o \
+			   falcon_gmac.o falcon_xmac.o mcdi_mac.o \
+			   selftest.o ethtool.o qt202x_phy.o mdio_10g.o \
+			   tenxpress.o falcon_boards.o mcdi.o mcdi_phy.o
 sfc-$(CONFIG_SFC_MTD)	+= mtd.o
 
 obj-$(CONFIG_SFC)	+= sfc.o
diff --git a/drivers/net/sfc/bitfield.h b/drivers/net/sfc/bitfield.h
index 6ad909b..bb5de4f 100644
--- a/drivers/net/sfc/bitfield.h
+++ b/drivers/net/sfc/bitfield.h
@@ -37,6 +37,8 @@
 #define EFX_DWORD_2_WIDTH 32
 #define EFX_DWORD_3_LBN 96
 #define EFX_DWORD_3_WIDTH 32
+#define EFX_QWORD_0_LBN 0
+#define EFX_QWORD_0_WIDTH 64
 
 /* Specified attribute (e.g. LBN) of the specified field */
 #define EFX_VAL(field, attribute) field ## _ ## attribute
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 97a6ebd..4b5c786 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -25,6 +25,8 @@
 #include "mdio_10g.h"
 #include "nic.h"
 
+#include "mcdi.h"
+
 /**************************************************************************
  *
  * Type name strings
@@ -84,6 +86,7 @@ const char *efx_reset_type_names[] = {
 	[RESET_TYPE_RX_DESC_FETCH] = "RX_DESC_FETCH",
 	[RESET_TYPE_TX_DESC_FETCH] = "TX_DESC_FETCH",
 	[RESET_TYPE_TX_SKIP]       = "TX_SKIP",
+	[RESET_TYPE_MC_FAILURE]    = "MC_FAILURE",
 };
 
 #define EFX_MAX_MTU (9 * 1024)
@@ -1191,6 +1194,15 @@ static void efx_start_all(struct efx_nic *efx)
 
 	efx_nic_enable_interrupts(efx);
 
+	/* Switch to event based MCDI completions after enabling interrupts.
+	 * If a reset has been scheduled, then we need to stay in polled mode.
+	 * Rather than serialising efx_mcdi_mode_event() [which sleeps] and
+	 * reset_pending [modified from an atomic context], we instead guarantee
+	 * that efx_mcdi_mode_poll() isn't reverted erroneously */
+	efx_mcdi_mode_event(efx);
+	if (efx->reset_pending != RESET_TYPE_NONE)
+		efx_mcdi_mode_poll(efx);
+
 	/* Start the hardware monitor if there is one. Otherwise (we're link
 	 * event driven), we have to poll the PHY because after an event queue
 	 * flush, we could have a missed a link state change */
@@ -1242,6 +1254,9 @@ static void efx_stop_all(struct efx_nic *efx)
 
 	efx->type->stop_stats(efx);
 
+	/* Switch to MCDI polling on Siena before disabling interrupts */
+	efx_mcdi_mode_poll(efx);
+
 	/* Disable interrupts and wait for ISR to complete */
 	efx_nic_disable_interrupts(efx);
 	if (efx->legacy_irq)
@@ -1445,6 +1460,8 @@ static int efx_net_open(struct net_device *net_dev)
 		return -EIO;
 	if (efx->phy_mode & PHY_MODE_SPECIAL)
 		return -EBUSY;
+	if (efx_mcdi_poll_reboot(efx) && efx_reset(efx, RESET_TYPE_ALL))
+		return -EIO;
 
 	/* Notify the kernel of the link state polled during driver load,
 	 * before the monitor starts running */
@@ -1895,6 +1912,7 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
 	case RESET_TYPE_TX_SKIP:
 		method = RESET_TYPE_INVISIBLE;
 		break;
+	case RESET_TYPE_MC_FAILURE:
 	default:
 		method = RESET_TYPE_ALL;
 		break;
@@ -1908,6 +1926,10 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
 
 	efx->reset_pending = method;
 
+	/* efx_process_channel() will no longer read events once a
+	 * reset is scheduled. So switch back to poll'd MCDI completions. */
+	efx_mcdi_mode_poll(efx);
+
 	queue_work(reset_workqueue, &efx->reset_work);
 }
 
@@ -1923,6 +1945,10 @@ static struct pci_device_id efx_pci_table[] __devinitdata = {
 	 .driver_data = (unsigned long) &falcon_a1_nic_type},
 	{PCI_DEVICE(EFX_VENDID_SFC, FALCON_B_P_DEVID),
 	 .driver_data = (unsigned long) &falcon_b0_nic_type},
+	{PCI_DEVICE(EFX_VENDID_SFC, BETHPAGE_A_P_DEVID),
+	 .driver_data = (unsigned long) &siena_a0_nic_type},
+	{PCI_DEVICE(EFX_VENDID_SFC, SIENA_A_P_DEVID),
+	 .driver_data = (unsigned long) &siena_a0_nic_type},
 	{0}			/* end of list */
 };
 
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index fa40c7b..b4470da 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -18,6 +18,8 @@
 #define FALCON_A_P_DEVID	0x0703
 #define FALCON_A_S_DEVID        0x6703
 #define FALCON_B_P_DEVID        0x0710
+#define BETHPAGE_A_P_DEVID      0x0803
+#define SIENA_A_P_DEVID         0x0813
 
 /* Solarstorm controllers use BAR 0 for I/O space and BAR 2(&3) for memory */
 #define EFX_MEM_BAR 2
diff --git a/drivers/net/sfc/enum.h b/drivers/net/sfc/enum.h
index 7a9e79a..b1f7a40 100644
--- a/drivers/net/sfc/enum.h
+++ b/drivers/net/sfc/enum.h
@@ -144,6 +144,7 @@ enum efx_loopback_mode {
  * @RESET_TYPE_RX_DESC_FETCH: pcie error during rx descriptor fetch
  * @RESET_TYPE_TX_DESC_FETCH: pcie error during tx descriptor fetch
  * @RESET_TYPE_TX_SKIP: hardware completed empty tx descriptors
+ * @RESET_TYPE_MC_FAILURE: MC reboot/assertion
  */
 enum reset_type {
 	RESET_TYPE_NONE = -1,
@@ -158,6 +159,7 @@ enum reset_type {
 	RESET_TYPE_RX_DESC_FETCH,
 	RESET_TYPE_TX_DESC_FETCH,
 	RESET_TYPE_TX_SKIP,
+	RESET_TYPE_MC_FAILURE,
 	RESET_TYPE_MAX,
 };
 
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 012ee31..5492b63 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -236,6 +236,9 @@ static void efx_ethtool_get_drvinfo(struct net_device *net_dev,
 
 	strlcpy(info->driver, EFX_DRIVER_NAME, sizeof(info->driver));
 	strlcpy(info->version, EFX_DRIVER_VERSION, sizeof(info->version));
+	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0)
+		siena_print_fwver(efx, info->fw_version,
+				  sizeof(info->fw_version));
 	strlcpy(info->bus_info, pci_name(efx->pci_dev), sizeof(info->bus_info));
 }
 
diff --git a/drivers/net/sfc/mac.h b/drivers/net/sfc/mac.h
index d2af50f..c733863 100644
--- a/drivers/net/sfc/mac.h
+++ b/drivers/net/sfc/mac.h
@@ -15,6 +15,9 @@
 
 extern struct efx_mac_operations falcon_gmac_operations;
 extern struct efx_mac_operations falcon_xmac_operations;
+extern struct efx_mac_operations efx_mcdi_mac_operations;
 extern void falcon_reconfigure_xmac_core(struct efx_nic *efx);
+extern int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
+			      u32 dma_len, int enable, int clear);
 
 #endif
diff --git a/drivers/net/sfc/mtd.c b/drivers/net/sfc/mtd.c
index 65a22f1..ef561f8 100644
--- a/drivers/net/sfc/mtd.c
+++ b/drivers/net/sfc/mtd.c
@@ -8,6 +8,7 @@
  * by the Free Software Foundation, incorporated herein by reference.
  */
 
+#include <linux/bitops.h>
 #include <linux/module.h>
 #include <linux/mtd/mtd.h>
 #include <linux/delay.h>
@@ -18,12 +19,22 @@
 #include "spi.h"
 #include "efx.h"
 #include "nic.h"
+#include "mcdi.h"
+#include "mcdi_pcol.h"
 
 #define EFX_SPI_VERIFY_BUF_LEN 16
+#define EFX_MCDI_CHUNK_LEN 128
 
 struct efx_mtd_partition {
 	struct mtd_info mtd;
-	size_t offset;
+	union {
+		struct {
+			bool updating;
+			u8 nvram_type;
+			u16 fw_subtype;
+		} mcdi;
+		size_t offset;
+	};
 	const char *type_name;
 	char name[IFNAMSIZ + 20];
 };
@@ -56,6 +67,7 @@ struct efx_mtd {
 	container_of(mtd, struct efx_mtd_partition, mtd)
 
 static int falcon_mtd_probe(struct efx_nic *efx);
+static int siena_mtd_probe(struct efx_nic *efx);
 
 /* SPI utilities */
 
@@ -223,9 +235,14 @@ static void efx_mtd_rename_device(struct efx_mtd *efx_mtd)
 	struct efx_mtd_partition *part;
 
 	efx_for_each_partition(part, efx_mtd)
-		snprintf(part->name, sizeof(part->name),
-			 "%s %s", efx_mtd->efx->name,
-			 part->type_name);
+		if (efx_nic_rev(efx_mtd->efx) >= EFX_REV_SIENA_A0)
+			snprintf(part->name, sizeof(part->name),
+				 "%s %s:%02x", efx_mtd->efx->name,
+				 part->type_name, part->mcdi.fw_subtype);
+		else
+			snprintf(part->name, sizeof(part->name),
+				 "%s %s", efx_mtd->efx->name,
+				 part->type_name);
 }
 
 static int efx_mtd_probe_device(struct efx_nic *efx, struct efx_mtd *efx_mtd)
@@ -285,7 +302,10 @@ void efx_mtd_rename(struct efx_nic *efx)
 
 int efx_mtd_probe(struct efx_nic *efx)
 {
-	return falcon_mtd_probe(efx);
+	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0)
+		return siena_mtd_probe(efx);
+	else
+		return falcon_mtd_probe(efx);
 }
 
 /* Implementation of MTD operations for Falcon */
@@ -393,3 +413,240 @@ static int falcon_mtd_probe(struct efx_nic *efx)
 		kfree(efx_mtd);
 	return rc;
 }
+
+/* Implementation of MTD operations for Siena */
+
+static int siena_mtd_read(struct mtd_info *mtd, loff_t start,
+			  size_t len, size_t *retlen, u8 *buffer)
+{
+	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
+	struct efx_mtd *efx_mtd = mtd->priv;
+	struct efx_nic *efx = efx_mtd->efx;
+	loff_t offset = start;
+	loff_t end = min_t(loff_t, start + len, mtd->size);
+	size_t chunk;
+	int rc = 0;
+
+	while (offset < end) {
+		chunk = min_t(size_t, end - offset, EFX_MCDI_CHUNK_LEN);
+		rc = efx_mcdi_nvram_read(efx, part->mcdi.nvram_type, offset,
+					 buffer, chunk);
+		if (rc)
+			goto out;
+		offset += chunk;
+		buffer += chunk;
+	}
+out:
+	*retlen = offset - start;
+	return rc;
+}
+
+static int siena_mtd_erase(struct mtd_info *mtd, loff_t start, size_t len)
+{
+	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
+	struct efx_mtd *efx_mtd = mtd->priv;
+	struct efx_nic *efx = efx_mtd->efx;
+	loff_t offset = start & ~((loff_t)(mtd->erasesize - 1));
+	loff_t end = min_t(loff_t, start + len, mtd->size);
+	size_t chunk = part->mtd.erasesize;
+	int rc = 0;
+
+	if (!part->mcdi.updating) {
+		rc = efx_mcdi_nvram_update_start(efx, part->mcdi.nvram_type);
+		if (rc)
+			goto out;
+		part->mcdi.updating = 1;
+	}
+
+	/* The MCDI interface can in fact do multiple erase blocks at once;
+	 * but erasing may be slow, so we make multiple calls here to avoid
+	 * tripping the MCDI RPC timeout. */
+	while (offset < end) {
+		rc = efx_mcdi_nvram_erase(efx, part->mcdi.nvram_type, offset,
+					  chunk);
+		if (rc)
+			goto out;
+		offset += chunk;
+	}
+out:
+	return rc;
+}
+
+static int siena_mtd_write(struct mtd_info *mtd, loff_t start,
+			   size_t len, size_t *retlen, const u8 *buffer)
+{
+	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
+	struct efx_mtd *efx_mtd = mtd->priv;
+	struct efx_nic *efx = efx_mtd->efx;
+	loff_t offset = start;
+	loff_t end = min_t(loff_t, start + len, mtd->size);
+	size_t chunk;
+	int rc = 0;
+
+	if (!part->mcdi.updating) {
+		rc = efx_mcdi_nvram_update_start(efx, part->mcdi.nvram_type);
+		if (rc)
+			goto out;
+		part->mcdi.updating = 1;
+	}
+
+	while (offset < end) {
+		chunk = min_t(size_t, end - offset, EFX_MCDI_CHUNK_LEN);
+		rc = efx_mcdi_nvram_write(efx, part->mcdi.nvram_type, offset,
+					  buffer, chunk);
+		if (rc)
+			goto out;
+		offset += chunk;
+		buffer += chunk;
+	}
+out:
+	*retlen = offset - start;
+	return rc;
+}
+
+static int siena_mtd_sync(struct mtd_info *mtd)
+{
+	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
+	struct efx_mtd *efx_mtd = mtd->priv;
+	struct efx_nic *efx = efx_mtd->efx;
+	int rc = 0;
+
+	if (part->mcdi.updating) {
+		part->mcdi.updating = 0;
+		rc = efx_mcdi_nvram_update_finish(efx, part->mcdi.nvram_type);
+	}
+
+	return rc;
+}
+
+static struct efx_mtd_ops siena_mtd_ops = {
+	.read	= siena_mtd_read,
+	.erase	= siena_mtd_erase,
+	.write	= siena_mtd_write,
+	.sync	= siena_mtd_sync,
+};
+
+struct siena_nvram_type_info {
+	int port;
+	const char *name;
+};
+
+static struct siena_nvram_type_info siena_nvram_types[] = {
+	[MC_CMD_NVRAM_TYPE_DISABLED_CALLISTO]	= { 0, "sfc_dummy_phy" },
+	[MC_CMD_NVRAM_TYPE_MC_FW]		= { 0, "sfc_mcfw" },
+	[MC_CMD_NVRAM_TYPE_MC_FW_BACKUP]	= { 0, "sfc_mcfw_backup" },
+	[MC_CMD_NVRAM_TYPE_STATIC_CFG_PORT0]	= { 0, "sfc_static_cfg" },
+	[MC_CMD_NVRAM_TYPE_STATIC_CFG_PORT1]	= { 1, "sfc_static_cfg" },
+	[MC_CMD_NVRAM_TYPE_DYNAMIC_CFG_PORT0]	= { 0, "sfc_dynamic_cfg" },
+	[MC_CMD_NVRAM_TYPE_DYNAMIC_CFG_PORT1]	= { 1, "sfc_dynamic_cfg" },
+	[MC_CMD_NVRAM_TYPE_EXP_ROM]		= { 0, "sfc_exp_rom" },
+	[MC_CMD_NVRAM_TYPE_EXP_ROM_CFG_PORT0]	= { 0, "sfc_exp_rom_cfg" },
+	[MC_CMD_NVRAM_TYPE_EXP_ROM_CFG_PORT1]	= { 1, "sfc_exp_rom_cfg" },
+	[MC_CMD_NVRAM_TYPE_PHY_PORT0]		= { 0, "sfc_phy_fw" },
+	[MC_CMD_NVRAM_TYPE_PHY_PORT1]		= { 1, "sfc_phy_fw" },
+};
+
+static int siena_mtd_probe_partition(struct efx_nic *efx,
+				     struct efx_mtd *efx_mtd,
+				     unsigned int part_id,
+				     unsigned int type)
+{
+	struct efx_mtd_partition *part = &efx_mtd->part[part_id];
+	struct siena_nvram_type_info *info;
+	size_t size, erase_size;
+	bool protected;
+	int rc;
+
+	if (type >= ARRAY_SIZE(siena_nvram_types))
+		return -ENODEV;
+
+	info = &siena_nvram_types[type];
+
+	if (info->port != efx_port_num(efx))
+		return -ENODEV;
+
+	rc = efx_mcdi_nvram_info(efx, type, &size, &erase_size, &protected);
+	if (rc)
+		return rc;
+	if (protected)
+		return -ENODEV; /* hide it */
+
+	part->mcdi.nvram_type = type;
+	part->type_name = info->name;
+
+	part->mtd.type = MTD_NORFLASH;
+	part->mtd.flags = MTD_CAP_NORFLASH;
+	part->mtd.size = size;
+	part->mtd.erasesize = erase_size;
+
+	return 0;
+}
+
+static int siena_mtd_get_fw_subtypes(struct efx_nic *efx,
+				     struct efx_mtd *efx_mtd)
+{
+	struct efx_mtd_partition *part;
+	uint16_t fw_subtype_list[MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_LEN /
+				 sizeof(uint16_t)];
+	int rc;
+
+	rc = efx_mcdi_get_board_cfg(efx, NULL, fw_subtype_list);
+	if (rc)
+		return rc;
+
+	efx_for_each_partition(part, efx_mtd)
+		part->mcdi.fw_subtype = fw_subtype_list[part->mcdi.nvram_type];
+
+	return 0;
+}
+
+static int siena_mtd_probe(struct efx_nic *efx)
+{
+	struct efx_mtd *efx_mtd;
+	int rc = -ENODEV;
+	u32 nvram_types;
+	unsigned int type;
+
+	ASSERT_RTNL();
+
+	rc = efx_mcdi_nvram_types(efx, &nvram_types);
+	if (rc)
+		return rc;
+
+	efx_mtd = kzalloc(sizeof(*efx_mtd) +
+			  hweight32(nvram_types) * sizeof(efx_mtd->part[0]),
+			  GFP_KERNEL);
+	if (!efx_mtd)
+		return -ENOMEM;
+
+	efx_mtd->name = "Siena NVRAM manager";
+
+	efx_mtd->ops = &siena_mtd_ops;
+
+	type = 0;
+	efx_mtd->n_parts = 0;
+
+	while (nvram_types != 0) {
+		if (nvram_types & 1) {
+			rc = siena_mtd_probe_partition(efx, efx_mtd,
+						       efx_mtd->n_parts, type);
+			if (rc == 0)
+				efx_mtd->n_parts++;
+			else if (rc != -ENODEV)
+				goto fail;
+		}
+		type++;
+		nvram_types >>= 1;
+	}
+
+	rc = siena_mtd_get_fw_subtypes(efx, efx_mtd);
+	if (rc)
+		goto fail;
+
+	rc = efx_mtd_probe_device(efx, efx_mtd);
+fail:
+	if (rc)
+		kfree(efx_mtd);
+	return rc;
+}
+
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 96d3f00..ec13203 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -706,6 +706,7 @@ union efx_multicast_hash {
  * @phy_op: PHY interface
  * @phy_data: PHY private data (including PHY-specific stats)
  * @mdio: PHY MDIO interface
+ * @mdio_bus: PHY MDIO bus ID (only used by Siena)
  * @phy_mode: PHY operating mode. Serialised by @mac_lock.
  * @xmac_poll_required: XMAC link state needs polling
  * @link_advertising: Autonegotiation advertising flags
@@ -756,6 +757,7 @@ struct efx_nic {
 
 	struct efx_buffer irq_status;
 	volatile signed int last_irq_cpu;
+	unsigned long irq_zero_count;
 
 	struct efx_spi_device *spi_flash;
 	struct efx_spi_device *spi_eeprom;
@@ -766,7 +768,7 @@ struct efx_nic {
 
 	unsigned n_rx_nodesc_drop_cnt;
 
-	struct falcon_nic_data *nic_data;
+	void *nic_data;
 
 	struct mutex mac_lock;
 	struct work_struct mac_work;
@@ -792,6 +794,7 @@ struct efx_nic {
 	struct efx_phy_operations *phy_op;
 	void *phy_data;
 	struct mdio_if_info mdio;
+	unsigned int mdio_bus;
 	enum efx_phy_mode phy_mode;
 
 	bool xmac_poll_required;
@@ -824,6 +827,11 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
 	return efx_dev_registered(efx) ? efx->name : "";
 }
 
+static inline unsigned int efx_port_num(struct efx_nic *efx)
+{
+	return PCI_FUNC(efx->pci_dev->devfn);
+}
+
 /**
  * struct efx_nic_type - Efx device type definition
  * @probe: Probe the controller
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 55dbd79..5ac4b1a 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -997,6 +997,9 @@ int efx_nic_process_eventq(struct efx_channel *channel, int rx_quota)
 		case FSE_AZ_EV_CODE_DRIVER_EV:
 			efx_handle_driver_event(channel, &event);
 			break;
+		case FSE_CZ_EV_CODE_MCDI_EV:
+			efx_mcdi_process_event(channel, &event);
+			break;
 		default:
 			EFX_ERR(channel->efx, "channel %d unknown event type %d"
 				" (data " EFX_QWORD_FMT ")\n", channel->channel,
@@ -1025,13 +1028,21 @@ int efx_nic_probe_eventq(struct efx_channel *channel)
 
 void efx_nic_init_eventq(struct efx_channel *channel)
 {
-	efx_oword_t evq_ptr;
+	efx_oword_t reg;
 	struct efx_nic *efx = channel->efx;
 
 	EFX_LOG(efx, "channel %d event queue in special buffers %d-%d\n",
 		channel->channel, channel->eventq.index,
 		channel->eventq.index + channel->eventq.entries - 1);
 
+	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0) {
+		EFX_POPULATE_OWORD_3(reg,
+				     FRF_CZ_TIMER_Q_EN, 1,
+				     FRF_CZ_HOST_NOTIFY_MODE, 0,
+				     FRF_CZ_TIMER_MODE, FFE_CZ_TIMER_MODE_DIS);
+		efx_writeo_table(efx, &reg, FR_BZ_TIMER_TBL, channel->channel);
+	}
+
 	/* Pin event queue buffer */
 	efx_init_special_buffer(efx, &channel->eventq);
 
@@ -1039,11 +1050,11 @@ void efx_nic_init_eventq(struct efx_channel *channel)
 	memset(channel->eventq.addr, 0xff, channel->eventq.len);
 
 	/* Push event queue to card */
-	EFX_POPULATE_OWORD_3(evq_ptr,
+	EFX_POPULATE_OWORD_3(reg,
 			     FRF_AZ_EVQ_EN, 1,
 			     FRF_AZ_EVQ_SIZE, __ffs(channel->eventq.entries),
 			     FRF_AZ_EVQ_BUF_BASE_ID, channel->eventq.index);
-	efx_writeo_table(efx, &evq_ptr, efx->type->evq_ptr_tbl_base,
+	efx_writeo_table(efx, &reg, efx->type->evq_ptr_tbl_base,
 			 channel->channel);
 
 	efx->type->push_irq_moderation(channel);
@@ -1051,13 +1062,15 @@ void efx_nic_init_eventq(struct efx_channel *channel)
 
 void efx_nic_fini_eventq(struct efx_channel *channel)
 {
-	efx_oword_t eventq_ptr;
+	efx_oword_t reg;
 	struct efx_nic *efx = channel->efx;
 
 	/* Remove event queue from card */
-	EFX_ZERO_OWORD(eventq_ptr);
-	efx_writeo_table(efx, &eventq_ptr, efx->type->evq_ptr_tbl_base,
+	EFX_ZERO_OWORD(reg);
+	efx_writeo_table(efx, &reg, efx->type->evq_ptr_tbl_base,
 			 channel->channel);
+	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0)
+		efx_writeo_table(efx, &reg, FR_BZ_TIMER_TBL, channel->channel);
 
 	/* Unpin event queue */
 	efx_fini_special_buffer(efx, &channel->eventq);
@@ -1220,8 +1233,15 @@ static inline void efx_nic_interrupts(struct efx_nic *efx,
 				      bool enabled, bool force)
 {
 	efx_oword_t int_en_reg_ker;
+	unsigned int level = 0;
+
+	if (EFX_WORKAROUND_17213(efx) && !EFX_INT_MODE_USE_MSI(efx))
+		/* Set the level always even if we're generating a test
+		 * interrupt, because our legacy interrupt handler is safe */
+		level = 0x1f;
 
-	EFX_POPULATE_OWORD_2(int_en_reg_ker,
+	EFX_POPULATE_OWORD_3(int_en_reg_ker,
+			     FRF_AZ_KER_INT_LEVE_SEL, level,
 			     FRF_AZ_KER_INT_KER, force,
 			     FRF_AZ_DRV_INT_EN_KER, enabled);
 	efx_writeo(efx, &int_en_reg_ker, FR_AZ_INT_EN_KER);
@@ -1334,15 +1354,30 @@ static irqreturn_t efx_legacy_interrupt(int irq, void *dev_id)
 	if (unlikely(syserr))
 		return efx_nic_fatal_interrupt(efx);
 
-	/* Schedule processing of any interrupting queues */
-	efx_for_each_channel(channel, efx) {
-		if ((queues & 1) ||
-		    efx_event_present(
-			    efx_event(channel, channel->eventq_read_ptr))) {
+	if (queues != 0) {
+		if (EFX_WORKAROUND_15783(efx))
+			efx->irq_zero_count = 0;
+
+		/* Schedule processing of any interrupting queues */
+		efx_for_each_channel(channel, efx) {
+			if (queues & 1)
+				efx_schedule_channel(channel);
+			queues >>= 1;
+		}
+		result = IRQ_HANDLED;
+
+	} else if (EFX_WORKAROUND_15783(efx) &&
+		   efx->irq_zero_count++ == 0) {
+		efx_qword_t *event;
+
+		/* Ensure we rearm all event queues */
+		efx_for_each_channel(channel, efx) {
+			event = efx_event(channel, channel->eventq_read_ptr);
+			if (efx_event_present(event))
 				efx_schedule_channel(channel);
-			result = IRQ_HANDLED;
 		}
-		queues >>= 1;
+
+		result = IRQ_HANDLED;
 	}
 
 	if (result == IRQ_HANDLED) {
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index e7eb304..57c510d 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -14,6 +14,7 @@
 #include <linux/i2c-algo-bit.h>
 #include "net_driver.h"
 #include "efx.h"
+#include "mcdi.h"
 
 /*
  * Falcon hardware control
@@ -23,6 +24,7 @@ enum {
 	EFX_REV_FALCON_A0 = 0,
 	EFX_REV_FALCON_A1 = 1,
 	EFX_REV_FALCON_B0 = 2,
+	EFX_REV_SIENA_A0 = 3,
 };
 
 static inline int efx_nic_rev(struct efx_nic *efx)
@@ -32,6 +34,10 @@ static inline int efx_nic_rev(struct efx_nic *efx)
 
 extern u32 efx_nic_fpga_ver(struct efx_nic *efx);
 
+static inline bool efx_nic_has_mc(struct efx_nic *efx)
+{
+	return efx_nic_rev(efx) >= EFX_REV_SIENA_A0;
+}
 /* NIC has two interlinked PCI functions for the same port. */
 static inline bool efx_nic_is_dual_func(struct efx_nic *efx)
 {
@@ -123,8 +129,25 @@ static inline struct falcon_board *falcon_board(struct efx_nic *efx)
 	return &data->board;
 }
 
+/**
+ * struct siena_nic_data - Siena NIC state
+ * @fw_version: Management controller firmware version
+ * @fw_build: Firmware build number
+ * @mcdi: Management-Controller-to-Driver Interface
+ * @wol_filter_id: Wake-on-LAN packet filter id
+ */
+struct siena_nic_data {
+	u64 fw_version;
+	u32 fw_build;
+	struct efx_mcdi_iface mcdi;
+	int wol_filter_id;
+};
+
+extern void siena_print_fwver(struct efx_nic *efx, char *buf, size_t len);
+
 extern struct efx_nic_type falcon_a1_nic_type;
 extern struct efx_nic_type falcon_b0_nic_type;
+extern struct efx_nic_type siena_a0_nic_type;
 
 /**************************************************************************
  *
diff --git a/drivers/net/sfc/phy.h b/drivers/net/sfc/phy.h
index 2ad1cec..64dff2d 100644
--- a/drivers/net/sfc/phy.h
+++ b/drivers/net/sfc/phy.h
@@ -41,4 +41,21 @@ extern struct efx_phy_operations falcon_qt202x_phy_ops;
 
 extern void falcon_qt202x_set_led(struct efx_nic *p, int led, int state);
 
+/****************************************************************************
+ * Siena managed PHYs
+ */
+extern struct efx_phy_operations efx_mcdi_phy_ops;
+
+extern int efx_mcdi_mdio_read(struct efx_nic *efx, unsigned int bus,
+			      unsigned int prtad, unsigned int devad,
+			      u16 addr, u16 *value_out, u32 *status_out);
+extern int efx_mcdi_mdio_write(struct efx_nic *efx, unsigned int bus,
+			       unsigned int prtad, unsigned int devad,
+			       u16 addr, u16 value, u32 *status_out);
+extern void efx_mcdi_phy_decode_link(struct efx_nic *efx,
+				     struct efx_link_state *link_state,
+				     u32 speed, u32 flags, u32 fcntl);
+extern int efx_mcdi_phy_reconfigure(struct efx_nic *efx);
+extern void efx_mcdi_phy_check_fcntl(struct efx_nic *efx, u32 lpa);
+
 #endif
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index 021d0d2..ecee8f5 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -18,6 +18,7 @@
 #define EFX_WORKAROUND_ALWAYS(efx) 1
 #define EFX_WORKAROUND_FALCON_A(efx) (efx_nic_rev(efx) <= EFX_REV_FALCON_A1)
 #define EFX_WORKAROUND_FALCON_AB(efx) (efx_nic_rev(efx) <= EFX_REV_FALCON_B0)
+#define EFX_WORKAROUND_SIENA(efx) (efx_nic_rev(efx) == EFX_REV_SIENA_A0)
 #define EFX_WORKAROUND_10G(efx) EFX_IS10G(efx)
 #define EFX_WORKAROUND_SFT9001(efx) ((efx)->phy_type == PHY_TYPE_SFT9001A || \
 				     (efx)->phy_type == PHY_TYPE_SFT9001B)
@@ -35,6 +36,10 @@
 #define EFX_WORKAROUND_11482 EFX_WORKAROUND_FALCON_AB
 /* Truncated IPv4 packets can confuse the TX packet parser */
 #define EFX_WORKAROUND_15592 EFX_WORKAROUND_FALCON_AB
+/* Legacy ISR read can return zero once */
+#define EFX_WORKAROUND_15783 EFX_WORKAROUND_SIENA
+/* Legacy interrupt storm when interrupt fifo fills */
+#define EFX_WORKAROUND_17213 EFX_WORKAROUND_SIENA
 
 /* Spurious parity errors in TSORT buffers */
 #define EFX_WORKAROUND_5129 EFX_WORKAROUND_FALCON_A
-- 
1.6.5.3




-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

