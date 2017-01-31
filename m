From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 1/6] drivers: net: xgene-v2: Add DMA descriptor
Date: Tue, 31 Jan 2017 11:03:16 -0800
Message-ID: <1485889401-13909-2-git-send-email-isubramanian@apm.com>
References: <1485889401-13909-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33160 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751517AbdAaTFS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 14:05:18 -0500
Received: by mail-pf0-f180.google.com with SMTP id y143so109951241pfb.0
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 11:03:23 -0800 (PST)
In-Reply-To: <1485889401-13909-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds DMA descriptor setup and interrupt enable/disable
functions.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 drivers/net/ethernet/apm/xgene-v2/main.h | 88 ++++++++++++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene-v2/ring.c | 73 ++++++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene-v2/ring.h | 77 ++++++++++++++++++++++++++++
 3 files changed, 238 insertions(+)
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/main.h
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/ring.c
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/ring.h

diff --git a/drivers/net/ethernet/apm/xgene-v2/main.h b/drivers/net/ethernet/apm/xgene-v2/main.h
new file mode 100644
index 0000000..c8a40af
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene-v2/main.h
@@ -0,0 +1,88 @@
+/*
+ * Applied Micro X-Gene SoC Ethernet v2 Driver
+ *
+ * Copyright (c) 2017, Applied Micro Circuits Corporation
+ * Author(s): Iyappan Subramanian <isubramanian@apm.com>
+ *	      Keyur Chudgar <kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef __XGENE_ENET_V2_MAIN_H__
+#define __XGENE_ENET_V2_MAIN_H__
+
+#include <linux/acpi.h>
+#include <linux/clk.h>
+#include <linux/efi.h>
+#include <linux/if_vlan.h>
+#include <linux/irq.h>
+#include <linux/io.h>
+#include <linux/module.h>
+#include <linux/of_platform.h>
+#include <linux/of_net.h>
+#include <linux/of_mdio.h>
+#include <linux/prefetch.h>
+#include <linux/phy.h>
+#include <net/ip.h>
+#include "mac.h"
+#include "enet.h"
+#include "ring.h"
+
+#define XGENE_ENET_V2_VERSION	"v1.0"
+#define XGENE_ENET_STD_MTU	1536
+#define XGENE_ENET_MIN_FRAME	60
+#define IRQ_ID_SIZE             16
+
+struct xge_resource {
+	void __iomem *base_addr;
+	int phy_mode;
+	u32 irq;
+};
+
+struct xge_stats {
+	u64 tx_packets;
+	u64 tx_bytes;
+	u64 rx_packets;
+	u64 rx_bytes;
+};
+
+/* software context of a descriptor ring */
+struct xge_desc_ring {
+	struct net_device *ndev;
+	dma_addr_t dma_addr;
+	u8 head;
+	u8 tail;
+	union {
+		void *desc_addr;
+		struct xge_raw_desc *raw_desc;
+	};
+	struct sk_buff *(*skbs);
+	void *(*pkt_bufs);
+};
+
+/* ethernet private data */
+struct xge_pdata {
+	struct xge_resource resources;
+	struct xge_desc_ring *tx_ring;
+	struct xge_desc_ring *rx_ring;
+	struct platform_device *pdev;
+	char irq_name[IRQ_ID_SIZE];
+	struct net_device *ndev;
+	struct napi_struct napi;
+	struct xge_stats stats;
+	int phy_speed;
+	u8 nbufs;
+};
+
+#endif /* __XGENE_ENET_V2_MAIN_H__ */
diff --git a/drivers/net/ethernet/apm/xgene-v2/ring.c b/drivers/net/ethernet/apm/xgene-v2/ring.c
new file mode 100644
index 0000000..3289bf3
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene-v2/ring.c
@@ -0,0 +1,73 @@
+/*
+ * Applied Micro X-Gene SoC Ethernet v2 Driver
+ *
+ * Copyright (c) 2017, Applied Micro Circuits Corporation
+ * Author(s): Iyappan Subramanian <isubramanian@apm.com>
+ *	      Keyur Chudgar <kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include "main.h"
+
+/* create circular linked list of descriptors */
+void xge_setup_desc(struct xge_desc_ring *ring)
+{
+	struct xge_raw_desc *raw_desc;
+	dma_addr_t dma_h, next_dma;
+	u16 offset;
+	int i;
+
+	for (i = 0; i < XGENE_ENET_NUM_DESC; i++) {
+		raw_desc = &ring->raw_desc[i];
+
+		offset = (i + 1) & (XGENE_ENET_NUM_DESC - 1);
+		next_dma = ring->dma_addr + (offset * XGENE_ENET_DESC_SIZE);
+
+		raw_desc->m0 = cpu_to_le64(SET_BITS(E, 1) |
+					   SET_BITS(PKT_SIZE, 0));
+		dma_h = next_dma >> NEXT_DESC_ADDRL_LEN;
+		raw_desc->m1 = cpu_to_le64(SET_BITS(NEXT_DESC_ADDRL, next_dma) |
+					   SET_BITS(NEXT_DESC_ADDRL, dma_h));
+	}
+}
+
+void xge_update_tx_desc_addr(struct xge_pdata *pdata)
+{
+	dma_addr_t dma_addr = pdata->tx_ring->dma_addr;
+
+	xge_wr_csr(pdata, DMATXDESCL, dma_addr);
+	xge_wr_csr(pdata, DMATXDESCH, (dma_addr >> NEXT_DESC_ADDRL_LEN));
+}
+
+void xge_update_rx_desc_addr(struct xge_pdata *pdata)
+{
+	dma_addr_t dma_addr = pdata->rx_ring->dma_addr;
+
+	xge_wr_csr(pdata, DMARXDESCL, dma_addr);
+	xge_wr_csr(pdata, DMARXDESCH, (dma_addr >> NEXT_DESC_ADDRL_LEN));
+}
+
+void xge_intr_enable(struct xge_pdata *pdata)
+{
+	u32 data;
+
+	data = RX_PKT_RCVD | TX_PKT_SENT;
+	xge_wr_csr(pdata, DMAINTRMASK, data);
+}
+
+void xge_intr_disable(struct xge_pdata *pdata)
+{
+	xge_wr_csr(pdata, DMAINTRMASK, 0);
+}
diff --git a/drivers/net/ethernet/apm/xgene-v2/ring.h b/drivers/net/ethernet/apm/xgene-v2/ring.h
new file mode 100644
index 0000000..f2711f4
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene-v2/ring.h
@@ -0,0 +1,77 @@
+/*
+ * Applied Micro X-Gene SoC Ethernet v2 Driver
+ *
+ * Copyright (c) 2017, Applied Micro Circuits Corporation
+ * Author(s): Iyappan Subramanian <isubramanian@apm.com>
+ *	      Keyur Chudgar <kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef __XGENE_ENET_V2_RING_H__
+#define __XGENE_ENET_V2_RING_H__
+
+struct xge_desc_ring;
+
+#define XGENE_ENET_DESC_SIZE	64
+#define XGENE_ENET_NUM_DESC	256
+#define NUM_BUFS		8
+
+#define E_POS			63
+#define E_LEN			1
+#define PKT_ADDRL_POS		0
+#define PKT_ADDRL_LEN		32
+#define PKT_ADDRH_POS		32
+#define PKT_ADDRH_LEN		10
+#define PKT_SIZE_POS		32
+#define PKT_SIZE_LEN		12
+#define NEXT_DESC_ADDRL_POS	0
+#define NEXT_DESC_ADDRL_LEN	32
+#define NEXT_DESC_ADDRH_POS	48
+#define NEXT_DESC_ADDRH_LEN	10
+
+struct xge_raw_desc {
+	__le64 m0;
+	__le64 m1;
+	__le64 m2;
+	__le64 m3;
+	__le64 m4;
+	__le64 m5;
+	__le64 m6;
+	__le64 m7;
+};
+
+static inline u64 xge_set_desc_bits(int pos, int len, u64 val)
+{
+	return (val & ((1ULL << len) - 1)) << pos;
+}
+
+static inline u64 xge_get_desc_bits(int pos, int len, u64 src)
+{
+	return (src >> pos) & ((1ULL << len) - 1);
+}
+
+#define SET_BITS(field, val) \
+		xge_set_desc_bits(field ## _POS, field ## _LEN, val)
+
+#define GET_BITS(field, src) \
+		xge_get_desc_bits(field ## _POS, field ## _LEN, src)
+
+void xge_setup_desc(struct xge_desc_ring *ring);
+void xge_update_tx_desc_addr(struct xge_pdata *pdata);
+void xge_update_rx_desc_addr(struct xge_pdata *pdata);
+void xge_intr_enable(struct xge_pdata *pdata);
+void xge_intr_disable(struct xge_pdata *pdata);
+
+#endif  /* __XGENE_ENET_V2_RING_H__ */
-- 
1.9.1
