From: Olof Johansson <olof@lixom.net>
Subject: [patch 6/6] pasemi_mac: basic ethtool support
Date: Wed, 20 Feb 2008 20:57:59 -0600
Message-ID: <20080221025930.555130000@lixom.net>
References: <20080221025753.903665000@lixom.net>
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	pasemi-linux@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:44459 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752428AbYBUDPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 22:15:10 -0500
Content-Disposition: inline; filename=in-progress/pasemi_mac-ethtool
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First cut at ethtool support, to be completed over time.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: 2.6.25/drivers/net/Makefile
===================================================================
--- 2.6.25.orig/drivers/net/Makefile
+++ 2.6.25/drivers/net/Makefile
@@ -218,7 +218,8 @@ obj-$(CONFIG_SMC911X) += smc911x.o
 obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
 obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_FEC_8XX) += fec_8xx/
-obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o
+obj-$(CONFIG_PASEMI_MAC) += pasemi_mac_driver.o
+pasemi_mac_driver-objs := pasemi_mac.o pasemi_mac_ethtool.o
 obj-$(CONFIG_MLX4_CORE) += mlx4/
 obj-$(CONFIG_ENC28J60) += enc28j60.o
 
Index: 2.6.25/drivers/net/pasemi_mac.c
===================================================================
--- 2.6.25.orig/drivers/net/pasemi_mac.c
+++ 2.6.25/drivers/net/pasemi_mac.c
@@ -55,12 +55,6 @@
  * - Multiqueue RX/TX
  */
 
-
-/* Must be a power of two */
-#define RX_RING_SIZE 2048
-#define TX_RING_SIZE 4096
-#define CS_RING_SIZE (TX_RING_SIZE*2)
-
 #define LRO_MAX_AGGR 64
 
 #define PE_MIN_MTU	64
@@ -77,17 +71,6 @@
 	 NETIF_MSG_RX_ERR	| \
 	 NETIF_MSG_TX_ERR)
 
-#define TX_DESC(tx, num)	((tx)->chan.ring_virt[(num) & (TX_RING_SIZE-1)])
-#define TX_DESC_INFO(tx, num)	((tx)->ring_info[(num) & (TX_RING_SIZE-1)])
-#define RX_DESC(rx, num)	((rx)->chan.ring_virt[(num) & (RX_RING_SIZE-1)])
-#define RX_DESC_INFO(rx, num)	((rx)->ring_info[(num) & (RX_RING_SIZE-1)])
-#define RX_BUFF(rx, num)	((rx)->buffers[(num) & (RX_RING_SIZE-1)])
-#define CS_DESC(cs, num)	((cs)->chan.ring_virt[(num) & (CS_RING_SIZE-1)])
-
-#define RING_USED(ring)		(((ring)->next_to_fill - (ring)->next_to_clean) \
-				 & ((ring)->size - 1))
-#define RING_AVAIL(ring)	((ring->size) - RING_USED(ring))
-
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR ("Olof Johansson <olof@lixom.net>");
 MODULE_DESCRIPTION("PA Semi PWRficient Ethernet driver");
@@ -96,6 +79,8 @@ static int debug = -1;	/* -1 == use DEFA
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "PA Semi MAC bitmapped debugging message enable value");
 
+extern const struct ethtool_ops pasemi_mac_ethtool_ops;
+
 static int translation_enabled(void)
 {
 #if defined(CONFIG_PPC_PASEMI_IOMMU_DMA_FORCE)
@@ -1148,7 +1133,7 @@ static int pasemi_mac_open(struct net_de
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int flags;
-	int ret;
+	int i, ret;
 
 	flags = PAS_MAC_CFG_TXP_FCE | PAS_MAC_CFG_TXP_FPC(3) |
 		PAS_MAC_CFG_TXP_SL(3) | PAS_MAC_CFG_TXP_COB(0xf) |
@@ -1171,6 +1156,10 @@ static int pasemi_mac_open(struct net_de
 			goto out_tx_ring;
 	}
 
+	/* Zero out rmon counters */
+	for (i = 0; i < 32; i++)
+		write_mac_reg(mac, PAS_MAC_RMON(i), 0);
+
 	/* 0x3ff with 33MHz clock is about 31us */
 	write_iob_reg(PAS_IOB_DMA_COM_TIMEOUTCFG,
 		      PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0x3ff));
@@ -1812,6 +1801,7 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 	mac->bufsz = dev->mtu + ETH_HLEN + ETH_FCS_LEN + LOCAL_SKB_ALIGN + 128;
 
 	dev->change_mtu = pasemi_mac_change_mtu;
+	dev->ethtool_ops = &pasemi_mac_ethtool_ops;
 
 	if (err)
 		goto out;
Index: 2.6.25/drivers/net/pasemi_mac.h
===================================================================
--- 2.6.25.orig/drivers/net/pasemi_mac.h
+++ 2.6.25/drivers/net/pasemi_mac.h
@@ -26,6 +26,12 @@
 #include <linux/spinlock.h>
 #include <linux/phy.h>
 
+/* Must be a power of two */
+#define RX_RING_SIZE 2048
+#define TX_RING_SIZE 4096
+#define CS_RING_SIZE (TX_RING_SIZE*2)
+
+
 #define MAX_LRO_DESCRIPTORS 8
 #define MAX_CS	2
 
@@ -103,6 +109,16 @@ struct pasemi_mac_buffer {
 	dma_addr_t	dma;
 };
 
+#define TX_DESC(tx, num)	((tx)->chan.ring_virt[(num) & (TX_RING_SIZE-1)])
+#define TX_DESC_INFO(tx, num)	((tx)->ring_info[(num) & (TX_RING_SIZE-1)])
+#define RX_DESC(rx, num)	((rx)->chan.ring_virt[(num) & (RX_RING_SIZE-1)])
+#define RX_DESC_INFO(rx, num)	((rx)->ring_info[(num) & (RX_RING_SIZE-1)])
+#define RX_BUFF(rx, num)	((rx)->buffers[(num) & (RX_RING_SIZE-1)])
+#define CS_DESC(cs, num)	((cs)->chan.ring_virt[(num) & (CS_RING_SIZE-1)])
+
+#define RING_USED(ring)	(((ring)->next_to_fill - (ring)->next_to_clean) \
+				& ((ring)->size - 1))
+#define RING_AVAIL(ring)	((ring->size) - RING_USED(ring))
 
 /* PCI register offsets and formats */
 
@@ -114,6 +130,7 @@ enum {
 	PAS_MAC_CFG_ADR0 = 0x8c,
 	PAS_MAC_CFG_ADR1 = 0x90,
 	PAS_MAC_CFG_TXP = 0x98,
+	PAS_MAC_CFG_RMON = 0x100,
 	PAS_MAC_IPC_CHNL = 0x208,
 };
 
@@ -185,6 +202,8 @@ enum {
 #define PAS_MAC_CFG_TXP_TIFG(x)		(((x) << PAS_MAC_CFG_TXP_TIFG_S) & \
 					 PAS_MAC_CFG_TXP_TIFG_M)
 
+#define PAS_MAC_RMON(r)			(0x100+(r)*4)
+
 #define PAS_MAC_IPC_CHNL_DCHNO_M	0x003f0000
 #define PAS_MAC_IPC_CHNL_DCHNO_S	16
 #define PAS_MAC_IPC_CHNL_DCHNO(x)	(((x) << PAS_MAC_IPC_CHNL_DCHNO_S) & \
@@ -194,4 +213,5 @@ enum {
 #define PAS_MAC_IPC_CHNL_BCH(x)		(((x) << PAS_MAC_IPC_CHNL_BCH_S) & \
 					 PAS_MAC_IPC_CHNL_BCH_M)
 
+
 #endif /* PASEMI_MAC_H */
Index: 2.6.25/drivers/net/pasemi_mac_ethtool.c
===================================================================
--- /dev/null
+++ 2.6.25/drivers/net/pasemi_mac_ethtool.c
@@ -0,0 +1,159 @@
+/*
+ * Copyright (C) 2006-2008 PA Semi, Inc
+ *
+ * Ethtool hooks for the PA Semi PWRficient onchip 1G/10G Ethernet MACs
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+ */
+
+
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+#include <linux/pci.h>
+#include <linux/inet_lro.h>
+
+#include <asm/pasemi_dma.h>
+#include "pasemi_mac.h"
+
+static struct {
+	const char str[ETH_GSTRING_LEN];
+} ethtool_stats_keys[] = {
+	{ "rx-drops" },
+	{ "rx-bytes" },
+	{ "rx-packets" },
+	{ "rx-broadcast-packets" },
+	{ "rx-multicast-packets" },
+	{ "rx-crc-errors" },
+	{ "rx-undersize-errors" },
+	{ "rx-oversize-errors" },
+	{ "rx-short-fragment-errors" },
+	{ "rx-jabber-errors" },
+	{ "rx-64-byte-packets" },
+	{ "rx-65-127-byte-packets" },
+	{ "rx-128-255-byte-packets" },
+	{ "rx-256-511-byte-packets" },
+	{ "rx-512-1023-byte-packets" },
+	{ "rx-1024-1518-byte-packets" },
+	{ "rx-pause-frames" },
+	{ "tx-bytes" },
+	{ "tx-packets" },
+	{ "tx-broadcast-packets" },
+	{ "tx-multicast-packets" },
+	{ "tx-collisions" },
+	{ "tx-late-collisions" },
+	{ "tx-excessive-collisions" },
+	{ "tx-crc-errors" },
+	{ "tx-undersize-errors" },
+	{ "tx-oversize-errors" },
+	{ "tx-64-byte-packets" },
+	{ "tx-65-127-byte-packets" },
+	{ "tx-128-255-byte-packets" },
+	{ "tx-256-511-byte-packets" },
+	{ "tx-512-1023-byte-packets" },
+	{ "tx-1024-1518-byte-packets" },
+};
+
+static int
+pasemi_mac_ethtool_get_settings(struct net_device *netdev,
+			       struct ethtool_cmd *cmd)
+{
+	struct pasemi_mac *mac = netdev_priv(netdev);
+	struct phy_device *phydev = mac->phydev;
+
+	return phy_ethtool_gset(phydev, cmd);
+}
+
+static void
+pasemi_mac_ethtool_get_drvinfo(struct net_device *netdev,
+			       struct ethtool_drvinfo *drvinfo)
+{
+	struct pasemi_mac *mac;
+	mac = netdev_priv(netdev);
+
+	/* clear and fill out info */
+	memset(drvinfo, 0, sizeof(struct ethtool_drvinfo));
+	strncpy(drvinfo->driver, "pasemi_mac", 12);
+	strcpy(drvinfo->version, "N/A");
+	strcpy(drvinfo->fw_version, "N/A");
+	strncpy(drvinfo->bus_info, pci_name(mac->pdev), 32);
+}
+
+static u32
+pasemi_mac_ethtool_get_msglevel(struct net_device *netdev)
+{
+	struct pasemi_mac *mac = netdev_priv(netdev);
+	return mac->msg_enable;
+}
+
+static void
+pasemi_mac_ethtool_set_msglevel(struct net_device *netdev,
+				u32 level)
+{
+	struct pasemi_mac *mac = netdev_priv(netdev);
+	mac->msg_enable = level;
+}
+
+
+static void
+pasemi_mac_ethtool_get_ringparam(struct net_device *netdev,
+				 struct ethtool_ringparam *ering)
+{
+	struct pasemi_mac *mac = netdev->priv;
+
+	ering->tx_max_pending = TX_RING_SIZE/2;
+	ering->tx_pending = RING_USED(mac->tx)/2;
+	ering->rx_max_pending = RX_RING_SIZE/4;
+	ering->rx_pending = RING_USED(mac->rx)/4;
+}
+
+static int pasemi_mac_get_sset_count(struct net_device *netdev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(ethtool_stats_keys);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void pasemi_mac_get_ethtool_stats(struct net_device *netdev,
+		struct ethtool_stats *stats, u64 *data)
+{
+	struct pasemi_mac *mac = netdev->priv;
+	int i;
+
+	data[0] = pasemi_read_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if))
+			>> PAS_DMA_RXINT_RCMDSTA_DROPS_S;
+	for (i = 0; i < 32; i++)
+		data[1+i] = pasemi_read_mac_reg(mac->dma_if, PAS_MAC_RMON(i));
+}
+
+static void pasemi_mac_get_strings(struct net_device *netdev, u32 stringset,
+				   u8 *data)
+{
+	memcpy(data, ethtool_stats_keys, sizeof(ethtool_stats_keys));
+}
+
+const struct ethtool_ops pasemi_mac_ethtool_ops = {
+	.get_settings		= pasemi_mac_ethtool_get_settings,
+	.get_drvinfo		= pasemi_mac_ethtool_get_drvinfo,
+	.get_msglevel		= pasemi_mac_ethtool_get_msglevel,
+	.set_msglevel		= pasemi_mac_ethtool_set_msglevel,
+	.get_link		= ethtool_op_get_link,
+	.get_ringparam          = pasemi_mac_ethtool_get_ringparam,
+	.get_strings		= pasemi_mac_get_strings,
+	.get_sset_count		= pasemi_mac_get_sset_count,
+	.get_ethtool_stats	= pasemi_mac_get_ethtool_stats,
+};
+

-- 

