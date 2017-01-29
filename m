From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH stable v1 09/13] net: ethernet: aquantia: Atlantic hardware abstraction layer
Date: Sat, 28 Jan 2017 21:09:09 -0800
Message-ID: <efa9a7a3f0c7275e0a41007499c7b357be34405a.1485665881.git.vomlehn@texas.net>
References: <cover.1485665881.git.vomlehn@texas.net>
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda1.aus1.datafoundry.com ([209.99.124.132]:38105 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751843AbdA2Fp0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 00:45:26 -0500
In-Reply-To: <cover.1485665881.git.vomlehn@texas.net>
In-Reply-To: <cover.1485665881.git.vomlehn@texas.net>
References: <cover.1485665881.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <vomlehn@texas.net>

Add common functions for Atlantic hardware abstraction layer.

Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>
---
 .../aquantia/atlantic/hw_atl/hw_atl_utils.c        | 570 +++++++++++++++++++++
 .../aquantia/atlantic/hw_atl/hw_atl_utils.h        | 210 ++++++++
 2 files changed, 780 insertions(+)
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h

diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
new file mode 100644
index 0000000..8d6d8f5
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
@@ -0,0 +1,570 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File hw_atl_utils.c: Definition of common functions for Atlantic hardware
+ * abstraction layer.
+ */
+
+#include "../aq_hw.h"
+#include "../aq_hw_utils.h"
+#include "../aq_pci_func.h"
+#include "../aq_ring.h"
+#include "../aq_vec.h"
+#include "hw_atl_utils.h"
+#include "hw_atl_llh.h"
+
+#include <linux/random.h>
+
+#define HW_ATL_UCP_0X370_REG    0x0370U
+
+#define HW_ATL_FW_SM_RAM        0x2U
+#define HW_ATL_MPI_CONTROL_ADR  0x0368U
+#define HW_ATL_MPI_STATE_ADR    0x036CU
+
+#define HW_ATL_MPI_STATE_MSK    0x00FFU
+#define HW_ATL_MPI_STATE_SHIFT  0U
+#define HW_ATL_MPI_SPEED_MSK    0xFFFFU
+#define HW_ATL_MPI_SPEED_SHIFT  16U
+
+static int hw_atl_utils_fw_downld_dwords(struct aq_hw_s *self, u32 a,
+					 u32 *p, u32 cnt)
+{
+	int err = 0;
+
+	AQ_HW_WAIT_FOR(reg_glb_cpu_sem_get(self,
+					   HW_ATL_FW_SM_RAM) == 1U,
+					   1U, 10000U);
+
+	if (err < 0) {
+		bool is_locked;
+
+		reg_glb_cpu_sem_set(self, 1U, HW_ATL_FW_SM_RAM);
+		is_locked = reg_glb_cpu_sem_get(self, HW_ATL_FW_SM_RAM);
+		if (!is_locked) {
+			err = -ETIME;
+			goto err_exit;
+		}
+	}
+
+	aq_hw_write_reg(self, 0x00000208U, a);
+
+	for (++cnt; --cnt;) {
+		u32 i = 0U;
+
+		aq_hw_write_reg(self, 0x00000200U, 0x00008000U);
+
+		for (i = 1024U;
+			(0x100U & aq_hw_read_reg(self, 0x00000200U)) && --i;) {
+		}
+
+		*(p++) = aq_hw_read_reg(self, 0x0000020CU);
+	}
+
+	reg_glb_cpu_sem_set(self, 1U, HW_ATL_FW_SM_RAM);
+
+err_exit:
+	return err;
+}
+
+static int hw_atl_utils_fw_upload_dwords(struct aq_hw_s *self, u32 a, u32 *p,
+					 u32 cnt)
+{
+	int err = 0;
+	bool is_locked;
+
+	is_locked = reg_glb_cpu_sem_get(self, HW_ATL_FW_SM_RAM);
+	if (!is_locked) {
+		err = -ETIME;
+		goto err_exit;
+	}
+
+	aq_hw_write_reg(self, 0x00000208U, a);
+
+	for (++cnt; --cnt;) {
+		u32 i = 0U;
+
+		aq_hw_write_reg(self, 0x0000020CU, *(p++));
+		aq_hw_write_reg(self, 0x00000200U, 0xC000U);
+
+		for (i = 1024U;
+			(0x100U & aq_hw_read_reg(self, 0x00000200U)) && --i;) {
+		}
+	}
+
+	reg_glb_cpu_sem_set(self, 1U, HW_ATL_FW_SM_RAM);
+
+err_exit:
+	return err;
+}
+
+static int hw_atl_utils_ver_match(u32 ver_expected, u32 ver_actual)
+{
+	int err = 0;
+	const u32 dw_major_mask = 0xff000000U;
+	const u32 dw_minor_mask = 0x00ffffffU;
+
+	err = (dw_major_mask & (ver_expected ^ ver_actual)) ? -EOPNOTSUPP : 0;
+	if (err < 0)
+		goto err_exit;
+	err = ((dw_minor_mask & ver_expected) > (dw_minor_mask & ver_actual)) ?
+		-EOPNOTSUPP : 0;
+err_exit:
+	return err;
+}
+
+static int hw_atl_utils_init_ucp(struct aq_hw_s *self,
+				 struct aq_hw_caps_s *aq_hw_caps)
+{
+	int err = 0;
+
+	if (!aq_hw_read_reg(self, 0x370U)) {
+		unsigned int rnd = 0U;
+		unsigned int ucp_0x370 = 0U;
+
+		get_random_bytes(&rnd, sizeof(unsigned int));
+
+		ucp_0x370 = 0x02020202U | (0xFEFEFEFEU & rnd);
+		aq_hw_write_reg(self, HW_ATL_UCP_0X370_REG, ucp_0x370);
+	}
+
+	reg_glb_cpu_scratch_scp_set(self, 0x00000000U, 25U);
+
+	/* check 10 times by 1ms */
+	AQ_HW_WAIT_FOR(0U != (PHAL_ATLANTIC_A0->mbox_addr =
+			aq_hw_read_reg(self, 0x360U)), 1000U, 10U);
+
+	err = hw_atl_utils_ver_match(aq_hw_caps->fw_ver_expected,
+				     aq_hw_read_reg(self, 0x18U));
+	return err;
+}
+
+#define HW_ATL_RPC_CONTROL_ADR 0x0338U
+#define HW_ATL_RPC_STATE_ADR   0x033CU
+
+struct aq_hw_atl_utils_fw_rpc_tid_s {
+	union {
+		u32 val;
+		struct {
+			u16 tid;
+			u16 len;
+		};
+	};
+};
+
+#define hw_atl_utils_fw_rpc_init(_H_) hw_atl_utils_fw_rpc_wait(_H_, NULL)
+
+static int hw_atl_utils_fw_rpc_call(struct aq_hw_s *self, unsigned int rpc_size)
+{
+	int err = 0;
+	struct aq_hw_atl_utils_fw_rpc_tid_s sw;
+
+	if (!IS_CHIP_FEATURE(MIPS)) {
+		err = -1;
+		goto err_exit;
+	}
+	err = hw_atl_utils_fw_upload_dwords(self, PHAL_ATLANTIC->rpc_addr,
+					    (u32 *)(void *)&PHAL_ATLANTIC->rpc,
+					    (rpc_size + sizeof(u32) -
+					    sizeof(u8)) / sizeof(u32));
+	if (err < 0)
+		goto err_exit;
+
+	sw.tid = 0xFFFFU & (++PHAL_ATLANTIC->rpc_tid);
+	sw.len = (u16)rpc_size;
+	aq_hw_write_reg(self, HW_ATL_RPC_CONTROL_ADR, sw.val);
+
+err_exit:
+	return err;
+}
+
+static int hw_atl_utils_fw_rpc_wait(struct aq_hw_s *self,
+				    struct hw_aq_atl_utils_fw_rpc **rpc)
+{
+	int err = 0;
+	struct aq_hw_atl_utils_fw_rpc_tid_s sw;
+	struct aq_hw_atl_utils_fw_rpc_tid_s fw;
+
+	do {
+		sw.val = aq_hw_read_reg(self, HW_ATL_RPC_CONTROL_ADR);
+
+		PHAL_ATLANTIC->rpc_tid = sw.tid;
+
+		AQ_HW_WAIT_FOR(sw.tid ==
+				(fw.val =
+				aq_hw_read_reg(self, HW_ATL_RPC_STATE_ADR),
+				fw.tid), 1000U, 100U);
+		if (err < 0)
+			goto err_exit;
+
+		if (fw.len == 0xFFFFU) {
+			err = hw_atl_utils_fw_rpc_call(self, sw.len);
+			if (err < 0)
+				goto err_exit;
+		}
+	} while (sw.tid != fw.tid || 0xFFFFU == fw.len);
+	if (err < 0)
+		goto err_exit;
+
+	if (rpc) {
+		if (fw.len) {
+			err =
+			hw_atl_utils_fw_downld_dwords(self,
+						      PHAL_ATLANTIC->rpc_addr,
+						      (u32 *)(void *)
+						      &PHAL_ATLANTIC->rpc,
+						      (fw.len + sizeof(u32) -
+						      sizeof(u8)) /
+						      sizeof(u32));
+			if (err < 0)
+				goto err_exit;
+		}
+
+		*rpc = &PHAL_ATLANTIC->rpc;
+	}
+
+err_exit:
+	return err;
+}
+
+static int hw_atl_utils_mpi_create(struct aq_hw_s *self,
+				   struct aq_hw_caps_s *aq_hw_caps)
+{
+	int err = 0;
+
+	err = hw_atl_utils_init_ucp(self, aq_hw_caps);
+	if (err < 0)
+		goto err_exit;
+
+	err = hw_atl_utils_fw_rpc_init(self);
+	if (err < 0)
+		goto err_exit;
+
+err_exit:
+	return err;
+}
+
+void hw_atl_utils_mpi_read_stats(struct aq_hw_s *self,
+				 struct hw_aq_atl_utils_mbox *pmbox)
+{
+	int err = 0;
+
+	err = hw_atl_utils_fw_downld_dwords(self,
+					    PHAL_ATLANTIC->mbox_addr,
+					    (u32 *)(void *)pmbox,
+					    sizeof(*pmbox) / sizeof(u32));
+	if (err < 0)
+		goto err_exit;
+
+	if (pmbox != &PHAL_ATLANTIC->mbox)
+		memcpy(pmbox, &PHAL_ATLANTIC->mbox, sizeof(*pmbox));
+
+	if (IS_CHIP_FEATURE(REVISION_A0)) {
+		unsigned int mtu = self->aq_nic_cfg ?
+					self->aq_nic_cfg->mtu : 1514U;
+		pmbox->stats.ubrc = pmbox->stats.uprc * mtu;
+		pmbox->stats.ubtc = pmbox->stats.uptc * mtu;
+		pmbox->stats.dpc = atomic_read(&PHAL_ATLANTIC_A0->dpc);
+	} else {
+		pmbox->stats.dpc = reg_rx_dma_stat_counter7get(self);
+	}
+
+err_exit:;
+}
+
+int hw_atl_utils_mpi_set_speed(struct aq_hw_s *self, u32 speed,
+			       enum hal_atl_utils_fw_state_e state)
+{
+	u32 ucp_0x368 = 0;
+
+	ucp_0x368 = (speed << HW_ATL_MPI_SPEED_SHIFT) | state;
+	aq_hw_write_reg(self, HW_ATL_MPI_CONTROL_ADR, ucp_0x368);
+
+	return 0;
+}
+
+void hw_atl_utils_mpi_set(struct aq_hw_s *self,
+			  enum hal_atl_utils_fw_state_e state, u32 speed)
+{
+	int err = 0;
+	u32 transaction_id = 0;
+
+	if (state == MPI_RESET) {
+		hw_atl_utils_mpi_read_stats(self, &PHAL_ATLANTIC->mbox);
+
+		transaction_id = PHAL_ATLANTIC->mbox.transaction_id;
+
+		AQ_HW_WAIT_FOR(transaction_id !=
+				(hw_atl_utils_mpi_read_stats
+					(self, &PHAL_ATLANTIC->mbox),
+					PHAL_ATLANTIC->mbox.transaction_id),
+					1000U, 100U);
+		if (err < 0)
+			goto err_exit;
+	}
+
+	err = hw_atl_utils_mpi_set_speed(self, speed, state);
+
+err_exit:;
+}
+
+int hw_atl_utils_mpi_get_link_status(struct aq_hw_s *self,
+				     struct aq_hw_link_status_s *link_status)
+{
+	u32 cp0x036C = aq_hw_read_reg(self, HW_ATL_MPI_STATE_ADR);
+	u32 link_speed_mask = cp0x036C >> HW_ATL_MPI_SPEED_SHIFT;
+
+	if (!link_speed_mask) {
+		link_status->mbps = 0U;
+	} else {
+		switch (link_speed_mask) {
+		case HAL_ATLANTIC_RATE_10G:
+			link_status->mbps = 10000U;
+			break;
+
+		case HAL_ATLANTIC_RATE_5G:
+		case HAL_ATLANTIC_RATE_5GSR:
+			link_status->mbps = 5000U;
+			break;
+
+		case HAL_ATLANTIC_RATE_2GS:
+			link_status->mbps = 2500U;
+			break;
+
+		case HAL_ATLANTIC_RATE_1G:
+			link_status->mbps = 1000U;
+			break;
+
+		case HAL_ATLANTIC_RATE_100M:
+			link_status->mbps = 100U;
+			break;
+
+		default:
+			link_status->mbps = 0U;
+			break;
+		}
+	}
+
+	return 0;
+}
+
+int hw_atl_utils_get_mac_permanent(struct aq_hw_s *self,
+				   struct aq_hw_caps_s *aq_hw_caps,
+				   u8 *mac)
+{
+	int err = 0;
+	u32 h = 0U;
+	u32 l = 0U;
+	u32 mac_addr[2];
+
+	self->mmio = aq_pci_func_get_mmio(self->aq_pci_func);
+
+	hw_atl_utils_hw_chip_features_init(self,
+					   &PHAL_ATLANTIC_A0->chip_features);
+
+	err = hw_atl_utils_mpi_create(self, aq_hw_caps);
+	if (err < 0)
+		goto err_exit;
+
+	if (!aq_hw_read_reg(self, HW_ATL_UCP_0X370_REG)) {
+		unsigned int rnd = 0;
+		unsigned int ucp_0x370 = 0;
+
+		get_random_bytes(&rnd, sizeof(unsigned int));
+
+		ucp_0x370 = 0x02020202 | (0xFEFEFEFE & rnd);
+		aq_hw_write_reg(self, HW_ATL_UCP_0X370_REG, ucp_0x370);
+	}
+
+	err = hw_atl_utils_fw_downld_dwords(self,
+					    aq_hw_read_reg(self, 0x00000374U) +
+					    (40U * 4U),
+					    mac_addr,
+					    AQ_DIMOF(mac_addr));
+	if (err < 0) {
+		mac_addr[0] = 0U;
+		mac_addr[1] = 0U;
+		err = 0;
+	} else {
+		mac_addr[0] = __swab32(mac_addr[0]);
+		mac_addr[1] = __swab32(mac_addr[1]);
+	}
+
+	ether_addr_copy(mac, (u8 *)mac_addr);
+
+	if ((mac[0] & 0x01U) || ((mac[0] | mac[1] | mac[2]) == 0x00U)) {
+		/* chip revision */
+		l = 0xE3000000U
+			| (0xFFFFU & aq_hw_read_reg(self, HW_ATL_UCP_0X370_REG))
+			| (0x00 << 16);
+		h = 0x8001300EU;
+
+		mac[5] = (u8)(0xFFU & l);
+		l >>= 8;
+		mac[4] = (u8)(0xFFU & l);
+		l >>= 8;
+		mac[3] = (u8)(0xFFU & l);
+		l >>= 8;
+		mac[2] = (u8)(0xFFU & l);
+		mac[1] = (u8)(0xFFU & h);
+		h >>= 8;
+		mac[0] = (u8)(0xFFU & h);
+	}
+
+err_exit:
+	return err;
+}
+
+unsigned int hw_atl_utils_mbps_2_speed_index(unsigned int mbps)
+{
+	unsigned int ret = 0U;
+
+	switch (mbps) {
+	case 100U:
+		ret = 5U;
+		break;
+
+	case 1000U:
+		ret = 4U;
+		break;
+
+	case 2500U:
+		ret = 3U;
+		break;
+
+	case 5000U:
+		ret = 1U;
+		break;
+
+	case 10000U:
+		ret = 0U;
+		break;
+
+	default:
+		break;
+	}
+	return ret;
+}
+
+void hw_atl_utils_hw_chip_features_init(struct aq_hw_s *self, u32 *p)
+{
+	u32 chip_features = 0U;
+	u32 val = reg_glb_mif_id_get(self);
+	u32 mif_rev = val & 0xFFU;
+
+	if ((3U & mif_rev) == 1U) {
+		chip_features |=
+			HAL_ATLANTIC_UTILS_CHIP_REVISION_A0 |
+			HAL_ATLANTIC_UTILS_CHIP_MPI_AQ |
+			HAL_ATLANTIC_UTILS_CHIP_MIPS;
+	} else if ((3U & mif_rev) == 2U) {
+		chip_features |=
+			HAL_ATLANTIC_UTILS_CHIP_REVISION_B0 |
+			HAL_ATLANTIC_UTILS_CHIP_MPI_AQ |
+			HAL_ATLANTIC_UTILS_CHIP_MIPS |
+			HAL_ATLANTIC_UTILS_CHIP_TPO2 |
+			HAL_ATLANTIC_UTILS_CHIP_RPF2;
+	}
+
+	*p = chip_features;
+}
+
+int hw_atl_utils_hw_deinit(struct aq_hw_s *self)
+{
+	hw_atl_utils_mpi_set(self, MPI_DEINIT, 0x0U);
+	return 0;
+}
+
+int hw_atl_utils_hw_set_power(struct aq_hw_s *self,
+			      unsigned int power_state)
+{
+	hw_atl_utils_mpi_set(self, MPI_POWER, 0x0U);
+	return 0;
+}
+
+int hw_atl_utils_get_hw_stats(struct aq_hw_s *self,
+			      u64 *data, unsigned int *p_count)
+{
+	struct hw_atl_stats_s *stats = NULL;
+	int i = 0;
+
+	hw_atl_utils_mpi_read_stats(self, &PHAL_ATLANTIC->mbox);
+
+	stats = &PHAL_ATLANTIC->mbox.stats;
+
+	data[i] = stats->uprc + stats->mprc + stats->bprc;
+	data[++i] = stats->uprc;
+	data[++i] = stats->mprc;
+	data[++i] = stats->bprc;
+	data[++i] = stats->erpt;
+	data[++i] = stats->uptc + stats->mptc + stats->bptc;
+	data[++i] = stats->uptc;
+	data[++i] = stats->mptc;
+	data[++i] = stats->bptc;
+	data[++i] = stats->ubrc;
+	data[++i] = stats->ubtc;
+	data[++i] = stats->mbrc;
+	data[++i] = stats->mbtc;
+	data[++i] = stats->bbrc;
+	data[++i] = stats->bbtc;
+	data[++i] = stats->ubrc + stats->mbrc + stats->bbrc;
+	data[++i] = stats->ubtc + stats->mbtc + stats->bbtc;
+	data[++i] = stats_rx_dma_good_pkt_counterlsw_get(self);
+	data[++i] = stats_tx_dma_good_pkt_counterlsw_get(self);
+	data[++i] = stats_rx_dma_good_octet_counterlsw_get(self);
+	data[++i] = stats_tx_dma_good_octet_counterlsw_get(self);
+	data[++i] = stats->dpc;
+
+	if (p_count)
+		*p_count = ++i;
+
+	return 0;
+}
+
+static const u32 hw_atl_utils_hw_mac_regs[] = {
+	0x00005580U, 0x00005590U, 0x000055B0U, 0x000055B4U,
+	0x000055C0U, 0x00005B00U, 0x00005B04U, 0x00005B08U,
+	0x00005B0CU, 0x00005B10U, 0x00005B14U, 0x00005B18U,
+	0x00005B1CU, 0x00005B20U, 0x00005B24U, 0x00005B28U,
+	0x00005B2CU, 0x00005B30U, 0x00005B34U, 0x00005B38U,
+	0x00005B3CU, 0x00005B40U, 0x00005B44U, 0x00005B48U,
+	0x00005B4CU, 0x00005B50U, 0x00005B54U, 0x00005B58U,
+	0x00005B5CU, 0x00005B60U, 0x00005B64U, 0x00005B68U,
+	0x00005B6CU, 0x00005B70U, 0x00005B74U, 0x00005B78U,
+	0x00005B7CU, 0x00007C00U, 0x00007C04U, 0x00007C08U,
+	0x00007C0CU, 0x00007C10U, 0x00007C14U, 0x00007C18U,
+	0x00007C1CU, 0x00007C20U, 0x00007C40U, 0x00007C44U,
+	0x00007C48U, 0x00007C4CU, 0x00007C50U, 0x00007C54U,
+	0x00007C58U, 0x00007C5CU, 0x00007C60U, 0x00007C80U,
+	0x00007C84U, 0x00007C88U, 0x00007C8CU, 0x00007C90U,
+	0x00007C94U, 0x00007C98U, 0x00007C9CU, 0x00007CA0U,
+	0x00007CC0U, 0x00007CC4U, 0x00007CC8U, 0x00007CCCU,
+	0x00007CD0U, 0x00007CD4U, 0x00007CD8U, 0x00007CDCU,
+	0x00007CE0U, 0x00000300U, 0x00000304U, 0x00000308U,
+	0x0000030cU, 0x00000310U, 0x00000314U, 0x00000318U,
+	0x0000031cU, 0x00000360U, 0x00000364U, 0x00000368U,
+	0x0000036cU, 0x00000370U, 0x00000374U, 0x00006900U,
+};
+
+int hw_atl_utils_hw_get_regs(struct aq_hw_s *self,
+			     struct aq_hw_caps_s *aq_hw_caps,
+			     u32 *regs_buff)
+{
+	unsigned int i = 0U;
+
+	for (i = 0; i < aq_hw_caps->mac_regs_count; i++)
+		regs_buff[i] = aq_hw_read_reg(self,
+			hw_atl_utils_hw_mac_regs[i]);
+	return 0;
+}
+
+int hw_atl_utils_get_fw_version(struct aq_hw_s *self, u32 *fw_version)
+{
+	*fw_version = aq_hw_read_reg(self, 0x18U);
+	return 0;
+}
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
new file mode 100644
index 0000000..b8e3d88
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
@@ -0,0 +1,210 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File hw_atl_utils.h: Declaration of common functions for Atlantic hardware
+ * abstraction layer.
+ */
+
+#ifndef HW_ATL_UTILS_H
+#define HW_ATL_UTILS_H
+
+#include "../aq_common.h"
+
+#define HW_ATL_FLUSH() { (void)aq_hw_read_reg(self, 0x10); }
+
+struct __packed hw_atl_stats_s {
+	u32 uprc;
+	u32 mprc;
+	u32 bprc;
+	u32 erpt;
+	u32 uptc;
+	u32 mptc;
+	u32 bptc;
+	u32 erpr;
+	u32 mbtc;
+	u32 bbtc;
+	u32 mbrc;
+	u32 bbrc;
+	u32 ubrc;
+	u32 ubtc;
+	u32 dpc;
+};
+
+union __packed ip_addr {
+	struct {
+		u8 addr[16];
+	} v6;
+	struct {
+		u8 padding[12];
+		u8 addr[4];
+	} v4;
+};
+
+struct __packed hw_aq_atl_utils_fw_rpc {
+	u32 msg_id;
+
+	union {
+		struct {
+			u32 pong;
+		} msg_ping;
+
+		struct {
+			u8 mac_addr[6];
+			u32 ip_addr_cnt;
+
+			struct {
+				union ip_addr addr;
+				union ip_addr mask;
+			} ip[1];
+		} msg_arp;
+
+		struct {
+			u32 len;
+			u8 packet[1514U];
+		} msg_inject;
+
+		struct {
+			u32 priority;
+			u32 wol_packet_type;
+			u16 friendly_name_len;
+			u16 friendly_name[65];
+			u32 pattern_id;
+			u32 next_wol_pattern_offset;
+
+			union {
+				struct {
+					u32 flags;
+					u8 ipv4_source_address[4];
+					u8 ipv4_dest_address[4];
+					u16 tcp_source_port_number;
+					u16 tcp_dest_port_number;
+				} ipv4_tcp_syn_parameters;
+
+				struct {
+					u32 flags;
+					u8 ipv6_source_address[16];
+					u8 ipv6_dest_address[16];
+					u16 tcp_source_port_number;
+					u16 tcp_dest_port_number;
+				} ipv6_tcp_syn_parameters;
+
+				struct {
+					u32 flags;
+				} eapol_request_id_message_parameters;
+
+				struct {
+					u32 flags;
+					u32 mask_offset;
+					u32 mask_size;
+					u32 pattern_offset;
+					u32 pattern_size;
+				} wol_bit_map_pattern;
+			} wol_pattern;
+		} msg_wol;
+
+		struct {
+			u32 is_wake_on_link_down;
+			u32 is_wake_on_link_up;
+		} msg_wolink;
+	};
+};
+
+struct __packed hw_aq_atl_utils_mbox {
+	u32 version;
+	u32 transaction_id;
+	int error;
+	struct hw_atl_stats_s stats;
+};
+
+struct __packed hw_atl_s {
+	struct aq_hw_s base;
+	struct hw_aq_atl_utils_mbox mbox;
+	u64 speed;
+	u32 itr_tx;
+	u32 itr_rx;
+	unsigned int chip_features;
+	u32 fw_ver_actual;
+	atomic_t dpc;
+	u32 mbox_addr;
+	u32 rpc_addr;
+	u32 rpc_tid;
+	struct hw_aq_atl_utils_fw_rpc rpc;
+};
+
+#define SELF ((struct hw_atl_s *)self)
+
+#define PHAL_ATLANTIC ((struct hw_atl_s *)((void *)(self)))
+#define PHAL_ATLANTIC_A0 ((struct hw_atl_s *)((void *)(self)))
+#define PHAL_ATLANTIC_B0 ((struct hw_atl_s *)((void *)(self)))
+
+#define HAL_ATLANTIC_UTILS_CHIP_MIPS         0x00000001U
+#define HAL_ATLANTIC_UTILS_CHIP_TPO2         0x00000002U
+#define HAL_ATLANTIC_UTILS_CHIP_RPF2         0x00000004U
+#define HAL_ATLANTIC_UTILS_CHIP_MPI_AQ       0x00000010U
+#define HAL_ATLANTIC_UTILS_CHIP_REVISION_A0  0x01000000U
+#define HAL_ATLANTIC_UTILS_CHIP_REVISION_B0  0x02000000U
+
+#define IS_CHIP_FEATURE(_F_) (HAL_ATLANTIC_UTILS_CHIP_##_F_ & \
+				PHAL_ATLANTIC->chip_features)
+
+enum hal_atl_utils_fw_state_e {
+	MPI_DEINIT = 0,
+	MPI_RESET = 1,
+	MPI_INIT = 2,
+	MPI_POWER = 4,
+};
+
+#define HAL_ATLANTIC_RATE_10G        BIT(0)
+#define HAL_ATLANTIC_RATE_5G         BIT(1)
+#define HAL_ATLANTIC_RATE_5GSR       BIT(2)
+#define HAL_ATLANTIC_RATE_2GS        BIT(3)
+#define HAL_ATLANTIC_RATE_1G         BIT(4)
+#define HAL_ATLANTIC_RATE_100M       BIT(5)
+#define HAL_ATLANTIC_RATE_INVALID    BIT(6)
+
+void hw_atl_utils_hw_chip_features_init(struct aq_hw_s *self, u32 *p);
+
+void hw_atl_utils_mpi_read_stats(struct aq_hw_s *self,
+				 struct hw_aq_atl_utils_mbox *pmbox);
+
+void hw_atl_utils_mpi_set(struct aq_hw_s *self,
+			  enum hal_atl_utils_fw_state_e state,
+			  u32 speed);
+
+int hw_atl_utils_mpi_set_speed(struct aq_hw_s *self, u32 speed,
+			       enum hal_atl_utils_fw_state_e state);
+
+int hw_atl_utils_mpi_get_link_status(struct aq_hw_s *self,
+				     struct aq_hw_link_status_s *link_status);
+
+int hw_atl_utils_get_mac_permanent(struct aq_hw_s *self,
+				   struct aq_hw_caps_s *aq_hw_caps,
+				   u8 *mac);
+
+unsigned int hw_atl_utils_mbps_2_speed_index(unsigned int mbps);
+
+int hw_atl_utils_hw_get_regs(struct aq_hw_s *self,
+			     struct aq_hw_caps_s *aq_hw_caps,
+			     u32 *regs_buff);
+
+int hw_atl_utils_hw_get_settings(struct aq_hw_s *self,
+				 struct ethtool_cmd *cmd);
+
+int hw_atl_utils_hw_set_power(struct aq_hw_s *self,
+			      unsigned int power_state);
+
+int hw_atl_utils_hw_deinit(struct aq_hw_s *self);
+
+int hw_atl_utils_get_fw_version(struct aq_hw_s *self, u32 *fw_version);
+
+int hw_atl_utils_get_hw_stats(struct aq_hw_s *self,
+			      u64 *data,
+			      unsigned int *p_count);
+
+#endif /* HW_ATL_UTILS_H */
-- 
2.9.3
