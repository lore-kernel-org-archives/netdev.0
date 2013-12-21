From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 3/5] drivers: net: APM X-Gene SoC Ethernet base driver
Date: Fri, 20 Dec 2013 19:42:54 -0800
Message-ID: <1387597376-29303-4-git-send-email-isubramanian@apm.com>
References: <1387597376-29303-1-git-send-email-isubramanian@apm.com>
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, jcm@redhat.com,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>,
	Ravi Patel <rapatel@apm.com>, Keyur Chudgar <kchudgar@apm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og112.obsmtp.com ([64.18.0.24]:57990 "HELO
	exprod5og112.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754124Ab3LUDtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 22:49:22 -0500
Received: by mail-pd0-f174.google.com with SMTP id x10so3286038pdj.33
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 19:49:21 -0800 (PST)
In-Reply-To: <1387597376-29303-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethernet base device driver for APM X-Gene SoC.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 MAINTAINERS                                        |    7 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/apm/Kconfig                   |    1 +
 drivers/net/ethernet/apm/Makefile                  |    5 +
 drivers/net/ethernet/apm/xgene/Kconfig             |   10 +
 drivers/net/ethernet/apm/xgene/Makefile            |   10 +
 drivers/net/ethernet/apm/xgene/xgene_enet_common.c |  497 ++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_common.h |  450 ++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_csr.h    |  162 ++
 drivers/net/ethernet/apm/xgene/xgene_enet_mac.c    |  520 +++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   | 1581 ++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |  172 +++
 13 files changed, 3417 insertions(+)
 create mode 100644 drivers/net/ethernet/apm/Kconfig
 create mode 100644 drivers/net/ethernet/apm/Makefile
 create mode 100644 drivers/net/ethernet/apm/xgene/Kconfig
 create mode 100644 drivers/net/ethernet/apm/xgene/Makefile
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_common.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_common.h
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_csr.h
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_mac.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 920cae8..01340e5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -672,6 +672,13 @@ S:	Maintained
 F:	drivers/misc/xgene/
 F:	include/misc/xgene/xgene_qmtm.h
 
+APPLIEDMICRO (APM) X-GENE SOC ETHERNET DRIVER
+M:	Keyur Chudgar <kchudgar@apm.com>
+M:	Iyappan Subramanian <isubramanian@apm.com>
+M:	Ravi Patel <rapatel@apm.com>
+S:	Maintained
+F:	drivers/net/ethernet/apm/
+
 APTINA CAMERA SENSOR PLL
 M:	Laurent Pinchart <Laurent.pinchart@ideasonboard.com>
 L:	linux-media@vger.kernel.org
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 506b024..f0c4315 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -17,6 +17,7 @@ config MDIO
 config SUNGEM_PHY
 	tristate
 
+source "drivers/net/ethernet/apm/Kconfig"
 source "drivers/net/ethernet/3com/Kconfig"
 source "drivers/net/ethernet/adaptec/Kconfig"
 source "drivers/net/ethernet/aeroflex/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index c0b8789..bc0d4a5 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -9,6 +9,7 @@ obj-$(CONFIG_GRETH) += aeroflex/
 obj-$(CONFIG_NET_VENDOR_ALLWINNER) += allwinner/
 obj-$(CONFIG_NET_VENDOR_ALTEON) += alteon/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
+obj-$(CONFIG_NET_XGENE) += apm/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
 obj-$(CONFIG_NET_VENDOR_ARC) += arc/
 obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
diff --git a/drivers/net/ethernet/apm/Kconfig b/drivers/net/ethernet/apm/Kconfig
new file mode 100644
index 0000000..ec63d70
--- /dev/null
+++ b/drivers/net/ethernet/apm/Kconfig
@@ -0,0 +1 @@
+source "drivers/net/ethernet/apm/xgene/Kconfig"
diff --git a/drivers/net/ethernet/apm/Makefile b/drivers/net/ethernet/apm/Makefile
new file mode 100644
index 0000000..65ce32a
--- /dev/null
+++ b/drivers/net/ethernet/apm/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for APM X-GENE Ethernet driver.
+#
+
+obj-$(CONFIG_NET_XGENE) += xgene/
diff --git a/drivers/net/ethernet/apm/xgene/Kconfig b/drivers/net/ethernet/apm/xgene/Kconfig
new file mode 100644
index 0000000..c6ac5f9
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/Kconfig
@@ -0,0 +1,10 @@
+config NET_XGENE
+	tristate "APM X-Gene Ethernet Driver"
+	depends on XGENE_QMTM
+	select PHYLIB
+	default y
+	help
+	  This is the Ethernet driver for APM X-Gene SoC.
+
+	  To compile this driver as a module, choose M here. This module will
+	  be called xgene_enet.
diff --git a/drivers/net/ethernet/apm/xgene/Makefile b/drivers/net/ethernet/apm/xgene/Makefile
new file mode 100644
index 0000000..16dfc6c
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/Makefile
@@ -0,0 +1,10 @@
+#
+# Makefile for APM X-GENE Ethernet driver.
+#
+
+xgene-enet-objs := \
+		xgene_enet_common.o	\
+		xgene_enet_mac.o	\
+		xgene_enet_main.o
+
+obj-$(CONFIG_NET_XGENE) += xgene-enet.o
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_common.c b/drivers/net/ethernet/apm/xgene/xgene_enet_common.c
new file mode 100644
index 0000000..279f3cd
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_common.c
@@ -0,0 +1,497 @@
+/* AppliedMicro X-Gene SoC Ethernet Driver
+ *
+ * Copyright (c) 2013, Applied Micro Circuits Corporation
+ * Authors:	Ravi Patel <rapatel@apm.com>
+ *		Iyappan Subramanian <isubramanian@apm.com>
+ *		Fushen Chen <fchen@apm.com>
+ *		Keyur Chudgar <kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#include "xgene_enet_main.h"
+#include "xgene_enet_common.h"
+#include "xgene_enet_csr.h"
+
+/* Indirect Address - read/write commands */
+#define PHY_ADDR_WR(src)		(((u32)(src) < 8) & 0x00001f00)
+#define REG_ADDR_WR(src)		(((u32)(src)) & 0x0000001f)
+
+int xgene_enet_wr(struct xgene_enet_priv *priv, u8 block_id,
+		  u32 reg_offset, u32 value)
+{
+	u32 cmd_done;
+	u32 indirect = 0;
+	int wait;
+	void *addr_reg_offst, *cmd_reg_offst, *wr_reg_offst;
+	void *cmd_done_reg_offst;
+
+	switch (block_id) {
+	case BLOCK_ETH_CSR:
+		addr_reg_offst = priv->eth_csr_addr_v + reg_offset;
+		pr_debug("ETH CSR write\n");
+		break;
+
+	case BLOCK_ETH_MDIO_CSR:
+		addr_reg_offst = priv->vmii_base + reg_offset
+		    + BLOCK_ETH_CSR_OFFSET;
+		pr_debug("BLOCK_ETH_MDIO_CSR write 0x%p\n", addr_reg_offst);
+		break;
+
+	case BLOCK_ETH_CLE:
+		addr_reg_offst = priv->eth_cle_addr_v + reg_offset;
+		pr_debug("ETH CLE write\n");
+		break;
+
+	case BLOCK_ETH_QMI:
+		addr_reg_offst = priv->eth_qmi_addr_v + reg_offset;
+		pr_debug("ETH QMI write\n");
+		break;
+
+	case BLOCK_ETH_SDS_CSR:
+		addr_reg_offst = priv->eth_sds_csr_addr_v + reg_offset;
+		pr_debug("ETH SDS CSR write\n");
+		break;
+
+	case BLOCK_ETH_CLKRST_CSR:
+		addr_reg_offst = priv->eth_clkrst_csr_addr_v + reg_offset;
+		pr_debug("ETH CLKRST CSR write\n");
+		break;
+
+	case BLOCK_ETH_DIAG_CSR:
+		addr_reg_offst = priv->eth_diag_csr_addr_v + reg_offset;
+		pr_debug("ETH DIAG CSR write\n");
+		break;
+
+	case BLOCK_MCX_MAC:
+	case BLOCK_ETH_INTPHY:
+		addr_reg_offst = priv->mcx_mac_addr_v + MAC_ADDR_REG_OFFSET;
+		cmd_reg_offst = priv->mcx_mac_addr_v + MAC_COMMAND_REG_OFFSET;
+		wr_reg_offst = priv->mcx_mac_addr_v + MAC_WRITE_REG_OFFSET;
+		cmd_done_reg_offst = priv->mcx_mac_addr_v
+		    + MAC_COMMAND_DONE_REG_OFFSET;
+		indirect = 1;
+		pr_debug("MCX MAC/Internal PHY write\n");
+		break;
+
+	case BLOCK_ETH_EXTPHY:
+		addr_reg_offst = priv->vmii_base + MAC_ADDR_REG_OFFSET;
+		cmd_reg_offst = priv->vmii_base + MAC_COMMAND_REG_OFFSET;
+		wr_reg_offst = priv->vmii_base + MAC_WRITE_REG_OFFSET;
+		cmd_done_reg_offst = priv->vmii_base
+		    + MAC_COMMAND_DONE_REG_OFFSET;
+		indirect = 1;
+		pr_debug("MCX MAC/External PHY write\n");
+		break;
+
+	case BLOCK_MCX_STATS:
+		addr_reg_offst = priv->mcx_stats_addr_v + STAT_ADDR_REG_OFFSET;
+		cmd_reg_offst =
+		    priv->mcx_stats_addr_v + STAT_COMMAND_REG_OFFSET;
+		wr_reg_offst = priv->mcx_stats_addr_v + STAT_WRITE_REG_OFFSET;
+		cmd_done_reg_offst = priv->mcx_stats_addr_v
+		    + STAT_COMMAND_DONE_REG_OFFSET;
+		indirect = 1;
+		pr_debug("MCX STATS write\n");
+		break;
+
+	case BLOCK_MCX_MAC_CSR:
+		addr_reg_offst = priv->mcx_mac_csr_addr_v + reg_offset;
+		pr_debug("MCX MAC CSR write\n");
+		break;
+
+	case BLOCK_SATA_ENET_CSR:
+		addr_reg_offst = priv->sata_enet_csr_addr_v + reg_offset;
+		pr_debug("SATA ENET CSR write\n");
+		break;
+
+	case BLOCK_AXG_MAC:
+		addr_reg_offst = priv->axg_mac_addr_v + MAC_ADDR_REG_OFFSET;
+		cmd_reg_offst = priv->axg_mac_addr_v + MAC_COMMAND_REG_OFFSET;
+		wr_reg_offst = priv->axg_mac_addr_v + MAC_WRITE_REG_OFFSET;
+		cmd_done_reg_offst = priv->axg_mac_addr_v
+		    + MAC_COMMAND_DONE_REG_OFFSET;
+		indirect = 1;
+		pr_debug("AXG MAC write\n");
+		break;
+
+	case BLOCK_AXG_STATS:
+		addr_reg_offst = priv->axg_stats_addr_v + STAT_ADDR_REG_OFFSET;
+		cmd_reg_offst =
+		    priv->axg_stats_addr_v + STAT_COMMAND_REG_OFFSET;
+		wr_reg_offst = priv->axg_stats_addr_v + STAT_WRITE_REG_OFFSET;
+		cmd_done_reg_offst = priv->axg_stats_addr_v
+		    + STAT_COMMAND_DONE_REG_OFFSET;
+		indirect = 1;
+		pr_debug("AXG STATS write\n");
+		break;
+
+	case BLOCK_AXG_MAC_CSR:
+		addr_reg_offst = priv->axg_mac_csr_addr_v + reg_offset;
+		pr_debug("AXG MAC CSR write\n");
+		break;
+
+	case BLOCK_XGENET_PCS:
+		addr_reg_offst = priv->xgenet_pcs_addr_v + reg_offset;
+		pr_debug("XGENET PCS write\n");
+		break;
+
+	case BLOCK_XGENET_MDIO_CSR:
+		addr_reg_offst = priv->xgenet_mdio_csr_addr_v + reg_offset;
+		pr_debug("XGENET MDIO CSR write\n");
+		break;
+
+	default:
+		pr_err("Invalid blockid in write reg: %d\n", block_id);
+		return -1;
+	}
+
+	if (indirect) {
+		xgene_enet_wr32(addr_reg_offst, reg_offset);
+		xgene_enet_wr32(wr_reg_offst, value);
+		xgene_enet_wr32(cmd_reg_offst, XGENE_ENET_WR_CMD);
+		pr_debug("Indirect write: addr: 0x%X, value: 0x%X\n",
+			 reg_offset, value);
+
+		/* wait upto 5 us for completion */
+		wait = 5;
+		do {
+			xgene_enet_rd32(cmd_done_reg_offst, &cmd_done);
+			usleep_range(1, 2);
+		} while (--wait && !cmd_done);
+		if (!wait) {
+			pr_err("Write failed for blk: %d\n", block_id);
+			BUG();
+		}
+
+		xgene_enet_wr32(cmd_reg_offst, 0);
+	} else {
+		xgene_enet_wr32(addr_reg_offst, value);
+		pr_debug("Direct write addr: 0x%p, value: 0x%X\n",
+			 addr_reg_offst, value);
+	}
+
+	return 0;
+}
+
+int xgene_enet_rd(struct xgene_enet_priv *priv, u8 block_id,
+		  u32 reg_offset, u32 *value)
+{
+	u32 cmd_done;
+	u32 indirect = 0;
+	int wait;
+	void *addr_reg_offst, *cmd_reg_offst, *rd_reg_offst;
+	void *cmd_done_reg_offst;
+
+	switch (block_id) {
+	case BLOCK_ETH_CSR:
+		addr_reg_offst = priv->eth_csr_addr_v + reg_offset;
+		pr_debug("ETH CSR read\n");
+		break;
+
+	case BLOCK_ETH_MDIO_CSR:
+		addr_reg_offst = priv->vmii_base + reg_offset
+		    + BLOCK_ETH_CSR_OFFSET;
+		pr_debug("BLOCK_ETH_MDIO_CSR read 0x%p\n", addr_reg_offst);
+		break;
+
+	case BLOCK_ETH_CLE:
+		addr_reg_offst = priv->eth_cle_addr_v + reg_offset;
+		pr_debug("ETH CLE read\n");
+		break;
+
+	case BLOCK_ETH_QMI:
+		addr_reg_offst = priv->eth_qmi_addr_v + reg_offset;
+		pr_debug("ETH QMI read\n");
+		break;
+
+	case BLOCK_ETH_SDS_CSR:
+		addr_reg_offst = priv->eth_sds_csr_addr_v + reg_offset;
+		pr_debug("ETH SDS CSR read\n");
+		break;
+
+	case BLOCK_ETH_CLKRST_CSR:
+		addr_reg_offst = priv->eth_clkrst_csr_addr_v + reg_offset;
+		pr_debug("ETH CLKRST CSR read\n");
+		break;
+
+	case BLOCK_ETH_DIAG_CSR:
+		addr_reg_offst = priv->eth_diag_csr_addr_v + reg_offset;
+		pr_debug("ETH DIAG CSR read\n");
+		break;
+
+	case BLOCK_MCX_MAC:
+	case BLOCK_ETH_INTPHY:
+		addr_reg_offst = priv->mcx_mac_addr_v + MAC_ADDR_REG_OFFSET;
+		cmd_reg_offst = priv->mcx_mac_addr_v + MAC_COMMAND_REG_OFFSET;
+		rd_reg_offst = priv->mcx_mac_addr_v + MAC_READ_REG_OFFSET;
+		cmd_done_reg_offst = priv->mcx_mac_addr_v
+		    + MAC_COMMAND_DONE_REG_OFFSET;
+		indirect = 1;
+		pr_debug("MCX MAC/Internal PHY read\n");
+		break;
+
+	case BLOCK_ETH_EXTPHY:
+		addr_reg_offst = priv->vmii_base + MAC_ADDR_REG_OFFSET;
+		cmd_reg_offst = priv->vmii_base + MAC_COMMAND_REG_OFFSET;
+		rd_reg_offst = priv->vmii_base + MAC_READ_REG_OFFSET;
+		cmd_done_reg_offst = priv->vmii_base
+		    + MAC_COMMAND_DONE_REG_OFFSET;
+		indirect = 1;
+		pr_debug("MCX MAC/External PHY read\n");
+		break;
+
+	case BLOCK_MCX_STATS:
+		addr_reg_offst = priv->mcx_stats_addr_v + STAT_ADDR_REG_OFFSET;
+		cmd_reg_offst =
+		    priv->mcx_stats_addr_v + STAT_COMMAND_REG_OFFSET;
+		rd_reg_offst = priv->mcx_stats_addr_v + STAT_READ_REG_OFFSET;
+		cmd_done_reg_offst = priv->mcx_stats_addr_v
+		    + STAT_COMMAND_DONE_REG_OFFSET;
+		indirect = 1;
+		pr_debug("MCX STATS read\n");
+		break;
+
+	case BLOCK_MCX_MAC_CSR:
+		addr_reg_offst = priv->mcx_mac_csr_addr_v + reg_offset;
+		pr_debug("MCX MAC CSR read\n");
+		break;
+
+	case BLOCK_SATA_ENET_CSR:
+		addr_reg_offst = priv->sata_enet_csr_addr_v + reg_offset;
+		pr_debug("SATA ENET CSR read\n");
+		break;
+
+	case BLOCK_AXG_MAC:
+		addr_reg_offst = priv->axg_mac_addr_v + MAC_ADDR_REG_OFFSET;
+		cmd_reg_offst = priv->axg_mac_addr_v + MAC_COMMAND_REG_OFFSET;
+		rd_reg_offst = priv->axg_mac_addr_v + MAC_READ_REG_OFFSET;
+		cmd_done_reg_offst = priv->axg_mac_addr_v
+		    + MAC_COMMAND_DONE_REG_OFFSET;
+		indirect = 1;
+		pr_debug("AXG MAC read\n");
+		break;
+
+	case BLOCK_AXG_STATS:
+		addr_reg_offst = priv->axg_stats_addr_v + STAT_ADDR_REG_OFFSET;
+		cmd_reg_offst =
+		    priv->axg_stats_addr_v + STAT_COMMAND_REG_OFFSET;
+		rd_reg_offst = priv->axg_stats_addr_v + STAT_READ_REG_OFFSET;
+		cmd_done_reg_offst = priv->axg_stats_addr_v
+		    + STAT_COMMAND_DONE_REG_OFFSET;
+		indirect = 1;
+		pr_debug("AXG STATS read\n");
+		break;
+
+	case BLOCK_AXG_MAC_CSR:
+		addr_reg_offst = priv->axg_mac_csr_addr_v + reg_offset;
+		pr_debug("AXG MAC CSR read\n");
+		break;
+
+	case BLOCK_XGENET_PCS:
+		addr_reg_offst = priv->xgenet_pcs_addr_v + reg_offset;
+		pr_debug("XGENET PCS read\n");
+		break;
+
+	case BLOCK_XGENET_MDIO_CSR:
+		addr_reg_offst = priv->xgenet_mdio_csr_addr_v + reg_offset;
+		pr_debug("XGENET MDIO CSR read\n");
+		break;
+
+	default:
+		pr_err("Invalid blockid in read reg: %d\n", block_id);
+		return -1;
+	}
+
+	if (indirect) {
+		xgene_enet_wr32(addr_reg_offst, reg_offset);
+		xgene_enet_wr32(cmd_reg_offst, XGENE_ENET_RD_CMD);
+		pr_debug("Indirect read: addr: 0x%X\n", reg_offset);
+
+		/* wait upto 5 us for completion */
+		wait = 5;
+		do {
+			xgene_enet_rd32(cmd_done_reg_offst, &cmd_done);
+		} while (--wait && !cmd_done);
+		if (!wait) {
+			pr_err("Read failed for blk: %d\n", block_id);
+			BUG();
+		}
+
+		xgene_enet_rd32(rd_reg_offst, value);
+		pr_debug("Indirect read value: 0x%X\n", *value);
+
+		xgene_enet_wr32(cmd_reg_offst, 0);
+	} else {
+		xgene_enet_rd32(addr_reg_offst, value);
+		pr_debug("Direct read addr: 0x%p, value: 0x%X\n",
+			 addr_reg_offst, *value);
+	}
+
+	return 0;
+}
+
+void xgene_genericmiiphy_write(struct xgene_enet_priv *priv, u8 phy_id,
+			       unsigned char reg, u32 data)
+{
+	u32 value;
+	int wait;
+	u32 blockid = BLOCK_ETH_EXTPHY;
+
+	if (priv->port == MENET)
+		phy_id = priv->phy_addr;
+
+	/* All PHYs lie on MII bus of Port0 MAC due to this
+	 * each port should access its PHY through Port0 MAC.
+	 * Hence we allow access to PHY_ID associated with this
+	 * port only.
+	 */
+
+	/* Write PHY number and address in MII Mgmt Address */
+	value = PHY_ADDR_WR(phy_id) | REG_ADDR_WR(reg);
+	pr_debug("Write MII_MGMT_ADDRESS phy_id=0x%x, reg=0x%x, value=0x%x\n",
+		 phy_id, reg << 2, value);
+	xgene_enet_wr(priv, blockid, MII_MGMT_ADDRESS_ADDR, value);
+
+	/* Write 16 bit data to MII MGMT CONTROL */
+	value = PHY_CONTROL_WR(data);
+	pr_debug("Write MII_MGMT_CONTROL phy_id=0x%x, reg=0x%x, value=0x%x\n",
+		 phy_id, reg << 2, value);
+	xgene_enet_wr(priv, blockid, MII_MGMT_CONTROL_ADDR, value);
+
+	/* wait upto 20 us for completion */
+	wait = 20;
+	do {
+		xgene_enet_rd(priv, blockid, MII_MGMT_INDICATORS_ADDR, &value);
+		usleep_range(1, 2);
+	} while (--wait && (value & BUSY_MASK));
+	if (!wait)
+		pr_err("MII_MGMT write failed\n");
+}
+
+void xgene_genericmiiphy_read(struct xgene_enet_priv *priv, u8 phy_id,
+			      unsigned char reg, u32 *data)
+{
+	u32 value;
+	u32 blockid = BLOCK_ETH_EXTPHY;
+	int wait;
+
+	if (priv->port == MENET)
+		phy_id = priv->phy_addr;
+
+	/* All PHYs lie on MII bus of Port0 MAC due to this
+	 * each port should access its PHY through Port0 MAC.
+	 * Hence we allow access to PHY_ID associated with this
+	 * port only.
+	 */
+
+	/* Write PHY number and address in MII Mgmt Address */
+	value = PHY_ADDR_WR(phy_id) | REG_ADDR_WR(reg);
+	pr_debug("Write MII_MGMT_ADDR phy_id=0x%x, reg=0x%x, value=0x%x\n",
+		 phy_id, reg << 2, value);
+	xgene_enet_wr(priv, blockid, MII_MGMT_ADDRESS_ADDR, value);
+
+	/* Write read command */
+	xgene_enet_wr(priv, blockid, MII_MGMT_COMMAND_ADDR, READ_CYCLE_MASK);
+
+	/* wait upto 20 us for completion */
+	wait = 20;
+	do {
+		xgene_enet_rd(priv, blockid, MII_MGMT_INDICATORS_ADDR, &value);
+		if (!(value & BUSY_MASK))
+			break;
+		usleep_range(1, 2);
+	} while (--wait && (value & BUSY_MASK));
+
+	xgene_enet_rd(priv, blockid, MII_MGMT_STATUS_ADDR, data);
+
+	/* reset mii_mgmt_command register */
+	xgene_enet_wr(priv, blockid, MII_MGMT_COMMAND_ADDR, 0);
+}
+
+inline void xgene_enet_port_reset(struct xgene_enet_priv *priv)
+{
+	if (priv->port_reset)
+		priv->port_reset(priv);
+}
+
+inline void xgene_enet_mac_reset(struct xgene_enet_priv *priv)
+{
+	if (priv->mac_reset)
+		priv->mac_reset(priv);
+}
+
+inline int xgene_enet_mac_init(struct xgene_enet_priv *priv,
+			       unsigned char *dev_addr, int speed, int mtu,
+			       int crc)
+{
+	int rc = 0;
+	if (priv->mac_init)
+		rc = priv->mac_init(priv, dev_addr, speed, mtu, crc);
+	return rc;
+}
+
+inline void xgene_enet_mac_tx_state(struct xgene_enet_priv *priv, u32 enable)
+{
+	if (priv->mac_tx_state)
+		priv->mac_tx_state(priv, enable);
+}
+
+inline void xgene_enet_mac_rx_state(struct xgene_enet_priv *priv, u32 enable)
+{
+	if (priv->mac_rx_state)
+		priv->mac_rx_state(priv, enable);
+}
+
+inline void xgene_enet_mac_change_mtu(struct xgene_enet_priv *priv, u32 new_mtu)
+{
+	if (priv->mac_change_mtu)
+		priv->mac_change_mtu(priv, new_mtu);
+}
+
+inline void xgene_enet_mac_set_ipg(struct xgene_enet_priv *priv, u16 ipg)
+{
+	if (priv->mac_set_ipg)
+		priv->mac_set_ipg(priv, ipg);
+}
+
+inline void xgene_enet_get_stats(struct xgene_enet_priv *priv,
+				 struct xgene_enet_detailed_stats *stats)
+{
+	if (priv->get_stats)
+		priv->get_stats(priv, stats);
+}
+
+inline void xgene_enet_set_mac_addr(struct xgene_enet_priv *priv,
+				    unsigned char *dev_addr)
+{
+	if (priv->set_mac_addr)
+		priv->set_mac_addr(priv, dev_addr);
+}
+
+inline void xgene_enet_cle_bypass(struct xgene_enet_priv *priv,
+				  u32 dstqid, u32 fpsel)
+{
+	if (priv->cle_bypass)
+		priv->cle_bypass(priv, dstqid, fpsel);
+}
+
+inline void xgene_enet_tx_offload(struct xgene_enet_priv *priv,
+				  u32 command, u32 value)
+{
+	if (priv->tx_offload)
+		priv->tx_offload(priv, command, value);
+}
+
+inline void xgene_enet_port_shutdown(struct xgene_enet_priv *priv)
+{
+	if (priv->port_shutdown)
+		priv->port_shutdown(priv);
+}
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_common.h b/drivers/net/ethernet/apm/xgene/xgene_enet_common.h
new file mode 100644
index 0000000..4b0bfad
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_common.h
@@ -0,0 +1,450 @@
+/* AppliedMicro X-Gene SoC Ethernet Driver
+ *
+ * Copyright (c) 2013, Applied Micro Circuits Corporation
+ * Authors:	Ravi Patel rapatel@apm.com>
+ *		Iyappan Subramanian isubramanian@apm.com>
+ *		Fushen Chen fchen@apm.com>
+ *		Keyur Chudgar kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef __XGENE_ENET_COMMON_H__
+#define __XGENE_ENET_COMMON_H__
+
+#include <misc/xgene/xgene_qmtm.h>
+#define MAX_LOOP_POLL_CNT	10
+
+#ifndef UDP_HDR_SIZE
+#define UDP_HDR_SIZE		2
+#endif
+
+/* Ethernet & XGENET port ids */
+enum eth_port_ids {
+	ENET_0 = 0,
+	ENET_1,
+	ENET_2,
+	ENET_3,
+	XGENET_0,
+	XGENET_1,
+	XGENET_2,
+	XGENET_3,
+	MENET,
+	MAX_ENET_PORTS
+};
+
+/* TSO Parameters */
+#define TSO_ENABLE		1
+#define TSO_ENABLE_MASK		1
+#define TSO_CHKSUM_ENABLE	1
+#define TSO_INS_CRC_ENABLE	1
+#define TSO_IPPROTO_TCP		1
+#define TSO_IPPROTO_UDP		0
+#define TSO_IP_HLEN_MASK	0X3F
+#define TSO_TCP_HLEN_MASK	0X3F
+#define TSO_ETH_HLEN_MASK	0XFF
+#define TSO_MSS_MASK		0X3	/* 2b */
+#define DEFAULT_TCP_MSS		1448
+
+enum {
+	XGENE_ENET_MSS0 = 0,
+	XGENE_ENET_MSS1,
+	XGENE_ENET_MSS2,
+	XGENE_ENET_MSS3,
+	XGENE_ENET_TSO_CFG,
+	XGENE_ENET_INSERT_VLAN
+};
+
+/* TYPE_SEL for Ethernt egress message */
+#define TYPE_SEL_WORK_MSG	1U
+
+/* Blocks for defined regions */
+enum {
+	BLOCK_ETH_CSR = 1,
+	BLOCK_ETH_CLE,
+	BLOCK_ETH_QMI,
+	BLOCK_ETH_SDS_CSR,
+	BLOCK_ETH_CLKRST_CSR,
+	BLOCK_ETH_DIAG_CSR,
+	BLOCK_ETH_MDIO_CSR,
+	BLOCK_ETH_INTPHY,
+	BLOCK_ETH_EXTPHY,
+	BLOCK_MCX_MAC,
+	BLOCK_MCX_STATS,
+	BLOCK_MCX_MAC_CSR,
+	BLOCK_SATA_ENET_CSR,
+	BLOCK_AXG_MAC,
+	BLOCK_AXG_STATS,
+	BLOCK_AXG_MAC_CSR,
+	BLOCK_XGENET_PCS,
+	BLOCK_XGENET_MDIO_CSR,
+	BLOCK_ETH_MAX
+};
+
+/* Direct Address mode */
+#define BLOCK_ETH_CSR_OFFSET		0x2000
+#define BLOCK_ETH_CLE_OFFSET		0x6000
+#define BLOCK_ETH_QMI_OFFSET		0x9000
+#define BLOCK_ETH_SDS_CSR_OFFSET	0xA000
+#define BLOCK_ETH_CLKRST_CSR_OFFSET	0xC000
+#define BLOCK_ETH_DIAG_CSR_OFFSET	0xD000
+
+/* Indirect & Direct  Address mode for MCX_MAC and AXG_MAC */
+#define BLOCK_ETH_MAC_OFFSET		0x0000
+#define BLOCK_ETH_STATS_OFFSET		0x0014
+#define BLOCK_ETH_MAC_CSR_OFFSET	0x2800
+
+#define BLOCK_SATA_ENET_CSR_OFFSET	0x7000
+
+/* Constants for indirect registers */
+#define MAC_ADDR_REG_OFFSET		0
+#define MAC_COMMAND_REG_OFFSET		4
+#define MAC_WRITE_REG_OFFSET		8
+#define MAC_READ_REG_OFFSET		12
+#define MAC_COMMAND_DONE_REG_OFFSET	16
+
+#define STAT_ADDR_REG_OFFSET		0
+#define STAT_COMMAND_REG_OFFSET		4
+#define STAT_WRITE_REG_OFFSET		8
+#define STAT_READ_REG_OFFSET		12
+#define STAT_COMMAND_DONE_REG_OFFSET	16
+
+/* Address PE_MCXMAC  Registers */
+#define MII_MGMT_COMMAND_ADDR                                        0x00000024
+#define MII_MGMT_ADDRESS_ADDR                                        0x00000028
+#define MII_MGMT_CONTROL_ADDR                                        0x0000002c
+#define MII_MGMT_STATUS_ADDR                                         0x00000030
+#define MII_MGMT_INDICATORS_ADDR                                     0x00000034
+
+#define INT_PHY_ADDR	0x1E
+
+#define BUSY_MASK                                                    0x00000001
+#define READ_CYCLE_MASK                                              0x00000001
+#define PHY_CONTROL_WR(src)                         (((u32)(src)) & 0x0000ffff)
+
+#define HW_MTU(m) ((m) + 12 + 2 + 4 /* MAC + CRC */)
+
+enum xgene_enum_speed {
+	XGENE_ENET_SPEED_0 = 0xffff,
+	XGENE_ENET_SPEED_10 = 10,
+	XGENE_ENET_SPEED_100 = 100,
+	XGENE_ENET_SPEED_1000 = 1000,
+	XGENE_ENET_SPEED_10000 = 10000
+};
+
+enum xgene_enet_mode {
+	HALF_DUPLEX = 1,
+	FULL_DUPLEX = 2
+};
+
+enum xgene_enet_phy_mode {
+	PHY_MODE_NONE,
+	PHY_MODE_RGMII,
+	PHY_MODE_SGMII,
+	PHY_MODE_XGMII
+};
+
+enum xgene_enet_cmd {
+	XGENE_ENET_WR_CMD = 0x80000000,
+	XGENE_ENET_RD_CMD = 0x40000000
+};
+
+#define CMU 0
+
+/* ===== MII definitions ===== */
+
+#define MII_CRC_LEN		0x4	/* CRC length in bytes */
+#define MII_ETH_MAX_PCK_SZ      (ETHERMTU + SIZEOF_ETHERHEADER          \
+				 + MII_CRC_LEN)
+#define MII_MAX_PHY_NUM		0x20	/* max number of attached PHYs */
+#define MII_MAX_REG_NUM         0x20	/* max number of registers */
+
+#define MII_CTRL_REG		0x0	/* Control Register */
+#define MII_STAT_REG		0x1	/* Status Register */
+#define MII_PHY_ID1_REG		0x2	/* PHY identifier 1 Register */
+#define MII_PHY_ID2_REG		0x3	/* PHY identifier 2 Register */
+#define MII_AN_ADS_REG		0x4	/* Auto-Negotiation       */
+					/* Advertisement Register */
+#define MII_AN_PRTN_REG		0x5	/* Auto-Negotiation         */
+					/* partner ability Register */
+#define MII_AN_EXP_REG		0x6	/* Auto-Negotiation   */
+					/* Expansion Register */
+#define MII_AN_NEXT_REG		0x7	/* Auto-Negotiation            */
+					/* next-page transmit Register */
+
+#define MII_AN_PRTN_NEXT_REG	0x8	/* Link partner received next page */
+#define MII_MASSLA_CTRL_REG	0x9	/* MATER-SLAVE control register */
+#define MII_MASSLA_STAT_REG	0xa	/* MATER-SLAVE status register */
+#define MII_EXT_STAT_REG	0xf	/* Extented status register */
+
+/* MII control register bit  */
+#define MII_CR_1000		0x0040	/* 1 = 1000mb when
+					* MII_CR_100 is also 1
+					*/
+#define MII_CR_COLL_TEST	0x0080	/* collision test */
+#define MII_CR_FDX		0x0100	/* FDX =1, half duplex =0 */
+#define MII_CR_RESTART		0x0200	/* restart auto negotiation */
+#define MII_CR_ISOLATE		0x0400	/* isolate PHY from MII */
+#define MII_CR_POWER_DOWN	0x0800	/* power down */
+#define MII_CR_AUTO_EN		0x1000	/* auto-negotiation enable */
+#define MII_CR_100		0x2000	/* 0 = 10mb, 1 = 100mb */
+#define MII_CR_LOOPBACK		0x4000	/* 0 = normal, 1 = loopback */
+#define MII_CR_RESET		0x8000	/* 0 = normal, 1 = PHY reset */
+#define MII_CR_NORM_EN		0x0000	/* just enable the PHY */
+#define MII_CR_DEF_0_MASK       0xca7f	/* they must return zero */
+#define MII_CR_RES_MASK		0x003f	/* reserved bits,return zero */
+
+/* MII Status register bit definitions */
+#define MII_SR_LINK_STATUS	0x0004	/* link Status -- 1 = link */
+#define MII_SR_AUTO_SEL		0x0008	/* auto speed select capable */
+#define MII_SR_REMOTE_FAULT     0x0010	/* Remote fault detect */
+#define MII_SR_AUTO_NEG         0x0020	/* auto negotiation complete */
+#define MII_SR_EXT_STS		0x0100	/* extended sts in reg 15 */
+#define MII_SR_T2_HALF_DPX	0x0200	/* 100baseT2 HD capable */
+#define MII_SR_T2_FULL_DPX	0x0400	/* 100baseT2 FD capable */
+#define MII_SR_10T_HALF_DPX     0x0800	/* 10BaseT HD capable */
+#define MII_SR_10T_FULL_DPX     0x1000	/* 10BaseT FD capable */
+#define MII_SR_TX_HALF_DPX      0x2000	/* TX HD capable */
+#define MII_SR_TX_FULL_DPX      0x4000	/* TX FD capable */
+#define MII_SR_T4               0x8000	/* T4 capable */
+#define MII_SR_ABIL_MASK        0xff80	/* abilities mask */
+#define MII_SR_EXT_CAP          0x0001	/* extended capabilities */
+#define MII_SR_SPEED_SEL_MASK	0xf800	/* Mask to extract just speed
+					 * capabilities  from status
+					 * register.
+					 */
+
+/* MII AN advertisement Register bit definition */
+#define MII_ANAR_10TX_HD        0x0020
+#define MII_ANAR_10TX_FD        0x0040
+#define MII_ANAR_100TX_HD       0x0080
+#define MII_ANAR_100TX_FD       0x0100
+#define MII_ANAR_100T_4         0x0200
+#define MII_ANAR_PAUSE          0x0400
+#define MII_ANAR_ASM_PAUSE      0x0800
+#define MII_ANAR_REMORT_FAULT   0x2000
+#define MII_ANAR_NEXT_PAGE      0x8000
+#define MII_ANAR_PAUSE_MASK     0x0c00
+
+/* MII Link Code word  bit definitions */
+#define MII_BP_FAULT	0x2000	/* remote fault */
+#define MII_BP_ACK	0x4000	/* acknowledge */
+#define MII_BP_NP	0x8000	/* nexp page is supported */
+
+/* MII Next Page bit definitions */
+#define MII_NP_TOGGLE	0x0800	/* toggle bit */
+#define MII_NP_ACK2	0x1000	/* acknowledge two */
+#define MII_NP_MSG	0x2000	/* message page */
+#define MII_NP_ACK1	0x4000	/* acknowledge one */
+#define MII_NP_NP	0x8000	/* nexp page will follow */
+
+/* MII Master-Slave Control register bit definition */
+#define MII_MASSLA_CTRL_1000T_HD    0x100
+#define MII_MASSLA_CTRL_1000T_FD    0x200
+#define MII_MASSLA_CTRL_PORT_TYPE   0x400
+#define MII_MASSLA_CTRL_CONFIG_VAL  0x800
+#define MII_MASSLA_CTRL_CONFIG_EN   0x1000
+
+/* MII Master-Slave Status register bit definition */
+#define MII_MASSLA_STAT_LP1000T_HD  0x400
+#define MII_MASSLA_STAT_LP1000T_FD  0x800
+#define MII_MASSLA_STAT_REMOTE_RCV  0x1000
+#define MII_MASSLA_STAT_LOCAL_RCV   0x2000
+#define MII_MASSLA_STAT_CONF_RES    0x4000
+#define MII_MASSLA_STAT_CONF_FAULT  0x8000
+
+/* these values may be used in the default phy mode field of the load
+ * string, since that is used to force the operating mode of the PHY
+ * in case any attempt to establish the link failed.
+ */
+
+#define PHY_10BASE_T            0x00	/* 10 Base-T */
+#define PHY_10BASE_T_FDX        0x01	/* 10 Base Tx, full duplex */
+#define PHY_100BASE_TX          0x02	/* 100 Base Tx */
+#define PHY_100BASE_TX_FDX      0x03	/* 100 Base TX, full duplex */
+#define PHY_100BASE_T4          0x04	/* 100 Base T4 */
+#define PHY_AN_ENABLE		0x05	/* re-enable auto-negotiation */
+
+#define MII_AN_TBL_MAX		20	/* max number of entries in the table */
+
+/* Realtek PHY definitions */
+#define PHY_SPEED_RES			3
+#define PHY_SPEED_1000			2
+#define PHY_SPEED_100			1
+#define PHY_SPEED_10			0
+#define RTL_PHYSR_ADR			0X11
+#define RTL_PHYSR_SPEED_RD(src)		(((src) & 0x0000C000) >> 14)
+#define RTL_PHYSR_LINK_RD(src)		(((src) & 0x00000400) >> 10)
+
+#define RTL_PHYSR_ADR           0X11
+
+/* LErr(3b) Decoding */
+enum xgene_enet_lerr {
+	ENET_NO_ERR = 0,	/* No Error */
+	ENET_AXI_WR_ERR = 1,	/* AXI write data error due to RSIF */
+	ENET_ING_CRC_ERR = 2,	/* Rx packet had CRC */
+	ENET_AXI_RD_ERR = 3,	/* AXI read data error when processing
+				 * a work message in TSIF
+				 */
+	ENET_LL_RD_ERR = 4,	/* AXI Link List read error when
+				 * processing a work message in TSIF
+				 */
+	ENET_ING_ERR = 5,	/* Rx packet had ingress processing error */
+	ENET_CHKSUM_ERR = 5,	/* Checksum error */
+	ENET_BAD_MSG_ERR = 6,	/* Bad message to subsytem */
+	ENET_MISC_ERR = 7,	/* Other ingress processing error */
+	ENET_MAC_TRUNC_ERR = 7,	/* MAX truncated */
+	ENET_MAC_LEN_ERR = 8,	/* Packet length error */
+	ENET_PKT_LESS64_ERR = 9,	/* MAC length lesser than 64B */
+	ENET_MAC_OVERRUN_ERR = 10,	/* FIFO overrun on ingress */
+	ENET_UNISEC_CHKSUM_ERR = 11,	/* Rx pacekt checksum error */
+	ENET_UNISEC_LEN_ERR = 12,	/* Rx pkt length mismatch QM message */
+	ENET_UNISEC_ICV_ERR = 13,	/* Rx pkt ICV error */
+	ENET_UNISEC_PROTO_ERR = 14,	/* Rx pkt protocol field mismatch */
+	ENET_FP_TIMEOUT_ERR = 15	/* Free pool buffer timeout */
+};
+
+/* Error TX/RX Statistics - maintained by software */
+struct xgene_mac_error_stats {
+	u64 rx_hw_errors;
+	u64 rx_hw_overrun;
+	u64 tx_dropped;
+};
+
+struct xgene_enet_rx_stats {
+	u32 rx_byte_count;	/* Receive Byte Counter */
+	u32 rx_packet_count;	/* Receive Packet Counter */
+	u32 rx_fcs_err_count;	/* Receive FCS Error Counter */
+	u32 rx_alignment_err_pkt_count;	/* Rx Alignment Err Packet Counter */
+	u32 rx_frm_len_err_pkt_count;	/* Rx Frame Len Err Packet Counter */
+	u32 rx_undersize_pkt_count;	/* Receive Undersize Packet Counter */
+	u32 rx_oversize_pkt_count;	/* Receive Oversize Packet Counter */
+	u32 rx_drop_pkt_count;	/* Receive Drop Packet Counter */
+};
+
+struct xgene_enet_tx_stats {
+	u32 tx_byte_count;	/* Tx Byte cnt */
+	u32 tx_pkt_count;	/* Tx pkt cnt */
+	u32 tx_drop_frm_count;	/* Tx Drop Frame cnt */
+	u32 tx_fcs_err_frm_count;	/* Tx FCS Error Frame cnt */
+	u32 tx_undersize_frm_count;	/* Tx Undersize Frame cnt */
+};
+
+struct xgene_enet_detailed_stats {
+	struct xgene_enet_rx_stats rx_stats;
+	struct xgene_enet_tx_stats tx_stats;
+	struct xgene_mac_error_stats estats;
+};
+
+/* Ethernet private structure */
+struct xgene_enet_priv {
+	void *eth_csr_addr_v;
+	void *eth_cle_addr_v;
+	void *eth_qmi_addr_v;
+	void *eth_sds_csr_addr_v;
+	void *eth_clkrst_csr_addr_v;
+	void *eth_diag_csr_addr_v;
+	void *mcx_mac_addr_v;
+	void *mcx_stats_addr_v;
+	void *mcx_mac_csr_addr_v;
+	void *sata_enet_csr_addr_v;
+	void *axg_mac_addr_v;
+	void *axg_stats_addr_v;
+	void *axg_mac_csr_addr_v;
+	void *xgenet_pcs_addr_v;
+	void *xgenet_mdio_csr_addr_v;
+
+	u64 paddr_base;		/* Base physical address of device */
+	void *vaddr_base;	/* Base Virtual address for the device */
+	u64 ppaddr_base;	/* Per port physical address of device */
+	void *vpaddr_base;	/* Per port Virtual address of device */
+	void *vmii_base;	/* Base MII Virtual address of device */
+
+	u32 phy_addr;		/* Virtual address for PHY */
+	u32 phy_mode;
+	u32 port;
+	u32 speed;		/* Forced Link Speed */
+	u32 link_status;
+	u32 crc;
+	u32 autoneg_set;
+	u32 mac_to_mac;		/* Tell traffic is MAC-to-MAC */
+	u32 desired_speed;	/* In case of MAC-to-MAC, no autoneg,
+				 * tell the desired speed to setup
+				 */
+	u32 phyless;		/* PHY stays away from board on
+				 * common server board design
+				 */
+	u32 force_serdes_reset;	/* Force analog reset till stable state */
+
+	/* Function pointers */
+	void (*port_reset) (struct xgene_enet_priv *priv);
+	int (*phy_autoneg_done) (struct xgene_enet_priv *priv);
+	void (*phy_link_mode) (struct xgene_enet_priv *priv,
+			       u32 *speed, u32 *state);
+	void (*mac_reset) (struct xgene_enet_priv *priv);
+	int (*mac_init) (struct xgene_enet_priv *priv,
+			 unsigned char *dev_addr, int speed, int mtu, int crc);
+	void (*mac_rx_state) (struct xgene_enet_priv *priv, u32 enable);
+	void (*mac_tx_state) (struct xgene_enet_priv *priv, u32 enable);
+	void (*mac_change_mtu) (struct xgene_enet_priv *priv, u32 new_mtu);
+	void (*mac_set_ipg) (struct xgene_enet_priv *priv, u16 new_ipg);
+	void (*get_stats) (struct xgene_enet_priv *priv,
+			   struct xgene_enet_detailed_stats *stats);
+	void (*set_mac_addr) (struct xgene_enet_priv *priv,
+			      unsigned char *dev_addr);
+	void (*cle_bypass) (struct xgene_enet_priv *priv, u32 dstqid,
+			    u32 fpsel);
+	void (*tx_offload) (struct xgene_enet_priv *priv, u32 command,
+			    u32 value);
+	void (*qmi_assoc) (struct xgene_enet_priv *priv);
+	void (*port_shutdown) (struct xgene_enet_priv *priv);
+};
+
+int xgene_enet_wr(struct xgene_enet_priv *priv, u8 block_id,
+		  u32 reg_offset, u32 value);
+
+int xgene_enet_rd(struct xgene_enet_priv *priv, u8 block_id,
+		  u32 reg_offset, u32 *value);
+
+void xgene_enet_port_reset(struct xgene_enet_priv *priv);
+
+/* This function resets the entire part of MAC and minimal init for phy access
+ * It will put both Transmit and Receive MAC Control block in reset
+ * and then init.
+ */
+void xgene_enet_mac_reset(struct xgene_enet_priv *priv);
+
+int xgene_enet_mac_init(struct xgene_enet_priv *priv, unsigned char *dev_addr,
+			int speed, int mtu, int crc);
+
+void xgene_enet_mac_rx_state(struct xgene_enet_priv *priv, u32 enable);
+void xgene_enet_mac_tx_state(struct xgene_enet_priv *priv, u32 enable);
+
+void xgene_enet_mac_change_mtu(struct xgene_enet_priv *priv, u32 new_mtu);
+void xgene_enet_mac_set_ipg(struct xgene_enet_priv *priv, u16 ipg);
+
+void xgene_enet_set_mac_addr(struct xgene_enet_priv *priv,
+			     unsigned char *dev_addr);
+
+void xgene_enet_cle_bypass(struct xgene_enet_priv *priv, u32 dstqid, u32 fpsel);
+
+void xgene_enet_tx_offload(struct xgene_enet_priv *priv,
+			   u32 command, u32 value);
+
+void xgene_enet_port_shutdown(struct xgene_enet_priv *priv);
+enum xgene_qmtm_qaccess xgene_enet_get_qacess(void);
+void xgene_genericmiiphy_read(struct xgene_enet_priv *priv, u8 phy_id,
+			      unsigned char reg, u32 *data);
+void xgene_genericmiiphy_write(struct xgene_enet_priv *priv, u8 phy_id,
+			       unsigned char reg, u32 data);
+
+void xgene_enet_get_stats(struct xgene_enet_priv *priv,
+			  struct xgene_enet_detailed_stats *detailed_stats);
+#endif /* __XGENE_ENET_COMMON_H__ */
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_csr.h b/drivers/net/ethernet/apm/xgene/xgene_enet_csr.h
new file mode 100644
index 0000000..c6b49c9
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_csr.h
@@ -0,0 +1,162 @@
+/* AppliedMicro X-Gene SoC Ethernet Driver
+ *
+ * Copyright (c) 2013, Applied Micro Circuits Corporation
+ * Authors:	Ravi Patel <rapatel@apm.com>
+ *		Iyappan Subramanian <isubramanian@apm.com>
+ *		Fushen Chen <fchen@apm.com>
+ *		Keyur Chudgar <kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef __XGENE_ENET_CSR_H__
+#define __XGENE_ENET_CSR_H__
+
+#define ENET_SPARE_CFG_REG_ADDR                                      0x00000750
+#define RSIF_CONFIG_REG_ADDR                                         0x00000010
+#define RSIF_RAM_DBG_REG0_ADDR                                       0x00000048
+#define RGMII_REG_0_ADDR                                             0x000007e0
+#define CFG_LINK_AGGR_RESUME_0_ADDR                                  0x000007c8
+#define DEBUG_REG_ADDR                                               0x00000700
+#define CFG_BYPASS_ADDR                                              0x00000294
+#define CLE_BYPASS_REG0_0_ADDR                                       0x00000490
+#define CLE_BYPASS_REG1_0_ADDR                                       0x00000494
+#define CLE_BYPASS_REG8_0_ADDR                                       0x000004b0
+#define TSIF_MSS_REG0_0_ADDR                                         0x00000108
+#define TSIF_MSS_REG1_0_ADDR                                         0x00000110
+#define TSO_CFG_0_ADDR                                               0x00000314
+#define TSO_CFG_INSERT_VLAN_0_ADDR                                   0x0000031c
+#define CFG_RSIF_FPBUFF_TIMEOUT_EN_WR(src)      (((u32)(src)<<31) & 0x80000000)
+#define CFG_TSIF_MSS_SZ10_SET(dst, src) \
+	(((dst) & ~0x3fff0000) | (((u32)(src)<<16) & 0x3fff0000))
+#define CFG_TSIF_MSS_SZ00_SET(dst, src) \
+	(((dst) & ~0x00003fff) | (((u32)(src)) & 0x00003fff))
+#define CFG_TSIF_MSS_SZ20_SET(dst, src) \
+	(((dst) & ~0x00003fff) | (((u32)(src)) & 0x00003fff))
+#define CFG_TSIF_MSS_SZ30_SET(dst, src) \
+	(((dst) & ~0x3fff0000) | (((u32)(src)<<16) & 0x3fff0000))
+#define RESUME_TX_WR(src)                           (((u32)(src)) & 0x00000001)
+#define CFG_SPEED_1250_WR(src)                  (((u32)(src)<<24) & 0x01000000)
+#define CFG_TXCLK_MUXSEL0_WR(src)               (((u32)(src)<<29) & 0xe0000000)
+#define TX_PORT0_WR(src)                            (((u32)(src)) & 0x00000001)
+#define CFG_BYPASS_UNISEC_TX_WR(src)             (((u32)(src)<<2) & 0x00000004)
+#define CFG_BYPASS_UNISEC_RX_WR(src)             (((u32)(src)<<1) & 0x00000002)
+#define CFG_CLE_BYPASS_EN0_SET(dst, src) \
+	(((dst) & ~0x80000000) | (((u32)(src)<<31) & 0x80000000))
+#define CFG_CLE_IP_PROTOCOL0_SET(dst, src) \
+	(((dst) & ~0x00030000) | (((u32)(src)<<16) & 0x00030000))
+#define CFG_CLE_DSTQID0_SET(dst, src) \
+	(((dst) & ~0x00000fff) | (((u32)(src)) & 0x00000fff))
+#define CFG_CLE_FPSEL0_SET(dst, src) \
+	(((dst) & ~0x000f0000) | (((u32)(src)<<16) & 0x000f0000))
+#define CFG_CLE_HENQNUM0_SET(dst, src) \
+	(((dst) & ~0x0fff0000) | (((u32)(src)<<16) & 0x0fff0000))
+#define ICM_CONFIG0_REG_0_ADDR                                       0x00000400
+#define ICM_CONFIG2_REG_0_ADDR                                       0x00000410
+#define ECM_CONFIG0_REG_0_ADDR                                       0x00000500
+#define RX_DV_GATE_REG_0_ADDR                                        0x000005fc
+#define TX_DV_GATE_EN0_SET(dst, src) \
+	(((dst) & ~0x00000004) | (((u32)(src)<<2) & 0x00000004))
+#define RX_DV_GATE_EN0_SET(dst, src) \
+	(((dst) & ~0x00000002) | (((u32)(src)<<1) & 0x00000002))
+#define RESUME_RX0_SET(dst, src) \
+	(((dst) & ~0x00000001) | (((u32)(src)) & 0x00000001))
+#define ENET_CFGSSQMIWQASSOC_ADDR                                 0x000000e0
+#define ENET_CFGSSQMIFPQASSOC_ADDR                                0x000000dc
+#define ENET_CFGSSQMIQMLITEFPQASSOC_ADDR                          0x000000f0
+#define ENET_CFGSSQMIQMLITEWQASSOC_ADDR                           0x000000f4
+#define ENET_CLKEN_ADDR                                              0x00000008
+#define ENET_SRST_ADDR                                               0x00000000
+#define CSR0_RESET_WR(src)                          (((u32)(src)) & 0x00000001)
+#define ENET0_RESET_WR(src)                      (((u32)(src)<<1) & 0x00000002)
+#define CSR1_RESET_WR(src)                       (((u32)(src)<<2) & 0x00000004)
+#define ENET1_RESET_WR(src)                      (((u32)(src)<<3) & 0x00000008)
+#define CSR0_CLKEN_WR(src)                          (((u32)(src)) & 0x00000001)
+#define ENET0_CLKEN_WR(src)                      (((u32)(src)<<1) & 0x00000002)
+#define CSR1_CLKEN_WR(src)                       (((u32)(src)<<2) & 0x00000004)
+#define ENET1_CLKEN_WR(src)                      (((u32)(src)<<3) & 0x00000008)
+#define ENET_CFG_MEM_RAM_SHUTDOWN_ADDR                            0x00000070
+#define ENET_BLOCK_MEM_RDY_ADDR                                   0x00000074
+#define MAC_CONFIG_1_ADDR                                            0x00000000
+#define MAC_CONFIG_2_ADDR                                            0x00000004
+#define MAX_FRAME_LEN_ADDR                                           0x00000010
+#define MII_MGMT_CONFIG_ADDR                                         0x00000020
+#define MII_MGMT_COMMAND_ADDR                                        0x00000024
+#define MII_MGMT_ADDRESS_ADDR                                        0x00000028
+#define MII_MGMT_CONTROL_ADDR                                        0x0000002c
+#define MII_MGMT_STATUS_ADDR                                         0x00000030
+#define MII_MGMT_INDICATORS_ADDR                                     0x00000034
+#define INTERFACE_CONTROL_ADDR                                       0x00000038
+#define STATION_ADDR0_ADDR                                           0x00000040
+#define STATION_ADDR1_ADDR                                           0x00000044
+#define SCAN_CYCLE_MASK                                              0x00000002
+#define SOFT_RESET1_MASK                                             0x80000000
+#define MAX_FRAME_LEN_SET(dst, src) \
+	(((dst) & ~0x0000ffff) | (((u32)(src)) & 0x0000ffff))
+#define PHY_ADDR_SET(dst, src) \
+	(((dst) & ~0x00001f00) | (((u32)(src)<<8) & 0x00001f00))
+#define REG_ADDR_SET(dst, src) \
+	(((dst) & ~0x0000001f) | (((u32)(src)) & 0x0000001f))
+#define RESET_TX_FUN1_WR(src)                   (((u32)(src)<<16) & 0x00010000)
+#define RESET_RX_FUN1_WR(src)                   (((u32)(src)<<17) & 0x00020000)
+#define RESET_TX_MC1_WR(src)                    (((u32)(src)<<18) & 0x00040000)
+#define RESET_RX_MC1_WR(src)                    (((u32)(src)<<19) & 0x00080000)
+#define SIM_RESET1_WR(src)                      (((u32)(src)<<30) & 0x40000000)
+#define SOFT_RESET1_WR(src)                     (((u32)(src)<<31) & 0x80000000)
+#define TX_EN1_WR(src)                              (((u32)(src)) & 0x00000001)
+#define RX_EN1_WR(src)                           (((u32)(src)<<2) & 0x00000004)
+#define TX_FLOW_EN1_WR(src)                      (((u32)(src)<<4) & 0x00000010)
+#define LOOP_BACK1_WR(src)                       (((u32)(src)<<8) & 0x00000100)
+#define RX_FLOW_EN1_WR(src)                      (((u32)(src)<<5) & 0x00000020)
+#define ENET_LHD_MODE_WR(src)                (((u32)(src)<<25) & 0x02000000)
+#define ENET_GHD_MODE_WR(src)                (((u32)(src)<<26) & 0x04000000)
+#define FULL_DUPLEX2_WR(src)                        (((u32)(src)) & 0x00000001)
+#define LENGTH_CHECK2_WR(src)                    (((u32)(src)<<4) & 0x00000010)
+#define HUGE_FRAME_EN2_WR(src)                   (((u32)(src)<<5) & 0x00000020)
+#define ENET_INTERFACE_MODE2_WR(src)          (((u32)(src)<<8) & 0x00000300)
+#define PAD_CRC2_WR(src)                         (((u32)(src)<<2) & 0x00000004)
+#define CRC_EN2_WR(src)                          (((u32)(src)<<1) & 0x00000002)
+#define PREAMBLE_LENGTH2_WR(src)                (((u32)(src)<<12) & 0x0000f000)
+#define MAX_FRAME_LEN_WR(src)                       (((u32)(src)) & 0x0000ffff)
+#define MGMT_CLOCK_SEL_SET(dst, src) \
+	(((dst) & ~0x00000007) | (((u32)(src)) & 0x00000007))
+#define RX_EN1_SET(dst, src) \
+	(((dst) & ~0x00000004) | (((u32)(src)<<2) & 0x00000004))
+#define TX_EN1_SET(dst, src) \
+	(((dst) & ~0x00000001) | (((u32)(src)) & 0x00000001))
+#define SCAN_AUTO_INCR_MASK                                          0x00000020
+#define RBYT_ADDR                                                    0x00000027
+#define RPKT_ADDR                                                    0x00000028
+#define RFCS_ADDR                                                    0x00000029
+#define RALN_ADDR                                                    0x0000002f
+#define RFLR_ADDR                                                    0x00000030
+#define RUND_ADDR                                                    0x00000033
+#define ROVR_ADDR                                                    0x00000034
+#define RDRP_ADDR                                                    0x00000037
+#define TBYT_ADDR                                                    0x00000038
+#define TPKT_ADDR                                                    0x00000039
+#define TDRP_ADDR                                                    0x00000045
+#define TFCS_ADDR                                                    0x00000047
+#define TUND_ADDR                                                    0x0000004a
+#define RX_BYTE_CNTR_MASK                                            0x7fffffff
+#define RX_PKT_CNTR_MASK                                             0x7fffffff
+#define RX_FCS_ERROR_CNTR_MASK                                       0x0000ffff
+#define RX_ALIGN_ERR_CNTR_MASK                                       0x0000ffff
+#define RX_LEN_ERR_CNTR_MASK                                         0x0000ffff
+#define RX_UNDRSIZE_PKT_CNTR_MASK                                    0x0000ffff
+#define RX_OVRSIZE_PKT_CNTR_MASK                                     0x0000ffff
+#define RX_DROPPED_PKT_CNTR_MASK                                     0x0000ffff
+#define TX_BYTE_CNTR_MASK                                            0x7fffffff
+#define TX_PKT_CNTR_MASK                                             0x7fffffff
+#define TX_DROP_FRAME_CNTR_MASK                                      0x0000ffff
+#define TX_FCS_ERROR_CNTR_MASK                                       0x00000fff
+#define TX_UNDSIZE_FRAME_CNTR_MASK                                   0x00000fff
+
+#endif /* __XGENE_ENET_CSR_H__ */
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_mac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_mac.c
new file mode 100644
index 0000000..68f8851
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_mac.c
@@ -0,0 +1,520 @@
+/* AppliedMicro X-Gene SoC Ethernet Driver
+ *
+ * Copyright (c) 2013, Applied Micro Circuits Corporation
+ * Authors:	Ravi Patel <rapatel@apm.com>
+ *		Iyappan Subramanian <isubramanian@apm.com>
+ *		Fushen Chen <fchen@apm.com>
+ *		Keyur Chudgar <kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#include "xgene_enet_main.h"
+#include "xgene_enet_csr.h"
+
+static void xgene_gmac_set_mac_addr(struct xgene_enet_priv *priv,
+				    unsigned char *dev_addr)
+{
+	u32 a_hi = *(u32 *)&dev_addr[0];
+	u32 a_lo = (u32) *(u16 *)&dev_addr[4];
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, STATION_ADDR0_ADDR, a_hi);
+
+	a_lo <<= 16;
+	a_lo |= (priv->phy_addr & 0xFFFF);
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, STATION_ADDR1_ADDR, a_lo);
+}
+
+static int xgene_enet_ecc_init(struct xgene_enet_priv *priv)
+{
+	u32 data;
+	int wait;
+
+	xgene_enet_wr(priv, BLOCK_ETH_DIAG_CSR,
+			ENET_CFG_MEM_RAM_SHUTDOWN_ADDR, 0x0);
+	/* check for at leaset 1 ms */
+	wait = 1000;
+	do {
+		xgene_enet_rd(priv, BLOCK_ETH_DIAG_CSR,
+			ENET_BLOCK_MEM_RDY_ADDR, &data);
+		usleep_range(1, 100);
+	} while (--wait && data != 0xffffffff);
+	if (!wait) {
+		pr_err("Failed to release memory from shutdown\n");
+		return -ENODEV;
+	}
+
+	return 0;
+}
+
+static void xgene_gmac_change_mtu(struct xgene_enet_priv *priv, u32 new_mtu)
+{
+	u32 data;
+
+	xgene_enet_rd(priv, BLOCK_MCX_MAC, MAX_FRAME_LEN_ADDR, &data);
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, MAX_FRAME_LEN_ADDR,
+		      MAX_FRAME_LEN_SET(data, new_mtu));
+}
+
+static void xgene_gmac_phy_enable_scan_cycle(struct xgene_enet_priv *priv,
+					     int enable)
+{
+	u32 val;
+
+	xgene_enet_rd(priv, BLOCK_MCX_MAC, MII_MGMT_COMMAND_ADDR, &val);
+	if (enable)
+		val |= SCAN_CYCLE_MASK;
+	else
+		val &= ~SCAN_CYCLE_MASK;
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, MII_MGMT_COMMAND_ADDR, val);
+
+	/* Program phy address start scan from 0 and register at address 0x1 */
+	xgene_enet_rd(priv, BLOCK_MCX_MAC, MII_MGMT_ADDRESS_ADDR, &val);
+	val = PHY_ADDR_SET(val, 0);
+	val = REG_ADDR_SET(val, 1);
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, MII_MGMT_ADDRESS_ADDR, val);
+}
+
+static void xgene_gmac_reset(struct xgene_enet_priv *priv)
+{
+	u32 value;
+	xgene_enet_rd(priv, BLOCK_MCX_MAC, MAC_CONFIG_1_ADDR, &value);
+	if (!(value & SOFT_RESET1_MASK))
+		return;
+
+	value = RESET_TX_FUN1_WR(1)
+	    | RESET_RX_FUN1_WR(1)
+	    | RESET_TX_MC1_WR(1)
+	    | RESET_RX_MC1_WR(1)
+	    | SIM_RESET1_WR(1)
+	    | SOFT_RESET1_WR(1);
+
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, MAC_CONFIG_1_ADDR, value);
+	xgene_enet_rd(priv, BLOCK_MCX_MAC, MAC_CONFIG_1_ADDR, &value);
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, MAC_CONFIG_1_ADDR, 0);
+}
+
+int xgene_gmac_init(struct xgene_enet_priv *priv, unsigned char *dev_addr,
+		    int speed, int mtu, int crc)
+{
+	u32 value, temp;
+	u32 addr_hi, addr_lo;
+
+	u32 interface_control;
+	u32 mac_config_2;
+	u32 rgmii;
+	u32 icm_config0 = 0x0008503f;
+	u32 icm_config2 = 0x0010000f;
+	u32 ecm_config0 = 0x00000032;
+	u32 enet_spare_cfg = 0x00006040;
+
+	/* Reset subsystem */
+	value = RESET_TX_FUN1_WR(1)
+	    | RESET_RX_FUN1_WR(1)
+	    | RESET_TX_MC1_WR(1)
+	    | RESET_RX_MC1_WR(1)
+	    | SIM_RESET1_WR(1)
+	    | SOFT_RESET1_WR(1);
+
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, MAC_CONFIG_1_ADDR, value);
+	xgene_enet_rd(priv, BLOCK_MCX_MAC, MAC_CONFIG_1_ADDR, &temp);
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, MAC_CONFIG_1_ADDR, 0);
+	xgene_enet_rd(priv, BLOCK_MCX_MAC, MAC_CONFIG_1_ADDR, &temp);
+
+	value = TX_EN1_WR(1)
+	    | RX_EN1_WR(1)
+	    | TX_FLOW_EN1_WR(0)
+	    | LOOP_BACK1_WR(0)
+	    | RX_FLOW_EN1_WR(0);
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, MAC_CONFIG_1_ADDR, value);
+	xgene_enet_rd(priv, BLOCK_ETH_CSR,
+		      ENET_SPARE_CFG_REG_ADDR, &enet_spare_cfg);
+
+	if (speed == XGENE_ENET_SPEED_10) {
+		interface_control = ENET_LHD_MODE_WR(0)
+		    | ENET_GHD_MODE_WR(0);
+		mac_config_2 = FULL_DUPLEX2_WR(1)
+		    | LENGTH_CHECK2_WR(0)
+		    | HUGE_FRAME_EN2_WR(0)
+		    | ENET_INTERFACE_MODE2_WR(1)	/* 10Mbps */
+		    |PAD_CRC2_WR(crc)
+		    | CRC_EN2_WR(crc)
+		    | PREAMBLE_LENGTH2_WR(7);
+		rgmii = 0;
+		icm_config0 = 0x0000503f;
+		icm_config2 = 0x000101f4;
+		ecm_config0 = 0x600032;
+		enet_spare_cfg = enet_spare_cfg | (0x0000c040);
+	} else if (speed == XGENE_ENET_SPEED_100) {
+		interface_control = ENET_LHD_MODE_WR(1);
+		mac_config_2 = FULL_DUPLEX2_WR(1)
+		    | LENGTH_CHECK2_WR(0)
+		    | HUGE_FRAME_EN2_WR(0)
+		    | ENET_INTERFACE_MODE2_WR(1)	/* 100Mbps */
+		    |PAD_CRC2_WR(crc)
+		    | CRC_EN2_WR(crc)
+		    | PREAMBLE_LENGTH2_WR(7);
+		rgmii = 0;
+		icm_config0 = 0x0004503f;
+		icm_config2 = 0x00010050;
+		ecm_config0 = 0x600032;
+		enet_spare_cfg = enet_spare_cfg | (0x0000c040);
+	} else {
+		interface_control = ENET_GHD_MODE_WR(1);
+		mac_config_2 = FULL_DUPLEX2_WR(1)
+		    | LENGTH_CHECK2_WR(0)
+		    | HUGE_FRAME_EN2_WR(0)
+		    | ENET_INTERFACE_MODE2_WR(2)	/* 1Gbps */
+		    |PAD_CRC2_WR(crc)
+		    | CRC_EN2_WR(crc)
+		    | PREAMBLE_LENGTH2_WR(7);
+		rgmii = CFG_SPEED_1250_WR(1) | CFG_TXCLK_MUXSEL0_WR(4);
+		icm_config0 = 0x0008503f;
+		icm_config2 = 0x0001000f;
+		ecm_config0 = 0x32;
+		enet_spare_cfg = (enet_spare_cfg & ~0x0000c000)
+		    | (0x00000040);
+	}
+
+	enet_spare_cfg |= 0x00006040;
+
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, MAC_CONFIG_2_ADDR, mac_config_2);
+
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, INTERFACE_CONTROL_ADDR,
+		      interface_control);
+
+	value = MAX_FRAME_LEN_WR(0x0600);
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, MAX_FRAME_LEN_ADDR, value);
+
+	/* Program the station MAC address */
+	addr_hi = *(u32 *) &dev_addr[0];
+	addr_lo = *(u16 *) &dev_addr[4];
+	addr_lo <<= 16;
+	addr_lo |= (priv->phy_addr & 0xFFFF);
+
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, STATION_ADDR0_ADDR, addr_hi);
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, STATION_ADDR1_ADDR, addr_lo);
+
+	/* Adjust MDC clock frequency */
+	xgene_enet_rd(priv, BLOCK_MCX_MAC, MII_MGMT_CONFIG_ADDR, &value);
+	value = MGMT_CLOCK_SEL_SET(value, 7);
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, MII_MGMT_CONFIG_ADDR, value);
+
+	/* Enable drop if FP not available */
+	xgene_enet_rd(priv, BLOCK_ETH_CSR, RSIF_CONFIG_REG_ADDR, &value);
+	value |= CFG_RSIF_FPBUFF_TIMEOUT_EN_WR(1);
+	xgene_enet_wr(priv, BLOCK_ETH_CSR, RSIF_CONFIG_REG_ADDR, value);
+
+	/* Rtype should be copied from FP */
+	value = 0;
+	xgene_enet_wr(priv, BLOCK_ETH_CSR, RSIF_RAM_DBG_REG0_ADDR, value);
+	/* Initialize RGMII PHY */
+	if (priv->phy_mode == PHY_MODE_RGMII)
+		xgene_enet_wr(priv, BLOCK_ETH_CSR, RGMII_REG_0_ADDR, rgmii);
+
+	xgene_enet_wr(priv, BLOCK_MCX_MAC_CSR, ICM_CONFIG0_REG_0_ADDR,
+		      icm_config0);
+	xgene_enet_wr(priv, BLOCK_MCX_MAC_CSR, ICM_CONFIG2_REG_0_ADDR,
+		      icm_config2);
+	xgene_enet_wr(priv, BLOCK_MCX_MAC_CSR, ECM_CONFIG0_REG_0_ADDR,
+		      ecm_config0);
+	xgene_enet_wr(priv, BLOCK_ETH_CSR, ENET_SPARE_CFG_REG_ADDR,
+		      enet_spare_cfg);
+
+	/* Rx-Tx traffic resume */
+	xgene_enet_wr(priv, BLOCK_ETH_CSR,
+		      CFG_LINK_AGGR_RESUME_0_ADDR, TX_PORT0_WR(0x1));
+
+	if (speed != XGENE_ENET_SPEED_10 && speed != XGENE_ENET_SPEED_100) {
+		xgene_enet_rd(priv, BLOCK_ETH_CSR, DEBUG_REG_ADDR, &value);
+		value |= CFG_BYPASS_UNISEC_TX_WR(1)
+		    | CFG_BYPASS_UNISEC_RX_WR(1);
+		xgene_enet_wr(priv, BLOCK_ETH_CSR, DEBUG_REG_ADDR, value);
+	}
+
+	xgene_enet_rd(priv, BLOCK_MCX_MAC_CSR, RX_DV_GATE_REG_0_ADDR, &value);
+	value = TX_DV_GATE_EN0_SET(value, 0);
+	value = RX_DV_GATE_EN0_SET(value, 0);
+	value = RESUME_RX0_SET(value, 1);
+	xgene_enet_wr(priv, BLOCK_MCX_MAC_CSR, RX_DV_GATE_REG_0_ADDR, value);
+
+	xgene_enet_wr(priv, BLOCK_ETH_CSR, CFG_BYPASS_ADDR, RESUME_TX_WR(1));
+	return 0;
+}
+
+/* Start Statistics related functions */
+static void xgene_gmac_get_rx_stats(struct xgene_enet_priv *priv,
+				    struct xgene_enet_rx_stats *rx_stat)
+{
+	xgene_enet_rd(priv, BLOCK_MCX_STATS, RBYT_ADDR,
+		      &rx_stat->rx_byte_count);
+	xgene_enet_rd(priv, BLOCK_MCX_STATS, RPKT_ADDR,
+		      &rx_stat->rx_packet_count);
+	xgene_enet_rd(priv, BLOCK_MCX_STATS, RDRP_ADDR,
+		      &rx_stat->rx_drop_pkt_count);
+	xgene_enet_rd(priv, BLOCK_MCX_STATS, RFCS_ADDR,
+		      &rx_stat->rx_fcs_err_count);
+	xgene_enet_rd(priv, BLOCK_MCX_STATS, RFLR_ADDR,
+		      &rx_stat->rx_frm_len_err_pkt_count);
+	xgene_enet_rd(priv, BLOCK_MCX_STATS, RALN_ADDR,
+		      &rx_stat->rx_alignment_err_pkt_count);
+	xgene_enet_rd(priv, BLOCK_MCX_STATS, ROVR_ADDR,
+		      &rx_stat->rx_oversize_pkt_count);
+	xgene_enet_rd(priv, BLOCK_MCX_STATS, RUND_ADDR,
+		      &rx_stat->rx_undersize_pkt_count);
+
+	rx_stat->rx_byte_count &= RX_BYTE_CNTR_MASK;
+	rx_stat->rx_packet_count &= RX_PKT_CNTR_MASK;
+	rx_stat->rx_drop_pkt_count &= RX_DROPPED_PKT_CNTR_MASK;
+	rx_stat->rx_fcs_err_count &= RX_FCS_ERROR_CNTR_MASK;
+	rx_stat->rx_frm_len_err_pkt_count &= RX_LEN_ERR_CNTR_MASK;
+	rx_stat->rx_alignment_err_pkt_count &= RX_ALIGN_ERR_CNTR_MASK;
+	rx_stat->rx_oversize_pkt_count &= RX_OVRSIZE_PKT_CNTR_MASK;
+	rx_stat->rx_undersize_pkt_count &= RX_UNDRSIZE_PKT_CNTR_MASK;
+}
+
+static void xgene_gmac_get_tx_stats(struct xgene_enet_priv *priv,
+				    struct xgene_enet_tx_stats *tx_stats)
+{
+	xgene_enet_rd(priv, BLOCK_MCX_STATS, TBYT_ADDR,
+		      &tx_stats->tx_byte_count);
+	xgene_enet_rd(priv, BLOCK_MCX_STATS, TPKT_ADDR,
+		      &tx_stats->tx_pkt_count);
+	xgene_enet_rd(priv, BLOCK_MCX_STATS, TDRP_ADDR,
+		      &tx_stats->tx_drop_frm_count);
+	xgene_enet_rd(priv, BLOCK_MCX_STATS, TFCS_ADDR,
+		      &tx_stats->tx_fcs_err_frm_count);
+	xgene_enet_rd(priv, BLOCK_MCX_STATS, TUND_ADDR,
+		      &tx_stats->tx_undersize_frm_count);
+
+	tx_stats->tx_byte_count &= TX_BYTE_CNTR_MASK;
+	tx_stats->tx_pkt_count &= TX_PKT_CNTR_MASK;
+	tx_stats->tx_drop_frm_count &= TX_DROP_FRAME_CNTR_MASK;
+	tx_stats->tx_fcs_err_frm_count &= TX_FCS_ERROR_CNTR_MASK;
+	tx_stats->tx_undersize_frm_count &= TX_UNDSIZE_FRAME_CNTR_MASK;
+}
+
+static void xgene_gmac_get_detailed_stats(struct xgene_enet_priv *priv,
+		struct xgene_enet_detailed_stats *stats)
+{
+	xgene_gmac_get_rx_stats(priv, &(stats->rx_stats));
+	xgene_gmac_get_tx_stats(priv, &(stats->tx_stats));
+}
+
+/* Configure Ethernet QMI: WQ and FPQ association to QML */
+static void xgene_enet_config_qmi_assoc(struct xgene_enet_priv *priv)
+{
+	xgene_enet_wr(priv, BLOCK_ETH_QMI, ENET_CFGSSQMIWQASSOC_ADDR,
+		      0xffffffff);
+	xgene_enet_wr(priv, BLOCK_ETH_QMI, ENET_CFGSSQMIFPQASSOC_ADDR,
+		      0xffffffff);
+	xgene_enet_wr(priv, BLOCK_ETH_QMI, ENET_CFGSSQMIQMLITEFPQASSOC_ADDR,
+		      0xffffffff);
+	xgene_enet_wr(priv, BLOCK_ETH_QMI, ENET_CFGSSQMIQMLITEWQASSOC_ADDR,
+		      0xffffffff);
+}
+
+static void xgene_enet_cle_bypass_mode_cfg(struct xgene_enet_priv *priv,
+					   u32 cle_dstqid, u32 cle_fpsel)
+{
+	u32 reg;
+
+	xgene_enet_rd(priv, BLOCK_ETH_CSR, CLE_BYPASS_REG0_0_ADDR, &reg);
+	reg = CFG_CLE_BYPASS_EN0_SET(reg, 1);
+	reg = CFG_CLE_IP_PROTOCOL0_SET(reg, 3);
+	xgene_enet_wr(priv, BLOCK_ETH_CSR, CLE_BYPASS_REG0_0_ADDR, reg);
+
+	xgene_enet_rd(priv, BLOCK_ETH_CSR, CLE_BYPASS_REG1_0_ADDR, &reg);
+	reg = CFG_CLE_DSTQID0_SET(reg, cle_dstqid);
+	reg = CFG_CLE_FPSEL0_SET(reg, cle_fpsel);
+	xgene_enet_wr(priv, BLOCK_ETH_CSR, CLE_BYPASS_REG1_0_ADDR, reg);
+
+	xgene_enet_rd(priv, BLOCK_ETH_CSR, CLE_BYPASS_REG8_0_ADDR, &reg);
+	reg = CFG_CLE_HENQNUM0_SET(reg, cle_dstqid);
+	xgene_enet_wr(priv, BLOCK_ETH_CSR, CLE_BYPASS_REG8_0_ADDR, reg);
+}
+
+static void xgene_gmac_rx_state(struct xgene_enet_priv *priv, u32 enable)
+{
+	u32 data, rx_en;
+
+	xgene_enet_rd(priv, BLOCK_MCX_MAC, MAC_CONFIG_1_ADDR, &data);
+	rx_en = (enable) ? RX_EN1_SET(data, 1) : RX_EN1_SET(data, 0);
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, MAC_CONFIG_1_ADDR, rx_en);
+}
+
+static void xgene_gmac_tx_state(struct xgene_enet_priv *priv, u32 enable)
+{
+	u32 data, tx_en;
+
+	xgene_enet_rd(priv, BLOCK_MCX_MAC, MAC_CONFIG_1_ADDR, &data);
+	tx_en = (enable) ? TX_EN1_SET(data, 1) : TX_EN1_SET(data, 0);
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, MAC_CONFIG_1_ADDR, tx_en);
+}
+
+static void xgene_gmac_tx_offload(struct xgene_enet_priv *priv,
+				  u32 command, u32 value)
+{
+	u32 data;
+
+	switch (priv->port) {
+	case MENET:
+		switch (command) {
+			/* TCP MSS 0 */
+		case XGENE_ENET_MSS0:
+			xgene_enet_rd(priv, BLOCK_ETH_CSR,
+				      TSIF_MSS_REG0_0_ADDR, &data);
+			xgene_enet_wr(priv, BLOCK_ETH_CSR,
+				      TSIF_MSS_REG0_0_ADDR,
+				      CFG_TSIF_MSS_SZ00_SET(data, value));
+			break;
+			/* TCP MSS 1 */
+		case XGENE_ENET_MSS1:
+			xgene_enet_rd(priv, BLOCK_ETH_CSR,
+				      TSIF_MSS_REG0_0_ADDR, &data);
+			xgene_enet_wr(priv, BLOCK_ETH_CSR,
+				      TSIF_MSS_REG0_0_ADDR,
+				      CFG_TSIF_MSS_SZ10_SET(data, value));
+			break;
+			/* TCP MSS 2 */
+		case XGENE_ENET_MSS2:
+			xgene_enet_rd(priv, BLOCK_ETH_CSR,
+				      TSIF_MSS_REG1_0_ADDR, &data);
+			xgene_enet_wr(priv, BLOCK_ETH_CSR,
+				      TSIF_MSS_REG1_0_ADDR,
+				      CFG_TSIF_MSS_SZ20_SET(data, value));
+			break;
+			/* TCP MSS 3 */
+		case XGENE_ENET_MSS3:
+			xgene_enet_rd(priv, BLOCK_ETH_CSR,
+				      TSIF_MSS_REG1_0_ADDR, &data);
+			xgene_enet_wr(priv, BLOCK_ETH_CSR,
+				      TSIF_MSS_REG1_0_ADDR,
+				      CFG_TSIF_MSS_SZ30_SET(data, value));
+			break;
+			/* Program TSO config */
+		case XGENE_ENET_TSO_CFG:
+			xgene_enet_wr(priv, BLOCK_ETH_CSR, TSO_CFG_0_ADDR,
+				      value);
+			break;
+			/* Insert Inser tVLAN TAG */
+		case XGENE_ENET_INSERT_VLAN:
+			xgene_enet_wr(priv, BLOCK_ETH_CSR,
+				      TSO_CFG_INSERT_VLAN_0_ADDR, value);
+			break;
+		}
+		break;
+	default:
+		break;
+	}
+}
+
+static void xgene_enet_clkrst_cfg(struct xgene_enet_priv *priv)
+{
+	u32 data;
+
+	/* disable all clocks */
+	data = CSR0_CLKEN_WR(0) | ENET0_CLKEN_WR(0) |
+	    CSR1_CLKEN_WR(0) | ENET1_CLKEN_WR(0);
+	xgene_enet_wr(priv, BLOCK_ETH_CLKRST_CSR, ENET_CLKEN_ADDR, data);
+
+	/* enable all clocks */
+	data = CSR0_CLKEN_WR(1) | ENET0_CLKEN_WR(1) |
+	    CSR1_CLKEN_WR(1) | ENET1_CLKEN_WR(1);
+	xgene_enet_wr(priv, BLOCK_ETH_CLKRST_CSR, ENET_CLKEN_ADDR, data);
+
+	/* put csr and core reset */
+	data = CSR0_RESET_WR(1) | ENET0_RESET_WR(1) |
+	    CSR1_RESET_WR(1) | ENET1_RESET_WR(1);
+	xgene_enet_wr(priv, BLOCK_ETH_CLKRST_CSR, ENET_SRST_ADDR, data);
+
+	/* release csr and core reset */
+	data = CSR0_RESET_WR(0) | ENET0_RESET_WR(0) |
+	    CSR1_RESET_WR(0) | ENET1_RESET_WR(0);
+	xgene_enet_wr(priv, BLOCK_ETH_CLKRST_CSR, ENET_SRST_ADDR, data);
+
+	xgene_enet_ecc_init(priv);
+}
+
+static void xgene_gport_reset(struct xgene_enet_priv *priv)
+{
+	u32 val;
+
+	xgene_enet_clkrst_cfg(priv);
+	xgene_enet_config_qmi_assoc(priv);
+
+	/* Enable auto-incr for scanning */
+	xgene_enet_rd(priv, BLOCK_MCX_MAC, MII_MGMT_CONFIG_ADDR, &val);
+	val |= SCAN_AUTO_INCR_MASK;
+	val = MGMT_CLOCK_SEL_SET(val, 1);
+	xgene_enet_wr(priv, BLOCK_MCX_MAC, MII_MGMT_CONFIG_ADDR, val);
+	xgene_gmac_phy_enable_scan_cycle(priv, 1);
+}
+
+static void xgene_gport_shutdown(struct xgene_enet_priv *priv)
+{
+	u32 clk, rst;
+
+	rst = CSR0_RESET_WR(1) | ENET0_RESET_WR(1);
+	clk = CSR0_CLKEN_WR(0) | ENET0_CLKEN_WR(0);
+
+	/* reset ethernet csr, core and disable clock */
+	xgene_enet_wr(priv, BLOCK_ETH_CLKRST_CSR, ENET_SRST_ADDR, rst);
+	xgene_enet_wr(priv, BLOCK_ETH_CLKRST_CSR, ENET_CLKEN_ADDR, clk);
+}
+
+void xgene_enet_init_priv(struct xgene_enet_priv *priv)
+{
+	void *gbl_vaddr = priv->vaddr_base;
+	void *port_vaddr = priv->vpaddr_base;
+
+	/* Initialize base addresses for direct access */
+	priv->eth_csr_addr_v = gbl_vaddr + BLOCK_ETH_CSR_OFFSET;
+	priv->eth_cle_addr_v = gbl_vaddr + BLOCK_ETH_CLE_OFFSET;
+	priv->eth_qmi_addr_v = gbl_vaddr + BLOCK_ETH_QMI_OFFSET;
+	priv->eth_sds_csr_addr_v = gbl_vaddr + BLOCK_ETH_SDS_CSR_OFFSET;
+	priv->eth_clkrst_csr_addr_v = gbl_vaddr + BLOCK_ETH_CLKRST_CSR_OFFSET;
+	priv->eth_diag_csr_addr_v = gbl_vaddr + BLOCK_ETH_DIAG_CSR_OFFSET;
+
+	/* Initialize per port base addr for indirect & direct MCX MAC access */
+	priv->mcx_mac_addr_v = port_vaddr + BLOCK_ETH_MAC_OFFSET;
+	priv->mcx_stats_addr_v = port_vaddr + BLOCK_ETH_STATS_OFFSET;
+	priv->mcx_mac_csr_addr_v = gbl_vaddr + BLOCK_ETH_MAC_CSR_OFFSET;
+	priv->sata_enet_csr_addr_v = gbl_vaddr + BLOCK_SATA_ENET_CSR_OFFSET;
+
+	/* Enable autonegotiation by default */
+	priv->autoneg_set = 1;
+
+	pr_debug("         ETH%d VADDR: 0x%p\n", priv->port, priv->vpaddr_base);
+	pr_debug("           ETH VADDR: 0x%p\n", priv->vaddr_base);
+	pr_debug("       ETH CSR VADDR: 0x%p\n", priv->eth_csr_addr_v);
+	pr_debug("       ETH CLE VADDR: 0x%p\n", priv->eth_cle_addr_v);
+	pr_debug("       ETH QMI VADDR: 0x%p\n", priv->eth_qmi_addr_v);
+	pr_debug("   ETH SDS CSR VADDR: 0x%p\n", priv->eth_sds_csr_addr_v);
+	pr_debug("ETH CLKRST CSR VADDR: 0x%p\n", priv->eth_clkrst_csr_addr_v);
+	pr_debug("      ETH DIAG VADDR: 0x%p\n", priv->eth_diag_csr_addr_v);
+	pr_debug("       MAC MII VADDR: 0x%p\n", priv->vmii_base);
+	pr_debug("       MCX MAC VADDR: 0x%p\n", priv->mcx_mac_addr_v);
+	pr_debug("      MCX STAT VADDR: 0x%p\n", priv->mcx_stats_addr_v);
+	pr_debug("   MCX MAC CSR VADDR: 0x%p\n", priv->mcx_mac_csr_addr_v);
+	pr_debug(" SATA ENET CSR VADDR: 0x%p\n", priv->sata_enet_csr_addr_v);
+
+	/* Initialize priv handlers */
+	priv->port_reset = xgene_gport_reset;
+	priv->mac_reset = xgene_gmac_reset;
+	priv->mac_init = xgene_gmac_init;
+	priv->mac_rx_state = xgene_gmac_rx_state;
+	priv->mac_tx_state = xgene_gmac_tx_state;
+	priv->mac_change_mtu = xgene_gmac_change_mtu;
+	priv->set_mac_addr = xgene_gmac_set_mac_addr;
+	priv->cle_bypass = xgene_enet_cle_bypass_mode_cfg;
+	priv->tx_offload = xgene_gmac_tx_offload;
+	priv->port_shutdown = xgene_gport_shutdown;
+	priv->get_stats = xgene_gmac_get_detailed_stats;
+}
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
new file mode 100644
index 0000000..2aa1808
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -0,0 +1,1581 @@
+/* AppliedMicro X-Gene SoC Ethernet Driver
+ *
+ * Copyright (c) 2013, Applied Micro Circuits Corporation
+ * Authors:	Ravi Patel <rapatel@apm.com>
+ *		Iyappan Subramanian <isubramanian@apm.com>
+ *		Fushen Chen <fchen@apm.com>
+ *		Keyur Chudgar <kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#include "xgene_enet_main.h"
+#include "xgene_enet_csr.h"
+
+inline void xgene_enet_wr32(void *addr, u32 data)
+{
+	pr_debug("Write addr 0x%p data 0x%08X\n", addr, data);
+	writel(data, (void __iomem *)addr);
+}
+
+inline void xgene_enet_rd32(void *addr, u32 *data)
+{
+	*data = readl((void __iomem *)addr);
+	pr_debug("data 0x%08X\n", *data);
+}
+
+inline u32 xgene_enet_get_port(struct xgene_enet_pdev *pdev)
+{
+	return pdev->priv.port;
+}
+
+inline phys_addr_t xgene_enet_enc_addr(void *vaddr)
+{
+	return __pa(vaddr);
+}
+
+inline void *xgene_enet_dec_addr(phys_addr_t paddr)
+{
+	return __va(paddr);
+}
+
+inline void xgene_enet_set_skb_data(struct xgene_qmtm_msg16 *msg16,
+				    struct sk_buff *skb)
+{
+	u64 pa;
+
+	pa = xgene_enet_enc_addr((void *)skb);
+	msg16->UserInfo = (u32) pa;
+	pa >>= 32;
+	msg16->Rv6 = (u8) pa;
+	msg16->Rv2 = (u8) (pa >> 6);
+
+	pa = xgene_enet_enc_addr(skb->data);
+	msg16->DataAddr = pa;
+}
+
+inline struct sk_buff *xgene_enet_get_skb(struct xgene_qmtm_msg16 *msg16)
+{
+	u64 pa = ((u64) msg16->Rv2 << 6) | (u64) msg16->Rv6;
+	pa <<= 32;
+	pa |= (u64) msg16->UserInfo;
+	return (struct sk_buff *)xgene_enet_dec_addr(pa);
+}
+
+static int xgene_enet_init_fp(struct xgene_enet_qcontext *c2e, u32 nbuf)
+{
+	struct xgene_enet_pdev *pdev = c2e->pdev;
+	struct sk_buff *skb;
+	struct xgene_qmtm_msg16 *msg16;
+	u32 i;
+
+	/* Initializing common fields */
+	for (i = 0; i < c2e->qdesc->count; i++) {
+		msg16 = &c2e->qdesc->msg16[i];
+		memset(msg16, 0, sizeof(struct xgene_qmtm_msg16));
+		msg16->C = 1;
+		msg16->BufDataLen = xgene_qmtm_encode_bufdatalen(c2e->buf_size);
+		msg16->FPQNum = c2e->eqnum;
+		msg16->PB = 0;
+		msg16->HB = 1;
+	}
+
+	if (nbuf > c2e->qdesc->count) {
+		netdev_warn(pdev->ndev,
+			    "Limiting number of skb alloc to queue size\n");
+		nbuf = c2e->qdesc->count;
+	}
+
+	for (i = 0; i < nbuf; i++) {
+		msg16 = &c2e->qdesc->msg16[i];
+		skb = dev_alloc_skb(c2e->buf_size);
+		if (unlikely(!skb)) {
+			netdev_err(pdev->ndev,
+				   "Failed to allocate new skb size %d",
+				   c2e->buf_size);
+			return -ENOMEM;
+		}
+		skb_reserve(skb, NET_IP_ALIGN);
+		xgene_enet_set_skb_data(msg16, skb);
+	}
+
+	writel(nbuf, c2e->qdesc->command);
+
+	if (nbuf == c2e->qdesc->count)
+		nbuf = 0;
+	c2e->qdesc->qtail = nbuf;
+
+	return 0;
+}
+
+static int xgene_enet_refill_fp(struct xgene_enet_qcontext *c2e, u32 nbuf)
+{
+	register u32 qtail = c2e->qdesc->qtail;
+	struct xgene_enet_pdev *pdev = c2e->pdev;
+	u32 i;
+
+	for (i = 0; i < nbuf; i++) {
+		struct sk_buff *skb;
+		struct xgene_qmtm_msg16 *msg16 = &c2e->qdesc->msg16[qtail];
+
+		msg16->BufDataLen = xgene_qmtm_encode_bufdatalen(c2e->buf_size);
+		skb = dev_alloc_skb(c2e->buf_size);
+		if (unlikely(!skb)) {
+			netdev_err(pdev->ndev,
+				   "Failed to allocate new skb size %d",
+				   c2e->buf_size);
+			return -ENOMEM;
+		}
+		skb_reserve(skb, NET_IP_ALIGN);
+		xgene_enet_set_skb_data(msg16, skb);
+		if (++qtail == c2e->qdesc->count)
+			qtail = 0;
+	}
+
+	writel(nbuf, c2e->qdesc->command);
+	c2e->qdesc->qtail = qtail;
+
+	return 0;
+}
+
+static void xgene_enet_deinit_fp(struct xgene_enet_qcontext *c2e, int qid)
+{
+	u32 qtail = c2e->qdesc->qtail;
+	u32 count = c2e->qdesc->count;
+	u32 command = 0;
+	struct xgene_enet_pdev *pdev = c2e->pdev;
+	struct xgene_qmtm_msg16 *msg16;
+	struct xgene_qmtm_qinfo qinfo;
+	struct sk_buff *skb;
+	int i;
+
+	memset(&qinfo, 0, sizeof(qinfo));
+	qinfo.qmtm = pdev->sdev->qmtm;
+	qinfo.queue_id = qid;
+	xgene_qmtm_read_qstate(&qinfo);
+
+	for (i = 0; i < qinfo.nummsgs; i++) {
+		if (qtail == 0)
+			qtail = count;
+
+		qtail--;
+		msg16 = &c2e->qdesc->msg16[qtail];
+		if (msg16->UserInfo) {
+			skb = xgene_enet_get_skb(msg16);
+			kfree_skb(skb);
+		}
+		command--;
+	}
+
+	writel(command, c2e->qdesc->command);
+	c2e->qdesc->qtail = qtail;
+}
+
+static int xgene_enet_change_mtu(struct net_device *ndev, int new_mtu)
+{
+	struct xgene_enet_pdev *pdev = netdev_priv(ndev);
+	struct xgene_enet_priv *priv = &pdev->priv;
+	int eth_running;
+
+	if (HW_MTU(new_mtu) < XGENE_ENET_MIN_MTU
+	    || HW_MTU(new_mtu) > XGENE_ENET_MAX_MTU) {
+		netdev_err(ndev, "Invalid MTU: %d\n", new_mtu);
+		return -EINVAL;
+	}
+
+	netdev_info(ndev, "changing MTU from %d to %d\n", ndev->mtu, new_mtu);
+	eth_running = netif_running(ndev);
+	if (eth_running) {
+		netif_stop_queue(ndev);
+		xgene_enet_mac_rx_state(priv, 0);
+		xgene_enet_mac_tx_state(priv, 0);
+	}
+	ndev->mtu = new_mtu;
+	xgene_enet_mac_change_mtu(priv, HW_MTU(new_mtu));
+	if (eth_running) {
+		xgene_enet_mac_rx_state(priv, 1);
+		xgene_enet_mac_tx_state(priv, 1);
+		netif_start_queue(ndev);
+	}
+	return 0;
+}
+
+static int xgene_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+{
+	struct xgene_enet_pdev *pdev = bus->priv;
+	struct xgene_enet_priv *priv = &pdev->priv;
+	u32 regval1;
+
+	xgene_genericmiiphy_read(priv, mii_id, regnum, &regval1);
+	pr_debug("%s: bus=%d reg=%d val=%x\n", __func__, mii_id,
+		 regnum, regval1);
+	return (int)regval1;
+}
+
+static int xgene_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
+				 u16 regval)
+{
+	struct xgene_enet_pdev *pdev = bus->priv;
+	struct xgene_enet_priv *priv = &pdev->priv;
+
+	pr_debug("%s: bus=%d reg=%d val=%x\n", __func__, mii_id,
+		 regnum, regval);
+	xgene_genericmiiphy_write(priv, mii_id, regnum, regval);
+
+	return 0;
+}
+
+static void xgene_enet_mdio_link_change(struct net_device *ndev)
+{
+	struct xgene_enet_pdev *pdev = netdev_priv(ndev);
+	struct xgene_enet_priv *priv = &pdev->priv;
+	struct phy_device *phydev = pdev->phy_dev;
+	int status_change = 0;
+
+	if (phydev->link) {
+		if (pdev->phy_speed != phydev->speed) {
+			xgene_enet_mac_init(priv, ndev->dev_addr, phydev->speed,
+					    HW_MTU(ndev->mtu), priv->crc);
+			pdev->phy_speed = phydev->speed;
+			status_change = 1;
+		}
+	}
+
+	if (phydev->link != pdev->phy_link) {
+		if (!phydev->link)
+			pdev->phy_speed = 0;
+		pdev->phy_link = phydev->link;
+		status_change = 1;
+	}
+
+	if (status_change) {
+		xgene_enet_mac_rx_state(priv, phydev->link);
+		xgene_enet_mac_tx_state(priv, phydev->link);
+		if (phydev->link)
+			netdev_info(ndev, "%s: link up %d Mbps\n",
+				    ndev->name, phydev->speed);
+		else
+			netdev_info(ndev, "%s: link down\n", ndev->name);
+	}
+}
+
+static int xgene_enet_mdio_probe(struct net_device *ndev)
+{
+	struct xgene_enet_pdev *pdev = netdev_priv(ndev);
+	struct phy_device *phydev = NULL;
+	int phy_addr;
+
+	/* find the first phy */
+	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
+		if (pdev->mdio_bus->phy_map[phy_addr]) {
+			phydev = pdev->mdio_bus->phy_map[phy_addr];
+			break;
+		}
+	}
+
+	if (!phydev) {
+		netdev_info(ndev, "%s: no PHY found\n", ndev->name);
+		return -1;
+	}
+
+	/* attach the mac to the phy */
+	phydev = phy_connect(ndev, dev_name(&phydev->dev),
+			     &xgene_enet_mdio_link_change,
+			     PHY_INTERFACE_MODE_RGMII);
+
+	pdev->phy_link = 0;
+	pdev->phy_speed = 0;
+
+	if (IS_ERR(phydev)) {
+		pdev->phy_dev = NULL;
+		netdev_err(ndev, "%s: Could not attach to PHY\n", ndev->name);
+		return PTR_ERR(phydev);
+	}
+	pdev->phy_dev = phydev;
+
+	netdev_info(ndev, "%s: phy_id=0x%08x phy_drv=\"%s\"",
+		    ndev->name, phydev->phy_id, phydev->drv->name);
+
+	return 0;
+}
+
+static int xgene_enet_mdio_remove(struct net_device *ndev)
+{
+	struct xgene_enet_pdev *pdev =
+	    (struct xgene_enet_pdev *)netdev_priv(ndev);
+	struct mii_bus *mdio_bus;
+
+	mdio_bus = pdev->mdio_bus;
+	mdiobus_unregister(mdio_bus);
+	mdiobus_free(mdio_bus);
+	pdev->mdio_bus = NULL;
+
+	return 0;
+}
+
+static inline u32 xgene_enet_hdr_len(const void *data)
+{
+	const struct ethhdr *eth = data;
+	return (eth->h_proto == htons(ETH_P_8021Q)) ? VLAN_ETH_HLEN : ETH_HLEN;
+}
+
+irqreturn_t xgene_enet_e2c_irq(const int irq, void *data)
+{
+	struct xgene_enet_qcontext *e2c = (struct xgene_enet_qcontext *)data;
+
+	if (napi_schedule_prep(&e2c->napi)) {
+		disable_irq_nosync(irq);
+		__napi_schedule(&e2c->napi);
+	}
+
+	return IRQ_HANDLED;
+}
+
+static int xgene_enet_tx_completion(struct xgene_enet_qcontext *e2c,
+				    struct xgene_qmtm_msg32 *msg32_1)
+{
+	struct sk_buff *skb;
+	int rc = 0;
+
+	skb = (struct sk_buff *)xgene_enet_dec_addr(
+			msg32_1->msgup16.H0Info_msb);
+
+	if (likely(skb)) {
+		dev_kfree_skb_any(skb);
+	} else {
+		netdev_info(e2c->pdev->ndev, "completion skb is NULL\n");
+		rc = -1;
+	}
+
+	return rc;
+}
+
+static inline u16 xgene_enet_select_queue(struct net_device *ndev,
+					  struct sk_buff *skb)
+{
+	return skb_tx_hash(ndev, skb);
+}
+
+/* Checksum offload processing */
+static int xgene_enet_checksum_offload(struct net_device *ndev,
+				       struct sk_buff *skb,
+				       struct xgene_qmtm_msg_up16 *msg_up16)
+{
+	u32 maclen, nr_frags, ihl;
+	struct iphdr *iph;
+	struct xgene_enet_pdev *pdev = netdev_priv(ndev);
+	int rc = 0;
+
+	if (unlikely(!(ndev->features & NETIF_F_IP_CSUM)))
+		goto out;
+
+	if (unlikely(skb->protocol != htons(ETH_P_IP)) &&
+	    unlikely(skb->protocol != htons(ETH_P_8021Q)))
+		goto out;
+
+	nr_frags = skb_shinfo(skb)->nr_frags;
+	maclen = xgene_enet_hdr_len(skb->data);
+	iph = ip_hdr(skb);
+	ihl = ip_hdrlen(skb) >> 2;
+
+	if (unlikely(iph->frag_off & htons(IP_MF | IP_OFFSET)))
+		goto out;
+
+	if (likely(iph->protocol == IPPROTO_TCP)) {
+		int xhlen, mss_len;
+		u32 mss, all_hdr_len;
+
+		xhlen = tcp_hdrlen(skb) / 4;
+		msg_up16->H0Info_lsb |=
+		    (xhlen & TSO_TCP_HLEN_MASK) |
+		    ((ihl & TSO_IP_HLEN_MASK) << 6) |
+		    (TSO_CHKSUM_ENABLE << 22) | (TSO_IPPROTO_TCP << 24);
+
+		netdev_dbg(ndev,
+			   "Checksum Offload H0Info 0x%llX H1Info 0x%0llX\n",
+			   (unsigned long long)msg_up16->H0Info_lsb,
+			   (unsigned long long)msg_up16->H0Info_msb);
+
+		if (unlikely(!(ndev->features & NETIF_F_TSO)))
+			goto out;
+
+		/* TCP Segmentation offload processing */
+		mss = skb_shinfo(skb)->gso_size;
+		all_hdr_len = maclen + ip_hdrlen(skb) + tcp_hdrlen(skb);
+		mss_len = skb->len - all_hdr_len;
+
+		/* HW requires all header resides in the first buffer */
+		if (nr_frags && (skb_headlen(skb) < all_hdr_len)) {
+			netdev_err(ndev,
+				   "Unsupported header len location by Eth HW\n");
+			pdev->stats.estats.tx_dropped++;
+			dev_kfree_skb(skb);
+			rc = -1;
+			goto out;
+		}
+
+		if (!mss || mss_len <= mss)
+			goto out;
+
+		if (mss != pdev->mss) {
+			xgene_enet_tx_offload(&pdev->priv, XGENE_ENET_MSS0,
+					      mss);
+			pdev->mss = mss;
+		}
+
+		msg_up16->H0Info_lsb |= ((0 & TSO_MSS_MASK) << 20) |
+		    ((TSO_ENABLE & TSO_ENABLE_MASK) << 23);
+		netdev_dbg(ndev, "TSO H0Info 0x%llX H1Info 0x%0llX mss %d\n",
+			   (unsigned long long)msg_up16->H0Info_lsb,
+			   (unsigned long long)msg_up16->H0Info_msb, mss);
+	} else if (iph->protocol == IPPROTO_UDP) {
+		msg_up16->H0Info_lsb |= (UDP_HDR_SIZE & TSO_TCP_HLEN_MASK)
+		    | ((ihl & TSO_IP_HLEN_MASK) << 6)
+		    | (TSO_CHKSUM_ENABLE << 22)
+		    | (TSO_IPPROTO_UDP << 24);
+		netdev_dbg(ndev, "Csum Offload H0Info 0x%llX H1Info 0x%0llX\n",
+			   (unsigned long long)msg_up16->H0Info_lsb,
+			   (unsigned long long)msg_up16->H0Info_msb);
+	} else {
+		msg_up16->H0Info_lsb |= ((ihl & TSO_IP_HLEN_MASK) << 6);
+	}
+out:
+	return rc;
+}
+
+static void xgene_enet_process_frags(struct net_device *ndev,
+				     struct xgene_qmtm_msg16 *msg16,
+				     struct xgene_enet_qcontext *c2e,
+				     struct sk_buff *skb)
+{
+	struct xgene_qmtm_msg_up16 *msg_up16;
+	struct xgene_qmtm_msg_ext32 *msg32_2;
+	struct xgene_qmtm_msg_ext8 *ext_msg;
+	struct xgene_qmtm_msg_ll8 *ext_msg_ll8;
+	u32 qtail = c2e->qdesc->qtail;
+	phys_addr_t paddr = virt_to_phys(skb->data);
+	u32 nr_frags = skb_shinfo(skb)->nr_frags;
+	skb_frag_t *frag = NULL;
+	u8 *vaddr = NULL;
+	int frag_no = 0, len = 0, offset = 0;
+	int ell_bcnt = 0, ell_cnt = 0, i;
+
+	msg_up16 = (struct xgene_qmtm_msg_up16 *)&msg16[1];
+	msg32_2 = (struct xgene_qmtm_msg_ext32 *)&c2e->qdesc->msg32[qtail];
+
+	if (++qtail == c2e->qdesc->count)
+		qtail = 0;
+
+	memset(msg32_2, 0, sizeof(struct xgene_qmtm_msg_ext32));
+
+	/* First Fragment, 64B message */
+	msg16->BufDataLen = xgene_qmtm_encode_datalen(skb_headlen(skb));
+	msg16->DataAddr = paddr;
+	msg16->NV = 1;
+
+	/* 2nd, 3rd, and 4th fragments */
+	ext_msg = &msg32_2->msg8_1;
+
+	/* Terminate next pointers, will be updated later as required */
+	msg32_2->msg8_2.NxtBufDataLength = 0x7800;
+	msg32_2->msg8_3.NxtBufDataLength = 0x7800;
+	msg32_2->msg8_4.NxtBufDataLength = 0x7800;
+
+	for (i = 0; i < 3 && frag_no < nr_frags; i++) {
+		if (!vaddr) {
+			frag = &skb_shinfo(skb)->frags[frag_no];
+			len = frag->size;
+			vaddr = skb_frag_address(frag);
+			offset = 0;
+			netdev_dbg(ndev, "SKB Frag[%d] 0x%p len %d\n",
+				   frag_no, vaddr, len);
+		}
+		paddr = virt_to_phys(vaddr + offset);
+		ext_msg->NxtDataAddr = paddr;
+
+		if (len <= 16 * 1024) {
+			/* Encode using 16K buffer size format */
+			ext_msg->NxtBufDataLength =
+			    xgene_qmtm_encode_datalen(len);
+			vaddr = NULL;
+			frag_no++;
+		} else {
+			len -= 16 * 1024;
+			offset += 16 * 1024;
+			/* Encode using 16K buffer size format */
+			ext_msg->NxtBufDataLength = 0;
+		}
+
+		netdev_dbg(ndev, "Frag[%d] PADDR 0x%llX len %d\n", i,
+			   (unsigned long long)ext_msg->NxtDataAddr,
+			   ext_msg->NxtBufDataLength);
+		ext_msg = (struct xgene_qmtm_msg_ext8 *)
+		    (((u8 *) msg32_2) + (8 * ((i + 1) ^ 1)));
+	}
+
+	/* Determine no more fragment, last one, or more than one */
+	if (!vaddr) {
+		/* Check next fragment */
+		if (frag_no >= nr_frags) {
+			goto out;
+		} else {
+			frag = &skb_shinfo(skb)->frags[frag_no];
+			if (frag->size <= 16 * 1024
+			    && (frag_no + 1) >= nr_frags)
+				goto one_more_frag;
+			else
+				goto more_than_one_frag;
+		}
+	} else if (len <= 16 * 1024) {
+		/* Current fragment <= 16K, check if last fragment */
+		if ((frag_no + 1) >= nr_frags)
+			goto one_more_frag;
+		else
+			goto more_than_one_frag;
+	} else {
+		/* Current fragment requires two pointers */
+		goto more_than_one_frag;
+	}
+
+one_more_frag:
+	if (!vaddr) {
+		frag = &skb_shinfo(skb)->frags[frag_no];
+		len = frag->size;
+		vaddr = skb_frag_address(frag);
+		offset = 0;
+		netdev_dbg(ndev, "SKB Frag[%d] 0x%p len %d\n",
+			   frag_no, vaddr, len);
+	}
+
+	paddr = virt_to_phys(vaddr + offset);
+	ext_msg->NxtDataAddr = paddr;
+	/* Encode using 16K buffer size format */
+	ext_msg->NxtBufDataLength = xgene_qmtm_encode_datalen(len);
+	netdev_dbg(ndev, "Frag[%d] PADDR 0x%llX len %d\n", i,
+		   (unsigned long long)ext_msg->NxtDataAddr,
+		   ext_msg->NxtBufDataLength);
+	goto out;
+
+more_than_one_frag:
+	msg16->LL = 1;		/* Extended link list */
+	ext_msg_ll8 = &msg32_2->msg8_ll;
+	ext_msg = &c2e->msg8[qtail * 256];
+	memset(ext_msg, 0, 255 * sizeof(struct xgene_qmtm_msg_ext8));
+	paddr = virt_to_phys(ext_msg);
+	ext_msg_ll8->NxtDataPtr = paddr;
+
+	for (i = 0; i < 255 && frag_no < nr_frags;) {
+		if (vaddr == NULL) {
+			frag = &skb_shinfo(skb)->frags[frag_no];
+			len = frag->size;
+			vaddr = skb_frag_address(frag);
+			offset = 0;
+			netdev_dbg(ndev, "SKB Frag[%d] 0x%p len %d\n",
+				   frag_no, vaddr, len);
+		}
+		paddr = virt_to_phys(vaddr + offset);
+		ext_msg[i ^ 1].NxtDataAddr = paddr;
+
+		if (len <= 16 * 1024) {
+			/* Encode using 16K buffer size format */
+			ext_msg[i ^ 1].NxtBufDataLength =
+			    xgene_qmtm_encode_datalen(len);
+			ell_bcnt += len;
+			vaddr = NULL;
+			frag_no++;
+		} else {
+			len -= 16 * 1024;
+			offset += 16 * 1024;
+			ell_bcnt += 16 * 1024;
+		}
+
+		ell_cnt++;
+		netdev_dbg(ndev, "Frag ELL[%d] PADDR 0x%llX len %d\n", i,
+			   (unsigned long long)ext_msg[i ^ 1].NxtDataAddr,
+			   ext_msg[i ^ 1].NxtBufDataLength);
+		i++;
+	}
+
+	/* Encode the extended link list byte count and link count */
+	ext_msg_ll8->NxtLinkListength = ell_cnt;
+	msg_up16->TotDataLengthLinkListLSBs = (ell_bcnt & 0xFFF);
+	ext_msg_ll8->TotDataLengthLinkListMSBs = ((ell_bcnt & 0xFF000) >> 12);
+
+out:
+	c2e->qdesc->qtail = qtail;
+}
+
+/* Packet transmit function */
+static netdev_tx_t xgene_enet_start_xmit(struct sk_buff *skb,
+					 struct net_device *ndev)
+{
+	struct xgene_enet_pdev *pdev = netdev_priv(ndev);
+	struct xgene_enet_qcontext *c2e = pdev->tx[skb->queue_mapping];
+	struct xgene_qmtm_msg16 *msg16;
+	struct xgene_qmtm_msg_up16 *msg_up16;
+	u32 nr_frags = skb_shinfo(skb)->nr_frags;
+	u32 nummsgs = (readl(c2e->nummsgs) & 0x1fffe) >> 1;
+	u32 cmd = 1;
+
+	msg16 =
+	    (struct xgene_qmtm_msg16 *)&c2e->qdesc->msg32[c2e->qdesc->qtail];
+	msg_up16 = (struct xgene_qmtm_msg_up16 *)&msg16[1];
+
+	if (nummsgs > pdev->tx_cqt_hi) {
+		do {
+			nummsgs = (readl(c2e->nummsgs) & 0x1fffe) >> 1;
+		} while (nummsgs < pdev->tx_cqt_low);
+	}
+
+	if (++c2e->qdesc->qtail == c2e->qdesc->count)
+		c2e->qdesc->qtail = 0;
+
+	memset(msg16, 0, sizeof(struct xgene_qmtm_msg32));
+
+	if (likely(nr_frags == 0)) {
+		skb->len = (skb->len < 60) ? 60 : skb->len;
+		msg16->BufDataLen = xgene_qmtm_encode_datalen(skb->len);
+		msg16->DataAddr = virt_to_phys(skb->data);
+	} else {
+		xgene_enet_process_frags(ndev, msg16, c2e, skb);
+		cmd = 2;
+	}
+
+	msg_up16->H0Info_msb = xgene_enet_enc_addr((void *)skb);
+	msg_up16->H0Enq_Num = c2e->eqnum;
+	msg16->C = 1;
+
+	/* Set TYPE_SEL for egress work message */
+	msg_up16->H0Info_lsb = (u64) TYPE_SEL_WORK_MSG << 44;
+
+	/* Enable CRC insertion */
+	if (!pdev->priv.crc)
+		msg_up16->H0Info_lsb |= (u64) ((u64) TSO_INS_CRC_ENABLE << 35);
+
+	/* Setup mac header length H0Info */
+	msg_up16->H0Info_lsb |=
+	    ((xgene_enet_hdr_len(skb->data) & TSO_ETH_HLEN_MASK) << 12);
+
+	if (unlikely(xgene_enet_checksum_offload(ndev, skb, msg_up16)))
+		return NETDEV_TX_OK;
+
+	/* xmit: Push the work message to ENET HW */
+	netdev_dbg(ndev, "TX CQID %d Addr 0x%llx len %d\n",
+		   msg_up16->H0Enq_Num,
+		   (unsigned long long)msg16->DataAddr, msg16->BufDataLen);
+	writel(cmd, c2e->qdesc->command);
+
+	ndev->trans_start = jiffies;
+	return NETDEV_TX_OK;
+}
+
+int xgene_enet_check_skb(struct net_device *ndev,
+			 struct sk_buff *skb,
+			 struct xgene_qmtm_msg32 *msg32_1, u32 qid)
+{
+	struct xgene_qmtm_msg16 *msg16 = &msg32_1->msg16;
+	u32 UserInfo = msg16->UserInfo;
+	u8 NV = msg16->NV;
+	int rc = 0;
+
+	if (unlikely(!skb)) {
+		netdev_err(ndev, "ENET skb NULL UserInfo %d QID %d FP 0x%x\n",
+			   UserInfo, qid, msg16->FPQNum);
+		print_hex_dump(KERN_INFO, "QM msg:",
+			       DUMP_PREFIX_ADDRESS, 16, 4, msg32_1,
+			       NV ? 64 : 32, 1);
+		rc = -1;
+		goto out;
+	}
+
+	if (unlikely(!skb->head) || unlikely(!skb->data)) {
+		netdev_err(ndev, "ENET skb 0x%p head 0x%p data 0x%p FP 0x%x\n",
+			   skb, skb->head, skb->data, msg16->FPQNum);
+		print_hex_dump(KERN_INFO, "QM msg:",
+			       DUMP_PREFIX_ADDRESS, 16, 4, msg32_1,
+			       NV ? 64 : 32, 1);
+		rc = -1;
+		goto out;
+	}
+
+	if (unlikely(skb->len)) {
+		netdev_err(ndev, "ENET skb 0x%p len %d FP 0x%x\n", skb,
+			   skb->len, msg16->FPQNum);
+		print_hex_dump(KERN_INFO, "QM msg:",
+			       DUMP_PREFIX_ADDRESS, 16, 4, msg32_1,
+			       NV ? 64 : 32, 1);
+		rc = -1;
+		goto out;
+	}
+
+out:
+	return rc;
+}
+
+inline void xgene_enet_skip_csum(struct sk_buff *skb)
+{
+	struct iphdr *iph = (struct iphdr *)skb->data;
+	if (likely(!(iph->frag_off & htons(IP_MF | IP_OFFSET)))
+	    || likely(iph->protocol != IPPROTO_TCP
+		      && iph->protocol != IPPROTO_UDP)) {
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	}
+}
+
+/* Process received frame */
+static int xgene_enet_rx_frame(struct xgene_enet_qcontext *e2c,
+			       struct xgene_qmtm_msg32 *msg32_1)
+{
+	struct xgene_enet_qcontext *c2e = e2c->c2e_skb;
+	struct xgene_enet_pdev *pdev = e2c->pdev;
+	struct net_device *ndev = pdev->ndev;
+	struct xgene_qmtm_msg16 *msg16 = &msg32_1->msg16;
+	struct sk_buff *skb = NULL;
+	u32 data_len = xgene_qmtm_decode_datalen(msg16->BufDataLen);
+	u8 NV = msg16->NV;
+	u8 LErr = ((u8) msg16->ELErr << 3) | msg16->LErr;
+	u32 UserInfo = msg16->UserInfo;
+	u32 qid = pdev->qm_queues.rx[e2c->queue_index].qid;
+
+	if (unlikely(UserInfo == 0)) {
+		netdev_err(ndev, "ENET UserInfo NULL QID %d FP 0x%x\n",
+			   qid, msg16->FPQNum);
+		print_hex_dump(KERN_INFO, "QM msg:",
+			       DUMP_PREFIX_ADDRESS, 16, 4, msg32_1,
+			       NV ? 64 : 32, 1);
+		goto err_refill;
+	}
+
+	skb = xgene_enet_get_skb(msg16);
+	if (unlikely(xgene_enet_check_skb(ndev, skb, msg32_1, qid)))
+		goto err_refill;
+
+	/* Check for error, if packet received with error */
+	if (unlikely(LErr)) {
+		if (LErr == 0x15)	/* ignore rx queue full error */
+			goto process_pkt;
+		if (LErr == 0x10 || LErr == 0x11) {
+			LErr = 0;
+			goto process_pkt;
+		}
+		if (LErr == 0x10 || LErr == 5) {
+			LErr = 0;
+			goto process_pkt;
+		}
+
+		netdev_dbg(ndev, "ENET LErr 0x%x skb 0x%p FP 0x%x\n",
+			   LErr, skb, msg16->FPQNum);
+		print_hex_dump(KERN_ERR, "QM Msg: ",
+			       DUMP_PREFIX_ADDRESS, 16, 4, msg32_1,
+			       NV ? 64 : 32, 1);
+		goto err_refill;
+	}
+
+process_pkt:
+	prefetch(skb->data - NET_IP_ALIGN);
+
+	if (likely(!NV)) {
+		/* Strip off CRC as HW isn't doing this */
+		data_len -= 4;
+		skb_put(skb, data_len);
+		netdev_dbg(ndev, "RX port %d SKB len %d\n",
+			   xgene_enet_get_port(pdev), data_len);
+	}
+
+	if (--e2c->c2e_count == 0) {
+		xgene_enet_refill_fp(c2e, 32);
+		e2c->c2e_count = 32;
+	}
+
+	if (pdev->num_rx_queues > 1)
+		skb_record_rx_queue(skb, e2c->queue_index);
+
+	skb->protocol = eth_type_trans(skb, ndev);
+	if (likely(ndev->features & NETIF_F_IP_CSUM)
+	    && likely(LErr == 0)
+	    && likely(skb->protocol == htons(ETH_P_IP))) {
+		xgene_enet_skip_csum(skb);
+	}
+
+	napi_gro_receive(&e2c->napi, skb);
+	return 0;
+
+err_refill:
+	if (skb != NULL)
+		dev_kfree_skb_any(skb);
+
+	xgene_enet_refill_fp(e2c->c2e_skb, 1);
+
+	if (LErr != 0x15)
+		pdev->stats.estats.rx_hw_errors++;
+	else
+		pdev->stats.estats.rx_hw_overrun++;
+
+	return -1;
+}
+
+static int xgene_enet_dequeue_msg(struct xgene_enet_qcontext *e2c, int budget)
+{
+	u32 processed = 0;
+	u32 command = 0;
+	u32 qhead = e2c->qdesc->qhead;
+	u32 count = e2c->qdesc->count;
+	u16 nummsgs;
+
+	while (budget--) {
+		struct xgene_qmtm_msg32 *msg32_1 = &e2c->qdesc->msg32[qhead];
+		struct xgene_qmtm_msg_ext32 *msg32_2 = NULL;
+
+		if (unlikely(((u32 *) msg32_1)[EMPTY_SLOT_INDEX] == EMPTY_SLOT))
+			break;
+
+		command--;
+
+		if (msg32_1->msg16.FPQNum)
+			xgene_enet_rx_frame(e2c, msg32_1);
+		else
+			xgene_enet_tx_completion(e2c, msg32_1);
+
+		if (++qhead == count)
+			qhead = 0;
+
+		if (msg32_1->msg16.NV) {
+			msg32_2 = (struct xgene_qmtm_msg_ext32 *)
+			    &e2c->qdesc->msg32[qhead];
+			if (unlikely(((u32 *) msg32_2)[EMPTY_SLOT_INDEX]
+				     == EMPTY_SLOT)) {
+				command++;
+				if (!qhead)
+					qhead = count;
+				qhead--;
+				break;
+			}
+			command--;
+			if (++qhead == count)
+				qhead = 0;
+		}
+
+		((u32 *) msg32_1)[EMPTY_SLOT_INDEX] = EMPTY_SLOT;
+		if (msg32_2)
+			((u32 *) msg32_2)[EMPTY_SLOT_INDEX] = EMPTY_SLOT;
+		processed++;
+	}
+
+	do {
+		nummsgs = (readl(e2c->nummsgs) & 0x1fffe) >> 1;
+	} while (nummsgs < (1 + ~command));
+	writel(command, e2c->qdesc->command);
+	e2c->qdesc->qhead = qhead;
+
+	return processed;
+}
+
+static int xgene_enet_napi(struct napi_struct *napi, const int budget)
+{
+	struct xgene_enet_qcontext *e2c =
+	    container_of(napi, struct xgene_enet_qcontext, napi);
+	int processed = xgene_enet_dequeue_msg(e2c, budget);
+
+	if (processed != budget) {
+		napi_complete(napi);
+		enable_irq(e2c->qdesc->irq);
+	}
+
+	return processed;
+}
+
+static void xgene_enet_timeout(struct net_device *ndev)
+{
+	struct xgene_enet_pdev *pdev = netdev_priv(ndev);
+	xgene_enet_mac_reset(&pdev->priv);
+}
+
+static void xgene_enet_napi_add(struct xgene_enet_pdev *pdev)
+{
+	u32 qindex;
+
+	for (qindex = 0; qindex < pdev->num_rx_queues; qindex++)
+		netif_napi_add(pdev->ndev, &pdev->rx[qindex]->napi,
+			       xgene_enet_napi, 64);
+}
+
+static void xgene_enet_napi_del(struct xgene_enet_pdev *pdev)
+{
+	u32 qindex;
+
+	for (qindex = 0; qindex < pdev->num_rx_queues; qindex++)
+		netif_napi_del(&pdev->rx[qindex]->napi);
+}
+
+static void xgene_enet_napi_enable(struct xgene_enet_pdev *pdev)
+{
+	u32 qindex;
+
+	for (qindex = 0; qindex < pdev->num_rx_queues; qindex++)
+		napi_enable(&pdev->rx[qindex]->napi);
+}
+
+static void xgene_enet_napi_disable(struct xgene_enet_pdev *pdev)
+{
+	u32 qindex;
+
+	for (qindex = 0; qindex < pdev->num_rx_queues; qindex++)
+		napi_disable(&pdev->rx[qindex]->napi);
+}
+
+static void xgene_enet_irq_enable(struct xgene_enet_pdev *pdev)
+{
+	u32 qindex;
+
+	for (qindex = 0; qindex < pdev->num_rx_queues; qindex++)
+		enable_irq(pdev->rx[qindex]->qdesc->irq);
+}
+
+static void xgene_enet_irq_disable_all(struct xgene_enet_pdev *pdev)
+{
+	u32 qindex;
+
+	for (qindex = 0; qindex < pdev->num_rx_queues; qindex++)
+		disable_irq_nosync(pdev->rx[qindex]->qdesc->irq);
+}
+
+static int xgene_enet_open(struct net_device *ndev)
+{
+	struct xgene_enet_pdev *pdev = netdev_priv(ndev);
+	struct xgene_enet_priv *priv = &pdev->priv;
+
+	xgene_enet_napi_enable(pdev);
+	xgene_enet_irq_enable(pdev);
+
+	netif_tx_start_all_queues(ndev);
+	netif_carrier_on(ndev);
+
+	if (pdev->phy_dev)
+		phy_start(pdev->phy_dev);
+
+	xgene_enet_mac_tx_state(priv, 1);
+	xgene_enet_mac_rx_state(priv, 1);
+
+	return 0;
+}
+
+static int xgene_enet_close(struct net_device *ndev)
+{
+	struct xgene_enet_pdev *pdev = netdev_priv(ndev);
+	struct xgene_enet_priv *priv = &pdev->priv;
+	u32 qindex;
+
+	netif_tx_stop_all_queues(ndev);
+	netif_carrier_off(ndev);
+	netif_tx_disable(ndev);
+
+	if (pdev->phy_dev)
+		phy_stop(pdev->phy_dev);
+
+	xgene_enet_mac_tx_state(priv, 0);
+	xgene_enet_mac_rx_state(priv, 0);
+
+	xgene_enet_irq_disable_all(pdev);
+	xgene_enet_napi_disable(pdev);
+
+	for (qindex = 0; qindex < pdev->num_rx_queues; qindex++)
+		xgene_enet_dequeue_msg(pdev->rx[qindex], -1);
+
+	return 0;
+}
+
+static struct xgene_enet_qcontext *xgene_enet_allocq(struct xgene_enet_pdev
+						     *pdev,
+						     struct xgene_qmtm_qinfo
+						     *qinfo,
+						     struct xgene_qmtm_sdev
+						     *sdev, u8 qtype, u8 qsize)
+{
+	struct xgene_enet_qcontext *qc;
+
+	memset(qinfo, 0, sizeof(struct xgene_qmtm_qinfo));
+	qinfo->sdev = sdev;
+	qinfo->qaccess = QACCESS_ALT;
+	qinfo->qtype = qtype;
+	qinfo->qsize = qsize;
+	qinfo->flags = XGENE_SLAVE_DEFAULT_FLAGS;
+
+	if (xgene_qmtm_set_qinfo(qinfo)) {
+		netdev_err(pdev->ndev, "Could not allocate queue\n");
+		return NULL;
+	}
+
+	qc = (struct xgene_enet_qcontext *)
+	    kmalloc(sizeof(struct xgene_enet_qcontext),
+		    GFP_KERNEL | __GFP_ZERO);
+	qc->nummsgs = &(((u32 *) qinfo->qfabric)[1]);
+	qc->qdesc = qinfo->qdesc;
+	qc->pdev = pdev;
+
+	return qc;
+}
+
+static int xgene_enet_qconfig(struct xgene_enet_pdev *pdev)
+{
+	struct xgene_qmtm_qinfo qinfo;
+	struct xgene_qmtm_sdev *sdev = pdev->sdev;
+	struct xgene_qmtm_sdev *idev = pdev->sdev->idev;
+	int qmtm_ip = sdev->qmtm_ip;
+	int port = pdev->priv.port;
+	int rc = 0;
+	u32 qindex;
+	struct xgene_enet_qcontext *e2c;
+	struct xgene_enet_qcontext *c2e;
+
+	memset(&pdev->qm_queues, 0, sizeof(struct eth_queue_ids));
+	pdev->qm_queues.qm_ip = qmtm_ip;
+
+	for (qindex = 0; qindex < pdev->num_tx_queues; qindex++) {
+		/* Allocate EGRESS work queues from CPUx to ETHx */
+		c2e = xgene_enet_allocq(pdev, &qinfo, sdev,
+					      QTYPE_PQ, QSIZE_64KB);
+		if (!c2e)
+			goto out;
+
+		pdev->qm_queues.tx[qindex].qid = qinfo.queue_id;
+
+		/* Setup TX Frame cpu_to_enet info */
+		c2e->msg8 =
+		    (struct xgene_qmtm_msg_ext8 *)
+		    kmalloc(sizeof(struct xgene_qmtm_msg_ext8) * 256 *
+			    c2e->qdesc->count, GFP_KERNEL);
+		c2e->queue_index = qindex;
+		pdev->tx[qindex] = c2e;
+		/* Assign TX completn queue threshold based on rx queue size */
+		pdev->tx_cqt_hi = c2e->qdesc->count / 4;
+		pdev->tx_cqt_low = pdev->tx_cqt_low / 16;
+	}
+
+	pdev->qm_queues.default_tx_qid = pdev->qm_queues.tx[0].qid;
+
+	for (qindex = 0; qindex < pdev->num_rx_queues; qindex++) {
+		/* Allocate INGRESS work queue from ETHx to CPUx */
+		u8 qsize = QSIZE_512KB;
+		e2c = xgene_enet_allocq(pdev, &qinfo, idev,
+					      QTYPE_PQ, qsize);
+		if (!e2c)
+			goto out;
+
+		pdev->qm_queues.rx[qindex].qid = qinfo.queue_id;
+		e2c->queue_index = qindex;
+		snprintf(e2c->irq_name, sizeof(e2c->irq_name), "%s-rx%d",
+			 pdev->ndev->name, qindex);
+		e2c->c2e_count = 1;
+		pdev->rx[qindex] = e2c;
+
+		/* Allocate free pool for ETHx from CPUx */
+		c2e = xgene_enet_allocq(pdev, &qinfo, sdev,
+					      QTYPE_FP, QSIZE_16KB);
+		if (!c2e)
+			goto out;
+
+		pdev->qm_queues.rx_fp[qindex].qid = qinfo.queue_id;
+		pdev->qm_queues.rx_fp[qindex].pbn = qinfo.pbn;
+
+		c2e->eqnum = QMTM_QUEUE_ID(qmtm_ip, qinfo.queue_id);
+		c2e->buf_size = XGENE_ENET_PKT_BUF_SIZE;
+		pdev->rx_skb_pool[qindex] = c2e;
+		pdev->rx[qindex]->c2e_skb = pdev->rx_skb_pool[qindex];
+
+		/* Configure free pool */
+		xgene_enet_init_fp(pdev->rx_skb_pool[qindex],
+				   pdev->rx_buff_cnt);
+	}
+
+	for (qindex = 0; qindex < pdev->num_tx_queues; qindex++) {
+		u32 cqindex = pdev->num_tx_queues - qindex - 1;
+		u32 rqindex = qindex % pdev->num_rx_queues;
+
+		pdev->tx[cqindex]->nummsgs = pdev->rx[rqindex]->nummsgs;
+		pdev->tx[cqindex]->eqnum = QMTM_QUEUE_ID(qmtm_ip,
+							 pdev->qm_queues.
+							 rx[rqindex].qid);
+	}
+
+	pdev->qm_queues.default_hw_tx_qid = pdev->qm_queues.hw_tx[0].qid;
+	pdev->qm_queues.default_rx_qid = pdev->qm_queues.rx[0].qid;
+	pdev->qm_queues.default_rx_fp_qid = pdev->qm_queues.rx_fp[0].qid;
+	pdev->qm_queues.default_rx_fp_pbn = pdev->qm_queues.rx_fp[0].pbn;
+	pdev->qm_queues.default_rx_nxtfp_qid = pdev->qm_queues.rx_nxtfp[0].qid;
+	pdev->qm_queues.default_rx_nxtfp_pbn = pdev->qm_queues.rx_nxtfp[0].pbn;
+
+	netdev_dbg(pdev->ndev, "Port %d CQID %d FP %d FP PBN %d\n",
+		   port, pdev->qm_queues.default_comp_qid,
+		   pdev->qm_queues.default_rx_fp_qid,
+		   pdev->qm_queues.default_rx_fp_pbn);
+
+out:
+	return rc;
+}
+
+static void xgene_enet_delete_queue(struct xgene_enet_pdev *pdev)
+{
+	struct xgene_qmtm_qinfo qinfo;
+	u32 qindex;
+	u8 qmtm_ip = pdev->sdev->qmtm_ip;
+	u16 queue_id;
+
+	qinfo.qmtm_ip = qmtm_ip;
+
+	for (qindex = 0; qindex < pdev->num_tx_queues; qindex++) {
+		queue_id = pdev->qm_queues.tx[qindex].qid;
+
+		if (queue_id) {
+			qinfo.queue_id = queue_id;
+			xgene_qmtm_clr_qinfo(&qinfo);
+		}
+	}
+
+	for (qindex = 0; qindex < pdev->num_rx_queues; qindex++) {
+		queue_id = pdev->qm_queues.rx[qindex].qid;
+
+		if (queue_id) {
+			qinfo.queue_id = queue_id;
+			xgene_qmtm_clr_qinfo(&qinfo);
+		}
+
+		queue_id = pdev->qm_queues.rx_fp[qindex].qid;
+
+		if (queue_id) {
+			qinfo.queue_id = queue_id;
+			xgene_qmtm_clr_qinfo(&qinfo);
+		}
+	}
+}
+
+static struct net_device_stats *xgene_enet_stats(struct net_device *ndev)
+{
+	struct xgene_enet_pdev *pdev = netdev_priv(ndev);
+	struct xgene_enet_priv *priv = &(pdev->priv);
+	struct net_device_stats *nst = &pdev->nstats;
+	struct xgene_enet_detailed_stats detailed_stats;
+	struct xgene_enet_rx_stats *rx_stats;
+	struct xgene_enet_tx_stats *tx_stats;
+	u32 pkt_bytes, crc_bytes = 4;
+
+	memset(&detailed_stats, 0, sizeof(struct xgene_enet_detailed_stats));
+
+	rx_stats = &detailed_stats.rx_stats;
+	tx_stats = &detailed_stats.tx_stats;
+
+	local_irq_disable();
+	xgene_enet_get_stats(priv, &detailed_stats);
+
+	pkt_bytes = rx_stats->rx_byte_count;
+	pkt_bytes -= (rx_stats->rx_packet_count * crc_bytes);
+	nst->rx_packets += rx_stats->rx_packet_count;
+	nst->rx_bytes += pkt_bytes;
+
+	pkt_bytes = tx_stats->tx_byte_count;
+	pkt_bytes -= (tx_stats->tx_pkt_count * crc_bytes);
+	nst->tx_packets += tx_stats->tx_pkt_count;
+	nst->tx_bytes += pkt_bytes;
+
+	nst->rx_dropped += rx_stats->rx_drop_pkt_count;
+	nst->tx_dropped += tx_stats->tx_drop_frm_count;
+
+	nst->rx_crc_errors += rx_stats->rx_fcs_err_count;
+	nst->rx_length_errors += rx_stats->rx_frm_len_err_pkt_count;
+	nst->rx_frame_errors += rx_stats->rx_alignment_err_pkt_count;
+	nst->rx_over_errors += (rx_stats->rx_oversize_pkt_count
+				+ pdev->stats.estats.rx_hw_overrun);
+
+	nst->rx_errors += (rx_stats->rx_fcs_err_count
+			   + rx_stats->rx_frm_len_err_pkt_count
+			   + rx_stats->rx_oversize_pkt_count
+			   + rx_stats->rx_undersize_pkt_count
+			   + pdev->stats.estats.rx_hw_overrun
+			   + pdev->stats.estats.rx_hw_errors);
+
+	nst->tx_errors += tx_stats->tx_fcs_err_frm_count +
+	    tx_stats->tx_undersize_frm_count;
+
+	local_irq_enable();
+
+	pdev->stats.estats.rx_hw_errors = 0;
+	pdev->stats.estats.rx_hw_overrun = 0;
+
+	return nst;
+}
+
+static int xgene_enet_set_mac_address(struct net_device *ndev, void *p)
+{
+	struct xgene_enet_pdev *pdev = netdev_priv(ndev);
+	struct xgene_enet_priv *priv = &(pdev->priv);
+	struct sockaddr *addr = p;
+
+	if (netif_running(ndev))
+		return -EBUSY;
+
+	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
+	xgene_enet_set_mac_addr(priv, (unsigned char *)(ndev->dev_addr));
+	return 0;
+}
+
+/* net_device_ops structure for data path ethernet */
+static const struct net_device_ops apm_dnetdev_ops = {
+	.ndo_open = xgene_enet_open,
+	.ndo_stop = xgene_enet_close,
+	.ndo_select_queue = xgene_enet_select_queue,
+	.ndo_start_xmit = xgene_enet_start_xmit,
+	.ndo_tx_timeout = xgene_enet_timeout,
+	.ndo_get_stats = xgene_enet_stats,
+	.ndo_change_mtu = xgene_enet_change_mtu,
+	.ndo_set_mac_address = xgene_enet_set_mac_address,
+};
+
+static void xgene_enet_register_irq(struct net_device *ndev)
+{
+	struct xgene_enet_pdev *pdev;
+	struct device *dev;
+	u32 qindex;
+
+	pdev = (struct xgene_enet_pdev *)netdev_priv(ndev);
+	dev = &pdev->plat_dev->dev;
+
+	for (qindex = 0; qindex < pdev->num_rx_queues; qindex++) {
+		if (devm_request_irq(dev, pdev->rx[qindex]->qdesc->irq,
+				xgene_enet_e2c_irq, 0,
+				pdev->rx[qindex]->irq_name,
+				(void *)pdev->rx[qindex]) != 0) {
+			netdev_err(ndev, "request_irq failed %d for RX Frame\n",
+				   pdev->rx[qindex]->qdesc->irq);
+			return;
+		}
+
+		/* Disable interrupts for RX queue mailboxes */
+		disable_irq_nosync(pdev->rx[qindex]->qdesc->irq);
+	}
+}
+
+static int xgene_enet_get_resources(struct xgene_enet_pdev *pdev)
+{
+	struct platform_device *plat_dev;
+	struct net_device *ndev;
+	struct device *dev;
+	struct xgene_enet_priv *priv;
+	struct xgene_qmtm_sdev *sdev;
+	struct xgene_enet_platform_data pdata;
+	struct resource *res;
+	u64 csr_paddr;
+	void *csr_addr;
+	int i, rc;
+
+	plat_dev = pdev->plat_dev;
+	dev = &plat_dev->dev;
+	ndev = pdev->ndev;
+	priv = &pdev->priv;
+
+	rc = of_property_read_u32(plat_dev->dev.of_node, "devid",
+				  &pdata.port_id);
+	if (rc || pdata.port_id >= MAX_ENET_PORTS) {
+		dev_err(dev, "No device ID or invalid value %d\n",
+			pdata.port_id);
+		goto out;
+	}
+	priv->port = pdata.port_id;
+
+	res = platform_get_resource(plat_dev, IORESOURCE_MEM, 0);
+	if (!res) {
+		dev_err(dev, "Unable to retrieve ENET Port CSR region\n");
+		rc = -ENODEV;
+		goto out;
+	}
+	csr_paddr = res->start;
+	csr_addr = devm_ioremap(&plat_dev->dev, csr_paddr, resource_size(res));
+	priv->ppaddr_base = csr_paddr;
+	priv->vpaddr_base = csr_addr;
+
+	res = platform_get_resource(plat_dev, IORESOURCE_MEM, 1);
+	if (!res) {
+		dev_err(dev, "Unable to retrieve ENET Global CSR region\n");
+		rc = -ENODEV;
+		goto out;
+	}
+	csr_paddr = res->start;
+	csr_addr = devm_ioremap(&plat_dev->dev, csr_paddr, resource_size(res));
+	priv->paddr_base = csr_paddr;
+	priv->vaddr_base = csr_addr;
+
+	res = platform_get_resource(plat_dev, IORESOURCE_MEM, 2);
+	if (!res) {
+		dev_err(dev, "Unable to retrieve ENET MII access region\n");
+		rc = -ENODEV;
+		goto out;
+	}
+	csr_paddr = res->start;
+	csr_addr = devm_ioremap(&plat_dev->dev, csr_paddr, resource_size(res));
+	priv->vmii_base = csr_addr;
+
+	rc = of_property_read_string(plat_dev->dev.of_node, "slave-name",
+				     &pdata.sname);
+
+	sdev = xgene_qmtm_get_sdev((char *)pdata.sname);
+	if (!sdev) {
+		dev_err(dev, "QMTM Slave %s error\n", pdata.sname);
+		rc = -ENODEV;
+		goto out;
+	}
+	pdev->sdev = sdev;
+
+	rc = of_property_read_u32(plat_dev->dev.of_node, "phyid",
+				  &pdata.phy_id);
+	if (rc || pdata.phy_id > 0x1F) {
+		dev_err(dev, "No phy ID or invalid value in DTS\n");
+		rc = -EINVAL;
+		goto out;
+	}
+	priv->phy_addr = pdata.phy_id;
+
+	rc = of_property_read_u8_array(plat_dev->dev.of_node,
+				       "local-mac-address", pdata.ethaddr,
+				       ARRAY_SIZE(pdata.ethaddr));
+	if (rc) {
+		dev_err(dev, "Can't get Device MAC address\n");
+	} else {
+		for (i = 0; i < ETH_ALEN; i++)
+			ndev->dev_addr[i] = pdata.ethaddr[i] & 0xff;
+	}
+
+	pdev->clk = clk_get(&plat_dev->dev, NULL);
+
+	if (IS_ERR(pdev->clk))
+		dev_err(&plat_dev->dev, "can't get clock\n");
+	else if (clk_prepare_enable(pdev->clk))
+		dev_err(&plat_dev->dev, "clock prepare enable failed");
+
+	priv->phy_mode = PHY_MODE_RGMII;
+	pdev->rx_buff_cnt = XGENE_NUM_PKT_BUF;
+
+out:
+	return rc;
+}
+
+static int xgene_enet_init_hw(struct xgene_enet_pdev *pdev)
+{
+	struct net_device *ndev;
+	struct xgene_enet_priv *priv;
+	struct mii_bus *mdio_bus;
+	int rc = 0;
+
+	ndev = pdev->ndev;
+	priv = &pdev->priv;
+
+	xgene_enet_port_reset(priv);
+
+	/* To ensure no packet enters the system, disable Rx/Tx */
+	xgene_enet_mac_tx_state(priv, 0);
+	xgene_enet_mac_rx_state(priv, 0);
+
+	ndev->netdev_ops = &apm_dnetdev_ops;
+
+	ndev->features |= NETIF_F_IP_CSUM;
+	ndev->features |= NETIF_F_TSO | NETIF_F_SG;
+	pdev->mss = DEFAULT_TCP_MSS;
+	xgene_enet_tx_offload(priv, XGENE_ENET_MSS0, pdev->mss);
+	ndev->features |= NETIF_F_GRO;
+
+	/* Ethtool checks the capabilities/features in hw_features flag */
+	ndev->hw_features = ndev->features;
+
+	rc = register_netdev(ndev);
+	if (rc) {
+		netdev_err(ndev, "Failed to register net dev(%d)!\n", rc);
+		goto out;
+	}
+
+	rc = xgene_enet_qconfig(pdev);
+	if (rc) {
+		netdev_err(ndev, "Error in QM configuration\n");
+		goto out;
+	}
+
+	xgene_enet_napi_add(pdev);
+
+	xgene_enet_cle_bypass(priv, QMTM_QUEUE_ID(pdev->sdev->qmtm_ip,
+						  pdev->qm_queues.
+						  default_rx_qid),
+			      pdev->qm_queues.default_rx_fp_pbn - 0x20);
+
+	/* Default MAC initialization */
+	xgene_enet_mac_init(priv, ndev->dev_addr, SPEED_1000,
+			    HW_MTU(ndev->mtu), priv->crc);
+
+	/* Setup MDIO bus */
+	mdio_bus = mdiobus_alloc();
+	if (!mdio_bus) {
+		netdev_err(ndev, "Not able to allocate memory for MDIO bus\n");
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	pdev->mdio_bus = mdio_bus;
+	mdio_bus->name = "APM Ethernet MII Bus";
+	mdio_bus->read = xgene_enet_mdio_read;
+	mdio_bus->write = xgene_enet_mdio_write;
+	snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "%x", priv->port);
+	mdio_bus->priv = pdev;
+	mdio_bus->parent = &ndev->dev;
+	mdio_bus->phy_mask = ~(1 << priv->phy_addr);
+	rc = mdiobus_register(mdio_bus);
+	if (rc) {
+		netdev_err(ndev, "Failed to register MDIO bus(%d)!\n", rc);
+		return rc;
+	}
+
+	rc = xgene_enet_mdio_probe(ndev);
+	xgene_enet_register_irq(ndev);
+
+out:
+	return rc;
+}
+
+static int xgene_enet_probe(struct platform_device *plat_dev)
+{
+	struct net_device *ndev;
+	struct xgene_enet_pdev *pdev;
+	struct device *dev;
+	struct xgene_enet_priv *priv;
+	u32 num_tx_queues, num_rx_queues;
+	int rc;
+
+	dev = &plat_dev->dev;
+	num_tx_queues = MAX_TX_QUEUES;
+	num_rx_queues = MAX_RX_QUEUES;
+
+	ndev = alloc_etherdev_mqs(sizeof(struct xgene_enet_pdev),
+				  num_tx_queues, num_rx_queues);
+
+	if (!ndev) {
+		dev_err(dev, "Not able to allocate memory for netdev\n");
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	pdev = (struct xgene_enet_pdev *)netdev_priv(ndev);
+	priv = &pdev->priv;
+	pdev->ndev = ndev;
+	pdev->num_tx_queues = num_tx_queues;
+	pdev->num_rx_queues = num_rx_queues;
+	pdev->plat_dev = plat_dev;
+	pdev->node = plat_dev->dev.of_node;
+	SET_NETDEV_DEV(ndev, &plat_dev->dev);
+	dev_set_drvdata(&plat_dev->dev, pdev);
+
+	xgene_enet_get_resources(pdev);
+
+	xgene_enet_init_priv(priv);
+	rc = xgene_enet_init_hw(pdev);
+
+out:
+	return rc;
+}
+
+static int xgene_enet_remove(struct platform_device *plat_dev)
+{
+	struct xgene_enet_pdev *pdev;
+	struct xgene_enet_priv *priv;
+	struct net_device *ndev;
+	int port;
+	u32 qindex;
+	u8 qmtm_ip;
+
+	pdev = platform_get_drvdata(plat_dev);
+	qmtm_ip = pdev->sdev->qmtm_ip;
+	ndev = pdev->ndev;
+	priv = &pdev->priv;
+
+	port = xgene_enet_get_port(pdev);
+
+	/* Stop any traffic and disable MAC */
+	xgene_enet_mac_rx_state(priv, 0);
+	xgene_enet_mac_tx_state(priv, 0);
+
+	if (netif_running(ndev)) {
+		netif_device_detach(ndev);
+		netif_stop_queue(ndev);
+		xgene_enet_napi_disable(pdev);
+	}
+
+	xgene_enet_napi_del(pdev);
+	xgene_enet_mdio_remove(ndev);
+
+	for (qindex = 0; qindex < pdev->num_rx_queues; qindex++) {
+		if (pdev->qm_queues.rx_fp[qindex].qid > 0)
+			xgene_enet_deinit_fp(pdev->rx_skb_pool[qindex],
+					     pdev->qm_queues.rx_fp[qindex].qid);
+	}
+
+	xgene_enet_delete_queue(pdev);
+
+	for (qindex = 0; qindex < pdev->num_rx_queues; qindex++) {
+		kfree(pdev->rx_skb_pool[qindex]);
+		kfree(pdev->rx[qindex]);
+	}
+	for (qindex = 0; qindex < pdev->num_tx_queues; qindex++) {
+		kfree(pdev->tx[qindex]->msg8);
+		kfree(pdev->tx[qindex]);
+	}
+
+	unregister_netdev(ndev);
+	xgene_enet_port_shutdown(priv);
+
+	free_netdev(ndev);
+
+	return 0;
+}
+
+static struct of_device_id xgene_enet_match[] = {
+	{
+	 .compatible = "apm,xgene-enet",
+	 },
+	{},
+};
+
+MODULE_DEVICE_TABLE(of, xgene_enet_match);
+
+static struct platform_driver xgene_enet_driver = {
+	.driver = {
+		   .name = XGENE_ENET_DRIVER_NAME,
+		   .owner = THIS_MODULE,
+		   .of_match_table = xgene_enet_match,
+		   },
+	.probe = xgene_enet_probe,
+	.remove = xgene_enet_remove,
+};
+
+static int __init xgene_enet_init(void)
+{
+	if (!platform_driver_register(&xgene_enet_driver))
+		pr_info("%s v%s loaded\n", XGENE_ENET_DRIVER_DESC,
+				XGENE_ENET_DRIVER_VERSION);
+
+	return 0;
+}
+
+static void __exit xgene_enet_exit(void)
+{
+	platform_driver_unregister(&xgene_enet_driver);
+	pr_info("%s v%s unloaded\n", XGENE_ENET_DRIVER_DESC,
+			XGENE_ENET_DRIVER_VERSION);
+}
+
+module_init(xgene_enet_init);
+module_exit(xgene_enet_exit);
+
+MODULE_DESCRIPTION(XGENE_ENET_DRIVER_DESC);
+MODULE_VERSION(XGENE_ENET_DRIVER_VERSION);
+MODULE_AUTHOR("Keyur Chudgar <kchudgar@apm.com>");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
new file mode 100644
index 0000000..15ea995
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -0,0 +1,172 @@
+/* AppliedMicro X-Gene SoC Ethernet Driver
+ *
+ * Copyright (c) 2013, Applied Micro Circuits Corporation
+ * Authors:	Ravi Patel <rapatel@apm.com>
+ *		Iyappan Subramanian <isubramanian@apm.com>
+ *		Fushen Chen <fchen@apm.com>
+ *		Keyur Chudgar <kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef __XGENE_ENET_MAIN_H__
+#define __XGENE_ENET_MAIN_H__
+
+#include <linux/clk.h>
+#include <linux/of_platform.h>
+#include <linux/of_irq.h>
+#include <linux/module.h>
+#include <net/ip.h>
+#include <linux/tcp.h>
+#include <linux/interrupt.h>
+#include <linux/if_vlan.h>
+#include <linux/phy.h>
+#include <linux/netdevice.h>
+#include <linux/io.h>
+#include <misc/xgene/xgene_qmtm.h>
+#include "xgene_enet_common.h"
+
+#define XGENE_ENET_DRIVER_NAME "xgene-enet"
+#define XGENE_ENET_DRIVER_VERSION "1.0"
+#define XGENE_ENET_DRIVER_DESC "APM X-Gene SoC Ethernet driver"
+
+#define XGENE_ENET_MIN_MTU		64
+#define XGENE_ENET_MAX_MTU		10000
+
+/* Note: PKT_BUF_SIZE & PKT_NXTBUF_SIZE has to be one of the following:
+ * 256, 1K, 2K, 4K, 16K for ethernet to work with optimum performance.
+ */
+#define XGENE_ENET_PKT_BUF_SIZE		2048
+#define XGENE_NUM_PKT_BUF		256
+
+/* define Enet system struct */
+struct xgene_enet_dev {
+	int refcnt;
+	struct timer_list link_poll_timer;
+	int ipp_loaded;
+	int ipp_hw_mtu;
+};
+
+enum xgene_enet_phy_poll_interval {
+	PHY_POLL_LINK_ON = HZ,
+	PHY_POLL_LINK_OFF = (HZ / 5)
+};
+
+enum xgene_enet_debug_cmd {
+	XGENE_ENET_READ_CMD,
+	XGENE_ENET_WRITE_CMD,
+	XGENE_ENET_MAX_CMD
+};
+
+#define MAX_TX_QUEUES 1
+#define MAX_RX_QUEUES 1
+
+/* This is soft flow context of queue */
+struct xgene_enet_qcontext {
+	struct xgene_enet_pdev *pdev;
+	struct xgene_qmtm_qdesc *qdesc;
+	struct xgene_qmtm_msg_ext8 *msg8;
+	u32 *nummsgs;
+	unsigned int queue_index;
+	unsigned int eqnum;
+	u32 buf_size;
+	unsigned int c2e_count;
+	struct xgene_enet_qcontext *c2e_skb;
+	struct xgene_enet_qcontext *c2e_page;
+	struct napi_struct napi;
+	char irq_name[16];
+};
+
+/* Queues related parameters per Enet port */
+#define ENET_MAX_PBN	8
+#define ENET_MAX_QSEL	8
+
+struct eth_wqids {
+	u16 qtype;
+	u16 qid;
+	u16 arb;
+	u16 qcount;
+	u16 qsel[ENET_MAX_QSEL];
+};
+
+struct eth_fqids {
+	u16 qid;
+	u16 pbn;
+};
+
+struct eth_queue_ids {
+	u16 default_tx_qid;
+	u16 tx_count;
+	u16 tx_idx;
+	struct eth_wqids tx[ENET_MAX_PBN];
+	u16 default_rx_qid;
+	u16 rx_count;
+	u16 rx_idx;
+	struct eth_wqids rx[ENET_MAX_PBN];
+	u16 default_rx_fp_qid;
+	u16 default_rx_fp_pbn;
+	struct eth_fqids rx_fp[ENET_MAX_PBN];
+	u16 default_rx_nxtfp_qid;
+	u16 default_rx_nxtfp_pbn;
+	struct eth_fqids rx_nxtfp[ENET_MAX_PBN];
+	struct eth_fqids hw_fp;
+	u16 default_hw_tx_qid;
+	struct eth_fqids hw_tx[ENET_MAX_PBN];
+	struct eth_wqids comp[ENET_MAX_PBN];
+	u16 default_comp_qid;
+	u32 qm_ip;
+};
+
+struct xgene_enet_platform_data {
+	u32 port_id;
+	const char *sname;
+	u32 phy_id;
+	u8 ethaddr[6];
+};
+
+/* APM ethernet per port data */
+struct xgene_enet_pdev {
+	struct net_device *ndev;
+	struct mii_bus *mdio_bus;
+	struct phy_device *phy_dev;
+	int phy_link;
+	int phy_speed;
+	struct clk *clk;
+	struct device_node *node;
+	struct platform_device *plat_dev;
+	struct xgene_qmtm_sdev *sdev;
+	struct xgene_enet_qcontext *tx[MAX_TX_QUEUES];
+	struct xgene_enet_qcontext *rx_skb_pool[MAX_RX_QUEUES];
+	u32 num_tx_queues;
+	struct xgene_enet_qcontext *rx[MAX_RX_QUEUES];
+	struct xgene_enet_qcontext *tx_completion[MAX_TX_QUEUES];
+	u32 num_rx_queues;
+	struct net_device_stats nstats;
+	struct xgene_enet_detailed_stats stats;
+	char *dev_name;
+	int uc_count;
+	struct eth_queue_ids qm_queues;
+	u32 rx_buff_cnt, tx_cqt_low, tx_cqt_hi;
+	int mss;
+	struct xgene_enet_priv priv;
+};
+
+/* Ethernet raw register write, read routines */
+void xgene_enet_wr32(void *addr, u32 data);
+void xgene_enet_rd32(void *addr, u32 *data);
+
+u32 xgene_enet_get_port(struct xgene_enet_pdev *pdev);
+
+void xgene_enet_init_priv(struct xgene_enet_priv *priv);
+
+int xgene_enet_parse_error(u8 LErr, int qid);
+void xgene_enet_register_err_irqs(struct net_device *ndev);
+
+#endif /* __XGENE_ENET_MAIN_H__ */
-- 
1.7.9.5
