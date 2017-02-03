From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 2/8] soc: alpine: add udma helpers
Date: Fri,  3 Feb 2017 19:12:10 +0100
Message-ID: <20170203181216.30214-3-antoine.tenart@free-electrons.com>
References: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        tsahee@annapurnalabs.com, rshitrit@annapurnalabs.com,
        saeed@annapurnalabs.com, barak@annapurnalabs.com,
        talz@annapurnalabs.com, thomas.petazzoni@free-electrons.com,
        arnd@arndb.de
To: netdev@vger.kernel.org, davem@davemloft.net,
        linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:36464 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750863AbdBCSPI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 13:15:08 -0500
In-Reply-To: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One or more DMA controllers (called Universal DMA) are exposed as PCI
endpoints for some units connected to the I/O fabric. The DMA controller
registers are mapped in BARs.

These helpers help drivers supporting units connected to the Alpine I/O
fabric, to configure and use the exposed UDMA.

The Alpine UDMA is a full-duplex DMA consisting of a Tx (memory to
stream -m2s-) and an Rx (stream to memory -s2m-) DMA engines. Multiple
queues are available per DMA, with each a description and a completion
ring.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/soc/Kconfig                            |   1 +
 drivers/soc/Makefile                           |   1 +
 drivers/soc/alpine/Kconfig                     |  11 +
 drivers/soc/alpine/Makefile                    |   1 +
 drivers/soc/alpine/udma/Makefile               |   1 +
 drivers/soc/alpine/udma/al_udma_config.c       | 140 +++++++
 drivers/soc/alpine/udma/al_udma_iofic.c        | 110 ++++++
 drivers/soc/alpine/udma/al_udma_main.c         | 245 ++++++++++++
 drivers/soc/alpine/udma/al_udma_queue.c        | 232 ++++++++++++
 include/linux/soc/alpine/al_hw_udma.h          | 499 +++++++++++++++++++++++++
 include/linux/soc/alpine/al_hw_udma_config.h   |  75 ++++
 include/linux/soc/alpine/al_hw_udma_iofic.h    | 199 ++++++++++
 include/linux/soc/alpine/al_hw_udma_regs.h     | 134 +++++++
 include/linux/soc/alpine/al_hw_udma_regs_m2s.h | 413 ++++++++++++++++++++
 include/linux/soc/alpine/al_hw_udma_regs_s2m.h | 294 +++++++++++++++
 15 files changed, 2356 insertions(+)
 create mode 100644 drivers/soc/alpine/Kconfig
 create mode 100644 drivers/soc/alpine/Makefile
 create mode 100644 drivers/soc/alpine/udma/Makefile
 create mode 100644 drivers/soc/alpine/udma/al_udma_config.c
 create mode 100644 drivers/soc/alpine/udma/al_udma_iofic.c
 create mode 100644 drivers/soc/alpine/udma/al_udma_main.c
 create mode 100644 drivers/soc/alpine/udma/al_udma_queue.c
 create mode 100644 include/linux/soc/alpine/al_hw_udma.h
 create mode 100644 include/linux/soc/alpine/al_hw_udma_config.h
 create mode 100644 include/linux/soc/alpine/al_hw_udma_iofic.h
 create mode 100644 include/linux/soc/alpine/al_hw_udma_regs.h
 create mode 100644 include/linux/soc/alpine/al_hw_udma_regs_m2s.h
 create mode 100644 include/linux/soc/alpine/al_hw_udma_regs_s2m.h

diff --git a/drivers/soc/Kconfig b/drivers/soc/Kconfig
index f31bceb69c0d..010b4c60cd1a 100644
--- a/drivers/soc/Kconfig
+++ b/drivers/soc/Kconfig
@@ -1,5 +1,6 @@
 menu "SOC (System On Chip) specific Drivers"
 
+source "drivers/soc/alpine/Kconfig"
 source "drivers/soc/bcm/Kconfig"
 source "drivers/soc/fsl/Kconfig"
 source "drivers/soc/mediatek/Kconfig"
diff --git a/drivers/soc/Makefile b/drivers/soc/Makefile
index 50c23d0bd457..8385e0108630 100644
--- a/drivers/soc/Makefile
+++ b/drivers/soc/Makefile
@@ -2,6 +2,7 @@
 # Makefile for the Linux Kernel SOC specific device drivers.
 #
 
+obj-$(CONFIG_ARCH_ALPINE)	+= alpine/
 obj-y				+= bcm/
 obj-$(CONFIG_ARCH_DOVE)		+= dove/
 obj-$(CONFIG_MACH_DOVE)		+= dove/
diff --git a/drivers/soc/alpine/Kconfig b/drivers/soc/alpine/Kconfig
new file mode 100644
index 000000000000..d09df30ff723
--- /dev/null
+++ b/drivers/soc/alpine/Kconfig
@@ -0,0 +1,11 @@
+if ARCH_ALPINE
+
+config ALPINE_UDMA
+	bool "Alpine UDMA engine"
+	default ARCH_ALPINE
+	help
+	  Say y here to enable the Alpine Universal DMA support. This UDMA
+	  interfaces with the i/o fabric through a PCI endpoint for each
+	  i/o fabric bus.
+
+endif
diff --git a/drivers/soc/alpine/Makefile b/drivers/soc/alpine/Makefile
new file mode 100644
index 000000000000..0d3769b342a8
--- /dev/null
+++ b/drivers/soc/alpine/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_ALPINE_UDMA)	+= udma/
diff --git a/drivers/soc/alpine/udma/Makefile b/drivers/soc/alpine/udma/Makefile
new file mode 100644
index 000000000000..b5915454a3f3
--- /dev/null
+++ b/drivers/soc/alpine/udma/Makefile
@@ -0,0 +1 @@
+obj-y	+= al_udma_main.o al_udma_iofic.o al_udma_config.o al_udma_queue.o
diff --git a/drivers/soc/alpine/udma/al_udma_config.c b/drivers/soc/alpine/udma/al_udma_config.c
new file mode 100644
index 000000000000..2471195fd7bd
--- /dev/null
+++ b/drivers/soc/alpine/udma/al_udma_config.c
@@ -0,0 +1,140 @@
+/*
+ * Copyright (C) 2017, Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include <linux/device.h>
+#include <linux/soc/alpine/al_hw_udma_config.h>
+#include <linux/soc/alpine/al_hw_udma_regs.h>
+
+/* M2S packet len configuration */
+int al_udma_m2s_packet_size_cfg_set(struct al_udma *udma,
+				    struct al_udma_m2s_pkt_len_conf *conf)
+{
+	u32 reg = readl(&udma->udma_regs->m2s.m2s.cfg_len);
+	u32 max_supported_size = UDMA_M2S_CFG_LEN_MAX_PKT_SIZE_MASK;
+
+	WARN_ON(udma->type != UDMA_TX);
+
+	if (conf->encode_64k_as_zero)
+		max_supported_size += 1;
+
+	if (conf->max_pkt_size > max_supported_size) {
+		dev_err(udma->dev,
+			"udma [%s]: requested max_pkt_size (0x%x) exceeds the supported limit (0x%x)\n",
+			udma->name, conf->max_pkt_size, max_supported_size);
+		return -EINVAL;
+	}
+
+	reg &= ~UDMA_M2S_CFG_LEN_ENCODE_64K;
+	if (conf->encode_64k_as_zero)
+		reg |= UDMA_M2S_CFG_LEN_ENCODE_64K;
+	else
+		reg &= ~UDMA_M2S_CFG_LEN_ENCODE_64K;
+
+	reg &= ~UDMA_M2S_CFG_LEN_MAX_PKT_SIZE_MASK;
+	reg |= conf->max_pkt_size;
+
+	writel(reg, &udma->udma_regs->m2s.m2s.cfg_len);
+
+	return 0;
+}
+
+/* set max descriptors */
+void al_udma_m2s_max_descs_set(struct al_udma *udma, u8 max_descs)
+{
+	u32 pref_thr = max_descs, min_burst_above_thr = 4, tmp;
+
+	/*
+	 * increase min_burst_above_thr so larger burst can be used to fetch
+	 * descriptors
+	 */
+	if (pref_thr >= 8)
+		min_burst_above_thr = 8;
+	/*
+	 * don't set prefetch threshold too low so we can have the
+	 * min_burst_above_thr >= 4
+	 */
+	else
+		pref_thr = 4;
+
+	tmp = readl(&udma->udma_regs->m2s.m2s_rd.desc_pref_cfg_2);
+	tmp &= ~UDMA_M2S_RD_DESC_PREF_CFG_2_MAX_DESC_PER_PKT_MASK;
+	tmp |= max_descs << UDMA_M2S_RD_DESC_PREF_CFG_2_MAX_DESC_PER_PKT_SHIFT;
+	writel(tmp, &udma->udma_regs->m2s.m2s_rd.desc_pref_cfg_2);
+
+	tmp = readl(&udma->udma_regs->m2s.m2s_rd.desc_pref_cfg_3);
+	tmp &= ~(UDMA_M2S_RD_DESC_PREF_CFG_3_PREF_THR_MASK |
+		 UDMA_M2S_RD_DESC_PREF_CFG_3_MIN_BURST_ABOVE_THR_MASK);
+	tmp |= pref_thr << UDMA_M2S_RD_DESC_PREF_CFG_3_PREF_THR_SHIFT;
+	tmp |= min_burst_above_thr << UDMA_M2S_RD_DESC_PREF_CFG_3_MIN_BURST_ABOVE_THR_SHIFT;
+	writel(tmp, &udma->udma_regs->m2s.m2s_rd.desc_pref_cfg_3);
+}
+
+/* set s2m max descriptors */
+void al_udma_s2m_max_descs_set(struct al_udma *udma, u8 max_descs)
+{
+	u32 pref_thr = max_descs, min_burst_above_thr = 4, tmp;
+
+	/*
+	 * increase min_burst_above_thr so larger burst can be used to fetch
+	 * descriptors
+	 */
+	if (pref_thr >= 8)
+		min_burst_above_thr = 8;
+	/*
+	 * don't set prefetch threshold too low so we can have the
+	 * min_burst_above_thr >= 4
+	 */
+	else
+		pref_thr = 4;
+
+	tmp = readl(&udma->udma_regs->s2m.s2m_rd.desc_pref_cfg_3);
+	tmp &= ~(UDMA_S2M_RD_DESC_PREF_CFG_3_PREF_THR_MASK |
+		 UDMA_S2M_RD_DESC_PREF_CFG_3_MIN_BURST_ABOVE_THR_MASK);
+	tmp |= pref_thr << UDMA_S2M_RD_DESC_PREF_CFG_3_PREF_THR_SHIFT;
+	tmp |= min_burst_above_thr << UDMA_S2M_RD_DESC_PREF_CFG_3_MIN_BURST_ABOVE_THR_SHIFT;
+	writel(tmp, &udma->udma_regs->s2m.s2m_rd.desc_pref_cfg_3);
+}
+
+/* S2M UDMA configure a queue's completion descriptors coalescing */
+void al_udma_s2m_q_compl_coal_config(struct al_udma_q *udma_q, bool enable,
+				     u32 coal_timeout)
+{
+	u32 reg = readl(&udma_q->q_regs->s2m_q.comp_cfg);
+
+	if (enable)
+		reg &= ~UDMA_S2M_Q_COMP_CFG_DIS_COMP_COAL;
+	else
+		reg |= UDMA_S2M_Q_COMP_CFG_DIS_COMP_COAL;
+
+	writel(reg, &udma_q->q_regs->s2m_q.comp_cfg);
+	writel(coal_timeout, &udma_q->q_regs->s2m_q.comp_cfg_2);
+}
+
+/* S2M UDMA configure completion descriptors write burst parameters */
+int al_udma_s2m_compl_desc_burst_config(struct al_udma *udma, u16 burst_size)
+{
+	u32 tmp;
+
+	if ((burst_size != 64) && (burst_size != 128) && (burst_size != 256)) {
+		dev_err(udma->dev, "invalid burst_size value (%d)\n",
+			burst_size);
+		return -EINVAL;
+	}
+
+	/* convert burst size from bytes to beats (16 byte) */
+	burst_size = burst_size / 16;
+
+	tmp = readl(&udma->udma_regs->s2m.axi_s2m.desc_wr_cfg_1);
+	tmp &= ~(UDMA_AXI_S2M_DESC_WR_CFG_1_MIN_AXI_BEATS_MASK |
+		 UDMA_AXI_S2M_DESC_WR_CFG_1_MAX_AXI_BEATS_MASK);
+	tmp |= burst_size << UDMA_AXI_S2M_DESC_WR_CFG_1_MIN_AXI_BEATS_SHIFT;
+	tmp |= burst_size << UDMA_AXI_S2M_DESC_WR_CFG_1_MAX_AXI_BEATS_SHIFT;
+	writel(tmp, &udma->udma_regs->s2m.axi_s2m.desc_wr_cfg_1);
+
+	return 0;
+}
diff --git a/drivers/soc/alpine/udma/al_udma_iofic.c b/drivers/soc/alpine/udma/al_udma_iofic.c
new file mode 100644
index 000000000000..cf4f27d21b61
--- /dev/null
+++ b/drivers/soc/alpine/udma/al_udma_iofic.c
@@ -0,0 +1,110 @@
+/*
+ * Annapurna Labs UDMA-specific IOFIC helpers
+ *
+ * Copyright (C) 2017, Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include <linux/soc/alpine/al_hw_udma_iofic.h>
+#include <linux/soc/alpine/al_hw_udma_regs.h>
+
+/* configure the interrupt registers, interrupts will are kept masked */
+static int al_udma_main_iofic_config(void __iomem *iofic,
+				     enum al_iofic_mode mode)
+{
+	switch (mode) {
+	case AL_IOFIC_MODE_LEGACY:
+		al_iofic_config(iofic, AL_INT_GROUP_A,
+				INT_CONTROL_GRP_SET_ON_POSEDGE |
+				INT_CONTROL_GRP_MASK_MSI_X |
+				INT_CONTROL_GRP_CLEAR_ON_READ);
+		al_iofic_config(iofic, AL_INT_GROUP_B,
+				INT_CONTROL_GRP_CLEAR_ON_READ |
+				INT_CONTROL_GRP_MASK_MSI_X);
+		al_iofic_config(iofic, AL_INT_GROUP_C,
+				INT_CONTROL_GRP_CLEAR_ON_READ |
+				INT_CONTROL_GRP_MASK_MSI_X);
+		al_iofic_config(iofic, AL_INT_GROUP_D,
+				INT_CONTROL_GRP_SET_ON_POSEDGE |
+				INT_CONTROL_GRP_MASK_MSI_X |
+				INT_CONTROL_GRP_CLEAR_ON_READ);
+		break;
+	case AL_IOFIC_MODE_MSIX_PER_Q:
+		al_iofic_config(iofic, AL_INT_GROUP_A,
+				INT_CONTROL_GRP_SET_ON_POSEDGE |
+				INT_CONTROL_GRP_AUTO_MASK |
+				INT_CONTROL_GRP_AUTO_CLEAR);
+		al_iofic_config(iofic, AL_INT_GROUP_B,
+				INT_CONTROL_GRP_AUTO_CLEAR |
+				INT_CONTROL_GRP_AUTO_MASK |
+				INT_CONTROL_GRP_CLEAR_ON_READ);
+		al_iofic_config(iofic, AL_INT_GROUP_C,
+				INT_CONTROL_GRP_AUTO_CLEAR |
+				INT_CONTROL_GRP_AUTO_MASK |
+				INT_CONTROL_GRP_CLEAR_ON_READ);
+		al_iofic_config(iofic, AL_INT_GROUP_D,
+				INT_CONTROL_GRP_SET_ON_POSEDGE |
+				INT_CONTROL_GRP_CLEAR_ON_READ |
+				INT_CONTROL_GRP_MASK_MSI_X);
+		break;
+	case AL_IOFIC_MODE_MSIX_PER_GROUP:
+		al_iofic_config(iofic, AL_INT_GROUP_A,
+				INT_CONTROL_GRP_SET_ON_POSEDGE |
+				INT_CONTROL_GRP_AUTO_CLEAR |
+				INT_CONTROL_GRP_AUTO_MASK);
+		al_iofic_config(iofic, AL_INT_GROUP_B,
+				INT_CONTROL_GRP_CLEAR_ON_READ |
+				INT_CONTROL_GRP_MASK_MSI_X);
+		al_iofic_config(iofic, AL_INT_GROUP_C,
+				INT_CONTROL_GRP_CLEAR_ON_READ |
+				INT_CONTROL_GRP_MASK_MSI_X);
+		al_iofic_config(iofic, AL_INT_GROUP_D,
+				INT_CONTROL_GRP_SET_ON_POSEDGE |
+				INT_CONTROL_GRP_CLEAR_ON_READ |
+				INT_CONTROL_GRP_MASK_MSI_X);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/* configure the UDMA interrupt registers, interrupts are kept masked */
+int al_udma_iofic_config(struct unit_regs __iomem *regs,
+			 enum al_iofic_mode mode, u32 m2s_errors_disable,
+			 u32 m2s_aborts_disable, u32 s2m_errors_disable,
+			 u32 s2m_aborts_disable)
+{
+	int rc;
+
+	rc = al_udma_main_iofic_config(&regs->gen.interrupt_regs.main_iofic,
+				       mode);
+	if (rc)
+		return rc;
+
+	al_iofic_unmask(&regs->gen.interrupt_regs.secondary_iofic_ctrl,
+			AL_INT_GROUP_A, ~m2s_errors_disable);
+	al_iofic_abort_mask(&regs->gen.interrupt_regs.secondary_iofic_ctrl,
+			    AL_INT_GROUP_A, m2s_aborts_disable);
+
+	al_iofic_unmask(&regs->gen.interrupt_regs.secondary_iofic_ctrl,
+			AL_INT_GROUP_B, ~s2m_errors_disable);
+	al_iofic_abort_mask(&regs->gen.interrupt_regs.secondary_iofic_ctrl,
+			    AL_INT_GROUP_B, s2m_aborts_disable);
+
+	return 0;
+}
+
+/* returns the offset of the unmask register for a given group */
+u32 __iomem *al_udma_iofic_unmask_offset_get(struct unit_regs __iomem *regs,
+					     enum al_udma_iofic_level level,
+					     int group)
+{
+	WARN_ON(!al_udma_iofic_level_and_group_valid(level, group));
+	return al_iofic_unmask_offset_get(
+			al_udma_iofic_reg_base_get(regs, level), group);
+}
diff --git a/drivers/soc/alpine/udma/al_udma_main.c b/drivers/soc/alpine/udma/al_udma_main.c
new file mode 100644
index 000000000000..86a294d65495
--- /dev/null
+++ b/drivers/soc/alpine/udma/al_udma_main.c
@@ -0,0 +1,245 @@
+/*
+ * Copyright (C) 2017, Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include <linux/delay.h>
+#include <linux/device.h>
+#include <linux/soc/alpine/al_hw_udma.h>
+#include <linux/soc/alpine/al_hw_udma_config.h>
+
+#define UDMA_STATE_IDLE		0x0
+#define UDMA_STATE_NORMAL	0x1
+#define UDMA_STATE_ABORT	0x2
+#define UDMA_STATE_RESERVED	0x3
+
+const char *const al_udma_states_name[] = {
+	"Idle",
+	"Normal",
+	"Abort",
+	"Reset"
+};
+
+#define AL_ADDR_LOW(x)	((u32)((dma_addr_t)(x)))
+#define AL_ADDR_HIGH(x)	((u32)((((dma_addr_t)(x)) >> 16) >> 16))
+
+static void al_udma_set_defaults(struct al_udma *udma)
+{
+	u8 rev_id = udma->rev_id;
+	u32 tmp;
+
+	if (udma->type == UDMA_TX) {
+		struct unit_regs *tmp_unit_regs =
+			(struct unit_regs *)udma->udma_regs;
+
+		/*
+		 * Setting the data fifo depth to 4K (256 strips of 16B)
+		 * This allows the UDMA to have 16 outstanding writes
+		 */
+		if (rev_id >= AL_UDMA_REV_ID_2) {
+			tmp = readl(&tmp_unit_regs->m2s.m2s_rd.data_cfg);
+			tmp &= ~UDMA_M2S_RD_DATA_CFG_DATA_FIFO_DEPTH_MASK;
+			tmp |= 256 << UDMA_M2S_RD_DATA_CFG_DATA_FIFO_DEPTH_SHIFT;
+			writel(tmp, &tmp_unit_regs->m2s.m2s_rd.data_cfg);
+		}
+
+		/* set AXI timeout to 1M (~2.6 ms) */
+		writel(1000000, &tmp_unit_regs->gen.axi.cfg_1);
+
+		writel(0, &tmp_unit_regs->m2s.m2s_comp.cfg_application_ack);
+	}
+
+	if (udma->type == UDMA_RX)
+		writel(0, &udma->udma_regs->s2m.s2m_comp.cfg_application_ack);
+}
+
+static void al_udma_config_compl(struct al_udma *udma)
+{
+	u32 val;
+
+	if (udma->type != UDMA_RX)
+		return;
+
+	val = readl(&udma->udma_regs->s2m.s2m_comp.cfg_1c);
+	val &= ~UDMA_S2M_COMP_CFG_1C_DESC_SIZE_MASK;
+	val |= (udma->cdesc_size >> 2) & UDMA_S2M_COMP_CFG_1C_DESC_SIZE_MASK;
+	writel(val, &udma->udma_regs->s2m.s2m_comp.cfg_1c);
+}
+
+/* Initialize the udma engine */
+int al_udma_init(struct al_udma *udma, struct al_udma_params *udma_params)
+{
+	int i;
+
+	udma->dev = udma_params->dev;
+
+	if (udma_params->num_of_queues > DMA_MAX_Q) {
+		dev_err(udma->dev, "udma: invalid num_of_queues parameter\n");
+		return -EINVAL;
+	}
+
+	udma->type = udma_params->type;
+	udma->num_of_queues = udma_params->num_of_queues;
+	udma->cdesc_size = udma_params->cdesc_size;
+	udma->gen_regs = &udma_params->udma_regs_base->gen;
+
+	if (udma->type == UDMA_TX)
+		udma->udma_regs = (union udma_regs *)&udma_params->udma_regs_base->m2s;
+	else
+		udma->udma_regs = (union udma_regs *)&udma_params->udma_regs_base->s2m;
+
+	udma->rev_id = al_udma_get_revision(udma_params->udma_regs_base);
+
+	if (udma_params->name == NULL)
+		udma->name = "";
+	else
+		udma->name = udma_params->name;
+
+	udma->state = UDMA_DISABLE;
+	for (i = 0; i < DMA_MAX_Q; i++) {
+		udma->udma_q[i].status = AL_QUEUE_NOT_INITIALIZED;
+	}
+
+	/*
+	 * the register expects it to be in words
+	 * initialize configuration registers to correct values
+	 */
+	al_udma_set_defaults(udma);
+
+	al_udma_config_compl(udma);
+
+	dev_dbg(udma->dev, "udma [%s] initialized. base %p\n", udma->name,
+		udma->udma_regs);
+
+	return 0;
+}
+
+/* Change the UDMA's state */
+void al_udma_state_set(struct al_udma *udma, enum al_udma_state state)
+{
+	u32 reg = 0;
+
+	if (state == udma->state)
+		dev_dbg(udma->dev,
+			"udma [%s]: requested state identical to current state (%d)\n",
+			udma->name, state);
+	else
+		dev_dbg(udma->dev, "udma [%s]: change state from (%s) to (%s)\n",
+			udma->name, al_udma_states_name[udma->state],
+			 al_udma_states_name[state]);
+
+	switch (state) {
+	case UDMA_DISABLE:
+		reg |= UDMA_M2S_CHANGE_STATE_DIS;
+		break;
+	case UDMA_NORMAL:
+		reg |= UDMA_M2S_CHANGE_STATE_NORMAL;
+		break;
+	case UDMA_ABORT:
+		reg |= UDMA_M2S_CHANGE_STATE_ABORT;
+		break;
+	default:
+		dev_err(udma->dev, "udma: invalid state (%d)\n", state);
+		return;
+	}
+
+	if (udma->type == UDMA_TX)
+		writel(reg, &udma->udma_regs->m2s.m2s.change_state);
+	else
+		writel(reg, &udma->udma_regs->s2m.s2m.change_state);
+
+	udma->state = state;
+}
+
+/* returns the current UDMA hardware state */
+enum al_udma_state al_udma_state_get(struct al_udma *udma)
+{
+	u32 state_reg;
+	u32 comp_ctrl;
+	u32 stream_if;
+	u32 data_rd;
+	u32 desc_pref;
+
+	if (udma->type == UDMA_TX)
+		state_reg = readl(&udma->udma_regs->m2s.m2s.state);
+	else
+		state_reg = readl(&udma->udma_regs->s2m.s2m.state);
+
+	comp_ctrl = (state_reg & UDMA_M2S_STATE_COMP_CTRL_MASK) >>
+			UDMA_M2S_STATE_COMP_CTRL_SHIFT;
+	stream_if = (state_reg & UDMA_M2S_STATE_STREAM_IF_MASK) >>
+			UDMA_M2S_STATE_STREAM_IF_SHIFT;
+	data_rd = (state_reg & UDMA_M2S_STATE_DATA_RD_CTRL_MASK) >>
+			UDMA_M2S_STATE_DATA_RD_CTRL_SHIFT;
+	desc_pref = (state_reg & UDMA_M2S_STATE_DESC_PREF_MASK) >>
+			UDMA_M2S_STATE_DESC_PREF_SHIFT;
+
+	/* if any of the states is abort then return abort */
+	if ((comp_ctrl == UDMA_STATE_ABORT) || (stream_if == UDMA_STATE_ABORT)
+			|| (data_rd == UDMA_STATE_ABORT)
+			|| (desc_pref == UDMA_STATE_ABORT))
+		return UDMA_ABORT;
+
+	/* if any of the states is normal then return normal */
+	if ((comp_ctrl == UDMA_STATE_NORMAL)
+			|| (stream_if == UDMA_STATE_NORMAL)
+			|| (data_rd == UDMA_STATE_NORMAL)
+			|| (desc_pref == UDMA_STATE_NORMAL))
+		return UDMA_NORMAL;
+
+	return UDMA_IDLE;
+}
+
+/* get next completed packet from completion ring of the queue */
+u32 al_udma_cdesc_packet_get(struct al_udma_q *udma_q,
+			     volatile union al_udma_cdesc **cdesc)
+{
+	u32 count;
+	volatile union al_udma_cdesc *curr;
+	u32 comp_flags;
+
+	/* comp_head points to the last comp desc that was processed */
+	curr = udma_q->comp_head_ptr;
+	comp_flags = le32_to_cpu(curr->al_desc_comp_tx.ctrl_meta);
+
+	/* check if the completion descriptor is new */
+	if (unlikely(!al_udma_new_cdesc(udma_q, comp_flags)))
+		return 0;
+
+	count = udma_q->pkt_crnt_descs + 1;
+
+	/* if new desc found, increment the current packets descriptors */
+	while (!cdesc_is_last(comp_flags)) {
+		curr = al_cdesc_next_update(udma_q, curr);
+		comp_flags = le32_to_cpu(curr->al_desc_comp_tx.ctrl_meta);
+
+		if (unlikely(!al_udma_new_cdesc(udma_q, comp_flags))) {
+			/*
+			 * The current packet here doesn't have all
+			 * descriptors completed. log the current desc
+			 * location and number of completed descriptors so
+			 * far. Then return.
+			 */
+			udma_q->pkt_crnt_descs = count;
+			udma_q->comp_head_ptr = curr;
+
+			return 0;
+		}
+		count++;
+	}
+
+	/* return back the first descriptor of the packet */
+	*cdesc = al_udma_cdesc_idx_to_ptr(udma_q, udma_q->next_cdesc_idx);
+	udma_q->pkt_crnt_descs = 0;
+	udma_q->comp_head_ptr = al_cdesc_next_update(udma_q, curr);
+
+	dev_dbg(udma_q->udma->dev,
+		"udma [%s %d]: packet completed. first desc %p (ixd 0x%x) descs %d\n",
+		udma_q->udma->name, udma_q->qid, *cdesc, udma_q->next_cdesc_idx,
+		count);
+
+	return count;
+}
diff --git a/drivers/soc/alpine/udma/al_udma_queue.c b/drivers/soc/alpine/udma/al_udma_queue.c
new file mode 100644
index 000000000000..b5ca082faac6
--- /dev/null
+++ b/drivers/soc/alpine/udma/al_udma_queue.c
@@ -0,0 +1,232 @@
+/*
+ * Copyright (C) 2017, Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include <linux/delay.h>
+#include <linux/device.h>
+#include <linux/soc/alpine/al_hw_udma.h>
+#include <linux/soc/alpine/al_hw_udma_config.h>
+
+/* dma_q flags */
+#define AL_UDMA_Q_FLAGS_IGNORE_RING_ID	BIT(0)
+#define AL_UDMA_Q_FLAGS_NO_COMP_UPDATE	BIT(1)
+#define AL_UDMA_Q_FLAGS_EN_COMP_COAL	BIT(2)
+
+#define AL_UDMA_INITIAL_RING_ID		1
+
+#define AL_ADDR_LOW(x)	((u32)((dma_addr_t)(x)))
+#define AL_ADDR_HIGH(x)	((u32)((((dma_addr_t)(x)) >> 16) >> 16))
+
+/*
+ * misc queue configurations
+ *
+ * @param udma_q udma queue data structure
+ */
+static void al_udma_q_config(struct al_udma_q *udma_q)
+{
+	u32 *reg_addr;
+	u32 val;
+
+	if (udma_q->udma->type == UDMA_TX) {
+		reg_addr = &udma_q->q_regs->m2s_q.rlimit.mask;
+
+		/* enable DMB */
+		val = readl(reg_addr);
+		val &= ~UDMA_M2S_Q_RATE_LIMIT_MASK_INTERNAL_PAUSE_DMB;
+		writel(val, reg_addr);
+	}
+}
+
+/*
+ * set the queue's completion configuration register
+ *
+ * @param udma_q udma queue data structure
+ */
+static void al_udma_q_config_compl(struct al_udma_q *udma_q)
+{
+	u32 *reg_addr;
+	u32 val;
+
+	if (udma_q->udma->type == UDMA_TX)
+		reg_addr = &udma_q->q_regs->m2s_q.comp_cfg;
+	else
+		reg_addr = &udma_q->q_regs->s2m_q.comp_cfg;
+
+	val = readl(reg_addr);
+
+	if (udma_q->flags & AL_UDMA_Q_FLAGS_NO_COMP_UPDATE)
+		val &= ~UDMA_M2S_Q_COMP_CFG_EN_COMP_RING_UPDATE;
+	else
+		val |= UDMA_M2S_Q_COMP_CFG_EN_COMP_RING_UPDATE;
+
+	if (udma_q->flags & AL_UDMA_Q_FLAGS_EN_COMP_COAL)
+		val &= ~UDMA_M2S_Q_COMP_CFG_DIS_COMP_COAL;
+	else
+		val |= UDMA_M2S_Q_COMP_CFG_DIS_COMP_COAL;
+
+	writel(val, reg_addr);
+}
+
+/*
+ * reset the queues pointers (Head, Tail, etc) and set the base addresses
+ *
+ * @param udma_q udma queue data structure
+ */
+static void al_udma_q_set_pointers(struct al_udma_q *udma_q)
+{
+	/*
+	 * reset the descriptors ring pointers
+	 * assert descriptor base address aligned.
+	 */
+	WARN_ON((AL_ADDR_LOW(udma_q->desc_phy_base) &
+			~UDMA_M2S_Q_TDRBP_LOW_ADDR_MASK) != 0);
+	writel(AL_ADDR_LOW(udma_q->desc_phy_base),
+	       &udma_q->q_regs->rings.drbp_low);
+	writel(AL_ADDR_HIGH(udma_q->desc_phy_base),
+	       &udma_q->q_regs->rings.drbp_high);
+
+	writel(udma_q->size, &udma_q->q_regs->rings.drl);
+
+	/* if completion ring update disabled */
+	if (udma_q->cdesc_base_ptr == NULL) {
+		udma_q->flags |= AL_UDMA_Q_FLAGS_NO_COMP_UPDATE;
+	} else {
+		/*
+		 * reset the completion descriptors ring pointers
+		 * assert completion base address aligned.
+		 */
+		WARN_ON((AL_ADDR_LOW(udma_q->cdesc_phy_base) & ~UDMA_M2S_Q_TCRBP_LOW_ADDR_MASK) != 0);
+		writel(AL_ADDR_LOW(udma_q->cdesc_phy_base),
+		       &udma_q->q_regs->rings.crbp_low);
+		writel(AL_ADDR_HIGH(udma_q->cdesc_phy_base),
+		       &udma_q->q_regs->rings.crbp_high);
+	}
+	al_udma_q_config_compl(udma_q);
+}
+
+/*
+ * enable/disable udma queue
+ *
+ * @param udma_q udma queue data structure
+ * @param enable none zero value enables the queue, zero means disable
+ */
+static void al_udma_q_enable(struct al_udma_q *udma_q, int enable)
+{
+	u32 reg = readl(&udma_q->q_regs->rings.cfg);
+
+	if (enable) {
+		reg |= (UDMA_M2S_Q_CFG_EN_PREF | UDMA_M2S_Q_CFG_EN_SCHEDULING);
+		udma_q->status = AL_QUEUE_ENABLED;
+	} else {
+		reg &= ~(UDMA_M2S_Q_CFG_EN_PREF | UDMA_M2S_Q_CFG_EN_SCHEDULING);
+		udma_q->status = AL_QUEUE_DISABLED;
+	}
+
+	writel(reg, &udma_q->q_regs->rings.cfg);
+}
+
+/* Initialize the udma queue data structure */
+int al_udma_q_init(struct al_udma *udma, u32 qid,
+		   struct al_udma_q_params *q_params)
+{
+	struct al_udma_q *udma_q;
+
+	if (qid >= udma->num_of_queues) {
+		dev_err(udma->dev, "udma: invalid queue id (%d)\n", qid);
+		return -EINVAL;
+	}
+
+	if (udma->udma_q[qid].status == AL_QUEUE_ENABLED) {
+		dev_err(udma->dev, "udma: queue (%d) already enabled!\n", qid);
+		return -EIO;
+	}
+
+	if (q_params->size < AL_UDMA_MIN_Q_SIZE) {
+		dev_err(udma->dev, "udma: queue (%d) size too small\n", qid);
+		return -EINVAL;
+	}
+
+	if (q_params->size > AL_UDMA_MAX_Q_SIZE) {
+		dev_err(udma->dev, "udma: queue (%d) size too large\n", qid);
+		return -EINVAL;
+	}
+
+	if (q_params->size & (q_params->size - 1)) {
+		dev_err(udma->dev,
+			"udma: queue (%d) size (%d) must be power of 2\n",
+			q_params->size, qid);
+		return -EINVAL;
+	}
+
+	udma_q = &udma->udma_q[qid];
+	/* set the queue's regs base address */
+	if (udma->type == UDMA_TX)
+		udma_q->q_regs =
+			(union udma_q_regs __iomem *)&udma->udma_regs->m2s.m2s_q[qid];
+	else
+		udma_q->q_regs =
+			(union udma_q_regs __iomem *)&udma->udma_regs->s2m.s2m_q[qid];
+
+	udma_q->adapter_rev_id = q_params->adapter_rev_id;
+	udma_q->size = q_params->size;
+	udma_q->size_mask = q_params->size - 1;
+	udma_q->desc_base_ptr = q_params->desc_base;
+	udma_q->desc_phy_base = q_params->desc_phy_base;
+	udma_q->cdesc_base_ptr = q_params->cdesc_base;
+	udma_q->cdesc_phy_base = q_params->cdesc_phy_base;
+
+	udma_q->next_desc_idx = 0;
+	udma_q->next_cdesc_idx = 0;
+	udma_q->end_cdesc_ptr = (u8 *) udma_q->cdesc_base_ptr +
+	    (udma_q->size - 1) * udma->cdesc_size;
+	udma_q->comp_head_idx = 0;
+	udma_q->comp_head_ptr = (union al_udma_cdesc *)udma_q->cdesc_base_ptr;
+	udma_q->desc_ring_id = AL_UDMA_INITIAL_RING_ID;
+	udma_q->comp_ring_id = AL_UDMA_INITIAL_RING_ID;
+
+	udma_q->pkt_crnt_descs = 0;
+	udma_q->flags = 0;
+	udma_q->status = AL_QUEUE_DISABLED;
+	udma_q->udma = udma;
+	udma_q->qid = qid;
+
+	/* start hardware configuration: */
+	al_udma_q_config(udma_q);
+	/* reset the queue pointers */
+	al_udma_q_set_pointers(udma_q);
+
+	/* enable the q */
+	al_udma_q_enable(udma_q, 1);
+
+	dev_dbg(udma->dev,
+		"udma [%s %d]: %s q init. size 0x%x\n  desc ring info: phys base 0x%llx virt base %p)",
+		udma_q->udma->name, udma_q->qid,
+		udma->type == UDMA_TX ? "Tx" : "Rx", q_params->size,
+		(unsigned long long)q_params->desc_phy_base,
+		q_params->desc_base);
+	dev_dbg(udma->dev,
+		"  cdesc ring info: phys base 0x%llx virt base %p",
+		(unsigned long long)q_params->cdesc_phy_base,
+		q_params->cdesc_base);
+
+	return 0;
+}
+
+/* return (by reference) a pointer to a specific queue date structure. */
+int al_udma_q_handle_get(struct al_udma *udma, u32 qid,
+			 struct al_udma_q **q_handle)
+{
+
+	if (unlikely(qid >= udma->num_of_queues)) {
+		dev_err(udma->dev, "udma [%s]: invalid queue id (%d)\n",
+			udma->name, qid);
+		return -EINVAL;
+	}
+
+	*q_handle = &udma->udma_q[qid];
+	return 0;
+}
diff --git a/include/linux/soc/alpine/al_hw_udma.h b/include/linux/soc/alpine/al_hw_udma.h
new file mode 100644
index 000000000000..3a428a8daedc
--- /dev/null
+++ b/include/linux/soc/alpine/al_hw_udma.h
@@ -0,0 +1,499 @@
+/*
+ * Copyright (C) 2017, Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#ifndef __AL_HW_UDMA_H__
+#define __AL_HW_UDMA_H__
+
+#include <linux/bitops.h>
+#include <linux/io.h>
+#include <linux/types.h>
+
+#include "al_hw_udma_regs.h"
+
+#define DMA_MAX_Q 	4
+#define AL_UDMA_MIN_Q_SIZE 	4
+#define AL_UDMA_MAX_Q_SIZE 	BIT(16) /* hw can do more, but we limit it */
+
+#define AL_UDMA_REV_ID_2	2
+
+#define DMA_RING_ID_MASK	0x3
+/* New registers ?? */
+/* Statistics - TBD */
+
+/* UDMA submission descriptor */
+union al_udma_desc {
+	/* TX */
+	struct {
+		u32 len_ctrl;
+		u32 meta_ctrl;
+		u64 buf_ptr;
+	} tx;
+	/* TX Meta, used by upper layer */
+	struct {
+		u32 len_ctrl;
+		u32 meta_ctrl;
+		u32 meta1;
+		u32 meta2;
+	} tx_meta;
+	/* RX */
+	struct {
+		u32 len_ctrl;
+		u32 buf2_ptr_lo;
+		u64 buf1_ptr;
+	} rx;
+} __attribute__((aligned(16)));
+
+/* TX desc length and control fields */
+
+#define AL_M2S_DESC_CONCAT			BIT(31)
+#define AL_M2S_DESC_NO_SNOOP_H			BIT(29)
+#define AL_M2S_DESC_INT_EN			BIT(28)
+#define AL_M2S_DESC_LAST			BIT(27)
+#define AL_M2S_DESC_FIRST			BIT(26)
+#define AL_M2S_DESC_RING_ID_SHIFT		24
+#define AL_M2S_DESC_RING_ID_MASK		(0x3 << AL_M2S_DESC_RING_ID_SHIFT)
+#define AL_M2S_DESC_META_DATA			BIT(23)
+#define AL_M2S_DESC_LEN_SHIFT			0
+#define AL_M2S_DESC_LEN_MASK			(0xfffff << AL_M2S_DESC_LEN_SHIFT)
+
+#define AL_S2M_DESC_DUAL_BUF			BIT(31)
+#define AL_S2M_DESC_RING_ID_SHIFT		24
+#define AL_S2M_DESC_LEN_SHIFT			0
+#define AL_S2M_DESC_LEN_MASK			(0xffff << AL_S2M_DESC_LEN_SHIFT)
+#define AL_S2M_DESC_LEN2_SHIFT			16
+#define AL_S2M_DESC_LEN2_MASK			(0x3fff << AL_S2M_DESC_LEN2_SHIFT)
+#define AL_S2M_DESC_LEN2_GRANULARITY_SHIFT	6
+
+/* TX/RX descriptor Target-ID field (in the buffer address 64 bit field) */
+#define AL_UDMA_DESC_TGTID_SHIFT		48
+
+/* UDMA completion descriptor */
+union al_udma_cdesc {
+	/* TX completion */
+	struct {
+		u32 ctrl_meta;
+	} al_desc_comp_tx;
+	/* RX completion */
+	struct {
+		u32 ctrl_meta;
+	} al_desc_comp_rx;
+} __attribute__((aligned(4)));
+
+/* TX/RX common completion desc ctrl_meta feilds */
+#define AL_UDMA_CDESC_ERROR		BIT(31)
+#define AL_UDMA_CDESC_LAST		BIT(27)
+#define AL_UDMA_CDESC_BUF2_USED		BIT(31)
+
+/* Basic Buffer structure */
+struct al_buf {
+	/* Buffer physical address */
+	dma_addr_t addr;
+	/* Buffer lenght in bytes */
+	u32 len;
+};
+
+/* UDMA type */
+enum al_udma_type {
+	UDMA_TX,
+	UDMA_RX
+};
+
+/* UDMA state */
+enum al_udma_state {
+	UDMA_DISABLE = 0,
+	UDMA_IDLE,
+	UDMA_NORMAL,
+	UDMA_ABORT,
+	UDMA_RESET
+};
+
+extern const char *const al_udma_states_name[];
+
+/* UDMA Q specific parameters from upper layer */
+struct al_udma_q_params {
+	/*
+	 * ring size (in descriptors), submission and completion rings must have
+	 * the same size
+	 */
+	u32 size;
+	/* cpu address for submission ring descriptors */
+	union al_udma_desc *desc_base;
+	/* submission ring descriptors physical base address */
+	dma_addr_t desc_phy_base;
+	 /* completion descriptors pointer, NULL means no completion update */
+	u8 *cdesc_base;
+	/* completion descriptors ring physical base address */
+	dma_addr_t cdesc_phy_base;
+
+	u8 adapter_rev_id;
+};
+
+/* UDMA parameters from upper layer */
+struct al_udma_params {
+	struct device *dev;
+	struct unit_regs __iomem *udma_regs_base;
+	enum al_udma_type type;
+	/* size (in bytes) of the udma completion ring descriptor */
+	u32 cdesc_size;
+	u8 num_of_queues;
+	const char *name;
+};
+
+/* Fordward decleration */
+struct al_udma;
+
+/* SW status of a queue */
+enum al_udma_queue_status {
+	AL_QUEUE_NOT_INITIALIZED = 0,
+	AL_QUEUE_DISABLED,
+	AL_QUEUE_ENABLED,
+	AL_QUEUE_ABORTED
+};
+
+/* UDMA Queue private data structure */
+struct al_udma_q {
+	/* mask used for pointers wrap around equals to size - 1 */
+	u16 size_mask;
+	/* pointer to the per queue UDMA registers */
+	union udma_q_regs __iomem *q_regs;
+	/* base address submission ring descriptors */
+	union al_udma_desc *desc_base_ptr;
+	/* index to the next available submission descriptor */
+	u16 next_desc_idx;
+	/* current submission ring id */
+	u32 desc_ring_id;
+	/* completion descriptors pointer, NULL means no completion */
+	u8 *cdesc_base_ptr;
+	/* index in descriptors for next completing ring descriptor */
+	u16 next_cdesc_idx;
+	/* used for wrap around detection */
+	u8 *end_cdesc_ptr;
+	/* completion ring head pointer register shadow */
+	u16 comp_head_idx;
+	/*
+	 * when working in get_packet mode we maintain pointer instead of the
+	 * above id
+	 */
+	volatile union al_udma_cdesc *comp_head_ptr;
+
+	/* holds the number of processed descriptors of the current packet */
+	u32 pkt_crnt_descs;
+	/* current completion Ring Id */
+	u32 comp_ring_id;
+
+	dma_addr_t desc_phy_base;	/* submission desc. physical base */
+	dma_addr_t cdesc_phy_base;	/* completion desc. physical base */
+
+	u32 flags;			/* flags used for completion modes */
+	u32 size;			/* ring size in descriptors  */
+	enum al_udma_queue_status status;
+	struct al_udma *udma;		/* pointer to parent UDMA */
+	u32 qid;			/* the index number of the queue */
+
+	/*
+	 * The following fields are duplicated from the UDMA parent adapter
+	 * due to performance considerations.
+	 */
+	u8 adapter_rev_id;
+} ____cacheline_aligned;
+
+/* UDMA */
+struct al_udma {
+	const char *name;
+	struct device *dev;
+	enum al_udma_type type;		/* Tx or Rx */
+	enum al_udma_state state;
+	/* size (in bytes) of the udma completion ring descriptor */
+	u32 cdesc_size;
+	u8 num_of_queues;
+	union udma_regs __iomem *udma_regs;
+	struct udma_gen_regs *gen_regs;
+	struct al_udma_q udma_q[DMA_MAX_Q];
+	unsigned int rev_id;
+};
+
+/*
+ * Initialize the udma engine
+ *
+ * @param udma udma data structure
+ * @param udma_params udma parameters from upper layer
+ *
+ * @return 0 on success. -EINVAL otherwise.
+ */
+int al_udma_init(struct al_udma *udma, struct al_udma_params *udma_params);
+
+/*
+ * Initialize the udma queue data structure
+ *
+ * @param udma
+ * @param qid
+ * @param q_params
+ *
+ * @return 0 if no error found.
+ *	   -EINVAL if the qid is out of range
+ *	   -EIO if queue was already initialized
+ */
+
+int al_udma_q_init(struct al_udma *udma, u32 qid,
+		   struct al_udma_q_params *q_params);
+
+/*
+ * return (by reference) a pointer to a specific queue date structure.
+ * this pointer needed for calling functions (i.e. al_udma_desc_action_add) that
+ * require this pointer as input argument.
+ *
+ * @param udma udma data structure
+ * @param qid queue index
+ * @param q_handle pointer to the location where the queue structure pointer
+ * written to.
+ *
+ * @return  0 on success. -EINVAL otherwise.
+ */
+int al_udma_q_handle_get(struct al_udma *udma, u32 qid,
+			 struct al_udma_q **q_handle);
+
+/*
+ * Change the UDMA's state
+ *
+ * @param udma udma data structure
+ * @param state the target state
+ */
+void al_udma_state_set(struct al_udma *udma, enum al_udma_state state);
+
+/*
+ * return the current UDMA hardware state
+ *
+ * @param udma udma handle
+ *
+ * @return the UDMA state as reported by the hardware.
+ */
+enum al_udma_state al_udma_state_get(struct al_udma *udma);
+
+/*
+ * Action handling
+ */
+
+/*
+ * get number of descriptors that can be submitted to the udma.
+ * keep one free descriptor to simplify full/empty management
+ * @param udma_q queue handle
+ *
+ * @return num of free descriptors.
+ */
+static inline u32 al_udma_available_get(struct al_udma_q *udma_q)
+{
+	u16 tmp = udma_q->next_cdesc_idx - (udma_q->next_desc_idx + 1);
+	tmp &= udma_q->size_mask;
+
+	return (u32) tmp;
+}
+
+/*
+ * get next available descriptor
+ * @param udma_q queue handle
+ *
+ * @return pointer to the next available descriptor
+ */
+static inline union al_udma_desc *al_udma_desc_get(struct al_udma_q *udma_q)
+{
+	union al_udma_desc *desc;
+	u16 next_desc_idx;
+
+	next_desc_idx = udma_q->next_desc_idx;
+	desc = udma_q->desc_base_ptr + next_desc_idx;
+
+	next_desc_idx++;
+
+	/* if reached end of queue, wrap around */
+	udma_q->next_desc_idx = next_desc_idx & udma_q->size_mask;
+
+	return desc;
+}
+
+/*
+ * get ring id for the last allocated descriptor
+ * @param udma_q
+ *
+ * @return ring id for the last allocated descriptor
+ * this function must be called each time a new descriptor is allocated
+ * by the al_udma_desc_get(), unless ring id is ignored.
+ */
+static inline u32 al_udma_ring_id_get(struct al_udma_q *udma_q)
+{
+	u32 ring_id;
+
+	ring_id = udma_q->desc_ring_id;
+
+	/* calculate the ring id of the next desc */
+	/* if next_desc points to first desc, then queue wrapped around */
+	if (unlikely(udma_q->next_desc_idx) == 0)
+		udma_q->desc_ring_id = (udma_q->desc_ring_id + 1) &
+			DMA_RING_ID_MASK;
+	return ring_id;
+}
+
+/* add DMA action - trigger the engine */
+/*
+ * add num descriptors to the submission queue.
+ *
+ * @param udma_q queue handle
+ * @param num number of descriptors to add to the queues ring.
+ */
+static inline void al_udma_desc_action_add(struct al_udma_q *udma_q, u32 num)
+{
+	u32 *addr;
+
+	addr = &udma_q->q_regs->rings.drtp_inc;
+	/*
+	 * make sure data written to the descriptors will be visible by the
+	 * DMA
+	 */
+	wmb();
+
+	writel_relaxed(num, addr);
+}
+
+#define cdesc_is_last(flags) ((flags) & AL_UDMA_CDESC_LAST)
+
+/*
+ * return pointer to the cdesc + offset desciptors. wrap around when needed.
+ *
+ * @param udma_q queue handle
+ * @param cdesc pointer that set by this function
+ * @param offset offset desciptors
+ *
+ */
+static inline volatile union al_udma_cdesc *al_cdesc_next(
+					struct al_udma_q *udma_q,
+					volatile union al_udma_cdesc *cdesc,
+					u32 offset)
+{
+	volatile u8 *tmp = (volatile u8 *) cdesc + offset * udma_q->udma->cdesc_size;
+
+	/* if wrap around */
+	if (unlikely((tmp > udma_q->end_cdesc_ptr)))
+		return (union al_udma_cdesc *)
+			(udma_q->cdesc_base_ptr +
+			(tmp - udma_q->end_cdesc_ptr - udma_q->udma->cdesc_size));
+
+	return (volatile union al_udma_cdesc *) tmp;
+}
+
+/*
+ * check if the flags of the descriptor indicates that is new one
+ * the function uses the ring id from the descriptor flags to know whether it
+ * new one by comparing it with the curring ring id of the queue
+ *
+ * @param udma_q queue handle
+ * @param flags the flags of the completion descriptor
+ *
+ * @return true if the completion descriptor is new one.
+ * 	false if it old one.
+ */
+static inline bool al_udma_new_cdesc(struct al_udma_q *udma_q, u32 flags)
+{
+	if (((flags & AL_M2S_DESC_RING_ID_MASK) >> AL_M2S_DESC_RING_ID_SHIFT)
+	    == udma_q->comp_ring_id)
+		return true;
+	return false;
+}
+
+/*
+ * get next completion descriptor
+ * this function will also increment the completion ring id when the ring wraps
+ * around
+ *
+ * @param udma_q queue handle
+ * @param cdesc current completion descriptor
+ *
+ * @return pointer to the completion descriptor that follows the one pointed by
+ * cdesc
+ */
+static inline volatile union al_udma_cdesc *al_cdesc_next_update(
+					struct al_udma_q *udma_q,
+					volatile union al_udma_cdesc *cdesc)
+{
+	/* if last desc, wrap around */
+	if (unlikely(((volatile u8 *) cdesc == udma_q->end_cdesc_ptr))) {
+		udma_q->comp_ring_id =
+		    (udma_q->comp_ring_id + 1) & DMA_RING_ID_MASK;
+		return (union al_udma_cdesc *) udma_q->cdesc_base_ptr;
+	}
+	return (volatile union al_udma_cdesc *) ((volatile u8 *) cdesc + udma_q->udma->cdesc_size);
+}
+
+/*
+ * get next completed packet from completion ring of the queue
+ *
+ * @param udma_q udma queue handle
+ * @param desc pointer that set by this function to the first descriptor
+ * note: desc is valid only when return value is not zero
+ * @return number of descriptors that belong to the packet. 0 means no completed
+ * full packet was found.
+ * If the descriptors found in the completion queue don't form full packet (no
+ * desc with LAST flag), then this function will do the following:
+ * (1) save the number of processed descriptors.
+ * (2) save last processed descriptor, so next time it called, it will resume
+ *     from there.
+ * (3) return 0.
+ * note: the descriptors that belong to the completed packet will still be
+ * considered as used, that means the upper layer is safe to access those
+ * descriptors when this function returns. the al_udma_cdesc_ack() should be
+ * called to inform the udma driver that those descriptors are freed.
+ */
+u32 al_udma_cdesc_packet_get(struct al_udma_q *udma_q,
+			     volatile union al_udma_cdesc **desc);
+
+/* get completion descriptor pointer from its index */
+#define al_udma_cdesc_idx_to_ptr(udma_q, idx)				\
+	((volatile union al_udma_cdesc *) ((udma_q)->cdesc_base_ptr +	\
+				(idx) * (udma_q)->udma->cdesc_size))
+
+
+/*
+ * return number of all completed descriptors in the completion ring
+ *
+ * @param udma_q udma queue handle
+ * @param cdesc pointer that set by this function to the first descriptor
+ * note: desc is valid only when return value is not zero
+ * note: pass NULL if not interested
+ * @return number of descriptors. 0 means no completed descriptors were found.
+ * note: the descriptors that belong to the completed packet will still be
+ * considered as used, that means the upper layer is safe to access those
+ * descriptors when this function returns. the al_udma_cdesc_ack() should be
+ * called to inform the udma driver that those descriptors are freed.
+ */
+static inline u32 al_udma_cdesc_get_all(struct al_udma_q *udma_q,
+					volatile union al_udma_cdesc **cdesc)
+{
+	u16 count = 0;
+
+	udma_q->comp_head_idx = readl(&udma_q->q_regs->rings.crhp) & 0xffff;
+	count = (udma_q->comp_head_idx - udma_q->next_cdesc_idx) &
+		udma_q->size_mask;
+
+	if (cdesc)
+		*cdesc = al_udma_cdesc_idx_to_ptr(udma_q, udma_q->next_cdesc_idx);
+
+	return count;
+}
+
+/*
+ * acknowledge the driver that the upper layer completed processing completion
+ * descriptors
+ *
+ * @param udma_q udma queue handle
+ * @param num number of descriptors to acknowledge
+ */
+static inline void al_udma_cdesc_ack(struct al_udma_q *udma_q, u32 num)
+{
+	udma_q->next_cdesc_idx += num;
+	udma_q->next_cdesc_idx &= udma_q->size_mask;
+}
+
+#endif /* __AL_HW_UDMA_H__ */
diff --git a/include/linux/soc/alpine/al_hw_udma_config.h b/include/linux/soc/alpine/al_hw_udma_config.h
new file mode 100644
index 000000000000..0245d2a51459
--- /dev/null
+++ b/include/linux/soc/alpine/al_hw_udma_config.h
@@ -0,0 +1,75 @@
+/*
+ * Copyright (C) 2017, Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#ifndef __AL_HW_UDMA_CONFIG_H__
+#define __AL_HW_UDMA_CONFIG_H__
+
+#include "al_hw_udma_regs.h"
+#include "al_hw_udma.h"
+
+/* M2S max packet size configuration */
+struct al_udma_m2s_pkt_len_conf {
+	u32 max_pkt_size;
+	bool encode_64k_as_zero;
+};
+
+/* M2S DMA Rate Limitation mode */
+struct al_udma_m2s_rlimit_mode {
+	bool pkt_mode_en;
+	u16 short_cycle_sz;
+	u32 token_init_val;
+};
+
+enum al_udma_m2s_rlimit_action {
+	AL_UDMA_STRM_RLIMIT_ENABLE,
+	AL_UDMA_STRM_RLIMIT_PAUSE,
+	AL_UDMA_STRM_RLIMIT_RESET
+};
+
+/* UDMA / UDMA Q rate limitation configuration */
+struct al_udma_m2s_rlimit {
+	struct al_udma_m2s_rlimit_mode rlimit_mode; /* rate limitation enablers */
+};
+
+/* Configure M2S packet len */
+int al_udma_m2s_packet_size_cfg_set(struct al_udma *udma,
+				    struct al_udma_m2s_pkt_len_conf *conf);
+
+void al_udma_s2m_max_descs_set(struct al_udma *udma, u8 max_descs);
+void al_udma_m2s_max_descs_set(struct al_udma *udma, u8 max_descs);
+
+/* UDMA get revision */
+static inline unsigned int al_udma_get_revision(
+		struct unit_regs __iomem *unit_regs)
+{
+	return (readl(&unit_regs->gen.dma_misc.revision)
+			& UDMA_GEN_DMA_MISC_REVISION_PROGRAMMING_ID_MASK) >>
+			UDMA_GEN_DMA_MISC_REVISION_PROGRAMMING_ID_SHIFT;
+}
+
+/*
+ * S2M UDMA configure a queue's completion descriptors coalescing
+ *
+ * @param q_udma
+ * @param enable set to true to enable completion coalescing
+ * @param coal_timeout in South Bridge cycles.
+ */
+void al_udma_s2m_q_compl_coal_config(struct al_udma_q *udma_q, bool enable,
+				     u32 coal_timeout);
+
+/*
+ * S2M UDMA configure completion descriptors write burst parameters
+ *
+ * @param udma
+ * @param burst_size completion descriptors write burst size in bytes.
+ *
+ * @return 0 if no error found.
+ */
+int al_udma_s2m_compl_desc_burst_config(struct al_udma *udma, u16 burst_size);
+
+#endif /* __AL_HW_UDMA_CONFIG_H__ */
diff --git a/include/linux/soc/alpine/al_hw_udma_iofic.h b/include/linux/soc/alpine/al_hw_udma_iofic.h
new file mode 100644
index 000000000000..f55c4b608857
--- /dev/null
+++ b/include/linux/soc/alpine/al_hw_udma_iofic.h
@@ -0,0 +1,199 @@
+/*
+ * Copyright (C) 2017, Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#ifndef __AL_HW_UDMA_IOFIC_H__
+#define __AL_HW_UDMA_IOFIC_H__
+
+#include <linux/soc/alpine/iofic.h>
+
+#include "al_hw_udma_regs.h"
+
+/*
+ * Interrupt Mode
+ * This is the interrupt mode for the primary interrupt level The secondary
+ * interrupt level does not have mode and it is always a level sensitive
+ * interrupt that is reflected in group D of the primary.
+ */
+enum al_iofic_mode {
+	AL_IOFIC_MODE_LEGACY, /*< level-sensitive interrupt wire */
+	AL_IOFIC_MODE_MSIX_PER_Q, /*< per UDMA queue MSI-X interrupt */
+	AL_IOFIC_MODE_MSIX_PER_GROUP
+};
+
+/* interrupt controller level (primary/secondary) */
+enum al_udma_iofic_level {
+	AL_UDMA_IOFIC_LEVEL_PRIMARY,
+	AL_UDMA_IOFIC_LEVEL_SECONDARY
+};
+
+/*
+ * The next four groups represents the standard 4 groups in the primary
+ * interrupt controller of each bus-master unit in the I/O Fabric.
+ * The first two groups can be used when accessing the secondary interrupt
+ * controller as well.
+ */
+#define AL_INT_GROUP_A		0 /* summary of the below events */
+#define AL_INT_GROUP_B		1 /* RX completion queues */
+#define AL_INT_GROUP_C		2 /* TX completion queues */
+#define AL_INT_GROUP_D		3 /* Misc */
+
+/*
+ * Primary interrupt controller, group A bits
+ * Group A bits which are just summary bits of GROUP B, C and D
+ */
+#define AL_INT_GROUP_A_GROUP_B_SUM	BIT(0)
+#define AL_INT_GROUP_A_GROUP_C_SUM	BIT(1)
+#define AL_INT_GROUP_A_GROUP_D_SUM	BIT(2)
+
+/*
+ * Configure the UDMA interrupt controller registers, interrupts will are kept
+ * masked.
+ *
+ * This is a static setting that should be called while initialized the
+ * interrupt controller within a given UDMA, and should not be modified during
+ * runtime unless the UDMA is completely disabled. The first argument sets the
+ * interrupt and MSIX modes. The m2s/s2m errors/abort are a set of bit-wise
+ * masks to define the behaviour of the UDMA once an error happens: The _abort
+ * will put the UDMA in abort state once an error happens The _error bitmask
+ * will indicate and error in the secondary cause register but will not abort.
+ * The bit-mask that the _errors_disable and _aborts_disable are described in
+ * 'AL_INT_2ND_GROUP_A_*' and 'AL_INT_2ND_GROUP_B_*'
+ *
+ * @param regs pointer to unit registers
+ * @param mode interrupt scheme mode (legacy, MSI-X..)
+ * @param m2s_errors_disable
+ * 	  This is a bit-wise mask, to indicate which one of the error causes in
+ * 	  secondary interrupt group_A should generate an interrupt. When a bit is
+ * 	  set, the error cause is ignored.
+ * 	  Recommended value: 0 (enable all errors).
+ * @param m2s_aborts_disable
+ * 	  This is a bit-wise mask, to indicate which one of the error causes in
+ * 	  secondary interrupt group_A should automatically put the UDMA in
+ * 	  abort state. When a bit is set, the error cause does cause an abort.
+ * 	  Recommended value: 0 (enable all aborts).
+ * @param s2m_errors_disable
+ * 	  This is a bit-wise mask, to indicate which one of the error causes in
+ * 	  secondary interrupt group_A should generate an interrupt. When a bit is
+ * 	  set, the error cause is ignored.
+ * 	  Recommended value: 0xE0 (disable hint errors).
+ * @param s2m_aborts_disable
+ * 	  This is a bit-wise mask, to indicate which one of the error causes in
+ * 	  secondary interrupt group_A should automatically put the UDMA in
+ * 	  abort state. When a bit is set, the error cause does cause an abort.
+ * 	  Recommended value: 0xE0 (disable hint aborts).
+ *
+ * @return 0 on success. -EINVAL otherwise.
+ */
+int al_udma_iofic_config(struct unit_regs __iomem *regs,
+			 enum al_iofic_mode mode, u32 m2s_errors_disable,
+			 u32 m2s_aborts_disable, u32 s2m_errors_disable,
+			 u32 s2m_aborts_disable);
+/*
+ * return the offset of the unmask register for a given group.
+ * this function can be used when the upper layer wants to directly
+ * access the unmask regiter and bypass the al_udma_iofic_unmask() API.
+ *
+ * @param regs pointer to udma registers
+ * @param level the interrupt controller level (primary / secondary)
+ * @param group the interrupt group ('AL_INT_GROUP_*')
+ * @return the offset of the unmask register.
+ */
+u32 __iomem *al_udma_iofic_unmask_offset_get(struct unit_regs __iomem *regs,
+					     enum al_udma_iofic_level level,
+					     int group);
+
+/*
+ * Get the interrupt controller base address for either the primary or secondary
+ * interrupt controller
+ *
+ * @param regs pointer to udma unit registers
+ * @param level the interrupt controller level (primary / secondary)
+ *
+ * @returns	The interrupt controller base address
+ */
+static inline void __iomem *al_udma_iofic_reg_base_get(
+	struct unit_regs __iomem *regs, enum al_udma_iofic_level level)
+{
+	void __iomem *iofic_regs = (level == AL_UDMA_IOFIC_LEVEL_PRIMARY) ?
+		(void __iomem *)&regs->gen.interrupt_regs.main_iofic :
+		(void __iomem *)&regs->gen.interrupt_regs.secondary_iofic_ctrl;
+
+	return iofic_regs;
+}
+
+/*
+ * Check the interrupt controller level/group validity
+ *
+ * @param level the interrupt controller level (primary / secondary)
+ * @param group the interrupt group ('AL_INT_GROUP_*')
+ *
+ * @returns	0 - invalid, 1 - valid
+ */
+static inline int al_udma_iofic_level_and_group_valid(
+		enum al_udma_iofic_level level, int group)
+{
+	if (((level == AL_UDMA_IOFIC_LEVEL_PRIMARY) && (group >= 0) && (group < 4)) ||
+		((level == AL_UDMA_IOFIC_LEVEL_SECONDARY) && (group >= 0) && (group < 2)))
+		return 1;
+
+	return 0;
+}
+/*
+ * unmask specific interrupts for a given group
+ * this functions uses the interrupt mask clear register to guarantee atomicity
+ * it's safe to call it while the mask is changed by the HW (auto mask) or
+ * another cpu.
+ *
+ * @param regs pointer to udma unit registers
+ * @param level the interrupt controller level (primary / secondary)
+ * @param group the interrupt group ('AL_INT_GROUP_*')
+ * @param mask bitwise of interrupts to unmask, set bits will be unmasked.
+ */
+static inline void al_udma_iofic_unmask(struct unit_regs __iomem *regs,
+					enum al_udma_iofic_level level,
+					int group, u32 mask)
+{
+	BUG_ON(!al_udma_iofic_level_and_group_valid(level, group));
+	al_iofic_unmask(al_udma_iofic_reg_base_get(regs, level), group, mask);
+}
+
+/*
+ * mask specific interrupts for a given group
+ * this functions modifies interrupt mask register, the callee must make sure
+ * the mask is not changed by another cpu.
+ *
+ * @param regs pointer to udma unit registers
+ * @param level the interrupt controller level (primary / secondary)
+ * @param group the interrupt group ('AL_INT_GROUP_*')
+ * @param mask bitwise of interrupts to mask, set bits will be masked.
+ */
+static inline void al_udma_iofic_mask(struct unit_regs __iomem *regs,
+				      enum al_udma_iofic_level level, int group,
+				      u32 mask)
+{
+	BUG_ON(!al_udma_iofic_level_and_group_valid(level, group));
+	al_iofic_mask(al_udma_iofic_reg_base_get(regs, level), group, mask);
+}
+
+/*
+ * read interrupt cause register for a given group
+ * this will clear the set bits if the Clear on Read mode enabled.
+ * @param regs pointer to udma unit registers
+ * @param level the interrupt controller level (primary / secondary)
+ * @param group the interrupt group ('AL_INT_GROUP_*')
+ */
+static inline u32 al_udma_iofic_read_cause(struct unit_regs __iomem *regs,
+					   enum al_udma_iofic_level level,
+					   int group)
+{
+	BUG_ON(!al_udma_iofic_level_and_group_valid(level, group));
+	return al_iofic_read_cause(al_udma_iofic_reg_base_get(regs, level),
+				   group);
+}
+
+#endif
diff --git a/include/linux/soc/alpine/al_hw_udma_regs.h b/include/linux/soc/alpine/al_hw_udma_regs.h
new file mode 100644
index 000000000000..8ae3ceaa3753
--- /dev/null
+++ b/include/linux/soc/alpine/al_hw_udma_regs.h
@@ -0,0 +1,134 @@
+/*
+ * Copyright (C) 2017, Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#ifndef __AL_HW_UDMA_REG_H
+#define __AL_HW_UDMA_REG_H
+
+#include "al_hw_udma_regs_m2s.h"
+#include "al_hw_udma_regs_s2m.h"
+
+
+/* Design programming interface  revision ID */
+#define UDMA_GEN_DMA_MISC_REVISION_PROGRAMMING_ID_MASK	0xfff
+#define UDMA_GEN_DMA_MISC_REVISION_PROGRAMMING_ID_SHIFT	0x0
+
+struct al_iofic_grp_mod {
+	u32 grp_int_mod_reg;
+	u32 grp_int_tgtid_reg;
+};
+
+struct al_iofic_grp_ctrl {
+	u32 int_cause_grp;
+	u32 rsrvd1;
+	u32 int_cause_set_grp;
+	u32 rsrvd2;
+	u32 int_mask_grp;
+	u32 rsrvd3;
+	u32 int_mask_clear_grp;
+	u32 rsrvd4;
+	u32 int_status_grp;
+	u32 rsrvd5;
+	u32 int_control_grp;
+	u32 rsrvd6;
+	u32 int_abort_msk_grp;
+	u32 rsrvd7;
+	u32 int_log_msk_grp;
+	u32 rsrvd8;
+};
+
+struct al_iofic_regs {
+	struct al_iofic_grp_ctrl ctrl[0];
+	u32 rsrvd1[0x100];
+	struct al_iofic_grp_mod grp_int_mod[0][32];
+};
+
+struct udma_iofic_regs {
+	struct al_iofic_regs main_iofic;
+	u32 rsrvd1[0x700];
+	struct al_iofic_grp_ctrl secondary_iofic_ctrl[2];
+};
+
+struct udma_gen_dma_misc {
+	u32 int_cfg;
+	u32 revision;
+	u32 general_cfg_1;
+	u32 general_cfg_2;
+	u32 general_cfg_3;
+	u32 general_cfg_4;
+	u32 general_cfg_5;
+	u32 rsrvd[57];
+};
+
+/*
+ * Mailbox interrupt generator.
+ * Generates interrupt to neighbor DMA
+ */
+struct udma_gen_mailbox {
+	u32 interrupt;
+	u32 msg_out;
+	u32 msg_in;
+	u32 rsrvd[0xd];
+};
+
+struct udma_gen_axi {
+	u32 cfg_1;
+	u32 cfg_2;
+	u32 endian_cfg;
+	u32 rsrvd[0x3d];
+};
+
+struct udma_gen_regs {
+	struct udma_iofic_regs interrupt_regs;
+	struct udma_gen_dma_misc dma_misc;
+	struct udma_gen_mailbox mailbox[4];
+	struct udma_gen_axi axi;
+};
+
+/* UDMA registers, either m2s or s2m */
+union udma_regs {
+	struct udma_m2s_regs m2s;
+	struct udma_s2m_regs s2m;
+};
+
+struct unit_regs {
+	struct udma_m2s_regs m2s;
+	u32 rsrvd0[0x2c00];
+	struct udma_s2m_regs s2m;
+	u32 rsrvd1[0x1c00];
+	struct udma_gen_regs gen;
+};
+
+/*
+ * UDMA submission and completion registers, M2S and S2M UDMAs have same
+ * stucture
+ */
+struct udma_rings_regs {
+	u32 rsrvd0[8];
+	u32 cfg;		/* Descriptor ring configuration */
+	u32 status;		/* Descriptor ring status and information */
+	u32 drbp_low;		/* Descriptor Ring Base Pointer [31:4] */
+	u32 drbp_high;		/* Descriptor Ring Base Pointer [63:32] */
+	u32 drl;		/* Descriptor Ring Length[23:2] */
+	u32 drhp;		/* Descriptor Ring Head Pointer */
+	u32 drtp_inc;		/* Descriptor Tail Pointer increment */
+	u32 drtp;		/* Descriptor Tail Pointer */
+	u32 dcp;		/* Descriptor Current Pointer */
+	u32 crbp_low;		/* Completion Ring Base Pointer [31:4] */
+	u32 crbp_high;		/* Completion Ring Base Pointer [63:32] */
+	u32 crhp;		/* Completion Ring Head Pointer */
+	u32 crhp_internal;	/* Completion Ring Head Pointer internal */
+};
+
+/* M2S and S2M generic structure of Q registers */
+union udma_q_regs {
+	struct udma_rings_regs	rings;
+	struct udma_m2s_q	m2s_q;
+	struct udma_s2m_q	s2m_q;
+};
+
+#endif /* __AL_HW_UDMA_REG_H */
diff --git a/include/linux/soc/alpine/al_hw_udma_regs_m2s.h b/include/linux/soc/alpine/al_hw_udma_regs_m2s.h
new file mode 100644
index 000000000000..78a04de9df27
--- /dev/null
+++ b/include/linux/soc/alpine/al_hw_udma_regs_m2s.h
@@ -0,0 +1,413 @@
+/*
+ * Copyright (C) 2015, Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#ifndef __AL_HW_UDMA_M2S_REG_H
+#define __AL_HW_UDMA_M2S_REG_H
+
+#include <linux/types.h>
+
+struct udma_axi_m2s {
+	/* Completion write master configuration */
+	u32 comp_wr_cfg_1;
+	/* Completion write master configuration */
+	u32 comp_wr_cfg_2;
+	/* Data read master configuration */
+	u32 data_rd_cfg_1;
+	/* Data read master configuration */
+	u32 data_rd_cfg_2;
+	/* Descriptor read master configuration */
+	u32 desc_rd_cfg_1;
+	/* Descriptor read master configuration */
+	u32 desc_rd_cfg_2;
+	/* Data read master configuration */
+	u32 data_rd_cfg;
+	/* Descriptors read master configuration */
+	u32 desc_rd_cfg_3;
+	/* Descriptors write master configuration (completion) */
+	u32 desc_wr_cfg_1;
+	/* AXI outstanding  configuration */
+	u32 ostand_cfg;
+	u32 rsrvd[54];
+};
+struct udma_m2s {
+	/*
+	 * DMA state.
+	 * 00  - No pending tasks
+	 * 01 – Normal (active)
+	 * 10 – Abort (error condition)
+	 * 11 – Reserved
+	 */
+	u32 state;
+	/* CPU request to change DMA state */
+	u32 change_state;
+	u32 rsrvd_0;
+	/*
+	 * M2S DMA error log mask.
+	 * Each error has an interrupt controller cause bit.
+	 * This register determines if these errors cause the M2S DMA to log the
+	 * error condition.
+	 * 0 - Log is enabled.
+	 * 1 - Log is masked.
+	 */
+	u32 err_log_mask;
+	u32 rsrvd_1;
+	/*
+	 * DMA header log.
+	 * Sample the packet header that caused the error.
+	 */
+	u32 log_0;
+	/*
+	 * DMA header log.
+	 * Sample the packet header that caused the error.
+	 */
+	u32 log_1;
+	/*
+	 * DMA header log.
+	 * Sample the packet header that caused the error.
+	 */
+	u32 log_2;
+	/*
+	 * DMA header log.
+	 * Sample the packet header that caused the error.
+	 */
+	u32 log_3;
+	/* DMA clear error log */
+	u32 clear_err_log;
+	/* M2S data FIFO status */
+	u32 data_fifo_status;
+	/* M2S header FIFO status */
+	u32 header_fifo_status;
+	/* M2S unack FIFO status */
+	u32 unack_fifo_status;
+	/* Select queue for debug */
+	u32 indirect_ctrl;
+	/*
+	 * M2S prefetch FIFO status.
+	 * Status of the selected queue in M2S_indirect_ctrl
+	 */
+	u32 sel_pref_fifo_status;
+	/*
+	 * M2S completion FIFO status.
+	 * Status of the selected queue in M2S_indirect_ctrl
+	 */
+	u32 sel_comp_fifo_status;
+	/*
+	 * M2S rate limit status.
+	 * Status of the selected queue in M2S_indirect_ctrl
+	 */
+	u32 sel_rate_limit_status;
+	/*
+	 * M2S DWRR scheduler status.
+	 * Status of the selected queue in M2S_indirect_ctrl
+	 */
+	u32 sel_dwrr_status;
+	/* M2S state machine and FIFO clear control */
+	u32 clear_ctrl;
+	/* Misc Check enable */
+	u32 check_en;
+	/* M2S FIFO enable control, internal */
+	u32 fifo_en;
+	/* M2S packet length configuration */
+	u32 cfg_len;
+	/* Stream interface configuration */
+	u32 stream_cfg;
+	u32 rsrvd[41];
+};
+struct udma_m2s_rd {
+	/* M2S descriptor prefetch configuration */
+	u32 desc_pref_cfg_1;
+	/* M2S descriptor prefetch configuration */
+	u32 desc_pref_cfg_2;
+	/* M2S descriptor prefetch configuration */
+	u32 desc_pref_cfg_3;
+	u32 rsrvd_0;
+	/* Data burst read configuration */
+	u32 data_cfg;
+	u32 rsrvd[11];
+};
+struct udma_m2s_dwrr {
+	/* Tx DMA DWRR scheduler configuration */
+	u32 cfg_sched;
+	/* Token bucket rate limit control */
+	u32 ctrl_deficit_cnt;
+	u32 rsrvd[14];
+};
+struct udma_m2s_rate_limiter {
+	/* Token bucket rate limit configuration */
+	u32 gen_cfg;
+	/*
+	 * Token bucket rate limit control.
+	 * Controls the cycle counters.
+	 */
+	u32 ctrl_cycle_cnt;
+	/*
+	 * Token bucket rate limit control.
+	 * Controls the token bucket counter.
+	 */
+	u32 ctrl_token;
+	u32 rsrvd[13];
+};
+
+struct udma_rlimit_common {
+	/* Token bucket configuration */
+	u32 cfg_1s;
+	/* Token bucket rate limit configuration */
+	u32 cfg_cycle;
+	/* Token bucket rate limit configuration */
+	u32 cfg_token_size_1;
+	/* Token bucket rate limit configuration */
+	u32 cfg_token_size_2;
+	/* Token bucket rate limit configuration */
+	u32 sw_ctrl;
+	/*
+	 * Mask the different types of rate limiter.
+	 * 0 - Rate limit is active.
+	 * 1 - Rate limit is masked.
+	 */
+	u32 mask;
+};
+
+struct udma_m2s_stream_rate_limiter {
+	struct udma_rlimit_common rlimit;
+	u32 rsrvd[10];
+};
+struct udma_m2s_comp {
+	/* Completion controller configuration */
+	u32 cfg_1c;
+	/* Completion controller coalescing configuration */
+	u32 cfg_coal;
+	/* Completion controller application acknowledge configuration */
+	u32 cfg_application_ack;
+	u32 rsrvd[61];
+};
+struct udma_m2s_stat {
+	/* Statistics counters configuration */
+	u32 cfg_st;
+	/* Counting number of descriptors with First-bit set. */
+	u32 tx_pkt;
+	/*
+	 *  Counting the net length of the data buffers [64-bit]
+	 * Should be read before tx_bytes_high
+	 */
+	u32 tx_bytes_low;
+	/*
+	 *  Counting the net length of the data buffers [64-bit],
+	 * Should be read after tx_bytes_low (value is sampled when reading
+	 * Should be read before tx_bytes_low
+	 */
+	u32 tx_bytes_high;
+	/* Total number of descriptors read from the host memory */
+	u32 prefed_desc;
+	/* Number of packets read from the unack FIFO */
+	u32 comp_pkt;
+	/* Number of descriptors written into the completion ring */
+	u32 comp_desc;
+	/*
+	 *  Number of acknowledged packets.
+	 * (acknowledge received from the stream interface)
+	 */
+	u32 ack_pkts;
+	u32 rsrvd[56];
+};
+struct udma_m2s_feature {
+	/*
+	 *  M2S Feature register.
+	 * M2S instantiation parameters
+	 */
+	u32 reg_1;
+	/* Reserved M2S feature register */
+	u32 reg_2;
+	/*
+	 *  M2S Feature register.
+	 * M2S instantiation parameters
+	 */
+	u32 reg_3;
+	/*
+	 *  M2S Feature register.
+	 * M2S instantiation parameters
+	 */
+	u32 reg_4;
+	/*
+	 *  M2S Feature register.
+	 * M2S instantiation parameters
+	 */
+	u32 reg_5;
+	u32 rsrvd[59];
+};
+struct udma_m2s_q {
+	u32 rsrvd_0[8];
+	/* M2S descriptor ring configuration */
+	u32 cfg;
+	/* M2S descriptor ring status and information */
+	u32 status;
+	/* TX Descriptor Ring Base Pointer [31:4] */
+	u32 tdrbp_low;
+	/* TX Descriptor Ring Base Pointer [63:32] */
+	u32 tdrbp_high;
+	/*
+	 *  TX Descriptor Ring Length[23:2]
+	 */
+	u32 tdrl;
+	/* TX Descriptor Ring Head Pointer */
+	u32 tdrhp;
+	/* Tx Descriptor Tail Pointer increment */
+	u32 tdrtp_inc;
+	/* Tx Descriptor Tail Pointer */
+	u32 tdrtp;
+	/* TX Descriptor Current Pointer */
+	u32 tdcp;
+	/* Tx Completion Ring Base Pointer [31:4] */
+	u32 tcrbp_low;
+	/* TX Completion Ring Base Pointer [63:32] */
+	u32 tcrbp_high;
+	/* TX Completion Ring Head Pointer */
+	u32 tcrhp;
+	/*
+	 *  Tx Completion Ring Head Pointer internal (Before the
+	 * coalescing FIFO)
+	 */
+	u32 tcrhp_internal;
+	u32 rsrvd_1[3];
+	/* Rate limit configuration */
+	struct udma_rlimit_common rlimit;
+	u32 rsrvd_2[2];
+	/* DWRR scheduler configuration */
+	u32 dwrr_cfg_1;
+	/* DWRR scheduler configuration */
+	u32 dwrr_cfg_2;
+	/* DWRR scheduler configuration */
+	u32 dwrr_cfg_3;
+	/* DWRR scheduler software control */
+	u32 dwrr_sw_ctrl;
+	u32 rsrvd_3[4];
+	/* Completion controller configuration */
+	u32 comp_cfg;
+	u32 rsrvd_4[3];
+	/* SW control  */
+	u32 q_sw_ctrl;
+	u32 rsrvd_5[3];
+	/* Number of M2S Tx packets after the scheduler */
+	u32 q_tx_pkt;
+	u32 rsrvd[975];
+};
+
+struct udma_m2s_regs {
+	u32 rsrvd_0[64];
+	struct udma_axi_m2s axi_m2s;
+	struct udma_m2s m2s;
+	struct udma_m2s_rd m2s_rd;
+	struct udma_m2s_dwrr m2s_dwrr;
+	struct udma_m2s_rate_limiter m2s_rate_limiter;
+	struct udma_m2s_stream_rate_limiter m2s_stream_rate_limiter;
+	struct udma_m2s_comp m2s_comp;
+	struct udma_m2s_stat m2s_stat;
+	struct udma_m2s_feature m2s_feature;
+	u32 rsrvd_1[576];
+	struct udma_m2s_q m2s_q[4];
+};
+
+
+/* Completion control */
+#define UDMA_M2S_STATE_COMP_CTRL_MASK 0x00000003
+#define UDMA_M2S_STATE_COMP_CTRL_SHIFT 0
+/* Stream interface */
+#define UDMA_M2S_STATE_STREAM_IF_MASK 0x00000030
+#define UDMA_M2S_STATE_STREAM_IF_SHIFT 4
+/* Data read control */
+#define UDMA_M2S_STATE_DATA_RD_CTRL_MASK 0x00000300
+#define UDMA_M2S_STATE_DATA_RD_CTRL_SHIFT 8
+/* Descriptor prefetch */
+#define UDMA_M2S_STATE_DESC_PREF_MASK 0x00003000
+#define UDMA_M2S_STATE_DESC_PREF_SHIFT 12
+
+/* Start normal operation */
+#define UDMA_M2S_CHANGE_STATE_NORMAL BIT(0)
+/* Stop normal operation */
+#define UDMA_M2S_CHANGE_STATE_DIS    BIT(1)
+/*
+ * Stop all machines.
+ * (Prefetch, scheduling, completion and stream interface)
+ */
+#define UDMA_M2S_CHANGE_STATE_ABORT  BIT(2)
+
+/* Maximum packet size for the M2S */
+#define UDMA_M2S_CFG_LEN_MAX_PKT_SIZE_MASK 0x000FFFFF
+/*
+ * Length encoding for 64K.
+ * 0 - length 0x0000 = 0
+ * 1 - length 0x0000 = 64k
+ */
+#define UDMA_M2S_CFG_LEN_ENCODE_64K  BIT(24)
+
+/* Maximum number of descriptors per packet */
+#define UDMA_M2S_RD_DESC_PREF_CFG_2_MAX_DESC_PER_PKT_MASK 0x0000001F
+#define UDMA_M2S_RD_DESC_PREF_CFG_2_MAX_DESC_PER_PKT_SHIFT 0
+/*
+ * Minimum descriptor burst size when prefetch FIFO level is above the
+ * descriptor prefetch threshold
+ */
+#define UDMA_M2S_RD_DESC_PREF_CFG_3_MIN_BURST_ABOVE_THR_MASK 0x000000F0
+#define UDMA_M2S_RD_DESC_PREF_CFG_3_MIN_BURST_ABOVE_THR_SHIFT 4
+/*
+ * Descriptor fetch threshold.
+ * Used as a threshold to determine the allowed minimum descriptor burst size.
+ * (Must be at least max_desc_per_pkt)
+ */
+#define UDMA_M2S_RD_DESC_PREF_CFG_3_PREF_THR_MASK 0x0000FF00
+#define UDMA_M2S_RD_DESC_PREF_CFG_3_PREF_THR_SHIFT 8
+
+/*
+ * Maximum number of data beats in the data read FIFO.
+ * Defined based on data FIFO size
+ * (default FIFO size 2KB → 128 beats)
+ */
+#define UDMA_M2S_RD_DATA_CFG_DATA_FIFO_DEPTH_MASK 0x000003FF
+#define UDMA_M2S_RD_DATA_CFG_DATA_FIFO_DEPTH_SHIFT 0
+
+/*
+ * Enable operation of this queue.
+ * Start prefetch.
+ */
+#define UDMA_M2S_Q_CFG_EN_PREF       BIT(16)
+/*
+ * Enable operation of this queue.
+ * Start scheduling.
+ */
+#define UDMA_M2S_Q_CFG_EN_SCHEDULING BIT(17)
+
+/*
+ * M2S Descriptor Ring Base address [31:4].
+ * Value of the base address of the M2S descriptor ring
+ * [3:0] - 0 - 16B alignment is enforced
+ * ([11:4] should be 0 for 4KB alignment)
+ */
+#define UDMA_M2S_Q_TDRBP_LOW_ADDR_MASK 0xFFFFFFF0
+
+/*
+ * M2S Descriptor Ring Base address [31:4].
+ * Value of the base address of the M2S descriptor ring
+ * [3:0] - 0 - 16B alignment is enforced
+ * ([11:4] should be 0 for 4KB alignment)
+ * NOTE:
+ * Length of the descriptor ring (in descriptors) associated with the ring base
+ * address. Ends at maximum burst size alignment.
+ */
+#define UDMA_M2S_Q_TCRBP_LOW_ADDR_MASK 0xFFFFFFF0
+
+/*
+ * Mask the internal pause mechanism for DMB.
+ * (Data Memory Barrier).
+ */
+#define UDMA_M2S_Q_RATE_LIMIT_MASK_INTERNAL_PAUSE_DMB BIT(2)
+
+/* Enable writing to the completion ring */
+#define UDMA_M2S_Q_COMP_CFG_EN_COMP_RING_UPDATE BIT(0)
+/* Disable the completion coalescing function. */
+#define UDMA_M2S_Q_COMP_CFG_DIS_COMP_COAL BIT(1)
+
+#endif /* __AL_HW_UDMA_M2S_REG_H */
diff --git a/include/linux/soc/alpine/al_hw_udma_regs_s2m.h b/include/linux/soc/alpine/al_hw_udma_regs_s2m.h
new file mode 100644
index 000000000000..e23480718844
--- /dev/null
+++ b/include/linux/soc/alpine/al_hw_udma_regs_s2m.h
@@ -0,0 +1,294 @@
+/*
+ * Copyright (C) 2017, Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#ifndef __AL_HW_UDMA_S2M_REG_H
+#define __AL_HW_UDMA_S2M_REG_H
+
+struct udma_axi_s2m {
+	/* Data write master configuration */
+	u32 data_wr_cfg_1;
+	/* Data write master configuration */
+	u32 data_wr_cfg_2;
+	/* Descriptor read master configuration */
+	u32 desc_rd_cfg_4;
+	/* Descriptor read master configuration */
+	u32 desc_rd_cfg_5;
+	/* Completion  write master configuration */
+	u32 comp_wr_cfg_1;
+	/* Completion  write master configuration */
+	u32 comp_wr_cfg_2;
+	/* Data write master configuration */
+	u32 data_wr_cfg;
+	/* Descriptors read master configuration */
+	u32 desc_rd_cfg_3;
+	/* Completion descriptors write master configuration */
+	u32 desc_wr_cfg_1;
+	/* AXI outstanding read configuration */
+	u32 ostand_cfg_rd;
+	/* AXI outstanding write configuration */
+	u32 ostand_cfg_wr;
+	u32 rsrvd[53];
+};
+struct udma_s2m {
+	/*
+	 * DMA state
+	 * 00  - No pending tasks
+	 * 01 – Normal (active)
+	 * 10 – Abort (error condition)
+	 * 11 – Reserved
+	 */
+	u32 state;
+	/* CPU request to change DMA state */
+	u32 change_state;
+	u32 rsrvd_0;
+	/*
+	 * S2M DMA error log mask.
+	 * Each error has an interrupt controller cause bit.
+	 * This register determines if these errors cause the S2M DMA to log the
+	 * error condition.
+	 * 0 - Log is enable
+	 * 1 - Log is masked.
+	 */
+	u32 err_log_mask;
+	u32 rsrvd_1;
+	/*
+	 * DMA header log
+	 * Sample the packet header that caused the error
+	 */
+	u32 log_0;
+	/*
+	 * DMA header log
+	 * Sample the packet header that caused the error.
+	 */
+	u32 log_1;
+	/*
+	 * DMA header log
+	 * Sample the packet header that caused the error.
+	 */
+	u32 log_2;
+	/*
+	 * DMA header log
+	 * Sample the packet header that caused the error
+	 */
+	u32 log_3;
+	/* DMA clear error log */
+	u32 clear_err_log;
+	/* S2M stream data FIFO status */
+	u32 s_data_fifo_status;
+	/* S2M stream header FIFO status */
+	u32 s_header_fifo_status;
+	/* S2M AXI data FIFO status */
+	u32 axi_data_fifo_status;
+	/* S2M unack FIFO status */
+	u32 unack_fifo_status;
+	/* Select queue for debug */
+	u32 indirect_ctrl;
+	/*
+	 * S2M prefetch FIFO status.
+	 * Status of the selected queue in S2M_indirect_ctrl
+	 */
+	u32 sel_pref_fifo_status;
+	/*
+	 * S2M completion FIFO status.
+	 * Status of the selected queue in S2M_indirect_ctrl
+	 */
+	u32 sel_comp_fifo_status;
+	/* S2M state machine and FIFO clear control */
+	u32 clear_ctrl;
+	/* S2M Misc Check enable */
+	u32 check_en;
+	/* S2M FIFO enable control, internal */
+	u32 fifo_en;
+	/* Stream interface configuration */
+	u32 stream_cfg;
+	u32 rsrvd[43];
+};
+struct udma_s2m_rd {
+	/* S2M descriptor prefetch configuration */
+	u32 desc_pref_cfg_1;
+	/* S2M descriptor prefetch configuration */
+	u32 desc_pref_cfg_2;
+	/* S2M descriptor prefetch configuration */
+	u32 desc_pref_cfg_3;
+	/* S2M descriptor prefetch configuration */
+	u32 desc_pref_cfg_4;
+	u32 rsrvd[12];
+};
+struct udma_s2m_wr {
+	/* Stream data FIFO configuration */
+	u32 data_cfg_1;
+	/* Data write configuration */
+	u32 data_cfg_2;
+	u32 rsrvd[14];
+};
+struct udma_s2m_comp {
+	/* Completion controller configuration */
+	u32 cfg_1c;
+	/* Completion controller configuration */
+	u32 cfg_2c;
+	u32 rsrvd_0;
+	/* Completion controller application acknowledge configuration */
+	u32 cfg_application_ack;
+	u32 rsrvd[12];
+};
+struct udma_s2m_stat {
+	u32 rsrvd_0;
+	/* Number of dropped packets */
+	u32 drop_pkt;
+	/*
+	 * Counting the net length of the data buffers [64-bit]
+	 * Should be read before rx_bytes_high
+	 */
+	u32 rx_bytes_low;
+	/*
+	 * Counting the net length of the data buffers [64-bit]
+	 * Should be read after tx_bytes_low (value is sampled when reading
+	 * Should be read before rx_bytes_low
+	 */
+	u32 rx_bytes_high;
+	/* Total number of descriptors read from the host memory */
+	u32 prefed_desc;
+	/* Number of packets written into the completion ring */
+	u32 comp_pkt;
+	/* Number of descriptors written into the completion ring */
+	u32 comp_desc;
+	/*
+	 * Number of acknowledged packets.
+	 * (acknowledge sent to the stream interface)
+	 */
+	u32 ack_pkts;
+	u32 rsrvd[56];
+};
+struct udma_s2m_feature {
+	/*
+	 * S2M Feature register
+	 * S2M instantiation parameters
+	 */
+	u32 reg_1;
+	/* Reserved S2M feature register */
+	u32 reg_2;
+	/*
+	 * S2M Feature register
+	 * S2M instantiation parameters
+	 */
+	u32 reg_3;
+	/*
+	 * S2M Feature register.
+	 * S2M instantiation parameters.
+	 */
+	u32 reg_4;
+	/*
+	 * S2M Feature register.
+	 * S2M instantiation parameters.
+	 */
+	u32 reg_5;
+	/* S2M Feature register. S2M instantiation parameters. */
+	u32 reg_6;
+	u32 rsrvd[58];
+};
+struct udma_s2m_q {
+	u32 rsrvd_0[8];
+	/* S2M Descriptor ring configuration */
+	u32 cfg;
+	/* S2M Descriptor ring status and information */
+	u32 status;
+	/* Rx Descriptor Ring Base Pointer [31:4] */
+	u32 rdrbp_low;
+	/* Rx Descriptor Ring Base Pointer [63:32] */
+	u32 rdrbp_high;
+	/*
+	 * Rx Descriptor Ring Length[23:2]
+	 */
+	u32 rdrl;
+	/* RX Descriptor Ring Head Pointer */
+	u32 rdrhp;
+	/* Rx Descriptor Tail Pointer increment */
+	u32 rdrtp_inc;
+	/* Rx Descriptor Tail Pointer */
+	u32 rdrtp;
+	/* RX Descriptor Current Pointer */
+	u32 rdcp;
+	/* Rx Completion Ring Base Pointer [31:4] */
+	u32 rcrbp_low;
+	/* Rx Completion Ring Base Pointer [63:32] */
+	u32 rcrbp_high;
+	/* Rx Completion Ring Head Pointer */
+	u32 rcrhp;
+	/*
+	 * RX Completion Ring Head Pointer internal.
+	 * (Before the coalescing FIFO)
+	 */
+	u32 rcrhp_internal;
+	/* Completion controller configuration for the queue */
+	u32 comp_cfg;
+	/* Completion controller configuration for the queue */
+	u32 comp_cfg_2;
+	/* Packet handler configuration */
+	u32 pkt_cfg;
+	/* Queue QoS configuration */
+	u32 qos_cfg;
+	/* DMB software control */
+	u32 q_sw_ctrl;
+	/* Number of S2M Rx packets after completion  */
+	u32 q_rx_pkt;
+	u32 rsrvd[997];
+};
+
+struct udma_s2m_regs {
+	u32 rsrvd_0[64];
+	struct udma_axi_s2m axi_s2m;
+	struct udma_s2m s2m;
+	struct udma_s2m_rd s2m_rd;
+	struct udma_s2m_wr s2m_wr;
+	struct udma_s2m_comp s2m_comp;
+	u32 rsrvd_1[80];
+	struct udma_s2m_stat s2m_stat;
+	struct udma_s2m_feature s2m_feature;
+	u32 rsrvd_2[576];
+	struct udma_s2m_q s2m_q[4];
+};
+
+/*
+ * Defines the maximum number of AXI beats for a single AXI burst. This value is
+ * used for the burst split decision.
+ */
+#define UDMA_AXI_S2M_DESC_WR_CFG_1_MAX_AXI_BEATS_MASK 0x000000FF
+#define UDMA_AXI_S2M_DESC_WR_CFG_1_MAX_AXI_BEATS_SHIFT 0
+/*
+ * Minimum burst for writing completion descriptors.
+ * (AXI beats).
+ * Value must be aligned to cache lines (64 bytes).
+ * Default value is 2 cache lines, 8 beats.
+ */
+#define UDMA_AXI_S2M_DESC_WR_CFG_1_MIN_AXI_BEATS_MASK 0x00FF0000
+#define UDMA_AXI_S2M_DESC_WR_CFG_1_MIN_AXI_BEATS_SHIFT 16
+
+/*
+ * Minimum descriptor burst size when prefetch FIFO level is above the
+ * descriptor prefetch threshold
+ */
+#define UDMA_S2M_RD_DESC_PREF_CFG_3_MIN_BURST_ABOVE_THR_MASK 0x000000F0
+#define UDMA_S2M_RD_DESC_PREF_CFG_3_MIN_BURST_ABOVE_THR_SHIFT 4
+/*
+ * Descriptor fetch threshold.
+ * Used as a threshold to determine the allowed minimum descriptor burst size.
+ * (Must be at least "max_desc_per_pkt")
+ */
+#define UDMA_S2M_RD_DESC_PREF_CFG_3_PREF_THR_MASK 0x0000FF00
+#define UDMA_S2M_RD_DESC_PREF_CFG_3_PREF_THR_SHIFT 8
+
+/*
+ * Completion descriptor size.
+ * (words)
+ */
+#define UDMA_S2M_COMP_CFG_1C_DESC_SIZE_MASK 0x0000000F
+
+/* Disables the completion coalescing function. */
+#define UDMA_S2M_Q_COMP_CFG_DIS_COMP_COAL BIT(1)
+
+#endif /* __AL_HW_UDMA_S2M_REG_H */
-- 
2.11.0
