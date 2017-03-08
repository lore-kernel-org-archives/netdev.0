From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v4 net-next 1/6] drivers: net: xgene-v2: Add DMA descriptor
Date: Tue,  7 Mar 2017 17:08:40 -0800
Message-ID: <1488935325-13603-2-git-send-email-isubramanian@apm.com>
References: <1488935325-13603-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kchudgar@apm.com, patches@apm.com, linux-arm-kernel@lists.infradead.org,
 Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org, andrew@lunn.ch,
 f.fainelli@gmail.com, David.Laight@aculab.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1488935325-13603-1-git-send-email-isubramanian@apm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch adds DMA descriptor setup and interrupt enable/disable
functions.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 drivers/net/ethernet/apm/xgene-v2/main.h |  74 +++++++++++++++++++
 drivers/net/ethernet/apm/xgene-v2/ring.c |  81 +++++++++++++++++++++
 drivers/net/ethernet/apm/xgene-v2/ring.h | 119 +++++++++++++++++++++++++++++++
 3 files changed, 274 insertions(+)
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/main.h
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/ring.c
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/ring.h

diff --git a/drivers/net/ethernet/apm/xgene-v2/main.h b/drivers/net/ethernet/apm/xgene-v2/main.h
new file mode 100644
index 0000000..a2f8712
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene-v2/main.h
@@ -0,0 +1,74 @@
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
index 0000000..3881082
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene-v2/ring.c
@@ -0,0 +1,81 @@
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
+					   SET_BITS(PKT_SIZE, SLOT_EMPTY));
+		dma_h = upper_32_bits(next_dma);
+		raw_desc->m1 = cpu_to_le64(SET_BITS(NEXT_DESC_ADDRL, next_dma) |
+					   SET_BITS(NEXT_DESC_ADDRH, dma_h));
+	}
+}
+
+void xge_update_tx_desc_addr(struct xge_pdata *pdata)
+{
+	struct xge_desc_ring *ring = pdata->tx_ring;
+	dma_addr_t dma_addr = ring->dma_addr;
+
+	xge_wr_csr(pdata, DMATXDESCL, dma_addr);
+	xge_wr_csr(pdata, DMATXDESCH, upper_32_bits(dma_addr));
+
+	ring->head = 0;
+	ring->tail = 0;
+}
+
+void xge_update_rx_desc_addr(struct xge_pdata *pdata)
+{
+	struct xge_desc_ring *ring = pdata->rx_ring;
+	dma_addr_t dma_addr = ring->dma_addr;
+
+	xge_wr_csr(pdata, DMARXDESCL, dma_addr);
+	xge_wr_csr(pdata, DMARXDESCH, upper_32_bits(dma_addr));
+
+	ring->head = 0;
+	ring->tail = 0;
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
index 0000000..abc8c9a
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene-v2/ring.h
@@ -0,0 +1,119 @@
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
+#define XGENE_ENET_DESC_SIZE	64
+#define XGENE_ENET_NUM_DESC	256
+#define NUM_BUFS		8
+#define SLOT_EMPTY		0xfff
+
+#define DMATXCTRL		0xa180
+#define DMATXDESCL		0xa184
+#define DMATXDESCH		0xa1a0
+#define DMATXSTATUS		0xa188
+#define DMARXCTRL		0xa18c
+#define DMARXDESCL		0xa190
+#define DMARXDESCH		0xa1a4
+#define DMARXSTATUS		0xa194
+#define DMAINTRMASK		0xa198
+#define DMAINTERRUPT		0xa19c
+
+#define D_POS			62
+#define D_LEN			2
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
+#define TXPKTCOUNT_POS		16
+#define TXPKTCOUNT_LEN		8
+#define RXPKTCOUNT_POS		16
+#define RXPKTCOUNT_LEN		8
+
+#define TX_PKT_SENT		BIT(0)
+#define TX_BUS_ERROR		BIT(3)
+#define RX_PKT_RCVD		BIT(4)
+#define RX_BUS_ERROR		BIT(7)
+#define RXSTATUS_RXPKTRCVD	BIT(0)
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
+struct pkt_info {
+	struct sk_buff *skb;
+	dma_addr_t dma_addr;
+	void *pkt_buf;
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
+	struct pkt_info (*pkt_info);
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
