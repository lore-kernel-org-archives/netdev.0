From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH net] ftgmac100: Mostly rewrite the driver
Date: Wed, 29 Mar 2017 15:40:46 +1100
Message-ID: <1490762446.3177.164.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36867 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752235AbdC2Ekw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 00:40:52 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v2T4ekrh005550
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 23:40:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an almost complete rewrite of this driver.

The patch overall multiplies the performance of the driver
on an AST2500 eval board with a gigabit link by 3 to 4.

I get arounnd 400Mbit/s with this vs. about 80Mbit/s with the current
driver using iperf3. I've done some tests on NC-SI machines as well,
I get close to peak (above 90Mbit/s).

It does that by, among other things, rewriting the receive and
transmit code, to both simplify the fast path as much as possible,
avoid flushing of the caches (the aspeed chips have really slow
little ARM cores), implementing support for fragmented sends,
fixing HW checksum generation (AST2500 only), etc...

In addition, I've added netpoll support, tx timeout recovery,
better handling of link speed changes, multicast filter
and promisc support, various ethtool config additions etc...

Finally, the code has been cleaned up and reorganized, and
various corner cases fixed, such as recovery in some error
situations.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
--

While I tried initially to do an incremental series of patch this
quickly became unrealistic as I rewrote more of the driver. This
is better reviewed as a new replacement driver for the same chip
instead. Since the Aspeed SoC is the only in-tree user and we are
maintaining this for OpenBMC, the risk is limited, I didn't feel
the need of submitting this as a separate driver and deprecate
the old one.

Checkpatch note: There are some remaining checkpatch complaints that
I chose not to address. The bulk is lines slightly over 80 characters
which I feel fixing would impair the readability of the code.
The ones about using BIT macros, I chose not to rewrite all the
original driver bit definitions. We can do that as a separate
mechanical patch later if needed. Finally the handful remaining
ones are personal style choices that in my opinion make the code
more pleasant to read.
---
 .../devicetree/bindings/net/ftgmac100.txt          |   37 +
 arch/arm/boot/dts/aspeed-g4.dtsi                   |    6 +-
 arch/arm/boot/dts/aspeed-g5.dtsi                   |    6 +-
 drivers/net/ethernet/faraday/ftgmac100.c           | 2182 +++++++++++---------
 drivers/net/ethernet/faraday/ftgmac100.h           |  182 +-
 5 files changed, 1450 insertions(+), 963 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/ftgmac100.txt

diff --git a/Documentation/devicetree/bindings/net/ftgmac100.txt b/Documentation/devicetree/bindings/net/ftgmac100.txt
new file mode 100644
index 0000000..1c47cda
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/ftgmac100.txt
@@ -0,0 +1,37 @@
+* Faraday Technology FTGMAC100 gigabit ethernet controller
+
+Required properties:
+- compatible: "faraday,ftgmac100"
+
+  Must also contain one of these if used as part of an Aspeed AST2400
+  or 2500 family SoC as they have some subtle tweaks to the
+  implementation:
+
+     - "aspeed,ast2400-mac"
+     - "aspeed,ast2500-mac"
+
+- reg: Address and length of the register set for the device
+- interrupts: Should contain ethernet controller interrupt
+
+Optional properties:
+- phy-mode: See ethernet.txt file in the same directory. If the property is
+  absent, "rgmii" is assumed. Supported values are "rgmii" and "rmii"
+- use-ncsi: Use the NC-SI stack instead of an MDIO PHY. Currently assumes
+  rmii (100bT) but kept as a separate property in case NC-SI grows support
+  for a gigabit link.
+- no-hw-checksum: Used to disable HW checksum support. Here for backward
+  compatibility as the driver now should have correct defaults based on
+  the SoC.
+- pinctrl related properties
+
+Example:
+
+	mac0: ethernet@1e660000 {
+		compatible = "aspeed,ast2500-mac", "faraday,ftgmac100";
+		reg = <0x1e660000 0x180>;
+		interrupts = <2>;
+		status = "okay";
+		use-ncsi;
+	};
+
+
diff --git a/arch/arm/boot/dts/aspeed-g4.dtsi b/arch/arm/boot/dts/aspeed-g4.dtsi
index 0b4932c..c79c937 100644
--- a/arch/arm/boot/dts/aspeed-g4.dtsi
+++ b/arch/arm/boot/dts/aspeed-g4.dtsi
@@ -42,18 +42,16 @@
 		};
 
 		mac0: ethernet@1e660000 {
-			compatible = "faraday,ftgmac100";
+			compatible = "aspeed,ast2400-mac", "faraday,ftgmac100";
 			reg = <0x1e660000 0x180>;
 			interrupts = <2>;
-			no-hw-checksum;
 			status = "disabled";
 		};
 
 		mac1: ethernet@1e680000 {
-			compatible = "faraday,ftgmac100";
+			compatible = "aspeed,ast2400-mac", "faraday,ftgmac100";
 			reg = <0x1e680000 0x180>;
 			interrupts = <3>;
-			no-hw-checksum;
 			status = "disabled";
 		};
 
diff --git a/arch/arm/boot/dts/aspeed-g5.dtsi b/arch/arm/boot/dts/aspeed-g5.dtsi
index b664fe3..b659663 100644
--- a/arch/arm/boot/dts/aspeed-g5.dtsi
+++ b/arch/arm/boot/dts/aspeed-g5.dtsi
@@ -33,18 +33,16 @@
 		};
 
 		mac0: ethernet@1e660000 {
-			compatible = "faraday,ftgmac100";
+			compatible = "aspeed,ast2500-mac", "faraday,ftgmac100";
 			reg = <0x1e660000 0x180>;
 			interrupts = <2>;
-			no-hw-checksum;
 			status = "disabled";
 		};
 
 		mac1: ethernet@1e680000 {
-			compatible = "faraday,ftgmac100";
+			compatible = "aspeed,ast2500-mac", "faraday,ftgmac100";
 			reg = <0x1e680000 0x180>;
 			interrupts = <3>;
-			no-hw-checksum;
 			status = "disabled";
 		};
 
diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 928b0df..0ef8c27 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -4,6 +4,10 @@
  * (C) Copyright 2009-2011 Faraday Technology
  * Po-Yu Chuang <ratbert@faraday-tech.com>
  *
+ * Largely rewritten by
+ *
+ * Benjamin Herrenschmidt, copyright 2017, IBM Corp.
+ *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 2 of the License, or
@@ -13,12 +17,7 @@
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
-
 #define pr_fmt(fmt)	KBUILD_MODNAME ": " fmt
 
 #include <linux/dma-mapping.h>
@@ -30,901 +29,1373 @@
 #include <linux/netdevice.h>
 #include <linux/phy.h>
 #include <linux/platform_device.h>
+#include <linux/crc32.h>
+#include <linux/delay.h>
 #include <net/ip.h>
 #include <net/ncsi.h>
 
 #include "ftgmac100.h"
 
 #define DRV_NAME	"ftgmac100"
-#define DRV_VERSION	"0.7"
+#define DRV_VERSION	"1.0"
 
-#define RX_QUEUE_ENTRIES	256	/* must be power of 2 */
-#define TX_QUEUE_ENTRIES	512	/* must be power of 2 */
+/* Arbitrary values, I am not sure the HW has limits */
+#define MAX_RX_QUEUE_ENTRIES	1024
+#define MAX_TX_QUEUE_ENTRIES	1024
+#define MIN_RX_QUEUE_ENTRIES	32
+#define MIN_TX_QUEUE_ENTRIES	32
 
-#define MAX_PKT_SIZE		1518
-#define RX_BUF_SIZE		PAGE_SIZE	/* must be smaller than 0x3fff */
+/* Defaults */
+#define DEF_RX_QUEUE_ENTRIES	128
+#define DEF_TX_QUEUE_ENTRIES	128
 
-/******************************************************************************
- * private data
- *****************************************************************************/
-struct ftgmac100_descs {
-	struct ftgmac100_rxdes rxdes[RX_QUEUE_ENTRIES];
-	struct ftgmac100_txdes txdes[TX_QUEUE_ENTRIES];
-};
+/* We don't do jumbo frames */
+#define MAX_PKT_SIZE		1536
+#define RX_BUF_SIZE		MAX_PKT_SIZE  /* must be smaller than 0x3fff */
+
+/* Min number of tx ring entries before stopping queue */
+#define TX_THRESHOLD		(MAX_SKB_FRAGS + 1)
 
 struct ftgmac100 {
+	/* Registers */
 	struct resource *res;
 	void __iomem *base;
-	int irq;
-
-	struct ftgmac100_descs *descs;
-	dma_addr_t descs_dma_addr;
-
-	struct page *rx_pages[RX_QUEUE_ENTRIES];
 
+	/* Rx ring */
+	unsigned int rx_q_entries;
+	struct ftgmac100_rxdes *rxdes;
+	dma_addr_t rxdes_dma;
+	struct sk_buff **rx_skbs;
 	unsigned int rx_pointer;
+
+	/* Tx ring */
+	struct ftgmac100_txdes *txdes;
+	dma_addr_t txdes_dma;
+	unsigned int tx_q_entries;
+	struct sk_buff **tx_skbs;
 	unsigned int tx_clean_pointer;
 	unsigned int tx_pointer;
-	unsigned int tx_pending;
 
-	spinlock_t tx_lock;
+	/* Used to signal the reset task of ring change request */
+	unsigned int new_rx_q_entries;
+	unsigned int new_tx_q_entries;
 
-	struct net_device *netdev;
+	/* Scratch page to use when rx skb alloc fails */
+	void *rx_scratch;
+	dma_addr_t rx_scratch_dma;
+
+	/* Component structures */
+	struct net_device *ndev;
 	struct device *dev;
-	struct ncsi_dev *ndev;
+	struct ncsi_dev *ncsidev;
 	struct napi_struct napi;
-
+	struct work_struct reset_task;
 	struct mii_bus *mii_bus;
-	int old_speed;
-	int int_mask_all;
+
+	/* Link management */
+	int cur_speed;
+	int cur_duplex;
 	bool use_ncsi;
-	bool enabled;
+
+	/* Multicast filter settings */
+	u32 maht0;
+	u32 maht1;
+
+	/* Tells the reset task to skip  */
+	bool stopping;
+	bool need_mac_restart;
+
+	/* Flow control settings */
+	bool tx_pause;
+	bool rx_pause;
+	bool aneg_pause;
 
 	u32 rxdes0_edorr_mask;
 	u32 txdes0_edotr_mask;
 };
 
-static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
-				   struct ftgmac100_rxdes *rxdes, gfp_t gfp);
-
-/******************************************************************************
- * internal functions (hardware register access)
- *****************************************************************************/
-static void ftgmac100_set_rx_ring_base(struct ftgmac100 *priv, dma_addr_t addr)
+static int ftgmac100_alloc_rx_buf(struct ftgmac100 *priv,
+				  unsigned int entry, gfp_t gfp)
 {
-	iowrite32(addr, priv->base + FTGMAC100_OFFSET_RXR_BADR);
-}
+	struct net_device *ndev = priv->ndev;
+	struct ftgmac100_rxdes *rxdes = &priv->rxdes[entry];
+	struct sk_buff *skb;
+	dma_addr_t map;
+	int err = 0;
 
-static void ftgmac100_set_rx_buffer_size(struct ftgmac100 *priv,
-		unsigned int size)
-{
-	size = FTGMAC100_RBSR_SIZE(size);
-	iowrite32(size, priv->base + FTGMAC100_OFFSET_RBSR);
-}
+	skb = netdev_alloc_skb_ip_align(ndev, RX_BUF_SIZE);
+	if (unlikely(!skb)) {
+		if (net_ratelimit())
+			netdev_err(ndev, "failed to allocate rx skb\n");
+		err = -ENOMEM;
+		map = priv->rx_scratch_dma;
+	} else {
+		map = dma_map_single(priv->dev, skb->data, RX_BUF_SIZE,
+				     DMA_FROM_DEVICE);
+		if (unlikely(dma_mapping_error(priv->dev, map))) {
+			if (net_ratelimit())
+				netdev_err(ndev, "failed to map rx page\n");
+			dev_kfree_skb_any(skb);
+			map = priv->rx_scratch_dma;
+			skb = NULL;
+			err = -ENOMEM;
+		}
+	}
 
-static void ftgmac100_set_normal_prio_tx_ring_base(struct ftgmac100 *priv,
-						   dma_addr_t addr)
-{
-	iowrite32(addr, priv->base + FTGMAC100_OFFSET_NPTXR_BADR);
-}
+	/* Store skb */
+	priv->rx_skbs[entry] = skb;
 
-static void ftgmac100_txdma_normal_prio_start_polling(struct ftgmac100 *priv)
-{
-	iowrite32(1, priv->base + FTGMAC100_OFFSET_NPTXPD);
+	/* Store DMA address into RX desc */
+	ftgmac100_rxdes_set_dma_addr(rxdes, map);
+
+	/* Ensure the above is ordered vs clearing the OWN bit */
+	dma_wmb();
+
+	/* Clean rxdes0 (which resets own bit) */
+	rxdes->rxdes0 &= cpu_to_le32(priv->rxdes0_edorr_mask);
+
+	return err;
 }
 
-static int ftgmac100_reset_hw(struct ftgmac100 *priv)
+static void ftgmac100_free_tx_packet(struct ftgmac100 *priv,
+				     unsigned int pointer,
+				     struct ftgmac100_txdes *txdes)
 {
-	struct net_device *netdev = priv->netdev;
-	int i;
+	struct sk_buff *skb = priv->tx_skbs[pointer];
+	dma_addr_t map = ftgmac100_txdes_get_dma_addr(txdes);
 
-	/* NOTE: reset clears all registers */
-	iowrite32(FTGMAC100_MACCR_SW_RST, priv->base + FTGMAC100_OFFSET_MACCR);
-	for (i = 0; i < 5; i++) {
-		unsigned int maccr;
+	if (ftgmac100_txdes_get_first_segment(txdes)) {
+		size_t len = skb_headlen(skb);
 
-		maccr = ioread32(priv->base + FTGMAC100_OFFSET_MACCR);
-		if (!(maccr & FTGMAC100_MACCR_SW_RST))
-			return 0;
-
-		udelay(1000);
+		if (skb_shinfo(skb)->nr_frags == 0 && len < ETH_ZLEN)
+			len = ETH_ZLEN;
+		dma_unmap_single(priv->dev, map, len, DMA_TO_DEVICE);
+	} else {
+		dma_unmap_page(priv->dev, map,
+			       ftgmac100_txdes_get_buffer_size(txdes),
+			       DMA_TO_DEVICE);
 	}
 
-	netdev_err(netdev, "software reset failed\n");
-	return -EIO;
+	if (ftgmac100_txdes_get_last_segment(txdes))
+		dev_kfree_skb_any(skb);
+	priv->tx_skbs[pointer] = NULL;
 }
 
-static void ftgmac100_set_mac(struct ftgmac100 *priv, const unsigned char *mac)
+static int ftgmac100_next_rx_pointer(struct ftgmac100 *priv, int pointer)
 {
-	unsigned int maddr = mac[0] << 8 | mac[1];
-	unsigned int laddr = mac[2] << 24 | mac[3] << 16 | mac[4] << 8 | mac[5];
-
-	iowrite32(maddr, priv->base + FTGMAC100_OFFSET_MAC_MADR);
-	iowrite32(laddr, priv->base + FTGMAC100_OFFSET_MAC_LADR);
+	return (pointer + 1) & (priv->rx_q_entries - 1);
 }
 
-static void ftgmac100_setup_mac(struct ftgmac100 *priv)
+static void ftgmac100_rx_packet_error(struct ftgmac100 *priv,
+				      struct ftgmac100_rxdes *rxdes)
 {
-	u8 mac[ETH_ALEN];
-	unsigned int m;
-	unsigned int l;
-	void *addr;
+	struct net_device *ndev = priv->ndev;
 
-	addr = device_get_mac_address(priv->dev, mac, ETH_ALEN);
-	if (addr) {
-		ether_addr_copy(priv->netdev->dev_addr, mac);
-		dev_info(priv->dev, "Read MAC address %pM from device tree\n",
-			 mac);
-		return;
-	}
+	if (ftgmac100_rxdes_rx_error(rxdes))
+		ndev->stats.rx_errors++;
 
-	m = ioread32(priv->base + FTGMAC100_OFFSET_MAC_MADR);
-	l = ioread32(priv->base + FTGMAC100_OFFSET_MAC_LADR);
+	if (ftgmac100_rxdes_crc_error(rxdes))
+		ndev->stats.rx_crc_errors++;
 
-	mac[0] = (m >> 8) & 0xff;
-	mac[1] = m & 0xff;
-	mac[2] = (l >> 24) & 0xff;
-	mac[3] = (l >> 16) & 0xff;
-	mac[4] = (l >> 8) & 0xff;
-	mac[5] = l & 0xff;
-
-	if (is_valid_ether_addr(mac)) {
-		ether_addr_copy(priv->netdev->dev_addr, mac);
-		dev_info(priv->dev, "Read MAC address %pM from chip\n", mac);
-	} else {
-		eth_hw_addr_random(priv->netdev);
-		dev_info(priv->dev, "Generated random MAC address %pM\n",
-			 priv->netdev->dev_addr);
-	}
+	if (ftgmac100_rxdes_frame_too_long(rxdes) ||
+	    ftgmac100_rxdes_runt(rxdes) ||
+	    ftgmac100_rxdes_odd_nibble(rxdes))
+		ndev->stats.rx_length_errors++;
 }
 
-static int ftgmac100_set_mac_addr(struct net_device *dev, void *p)
+static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 {
-	int ret;
-
-	ret = eth_prepare_mac_addr_change(dev, p);
-	if (ret < 0)
-		return ret;
+	struct net_device *ndev = priv->ndev;
+	struct ftgmac100_rxdes *rxdes;
+	struct sk_buff *skb;
+	unsigned int pointer, size;
+	dma_addr_t map;
 
-	eth_commit_mac_addr_change(dev, p);
-	ftgmac100_set_mac(netdev_priv(dev), dev->dev_addr);
+	/* Grab next RX descriptor */
+	pointer = priv->rx_pointer;
+	rxdes = &priv->rxdes[pointer];
 
-	return 0;
-}
+	/* Do we have a packet ? */
+	if (!ftgmac100_rxdes_packet_ready(rxdes))
+		return false;
 
-static void ftgmac100_init_hw(struct ftgmac100 *priv)
-{
-	/* setup ring buffer base registers */
-	ftgmac100_set_rx_ring_base(priv,
-				   priv->descs_dma_addr +
-				   offsetof(struct ftgmac100_descs, rxdes));
-	ftgmac100_set_normal_prio_tx_ring_base(priv,
-					       priv->descs_dma_addr +
-					       offsetof(struct ftgmac100_descs, txdes));
+	/* We don't cope with fragmented RX packets */
+	if (unlikely(!ftgmac100_rxdes_first_segment(rxdes) ||
+		     !ftgmac100_rxdes_last_segment(rxdes)))
+		goto drop;
 
-	ftgmac100_set_rx_buffer_size(priv, RX_BUF_SIZE);
+	/* Any error (other than csum offload) flagged ? */
+	if (unlikely(ftgmac100_rxdes_any_error(rxdes))) {
+		ftgmac100_rx_packet_error(priv, rxdes);
+		goto drop;
+	}
 
-	iowrite32(FTGMAC100_APTC_RXPOLL_CNT(1), priv->base + FTGMAC100_OFFSET_APTC);
+	/* Grab the corresponding skb */
+	skb = priv->rx_skbs[pointer];
+	if (unlikely(!skb)) {
+		netdev_err(ndev, "Missing skb in rx ring !\n");
+		goto drop;
+	}
 
-	ftgmac100_set_mac(priv, priv->netdev->dev_addr);
-}
+	/* Grab received size */
+	size = ftgmac100_rxdes_data_length(rxdes);
+	skb_put(skb, size);
 
-#define MACCR_ENABLE_ALL	(FTGMAC100_MACCR_TXDMA_EN	| \
-				 FTGMAC100_MACCR_RXDMA_EN	| \
-				 FTGMAC100_MACCR_TXMAC_EN	| \
-				 FTGMAC100_MACCR_RXMAC_EN	| \
-				 FTGMAC100_MACCR_FULLDUP	| \
-				 FTGMAC100_MACCR_CRC_APD	| \
-				 FTGMAC100_MACCR_RX_RUNT	| \
-				 FTGMAC100_MACCR_RX_BROADPKT)
+	/* Tear down DMA mapping, do necessary cache management */
+	map = ftgmac100_rxdes_get_dma_addr(rxdes);
 
-static void ftgmac100_start_hw(struct ftgmac100 *priv, int speed)
-{
-	int maccr = MACCR_ENABLE_ALL;
+#if defined(CONFIG_ARM) && !defined(CONFIG_ARM_DMA_USE_IOMMU)
+	/* When we don't have an iommu, we can save cycles by not
+	 * invalidating the cache for the part of the packet that
+	 * wasn't received.
+	 */
+	dma_unmap_single(priv->dev, map, size, DMA_FROM_DEVICE);
+#else
+	dma_unmap_single(priv->dev, map, RX_BUF_SIZE, DMA_FROM_DEVICE);
+#endif
+
+	/* Grab protocol and handle rx csum */
+	skb->protocol = eth_type_trans(skb, ndev);
+	if ((ndev->features & NETIF_F_RXCSUM) &&
+	    !ftgmac100_rxdes_csum_err(rxdes))
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	else
+		skb->ip_summed = CHECKSUM_NONE;
 
-	switch (speed) {
-	default:
-	case 10:
-		break;
+	/* Some stats ... */
+	if (unlikely(ftgmac100_rxdes_multicast(rxdes)))
+		ndev->stats.multicast++;
+	ndev->stats.rx_packets++;
+	ndev->stats.rx_bytes += size;
 
-	case 100:
-		maccr |= FTGMAC100_MACCR_FAST_MODE;
-		break;
+	/* Resplenish rx ring */
+	ftgmac100_alloc_rx_buf(priv, pointer, GFP_ATOMIC);
+	priv->rx_pointer = ftgmac100_next_rx_pointer(priv, pointer);
 
-	case 1000:
-		maccr |= FTGMAC100_MACCR_GIGA_MODE;
-		break;
-	}
+	/* push packet to protocol stack */
+	if (skb->ip_summed == CHECKSUM_NONE)
+		netif_receive_skb(skb);
+	else
+		napi_gro_receive(&priv->napi, skb);
 
-	iowrite32(maccr, priv->base + FTGMAC100_OFFSET_MACCR);
-}
+	(*processed)++;
+	return true;
 
-static void ftgmac100_stop_hw(struct ftgmac100 *priv)
-{
-	iowrite32(0, priv->base + FTGMAC100_OFFSET_MACCR);
+ drop:
+	/* Clean rxdes0 (which resets own bit) */
+	rxdes->rxdes0 &= cpu_to_le32(priv->rxdes0_edorr_mask);
+	priv->rx_pointer = ftgmac100_next_rx_pointer(priv, priv->rx_pointer);
+	ndev->stats.rx_dropped++;
+	return true;
 }
 
-/******************************************************************************
- * internal functions (receive descriptor)
- *****************************************************************************/
-static bool ftgmac100_rxdes_first_segment(struct ftgmac100_rxdes *rxdes)
+static int ftgmac100_next_tx_pointer(struct ftgmac100 *priv, int pointer)
 {
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_FRS);
+	return (pointer + 1) & (priv->tx_q_entries - 1);
 }
 
-static bool ftgmac100_rxdes_last_segment(struct ftgmac100_rxdes *rxdes)
+static u32 ftgmac100_tx_buf_avail(struct ftgmac100 *priv)
 {
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_LRS);
+	if (priv->tx_clean_pointer <= priv->tx_pointer)
+		return priv->tx_clean_pointer + (priv->tx_q_entries - 1)
+			- priv->tx_pointer;
+	else
+		return priv->tx_clean_pointer - priv->tx_pointer - 1;
 }
 
-static bool ftgmac100_rxdes_packet_ready(struct ftgmac100_rxdes *rxdes)
+static bool ftgmac100_tx_buf_cleanable(struct ftgmac100 *priv)
 {
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_RXPKT_RDY);
+	return priv->tx_pointer != priv->tx_clean_pointer;
 }
 
-static void ftgmac100_rxdes_set_dma_own(const struct ftgmac100 *priv,
-					struct ftgmac100_rxdes *rxdes)
+static bool ftgmac100_tx_complete_packet(struct ftgmac100 *priv)
 {
-	/* clear status bits */
-	rxdes->rxdes0 &= cpu_to_le32(priv->rxdes0_edorr_mask);
-}
+	struct net_device *ndev = priv->ndev;
+	struct ftgmac100_txdes *txdes;
+	struct sk_buff *skb;
+	unsigned int pointer = priv->tx_clean_pointer;
 
-static bool ftgmac100_rxdes_rx_error(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_RX_ERR);
-}
+	txdes = &priv->txdes[pointer];
+	if (ftgmac100_txdes_owned_by_dma(txdes))
+		return false;
 
-static bool ftgmac100_rxdes_crc_error(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_CRC_ERR);
-}
+	if (ftgmac100_txdes_get_last_segment(txdes)) {
+		skb = priv->tx_skbs[pointer];
+		ndev->stats.tx_packets++;
+		ndev->stats.tx_bytes += skb->len;
+	}
+	ftgmac100_free_tx_packet(priv, priv->tx_clean_pointer, txdes);
 
-static bool ftgmac100_rxdes_frame_too_long(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_FTL);
-}
+	/* Clear except end of ring bit */
+	txdes->txdes0 &= cpu_to_le32(priv->txdes0_edotr_mask);
+	txdes->txdes1 = 0;
 
-static bool ftgmac100_rxdes_runt(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_RUNT);
-}
+	priv->tx_clean_pointer = ftgmac100_next_tx_pointer(priv, pointer);
 
-static bool ftgmac100_rxdes_odd_nibble(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_RX_ODD_NB);
+	return true;
 }
 
-static unsigned int ftgmac100_rxdes_data_length(struct ftgmac100_rxdes *rxdes)
+static irqreturn_t ftgmac100_interrupt(int irq __always_unused, void *dev_id)
 {
-	return le32_to_cpu(rxdes->rxdes0) & FTGMAC100_RXDES0_VDBC;
-}
+	struct net_device *ndev = dev_id;
+	struct ftgmac100 *priv = netdev_priv(ndev);
+	unsigned int status, new_mask = FTGMAC100_INT_BAD;
 
-static bool ftgmac100_rxdes_multicast(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_MULTICAST);
-}
+	/* Fetch and clear interrupt bits, process abnormal ones */
+	status = ioread32(priv->base + FTGMAC100_OFFSET_ISR);
+	iowrite32(status, priv->base + FTGMAC100_OFFSET_ISR);
+	if (unlikely(status & FTGMAC100_INT_BAD)) {
+		/* RX buffer unavailable */
+		if (status & FTGMAC100_INT_NO_RXBUF)
+			ndev->stats.rx_over_errors++;
+
+		/* Received packet lost due to RX FIFO full */
+		if (status & FTGMAC100_INT_RPKT_LOST)
+			ndev->stats.rx_fifo_errors++;
+
+		/* AHB error -> Reset the chip */
+		if (status & FTGMAC100_INT_AHB_ERR) {
+			if (net_ratelimit())
+				netdev_warn(ndev, "AHB bus error ! Resetting chip.\n");
+			iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
+			schedule_work(&priv->reset_task);
+			return IRQ_HANDLED;
+		}
 
-static void ftgmac100_rxdes_set_end_of_ring(const struct ftgmac100 *priv,
-					    struct ftgmac100_rxdes *rxdes)
-{
-	rxdes->rxdes0 |= cpu_to_le32(priv->rxdes0_edorr_mask);
-}
+		/* We may need to restart the MAC after such errors, delay
+		 * this until after we have freed some Rx buffers though
+		 */
+		priv->need_mac_restart = true;
 
-static void ftgmac100_rxdes_set_dma_addr(struct ftgmac100_rxdes *rxdes,
-					 dma_addr_t addr)
-{
-	rxdes->rxdes3 = cpu_to_le32(addr);
-}
+		/* Disable those errors until we restart */
+		new_mask &= ~status;
+	}
 
-static dma_addr_t ftgmac100_rxdes_get_dma_addr(struct ftgmac100_rxdes *rxdes)
-{
-	return le32_to_cpu(rxdes->rxdes3);
-}
 
-static bool ftgmac100_rxdes_is_tcp(struct ftgmac100_rxdes *rxdes)
-{
-	return (rxdes->rxdes1 & cpu_to_le32(FTGMAC100_RXDES1_PROT_MASK)) ==
-	       cpu_to_le32(FTGMAC100_RXDES1_PROT_TCPIP);
-}
+	/* Only enable "bad" interrupts while NAPI is on */
+	iowrite32(new_mask, priv->base + FTGMAC100_OFFSET_IER);
 
-static bool ftgmac100_rxdes_is_udp(struct ftgmac100_rxdes *rxdes)
-{
-	return (rxdes->rxdes1 & cpu_to_le32(FTGMAC100_RXDES1_PROT_MASK)) ==
-	       cpu_to_le32(FTGMAC100_RXDES1_PROT_UDPIP);
-}
+	/* Schedule NAPI bh */
+	napi_schedule_irqoff(&priv->napi);
 
-static bool ftgmac100_rxdes_tcpcs_err(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes1 & cpu_to_le32(FTGMAC100_RXDES1_TCP_CHKSUM_ERR);
+	return IRQ_HANDLED;
 }
 
-static bool ftgmac100_rxdes_udpcs_err(struct ftgmac100_rxdes *rxdes)
+static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
+				     struct net_device *ndev)
 {
-	return rxdes->rxdes1 & cpu_to_le32(FTGMAC100_RXDES1_UDP_CHKSUM_ERR);
-}
+	struct ftgmac100 *priv = netdev_priv(ndev);
+	struct ftgmac100_txdes *txdes, *first;
+	int nfrags;
+	int pointer, len, i, j;
+	dma_addr_t map;
 
-static bool ftgmac100_rxdes_ipcs_err(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes1 & cpu_to_le32(FTGMAC100_RXDES1_IP_CHKSUM_ERR);
-}
+	if (unlikely(skb->len > MAX_PKT_SIZE)) {
+		if (net_ratelimit())
+			netdev_dbg(ndev, "tx packet too big\n");
+		goto drop;
+	}
 
-static inline struct page **ftgmac100_rxdes_page_slot(struct ftgmac100 *priv,
-						      struct ftgmac100_rxdes *rxdes)
-{
-	return &priv->rx_pages[rxdes - priv->descs->rxdes];
-}
+	/* The HW doesn't pad small frames */
+	if (skb_padto(skb, ETH_ZLEN) < 0) {
+		ndev->stats.tx_dropped++;
+		return NETDEV_TX_OK;
+	}
 
-/*
- * rxdes2 is not used by hardware. We use it to keep track of page.
- * Since hardware does not touch it, we can skip cpu_to_le32()/le32_to_cpu().
- */
-static void ftgmac100_rxdes_set_page(struct ftgmac100 *priv,
-				     struct ftgmac100_rxdes *rxdes,
-				     struct page *page)
-{
-	*ftgmac100_rxdes_page_slot(priv, rxdes) = page;
-}
+	/* Do we have a limit on #fragments ? I yet have to get a reply
+	 * from Aspeed. If there's one I haven't hit it.
+	 */
+	nfrags = skb_shinfo(skb)->nr_frags;
 
-static struct page *ftgmac100_rxdes_get_page(struct ftgmac100 *priv,
-					     struct ftgmac100_rxdes *rxdes)
-{
-	return *ftgmac100_rxdes_page_slot(priv, rxdes);
-}
+	/* Get header len and pad for non-fragmented packets */
+	len = skb_headlen(skb);
+	if (nfrags == 0 && len < ETH_ZLEN)
+		len = ETH_ZLEN;
 
-/******************************************************************************
- * internal functions (receive)
- *****************************************************************************/
-static int ftgmac100_next_rx_pointer(int pointer)
-{
-	return (pointer + 1) & (RX_QUEUE_ENTRIES - 1);
-}
+	/* Map the packet head */
+	map = dma_map_single(priv->dev, skb->data, len, DMA_TO_DEVICE);
+	if (dma_mapping_error(priv->dev, map)) {
+		if (net_ratelimit())
+			netdev_err(ndev, "map tx packet head failed\n");
+		goto drop;
+	}
 
-static void ftgmac100_rx_pointer_advance(struct ftgmac100 *priv)
-{
-	priv->rx_pointer = ftgmac100_next_rx_pointer(priv->rx_pointer);
-}
+	/* Grab the next free tx descriptor */
+	pointer = priv->tx_pointer;
+	txdes = first = &priv->txdes[pointer];
 
-static struct ftgmac100_rxdes *ftgmac100_current_rxdes(struct ftgmac100 *priv)
-{
-	return &priv->descs->rxdes[priv->rx_pointer];
-}
+	/* Setup it up. We don't set the OWN bit yet. */
+	priv->tx_skbs[pointer] = skb;
+	ftgmac100_txdes_set_dma_addr(txdes, map);
+	ftgmac100_txdes_set_buffer_size(txdes, len);
+	ftgmac100_txdes_set_first_segment(txdes);
 
-static struct ftgmac100_rxdes *
-ftgmac100_rx_locate_first_segment(struct ftgmac100 *priv)
-{
-	struct ftgmac100_rxdes *rxdes = ftgmac100_current_rxdes(priv);
+	/* Setup HW checksumming */
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		__be16 protocol = skb->protocol;
 
-	while (ftgmac100_rxdes_packet_ready(rxdes)) {
-		if (ftgmac100_rxdes_first_segment(rxdes))
-			return rxdes;
+		if (protocol == cpu_to_be16(ETH_P_IP)) {
+			u8 ip_proto = ip_hdr(skb)->protocol;
 
-		ftgmac100_rxdes_set_dma_own(priv, rxdes);
-		ftgmac100_rx_pointer_advance(priv);
-		rxdes = ftgmac100_current_rxdes(priv);
+			ftgmac100_txdes_set_ipcs(txdes);
+			if (ip_proto == IPPROTO_TCP)
+				ftgmac100_txdes_set_tcpcs(txdes);
+			else if (ip_proto == IPPROTO_UDP)
+				ftgmac100_txdes_set_udpcs(txdes);
+		} else if (skb_checksum_help(skb))
+			goto drop;
 	}
 
-	return NULL;
-}
+	/* Next descriptor */
+	pointer = ftgmac100_next_tx_pointer(priv, pointer);
 
-static bool ftgmac100_rx_packet_error(struct ftgmac100 *priv,
-				      struct ftgmac100_rxdes *rxdes)
-{
-	struct net_device *netdev = priv->netdev;
-	bool error = false;
+	/* Add the fragments */
+	for (i = 0; i < nfrags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-	if (unlikely(ftgmac100_rxdes_rx_error(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx err\n");
+		len = frag->size;
+
+		/* Map it */
+		map = skb_frag_dma_map(priv->dev, frag, 0, len,
+				       DMA_TO_DEVICE);
+		if (dma_mapping_error(priv->dev, map))
+			goto dma_err;
 
-		netdev->stats.rx_errors++;
-		error = true;
+		/* Setup descriptor */
+		priv->tx_skbs[pointer] = skb;
+		txdes = &priv->txdes[pointer];
+		ftgmac100_txdes_set_dma_addr(txdes, map);
+		ftgmac100_txdes_set_buffer_size(txdes, len);
+		ftgmac100_txdes_set_dma_own(txdes);
+
+		/* The spec is unclear, whether these need to be in the
+		 * first descriptor only or all of them. Gor now, do all
+		 * of them.
+		 */
+#define CSUM_MASK cpu_to_le32(FTGMAC100_TXDES1_TCP_CHKSUM | \
+			      FTGMAC100_TXDES1_UDP_CHKSUM | \
+			      FTGMAC100_TXDES1_IP_CHKSUM)
+		txdes->txdes1 |= first->txdes1 & CSUM_MASK;
+		pointer = ftgmac100_next_tx_pointer(priv, pointer);
 	}
 
-	if (unlikely(ftgmac100_rxdes_crc_error(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx crc err\n");
+	/* Tag last fragment */
+	ftgmac100_txdes_set_last_segment(txdes);
 
-		netdev->stats.rx_crc_errors++;
-		error = true;
-	} else if (unlikely(ftgmac100_rxdes_ipcs_err(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx IP checksum err\n");
+	/* Set the own bit on the first descriptor, this can cause the
+	 * HW to transmit, it needs to be ordered after all previous
+	 * stores.
+	 */
+	dma_wmb();
+	ftgmac100_txdes_set_dma_own(first);
+
+	/* Update next TX pointer */
+	priv->tx_pointer = pointer;
 
-		error = true;
+	/* If there isn't enough room for all the fragments of a new packet
+	 * in the TX ring, stop the queue. The sequence below is race free
+	 * vs. a concurrent restart in ftgmac100_poll()
+	 */
+	if (unlikely(ftgmac100_tx_buf_avail(priv) <= TX_THRESHOLD)) {
+		netif_stop_queue(ndev);
+		/* Order the queue stop with the test below */
+		smp_mb();
+		if (ftgmac100_tx_buf_avail(priv) > TX_THRESHOLD)
+			netif_wake_queue(ndev);
 	}
 
-	if (unlikely(ftgmac100_rxdes_frame_too_long(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx frame too long\n");
+	/* Poke transmitter to read the updated TX descriptors */
+	iowrite32(1, priv->base + FTGMAC100_OFFSET_NPTXPD);
 
-		netdev->stats.rx_length_errors++;
-		error = true;
-	} else if (unlikely(ftgmac100_rxdes_runt(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx runt\n");
+	return NETDEV_TX_OK;
 
-		netdev->stats.rx_length_errors++;
-		error = true;
-	} else if (unlikely(ftgmac100_rxdes_odd_nibble(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx odd nibble\n");
+ dma_err:
+	if (net_ratelimit())
+		netdev_dbg(ndev, "map tx fragment failed\n");
+
+	/* Free head */
+	pointer = priv->tx_pointer;
+	ftgmac100_free_tx_packet(priv, pointer, first);
 
-		netdev->stats.rx_length_errors++;
-		error = true;
+	/* Then all fragments */
+	for (j = 0; j < i; j++) {
+		pointer = ftgmac100_next_tx_pointer(priv, pointer);
+		txdes = &priv->txdes[pointer];
+		ftgmac100_free_tx_packet(priv, pointer, txdes);
 	}
 
-	return error;
+	/* This cannot be reached if we successfully mapped the
+	 * last fragment, so we know ftgmac100_free_tx_packet()
+	 * hasn't freed the skb yet.
+	 */
+ drop:
+	/* Drop the packet */
+	dev_kfree_skb_any(skb);
+	ndev->stats.tx_dropped++;
+
+	return NETDEV_TX_OK;
 }
 
-static void ftgmac100_rx_drop_packet(struct ftgmac100 *priv)
+static void ftgmac100_start_mac(struct ftgmac100 *priv)
 {
-	struct net_device *netdev = priv->netdev;
-	struct ftgmac100_rxdes *rxdes = ftgmac100_current_rxdes(priv);
-	bool done = false;
+	u32 maccr = ioread32(priv->base + FTGMAC100_OFFSET_MACCR);
 
-	if (net_ratelimit())
-		netdev_dbg(netdev, "drop packet %p\n", rxdes);
+	priv->need_mac_restart = false;
+
+	/* Keep the original GMAC and FAST bits */
+	maccr &= (FTGMAC100_MACCR_FAST_MODE | FTGMAC100_MACCR_GIGA_MODE);
 
-	do {
-		if (ftgmac100_rxdes_last_segment(rxdes))
-			done = true;
+	/* Add all the main enable bits */
+	maccr |= FTGMAC100_MACCR_TXDMA_EN	|
+		 FTGMAC100_MACCR_RXDMA_EN	|
+		 FTGMAC100_MACCR_TXMAC_EN	|
+		 FTGMAC100_MACCR_RXMAC_EN	|
+		 FTGMAC100_MACCR_CRC_APD	|
+		 FTGMAC100_MACCR_PHY_LINK_LEVEL	|
+		 FTGMAC100_MACCR_RX_RUNT	|
+		 FTGMAC100_MACCR_RX_BROADPKT;
 
-		ftgmac100_rxdes_set_dma_own(priv, rxdes);
-		ftgmac100_rx_pointer_advance(priv);
-		rxdes = ftgmac100_current_rxdes(priv);
-	} while (!done && ftgmac100_rxdes_packet_ready(rxdes));
+	/* Add other bits as needed */
+	if (priv->cur_duplex == DUPLEX_FULL)
+		maccr |= FTGMAC100_MACCR_FULLDUP;
+	if (priv->ndev->flags & IFF_PROMISC)
+		maccr |= FTGMAC100_MACCR_RX_ALL;
+	if (priv->ndev->flags & IFF_ALLMULTI)
+		maccr |= FTGMAC100_MACCR_RX_MULTIPKT;
+	else if (netdev_mc_count(priv->ndev))
+		maccr |= FTGMAC100_MACCR_HT_MULTI_EN;
 
-	netdev->stats.rx_dropped++;
+	/* Hit the HW */
+	iowrite32(maccr, priv->base + FTGMAC100_OFFSET_MACCR);
 }
 
-static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
+static void ftgmac100_stop_mac(struct ftgmac100 *priv)
 {
-	struct net_device *netdev = priv->netdev;
-	struct ftgmac100_rxdes *rxdes;
-	struct sk_buff *skb;
-	bool done = false;
+	iowrite32(0, priv->base + FTGMAC100_OFFSET_MACCR);
+}
 
-	rxdes = ftgmac100_rx_locate_first_segment(priv);
-	if (!rxdes)
-		return false;
+static int ftgmac100_poll(struct napi_struct *napi, int budget)
+{
+	struct ftgmac100 *priv = container_of(napi, struct ftgmac100, napi);
+	struct net_device *ndev = priv->ndev;
+	struct netdev_queue *txq;
+	int work_done = 0;
+	bool more;
+
+	/* Handle Tx packet reclaim */
+	if (ftgmac100_tx_buf_cleanable(priv)) {
+		while (ftgmac100_tx_buf_cleanable(priv) &&
+		       ftgmac100_tx_complete_packet(priv))
+			;
+		/* Restart queue if needed */
+		smp_mb();
+		if (unlikely(netif_queue_stopped(ndev) &&
+			     ftgmac100_tx_buf_avail(priv) > TX_THRESHOLD)) {
+			txq = netdev_get_tx_queue(ndev, 0);
+			__netif_tx_lock(txq, smp_processor_id());
+			if (netif_queue_stopped(ndev) &&
+			    ftgmac100_tx_buf_avail(priv) > TX_THRESHOLD)
+				netif_wake_queue(ndev);
+			__netif_tx_unlock(txq);
+		}
+	}
 
-	if (unlikely(ftgmac100_rx_packet_error(priv, rxdes))) {
-		ftgmac100_rx_drop_packet(priv);
-		return true;
+	/* Handle RX packets */
+	do
+		more = ftgmac100_rx_packet(priv, &work_done);
+	while (more && work_done < budget);
+
+	/* The interrupt is telling us to kick the MAC back to life
+	 * after an RX overflow
+	 */
+	if (unlikely(priv->need_mac_restart)) {
+		ftgmac100_start_mac(priv);
+
+		/* Re-enable "bad" interrupts */
+		iowrite32(FTGMAC100_INT_BAD,
+			  priv->base + FTGMAC100_OFFSET_IER);
 	}
 
-	/* start processing */
-	skb = netdev_alloc_skb_ip_align(netdev, 128);
-	if (unlikely(!skb)) {
-		if (net_ratelimit())
-			netdev_err(netdev, "rx skb alloc failed\n");
+	/* As long as we are waiting for transmit packets to be
+	 * completed we keep NAPI going
+	 */
+	if (ftgmac100_tx_buf_cleanable(priv))
+		work_done = budget;
+
+	/* Are we done ? */
+	if (work_done < budget) {
+		/* NAPI's over for now */
+		napi_complete(napi);
 
-		ftgmac100_rx_drop_packet(priv);
-		return true;
+		/* Enable all interrupts */
+		iowrite32(FTGMAC100_INT_ALL,
+			  priv->base + FTGMAC100_OFFSET_IER);
 	}
 
-	if (unlikely(ftgmac100_rxdes_multicast(rxdes)))
-		netdev->stats.multicast++;
+	return work_done;
+}
+
+static void ftgmac100_write_mac_addr(struct ftgmac100 *priv, const u8 *mac)
+{
+	unsigned int maddr = mac[0] << 8 | mac[1];
+	unsigned int laddr = mac[2] << 24 | mac[3] << 16 | mac[4] << 8 | mac[5];
+
+	iowrite32(maddr, priv->base + FTGMAC100_OFFSET_MAC_MADR);
+	iowrite32(laddr, priv->base + FTGMAC100_OFFSET_MAC_LADR);
+}
+
+static void ftgmac100_config_pause(struct ftgmac100 *priv)
+{
+	u32 fcr = FTGMAC100_FCR_PAUSE_TIME(16);
 
-	/*
-	 * It seems that HW does checksum incorrectly with fragmented packets,
-	 * so we are conservative here - if HW checksum error, let software do
-	 * the checksum again.
+	/* Throttle tx queue when receiving pause frames */
+	if (priv->rx_pause)
+		fcr |= FTGMAC100_FCR_FC_EN;
+
+	/* Enables sending pause frames when the RX queue is past a
+	 * certain threshold.
 	 */
-	if ((ftgmac100_rxdes_is_tcp(rxdes) && !ftgmac100_rxdes_tcpcs_err(rxdes)) ||
-	    (ftgmac100_rxdes_is_udp(rxdes) && !ftgmac100_rxdes_udpcs_err(rxdes)))
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	if (priv->tx_pause)
+		fcr |= FTGMAC100_FCR_FCTHR_EN;
 
-	do {
-		dma_addr_t map = ftgmac100_rxdes_get_dma_addr(rxdes);
-		struct page *page = ftgmac100_rxdes_get_page(priv, rxdes);
-		unsigned int size;
+	iowrite32(fcr, priv->base + FTGMAC100_OFFSET_FCR);
+}
 
-		dma_unmap_page(priv->dev, map, RX_BUF_SIZE, DMA_FROM_DEVICE);
+static void ftgmac100_init_hw(struct ftgmac100 *priv)
+{
+	u32 reg, rfifo_sz, tfifo_sz;
 
-		size = ftgmac100_rxdes_data_length(rxdes);
-		skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags, page, 0, size);
+	/* Clear stale interrupts */
+	reg = ioread32(priv->base + FTGMAC100_OFFSET_ISR);
+	iowrite32(reg, priv->base + FTGMAC100_OFFSET_ISR);
 
-		skb->len += size;
-		skb->data_len += size;
-		skb->truesize += PAGE_SIZE;
+	/* Setup RX ring buffer base */
+	iowrite32(priv->rxdes_dma, priv->base + FTGMAC100_OFFSET_RXR_BADR);
 
-		if (ftgmac100_rxdes_last_segment(rxdes))
-			done = true;
+	/* Setup TX ring buffer base */
+	iowrite32(priv->txdes_dma, priv->base + FTGMAC100_OFFSET_NPTXR_BADR);
 
-		ftgmac100_alloc_rx_page(priv, rxdes, GFP_ATOMIC);
+	/* Configure RX buffer size */
+	iowrite32(FTGMAC100_RBSR_SIZE(RX_BUF_SIZE),
+		  priv->base + FTGMAC100_OFFSET_RBSR);
 
-		ftgmac100_rx_pointer_advance(priv);
-		rxdes = ftgmac100_current_rxdes(priv);
-	} while (!done);
+	/* Set RX descriptor autopoll */
+	iowrite32(FTGMAC100_APTC_RXPOLL_CNT(1),
+		  priv->base + FTGMAC100_OFFSET_APTC);
 
-	/* Small frames are copied into linear part of skb to free one page */
-	if (skb->len <= 128) {
-		skb->truesize -= PAGE_SIZE;
-		__pskb_pull_tail(skb, skb->len);
-	} else {
-		/* We pull the minimum amount into linear part */
-		__pskb_pull_tail(skb, ETH_HLEN);
-	}
-	skb->protocol = eth_type_trans(skb, netdev);
+	/* Configure descriptor sizes and increase burst sizes according
+	 * to values in Aspeed SDK. The FIFO arbitration is enabled and
+	 * the thresholds set based on the recommended values in the
+	 * AST2400 specification.
+	 */
+	iowrite32(FTGMAC100_DBLAC_RXDES_SIZE(2) |   /* 2*8 bytes RX descs */
+		  FTGMAC100_DBLAC_TXDES_SIZE(2) |   /* 2*8 bytes TX descs */
+		  FTGMAC100_DBLAC_RXBURST_SIZE(3) | /* 512 bytes max RX bursts */
+		  FTGMAC100_DBLAC_TXBURST_SIZE(3) | /* 512 bytes max TX bursts */
+		  FTGMAC100_DBLAC_RX_THR_EN |       /* Enable fifo threshold arb */
+		  FTGMAC100_DBLAC_RXFIFO_HTHR(6) |  /* 6/8 of FIFO high threshold */
+		  FTGMAC100_DBLAC_RXFIFO_LTHR(2),   /* 2/8 of FIFO low threshold */
+		  priv->base + FTGMAC100_OFFSET_DBLAC);
+
+	/* Interrupt mitigation configured for 1 interrupt/packet. HW interrupt
+	 * mitigation doesn't seem to provide any benefit with NAPI so leave
+	 * it at that.
+	 */
+	iowrite32(FTGMAC100_ITC_RXINT_THR(1) |
+		  FTGMAC100_ITC_TXINT_THR(1),
+		  priv->base + FTGMAC100_OFFSET_ITC);
 
-	netdev->stats.rx_packets++;
-	netdev->stats.rx_bytes += skb->len;
+	/* Configure FIFO sizes in the TPAFCR register */
+	reg = ioread32(priv->base + FTGMAC100_OFFSET_FEAR);
+	rfifo_sz = reg & 0x00000007;
+	tfifo_sz = (reg >> 3) & 0x00000007;
+	reg = ioread32(priv->base + FTGMAC100_OFFSET_TPAFCR);
+	reg &= ~0x3f000000;
+	reg |= (tfifo_sz << 27);
+	reg |= (rfifo_sz << 24);
+	iowrite32(reg, priv->base + FTGMAC100_OFFSET_TPAFCR);
 
-	/* push packet to protocol stack */
-	napi_gro_receive(&priv->napi, skb);
+	/* Write MAC address */
+	ftgmac100_write_mac_addr(priv, priv->ndev->dev_addr);
 
-	(*processed)++;
-	return true;
+	/* Write multicast filters */
+	iowrite32(priv->maht0, priv->base + FTGMAC100_OFFSET_MAHT0);
+	iowrite32(priv->maht1, priv->base + FTGMAC100_OFFSET_MAHT1);
 }
 
-/******************************************************************************
- * internal functions (transmit descriptor)
- *****************************************************************************/
-static void ftgmac100_txdes_reset(const struct ftgmac100 *priv,
-				  struct ftgmac100_txdes *txdes)
+static int ftgmac100_reset_mac(struct ftgmac100 *priv, u32 maccr)
 {
-	/* clear all except end of ring bit */
-	txdes->txdes0 &= cpu_to_le32(priv->txdes0_edotr_mask);
-	txdes->txdes1 = 0;
-	txdes->txdes2 = 0;
-	txdes->txdes3 = 0;
-}
+	struct net_device *ndev = priv->ndev;
+	int i;
 
-static bool ftgmac100_txdes_owned_by_dma(struct ftgmac100_txdes *txdes)
-{
-	return txdes->txdes0 & cpu_to_le32(FTGMAC100_TXDES0_TXDMA_OWN);
-}
+	/* NOTE: reset clears all registers */
+	iowrite32(maccr, priv->base + FTGMAC100_OFFSET_MACCR);
+	iowrite32(maccr | FTGMAC100_MACCR_SW_RST,
+		  priv->base + FTGMAC100_OFFSET_MACCR);
+	for (i = 0; i < 50; i++) {
+		maccr = ioread32(priv->base + FTGMAC100_OFFSET_MACCR);
+		if (!(maccr & FTGMAC100_MACCR_SW_RST))
+			return 0;
+		udelay(1);
+	}
 
-static void ftgmac100_txdes_set_dma_own(struct ftgmac100_txdes *txdes)
-{
-	/*
-	 * Make sure dma own bit will not be set before any other
-	 * descriptor fields.
-	 */
-	wmb();
-	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_TXDMA_OWN);
+	netdev_err(ndev, "Hardware reset failed\n");
+	return -EIO;
 }
 
-static void ftgmac100_txdes_set_end_of_ring(const struct ftgmac100 *priv,
-					    struct ftgmac100_txdes *txdes)
+static int ftgmac100_reset_and_config_mac(struct ftgmac100 *priv)
 {
-	txdes->txdes0 |= cpu_to_le32(priv->txdes0_edotr_mask);
-}
+	u32 maccr = 0;
 
-static void ftgmac100_txdes_set_first_segment(struct ftgmac100_txdes *txdes)
-{
-	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_FTS);
-}
+	switch (priv->cur_speed) {
+	case SPEED_10:
+	case 0: /* no link */
+		break;
 
-static void ftgmac100_txdes_set_last_segment(struct ftgmac100_txdes *txdes)
-{
-	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_LTS);
+	case SPEED_100:
+		maccr |= FTGMAC100_MACCR_FAST_MODE;
+		break;
+
+	case SPEED_1000:
+		maccr |= FTGMAC100_MACCR_GIGA_MODE;
+		break;
+	default:
+		netdev_err(priv->ndev, "Unknown speed %d !\n", priv->cur_speed);
+		break;
+	}
+
+	/* (Re)initialize the queue pointers */
+	priv->rx_pointer = 0;
+	priv->tx_clean_pointer = 0;
+	priv->tx_pointer = 0;
+
+	/* The doc says reset twice with 10us interval */
+	if (ftgmac100_reset_mac(priv, maccr))
+		return -EIO;
+	usleep_range(10, 1000);
+	return ftgmac100_reset_mac(priv, maccr);
 }
 
-static void ftgmac100_txdes_set_buffer_size(struct ftgmac100_txdes *txdes,
-					    unsigned int len)
+static void ftgmac100_calc_mc_hash(struct ftgmac100 *priv)
 {
-	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_TXBUF_SIZE(len));
+	struct netdev_hw_addr *ha;
+
+	priv->maht1 = 0;
+	priv->maht0 = 0;
+	netdev_for_each_mc_addr(ha, priv->ndev) {
+		u32 crc_val = ether_crc_le(ETH_ALEN, ha->addr);
+
+		crc_val = (~(crc_val >> 2)) & 0x3f;
+		if (crc_val >= 32)
+			priv->maht1 |= 1ul << (crc_val - 32);
+		else
+			priv->maht0 |= 1ul << (crc_val);
+	}
 }
 
-static void ftgmac100_txdes_set_txint(struct ftgmac100_txdes *txdes)
+static void ftgmac100_set_rx_mode(struct net_device *ndev)
 {
-	txdes->txdes1 |= cpu_to_le32(FTGMAC100_TXDES1_TXIC);
+	struct ftgmac100 *priv = netdev_priv(ndev);
+
+	/* If we get passed some MC addresses, setup the hash filter */
+	if (netdev_mc_count(ndev)) {
+		ftgmac100_calc_mc_hash(priv);
+		iowrite32(priv->maht0, priv->base + FTGMAC100_OFFSET_MAHT0);
+		iowrite32(priv->maht1, priv->base + FTGMAC100_OFFSET_MAHT1);
+	}
+
+	/* Reconfigure MACCR */
+	ftgmac100_start_mac(priv);
 }
 
-static void ftgmac100_txdes_set_tcpcs(struct ftgmac100_txdes *txdes)
+static int ftgmac100_set_mac_addr(struct net_device *ndev, void *p)
 {
-	txdes->txdes1 |= cpu_to_le32(FTGMAC100_TXDES1_TCP_CHKSUM);
+	struct ftgmac100 *priv = netdev_priv(ndev);
+	int ret;
+
+	ret = eth_prepare_mac_addr_change(ndev, p);
+	if (ret < 0)
+		return ret;
+	ftgmac100_write_mac_addr(priv, p);
+	eth_commit_mac_addr_change(ndev, p);
+	return 0;
 }
 
-static void ftgmac100_txdes_set_udpcs(struct ftgmac100_txdes *txdes)
+static int ftgmac100_do_ioctl(struct net_device *ndev, struct ifreq *ifr,
+			      int cmd)
 {
-	txdes->txdes1 |= cpu_to_le32(FTGMAC100_TXDES1_UDP_CHKSUM);
+	if (!ndev->phydev)
+		return -ENXIO;
+
+	return phy_mii_ioctl(ndev->phydev, ifr, cmd);
 }
 
-static void ftgmac100_txdes_set_ipcs(struct ftgmac100_txdes *txdes)
+static void ftgmac100_get_drvinfo(struct net_device *ndev,
+				  struct ethtool_drvinfo *info)
 {
-	txdes->txdes1 |= cpu_to_le32(FTGMAC100_TXDES1_IP_CHKSUM);
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, dev_name(&ndev->dev), sizeof(info->bus_info));
 }
 
-static void ftgmac100_txdes_set_dma_addr(struct ftgmac100_txdes *txdes,
-					 dma_addr_t addr)
+static int ftgmac100_nway_reset(struct net_device *ndev)
 {
-	txdes->txdes3 = cpu_to_le32(addr);
+	if (!ndev->phydev)
+		return -ENXIO;
+	return phy_start_aneg(ndev->phydev);
 }
 
-static dma_addr_t ftgmac100_txdes_get_dma_addr(struct ftgmac100_txdes *txdes)
+static void ftgmac100_get_ringparam(struct net_device *ndev,
+				    struct ethtool_ringparam *ering)
 {
-	return le32_to_cpu(txdes->txdes3);
+	struct ftgmac100 *priv = netdev_priv(ndev);
+
+	memset(ering, 0, sizeof(*ering));
+	ering->rx_max_pending = MAX_RX_QUEUE_ENTRIES;
+	ering->tx_max_pending = MAX_TX_QUEUE_ENTRIES;
+	ering->rx_pending = priv->rx_q_entries;
+	ering->tx_pending = priv->tx_q_entries;
 }
 
-/*
- * txdes2 is not used by hardware. We use it to keep track of socket buffer.
- * Since hardware does not touch it, we can skip cpu_to_le32()/le32_to_cpu().
- */
-static void ftgmac100_txdes_set_skb(struct ftgmac100_txdes *txdes,
-				    struct sk_buff *skb)
+static int ftgmac100_set_ringparam(struct net_device *ndev,
+				   struct ethtool_ringparam *ering)
 {
-	txdes->txdes2 = (unsigned int)skb;
+	struct ftgmac100 *priv = netdev_priv(ndev);
+
+	if (ering->rx_pending > MAX_RX_QUEUE_ENTRIES ||
+	    ering->tx_pending > MAX_TX_QUEUE_ENTRIES ||
+	    ering->rx_pending < MIN_RX_QUEUE_ENTRIES ||
+	    ering->tx_pending < MIN_TX_QUEUE_ENTRIES ||
+	    !is_power_of_2(ering->rx_pending) ||
+	    !is_power_of_2(ering->tx_pending))
+		return -EINVAL;
+
+	priv->new_rx_q_entries = ering->rx_pending;
+	priv->new_tx_q_entries = ering->tx_pending;
+	if (netif_running(ndev))
+		schedule_work(&priv->reset_task);
+
+	return 0;
 }
 
-static struct sk_buff *ftgmac100_txdes_get_skb(struct ftgmac100_txdes *txdes)
+static void ftgmac100_get_pauseparam(struct net_device *ndev,
+				     struct ethtool_pauseparam *pause)
 {
-	return (struct sk_buff *)txdes->txdes2;
+	struct ftgmac100 *priv = netdev_priv(ndev);
+
+	pause->autoneg = priv->aneg_pause;
+	pause->tx_pause = priv->tx_pause;
+	pause->rx_pause = priv->rx_pause;
 }
 
-/******************************************************************************
- * internal functions (transmit)
- *****************************************************************************/
-static int ftgmac100_next_tx_pointer(int pointer)
+static int ftgmac100_set_pauseparam(struct net_device *ndev,
+				    struct ethtool_pauseparam *pause)
 {
-	return (pointer + 1) & (TX_QUEUE_ENTRIES - 1);
+	struct ftgmac100 *priv = netdev_priv(ndev);
+	struct phy_device *phydev = ndev->phydev;
+
+	priv->aneg_pause = pause->autoneg;
+	priv->tx_pause = pause->tx_pause;
+	priv->rx_pause = pause->rx_pause;
+
+	if (phydev) {
+		phydev->advertising &= ~ADVERTISED_Pause;
+		phydev->advertising &= ~ADVERTISED_Asym_Pause;
+
+		if (pause->rx_pause) {
+			phydev->advertising |= ADVERTISED_Pause;
+			phydev->advertising |= ADVERTISED_Asym_Pause;
+		}
+
+		if (pause->tx_pause)
+			phydev->advertising ^= ADVERTISED_Asym_Pause;
+	}
+	if (netif_running(ndev)) {
+		if (phydev && priv->aneg_pause)
+			phy_start_aneg(phydev);
+		else
+			ftgmac100_config_pause(priv);
+	}
+
+	return 0;
 }
 
-static void ftgmac100_tx_pointer_advance(struct ftgmac100 *priv)
+static const struct ethtool_ops ftgmac100_ethtool_ops = {
+	.get_drvinfo		= ftgmac100_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+	.get_link_ksettings	= phy_ethtool_get_link_ksettings,
+	.set_link_ksettings	= phy_ethtool_set_link_ksettings,
+	.nway_reset		= ftgmac100_nway_reset,
+	.get_ringparam		= ftgmac100_get_ringparam,
+	.set_ringparam		= ftgmac100_set_ringparam,
+	.get_pauseparam		= ftgmac100_get_pauseparam,
+	.set_pauseparam		= ftgmac100_set_pauseparam,
+};
+
+static void ftgmac100_free_tx_buffers(struct ftgmac100 *priv)
 {
-	priv->tx_pointer = ftgmac100_next_tx_pointer(priv->tx_pointer);
+	int i;
+
+	/* Free all tx buffers */
+	for (i = 0; i < priv->tx_q_entries; i++) {
+		struct ftgmac100_txdes *txdes = &priv->txdes[i];
+
+		if (!priv->tx_skbs[i])
+			continue;
+		ftgmac100_free_tx_packet(priv, i, txdes);
+	}
 }
 
-static void ftgmac100_tx_clean_pointer_advance(struct ftgmac100 *priv)
+static void ftgmac100_free_rx_buffers(struct ftgmac100 *priv)
 {
-	priv->tx_clean_pointer = ftgmac100_next_tx_pointer(priv->tx_clean_pointer);
+	int i;
+
+	/* Free all RX buffers */
+	for (i = 0; i < priv->rx_q_entries; i++) {
+		struct ftgmac100_rxdes *rxdes = &priv->rxdes[i];
+		struct sk_buff *skb = priv->rx_skbs[i];
+		dma_addr_t map = ftgmac100_rxdes_get_dma_addr(rxdes);
+
+		if (!skb)
+			continue;
+
+		priv->rx_skbs[i] = NULL;
+		dma_unmap_page(priv->dev, map, RX_BUF_SIZE, DMA_FROM_DEVICE);
+		dev_kfree_skb_any(skb);
+	}
 }
 
-static struct ftgmac100_txdes *ftgmac100_current_txdes(struct ftgmac100 *priv)
+static void ftgmac100_free_descriptors(struct ftgmac100 *priv)
 {
-	return &priv->descs->txdes[priv->tx_pointer];
+	/* Free skb arrays */
+	kfree(priv->rx_skbs);
+	kfree(priv->tx_skbs);
+
+	/* Free descriptor arrays */
+	if (priv->rxdes)
+		dma_free_coherent(priv->dev, MAX_RX_QUEUE_ENTRIES *
+				  sizeof(struct ftgmac100_rxdes),
+				  priv->rxdes, priv->rxdes_dma);
+	priv->rxdes = NULL;
+	if (priv->txdes)
+		dma_free_coherent(priv->dev, MAX_TX_QUEUE_ENTRIES *
+				  sizeof(struct ftgmac100_txdes),
+				  priv->txdes, priv->txdes_dma);
+	priv->txdes = NULL;
+
+	/* Free scratch packet buffer */
+	if (priv->rx_scratch)
+		dma_free_coherent(priv->dev, RX_BUF_SIZE,
+				  priv->rx_scratch, priv->rx_scratch_dma);
 }
 
-static struct ftgmac100_txdes *
-ftgmac100_current_clean_txdes(struct ftgmac100 *priv)
+static void ftgmac100_init_descriptors(struct ftgmac100 *priv)
 {
-	return &priv->descs->txdes[priv->tx_clean_pointer];
+	int i;
+
+	/* Update entries counts */
+	priv->rx_q_entries = priv->new_rx_q_entries;
+	priv->tx_q_entries = priv->new_tx_q_entries;
+
+	/* Clean all rx and tx descriptors and set the end-of-ring
+	 * marker on the last entry. For the RX descriptor, populate
+	 * all entries with a DMA address pointing to the scratch
+	 * page.
+	 */
+	for (i = 0; i < priv->rx_q_entries; i++) {
+		priv->rxdes[i].rxdes0 = 0;
+		ftgmac100_rxdes_set_dma_addr(&priv->rxdes[i],
+					     priv->rx_scratch_dma);
+	}
+	priv->rxdes[i - 1].rxdes0 = cpu_to_le32(priv->rxdes0_edorr_mask);
+	for (i = 0; i < priv->tx_q_entries; i++)
+		priv->txdes[i].txdes0 = 0;
+	priv->txdes[i - 1].txdes0 = cpu_to_le32(priv->txdes0_edotr_mask);
 }
 
-static bool ftgmac100_tx_complete_packet(struct ftgmac100 *priv)
+static int ftgmac100_alloc_descriptors(struct ftgmac100 *priv)
 {
-	struct net_device *netdev = priv->netdev;
-	struct ftgmac100_txdes *txdes;
-	struct sk_buff *skb;
-	dma_addr_t map;
+	/* Allocate skb arrays */
+	priv->rx_skbs = kcalloc(MAX_RX_QUEUE_ENTRIES, sizeof(void *),
+				GFP_KERNEL);
+	if (!priv->rx_skbs)
+		return -ENOMEM;
+	priv->tx_skbs = kcalloc(MAX_TX_QUEUE_ENTRIES, sizeof(void *),
+				GFP_KERNEL);
+	if (!priv->tx_skbs)
+		return -ENOMEM;
 
-	if (priv->tx_pending == 0)
-		return false;
+	/* Allocate descriptor arrays */
+	priv->rxdes = dma_zalloc_coherent(priv->dev,
+					  MAX_RX_QUEUE_ENTRIES *
+					  sizeof(struct ftgmac100_rxdes),
+					  &priv->rxdes_dma, GFP_KERNEL);
+	if (!priv->rxdes)
+		return -ENOMEM
+;	priv->txdes = dma_zalloc_coherent(priv->dev,
+					  MAX_TX_QUEUE_ENTRIES *
+					  sizeof(struct ftgmac100_txdes),
+					  &priv->txdes_dma, GFP_KERNEL);
+	if (!priv->txdes)
+		return -ENOMEM;
 
-	txdes = ftgmac100_current_clean_txdes(priv);
+	/* Allocate scratch packet buffer */
+	priv->rx_scratch = dma_alloc_coherent(priv->dev,
+					      RX_BUF_SIZE,
+					      &priv->rx_scratch_dma,
+					      GFP_KERNEL);
+	if (!priv->rx_scratch)
+		return -ENOMEM;
 
-	if (ftgmac100_txdes_owned_by_dma(txdes))
-		return false;
+	return 0;
+}
 
-	skb = ftgmac100_txdes_get_skb(txdes);
-	map = ftgmac100_txdes_get_dma_addr(txdes);
+static int ftgmac100_alloc_rx_buffers(struct ftgmac100 *priv)
+{
+	int i;
 
-	netdev->stats.tx_packets++;
-	netdev->stats.tx_bytes += skb->len;
+	/* Populate RX ring */
+	for (i = 0; i < priv->rx_q_entries; i++) {
+		/* Give up on error, the entries have been pre-populated
+		 * with the address of the scratch page
+		 */
+		if (ftgmac100_alloc_rx_buf(priv, i, GFP_KERNEL))
+			return -ENOMEM;
+	}
+	return 0;
+}
 
-	dma_unmap_single(priv->dev, map, skb_headlen(skb), DMA_TO_DEVICE);
+static void ftgmac100_init_all(struct ftgmac100 *priv)
+{
+	if (!netif_running(priv->ndev))
+		return;
 
-	dev_kfree_skb(skb);
+	/* Re-init descriptors (adjust queue sizes) */
+	ftgmac100_init_descriptors(priv);
 
-	ftgmac100_txdes_reset(priv, txdes);
+	/* Realloc rx descriptors */
+	ftgmac100_alloc_rx_buffers(priv);
 
-	ftgmac100_tx_clean_pointer_advance(priv);
+	/* Reinit and restart HW */
+	ftgmac100_init_hw(priv);
+	ftgmac100_config_pause(priv);
+	ftgmac100_start_mac(priv);
 
-	spin_lock(&priv->tx_lock);
-	priv->tx_pending--;
-	spin_unlock(&priv->tx_lock);
-	netif_wake_queue(netdev);
+	/* Re-enable the device */
+	napi_enable(&priv->napi);
+	netif_start_queue(priv->ndev);
 
-	return true;
+	/* Enable all interrupts */
+	iowrite32(FTGMAC100_INT_ALL, priv->base + FTGMAC100_OFFSET_IER);
 }
 
-static void ftgmac100_tx_complete(struct ftgmac100 *priv)
+static int ftgmac100_open(struct net_device *ndev)
 {
-	while (ftgmac100_tx_complete_packet(priv))
-		;
-}
+	struct ftgmac100 *priv = netdev_priv(ndev);
+	int err;
 
-static int ftgmac100_xmit(struct ftgmac100 *priv, struct sk_buff *skb,
-			  dma_addr_t map)
-{
-	struct net_device *netdev = priv->netdev;
-	struct ftgmac100_txdes *txdes;
-	unsigned int len = (skb->len < ETH_ZLEN) ? ETH_ZLEN : skb->len;
+	/* Clear stale stopping flag */
+	priv->stopping = false;
 
-	txdes = ftgmac100_current_txdes(priv);
-	ftgmac100_tx_pointer_advance(priv);
+	/* Allocate ring buffers and populate Rx ring */
+	err = ftgmac100_alloc_descriptors(priv);
+	if (err) {
+		netdev_err(ndev, "failed to allocate descriptors\n");
+		goto err_alloc;
+	}
 
-	/* setup TX descriptor */
-	ftgmac100_txdes_set_skb(txdes, skb);
-	ftgmac100_txdes_set_dma_addr(txdes, map);
-	ftgmac100_txdes_set_buffer_size(txdes, len);
+	/* When using NC-SI we force the speed to 100Mbit/s full duplex,
+	 *
+	 * Otherwise we leave it set to 0 (no link), the link
+	 * message from the PHY layer will handle setting it up to
+	 * something else if needed.
+	 */
+	if (priv->use_ncsi) {
+		priv->cur_duplex = DUPLEX_FULL;
+		priv->cur_speed = SPEED_100;
+	} else {
+		priv->cur_duplex = 0;
+		priv->cur_speed = 0;
+	}
 
-	ftgmac100_txdes_set_first_segment(txdes);
-	ftgmac100_txdes_set_last_segment(txdes);
-	ftgmac100_txdes_set_txint(txdes);
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		__be16 protocol = skb->protocol;
+	/* Reset the hardware */
+	err = ftgmac100_reset_and_config_mac(priv);
+	if (err)
+		goto err_hw;
 
-		if (protocol == cpu_to_be16(ETH_P_IP)) {
-			u8 ip_proto = ip_hdr(skb)->protocol;
+	/* Initialize NAPI */
+	netif_napi_add(ndev, &priv->napi, ftgmac100_poll, NAPI_POLL_WEIGHT);
 
-			ftgmac100_txdes_set_ipcs(txdes);
-			if (ip_proto == IPPROTO_TCP)
-				ftgmac100_txdes_set_tcpcs(txdes);
-			else if (ip_proto == IPPROTO_UDP)
-				ftgmac100_txdes_set_udpcs(txdes);
-		}
+	/* Disable all interrupts */
+	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
+
+	/* Grab our interrupt */
+	err = request_irq(ndev->irq, ftgmac100_interrupt, 0,
+			  ndev->name, ndev);
+	if (err) {
+		netdev_err(ndev, "failed to request irq %d\n", ndev->irq);
+		goto err_irq;
 	}
 
-	spin_lock(&priv->tx_lock);
-	priv->tx_pending++;
-	if (priv->tx_pending == TX_QUEUE_ENTRIES)
-		netif_stop_queue(netdev);
+	/* Start thing up */
+	ftgmac100_init_all(priv);
+	if (ndev->phydev) {
+		/* If we have a PHY, start polling */
+		phy_start(ndev->phydev);
+	} else if (priv->use_ncsi) {
+		/* If using NC-SI, set our carrier on and start the stack */
+		netif_carrier_on(ndev);
+
+		/* Start the NCSI device */
+		err = ncsi_start_dev(priv->ncsidev);
+		if (err)
+			goto err_ncsi;
+	}
+
+	return 0;
+
+ err_ncsi:
+	napi_disable(&priv->napi);
+	netif_stop_queue(ndev);
+	free_irq(ndev->irq, ndev);
+ err_irq:
+	netif_napi_del(&priv->napi);
+ err_hw:
+ err_alloc:
+	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
+	ftgmac100_free_tx_buffers(priv);
+	ftgmac100_free_rx_buffers(priv);
+	ftgmac100_free_descriptors(priv);
+	return err;
+}
+
+static int ftgmac100_stop(struct net_device *ndev)
+{
+	struct ftgmac100 *priv = netdev_priv(ndev);
 
-	/* start transmit */
-	ftgmac100_txdes_set_dma_own(txdes);
-	spin_unlock(&priv->tx_lock);
+	/* Block reset task */
+	priv->stopping = true;
 
-	ftgmac100_txdma_normal_prio_start_polling(priv);
+	/* Kill any pending one */
+	cancel_work_sync(&priv->reset_task);
 
-	return NETDEV_TX_OK;
-}
+	/* Disable all interrupts */
+	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
 
-/******************************************************************************
- * internal functions (buffer)
- *****************************************************************************/
-static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
-				   struct ftgmac100_rxdes *rxdes, gfp_t gfp)
-{
-	struct net_device *netdev = priv->netdev;
-	struct page *page;
-	dma_addr_t map;
+	/* Stop the PHY or NCSI */
+	if (ndev->phydev)
+		phy_stop(ndev->phydev);
+	else if (priv->use_ncsi)
+		ncsi_stop_dev(priv->ncsidev);
 
-	page = alloc_page(gfp);
-	if (!page) {
-		if (net_ratelimit())
-			netdev_err(netdev, "failed to allocate rx page\n");
-		return -ENOMEM;
-	}
+	/* Stop the network stack */
+	netif_stop_queue(ndev);
+	napi_disable(&priv->napi);
+	netif_napi_del(&priv->napi);
 
-	map = dma_map_page(priv->dev, page, 0, RX_BUF_SIZE, DMA_FROM_DEVICE);
-	if (unlikely(dma_mapping_error(priv->dev, map))) {
-		if (net_ratelimit())
-			netdev_err(netdev, "failed to map rx page\n");
-		__free_page(page);
-		return -ENOMEM;
-	}
+	/* Stop the HW */
+	ftgmac100_stop_mac(priv);
+
+	/* No more IRQ for us */
+	free_irq(ndev->irq, ndev);
+
+	/* Free everything */
+	ftgmac100_free_tx_buffers(priv);
+	ftgmac100_free_rx_buffers(priv);
+	ftgmac100_free_descriptors(priv);
 
-	ftgmac100_rxdes_set_page(priv, rxdes, page);
-	ftgmac100_rxdes_set_dma_addr(rxdes, map);
-	ftgmac100_rxdes_set_dma_own(priv, rxdes);
 	return 0;
 }
 
-static void ftgmac100_free_buffers(struct ftgmac100 *priv)
+static void ftgmac100_reset_task(struct work_struct *work)
 {
-	int i;
+	struct ftgmac100 *priv = container_of(work, struct ftgmac100, reset_task);
+	struct net_device *ndev = priv->ndev;
+	int err;
 
-	for (i = 0; i < RX_QUEUE_ENTRIES; i++) {
-		struct ftgmac100_rxdes *rxdes = &priv->descs->rxdes[i];
-		struct page *page = ftgmac100_rxdes_get_page(priv, rxdes);
-		dma_addr_t map = ftgmac100_rxdes_get_dma_addr(rxdes);
+	/* Adapter is going down */
+	if (priv->stopping)
+		return;
 
-		if (!page)
-			continue;
+	netdev_dbg(ndev, "Resetting NIC...\n");
 
-		dma_unmap_page(priv->dev, map, RX_BUF_SIZE, DMA_FROM_DEVICE);
-		__free_page(page);
-	}
+	/* Block PHY polling */
+	if (ndev->phydev)
+		mutex_lock(&ndev->phydev->lock);
 
-	for (i = 0; i < TX_QUEUE_ENTRIES; i++) {
-		struct ftgmac100_txdes *txdes = &priv->descs->txdes[i];
-		struct sk_buff *skb = ftgmac100_txdes_get_skb(txdes);
-		dma_addr_t map = ftgmac100_txdes_get_dma_addr(txdes);
+	rtnl_lock();
 
-		if (!skb)
-			continue;
+	/* Check if link state changed again */
+	if (priv->cur_speed == 0)
+		goto bail;
 
-		dma_unmap_single(priv->dev, map, skb_headlen(skb), DMA_TO_DEVICE);
-		kfree_skb(skb);
+	/* Stop the network stack */
+	netif_trans_update(ndev);
+	napi_disable(&priv->napi);
+	netif_tx_disable(ndev);
+
+	/* Stop and reset the MAC */
+	ftgmac100_stop_mac(priv);
+	err = ftgmac100_reset_and_config_mac(priv);
+	if (err) {
+		/* Not much we can do ... it might come back... */
+		netdev_err(ndev, "attempting to continue...\n");
 	}
 
-	dma_free_coherent(priv->dev, sizeof(struct ftgmac100_descs),
-			  priv->descs, priv->descs_dma_addr);
+	/* Free all rx and tx buffers */
+	ftgmac100_free_tx_buffers(priv);
+	ftgmac100_free_rx_buffers(priv);
+
+	/* Setup everything and restart chip */
+	ftgmac100_init_all(priv);
+
+	netdev_dbg(ndev, "Reset done !\n");
+ bail:
+	rtnl_unlock();
+
+	/* Unblock PHY polling */
+	if (ndev->phydev)
+		mutex_unlock(&ndev->phydev->lock);
 }
 
-static int ftgmac100_alloc_buffers(struct ftgmac100 *priv)
+static void ftgmac100_tx_timeout(struct net_device *ndev)
 {
-	int i;
+	struct ftgmac100 *priv = netdev_priv(ndev);
 
-	priv->descs = dma_zalloc_coherent(priv->dev,
-					  sizeof(struct ftgmac100_descs),
-					  &priv->descs_dma_addr, GFP_KERNEL);
-	if (!priv->descs)
-		return -ENOMEM;
+	/* Disable all interrupts */
+	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
 
-	/* initialize RX ring */
-	ftgmac100_rxdes_set_end_of_ring(priv,
-					&priv->descs->rxdes[RX_QUEUE_ENTRIES - 1]);
+	/* Do the reset outside of interrupt context */
+	schedule_work(&priv->reset_task);
+}
 
-	for (i = 0; i < RX_QUEUE_ENTRIES; i++) {
-		struct ftgmac100_rxdes *rxdes = &priv->descs->rxdes[i];
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void ftgmac100_netpoll(struct net_device *ndev)
+{
+	unsigned long flags;
 
-		if (ftgmac100_alloc_rx_page(priv, rxdes, GFP_KERNEL))
-			goto err;
-	}
+	disable_irq(dev->irq);
+	local_irq_save(flags);
+	ftgmac100_interrupt(dev->irq, ndev);
+	local_irq_restore(flags);
+	enable_irq(dev->irq);
+}
+#endif
 
-	/* initialize TX ring */
-	ftgmac100_txdes_set_end_of_ring(priv,
-					&priv->descs->txdes[TX_QUEUE_ENTRIES - 1]);
-	return 0;
+static const struct net_device_ops ftgmac100_netdev_ops = {
+	.ndo_open		= ftgmac100_open,
+	.ndo_stop		= ftgmac100_stop,
+	.ndo_start_xmit		= ftgmac100_hard_start_xmit,
+	.ndo_set_mac_address	= ftgmac100_set_mac_addr,
+	.ndo_set_rx_mode	= ftgmac100_set_rx_mode,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= ftgmac100_do_ioctl,
+	.ndo_tx_timeout		= ftgmac100_tx_timeout,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= ftgmac100_poll_controller,
+#endif
+};
 
-err:
-	ftgmac100_free_buffers(priv);
-	return -ENOMEM;
+static const char *ftgmac100_fctrl_string(struct ftgmac100 *priv)
+{
+	if (priv->tx_pause && priv->rx_pause)
+		return "rx/tx";
+	else if (priv->rx_pause)
+		return "rx";
+	else if (priv->tx_pause)
+		return "tx";
+	else
+		return "no";
 }
 
-/******************************************************************************
- * internal functions (mdio)
- *****************************************************************************/
-static void ftgmac100_adjust_link(struct net_device *netdev)
+static void ftgmac100_adjust_link(struct net_device *ndev)
 {
-	struct ftgmac100 *priv = netdev_priv(netdev);
-	struct phy_device *phydev = netdev->phydev;
-	int ier;
+	struct ftgmac100 *priv = netdev_priv(ndev);
+	struct phy_device *phydev = ndev->phydev;
+	bool tx_pause, rx_pause;
+
+	/* Link is down */
+	if (!phydev->link) {
+		if (priv->cur_speed)
+			netdev_info(ndev, "Link down\n");
+		priv->cur_speed = 0;
 
-	if (phydev->speed == priv->old_speed)
+		/* We just stop the MAC, we'll reset the adapter
+		 * if/when the link comes back up
+		 */
+		ftgmac100_stop_mac(priv);
 		return;
+	}
+
+	/* Grab pause settings from PHY if configured to do so */
+	if (priv->aneg_pause) {
+		rx_pause = tx_pause = phydev->pause;
+		if (phydev->asym_pause)
+			tx_pause = !rx_pause;
+	} else {
+		rx_pause = priv->rx_pause;
+		tx_pause = priv->tx_pause;
+	}
 
-	priv->old_speed = phydev->speed;
+	/* Link hasn't changed, do nothing */
+	if (phydev->speed == priv->cur_speed &&
+	    phydev->duplex == priv->cur_duplex &&
+	    rx_pause == priv->rx_pause &&
+	    tx_pause == priv->tx_pause)
+		return;
 
-	ier = ioread32(priv->base + FTGMAC100_OFFSET_IER);
+	priv->cur_speed = phydev->speed;
+	priv->cur_duplex = phydev->duplex;
+	priv->rx_pause = rx_pause;
+	priv->tx_pause = tx_pause;
 
-	/* disable all interrupts */
-	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
+	netdev_info(ndev, "Link up at %d Mbit/s %s duplex %s flow ctrl\n",
+		    priv->cur_speed,
+		    phydev->duplex == DUPLEX_FULL ? "full" : "half",
+		    ftgmac100_fctrl_string(priv));
 
-	netif_stop_queue(netdev);
-	ftgmac100_stop_hw(priv);
 
-	netif_start_queue(netdev);
-	ftgmac100_init_hw(priv);
-	ftgmac100_start_hw(priv, phydev->speed);
+	/* Disable all interrupts */
+	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
 
-	/* re-enable interrupts */
-	iowrite32(ier, priv->base + FTGMAC100_OFFSET_IER);
+	/* Reset the adapter asynchronously */
+	schedule_work(&priv->reset_task);
 }
 
-static int ftgmac100_mii_probe(struct ftgmac100 *priv)
+static int ftgmac100_mii_probe(struct ftgmac100 *priv, phy_interface_t intf)
 {
-	struct net_device *netdev = priv->netdev;
+	struct net_device *ndev = priv->ndev;
 	struct phy_device *phydev;
 
 	phydev = phy_find_first(priv->mii_bus);
 	if (!phydev) {
-		netdev_info(netdev, "%s: no PHY found\n", netdev->name);
+		netdev_info(ndev, "%s: no PHY found\n", ndev->name);
 		return -ENODEV;
 	}
 
-	phydev = phy_connect(netdev, phydev_name(phydev),
-			     &ftgmac100_adjust_link, PHY_INTERFACE_MODE_GMII);
+	phydev = phy_connect(ndev, phydev_name(phydev),
+			     &ftgmac100_adjust_link, intf);
 
 	if (IS_ERR(phydev)) {
-		netdev_err(netdev, "%s: Could not attach to PHY\n", netdev->name);
+		netdev_err(ndev, "%s: Could not attach to PHY\n", ndev->name);
 		return PTR_ERR(phydev);
 	}
 
+	/* Indicate that we support PAUSE frames (see comment in
+	 * Documentation/networking/phy.txt)
+	 */
+	phydev->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
+
+	phydev->advertising = phydev->supported;
+	phy_attached_info(phydev);
+
 	return 0;
 }
 
-/******************************************************************************
- * struct mii_bus functions
- *****************************************************************************/
-static int ftgmac100_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
+static int ftgmac100_mii_read(struct mii_bus *bus, int phy_addr, int regnum)
 {
-	struct net_device *netdev = bus->priv;
-	struct ftgmac100 *priv = netdev_priv(netdev);
+	struct net_device *ndev = bus->priv;
+	struct ftgmac100 *priv = netdev_priv(ndev);
 	unsigned int phycr;
 	int i;
 
@@ -952,15 +1423,15 @@ static int ftgmac100_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 		udelay(100);
 	}
 
-	netdev_err(netdev, "mdio read timed out\n");
+	netdev_err(ndev, "mdio read timed out\n");
 	return -EIO;
 }
 
-static int ftgmac100_mdiobus_write(struct mii_bus *bus, int phy_addr,
-				   int regnum, u16 value)
+static int ftgmac100_mii_write(struct mii_bus *bus, int phy_addr,
+			       int regnum, u16 value)
 {
-	struct net_device *netdev = bus->priv;
-	struct ftgmac100 *priv = netdev_priv(netdev);
+	struct net_device *ndev = bus->priv;
+	struct ftgmac100 *priv = netdev_priv(ndev);
 	unsigned int phycr;
 	int data;
 	int i;
@@ -988,269 +1459,17 @@ static int ftgmac100_mdiobus_write(struct mii_bus *bus, int phy_addr,
 		udelay(100);
 	}
 
-	netdev_err(netdev, "mdio write timed out\n");
+	netdev_err(ndev, "mdio write timed out\n");
 	return -EIO;
 }
 
-/******************************************************************************
- * struct ethtool_ops functions
- *****************************************************************************/
-static void ftgmac100_get_drvinfo(struct net_device *netdev,
-				  struct ethtool_drvinfo *info)
-{
-	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
-	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
-	strlcpy(info->bus_info, dev_name(&netdev->dev), sizeof(info->bus_info));
-}
-
-static const struct ethtool_ops ftgmac100_ethtool_ops = {
-	.get_drvinfo		= ftgmac100_get_drvinfo,
-	.get_link		= ethtool_op_get_link,
-	.get_link_ksettings	= phy_ethtool_get_link_ksettings,
-	.set_link_ksettings	= phy_ethtool_set_link_ksettings,
-};
-
-/******************************************************************************
- * interrupt handler
- *****************************************************************************/
-static irqreturn_t ftgmac100_interrupt(int irq, void *dev_id)
-{
-	struct net_device *netdev = dev_id;
-	struct ftgmac100 *priv = netdev_priv(netdev);
-
-	/* When running in NCSI mode, the interface should be ready for
-	 * receiving or transmitting NCSI packets before it's opened.
-	 */
-	if (likely(priv->use_ncsi || netif_running(netdev))) {
-		/* Disable interrupts for polling */
-		iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
-		napi_schedule(&priv->napi);
-	}
-
-	return IRQ_HANDLED;
-}
-
-/******************************************************************************
- * struct napi_struct functions
- *****************************************************************************/
-static int ftgmac100_poll(struct napi_struct *napi, int budget)
-{
-	struct ftgmac100 *priv = container_of(napi, struct ftgmac100, napi);
-	struct net_device *netdev = priv->netdev;
-	unsigned int status;
-	bool completed = true;
-	int rx = 0;
-
-	status = ioread32(priv->base + FTGMAC100_OFFSET_ISR);
-	iowrite32(status, priv->base + FTGMAC100_OFFSET_ISR);
-
-	if (status & (FTGMAC100_INT_RPKT_BUF | FTGMAC100_INT_NO_RXBUF)) {
-		/*
-		 * FTGMAC100_INT_RPKT_BUF:
-		 *	RX DMA has received packets into RX buffer successfully
-		 *
-		 * FTGMAC100_INT_NO_RXBUF:
-		 *	RX buffer unavailable
-		 */
-		bool retry;
-
-		do {
-			retry = ftgmac100_rx_packet(priv, &rx);
-		} while (retry && rx < budget);
-
-		if (retry && rx == budget)
-			completed = false;
-	}
-
-	if (status & (FTGMAC100_INT_XPKT_ETH | FTGMAC100_INT_XPKT_LOST)) {
-		/*
-		 * FTGMAC100_INT_XPKT_ETH:
-		 *	packet transmitted to ethernet successfully
-		 *
-		 * FTGMAC100_INT_XPKT_LOST:
-		 *	packet transmitted to ethernet lost due to late
-		 *	collision or excessive collision
-		 */
-		ftgmac100_tx_complete(priv);
-	}
-
-	if (status & priv->int_mask_all & (FTGMAC100_INT_NO_RXBUF |
-			FTGMAC100_INT_RPKT_LOST | FTGMAC100_INT_AHB_ERR)) {
-		if (net_ratelimit())
-			netdev_info(netdev, "[ISR] = 0x%x: %s%s%s\n", status,
-				    status & FTGMAC100_INT_NO_RXBUF ? "NO_RXBUF " : "",
-				    status & FTGMAC100_INT_RPKT_LOST ? "RPKT_LOST " : "",
-				    status & FTGMAC100_INT_AHB_ERR ? "AHB_ERR " : "");
-
-		if (status & FTGMAC100_INT_NO_RXBUF) {
-			/* RX buffer unavailable */
-			netdev->stats.rx_over_errors++;
-		}
-
-		if (status & FTGMAC100_INT_RPKT_LOST) {
-			/* received packet lost due to RX FIFO full */
-			netdev->stats.rx_fifo_errors++;
-		}
-	}
-
-	if (completed) {
-		napi_complete(napi);
-
-		/* enable all interrupts */
-		iowrite32(priv->int_mask_all,
-			  priv->base + FTGMAC100_OFFSET_IER);
-	}
-
-	return rx;
-}
-
-/******************************************************************************
- * struct net_device_ops functions
- *****************************************************************************/
-static int ftgmac100_open(struct net_device *netdev)
-{
-	struct ftgmac100 *priv = netdev_priv(netdev);
-	unsigned int status;
-	int err;
-
-	err = ftgmac100_alloc_buffers(priv);
-	if (err) {
-		netdev_err(netdev, "failed to allocate buffers\n");
-		goto err_alloc;
-	}
-
-	err = request_irq(priv->irq, ftgmac100_interrupt, 0, netdev->name, netdev);
-	if (err) {
-		netdev_err(netdev, "failed to request irq %d\n", priv->irq);
-		goto err_irq;
-	}
-
-	priv->rx_pointer = 0;
-	priv->tx_clean_pointer = 0;
-	priv->tx_pointer = 0;
-	priv->tx_pending = 0;
-
-	err = ftgmac100_reset_hw(priv);
-	if (err)
-		goto err_hw;
-
-	ftgmac100_init_hw(priv);
-	ftgmac100_start_hw(priv, priv->use_ncsi ? 100 : 10);
-
-	/* Clear stale interrupts */
-	status = ioread32(priv->base + FTGMAC100_OFFSET_ISR);
-	iowrite32(status, priv->base + FTGMAC100_OFFSET_ISR);
-
-	if (netdev->phydev)
-		phy_start(netdev->phydev);
-	else if (priv->use_ncsi)
-		netif_carrier_on(netdev);
-
-	napi_enable(&priv->napi);
-	netif_start_queue(netdev);
-
-	/* enable all interrupts */
-	iowrite32(priv->int_mask_all, priv->base + FTGMAC100_OFFSET_IER);
-
-	/* Start the NCSI device */
-	if (priv->use_ncsi) {
-		err = ncsi_start_dev(priv->ndev);
-		if (err)
-			goto err_ncsi;
-	}
-
-	priv->enabled = true;
-
-	return 0;
-
-err_ncsi:
-	napi_disable(&priv->napi);
-	netif_stop_queue(netdev);
-	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
-err_hw:
-	free_irq(priv->irq, netdev);
-err_irq:
-	ftgmac100_free_buffers(priv);
-err_alloc:
-	return err;
-}
-
-static int ftgmac100_stop(struct net_device *netdev)
-{
-	struct ftgmac100 *priv = netdev_priv(netdev);
-
-	if (!priv->enabled)
-		return 0;
-
-	/* disable all interrupts */
-	priv->enabled = false;
-	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
-
-	netif_stop_queue(netdev);
-	napi_disable(&priv->napi);
-	if (netdev->phydev)
-		phy_stop(netdev->phydev);
-	else if (priv->use_ncsi)
-		ncsi_stop_dev(priv->ndev);
-
-	ftgmac100_stop_hw(priv);
-	free_irq(priv->irq, netdev);
-	ftgmac100_free_buffers(priv);
-
-	return 0;
-}
-
-static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
-				     struct net_device *netdev)
-{
-	struct ftgmac100 *priv = netdev_priv(netdev);
-	dma_addr_t map;
-
-	if (unlikely(skb->len > MAX_PKT_SIZE)) {
-		if (net_ratelimit())
-			netdev_dbg(netdev, "tx packet too big\n");
-
-		netdev->stats.tx_dropped++;
-		kfree_skb(skb);
-		return NETDEV_TX_OK;
-	}
-
-	map = dma_map_single(priv->dev, skb->data, skb_headlen(skb), DMA_TO_DEVICE);
-	if (unlikely(dma_mapping_error(priv->dev, map))) {
-		/* drop packet */
-		if (net_ratelimit())
-			netdev_err(netdev, "map socket buffer failed\n");
-
-		netdev->stats.tx_dropped++;
-		kfree_skb(skb);
-		return NETDEV_TX_OK;
-	}
-
-	return ftgmac100_xmit(priv, skb, map);
-}
-
-/* optional */
-static int ftgmac100_do_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
-{
-	if (!netdev->phydev)
-		return -ENXIO;
-
-	return phy_mii_ioctl(netdev->phydev, ifr, cmd);
-}
-
-static const struct net_device_ops ftgmac100_netdev_ops = {
-	.ndo_open		= ftgmac100_open,
-	.ndo_stop		= ftgmac100_stop,
-	.ndo_start_xmit		= ftgmac100_hard_start_xmit,
-	.ndo_set_mac_address	= ftgmac100_set_mac_addr,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_do_ioctl		= ftgmac100_do_ioctl,
-};
-
-static int ftgmac100_setup_mdio(struct net_device *netdev)
+static int ftgmac100_setup_mdio(struct net_device *ndev)
 {
-	struct ftgmac100 *priv = netdev_priv(netdev);
+	struct ftgmac100 *priv = netdev_priv(ndev);
 	struct platform_device *pdev = to_platform_device(priv->dev);
+	phy_interface_t phy_intf = PHY_INTERFACE_MODE_RGMII;
+	struct device_node *np = pdev->dev.of_node;
+	const char *intf_prop = NULL;
 	int i, err = 0;
 	u32 reg;
 
@@ -1259,20 +1478,43 @@ static int ftgmac100_setup_mdio(struct net_device *netdev)
 	if (!priv->mii_bus)
 		return -EIO;
 
-	if (of_machine_is_compatible("aspeed,ast2400") ||
-	    of_machine_is_compatible("aspeed,ast2500")) {
+	if (np && (of_device_is_compatible(np, "aspeed,ast2400-mac") ||
+		   of_device_is_compatible(np, "aspeed,ast2500-mac"))) {
 		/* This driver supports the old MDIO interface */
 		reg = ioread32(priv->base + FTGMAC100_OFFSET_REVR);
 		reg &= ~FTGMAC100_REVR_NEW_MDIO_INTERFACE;
 		iowrite32(reg, priv->base + FTGMAC100_OFFSET_REVR);
-	};
+	}
 
+	/* Note: When using RGMII mode, we simply pass "RGMII" to the
+	 *       PHY and assume that u-boot will have configured the
+	 *       clock delays appropriately for the system.
+	 *
+	 *       The implementation of the MAC in the Aspeed chips
+	 *       supports sub-ns programable delays that need to be
+	 *       configured in the SCU while the MAC IP block is in
+	 *       reset.
+	 *
+	 *       If needed in the future, we can support configuring this
+	 *       here based on device-tree properties but unless absolutely
+	 *       needed I'd rather avoid poking at the SCU registers from
+	 *       this driver.
+	 */
+	if (np)
+		intf_prop = of_get_property(np, "phy-mode", NULL);
+	if (intf_prop) {
+		if (!strcasecmp(intf_prop, "rmii"))
+			phy_intf = PHY_INTERFACE_MODE_RMII;
+		else if (strcasecmp(intf_prop, "rgmii"))
+			netdev_warn(ndev, "Unsupported PHY interface '%s'\n",
+				    intf_prop);
+	}
 	priv->mii_bus->name = "ftgmac100_mdio";
 	snprintf(priv->mii_bus->id, MII_BUS_ID_SIZE, "%s-%d",
 		 pdev->name, pdev->id);
-	priv->mii_bus->priv = priv->netdev;
-	priv->mii_bus->read = ftgmac100_mdiobus_read;
-	priv->mii_bus->write = ftgmac100_mdiobus_write;
+	priv->mii_bus->priv = priv->ndev;
+	priv->mii_bus->read = ftgmac100_mii_read;
+	priv->mii_bus->write = ftgmac100_mii_write;
 
 	for (i = 0; i < PHY_MAX_ADDR; i++)
 		priv->mii_bus->irq[i] = PHY_POLL;
@@ -1283,7 +1525,7 @@ static int ftgmac100_setup_mdio(struct net_device *netdev)
 		goto err_register_mdiobus;
 	}
 
-	err = ftgmac100_mii_probe(priv);
+	err = ftgmac100_mii_probe(priv, phy_intf);
 	if (err) {
 		dev_err(priv->dev, "MII Probe failed!\n");
 		goto err_mii_probe;
@@ -1298,14 +1540,14 @@ static int ftgmac100_setup_mdio(struct net_device *netdev)
 	return err;
 }
 
-static void ftgmac100_destroy_mdio(struct net_device *netdev)
+static void ftgmac100_destroy_mdio(struct net_device *ndev)
 {
-	struct ftgmac100 *priv = netdev_priv(netdev);
+	struct ftgmac100 *priv = netdev_priv(ndev);
 
-	if (!netdev->phydev)
+	if (!ndev->phydev)
 		return;
 
-	phy_disconnect(netdev->phydev);
+	phy_disconnect(ndev->phydev);
 	mdiobus_unregister(priv->mii_bus);
 	mdiobus_free(priv->mii_bus);
 }
@@ -1319,16 +1561,48 @@ static void ftgmac100_ncsi_handler(struct ncsi_dev *nd)
 		    nd->link_up ? "up" : "down");
 }
 
-/******************************************************************************
- * struct platform_driver functions
- *****************************************************************************/
+static void ftgmac100_initial_mac(struct ftgmac100 *priv)
+{
+	u8 mac[ETH_ALEN];
+	unsigned int m;
+	unsigned int l;
+	void *addr;
+
+	addr = device_get_mac_address(priv->dev, mac, ETH_ALEN);
+	if (addr) {
+		ether_addr_copy(priv->ndev->dev_addr, mac);
+		dev_info(priv->dev, "Read MAC address %pM from device tree\n",
+			 mac);
+		return;
+	}
+
+	m = ioread32(priv->base + FTGMAC100_OFFSET_MAC_MADR);
+	l = ioread32(priv->base + FTGMAC100_OFFSET_MAC_LADR);
+
+	mac[0] = (m >> 8) & 0xff;
+	mac[1] = m & 0xff;
+	mac[2] = (l >> 24) & 0xff;
+	mac[3] = (l >> 16) & 0xff;
+	mac[4] = (l >> 8) & 0xff;
+	mac[5] = l & 0xff;
+
+	if (is_valid_ether_addr(mac)) {
+		ether_addr_copy(priv->ndev->dev_addr, mac);
+		dev_info(priv->dev, "Read MAC address %pM from chip\n", mac);
+	} else {
+		eth_hw_addr_random(priv->ndev);
+		dev_info(priv->dev, "Generated random MAC address %pM\n",
+			 priv->ndev->dev_addr);
+	}
+}
+
 static int ftgmac100_probe(struct platform_device *pdev)
 {
 	struct resource *res;
-	int irq;
-	struct net_device *netdev;
+	struct net_device *ndev;
 	struct ftgmac100 *priv;
-	int err = 0;
+	struct device_node *np;
+	int irq, err = 0;
 
 	if (!pdev)
 		return -ENODEV;
@@ -1342,28 +1616,37 @@ static int ftgmac100_probe(struct platform_device *pdev)
 		return irq;
 
 	/* setup net_device */
-	netdev = alloc_etherdev(sizeof(*priv));
-	if (!netdev) {
+	ndev = alloc_etherdev(sizeof(*priv));
+	if (!ndev) {
 		err = -ENOMEM;
 		goto err_alloc_etherdev;
 	}
 
-	SET_NETDEV_DEV(netdev, &pdev->dev);
+	SET_NETDEV_DEV(ndev, &pdev->dev);
 
-	netdev->ethtool_ops = &ftgmac100_ethtool_ops;
-	netdev->netdev_ops = &ftgmac100_netdev_ops;
+	ndev->ethtool_ops = &ftgmac100_ethtool_ops;
+	ndev->netdev_ops = &ftgmac100_netdev_ops;
+	ndev->irq = irq;
 
-	platform_set_drvdata(pdev, netdev);
+	platform_set_drvdata(pdev, ndev);
 
 	/* setup private data */
-	priv = netdev_priv(netdev);
-	priv->netdev = netdev;
+	priv = netdev_priv(ndev);
+	priv->ndev = ndev;
 	priv->dev = &pdev->dev;
+	priv->maht1 = 0;
+	priv->maht0 = 0;
+	INIT_WORK(&priv->reset_task, ftgmac100_reset_task);
 
-	spin_lock_init(&priv->tx_lock);
-
-	/* initialize NAPI */
-	netif_napi_add(netdev, &priv->napi, ftgmac100_poll, 64);
+	np = pdev->dev.of_node;
+	if (np && (of_device_is_compatible(np, "aspeed,ast2400-mac") ||
+		   of_device_is_compatible(np, "aspeed,ast2500-mac"))) {
+		priv->rxdes0_edorr_mask = BIT(30);
+		priv->txdes0_edotr_mask = BIT(30);
+	} else {
+		priv->rxdes0_edorr_mask = BIT(15);
+		priv->txdes0_edotr_mask = BIT(15);
+	}
 
 	/* map io memory */
 	priv->res = request_mem_region(res->start, resource_size(res),
@@ -1381,29 +1664,15 @@ static int ftgmac100_probe(struct platform_device *pdev)
 		goto err_ioremap;
 	}
 
-	priv->irq = irq;
+	/* Enable pause */
+	priv->tx_pause = true;
+	priv->rx_pause = true;
+	priv->aneg_pause = true;
 
 	/* MAC address from chip or random one */
-	ftgmac100_setup_mac(priv);
-
-	priv->int_mask_all = (FTGMAC100_INT_RPKT_LOST |
-			      FTGMAC100_INT_XPKT_ETH |
-			      FTGMAC100_INT_XPKT_LOST |
-			      FTGMAC100_INT_AHB_ERR |
-			      FTGMAC100_INT_RPKT_BUF |
-			      FTGMAC100_INT_NO_RXBUF);
+	ftgmac100_initial_mac(priv);
 
-	if (of_machine_is_compatible("aspeed,ast2400") ||
-	    of_machine_is_compatible("aspeed,ast2500")) {
-		priv->rxdes0_edorr_mask = BIT(30);
-		priv->txdes0_edotr_mask = BIT(30);
-	} else {
-		priv->rxdes0_edorr_mask = BIT(15);
-		priv->txdes0_edotr_mask = BIT(15);
-	}
-
-	if (pdev->dev.of_node &&
-	    of_get_property(pdev->dev.of_node, "use-ncsi", NULL)) {
+	if (np && of_get_property(np, "use-ncsi", NULL)) {
 		if (!IS_ENABLED(CONFIG_NET_NCSI)) {
 			dev_err(&pdev->dev, "NCSI stack not enabled\n");
 			goto err_ncsi_dev;
@@ -1411,67 +1680,80 @@ static int ftgmac100_probe(struct platform_device *pdev)
 
 		dev_info(&pdev->dev, "Using NCSI interface\n");
 		priv->use_ncsi = true;
-		priv->ndev = ncsi_register_dev(netdev, ftgmac100_ncsi_handler);
+		priv->ncsidev = ncsi_register_dev(ndev, ftgmac100_ncsi_handler);
 		if (!priv->ndev)
 			goto err_ncsi_dev;
 	} else {
 		priv->use_ncsi = false;
-		err = ftgmac100_setup_mdio(netdev);
+		err = ftgmac100_setup_mdio(ndev);
 		if (err)
 			goto err_setup_mdio;
 	}
 
-	/* We have to disable on-chip IP checksum functionality
-	 * when NCSI is enabled on the interface. It doesn't work
-	 * in that case.
-	 */
-	netdev->features = NETIF_F_IP_CSUM | NETIF_F_GRO;
-	if (priv->use_ncsi &&
-	    of_get_property(pdev->dev.of_node, "no-hw-checksum", NULL))
-		netdev->features &= ~NETIF_F_IP_CSUM;
+	/* Default ring sizes */
+	priv->rx_q_entries = priv->new_rx_q_entries = DEF_RX_QUEUE_ENTRIES;
+	priv->tx_q_entries = priv->new_tx_q_entries = DEF_TX_QUEUE_ENTRIES;
 
+	/* Setup feature set */
+	ndev->hw_features = NETIF_F_RXCSUM | NETIF_F_IP_CSUM |
+		NETIF_F_GRO | NETIF_F_SG;
+	/* AST2400  doesn't have working HW checksum generation */
+	if (np && of_device_is_compatible(np, "aspeed,ast2400-mac"))
+		ndev->hw_features &= ~NETIF_F_IP_CSUM;
+	if (np && of_get_property(np, "no-hw-checksum", NULL))
+		ndev->hw_features &= ~(NETIF_F_IP_CSUM | NETIF_F_RXCSUM);
+	ndev->features |= ndev->hw_features;
 
 	/* register network device */
-	err = register_netdev(netdev);
+	err = register_netdev(ndev);
 	if (err) {
 		dev_err(&pdev->dev, "Failed to register netdev\n");
 		goto err_register_netdev;
 	}
 
-	netdev_info(netdev, "irq %d, mapped at %p\n", priv->irq, priv->base);
+	netdev_info(ndev, "irq %d, mapped at %p\n", ndev->irq, priv->base);
 
 	return 0;
 
 err_ncsi_dev:
 err_register_netdev:
-	ftgmac100_destroy_mdio(netdev);
+	ftgmac100_destroy_mdio(ndev);
 err_setup_mdio:
 	iounmap(priv->base);
 err_ioremap:
 	release_resource(priv->res);
 err_req_mem:
-	netif_napi_del(&priv->napi);
-	free_netdev(netdev);
+	free_netdev(ndev);
 err_alloc_etherdev:
 	return err;
 }
 
 static int ftgmac100_remove(struct platform_device *pdev)
 {
-	struct net_device *netdev;
+	struct net_device *ndev;
 	struct ftgmac100 *priv;
 
-	netdev = platform_get_drvdata(pdev);
-	priv = netdev_priv(netdev);
+	ndev = platform_get_drvdata(pdev);
+	priv = netdev_priv(ndev);
+
+	/* Preent the reset task from kicking early on */
+	priv->stopping = true;
+
+	/* Close & unregister the netdevice, at this points
+	 * the interrupt will be disabled
+	 */
+	unregister_netdev(ndev);
+
+	/* There's a small chance the reset task will have been re-queued,
+	 * during stop, make sure it's gone before we free the structure.
+	 */
+	cancel_work_sync(&priv->reset_task);
 
-	unregister_netdev(netdev);
-	ftgmac100_destroy_mdio(netdev);
+	ftgmac100_destroy_mdio(ndev);
 
 	iounmap(priv->base);
 	release_resource(priv->res);
-
-	netif_napi_del(&priv->napi);
-	free_netdev(netdev);
+	free_netdev(ndev);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/faraday/ftgmac100.h b/drivers/net/ethernet/faraday/ftgmac100.h
index a7ce0ac..00271a9 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.h
+++ b/drivers/net/ethernet/faraday/ftgmac100.h
@@ -86,6 +86,19 @@
 #define FTGMAC100_INT_PHYSTS_CHG	(1 << 9)
 #define FTGMAC100_INT_NO_HPTXBUF	(1 << 10)
 
+/* These are all the interrupts we care about */
+#define FTGMAC100_INT_ALL (FTGMAC100_INT_RPKT_LOST |	\
+			   FTGMAC100_INT_XPKT_ETH |	\
+			   FTGMAC100_INT_XPKT_LOST |	\
+			   FTGMAC100_INT_AHB_ERR |	\
+			   FTGMAC100_INT_RPKT_BUF |	\
+			   FTGMAC100_INT_NO_RXBUF)
+
+/* These are the interrupts we care about in NAPI mode */
+#define FTGMAC100_INT_BAD (FTGMAC100_INT_RPKT_LOST |	\
+			   FTGMAC100_INT_AHB_ERR |	\
+			   FTGMAC100_INT_NO_RXBUF)
+
 /*
  * Interrupt timer control register
  */
@@ -185,6 +198,13 @@
 #define FTGMAC100_PHYDATA_MIIRDATA(phydata)	(((phydata) >> 16) & 0xffff)
 
 /*
+ * Flow control register
+ */
+#define FTGMAC100_FCR_FC_EN		(1 << 0)
+#define FTGMAC100_FCR_FCTHR_EN		(1 << 2)
+#define FTGMAC100_FCR_PAUSE_TIME(x)	(((x) & 0xffff) << 16)
+
+/*
  * Transmit descriptor, aligned to 16 bytes
  */
 struct ftgmac100_txdes {
@@ -209,6 +229,78 @@ struct ftgmac100_txdes {
 #define FTGMAC100_TXDES1_TX2FIC		(1 << 30)
 #define FTGMAC100_TXDES1_TXIC		(1 << 31)
 
+static inline bool ftgmac100_txdes_owned_by_dma(struct ftgmac100_txdes *txdes)
+{
+	return txdes->txdes0 & cpu_to_le32(FTGMAC100_TXDES0_TXDMA_OWN);
+}
+
+static inline void ftgmac100_txdes_set_dma_own(struct ftgmac100_txdes *txdes)
+{
+	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_TXDMA_OWN);
+}
+
+static inline void ftgmac100_txdes_set_first_segment(struct ftgmac100_txdes *txdes)
+{
+	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_FTS);
+}
+
+static inline bool ftgmac100_txdes_get_first_segment(struct ftgmac100_txdes *txdes)
+{
+	return (txdes->txdes0 & cpu_to_le32(FTGMAC100_TXDES0_FTS)) != 0;
+}
+
+static inline void ftgmac100_txdes_set_last_segment(struct ftgmac100_txdes *txdes)
+{
+	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_LTS);
+}
+
+static inline bool ftgmac100_txdes_get_last_segment(struct ftgmac100_txdes *txdes)
+{
+	return (txdes->txdes0 & cpu_to_le32(FTGMAC100_TXDES0_LTS)) != 0;
+}
+
+static inline void ftgmac100_txdes_set_buffer_size(struct ftgmac100_txdes *txdes,
+						   unsigned int len)
+{
+	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_TXBUF_SIZE(len));
+}
+
+static inline unsigned int ftgmac100_txdes_get_buffer_size(struct ftgmac100_txdes *txdes)
+{
+	return FTGMAC100_TXDES0_TXBUF_SIZE(cpu_to_le32(txdes->txdes0));
+}
+
+static inline void ftgmac100_txdes_set_txint(struct ftgmac100_txdes *txdes)
+{
+	txdes->txdes1 |= cpu_to_le32(FTGMAC100_TXDES1_TXIC);
+}
+
+static inline void ftgmac100_txdes_set_tcpcs(struct ftgmac100_txdes *txdes)
+{
+	txdes->txdes1 |= cpu_to_le32(FTGMAC100_TXDES1_TCP_CHKSUM);
+}
+
+static inline void ftgmac100_txdes_set_udpcs(struct ftgmac100_txdes *txdes)
+{
+	txdes->txdes1 |= cpu_to_le32(FTGMAC100_TXDES1_UDP_CHKSUM);
+}
+
+static inline void ftgmac100_txdes_set_ipcs(struct ftgmac100_txdes *txdes)
+{
+	txdes->txdes1 |= cpu_to_le32(FTGMAC100_TXDES1_IP_CHKSUM);
+}
+
+static inline void ftgmac100_txdes_set_dma_addr(struct ftgmac100_txdes *txdes,
+						dma_addr_t addr)
+{
+	txdes->txdes3 = cpu_to_le32(addr);
+}
+
+static inline dma_addr_t ftgmac100_txdes_get_dma_addr(struct ftgmac100_txdes *txdes)
+{
+	return le32_to_cpu(txdes->txdes3);
+}
+
 /*
  * Receive descriptor, aligned to 16 bytes
  */
@@ -235,11 +327,11 @@ struct ftgmac100_rxdes {
 #define FTGMAC100_RXDES0_RXPKT_RDY	(1 << 31)
 
 #define FTGMAC100_RXDES1_VLANTAG_CI	0xffff
-#define FTGMAC100_RXDES1_PROT_MASK	(0x3 << 20)
-#define FTGMAC100_RXDES1_PROT_NONIP	(0x0 << 20)
-#define FTGMAC100_RXDES1_PROT_IP	(0x1 << 20)
-#define FTGMAC100_RXDES1_PROT_TCPIP	(0x2 << 20)
-#define FTGMAC100_RXDES1_PROT_UDPIP	(0x3 << 20)
+#define FTGMAC100_RXDES1_PROT(x)	(((x) >> 20) & 3)
+#define   FTGMAC100_PROT_NONIP	0
+#define   FTGMAC100_PROT_IP	1
+#define   FTGMAC100_PROT_TCPIP	2
+#define   FTGMAC100_PROT_UDPIP	3
 #define FTGMAC100_RXDES1_LLC		(1 << 22)
 #define FTGMAC100_RXDES1_DF		(1 << 23)
 #define FTGMAC100_RXDES1_VLANTAG_AVAIL	(1 << 24)
@@ -247,4 +339,84 @@ struct ftgmac100_rxdes {
 #define FTGMAC100_RXDES1_UDP_CHKSUM_ERR	(1 << 26)
 #define FTGMAC100_RXDES1_IP_CHKSUM_ERR	(1 << 27)
 
+static bool ftgmac100_rxdes_first_segment(struct ftgmac100_rxdes *rxdes)
+{
+	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_FRS);
+}
+
+static bool ftgmac100_rxdes_last_segment(struct ftgmac100_rxdes *rxdes)
+{
+	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_LRS);
+}
+
+static bool ftgmac100_rxdes_packet_ready(struct ftgmac100_rxdes *rxdes)
+{
+	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_RXPKT_RDY);
+}
+
+#define RXDES0_ANY_ERROR		( \
+	FTGMAC100_RXDES0_RX_ERR		| \
+	FTGMAC100_RXDES0_CRC_ERR	| \
+	FTGMAC100_RXDES0_FTL		| \
+	FTGMAC100_RXDES0_RUNT		| \
+	FTGMAC100_RXDES0_RX_ODD_NB)
+
+static inline bool ftgmac100_rxdes_any_error(struct ftgmac100_rxdes *rxdes)
+{
+	return rxdes->rxdes0 & cpu_to_le32(RXDES0_ANY_ERROR);
+}
+
+static inline bool ftgmac100_rxdes_rx_error(struct ftgmac100_rxdes *rxdes)
+{
+	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_RX_ERR);
+}
+
+static inline bool ftgmac100_rxdes_crc_error(struct ftgmac100_rxdes *rxdes)
+{
+	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_CRC_ERR);
+}
+
+static inline bool ftgmac100_rxdes_frame_too_long(struct ftgmac100_rxdes *rxdes)
+{
+	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_FTL);
+}
+
+static inline bool ftgmac100_rxdes_runt(struct ftgmac100_rxdes *rxdes)
+{
+	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_RUNT);
+}
+
+static inline bool ftgmac100_rxdes_odd_nibble(struct ftgmac100_rxdes *rxdes)
+{
+	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_RX_ODD_NB);
+}
+
+static inline unsigned int ftgmac100_rxdes_data_length(struct ftgmac100_rxdes *rxdes)
+{
+	return le32_to_cpu(rxdes->rxdes0) & FTGMAC100_RXDES0_VDBC;
+}
+
+static inline bool ftgmac100_rxdes_multicast(struct ftgmac100_rxdes *rxdes)
+{
+	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_MULTICAST);
+}
+
+static inline void ftgmac100_rxdes_set_dma_addr(struct ftgmac100_rxdes *rxdes,
+						dma_addr_t addr)
+{
+	rxdes->rxdes3 = cpu_to_le32(addr);
+}
+
+static inline dma_addr_t ftgmac100_rxdes_get_dma_addr(struct ftgmac100_rxdes *rxdes)
+{
+	return le32_to_cpu(rxdes->rxdes3);
+}
+
+static inline bool ftgmac100_rxdes_csum_err(struct ftgmac100_rxdes *rxdes)
+{
+	return !!(rxdes->rxdes1 & cpu_to_le32(FTGMAC100_RXDES1_TCP_CHKSUM_ERR |
+					      FTGMAC100_RXDES1_UDP_CHKSUM_ERR |
+					      FTGMAC100_RXDES1_IP_CHKSUM_ERR));
+}
+
 #endif /* __FTGMAC100_H */
