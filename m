From: Zhao Qiang <qiang.zhao@nxp.com>
Subject: [PATCH v2 4/5] fsl/qe: Add QE TDM lib
Date: Thu, 2 Jun 2016 09:45:00 +0800
Message-ID: <1464831901-15913-4-git-send-email-qiang.zhao@nxp.com>
References: <1464831901-15913-1-git-send-email-qiang.zhao@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <xiaobo.xie@nxp.com>,
	Zhao Qiang <qiang.zhao@nxp.com>
To: <oss@buserror.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464831901-15913-1-git-send-email-qiang.zhao@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

QE has module to support TDM, some other protocols
supported by QE are based on TDM.
add a qe-tdm lib, this lib provides functions to the protocols
using TDM to configurate QE-TDM.

Signed-off-by: Zhao Qiang <qiang.zhao@nxp.com>
---
Changes for v2:
	- delete dead code
	- use strcmp instead of strcasecmp
	- use of_find_compatible_node instead of of_find_by_name
	- use devm_ioremap_resource 
	- rename init_si to ucc_tdm_init
	- rename of_parse_tdm to ucc_of_parse_tdm
	- return err when there is not t1 or e1

 drivers/soc/fsl/qe/Kconfig    |   6 +-
 drivers/soc/fsl/qe/Makefile   |   1 +
 drivers/soc/fsl/qe/qe_tdm.c   | 276 ++++++++++++++++++++++++++++++++++++++++++
 include/soc/fsl/qe/immap_qe.h |   5 +-
 include/soc/fsl/qe/qe_tdm.h   |  94 ++++++++++++++
 5 files changed, 377 insertions(+), 5 deletions(-)
 create mode 100644 drivers/soc/fsl/qe/qe_tdm.c
 create mode 100644 include/soc/fsl/qe/qe_tdm.h

diff --git a/drivers/soc/fsl/qe/Kconfig b/drivers/soc/fsl/qe/Kconfig
index 20978f2..73a2e08 100644
--- a/drivers/soc/fsl/qe/Kconfig
+++ b/drivers/soc/fsl/qe/Kconfig
@@ -22,7 +22,7 @@ config UCC_SLOW
 
 config UCC_FAST
 	bool
-	default y if UCC_GETH
+	default y if UCC_GETH || QE_TDM
 	help
 	  This option provides qe_lib support to UCC fast
 	  protocols: HDLC, Ethernet, ATM, transparent
@@ -31,6 +31,10 @@ config UCC
 	bool
 	default y if UCC_FAST || UCC_SLOW
 
+config QE_TDM
+	bool
+	default y if FSL_UCC_HDLC
+
 config QE_USB
 	bool
 	default y if USB_FSL_QE
diff --git a/drivers/soc/fsl/qe/Makefile b/drivers/soc/fsl/qe/Makefile
index ffac541..2031d38 100644
--- a/drivers/soc/fsl/qe/Makefile
+++ b/drivers/soc/fsl/qe/Makefile
@@ -6,5 +6,6 @@ obj-$(CONFIG_CPM)	+= qe_common.o
 obj-$(CONFIG_UCC)	+= ucc.o
 obj-$(CONFIG_UCC_SLOW)	+= ucc_slow.o
 obj-$(CONFIG_UCC_FAST)	+= ucc_fast.o
+obj-$(CONFIG_QE_TDM)	+= qe_tdm.o
 obj-$(CONFIG_QE_USB)	+= usb.o
 obj-$(CONFIG_QE_GPIO)	+= gpio.o
diff --git a/drivers/soc/fsl/qe/qe_tdm.c b/drivers/soc/fsl/qe/qe_tdm.c
new file mode 100644
index 0000000..5e48b14
--- /dev/null
+++ b/drivers/soc/fsl/qe/qe_tdm.c
@@ -0,0 +1,276 @@
+/*
+ * Copyright (C) 2015 Freescale Semiconductor, Inc. All rights reserved.
+ *
+ * Authors:	Zhao Qiang <qiang.zhao@nxp.com>
+ *
+ * Description:
+ * QE TDM API Set - TDM specific routines implementations.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ */
+#include <linux/io.h>
+#include <linux/kernel.h>
+#include <linux/of_address.h>
+#include <linux/of_irq.h>
+#include <linux/of_platform.h>
+#include <soc/fsl/qe/qe_tdm.h>
+
+static int set_tdm_framer(const char *tdm_framer_type)
+{
+	if (strcmp(tdm_framer_type, "e1") == 0)
+		return TDM_FRAMER_E1;
+	else if (strcmp(tdm_framer_type, "t1") == 0)
+		return TDM_FRAMER_T1;
+	else
+		return -EINVAL;
+}
+
+static void set_si_param(struct ucc_tdm *utdm, struct ucc_tdm_info *ut_info)
+{
+	struct si_mode_info *si_info = &ut_info->si_info;
+
+	if (utdm->tdm_mode == TDM_INTERNAL_LOOPBACK) {
+		si_info->simr_crt = 1;
+		si_info->simr_rfsd = 0;
+	}
+}
+
+int ucc_of_parse_tdm(struct device_node *np, struct ucc_tdm *utdm,
+		     struct ucc_tdm_info *ut_info)
+{
+	const char *sprop;
+	int ret = 0;
+	u32 val;
+	struct resource *res;
+	struct device_node *np2;
+	static int siram_init_flag;
+	struct platform_device *pdev;
+
+	sprop = of_get_property(np, "fsl,rx-sync-clock", NULL);
+	if (sprop) {
+		ut_info->uf_info.rx_sync = qe_clock_source(sprop);
+		if ((ut_info->uf_info.rx_sync < QE_CLK_NONE) ||
+		    (ut_info->uf_info.rx_sync > QE_RSYNC_PIN)) {
+			pr_err("QE-TDM: Invalid rx-sync-clock property\n");
+			return -EINVAL;
+		}
+	} else {
+		pr_err("QE-TDM: Invalid rx-sync-clock property\n");
+		return -EINVAL;
+	}
+
+	sprop = of_get_property(np, "fsl,tx-sync-clock", NULL);
+	if (sprop) {
+		ut_info->uf_info.tx_sync = qe_clock_source(sprop);
+		if ((ut_info->uf_info.tx_sync < QE_CLK_NONE) ||
+		    (ut_info->uf_info.tx_sync > QE_TSYNC_PIN)) {
+			pr_err("QE-TDM: Invalid tx-sync-clock property\n");
+		return -EINVAL;
+		}
+	} else {
+		pr_err("QE-TDM: Invalid tx-sync-clock property\n");
+		return -EINVAL;
+	}
+
+	ret = of_property_read_u32_index(np, "fsl,tx-timeslot-mask", 0, &val);
+	if (ret) {
+		pr_err("QE-TDM: Invalid tx-timeslot-mask property\n");
+		return -EINVAL;
+	}
+	utdm->tx_ts_mask = val;
+
+	ret = of_property_read_u32_index(np, "fsl,rx-timeslot-mask", 0, &val);
+	if (ret) {
+		ret = -EINVAL;
+		pr_err("QE-TDM: Invalid rx-timeslot-mask property\n");
+		return ret;
+	}
+	utdm->rx_ts_mask = val;
+
+	ret = of_property_read_u32_index(np, "fsl,tdm-id", 0, &val);
+	if (ret) {
+		ret = -EINVAL;
+		pr_err("QE-TDM: No fsl,tdm-id property for this UCC\n");
+		return ret;
+	}
+	utdm->tdm_port = val;
+	ut_info->uf_info.tdm_num = utdm->tdm_port;
+
+	if (of_get_property(np, "fsl,tdm-internal-loopback", NULL))
+		utdm->tdm_mode = TDM_INTERNAL_LOOPBACK;
+	else
+		utdm->tdm_mode = TDM_NORMAL;
+
+	sprop = of_get_property(np, "fsl,tdm-framer-type", NULL);
+	if (!sprop) {
+		ret = -EINVAL;
+		pr_err("QE-TDM: No tdm-framer-type property for UCC\n");
+		return ret;
+	}
+	ret = set_tdm_framer(sprop);
+	if (ret < 0)
+		return -EINVAL;
+	utdm->tdm_framer_type = ret;
+
+	ret = of_property_read_u32_index(np, "fsl,siram-entry-id", 0, &val);
+	if (ret) {
+		ret = -EINVAL;
+		pr_err("QE-TDM: No siram entry id for UCC\n");
+		return ret;
+	}
+	utdm->siram_entry_id = val;
+
+	set_si_param(utdm, ut_info);
+
+	np2 = of_find_compatible_node(NULL, NULL, "fsl,t1040-qe-si");
+	if (!np2)
+		return -EINVAL;
+
+	pdev = of_find_device_by_node(np2);
+	if (!pdev) {
+		pr_err("%s: failed to lookup pdev\n", np2->name);
+		of_node_put(np2);
+		return -EINVAL;
+	}
+
+	of_node_put(np2);
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	utdm->si_regs = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(utdm->si_regs)) {
+		ret = PTR_ERR(utdm->si_regs);
+		goto err_miss_siram_property;
+	}
+
+	np2 = of_find_compatible_node(NULL, NULL, "fsl,t1040-qe-siram");
+	if (!np2) {
+		ret = -EINVAL;
+		goto err_miss_siram_property;
+	}
+
+	pdev = of_find_device_by_node(np2);
+	if (!pdev) {
+		ret = -EINVAL;
+		pr_err("%s: failed to lookup pdev\n", np2->name);
+		of_node_put(np2);
+		goto err_miss_siram_property;
+	}
+
+	of_node_put(np2);
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	utdm->siram = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(utdm->siram)) {
+		ret = PTR_ERR(utdm->siram);
+		goto err_miss_siram_property;
+	}
+
+	if (siram_init_flag == 0) {
+		memset_io(utdm->siram, 0,  res->end - res->start + 1);
+		siram_init_flag = 1;
+	}
+
+	return ret;
+
+err_miss_siram_property:
+	devm_iounmap(&pdev->dev, utdm->si_regs);
+	return ret;
+}
+
+void ucc_tdm_init(struct ucc_tdm *utdm, struct ucc_tdm_info *ut_info)
+{
+	struct si1 __iomem *si_regs;
+	u16 __iomem *siram;
+	u16 siram_entry_valid;
+	u16 siram_entry_closed;
+	u16 ucc_num;
+	u8 csel;
+	u16 sixmr;
+	u16 tdm_port;
+	u32 siram_entry_id;
+	u32 mask;
+	int i;
+
+	si_regs = utdm->si_regs;
+	siram = utdm->siram;
+	ucc_num = ut_info->uf_info.ucc_num;
+	tdm_port = utdm->tdm_port;
+	siram_entry_id = utdm->siram_entry_id;
+
+	if (utdm->tdm_framer_type == TDM_FRAMER_T1)
+		utdm->num_of_ts = 24;
+	if (utdm->tdm_framer_type == TDM_FRAMER_E1)
+		utdm->num_of_ts = 32;
+
+	/* set siram table */
+	csel = (ucc_num < 4) ? ucc_num + 9 : ucc_num - 3;
+
+	siram_entry_valid = SIR_CSEL(csel) | SIR_BYTE | SIR_CNT(0);
+	siram_entry_closed = SIR_IDLE | SIR_BYTE | SIR_CNT(0);
+
+	for (i = 0; i < utdm->num_of_ts; i++) {
+		mask = 0x01 << i;
+
+		if (utdm->tx_ts_mask & mask)
+			iowrite16be(siram_entry_valid,
+				    &siram[siram_entry_id * 32 + i]);
+		else
+			iowrite16be(siram_entry_closed,
+				    &siram[siram_entry_id * 32 + i]);
+
+		if (utdm->rx_ts_mask & mask)
+			iowrite16be(siram_entry_valid,
+				    &siram[siram_entry_id * 32 + 0x200 +  i]);
+		else
+			iowrite16be(siram_entry_closed,
+				    &siram[siram_entry_id * 32 + 0x200 +  i]);
+	}
+
+	setbits16(&siram[(siram_entry_id * 32) + (utdm->num_of_ts - 1)],
+		  SIR_LAST);
+	setbits16(&siram[(siram_entry_id * 32) + 0x200 + (utdm->num_of_ts - 1)],
+		  SIR_LAST);
+
+	/* Set SIxMR register */
+	sixmr = SIMR_SAD(siram_entry_id);
+
+	sixmr &= ~SIMR_SDM_MASK;
+
+	if (utdm->tdm_mode == TDM_INTERNAL_LOOPBACK)
+		sixmr |= SIMR_SDM_INTERNAL_LOOPBACK;
+	else
+		sixmr |= SIMR_SDM_NORMAL;
+
+	sixmr |= SIMR_RFSD(ut_info->si_info.simr_rfsd) |
+			SIMR_TFSD(ut_info->si_info.simr_tfsd);
+
+	if (ut_info->si_info.simr_crt)
+		sixmr |= SIMR_CRT;
+	if (ut_info->si_info.simr_sl)
+		sixmr |= SIMR_SL;
+	if (ut_info->si_info.simr_ce)
+		sixmr |= SIMR_CE;
+	if (ut_info->si_info.simr_fe)
+		sixmr |= SIMR_FE;
+	if (ut_info->si_info.simr_gm)
+		sixmr |= SIMR_GM;
+
+	switch (tdm_port) {
+	case 0:
+		iowrite16be(sixmr, &si_regs->sixmr1[0]);
+		break;
+	case 1:
+		iowrite16be(sixmr, &si_regs->sixmr1[1]);
+		break;
+	case 2:
+		iowrite16be(sixmr, &si_regs->sixmr1[2]);
+		break;
+	case 3:
+		iowrite16be(sixmr, &si_regs->sixmr1[3]);
+		break;
+	default:
+		pr_err("QE-TDM: can not find tdm sixmr reg\n");
+		break;
+	}
+}
diff --git a/include/soc/fsl/qe/immap_qe.h b/include/soc/fsl/qe/immap_qe.h
index bedbff8..c76ef30 100644
--- a/include/soc/fsl/qe/immap_qe.h
+++ b/include/soc/fsl/qe/immap_qe.h
@@ -159,10 +159,7 @@ struct spi {
 
 /* SI */
 struct si1 {
-	__be16	siamr1;		/* SI1 TDMA mode register */
-	__be16	sibmr1;		/* SI1 TDMB mode register */
-	__be16	sicmr1;		/* SI1 TDMC mode register */
-	__be16	sidmr1;		/* SI1 TDMD mode register */
+	__be16	sixmr1[4];	/* SI1 TDMx (x = A B C D) mode register */
 	u8	siglmr1_h;	/* SI1 global mode register high */
 	u8	res0[0x1];
 	u8	sicmdr1_h;	/* SI1 command register high */
diff --git a/include/soc/fsl/qe/qe_tdm.h b/include/soc/fsl/qe/qe_tdm.h
new file mode 100644
index 0000000..4c91498
--- /dev/null
+++ b/include/soc/fsl/qe/qe_tdm.h
@@ -0,0 +1,94 @@
+/*
+ * Internal header file for QE TDM mode routines.
+ *
+ * Copyright (C) 2016 Freescale Semiconductor, Inc. All rights reserved.
+ *
+ * Authors:	Zhao Qiang <qiang.zhao@nxp.com>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version
+ */
+
+#ifndef CONFIG_QE_TDM_H
+#define CONFIG_QE_TDM_H
+
+#include <linux/kernel.h>
+#include <linux/list.h>
+
+#include <soc/fsl/qe/immap_qe.h>
+#include <soc/fsl/qe/qe.h>
+
+#include <soc/fsl/qe/ucc.h>
+#include <soc/fsl/qe/ucc_fast.h>
+
+/* SI RAM entries */
+#define SIR_LAST	0x0001
+#define SIR_BYTE	0x0002
+#define SIR_CNT(x)	((x) << 2)
+#define SIR_CSEL(x)	((x) << 5)
+#define SIR_SGS		0x0200
+#define SIR_SWTR	0x4000
+#define SIR_MCC		0x8000
+#define SIR_IDLE	0
+
+/* SIxMR fields */
+#define SIMR_SAD(x) ((x) << 12)
+#define SIMR_SDM_NORMAL	0x0000
+#define SIMR_SDM_INTERNAL_LOOPBACK	0x0800
+#define SIMR_SDM_MASK	0x0c00
+#define SIMR_CRT	0x0040
+#define SIMR_SL		0x0020
+#define SIMR_CE		0x0010
+#define SIMR_FE		0x0008
+#define SIMR_GM		0x0004
+#define SIMR_TFSD(n)	(n)
+#define SIMR_RFSD(n)	((n) << 8)
+
+enum tdm_ts_t {
+	TDM_TX_TS,
+	TDM_RX_TS
+};
+
+enum tdm_framer_t {
+	TDM_FRAMER_T1,
+	TDM_FRAMER_E1
+};
+
+enum tdm_mode_t {
+	TDM_INTERNAL_LOOPBACK,
+	TDM_NORMAL
+};
+
+struct si_mode_info {
+	u8 simr_rfsd;
+	u8 simr_tfsd;
+	u8 simr_crt;
+	u8 simr_sl;
+	u8 simr_ce;
+	u8 simr_fe;
+	u8 simr_gm;
+};
+
+struct ucc_tdm_info {
+	struct ucc_fast_info uf_info;
+	struct si_mode_info si_info;
+};
+
+struct ucc_tdm {
+	u16 tdm_port;		/* port for this tdm:TDMA,TDMB */
+	u32 siram_entry_id;
+	u16 __iomem *siram;
+	struct si1 __iomem *si_regs;
+	enum tdm_framer_t tdm_framer_type;
+	enum tdm_mode_t tdm_mode;
+	u8 num_of_ts;		/* the number of timeslots in this tdm frame */
+	u32 tx_ts_mask;		/* tx time slot mask */
+	u32 rx_ts_mask;		/* rx time slot mask */
+};
+
+int ucc_of_parse_tdm(struct device_node *np, struct ucc_tdm *utdm,
+		     struct ucc_tdm_info *ut_info);
+void ucc_tdm_init(struct ucc_tdm *utdm, struct ucc_tdm_info *ut_info);
+#endif
-- 
2.1.0.27.g96db324
