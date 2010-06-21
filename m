From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6] sfc: Implement ethtool register dump operation
Date: Mon, 21 Jun 2010 14:06:53 +0100
Message-ID: <1277125613.2100.9.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:23121 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757841Ab0FUNG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 09:06:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c |   16 +++
 drivers/net/sfc/io.h      |    7 +
 drivers/net/sfc/nic.c     |  266 +++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/nic.h     |    3 +
 4 files changed, 292 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 22026bf..81b7f39 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -242,6 +242,20 @@ static void efx_ethtool_get_drvinfo(struct net_device *net_dev,
 	strlcpy(info->bus_info, pci_name(efx->pci_dev), sizeof(info->bus_info));
 }
 
+static int efx_ethtool_get_regs_len(struct net_device *net_dev)
+{
+	return efx_nic_get_regs_len(netdev_priv(net_dev));
+}
+
+static void efx_ethtool_get_regs(struct net_device *net_dev,
+				 struct ethtool_regs *regs, void *buf)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+
+	regs->version = efx->type->revision;
+	efx_nic_get_regs(efx, buf);
+}
+
 /**
  * efx_fill_test - fill in an individual self-test entry
  * @test_index:		Index of the test
@@ -834,6 +848,8 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.get_settings		= efx_ethtool_get_settings,
 	.set_settings		= efx_ethtool_set_settings,
 	.get_drvinfo		= efx_ethtool_get_drvinfo,
+	.get_regs_len		= efx_ethtool_get_regs_len,
+	.get_regs		= efx_ethtool_get_regs,
 	.nway_reset		= efx_ethtool_nway_reset,
 	.get_link		= efx_ethtool_get_link,
 	.get_eeprom_len		= efx_ethtool_get_eeprom_len,
diff --git a/drivers/net/sfc/io.h b/drivers/net/sfc/io.h
index b89177c..4317574 100644
--- a/drivers/net/sfc/io.h
+++ b/drivers/net/sfc/io.h
@@ -211,6 +211,13 @@ static inline void efx_writed_table(struct efx_nic *efx, efx_dword_t *value,
 	efx_writed(efx, value, reg + index * sizeof(efx_oword_t));
 }
 
+/* Read from a dword register forming part of a table */
+static inline void efx_readd_table(struct efx_nic *efx, efx_dword_t *value,
+				   unsigned int reg, unsigned int index)
+{
+	efx_readd(efx, value, reg + index * sizeof(efx_dword_t));
+}
+
 /* Page-mapped register block size */
 #define EFX_PAGE_BLOCK_SIZE 0x2000
 
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 0ee6fd3..67235f1 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -1627,3 +1627,269 @@ void efx_nic_init_common(struct efx_nic *efx)
 		EFX_SET_OWORD_FIELD(temp, FRF_BZ_TX_FLUSH_MIN_LEN_EN, 1);
 	efx_writeo(efx, &temp, FR_AZ_TX_RESERVED);
 }
+
+/* Register dump */
+
+#define REGISTER_REVISION_A	1
+#define REGISTER_REVISION_B	2
+#define REGISTER_REVISION_C	3
+#define REGISTER_REVISION_Z	3	/* latest revision */
+
+struct efx_nic_reg {
+	u32 offset:24;
+	u32 min_revision:2, max_revision:2;
+};
+
+#define REGISTER(name, min_rev, max_rev) {				\
+	FR_ ## min_rev ## max_rev ## _ ## name,				\
+	REGISTER_REVISION_ ## min_rev, REGISTER_REVISION_ ## max_rev	\
+}
+#define REGISTER_AA(name) REGISTER(name, A, A)
+#define REGISTER_AB(name) REGISTER(name, A, B)
+#define REGISTER_AZ(name) REGISTER(name, A, Z)
+#define REGISTER_BB(name) REGISTER(name, B, B)
+#define REGISTER_BZ(name) REGISTER(name, B, Z)
+#define REGISTER_CZ(name) REGISTER(name, C, Z)
+
+static const struct efx_nic_reg efx_nic_regs[] = {
+	REGISTER_AZ(ADR_REGION),
+	REGISTER_AZ(INT_EN_KER),
+	REGISTER_BZ(INT_EN_CHAR),
+	REGISTER_AZ(INT_ADR_KER),
+	REGISTER_BZ(INT_ADR_CHAR),
+	/* INT_ACK_KER is WO */
+	/* INT_ISR0 is RC */
+	REGISTER_AZ(HW_INIT),
+	REGISTER_CZ(USR_EV_CFG),
+	REGISTER_AB(EE_SPI_HCMD),
+	REGISTER_AB(EE_SPI_HADR),
+	REGISTER_AB(EE_SPI_HDATA),
+	REGISTER_AB(EE_BASE_PAGE),
+	REGISTER_AB(EE_VPD_CFG0),
+	/* EE_VPD_SW_CNTL and EE_VPD_SW_DATA are not used */
+	/* PMBX_DBG_IADDR and PBMX_DBG_IDATA are indirect */
+	/* PCIE_CORE_INDIRECT is indirect */
+	REGISTER_AB(NIC_STAT),
+	REGISTER_AB(GPIO_CTL),
+	REGISTER_AB(GLB_CTL),
+	/* FATAL_INTR_KER and FATAL_INTR_CHAR are partly RC */
+	REGISTER_BZ(DP_CTRL),
+	REGISTER_AZ(MEM_STAT),
+	REGISTER_AZ(CS_DEBUG),
+	REGISTER_AZ(ALTERA_BUILD),
+	REGISTER_AZ(CSR_SPARE),
+	REGISTER_AB(PCIE_SD_CTL0123),
+	REGISTER_AB(PCIE_SD_CTL45),
+	REGISTER_AB(PCIE_PCS_CTL_STAT),
+	/* DEBUG_DATA_OUT is not used */
+	/* DRV_EV is WO */
+	REGISTER_AZ(EVQ_CTL),
+	REGISTER_AZ(EVQ_CNT1),
+	REGISTER_AZ(EVQ_CNT2),
+	REGISTER_AZ(BUF_TBL_CFG),
+	REGISTER_AZ(SRM_RX_DC_CFG),
+	REGISTER_AZ(SRM_TX_DC_CFG),
+	REGISTER_AZ(SRM_CFG),
+	/* BUF_TBL_UPD is WO */
+	REGISTER_AZ(SRM_UPD_EVQ),
+	REGISTER_AZ(SRAM_PARITY),
+	REGISTER_AZ(RX_CFG),
+	REGISTER_BZ(RX_FILTER_CTL),
+	/* RX_FLUSH_DESCQ is WO */
+	REGISTER_AZ(RX_DC_CFG),
+	REGISTER_AZ(RX_DC_PF_WM),
+	REGISTER_BZ(RX_RSS_TKEY),
+	/* RX_NODESC_DROP is RC */
+	REGISTER_AA(RX_SELF_RST),
+	/* RX_DEBUG, RX_PUSH_DROP are not used */
+	REGISTER_CZ(RX_RSS_IPV6_REG1),
+	REGISTER_CZ(RX_RSS_IPV6_REG2),
+	REGISTER_CZ(RX_RSS_IPV6_REG3),
+	/* TX_FLUSH_DESCQ is WO */
+	REGISTER_AZ(TX_DC_CFG),
+	REGISTER_AA(TX_CHKSM_CFG),
+	REGISTER_AZ(TX_CFG),
+	/* TX_PUSH_DROP is not used */
+	REGISTER_AZ(TX_RESERVED),
+	REGISTER_BZ(TX_PACE),
+	/* TX_PACE_DROP_QID is RC */
+	REGISTER_BB(TX_VLAN),
+	REGISTER_BZ(TX_IPFIL_PORTEN),
+	REGISTER_AB(MD_TXD),
+	REGISTER_AB(MD_RXD),
+	REGISTER_AB(MD_CS),
+	REGISTER_AB(MD_PHY_ADR),
+	REGISTER_AB(MD_ID),
+	/* MD_STAT is RC */
+	REGISTER_AB(MAC_STAT_DMA),
+	REGISTER_AB(MAC_CTRL),
+	REGISTER_BB(GEN_MODE),
+	REGISTER_AB(MAC_MC_HASH_REG0),
+	REGISTER_AB(MAC_MC_HASH_REG1),
+	REGISTER_AB(GM_CFG1),
+	REGISTER_AB(GM_CFG2),
+	/* GM_IPG and GM_HD are not used */
+	REGISTER_AB(GM_MAX_FLEN),
+	/* GM_TEST is not used */
+	REGISTER_AB(GM_ADR1),
+	REGISTER_AB(GM_ADR2),
+	REGISTER_AB(GMF_CFG0),
+	REGISTER_AB(GMF_CFG1),
+	REGISTER_AB(GMF_CFG2),
+	REGISTER_AB(GMF_CFG3),
+	REGISTER_AB(GMF_CFG4),
+	REGISTER_AB(GMF_CFG5),
+	REGISTER_BB(TX_SRC_MAC_CTL),
+	REGISTER_AB(XM_ADR_LO),
+	REGISTER_AB(XM_ADR_HI),
+	REGISTER_AB(XM_GLB_CFG),
+	REGISTER_AB(XM_TX_CFG),
+	REGISTER_AB(XM_RX_CFG),
+	REGISTER_AB(XM_MGT_INT_MASK),
+	REGISTER_AB(XM_FC),
+	REGISTER_AB(XM_PAUSE_TIME),
+	REGISTER_AB(XM_TX_PARAM),
+	REGISTER_AB(XM_RX_PARAM),
+	/* XM_MGT_INT_MSK (note no 'A') is RC */
+	REGISTER_AB(XX_PWR_RST),
+	REGISTER_AB(XX_SD_CTL),
+	REGISTER_AB(XX_TXDRV_CTL),
+	/* XX_PRBS_CTL, XX_PRBS_CHK and XX_PRBS_ERR are not used */
+	/* XX_CORE_STAT is partly RC */
+};
+
+struct efx_nic_reg_table {
+	u32 offset:24;
+	u32 min_revision:2, max_revision:2;
+	u32 step:6, rows:21;
+};
+
+#define REGISTER_TABLE_DIMENSIONS(_, offset, min_rev, max_rev, step, rows) { \
+	offset,								\
+	REGISTER_REVISION_ ## min_rev, REGISTER_REVISION_ ## max_rev,	\
+	step, rows							\
+}
+#define REGISTER_TABLE(name, min_rev, max_rev) 				\
+	REGISTER_TABLE_DIMENSIONS(					\
+		name, FR_ ## min_rev ## max_rev ## _ ## name,		\
+		min_rev, max_rev,					\
+		FR_ ## min_rev ## max_rev ## _ ## name ## _STEP,	\
+		FR_ ## min_rev ## max_rev ## _ ## name ## _ROWS)
+#define REGISTER_TABLE_AA(name) REGISTER_TABLE(name, A, A)
+#define REGISTER_TABLE_AZ(name) REGISTER_TABLE(name, A, Z)
+#define REGISTER_TABLE_BB(name) REGISTER_TABLE(name, B, B)
+#define REGISTER_TABLE_BZ(name) REGISTER_TABLE(name, B, Z)
+#define REGISTER_TABLE_BB_CZ(name)					\
+	REGISTER_TABLE_DIMENSIONS(name, FR_BZ_ ## name, B, B,		\
+				  FR_BZ_ ## name ## _STEP,		\
+				  FR_BB_ ## name ## _ROWS),		\
+	REGISTER_TABLE_DIMENSIONS(name, FR_BZ_ ## name, C, Z,		\
+				  FR_BZ_ ## name ## _STEP,		\
+				  FR_CZ_ ## name ## _ROWS)
+#define REGISTER_TABLE_CZ(name) REGISTER_TABLE(name, C, Z)
+
+static const struct efx_nic_reg_table efx_nic_reg_tables[] = {
+	/* DRIVER is not used */
+	/* EVQ_RPTR, TIMER_COMMAND, USR_EV and {RX,TX}_DESC_UPD are WO */
+	REGISTER_TABLE_BB(TX_IPFIL_TBL),
+	REGISTER_TABLE_BB(TX_SRC_MAC_TBL),
+	REGISTER_TABLE_AA(RX_DESC_PTR_TBL_KER),
+	REGISTER_TABLE_BB_CZ(RX_DESC_PTR_TBL),
+	REGISTER_TABLE_AA(TX_DESC_PTR_TBL_KER),
+	REGISTER_TABLE_BB_CZ(TX_DESC_PTR_TBL),
+	REGISTER_TABLE_AA(EVQ_PTR_TBL_KER),
+	REGISTER_TABLE_BB_CZ(EVQ_PTR_TBL),
+	/* The register buffer is allocated with slab, so we can't
+	 * reasonably read all of the buffer table (up to 8MB!).
+	 * However this driver will only use a few entries.  Reading
+	 * 1K entries allows for some expansion of queue count and
+	 * size before we need to change the version. */
+	REGISTER_TABLE_DIMENSIONS(BUF_FULL_TBL_KER, FR_AA_BUF_FULL_TBL_KER,
+				  A, A, 8, 1024),
+	REGISTER_TABLE_DIMENSIONS(BUF_FULL_TBL, FR_BZ_BUF_FULL_TBL,
+				  B, Z, 8, 1024),
+	/* RX_FILTER_TBL{0,1} is huge and not used by this driver */
+	REGISTER_TABLE_CZ(RX_MAC_FILTER_TBL0),
+	REGISTER_TABLE_BB_CZ(TIMER_TBL),
+	REGISTER_TABLE_BB_CZ(TX_PACE_TBL),
+	REGISTER_TABLE_BZ(RX_INDIRECTION_TBL),
+	/* TX_FILTER_TBL0 is huge and not used by this driver */
+	REGISTER_TABLE_CZ(TX_MAC_FILTER_TBL0),
+	REGISTER_TABLE_CZ(MC_TREG_SMEM),
+	/* MSIX_PBA_TABLE is not mapped */
+	/* SRM_DBG is not mapped (and is redundant with BUF_FLL_TBL) */
+};
+
+size_t efx_nic_get_regs_len(struct efx_nic *efx)
+{
+	const struct efx_nic_reg *reg;
+	const struct efx_nic_reg_table *table;
+	size_t len = 0;
+
+	for (reg = efx_nic_regs;
+	     reg < efx_nic_regs + ARRAY_SIZE(efx_nic_regs);
+	     reg++)
+		if (efx->type->revision >= reg->min_revision &&
+		    efx->type->revision <= reg->max_revision)
+			len += sizeof(efx_oword_t);
+
+	for (table = efx_nic_reg_tables;
+	     table < efx_nic_reg_tables + ARRAY_SIZE(efx_nic_reg_tables);
+	     table++)
+		if (efx->type->revision >= table->min_revision &&
+		    efx->type->revision <= table->max_revision)
+			len += table->rows * min_t(size_t, table->step, 16);
+
+	return len;
+}
+
+void efx_nic_get_regs(struct efx_nic *efx, void *buf)
+{
+	const struct efx_nic_reg *reg;
+	const struct efx_nic_reg_table *table;
+
+	for (reg = efx_nic_regs;
+	     reg < efx_nic_regs + ARRAY_SIZE(efx_nic_regs);
+	     reg++) {
+		if (efx->type->revision >= reg->min_revision &&
+		    efx->type->revision <= reg->max_revision) {
+			efx_reado(efx, (efx_oword_t *)buf, reg->offset);
+			buf += sizeof(efx_oword_t);
+		}
+	}
+
+	for (table = efx_nic_reg_tables;
+	     table < efx_nic_reg_tables + ARRAY_SIZE(efx_nic_reg_tables);
+	     table++) {
+		size_t size, i;
+
+		if (!(efx->type->revision >= table->min_revision &&
+		      efx->type->revision <= table->max_revision))
+			continue;
+
+		size = min_t(size_t, table->step, 16);
+
+		for (i = 0; i < table->rows; i++) {
+			switch (table->step) {
+			case 4: /* 32-bit register or SRAM */
+				efx_readd_table(efx, buf, table->offset, i);
+				break;
+			case 8: /* 64-bit SRAM */
+				efx_sram_readq(efx,
+					       efx->membase + table->offset,
+					       buf, i);
+				break;
+			case 16: /* 128-bit register */
+				efx_reado_table(efx, buf, table->offset, i);
+				break;
+			case 32: /* 128-bit register, interleaved */
+				efx_reado_table(efx, buf, table->offset, 2 * i);
+				break;
+			default:
+				WARN_ON(1);
+				return;
+			}
+			buf += size;
+		}
+	}
+}
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index 95770e1..534461f 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -222,6 +222,9 @@ extern int efx_nic_test_registers(struct efx_nic *efx,
 				  const struct efx_nic_register_test *regs,
 				  size_t n_regs);
 
+extern size_t efx_nic_get_regs_len(struct efx_nic *efx);
+extern void efx_nic_get_regs(struct efx_nic *efx, void *buf);
+
 /**************************************************************************
  *
  * Falcon MAC stats
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

