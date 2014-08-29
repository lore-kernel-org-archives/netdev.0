From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH 1/5] net: mvberlin_eth: add an Ethernet driver for Marvell
 Berlin
Date: Fri, 29 Aug 2014 15:50:59 +0200
Message-ID: <1409320263-10295-2-git-send-email-antoine.tenart@free-electrons.com>
References: <1409320263-10295-1-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: zmxu@marvell.com, jszhang@marvell.com, devicetree@vger.kernel.org,
 netdev@vger.kernel.org, Antoine Tenart <antoine.tenart@free-electrons.com>,
 linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
 linux-arm-kernel@lists.infradead.org
To: sebastian.hesselbarth@gmail.com,
	thomas.petazzoni@free-electrons.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1409320263-10295-1-git-send-email-antoine.tenart@free-electrons.com>
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

This patch introduces the Marvell Berlin network unit driver, which uses
the MVMDIO interface to communicate to the PHY. This is a fast Ethernet
driver.

This driver is highly based on the mv643xx_eth driver, and reuse some of
its functions. But lots of differences are there:
- They do not have the same registers.
- The mvberlin_eth driver only supports fast Ethernet.
- The rx/tx handling functions logic is different.
- The mv643xx_eth driver supports TSO.
- The mvberlin_eth driver uses a hash table to filter incoming packets.

No packet is dropped during a ping flood (ping -f) and an iperf test
shows:
------------------------------------------------------------
Client connecting to 192.168.0.11, TCP port 5001
TCP window size: 85.0 KByte (default)
------------------------------------------------------------
[  3] local 192.168.0.20 port 44183 connected with 192.168.0.11 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec   113 MBytes  94.8 Mbits/sec

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/Kconfig        |    9 +
 drivers/net/ethernet/marvell/Makefile       |    1 +
 drivers/net/ethernet/marvell/mvberlin_eth.c | 2081 +++++++++++++++++++++++++++
 3 files changed, 2091 insertions(+)
 create mode 100644 drivers/net/ethernet/marvell/mvberlin_eth.c

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index 1b4fc7c639e6..a4f12257d099 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -18,6 +18,15 @@ config NET_VENDOR_MARVELL
 
 if NET_VENDOR_MARVELL
 
+config MVBERLIN_ETH
+	tristate "Marvell Berlin ethernet support"
+	depends on ARCH_BERLIN && INET
+	select PHYLIB
+	select MVMDIO
+	---help---
+	  This driver supports the ethernet interface of the Marvell
+	  Berlin SoCs.
+
 config MV643XX_ETH
 	tristate "Marvell Discovery (643XX) and Orion ethernet support"
 	depends on (MV64X60 || PPC32 || PLAT_ORION) && INET
diff --git a/drivers/net/ethernet/marvell/Makefile b/drivers/net/ethernet/marvell/Makefile
index f6425bd2884b..a802dba2503e 100644
--- a/drivers/net/ethernet/marvell/Makefile
+++ b/drivers/net/ethernet/marvell/Makefile
@@ -2,6 +2,7 @@
 # Makefile for the Marvell device drivers.
 #
 
+obj-$(CONFIG_MVBERLIN_ETH) += mvberlin_eth.o
 obj-$(CONFIG_MVMDIO) += mvmdio.o
 obj-$(CONFIG_MV643XX_ETH) += mv643xx_eth.o
 obj-$(CONFIG_MVNETA) += mvneta.o
diff --git a/drivers/net/ethernet/marvell/mvberlin_eth.c b/drivers/net/ethernet/marvell/mvberlin_eth.c
new file mode 100644
index 000000000000..5f1874b58017
--- /dev/null
+++ b/drivers/net/ethernet/marvell/mvberlin_eth.c
@@ -0,0 +1,2081 @@
+/*
+ * Copyright (C) 2014 Marvell Technology Group Ltd.
+ *
+ * Antoine Tenart <antoine.tenart@free-electrons.com>
+ * Jisheng Zhang <jszhang@marvell.com>
+ *
+ * Based on the driver for Marvell Discovery (MV643XX) and Marvell Orion
+ * ethernet ports
+ * Copyright (C) 2002 Matthew Dharm <mdharm@momenco.com>
+ *
+ * Based on the 64360 driver from:
+ * Copyright (C) 2002 Rabeeh Khoury <rabeeh@galileo.co.il>
+ *		      Rabeeh Khoury <rabeeh@marvell.com>
+ *
+ * Copyright (C) 2003 PMC-Sierra, Inc.,
+ *	written by Manish Lachwani
+ *
+ * Copyright (C) 2003 Ralf Baechle <ralf@linux-mips.org>
+ *
+ * Copyright (C) 2004-2006 MontaVista Software, Inc.
+ *			   Dale Farnsworth <dale@farnsworth.org>
+ *
+ * Copyright (C) 2004 Steven J. Hill <sjhill1@rockwellcollins.com>
+ *				     <sjhill@realitydiluted.com>
+ *
+ * Copyright (C) 2007-2008 Marvell Semiconductor
+ *			   Lennert Buytenhek <buytenh@marvell.com>
+ *
+ * Copyright (C) 2013 Michael Stapelberg <michael@stapelberg.de>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include <linux/clk.h>
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/in.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
+#include <linux/ip.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mv643xx_eth.h>
+#include <linux/of.h>
+#include <linux/of_irq.h>
+#include <linux/of_net.h>
+#include <linux/of_mdio.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/tcp.h>
+#include <linux/types.h>
+#include <linux/udp.h>
+#include <linux/workqueue.h>
+
+static const char mvberlin_eth_driver_name[] = "mvberlin_eth";
+static const char mvberlin_eth_driver_version[] = "1.0";
+
+/* Main per-port registers. These live at offset 0x0400 */
+#define PORT_CONFIG			0x0000
+#define  PROMISCUOUS_MODE		0x00000001
+#define  BROADCAST_REJECT_MODE		0x00000002
+#define  PORT_ENABLE			0x00000080
+#define  HASH_SIZE_HALF_K		0x00001000
+#define  HASH_FUNCTION_1		0x00002000
+#define  HASH_PASS_MODE			0x00004000
+#define PORT_EXT_CONFIG			0x0008
+#define  EXT_IGMP			0x00000001
+#define  EXT_SPAN			0x00000002
+#define  EXT_FC_AN_DISABLE		0x00000400
+#define  EXT_FLP_DISABLE		0x00000800
+#define  EXT_FC_ENABLE			0x00000c00
+#define  EXT_MRU_ALL_MASK		0x0000c000
+#define  EXT_MIB_CLEAR			0x00010000
+#define  EXT_DSCP_EN			0x00200000
+#define  EXT_MAC_RX_2BSTUFF		0x10000000
+#define HASH_TABLE			0x0028
+#define MAC_ADDR_LOW			0x0030
+#define MAC_ADDR_HIGH			0x0038
+#define SDMA_CONFIG			0x0040
+#define  BURST_SIZE_8_64BIT		0x00003000
+#define  BLM_RX_LE			0x00000040
+#define  BLM_TX_LE			0x00000080
+#define  SET_MII_SPEED_TO_10		0x00000000
+#define  SET_MII_SPEED_TO_100		0x00000001
+#define  SET_FULL_DUPLEX_MODE		0x00000002
+#define  RX_FRAME_INTERRUPT		0x00000200
+#define PORT_STATUS			0x0018
+#define  TX_IN_PROGRESS			0x00000080
+#define  PORT_SPEED_MASK		0x00000001
+#define  PORT_SPEED_100			0x00000001
+#define  PORT_SPEED_10			0x00000000
+#define  FLOW_CONTROL_ENABLED		0x00000004
+#define  FULL_DUPLEX			0x00000002
+#define  LINK_UP			0x00000008
+#define INT_CAUSE			0x0050
+#define  INT_TX_0			0x00000004
+#define  INT_TX				0x0000000c
+#define  INT_TX_END			0x000000c0
+#define  INT_TX_END_0			0x00000040
+#define  INT_RX				0x000f0000
+#define  INT_RX_0			0x00010000
+#define  INT_EXT			0x10000000
+#define  INT_EXT_LINK_PHY		0x00000010
+#define  INT_EXT_TX			0x00000080
+#define INT_MASK			0x0058
+#define RXQ_CURRENT_DESC_PTR(q)		(0x00a0 + ((q) << 2))
+#define RXQ_FIRST_DESC_PTR(q)		(0x0080 + ((q) << 2))
+#define SDMA_COMMAND			0x0048
+#define  RX_ENABLE			0x00000080
+#define  RX_ABORT			0x00008000
+#define  TX_STOP			0x00010000
+#define  TX_START			0x00800000
+#define TXQ_CURRENT_DESC_PTR(q)		(0x00e0 + ((1-q) << 2))
+#define ETH_EDSCP2P0L			0x0060
+#define ETH_EDSCP2P0H			0x0064
+#define ETH_EDSCP2P1L			0x0068
+#define ETH_EDSCP2P1H			0x006c
+
+#define MRU_1518			0x00000000
+#define MRU_1536			0x00004000
+#define MRU_2048			0x00008000
+#define MRU_64K				0x0000c000
+
+#define HASH_TABLE_ENTRY_VALID		0x00000001
+#define HASH_TABLE_ENTRY_SKIP		0x00000002
+#define HASH_TABLE_SIZE			0x4000
+
+/* Hash function macroes */
+#define NIBBLE_SWAPPING_16_BIT(x)	\
+	(((x & 0xf) << 4)	|	\
+	 ((x & 0xf0) >> 4)	|	\
+	 ((x & 0xf00) << 4)	|	\
+	 ((x & 0xf000) >> 4))
+
+#define NIBBLE_SWAPPING_32_BIT(x)	\
+	(((x & 0xf) << 4)	|	\
+	 ((x & 0xf0) >> 4)	|	\
+	 ((x & 0xf00) << 4)	|	\
+	 ((x & 0xf000) >> 4)	|	\
+	 ((x & 0xf0000) << 4)	|	\
+	 ((x & 0xf00000) >> 4)	|	\
+	 ((x & 0xf000000) << 4)	|	\
+	 ((x & 0xf0000000) >> 4))
+
+#define GT_NIBBLE(x)			\
+	(((x & 0x1) << 3)	+	\
+	 ((x & 0x2) << 1)	+	\
+	 ((x & 0x4) >> 1)	+	\
+	 ((x & 0x8) >> 3))
+
+/* Misc per-port registers */
+#define MIB_COUNTERS(p)			(0x0500 + ((p) << 7))
+
+/* SDMA configuration register default value */
+#if defined(__BIG_ENDIAN)
+#define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
+		(BURST_SIZE_8_64BIT	|	\
+		 0x3c			|	\
+		 RX_FRAME_INTERRUPT)
+#elif defined(__LITTLE_ENDIAN)
+#define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
+		(BURST_SIZE_8_64BIT	|	\
+		 BLM_RX_LE		|	\
+		 BLM_TX_LE		|	\
+		 0x3c			|	\
+		 RX_FRAME_INTERRUPT)
+#else
+#error One of __BIG_ENDIAN or __LITTLE_ENDIAN must be defined
+#endif
+
+/* Misc definitions */
+#define DEFAULT_RX_QUEUE_SIZE	128
+#define DEFAULT_TX_QUEUE_SIZE	512
+#define SKB_DMA_REALIGN		((PAGE_SIZE - NET_SKB_PAD) % SMP_CACHE_BYTES)
+
+/* RX/TX descriptors */
+#if defined(__BIG_ENDIAN)
+struct rx_desc {
+	u16 buf_size;		/* Buffer size				*/
+	u16 byte_cnt;		/* Descriptor buffer byte count		*/
+	u32 cmd_sts;		/* Command/status field			*/
+	u32 next_desc_ptr;	/* Next descriptor pointer		*/
+	u32 buf_ptr;		/* Descriptor buffer pointer		*/
+};
+
+struct tx_desc {
+	u16 byte_cnt;		/* buffer byte count			*/
+	u16 l4i_chk;		/* CPU provided TCP checksum		*/
+	u32 cmd_sts;		/* Command/status field			*/
+	u32 next_desc_ptr;	/* Pointer to next descriptor		*/
+	u32 buf_ptr;		/* pointer to buffer for this descriptor*/
+};
+#elif defined(__LITTLE_ENDIAN)
+struct rx_desc {
+	u32 cmd_sts;		/* Descriptor command status		*/
+	u16 byte_cnt;		/* Descriptor buffer byte count		*/
+	u16 buf_size;		/* Buffer size				*/
+	u32 buf_ptr;		/* Descriptor buffer pointer		*/
+	u32 next_desc_ptr;	/* Next descriptor pointer		*/
+};
+
+struct tx_desc {
+	u32 cmd_sts;		/* Command/status field			*/
+	u16 l4i_chk;		/* CPU provided TCP checksum		*/
+	u16 byte_cnt;		/* buffer byte count			*/
+	u32 buf_ptr;		/* pointer to buffer for this descriptor*/
+	u32 next_desc_ptr;	/* Pointer to next descriptor		*/
+};
+#else
+#error One of __BIG_ENDIAN or __LITTLE_ENDIAN must be defined
+#endif
+
+/* RX & TX descriptor command */
+#define BUFFER_OWNED_BY_DMA		0x80000000
+
+/* RX & TX descriptor status */
+#define ERROR_SUMMARY			0x00008000
+
+/* RX descriptor status */
+#define RX_ENABLE_INTERRUPT		0x00800000
+#define RX_FIRST_DESC			0x00020000
+#define RX_LAST_DESC			0x00010000
+
+/* TX descriptor command */
+#define TX_ENABLE_INTERRUPT		0x00800000
+#define GEN_CRC				0x00400000
+#define TX_FIRST_DESC			0x00020000
+#define TX_LAST_DESC			0x00010000
+#define ZERO_PADDING			0x00040000
+
+/* global *******************************************************************/
+struct mvberlin_eth_shared_private {
+	/* Ethernet controller base address */
+	void __iomem *base;
+
+	/* Per-port MBUS window access register value */
+	u32 win_protect;
+
+	/* Hardware-specific parameters */
+	int extended_rx_coal_limit;
+	int tx_bw_control;
+	int tx_csum_limit;
+	struct clk *clk;
+};
+
+static int mvberlin_eth_open(struct net_device *dev);
+static int mvberlin_eth_stop(struct net_device *dev);
+
+/* per-port *****************************************************************/
+struct rx_queue {
+	int index;
+
+	int rx_ring_size;
+
+	int rx_desc_count;
+	int rx_curr_desc;
+	int rx_used_desc;
+
+	struct rx_desc *rx_desc_area;
+	dma_addr_t rx_desc_dma;
+	int rx_desc_area_size;
+	struct sk_buff **rx_skb;
+};
+
+struct tx_queue {
+	int index;
+
+	int tx_ring_size;
+
+	int tx_desc_count;
+	int tx_curr_desc;
+	int tx_used_desc;
+
+	int tx_stop_threshold;
+	int tx_wake_threshold;
+
+	struct tx_desc *tx_desc_area;
+	dma_addr_t tx_desc_dma;
+	int tx_desc_area_size;
+
+	struct sk_buff_head tx_skb;
+
+	unsigned long tx_packets;
+	unsigned long tx_bytes;
+	unsigned long tx_dropped;
+};
+
+struct mvberlin_eth_private {
+	struct mvberlin_eth_shared_private *shared;
+	void __iomem *base;
+	int port_num;
+
+	struct net_device *dev;
+
+	struct phy_device *phy;
+
+	struct work_struct tx_timeout_task;
+
+	struct napi_struct napi;
+	u32 int_mask;
+	u8 oom;
+	u8 work_rx_refill;
+
+	int skb_size;
+
+	/* RX state */
+	int rx_ring_size;
+	unsigned long rx_desc_sram_addr;
+	int rx_desc_sram_size;
+	int rxq_count;
+	struct timer_list rx_oom;
+	struct rx_queue rxq[8];
+
+	/* TX state */
+	int tx_ring_size;
+	unsigned long tx_desc_sram_addr;
+	int tx_desc_sram_size;
+	int txq_count;
+	struct tx_queue txq[8];
+
+	/* Hardware-specific parameters */
+	struct clk *clk;
+	unsigned int t_clk;
+	void *hash_tbl;
+	dma_addr_t hash_dma;
+};
+
+/* port register accessors **************************************************/
+static inline u32 rdl(struct mvberlin_eth_private *mp, int offset)
+{
+	return readl(mp->shared->base + offset);
+}
+
+static inline u32 rdlp(struct mvberlin_eth_private *mp, int offset)
+{
+	return readl(mp->base + offset);
+}
+
+static inline void wrl(struct mvberlin_eth_private *mp, int offset, u32 data)
+{
+	writel(data, mp->shared->base + offset);
+}
+
+static inline void wrlp(struct mvberlin_eth_private *mp, int offset, u32 data)
+{
+	writel(data, mp->base + offset);
+}
+
+/* rxq/txq helper functions *************************************************/
+static struct mvberlin_eth_private *rxq_to_mp(struct rx_queue *rxq)
+{
+	return container_of(rxq, struct mvberlin_eth_private, rxq[rxq->index]);
+}
+
+static struct mvberlin_eth_private *txq_to_mp(struct tx_queue *txq)
+{
+	return container_of(txq, struct mvberlin_eth_private, txq[txq->index]);
+}
+
+static void rxq_enable(struct rx_queue *rxq)
+{
+	struct mvberlin_eth_private *mp = rxq_to_mp(rxq);
+
+	wrlp(mp, SDMA_COMMAND, RX_ENABLE);
+}
+
+static void rxq_disable(struct rx_queue *rxq)
+{
+	struct mvberlin_eth_private *mp = rxq_to_mp(rxq);
+
+	wrlp(mp, SDMA_COMMAND, RX_ABORT);
+	while (rdlp(mp, SDMA_COMMAND) & RX_ABORT)
+		udelay(10);
+}
+
+static void txq_reset_hw_ptr(struct tx_queue *txq)
+{
+	struct mvberlin_eth_private *mp = txq_to_mp(txq);
+	u32 addr;
+
+	addr = (u32)txq->tx_desc_dma;
+	addr += txq->tx_curr_desc * sizeof(struct tx_desc);
+	wrlp(mp, TXQ_CURRENT_DESC_PTR(txq->index), addr);
+}
+
+static void txq_enable(struct tx_queue *txq)
+{
+	struct mvberlin_eth_private *mp = txq_to_mp(txq);
+
+	wrlp(mp, SDMA_COMMAND, TX_START);
+}
+
+static void txq_disable(struct tx_queue *txq)
+{
+	struct mvberlin_eth_private *mp = txq_to_mp(txq);
+
+	wrlp(mp, SDMA_COMMAND, TX_STOP);
+}
+
+static void txq_maybe_wake(struct tx_queue *txq)
+{
+	struct mvberlin_eth_private *mp = txq_to_mp(txq);
+	struct netdev_queue *nq = netdev_get_tx_queue(mp->dev, txq->index);
+
+	if (netif_tx_queue_stopped(nq)) {
+		__netif_tx_lock(nq, smp_processor_id());
+		if (txq->tx_desc_count <= txq->tx_wake_threshold)
+			netif_tx_wake_queue(nq);
+		__netif_tx_unlock(nq);
+	}
+}
+
+static int rxq_process(struct rx_queue *rxq, int budget)
+{
+	struct mvberlin_eth_private *mp = rxq_to_mp(rxq);
+	struct net_device_stats *stats = &mp->dev->stats;
+	int rx;
+
+	rx = 0;
+	while (rx < budget && rxq->rx_desc_count) {
+		struct rx_desc *rx_desc;
+		unsigned int cmd_sts;
+		struct sk_buff *skb;
+		u16 byte_cnt;
+
+		rx_desc = &rxq->rx_desc_area[rxq->rx_curr_desc];
+
+		cmd_sts = rx_desc->cmd_sts;
+		if (cmd_sts & BUFFER_OWNED_BY_DMA)
+			break;
+		rmb();
+
+		skb = rxq->rx_skb[rxq->rx_curr_desc];
+		rxq->rx_skb[rxq->rx_curr_desc] = NULL;
+
+		rxq->rx_curr_desc++;
+		if (rxq->rx_curr_desc == rxq->rx_ring_size)
+			rxq->rx_curr_desc = 0;
+
+		dma_unmap_single(mp->dev->dev.parent, rx_desc->buf_ptr,
+				 rx_desc->buf_size, DMA_FROM_DEVICE);
+		rxq->rx_desc_count--;
+		rx++;
+
+		mp->work_rx_refill |= 1 << rxq->index;
+
+		byte_cnt = rx_desc->byte_cnt;
+
+		/* Update statistics.
+		 *
+		 * Note that the descriptor byte count includes 2 dummy
+		 * bytes automatically inserted by the hardware at the
+		 * start of the packet (which we don't count), and a 4
+		 * byte CRC at the end of the packet (which we do count).
+		 */
+		stats->rx_packets++;
+		stats->rx_bytes += byte_cnt - 2;
+
+		/* In case we received a packet without first / last bits
+		 * on, or the error summary bit is set, the packet needs
+		 * to be dropped.
+		 */
+		if ((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC | ERROR_SUMMARY))
+			!= (RX_FIRST_DESC | RX_LAST_DESC))
+			goto err;
+
+		/* The -4 is for the CRC in the trailer of the
+		 * received packet
+		 */
+		skb_put(skb, byte_cnt - 2 - 4);
+
+		skb->protocol = eth_type_trans(skb, mp->dev);
+
+		napi_gro_receive(&mp->napi, skb);
+
+		continue;
+
+err:
+		stats->rx_dropped++;
+
+		if ((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
+			(RX_FIRST_DESC | RX_LAST_DESC)) {
+			if (net_ratelimit())
+				netdev_err(mp->dev,
+					   "received packet spanning multiple descriptors\n");
+		}
+
+		if (cmd_sts & ERROR_SUMMARY)
+			stats->rx_errors++;
+
+		dev_kfree_skb(skb);
+	}
+
+	return rx;
+}
+
+static int rxq_refill(struct rx_queue *rxq, int budget)
+{
+	struct mvberlin_eth_private *mp = rxq_to_mp(rxq);
+	int refilled;
+
+	refilled = 0;
+	while (refilled < budget && rxq->rx_desc_count < rxq->rx_ring_size) {
+		struct sk_buff *skb;
+		int rx;
+		struct rx_desc *rx_desc;
+		int size;
+
+		skb = netdev_alloc_skb(mp->dev, mp->skb_size);
+
+		if (skb == NULL) {
+			mp->oom = 1;
+			goto oom;
+		}
+
+		if (SKB_DMA_REALIGN)
+			skb_reserve(skb, SKB_DMA_REALIGN);
+
+		refilled++;
+		rxq->rx_desc_count++;
+
+		rx = rxq->rx_used_desc++;
+		if (rxq->rx_used_desc == rxq->rx_ring_size)
+			rxq->rx_used_desc = 0;
+
+		rx_desc = rxq->rx_desc_area + rx;
+
+		size = skb_end_pointer(skb) - skb->data;
+		rx_desc->buf_ptr = dma_map_single(mp->dev->dev.parent,
+						  skb->data, size,
+						  DMA_FROM_DEVICE);
+		rx_desc->buf_size = size;
+		rxq->rx_skb[rx] = skb;
+		wmb();
+		rx_desc->cmd_sts = BUFFER_OWNED_BY_DMA | RX_ENABLE_INTERRUPT;
+		wmb();
+
+		/* The hardware automatically prepends 2 bytes of
+		 * dummy data to each received packet, so that the
+		 * IP header ends up 16-byte aligned.
+		 */
+		skb_reserve(skb, 2);
+	}
+
+	if (refilled < budget)
+		mp->work_rx_refill &= ~(1 << rxq->index);
+
+oom:
+	return refilled;
+}
+
+/* tx ***********************************************************************/
+static inline unsigned int has_tiny_unaligned_frags(struct sk_buff *skb)
+{
+	int frag;
+
+	for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
+		const skb_frag_t *fragp = &skb_shinfo(skb)->frags[frag];
+
+		if (skb_frag_size(fragp) <= 8 && fragp->page_offset & 7)
+			return 1;
+	}
+
+	return 0;
+}
+
+static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
+{
+	struct mvberlin_eth_private *mp = txq_to_mp(txq);
+	int nr_frags = skb_shinfo(skb)->nr_frags;
+	int frag;
+
+	for (frag = 0; frag < nr_frags; frag++) {
+		skb_frag_t *this_frag;
+		int tx_index;
+		struct tx_desc *desc;
+		void *addr;
+
+		this_frag = &skb_shinfo(skb)->frags[frag];
+		addr = page_address(this_frag->page.p) + this_frag->page_offset;
+		tx_index = txq->tx_curr_desc++;
+		if (txq->tx_curr_desc == txq->tx_ring_size)
+			txq->tx_curr_desc = 0;
+		desc = &txq->tx_desc_area[tx_index];
+
+		/* The last fragment will generate an interrupt
+		 * which will free the skb on TX completion.
+		 */
+		if (frag == nr_frags - 1) {
+			desc->cmd_sts = BUFFER_OWNED_BY_DMA |
+					ZERO_PADDING | TX_LAST_DESC |
+					TX_ENABLE_INTERRUPT;
+		} else {
+			desc->cmd_sts = BUFFER_OWNED_BY_DMA;
+		}
+
+		desc->l4i_chk = 0;
+		desc->byte_cnt = skb_frag_size(this_frag);
+		desc->buf_ptr = dma_map_single(mp->dev->dev.parent, addr,
+					       desc->byte_cnt, DMA_TO_DEVICE);
+	}
+}
+
+static int txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb,
+			  struct net_device *dev)
+{
+	struct mvberlin_eth_private *mp = txq_to_mp(txq);
+	int nr_frags = skb_shinfo(skb)->nr_frags;
+	int tx_index;
+	struct tx_desc *desc;
+	u32 cmd_sts;
+	u16 l4i_chk;
+	int length;
+
+	cmd_sts = 0;
+	l4i_chk = 0;
+
+	if (txq->tx_ring_size - txq->tx_desc_count < MAX_SKB_FRAGS + 1) {
+		if (net_ratelimit())
+			netdev_err(dev, "tx queue full?!\n");
+		return -EBUSY;
+	}
+
+	cmd_sts |= TX_FIRST_DESC | GEN_CRC | BUFFER_OWNED_BY_DMA;
+
+	tx_index = txq->tx_curr_desc++;
+	if (txq->tx_curr_desc == txq->tx_ring_size)
+		txq->tx_curr_desc = 0;
+	desc = &txq->tx_desc_area[tx_index];
+
+	if (nr_frags) {
+		txq_submit_frag_skb(txq, skb);
+		length = skb_headlen(skb);
+	} else {
+		cmd_sts |= ZERO_PADDING | TX_LAST_DESC | TX_ENABLE_INTERRUPT;
+		length = skb->len;
+	}
+
+	desc->l4i_chk = l4i_chk;
+	desc->byte_cnt = length;
+	desc->buf_ptr = dma_map_single(mp->dev->dev.parent, skb->data,
+				       length, DMA_TO_DEVICE);
+
+	__skb_queue_tail(&txq->tx_skb, skb);
+
+	skb_tx_timestamp(skb);
+
+	/* ensure all other descriptors are written before first cmd_sts */
+	wmb();
+	desc->cmd_sts = cmd_sts;
+
+	/* ensure all descriptors are written before poking hardware */
+	wmb();
+	txq_enable(txq);
+
+	txq->tx_desc_count += nr_frags + 1;
+
+	return 0;
+}
+
+static netdev_tx_t mvberlin_eth_xmit(struct sk_buff *skb,
+				     struct net_device *dev)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+	int length, queue;
+	struct tx_queue *txq;
+	struct netdev_queue *nq;
+
+	queue = skb_get_queue_mapping(skb);
+	txq = mp->txq + queue;
+	nq = netdev_get_tx_queue(dev, queue);
+
+	if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
+		netdev_printk(KERN_DEBUG, dev,
+			      "failed to linearize skb with tiny unaligned fragment\n");
+		return NETDEV_TX_BUSY;
+	}
+
+	length = skb->len;
+
+	if (!txq_submit_skb(txq, skb, dev)) {
+		txq->tx_bytes += length;
+		txq->tx_packets++;
+
+		if (txq->tx_desc_count >= txq->tx_stop_threshold)
+			netif_tx_stop_queue(nq);
+	} else {
+		txq->tx_dropped++;
+		dev_kfree_skb_any(skb);
+	}
+
+	return NETDEV_TX_OK;
+}
+
+/* tx napi ******************************************************************/
+static void txq_kick(struct tx_queue *txq)
+{
+	struct mvberlin_eth_private *mp = txq_to_mp(txq);
+	struct netdev_queue *nq = netdev_get_tx_queue(mp->dev, txq->index);
+	u32 hw_desc_ptr;
+	u32 expected_ptr;
+
+	__netif_tx_lock(nq, smp_processor_id());
+
+	if (rdlp(mp, SDMA_COMMAND) & TX_START)
+		goto out;
+
+	hw_desc_ptr = rdlp(mp, TXQ_CURRENT_DESC_PTR(txq->index));
+	expected_ptr = (u32)txq->tx_desc_dma +
+		       txq->tx_curr_desc * sizeof(struct tx_desc);
+
+	if (hw_desc_ptr != expected_ptr)
+		txq_enable(txq);
+
+out:
+	__netif_tx_unlock(nq);
+}
+
+static int txq_reclaim(struct tx_queue *txq, int budget, int force)
+{
+	struct mvberlin_eth_private *mp = txq_to_mp(txq);
+	int reclaimed;
+
+	reclaimed = 0;
+	while (reclaimed < budget && txq->tx_desc_count > 0) {
+		int tx_index;
+		struct tx_desc *desc;
+		u32 cmd_sts;
+		struct sk_buff *skb;
+
+		tx_index = txq->tx_used_desc;
+		desc = &txq->tx_desc_area[tx_index];
+		cmd_sts = desc->cmd_sts;
+
+		if (cmd_sts & BUFFER_OWNED_BY_DMA) {
+			if (!force)
+				break;
+			desc->cmd_sts = cmd_sts & ~BUFFER_OWNED_BY_DMA;
+		}
+
+		txq->tx_used_desc = tx_index + 1;
+		if (txq->tx_used_desc == txq->tx_ring_size)
+			txq->tx_used_desc = 0;
+
+		reclaimed++;
+		txq->tx_desc_count--;
+
+		skb = NULL;
+		if (cmd_sts & TX_LAST_DESC)
+			skb = __skb_dequeue(&txq->tx_skb);
+
+		if (cmd_sts & ERROR_SUMMARY) {
+			netdev_info(mp->dev, "tx error\n");
+			mp->dev->stats.tx_errors++;
+		}
+
+		dev_kfree_skb_irq(skb);
+	}
+
+	return reclaimed;
+}
+
+/* mii management interface *************************************************/
+static void mvberlin_eth_adjust_link(struct net_device *dev)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+	u32 pscr = rdlp(mp, PORT_CONFIG);
+	u32 autoneg_disable = HASH_PASS_MODE;
+
+	if (mp->phy->autoneg == AUTONEG_ENABLE) {
+		/* enable auto negotiation */
+		pscr &= ~autoneg_disable;
+		goto out_write;
+	}
+
+	pscr |= autoneg_disable;
+
+	if (mp->phy->speed == SPEED_100)
+		pscr |= SET_MII_SPEED_TO_100;
+	else
+		pscr &= ~SET_MII_SPEED_TO_100;
+
+	if (mp->phy->duplex == DUPLEX_FULL)
+		pscr |= SET_FULL_DUPLEX_MODE;
+	else
+		pscr &= ~SET_FULL_DUPLEX_MODE;
+
+out_write:
+	wrlp(mp, PORT_CONFIG, pscr);
+}
+
+/* statistics ***************************************************************/
+static struct net_device_stats *mvberlin_eth_get_stats(struct net_device *dev)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	unsigned long tx_packets = 0;
+	unsigned long tx_bytes = 0;
+	unsigned long tx_dropped = 0;
+	int i;
+
+	for (i = 0; i < mp->txq_count; i++) {
+		struct tx_queue *txq = mp->txq + i;
+
+		tx_packets += txq->tx_packets;
+		tx_bytes += txq->tx_bytes;
+		tx_dropped += txq->tx_dropped;
+	}
+
+	stats->tx_packets = tx_packets;
+	stats->tx_bytes = tx_bytes;
+	stats->tx_dropped = tx_dropped;
+
+	return stats;
+}
+
+static inline u32 mib_read(struct mvberlin_eth_private *mp, int offset)
+{
+	return rdl(mp, MIB_COUNTERS(mp->port_num) + offset);
+}
+
+/* ethtool ******************************************************************/
+struct mvberlin_eth_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int netdev_off;
+	int mp_off;
+};
+
+#define SSTAT(m)						\
+	{ #m, FIELD_SIZEOF(struct net_device_stats, m),		\
+	  offsetof(struct net_device, stats.m), -1 }
+
+static const struct mvberlin_eth_stats mvberlin_eth_stats[] = {
+	SSTAT(rx_packets),
+	SSTAT(tx_packets),
+	SSTAT(rx_bytes),
+	SSTAT(tx_bytes),
+	SSTAT(rx_errors),
+	SSTAT(tx_errors),
+	SSTAT(rx_dropped),
+	SSTAT(tx_dropped),
+};
+
+static int
+mvberlin_eth_get_settings_phy(struct mvberlin_eth_private *mp,
+			      struct ethtool_cmd *cmd)
+{
+	int err;
+
+	err = phy_read_status(mp->phy);
+	if (err == 0)
+		err = phy_ethtool_gset(mp->phy, cmd);
+
+	return err;
+}
+
+static int
+mvberlin_eth_get_settings_phyless(struct mvberlin_eth_private *mp,
+				  struct ethtool_cmd *cmd)
+{
+	u32 port_status;
+
+	port_status = rdlp(mp, PORT_STATUS);
+
+	cmd->supported = SUPPORTED_MII;
+	cmd->advertising = ADVERTISED_MII;
+
+	switch (port_status & PORT_SPEED_MASK) {
+	case PORT_SPEED_10:
+		ethtool_cmd_speed_set(cmd, SPEED_10);
+		break;
+	case PORT_SPEED_100:
+		ethtool_cmd_speed_set(cmd, SPEED_100);
+		break;
+	default:
+		cmd->speed = -1;
+		break;
+	}
+
+	cmd->duplex = (port_status & FULL_DUPLEX) ? DUPLEX_FULL : DUPLEX_HALF;
+	cmd->port = PORT_MII;
+	cmd->phy_address = 0;
+	cmd->transceiver = XCVR_INTERNAL;
+	cmd->autoneg = AUTONEG_DISABLE;
+	cmd->maxtxpkt = 1;
+	cmd->maxrxpkt = 1;
+
+	return 0;
+}
+
+static void
+mvberlin_eth_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+
+	wol->supported = 0;
+	wol->wolopts = 0;
+	if (mp->phy)
+		phy_ethtool_get_wol(mp->phy, wol);
+}
+
+static int
+mvberlin_eth_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+	int err;
+
+	if (mp->phy == NULL)
+		return -EOPNOTSUPP;
+
+	err = phy_ethtool_set_wol(mp->phy, wol);
+	/* Given that mvberlin works without the marvell-specific PHY driver,
+	 * this debugging hint is useful to have.
+	 */
+	if (err == -EOPNOTSUPP)
+		netdev_info(dev, "The PHY does not support set_wol, was CONFIG_MARVELL_PHY enabled?\n");
+	return err;
+}
+
+static int
+mvberlin_eth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+
+	if (mp->phy != NULL)
+		return mvberlin_eth_get_settings_phy(mp, cmd);
+
+	return mvberlin_eth_get_settings_phyless(mp, cmd);
+}
+
+static int
+mvberlin_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+	int ret;
+
+	if (mp->phy == NULL)
+		return -EINVAL;
+
+	ret = phy_ethtool_sset(mp->phy, cmd);
+	if (!ret)
+		mvberlin_eth_adjust_link(dev);
+	return ret;
+}
+
+static void mvberlin_eth_get_drvinfo(struct net_device *dev,
+				     struct ethtool_drvinfo *drvinfo)
+{
+	strlcpy(drvinfo->driver, mvberlin_eth_driver_name,
+		sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, mvberlin_eth_driver_version,
+		sizeof(drvinfo->version));
+	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, "platform", sizeof(drvinfo->bus_info));
+	drvinfo->n_stats = ARRAY_SIZE(mvberlin_eth_stats);
+}
+
+static int mvberlin_eth_nway_reset(struct net_device *dev)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+
+	if (mp->phy == NULL)
+		return -EINVAL;
+
+	return genphy_restart_aneg(mp->phy);
+}
+
+static void
+mvberlin_eth_get_ringparam(struct net_device *dev, struct ethtool_ringparam *er)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+
+	er->rx_max_pending = 4096;
+	er->tx_max_pending = 4096;
+
+	er->rx_pending = mp->rx_ring_size;
+	er->tx_pending = mp->tx_ring_size;
+}
+
+static int
+mvberlin_eth_set_ringparam(struct net_device *dev, struct ethtool_ringparam *er)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+
+	if (er->rx_mini_pending || er->rx_jumbo_pending)
+		return -EINVAL;
+
+	mp->rx_ring_size = er->rx_pending < 4096 ? er->rx_pending : 4096;
+	mp->tx_ring_size = er->tx_pending < 4096 ? er->tx_pending : 4096;
+	if (mp->tx_ring_size != er->tx_pending)
+		netdev_warn(dev, "TX queue size set to %u (requested %u)\n",
+			    mp->tx_ring_size, er->tx_pending);
+
+	if (netif_running(dev)) {
+		mvberlin_eth_stop(dev);
+		if (mvberlin_eth_open(dev)) {
+			netdev_err(dev,
+				   "fatal error on re-opening device after ring param change\n");
+			return -ENOMEM;
+		}
+	}
+
+	return 0;
+}
+
+static void mvberlin_eth_get_strings(struct net_device *dev,
+				     uint32_t stringset, uint8_t *data)
+{
+	int i;
+
+	if (stringset == ETH_SS_STATS) {
+		for (i = 0; i < ARRAY_SIZE(mvberlin_eth_stats); i++) {
+			memcpy(data + i * ETH_GSTRING_LEN,
+			       mvberlin_eth_stats[i].stat_string,
+			       ETH_GSTRING_LEN);
+		}
+	}
+}
+
+static void mvberlin_eth_get_ethtool_stats(struct net_device *dev,
+					   struct ethtool_stats *stats,
+					   uint64_t *data)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+	int i;
+
+	mvberlin_eth_get_stats(dev);
+
+	for (i = 0; i < ARRAY_SIZE(mvberlin_eth_stats); i++) {
+		const struct mvberlin_eth_stats *stat;
+		void *p;
+
+		stat = mvberlin_eth_stats + i;
+
+		if (stat->netdev_off >= 0)
+			p = ((void *)mp->dev) + stat->netdev_off;
+		else
+			p = ((void *)mp) + stat->mp_off;
+
+		data[i] = (stat->sizeof_stat == 8) ?
+				*(uint64_t *)p : *(uint32_t *)p;
+	}
+}
+
+static int mvberlin_eth_get_sset_count(struct net_device *dev, int sset)
+{
+	if (sset == ETH_SS_STATS)
+		return ARRAY_SIZE(mvberlin_eth_stats);
+
+	return -EOPNOTSUPP;
+}
+
+const struct ethtool_ops mvberlin_eth_ethtool_ops = {
+	.get_settings		= mvberlin_eth_get_settings,
+	.set_settings		= mvberlin_eth_set_settings,
+	.get_drvinfo		= mvberlin_eth_get_drvinfo,
+	.nway_reset		= mvberlin_eth_nway_reset,
+	.get_link		= ethtool_op_get_link,
+	.get_ringparam		= mvberlin_eth_get_ringparam,
+	.set_ringparam		= mvberlin_eth_set_ringparam,
+	.get_strings		= mvberlin_eth_get_strings,
+	.get_ethtool_stats	= mvberlin_eth_get_ethtool_stats,
+	.get_sset_count		= mvberlin_eth_get_sset_count,
+	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_wol                = mvberlin_eth_get_wol,
+	.set_wol                = mvberlin_eth_set_wol,
+};
+
+/* rx/tx queue initialisation ***********************************************/
+static int rxq_init(struct mvberlin_eth_private *mp, int index)
+{
+	struct rx_queue *rxq = mp->rxq + index;
+	struct rx_desc *rx_desc;
+	int size;
+	int i;
+
+	rxq->index = index;
+
+	rxq->rx_ring_size = mp->rx_ring_size;
+
+	rxq->rx_desc_count = 0;
+	rxq->rx_curr_desc = 0;
+	rxq->rx_used_desc = 0;
+
+	size = rxq->rx_ring_size * sizeof(struct rx_desc);
+
+	if (index == 0 && size <= mp->rx_desc_sram_size) {
+		rxq->rx_desc_area = ioremap(mp->rx_desc_sram_addr,
+					    mp->rx_desc_sram_size);
+		rxq->rx_desc_dma = mp->rx_desc_sram_addr;
+	} else {
+		rxq->rx_desc_area = dma_alloc_coherent(mp->dev->dev.parent,
+						       size, &rxq->rx_desc_dma,
+						       GFP_KERNEL);
+	}
+
+	if (rxq->rx_desc_area == NULL) {
+		netdev_err(mp->dev,
+			   "can't allocate rx ring (%d bytes)\n", size);
+		goto out;
+	}
+	memset(rxq->rx_desc_area, 0, size);
+
+	rxq->rx_desc_area_size = size;
+	rxq->rx_skb = kcalloc(rxq->rx_ring_size, sizeof(*rxq->rx_skb),
+			      GFP_KERNEL);
+	if (rxq->rx_skb == NULL)
+		goto out_free;
+
+	rx_desc = rxq->rx_desc_area;
+	for (i = 0; i < rxq->rx_ring_size; i++) {
+		int nexti;
+
+		nexti = i + 1;
+		if (nexti == rxq->rx_ring_size)
+			nexti = 0;
+
+		rx_desc[i].next_desc_ptr = rxq->rx_desc_dma +
+					nexti * sizeof(struct rx_desc);
+	}
+
+	return 0;
+
+out_free:
+	if (index == 0 && size <= mp->rx_desc_sram_size)
+		iounmap(rxq->rx_desc_area);
+	else
+		dma_free_coherent(mp->dev->dev.parent, size,
+				  rxq->rx_desc_area,
+				  rxq->rx_desc_dma);
+
+out:
+	return -ENOMEM;
+}
+
+static void rxq_deinit(struct rx_queue *rxq)
+{
+	struct mvberlin_eth_private *mp = rxq_to_mp(rxq);
+	int i;
+
+	rxq_disable(rxq);
+
+	for (i = 0; i < rxq->rx_ring_size; i++) {
+		if (rxq->rx_skb[i]) {
+			dev_kfree_skb(rxq->rx_skb[i]);
+			rxq->rx_desc_count--;
+		}
+	}
+
+	if (rxq->rx_desc_count) {
+		netdev_err(mp->dev, "error freeing rx ring -- %d skbs stuck\n",
+			   rxq->rx_desc_count);
+	}
+
+	if (rxq->index == 0 &&
+	    rxq->rx_desc_area_size <= mp->rx_desc_sram_size)
+		iounmap(rxq->rx_desc_area);
+	else
+		dma_free_coherent(mp->dev->dev.parent, rxq->rx_desc_area_size,
+				  rxq->rx_desc_area, rxq->rx_desc_dma);
+
+	kfree(rxq->rx_skb);
+}
+
+static int txq_init(struct mvberlin_eth_private *mp, int index)
+{
+	struct tx_queue *txq = mp->txq + index;
+	struct tx_desc *tx_desc;
+	int size;
+	int i;
+
+	txq->index = index;
+
+	txq->tx_ring_size = mp->tx_ring_size;
+
+	txq->tx_desc_count = 0;
+	txq->tx_curr_desc = 0;
+	txq->tx_used_desc = 0;
+
+	size = txq->tx_ring_size * sizeof(struct tx_desc);
+
+	if (index == 0 && size <= mp->tx_desc_sram_size) {
+		txq->tx_desc_area = ioremap(mp->tx_desc_sram_addr,
+					    mp->tx_desc_sram_size);
+		txq->tx_desc_dma = mp->tx_desc_sram_addr;
+	} else {
+		txq->tx_desc_area = dma_alloc_coherent(mp->dev->dev.parent,
+						       size, &txq->tx_desc_dma,
+						       GFP_KERNEL);
+	}
+
+	if (txq->tx_desc_area == NULL) {
+		netdev_err(mp->dev,
+			   "can't allocate tx ring (%d bytes)\n", size);
+		return -ENOMEM;
+	}
+	memset(txq->tx_desc_area, 0, size);
+
+	txq->tx_desc_area_size = size;
+
+	tx_desc = txq->tx_desc_area;
+	for (i = 0; i < txq->tx_ring_size; i++) {
+		struct tx_desc *txd = tx_desc + i;
+		int nexti;
+
+		nexti = i + 1;
+		if (nexti == txq->tx_ring_size)
+			nexti = 0;
+
+		txd->cmd_sts = 0;
+		txd->next_desc_ptr = txq->tx_desc_dma +
+					nexti * sizeof(struct tx_desc);
+	}
+
+	skb_queue_head_init(&txq->tx_skb);
+
+	return 0;
+}
+
+static void txq_deinit(struct tx_queue *txq)
+{
+	struct mvberlin_eth_private *mp = txq_to_mp(txq);
+
+	txq_disable(txq);
+	txq_reclaim(txq, txq->tx_ring_size, 1);
+
+	BUG_ON(txq->tx_used_desc != txq->tx_curr_desc);
+
+	if (txq->index == 0 &&
+	    txq->tx_desc_area_size <= mp->tx_desc_sram_size)
+		iounmap(txq->tx_desc_area);
+	else
+		dma_free_coherent(mp->dev->dev.parent, txq->tx_desc_area_size,
+				  txq->tx_desc_area, txq->tx_desc_dma);
+}
+
+static void handle_link_event(struct mvberlin_eth_private *mp)
+{
+	struct net_device *dev = mp->dev;
+	u32 port_status;
+	int speed;
+	int duplex;
+	int fc;
+
+	port_status = rdlp(mp, PORT_STATUS);
+	if (!(port_status & LINK_UP)) {
+		if (netif_carrier_ok(dev)) {
+			int i;
+
+			netdev_info(dev, "link down\n");
+
+			netif_carrier_off(dev);
+
+			for (i = 0; i < mp->txq_count; i++) {
+				struct tx_queue *txq = mp->txq + i;
+
+				txq_reclaim(txq, txq->tx_ring_size, 1);
+				txq_reset_hw_ptr(txq);
+			}
+		}
+		return;
+	}
+
+	switch (port_status & PORT_SPEED_MASK) {
+	case PORT_SPEED_10:
+		speed = 10;
+		break;
+	case PORT_SPEED_100:
+		speed = 100;
+		break;
+	default:
+		speed = -1;
+		break;
+	}
+
+	duplex = (port_status & FULL_DUPLEX) ? 1 : 0;
+	fc = (port_status & FLOW_CONTROL_ENABLED) ? 1 : 0;
+
+	netdev_info(dev, "link up, %d Mb/s, %s duplex, flow control %sabled\n",
+		    speed, duplex ? "full" : "half", fc ? "en" : "dis");
+
+	if (!netif_carrier_ok(dev))
+		netif_carrier_on(dev);
+}
+
+static irqreturn_t mvberlin_eth_irq(int irq, void *dev_id)
+{
+	struct net_device *dev = (struct net_device *)dev_id;
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+	u32 int_cause, txstatus;
+	int i;
+
+	int_cause = rdlp(mp, INT_CAUSE) & mp->int_mask;
+
+	if (int_cause == 0)
+		return IRQ_NONE;
+	wrlp(mp, INT_CAUSE, ~int_cause);
+
+	if (int_cause & INT_RX) {
+		wrlp(mp, INT_MASK, mp->int_mask & ~INT_RX);
+		napi_schedule(&mp->napi);
+	}
+
+	if (int_cause & INT_EXT)
+		handle_link_event(mp);
+
+	txstatus = int_cause & INT_TX;
+	for (i = 0; i < mp->txq_count; ++i) {
+		if (txstatus & INT_TX_0 << i) {
+			txq_reclaim(mp->txq + i, 16, 0);
+			txq_maybe_wake(mp->txq + i);
+		}
+	}
+
+	txstatus = ((int_cause & INT_TX_END) >> 6) &
+		   ~((rdlp(mp, SDMA_COMMAND) >> 16) & 0x3);
+	for (i = 0; i < mp->txq_count; ++i) {
+		if (txstatus & 1 << i)
+			txq_kick(mp->txq + i);
+	}
+
+	return IRQ_HANDLED;
+}
+
+static int mvberlin_eth_poll(struct napi_struct *napi, int budget)
+{
+	struct mvberlin_eth_private *mp;
+	int i, work_done;
+
+	mp = container_of(napi, struct mvberlin_eth_private, napi);
+
+	if (unlikely(mp->oom)) {
+		mp->oom = 0;
+		del_timer(&mp->rx_oom);
+	}
+
+	work_done = 0;
+	for (i = mp->rxq_count - 1; work_done < budget && i >= 0; i--) {
+		struct rx_queue *rxq = mp->rxq + i;
+		int work_tbd = budget - work_done;
+
+		work_done += rxq_process(rxq, work_tbd);
+		wrlp(mp, INT_CAUSE, ~(INT_RX_0 << i));
+		if (likely(!mp->oom))
+			if (mp->work_rx_refill & 1 << i)
+				rxq_refill(rxq, work_tbd);
+	}
+
+	if (work_done < budget) {
+		if (mp->oom)
+			mod_timer(&mp->rx_oom, jiffies + (HZ / 10));
+		napi_complete(napi);
+		wrlp(mp, INT_MASK, mp->int_mask);
+	}
+
+	return work_done;
+}
+
+static inline void oom_timer_wrapper(unsigned long data)
+{
+	struct mvberlin_eth_private *mp = (void *)data;
+
+	napi_schedule(&mp->napi);
+}
+
+static inline unsigned int cal_mfl(int size)
+{
+	unsigned int pcxr;
+
+	if (size > 2048)
+		pcxr = MRU_64K;
+	else if (size > 1536)
+		pcxr = MRU_2048;
+	else if (size > 1518)
+		pcxr = MRU_1536;
+	else
+		pcxr = MRU_1518;
+
+	return pcxr;
+}
+
+static void port_start(struct mvberlin_eth_private *mp)
+{
+	u32 pscr, pcxr;
+	int i;
+
+	/* Perform PHY reset, if there is a PHY */
+	if (mp->phy != NULL) {
+		struct ethtool_cmd cmd;
+
+		mvberlin_eth_get_settings(mp->dev, &cmd);
+		phy_init_hw(mp->phy);
+		mvberlin_eth_set_settings(mp->dev, &cmd);
+		phy_start(mp->phy);
+	}
+
+	/* Configure basic link parameters */
+	pcxr =  rdlp(mp, PORT_EXT_CONFIG);
+	pcxr &= ~EXT_MRU_ALL_MASK;
+	pcxr |= cal_mfl(mp->skb_size);
+	wrlp(mp, PORT_EXT_CONFIG, pcxr);
+
+	pscr = rdlp(mp, PORT_CONFIG);
+	pscr |= PORT_ENABLE;
+	wrlp(mp, PORT_CONFIG, pscr);
+
+	/* Configure TX path and queues */
+	for (i = 0; i < mp->txq_count; i++) {
+		struct tx_queue *txq = mp->txq + i;
+
+		txq_reset_hw_ptr(txq);
+	}
+
+	/* Enable the receive queues */
+	for (i = 0; i < mp->rxq_count; i++) {
+		struct rx_queue *rxq = mp->rxq + i;
+		u32 addr;
+
+		addr = (u32)rxq->rx_desc_dma;
+		addr += rxq->rx_curr_desc * sizeof(struct rx_desc);
+		wrlp(mp, RXQ_CURRENT_DESC_PTR(i), addr);
+		wrlp(mp, RXQ_FIRST_DESC_PTR(i), addr);
+
+		rxq_enable(rxq);
+	}
+}
+
+static void mvberlin_eth_recalc_skb_size(struct mvberlin_eth_private *mp)
+{
+	int skb_size;
+
+	/* Reserve 2+14 bytes for an ethernet header (the hardware
+	 * automatically prepends 2 bytes of dummy data to each
+	 * received packet), 16 bytes for up to four VLAN tags, and
+	 * 4 bytes for the trailing FCS -- 36 bytes total.
+	 */
+	skb_size = mp->dev->mtu + 36;
+
+	/* Make sure that the skb size is a multiple of 8 bytes, as
+	 * the lower three bits of the receive descriptor's buffer
+	 * size field are ignored by the hardware.
+	 */
+	mp->skb_size = (skb_size + 7) & ~7;
+
+	/* If NET_SKB_PAD is smaller than a cache line,
+	 * netdev_alloc_skb() will cause skb->data to be misaligned
+	 * to a cache line boundary.  If this is the case, include
+	 * some extra space to allow re-aligning the data area.
+	 */
+	mp->skb_size += SKB_DMA_REALIGN;
+}
+
+static int mvberlin_eth_open(struct net_device *dev)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+	int err;
+	int i;
+
+	wrlp(mp, INT_CAUSE, 0);
+	wrlp(mp, INT_MASK, 0);
+
+	err = request_irq(dev->irq, mvberlin_eth_irq,
+			  IRQF_SHARED, dev->name, dev);
+	if (err) {
+		netdev_err(dev, "can't assign irq\n");
+		return -EAGAIN;
+	}
+
+	mvberlin_eth_recalc_skb_size(mp);
+
+	napi_enable(&mp->napi);
+
+	mp->int_mask = INT_EXT;
+
+	for (i = 0; i < mp->rxq_count; i++) {
+		err = rxq_init(mp, i);
+		if (err) {
+			while (--i >= 0)
+				rxq_deinit(mp->rxq + i);
+			goto out;
+		}
+
+		rxq_refill(mp->rxq + i, INT_MAX);
+		mp->int_mask |= INT_RX_0 << i;
+	}
+
+	if (mp->oom) {
+		mp->rx_oom.expires = jiffies + (HZ / 10);
+		add_timer(&mp->rx_oom);
+	}
+
+	for (i = 0; i < mp->txq_count; i++) {
+		err = txq_init(mp, i);
+		if (err) {
+			while (--i >= 0)
+				txq_deinit(mp->txq + i);
+			goto out_free;
+		}
+		mp->int_mask |= INT_TX_0 << i;
+		mp->int_mask |= INT_TX_END_0 << i;
+	}
+
+	port_start(mp);
+
+	wrlp(mp, INT_MASK, mp->int_mask);
+
+	return 0;
+
+out_free:
+	for (i = 0; i < mp->rxq_count; i++)
+		rxq_deinit(mp->rxq + i);
+out:
+	free_irq(dev->irq, dev);
+
+	return err;
+}
+
+static void port_reset(struct mvberlin_eth_private *mp)
+{
+	unsigned int data;
+	int i;
+
+	for (i = 0; i < mp->rxq_count; i++)
+		rxq_disable(mp->rxq + i);
+	for (i = 0; i < mp->txq_count; i++)
+		txq_disable(mp->txq + i);
+
+	/* Reset the Enable bit in the Configuration Register */
+	data = rdlp(mp, PORT_CONFIG);
+	data &= ~(PORT_ENABLE | HASH_PASS_MODE);
+	wrlp(mp, PORT_CONFIG, data);
+}
+
+static int mvberlin_eth_stop(struct net_device *dev)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+	int i;
+
+	wrlp(mp, INT_MASK, 0x00000000);
+	rdlp(mp, INT_MASK);
+
+	napi_disable(&mp->napi);
+
+	del_timer_sync(&mp->rx_oom);
+
+	netif_carrier_off(dev);
+	if (mp->phy)
+		phy_stop(mp->phy);
+	free_irq(dev->irq, dev);
+
+	port_reset(mp);
+	mvberlin_eth_get_stats(dev);
+
+	for (i = 0; i < mp->rxq_count; i++)
+		rxq_deinit(mp->rxq + i);
+	for (i = 0; i < mp->txq_count; i++)
+		txq_deinit(mp->txq + i);
+
+	return 0;
+}
+
+static int mvberlin_eth_ioctl(struct net_device *dev, struct ifreq *ifr,
+			      int cmd)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+	int ret;
+
+	if (mp->phy == NULL)
+		return -ENOTSUPP;
+
+	ret = phy_mii_ioctl(mp->phy, ifr, cmd);
+	if (!ret)
+		mvberlin_eth_adjust_link(dev);
+	return ret;
+}
+
+static int mvberlin_eth_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+
+	if (new_mtu < 64 || new_mtu > 9500)
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+	mvberlin_eth_recalc_skb_size(mp);
+
+	if (!netif_running(dev))
+		return 0;
+
+	/* Stop and then re-open the interface. This will allocate RX
+	 * skbs of the new MTU.
+	 * There is a possible danger that the open will not succeed,
+	 * due to memory being full.
+	 */
+	mvberlin_eth_stop(dev);
+	if (mvberlin_eth_open(dev)) {
+		netdev_err(dev,
+			   "fatal error on re-opening device after MTU change\n");
+	}
+
+	return 0;
+}
+
+static void tx_timeout_task(struct work_struct *ugly)
+{
+	struct mvberlin_eth_private *mp;
+
+	mp = container_of(ugly, struct mvberlin_eth_private, tx_timeout_task);
+	if (netif_running(mp->dev)) {
+		netif_tx_stop_all_queues(mp->dev);
+		port_reset(mp);
+		port_start(mp);
+		netif_tx_wake_all_queues(mp->dev);
+	}
+}
+
+static void mvberlin_eth_tx_timeout(struct net_device *dev)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+
+	netdev_info(dev, "tx timeout\n");
+
+	schedule_work(&mp->tx_timeout_task);
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void mvberlin_eth_netpoll(struct net_device *dev)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+
+	wrlp(mp, INT_MASK, 0x00000000);
+	rdlp(mp, INT_MASK);
+
+	mvberlin_eth_irq(dev->irq, dev);
+
+	wrlp(mp, INT_MASK, mp->int_mask);
+}
+#endif
+
+/* hash_table_function - Hash calculation function */
+static unsigned int hash_table_function(unsigned int mac_h, unsigned int mac_l)
+{
+	unsigned int hash_result;
+	unsigned int addr_h;
+	unsigned int addr_l;
+	unsigned int addr_0;
+	unsigned int addr_1;
+	unsigned int addr_2;
+	unsigned int addr_3;
+	unsigned int addr_h_swapped = 0;
+	unsigned int addr_l_swapped = 0;
+
+	addr_h = NIBBLE_SWAPPING_16_BIT(mac_h);
+	addr_l = NIBBLE_SWAPPING_32_BIT(mac_l);
+
+	addr_h_swapped = GT_NIBBLE(addr_h & 0xf)	+
+		((GT_NIBBLE((addr_h>>4) & 0xf)) << 4)	+
+		((GT_NIBBLE((addr_h>>8) & 0xf)) << 8)	+
+		((GT_NIBBLE((addr_h>>12) & 0xf)) << 12);
+
+	addr_l_swapped = GT_NIBBLE(addr_l & 0xf)	+
+		((GT_NIBBLE((addr_l>>4) & 0xf)) << 4)	+
+		((GT_NIBBLE((addr_l>>8) & 0xf)) << 8)	+
+		((GT_NIBBLE((addr_l>>12) & 0xf)) << 12)	+
+		((GT_NIBBLE((addr_l>>16) & 0xf)) << 16)	+
+		((GT_NIBBLE((addr_l>>20) & 0xf)) << 20)	+
+		((GT_NIBBLE((addr_l>>24) & 0xf)) << 24)	+
+		((GT_NIBBLE((addr_l>>28) & 0xf)) << 28);
+
+	addr_h = addr_h_swapped;
+	addr_l = addr_l_swapped;
+
+	/* hash mode 0 */
+	addr_0 = (addr_l >> 2) & 0x3f;
+	addr_1 = (addr_l & 0x3) | ((addr_l>>8) & 0x7f)<<2;
+	addr_2 = (addr_l >> 15) & 0x1ff;
+	addr_3 = ((addr_l >> 24) & 0xff) | ((addr_h & 0x1) << 8);
+
+	hash_result = (addr_0 << 9) | (addr_1 ^ addr_2 ^ addr_3);
+	hash_result = hash_result & 0x7ff; /* half-k */
+
+	return hash_result;
+}
+
+static void add_del_table_entry(void *ptr, unsigned char *addr,
+				int rd, int skip, int del)
+{
+	unsigned int addr_h, addr_l;
+	unsigned int addr_l_read, addr_h_read;
+	unsigned int mac_h, mac_l, *entry;
+	int i;
+
+	mac_h = (addr[0] << 8) | (addr[1]);
+	mac_l = (addr[2] << 24) | (addr[3] << 16) | (addr[4] << 8) | (addr[5]);
+	entry = (unsigned int *)(ptr + (8 * hash_table_function(mac_h, mac_l)));
+
+	addr_l = HASH_TABLE_ENTRY_VALID | (rd<<2)			 |
+		 (((mac_h>>8) & 0xf)<<3) | (((mac_h>>12) & 0xf) << 7)	 |
+		 (((mac_h>>0) & 0xf)<<11) | (((mac_h>>4) & 0xf) << 15)	 |
+		 (((mac_l>>24) & 0xf)<<19) | (((mac_l>>28) & 0xf) << 23) |
+		 (((mac_l>>16) & 0xf)<<27) | ((((mac_l>>20) & 0x1) << 31));
+
+	addr_h = ((mac_l>>21) & 0x7) | (((mac_l>>8) & 0xf)<<3)		 |
+		 (((mac_l>>12) & 0xf) << 7) | (((mac_l>>0) & 0xf) << 11) |
+		 (((mac_l>>4) & 0xf) << 15);
+
+	if (skip)
+		addr_l |= HASH_TABLE_ENTRY_SKIP;
+
+	/* find a free place */
+	for (i = 0 ; i < 12 ; i++) {
+		addr_l_read = *(entry + (i*2));
+		if (!(addr_l_read & HASH_TABLE_ENTRY_VALID) ||
+		     (addr_l_read & HASH_TABLE_ENTRY_SKIP)) {
+			entry = entry + (i*2);
+			break;
+		} else {
+			addr_h_read = *(entry + (i*2) + 1);
+			if (((addr_l_read>>3) & 0x1fffffff) ==
+			    ((addr_l>>3) & 0x1fffffff) &&
+			     (addr_h_read == addr_h)) {
+				entry = entry + (i*2);
+				break;
+			}
+		}
+	}
+
+	if (i == 12)
+		return;
+
+	/* update address entry */
+	if (del) {
+		*entry = 0;
+		*(entry + 1) = 0;
+	} else {
+		*entry = addr_l;
+		*(entry + 1) = addr_h;
+	}
+}
+
+static void init_hash_table(struct mvberlin_eth_private *mp)
+{
+	u32 epcr;
+
+	epcr = rdlp(mp, PORT_CONFIG);
+	epcr |= HASH_SIZE_HALF_K;
+	epcr &= ~HASH_FUNCTION_1;
+	/* reset HDM to 0: discard addresses not found in hash table */
+	epcr &= ~HASH_PASS_MODE;
+	wrlp(mp, PORT_CONFIG, epcr);
+	mp->hash_tbl = dma_alloc_coherent(mp->dev->dev.parent,
+					  HASH_TABLE_SIZE,
+					  &mp->hash_dma, GFP_KERNEL);
+	wrlp(mp, HASH_TABLE, mp->hash_dma);
+}
+
+static void mvberlin_eth_set_multicast_list(struct net_device *dev)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+	u32 epcr;
+
+	epcr = rdlp(mp, PORT_CONFIG);
+	if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) {
+		epcr |= PROMISCUOUS_MODE;
+		wrlp(mp, PORT_CONFIG, epcr);
+	} else {
+		struct netdev_hw_addr *ha;
+
+		epcr &= ~(PROMISCUOUS_MODE | BROADCAST_REJECT_MODE);
+		wrlp(mp, PORT_CONFIG, epcr);
+
+		memset(mp->hash_tbl, 0, HASH_TABLE_SIZE);
+		add_del_table_entry(mp->hash_tbl, dev->dev_addr, 1, 0, 0);
+		netdev_for_each_mc_addr(ha, dev)
+			add_del_table_entry(mp->hash_tbl, ha->addr, 1, 0, 0);
+	}
+}
+
+static void init_pscr(struct mvberlin_eth_private *mp)
+{
+	u32 pcxr;
+
+	wrlp(mp, PORT_CONFIG, 0);
+	pcxr = EXT_FC_AN_DISABLE | EXT_FLP_DISABLE | EXT_FC_ENABLE |
+	       EXT_MAC_RX_2BSTUFF | EXT_IGMP | EXT_SPAN | EXT_DSCP_EN;
+
+	/* Only use HIGH TXQ when only one TXQ, so set all pkts are from HIGH */
+	if (mp->txq_count == 1)
+		pcxr |= (7 << 3);
+
+	wrlp(mp, PORT_EXT_CONFIG, pcxr);
+	wrlp(mp, ETH_EDSCP2P0L, 0xFFFFFFFE);
+	wrlp(mp, ETH_EDSCP2P1L, 0x0);
+	wrlp(mp, ETH_EDSCP2P0H, 0xFFFFFFFF);
+	wrlp(mp, ETH_EDSCP2P1H, 0x0);
+}
+
+static void mib_counters_clear(struct mvberlin_eth_private *mp)
+{
+	int i;
+	u32 data;
+
+	data = rdlp(mp, PORT_EXT_CONFIG);
+	data &= ~EXT_MIB_CLEAR; /* 0 to read-clear */
+	wrlp(mp, PORT_EXT_CONFIG, data);
+	for (i = 0; i < 0x60; i += 4)
+		mib_read(mp, i);
+	data |= EXT_MIB_CLEAR; /* 1 to read-no-effect */
+	wrlp(mp, PORT_EXT_CONFIG, data);
+}
+
+static void uc_addr_get(struct mvberlin_eth_private *mp, unsigned char *addr)
+{
+	unsigned int mac_h = rdlp(mp, MAC_ADDR_HIGH);
+	unsigned int mac_l = rdlp(mp, MAC_ADDR_LOW);
+
+	addr[0] = (mac_h >> 24) & 0xff;
+	addr[1] = (mac_h >> 16) & 0xff;
+	addr[2] = (mac_h >> 8) & 0xff;
+	addr[3] = mac_h & 0xff;
+	addr[4] = (mac_l >> 8) & 0xff;
+	addr[5] = mac_l & 0xff;
+}
+
+static void uc_addr_set(struct mvberlin_eth_private *mp, unsigned char *addr)
+{
+	wrlp(mp, MAC_ADDR_HIGH,
+	     (addr[0] << 24) | (addr[1] << 16) | (addr[2] << 8) | addr[3]);
+	wrlp(mp, MAC_ADDR_LOW, (addr[4] << 8) | addr[5]);
+}
+
+static void mvberlin_eth_program_unicast_filter(struct mvberlin_eth_private *mp,
+						unsigned char *old,
+						unsigned char *new)
+{
+	uc_addr_set(mp, new);
+
+	/* delete the old address from the filter table */
+	if (old)
+		add_del_table_entry(mp->hash_tbl, old, 1, 0, 1);
+
+	/* add the new address to filter table */
+	add_del_table_entry(mp->hash_tbl, new, 1, 0, 0);
+}
+
+static int mvberlin_eth_set_mac_address(struct net_device *dev, void *addr)
+{
+	struct mvberlin_eth_private *mp = netdev_priv(dev);
+	struct sockaddr *sa = addr;
+	unsigned char old[ETH_ALEN];
+
+	if (!is_valid_ether_addr(sa->sa_data))
+		return -EINVAL;
+
+	memcpy(old, dev->dev_addr, ETH_ALEN);
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
+	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
+
+	netif_addr_lock_bh(dev);
+	mvberlin_eth_program_unicast_filter(mp, old, dev->dev_addr);
+	netif_addr_unlock_bh(dev);
+
+	return 0;
+}
+
+static void set_params(struct mvberlin_eth_private *mp,
+		       struct mv643xx_eth_platform_data *pd)
+{
+	struct net_device *dev = mp->dev;
+
+	if (is_valid_ether_addr(pd->mac_addr))
+		memcpy(dev->dev_addr, pd->mac_addr, ETH_ALEN);
+	else
+		uc_addr_get(mp, dev->dev_addr);
+
+	mp->rx_ring_size = DEFAULT_RX_QUEUE_SIZE;
+	if (pd->rx_queue_size)
+		mp->rx_ring_size = pd->rx_queue_size;
+	mp->rx_desc_sram_addr = pd->rx_sram_addr;
+	mp->rx_desc_sram_size = pd->rx_sram_size;
+
+	mp->rxq_count = pd->rx_queue_count ? : 1;
+
+	mp->tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
+	if (pd->tx_queue_size)
+		mp->tx_ring_size = pd->tx_queue_size;
+
+	mp->tx_desc_sram_addr = pd->tx_sram_addr;
+	mp->tx_desc_sram_size = pd->tx_sram_size;
+
+	mp->txq_count = pd->tx_queue_count ? : 1;
+}
+
+static const struct net_device_ops mvberlin_eth_netdev_ops = {
+	.ndo_open		= mvberlin_eth_open,
+	.ndo_stop		= mvberlin_eth_stop,
+	.ndo_start_xmit		= mvberlin_eth_xmit,
+	.ndo_set_rx_mode	= mvberlin_eth_set_multicast_list,
+	.ndo_set_mac_address	= mvberlin_eth_set_mac_address,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= mvberlin_eth_ioctl,
+	.ndo_change_mtu		= mvberlin_eth_change_mtu,
+	.ndo_tx_timeout		= mvberlin_eth_tx_timeout,
+	.ndo_get_stats		= mvberlin_eth_get_stats,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= mvberlin_eth_netpoll,
+#endif
+};
+
+static int mvberlin_eth_probe(struct platform_device *pdev)
+{
+	struct mv643xx_eth_platform_data *pd;
+	struct mvberlin_eth_private *mp;
+	struct net_device *dev;
+	struct resource *res;
+	int ret;
+
+	dev = alloc_etherdev_mq(sizeof(struct mvberlin_eth_private), 8);
+	if (!dev)
+		return -ENOMEM;
+
+	pd = devm_kzalloc(&pdev->dev, sizeof(*pd), GFP_KERNEL);
+	if (!pd)
+		return -ENOMEM;
+
+	mp = netdev_priv(dev);
+	platform_set_drvdata(pdev, mp);
+	mp->dev = dev;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res)
+		return -ENOMEM;
+
+	mp->shared = devm_kzalloc(&pdev->dev,
+				  sizeof(struct mvberlin_eth_shared_private),
+				  GFP_KERNEL);
+	if (!mp->shared)
+		return -ENOMEM;
+
+	mp->shared->base = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(mp->shared->base))
+		return PTR_ERR(mp->shared->base);
+	mp->base = mp->shared->base + 0x400;
+
+	mp->clk = devm_clk_get(&pdev->dev, NULL);
+	if (!IS_ERR(mp->clk)) {
+		clk_prepare_enable(mp->clk);
+		mp->t_clk = clk_get_rate(mp->clk);
+	}
+
+	set_params(mp, pd);
+	netif_set_real_num_tx_queues(dev, mp->txq_count);
+	netif_set_real_num_rx_queues(dev, mp->rxq_count);
+
+	pd->phy_node = of_parse_phandle(pdev->dev.of_node, "phy-handle", 0);
+	if (!pd->phy_node) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	mp->phy = of_phy_connect(dev, pd->phy_node,
+				 mvberlin_eth_adjust_link, 0,
+				 PHY_INTERFACE_MODE_RGMII);
+	if (!mp->phy) {
+		ret = -EPROBE_DEFER;
+		goto out;
+	}
+
+	dev->ethtool_ops = &mvberlin_eth_ethtool_ops;
+
+	init_pscr(mp);
+
+	init_hash_table(mp);
+	mvberlin_eth_program_unicast_filter(mp, NULL, dev->dev_addr);
+
+	mib_counters_clear(mp);
+
+	INIT_WORK(&mp->tx_timeout_task, tx_timeout_task);
+
+	netif_napi_add(dev, &mp->napi, mvberlin_eth_poll, NAPI_POLL_WEIGHT);
+
+	init_timer(&mp->rx_oom);
+	mp->rx_oom.data = (unsigned long)mp;
+	mp->rx_oom.function = oom_timer_wrapper;
+
+	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	BUG_ON(!res);
+	dev->irq = res->start;
+
+	dev->netdev_ops = &mvberlin_eth_netdev_ops;
+
+	dev->watchdog_timeo = 2 * HZ;
+	dev->base_addr = 0;
+
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	wrlp(mp, SDMA_CONFIG, PORT_SDMA_CONFIG_DEFAULT_VALUE);
+
+	ret = register_netdev(dev);
+	if (ret)
+		goto out;
+
+	netif_carrier_off(dev);
+
+	return 0;
+
+out:
+	if (!IS_ERR(mp->clk))
+		clk_disable_unprepare(mp->clk);
+	free_netdev(dev);
+
+	return ret;
+}
+
+static int mvberlin_eth_remove(struct platform_device *pdev)
+{
+	struct mvberlin_eth_private *mp = platform_get_drvdata(pdev);
+
+	unregister_netdev(mp->dev);
+	if (mp->phy != NULL)
+		phy_disconnect(mp->phy);
+	cancel_work_sync(&mp->tx_timeout_task);
+
+	if (!IS_ERR(mp->clk))
+		clk_disable_unprepare(mp->clk);
+
+	free_netdev(mp->dev);
+
+	return 0;
+}
+
+static void mvberlin_eth_shutdown(struct platform_device *pdev)
+{
+	struct mvberlin_eth_private *mp = platform_get_drvdata(pdev);
+
+	/* Mask all interrupts on ethernet port */
+	wrlp(mp, INT_MASK, 0);
+	rdlp(mp, INT_MASK);
+
+	if (netif_running(mp->dev))
+		port_reset(mp);
+}
+
+static const struct of_device_id mvberlin_eth_of_match[] = {
+	{ .compatible = "marvell,berlin-eth" },
+	{ },
+};
+MODULE_DEVICE_TABLE(of, mvberlin_eth_of_match);
+
+static struct platform_driver mvberlin_eth_driver = {
+	.probe		= mvberlin_eth_probe,
+	.remove		= mvberlin_eth_remove,
+	.shutdown	= mvberlin_eth_shutdown,
+	.driver		= {
+		.name		= "mvberlin-ethernet",
+		.owner		= THIS_MODULE,
+		.of_match_table	= mvberlin_eth_of_match,
+	},
+};
+module_platform_driver(mvberlin_eth_driver);
+
+MODULE_AUTHOR("Antoine Tenart <antoine.tenart@free-electrons.com>");
+MODULE_DESCRIPTION("Ethernet driver for Marvell Berlin SoCs");
+MODULE_LICENSE("GPL");
-- 
1.9.1
