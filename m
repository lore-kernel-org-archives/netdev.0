From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH 06/12] fsl/fman: Add the FMan MAC FLIB
Date: Wed, 10 Jun 2015 18:21:52 +0300
Message-ID: <1433949712-5648-13-git-send-email-madalin.bucur@freescale.com>
References: <1433949712-5648-1-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-2-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-3-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-4-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-5-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-6-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-7-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-8-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-9-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-10-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-11-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-12-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <scottwood@freescale.com>,
	Igal Liberman <Igal.Liberman@freescale.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxppc-dev@lists.ozlabs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433949712-5648-12-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Igal Liberman <Igal.Liberman@freescale.com>

The FMan MAC FLib provides basic API used by the drivers to
configure and control the FMan MAC hardware.

Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
---
 drivers/net/ethernet/freescale/fman/Makefile       |   1 +
 drivers/net/ethernet/freescale/fman/mac/Makefile   |   5 +
 .../net/ethernet/freescale/fman/mac/fman_dtsec.c   | 571 +++++++++++++++++++++
 .../freescale/fman/mac/fman_dtsec_mii_acc.c        | 168 ++++++
 .../net/ethernet/freescale/fman/mac/fman_memac.c   | 365 +++++++++++++
 .../freescale/fman/mac/fman_memac_mii_acc.c        | 217 ++++++++
 .../net/ethernet/freescale/fman/mac/fman_tgec.c    | 217 ++++++++
 7 files changed, 1544 insertions(+)
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/Makefile
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_dtsec.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_dtsec_mii_acc.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_memac.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_memac_mii_acc.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_tgec.c

diff --git a/drivers/net/ethernet/freescale/fman/Makefile b/drivers/net/ethernet/freescale/fman/Makefile
index 50a4de2..1841b03 100644
--- a/drivers/net/ethernet/freescale/fman/Makefile
+++ b/drivers/net/ethernet/freescale/fman/Makefile
@@ -5,3 +5,4 @@ obj-y		+= fsl_fman.o
 fsl_fman-objs	:= fman.o
 
 obj-y	+= port/
+obj-y	+= mac/
diff --git a/drivers/net/ethernet/freescale/fman/mac/Makefile b/drivers/net/ethernet/freescale/fman/mac/Makefile
new file mode 100644
index 0000000..ce03e25
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/Makefile
@@ -0,0 +1,5 @@
+obj-y	+= fsl_fman_mac.o
+
+fsl_fman_mac-objs		:= fman_dtsec.o fman_dtsec_mii_acc.o	\
+				   fman_memac.o fman_memac_mii_acc.o	\
+				   fman_tgec.o
diff --git a/drivers/net/ethernet/freescale/fman/mac/fman_dtsec.c b/drivers/net/ethernet/freescale/fman/mac/fman_dtsec.c
new file mode 100644
index 0000000..290a037
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/fman_dtsec.c
@@ -0,0 +1,571 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "fsl_fman_dtsec.h"
+
+void fman_dtsec_stop_rx(struct dtsec_regs __iomem *regs)
+{
+	/* Assert the graceful stop bit */
+	iowrite32be(ioread32be(&regs->rctrl) | RCTRL_GRS, &regs->rctrl);
+}
+
+void fman_dtsec_stop_tx(struct dtsec_regs __iomem *regs)
+{
+	/* Assert the graceful stop bit */
+	iowrite32be(ioread32be(&regs->tctrl) | DTSEC_TCTRL_GTS, &regs->tctrl);
+}
+
+void fman_dtsec_start_tx(struct dtsec_regs __iomem *regs)
+{
+	/* clear the graceful stop bit */
+	iowrite32be(ioread32be(&regs->tctrl) & ~DTSEC_TCTRL_GTS, &regs->tctrl);
+}
+
+void fman_dtsec_start_rx(struct dtsec_regs __iomem *regs)
+{
+	/* clear the graceful stop bit */
+	iowrite32be(ioread32be(&regs->rctrl) & ~RCTRL_GRS, &regs->rctrl);
+}
+
+void fman_dtsec_defconfig(struct dtsec_cfg *cfg)
+{
+	cfg->halfdup_on = DEFAULT_HALFDUP_ON;
+	cfg->halfdup_retransmit = DEFAULT_HALFDUP_RETRANSMIT;
+	cfg->halfdup_coll_window = DEFAULT_HALFDUP_COLL_WINDOW;
+	cfg->halfdup_excess_defer = DEFAULT_HALFDUP_EXCESS_DEFER;
+	cfg->halfdup_no_backoff = DEFAULT_HALFDUP_NO_BACKOFF;
+	cfg->halfdup_bp_no_backoff = DEFAULT_HALFDUP_BP_NO_BACKOFF;
+	cfg->halfdup_alt_backoff_val = DEFAULT_HALFDUP_ALT_BACKOFF_VAL;
+	cfg->halfdup_alt_backoff_en = DEFAULT_HALFDUP_ALT_BACKOFF_EN;
+	cfg->rx_drop_bcast = DEFAULT_RX_DROP_BCAST;
+	cfg->rx_short_frm = DEFAULT_RX_SHORT_FRM;
+	cfg->rx_len_check = DEFAULT_RX_LEN_CHECK;
+	cfg->tx_pad_crc = DEFAULT_TX_PAD_CRC;
+	cfg->tx_crc = DEFAULT_TX_CRC;
+	cfg->rx_ctrl_acc = DEFAULT_RX_CTRL_ACC;
+	cfg->tx_pause_time = DEFAULT_TX_PAUSE_TIME;
+	/* PHY address 0 is reserved (DPAA RM) */
+	cfg->tbipa = DEFAULT_TBIPA;
+	cfg->rx_prepend = DEFAULT_RX_PREPEND;
+	cfg->ptp_tsu_en = DEFAULT_PTP_TSU_EN;
+	cfg->ptp_exception_en = DEFAULT_PTP_EXCEPTION_EN;
+	cfg->preamble_len = DEFAULT_PREAMBLE_LEN;
+	cfg->rx_preamble = DEFAULT_RX_PREAMBLE;
+	cfg->tx_preamble = DEFAULT_TX_PREAMBLE;
+	cfg->loopback = DEFAULT_LOOPBACK;
+	cfg->rx_time_stamp_en = DEFAULT_RX_TIME_STAMP_EN;
+	cfg->tx_time_stamp_en = DEFAULT_TX_TIME_STAMP_EN;
+	cfg->rx_flow = DEFAULT_RX_FLOW;
+	cfg->tx_flow = DEFAULT_TX_FLOW;
+	cfg->rx_group_hash_exd = DEFAULT_RX_GROUP_HASH_EXD;
+	cfg->tx_pause_time_extd = DEFAULT_TX_PAUSE_TIME_EXTD;
+	cfg->rx_promisc = DEFAULT_RX_PROMISC;
+	cfg->non_back_to_back_ipg1 = DEFAULT_NON_BACK_TO_BACK_IPG1;
+	cfg->non_back_to_back_ipg2 = DEFAULT_NON_BACK_TO_BACK_IPG2;
+	cfg->min_ifg_enforcement = DEFAULT_MIN_IFG_ENFORCEMENT;
+	cfg->back_to_back_ipg = DEFAULT_BACK_TO_BACK_IPG;
+	cfg->maximum_frame = DEFAULT_MAXIMUM_FRAME;
+	cfg->tbi_phy_addr = DEFAULT_TBI_PHY_ADDR;
+	cfg->wake_on_lan = DEFAULT_WAKE_ON_LAN;
+}
+
+int fman_dtsec_init(struct dtsec_regs __iomem *regs, struct dtsec_cfg *cfg,
+		    enum enet_interface iface_mode,
+		    enum enet_speed iface_speed,
+		    uint8_t *macaddr,
+		    uint8_t __maybe_unused fm_rev_maj,
+		    uint8_t __maybe_unused fm_rev_min, uint32_t exception_mask)
+{
+	bool is_rgmii, is_sgmii, is_qsgmii;
+	int i;
+	uint32_t tmp;
+
+	/* let's start with a soft reset */
+	iowrite32be(MACCFG1_SOFT_RESET, &regs->maccfg1);
+	iowrite32be(0, &regs->maccfg1);
+
+	/*dtsec_id2*/
+	tmp = ioread32be(&regs->tsec_id2);
+
+	/* check RGMII support */
+	if (iface_mode == E_ENET_IF_RGMII || iface_mode == E_ENET_IF_RMII)
+		if (tmp & DTSEC_ID2_INT_REDUCED_OFF)
+			return -EINVAL;
+
+	if (iface_mode == E_ENET_IF_SGMII || iface_mode == E_ENET_IF_MII)
+		if (tmp & DTSEC_ID2_INT_REDUCED_OFF)
+			return -EINVAL;
+
+	/*ECNTRL*/
+
+	is_rgmii = (bool)((iface_mode == E_ENET_IF_RGMII) ? true : false);
+	is_sgmii = (bool)((iface_mode == E_ENET_IF_SGMII) ? true : false);
+	is_qsgmii = (bool)((iface_mode == E_ENET_IF_QSGMII) ? true : false);
+
+	tmp = 0;
+	if (is_rgmii || iface_mode == E_ENET_IF_GMII)
+		tmp |= DTSEC_ECNTRL_GMIIM;
+	if (is_sgmii)
+		tmp |= (DTSEC_ECNTRL_SGMIIM | DTSEC_ECNTRL_TBIM);
+	if (is_qsgmii)
+		tmp |= (DTSEC_ECNTRL_SGMIIM | DTSEC_ECNTRL_TBIM |
+			DTSEC_ECNTRL_QSGMIIM);
+	if (is_rgmii)
+		tmp |= DTSEC_ECNTRL_RPM;
+	if (iface_speed == E_ENET_SPEED_100)
+		tmp |= DTSEC_ECNTRL_R100M;
+
+	iowrite32be(tmp, &regs->ecntrl);
+	/*ECNTRL*/
+
+	/*TCTRL*/
+	tmp = 0;
+	if (cfg->halfdup_on)
+		tmp |= DTSEC_TCTRL_THDF;
+	if (cfg->tx_time_stamp_en)
+		tmp |= DTSEC_TCTRL_TTSE;
+
+	iowrite32be(tmp, &regs->tctrl);
+
+	/*TCTRL*/
+
+	/*PTV*/
+	tmp = 0;
+
+#ifdef FM_SHORT_PAUSE_TIME_ERRATA_DTSEC1
+	if ((fm_rev_maj == 1) && (fm_rev_min == 0))
+		cfg->tx_pause_time += 2;
+#endif /* FM_SHORT_PAUSE_TIME_ERRATA_DTSEC1 */
+
+	if (cfg->tx_pause_time)
+		tmp |= cfg->tx_pause_time;
+	if (cfg->tx_pause_time_extd)
+		tmp |= cfg->tx_pause_time_extd << PTV_PTE_OFST;
+	iowrite32be(tmp, &regs->ptv);
+
+	/*RCTRL*/
+	tmp = 0;
+	tmp |= ((uint32_t)(cfg->rx_prepend & 0x0000001f)) << 16;
+	if (cfg->rx_ctrl_acc)
+		tmp |= RCTRL_CFA;
+	if (cfg->rx_group_hash_exd)
+		tmp |= RCTRL_GHTX;
+	if (cfg->rx_time_stamp_en)
+		tmp |= RCTRL_RTSE;
+	if (cfg->rx_drop_bcast)
+		tmp |= RCTRL_BC_REJ;
+	if (cfg->rx_short_frm)
+		tmp |= RCTRL_RSF;
+	if (cfg->rx_promisc)
+		tmp |= RCTRL_PROM;
+
+	iowrite32be(tmp, &regs->rctrl);
+	/*RCTRL*/
+
+	/*Assign a Phy Address to the TBI (TBIPA).
+	 *Done also in cases where TBI is not selected to avoid conflict with
+	 *the external PHY's Physical address
+	 */
+	iowrite32be(cfg->tbipa, &regs->tbipa);
+
+	/*TMR_CTL*/
+	iowrite32be(0, &regs->tmr_ctrl);
+
+	if (cfg->ptp_tsu_en) {
+		tmp = 0;
+		tmp |= TMR_PEVENT_TSRE;
+		iowrite32be(tmp, &regs->tmr_pevent);
+
+		if (cfg->ptp_exception_en) {
+			tmp = 0;
+			tmp |= TMR_PEMASK_TSREEN;
+			iowrite32be(tmp, &regs->tmr_pemask);
+		}
+	}
+
+	/*MACCFG1*/
+	tmp = 0;
+	if (cfg->loopback)
+		tmp |= MACCFG1_LOOPBACK;
+	if (cfg->rx_flow)
+		tmp |= MACCFG1_RX_FLOW;
+	if (cfg->tx_flow)
+		tmp |= MACCFG1_TX_FLOW;
+	iowrite32be(tmp, &regs->maccfg1);
+
+	/*MACCFG1*/
+
+	/*MACCFG2*/
+	tmp = 0;
+
+	if (iface_speed < E_ENET_SPEED_1000)
+		tmp |= MACCFG2_NIBBLE_MODE;
+	else if (iface_speed == E_ENET_SPEED_1000)
+		tmp |= MACCFG2_BYTE_MODE;
+
+	tmp |= ((uint32_t)cfg->preamble_len & 0x0000000f)
+	    << PREAMBLE_LENGTH_SHIFT;
+
+	if (cfg->rx_preamble)
+		tmp |= MACCFG2_PRE_AM_RX_EN;
+	if (cfg->tx_preamble)
+		tmp |= MACCFG2_PRE_AM_TX_EN;
+	if (cfg->rx_len_check)
+		tmp |= MACCFG2_LENGTH_CHECK;
+	if (cfg->tx_pad_crc)
+		tmp |= MACCFG2_PAD_CRC_EN;
+	if (cfg->tx_crc)
+		tmp |= MACCFG2_CRC_EN;
+	if (!cfg->halfdup_on)
+		tmp |= MACCFG2_FULL_DUPLEX;
+	iowrite32be(tmp, &regs->maccfg2);
+
+	/*MACCFG2*/
+
+	/*IPGIFG*/
+	tmp = (((cfg->non_back_to_back_ipg1 <<
+		 IPGIFG_NON_BACK_TO_BACK_IPG_1_SHIFT)
+		& IPGIFG_NON_BACK_TO_BACK_IPG_1)
+	       | ((cfg->non_back_to_back_ipg2 <<
+		   IPGIFG_NON_BACK_TO_BACK_IPG_2_SHIFT)
+		 & IPGIFG_NON_BACK_TO_BACK_IPG_2)
+	       | ((cfg->min_ifg_enforcement << IPGIFG_MIN_IFG_ENFORCEMENT_SHIFT)
+		 & IPGIFG_MIN_IFG_ENFORCEMENT)
+	       | (cfg->back_to_back_ipg & IPGIFG_BACK_TO_BACK_IPG));
+	iowrite32be(tmp, &regs->ipgifg);
+
+	/*IPGIFG*/
+
+	/*HAFDUP*/
+	tmp = 0;
+
+	if (cfg->halfdup_alt_backoff_en)
+		tmp = (uint32_t)(HAFDUP_ALT_BEB |
+				  ((cfg->halfdup_alt_backoff_val & 0x0000000f)
+				   << HAFDUP_ALTERNATE_BEB_TRUNCATION_SHIFT));
+	if (cfg->halfdup_bp_no_backoff)
+		tmp |= HAFDUP_BP_NO_BACKOFF;
+	if (cfg->halfdup_no_backoff)
+		tmp |= HAFDUP_NO_BACKOFF;
+	if (cfg->halfdup_excess_defer)
+		tmp |= HAFDUP_EXCESS_DEFER;
+	tmp |= ((cfg->halfdup_retransmit << HAFDUP_RETRANSMISSION_MAX_SHIFT)
+		& HAFDUP_RETRANSMISSION_MAX);
+	tmp |= (cfg->halfdup_coll_window & HAFDUP_COLLISION_WINDOW);
+
+	iowrite32be(tmp, &regs->hafdup);
+	/*HAFDUP*/
+
+	/*MAXFRM*/
+	/* Initialize MAXFRM */
+	iowrite32be(cfg->maximum_frame, &regs->maxfrm);
+
+	/*MAXFRM*/
+
+	/*CAM1*/
+	iowrite32be(0xffffffff, &regs->cam1);
+	iowrite32be(0xffffffff, &regs->cam2);
+
+	/*IMASK*/
+	iowrite32be(exception_mask, &regs->imask);
+	/*IMASK*/
+
+	/*IEVENT*/
+	iowrite32be(0xffffffff, &regs->ievent);
+
+	/*MACSTNADDR1/2*/
+
+	tmp = (uint32_t)((macaddr[5] << 24) |
+			  (macaddr[4] << 16) | (macaddr[3] << 8) | macaddr[2]);
+	iowrite32be(tmp, &regs->macstnaddr1);
+
+	tmp = (uint32_t)((macaddr[1] << 24) | (macaddr[0] << 16));
+	iowrite32be(tmp, &regs->macstnaddr2);
+
+	/*MACSTNADDR1/2*/
+
+	/*HASH*/
+	for (i = 0; i < NUM_OF_HASH_REGS; i++) {
+		/* Initialize IADDRx */
+		iowrite32be(0, &regs->igaddr[i]);
+		/* Initialize GADDRx */
+		iowrite32be(0, &regs->gaddr[i]);
+	}
+
+	return 0;
+}
+
+uint16_t fman_dtsec_get_max_frame_len(struct dtsec_regs __iomem *regs)
+{
+	return (uint16_t)ioread32be(&regs->maxfrm);
+}
+
+void fman_dtsec_set_max_frame_len(struct dtsec_regs __iomem *regs,
+				  uint16_t length)
+{
+	iowrite32be(length, &regs->maxfrm);
+}
+
+void fman_dtsec_set_mac_address(struct dtsec_regs __iomem *regs, uint8_t *adr)
+{
+	uint32_t tmp;
+
+	tmp = (uint32_t)((adr[5] << 24) |
+			  (adr[4] << 16) | (adr[3] << 8) | adr[2]);
+	iowrite32be(tmp, &regs->macstnaddr1);
+
+	tmp = (uint32_t)((adr[1] << 24) | (adr[0] << 16));
+	iowrite32be(tmp, &regs->macstnaddr2);
+}
+
+void fman_dtsec_get_mac_address(struct dtsec_regs __iomem *regs,
+				uint8_t *macaddr)
+{
+	uint32_t tmp1, tmp2;
+
+	tmp1 = ioread32be(&regs->macstnaddr1);
+	tmp2 = ioread32be(&regs->macstnaddr2);
+
+	macaddr[0] = (uint8_t)((tmp2 & 0x00ff0000) >> 16);
+	macaddr[1] = (uint8_t)((tmp2 & 0xff000000) >> 24);
+	macaddr[2] = (uint8_t)(tmp1 & 0x000000ff);
+	macaddr[3] = (uint8_t)((tmp1 & 0x0000ff00) >> 8);
+	macaddr[4] = (uint8_t)((tmp1 & 0x00ff0000) >> 16);
+	macaddr[5] = (uint8_t)((tmp1 & 0xff000000) >> 24);
+}
+
+void fman_dtsec_set_bucket(struct dtsec_regs __iomem *regs, int bucket,
+			   bool enable)
+{
+	int reg_idx = (bucket >> 5) & 0xf;
+	int bit_idx = bucket & 0x1f;
+	uint32_t bit_mask = 0x80000000 >> bit_idx;
+	uint32_t __iomem *reg;
+
+	if (reg_idx > 7)
+		reg = &regs->gaddr[reg_idx - 8];
+	else
+		reg = &regs->igaddr[reg_idx];
+
+	if (enable)
+		iowrite32be(ioread32be(reg) | bit_mask, reg);
+	else
+		iowrite32be(ioread32be(reg) & (~bit_mask), reg);
+}
+
+int fman_dtsec_adjust_link(struct dtsec_regs __iomem *regs,
+			   enum enet_interface __maybe_unused iface_mode,
+			   enum enet_speed speed, bool full_dx)
+{
+	uint32_t tmp;
+
+	if ((speed == E_ENET_SPEED_1000) && !full_dx)
+		return -EINVAL;
+
+	tmp = ioread32be(&regs->maccfg2);
+	if (!full_dx)
+		tmp &= ~MACCFG2_FULL_DUPLEX;
+	else
+		tmp |= MACCFG2_FULL_DUPLEX;
+
+	tmp &= ~(MACCFG2_NIBBLE_MODE | MACCFG2_BYTE_MODE);
+	if (speed < E_ENET_SPEED_1000)
+		tmp |= MACCFG2_NIBBLE_MODE;
+	else if (speed == E_ENET_SPEED_1000)
+		tmp |= MACCFG2_BYTE_MODE;
+	iowrite32be(tmp, &regs->maccfg2);
+
+	tmp = ioread32be(&regs->ecntrl);
+	if (speed == E_ENET_SPEED_100)
+		tmp |= DTSEC_ECNTRL_R100M;
+	else
+		tmp &= ~DTSEC_ECNTRL_R100M;
+	iowrite32be(tmp, &regs->ecntrl);
+
+	return 0;
+}
+
+void fman_dtsec_set_uc_promisc(struct dtsec_regs __iomem *regs, bool enable)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->rctrl);
+
+	if (enable)
+		tmp |= RCTRL_UPROM;
+	else
+		tmp &= ~RCTRL_UPROM;
+
+	iowrite32be(tmp, &regs->rctrl);
+}
+
+void fman_dtsec_set_mc_promisc(struct dtsec_regs __iomem *regs, bool enable)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->rctrl);
+
+	if (enable)
+		tmp |= RCTRL_MPROM;
+	else
+		tmp &= ~RCTRL_MPROM;
+
+	iowrite32be(tmp, &regs->rctrl);
+}
+
+void fman_dtsec_enable(struct dtsec_regs __iomem *regs, bool apply_rx,
+		       bool apply_tx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->maccfg1);
+
+	if (apply_rx)
+		tmp |= MACCFG1_RX_EN;
+
+	if (apply_tx)
+		tmp |= MACCFG1_TX_EN;
+
+	iowrite32be(tmp, &regs->maccfg1);
+}
+
+void fman_dtsec_disable(struct dtsec_regs __iomem *regs, bool apply_rx,
+			bool apply_tx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->maccfg1);
+
+	if (apply_rx)
+		tmp &= ~MACCFG1_RX_EN;
+
+	if (apply_tx)
+		tmp &= ~MACCFG1_TX_EN;
+
+	iowrite32be(tmp, &regs->maccfg1);
+}
+
+void fman_dtsec_set_tx_pause_frames(struct dtsec_regs __iomem *regs,
+				    uint16_t time)
+{
+	uint32_t ptv = 0;
+
+	/* fixme: don't enable tx pause for half-duplex */
+
+	if (time) {
+		ptv = ioread32be(&regs->ptv);
+		ptv &= 0xffff0000;
+		ptv |= time & 0x0000ffff;
+		iowrite32be(ptv, &regs->ptv);
+
+		/* trigger the transmission of a flow-control pause frame */
+		iowrite32be(ioread32be(&regs->maccfg1) | MACCFG1_TX_FLOW,
+			    &regs->maccfg1);
+	} else
+		iowrite32be(ioread32be(&regs->maccfg1) & ~MACCFG1_TX_FLOW,
+			    &regs->maccfg1);
+}
+
+void fman_dtsec_handle_rx_pause(struct dtsec_regs __iomem *regs, bool en)
+{
+	uint32_t tmp;
+
+	/* todo: check if mac is set to full-duplex */
+
+	tmp = ioread32be(&regs->maccfg1);
+	if (en)
+		tmp |= MACCFG1_RX_FLOW;
+	else
+		tmp &= ~MACCFG1_RX_FLOW;
+	iowrite32be(tmp, &regs->maccfg1);
+}
+
+uint32_t fman_dtsec_get_rctrl(struct dtsec_regs __iomem *regs)
+{
+	return ioread32be(&regs->rctrl);
+}
+
+uint32_t fman_dtsec_get_revision(struct dtsec_regs __iomem *regs)
+{
+	return ioread32be(&regs->tsec_id);
+}
+
+uint32_t fman_dtsec_get_event(struct dtsec_regs __iomem *regs,
+			      uint32_t ev_mask)
+{
+	return ioread32be(&regs->ievent) & ev_mask;
+}
+
+void fman_dtsec_ack_event(struct dtsec_regs __iomem *regs, uint32_t ev_mask)
+{
+	iowrite32be(ev_mask, &regs->ievent);
+}
+
+uint32_t fman_dtsec_get_interrupt_mask(struct dtsec_regs __iomem *regs)
+{
+	return ioread32be(&regs->imask);
+}
+
+uint32_t fman_dtsec_check_and_clear_tmr_event(struct dtsec_regs __iomem *regs)
+{
+	uint32_t event;
+
+	event = ioread32be(&regs->tmr_pevent);
+	event &= ioread32be(&regs->tmr_pemask);
+
+	if (event)
+		iowrite32be(event, &regs->tmr_pevent);
+	return event;
+}
+
+void fman_dtsec_enable_tmr_interrupt(struct dtsec_regs __iomem *regs)
+{
+	iowrite32be(ioread32be(&regs->tmr_pemask) | TMR_PEMASK_TSREEN,
+		    &regs->tmr_pemask);
+}
+
+void fman_dtsec_disable_tmr_interrupt(struct dtsec_regs __iomem *regs)
+{
+	iowrite32be(ioread32be(&regs->tmr_pemask) & ~TMR_PEMASK_TSREEN,
+		    &regs->tmr_pemask);
+}
+
+void fman_dtsec_enable_interrupt(struct dtsec_regs __iomem *regs,
+				 uint32_t ev_mask)
+{
+	iowrite32be(ioread32be(&regs->imask) | ev_mask, &regs->imask);
+}
+
+void fman_dtsec_disable_interrupt(struct dtsec_regs __iomem *regs,
+				  uint32_t ev_mask)
+{
+	iowrite32be(ioread32be(&regs->imask) & ~ev_mask, &regs->imask);
+}
diff --git a/drivers/net/ethernet/freescale/fman/mac/fman_dtsec_mii_acc.c b/drivers/net/ethernet/freescale/fman/mac/fman_dtsec_mii_acc.c
new file mode 100644
index 0000000..c393938
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/fman_dtsec_mii_acc.c
@@ -0,0 +1,168 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "common/general.h"
+#include "fsl_fman_dtsec_mii_acc.h"
+
+/*dtsec_mii_get_div() - calculates the value of the dtsec mii divider
+ *@dtsec_freq:		dtsec clock frequency (in Mhz)
+ *This function calculates the dtsec mii clock divider that determines
+ *the MII MDC clock. MII MDC clock will be set to work in the range
+ *of 1.5 to 2.5Mhz
+ *The output of this function is the value of MIIMCFG[MgmtClk] which
+ *implicitly determines the divider value.
+ *Note: the dTSEC system clock is equal to 1/2 of the FMan clock.
+ *The table below which reflects dtsec_mii_get_div() functionality
+ *shows the relations among dtsec_freq, MgmtClk, actual divider
+ *and the MII frequency:
+ *dtsec freq   MgmtClk	   div	      MII freq Mhz
+ *[0.....80]	 1	(1/4)(1/8)    [0   to 2.5]
+ *[81...120]	 2	(1/6)(1/8)    [1.6 to 2.5]
+ *[121..160]	 3	(1/8)(1/8)    [1.8 to 2.5]
+ *[161..200]	 4	(1/10)(1/8)   [2.0 to 2.5]
+ *[201..280]	 5	(1/14)(1/8)   [1.8 to 2.5]
+ *[281..400]	 6	(1/20)(1/8)   [1.1 to 2.5]
+ *[401..560]	 7	(1/28)(1/8)   [1.8 to 2.5]
+ *[560..frq]	 7	(1/28)(1/8)   [frq/224]
+ *Returns: the MIIMCFG[MgmtClk] appropriate value
+ */
+
+static uint8_t dtsec_mii_get_div(uint16_t dtsec_freq)
+{
+	uint16_t mgmt_clk;
+
+	if (dtsec_freq < 80)
+		mgmt_clk = 1;
+	else if (dtsec_freq < 120)
+		mgmt_clk = 2;
+	else if (dtsec_freq < 160)
+		mgmt_clk = 3;
+	else if (dtsec_freq < 200)
+		mgmt_clk = 4;
+	else if (dtsec_freq < 280)
+		mgmt_clk = 5;
+	else if (dtsec_freq < 400)
+		mgmt_clk = 6;
+	else
+		mgmt_clk = 7;
+
+	return (uint8_t)mgmt_clk;
+}
+
+void fman_dtsec_mii_reset(struct dtsec_mii_reg __iomem *regs)
+{
+	/* Reset the management interface */
+	iowrite32be(ioread32be(&regs->miimcfg) | MIIMCFG_RESET_MGMT,
+		    &regs->miimcfg);
+	iowrite32be(ioread32be(&regs->miimcfg) & ~MIIMCFG_RESET_MGMT,
+		    &regs->miimcfg);
+}
+
+int fman_dtsec_mii_write_reg(struct dtsec_mii_reg __iomem *regs, uint8_t addr,
+			     uint8_t reg, uint16_t data, uint16_t dtsec_freq)
+{
+	uint32_t tmp;
+
+	/* Setup the MII Mgmt clock speed */
+	iowrite32be((uint32_t)dtsec_mii_get_div(dtsec_freq), &regs->miimcfg);
+	/* Memory barrier */
+	wmb();
+
+	/* Stop the MII management read cycle */
+	iowrite32be(0, &regs->miimcom);
+	/* Dummy read to make sure MIIMCOM is written */
+	tmp = ioread32be(&regs->miimcom);
+	/* Memory barrier */
+	wmb();
+
+	/* Setting up MII Management Address Register */
+	tmp = (uint32_t)((addr << MIIMADD_PHY_ADDR_SHIFT) | reg);
+	iowrite32be(tmp, &regs->miimadd);
+	/* Memory barrier */
+	wmb();
+
+	/* Setting up MII Management Control Register with data */
+	iowrite32be((uint32_t)data, &regs->miimcon);
+	/* Dummy read to make sure MIIMCON is written */
+	tmp = ioread32be(&regs->miimcon);
+	/* Memory barrier */
+	wmb();
+
+	/* Wait until MII management write is complete */
+	/* todo: a timeout could be useful here */
+	while ((ioread32be(&regs->miimind)) & MIIMIND_BUSY)
+		; /* busy wait */
+
+	return 0;
+}
+
+int fman_dtsec_mii_read_reg(struct dtsec_mii_reg __iomem *regs, uint8_t addr,
+			    uint8_t reg, uint16_t *data, uint16_t dtsec_freq)
+{
+	uint32_t tmp;
+
+	/* Setup the MII Mgmt clock speed */
+	iowrite32be((uint32_t)dtsec_mii_get_div(dtsec_freq), &regs->miimcfg);
+	/* Memory barrier */
+	wmb();
+
+	/* Setting up the MII Management Address Register */
+	tmp = (uint32_t)((addr << MIIMADD_PHY_ADDR_SHIFT) | reg);
+	iowrite32be(tmp, &regs->miimadd);
+	/* Memory barrier */
+	wmb();
+
+	/* Perform an MII management read cycle */
+	iowrite32be(MIIMCOM_READ_CYCLE, &regs->miimcom);
+	/* Dummy read to make sure MIIMCOM is written */
+	tmp = ioread32be(&regs->miimcom);
+	/* Memory barrier */
+	wmb();
+
+	/* Wait until MII management read is complete */
+	/* todo: a timeout could be useful here */
+	while ((ioread32be(&regs->miimind)) & MIIMIND_BUSY)
+		; /* busy wait */
+
+	/* Read MII management status  */
+	*data = (uint16_t)ioread32be(&regs->miimstat);
+	/* Memory barrier */
+	wmb();
+
+	iowrite32be(0, &regs->miimcom);
+	/* Dummy read to make sure MIIMCOM is written */
+	tmp = ioread32be(&regs->miimcom);
+
+	if (*data == 0xffff)
+		return -ENXIO;
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/freescale/fman/mac/fman_memac.c b/drivers/net/ethernet/freescale/fman/mac/fman_memac.c
new file mode 100644
index 0000000..e0bac5a
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/fman_memac.c
@@ -0,0 +1,365 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "fsl_fman_memac.h"
+
+uint32_t fman_memac_get_event(struct memac_regs __iomem *regs, uint32_t ev_mask)
+{
+	return ioread32be(&regs->ievent) & ev_mask;
+}
+
+uint32_t fman_memac_get_interrupt_mask(struct memac_regs __iomem *regs)
+{
+	return ioread32be(&regs->imask);
+}
+
+void fman_memac_ack_event(struct memac_regs __iomem *regs, uint32_t ev_mask)
+{
+	iowrite32be(ev_mask, &regs->ievent);
+}
+
+void fman_memac_set_promiscuous(struct memac_regs __iomem *regs, bool val)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+
+	if (val)
+		tmp |= CMD_CFG_PROMIS_EN;
+	else
+		tmp &= ~CMD_CFG_PROMIS_EN;
+
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_memac_clear_addr_in_paddr(struct memac_regs __iomem *regs,
+				    uint8_t paddr_num)
+{
+	if (paddr_num == 0) {
+		iowrite32be(0, &regs->mac_addr0.mac_addr_l);
+		iowrite32be(0, &regs->mac_addr0.mac_addr_u);
+	} else {
+		iowrite32be(0x0, &regs->mac_addr[paddr_num - 1].mac_addr_l);
+		iowrite32be(0x0, &regs->mac_addr[paddr_num - 1].mac_addr_u);
+	}
+}
+
+void fman_memac_add_addr_in_paddr(struct memac_regs __iomem *regs,
+				  uint8_t *adr, uint8_t paddr_num)
+{
+	uint32_t tmp0, tmp1;
+
+	tmp0 = (uint32_t)(adr[0] | adr[1] << 8 | adr[2] << 16 | adr[3] << 24);
+	tmp1 = (uint32_t)(adr[4] | adr[5] << 8);
+
+	if (paddr_num == 0) {
+		iowrite32be(tmp0, &regs->mac_addr0.mac_addr_l);
+		iowrite32be(tmp1, &regs->mac_addr0.mac_addr_u);
+	} else {
+		iowrite32be(tmp0, &regs->mac_addr[paddr_num - 1].mac_addr_l);
+		iowrite32be(tmp1, &regs->mac_addr[paddr_num - 1].mac_addr_u);
+	}
+}
+
+void fman_memac_enable(struct memac_regs __iomem *regs, bool apply_rx,
+		       bool apply_tx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+
+	if (apply_rx)
+		tmp |= CMD_CFG_RX_EN;
+
+	if (apply_tx)
+		tmp |= CMD_CFG_TX_EN;
+
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_memac_disable(struct memac_regs __iomem *regs, bool apply_rx,
+			bool apply_tx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+
+	if (apply_rx)
+		tmp &= ~CMD_CFG_RX_EN;
+
+	if (apply_tx)
+		tmp &= ~CMD_CFG_TX_EN;
+
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_memac_reset(struct memac_regs __iomem *regs)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+
+	tmp |= CMD_CFG_SW_RESET;
+
+	iowrite32be(tmp, &regs->command_config);
+
+	while (ioread32be(&regs->command_config) & CMD_CFG_SW_RESET)
+		;
+}
+
+int fman_memac_init(struct memac_regs __iomem *regs,
+		    struct memac_cfg *cfg,
+		    enum enet_interface enet_interface,
+		    enum enet_speed enet_speed,
+		    bool slow_10g_if,
+		    uint32_t exceptions)
+{
+	uint32_t tmp;
+
+	/* Config */
+	tmp = 0;
+	if (cfg->wan_mode_enable)
+		tmp |= CMD_CFG_WAN_MODE;
+	if (cfg->promiscuous_mode_enable)
+		tmp |= CMD_CFG_PROMIS_EN;
+	if (cfg->pause_forward_enable)
+		tmp |= CMD_CFG_PAUSE_FWD;
+	if (cfg->pause_ignore)
+		tmp |= CMD_CFG_PAUSE_IGNORE;
+	if (cfg->tx_addr_ins_enable)
+		tmp |= CMD_CFG_TX_ADDR_INS;
+	if (cfg->loopback_enable)
+		tmp |= CMD_CFG_LOOPBACK_EN;
+	if (cfg->cmd_frame_enable)
+		tmp |= CMD_CFG_CNT_FRM_EN;
+	if (cfg->send_idle_enable)
+		tmp |= CMD_CFG_SEND_IDLE;
+	if (cfg->no_length_check_enable)
+		tmp |= CMD_CFG_NO_LEN_CHK;
+	if (cfg->rx_sfd_any)
+		tmp |= CMD_CFG_SFD_ANY;
+	if (cfg->pad_enable)
+		tmp |= CMD_CFG_TX_PAD_EN;
+	if (cfg->wake_on_lan)
+		tmp |= CMD_CFG_MG;
+
+	tmp |= CMD_CFG_CRC_FWD;
+
+	iowrite32be(tmp, &regs->command_config);
+
+	/* Max Frame Length */
+	iowrite32be((uint32_t)cfg->max_frame_length, &regs->maxfrm);
+
+	/* Pause Time */
+	iowrite32be((uint32_t)cfg->pause_quanta, &regs->pause_quanta[0]);
+	iowrite32be((uint32_t)0, &regs->pause_thresh[0]);
+
+	/* IF_MODE */
+	tmp = 0;
+	switch (enet_interface) {
+	case E_ENET_IF_XGMII:
+	case E_ENET_IF_XFI:
+		tmp |= IF_MODE_XGMII;
+		break;
+	default:
+		tmp |= IF_MODE_GMII;
+		if (enet_interface == E_ENET_IF_RGMII && !cfg->loopback_enable)
+			tmp |= IF_MODE_RGMII | IF_MODE_RGMII_AUTO;
+	}
+	iowrite32be(tmp, &regs->if_mode);
+
+	/* TX_FIFO_SECTIONS */
+	tmp = 0;
+	if (enet_interface == E_ENET_IF_XGMII ||
+	    enet_interface == E_ENET_IF_XFI) {
+		if (slow_10g_if) {
+			tmp |= (TX_FIFO_SECTIONS_TX_AVAIL_SLOW_10G |
+				TX_FIFO_SECTIONS_TX_EMPTY_DEFAULT_10G);
+		} else {
+			tmp |= (TX_FIFO_SECTIONS_TX_AVAIL_10G |
+				TX_FIFO_SECTIONS_TX_EMPTY_DEFAULT_10G);
+		}
+	} else {
+		tmp |= (TX_FIFO_SECTIONS_TX_AVAIL_1G |
+			TX_FIFO_SECTIONS_TX_EMPTY_DEFAULT_1G);
+	}
+	iowrite32be(tmp, &regs->tx_fifo_sections);
+
+	/* clear all pending events and set-up interrupts */
+	fman_memac_ack_event(regs, 0xffffffff);
+	fman_memac_set_exception(regs, exceptions, true);
+
+	return 0;
+}
+
+void fman_memac_set_exception(struct memac_regs __iomem *regs, uint32_t val,
+			      bool enable)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->imask);
+	if (enable)
+		tmp |= val;
+	else
+		tmp &= ~val;
+
+	iowrite32be(tmp, &regs->imask);
+}
+
+void fman_memac_set_hash_table(struct memac_regs __iomem *regs, uint32_t val)
+{
+	iowrite32be(val, &regs->hashtable_ctrl);
+}
+
+uint16_t fman_memac_get_max_frame_len(struct memac_regs __iomem *regs)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->maxfrm);
+
+	return (uint16_t)tmp;
+}
+
+void fman_memac_set_tx_pause_frames(struct memac_regs __iomem *regs,
+				    uint8_t priority,
+				    uint16_t pause_time, uint16_t thresh_time)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->tx_fifo_sections);
+
+	GET_TX_EMPTY_DEFAULT_VALUE(tmp);
+	iowrite32be(tmp, &regs->tx_fifo_sections);
+
+	tmp = ioread32be(&regs->command_config);
+	tmp &= ~CMD_CFG_PFC_MODE;
+	priority = 0;
+
+	iowrite32be(tmp, &regs->command_config);
+
+	tmp = ioread32be(&regs->pause_quanta[priority / 2]);
+	if (priority % 2)
+		tmp &= 0x0000FFFF;
+	else
+		tmp &= 0xFFFF0000;
+	tmp |= ((uint32_t)pause_time << (16 * (priority % 2)));
+	iowrite32be(tmp, &regs->pause_quanta[priority / 2]);
+
+	tmp = ioread32be(&regs->pause_thresh[priority / 2]);
+	if (priority % 2)
+		tmp &= 0x0000FFFF;
+	else
+		tmp &= 0xFFFF0000;
+	tmp |= ((uint32_t)thresh_time << (16 * (priority % 2)));
+	iowrite32be(tmp, &regs->pause_thresh[priority / 2]);
+}
+
+void fman_memac_set_rx_ignore_pause_frames(struct memac_regs __iomem *regs,
+					   bool enable)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+	if (enable)
+		tmp |= CMD_CFG_PAUSE_IGNORE;
+	else
+		tmp &= ~CMD_CFG_PAUSE_IGNORE;
+
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_memac_adjust_link(struct memac_regs __iomem *regs,
+			    enum enet_interface iface_mode,
+			    enum enet_speed speed, bool full_dx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->if_mode);
+
+	if (full_dx)
+		tmp &= ~IF_MODE_HD;
+	else
+		tmp |= IF_MODE_HD;
+
+	if (iface_mode == E_ENET_IF_RGMII) {
+		/* Configure RGMII in manual mode */
+		tmp &= ~IF_MODE_RGMII_AUTO;
+		tmp &= ~IF_MODE_RGMII_SP_MASK;
+
+		if (full_dx)
+			tmp |= IF_MODE_RGMII_FD;
+		else
+			tmp &= ~IF_MODE_RGMII_FD;
+
+		switch (speed) {
+		case E_ENET_SPEED_1000:
+			tmp |= IF_MODE_RGMII_1000;
+			break;
+		case E_ENET_SPEED_100:
+			tmp |= IF_MODE_RGMII_100;
+			break;
+		case E_ENET_SPEED_10:
+			tmp |= IF_MODE_RGMII_10;
+			break;
+		default:
+			break;
+		}
+	}
+
+	iowrite32be(tmp, &regs->if_mode);
+}
+
+void fman_memac_defconfig(struct memac_cfg *cfg)
+{
+	cfg->reset_on_init = false;
+	cfg->wan_mode_enable = false;
+	cfg->promiscuous_mode_enable = false;
+	cfg->pause_forward_enable = false;
+	cfg->pause_ignore = false;
+	cfg->tx_addr_ins_enable = false;
+	cfg->loopback_enable = false;
+	cfg->cmd_frame_enable = false;
+	cfg->rx_error_discard = false;
+	cfg->send_idle_enable = false;
+	cfg->no_length_check_enable = true;
+	cfg->lgth_check_nostdr = false;
+	cfg->time_stamp_enable = false;
+	cfg->tx_ipg_length = DEFAULT_TX_IPG_LENGTH;
+	cfg->max_frame_length = DEFAULT_FRAME_LENGTH;
+	cfg->pause_quanta = DEFAULT_PAUSE_QUANTA;
+	cfg->pad_enable = true;
+	cfg->phy_tx_ena_on = false;
+	cfg->rx_sfd_any = false;
+	cfg->rx_pbl_fwd = false;
+	cfg->tx_pbl_fwd = false;
+	cfg->debug_mode = false;
+	cfg->wake_on_lan = false;
+}
diff --git a/drivers/net/ethernet/freescale/fman/mac/fman_memac_mii_acc.c b/drivers/net/ethernet/freescale/fman/mac/fman_memac_mii_acc.c
new file mode 100644
index 0000000..7addd6d
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/fman_memac_mii_acc.c
@@ -0,0 +1,217 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "fsl_fman_memac_mii_acc.h"
+
+static void write_phy_reg_10g(struct memac_mii_access_mem_map __iomem *mii_regs,
+			      uint8_t phy_addr, uint8_t reg, uint16_t data)
+{
+	uint32_t tmp_reg;
+
+	tmp_reg = ioread32be(&mii_regs->mdio_cfg);
+	/* Leave only MDIO_CLK_DIV bits set on */
+	tmp_reg &= MDIO_CFG_CLK_DIV_MASK;
+	/* Set maximum MDIO_HOLD value to allow phy to see
+	 * change of data signal
+	 **/
+	tmp_reg |= MDIO_CFG_HOLD_MASK;
+	/* Add 10G interface mode */
+	tmp_reg |= MDIO_CFG_ENC45;
+	iowrite32be(tmp_reg, &mii_regs->mdio_cfg);
+
+	/* Wait for command completion */
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Specify phy and register to be accessed */
+	iowrite32be(phy_addr, &mii_regs->mdio_ctrl);
+	iowrite32be(reg, &mii_regs->mdio_addr);
+	/* memory barrier */
+	wmb();
+
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Write data */
+	iowrite32be(data, &mii_regs->mdio_data);
+	/* memory barrier */
+	wmb();
+
+	/* Wait for write transaction end */
+	while ((ioread32be(&mii_regs->mdio_data)) & MDIO_DATA_BSY)
+		udelay(1);
+}
+
+static uint32_t read_phy_reg_10g(struct memac_mii_access_mem_map __iomem
+				 *mii_regs, uint8_t phy_addr, uint8_t reg,
+				 uint16_t *data)
+{
+	uint32_t tmp_reg;
+
+	tmp_reg = ioread32be(&mii_regs->mdio_cfg);
+	/* Leave only MDIO_CLK_DIV bits set on */
+	tmp_reg &= MDIO_CFG_CLK_DIV_MASK;
+	/* Set maximum MDIO_HOLD value to allow phy to see
+	 * change of data signal
+	 **/
+	tmp_reg |= MDIO_CFG_HOLD_MASK;
+	/* Add 10G interface mode */
+	tmp_reg |= MDIO_CFG_ENC45;
+	iowrite32be(tmp_reg, &mii_regs->mdio_cfg);
+
+	/* Wait for command completion */
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Specify phy and register to be accessed */
+	iowrite32be(phy_addr, &mii_regs->mdio_ctrl);
+	iowrite32be(reg, &mii_regs->mdio_addr);
+	/* memory barrier */
+	wmb();
+
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Read cycle */
+	tmp_reg = phy_addr;
+	tmp_reg |= MDIO_CTL_READ;
+	iowrite32be(tmp_reg, &mii_regs->mdio_ctrl);
+	/* memory barrier */
+	wmb();
+
+	/* Wait for data to be available */
+	while ((ioread32be(&mii_regs->mdio_data)) & MDIO_DATA_BSY)
+		udelay(1);
+
+	*data = (uint16_t)ioread32be(&mii_regs->mdio_data);
+
+	/* Check if there was an error */
+	return ioread32be(&mii_regs->mdio_cfg);
+}
+
+static void write_phy_reg_1g(struct memac_mii_access_mem_map __iomem *mii_regs,
+			     uint8_t phy_addr, uint8_t reg, uint16_t data)
+{
+	uint32_t tmp_reg;
+
+	/* Leave only MDIO_CLK_DIV and MDIO_HOLD bits set on */
+	tmp_reg = ioread32be(&mii_regs->mdio_cfg);
+	tmp_reg &= (MDIO_CFG_CLK_DIV_MASK | MDIO_CFG_HOLD_MASK);
+	iowrite32be(tmp_reg, &mii_regs->mdio_cfg);
+
+	/* Wait for command completion */
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Write transaction */
+	tmp_reg = (phy_addr << MDIO_CTL_PHY_ADDR_SHIFT);
+	tmp_reg |= reg;
+	iowrite32be(tmp_reg, &mii_regs->mdio_ctrl);
+
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	iowrite32be(data, &mii_regs->mdio_data);
+
+	/* memory barrier */
+	wmb();
+
+	/* Wait for write transaction to end */
+	while ((ioread32be(&mii_regs->mdio_data)) & MDIO_DATA_BSY)
+		udelay(1);
+}
+
+static uint32_t read_phy_reg_1g(struct memac_mii_access_mem_map __iomem
+				*mii_regs, uint8_t phy_addr, uint8_t reg,
+				uint16_t *data)
+{
+	uint32_t tmp_reg;
+
+	/* Leave only MDIO_CLK_DIV and MDIO_HOLD bits set on */
+	tmp_reg = ioread32be(&mii_regs->mdio_cfg);
+	tmp_reg &= (MDIO_CFG_CLK_DIV_MASK | MDIO_CFG_HOLD_MASK);
+	iowrite32be(tmp_reg, &mii_regs->mdio_cfg);
+
+	/* Wait for command completion */
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Read transaction */
+	tmp_reg = (phy_addr << MDIO_CTL_PHY_ADDR_SHIFT);
+	tmp_reg |= reg;
+	tmp_reg |= MDIO_CTL_READ;
+	iowrite32be(tmp_reg, &mii_regs->mdio_ctrl);
+
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Wait for data to be available */
+	while ((ioread32be(&mii_regs->mdio_data)) & MDIO_DATA_BSY)
+		udelay(1);
+
+	*data = (uint16_t)ioread32be(&mii_regs->mdio_data);
+
+	/* Check error */
+	return ioread32be(&mii_regs->mdio_cfg);
+}
+
+int fman_memac_mii_write_phy_reg(struct memac_mii_access_mem_map __iomem
+				 *mii_regs, uint8_t phy_addr, uint8_t reg,
+				 uint16_t data, enum enet_speed enet_speed)
+{
+	/* Figure out interface type - 10G vs 1G.
+	 * In 10G interface both phy_addr and devAddr present.
+	 **/
+	if (enet_speed == E_ENET_SPEED_10000)
+		write_phy_reg_10g(mii_regs, phy_addr, reg, data);
+	else
+		write_phy_reg_1g(mii_regs, phy_addr, reg, data);
+
+	return 0;
+}
+
+int fman_memac_mii_read_phy_reg(struct memac_mii_access_mem_map __iomem
+				*mii_regs, uint8_t phy_addr, uint8_t reg,
+				uint16_t *data, enum enet_speed enet_speed)
+{
+	uint32_t ans;
+	/* Figure out interface type - 10G vs 1G.
+	 * In 10G interface both phy_addr and devAddr present.
+	 **/
+	if (enet_speed == E_ENET_SPEED_10000)
+		ans = read_phy_reg_10g(mii_regs, phy_addr, reg, data);
+	else
+		ans = read_phy_reg_1g(mii_regs, phy_addr, reg, data);
+
+	if (ans & MDIO_CFG_READ_ERR)
+		return -EINVAL;
+	return 0;
+}
diff --git a/drivers/net/ethernet/freescale/fman/mac/fman_tgec.c b/drivers/net/ethernet/freescale/fman/mac/fman_tgec.c
new file mode 100644
index 0000000..11bcc1a
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/fman_tgec.c
@@ -0,0 +1,217 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "fsl_fman_tgec.h"
+
+void fman_tgec_set_mac_address(struct tgec_regs __iomem *regs, uint8_t *adr)
+{
+	uint32_t tmp0, tmp1;
+
+	tmp0 = (uint32_t)(adr[0] | adr[1] << 8 | adr[2] << 16 | adr[3] << 24);
+	tmp1 = (uint32_t)(adr[4] | adr[5] << 8);
+	iowrite32be(tmp0, &regs->mac_addr_0);
+	iowrite32be(tmp1, &regs->mac_addr_1);
+}
+
+void fman_tgec_enable(struct tgec_regs __iomem *regs, bool apply_rx,
+		      bool apply_tx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+	if (apply_rx)
+		tmp |= CMD_CFG_RX_EN;
+	if (apply_tx)
+		tmp |= CMD_CFG_TX_EN;
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_tgec_disable(struct tgec_regs __iomem *regs, bool apply_rx,
+		       bool apply_tx)
+{
+	uint32_t tmp_reg_32;
+
+	tmp_reg_32 = ioread32be(&regs->command_config);
+	if (apply_rx)
+		tmp_reg_32 &= ~CMD_CFG_RX_EN;
+	if (apply_tx)
+		tmp_reg_32 &= ~CMD_CFG_TX_EN;
+	iowrite32be(tmp_reg_32, &regs->command_config);
+}
+
+void fman_tgec_set_promiscuous(struct tgec_regs __iomem *regs, bool val)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+	if (val)
+		tmp |= CMD_CFG_PROMIS_EN;
+	else
+		tmp &= ~CMD_CFG_PROMIS_EN;
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_tgec_set_hash_table(struct tgec_regs __iomem *regs, uint32_t value)
+{
+	iowrite32be(value, &regs->hashtable_ctrl);
+}
+
+void fman_tgec_set_tx_pause_frames(struct tgec_regs __iomem *regs,
+				   uint16_t pause_time)
+{
+	iowrite32be((uint32_t)pause_time, &regs->pause_quant);
+}
+
+void fman_tgec_set_rx_ignore_pause_frames(struct tgec_regs __iomem *regs,
+					  bool en)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+	if (en)
+		tmp |= CMD_CFG_PAUSE_IGNORE;
+	else
+		tmp &= ~CMD_CFG_PAUSE_IGNORE;
+	iowrite32be(tmp, &regs->command_config);
+}
+
+uint32_t fman_tgec_get_event(struct tgec_regs __iomem *regs, uint32_t ev_mask)
+{
+	return ioread32be(&regs->ievent) & ev_mask;
+}
+
+void fman_tgec_ack_event(struct tgec_regs __iomem *regs, uint32_t ev_mask)
+{
+	iowrite32be(ev_mask, &regs->ievent);
+}
+
+uint32_t fman_tgec_get_interrupt_mask(struct tgec_regs __iomem *regs)
+{
+	return ioread32be(&regs->imask);
+}
+
+uint32_t fman_tgec_get_revision(struct tgec_regs __iomem *regs)
+{
+	return ioread32be(&regs->tgec_id);
+}
+
+void fman_tgec_enable_interrupt(struct tgec_regs __iomem *regs,
+				uint32_t ev_mask)
+{
+	iowrite32be(ioread32be(&regs->imask) | ev_mask, &regs->imask);
+}
+
+void fman_tgec_disable_interrupt(struct tgec_regs __iomem *regs,
+				 uint32_t ev_mask)
+{
+	iowrite32be(ioread32be(&regs->imask) & ~ev_mask, &regs->imask);
+}
+
+uint16_t fman_tgec_get_max_frame_len(struct tgec_regs __iomem *regs)
+{
+	return (uint16_t)ioread32be(&regs->maxfrm);
+}
+
+void fman_tgec_defconfig(struct tgec_cfg *cfg)
+{
+	cfg->wan_mode_enable = DEFAULT_WAN_MODE_ENABLE;
+	cfg->promiscuous_mode_enable = DEFAULT_PROMISCUOUS_MODE_ENABLE;
+	cfg->pause_forward_enable = DEFAULT_PAUSE_FORWARD_ENABLE;
+	cfg->pause_ignore = DEFAULT_PAUSE_IGNORE;
+	cfg->tx_addr_ins_enable = DEFAULT_TX_ADDR_INS_ENABLE;
+	cfg->loopback_enable = DEFAULT_LOOPBACK_ENABLE;
+	cfg->cmd_frame_enable = DEFAULT_CMD_FRAME_ENABLE;
+	cfg->rx_error_discard = DEFAULT_RX_ERROR_DISCARD;
+	cfg->send_idle_enable = DEFAULT_SEND_IDLE_ENABLE;
+	cfg->no_length_check_enable = DEFAULT_NO_LENGTH_CHECK_ENABLE;
+	cfg->lgth_check_nostdr = DEFAULT_LGTH_CHECK_NOSTDR;
+	cfg->time_stamp_enable = DEFAULT_TIME_STAMP_ENABLE;
+	cfg->tx_ipg_length = DEFAULT_TX_IPG_LENGTH;
+	cfg->max_frame_length = DEFAULT_MAX_FRAME_LENGTH;
+	cfg->pause_quant = DEFAULT_PAUSE_QUANT;
+#ifdef FM_TX_ECC_FRMS_ERRATA_10GMAC_A004
+	cfg->skip_fman11_workaround = false;
+#endif /* FM_TX_ECC_FRMS_ERRATA_10GMAC_A004 */
+}
+
+int fman_tgec_init(struct tgec_regs __iomem *regs, struct tgec_cfg *cfg,
+		   uint32_t exception_mask)
+{
+	uint32_t tmp;
+
+	/* Config */
+	tmp = 0x40;		/* CRC forward */
+	if (cfg->wan_mode_enable)
+		tmp |= CMD_CFG_WAN_MODE;
+	if (cfg->promiscuous_mode_enable)
+		tmp |= CMD_CFG_PROMIS_EN;
+	if (cfg->pause_forward_enable)
+		tmp |= CMD_CFG_PAUSE_FWD;
+	if (cfg->pause_ignore)
+		tmp |= CMD_CFG_PAUSE_IGNORE;
+	if (cfg->tx_addr_ins_enable)
+		tmp |= CMD_CFG_TX_ADDR_INS;
+	if (cfg->loopback_enable)
+		tmp |= CMD_CFG_LOOPBACK_EN;
+	if (cfg->cmd_frame_enable)
+		tmp |= CMD_CFG_CMD_FRM_EN;
+	if (cfg->rx_error_discard)
+		tmp |= CMD_CFG_RX_ER_DISC;
+	if (cfg->send_idle_enable)
+		tmp |= CMD_CFG_SEND_IDLE;
+	if (cfg->no_length_check_enable)
+		tmp |= CMD_CFG_NO_LEN_CHK;
+	if (cfg->time_stamp_enable)
+		tmp |= CMD_CFG_EN_TIMESTAMP;
+	iowrite32be(tmp, &regs->command_config);
+
+	/* Max Frame Length */
+	iowrite32be((uint32_t)cfg->max_frame_length, &regs->maxfrm);
+	/* Pause Time */
+	iowrite32be(cfg->pause_quant, &regs->pause_quant);
+
+	/* clear all pending events and set-up interrupts */
+	fman_tgec_ack_event(regs, 0xffffffff);
+	fman_tgec_enable_interrupt(regs, exception_mask);
+
+	return 0;
+}
+
+void fman_tgec_set_erratum_tx_fifo_corruption_10gmac_a007(struct tgec_regs
+							  __iomem *regs)
+{
+	uint32_t tmp;
+
+	/* restore the default tx ipg Length */
+	tmp = (ioread32be(&regs->tx_ipg_len) & ~TGEC_TX_IPG_LENGTH_MASK) | 12;
+
+	iowrite32be(tmp, &regs->tx_ipg_len);
+}
-- 
1.7.11.7
