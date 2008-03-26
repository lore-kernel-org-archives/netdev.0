From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 7/8] New driver "sfc" for Solarstorm SFC4000 controller (try #9)
Date: Wed, 26 Mar 2008 12:15:29 +0000
Message-ID: <20080326121528.GL24160@solarflare.com>
References: <20080326121210.GE24160@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net-drivers@solarflare.com, Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:59150 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754216AbYCZMPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 08:15:55 -0400
Content-Disposition: inline
In-Reply-To: <20080326121210.GE24160@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
new file mode 100644
index 0000000..2abc8e4
--- /dev/null
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -0,0 +1,530 @@
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
+#include <linux/delay.h>
+#include "net_driver.h"
+#include "efx.h"
+#include "falcon.h"
+#include "falcon_hwdefs.h"
+#include "falcon_io.h"
+#include "mac.h"
+#include "gmii.h"
+#include "mdio_10g.h"
+#include "phy.h"
+#include "boards.h"
+#include "workarounds.h"
+
+/**************************************************************************
+ *
+ * MAC register access
+ *
+ **************************************************************************/
+
+/* Offset of an XMAC register within Falcon */
+#define FALCON_XMAC_REG(mac_reg)					\
+	(FALCON_XMAC_REGBANK + ((mac_reg) * FALCON_XMAC_REG_SIZE))
+
+void falcon_xmac_writel(struct efx_nic *efx,
+			efx_dword_t *value, unsigned int mac_reg)
+{
+	efx_oword_t temp;
+
+	EFX_POPULATE_OWORD_1(temp, MAC_DATA, EFX_DWORD_FIELD(*value, MAC_DATA));
+	falcon_write(efx, &temp, FALCON_XMAC_REG(mac_reg));
+}
+
+void falcon_xmac_readl(struct efx_nic *efx,
+		       efx_dword_t *value, unsigned int mac_reg)
+{
+	efx_oword_t temp;
+
+	falcon_read(efx, &temp, FALCON_XMAC_REG(mac_reg));
+	EFX_POPULATE_DWORD_1(*value, MAC_DATA, EFX_OWORD_FIELD(temp, MAC_DATA));
+}
+
+/**************************************************************************
+ *
+ * MAC operations
+ *
+ *************************************************************************/
+static int falcon_reset_xmac(struct efx_nic *efx)
+{
+	efx_dword_t reg;
+	int count;
+
+	EFX_POPULATE_DWORD_1(reg, XM_CORE_RST, 1);
+	falcon_xmac_writel(efx, &reg, XM_GLB_CFG_REG_MAC);
+
+	for (count = 0; count < 10000; count++) {	/* wait upto 100ms */
+		falcon_xmac_readl(efx, &reg, XM_GLB_CFG_REG_MAC);
+		if (EFX_DWORD_FIELD(reg, XM_CORE_RST) == 0)
+			return 0;
+		udelay(10);
+	}
+
+	EFX_ERR(efx, "timed out waiting for XMAC core reset\n");
+	return -ETIMEDOUT;
+}
+
+/* Configure the XAUI driver that is an output from Falcon */
+static void falcon_setup_xaui(struct efx_nic *efx)
+{
+	efx_dword_t sdctl, txdrv;
+
+	/* Move the XAUI into low power, unless there is no PHY, in
+	 * which case the XAUI will have to drive a cable. */
+	if (efx->phy_type == PHY_TYPE_NONE)
+		return;
+
+	falcon_xmac_readl(efx, &sdctl, XX_SD_CTL_REG_MAC);
+	EFX_SET_DWORD_FIELD(sdctl, XX_HIDRVD, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_DWORD_FIELD(sdctl, XX_LODRVD, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_DWORD_FIELD(sdctl, XX_HIDRVC, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_DWORD_FIELD(sdctl, XX_LODRVC, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_DWORD_FIELD(sdctl, XX_HIDRVB, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_DWORD_FIELD(sdctl, XX_LODRVB, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_DWORD_FIELD(sdctl, XX_HIDRVA, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_DWORD_FIELD(sdctl, XX_LODRVA, XX_SD_CTL_DRV_DEFAULT);
+	falcon_xmac_writel(efx, &sdctl, XX_SD_CTL_REG_MAC);
+
+	EFX_POPULATE_DWORD_8(txdrv,
+			     XX_DEQD, XX_TXDRV_DEQ_DEFAULT,
+			     XX_DEQC, XX_TXDRV_DEQ_DEFAULT,
+			     XX_DEQB, XX_TXDRV_DEQ_DEFAULT,
+			     XX_DEQA, XX_TXDRV_DEQ_DEFAULT,
+			     XX_DTXD, XX_TXDRV_DTX_DEFAULT,
+			     XX_DTXC, XX_TXDRV_DTX_DEFAULT,
+			     XX_DTXB, XX_TXDRV_DTX_DEFAULT,
+			     XX_DTXA, XX_TXDRV_DTX_DEFAULT);
+	falcon_xmac_writel(efx, &txdrv, XX_TXDRV_CTL_REG_MAC);
+}
+
+static void falcon_hold_xaui_in_rst(struct efx_nic *efx)
+{
+	efx_dword_t reg;
+
+	EFX_ZERO_DWORD(reg);
+	EFX_SET_DWORD_FIELD(reg, XX_PWRDNA_EN, 1);
+	EFX_SET_DWORD_FIELD(reg, XX_PWRDNB_EN, 1);
+	EFX_SET_DWORD_FIELD(reg, XX_PWRDNC_EN, 1);
+	EFX_SET_DWORD_FIELD(reg, XX_PWRDND_EN, 1);
+	EFX_SET_DWORD_FIELD(reg, XX_RSTPLLAB_EN, 1);
+	EFX_SET_DWORD_FIELD(reg, XX_RSTPLLCD_EN, 1);
+	EFX_SET_DWORD_FIELD(reg, XX_RESETA_EN, 1);
+	EFX_SET_DWORD_FIELD(reg, XX_RESETB_EN, 1);
+	EFX_SET_DWORD_FIELD(reg, XX_RESETC_EN, 1);
+	EFX_SET_DWORD_FIELD(reg, XX_RESETD_EN, 1);
+	EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSRX_EN, 1);
+	EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSTX_EN, 1);
+	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	udelay(10);
+}
+
+static int _falcon_reset_xaui_a(struct efx_nic *efx)
+{
+	efx_dword_t reg;
+
+	falcon_hold_xaui_in_rst(efx);
+	falcon_xmac_readl(efx, &reg, XX_PWR_RST_REG_MAC);
+
+	/* Follow the RAMBUS XAUI data reset sequencing
+	 * Channels A and B first: power down, reset PLL, reset, clear
+	 */
+	EFX_SET_DWORD_FIELD(reg, XX_PWRDNA_EN, 0);
+	EFX_SET_DWORD_FIELD(reg, XX_PWRDNB_EN, 0);
+	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	udelay(10);
+
+	EFX_SET_DWORD_FIELD(reg, XX_RSTPLLAB_EN, 0);
+	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	udelay(10);
+
+	EFX_SET_DWORD_FIELD(reg, XX_RESETA_EN, 0);
+	EFX_SET_DWORD_FIELD(reg, XX_RESETB_EN, 0);
+	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	udelay(10);
+
+	/* Channels C and D: power down, reset PLL, reset, clear */
+	EFX_SET_DWORD_FIELD(reg, XX_PWRDNC_EN, 0);
+	EFX_SET_DWORD_FIELD(reg, XX_PWRDND_EN, 0);
+	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	udelay(10);
+
+	EFX_SET_DWORD_FIELD(reg, XX_RSTPLLCD_EN, 0);
+	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	udelay(10);
+
+	EFX_SET_DWORD_FIELD(reg, XX_RESETC_EN, 0);
+	EFX_SET_DWORD_FIELD(reg, XX_RESETD_EN, 0);
+	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	udelay(10);
+
+	/* Setup XAUI */
+	falcon_setup_xaui(efx);
+	udelay(10);
+
+	/* Take XGXS out of reset */
+	EFX_ZERO_DWORD(reg);
+	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	udelay(10);
+
+	return 0;
+}
+
+static int _falcon_reset_xaui_b(struct efx_nic *efx)
+{
+	efx_dword_t reg;
+	int count;
+
+	EFX_POPULATE_DWORD_1(reg, XX_RST_XX_EN, 1);
+	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+
+	/* Give some time for the link to establish */
+	for (count = 0; count < 1000; count++) { /* wait upto 10ms */
+		falcon_xmac_readl(efx, &reg, XX_PWR_RST_REG_MAC);
+		if (EFX_DWORD_FIELD(reg, XX_RST_XX_EN) == 0) {
+			falcon_setup_xaui(efx);
+			return 0;
+		}
+		udelay(10);
+	}
+	EFX_ERR(efx, "timed out waiting for XAUI/XGXS reset\n");
+	return -ETIMEDOUT;
+}
+
+int falcon_reset_xaui(struct efx_nic *efx)
+{
+	int rc;
+
+	if (EFX_WORKAROUND_9388(efx)) {
+		falcon_hold_xaui_in_rst(efx);
+		efx->phy_op->reset_xaui(efx);
+		rc = _falcon_reset_xaui_a(efx);
+	} else {
+		rc = _falcon_reset_xaui_b(efx);
+	}
+	return rc;
+}
+
+int falcon_init_xmac(struct efx_nic *efx)
+{
+	int rc;
+
+	/* Initialize the PHY first so the clock is around */
+	rc = efx->phy_op->init(efx);
+	if (rc)
+		goto fail1;
+
+	rc = falcon_reset_xaui(efx);
+	if (rc)
+		goto fail2;
+
+	/* Wait again. Give the PHY and MAC time to come back */
+	schedule_timeout_uninterruptible(HZ / 10);
+
+	rc = falcon_reset_xmac(efx);
+	if (rc)
+		goto fail2;
+
+	return 0;
+
+ fail2:
+	efx->phy_op->fini(efx);
+ fail1:
+	return rc;
+}
+
+int falcon_xaui_link_ok(struct efx_nic *efx)
+{
+	efx_dword_t reg;
+	int align_done;
+	int sync_status;
+	int link_ok = 0;
+
+	/* Read link status */
+	falcon_xmac_readl(efx, &reg, XX_CORE_STAT_REG_MAC);
+
+	align_done = EFX_DWORD_FIELD(reg, XX_ALIGN_DONE);
+	sync_status = EFX_DWORD_FIELD(reg, XX_SYNC_STAT);
+	if (align_done && (sync_status == XX_SYNC_STAT_DECODE_SYNCED))
+		link_ok = 1;
+
+	/* Clear link status ready for next read */
+	EFX_SET_DWORD_FIELD(reg, XX_COMMA_DET, XX_COMMA_DET_RESET);
+	EFX_SET_DWORD_FIELD(reg, XX_CHARERR, XX_CHARERR_RESET);
+	EFX_SET_DWORD_FIELD(reg, XX_DISPERR, XX_DISPERR_RESET);
+
+	falcon_xmac_writel(efx, &reg, XX_CORE_STAT_REG_MAC);
+
+	return link_ok;
+}
+
+static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
+{
+	unsigned int max_frame_len;
+	efx_dword_t reg;
+	int rx_fc = (efx->flow_control & EFX_FC_RX) ? 1 : 0;
+
+	/* Configure MAC  - cut-thru mode is hard wired on */
+	EFX_POPULATE_DWORD_3(reg,
+			     XM_RX_JUMBO_MODE, 1,
+			     XM_TX_STAT_EN, 1,
+			     XM_RX_STAT_EN, 1);
+	falcon_xmac_writel(efx, &reg, XM_GLB_CFG_REG_MAC);
+
+	/* Configure TX */
+	EFX_POPULATE_DWORD_6(reg,
+			     XM_TXEN, 1,
+			     XM_TX_PRMBL, 1,
+			     XM_AUTO_PAD, 1,
+			     XM_TXCRC, 1,
+			     XM_FCNTL, 1,
+			     XM_IPG, 0x3);
+	falcon_xmac_writel(efx, &reg, XM_TX_CFG_REG_MAC);
+
+	/* Configure RX */
+	EFX_POPULATE_DWORD_5(reg,
+			     XM_RXEN, 1,
+			     XM_AUTO_DEPAD, 0,
+			     XM_ACPT_ALL_MCAST, 1,
+			     XM_ACPT_ALL_UCAST, efx->promiscuous,
+			     XM_PASS_CRC_ERR, 1);
+	falcon_xmac_writel(efx, &reg, XM_RX_CFG_REG_MAC);
+
+	/* Set frame length */
+	max_frame_len = EFX_MAX_FRAME_LEN(efx->net_dev->mtu);
+	EFX_POPULATE_DWORD_1(reg, XM_MAX_RX_FRM_SIZE, max_frame_len);
+	falcon_xmac_writel(efx, &reg, XM_RX_PARAM_REG_MAC);
+	EFX_POPULATE_DWORD_2(reg,
+			     XM_MAX_TX_FRM_SIZE, max_frame_len,
+			     XM_TX_JUMBO_MODE, 1);
+	falcon_xmac_writel(efx, &reg, XM_TX_PARAM_REG_MAC);
+
+	EFX_POPULATE_DWORD_2(reg,
+			     XM_PAUSE_TIME, 0xfffe, /* MAX PAUSE TIME */
+			     XM_DIS_FCNTL, rx_fc ? 0 : 1);
+	falcon_xmac_writel(efx, &reg, XM_FC_REG_MAC);
+
+	/* Set MAC address */
+	EFX_POPULATE_DWORD_4(reg,
+			     XM_ADR_0, efx->net_dev->dev_addr[0],
+			     XM_ADR_1, efx->net_dev->dev_addr[1],
+			     XM_ADR_2, efx->net_dev->dev_addr[2],
+			     XM_ADR_3, efx->net_dev->dev_addr[3]);
+	falcon_xmac_writel(efx, &reg, XM_ADR_LO_REG_MAC);
+	EFX_POPULATE_DWORD_2(reg,
+			     XM_ADR_4, efx->net_dev->dev_addr[4],
+			     XM_ADR_5, efx->net_dev->dev_addr[5]);
+	falcon_xmac_writel(efx, &reg, XM_ADR_HI_REG_MAC);
+}
+
+/* Sometimes the XAUI link between Falcon and XFP fails to come up. The state
+ * of the link is checked during phy_reconfigure(). After XAIU is reset then
+ * the MAC must be reconfigured.
+ */
+#define MAX_XAUI_TRIES (5)	/* It's never been seen to take more than 2 */
+
+void falcon_check_xaui_link_up(struct efx_nic *efx)
+{
+	int max_tries, tries;
+	tries = EFX_WORKAROUND_5147(efx) ? MAX_XAUI_TRIES : 1;
+	max_tries = tries;
+
+	if (efx->phy_type == PHY_TYPE_NONE)
+		return;
+
+	while (tries) {
+		if (falcon_xaui_link_ok(efx))
+			return;
+
+		EFX_LOG(efx, "%s Clobbering XAUI (%d tries left).\n",
+			__func__, tries);
+		(void) falcon_reset_xaui(efx);
+		udelay(200);
+		tries--;
+	}
+
+	EFX_ERR(efx, "Failed to bring XAUI link back up in %d tries!\n",
+		max_tries);
+}
+
+void falcon_reconfigure_xmac(struct efx_nic *efx)
+{
+	falcon_deconfigure_mac_wrapper(efx);
+	efx->phy_op->reconfigure(efx);
+	falcon_reconfigure_xmac_core(efx);
+	falcon_reconfigure_mac_wrapper(efx);
+
+	/* Ensure XAUI link is up - might repeat reconfigure_xmac_core */
+	falcon_check_xaui_link_up(efx);
+}
+
+void falcon_fini_xmac(struct efx_nic *efx)
+{
+	/* Isolate the MAC - PHY */
+	falcon_deconfigure_mac_wrapper(efx);
+
+	/* Potentially power down the PHY */
+	efx->phy_op->fini(efx);
+}
+
+void falcon_update_stats_xmac(struct efx_nic *efx)
+{
+	struct efx_mac_stats *mac_stats = &efx->mac_stats;
+	int rc;
+
+	rc = falcon_dma_stats(efx, XgDmaDone_offset);
+	if (rc)
+		return;
+
+	/* Update MAC stats from DMAed values */
+	FALCON_STAT(efx, XgRxOctets, rx_bytes);
+	FALCON_STAT(efx, XgRxOctetsOK, rx_good_bytes);
+	FALCON_STAT(efx, XgRxPkts, rx_packets);
+	FALCON_STAT(efx, XgRxPktsOK, rx_good);
+	FALCON_STAT(efx, XgRxBroadcastPkts, rx_broadcast);
+	FALCON_STAT(efx, XgRxMulticastPkts, rx_multicast);
+	FALCON_STAT(efx, XgRxUnicastPkts, rx_unicast);
+	FALCON_STAT(efx, XgRxUndersizePkts, rx_lt64);
+	FALCON_STAT(efx, XgRxOversizePkts, rx_gtjumbo);
+	FALCON_STAT(efx, XgRxJabberPkts, rx_bad_gtjumbo);
+	FALCON_STAT(efx, XgRxUndersizeFCSerrorPkts, rx_bad_lt64);
+	FALCON_STAT(efx, XgRxDropEvents, rx_overflow);
+	FALCON_STAT(efx, XgRxFCSerrorPkts, rx_bad);
+	FALCON_STAT(efx, XgRxAlignError, rx_align_error);
+	FALCON_STAT(efx, XgRxSymbolError, rx_symbol_error);
+	FALCON_STAT(efx, XgRxInternalMACError, rx_internal_error);
+	FALCON_STAT(efx, XgRxControlPkts, rx_control);
+	FALCON_STAT(efx, XgRxPausePkts, rx_pause);
+	FALCON_STAT(efx, XgRxPkts64Octets, rx_64);
+	FALCON_STAT(efx, XgRxPkts65to127Octets, rx_65_to_127);
+	FALCON_STAT(efx, XgRxPkts128to255Octets, rx_128_to_255);
+	FALCON_STAT(efx, XgRxPkts256to511Octets, rx_256_to_511);
+	FALCON_STAT(efx, XgRxPkts512to1023Octets, rx_512_to_1023);
+	FALCON_STAT(efx, XgRxPkts1024to15xxOctets, rx_1024_to_15xx);
+	FALCON_STAT(efx, XgRxPkts15xxtoMaxOctets, rx_15xx_to_jumbo);
+	FALCON_STAT(efx, XgRxLengthError, rx_length_error);
+	FALCON_STAT(efx, XgTxPkts, tx_packets);
+	FALCON_STAT(efx, XgTxOctets, tx_bytes);
+	FALCON_STAT(efx, XgTxMulticastPkts, tx_multicast);
+	FALCON_STAT(efx, XgTxBroadcastPkts, tx_broadcast);
+	FALCON_STAT(efx, XgTxUnicastPkts, tx_unicast);
+	FALCON_STAT(efx, XgTxControlPkts, tx_control);
+	FALCON_STAT(efx, XgTxPausePkts, tx_pause);
+	FALCON_STAT(efx, XgTxPkts64Octets, tx_64);
+	FALCON_STAT(efx, XgTxPkts65to127Octets, tx_65_to_127);
+	FALCON_STAT(efx, XgTxPkts128to255Octets, tx_128_to_255);
+	FALCON_STAT(efx, XgTxPkts256to511Octets, tx_256_to_511);
+	FALCON_STAT(efx, XgTxPkts512to1023Octets, tx_512_to_1023);
+	FALCON_STAT(efx, XgTxPkts1024to15xxOctets, tx_1024_to_15xx);
+	FALCON_STAT(efx, XgTxPkts1519toMaxOctets, tx_15xx_to_jumbo);
+	FALCON_STAT(efx, XgTxUndersizePkts, tx_lt64);
+	FALCON_STAT(efx, XgTxOversizePkts, tx_gtjumbo);
+	FALCON_STAT(efx, XgTxNonTcpUdpPkt, tx_non_tcpudp);
+	FALCON_STAT(efx, XgTxMacSrcErrPkt, tx_mac_src_error);
+	FALCON_STAT(efx, XgTxIpSrcErrPkt, tx_ip_src_error);
+
+	/* Update derived statistics */
+	mac_stats->tx_good_bytes =
+		(mac_stats->tx_bytes - mac_stats->tx_bad_bytes);
+	mac_stats->rx_bad_bytes =
+		(mac_stats->rx_bytes - mac_stats->rx_good_bytes);
+}
+
+#define EFX_XAUI_RETRAIN_MAX 8
+
+int falcon_check_xmac(struct efx_nic *efx)
+{
+	unsigned link_ok, phyxs_ok = 1;
+	unsigned has_phyxs = efx->phy_op->mmds & (1 << MDIO_MMD_PHYXS);
+
+	/* Check the remote XAUI link status */
+	link_ok = falcon_xaui_link_ok(efx);
+	if (link_ok && has_phyxs) {
+		/* Does the PHYXS think we have lane sync? */
+		phyxs_ok = mdio_clause45_phyxgxs_lane_sync(efx);
+	}
+
+	if (EFX_WORKAROUND_5147(efx) && (!link_ok || !phyxs_ok))
+		(void) falcon_reset_xaui(efx);
+
+	/* Call the PHY check_hw routine */
+	return efx->phy_op->check_hw(efx);
+}
+
+/* Simulate a PHY event */
+void falcon_xmac_sim_phy_event(struct efx_nic *efx)
+{
+	efx_qword_t phy_event;
+
+	EFX_POPULATE_QWORD_2(phy_event,
+			     EV_CODE, GLOBAL_EV_DECODE,
+			     XG_PHY_INTR, 1);
+	falcon_generate_event(&efx->channel[0], &phy_event);
+}
+
+int falcon_xmac_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+{
+	mdio_clause45_get_settings(efx, ecmd);
+	ecmd->transceiver = XCVR_INTERNAL;
+	ecmd->phy_address = efx->mii.phy_id;
+	ecmd->autoneg = AUTONEG_DISABLE;
+	ecmd->duplex = DUPLEX_FULL;
+	return 0;
+}
+
+int falcon_xmac_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+{
+	if (ecmd->transceiver != XCVR_INTERNAL)
+		return -EINVAL;
+	if (ecmd->autoneg != AUTONEG_DISABLE)
+		return -EINVAL;
+	if (ecmd->duplex != DUPLEX_FULL)
+		return -EINVAL;
+
+	return mdio_clause45_set_settings(efx, ecmd);
+}
+
+
+int falcon_xmac_set_pause(struct efx_nic *efx, enum efx_fc_type flow_control)
+{
+	int reset;
+
+	if (flow_control & EFX_FC_AUTO) {
+		EFX_LOG(efx, "10G does not support flow control "
+			"autonegotiation\n");
+		return -EINVAL;
+	}
+
+	if ((flow_control & EFX_FC_TX) && !(flow_control & EFX_FC_RX))
+		return -EINVAL;
+
+	/* TX flow control may automatically turn itself off if the
+	 * link partner (intermittently) stops responding to pause
+	 * frames. There isn't any indication that this has happened,
+	 * so the best we do is leave it up to the user to spot this
+	 * and fix it be cycling transmit flow control on this end. */
+	reset = ((flow_control & EFX_FC_TX) &&
+		 !(efx->flow_control & EFX_FC_TX));
+	if (EFX_WORKAROUND_11482(efx) && reset) {
+		if (FALCON_REV(efx) >= FALCON_REV_B0) {
+			/* Recover by resetting the EM block */
+			if (efx->link_up)
+				falcon_drain_tx_fifo(efx);
+		} else {
+			/* Schedule a reset to recover */
+			efx_schedule_reset(efx, RESET_TYPE_INVISIBLE);
+		}
+	}
+
+	efx->flow_control = flow_control;
+
+	return 0;
+}
diff --git a/drivers/net/sfc/mac.h b/drivers/net/sfc/mac.h
new file mode 100644
index 0000000..edd07d4
--- /dev/null
+++ b/drivers/net/sfc/mac.h
@@ -0,0 +1,33 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2007 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_MAC_H
+#define EFX_MAC_H
+
+#include "net_driver.h"
+
+extern void falcon_xmac_writel(struct efx_nic *efx,
+			       efx_dword_t *value, unsigned int mac_reg);
+extern void falcon_xmac_readl(struct efx_nic *efx,
+			      efx_dword_t *value, unsigned int mac_reg);
+extern int falcon_init_xmac(struct efx_nic *efx);
+extern void falcon_reconfigure_xmac(struct efx_nic *efx);
+extern void falcon_update_stats_xmac(struct efx_nic *efx);
+extern void falcon_fini_xmac(struct efx_nic *efx);
+extern int falcon_check_xmac(struct efx_nic *efx);
+extern void falcon_xmac_sim_phy_event(struct efx_nic *efx);
+extern int falcon_xmac_get_settings(struct efx_nic *efx,
+				    struct ethtool_cmd *ecmd);
+extern int falcon_xmac_set_settings(struct efx_nic *efx,
+				    struct ethtool_cmd *ecmd);
+extern int falcon_xmac_set_pause(struct efx_nic *efx,
+				 enum efx_fc_type pause_params);
+
+#endif
diff --git a/drivers/net/sfc/gmii.h b/drivers/net/sfc/gmii.h
new file mode 100644
index 0000000..d25bbd1
--- /dev/null
+++ b/drivers/net/sfc/gmii.h
@@ -0,0 +1,195 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_GMII_H
+#define EFX_GMII_H
+
+/*
+ * GMII interface
+ */
+
+#include <linux/mii.h>
+
+/* GMII registers, excluding registers already defined as MII
+ * registers in mii.h
+ */
+#define GMII_IER		0x12	/* Interrupt enable register */
+#define GMII_ISR		0x13	/* Interrupt status register */
+
+/* Interrupt enable register */
+#define IER_ANEG_ERR		0x8000	/* Bit 15 - autonegotiation error */
+#define IER_SPEED_CHG		0x4000	/* Bit 14 - speed changed */
+#define IER_DUPLEX_CHG		0x2000	/* Bit 13 - duplex changed */
+#define IER_PAGE_RCVD		0x1000	/* Bit 12 - page received */
+#define IER_ANEG_DONE		0x0800	/* Bit 11 - autonegotiation complete */
+#define IER_LINK_CHG		0x0400	/* Bit 10 - link status changed */
+#define IER_SYM_ERR		0x0200	/* Bit 9 - symbol error */
+#define IER_FALSE_CARRIER	0x0100	/* Bit 8 - false carrier */
+#define IER_FIFO_ERR		0x0080	/* Bit 7 - FIFO over/underflow */
+#define IER_MDIX_CHG		0x0040	/* Bit 6 - MDI crossover changed */
+#define IER_DOWNSHIFT		0x0020	/* Bit 5 - downshift */
+#define IER_ENERGY		0x0010	/* Bit 4 - energy detect */
+#define IER_DTE_POWER		0x0004	/* Bit 2 - DTE power detect */
+#define IER_POLARITY_CHG	0x0002	/* Bit 1 - polarity changed */
+#define IER_JABBER		0x0001	/* Bit 0 - jabber */
+
+/* Interrupt status register */
+#define ISR_ANEG_ERR		0x8000	/* Bit 15 - autonegotiation error */
+#define ISR_SPEED_CHG		0x4000	/* Bit 14 - speed changed */
+#define ISR_DUPLEX_CHG		0x2000	/* Bit 13 - duplex changed */
+#define ISR_PAGE_RCVD		0x1000	/* Bit 12 - page received */
+#define ISR_ANEG_DONE		0x0800	/* Bit 11 - autonegotiation complete */
+#define ISR_LINK_CHG		0x0400	/* Bit 10 - link status changed */
+#define ISR_SYM_ERR		0x0200	/* Bit 9 - symbol error */
+#define ISR_FALSE_CARRIER	0x0100	/* Bit 8 - false carrier */
+#define ISR_FIFO_ERR		0x0080	/* Bit 7 - FIFO over/underflow */
+#define ISR_MDIX_CHG		0x0040	/* Bit 6 - MDI crossover changed */
+#define ISR_DOWNSHIFT		0x0020	/* Bit 5 - downshift */
+#define ISR_ENERGY		0x0010	/* Bit 4 - energy detect */
+#define ISR_DTE_POWER		0x0004	/* Bit 2 - DTE power detect */
+#define ISR_POLARITY_CHG	0x0002	/* Bit 1 - polarity changed */
+#define ISR_JABBER		0x0001	/* Bit 0 - jabber */
+
+/* Logically extended advertisement register */
+#define GM_ADVERTISE_SLCT		ADVERTISE_SLCT
+#define GM_ADVERTISE_CSMA		ADVERTISE_CSMA
+#define GM_ADVERTISE_10HALF		ADVERTISE_10HALF
+#define GM_ADVERTISE_1000XFULL		ADVERTISE_1000XFULL
+#define GM_ADVERTISE_10FULL		ADVERTISE_10FULL
+#define GM_ADVERTISE_1000XHALF		ADVERTISE_1000XHALF
+#define GM_ADVERTISE_100HALF		ADVERTISE_100HALF
+#define GM_ADVERTISE_1000XPAUSE		ADVERTISE_1000XPAUSE
+#define GM_ADVERTISE_100FULL		ADVERTISE_100FULL
+#define GM_ADVERTISE_1000XPSE_ASYM	ADVERTISE_1000XPSE_ASYM
+#define GM_ADVERTISE_100BASE4		ADVERTISE_100BASE4
+#define GM_ADVERTISE_PAUSE_CAP		ADVERTISE_PAUSE_CAP
+#define GM_ADVERTISE_PAUSE_ASYM		ADVERTISE_PAUSE_ASYM
+#define GM_ADVERTISE_RESV		ADVERTISE_RESV
+#define GM_ADVERTISE_RFAULT		ADVERTISE_RFAULT
+#define GM_ADVERTISE_LPACK		ADVERTISE_LPACK
+#define GM_ADVERTISE_NPAGE		ADVERTISE_NPAGE
+#define GM_ADVERTISE_1000FULL		(ADVERTISE_1000FULL << 8)
+#define GM_ADVERTISE_1000HALF		(ADVERTISE_1000HALF << 8)
+#define GM_ADVERTISE_1000		(GM_ADVERTISE_1000FULL | \
+					 GM_ADVERTISE_1000HALF)
+#define GM_ADVERTISE_FULL		(GM_ADVERTISE_1000FULL | \
+					 ADVERTISE_FULL)
+#define GM_ADVERTISE_ALL		(GM_ADVERTISE_1000FULL | \
+					 GM_ADVERTISE_1000HALF | \
+					 ADVERTISE_ALL)
+
+/* Logically extended link partner ability register */
+#define GM_LPA_SLCT			LPA_SLCT
+#define GM_LPA_10HALF			LPA_10HALF
+#define GM_LPA_1000XFULL		LPA_1000XFULL
+#define GM_LPA_10FULL			LPA_10FULL
+#define GM_LPA_1000XHALF		LPA_1000XHALF
+#define GM_LPA_100HALF			LPA_100HALF
+#define GM_LPA_1000XPAUSE		LPA_1000XPAUSE
+#define GM_LPA_100FULL			LPA_100FULL
+#define GM_LPA_1000XPAUSE_ASYM		LPA_1000XPAUSE_ASYM
+#define GM_LPA_100BASE4			LPA_100BASE4
+#define GM_LPA_PAUSE_CAP		LPA_PAUSE_CAP
+#define GM_LPA_PAUSE_ASYM		LPA_PAUSE_ASYM
+#define GM_LPA_RESV			LPA_RESV
+#define GM_LPA_RFAULT			LPA_RFAULT
+#define GM_LPA_LPACK			LPA_LPACK
+#define GM_LPA_NPAGE			LPA_NPAGE
+#define GM_LPA_1000FULL			(LPA_1000FULL << 6)
+#define GM_LPA_1000HALF			(LPA_1000HALF << 6)
+#define GM_LPA_10000FULL		0x00040000
+#define GM_LPA_10000HALF		0x00080000
+#define GM_LPA_DUPLEX			(GM_LPA_1000FULL | GM_LPA_10000FULL \
+					 | LPA_DUPLEX)
+#define GM_LPA_10			(LPA_10FULL | LPA_10HALF)
+#define GM_LPA_100			LPA_100
+#define GM_LPA_1000			(GM_LPA_1000FULL | GM_LPA_1000HALF)
+#define GM_LPA_10000			(GM_LPA_10000FULL | GM_LPA_10000HALF)
+
+/* Retrieve GMII autonegotiation advertised abilities
+ *
+ * The MII advertisment register (MII_ADVERTISE) is logically extended
+ * to include advertisement bits ADVERTISE_1000FULL and
+ * ADVERTISE_1000HALF from MII_CTRL1000.  The result can be tested
+ * against the GM_ADVERTISE_xxx constants.
+ */
+static inline unsigned int gmii_advertised(struct mii_if_info *gmii)
+{
+	unsigned int advertise;
+	unsigned int ctrl1000;
+
+	advertise = gmii->mdio_read(gmii->dev, gmii->phy_id, MII_ADVERTISE);
+	ctrl1000 = gmii->mdio_read(gmii->dev, gmii->phy_id, MII_CTRL1000);
+	return (((ctrl1000 << 8) & GM_ADVERTISE_1000) | advertise);
+}
+
+/* Retrieve GMII autonegotiation link partner abilities
+ *
+ * The MII link partner ability register (MII_LPA) is logically
+ * extended by adding bits LPA_1000HALF and LPA_1000FULL from
+ * MII_STAT1000.  The result can be tested against the GM_LPA_xxx
+ * constants.
+ */
+static inline unsigned int gmii_lpa(struct mii_if_info *gmii)
+{
+	unsigned int lpa;
+	unsigned int stat1000;
+
+	lpa = gmii->mdio_read(gmii->dev, gmii->phy_id, MII_LPA);
+	stat1000 = gmii->mdio_read(gmii->dev, gmii->phy_id, MII_STAT1000);
+	return (((stat1000 << 6) & GM_LPA_1000) | lpa);
+}
+
+/* Calculate GMII autonegotiated link technology
+ *
+ * "negotiated" should be the result of gmii_advertised() logically
+ * ANDed with the result of gmii_lpa().
+ *
+ * "tech" will be negotiated with the unused bits masked out.  For
+ * example, if both ends of the link are capable of both
+ * GM_LPA_1000FULL and GM_LPA_100FULL, GM_LPA_100FULL will be masked
+ * out.
+ */
+static inline unsigned int gmii_nway_result(unsigned int negotiated)
+{
+	unsigned int other_bits;
+
+	/* Mask out the speed and duplexity bits */
+	other_bits = negotiated & ~(GM_LPA_10 | GM_LPA_100 | GM_LPA_1000);
+
+	if (negotiated & GM_LPA_1000FULL)
+		return (other_bits | GM_LPA_1000FULL);
+	else if (negotiated & GM_LPA_1000HALF)
+		return (other_bits | GM_LPA_1000HALF);
+	else
+		return (other_bits | mii_nway_result(negotiated));
+}
+
+/* Calculate GMII non-autonegotiated link technology
+ *
+ * This provides an equivalent to gmii_nway_result for the case when
+ * autonegotiation is disabled.
+ */
+static inline unsigned int gmii_forced_result(unsigned int bmcr)
+{
+	unsigned int result;
+	int full_duplex;
+
+	full_duplex = bmcr & BMCR_FULLDPLX;
+	if (bmcr & BMCR_SPEED1000)
+		result = full_duplex ? GM_LPA_1000FULL : GM_LPA_1000HALF;
+	else if (bmcr & BMCR_SPEED100)
+		result = full_duplex ? GM_LPA_100FULL : GM_LPA_100HALF;
+	else
+		result = full_duplex ? GM_LPA_10FULL : GM_LPA_10HALF;
+	return result;
+}
+
+#endif /* EFX_GMII_H */
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
new file mode 100644
index 0000000..fee56b7
--- /dev/null
+++ b/drivers/net/sfc/tenxpress.c
@@ -0,0 +1,436 @@
+/****************************************************************************
+ * Driver for Solarflare 802.3an compliant PHY
+ * Copyright 2007 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/delay.h>
+#include <linux/seq_file.h>
+#include "efx.h"
+#include "gmii.h"
+#include "mdio_10g.h"
+#include "falcon.h"
+#include "phy.h"
+#include "falcon_hwdefs.h"
+#include "boards.h"
+#include "mac.h"
+
+/* We expect these MMDs to be in the package */
+/* AN not here as mdio_check_mmds() requires STAT2 support */
+#define TENXPRESS_REQUIRED_DEVS (MDIO_MMDREG_DEVS0_PMAPMD | \
+				 MDIO_MMDREG_DEVS0_PCS    | \
+				 MDIO_MMDREG_DEVS0_PHYXS)
+
+/* We complain if we fail to see the link partner as 10G capable this many
+ * times in a row (must be > 1 as sampling the autoneg. registers is racy)
+ */
+#define MAX_BAD_LP_TRIES	(5)
+
+/* Extended control register */
+#define	PMA_PMD_XCONTROL_REG 0xc000
+#define	PMA_PMD_LNPGA_POWERDOWN_LBN 8
+#define	PMA_PMD_LNPGA_POWERDOWN_WIDTH 1
+
+/* extended status register */
+#define PMA_PMD_XSTATUS_REG 0xc001
+#define PMA_PMD_XSTAT_FLP_LBN   (12)
+
+/* LED control register */
+#define PMA_PMD_LED_CTRL_REG	(0xc007)
+#define PMA_PMA_LED_ACTIVITY_LBN	(3)
+
+/* LED function override register */
+#define PMA_PMD_LED_OVERR_REG	(0xc009)
+/* Bit positions for different LEDs (there are more but not wired on SFE4001)*/
+#define PMA_PMD_LED_LINK_LBN	(0)
+#define PMA_PMD_LED_SPEED_LBN	(2)
+#define PMA_PMD_LED_TX_LBN	(4)
+#define PMA_PMD_LED_RX_LBN	(6)
+/* Override settings */
+#define	PMA_PMD_LED_AUTO	(0)	/* H/W control */
+#define	PMA_PMD_LED_ON		(1)
+#define	PMA_PMD_LED_OFF		(2)
+#define PMA_PMD_LED_FLASH	(3)
+/* All LEDs under hardware control */
+#define PMA_PMD_LED_FULL_AUTO	(0)
+/* Green and Amber under hardware control, Red off */
+#define PMA_PMD_LED_DEFAULT	(PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN)
+
+
+/* Self test (BIST) control register */
+#define PMA_PMD_BIST_CTRL_REG	(0xc014)
+#define PMA_PMD_BIST_BER_LBN	(2)	/* Run BER test */
+#define PMA_PMD_BIST_CONT_LBN	(1)	/* Run continuous BIST until cleared */
+#define PMA_PMD_BIST_SINGLE_LBN	(0)	/* Run 1 BIST iteration (self clears) */
+/* Self test status register */
+#define PMA_PMD_BIST_STAT_REG	(0xc015)
+#define PMA_PMD_BIST_ENX_LBN	(3)
+#define PMA_PMD_BIST_PMA_LBN	(2)
+#define PMA_PMD_BIST_RXD_LBN	(1)
+#define PMA_PMD_BIST_AFE_LBN	(0)
+
+#define BIST_MAX_DELAY	(1000)
+#define BIST_POLL_DELAY	(10)
+
+/* Misc register defines */
+#define PCS_CLOCK_CTRL_REG 0xd801
+#define PLL312_RST_N_LBN 2
+
+#define PCS_SOFT_RST2_REG 0xd806
+#define SERDES_RST_N_LBN 13
+#define XGXS_RST_N_LBN 12
+
+#define	PCS_TEST_SELECT_REG 0xd807	/* PRM 10.5.8 */
+#define	CLK312_EN_LBN 3
+
+/* Boot status register */
+#define PCS_BOOT_STATUS_REG	(0xd000)
+#define PCS_BOOT_FATAL_ERR_LBN	(0)
+#define PCS_BOOT_PROGRESS_LBN	(1)
+#define PCS_BOOT_PROGRESS_WIDTH	(2)
+#define PCS_BOOT_COMPLETE_LBN	(3)
+#define PCS_BOOT_MAX_DELAY	(100)
+#define PCS_BOOT_POLL_DELAY	(10)
+
+/* Time to wait between powering down the LNPGA and turning off the power
+ * rails */
+#define LNPGA_PDOWN_WAIT	(HZ / 5)
+
+static int crc_error_reset_threshold = 100;
+module_param(crc_error_reset_threshold, int, 0644);
+MODULE_PARM_DESC(crc_error_reset_threshold,
+		 "Max number of CRC errors before XAUI reset");
+
+struct tenxpress_phy_data {
+	enum tenxpress_state state;
+	atomic_t bad_crc_count;
+	int bad_lp_tries;
+};
+
+static int tenxpress_state_is(struct efx_nic *efx, int state)
+{
+	struct tenxpress_phy_data *phy_data = efx->phy_data;
+	return (phy_data != NULL) && (state == phy_data->state);
+}
+
+void tenxpress_set_state(struct efx_nic *efx,
+				enum tenxpress_state state)
+{
+	struct tenxpress_phy_data *phy_data = efx->phy_data;
+	if (phy_data != NULL)
+		phy_data->state = state;
+}
+
+void tenxpress_crc_err(struct efx_nic *efx)
+{
+	struct tenxpress_phy_data *phy_data = efx->phy_data;
+	if (phy_data != NULL)
+		atomic_inc(&phy_data->bad_crc_count);
+}
+
+/* Check that the C166 has booted successfully */
+static int tenxpress_phy_check(struct efx_nic *efx)
+{
+	int phy_id = efx->mii.phy_id;
+	int count = PCS_BOOT_MAX_DELAY / PCS_BOOT_POLL_DELAY;
+	int boot_stat;
+
+	/* Wait for the boot to complete (or not) */
+	while (count) {
+		boot_stat = mdio_clause45_read(efx, phy_id,
+					       MDIO_MMD_PCS,
+					       PCS_BOOT_STATUS_REG);
+		if (boot_stat & (1 << PCS_BOOT_COMPLETE_LBN))
+			break;
+		count--;
+		udelay(PCS_BOOT_POLL_DELAY);
+	}
+
+	if (!count) {
+		EFX_ERR(efx, "%s: PHY boot timed out. Last status "
+			"%x\n", __func__,
+			(boot_stat >> PCS_BOOT_PROGRESS_LBN) &
+			((1 << PCS_BOOT_PROGRESS_WIDTH) - 1));
+		return -ETIMEDOUT;
+	}
+
+	return 0;
+}
+
+static void tenxpress_reset_xaui(struct efx_nic *efx);
+
+static int tenxpress_init(struct efx_nic *efx)
+{
+	int rc, reg;
+
+	/* Turn on the clock  */
+	reg = (1 << CLK312_EN_LBN);
+	mdio_clause45_write(efx, efx->mii.phy_id,
+			    MDIO_MMD_PCS, PCS_TEST_SELECT_REG, reg);
+
+	rc = tenxpress_phy_check(efx);
+	if (rc < 0)
+		return rc;
+
+	/* Set the LEDs up as: Green = Link, Amber = Link/Act, Red = Off */
+	reg = mdio_clause45_read(efx, efx->mii.phy_id,
+				 MDIO_MMD_PMAPMD, PMA_PMD_LED_CTRL_REG);
+	reg |= (1 << PMA_PMA_LED_ACTIVITY_LBN);
+	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
+			    PMA_PMD_LED_CTRL_REG, reg);
+
+	reg = PMA_PMD_LED_DEFAULT;
+	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
+			    PMA_PMD_LED_OVERR_REG, reg);
+
+	return rc;
+}
+
+static int tenxpress_phy_init(struct efx_nic *efx)
+{
+	struct tenxpress_phy_data *phy_data;
+	int rc = 0;
+
+	phy_data = kzalloc(sizeof(*phy_data), GFP_KERNEL);
+	efx->phy_data = phy_data;
+
+	tenxpress_set_state(efx, TENXPRESS_STATUS_NORMAL);
+
+	rc = mdio_clause45_wait_reset_mmds(efx,
+					   TENXPRESS_REQUIRED_DEVS);
+	if (rc < 0)
+		goto fail;
+
+	rc = mdio_clause45_check_mmds(efx, TENXPRESS_REQUIRED_DEVS, 0);
+	if (rc < 0)
+		goto fail;
+
+	rc = tenxpress_init(efx);
+	if (rc < 0)
+		goto fail;
+
+	schedule_timeout_uninterruptible(HZ / 5); /* 200ms */
+
+	/* Let XGXS and SerDes out of reset and resets 10XPress */
+	falcon_reset_xaui(efx);
+
+	return 0;
+
+ fail:
+	kfree(efx->phy_data);
+	efx->phy_data = NULL;
+	return rc;
+}
+
+static void tenxpress_set_bad_lp(struct efx_nic *efx, int bad_lp)
+{
+	struct tenxpress_phy_data *pd = efx->phy_data;
+	int reg;
+
+	/* Nothing to do if all is well and was previously so. */
+	if (!(bad_lp || pd->bad_lp_tries))
+		return;
+
+	reg = mdio_clause45_read(efx, efx->mii.phy_id,
+				 MDIO_MMD_PMAPMD, PMA_PMD_LED_OVERR_REG);
+
+	if (bad_lp)
+		pd->bad_lp_tries++;
+	else
+		pd->bad_lp_tries = 0;
+
+	if (pd->bad_lp_tries == MAX_BAD_LP_TRIES) {
+		pd->bad_lp_tries = 0;	/* Restart count */
+		reg &= ~(PMA_PMD_LED_FLASH << PMA_PMD_LED_RX_LBN);
+		reg |= (PMA_PMD_LED_FLASH << PMA_PMD_LED_RX_LBN);
+		EFX_ERR(efx, "This NIC appears to be plugged into"
+			" a port that is not 10GBASE-T capable.\n"
+			" This PHY is 10GBASE-T ONLY, so no link can"
+			" be established.\n");
+	} else {
+		reg |= (PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN);
+	}
+	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
+			    PMA_PMD_LED_OVERR_REG, reg);
+}
+
+/* Check link status and return a boolean OK value. If the link is NOT
+ * OK we have a quick rummage round to see if we appear to be plugged
+ * into a non-10GBT port and if so warn the user that they won't get
+ * link any time soon as we are 10GBT only, unless caller specified
+ * not to do this check (it isn't useful in loopback) */
+static int tenxpress_link_ok(struct efx_nic *efx, int check_lp)
+{
+	int ok = mdio_clause45_links_ok(efx, TENXPRESS_REQUIRED_DEVS);
+
+	if (ok) {
+		tenxpress_set_bad_lp(efx, 0);
+	} else if (check_lp) {
+		/* Are we plugged into the wrong sort of link? */
+		int bad_lp = 0;
+		int phy_id = efx->mii.phy_id;
+		int an_stat = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
+						 MDIO_AN_STATUS);
+		int xphy_stat = mdio_clause45_read(efx, phy_id,
+						   MDIO_MMD_PMAPMD,
+						   PMA_PMD_XSTATUS_REG);
+		/* Are we plugged into anything that sends FLPs? If
+		 * not we can't distinguish between not being plugged
+		 * in and being plugged into a non-AN antique. The FLP
+		 * bit has the advantage of not clearing when autoneg
+		 * restarts. */
+		if (!(xphy_stat & (1 << PMA_PMD_XSTAT_FLP_LBN))) {
+			tenxpress_set_bad_lp(efx, 0);
+			return ok;
+		}
+
+		/* If it can do 10GBT it must be XNP capable */
+		bad_lp = !(an_stat & (1 << MDIO_AN_STATUS_XNP_LBN));
+		if (!bad_lp && (an_stat & (1 << MDIO_AN_STATUS_PAGE_LBN))) {
+			bad_lp = !(mdio_clause45_read(efx, phy_id,
+					MDIO_MMD_AN, MDIO_AN_10GBT_STATUS) &
+					(1 << MDIO_AN_10GBT_STATUS_LP_10G_LBN));
+		}
+		tenxpress_set_bad_lp(efx, bad_lp);
+	}
+	return ok;
+}
+
+static void tenxpress_phy_reconfigure(struct efx_nic *efx)
+{
+	if (!tenxpress_state_is(efx, TENXPRESS_STATUS_NORMAL))
+		return;
+
+	efx->link_up = tenxpress_link_ok(efx, 0);
+	efx->link_options = GM_LPA_10000FULL;
+}
+
+static void tenxpress_phy_clear_interrupt(struct efx_nic *efx)
+{
+	/* Nothing done here - LASI interrupts aren't reliable so poll  */
+}
+
+
+/* Poll PHY for interrupt */
+static int tenxpress_phy_check_hw(struct efx_nic *efx)
+{
+	struct tenxpress_phy_data *phy_data = efx->phy_data;
+	int phy_up = tenxpress_state_is(efx, TENXPRESS_STATUS_NORMAL);
+	int link_ok;
+
+	link_ok = phy_up && tenxpress_link_ok(efx, 1);
+
+	if (link_ok != efx->link_up) {
+		efx->link_up = link_ok;
+		falcon_xmac_sim_phy_event(efx);
+	}
+
+	/* Nothing to check if we've already shut down the PHY */
+	if (!phy_up)
+		return 0;
+
+	if (atomic_read(&phy_data->bad_crc_count) > crc_error_reset_threshold) {
+		EFX_ERR(efx, "Resetting XAUI due to too many CRC errors\n");
+		falcon_reset_xaui(efx);
+		atomic_set(&phy_data->bad_crc_count, 0);
+	}
+
+	return 0;
+}
+
+static void tenxpress_phy_fini(struct efx_nic *efx)
+{
+	int reg;
+
+	/* Power down the LNPGA */
+	reg = (1 << PMA_PMD_LNPGA_POWERDOWN_LBN);
+	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
+			    PMA_PMD_XCONTROL_REG, reg);
+
+	/* Waiting here ensures that the board fini, which can turn off the
+	 * power to the PHY, won't get run until the LNPGA powerdown has been
+	 * given long enough to complete. */
+	schedule_timeout_uninterruptible(LNPGA_PDOWN_WAIT); /* 200 ms */
+
+	kfree(efx->phy_data);
+	efx->phy_data = NULL;
+}
+
+
+/* Set the RX and TX LEDs and Link LED flashing. The other LEDs
+ * (which probably aren't wired anyway) are left in AUTO mode */
+void tenxpress_phy_blink(struct efx_nic *efx, int blink)
+{
+	int reg;
+
+	if (blink)
+		reg = (PMA_PMD_LED_FLASH << PMA_PMD_LED_TX_LBN) |
+			(PMA_PMD_LED_FLASH << PMA_PMD_LED_RX_LBN) |
+			(PMA_PMD_LED_FLASH << PMA_PMD_LED_LINK_LBN);
+	else
+		reg = PMA_PMD_LED_DEFAULT;
+
+	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
+			    PMA_PMD_LED_OVERR_REG, reg);
+}
+
+static void tenxpress_reset_xaui(struct efx_nic *efx)
+{
+	int phy = efx->mii.phy_id;
+	int clk_ctrl, test_select, soft_rst2;
+
+	/* Real work is done on clock_ctrl other resets are thought to be
+	 * optional but make the reset more reliable
+	 */
+
+	/* Read */
+	clk_ctrl = mdio_clause45_read(efx, phy, MDIO_MMD_PCS,
+				      PCS_CLOCK_CTRL_REG);
+	test_select = mdio_clause45_read(efx, phy, MDIO_MMD_PCS,
+					 PCS_TEST_SELECT_REG);
+	soft_rst2 = mdio_clause45_read(efx, phy, MDIO_MMD_PCS,
+				       PCS_SOFT_RST2_REG);
+
+	/* Put in reset */
+	test_select &= ~(1 << CLK312_EN_LBN);
+	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
+			    PCS_TEST_SELECT_REG, test_select);
+
+	soft_rst2 &= ~((1 << XGXS_RST_N_LBN) | (1 << SERDES_RST_N_LBN));
+	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
+			    PCS_SOFT_RST2_REG, soft_rst2);
+
+	clk_ctrl &= ~(1 << PLL312_RST_N_LBN);
+	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
+			    PCS_CLOCK_CTRL_REG, clk_ctrl);
+	udelay(10);
+
+	/* Remove reset */
+	clk_ctrl |= (1 << PLL312_RST_N_LBN);
+	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
+			    PCS_CLOCK_CTRL_REG, clk_ctrl);
+	udelay(10);
+
+	soft_rst2 |= ((1 << XGXS_RST_N_LBN) | (1 << SERDES_RST_N_LBN));
+	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
+			    PCS_SOFT_RST2_REG, soft_rst2);
+	udelay(10);
+
+	test_select |= (1 << CLK312_EN_LBN);
+	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
+			    PCS_TEST_SELECT_REG, test_select);
+	udelay(10);
+}
+
+struct efx_phy_operations falcon_tenxpress_phy_ops = {
+	.init             = tenxpress_phy_init,
+	.reconfigure      = tenxpress_phy_reconfigure,
+	.check_hw         = tenxpress_phy_check_hw,
+	.fini             = tenxpress_phy_fini,
+	.clear_interrupt  = tenxpress_phy_clear_interrupt,
+	.reset_xaui       = tenxpress_reset_xaui,
+	.mmds             = TENXPRESS_REQUIRED_DEVS,
+};
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
new file mode 100644
index 0000000..4fe34d7
--- /dev/null
+++ b/drivers/net/sfc/xfp_phy.c
@@ -0,0 +1,138 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2006-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+/*
+ * Driver for XFP optical PHYs (plus some support specific to the Quake 2032)
+ * See www.amcc.com for details (search for qt2032)
+ */
+
+#include <linux/timer.h>
+#include <linux/delay.h>
+#include "efx.h"
+#include "gmii.h"
+#include "mdio_10g.h"
+#include "xenpack.h"
+#include "phy.h"
+#include "mac.h"
+
+#define XFP_REQUIRED_DEVS (MDIO_MMDREG_DEVS0_PCS |	\
+			   MDIO_MMDREG_DEVS0_PMAPMD |	\
+			   MDIO_MMDREG_DEVS0_PHYXS)
+
+/****************************************************************************/
+/* Quake-specific MDIO registers */
+#define MDIO_QUAKE_LED0_REG	(0xD006)
+
+void xfp_set_led(struct efx_nic *p, int led, int mode)
+{
+	int addr = MDIO_QUAKE_LED0_REG + led;
+	mdio_clause45_write(p, p->mii.phy_id, MDIO_MMD_PMAPMD, addr,
+			    mode);
+}
+
+#define XFP_MAX_RESET_TIME 500
+#define XFP_RESET_WAIT 10
+
+/* Reset the PHYXS MMD. This is documented (for the Quake PHY) as doing
+ * a complete soft reset.
+ */
+static int xfp_reset_phy(struct efx_nic *efx)
+{
+	int rc;
+
+	rc = mdio_clause45_reset_mmd(efx, MDIO_MMD_PHYXS,
+				     XFP_MAX_RESET_TIME / XFP_RESET_WAIT,
+				     XFP_RESET_WAIT);
+	if (rc < 0)
+		goto fail;
+
+	/* Wait 250ms for the PHY to complete bootup */
+	msleep(250);
+
+	/* Check that all the MMDs we expect are present and responding. We
+	 * expect faults on some if the link is down, but not on the PHY XS */
+	rc = mdio_clause45_check_mmds(efx, XFP_REQUIRED_DEVS,
+				      MDIO_MMDREG_DEVS0_PHYXS);
+	if (rc < 0)
+		goto fail;
+
+	efx->board_info.init_leds(efx);
+
+	return rc;
+
+ fail:
+	EFX_ERR(efx, "XFP: reset timed out!\n");
+	return rc;
+}
+
+static int xfp_phy_init(struct efx_nic *efx)
+{
+	u32 devid = mdio_clause45_read_id(efx, MDIO_MMD_PHYXS);
+	int rc;
+
+	EFX_INFO(efx, "XFP: PHY ID reg %x (OUI %x model %x revision"
+		 " %x)\n", devid, MDIO_ID_OUI(devid), MDIO_ID_MODEL(devid),
+		 MDIO_ID_REV(devid));
+
+	rc = xfp_reset_phy(efx);
+	if (rc < 0)
+		goto fail;
+
+	EFX_INFO(efx, "XFP: PHY init %s.\n",
+		 rc ? "failed" : "successful");
+	return 0;
+
+ fail:
+	return rc;
+}
+
+static void xfp_phy_clear_interrupt(struct efx_nic *efx)
+{
+	xenpack_clear_lasi_irqs(efx);
+}
+
+static int xfp_link_ok(struct efx_nic *efx)
+{
+	return mdio_clause45_links_ok(efx, XFP_REQUIRED_DEVS);
+}
+
+static int xfp_phy_check_hw(struct efx_nic *efx)
+{
+	int rc = 0;
+	int link_up = xfp_link_ok(efx);
+	/* Simulate a PHY event if link state has changed */
+	if (link_up != efx->link_up) {
+		efx->link_up = link_up;
+		falcon_xmac_sim_phy_event(efx);
+	}
+
+	return rc;
+}
+
+static void xfp_phy_reconfigure(struct efx_nic *efx)
+{
+	efx->link_up = xfp_link_ok(efx);
+	efx->link_options = GM_LPA_10000FULL;
+}
+
+
+static void xfp_phy_fini(struct efx_nic *efx)
+{
+	/* Clobber the LED if it was blinking */
+	efx->board_info.blink(efx, 0);
+}
+
+struct efx_phy_operations falcon_xfp_phy_ops = {
+	.init            = xfp_phy_init,
+	.reconfigure     = xfp_phy_reconfigure,
+	.check_hw        = xfp_phy_check_hw,
+	.fini            = xfp_phy_fini,
+	.clear_interrupt = xfp_phy_clear_interrupt,
+	.reset_xaui      = efx_port_dummy_op_void,
+	.mmds            = XFP_REQUIRED_DEVS,
+};
diff --git a/drivers/net/sfc/xenpack.h b/drivers/net/sfc/xenpack.h
new file mode 100644
index 0000000..b0d1f22
--- /dev/null
+++ b/drivers/net/sfc/xenpack.h
@@ -0,0 +1,62 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2006 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_XENPACK_H
+#define EFX_XENPACK_H
+
+/* Exported functions from Xenpack standard PHY control */
+
+#include "mdio_10g.h"
+
+/****************************************************************************/
+/* XENPACK MDIO register extensions */
+#define MDIO_XP_LASI_RX_CTRL	(0x9000)
+#define MDIO_XP_LASI_TX_CTRL	(0x9001)
+#define MDIO_XP_LASI_CTRL	(0x9002)
+#define MDIO_XP_LASI_RX_STAT	(0x9003)
+#define MDIO_XP_LASI_TX_STAT	(0x9004)
+#define MDIO_XP_LASI_STAT	(0x9005)
+
+/* Control/Status bits */
+#define XP_LASI_LS_ALARM	(1 << 0)
+#define XP_LASI_TX_ALARM	(1 << 1)
+#define XP_LASI_RX_ALARM	(1 << 2)
+/* These two are Quake vendor extensions to the standard XENPACK defines */
+#define XP_LASI_LS_INTB		(1 << 3)
+#define XP_LASI_TEST		(1 << 7)
+
+/* Enable LASI interrupts for PHY */
+static inline void xenpack_enable_lasi_irqs(struct efx_nic *efx)
+{
+	int reg;
+	int phy_id = efx->mii.phy_id;
+	/* Read to clear LASI status register */
+	reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
+				 MDIO_XP_LASI_STAT);
+
+	mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
+			    MDIO_XP_LASI_CTRL, XP_LASI_LS_ALARM);
+}
+
+/* Read the LASI interrupt status to clear the interrupt. */
+static inline int xenpack_clear_lasi_irqs(struct efx_nic *efx)
+{
+	/* Read to clear link status alarm */
+	return mdio_clause45_read(efx, efx->mii.phy_id,
+				  MDIO_MMD_PMAPMD, MDIO_XP_LASI_STAT);
+}
+
+/* Turn off LASI interrupts */
+static inline void xenpack_disable_lasi_irqs(struct efx_nic *efx)
+{
+	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
+			    MDIO_XP_LASI_CTRL, 0);
+}
+
+#endif /* EFX_XENPACK_H */
diff --git a/drivers/net/sfc/phy.h b/drivers/net/sfc/phy.h
new file mode 100644
index 0000000..9d02c84
--- /dev/null
+++ b/drivers/net/sfc/phy.h
@@ -0,0 +1,48 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2007 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_PHY_H
+#define EFX_PHY_H
+
+/****************************************************************************
+ * 10Xpress (SFX7101) PHY
+ */
+extern struct efx_phy_operations falcon_tenxpress_phy_ops;
+
+enum tenxpress_state {
+	TENXPRESS_STATUS_OFF = 0,
+	TENXPRESS_STATUS_OTEMP = 1,
+	TENXPRESS_STATUS_NORMAL = 2,
+};
+
+extern void tenxpress_set_state(struct efx_nic *efx,
+				enum tenxpress_state state);
+extern void tenxpress_phy_blink(struct efx_nic *efx, int blink);
+extern void tenxpress_crc_err(struct efx_nic *efx);
+
+/****************************************************************************
+ * Exported functions from the driver for XFP optical PHYs
+ */
+extern struct efx_phy_operations falcon_xfp_phy_ops;
+
+/* The QUAKE XFP PHY provides various H/W control states for LEDs */
+#define QUAKE_LED_LINK_INVAL	(0)
+#define QUAKE_LED_LINK_STAT	(1)
+#define QUAKE_LED_LINK_ACT	(2)
+#define QUAKE_LED_LINK_ACTSTAT	(3)
+#define QUAKE_LED_OFF		(4)
+#define QUAKE_LED_ON		(5)
+#define QUAKE_LED_LINK_INPUT	(6)	/* Pin is an input. */
+/* What link the LED tracks */
+#define QUAKE_LED_TXLINK	(0)
+#define QUAKE_LED_RXLINK	(8)
+
+extern void xfp_set_led(struct efx_nic *p, int led, int state);
+
+#endif
diff --git a/drivers/net/sfc/i2c-direct.c b/drivers/net/sfc/i2c-direct.c
new file mode 100644
index 0000000..e89738c
--- /dev/null
+++ b/drivers/net/sfc/i2c-direct.c
@@ -0,0 +1,382 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005 Fen Systems Ltd.
+ * Copyright 2006-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <asm/io.h>
+#include <linux/delay.h>
+#include "net_driver.h"
+#include "i2c-direct.h"
+
+/*
+ * I2C data (SDA) and clock (SCL) line read/writes with appropriate
+ * delays.
+ */
+
+static inline void setsda(struct efx_i2c_interface *i2c, int state)
+{
+	udelay(i2c->op->udelay);
+	i2c->sda = state;
+	i2c->op->setsda(i2c);
+	udelay(i2c->op->udelay);
+}
+
+static inline void setscl(struct efx_i2c_interface *i2c, int state)
+{
+	udelay(i2c->op->udelay);
+	i2c->scl = state;
+	i2c->op->setscl(i2c);
+	udelay(i2c->op->udelay);
+}
+
+static inline int getsda(struct efx_i2c_interface *i2c)
+{
+	int sda;
+
+	udelay(i2c->op->udelay);
+	sda = i2c->op->getsda(i2c);
+	udelay(i2c->op->udelay);
+	return sda;
+}
+
+static inline int getscl(struct efx_i2c_interface *i2c)
+{
+	int scl;
+
+	udelay(i2c->op->udelay);
+	scl = i2c->op->getscl(i2c);
+	udelay(i2c->op->udelay);
+	return scl;
+}
+
+/*
+ * I2C low-level protocol operations
+ *
+ */
+
+static inline void i2c_release(struct efx_i2c_interface *i2c)
+{
+	EFX_WARN_ON_PARANOID(!i2c->scl);
+	EFX_WARN_ON_PARANOID(!i2c->sda);
+	/* Devices may time out if operations do not end */
+	setscl(i2c, 1);
+	setsda(i2c, 1);
+	EFX_BUG_ON_PARANOID(getsda(i2c) != 1);
+	EFX_BUG_ON_PARANOID(getscl(i2c) != 1);
+}
+
+static inline void i2c_start(struct efx_i2c_interface *i2c)
+{
+	/* We may be restarting immediately after a {send,recv}_bit,
+	 * so SCL will not necessarily already be high.
+	 */
+	EFX_WARN_ON_PARANOID(!i2c->sda);
+	setscl(i2c, 1);
+	setsda(i2c, 0);
+	setscl(i2c, 0);
+	setsda(i2c, 1);
+}
+
+static inline void i2c_send_bit(struct efx_i2c_interface *i2c, int bit)
+{
+	EFX_WARN_ON_PARANOID(i2c->scl != 0);
+	setsda(i2c, bit);
+	setscl(i2c, 1);
+	setscl(i2c, 0);
+	setsda(i2c, 1);
+}
+
+static inline int i2c_recv_bit(struct efx_i2c_interface *i2c)
+{
+	int bit;
+
+	EFX_WARN_ON_PARANOID(i2c->scl != 0);
+	EFX_WARN_ON_PARANOID(!i2c->sda);
+	setscl(i2c, 1);
+	bit = getsda(i2c);
+	setscl(i2c, 0);
+	return bit;
+}
+
+static inline void i2c_stop(struct efx_i2c_interface *i2c)
+{
+	EFX_WARN_ON_PARANOID(i2c->scl != 0);
+	setsda(i2c, 0);
+	setscl(i2c, 1);
+	setsda(i2c, 1);
+}
+
+/*
+ * I2C mid-level protocol operations
+ *
+ */
+
+/* Sends a byte via the I2C bus and checks for an acknowledgement from
+ * the slave device.
+ */
+static int i2c_send_byte(struct efx_i2c_interface *i2c, u8 byte)
+{
+	int i;
+
+	/* Send byte */
+	for (i = 0; i < 8; i++) {
+		i2c_send_bit(i2c, !!(byte & 0x80));
+		byte <<= 1;
+	}
+
+	/* Check for acknowledgement from slave */
+	return (i2c_recv_bit(i2c) == 0 ? 0 : -EIO);
+}
+
+/* Receives a byte via the I2C bus and sends ACK/NACK to the slave device. */
+static u8 i2c_recv_byte(struct efx_i2c_interface *i2c, int ack)
+{
+	u8 value = 0;
+	int i;
+
+	/* Receive byte */
+	for (i = 0; i < 8; i++)
+		value = (value << 1) | i2c_recv_bit(i2c);
+
+	/* Send ACK/NACK */
+	i2c_send_bit(i2c, (ack ? 0 : 1));
+
+	return value;
+}
+
+/* Calculate command byte for a read operation */
+static inline u8 i2c_read_cmd(u8 device_id)
+{
+	return ((device_id << 1) | 1);
+}
+
+/* Calculate command byte for a write operation */
+static inline u8 i2c_write_cmd(u8 device_id)
+{
+	return ((device_id << 1) | 0);
+}
+
+int efx_i2c_check_presence(struct efx_i2c_interface *i2c, u8 device_id)
+{
+	int rc;
+
+	/* If someone is driving the bus low we just give up. */
+	if (getsda(i2c) == 0 || getscl(i2c) == 0) {
+		EFX_ERR(i2c->efx, "%s someone is holding the I2C bus low."
+			" Giving up.\n", __func__);
+		return -EFAULT;
+	}
+
+	/* Pretend to initiate a device write */
+	i2c_start(i2c);
+	rc = i2c_send_byte(i2c, i2c_write_cmd(device_id));
+	if (rc)
+		goto out;
+
+ out:
+	i2c_stop(i2c);
+	i2c_release(i2c);
+
+	return rc;
+}
+
+/* This performs a fast read of one or more consecutive bytes from an
+ * I2C device.  Not all devices support consecutive reads of more than
+ * one byte; for these devices use efx_i2c_read() instead.
+ */
+int efx_i2c_fast_read(struct efx_i2c_interface *i2c,
+		      u8 device_id, u8 offset, u8 *data, unsigned int len)
+{
+	int i;
+	int rc;
+
+	EFX_WARN_ON_PARANOID(getsda(i2c) != 1);
+	EFX_WARN_ON_PARANOID(getscl(i2c) != 1);
+	EFX_WARN_ON_PARANOID(data == NULL);
+	EFX_WARN_ON_PARANOID(len < 1);
+
+	/* Select device and starting offset */
+	i2c_start(i2c);
+	rc = i2c_send_byte(i2c, i2c_write_cmd(device_id));
+	if (rc)
+		goto out;
+	rc = i2c_send_byte(i2c, offset);
+	if (rc)
+		goto out;
+
+	/* Read data from device */
+	i2c_start(i2c);
+	rc = i2c_send_byte(i2c, i2c_read_cmd(device_id));
+	if (rc)
+		goto out;
+	for (i = 0; i < (len - 1); i++)
+		/* Read and acknowledge all but the last byte */
+		data[i] = i2c_recv_byte(i2c, 1);
+	/* Read last byte with no acknowledgement */
+	data[i] = i2c_recv_byte(i2c, 0);
+
+ out:
+	i2c_stop(i2c);
+	i2c_release(i2c);
+
+	return rc;
+}
+
+/* This performs a fast write of one or more consecutive bytes to an
+ * I2C device.  Not all devices support consecutive writes of more
+ * than one byte; for these devices use efx_i2c_write() instead.
+ */
+int efx_i2c_fast_write(struct efx_i2c_interface *i2c,
+		       u8 device_id, u8 offset,
+		       const u8 *data, unsigned int len)
+{
+	int i;
+	int rc;
+
+	EFX_WARN_ON_PARANOID(getsda(i2c) != 1);
+	EFX_WARN_ON_PARANOID(getscl(i2c) != 1);
+	EFX_WARN_ON_PARANOID(len < 1);
+
+	/* Select device and starting offset */
+	i2c_start(i2c);
+	rc = i2c_send_byte(i2c, i2c_write_cmd(device_id));
+	if (rc)
+		goto out;
+	rc = i2c_send_byte(i2c, offset);
+	if (rc)
+		goto out;
+
+	/* Write data to device */
+	for (i = 0; i < len; i++) {
+		rc = i2c_send_byte(i2c, data[i]);
+		if (rc)
+			goto out;
+	}
+
+ out:
+	i2c_stop(i2c);
+	i2c_release(i2c);
+
+	return rc;
+}
+
+/* I2C byte-by-byte read */
+int efx_i2c_read(struct efx_i2c_interface *i2c,
+		 u8 device_id, u8 offset, u8 *data, unsigned int len)
+{
+	int rc;
+
+	/* i2c_fast_read with length 1 is a single byte read */
+	for (; len > 0; offset++, data++, len--) {
+		rc = efx_i2c_fast_read(i2c, device_id, offset, data, 1);
+		if (rc)
+			return rc;
+	}
+
+	return 0;
+}
+
+/* I2C byte-by-byte write */
+int efx_i2c_write(struct efx_i2c_interface *i2c,
+		  u8 device_id, u8 offset, const u8 *data, unsigned int len)
+{
+	int rc;
+
+	/* i2c_fast_write with length 1 is a single byte write */
+	for (; len > 0; offset++, data++, len--) {
+		rc = efx_i2c_fast_write(i2c, device_id, offset, data, 1);
+		if (rc)
+			return rc;
+		mdelay(i2c->op->mdelay);
+	}
+
+	return 0;
+}
+
+
+/* This is just a slightly neater wrapper round efx_i2c_fast_write
+ * in the case where the target doesn't take an offset
+ */
+int efx_i2c_send_bytes(struct efx_i2c_interface *i2c,
+		       u8 device_id, const u8 *data, unsigned int len)
+{
+	return efx_i2c_fast_write(i2c, device_id, data[0], data + 1, len - 1);
+}
+
+/* I2C receiving of bytes - does not send an offset byte */
+int efx_i2c_recv_bytes(struct efx_i2c_interface *i2c, u8 device_id,
+		       u8 *bytes, unsigned int len)
+{
+	int i;
+	int rc;
+
+	EFX_WARN_ON_PARANOID(getsda(i2c) != 1);
+	EFX_WARN_ON_PARANOID(getscl(i2c) != 1);
+	EFX_WARN_ON_PARANOID(len < 1);
+
+	/* Select device */
+	i2c_start(i2c);
+
+	/* Read data from device */
+	rc = i2c_send_byte(i2c, i2c_read_cmd(device_id));
+	if (rc)
+		goto out;
+
+	for (i = 0; i < (len - 1); i++)
+		/* Read and acknowledge all but the last byte */
+		bytes[i] = i2c_recv_byte(i2c, 1);
+	/* Read last byte with no acknowledgement */
+	bytes[i] = i2c_recv_byte(i2c, 0);
+
+ out:
+	i2c_stop(i2c);
+	i2c_release(i2c);
+
+	return rc;
+}
+
+/* SMBus and some I2C devices will time out if the I2C clock is
+ * held low for too long. This is most likely to happen in virtualised
+ * systems (when the entire domain is descheduled) but could in
+ * principle happen due to preemption on any busy system (and given the
+ * potential length of an I2C operation turning preemption off is not
+ * a sensible option). The following functions deal with the failure by
+ * retrying up to a fixed number of times.
+  */
+
+#define I2C_MAX_RETRIES	(10)
+
+/* The timeout problem will result in -EIO. If the wrapped function
+ * returns any other error, pass this up and do not retry. */
+#define RETRY_WRAPPER(_f) \
+	int retries = I2C_MAX_RETRIES; \
+	int rc; \
+	while (retries) { \
+		rc = _f; \
+		if (rc != -EIO) \
+			return rc; \
+		retries--; \
+	} \
+	return rc; \
+
+int efx_i2c_check_presence_retry(struct efx_i2c_interface *i2c, u8 device_id)
+{
+	RETRY_WRAPPER(efx_i2c_check_presence(i2c, device_id))
+}
+
+int efx_i2c_read_retry(struct efx_i2c_interface *i2c,
+		 u8 device_id, u8 offset, u8 *data, unsigned int len)
+{
+	RETRY_WRAPPER(efx_i2c_read(i2c, device_id, offset, data, len))
+}
+
+int efx_i2c_write_retry(struct efx_i2c_interface *i2c,
+		  u8 device_id, u8 offset, const u8 *data, unsigned int len)
+{
+	RETRY_WRAPPER(efx_i2c_write(i2c, device_id, offset, data, len))
+}
diff --git a/drivers/net/sfc/i2c-direct.h b/drivers/net/sfc/i2c-direct.h
new file mode 100644
index 0000000..291e561
--- /dev/null
+++ b/drivers/net/sfc/i2c-direct.h
@@ -0,0 +1,91 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005 Fen Systems Ltd.
+ * Copyright 2006 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_I2C_DIRECT_H
+#define EFX_I2C_DIRECT_H
+
+#include "net_driver.h"
+
+/*
+ * Direct control of an I2C bus
+ */
+
+struct efx_i2c_interface;
+
+/**
+ * struct efx_i2c_bit_operations - I2C bus direct control methods
+ *
+ * I2C bus direct control methods.
+ *
+ * @setsda: Set state of SDA line
+ * @setscl: Set state of SCL line
+ * @getsda: Get state of SDA line
+ * @getscl: Get state of SCL line
+ * @udelay: Delay between each bit operation
+ * @mdelay: Delay between each byte write
+ */
+struct efx_i2c_bit_operations {
+	void (*setsda) (struct efx_i2c_interface *i2c);
+	void (*setscl) (struct efx_i2c_interface *i2c);
+	int (*getsda) (struct efx_i2c_interface *i2c);
+	int (*getscl) (struct efx_i2c_interface *i2c);
+	unsigned int udelay;
+	unsigned int mdelay;
+};
+
+/**
+ * struct efx_i2c_interface - an I2C interface
+ *
+ * An I2C interface.
+ *
+ * @efx: Attached Efx NIC
+ * @op: I2C bus control methods
+ * @sda: Current output state of SDA line
+ * @scl: Current output state of SCL line
+ */
+struct efx_i2c_interface {
+	struct efx_nic *efx;
+	struct efx_i2c_bit_operations *op;
+	unsigned int sda:1;
+	unsigned int scl:1;
+};
+
+extern int efx_i2c_check_presence(struct efx_i2c_interface *i2c, u8 device_id);
+extern int efx_i2c_fast_read(struct efx_i2c_interface *i2c,
+			     u8 device_id, u8 offset,
+			     u8 *data, unsigned int len);
+extern int efx_i2c_fast_write(struct efx_i2c_interface *i2c,
+			      u8 device_id, u8 offset,
+			      const u8 *data, unsigned int len);
+extern int efx_i2c_read(struct efx_i2c_interface *i2c,
+			u8 device_id, u8 offset, u8 *data, unsigned int len);
+extern int efx_i2c_write(struct efx_i2c_interface *i2c,
+			 u8 device_id, u8 offset,
+			 const u8 *data, unsigned int len);
+
+extern int efx_i2c_send_bytes(struct efx_i2c_interface *i2c, u8 device_id,
+			      const u8 *bytes, unsigned int len);
+
+extern int efx_i2c_recv_bytes(struct efx_i2c_interface *i2c, u8 device_id,
+			      u8 *bytes, unsigned int len);
+
+
+/* Versions of the API that retry on failure. */
+extern int efx_i2c_check_presence_retry(struct efx_i2c_interface *i2c,
+					u8 device_id);
+
+extern int efx_i2c_read_retry(struct efx_i2c_interface *i2c,
+			u8 device_id, u8 offset, u8 *data, unsigned int len);
+
+extern int efx_i2c_write_retry(struct efx_i2c_interface *i2c,
+			 u8 device_id, u8 offset,
+			 const u8 *data, unsigned int len);
+
+#endif /* EFX_I2C_DIRECT_H */
diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
new file mode 100644
index 0000000..eecaa6d
--- /dev/null
+++ b/drivers/net/sfc/boards.c
@@ -0,0 +1,167 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2007 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include "net_driver.h"
+#include "phy.h"
+#include "boards.h"
+#include "efx.h"
+
+/* Macros for unpacking the board revision */
+/* The revision info is in host byte order. */
+#define BOARD_TYPE(_rev) (_rev >> 8)
+#define BOARD_MAJOR(_rev) ((_rev >> 4) & 0xf)
+#define BOARD_MINOR(_rev) (_rev & 0xf)
+
+/* Blink support. If the PHY has no auto-blink mode so we hang it off a timer */
+#define BLINK_INTERVAL (HZ/2)
+
+static void blink_led_timer(unsigned long context)
+{
+	struct efx_nic *efx = (struct efx_nic *)context;
+	struct efx_blinker *bl = &efx->board_info.blinker;
+	efx->board_info.set_fault_led(efx, bl->state);
+	bl->state = !bl->state;
+	if (bl->resubmit) {
+		bl->timer.expires = jiffies + BLINK_INTERVAL;
+		add_timer(&bl->timer);
+	}
+}
+
+static void board_blink(struct efx_nic *efx, int blink)
+{
+	struct efx_blinker *blinker = &efx->board_info.blinker;
+
+	/* The rtnl mutex serialises all ethtool ioctls, so
+	 * nothing special needs doing here. */
+	if (blink) {
+		blinker->resubmit = 1;
+		blinker->state = 0;
+		setup_timer(&blinker->timer, blink_led_timer,
+			    (unsigned long)efx);
+		blinker->timer.expires = jiffies + BLINK_INTERVAL;
+		add_timer(&blinker->timer);
+	} else {
+		blinker->resubmit = 0;
+		if (blinker->timer.function)
+			del_timer_sync(&blinker->timer);
+		efx->board_info.set_fault_led(efx, 0);
+	}
+}
+
+/*****************************************************************************
+ * Support for the SFE4002
+ *
+ */
+/****************************************************************************/
+/* LED allocations. Note that on rev A0 boards the schematic and the reality
+ * differ: red and green are swapped. Below is the fixed (A1) layout (there
+ * are only 3 A0 boards in existence, so no real reason to make this
+ * conditional).
+ */
+#define SFE4002_FAULT_LED (2)	/* Red */
+#define SFE4002_RX_LED    (0)	/* Green */
+#define SFE4002_TX_LED    (1)	/* Amber */
+
+static int sfe4002_init_leds(struct efx_nic *efx)
+{
+	/* Set the TX and RX LEDs to reflect status and activity, and the
+	 * fault LED off */
+	xfp_set_led(efx, SFE4002_TX_LED,
+		    QUAKE_LED_TXLINK | QUAKE_LED_LINK_ACTSTAT);
+	xfp_set_led(efx, SFE4002_RX_LED,
+		    QUAKE_LED_RXLINK | QUAKE_LED_LINK_ACTSTAT);
+	xfp_set_led(efx, SFE4002_FAULT_LED, QUAKE_LED_OFF);
+	efx->board_info.blinker.led_num = SFE4002_FAULT_LED;
+	return 0;
+}
+
+static void sfe4002_fault_led(struct efx_nic *efx, int state)
+{
+	xfp_set_led(efx, SFE4002_FAULT_LED, state ? QUAKE_LED_ON :
+			QUAKE_LED_OFF);
+}
+
+static int sfe4002_init(struct efx_nic *efx)
+{
+	efx->board_info.init_leds = sfe4002_init_leds;
+	efx->board_info.set_fault_led = sfe4002_fault_led;
+	efx->board_info.blink = board_blink;
+	return 0;
+}
+
+/* This will get expanded as board-specific details get moved out of the
+ * PHY drivers. */
+struct efx_board_data {
+	const char *ref_model;
+	const char *gen_type;
+	int (*init) (struct efx_nic *nic);
+};
+
+static int dummy_init(struct efx_nic *nic)
+{
+	return 0;
+}
+
+static struct efx_board_data board_data[] = {
+	[EFX_BOARD_INVALID] =
+	{NULL,	    NULL,                  dummy_init},
+	[EFX_BOARD_SFE4001] =
+	{"SFE4001", "10GBASE-T adapter",   sfe4001_poweron},
+	[EFX_BOARD_SFE4002] =
+	{"SFE4002", "XFP adapter",         sfe4002_init},
+};
+
+int efx_set_board_info(struct efx_nic *efx, u16 revision_info)
+{
+	int rc = 0;
+	struct efx_board_data *data;
+
+	if (BOARD_TYPE(revision_info) >= EFX_BOARD_MAX) {
+		EFX_ERR(efx, "squashing unknown board type %d\n",
+			BOARD_TYPE(revision_info));
+		revision_info = 0;
+	}
+
+	if (BOARD_TYPE(revision_info) == 0) {
+		efx->board_info.major = 0;
+		efx->board_info.minor = 0;
+		/* For early boards that don't have revision info. there is
+		 * only 1 board for each PHY type, so we can work it out, with
+		 * the exception of the PHY-less boards. */
+		switch (efx->phy_type) {
+		case PHY_TYPE_10XPRESS:
+			efx->board_info.type = EFX_BOARD_SFE4001;
+			break;
+		case PHY_TYPE_XFP:
+			efx->board_info.type = EFX_BOARD_SFE4002;
+			break;
+		default:
+			efx->board_info.type = 0;
+			break;
+		}
+	} else {
+		efx->board_info.type = BOARD_TYPE(revision_info);
+		efx->board_info.major = BOARD_MAJOR(revision_info);
+		efx->board_info.minor = BOARD_MINOR(revision_info);
+	}
+
+	data = &board_data[efx->board_info.type];
+
+	/* Report the board model number or generic type for recognisable
+	 * boards. */
+	if (efx->board_info.type != 0)
+		EFX_INFO(efx, "board is %s rev %c%d\n",
+			 (efx->pci_dev->subsystem_vendor == EFX_VENDID_SFC)
+			 ? data->ref_model : data->gen_type,
+			 'A' + efx->board_info.major, efx->board_info.minor);
+
+	efx->board_info.init = data->init;
+
+	return rc;
+}
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
new file mode 100644
index 0000000..11fa9fb
--- /dev/null
+++ b/drivers/net/sfc/sfe4001.c
@@ -0,0 +1,252 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2007 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+/*****************************************************************************
+ * Support for the SFE4001 NIC: driver code for the PCA9539 I/O expander that
+ * controls the PHY power rails, and for the MAX6647 temp. sensor used to check
+ * the PHY
+ */
+#include <linux/delay.h>
+#include "efx.h"
+#include "phy.h"
+#include "boards.h"
+#include "falcon.h"
+#include "falcon_hwdefs.h"
+#include "mac.h"
+
+/**************************************************************************
+ *
+ * I2C IO Expander device
+ *
+ **************************************************************************/
+#define	PCA9539 0x74
+
+#define	P0_IN 0x00
+#define	P0_OUT 0x02
+#define	P0_INVERT 0x04
+#define	P0_CONFIG 0x06
+
+#define	P0_EN_1V0X_LBN 0
+#define	P0_EN_1V0X_WIDTH 1
+#define	P0_EN_1V2_LBN 1
+#define	P0_EN_1V2_WIDTH 1
+#define	P0_EN_2V5_LBN 2
+#define	P0_EN_2V5_WIDTH 1
+#define	P0_EN_3V3X_LBN 3
+#define	P0_EN_3V3X_WIDTH 1
+#define	P0_EN_5V_LBN 4
+#define	P0_EN_5V_WIDTH 1
+#define	P0_SHORTEN_JTAG_LBN 5
+#define	P0_SHORTEN_JTAG_WIDTH 1
+#define	P0_X_TRST_LBN 6
+#define	P0_X_TRST_WIDTH 1
+#define	P0_DSP_RESET_LBN 7
+#define	P0_DSP_RESET_WIDTH 1
+
+#define	P1_IN 0x01
+#define	P1_OUT 0x03
+#define	P1_INVERT 0x05
+#define	P1_CONFIG 0x07
+
+#define	P1_AFE_PWD_LBN 0
+#define	P1_AFE_PWD_WIDTH 1
+#define	P1_DSP_PWD25_LBN 1
+#define	P1_DSP_PWD25_WIDTH 1
+#define	P1_RESERVED_LBN 2
+#define	P1_RESERVED_WIDTH 2
+#define	P1_SPARE_LBN 4
+#define	P1_SPARE_WIDTH 4
+
+
+/**************************************************************************
+ *
+ * Temperature Sensor
+ *
+ **************************************************************************/
+#define	MAX6647	0x4e
+
+#define	RLTS	0x00
+#define	RLTE	0x01
+#define	RSL	0x02
+#define	RCL	0x03
+#define	RCRA	0x04
+#define	RLHN	0x05
+#define	RLLI	0x06
+#define	RRHI	0x07
+#define	RRLS	0x08
+#define	WCRW	0x0a
+#define	WLHO	0x0b
+#define	WRHA	0x0c
+#define	WRLN	0x0e
+#define	OSHT	0x0f
+#define	REET	0x10
+#define	RIET	0x11
+#define	RWOE	0x19
+#define	RWOI	0x20
+#define	HYS	0x21
+#define	QUEUE	0x22
+#define	MFID	0xfe
+#define	REVID	0xff
+
+/* Status bits */
+#define MAX6647_BUSY	(1 << 7)	/* ADC is converting */
+#define MAX6647_LHIGH	(1 << 6)	/* Local high temp. alarm */
+#define MAX6647_LLOW	(1 << 5)	/* Local low temp. alarm */
+#define MAX6647_RHIGH	(1 << 4)	/* Remote high temp. alarm */
+#define MAX6647_RLOW	(1 << 3)	/* Remote low temp. alarm */
+#define MAX6647_FAULT	(1 << 2)	/* DXN/DXP short/open circuit */
+#define MAX6647_EOT	(1 << 1)	/* Remote junction overtemp. */
+#define MAX6647_IOT	(1 << 0)	/* Local junction overtemp. */
+
+static const u8 xgphy_max_temperature = 90;
+
+void sfe4001_poweroff(struct efx_nic *efx)
+{
+	struct efx_i2c_interface *i2c = &efx->i2c;
+
+	u8 cfg, out, in;
+
+	EFX_INFO(efx, "%s\n", __func__);
+
+	/* Turn off all power rails */
+	out = 0xff;
+	(void) efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
+
+	/* Disable port 1 outputs on IO expander */
+	cfg = 0xff;
+	(void) efx_i2c_write(i2c, PCA9539, P1_CONFIG, &cfg, 1);
+
+	/* Disable port 0 outputs on IO expander */
+	cfg = 0xff;
+	(void) efx_i2c_write(i2c, PCA9539, P0_CONFIG, &cfg, 1);
+
+	/* Clear any over-temperature alert */
+	(void) efx_i2c_read(i2c, MAX6647, RSL, &in, 1);
+}
+
+/* This board uses an I2C expander to provider power to the PHY, which needs to
+ * be turned on before the PHY can be used.
+ * Context: Process context, rtnl lock held
+ */
+int sfe4001_poweron(struct efx_nic *efx)
+{
+	struct efx_i2c_interface *i2c = &efx->i2c;
+	unsigned int count;
+	int rc;
+	u8 out, in, cfg;
+	efx_dword_t reg;
+
+	/* 10Xpress has fixed-function LED pins, so there is no board-specific
+	 * blink code. */
+	efx->board_info.blink = tenxpress_phy_blink;
+
+	/* Ensure that XGXS and XAUI SerDes are held in reset */
+	EFX_POPULATE_DWORD_7(reg, XX_PWRDNA_EN, 1,
+			     XX_PWRDNB_EN, 1,
+			     XX_RSTPLLAB_EN, 1,
+			     XX_RESETA_EN, 1,
+			     XX_RESETB_EN, 1,
+			     XX_RSTXGXSRX_EN, 1,
+			     XX_RSTXGXSTX_EN, 1);
+	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	udelay(10);
+
+	/* Set DSP over-temperature alert threshold */
+	EFX_INFO(efx, "DSP cut-out at %dC\n", xgphy_max_temperature);
+	rc = efx_i2c_write(i2c, MAX6647, WLHO,
+			   &xgphy_max_temperature, 1);
+	if (rc)
+		goto fail1;
+
+	/* Read it back and verify */
+	rc = efx_i2c_read(i2c, MAX6647, RLHN, &in, 1);
+	if (rc)
+		goto fail1;
+	if (in != xgphy_max_temperature) {
+		rc = -EFAULT;
+		goto fail1;
+	}
+
+	/* Clear any previous over-temperature alert */
+	rc = efx_i2c_read(i2c, MAX6647, RSL, &in, 1);
+	if (rc)
+		goto fail1;
+
+	/* Enable port 0 and port 1 outputs on IO expander */
+	cfg = 0x00;
+	rc = efx_i2c_write(i2c, PCA9539, P0_CONFIG, &cfg, 1);
+	if (rc)
+		goto fail1;
+	cfg = 0xff & ~(1 << P1_SPARE_LBN);
+	rc = efx_i2c_write(i2c, PCA9539, P1_CONFIG, &cfg, 1);
+	if (rc)
+		goto fail2;
+
+	/* Turn all power off then wait 1 sec. This ensures PHY is reset */
+	out = 0xff & ~((0 << P0_EN_1V2_LBN) | (0 << P0_EN_2V5_LBN) |
+		       (0 << P0_EN_3V3X_LBN) | (0 << P0_EN_5V_LBN) |
+		       (0 << P0_EN_1V0X_LBN));
+	rc = efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
+	if (rc)
+		goto fail3;
+
+	schedule_timeout_uninterruptible(HZ);
+	count = 0;
+	do {
+		/* Turn on 1.2V, 2.5V, 3.3V and 5V power rails */
+		out = 0xff & ~((1 << P0_EN_1V2_LBN) | (1 << P0_EN_2V5_LBN) |
+			       (1 << P0_EN_3V3X_LBN) | (1 << P0_EN_5V_LBN) |
+			       (1 << P0_X_TRST_LBN));
+
+		rc = efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
+		if (rc)
+			goto fail3;
+		msleep(10);
+
+		/* Turn on 1V power rail */
+		out &= ~(1 << P0_EN_1V0X_LBN);
+		rc = efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
+		if (rc)
+			goto fail3;
+
+		EFX_INFO(efx, "waiting for power (attempt %d)...\n", count);
+
+		schedule_timeout_uninterruptible(HZ);
+
+		/* Check DSP is powered */
+		rc = efx_i2c_read(i2c, PCA9539, P1_IN, &in, 1);
+		if (rc)
+			goto fail3;
+		if (in & (1 << P1_AFE_PWD_LBN))
+			goto done;
+
+	} while (++count < 20);
+
+	EFX_INFO(efx, "timed out waiting for power\n");
+	rc = -ETIMEDOUT;
+	goto fail3;
+
+done:
+	EFX_INFO(efx, "PHY is powered on\n");
+	return 0;
+
+fail3:
+	/* Turn off all power rails */
+	out = 0xff;
+	(void) efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
+	/* Disable port 1 outputs on IO expander */
+	out = 0xff;
+	(void) efx_i2c_write(i2c, PCA9539, P1_CONFIG, &out, 1);
+fail2:
+	/* Disable port 0 outputs on IO expander */
+	out = 0xff;
+	(void) efx_i2c_write(i2c, PCA9539, P0_CONFIG, &out, 1);
+fail1:
+	return rc;
+}
diff --git a/drivers/net/sfc/boards.h b/drivers/net/sfc/boards.h
new file mode 100644
index 0000000..f56341d
--- /dev/null
+++ b/drivers/net/sfc/boards.h
@@ -0,0 +1,26 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2007 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_BOARDS_H
+#define EFX_BOARDS_H
+
+/* Board IDs (must fit in 8 bits) */
+enum efx_board_type {
+	EFX_BOARD_INVALID = 0,
+	EFX_BOARD_SFE4001 = 1,   /* SFE4001 (10GBASE-T) */
+	EFX_BOARD_SFE4002 = 2,
+	/* Insert new types before here */
+	EFX_BOARD_MAX
+};
+
+extern int efx_set_board_info(struct efx_nic *efx, u16 revision_info);
+extern int sfe4001_poweron(struct efx_nic *efx);
+extern void sfe4001_poweroff(struct efx_nic *efx);
+
+#endif

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
