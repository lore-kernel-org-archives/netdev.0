From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 38/52] sfc: Extend self-tests
Date: Mon, 1 Sep 2008 12:49:02 +0100
Message-ID: <20080901114901.GF7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:42466 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756628AbYIALtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:49:05 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Include PMA/PMD in loopback self-tests as intended.

Add NVRAM checksum validation and include it in self-tests.

Add register self-tests.

Run PHY self-tests where available.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/bitfield.h      |   19 +++-
 drivers/net/sfc/efx.c           |   20 ++-
 drivers/net/sfc/efx.h           |    6 +
 drivers/net/sfc/ethtool.c       |   22 ++--
 drivers/net/sfc/falcon.c        |  198 ++++++++++++++++++++++++----
 drivers/net/sfc/falcon.h        |    6 +
 drivers/net/sfc/falcon_hwdefs.h |    4 +-
 drivers/net/sfc/falcon_xmac.c   |   14 +--
 drivers/net/sfc/net_driver.h    |   16 ++-
 drivers/net/sfc/selftest.c      |  277 ++++++++++++++++++++++++---------------
 drivers/net/sfc/selftest.h      |    9 +-
 drivers/net/sfc/tenxpress.c     |   22 +--
 12 files changed, 429 insertions(+), 184 deletions(-)

diff --git a/drivers/net/sfc/bitfield.h b/drivers/net/sfc/bitfield.h
index b757a39..d95c218 100644
--- a/drivers/net/sfc/bitfield.h
+++ b/drivers/net/sfc/bitfield.h
@@ -416,12 +416,23 @@ typedef union efx_oword {
  * for read-modify-write operations.
  *
  */
-
 #define EFX_INVERT_OWORD(oword) do {		\
 	(oword).u64[0] = ~((oword).u64[0]);	\
 	(oword).u64[1] = ~((oword).u64[1]);	\
 	} while (0)
 
+#define EFX_AND_OWORD(oword, from, mask)			\
+	do {							\
+		(oword).u64[0] = (from).u64[0] & (mask).u64[0];	\
+		(oword).u64[1] = (from).u64[1] & (mask).u64[1];	\
+	} while (0)
+
+#define EFX_OR_OWORD(oword, from, mask)				\
+	do {							\
+		(oword).u64[0] = (from).u64[0] | (mask).u64[0];	\
+		(oword).u64[1] = (from).u64[1] | (mask).u64[1];	\
+	} while (0)
+
 #define EFX_INSERT64(min, max, low, high, value)			\
 	cpu_to_le64(EFX_INSERT_NATIVE(min, max, low, high, value))
 
@@ -529,4 +540,10 @@ typedef union efx_oword {
 #define EFX_DMA_TYPE_WIDTH(width) \
 	(((width) < DMA_ADDR_T_WIDTH) ? (width) : DMA_ADDR_T_WIDTH)
 
+
+/* Static initialiser */
+#define EFX_OWORD32(a, b, c, d)						\
+	{ .u32 = { __constant_cpu_to_le32(a), __constant_cpu_to_le32(b), \
+		   __constant_cpu_to_le32(c), __constant_cpu_to_le32(d) } }
+
 #endif /* EFX_BITFIELD_H */
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index f34dbf2..e1e2f80 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -508,6 +508,11 @@ static void efx_link_status_changed(struct efx_nic *efx)
 	if (!netif_running(efx->net_dev))
 		return;
 
+	if (efx->port_inhibited) {
+		netif_carrier_off(efx->net_dev);
+		return;
+	}
+
 	if (efx->link_up != netif_carrier_ok(efx->net_dev)) {
 		efx->n_link_state_changes++;
 
@@ -549,7 +554,7 @@ static void efx_link_status_changed(struct efx_nic *efx)
 
 /* This call reinitialises the MAC to pick up new PHY settings. The
  * caller must hold the mac_lock */
-static void __efx_reconfigure_port(struct efx_nic *efx)
+void __efx_reconfigure_port(struct efx_nic *efx)
 {
 	WARN_ON(!mutex_is_locked(&efx->mac_lock));
 
@@ -634,6 +639,7 @@ static int efx_init_port(struct efx_nic *efx)
 		return rc;
 
 	efx->port_initialized = true;
+	efx->stats_enabled = true;
 
 	/* Reconfigure port to program MAC registers */
 	falcon_reconfigure_xmac(efx);
@@ -1311,7 +1317,7 @@ static struct net_device_stats *efx_net_stats(struct net_device *net_dev)
 	 */
 	if (!spin_trylock(&efx->stats_lock))
 		return stats;
-	if (efx->state == STATE_RUNNING) {
+	if (efx->stats_enabled) {
 		falcon_update_stats_xmac(efx);
 		falcon_update_nic_stats(efx);
 	}
@@ -1529,7 +1535,7 @@ static void efx_unregister_netdev(struct efx_nic *efx)
 
 /* Tears down the entire software state and most of the hardware state
  * before reset.  */
-static void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
 	int rc;
 
@@ -1538,6 +1544,7 @@ static void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 	/* The net_dev->get_stats handler is quite slow, and will fail
 	 * if a fetch is pending over reset. Serialise against it. */
 	spin_lock(&efx->stats_lock);
+	efx->stats_enabled = false;
 	spin_unlock(&efx->stats_lock);
 
 	efx_stop_all(efx);
@@ -1555,8 +1562,7 @@ static void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd)
  * that we were unable to reinitialise the hardware, and the
  * driver should be disabled. If ok is false, then the rx and tx
  * engines are not restarted, pending a RESET_DISABLE. */
-static int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd,
-			bool ok)
+int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd, bool ok)
 {
 	int rc;
 
@@ -1577,8 +1583,10 @@ static int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd,
 
 	mutex_unlock(&efx->mac_lock);
 
-	if (ok)
+	if (ok) {
 		efx_start_all(efx);
+		efx->stats_enabled = true;
+	}
 	return rc;
 }
 
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 9a8c283..d02937b 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -37,6 +37,12 @@ extern void efx_flush_queues(struct efx_nic *efx);
 
 /* Ports */
 extern void efx_reconfigure_port(struct efx_nic *efx);
+extern void __efx_reconfigure_port(struct efx_nic *efx);
+
+/* Reset handling */
+extern void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd);
+extern int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd,
+			bool ok);
 
 /* Global */
 extern void efx_schedule_reset(struct efx_nic *efx, enum reset_type type);
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 7989416..fa98af5 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -333,7 +333,10 @@ static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
 	unsigned int n = 0;
 	enum efx_loopback_mode mode;
 
-	/* Interrupt */
+	efx_fill_test(n++, strings, data, &tests->mii,
+		      "core", 0, "mii", NULL);
+	efx_fill_test(n++, strings, data, &tests->nvram,
+		      "core", 0, "nvram", NULL);
 	efx_fill_test(n++, strings, data, &tests->interrupt,
 		      "core", 0, "interrupt", NULL);
 
@@ -353,16 +356,17 @@ static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
 			      "eventq.poll", NULL);
 	}
 
-	/* PHY presence */
-	efx_fill_test(n++, strings, data, &tests->phy_ok,
-		      EFX_PORT_NAME, "phy_ok", NULL);
+	efx_fill_test(n++, strings, data, &tests->registers,
+		      "core", 0, "registers", NULL);
+	efx_fill_test(n++, strings, data, &tests->phy,
+		      EFX_PORT_NAME, "phy", NULL);
 
 	/* Loopback tests */
 	efx_fill_test(n++, strings, data, &tests->loopback_speed,
 		      EFX_PORT_NAME, "loopback.speed", NULL);
 	efx_fill_test(n++, strings, data, &tests->loopback_full_duplex,
 		      EFX_PORT_NAME, "loopback.full_duplex", NULL);
-	for (mode = LOOPBACK_NONE; mode < LOOPBACK_TEST_MAX; mode++) {
+	for (mode = LOOPBACK_NONE; mode <= LOOPBACK_TEST_MAX; mode++) {
 		if (!(efx->loopback_modes & (1 << mode)))
 			continue;
 		n = efx_fill_loopback_test(efx,
@@ -500,15 +504,9 @@ static void efx_ethtool_self_test(struct net_device *net_dev,
 		goto out;
 
 	/* Perform offline tests only if online tests passed */
-	if (offline) {
-		/* Stop the kernel from sending packets during the test. */
-		efx_stop_queue(efx);
-		efx_flush_queues(efx);
-
+	if (offline)
 		rc = efx_offline_test(efx, &efx_tests,
 				      efx->loopback_modes);
-		efx_wake_queue(efx);
-	}
 
  out:
 	if (!already_up)
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index e66d6cf..e0c0b23 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2223,6 +2223,170 @@ void falcon_set_multicast_hash(struct efx_nic *efx)
 	falcon_write(efx, &mc_hash->oword[1], MAC_MCAST_HASH_REG1_KER);
 }
 
+
+/**************************************************************************
+ *
+ * Falcon test code
+ *
+ **************************************************************************/
+
+int falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
+{
+	struct falcon_nvconfig *nvconfig;
+	struct efx_spi_device *spi;
+	void *region;
+	int rc, magic_num, struct_ver;
+	__le16 *word, *limit;
+	u32 csum;
+
+	region = kmalloc(NVCONFIG_END, GFP_KERNEL);
+	if (!region)
+		return -ENOMEM;
+	nvconfig = region + NVCONFIG_OFFSET;
+
+	spi = efx->spi_flash ? efx->spi_flash : efx->spi_eeprom;
+	rc = falcon_spi_read(spi, 0, NVCONFIG_END, NULL, region);
+	if (rc) {
+		EFX_ERR(efx, "Failed to read %s\n",
+			efx->spi_flash ? "flash" : "EEPROM");
+		rc = -EIO;
+		goto out;
+	}
+
+	magic_num = le16_to_cpu(nvconfig->board_magic_num);
+	struct_ver = le16_to_cpu(nvconfig->board_struct_ver);
+
+	rc = -EINVAL;
+	if (magic_num != NVCONFIG_BOARD_MAGIC_NUM) {
+		EFX_ERR(efx, "NVRAM bad magic 0x%x\n", magic_num);
+		goto out;
+	}
+	if (struct_ver < 2) {
+		EFX_ERR(efx, "NVRAM has ancient version 0x%x\n", struct_ver);
+		goto out;
+	} else if (struct_ver < 4) {
+		word = &nvconfig->board_magic_num;
+		limit = (__le16 *) (nvconfig + 1);
+	} else {
+		word = region;
+		limit = region + NVCONFIG_END;
+	}
+	for (csum = 0; word < limit; ++word)
+		csum += le16_to_cpu(*word);
+
+	if (~csum & 0xffff) {
+		EFX_ERR(efx, "NVRAM has incorrect checksum\n");
+		goto out;
+	}
+
+	rc = 0;
+	if (nvconfig_out)
+		memcpy(nvconfig_out, nvconfig, sizeof(*nvconfig));
+
+ out:
+	kfree(region);
+	return rc;
+}
+
+/* Registers tested in the falcon register test */
+static struct {
+	unsigned address;
+	efx_oword_t mask;
+} efx_test_registers[] = {
+	{ ADR_REGION_REG_KER,
+	  EFX_OWORD32(0x0001FFFF, 0x0001FFFF, 0x0001FFFF, 0x0001FFFF) },
+	{ RX_CFG_REG_KER,
+	  EFX_OWORD32(0xFFFFFFFE, 0x00017FFF, 0x00000000, 0x00000000) },
+	{ TX_CFG_REG_KER,
+	  EFX_OWORD32(0x7FFF0037, 0x00000000, 0x00000000, 0x00000000) },
+	{ TX_CFG2_REG_KER,
+	  EFX_OWORD32(0xFFFEFE80, 0x1FFFFFFF, 0x020000FE, 0x007FFFFF) },
+	{ MAC0_CTRL_REG_KER,
+	  EFX_OWORD32(0xFFFF0000, 0x00000000, 0x00000000, 0x00000000) },
+	{ SRM_TX_DC_CFG_REG_KER,
+	  EFX_OWORD32(0x001FFFFF, 0x00000000, 0x00000000, 0x00000000) },
+	{ RX_DC_CFG_REG_KER,
+	  EFX_OWORD32(0x0000000F, 0x00000000, 0x00000000, 0x00000000) },
+	{ RX_DC_PF_WM_REG_KER,
+	  EFX_OWORD32(0x000003FF, 0x00000000, 0x00000000, 0x00000000) },
+	{ DP_CTRL_REG,
+	  EFX_OWORD32(0x00000FFF, 0x00000000, 0x00000000, 0x00000000) },
+	{ XM_GLB_CFG_REG,
+	  EFX_OWORD32(0x00000C68, 0x00000000, 0x00000000, 0x00000000) },
+	{ XM_TX_CFG_REG,
+	  EFX_OWORD32(0x00080164, 0x00000000, 0x00000000, 0x00000000) },
+	{ XM_RX_CFG_REG,
+	  EFX_OWORD32(0x07100A0C, 0x00000000, 0x00000000, 0x00000000) },
+	{ XM_RX_PARAM_REG,
+	  EFX_OWORD32(0x00001FF8, 0x00000000, 0x00000000, 0x00000000) },
+	{ XM_FC_REG,
+	  EFX_OWORD32(0xFFFF0001, 0x00000000, 0x00000000, 0x00000000) },
+	{ XM_ADR_LO_REG,
+	  EFX_OWORD32(0xFFFFFFFF, 0x00000000, 0x00000000, 0x00000000) },
+	{ XX_SD_CTL_REG,
+	  EFX_OWORD32(0x0003FF0F, 0x00000000, 0x00000000, 0x00000000) },
+};
+
+static bool efx_masked_compare_oword(const efx_oword_t *a, const efx_oword_t *b,
+				     const efx_oword_t *mask)
+{
+	return ((a->u64[0] ^ b->u64[0]) & mask->u64[0]) ||
+		((a->u64[1] ^ b->u64[1]) & mask->u64[1]);
+}
+
+int falcon_test_registers(struct efx_nic *efx)
+{
+	unsigned address = 0, i, j;
+	efx_oword_t mask, imask, original, reg, buf;
+
+	/* Falcon should be in loopback to isolate the XMAC from the PHY */
+	WARN_ON(!LOOPBACK_INTERNAL(efx));
+
+	for (i = 0; i < ARRAY_SIZE(efx_test_registers); ++i) {
+		address = efx_test_registers[i].address;
+		mask = imask = efx_test_registers[i].mask;
+		EFX_INVERT_OWORD(imask);
+
+		falcon_read(efx, &original, address);
+
+		/* bit sweep on and off */
+		for (j = 0; j < 128; j++) {
+			if (!EFX_EXTRACT_OWORD32(mask, j, j))
+				continue;
+
+			/* Test this testable bit can be set in isolation */
+			EFX_AND_OWORD(reg, original, mask);
+			EFX_SET_OWORD32(reg, j, j, 1);
+
+			falcon_write(efx, &reg, address);
+			falcon_read(efx, &buf, address);
+
+			if (efx_masked_compare_oword(&reg, &buf, &mask))
+				goto fail;
+
+			/* Test this testable bit can be cleared in isolation */
+			EFX_OR_OWORD(reg, original, mask);
+			EFX_SET_OWORD32(reg, j, j, 0);
+
+			falcon_write(efx, &reg, address);
+			falcon_read(efx, &buf, address);
+
+			if (efx_masked_compare_oword(&reg, &buf, &mask))
+				goto fail;
+		}
+
+		falcon_write(efx, &original, address);
+	}
+
+	return 0;
+
+fail:
+	EFX_ERR(efx, "wrote "EFX_OWORD_FMT" read "EFX_OWORD_FMT
+		" at address 0x%x mask "EFX_OWORD_FMT"\n", EFX_OWORD_VAL(reg),
+		EFX_OWORD_VAL(buf), address, EFX_OWORD_VAL(mask));
+	return -EIO;
+}
+
 /**************************************************************************
  *
  * Device reset
@@ -2404,37 +2568,22 @@ static void falcon_remove_spi_devices(struct efx_nic *efx)
 static int falcon_probe_nvconfig(struct efx_nic *efx)
 {
 	struct falcon_nvconfig *nvconfig;
-	struct efx_spi_device *spi;
-	int magic_num, struct_ver, board_rev;
+	int board_rev;
 	int rc;
 
 	nvconfig = kmalloc(sizeof(*nvconfig), GFP_KERNEL);
 	if (!nvconfig)
 		return -ENOMEM;
 
-	/* Read the whole configuration structure into memory. */
-	spi = efx->spi_flash ? efx->spi_flash : efx->spi_eeprom;
-	rc = falcon_spi_read(spi, NVCONFIG_BASE, sizeof(*nvconfig),
-			     NULL, (char *)nvconfig);
-	if (rc) {
-		EFX_ERR(efx, "Failed to read %s\n", efx->spi_flash ? "flash" :
-			"EEPROM");
-		goto fail1;
-	}
-
-	/* Read the MAC addresses */
-	memcpy(efx->mac_address, nvconfig->mac_address[0], ETH_ALEN);
-
-	/* Read the board configuration. */
-	magic_num = le16_to_cpu(nvconfig->board_magic_num);
-	struct_ver = le16_to_cpu(nvconfig->board_struct_ver);
-
-	if (magic_num != NVCONFIG_BOARD_MAGIC_NUM || struct_ver < 2) {
-		EFX_ERR(efx, "Non volatile memory bad magic=%x ver=%x "
-			"therefore using defaults\n", magic_num, struct_ver);
+	rc = falcon_read_nvram(efx, nvconfig);
+	if (rc == -EINVAL) {
+		EFX_ERR(efx, "NVRAM is invalid therefore using defaults\n");
 		efx->phy_type = PHY_TYPE_NONE;
 		efx->mii.phy_id = PHY_ADDR_INVALID;
 		board_rev = 0;
+		rc = 0;
+	} else if (rc) {
+		goto fail1;
 	} else {
 		struct falcon_nvconfig_board_v2 *v2 = &nvconfig->board_v2;
 		struct falcon_nvconfig_board_v3 *v3 = &nvconfig->board_v3;
@@ -2443,7 +2592,7 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 		efx->mii.phy_id = v2->port0_phy_addr;
 		board_rev = le16_to_cpu(v2->board_revision);
 
-		if (struct_ver >= 3) {
+		if (le16_to_cpu(nvconfig->board_struct_ver) >= 3) {
 			__le32 fl = v3->spi_device_type[EE_SPI_FLASH];
 			__le32 ee = v3->spi_device_type[EE_SPI_EEPROM];
 			rc = falcon_spi_device_init(efx, &efx->spi_flash,
@@ -2459,6 +2608,9 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 		}
 	}
 
+	/* Read the MAC addresses */
+	memcpy(efx->mac_address, nvconfig->mac_address[0], ETH_ALEN);
+
 	EFX_LOG(efx, "PHY is %d phy_id %d\n", efx->phy_type, efx->mii.phy_id);
 
 	efx_set_board_info(efx, board_rev);
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 41b388b..30d61e4 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -93,6 +93,12 @@ extern void falcon_update_nic_stats(struct efx_nic *efx);
 extern void falcon_set_multicast_hash(struct efx_nic *efx);
 extern int falcon_reset_xaui(struct efx_nic *efx);
 
+/* Tests */
+struct falcon_nvconfig;
+extern int falcon_read_nvram(struct efx_nic *efx,
+			     struct falcon_nvconfig *nvconfig);
+extern int falcon_test_registers(struct efx_nic *efx);
+
 /**************************************************************************
  *
  * Falcon MAC stats
diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
index a3260df..e319fd6 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -1150,7 +1150,9 @@ struct falcon_nvconfig_board_v3 {
 #define SPI_DEV_TYPE_FIELD(type, field)					\
 	(((type) >> EFX_LOW_BIT(field)) & EFX_MASK32(EFX_WIDTH(field)))
 
-#define NVCONFIG_BASE 0x300
+#define NVCONFIG_OFFSET 0x300
+#define NVCONFIG_END 0x400
+
 #define NVCONFIG_BOARD_MAGIC_NUM 0xFA1C
 struct falcon_nvconfig {
 	efx_oword_t ee_vpd_cfg_reg;			/* 0x300 */
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index a9ae06a..0d9f68f 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -373,17 +373,9 @@ static void falcon_reconfigure_xgxs_core(struct efx_nic *efx)
 		reset_xgxs = ((xgxs_loopback != old_xgxs_loopback) ||
 			      (xaui_loopback != old_xaui_loopback) ||
 			      (xgmii_loopback != old_xgmii_loopback));
-		if (reset_xgxs) {
-			falcon_read(efx, &reg, XX_PWR_RST_REG);
-			EFX_SET_OWORD_FIELD(reg, XX_RSTXGXSTX_EN, 1);
-			EFX_SET_OWORD_FIELD(reg, XX_RSTXGXSRX_EN, 1);
-			falcon_write(efx, &reg, XX_PWR_RST_REG);
-			udelay(1);
-			EFX_SET_OWORD_FIELD(reg, XX_RSTXGXSTX_EN, 0);
-			EFX_SET_OWORD_FIELD(reg, XX_RSTXGXSRX_EN, 0);
-			falcon_write(efx, &reg, XX_PWR_RST_REG);
-			udelay(1);
-		}
+
+		if (reset_xgxs)
+			falcon_reset_xaui(efx);
 	}
 
 	falcon_read(efx, &reg, XX_CORE_STAT_REG);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index df863bc..531d939 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -515,6 +515,7 @@ struct efx_phy_operations {
 	void (*clear_interrupt) (struct efx_nic *efx);
 	int (*check_hw) (struct efx_nic *efx);
 	void (*reset_xaui) (struct efx_nic *efx);
+	int (*test) (struct efx_nic *efx);
 	int mmds;
 	unsigned loopbacks;
 };
@@ -533,7 +534,7 @@ enum efx_phy_mode {
 
 static inline bool efx_phy_mode_disabled(enum efx_phy_mode mode)
 {
-	return (mode & ~PHY_MODE_TX_DISABLED) != 0;
+	return !!(mode & ~PHY_MODE_TX_DISABLED);
 }
 
 /*
@@ -655,13 +656,14 @@ union efx_multicast_hash {
  *	This field will be %NULL if no EEPROM device is present.
  * @n_rx_nodesc_drop_cnt: RX no descriptor drop count
  * @nic_data: Hardware dependant state
- * @mac_lock: MAC access lock. Protects @port_enabled, efx_monitor() and
- *	efx_reconfigure_port()
+ * @mac_lock: MAC access lock. Protects @port_enabled, @phy_mode,
+ *	@port_inhibited, efx_monitor() and efx_reconfigure_port()
  * @port_enabled: Port enabled indicator.
  *	Serialises efx_stop_all(), efx_start_all() and efx_monitor() and
  *	efx_reconfigure_work with kernel interfaces. Safe to read under any
  *	one of the rtnl_lock, mac_lock, or netif_tx_lock, but all three must
  *	be held to modify it.
+ * @port_inhibited: If set, the netif_carrier is always off. Hold the mac_lock
  * @port_initialized: Port initialized?
  * @net_dev: Operating system network device. Consider holding the rtnl lock
  * @rx_checksum_enabled: RX checksumming enabled
@@ -671,14 +673,16 @@ union efx_multicast_hash {
  *	can provide.  Generic code converts these into a standard
  *	&struct net_device_stats.
  * @stats_buffer: DMA buffer for statistics
- * @stats_lock: Statistics update lock
+ * @stats_lock: Statistics update lock. Serialises statistics fetches
+ * @stats_enabled: Temporarily disable statistics fetches.
+ *	Serialised by @stats_lock
  * @mac_address: Permanent MAC address
  * @phy_type: PHY type
  * @phy_lock: PHY access lock
  * @phy_op: PHY interface
  * @phy_data: PHY private data (including PHY-specific stats)
  * @mii: PHY interface
- * @phy_mode: PHY operating mode
+ * @phy_mode: PHY operating mode. Serialised by @mac_lock.
  * @link_up: Link status
  * @link_options: Link options (MII/GMII format)
  * @n_link_state_changes: Number of times the link has changed state
@@ -733,6 +737,7 @@ struct efx_nic {
 
 	struct mutex mac_lock;
 	bool port_enabled;
+	bool port_inhibited;
 
 	bool port_initialized;
 	struct net_device *net_dev;
@@ -744,6 +749,7 @@ struct efx_nic {
 	struct efx_mac_stats mac_stats;
 	struct efx_buffer stats_buffer;
 	spinlock_t stats_lock;
+	bool stats_enabled;
 
 	unsigned char mac_address[ETH_ALEN];
 
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 2f7def6..362956e 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -27,6 +27,9 @@
 #include "boards.h"
 #include "workarounds.h"
 #include "mac.h"
+#include "spi.h"
+#include "falcon_io.h"
+#include "mdio_10g.h"
 
 /*
  * Loopback test packet structure
@@ -51,7 +54,7 @@ static const char *payload_msg =
 	"Hello world! This is an Efx loopback test in progress!";
 
 /**
- * efx_selftest_state - persistent state during a selftest
+ * efx_loopback_state - persistent state during a loopback selftest
  * @flush:		Drop all packets in efx_loopback_rx_packet
  * @packet_count:	Number of packets being used in this test
  * @skbs:		An array of skbs transmitted
@@ -59,7 +62,7 @@ static const char *payload_msg =
  * @rx_bad:		RX bad packet count
  * @payload:		Payload used in tests
  */
-struct efx_selftest_state {
+struct efx_loopback_state {
 	bool flush;
 	int packet_count;
 	struct sk_buff **skbs;
@@ -74,21 +77,65 @@ struct efx_selftest_state {
 
 /**************************************************************************
  *
- * Configurable values
+ * MII, NVRAM and register tests
  *
  **************************************************************************/
 
-/* Level of loopback testing
- *
- * The maximum packet burst length is 16**(n-1), i.e.
- *
- * - Level 0 : no packets
- * - Level 1 : 1 packet
- * - Level 2 : 17 packets (1 * 1 packet, 1 * 16 packets)
- * - Level 3 : 273 packets (1 * 1 packet, 1 * 16 packet, 1 * 256 packets)
- *
- */
-static unsigned int loopback_test_level = 3;
+static int efx_test_mii(struct efx_nic *efx, struct efx_self_tests *tests)
+{
+	int rc = 0;
+	u16 physid1, physid2;
+	struct mii_if_info *mii = &efx->mii;
+	struct net_device *net_dev = efx->net_dev;
+
+	if (efx->phy_type == PHY_TYPE_NONE)
+		return 0;
+
+	mutex_lock(&efx->mac_lock);
+	tests->mii = -1;
+
+	physid1 = mii->mdio_read(net_dev, mii->phy_id, MII_PHYSID1);
+	physid2 = mii->mdio_read(net_dev, mii->phy_id, MII_PHYSID2);
+
+	if ((physid1 == 0x0000) || (physid1 == 0xffff) ||
+	    (physid2 == 0x0000) || (physid2 == 0xffff)) {
+		EFX_ERR(efx, "no MII PHY present with ID %d\n",
+			mii->phy_id);
+		rc = -EINVAL;
+		goto out;
+	}
+
+	rc = mdio_clause45_check_mmds(efx, efx->phy_op->mmds, 0);
+	if (rc)
+		goto out;
+
+out:
+	mutex_unlock(&efx->mac_lock);
+	tests->mii = rc ? -1 : 1;
+	return rc;
+}
+
+static int efx_test_nvram(struct efx_nic *efx, struct efx_self_tests *tests)
+{
+	int rc;
+
+	rc = falcon_read_nvram(efx, NULL);
+	tests->nvram = rc ? -1 : 1;
+	return rc;
+}
+
+static int efx_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
+{
+	int rc;
+
+	/* Not supported on A-series silicon */
+	if (falcon_rev(efx) < FALCON_REV_B0)
+		return 0;
+
+	rc = falcon_test_registers(efx);
+	tests->registers = rc ? -1 : 1;
+	return rc;
+}
 
 /**************************************************************************
  *
@@ -199,39 +246,18 @@ static int efx_test_eventq_irq(struct efx_channel *channel,
 	return 0;
 }
 
-/**************************************************************************
- *
- * PHY testing
- *
- **************************************************************************/
-
-/* Check PHY presence by reading the PHY ID registers */
-static int efx_test_phy(struct efx_nic *efx,
-			struct efx_self_tests *tests)
+static int efx_test_phy(struct efx_nic *efx, struct efx_self_tests *tests)
 {
-	u16 physid1, physid2;
-	struct mii_if_info *mii = &efx->mii;
-	struct net_device *net_dev = efx->net_dev;
-
-	if (efx->phy_type == PHY_TYPE_NONE)
-		return 0;
-
-	EFX_LOG(efx, "testing PHY presence\n");
-	tests->phy_ok = -1;
-
-	physid1 = mii->mdio_read(net_dev, mii->phy_id, MII_PHYSID1);
-	physid2 = mii->mdio_read(net_dev, mii->phy_id, MII_PHYSID2);
+	int rc;
 
-	if ((physid1 != 0x0000) && (physid1 != 0xffff) &&
-	    (physid2 != 0x0000) && (physid2 != 0xffff)) {
-		EFX_LOG(efx, "found MII PHY %d ID 0x%x:%x\n",
-			mii->phy_id, physid1, physid2);
-		tests->phy_ok = 1;
+	if (!efx->phy_op->test)
 		return 0;
-	}
 
-	EFX_ERR(efx, "no MII PHY present with ID %d\n", mii->phy_id);
-	return -ENODEV;
+	mutex_lock(&efx->mac_lock);
+	rc = efx->phy_op->test(efx);
+	mutex_unlock(&efx->mac_lock);
+	tests->phy = rc ? -1 : 1;
+	return rc;
 }
 
 /**************************************************************************
@@ -247,7 +273,7 @@ static int efx_test_phy(struct efx_nic *efx,
 void efx_loopback_rx_packet(struct efx_nic *efx,
 			    const char *buf_ptr, int pkt_len)
 {
-	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct efx_loopback_state *state = efx->loopback_selftest;
 	struct efx_loopback_payload *received;
 	struct efx_loopback_payload *payload;
 
@@ -258,7 +284,7 @@ void efx_loopback_rx_packet(struct efx_nic *efx,
 		return;
 
 	payload = &state->payload;
-	
+
 	received = (struct efx_loopback_payload *) buf_ptr;
 	received->ip.saddr = payload->ip.saddr;
 	if (state->offload_csum)
@@ -332,7 +358,7 @@ void efx_loopback_rx_packet(struct efx_nic *efx,
 /* Initialise an efx_selftest_state for a new iteration */
 static void efx_iterate_state(struct efx_nic *efx)
 {
-	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct efx_loopback_state *state = efx->loopback_selftest;
 	struct net_device *net_dev = efx->net_dev;
 	struct efx_loopback_payload *payload = &state->payload;
 
@@ -368,14 +394,14 @@ static void efx_iterate_state(struct efx_nic *efx)
 static int efx_begin_loopback(struct efx_tx_queue *tx_queue)
 {
 	struct efx_nic *efx = tx_queue->efx;
-	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct efx_loopback_state *state = efx->loopback_selftest;
 	struct efx_loopback_payload *payload;
 	struct sk_buff *skb;
 	int i, rc;
 
 	/* Transmit N copies of buffer */
 	for (i = 0; i < state->packet_count; i++) {
-		/* Allocate an skb, holding an extra reference for 
+		/* Allocate an skb, holding an extra reference for
 		 * transmit completion counting */
 		skb = alloc_skb(sizeof(state->payload), GFP_KERNEL);
 		if (!skb)
@@ -416,7 +442,7 @@ static int efx_begin_loopback(struct efx_tx_queue *tx_queue)
 
 static int efx_poll_loopback(struct efx_nic *efx)
 {
-	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct efx_loopback_state *state = efx->loopback_selftest;
 	struct efx_channel *channel;
 
 	/* NAPI polling is not enabled, so process channels
@@ -432,7 +458,7 @@ static int efx_end_loopback(struct efx_tx_queue *tx_queue,
 			    struct efx_loopback_self_tests *lb_tests)
 {
 	struct efx_nic *efx = tx_queue->efx;
-	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct efx_loopback_state *state = efx->loopback_selftest;
 	struct sk_buff *skb;
 	int tx_done = 0, rx_good, rx_bad;
 	int i, rc = 0;
@@ -491,10 +517,10 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 		  struct efx_loopback_self_tests *lb_tests)
 {
 	struct efx_nic *efx = tx_queue->efx;
-	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct efx_loopback_state *state = efx->loopback_selftest;
 	int i, begin_rc, end_rc;
 
-	for (i = 0; i < loopback_test_level; i++) {
+	for (i = 0; i < 3; i++) {
 		/* Determine how many packets to send */
 		state->packet_count = (efx->type->txd_ring_mask + 1) / 3;
 		state->packet_count = min(1 << (i << 2), state->packet_count);
@@ -537,42 +563,28 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 	return 0;
 }
 
-static int efx_test_loopbacks(struct efx_nic *efx,
+static int efx_test_loopbacks(struct efx_nic *efx, struct ethtool_cmd ecmd,
 			      struct efx_self_tests *tests,
 			      unsigned int loopback_modes)
 {
-	struct efx_selftest_state *state = efx->loopback_selftest;
-	struct ethtool_cmd ecmd, ecmd_loopback;
+	enum efx_loopback_mode mode;
+	struct efx_loopback_state *state;
 	struct efx_tx_queue *tx_queue;
-	enum efx_loopback_mode old_mode, mode;
 	bool link_up;
-	int count, rc;
-
-	rc = efx_ethtool_get_settings(efx->net_dev, &ecmd);
-	if (rc) {
-		EFX_ERR(efx, "could not get GMII settings\n");
-		return rc;
-	}
-	old_mode = efx->loopback_mode;
-
-	/* Disable autonegotiation for the purposes of loopback */
-	memcpy(&ecmd_loopback, &ecmd, sizeof(ecmd_loopback));
-	if (ecmd_loopback.autoneg == AUTONEG_ENABLE) {
-		ecmd_loopback.autoneg = AUTONEG_DISABLE;
-		ecmd_loopback.duplex = DUPLEX_FULL;
-		ecmd_loopback.speed = SPEED_10000;
-	}
+	int count, rc = 0;
 
-	rc = efx_ethtool_set_settings(efx->net_dev, &ecmd_loopback);
-	if (rc) {
-		EFX_ERR(efx, "could not disable autonegotiation\n");
-		goto out;
-	}
-	tests->loopback_speed = ecmd_loopback.speed;
-	tests->loopback_full_duplex = ecmd_loopback.duplex;
+	/* Set the port loopback_selftest member. From this point on
+	 * all received packets will be dropped. Mark the state as
+	 * "flushing" so all inflight packets are dropped */
+	state = kzalloc(sizeof(*state), GFP_KERNEL);
+	if (state == NULL)
+		return -ENOMEM;
+	BUG_ON(efx->loopback_selftest);
+	state->flush = true;
+	efx->loopback_selftest = state;
 
 	/* Test all supported loopback modes */
-	for (mode = LOOPBACK_NONE; mode < LOOPBACK_TEST_MAX; mode++) {
+	for (mode = LOOPBACK_NONE; mode <= LOOPBACK_TEST_MAX; mode++) {
 		if (!(loopback_modes & (1 << mode)))
 			continue;
 
@@ -601,7 +613,7 @@ static int efx_test_loopbacks(struct efx_nic *efx,
 			 */
 			link_up = efx->link_up;
 			if (!falcon_xaui_link_ok(efx))
-				link_up = 0;
+				link_up = false;
 
 		} while ((++count < 20) && !link_up);
 
@@ -629,10 +641,11 @@ static int efx_test_loopbacks(struct efx_nic *efx,
 	}
 
  out:
-	/* Take out of loopback and restore PHY settings */
+	/* Remove the flush. The caller will remove the loopback setting */
 	state->flush = true;
-	efx->loopback_mode = old_mode;
-	efx_ethtool_set_settings(efx->net_dev, &ecmd);
+	efx->loopback_selftest = NULL;
+	wmb();
+	kfree(state);
 
 	return rc;
 }
@@ -648,18 +661,27 @@ static int efx_test_loopbacks(struct efx_nic *efx,
 int efx_online_test(struct efx_nic *efx, struct efx_self_tests *tests)
 {
 	struct efx_channel *channel;
-	int rc;
+	int rc, rc2 = 0;
+
+	rc = efx_test_mii(efx, tests);
+	if (rc && !rc2)
+		rc2 = rc;
+
+	rc = efx_test_nvram(efx, tests);
+	if (rc && !rc2)
+		rc2 = rc;
 
 	rc = efx_test_interrupts(efx, tests);
-	if (rc)
-		return rc;
+	if (rc && !rc2)
+		rc2 = rc;
+
 	efx_for_each_channel(channel, efx) {
 		rc = efx_test_eventq_irq(channel, tests);
-		if (rc)
-			return rc;
+		if (rc && !rc2)
+			rc2 = rc;
 	}
-	rc = efx_test_phy(efx, tests);
-	return rc;
+
+	return rc2;
 }
 
 /* Offline (i.e. disruptive) testing
@@ -667,27 +689,66 @@ int efx_online_test(struct efx_nic *efx, struct efx_self_tests *tests)
 int efx_offline_test(struct efx_nic *efx,
 		     struct efx_self_tests *tests, unsigned int loopback_modes)
 {
-	struct efx_selftest_state *state;
-	int rc;
+	enum efx_loopback_mode loopback_mode = efx->loopback_mode;
+	int phy_mode = efx->phy_mode;
+	struct ethtool_cmd ecmd, ecmd_test;
+	int rc, rc2 = 0;
+
+	/* force the carrier state off so the kernel doesn't transmit during
+	 * the loopback test, and the watchdog timeout doesn't fire. Also put
+	 * falcon into loopback for the register test.
+	 */
+	mutex_lock(&efx->mac_lock);
+	efx->port_inhibited = true;
+	if (efx->loopback_modes)
+		efx->loopback_mode = __ffs(efx->loopback_modes);
+	__efx_reconfigure_port(efx);
+	mutex_unlock(&efx->mac_lock);
+
+	/* free up all consumers of SRAM (including all the queues) */
+	efx_reset_down(efx, &ecmd);
+
+	rc = efx_test_chip(efx, tests);
+	if (rc && !rc2)
+		rc2 = rc;
+
+	/* reset the chip to recover from the register test */
+	rc = falcon_reset_hw(efx, RESET_TYPE_ALL);
+
+	/* Modify the saved ecmd so that when efx_reset_up() restores the phy
+	 * state, AN is disabled, and the phy is powered, and out of loopback */
+	memcpy(&ecmd_test, &ecmd, sizeof(ecmd_test));
+	if (ecmd_test.autoneg == AUTONEG_ENABLE) {
+		ecmd_test.autoneg = AUTONEG_DISABLE;
+		ecmd_test.duplex = DUPLEX_FULL;
+		ecmd_test.speed = SPEED_10000;
+	}
+	efx->loopback_mode = LOOPBACK_NONE;
 
-	/* Create a selftest_state structure to hold state for the test */
-	state = kzalloc(sizeof(*state), GFP_KERNEL);
-	if (state == NULL)
-		return -ENOMEM;
+	rc = efx_reset_up(efx, &ecmd_test, rc == 0);
+	if (rc) {
+		EFX_ERR(efx, "Unable to recover from chip test\n");
+		efx_schedule_reset(efx, RESET_TYPE_DISABLE);
+		return rc;
+	}
 
-	/* Set the port loopback_selftest member. From this point on
-	 * all received packets will be dropped. Mark the state as
-	 * "flushing" so all inflight packets are dropped */
-	BUG_ON(efx->loopback_selftest);
-	state->flush = true;
-	efx->loopback_selftest = state;
+	tests->loopback_speed = ecmd_test.speed;
+	tests->loopback_full_duplex = ecmd_test.duplex;
 
-	rc = efx_test_loopbacks(efx, tests, loopback_modes);
+	rc = efx_test_phy(efx, tests);
+	if (rc && !rc2)
+		rc2 = rc;
 
-	efx->loopback_selftest = NULL;
-	wmb();
-	kfree(state);
+	rc = efx_test_loopbacks(efx, ecmd_test, tests, loopback_modes);
+	if (rc && !rc2)
+		rc2 = rc;
 
-	return rc;
+	/* restore the PHY to the previous state */
+	efx->loopback_mode = loopback_mode;
+	efx->phy_mode = phy_mode;
+	efx->port_inhibited = false;
+	efx_ethtool_set_settings(efx->net_dev, &ecmd);
+
+	return rc2;
 }
 
diff --git a/drivers/net/sfc/selftest.h b/drivers/net/sfc/selftest.h
index cd59f00..fc15df1 100644
--- a/drivers/net/sfc/selftest.h
+++ b/drivers/net/sfc/selftest.h
@@ -29,14 +29,19 @@ struct efx_loopback_self_tests {
  * indicates failure.
  */
 struct efx_self_tests {
+	/* online tests */
+	int mii;
+	int nvram;
 	int interrupt;
 	int eventq_dma[EFX_MAX_CHANNELS];
 	int eventq_int[EFX_MAX_CHANNELS];
 	int eventq_poll[EFX_MAX_CHANNELS];
-	int phy_ok;
+	/* offline tests */
+	int registers;
+	int phy;
 	int loopback_speed;
 	int loopback_full_duplex;
-	struct efx_loopback_self_tests loopback[LOOPBACK_TEST_MAX];
+	struct efx_loopback_self_tests loopback[LOOPBACK_TEST_MAX + 1];
 };
 
 extern void efx_loopback_rx_packet(struct efx_nic *efx,
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 499e127..8412dbe 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -65,25 +65,10 @@
 #define PMA_PMD_LED_DEFAULT	(PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN)
 
 
-/* Self test (BIST) control register */
-#define PMA_PMD_BIST_CTRL_REG	(0xc014)
-#define PMA_PMD_BIST_BER_LBN	(2)	/* Run BER test */
-#define PMA_PMD_BIST_CONT_LBN	(1)	/* Run continuous BIST until cleared */
-#define PMA_PMD_BIST_SINGLE_LBN	(0)	/* Run 1 BIST iteration (self clears) */
-/* Self test status register */
-#define PMA_PMD_BIST_STAT_REG	(0xc015)
-#define PMA_PMD_BIST_ENX_LBN	(3)
-#define PMA_PMD_BIST_PMA_LBN	(2)
-#define PMA_PMD_BIST_RXD_LBN	(1)
-#define PMA_PMD_BIST_AFE_LBN	(0)
-
 /* Special Software reset register */
 #define PMA_PMD_EXT_CTRL_REG 49152
 #define PMA_PMD_EXT_SSR_LBN 15
 
-#define BIST_MAX_DELAY	(1000)
-#define BIST_POLL_DELAY	(10)
-
 /* Misc register defines */
 #define PCS_CLOCK_CTRL_REG 0xd801
 #define PLL312_RST_N_LBN 2
@@ -491,6 +476,12 @@ static void tenxpress_reset_xaui(struct efx_nic *efx)
 	udelay(10);
 }
 
+static int tenxpress_phy_test(struct efx_nic *efx)
+{
+	/* BIST is automatically run after a special software reset */
+	return tenxpress_special_reset(efx);
+}
+
 struct efx_phy_operations falcon_tenxpress_phy_ops = {
 	.init             = tenxpress_phy_init,
 	.reconfigure      = tenxpress_phy_reconfigure,
@@ -498,6 +489,7 @@ struct efx_phy_operations falcon_tenxpress_phy_ops = {
 	.fini             = tenxpress_phy_fini,
 	.clear_interrupt  = tenxpress_phy_clear_interrupt,
 	.reset_xaui       = tenxpress_reset_xaui,
+	.test             = tenxpress_phy_test,
 	.mmds             = TENXPRESS_REQUIRED_DEVS,
 	.loopbacks        = TENXPRESS_LOOPBACKS,
 };
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

