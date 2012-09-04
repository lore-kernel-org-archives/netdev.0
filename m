From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 1/4] net: mvneta: driver for Marvell Armada 370/XP network unit
Date: Tue,  4 Sep 2012 15:06:41 +0200
Message-ID: <1346764004-16332-2-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1346764004-16332-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Ike Pan <ike.pan@canonical.com>, Albert Stone <albert.stone@canonical.com>,
 Nadav Haklai <nadavh@marvell.com>, Ian Molton <ian.molton@codethink.co.uk>,
 David Marlin <dmarlin@redhat.com>, Rami Rosen <rosenr@marvell.com>,
 Yehuda Yitschak <yehuday@marvell.com>,
 Jani Monoses <jani.monoses@canonical.com>, Tawfik Bayouk <tawfik@marvell.com>,
 Dan Frazier <dann.frazier@canonical.com>, Eran Ben-Avi <benavi@marvell.com>,
 Li Li <li.li@canonical.com>, Leif Lindholm <leif.lindholm@arm.com>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>, Arnd Bergmann <arnd@arndb.de>,
 Jon Masters <jcm@redhat.com>, Ben Dooks <ben-linux@fluff.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
To: "David S. Miller" <davem@davemloft.net>,
 Lennert Buytenhek <kernel@wantstofly.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1346764004-16332-1-git-send-email-thomas.petazzoni@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Rami Rosen <rosenr@marvell.com>

This patch contains a new network driver for the network unit of the
ARM Marvell Armada 370 and the Armada XP. Both SoCs use the PJ4B
processor, a Marvell-developed ARM core that implements the ARMv7
instruction set.

Compared to previous ARM Marvell SoCs (Kirkwood, Orion, Discovery),
the network unit in Armada 370 and Armada XP is highly different. This
is the reason why this new 'mvneta' driver is needed, while the older
ARM Marvell SoCs use the 'mv643xx_eth' driver.

Here is an overview of the most important hardware changes that
require a new, specific, driver for the network unit of Armada 370/XP:

 - The new network unit has a completely different design and layout
   for the RX and TX descriptors. They are now organized as a simple
   array (each RX and TX queue has base address and size of this
   array) rather than a linked list as in the old SoCs.

 - The new network unit has a different RXQ and TXQ management: this
   management is done using special read/write counter registers,
   while in the Old SocS, it was done using the Ownership bit in RX
   and TX descriptors.

 - The new network unit has different interrupt registers

 - The new network unit way of cleaning of interrupts is not done by
   writing to the cause register, but by updating per-queue counters

 - The new network unit has different GMAC registers (link, speed,
   duplex configuration) and different WRR registers.

 - The new network unit has lots of new units like PnC (Parser and
   Classifier), PMT, BM (Memory Buffer Management), xPON, and more.

The driver proposed in the current patch only handles the basic
features. Additional hardware features will progressively be supported
as needed.

This code has originally been written by Rami Rosen
<rosenr@marvell.com>, and then reviewed and cleaned up by Thomas
Petazzoni <thomas.petazzoni@free-electrons.com>.

Signed-off-by: Rami Rosen <rosenr@marvell.com>
Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 .../devicetree/bindings/net/marvell-neta.txt       |   24 +
 drivers/net/ethernet/marvell/Kconfig               |   11 +
 drivers/net/ethernet/marvell/Makefile              |    1 +
 drivers/net/ethernet/marvell/mvneta.c              | 2732 ++++++++++++++++++++
 drivers/net/ethernet/marvell/mvneta.h              |  496 ++++
 5 files changed, 3264 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/marvell-neta.txt
 create mode 100644 drivers/net/ethernet/marvell/mvneta.c
 create mode 100644 drivers/net/ethernet/marvell/mvneta.h

diff --git a/Documentation/devicetree/bindings/net/marvell-neta.txt b/Documentation/devicetree/bindings/net/marvell-neta.txt
new file mode 100644
index 0000000..a031978
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/marvell-neta.txt
@@ -0,0 +1,24 @@
+* Marvell Armada 370 / Armada XP Ethernet Controller (NETA)
+
+Required properties:
+- compatible: should be "marvell,neta".
+- reg: address and length of the register set for the device.
+- interrupts: interrupt for the device
+- phy-mode: String, operation mode of the PHY interface. Supported
+  values are "sgmii" and "rmii".
+- phy-addr: Integer, address of the PHY.
+- device_type: should be "network".
+- clock-frequency: frequency of the peripheral clock of the SoC.
+
+Example:
+
+eth@d0070000 {
+               compatible = "marvell,neta";
+               reg = <0xd0070000 0x2500>;
+               interrupts = <8>;
+               device_type = "network";
+               clock-frequency = <250000000>;
+               status = "okay";
+               phy-mode = "sgmii";
+               phy-addr = <25>;
+};
diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index 0029934..a526989 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -18,6 +18,17 @@ config NET_VENDOR_MARVELL
 
 if NET_VENDOR_MARVELL
 
+config MVNETA
+	tristate "Marvell Armada 370/XP network interface support"
+	depends on MACH_ARMADA_370_XP
+	---help---
+	  This driver supports the network interface units in the
+	  Marvell ARMADA XP and ARMADA 370 SoC family.
+
+	  Note that this driver is distinct from the mv643xx_eth
+	  driver, which should be used for the older Marvell SoCs
+	  (Dove, Orion, Discovery, Kirkwood).
+
 config MV643XX_ETH
 	tristate "Marvell Discovery (643XX) and Orion ethernet support"
 	depends on (MV64X60 || PPC32 || PLAT_ORION) && INET
diff --git a/drivers/net/ethernet/marvell/Makefile b/drivers/net/ethernet/marvell/Makefile
index 57e3234..a13f9b9 100644
--- a/drivers/net/ethernet/marvell/Makefile
+++ b/drivers/net/ethernet/marvell/Makefile
@@ -6,3 +6,4 @@ obj-$(CONFIG_MV643XX_ETH) += mv643xx_eth.o
 obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
 obj-$(CONFIG_SKGE) += skge.o
 obj-$(CONFIG_SKY2) += sky2.o
+obj-$(CONFIG_MVNETA) += mvneta.o
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
new file mode 100644
index 0000000..20b8d55
--- /dev/null
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -0,0 +1,2732 @@
+/*
+ * Driver for Marvell NETA network card for Armada XP and Armada 370 SoCs.
+ *
+ * Copyright (C) 2012 Marvell
+ *
+ * Rami Rosen <rosenr@marvell.com>
+ * Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include <linux/kernel.h>
+#include <linux/version.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/platform_device.h>
+#include <linux/skbuff.h>
+#include <linux/inetdevice.h>
+#include <linux/mbus.h>
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
+#include <linux/of.h>
+#include <linux/of_irq.h>
+#include <linux/of_net.h>
+#include <linux/of_address.h>
+#include <linux/phy.h>
+
+#include "mvneta.h"
+
+static int mvneta_rxq_number = 8;
+static int mvneta_txq_number = 8;
+
+static int mvneta_rxq_def;
+static int mvneta_txq_def;
+
+/* Max number of Rx descriptors */
+#define MVNETA_MAX_RXD 128
+
+/* Max number of Tx descriptors */
+#define MVNETA_MAX_TXD 532
+
+static const char mvneta_driver_name[] = "mvneta";
+static const char mvneta_driver_version[] = "1.0";
+
+/* Utility/helper methods */
+
+/* Write helper method */
+static void mvreg_write(struct mvneta_port *pp, u32 offset, u32 data)
+{
+	writel(data, pp->base + offset);
+}
+
+/* Read helper method */
+static u32 mvreg_read(struct mvneta_port *pp, u32 offset)
+{
+	return readl(pp->base + offset);
+}
+
+/* Increment txq get counter */
+static void mvneta_inc_get(struct mvneta_tx_queue *txq)
+{
+	txq->txq_get_index++;
+	if (txq->txq_get_index == txq->size)
+		txq->txq_get_index = 0;
+}
+
+/* Increment txq put counter */
+static void mvneta_inc_put(struct mvneta_tx_queue *txq)
+{
+	txq->txq_put_index++;
+	if (txq->txq_put_index == txq->size)
+		txq->txq_put_index = 0;
+}
+
+
+/* Clear all MIB counters */
+static void mvneta_mib_counters_clear(struct mvneta_port *pp)
+{
+	int i;
+	u32 dummy;
+
+	/* Perform dummy reads from MIB counters */
+	for (i = 0; i < MVNETA_MIB_LATE_COLLISION; i += 4)
+		dummy = mvreg_read(pp, (MVNETA_MIB_COUNTERS_BASE + i));
+}
+
+/* Read speed, duplex, and flow control from port status register */
+static int mvneta_link_status(struct mvneta_port *pp,
+			      struct mvneta_lnk_status *status)
+{
+	u32 val;
+
+	val = mvreg_read(pp, MVNETA_GMAC_STATUS);
+
+	if (val & MVNETA_GMAC_SPEED_1000_MASK)
+		status->speed = MVNETA_SPEED_1000;
+	else if (val & MVNETA_GMAC_SPEED_100_MASK)
+		status->speed = MVNETA_SPEED_100;
+	else
+		status->speed = MVNETA_SPEED_10;
+
+	if (val & MVNETA_GMAC_LINK_UP_MASK)
+		status->linkup = 1;
+	else
+		status->linkup = 0;
+
+	if (val & MVNETA_GMAC_FULL_DUPLEX_MASK)
+		status->duplex = MVNETA_DUPLEX_FULL;
+	else
+		status->duplex = MVNETA_DUPLEX_HALF;
+
+	if (val & MVNETA_GMAC_TX_FLOW_CTRL_ACTIVE_MASK)
+		status->tx_fc = MVNETA_FC_ACTIVE;
+	else if (val & MVNETA_GMAC_TX_FLOW_CTRL_ENABLE_MASK)
+		status->tx_fc = MVNETA_FC_ENABLE;
+	else
+		status->tx_fc = MVNETA_FC_DISABLE;
+
+	if (val & MVNETA_GMAC_RX_FLOW_CTRL_ACTIVE_MASK)
+		status->rx_fc = MVNETA_FC_ACTIVE;
+	else if (val & MVNETA_GMAC_RX_FLOW_CTRL_ENABLE_MASK)
+		status->rx_fc = MVNETA_FC_ENABLE;
+	else
+		status->rx_fc = MVNETA_FC_DISABLE;
+
+	return 0;
+}
+
+
+/* Get System Network Statistics */
+struct rtnl_link_stats64 *mvneta_get_stats64(struct net_device *dev,
+					     struct rtnl_link_stats64 *stats)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+	unsigned int start;
+
+	memset(stats, 0, sizeof(struct rtnl_link_stats64));
+
+	do {
+		start = u64_stats_fetch_begin_bh(&pp->rx_stats.syncp);
+		stats->rx_packets = pp->rx_stats.packets;
+		stats->rx_bytes	= pp->rx_stats.bytes;
+	} while (u64_stats_fetch_retry_bh(&pp->rx_stats.syncp, start));
+
+
+	do {
+		start = u64_stats_fetch_begin_bh(&pp->tx_stats.syncp);
+		stats->tx_packets = pp->tx_stats.packets;
+		stats->tx_bytes	= pp->tx_stats.bytes;
+	} while (u64_stats_fetch_retry_bh(&pp->tx_stats.syncp, start));
+
+	stats->rx_errors	= dev->stats.rx_errors;
+	stats->rx_dropped	= dev->stats.rx_dropped;
+
+	stats->tx_dropped	= dev->stats.tx_dropped;
+
+	return stats;
+
+}
+
+/* Rx descriptors helper methods */
+
+/* Add number of descriptors ready to receive new packets */
+static void mvneta_rxq_non_occup_desc_add(struct mvneta_port *pp,
+					  struct mvneta_rx_queue *rxq,
+					  int rx_desc)
+{
+	u32 val;
+
+	/* Only 255 descriptors can be added at once */
+	while (rx_desc > 0xff) {
+		val = (0xff << MVNETA_RXQ_ADD_NON_OCCUPIED_OFFS);
+		mvreg_write(pp, MVNETA_RXQ_STATUS_UPDATE_REG(rxq->id), val);
+		rx_desc = rx_desc - 0xff;
+	}
+
+	val = (rx_desc << MVNETA_RXQ_ADD_NON_OCCUPIED_OFFS);
+	mvreg_write(pp, MVNETA_RXQ_STATUS_UPDATE_REG(rxq->id), val);
+}
+
+/* Get number of RX descriptors occupied by received packets */
+static int mvneta_rxq_busy_desc_num_get(struct mvneta_port *pp,
+					struct mvneta_rx_queue *rxq)
+{
+	u32 val;
+
+	val = mvreg_read(pp, MVNETA_RXQ_STATUS_REG(rxq->id));
+	return val & MVNETA_RXQ_OCCUPIED_ALL_MASK;
+}
+
+/*
+ * Update num of rx desc called upon return from rx path or
+ * from mvneta_rxq_drop_pkts().
+ */
+static void mvneta_rxq_desc_num_update(struct mvneta_port *pp,
+				       struct mvneta_rx_queue *rxq,
+				       int rx_done, int rx_filled)
+{
+	u32 val;
+
+	if ((rx_done <= 0xff) && (rx_filled <= 0xff)) {
+		val = rx_done | (rx_filled << MVNETA_RXQ_ADD_NON_OCCUPIED_OFFS);
+		mvreg_write(pp, MVNETA_RXQ_STATUS_UPDATE_REG(rxq->id), val);
+		return;
+	}
+
+	/* Only 255 descriptors can be added at once */
+	while ((rx_done > 0) || (rx_filled > 0)) {
+		if (rx_done <= 0xff) {
+			val = rx_done;
+			rx_done = 0;
+		} else {
+			val = 0xff;
+			rx_done -= 0xff;
+		}
+		if (rx_filled <= 0xff) {
+			val |= rx_filled
+				<< MVNETA_RXQ_ADD_NON_OCCUPIED_OFFS;
+			rx_filled = 0;
+		} else {
+			val |= 0xff << MVNETA_RXQ_ADD_NON_OCCUPIED_OFFS;
+			rx_filled -= 0xff;
+		}
+		mvreg_write(pp, MVNETA_RXQ_STATUS_UPDATE_REG(rxq->id), val);
+	}
+}
+
+/* Get pointer to next RX descriptor to be processed by SW */
+static struct mvneta_rx_desc *
+mvneta_rxq_next_desc_get(struct mvneta_rx_queue *rxq)
+{
+	unsigned int cur_desc = rxq->next_desc_to_proc;
+
+	rxq->next_desc_to_proc =
+		MVNETA_QUEUE_NEXT_DESC(rxq, cur_desc);
+
+	return rxq->descs + cur_desc;
+}
+
+/* Change maximum receive size of the port. */
+static int mvneta_max_rx_size_set(struct mvneta_port *pp, int max_rx_size)
+{
+	u32 val;
+
+	val =  mvreg_read(pp, MVNETA_GMAC_CTRL_0);
+	val &= ~MVNETA_GMAC_MAX_RX_SIZE_MASK;
+	val |= (((max_rx_size - MVNETA_MH_SIZE) / 2)
+		    << MVNETA_GMAC_MAX_RX_SIZE_OFFS);
+	mvreg_write(pp, MVNETA_GMAC_CTRL_0, val);
+	return 0;
+}
+
+
+/* Set rx queue offset */
+static int mvneta_rxq_offset_set(struct mvneta_port *pp,
+				 struct mvneta_rx_queue *rxq,
+				 int offset)
+{
+	u32 val;
+
+	val = mvreg_read(pp, MVNETA_RXQ_CONFIG_REG(rxq->id));
+	val &= ~MVNETA_RXQ_PKT_OFFSET_ALL_MASK;
+
+	/* Offset is in */
+	val |= MVNETA_RXQ_PKT_OFFSET_MASK(offset >> 3);
+	mvreg_write(pp, MVNETA_RXQ_CONFIG_REG(rxq->id), val);
+
+	return 0;
+}
+
+
+/* Tx descriptors helper methods */
+
+/* Update HW with number of TX descriptors to be sent */
+static void mvneta_txq_pend_desc_add(struct mvneta_port *pp,
+				     struct mvneta_tx_queue *txq,
+				     int pend_desc)
+{
+	u32 val;
+
+	/* Only 255 descriptors can be added at once ; Assume caller process
+	TX desriptors in quanta less than 256 */
+	val = pend_desc;
+	mvreg_write(pp, MVNETA_TXQ_UPDATE_REG(txq->id), val);
+}
+
+/* Get pointer to next TX descriptor to be processed (send) by HW */
+static struct mvneta_tx_desc *
+mvneta_txq_next_desc_get(struct mvneta_tx_queue *txq)
+{
+	unsigned int cur_desc = txq->next_desc_to_proc;
+
+	txq->next_desc_to_proc =
+		MVNETA_QUEUE_NEXT_DESC(txq, cur_desc);
+
+	return txq->descs + cur_desc;
+}
+
+/* Get a TX descriptor if there are enough TX descriptors */
+static struct mvneta_tx_desc *
+mvneta_tx_desc_get(struct mvneta_port *pp, struct mvneta_tx_queue *txq,
+		   int num)
+{
+	/* Are there enough TX descriptors to send packet ? */
+	if ((txq->count + num) >= txq->size)
+		return NULL;
+
+	return mvneta_txq_next_desc_get(txq);
+}
+
+
+/* Set rxq buf size */
+static void mvneta_rxq_buf_size_set(struct mvneta_port *pp,
+				    struct mvneta_rx_queue *rxq,
+				    int buf_size)
+{
+	u32 val;
+
+	val = mvreg_read(pp, MVNETA_RXQ_SIZE_REG(rxq->id));
+
+	val &= ~MVNETA_RXQ_BUF_SIZE_MASK;
+	val |= ((buf_size >> 3) << MVNETA_RXQ_BUF_SIZE_OFFS);
+
+	mvreg_write(pp, MVNETA_RXQ_SIZE_REG(rxq->id), val);
+}
+
+/* Disable buffer management (BM) */
+static void mvneta_rxq_bm_disable(struct mvneta_port *pp,
+				  struct mvneta_rx_queue *rxq)
+{
+	u32 val;
+
+	val = mvreg_read(pp, MVNETA_RXQ_CONFIG_REG(rxq->id));
+	val &= ~MVNETA_RXQ_HW_BUF_ALLOC_MASK;
+	mvreg_write(pp, MVNETA_RXQ_CONFIG_REG(rxq->id), val);
+}
+
+
+
+/* Sets the RGMII Enable bit (RGMIIEn) in port MAC control register */
+static void __devinit mvneta_gmac_rgmii_set(struct mvneta_port *pp, int enable)
+{
+	u32  val;
+
+	val = mvreg_read(pp, MVNETA_GMAC_CTRL_2);
+
+	if (enable)
+		val |= MVNETA_GMAC2_PORT_RGMII_MASK;
+	else
+		val &= ~MVNETA_GMAC2_PORT_RGMII_MASK;
+
+	mvreg_write(pp, MVNETA_GMAC_CTRL_2, val);
+}
+
+/* Config SGMII port */
+static void __devinit mvneta_port_sgmii_config(struct mvneta_port *pp)
+{
+	u32 val;
+
+	val = mvreg_read(pp, MVNETA_GMAC_CTRL_2);
+	val |= MVNETA_GMAC2_PSC_ENABLE_MASK;
+	mvreg_write(pp, MVNETA_GMAC_CTRL_2, val);
+}
+
+/* Start the Ethernet port RX and TX activity */
+static void mvneta_port_up(struct mvneta_port *pp)
+{
+	int queue;
+	u32 q_map;
+
+	/* Enable all initialized TXs. */
+	mvneta_mib_counters_clear(pp);
+	q_map = 0;
+	for (queue = 0; queue < mvneta_txq_number; queue++) {
+		struct mvneta_tx_queue *txq = &pp->txqs[queue];
+		if (txq->descs != NULL)
+			q_map |= (1 << queue);
+	}
+	mvreg_write(pp, MVNETA_TXQ_CMD, q_map);
+
+	/* Enable all initialized RXQs. */
+	q_map = 0;
+	for (queue = 0; queue < mvneta_rxq_number; queue++) {
+		struct mvneta_rx_queue *rxq = &pp->rxqs[queue];
+		if (rxq->descs != NULL)
+			q_map |= (1 << queue);
+	}
+
+	mvreg_write(pp, MVNETA_RXQ_CMD, q_map);
+}
+
+/* Stop the Ethernet port activity */
+static void mvneta_port_down(struct mvneta_port *pp)
+{
+	u32 val;
+	u32 tx_fifo_empty_mask = 0, tx_in_prog_mask = 0;
+	int m_delay;
+
+	/* Stop Rx port activity. Check port Rx activity. */
+	val = (mvreg_read(pp, MVNETA_RXQ_CMD))
+		& MVNETA_RXQ_ENABLE_MASK;
+	/* Issue stop command for active channels only */
+	if (val != 0)
+		mvreg_write(pp, MVNETA_RXQ_CMD, val << MVNETA_RXQ_DISABLE_OFFS);
+
+	/* Wait for all Rx activity to terminate. */
+	m_delay = 0;
+	do {
+		if (m_delay >= MVNETA_RX_DISABLE_TIMEOUT_MSEC) {
+			netdev_info(pp->dev,
+				"TIMEOUT for RX stopped ! rx_queue_cmd: 0x08%x\n",
+				val);
+			break;
+		}
+		mdelay(1);
+		m_delay++;
+
+		val = mvreg_read(pp, MVNETA_RXQ_CMD);
+	} while (val & 0xff);
+
+	/* Stop Tx port activity. Check port Tx activity. Issue stop
+	   command for active channels only  */
+	val = (mvreg_read(pp, MVNETA_TXQ_CMD)) & MVNETA_TXQ_ENABLE_MASK;
+
+	if (val != 0)
+		mvreg_write(pp, MVNETA_TXQ_CMD,
+			(val << MVNETA_TXQ_DISABLE_OFFS));
+
+	/* Wait for all Tx activity to terminate. */
+	m_delay = 0;
+	do {
+		if (m_delay >= MVNETA_TX_DISABLE_TIMEOUT_MSEC) {
+			netdev_info(pp->dev,
+				"TIMEOUT for TX stopped tx_queue_cmd - 0x%08x\n",
+				val);
+			break;
+		}
+		mdelay(1);
+		m_delay++;
+
+		/* Check TX Command reg that all Txqs are stopped */
+		val = mvreg_read(pp, MVNETA_TXQ_CMD);
+
+	} while (val & 0xff);
+	tx_fifo_empty_mask |= MVNETA_TX_FIFO_EMPTY_MASK;
+	tx_in_prog_mask    |= MVNETA_TX_IN_PRGRS_MASK;
+
+	/* Double check to verify that TX FIFO is empty */
+	m_delay = 0;
+	while (1) {
+		do {
+			if (m_delay >= MVNETA_TX_FIFO_EMPTY_TIMEOUT) {
+				netdev_info(pp->dev,
+					    "TX FIFO empty timeout status=0x08%x, empty=%x, in_prog=%x",
+					    val, tx_fifo_empty_mask,
+					    tx_in_prog_mask);
+				break;
+			}
+			mdelay(1);
+			m_delay++;
+
+			val = mvreg_read(pp, MVNETA_PORT_STATUS);
+		} while (((val & tx_fifo_empty_mask) != tx_fifo_empty_mask)
+			 || ((val & tx_in_prog_mask) != 0));
+
+		if (m_delay >= MVNETA_TX_FIFO_EMPTY_TIMEOUT)
+			break;
+
+		val = mvreg_read(pp, MVNETA_PORT_STATUS);
+		if (((val & tx_fifo_empty_mask) == tx_fifo_empty_mask) &&
+		    ((val & tx_in_prog_mask) == 0))
+			break;
+		else
+			netdev_info(pp->dev, "TX FIFO Empty double check failed. %d msec status=0x%x, empty=0x%x, in_prog=0x%x\n",
+				    m_delay, val, tx_fifo_empty_mask,
+				    tx_in_prog_mask);
+	}
+
+	udelay(200);
+}
+
+/* Enable the port by setting the port enable bit of the MAC control register */
+static void mvneta_port_enable(struct mvneta_port *pp)
+{
+	u32 val;
+
+	/* Enable port */
+	val = mvreg_read(pp, MVNETA_GMAC_CTRL_0);
+	val |= MVNETA_GMAC0_PORT_ENABLE;
+	mvreg_write(pp, MVNETA_GMAC_CTRL_0, val);
+
+	/* If link is up, start RX and TX traffic */
+	if (mvreg_read(pp, MVNETA_GMAC_STATUS) & MVNETA_GMAC_LINK_UP_MASK)
+		mvneta_port_up(pp);
+}
+
+/* Disable the port and wait for about 200 usec before retuning */
+static void mvneta_port_disable(struct mvneta_port *pp)
+{
+	u32 val;
+
+	mvneta_port_down(pp);
+
+	/* Reset the Enable bit in the Serial Control Register */
+	val = mvreg_read(pp, MVNETA_GMAC_CTRL_0);
+	val &= ~(MVNETA_GMAC0_PORT_ENABLE);
+	mvreg_write(pp, MVNETA_GMAC_CTRL_0, val);
+
+	udelay(200);
+}
+
+/* Multicast tables methods */
+
+/* Set all entries in Unicast MAC Table; queue==-1 means reject all */
+static void mvneta_set_ucast_table(struct mvneta_port *pp, int queue)
+{
+	int offset;
+	u32 val;
+
+	if (queue == -1) {
+		val = 0;
+	} else {
+		val =	(((0x01 | (queue << 1)) << 0) |
+			((0x01 | (queue << 1)) << 8) |
+			((0x01 | (queue << 1)) << 16) |
+			((0x01 | (queue << 1)) << 24));
+	}
+
+	for (offset = 0; offset <= 0xc; offset += 4)
+		mvreg_write(pp, MVNETA_DA_FILT_UCAST_BASE + offset, val);
+}
+
+/* Set all entries in Special Multicast MAC Table; queue==-1 means reject all */
+static void mvneta_set_special_mcast_table(struct mvneta_port *pp, int queue)
+{
+	int offs;
+	u32 val;
+
+	if (queue == -1) {
+		val = 0;
+	} else {
+		val =	(((0x01 | (queue << 1)) << 0) |
+			((0x01 | (queue << 1)) << 8) |
+			((0x01 | (queue << 1)) << 16) |
+			((0x01 | (queue << 1)) << 24));
+	}
+
+	for (offs = 0; offs <= 0xfc; offs += 4)
+		mvreg_write(pp, (MVNETA_DA_FILT_SPEC_MCAST + offs), val);
+
+}
+
+/* Set all entries in Other Multicast MAC Table. queue==-1 means reject all */
+static void mvneta_set_other_mcast_table(struct mvneta_port *pp, int queue)
+{
+	int offset;
+	u32 val;
+
+	if (queue == -1) {
+		memset(pp->mcast_count, 0, sizeof(pp->mcast_count));
+		val = 0;
+	} else {
+		memset(pp->mcast_count, 1, sizeof(pp->mcast_count));
+		val = (((0x01 | (queue << 1)) << 0) |
+			  ((0x01 | (queue << 1)) << 8) |
+			  ((0x01 | (queue << 1)) << 16) |
+			  ((0x01 | (queue << 1)) << 24));
+	}
+
+	for (offset = 0; offset <= 0xfc; offset += 4)
+		mvreg_write(pp, (MVNETA_DA_FILT_OTH_MCAST + offset), val);
+}
+
+/* This method sets defaults to the NETA port:
+ *	Clears interrupt Cause and Mask registers.
+ *	Clears all MAC tables.
+ *	Sets defaults to all registers.
+ *	Resets RX and TX descriptor rings.
+ *	Resets PHY.
+ * This method can be called after mvneta_port_down() to return the port
+ *	settings to defaults.
+ */
+static void mvneta_defaults_set(struct mvneta_port *pp)
+{
+	int cpu;
+	int queue;
+	u32 val;
+
+	/* Clear all Cause registers */
+	mvreg_write(pp, MVNETA_INTR_NEW_CAUSE, 0);
+	mvreg_write(pp, MVNETA_INTR_OLD_CAUSE, 0);
+	mvreg_write(pp, MVNETA_INTR_MISC_CAUSE, 0);
+
+	/* Mask all interrupts */
+	mvreg_write(pp, MVNETA_INTR_NEW_MASK, 0);
+	mvreg_write(pp, MVNETA_INTR_OLD_MASK, 0);
+	mvreg_write(pp, MVNETA_INTR_MISC_MASK, 0);
+	mvreg_write(pp, MVNETA_INTR_ENABLE, 0);
+
+	/* Enable MBUS Retry bit16 */
+	mvreg_write(pp, MVNETA_MBUS_RETRY, 0x20);
+
+	/* Set CPU queue access map - all CPUs have access to all RX
+	   queues and to all TX queues */
+	for (cpu = 0; cpu < CONFIG_NR_CPUS; cpu++)
+		mvreg_write(pp, MVNETA_CPU_MAP(cpu),
+			    (MVNETA_CPU_RXQ_ACCESS_ALL_MASK |
+			     MVNETA_CPU_TXQ_ACCESS_ALL_MASK));
+
+	/* Reset RX and TX DMAs */
+	mvreg_write(pp, MVNETA_PORT_RX_RESET, MVNETA_PORT_RX_DMA_RESET_MASK);
+	mvreg_write(pp, MVNETA_PORT_TX_RESET, MVNETA_PORT_TX_DMA_RESET_MASK);
+
+	/* Disable Legacy WRR, Disable EJP, Release from reset */
+	mvreg_write(pp, MVNETA_TXQ_CMD_1, 0);
+	for (queue = 0; queue < mvneta_txq_number; queue++) {
+		mvreg_write(pp, MVETH_TXQ_TOKEN_COUNT_REG(queue), 0);
+		mvreg_write(pp, MVETH_TXQ_TOKEN_CFG_REG(queue), 0);
+	}
+
+	mvreg_write(pp, MVNETA_PORT_TX_RESET, 0);
+	mvreg_write(pp, MVNETA_PORT_RX_RESET, 0);
+
+	/* Set Port Acceleration Mode */
+	val = MVNETA_ACC_MODE_EXT;
+	mvreg_write(pp, MVNETA_ACC_MODE, val);
+
+	/* Update val of portCfg register accordingly with all RxQueue types */
+	val = MVNETA_PORT_CONFIG_VALUE(mvneta_rxq_def);
+	mvreg_write(pp, MVNETA_PORT_CONFIG, val);
+
+	val = 0;
+	mvreg_write(pp, MVNETA_PORT_CONFIG_EXTEND, val);
+	mvreg_write(pp, MVNETA_RX_MIN_FRAME_SIZE, 64);
+
+	/* Build PORT_SDMA_CONFIG_REG */
+	val = 0;
+
+	/* Default burst size */
+	val |= MVNETA_TX_BRST_SZ_MASK(MVNETA_SDMA_BRST_SIZE_16_64BIT_VALUE);
+	val |= MVNETA_RX_BRST_SZ_MASK(MVNETA_SDMA_BRST_SIZE_16_64BIT_VALUE);
+
+	val |= (MVNETA_RX_NO_DATA_SWAP | MVNETA_TX_NO_DATA_SWAP |
+		MVNETA_NO_DESC_SWAP);
+
+	/* Assign port SDMA configuration */
+	mvreg_write(pp, MVNETA_SDMA_CONFIG, val);
+
+	mvneta_set_ucast_table(pp, -1);
+	mvneta_set_special_mcast_table(pp, -1);
+	mvneta_set_other_mcast_table(pp, -1);
+
+	/* Set port interrupt enable register - default enable all */
+	mvreg_write(pp, MVNETA_INTR_ENABLE,
+		    (MVNETA_RXQ_INTR_ENABLE_ALL_MASK
+		     | MVNETA_TXQ_INTR_ENABLE_ALL_MASK));
+}
+
+
+/* Read the Link Up bit (LinkUp) in port MAC control register */
+static int mvneta_link_is_up(struct mvneta_port *pp)
+{
+	u32 val;
+	val = mvreg_read(pp, MVNETA_GMAC_STATUS);
+	if (val & MVNETA_GMAC_LINK_UP_MASK)
+		return 1;
+
+	return 0;
+}
+
+/* Get phy address */
+static int mvneta_phy_addr_get(struct mvneta_port *pp)
+{
+	unsigned int val;
+
+	val = mvreg_read(pp, MVNETA_PHY_ADDR);
+	val &= 0x1f;
+	return val;
+}
+
+/* Set phy address */
+static void mvneta_phy_addr_set(struct mvneta_port *pp, int phy_addr)
+{
+	unsigned int val;
+
+	val = mvreg_read(pp, MVNETA_PHY_ADDR);
+
+	val &= ~MVNETA_PHY_ADDR_MASK;
+	val |= phy_addr;
+
+	mvreg_write(pp, MVNETA_PHY_ADDR, val);
+
+	/* Enable PHY polling */
+	val = mvreg_read(pp, MVNETA_UNIT_CONTROL);
+
+	val |= MVNETA_PHY_POLLING_ENABLE_MASK;
+	mvreg_write(pp, MVNETA_UNIT_CONTROL, val);
+}
+
+
+/* Set max sizes for tx queues */
+static void mvneta_txq_max_tx_size_set(struct mvneta_port *pp, int max_tx_size)
+
+{
+	u32 val, size, mtu;
+	int queue;
+
+	mtu = max_tx_size * 8;
+	if (mtu > MVNETA_TX_MTU_MAX)
+		mtu = MVNETA_TX_MTU_MAX;
+
+	/* Set MTU */
+	val = mvreg_read(pp, MVNETA_TX_MTU);
+	val &= ~MVNETA_TX_MTU_MAX;
+	val |= mtu;
+	mvreg_write(pp, MVNETA_TX_MTU, val);
+
+	/* TX token size and all TXQs token size must be larger that MTU */
+	val = mvreg_read(pp, MVNETA_TX_TOKEN_SIZE);
+
+	size = val & MVNETA_TX_TOKEN_SIZE_MAX;
+	if (size < mtu) {
+		size = mtu;
+		val &= ~MVNETA_TX_TOKEN_SIZE_MAX;
+		val |= size;
+		mvreg_write(pp, MVNETA_TX_TOKEN_SIZE, val);
+	}
+
+	for (queue = 0; queue < mvneta_txq_number; queue++) {
+		val = mvreg_read(pp, MVNETA_TXQ_TOKEN_SIZE_REG(queue));
+
+		size = val & MVNETA_TXQ_TOKEN_SIZE_MAX;
+		if (size < mtu) {
+			size = mtu;
+			val &= ~MVNETA_TXQ_TOKEN_SIZE_MAX;
+			val |= size;
+			mvreg_write(pp, MVNETA_TXQ_TOKEN_SIZE_REG(queue), val);
+		}
+	}
+}
+
+/* Set unicast address */
+static int mvneta_set_ucast_addr(struct mvneta_port *pp, u8 last_nibble,
+				int queue)
+{
+	unsigned int unicast_reg;
+	unsigned int tbl_offset;
+	unsigned int reg_offset;
+
+	/* Locate the Unicast table entry */
+	last_nibble = (0xf & last_nibble);
+
+	/* offset from unicast tbl base */
+	tbl_offset = (last_nibble / 4) * 4;
+
+	/* offset within the above reg */
+	reg_offset = last_nibble % 4;
+
+	unicast_reg = mvreg_read(pp, (MVNETA_DA_FILT_UCAST_BASE + tbl_offset));
+
+	if (queue == -1) {
+		/* Clear accepts frame bit at specified unicast DA tbl entry */
+		unicast_reg &= ~(0xff << (8 * reg_offset));
+	} else {
+		unicast_reg &= ~(0xff << (8 * reg_offset));
+		unicast_reg |= ((0x01 | (queue << 1)) << (8 * reg_offset));
+	}
+
+	mvreg_write(pp, (MVNETA_DA_FILT_UCAST_BASE + tbl_offset), unicast_reg);
+	return 1;
+}
+
+/* Set mac address */
+static int mvneta_mac_addr_set(struct mvneta_port *pp, unsigned char *addr,
+			       int queue)
+{
+	unsigned int mac_h;
+	unsigned int mac_l;
+
+	if (queue >= 1) {
+		netdev_err(pp->dev, "RX queue #%d is out of range\n", queue);
+		return -EINVAL;
+	}
+
+	if (queue != -1) {
+		mac_l = (addr[4] << 8) | (addr[5]);
+		mac_h = (addr[0] << 24) | (addr[1] << 16) |
+			(addr[2] << 8) | (addr[3] << 0);
+
+		mvreg_write(pp, MVNETA_MAC_ADDR_LOW, mac_l);
+		mvreg_write(pp, MVNETA_MAC_ADDR_HIGH, mac_h);
+	}
+
+	/* Accept frames of this address */
+	mvneta_set_ucast_addr(pp, addr[5], queue);
+
+	return 0;
+}
+
+/* Mask interrupts */
+static void mvneta_interrupts_mask(void *priv)
+{
+	struct mvneta_port *pp = priv;
+
+	/* Mask all ethernet port interrupts */
+	mvreg_write(pp, MVNETA_INTR_NEW_MASK, 0);
+	mvreg_write(pp, MVNETA_INTR_OLD_MASK, 0);
+	mvreg_write(pp, MVNETA_INTR_MISC_MASK, 0);
+}
+
+/* Unmask interrupts */
+static void mvneta_interrupts_unmask(void *priv)
+{
+	struct mvneta_port *pp = priv;
+
+	mvreg_write(pp, MVNETA_INTR_MISC_MASK, MVNETA_CAUSE_LINK_CHANGE_MASK);
+	mvreg_write(pp, MVNETA_INTR_NEW_MASK,
+		    (MVNETA_ETH_MISC_SUM_INTR_MASK | MVNETA_RX_INTR_MASK));
+}
+
+/*
+ * Set the number of packets that will be received before
+ * RX interrupt will be generated by HW.
+ */
+static void mvneta_rx_pkts_coal_set(struct mvneta_port *pp,
+				    struct mvneta_rx_queue *rxq, u32 value)
+{
+	mvreg_write(pp, MVNETA_RXQ_THRESHOLD_REG(rxq->id),
+		    (value | MVNETA_RXQ_NON_OCCUPIED_MASK(0)));
+	rxq->pkts_coal = value;
+}
+
+/*
+ * Set the time delay in usec before
+ * RX interrupt will be generated by HW.
+ */
+static void mvneta_rx_time_coal_set(struct mvneta_port *pp,
+				    struct mvneta_rx_queue *rxq, u32 value)
+{
+	u32 val = (pp->clk / 1000000) * value;
+
+	mvreg_write(pp, MVNETA_RXQ_TIME_COAL_REG(rxq->id), val);
+	rxq->time_coal = value;
+}
+
+/* Set threshold for TX_DONE pkts coalescing */
+static void mvneta_tx_done_pkts_coal_set(struct mvneta_port *pp,
+					 struct mvneta_tx_queue *txq,
+					 u32 value)
+{
+	u32 val;
+
+	val = mvreg_read(pp, MVNETA_TXQ_SIZE_REG(txq->id));
+
+	val &= ~MVNETA_TXQ_SENT_TRESH_ALL_MASK;
+	val |= MVNETA_TXQ_SENT_TRESH_MASK(value);
+
+	mvreg_write(pp, MVNETA_TXQ_SIZE_REG(txq->id), val);
+
+	txq->done_pkts_coal = value;
+}
+
+
+
+/* Trigger cleanup timer in MVNETA_CLEANUP_TIMER_PERIOD msecs */
+static void mvneta_add_cleanup_timer(struct mvneta_port *pp)
+{
+	if (test_and_set_bit(MVNETA_F_CLEANUP_TIMER_BIT, &pp->flags) == 0) {
+		pp->cleanup_timer.expires = jiffies +
+			msecs_to_jiffies(MVNETA_CLEANUP_TIMER_PERIOD);
+		add_timer(&pp->cleanup_timer);
+	}
+}
+
+/* Trigger tx done timer in MVNETA_TX_DONE_TIMER_PERIOD msecs */
+static void mvneta_add_tx_done_timer(struct mvneta_port *pp)
+{
+	if (test_and_set_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags) == 0) {
+		pp->tx_done_timer.expires = jiffies +
+			msecs_to_jiffies(MVNETA_TX_DONE_TIMER_PERIOD);
+		add_timer(&pp->tx_done_timer);
+	}
+}
+
+/* Handle rx descriptor fill by setting buf_cookie and buf_phys_addr */
+static void mvneta_rx_desc_fill(struct mvneta_rx_desc *rx_desc,
+				u32 phys_addr, u32 cookie)
+{
+	rx_desc->buf_cookie = cookie;
+	rx_desc->buf_phys_addr = phys_addr;
+}
+
+/* Decrement sent descriptors counter */
+static void mvneta_txq_sent_desc_dec(struct mvneta_port *pp,
+				     struct mvneta_tx_queue *txq,
+				     int sent_desc)
+{
+	u32 val;
+
+	/* Only 255 TX descriptors can be updated at once */
+	while (sent_desc > 0xff) {
+		val = (0xff << MVNETA_TXQ_DEC_SENT_OFFS);
+		mvreg_write(pp, MVNETA_TXQ_UPDATE_REG(txq->id), val);
+		sent_desc = sent_desc - 0xff;
+	}
+
+	val = (sent_desc << MVNETA_TXQ_DEC_SENT_OFFS);
+	mvreg_write(pp, MVNETA_TXQ_UPDATE_REG(txq->id), val);
+}
+
+/* Get number of TX descriptors already sent by HW */
+static int mvneta_txq_sent_desc_num_get(struct mvneta_port *pp,
+					struct mvneta_tx_queue *txq)
+{
+	u32 val;
+	int sent_desc;
+
+	val = mvreg_read(pp, MVNETA_TXQ_STATUS_REG(txq->id));
+	sent_desc = (val & MVNETA_TXQ_SENT_DESC_MASK) >>
+		MVNETA_TXQ_SENT_DESC_OFFS;
+
+	return sent_desc;
+}
+
+/*
+ * Get number of sent descriptors and decrement counter.
+ *  The number of sent descriptors is returned.
+ */
+static int mvneta_txq_sent_desc_proc(struct mvneta_port *pp,
+				     struct mvneta_tx_queue *txq)
+{
+	int sent_desc;
+
+	/* Get number of sent descriptors */
+	sent_desc = mvneta_txq_sent_desc_num_get(pp, txq);
+
+	/* Decrement sent descriptors counter */
+	if (sent_desc)
+		mvneta_txq_sent_desc_dec(pp, txq, sent_desc);
+
+	return sent_desc;
+}
+
+/* Set TXQ descriptors fields relevant for CSUM calculation */
+static u32 mvneta_txq_desc_csum(int l3_offs, int l3_proto,
+				int ip_hdr_len, int l4_proto)
+{
+	u32 command;
+
+	/* Fields: L3_offset, IP_hdrlen, L3_type, G_IPv4_chk,
+	   G_L4_chk, L4_type; required only for checksum
+	   calculation */
+	command = l3_offs;
+	command |= (ip_hdr_len << MVNETA_TX_IP_HLEN_OFFS);
+
+	if (l3_proto == swab16(ETH_P_IP))
+		command |= MVNETA_TXD_IP_CSUM_MASK;
+	else
+		command |= MVNETA_TX_L3_IP6;
+
+	if (l4_proto == IPPROTO_TCP)
+		command |=  MVNETA_TX_L4_CSUM_FULL;
+	else if (l4_proto == IPPROTO_UDP)
+		command |= (MVNETA_TX_L4_UDP | MVNETA_TX_L4_CSUM_FULL);
+	else
+		command |= MVNETA_TX_L4_CSUM_NOT;
+
+	return command;
+}
+
+
+/* Display status (link, duplex, speed) of the port */
+void mvneta_link_status_print(struct mvneta_port *pp)
+{
+	struct mvneta_lnk_status link;
+	char *speedstr, *duplexstr;
+
+	mvneta_link_status(pp, &link);
+
+	if (link.linkup) {
+		if (link.speed == MVNETA_SPEED_1000)
+			speedstr = "1 Gbps";
+		else if (link.speed == MVNETA_SPEED_100)
+			speedstr = "100 Mbps";
+		else
+			speedstr = "10 Mbps";
+
+		if (link.duplex == MVNETA_DUPLEX_FULL)
+			duplexstr = "full";
+		else
+			duplexstr = "half";
+
+		netdev_info(pp->dev,
+			    "link up, %s duplex, speed %s\n",
+			    duplexstr, speedstr);
+	} else
+		netdev_info(pp->dev, "link down\n");
+}
+
+/* Display more error info */
+static void mvneta_rx_error(struct mvneta_port *pp,
+			    struct mvneta_rx_desc *rx_desc)
+{
+	u32 status = rx_desc->status;
+
+	if (pp->dev)
+		pp->dev->stats.rx_errors++;
+
+	if ((status & MVNETA_RXD_FIRST_LAST_DESC_MASK)
+	    != MVNETA_RXD_FIRST_LAST_DESC_MASK) {
+		netdev_err(pp->dev,
+			   "bad rx status %08x (buffer oversize), size=%d\n",
+			   rx_desc->status, rx_desc->data_size);
+		return;
+	}
+
+	switch (status & MVNETA_RXD_ERR_CODE_MASK) {
+	case MVNETA_RXD_ERR_CRC_MASK:
+		netdev_err(pp->dev, "bad rx status %08x (crc error), size=%d\n",
+			   status, rx_desc->data_size);
+		break;
+	case MVNETA_RXD_ERR_OVERRUN_MASK:
+		netdev_err(pp->dev, "bad rx status %08x (overrun error), size=%d\n",
+			   status, rx_desc->data_size);
+		break;
+	case MVNETA_RXD_ERR_LEN_MASK:
+		netdev_err(pp->dev, "bad rx status %08x (max frame length error), size=%d\n",
+			   status, rx_desc->data_size);
+		break;
+	case MVNETA_RXD_ERR_RESOURCE_MASK:
+		netdev_err(pp->dev, "bad rx status %08x (resource error), size=%d\n",
+			   status, rx_desc->data_size);
+		break;
+	}
+}
+
+/* Handle RX checksum offload */
+static void mvneta_rx_csum(struct mvneta_port *pp,
+			   struct mvneta_rx_desc *rx_desc,
+			   struct sk_buff *skb)
+{
+	if (((MVNETA_RX_L3_IS_IP4(rx_desc->status)) &&
+	     (rx_desc->status & MVNETA_RXD_L4_CSUM_OK_MASK))) {
+		skb->csum = 0;
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		return;
+	}
+
+	skb->ip_summed = CHECKSUM_NONE;
+}
+
+/* Return tx queue pointer (find last set bit) according to causeTxDone reg */
+static struct mvneta_tx_queue *mvneta_tx_done_policy(struct mvneta_port *pp,
+						     u32 cause)
+{
+	int queue;
+	queue = fls(cause) - 1;
+	if (queue < 0 || queue >= mvneta_txq_number)
+		return NULL;
+	return &pp->txqs[queue];
+}
+
+/* Free tx queue skbuffs */
+static void mvneta_txq_bufs_free(struct mvneta_port *pp,
+				 struct mvneta_tx_queue *txq, int num)
+{
+	struct sk_buff *skb;
+	int i;
+	struct mvneta_tx_desc *tx_desc;
+
+	for (i = 0; i < num; i++) {
+		skb = txq->tx_skb[txq->txq_get_index];
+		tx_desc = txq->descs + txq->txq_get_index;
+
+		mvneta_inc_get(txq);
+
+		if (!skb)
+			continue;
+		if (tx_desc) {
+			dma_unmap_single(pp->dev->dev.parent,
+					 tx_desc->buf_phys_addr,
+					 tx_desc->data_size,
+					 DMA_TO_DEVICE);
+			dev_kfree_skb_any(skb);
+		}
+	}
+}
+
+/* Handle end of transmission */
+static int mvneta_txq_done(struct mvneta_port *pp,
+			   struct mvneta_tx_queue *txq)
+{
+	int tx_done;
+
+	tx_done = mvneta_txq_sent_desc_proc(pp, txq);
+	if (tx_done == 0)
+		return tx_done;
+	mvneta_txq_bufs_free(pp, txq, tx_done);
+
+	txq->count -= tx_done;
+
+	return tx_done;
+}
+
+/* Refill processing */
+static int mvneta_rx_refill(struct mvneta_port *pp,
+			    struct mvneta_rx_desc *rx_desc)
+
+{
+	unsigned long phys_addr;
+	struct sk_buff *skb;
+
+	skb = netdev_alloc_skb(pp->dev, pp->pkt_size);
+	if (!skb) {
+		mvneta_add_cleanup_timer(pp);
+		return 1;
+	}
+
+	phys_addr = dma_map_single(pp->dev->dev.parent, skb->head,
+				   MVNETA_RX_BUF_SIZE(pp->pkt_size),
+				   DMA_FROM_DEVICE);
+
+	mvneta_rx_desc_fill(rx_desc, phys_addr, (u32)skb);
+
+	return 0;
+}
+
+/* Handle tx checksum */
+static u32 mvneta_skb_tx_csum(struct mvneta_port *pp, struct sk_buff *skb)
+{
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		int ip_hdr_len = 0;
+		u8 l4_proto;
+
+		if (skb->protocol == htons(ETH_P_IP)) {
+			struct iphdr *ip4h = ip_hdr(skb);
+
+			/* Calculate IPv4 checksum and L4 checksum */
+			ip_hdr_len = ip4h->ihl;
+			l4_proto = ip4h->protocol;
+		} else if (skb->protocol == htons(ETH_P_IPV6)) {
+			struct ipv6hdr *ip6h = ipv6_hdr(skb);
+
+			/* Read l4_protocol from one of IPv6 extra headers */
+			if (skb_network_header_len(skb) > 0)
+				ip_hdr_len = (skb_network_header_len(skb) >> 2);
+			l4_proto = ip6h->nexthdr;
+		} else
+			return MVNETA_TX_L4_CSUM_NOT;
+
+		return mvneta_txq_desc_csum(skb_network_offset(skb),
+				skb->protocol, ip_hdr_len, l4_proto);
+	}
+
+	return MVNETA_TX_L4_CSUM_NOT;
+}
+
+/*
+ * Return rx queue pointer (find last set bit) according to causeRxTx
+ * reg
+ */
+static struct mvneta_rx_queue *mvneta_rx_policy(struct mvneta_port *pp,
+						u32 cause)
+{
+	int queue;
+	queue = fls(cause >> 8) - 1;
+	if (queue < 0 || queue >= mvneta_rxq_number)
+		return NULL;
+	return &pp->rxqs[queue];
+}
+
+/* Drop packets received by the RXQ and free buffers */
+static void mvneta_rxq_drop_pkts(struct mvneta_port *pp,
+				 struct mvneta_rx_queue *rxq)
+{
+	struct mvneta_rx_desc *rx_desc;
+	struct sk_buff *skb;
+	int rx_done, i;
+
+	rx_done = mvneta_rxq_busy_desc_num_get(pp, rxq);
+	for (i = 0; i < rxq->size; i++) {
+		rx_desc = rxq->descs + i;
+
+		skb = (struct sk_buff *)rx_desc->buf_cookie;
+		dev_kfree_skb_any(skb);
+		dma_unmap_single(pp->dev->dev.parent, rx_desc->buf_phys_addr,
+				 rx_desc->data_size, DMA_FROM_DEVICE);
+	}
+	if (rx_done)
+		mvneta_rxq_desc_num_update(pp, rxq, rx_done, rx_done);
+}
+
+/* Main rx processing */
+static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
+		     struct mvneta_rx_queue *rxq)
+{
+	struct net_device *dev = pp->dev;
+	int rx_done, rx_filled, err;
+	struct mvneta_rx_desc *rx_desc;
+	u32 rx_status;
+	int rx_bytes;
+	struct sk_buff *skb;
+
+	/* Get number of received packets */
+	rx_done = mvneta_rxq_busy_desc_num_get(pp, rxq);
+
+	if (rx_todo > rx_done)
+		rx_todo = rx_done;
+
+	rx_done = 0;
+	rx_filled = 0;
+
+	/* Fairness NAPI loop */
+	while (rx_done < rx_todo) {
+		rx_desc = mvneta_rxq_next_desc_get(rxq);
+		prefetch(rx_desc);
+		rx_done++;
+		rx_filled++;
+		rx_status = rx_desc->status;
+		skb = (struct sk_buff *)rx_desc->buf_cookie;
+
+		if (((rx_status & MVNETA_RXD_FIRST_LAST_DESC_MASK)
+		     != MVNETA_RXD_FIRST_LAST_DESC_MASK)
+		    || (rx_status & MVNETA_RXD_ERR_SUMMARY_MASK)) {
+			mvneta_rx_error(pp, rx_desc);
+			mvneta_rx_desc_fill(rx_desc, rx_desc->buf_phys_addr,
+					    (u32)skb);
+			continue;
+		}
+
+		dma_unmap_single(pp->dev->dev.parent, rx_desc->buf_phys_addr,
+				 rx_desc->data_size, DMA_FROM_DEVICE);
+
+		rx_bytes = rx_desc->data_size -
+			(MVNETA_ETH_CRC_SIZE + MVNETA_MH_SIZE);
+		u64_stats_update_begin(&pp->rx_stats.syncp);
+		pp->rx_stats.packets++;
+		pp->rx_stats.bytes += rx_bytes;
+		u64_stats_update_end(&pp->rx_stats.syncp);
+
+		/* Linux processing */
+		skb->data += MVNETA_MH_SIZE;
+		skb->tail += (rx_bytes + MVNETA_MH_SIZE);
+		skb->len = rx_bytes;
+
+		skb->protocol = eth_type_trans(skb, dev);
+
+		mvneta_rx_csum(pp, rx_desc, skb);
+
+		if (dev->features & NETIF_F_GRO)
+			napi_gro_receive(&pp->napi, skb);
+		else
+			netif_receive_skb(skb);
+
+		/* Refill processing */
+		err = mvneta_rx_refill(pp, rx_desc);
+		if (err) {
+			netdev_err(pp->dev, "Linux processing - Can't refill\n");
+			rxq->missed++;
+			mvneta_add_cleanup_timer(pp);
+			rx_filled--;
+		}
+	}
+
+	/* Update rxq management counters */
+	mvneta_rxq_desc_num_update(pp, rxq, rx_done, rx_filled);
+
+	return rx_done;
+}
+
+/* Handle tx fragmentation processing */
+static void mvneta_tx_frag_process(struct mvneta_port *pp, struct sk_buff *skb,
+				   struct mvneta_tx_queue *txq)
+{
+	int i;
+	struct mvneta_tx_desc *tx_desc;
+	skb_frag_t *frag;
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		frag = &skb_shinfo(skb)->frags[i];
+
+		tx_desc = mvneta_txq_next_desc_get(txq);
+		tx_desc->data_size = frag->size;
+
+		tx_desc->buf_phys_addr =
+			dma_map_single(pp->dev->dev.parent,
+				       page_address(frag->page.p) +
+				       frag->page_offset, tx_desc->data_size,
+				       DMA_TO_DEVICE);
+
+		if (i == (skb_shinfo(skb)->nr_frags - 1)) {
+			/* Last descriptor */
+			tx_desc->command = (MVNETA_TXD_L_DESC_MASK |
+						MVNETA_TXD_Z_PAD_MASK);
+
+			txq->tx_skb[txq->txq_put_index] = skb;
+
+			mvneta_inc_put(txq);
+		} else {
+			/* Descriptor in the middle: Not First, Not Last */
+			tx_desc->command = 0;
+
+			txq->tx_skb[txq->txq_put_index] = NULL;
+			mvneta_inc_put(txq);
+		}
+	}
+}
+
+/* Main tx processing */
+static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+
+	int frags = 0;
+	int res = NETDEV_TX_OK;
+	u32 tx_cmd;
+	struct mvneta_tx_queue *txq = NULL;
+	struct mvneta_tx_desc *tx_desc;
+
+	if (!test_bit(MVNETA_F_STARTED_BIT, &pp->flags))
+		goto out;
+
+	txq = &pp->txqs[mvneta_txq_def];
+
+	frags = skb_shinfo(skb)->nr_frags + 1;
+
+	tx_desc = mvneta_tx_desc_get(pp, txq, frags);
+	if (tx_desc == NULL) {
+		frags = 0;
+		dev->stats.tx_dropped++;
+		res = NETDEV_TX_BUSY;
+		goto out;
+	}
+
+	tx_cmd = mvneta_skb_tx_csum(pp, skb);
+
+	tx_desc->data_size = skb_headlen(skb);
+
+	tx_desc->buf_phys_addr = dma_map_single(dev->dev.parent, skb->data,
+						tx_desc->data_size,
+						DMA_TO_DEVICE);
+
+	if (frags == 1) {
+		/* First and Last descriptor */
+		tx_cmd |= MVNETA_TXD_FLZ_DESC_MASK;
+		tx_desc->command = tx_cmd;
+		txq->tx_skb[txq->txq_put_index] = skb;
+		mvneta_inc_put(txq);
+	} else {
+		/* First but not Last */
+		tx_cmd |= MVNETA_TXD_F_DESC_MASK;
+		txq->tx_skb[txq->txq_put_index] = NULL;
+		mvneta_inc_put(txq);
+
+		tx_desc->command = tx_cmd;
+		/* Continue with other skb fragments */
+		mvneta_tx_frag_process(pp, skb, txq);
+	}
+
+	txq->count += frags;
+	mvneta_txq_pend_desc_add(pp, txq, frags);
+
+out:
+	if (frags > 0) {
+		u64_stats_update_begin(&pp->tx_stats.syncp);
+		pp->tx_stats.packets++;
+		pp->tx_stats.bytes += skb->len;
+		u64_stats_update_end(&pp->tx_stats.syncp);
+
+	} else {
+		dev->stats.tx_dropped++;
+		dev_kfree_skb_any(skb);
+	}
+
+	if (txq->count >= MVNETA_TXDONE_COAL_PKTS)
+		mvneta_txq_done(pp, txq);
+
+	/* If after calling mvneta_txq_done, count equals
+		frags, we need to set the timer */
+	if (txq->count == frags && frags > 0)
+		mvneta_add_tx_done_timer(pp);
+
+	return res;
+}
+
+
+/* Free tx resources, when resetting a port */
+static void mvneta_txq_done_force(struct mvneta_port *pp,
+				  struct mvneta_tx_queue *txq)
+
+{
+	int tx_done = txq->count;
+	mvneta_txq_bufs_free(pp, txq, tx_done);
+
+	/* reset txq */
+	txq->count = 0;
+	txq->txq_put_index = 0;
+	txq->txq_get_index = 0;
+}
+
+/* handle tx done - called from tx done timer callback */
+static u32 mvneta_tx_done_gbe(struct mvneta_port *pp, u32 cause_tx_done,
+			      int *tx_todo)
+{
+	struct mvneta_tx_queue *txq;
+	u32 tx_done = 0;
+	struct netdev_queue *nq;
+
+	*tx_todo = 0;
+	while (cause_tx_done != 0) {
+		txq = mvneta_tx_done_policy(pp, cause_tx_done);
+		if (!txq)
+			break;
+
+		nq = netdev_get_tx_queue(pp->dev, txq->id);
+
+		__netif_tx_lock(nq, smp_processor_id());
+		if (txq->count) {
+			tx_done += mvneta_txq_done(pp, txq);
+			*tx_todo += txq->count;
+		}
+
+		__netif_tx_unlock(nq);
+		cause_tx_done &= ~((1 << txq->id));
+	}
+
+	return tx_done;
+}
+
+/*
+ * Compute crc8 of the specified address, using a unique algorithm ,
+ * according to hw spec, different than generic crc8 algorithm
+ */
+static int mvneta_addr_crc(unsigned char *addr)
+{
+	int crc = 0;
+	int i;
+
+	for (i = 0; i < 6; i++) {
+		int j;
+
+		crc = (crc ^ addr[i]) << 8;
+		for (j = 7; j >= 0; j--) {
+			if (crc & (0x100 << j))
+				crc ^= 0x107 << j;
+		}
+	}
+
+	return crc;
+}
+
+/* This method controls the net device special MAC multicast support.
+ * The Special Multicast Table for MAC addresses supports MAC of the form
+ * 0x01-00-5E-00-00-XX (where XX is between 0x00 and 0xFF).
+ * The MAC DA[7:0] bits are used as a pointer to the Special Multicast
+ * Table entries in the DA-Filter table. This method set the Special
+ * Multicast Table appropriate entry.
+ */
+static void mvneta_set_special_mcast_addr(struct mvneta_port *pp,
+					  unsigned char last_byte,
+					  int queue)
+{
+	unsigned int smc_table_reg;
+	unsigned int tbl_offset;
+	unsigned int reg_offset;
+
+	/* Register offset from SMC table base    */
+	tbl_offset = (last_byte / 4);
+	/* Entry offset within the above reg */
+	reg_offset = last_byte % 4;
+
+	smc_table_reg = mvreg_read(pp, (MVNETA_DA_FILT_SPEC_MCAST
+					+ tbl_offset * 4));
+
+	if (queue == -1)
+		smc_table_reg &= ~(0xff << (8 * reg_offset));
+	else {
+		smc_table_reg &= ~(0xff << (8 * reg_offset));
+		smc_table_reg |= ((0x01 | (queue << 1)) << (8 * reg_offset));
+	}
+
+	mvreg_write(pp, MVNETA_DA_FILT_SPEC_MCAST + tbl_offset * 4,
+		    smc_table_reg);
+}
+
+/* This method controls the network device Other MAC multicast support.
+ * The Other Multicast Table is used for multicast of another type.
+ * A CRC-8 is used as an index to the Other Multicast Table entries
+ * in the DA-Filter table.
+ * The method gets the CRC-8 value from the calling routine and
+ * sets the Other Multicast Table appropriate entry according to the
+ * specified CRC-8 .
+ */
+static void mvneta_set_other_mcast_addr(struct mvneta_port *pp,
+					unsigned char crc8,
+					int queue)
+{
+	unsigned int omc_table_reg;
+	unsigned int tbl_offset;
+	unsigned int reg_offset;
+
+	tbl_offset = (crc8 / 4) * 4; /* Register offset from OMC table base */
+	reg_offset = crc8 % 4;	     /* Entry offset within the above reg   */
+
+	omc_table_reg = mvreg_read(pp, MVNETA_DA_FILT_OTH_MCAST + tbl_offset);
+
+	if (queue == -1) {
+		/* Clear accepts frame bit at specified Other DA table entry */
+		omc_table_reg &= ~(0xff << (8 * reg_offset));
+	} else {
+		omc_table_reg &= ~(0xff << (8 * reg_offset));
+		omc_table_reg |= ((0x01 | (queue << 1)) << (8 * reg_offset));
+	}
+
+	mvreg_write(pp, MVNETA_DA_FILT_OTH_MCAST + tbl_offset, omc_table_reg);
+}
+
+/* The network device supports multicast using two tables:
+ *    1) Special Multicast Table for MAC addresses of the form
+ *       0x01-00-5E-00-00-XX (where XX is between 0x00 and 0xFF).
+ *       The MAC DA[7:0] bits are used as a pointer to the Special Multicast
+ *       Table entries in the DA-Filter table.
+ *    2) Other Multicast Table for multicast of another type. A CRC-8 value
+ *       is used as an index to the Other Multicast Table entries in the
+ *       DA-Filter table.
+ */
+static int mvneta_mcast_addr_set(struct mvneta_port *pp, unsigned char *p_addr,
+				 int queue)
+{
+	unsigned char crc_result = 0;
+
+	if (memcmp(p_addr, "\x01\x00\x5e\x00\x00", 5) == 0) {
+		mvneta_set_special_mcast_addr(pp, p_addr[5], queue);
+		return 0;
+	}
+
+	crc_result = mvneta_addr_crc(p_addr);
+	if (queue == -1) {
+		if (pp->mcast_count[crc_result] == 0) {
+			netdev_info(pp->dev, "No valid Mcast for crc8=0x%02x\n",
+				    crc_result);
+			return -EINVAL;
+		}
+
+		pp->mcast_count[crc_result]--;
+		if (pp->mcast_count[crc_result] != 0) {
+			netdev_info(pp->dev,
+				    "After delete there are %d valid Mcast for crc8=0x%02x\n",
+				    pp->mcast_count[crc_result], crc_result);
+			return -EINVAL;
+		}
+	} else
+		pp->mcast_count[crc_result]++;
+
+	mvneta_set_other_mcast_addr(pp, crc_result, queue);
+
+	return 0;
+}
+
+/* Configure Fitering mode of Ethernet port */
+static void mvneta_rx_unicast_promisc_set(struct mvneta_port *pp,
+					  int is_promisc)
+{
+	u32 port_cfg_reg, val;
+
+	port_cfg_reg = mvreg_read(pp, MVNETA_PORT_CONFIG);
+
+	val = mvreg_read(pp, MVNETA_TYPE_PRIO);
+
+	/* Set / Clear UPM bit in port configuration register */
+	if (is_promisc) {
+		/* Accept all Unicast addresses */
+		port_cfg_reg |= MVNETA_UNI_PROMISC_MODE_MASK;
+		val |= MVNETA_FORCE_UNI_MASK;
+		mvreg_write(pp, MVNETA_MAC_ADDR_LOW, 0xffff);
+		mvreg_write(pp, MVNETA_MAC_ADDR_HIGH, 0xffffffff);
+	} else {
+		/* Reject all Unicast addresses */
+		port_cfg_reg &= ~MVNETA_UNI_PROMISC_MODE_MASK;
+		val &= ~MVNETA_FORCE_UNI_MASK;
+	}
+
+	mvreg_write(pp, MVNETA_PORT_CONFIG, port_cfg_reg);
+	mvreg_write(pp, MVNETA_TYPE_PRIO, val);
+}
+
+/* register unicast and multicast addresses */
+static void mvneta_set_rx_mode(struct net_device *dev)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+	struct netdev_hw_addr *ha;
+	int queue = 0;
+
+	if (dev->flags & IFF_PROMISC) {
+		/* Accept all: Multicast + Unicast */
+		mvneta_rx_unicast_promisc_set(pp, 1);
+		mvneta_set_ucast_table(pp, queue);
+		mvneta_set_special_mcast_table(pp, queue);
+		mvneta_set_other_mcast_table(pp, queue);
+	} else {
+		/* Accept single Unicast */
+		mvneta_rx_unicast_promisc_set(pp, 0);
+		mvneta_set_ucast_table(pp, -1);
+		if ((mvneta_mac_addr_set(pp, dev->dev_addr, queue)) != 0)
+			netdev_err(dev, "mvneta_mac_addr_set failed\n");
+
+		if (dev->flags & IFF_ALLMULTI) {
+			/* Accept all multicast */
+			mvneta_set_special_mcast_table(pp, queue);
+			mvneta_set_other_mcast_table(pp, queue);
+		} else {
+			/* Accept only initialized multicast */
+			mvneta_set_special_mcast_table(pp, -1);
+			mvneta_set_other_mcast_table(pp, -1);
+
+			if (!netdev_mc_empty(dev)) {
+				netdev_for_each_mc_addr(ha, dev) {
+					mvneta_mcast_addr_set(pp, ha->addr,
+							      queue);
+				}
+			}
+		}
+	}
+}
+
+/* Interrupt handling - the callback for request_irq() */
+static irqreturn_t mvneta_isr(int irq, void *dev_id)
+{
+	struct mvneta_port *pp = (struct mvneta_port *)dev_id;
+
+	/* Mask all interrupts */
+	mvreg_write(pp, MVNETA_INTR_NEW_MASK, 0);
+
+	/* Verify that the device not already on the polling list */
+	if (napi_schedule_prep(&pp->napi))
+		__napi_schedule(&pp->napi);
+
+	return IRQ_HANDLED;
+}
+
+/* Handle link event */
+static void mvneta_link_event(struct mvneta_port *pp)
+{
+	struct net_device *dev = pp->dev;
+
+	/* Check Link status on ethernet port */
+
+	if (mvneta_link_is_up(pp)) {
+		mvneta_port_up(pp);
+		set_bit(MVNETA_F_LINK_UP_BIT, &pp->flags);
+
+		if (dev) {
+			netif_carrier_on(dev);
+			netif_tx_wake_all_queues(dev);
+		}
+	} else {
+		if (dev) {
+			netif_carrier_off(dev);
+			netif_tx_stop_all_queues(dev);
+		}
+		mvneta_port_down(pp);
+		clear_bit(MVNETA_F_LINK_UP_BIT, &pp->flags);
+	}
+
+	mvneta_link_status_print(pp);
+}
+
+/* NAPI handler
+ * Bits 0 - 7 of the causeRxTx register indicate that are transmitted
+ * packets on the corresponding TXQ (Bit 0 is for TX queue 1).
+ * Bits 8 -15 of the cause Rx Tx register indicate that are received
+ * packets on the corresponding RXQ (Bit 8 is for RX queue 0).
+ * Each CPU has its own causeRxTx register
+ */
+static int mvneta_poll(struct napi_struct *napi, int budget)
+{
+	int rx_done = 0;
+	u32 cause_rx_tx;
+	unsigned long flags;
+	u32 cause_misc;
+	struct mvneta_port *pp = netdev_priv(napi->dev);
+
+	if (!test_bit(MVNETA_F_STARTED_BIT, &pp->flags)) {
+		napi_complete(napi);
+		return rx_done;
+	}
+
+	/* Read cause register */
+	cause_rx_tx = mvreg_read(pp, MVNETA_INTR_NEW_CAUSE) &
+		(MVNETA_ETH_MISC_SUM_INTR_MASK | MVNETA_RX_INTR_MASK);
+	if (cause_rx_tx & MVNETA_ETH_MISC_SUM_INTR_MASK) {
+		/* Process MISC events - Link, etc */
+		cause_rx_tx &= ~MVNETA_ETH_MISC_SUM_INTR_MASK;
+		cause_misc = mvreg_read(pp, MVNETA_INTR_MISC_CAUSE);
+
+		if (cause_misc & MVNETA_CAUSE_LINK_CHANGE_MASK)
+			mvneta_link_event(pp);
+
+		mvreg_write(pp, MVNETA_INTR_MISC_CAUSE, 0);
+	}
+	/* TBD: For the case where the last mvneta_poll did not process
+	   all RX packets */
+	cause_rx_tx |= pp->cause_rx_tx[smp_processor_id()];
+	if (mvneta_rxq_number > 1) {
+		while ((cause_rx_tx != 0) && (budget > 0)) {
+			int count;
+			struct mvneta_rx_queue *rxq;
+			/* get rx queue number from cause_rx_tx */
+			rxq = mvneta_rx_policy(pp, cause_rx_tx);
+			if (!rxq)
+				break;
+			/* process the packet in that rx queue */
+			count = mvneta_rx(pp, budget, rxq);
+			rx_done += count;
+			budget -= count;
+			if (budget > 0) {
+				/* set off the rx bit of the corresponding bit
+				  in the cause rx tx register, so that next
+				  iteration will find the next rx queue where
+				  packets are received on */
+				cause_rx_tx &= ~((1 << rxq->id) << 8);
+			}
+		}
+	} else {
+		rx_done = mvneta_rx(pp, budget, &pp->rxqs[mvneta_rxq_def]);
+		budget -= rx_done;
+	}
+
+	if (budget > 0) {
+		cause_rx_tx = 0;
+		napi_complete(napi);
+		local_irq_save(flags);
+		mvreg_write(pp, MVNETA_INTR_NEW_MASK,
+			    (MVNETA_ETH_MISC_SUM_INTR_MASK |
+			     MVNETA_RX_INTR_MASK));
+		local_irq_restore(flags);
+	}
+
+	pp->cause_rx_tx[smp_processor_id()] = cause_rx_tx;
+	return rx_done;
+}
+
+/* tx done timer callback */
+static void mvneta_tx_done_timer_callback(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct mvneta_port *pp = netdev_priv(dev);
+	int tx_done = 0, tx_todo = 0;
+
+	if (!test_bit(MVNETA_F_STARTED_BIT, &pp->flags))
+		return;
+
+	clear_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags);
+
+	tx_done = mvneta_tx_done_gbe(pp,
+				     (((1 << mvneta_txq_number) - 1) &
+				      MVNETA_CAUSE_TXQ_SENT_DESC_ALL_MASK),
+				     &tx_todo);
+	if (tx_todo > 0)
+		mvneta_add_tx_done_timer(pp);
+}
+
+/* cleanup timer callback */
+static void mvneta_cleanup_timer_callback(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct mvneta_port *pp = netdev_priv(dev);
+
+	if (!test_bit(MVNETA_F_STARTED_BIT, &pp->flags))
+		return;
+
+	clear_bit(MVNETA_F_CLEANUP_TIMER_BIT, &pp->flags);
+}
+
+
+/* Handle rxq fill: allocates rxq skbs; called when initializing a port */
+static int mvneta_rxq_fill(struct mvneta_port *pp, struct mvneta_rx_queue *rxq,
+			   int num)
+{
+	int i;
+	struct sk_buff *skb;
+	struct mvneta_rx_desc *rx_desc;
+	unsigned long phys_addr;
+	struct net_device *dev = pp->dev;
+
+	for (i = 0; i < num; i++) {
+		skb = dev_alloc_skb(pp->pkt_size);
+		if (!skb) {
+			netdev_err(pp->dev, "%s:rxq %d, %d of %d buffs filled\n",
+				   __func__, rxq->id, i, num);
+			break;
+		}
+
+		rx_desc = rxq->descs + i;
+		memset(rx_desc, 0, sizeof(struct mvneta_rx_desc));
+		phys_addr = dma_map_single(dev->dev.parent, skb->head,
+					   MVNETA_RX_BUF_SIZE(pp->pkt_size),
+					   DMA_FROM_DEVICE);
+		mvneta_rx_desc_fill(rx_desc, phys_addr, (u32)skb);
+	}
+
+	/* add this num of RX descriptors as non occupied (ready to get pkts) */
+	mvneta_rxq_non_occup_desc_add(pp, rxq, i);
+
+	return i;
+}
+
+/* Free all packets pending transmit from all TXQs and reset TX port */
+static int mvneta_tx_reset(struct mvneta_port *pp)
+{
+	int queue;
+
+	if (pp->flags & MVNETA_F_STARTED) {
+		netdev_err(pp->dev, "Port must be stopped before\n");
+		return -EINVAL;
+	}
+
+	/* free the skb's in the hal tx ring */
+	for (queue = 0; queue < mvneta_txq_number; queue++) {
+		struct mvneta_tx_queue *txq = &pp->txqs[queue];
+		mvneta_txq_done_force(pp, txq);
+	}
+
+	mvreg_write(pp, MVNETA_PORT_TX_RESET, MVNETA_PORT_TX_DMA_RESET_MASK);
+	mvreg_write(pp, MVNETA_PORT_TX_RESET, 0);
+
+	return 0;
+}
+
+/* Rx/Tx queue initialization/cleanup methods */
+
+/* Create a specified RX queue */
+static int mvneta_rxq_init(struct mvneta_port *pp,
+			   struct mvneta_rx_queue *rxq)
+
+{
+	rxq->size = pp->rx_ring_size;
+
+	/* Allocate DMA descriptors array */
+	rxq->descs_orig = dma_alloc_coherent(pp->dev->dev.parent,
+					     MVNETA_RX_TOTAL_DESCS_SIZE(rxq),
+					     &rxq->descs_phys_orig,
+					     GFP_KERNEL);
+	if (rxq->descs_orig == NULL) {
+		netdev_err(pp->dev, "rxQ=%d: Can't allocate %d bytes for %d RX descr\n",
+			   rxq->id, MVNETA_RX_TOTAL_DESCS_SIZE(rxq), rxq->size);
+		return -ENOMEM;
+	}
+
+	/* Make sure descriptor address is cache line size aligned  */
+	rxq->descs = PTR_ALIGN(rxq->descs_orig, MVNETA_CPU_D_CACHE_LINE_SIZE);
+	rxq->descs_phys = ALIGN(rxq->descs_phys_orig,
+				MVNETA_CPU_D_CACHE_LINE_SIZE);
+
+	rxq->last_desc = rxq->size - 1;
+
+	/* Set Rx descriptors queue starting address */
+	mvreg_write(pp, MVNETA_RXQ_BASE_ADDR_REG(rxq->id), rxq->descs_phys);
+	mvreg_write(pp, MVNETA_RXQ_SIZE_REG(rxq->id), rxq->size);
+
+	/* Set Offset */
+	mvneta_rxq_offset_set(pp, rxq, NET_SKB_PAD);
+
+	/* Set coalescing pkts and time */
+	mvneta_rx_pkts_coal_set(pp, rxq, rxq->pkts_coal);
+	mvneta_rx_time_coal_set(pp, rxq, rxq->time_coal);
+
+	/* Fill RXQ with buffers from RX pool */
+	mvneta_rxq_buf_size_set(pp, rxq, MVNETA_RX_BUF_SIZE(pp->pkt_size));
+	mvneta_rxq_bm_disable(pp, rxq);
+	mvneta_rxq_fill(pp, rxq, rxq->size);
+
+	return 0;
+}
+
+/* Cleanup Rx queue */
+static void mvneta_rxq_deinit(struct mvneta_port *pp,
+			      struct mvneta_rx_queue *rxq)
+{
+	mvneta_rxq_drop_pkts(pp, rxq);
+
+	if (rxq->descs_orig)
+		dma_free_coherent(pp->dev->dev.parent,
+				  MVNETA_RX_TOTAL_DESCS_SIZE(rxq),
+				  rxq->descs_orig,
+				  rxq->descs_phys_orig);
+}
+
+/* Create and initialize a tx queue */
+static int mvneta_txq_init(struct mvneta_port *pp,
+			   struct mvneta_tx_queue *txq)
+{
+	txq->size = pp->tx_ring_size;
+
+	/* Allocate DMA descriptors array */
+	txq->descs_orig = dma_alloc_coherent(pp->dev->dev.parent,
+					     MVNETA_TX_TOTAL_DESCS_SIZE(txq),
+					     &txq->descs_phys_orig,
+					     GFP_KERNEL);
+	if (txq->descs_orig == NULL) {
+		netdev_err(pp->dev, "txQ=%d: Can't allocate %d bytes for %d TX descr\n",
+			   txq->id, MVNETA_TX_TOTAL_DESCS_SIZE(txq), txq->size);
+		return -ENOMEM;
+	}
+
+	/* Make sure descriptor address is cache line size aligned  */
+	txq->descs = PTR_ALIGN(txq->descs_orig, MVNETA_CPU_D_CACHE_LINE_SIZE);
+	txq->descs_phys = ALIGN(txq->descs_phys_orig,
+				MVNETA_CPU_D_CACHE_LINE_SIZE);
+
+	txq->last_desc = txq->size - 1;
+
+	txq->tx_skb = kmalloc(txq->size * sizeof(struct sk_buff), GFP_KERNEL);
+	if (txq->tx_skb == NULL) {
+		dma_free_coherent(pp->dev->dev.parent,
+				  MVNETA_TX_TOTAL_DESCS_SIZE(txq),
+				  txq->descs_orig,
+				  txq->descs_phys_orig);
+		return -ENOMEM;
+	}
+
+	/* Set maximum bandwidth for enabled TXQs */
+	mvreg_write(pp, MVETH_TXQ_TOKEN_CFG_REG(txq->id), 0x03ffffff);
+	mvreg_write(pp, MVETH_TXQ_TOKEN_COUNT_REG(txq->id), 0x3fffffff);
+
+	/* Set Tx descriptors queue starting address */
+	mvreg_write(pp, MVNETA_TXQ_BASE_ADDR_REG(txq->id), txq->descs_phys);
+	mvreg_write(pp, MVNETA_TXQ_SIZE_REG(txq->id), txq->size);
+
+	mvneta_tx_done_pkts_coal_set(pp, txq, txq->done_pkts_coal);
+
+	return 0;
+}
+
+/* Free resources allocated by mvneta_txq_init() */
+static void mvneta_txq_deinit(struct mvneta_port *pp,
+			      struct mvneta_tx_queue *txq)
+{
+	kfree(txq->tx_skb);
+
+	if (txq->descs_orig)
+		dma_free_coherent(pp->dev->dev.parent,
+				  MVNETA_TX_TOTAL_DESCS_SIZE(txq),
+				  txq->descs_orig,
+				  txq->descs_phys_orig);
+
+	txq->descs = NULL;
+	txq->descs_orig = NULL;
+	txq->descs_phys = 0;
+	txq->descs_phys_orig = 0;
+
+	/* Set minimum bandwidth for disabled TXQs */
+	mvreg_write(pp, MVETH_TXQ_TOKEN_CFG_REG(txq->id), 0);
+	mvreg_write(pp, MVETH_TXQ_TOKEN_COUNT_REG(txq->id), 0);
+
+	/* Set Tx descriptors queue starting address and size */
+	mvreg_write(pp, MVNETA_TXQ_BASE_ADDR_REG(txq->id), 0);
+	mvreg_write(pp, MVNETA_TXQ_SIZE_REG(txq->id), 0);
+}
+
+/* Cleanup all Tx queues */
+static void mvneta_cleanup_txqs(struct mvneta_port *pp)
+{
+	int queue;
+	for (queue = 0; queue < mvneta_txq_number; queue++)
+		mvneta_txq_deinit(pp, &pp->txqs[queue]);
+}
+
+/* Cleanup all Rx queues */
+static void mvneta_cleanup_rxqs(struct mvneta_port *pp)
+{
+	int queue;
+	for (queue = 0; queue < mvneta_rxq_number; queue++)
+		mvneta_rxq_deinit(pp, &pp->rxqs[queue]);
+}
+
+/* Init all Rx queues */
+static int mvneta_setup_rxqs(struct mvneta_port *pp)
+{
+	int queue, err;
+
+	for (queue = 0; queue < mvneta_rxq_number; queue++) {
+		err = mvneta_rxq_init(pp, &pp->rxqs[queue]);
+		if (err) {
+			netdev_err(pp->dev,
+				   "%s: can't create RxQ rxq=%d,desc=%d\n",
+				   __func__, queue, pp->rxqs[queue].size);
+			mvneta_cleanup_rxqs(pp);
+			return -ENODEV;
+		}
+	}
+
+	return 0;
+}
+
+/* Init all tx queues */
+static int mvneta_setup_txqs(struct mvneta_port *pp)
+{
+	int queue, err;
+
+	for (queue = 0; queue < mvneta_txq_number; queue++) {
+		err = mvneta_txq_init(pp, &pp->txqs[queue]);
+		if (err) {
+			netdev_err(pp->dev,
+				   "%s: can't create TxQ txq=%d,desc=%d\n",
+				   __func__, queue, pp->txqs[queue].size);
+			mvneta_cleanup_txqs(pp);
+			return err;
+		}
+	}
+
+	return 0;
+}
+
+/* Fill rx buffers, start Rx/Tx activity, set coalesing,
+*  clear and unmask interrupt bits
+*/
+static int mvneta_start_internals(struct mvneta_port *pp, int mtu)
+{
+	int err = 0;
+
+	pp->pkt_size = MVNETA_RX_PKT_SIZE(mtu);
+	if (test_bit(MVNETA_F_STARTED_BIT, &pp->flags))
+		return -EINVAL;
+
+	if (mvneta_max_rx_size_set(pp, MVNETA_RX_PKT_SIZE(mtu))) {
+		netdev_err(pp->dev,
+			   "%s: can't set maxRxSize=%d mtu=%d\n",
+			   __func__, MVNETA_RX_PKT_SIZE(mtu), mtu);
+		return -EINVAL;
+	}
+
+	err = mvneta_setup_rxqs(pp);
+	if (unlikely(err))
+		return err;
+
+	err = mvneta_setup_txqs(pp);
+	if (unlikely(err)) {
+		mvneta_cleanup_rxqs(pp);
+		return err;
+	}
+
+	mvneta_txq_max_tx_size_set(pp, MVNETA_RX_PKT_SIZE(mtu));
+
+	/* start the Rx/Tx activity */
+	mvneta_port_enable(pp);
+
+	set_bit(MVNETA_F_LINK_UP_BIT, &pp->flags);
+	set_bit(MVNETA_F_STARTED_BIT, &pp->flags);
+
+	return 0;
+}
+
+/* Stop port Rx/Tx activity, free skb's from Rx/Tx rings */
+static int mvneta_stop_internals(struct mvneta_port *pp)
+{
+	clear_bit(MVNETA_F_STARTED_BIT, &pp->flags);
+
+	/* Stop the port activity */
+	mvneta_port_disable(pp);
+
+	/* Clear all ethernet port interrupts */
+	mvreg_write(pp, MVNETA_INTR_MISC_CAUSE, 0);
+	mvreg_write(pp, MVNETA_INTR_OLD_CAUSE, 0);
+
+	/* Mask all interrupts */
+	mvneta_interrupts_mask(pp);
+	smp_call_function_many(cpu_online_mask, mvneta_interrupts_mask,
+			       pp, 1);
+
+	/* Reset TX port here. */
+	mvneta_tx_reset(pp);
+
+	mvneta_cleanup_rxqs(pp);
+	mvneta_cleanup_txqs(pp);
+
+	return 0;
+
+}
+
+/* Start the port, connect to port interrupt line, unmask interrupts  */
+static int mvneta_start(struct net_device *dev)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+
+	/* In default link is down */
+	netif_carrier_off(dev);
+	netif_tx_stop_all_queues(dev);
+
+	/* Fill rx buffers, start Rx/Tx activity, set coalescing */
+	if (mvneta_start_internals(pp, dev->mtu) != 0) {
+		netdev_err(dev, "start internals failed\n");
+		return -ENODEV;
+	}
+
+	/* Enable polling on the port, must be used after netif_poll_disable */
+	napi_enable(&pp->napi);
+
+	if (pp->flags & MVNETA_F_LINK_UP) {
+		netif_carrier_on(dev);
+		netif_tx_wake_all_queues(dev);
+	} else {
+		netdev_info(dev, "%s: NOT MVNETA_F_LINK_UP\n", __func__);
+	}
+
+	/* Connect to port interrupt line */
+	if (request_irq(dev->irq, mvneta_isr, (IRQF_DISABLED), "mv_eth", pp)) {
+		netdev_err(dev, "cannot request irq %d\n", dev->irq);
+		napi_disable(&pp->napi);
+		goto error;
+	}
+
+	/* Unmask interrupts */
+	mvneta_interrupts_unmask(pp);
+	smp_call_function_many(cpu_online_mask,
+			       mvneta_interrupts_unmask,
+			       pp, 1);
+
+	netdev_info(dev, "started\n");
+	return 0;
+
+error:
+	netdev_err(dev, "start failed\n");
+	mvneta_cleanup_rxqs(pp);
+	mvneta_cleanup_txqs(pp);
+
+	return -ENODEV;
+}
+
+/* Stop the port, free port interrupt line */
+static int mvneta_stop(struct net_device *dev)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+
+	netif_tx_disable(dev);
+	napi_disable(&pp->napi);
+
+	/* Stop upper layer */
+	netif_carrier_off(dev);
+
+	/* Stop tx/rx activity, mask all interrupts, release skb in rings */
+	mvneta_stop_internals(pp);
+
+	del_timer(&pp->tx_done_timer);
+	clear_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags);
+	del_timer(&pp->cleanup_timer);
+	clear_bit(MVNETA_F_CLEANUP_TIMER_BIT, &pp->flags);
+
+	if (dev->irq != 0)
+		free_irq(dev->irq, pp);
+
+	netdev_info(dev, "stopped\n");
+
+	return 0;
+}
+
+
+/* tx timeout callback - display a message and stop/start the network device */
+static void mvneta_tx_timeout(struct net_device *dev)
+{
+	netdev_info(dev, "tx timeout\n");
+	if (netif_running(dev)) {
+		mvneta_stop(dev);
+		mvneta_start(dev);
+	}
+
+}
+
+/* Return positive if MTU is valid */
+static int mvneta_check_mtu_valid(struct net_device *dev, int mtu)
+{
+	if (mtu < 68) {
+		netdev_err(dev, "cannot change mtu to less than 68\n");
+		return -EINVAL;
+	}
+
+	if (mtu > 9676 /* 9700 - 20 and rounding to 8 */) {
+		netdev_info(dev, "Illegal MTU value %d, round to 9676", mtu);
+		mtu = 9676;
+	}
+
+	if (!IS_ALIGNED(MVNETA_RX_PKT_SIZE(mtu), 8)) {
+		netdev_info(dev, "Illegal MTU value %d, rounding to %d",
+			mtu, ALIGN(MVNETA_RX_PKT_SIZE(mtu), 8));
+		mtu = ALIGN(MVNETA_RX_PKT_SIZE(mtu), 8);
+	}
+
+	return mtu;
+}
+
+/* Change the device mtu */
+static int mvneta_change_mtu(struct net_device *dev, int mtu)
+{
+	int old_mtu = dev->mtu;
+
+	mtu = mvneta_check_mtu_valid(dev, mtu);
+	if (mtu < 0)
+		return -EINVAL;
+
+	dev->mtu = mtu;
+
+	if (!netif_running(dev)) {
+		netdev_info(dev, "change mtu %d (buffer-size %d) to %d (buffer-size %d)\n",
+			old_mtu, MVNETA_RX_PKT_SIZE(old_mtu),
+			dev->mtu, MVNETA_RX_PKT_SIZE(dev->mtu));
+		return 0;
+	}
+
+	if (mvneta_stop(dev)) {
+		netdev_err(dev, "stop interface failed\n");
+		goto error;
+	}
+
+	if (mvneta_start(dev)) {
+		netdev_err(dev, "start interface failed\n");
+		goto error;
+	}
+
+	netdev_info(dev, "change mtu %d (buffer-size %d) to %d (buffer-size %d)\n",
+		old_mtu, MVNETA_RX_PKT_SIZE(old_mtu),
+		dev->mtu, MVNETA_RX_PKT_SIZE(dev->mtu));
+
+	return 0;
+
+error:
+	netdev_info(dev, "change mtu failed\n");
+	return -EINVAL;
+}
+
+/* Handle setting mac address (low level) */
+static int mvneta_set_mac_addr_internals(struct net_device *dev, void *addr)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+	u8 *mac = addr + 2;
+	int i;
+
+	/* Remove previous address table entry */
+	if (mvneta_mac_addr_set(pp, dev->dev_addr, -1) != 0) {
+		netdev_err(dev, "mvneta_mac_addr_set failed\n");
+		return -EINVAL;
+	}
+
+	/* Set new addr in hw */
+	if (mvneta_mac_addr_set(pp, mac, mvneta_rxq_def) != 0) {
+		netdev_err(dev, "mvneta_mac_addr_set failed\n");
+		return -EINVAL;
+	}
+
+	/* Set addr in the device */
+	for (i = 0; i < MVNETA_MAC_ADDR_SIZE; i++)
+		dev->dev_addr[i] = mac[i];
+
+	netdev_info(dev, "mac address changed\n");
+
+	return 0;
+}
+
+/* Handle setting mac address */
+static int mvneta_set_mac_addr(struct net_device *dev, void *addr)
+{
+	if (!netif_running(dev)) {
+		if (mvneta_set_mac_addr_internals(dev, addr) == -1)
+			goto error;
+		return 0;
+	}
+
+	if (mvneta_stop(dev)) {
+		netdev_err(dev, "stop interface failed\n");
+		goto error;
+	}
+
+	if (mvneta_set_mac_addr_internals(dev, addr) == -1)
+		goto error;
+
+	if (mvneta_start(dev)) {
+		netdev_err(dev, "start interface failed\n");
+		goto error;
+	}
+
+	return 0;
+
+error:
+	netdev_err(dev, "set mac addr failed\n");
+	return -EINVAL;
+}
+
+/*
+ * Called when a network interface is made active.
+ * Returns 0 on success, -EINVAL or =ENODEV on failure
+ * mvneta_open() is called when a network interface is made
+ * active by the system (IFF_UP). We set the mac address and
+ * invoke mvneta_start() to start the device.
+ */
+static int mvneta_open(struct net_device *dev)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+	int queue = mvneta_rxq_def;
+
+	if (mvneta_mac_addr_set(pp, dev->dev_addr, queue) != 0) {
+		netdev_err(dev, "mvneta_mac_addr_set failed\n");
+		return -EINVAL;
+	}
+
+	if (mvneta_start(dev)) {
+		netdev_err(dev, "start interface failed\n");
+		return -ENODEV;
+	}
+
+	return 0;
+}
+
+/* Ethtool methods */
+
+/* Get settings (phy address, speed) for ethtools */
+int mvneta_ethtool_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+	struct mvneta_lnk_status status;
+
+	mvneta_link_status(pp, &status);
+
+	cmd->phy_address = mvneta_phy_addr_get(pp);
+
+	switch (status.speed) {
+	case MVNETA_SPEED_1000:
+		ethtool_cmd_speed_set(cmd, SPEED_1000);
+		break;
+	case MVNETA_SPEED_100:
+		ethtool_cmd_speed_set(cmd, SPEED_100);
+		break;
+	case MVNETA_SPEED_10:
+		ethtool_cmd_speed_set(cmd, SPEED_10);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/* Set interrupt coalescing for ethtools */
+static int mvneta_ethtool_set_coalesce(struct net_device *dev,
+				       struct ethtool_coalesce *c)
+{
+	int queue;
+	struct mvneta_port *pp = netdev_priv(dev);
+
+	for (queue = 0; queue < mvneta_rxq_number; queue++) {
+		struct mvneta_rx_queue *rxq = &pp->rxqs[queue];
+
+		rxq->time_coal = c->rx_coalesce_usecs;
+		rxq->pkts_coal = c->rx_max_coalesced_frames;
+		mvneta_rx_pkts_coal_set(pp, rxq, rxq->pkts_coal);
+		mvneta_rx_time_coal_set(pp, rxq, rxq->time_coal);
+	}
+
+	for (queue = 0; queue < mvneta_txq_number; queue++) {
+		struct mvneta_tx_queue *txq = &pp->txqs[queue];
+
+		txq->done_pkts_coal = c->tx_max_coalesced_frames;
+		mvneta_tx_done_pkts_coal_set(pp, txq, txq->done_pkts_coal);
+	}
+
+	return 0;
+}
+
+/* get coalescing for ethtools */
+static int mvneta_ethtool_get_coalesce(struct net_device *dev,
+			       struct ethtool_coalesce *c)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+
+	c->rx_coalesce_usecs        = pp->rxqs[0].time_coal;
+	c->rx_max_coalesced_frames  = pp->rxqs[0].pkts_coal;
+
+	c->tx_max_coalesced_frames =  pp->txqs[0].done_pkts_coal;
+	return 0;
+}
+
+
+static void mvneta_ethtool_get_drvinfo(struct net_device *dev,
+				    struct ethtool_drvinfo *drvinfo)
+{
+	strlcpy(drvinfo->driver, mvneta_driver_name,
+		sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, mvneta_driver_version,
+		sizeof(drvinfo->version));
+}
+
+
+static void mvneta_ethtool_get_ringparam(struct net_device *netdev,
+				struct ethtool_ringparam *ring)
+{
+	struct mvneta_port *pp = netdev_priv(netdev);
+
+	ring->rx_max_pending = MVNETA_MAX_RXD;
+	ring->tx_max_pending = MVNETA_MAX_TXD;
+	ring->rx_pending = pp->rx_ring_size;
+	ring->tx_pending = pp->tx_ring_size;
+}
+
+static int mvneta_ethtool_set_ringparam(struct net_device *dev,
+			       struct ethtool_ringparam *ring)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+
+	if ((ring->rx_pending == 0) || (ring->tx_pending == 0))
+		return -EINVAL;
+	pp->rx_ring_size = ring->rx_pending < MVNETA_MAX_RXD ?
+		ring->rx_pending : MVNETA_MAX_RXD;
+	pp->tx_ring_size = ring->tx_pending < MVNETA_MAX_TXD ?
+		ring->tx_pending : MVNETA_MAX_TXD;
+
+	if (netif_running(dev)) {
+		mvneta_stop(dev);
+		if (mvneta_open(dev)) {
+			netdev_err(dev,
+				   "error on opening device after ring param change\n");
+			return -ENOMEM;
+		}
+	}
+
+	return 0;
+}
+
+static const struct net_device_ops mvneta_netdev_ops = {
+	.ndo_open = mvneta_open,
+	.ndo_stop = mvneta_stop,
+	.ndo_start_xmit = mvneta_tx,
+	.ndo_set_rx_mode = mvneta_set_rx_mode,
+	.ndo_set_mac_address = mvneta_set_mac_addr,
+	.ndo_change_mtu = mvneta_change_mtu,
+	.ndo_tx_timeout = mvneta_tx_timeout,
+	.ndo_get_stats64 = mvneta_get_stats64,
+};
+
+const struct ethtool_ops mvneta_eth_tool_ops = {
+	.get_link = ethtool_op_get_link,
+	.get_settings = mvneta_ethtool_get_settings,
+	.set_coalesce = mvneta_ethtool_set_coalesce,
+	.get_coalesce = mvneta_ethtool_get_coalesce,
+	.get_drvinfo  = mvneta_ethtool_get_drvinfo,
+	.get_ringparam	= mvneta_ethtool_get_ringparam,
+	.set_ringparam	= mvneta_ethtool_set_ringparam,
+
+
+};
+
+/* Initialize hw */
+static int __devinit mvneta_init(struct mvneta_port *pp, int phy_addr)
+{
+	int queue;
+
+	mvneta_phy_addr_set(pp, phy_addr);
+	mvneta_port_disable(pp);
+	mvneta_defaults_set(pp);
+
+	pp->txqs = kzalloc(mvneta_txq_number *
+			   sizeof(struct mvneta_tx_queue), GFP_KERNEL);
+	if (!pp->txqs) {
+		netdev_err(pp->dev, "out of memory in allocating tx queue\n");
+		return -ENOMEM;
+	}
+
+	/* Initialize TX descriptor rings */
+	for (queue = 0; queue < mvneta_txq_number; queue++) {
+		struct mvneta_tx_queue *txq = &pp->txqs[queue];
+		txq->id = queue;
+		txq->size = pp->tx_ring_size;
+		txq->done_pkts_coal = MVNETA_TXDONE_COAL_PKTS;
+	}
+
+	pp->rxqs = kzalloc(mvneta_rxq_number *
+			   sizeof(struct mvneta_rx_queue), GFP_KERNEL);
+	if (!pp->rxqs) {
+		kfree(pp->txqs);
+		netdev_err(pp->dev, "out of memory in allocating rx queue\n");
+		return -ENOMEM;
+	}
+
+	/* Create Rx descriptor rings */
+	for (queue = 0; queue < mvneta_rxq_number; queue++) {
+		struct mvneta_rx_queue *rxq = &pp->rxqs[queue];
+		rxq->id = queue;
+		rxq->size = pp->rx_ring_size;
+		rxq->pkts_coal = MVNETA_RX_COAL_PKTS;
+		rxq->time_coal = MVNETA_RX_COAL_USEC;
+	}
+
+	return 0;
+}
+
+static void mvneta_deinit(struct mvneta_port *pp)
+{
+	kfree(pp->txqs);
+	kfree(pp->rxqs);
+}
+
+/* platform glue : initialize decoding windows */
+static void __devinit mvneta_conf_mbus_windows(struct mvneta_port *pp,
+				const struct mbus_dram_target_info *dram)
+{
+	u32 win_enable;
+	u32 win_protect;
+	int i;
+
+	for (i = 0; i < 6; i++) {
+		mvreg_write(pp, MVNETA_WIN_BASE(i), 0);
+		mvreg_write(pp, MVNETA_WIN_SIZE(i), 0);
+
+		if (i < 4)
+			mvreg_write(pp, MVNETA_WIN_REMAP(i), 0);
+	}
+
+	win_enable = 0x3f;
+	win_protect = 0;
+
+	for (i = 0; i < dram->num_cs; i++) {
+		const struct mbus_dram_window *cs = dram->cs + i;
+		mvreg_write(pp, MVNETA_WIN_BASE(i),
+			    (cs->base & 0xffff0000) |
+			    (cs->mbus_attr << 8) |
+			    dram->mbus_dram_target_id);
+
+		mvreg_write(pp, MVNETA_WIN_SIZE(i),
+			    (cs->size - 1) & 0xffff0000);
+
+		win_enable &= ~(1 << i);
+		win_protect |= 3 << (2 * i);
+	}
+
+	mvreg_write(pp, MVNETA_BASE_ADDR_ENABLE, win_enable);
+}
+
+/* Power up the port */
+static void __devinit mvneta_port_power_up(struct mvneta_port *pp, int phy_mode)
+{
+	u32 val;
+
+	/* MAC Cause register should be cleared */
+	mvreg_write(pp, MVNETA_UNIT_INTR_CAUSE, 0);
+
+	if (phy_mode == PHY_INTERFACE_MODE_SGMII)
+		mvneta_port_sgmii_config(pp);
+
+	mvneta_gmac_rgmii_set(pp, 1);
+
+	/* Cancel Port Reset */
+	val = mvreg_read(pp, MVNETA_GMAC_CTRL_2);
+	val &= (~MVNETA_GMAC2_PORT_RESET_MASK);
+	mvreg_write(pp, MVNETA_GMAC_CTRL_2, val);
+
+	while ((mvreg_read(pp, MVNETA_GMAC_CTRL_2) &
+		MVNETA_GMAC2_PORT_RESET_MASK) != 0)
+		continue;
+}
+
+/* Device initialization routine */
+static int __devinit mvneta_probe(struct platform_device *pdev)
+{
+	int err = -EINVAL;
+	struct mvneta_port *pp;
+	struct net_device *dev;
+	u32 phy_addr, clk;
+	int phy_mode;
+	const char *mac_addr;
+	const struct mbus_dram_target_info *dram_target_info;
+	struct device_node *dn = pdev->dev.of_node;
+
+	dev = alloc_etherdev_mq(sizeof(struct mvneta_port), 8);
+	if (!dev)
+		return -ENOMEM;
+
+	dev->irq = irq_of_parse_and_map(dn, 0);
+	if (dev->irq == 0) {
+		err = -EINVAL;
+		goto err_irq;
+	}
+
+	if (of_property_read_u32(dn, "phy-addr", &phy_addr) != 0) {
+		dev_err(&pdev->dev, "could not read phy_addr\n");
+		err = -ENODEV;
+		goto err_node;
+	}
+
+	phy_mode = of_get_phy_mode(dn);
+	if (phy_mode < 0) {
+		dev_err(&pdev->dev, "wrong phy-mode\n");
+		err = -EINVAL;
+		goto err_node;
+	}
+
+	if (of_property_read_u32(dn, "clock-frequency", &clk) != 0) {
+		dev_err(&pdev->dev, "could not read clock-frequency\n");
+		err = -EINVAL;
+		goto err_node;
+	}
+
+	mac_addr = of_get_mac_address(dn);
+
+	if (!mac_addr || !is_valid_ether_addr(mac_addr))
+		eth_hw_addr_random(dev);
+	else
+		memcpy(dev->dev_addr, mac_addr, 6);
+
+	dev->tx_queue_len = MVNETA_MAX_TXD;
+	dev->watchdog_timeo = 5 * HZ;
+	dev->netdev_ops = &mvneta_netdev_ops;
+
+	SET_ETHTOOL_OPS(dev, &mvneta_eth_tool_ops);
+
+	pp = netdev_priv(dev);
+
+	pp->tx_done_timer.function = mvneta_tx_done_timer_callback;
+	init_timer(&pp->tx_done_timer);
+	clear_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags);
+	pp->cleanup_timer.function = mvneta_cleanup_timer_callback;
+	init_timer(&pp->cleanup_timer);
+	clear_bit(MVNETA_F_CLEANUP_TIMER_BIT, &pp->flags);
+
+	pp->weight = MVNETA_RX_POLL_WEIGHT;
+	pp->clk = clk;
+
+	pp->base = of_iomap(dn, 0);
+	if (pp->base == NULL) {
+		err = -ENOMEM;
+		goto err_node;
+	}
+
+	pp->tx_done_timer.data = (unsigned long)dev;
+	pp->cleanup_timer.data = (unsigned long)dev;
+
+	pp->tx_ring_size = MVNETA_MAX_TXD;
+	pp->rx_ring_size = MVNETA_MAX_RXD;
+
+	pp->dev = dev;
+
+	if (mvneta_init(pp, phy_addr)) {
+		dev_err(&pdev->dev, "can't init eth hal\n");
+		err = -ENODEV;
+		goto err_base;
+	}
+	mvneta_port_power_up(pp, phy_mode);
+
+	dram_target_info = mv_mbus_dram_info();
+	if (dram_target_info)
+		mvneta_conf_mbus_windows(pp, dram_target_info);
+
+	netif_napi_add(dev, &pp->napi, mvneta_poll, pp->weight);
+
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	if (register_netdev(dev)) {
+		dev_err(&pdev->dev, "failed to register\n");
+		err = ENOMEM;
+		goto err_base;
+	}
+
+	dev->features = NETIF_F_SG;
+	dev->hw_features =  NETIF_F_SG;
+	dev->priv_flags |= IFF_UNICAST_FLT;
+
+	if (dev->mtu <= MVNETA_TX_CSUM_MAX_SIZE) {
+		dev->features |= NETIF_F_IP_CSUM;
+		dev->hw_features |= NETIF_F_IP_CSUM;
+	}
+
+	dev_info(&pdev->dev, "%s, mac: %pM pp->base=%p\n", dev->name,
+		 dev->dev_addr, pp->base);
+
+	platform_set_drvdata(pdev, pp->dev);
+
+	return 0;
+err_base:
+	iounmap(pp->base);
+err_node:
+	irq_dispose_mapping(dev->irq);
+err_irq:
+	free_netdev(dev);
+	return err;
+}
+
+/* Device removal routine */
+static int __devexit mvneta_remove(struct platform_device *pdev)
+{
+	struct net_device  *dev = platform_get_drvdata(pdev);
+	struct mvneta_port *pp = netdev_priv(dev);
+
+	dev_info(&pdev->dev, "Removing Marvell Ethernet Driver\n");
+	iounmap(pp->base);
+
+	unregister_netdev(dev);
+	irq_dispose_mapping(dev->irq);
+	free_netdev(dev);
+	mvneta_deinit(pp);
+
+	platform_set_drvdata(pdev, NULL);
+
+	return 0;
+}
+
+static const struct of_device_id mvneta_match[] = {
+	{ .compatible = "marvell,neta" },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, mvneta_match);
+
+static struct platform_driver mvneta_driver = {
+	.probe = mvneta_probe,
+	.remove = __devexit_p(mvneta_remove),
+	.driver = {
+		.name = "mvneta",
+		.of_match_table = mvneta_match,
+	},
+};
+
+module_platform_driver(mvneta_driver);
+
+MODULE_DESCRIPTION("Marvell NETA Ethernet Driver - www.marvell.com");
+MODULE_AUTHOR("Rami Rosen <rosenr@marvell.com>");
+MODULE_LICENSE("GPL");
+
+module_param(mvneta_rxq_number, int, S_IRUGO);
+module_param(mvneta_txq_number, int, S_IRUGO);
+
+module_param(mvneta_rxq_def, int, S_IRUGO);
+module_param(mvneta_txq_def, int, S_IRUGO);
+
diff --git a/drivers/net/ethernet/marvell/mvneta.h b/drivers/net/ethernet/marvell/mvneta.h
new file mode 100644
index 0000000..bf0354f
--- /dev/null
+++ b/drivers/net/ethernet/marvell/mvneta.h
@@ -0,0 +1,496 @@
+/*
+ * Driver for Marvell NETA network card for Armada XP and Armada 370 SoCs.
+ *
+ * Copyright (C) 2012 Marvell
+ *
+ * Rami Rosen <rosenr@marvell.com>
+ * Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+  warranty of any kind, whether express or implied.
+ */
+
+#ifndef MVNETA_H
+#define MVNETA_H
+
+#include <linux/kernel.h>
+#include <linux/version.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/platform_device.h>
+#include <linux/skbuff.h>
+
+/* Registers */
+#define MVNETA_RXQ_CONFIG_REG(q)	(0x1400 + ((q) << 2))
+#define MVNETA_RXQ_THRESHOLD_REG(q)	(0x14c0 + ((q) << 2))
+#define MVNETA_RXQ_BASE_ADDR_REG(q)	(0x1480 + ((q) << 2))
+#define MVNETA_RXQ_SIZE_REG(q)		(0x14a0 + ((q) << 2))
+#define MVNETA_RXQ_STATUS_REG(q)	(0x14e0 + ((q) << 2))
+#define MVNETA_RXQ_STATUS_UPDATE_REG(q)	(0x1500 + ((q) << 2))
+#define MVNETA_PORT_RX_RESET		0x1cc0 /* Port RX Init (PRXINIT) */
+#define MVNETA_PHY_ADDR			0x2000 /* PHY Address Register */
+#define MVNETA_MBUS_RETRY		0x2010 /* Port Mbus Retry Register */
+#define MVNETA_UNIT_INTR_CAUSE		0x2080 /* Unit Interrupt Cause (EUIC) */
+#define MVNETA_UNIT_CONTROL		0x20B0 /* Interrupt Source Control */
+/* Window address decoding registers */
+#define MVNETA_WIN_BASE(w)		(0x2200 + ((w) << 3))
+#define MVNETA_WIN_SIZE(w)		(0x2204 + ((w) << 3))
+#define MVNETA_WIN_REMAP(w)		(0x2280 + ((w) << 2))
+#define MVNETA_BASE_ADDR_ENABLE		0x2290 /* Base Address Enable (BARE) */
+#define MVNETA_PORT_CONFIG		0x2400 /* Port Configuration (PxC) */
+#define MVNETA_PORT_CONFIG_EXTEND	0x2404 /* Port Conf Extend (PxCX) */
+#define MVNETA_MAC_ADDR_LOW		0x2414 /* MAC Address Low (MACAL) */
+#define MVNETA_MAC_ADDR_HIGH		0x2418 /* MAC Address High (MACAH) */
+#define MVNETA_SDMA_CONFIG		0x241c /* SDMA Configuration (SDC) */
+#define MVNETA_PORT_STATUS		0x2444 /* Ethernet Port Status */
+#define MVNETA_RX_MIN_FRAME_SIZE	0x247c /* Rx Min Frame Size (PxMFS)*/
+#define MVNETA_TYPE_PRIO		0x24bc /* Ethernet Type Priority */
+#define MVNETA_TXQ_CMD_1		0x24e4 /* Tx Queue Command1 (TQC1) */
+#define MVNETA_TXQ_CMD			0x2448 /* Tx Queue Command (TQC) */
+#define MVNETA_ACC_MODE			0x2500 /* Acceleration Mode (PACC) */
+#define MVNETA_CPU_MAP(cpu)		(0x2540 + ((cpu) << 2))
+#define MVNETA_RXQ_TIME_COAL_REG(q)	(0x2580 + ((q) << 2))
+#define MVNETA_INTR_NEW_CAUSE		0x25a0 /* Threshold Interrupt Cause */
+#define MVNETA_INTR_NEW_MASK		0x25a4 /* Threshold Interrupt Mask  */
+#define MVNETA_INTR_OLD_CAUSE		0x25a8 /* Interrupt Cause           */
+#define MVNETA_INTR_OLD_MASK		0x25ac /* Interrupt Mask	*/
+#define MVNETA_INTR_MISC_CAUSE		0x25b0 /* Misc Interrupt Cause */
+#define MVNETA_INTR_MISC_MASK		0x25b4 /* Misc Interrupt Mask */
+#define MVNETA_INTR_ENABLE		0x25b8 /* Interrupt Enable (PIntEnb)*/
+#define MVNETA_RXQ_CMD			0x2680 /* Receive Queue Command (RQC) */
+#define MVETH_TXQ_TOKEN_COUNT_REG(q)	(0x2700 + ((q) << 4))
+#define MVETH_TXQ_TOKEN_CFG_REG(q)	(0x2704 + ((q) << 4))
+#define MVNETA_GMAC_CTRL_0		0x2c00 /* MAC Control Register 0 */
+#define MVNETA_GMAC_CTRL_2		0x2c08 /* MAC Control Register 2 */
+#define MVNETA_GMAC_STATUS		0x2c10 /* Port Status Register 0 */
+#define MVNETA_MIB_COUNTERS_BASE	0x3080 /* MIB counters base	*/
+#define MVNETA_DA_FILT_SPEC_MCAST	0x3400 /* DA Filter Special Mcast Tbl */
+#define MVNETA_DA_FILT_OTH_MCAST	0x3500 /* DA Filter Other Mcast Tbl */
+#define MVNETA_DA_FILT_UCAST_BASE	0x3600 /* DA Filter Unicast Table   */
+#define MVNETA_TXQ_BASE_ADDR_REG(q)	(0x3c00 + ((q) << 2))
+#define MVNETA_TXQ_SIZE_REG(q)		(0x3c20 + ((q) << 2))
+#define MVNETA_TXQ_UPDATE_REG(q)	(0x3c60 + ((q) << 2))
+#define MVNETA_TXQ_STATUS_REG(q)	(0x3c40 + ((q) << 2))
+#define MVNETA_PORT_TX_RESET		0x3cf0 /* Port TX Init (PTXINIT) */
+#define MVNETA_TX_MTU			0x3e0c /* MTU Register */
+#define MVNETA_TX_TOKEN_SIZE		0x3e14 /* Maximum Token Bucket Size */
+#define MVNETA_TXQ_TOKEN_SIZE_REG(q)	(0x3e40 + ((q) << 2))
+
+
+/* Masks */
+
+/* MVNETA_TXQ_CMD register offset, mask */
+#define MVNETA_TXQ_DISABLE_OFFS		8
+#define MVNETA_TXQ_ENABLE_MASK		0x000000ff
+
+/* MVNETA_TXQ_STATUS_REG register offset and mask */
+#define MVNETA_TXQ_SENT_DESC_OFFS	16
+#define MVNETA_TXQ_SENT_DESC_MASK	0x3fff0000
+
+/* MVNETA_TXQ_SIZE_REG register offset and masks */
+#define MVNETA_TXQ_SENT_TRESH_OFFS	16
+#define MVNETA_TXQ_SENT_TRESH_ALL_MASK	0x3fff0000
+#define MVNETA_TXQ_SENT_TRESH_MASK(coal) ((coal) << MVNETA_TXQ_SENT_TRESH_OFFS)
+
+/* MVNETA_TXQ_TOKEN_SIZE_REG register mask */
+#define MVNETA_TXQ_TOKEN_SIZE_MAX	0x7fffffff
+
+/* MVNETA_TX_TOKEN_SIZE register mask */
+#define MVNETA_TX_TOKEN_SIZE_MAX	0xffffffff
+
+
+/* Tx descriptor command masks */
+#define MVNETA_TXD_IP_CSUM_MASK		0x00040000
+#define MVNETA_TXD_Z_PAD_MASK		0x00080000
+#define MVNETA_TXD_L_DESC_MASK		0x00100000
+#define MVNETA_TXD_F_DESC_MASK		0x00200000
+#define MVNETA_TXD_FLZ_DESC_MASK	0x00380000
+
+
+/* MVNETA_RXQ_CMD offset, mask */
+#define MVNETA_RXQ_DISABLE_OFFS		8
+#define MVNETA_RXQ_ENABLE_MASK		0x000000ff
+
+/* MVNETA_RXQ_SIZE offset and mask */
+#define MVNETA_RXQ_BUF_SIZE_OFFS	19
+#define MVNETA_RXQ_BUF_SIZE_MASK	(0x1fff << MVNETA_RXQ_BUF_SIZE_OFFS)
+
+/* MVNETA_RXQ_THRESHOLD_REG register mask */
+#define MVNETA_RXQ_NON_OCCUPIED_OFFS	16
+#define MVNETA_RXQ_NON_OCCUPIED_ALL_MASK 0x3fff0000
+#define MVNETA_RXQ_NON_OCCUPIED_MASK(v) ((v) << MVNETA_RXQ_NON_OCCUPIED_OFFS)
+
+/* MVNETA_RXQ_STATUS register mask */
+#define MVNETA_RXQ_OCCUPIED_ALL_MASK	0x3fff
+
+/* MVNETA_RXQ_CONFIG_REG register mask */
+#define MVNETA_RXQ_HW_BUF_ALLOC_MASK	0x0001
+
+/* Rx descriptor status masks */
+#define MVNETA_RXD_ERR_CRC_MASK		0x00000000
+#define MVNETA_RXD_ERR_SUMMARY_MASK	0x00010000
+#define MVNETA_RXD_ERR_OVERRUN_MASK	0x00020000
+#define MVNETA_RXD_ERR_LEN_MASK		0x00040000
+#define MVNETA_RXD_ERR_CODE_MASK	0x00060000
+#define MVNETA_RXD_ERR_RESOURCE_MASK	0x00060000
+#define MVNETA_RXD_L4_CSUM_OK_MASK	0x40000000
+#define MVNETA_RXD_FIRST_LAST_DESC_MASK	0x0c000000
+
+/* Mask and a macro to check if the rx descriptor is of IPv4 L3 header */
+#define MVNETA_RX_IP_HEADER_OK_MASK	0x2000000
+#define MVNETA_RX_L3_IS_IP4(status)	((status) & MVNETA_RX_IP_HEADER_OK_MASK)
+
+/* MVNETA_RXQ_STATUS_UPDATE register offset */
+#define MVNETA_RXQ_ADD_NON_OCCUPIED_OFFS 16
+
+#define MVNETA_RXQ_PKT_OFFSET_OFFS        8
+#define MVNETA_RXQ_PKT_OFFSET_ALL_MASK   (0xf << MVNETA_RXQ_PKT_OFFSET_OFFS)
+#define MVNETA_RXQ_PKT_OFFSET_MASK(offs) ((offs) << MVNETA_RXQ_PKT_OFFSET_OFFS)
+
+
+/* MVNETA_SDMA_CONFIG register masks */
+#define MVNETA_NO_DESC_SWAP		0x0
+#define MVNETA_RX_NO_DATA_SWAP		0x10
+#define MVNETA_TX_NO_DATA_SWAP		0x20
+
+/* SDMA Rx Burst size offset and masks */
+#define MVNETA_SDMA_BRST_SIZE_16_64BIT_VALUE	4
+
+#define MVNETA_RX_BRSTSZ_OFFS		1
+#define MVNETA_RX_BRST_SZ_MASK(burst)	((burst) << MVNETA_RX_BRSTSZ_OFFS)
+
+/* SDMA Tx Burst size offset and masks */
+#define MVNETA_TX_BRST_SZ_OFFS		22
+#define MVNETA_TX_BRST_SZ_MASK(burst)	((burst) << MVNETA_TX_BRST_SZ_OFFS)
+
+
+/* MVNETA_PORT_STATUS register mask */
+#define MVNETA_TX_IN_PRGRS_MASK		0x00000001
+#define MVNETA_TX_FIFO_EMPTY_MASK	0x00000100
+
+/* MVNETA_INTR_ENABLE register masks */
+#define MVNETA_TXQ_INTR_ENABLE_ALL_MASK 0x0000ff00
+#define MVNETA_RXQ_INTR_ENABLE_ALL_MASK 0xff000000
+
+/* MVNETA_CPU_MAP register masks */
+#define MVNETA_CPU_RXQ_ACCESS_ALL_MASK	0x000000ff
+#define MVNETA_CPU_TXQ_ACCESS_ALL_MASK	0x0000ff00
+
+/* MVNETA_INTR_NEW_MASK register mask */
+#define MVNETA_RX_INTR_MASK		(((1 << mvneta_rxq_number) - 1) << 8)
+
+/* MVNETA_GMAC_CTRL_0 register offset and mask */
+#define MVNETA_GMAC_MAX_RX_SIZE_OFFS	2
+#define MVNETA_GMAC_MAX_RX_SIZE_MASK	0x7ffc
+#define MVNETA_GMAC0_PORT_ENABLE	1
+
+
+/* MVNETA_GMAC_STATUS register masks - LinkUp, Speed, Duplex and Flow Control */
+#define MVNETA_GMAC_LINK_UP_MASK		0x01
+#define MVNETA_GMAC_SPEED_1000_MASK		0x02
+#define MVNETA_GMAC_SPEED_100_MASK		0x04
+#define MVNETA_GMAC_FULL_DUPLEX_MASK		0x08
+#define MVNETA_GMAC_RX_FLOW_CTRL_ENABLE_MASK	0x10
+#define MVNETA_GMAC_TX_FLOW_CTRL_ENABLE_MASK	0x20
+#define MVNETA_GMAC_RX_FLOW_CTRL_ACTIVE_MASK	0x40
+#define MVNETA_GMAC_TX_FLOW_CTRL_ACTIVE_MASK	0x80
+
+/* MVNETA_INTR_MISC_MASK register mask */
+#define MVNETA_CAUSE_LINK_CHANGE_MASK	0x0002
+
+/* MVNETA_INTR_NEW_MASK register mask */
+#define MVNETA_ETH_MISC_SUM_INTR_MASK	0xc0000000
+
+/* MVNETA_PORT_TX_RESET register mask */
+#define MVNETA_PORT_TX_DMA_RESET_MASK	0x1
+
+/* MVNETA_PORT_RX_RESET register mask */
+#define MVNETA_PORT_RX_DMA_RESET_MASK	0x1
+
+/* MVNETA_GMAC_CTRL_2 register mask */
+#define MVNETA_GMAC2_PSC_ENABLE_MASK	0x08
+#define MVNETA_GMAC2_PORT_RGMII_MASK	0x10
+#define MVNETA_GMAC2_PORT_RESET_MASK	0x40
+
+/* MVNETA_PHY_ADDR register mask */
+#define MVNETA_PHY_ADDR_MASK		0x1f
+
+/* MVNETA_UNIT_CONTROL register mask */
+#define MVNETA_PHY_POLLING_ENABLE_MASK	0x2
+
+/* MVNETA_PORT_CONFIG regiser masks and offsets */
+#define MVNETA_UNI_PROMISC_MODE_MASK	0x00000001
+#define MVNETA_TX_UNSET_ERR_SUM_MASK	0x00001000
+
+#define MVNETA_DEF_RXQ_OFFS	      1
+#define MVNETA_DEF_RXQ_MASK(q) ((q) << MVNETA_DEF_RXQ_OFFS)
+
+#define MVNETA_DEF_RXQ_ARP_OFFS         4
+#define MVNETA_DEF_RXQ_ARP_MASK(q)	((q) << MVNETA_DEF_RXQ_ARP_OFFS)
+
+#define MVNETA_DEF_RXQ_TCP_OFFS         16
+#define MVNETA_DEF_RXQ_TCP_MASK(q) ((q) << MVNETA_DEF_RXQ_TCP_OFFS)
+
+#define MVNETA_DEF_RXQ_UDP_OFFS         19
+#define MVNETA_DEF_RXQ_UDP_MASK(q) ((q) << MVNETA_DEF_RXQ_UDP_OFFS)
+
+#define MVNETA_DEF_RXQ_BPDU_OFFS        22
+#define MVNETA_DEF_RXQ_BPDU_MASK(q) ((q) << MVNETA_DEF_RXQ_BPDU_OFFS)
+
+#define MVNETA_RX_CHECKSUM_MODE_OFFS     25
+#define MVNETA_RX_CSUM_WITH_PSEUDO_HDR     (1 << MVNETA_RX_CHECKSUM_MODE_OFFS)
+
+#define MVNETA_PORT_CONFIG_VALUE(rxq) \
+	(MVNETA_DEF_RXQ_MASK(rxq)      | MVNETA_DEF_RXQ_ARP_MASK(rxq) | \
+	 MVNETA_DEF_RXQ_TCP_MASK(rxq)  | MVNETA_DEF_RXQ_UDP_MASK(rxq) | \
+	 MVNETA_DEF_RXQ_BPDU_MASK(rxq) | MVNETA_TX_UNSET_ERR_SUM_MASK | \
+	 MVNETA_RX_CSUM_WITH_PSEUDO_HDR)
+
+#define MVNETA_CAUSE_TXQ_SENT_DESC_ALL_MASK	0xff
+
+/* MVNETA_TYPE_PRIO regsister mask */
+#define MVNETA_FORCE_UNI_MASK			0x200000
+
+/* Descriptor ring Macros */
+#define MVNETA_QUEUE_NEXT_DESC(q, index)	\
+	(((index) < (q)->last_desc) ? ((index) + 1) : 0)
+
+/* Various constants */
+
+/* Coalescing */
+#define MVNETA_TXDONE_COAL_PKTS		16
+#define MVNETA_RX_COAL_PKTS		32
+#define MVNETA_RX_COAL_USEC		100
+
+/* Timers */
+#define MVNETA_CLEANUP_TIMER_PERIOD	10
+#define MVNETA_TX_DONE_TIMER_PERIOD	10
+
+/* Napi polling weight */
+#define MVNETA_RX_POLL_WEIGHT		64
+
+#define MVNETA_MH_SIZE			2
+
+#define MVNETA_CPU_D_CACHE_LINE_SIZE    32
+#define	MVNETA_MAC_ADDR_SIZE	        6
+#define MVNETA_ETH_CRC_SIZE		4
+#define MVNETA_TX_CSUM_MAX_SIZE		9800
+#define MVNETA_ACC_MODE_EXT		1
+
+/* Timeout constants */
+#define MVNETA_TX_DISABLE_TIMEOUT_MSEC	1000
+#define MVNETA_RX_DISABLE_TIMEOUT_MSEC	1000
+#define MVNETA_TX_FIFO_EMPTY_TIMEOUT	10000
+
+#define MVNETA_MIB_LATE_COLLISION	0x7c
+
+#define MVNETA_TX_MTU_MAX		0x3ffff
+
+/* Constants for csum calculation */
+#define MVNETA_TX_IP_HLEN_OFFS		8
+#define MVNETA_TX_L4_UDP		0x10000
+#define MVNETA_TX_L3_IP6		0x20000
+#define MVNETA_TX_L4_CSUM_FULL		0x40000000
+#define MVNETA_TX_L4_CSUM_NOT		0x80000000
+
+#define MVNETA_TXQ_DEC_SENT_OFFS	16
+
+/* Amount of memory needed for the DMA descriptors array for a given
+ * RX queue, taking into account the cache-line alignement
+ * requirement */
+#define MVNETA_RX_TOTAL_DESCS_SIZE(q) \
+	(((q)->size * sizeof(struct mvneta_rx_desc)) + \
+	 MVNETA_CPU_D_CACHE_LINE_SIZE)
+
+/* Amount of memory needed for the DMA descriptors array for a given
+ * TX queue, taking into account the cache-line alignement
+ * requirement */
+#define MVNETA_TX_TOTAL_DESCS_SIZE(q) \
+	(((q)->size * sizeof(struct mvneta_tx_desc)) + \
+	 MVNETA_CPU_D_CACHE_LINE_SIZE)
+
+#define MVNETA_RX_PKT_SIZE(mtu) \
+	ALIGN((mtu) + 2 + 4 + ETH_HLEN + 4, MVNETA_CPU_D_CACHE_LINE_SIZE)
+
+#define MVNETA_RX_BUF_SIZE(pkt_size)   ((pkt_size) + NET_SKB_PAD)
+
+/* Masks used for pp->flags */
+#define MVNETA_F_STARTED_BIT        0
+#define MVNETA_F_STARTED            BIT(MVNETA_F_STARTED_BIT)
+#define MVNETA_F_LINK_UP_BIT        1
+#define MVNETA_F_LINK_UP            BIT(MVNETA_F_LINK_UP_BIT)
+#define MVNETA_F_TX_DONE_TIMER_BIT  2
+#define MVNETA_F_TX_DONE_TIMER      BIT(MVNETA_F_TX_DONE_TIMER_BIT)
+#define MVNETA_F_CLEANUP_TIMER_BIT  3
+#define MVNETA_F_CLEANUP_TIMER      BIT(MVNETA_F_CLEANUP_TIMER_BIT)
+
+struct mvneta_stats {
+	struct	u64_stats_sync syncp;
+	u64	packets;
+	u64	bytes;
+};
+
+struct mvneta_port {
+	/* packet size in bytes */
+	int pkt_size;
+
+	/* Ethernet controller base address */
+	void __iomem *base;
+
+	/* Array of RX queues */
+	struct mvneta_rx_queue *rxqs;
+
+	/* Array of TX queues */
+	struct mvneta_tx_queue *txqs;
+
+	struct timer_list tx_done_timer;
+	struct timer_list cleanup_timer;
+	struct net_device *dev;
+	u32 cause_rx_tx[CONFIG_NR_CPUS];
+	struct napi_struct napi;
+	unsigned long flags;
+
+	/* Napi weight */
+	int weight;
+
+	/* Core clock [Hz] */
+	unsigned int clk;
+	u8 mcast_count[256];
+	u16 tx_ring_size;
+	u16 rx_ring_size;
+	struct mvneta_stats tx_stats;
+	struct mvneta_stats rx_stats;
+};
+
+/* mvneta_tx_desc and mvneta_rx_desc structs describe the layout of
+ * the transmit and reception DMA descriptors, and are therefore
+ * defined by the hardware design
+ */
+struct mvneta_tx_desc {
+	u32  command;		/* Options used by HW for packet transmitting.*/
+	u16  reserverd1;	/* csum_l4 (for future use)		*/
+	u16  data_size;		/* Data size of transmitted packet in bytes */
+	u32  buf_phys_addr;	/* Physical addr of transmitted buffer	*/
+	u32  reserved2;		/* hw_cmd - (for future use, PMT)	*/
+	u32  reserved3[4];	/* Reserved - (for future use)		*/
+};
+
+struct mvneta_rx_desc {
+	u32  status;		/* Info about received packet		*/
+	u16  reserved1;		/* pnc_info - (for future use, PnC)	*/
+	u16  data_size;		/* Size of received packet in bytes	*/
+	u32  buf_phys_addr;	/* Physical address of the buffer	*/
+	u32  reserved2;		/* pnc_flow_id  (for future use, PnC)	*/
+	u32  buf_cookie;	/* cookie for access to RX buffer in rx path */
+	u16  reserved3;		/* prefetch_cmd, for future use		*/
+	u16  reserved4;		/* csum_l4 - (for future use, PnC)	*/
+	u32  reserved5;		/* pnc_extra PnC (for future use, PnC)	*/
+	u32  reserved6;		/* hw_cmd (for future use, PnC and HWF)	*/
+};
+
+enum {
+	MVNETA_FC_AN_NO,
+	MVNETA_FC_AN_SYM,
+	MVNETA_FC_AN_ASYM,
+	MVNETA_FC_DISABLE,
+	MVNETA_FC_ENABLE,
+	MVNETA_FC_ACTIVE
+};
+
+enum {
+	MVNETA_SPEED_AN,
+	MVNETA_SPEED_10,
+	MVNETA_SPEED_100,
+	MVNETA_SPEED_1000
+};
+
+enum {
+	MVNETA_DUPLEX_AN,
+	MVNETA_DUPLEX_HALF,
+	MVNETA_DUPLEX_FULL
+};
+
+struct mvneta_lnk_status {
+	int	linkup;
+	int	speed;
+	int	duplex;
+	int	rx_fc;
+	int	tx_fc;
+};
+
+struct mvneta_tx_queue {
+	/* tx queue number, in the range 0-7 */
+	u8 id;
+
+	/* num of txq descriptors in the tx descriptor ring */
+	int size;
+
+	/* index of last tx descriptor in txq descriptor ring */
+	int count;
+
+	/* array of transmitted skb */
+	struct sk_buff **tx_skb;
+
+	/* index of last tx desc that was inserted */
+	int txq_put_index;
+
+	/* index of tx desc for cleanup */
+	int txq_get_index;
+
+	u32 done_pkts_coal;
+
+	/* Virtual address of DMA descriptors array, as returned by
+	 * dma_alloc_coherent */
+	void *descs_orig;
+
+	/* Cache-line aligned virtual address of the DMA descriptors
+	 * array. */
+	struct mvneta_tx_desc *descs;
+
+	/* Physical address of the DMA descriptors array, as returned
+	 * by dma_alloc_coherent */
+	dma_addr_t descs_phys_orig;
+
+	/* Cache-line aligned physical address of the DMA descriptors
+	 * array */
+	dma_addr_t descs_phys;
+
+	int last_desc;
+	int next_desc_to_proc;
+};
+
+struct mvneta_rx_queue {
+	/* rx queue number, in the range 0-7 */
+	u8 id;
+
+	/* num of rx descriptors in the rx descriptor ring */
+	int size;
+
+	/* counter of times when mvneta_refill() failed */
+	int missed;
+
+	u32 pkts_coal;
+	u32 time_coal;
+
+	/* Virtual address of DMA descriptors array, as returned by
+	 * dma_alloc_coherent */
+	void *descs_orig;
+
+	/* Cache-line aligned virtual address of the DMA descriptors
+	 * array. */
+	struct mvneta_rx_desc *descs;
+
+	/* Physical address of the DMA descriptors array, as returned
+	 * by dma_alloc_coherent */
+	dma_addr_t descs_phys_orig;
+
+	/* Cache-line aligned physical address of the DMA descriptors
+	 * array */
+	dma_addr_t descs_phys;
+
+	int last_desc;
+	int next_desc_to_proc;
+};
+
+#endif
-- 
1.7.9.5
