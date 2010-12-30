From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v4] Gemini: Gigabit ethernet driver
Date: Thu, 30 Dec 2010 09:39:05 +0100 (CET)
Message-ID: <20101230083905.5A8EB13909@rere.qmqm.pl>
References: <20101229130207.4F66413909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>
To: Hans Ulli Kroll <ulli.kroll@googlemail.com>,
	gemini-board-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43808 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751933Ab0L3IjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Dec 2010 03:39:08 -0500
In-Reply-To: <20101229130207.4F66413909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver for SL351x (Gemini) SoC ethernet peripheral. Based in part
on work by Paulius Zaleckas and GPLd code from Raidsonic and other
NAS vendors.

Tested on Raidsonic IcyBox 4220-B (dual SATA NAS).

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---

Against: v2.6.37-rc8

This depends on commit 83097f22d1f91a748bb2c066d049d0d1d2843ef2

        Gemini: create platform device for ethernet in Raidsonic IB-422=
0B

from  git://git.berlios.de/gemini-board

Note for testers: you may tweak DEFAULT_RX_BUF_ORDER (=3Dlog2(buffer si=
ze),
at most a page - so in range [6..12]) and RX_MAX_ALLOC_ORDER (max alloc=
ated
rx buffer page order) to find best memory usage/performance settings ap=
art
from what is available via ethtool. For TX, there's not much you can do=
 when
offloads are disabled.

MAC address needs to be set by userspace from flash VCTL partition (mtd=
4
on my box).

Changes from v3:
 - fixed remaining tx_queue_len misuse bugs
 - bulk RX DMA page map/unmap
 - whitespace changes to make checkpatch happier (please ignore remaini=
ng
   complaints - long lines in .c and typedefs/whitespace/long lines in =
=2Eh)

Changes from v2:
 - converted to page buffers and napi_gro_frags()
 - later IRQ acking and NAPI exits
 - larger rings by default
 - tx-interrupt coalescing
 - MTU changing
 - jumbo frames support
 - ringparam and coalesce settings via ethtool
 - more fixes/cleanups

Changes from v1:
 - fixed stats (now using u64_stats_sync; no-op on UP anyway)
 - pre-load mdio-gpio if built as module
 - disable TX checksum offload by default (unreliable HW)
 - convert to NAPI+GRO (netperf TCP STREAM RX test:
        before: 156mbit/s, now: 185mbit/s)

Later TODO:
 - netpoll (netconsole)
 - parse MAC address from flash settings and pass it through platform d=
ata

---
 MAINTAINERS             |    9 +
 drivers/net/Kconfig     |   10 +
 drivers/net/Makefile    |    1 +
 drivers/net/sl351x.c    | 2323 +++++++++++++++++++++++++++++++++++++++=
++++++++
 drivers/net/sl351x_hw.h | 1436 +++++++++++++++++++++++++++++
 5 files changed, 3779 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 71e40f9..694de04 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5439,6 +5439,15 @@ S:	Maintained
 F:	drivers/net/skge.*
 F:	drivers/net/sky2.*
=20
+SL351X (STORLINK GEMINI SOC) GIGABIT ETHERNET DRIVER
+M:	Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
+L:	netdev@vger.kernel.org
+L:	gemini-board-dev@lists.berlios.de
+T:	git git://git.berlios.de/gemini-board
+S:	Maintained
+F:	driver/net/sl351x.c
+F:	driver/net/sl351x_hw.h
+
 SLAB ALLOCATOR
 M:	Christoph Lameter <cl@linux-foundation.org>
 M:	Pekka Enberg <penberg@cs.helsinki.fi>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4f1755b..0336c4f 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2068,6 +2068,16 @@ config ACENIC_OMIT_TIGON_I
=20
 	  The safe and default value for this is N.
=20
+config GEMINI_SL351X
+	tristate "StorLink SL351x Gigabit Ethernet support"
+	depends on ARCH_GEMINI
+	select PHYLIB
+	select MDIO_BITBANG
+	select MDIO_GPIO
+	select CRC32
+	help
+	  This driver supports StorLink SL351x (Gemini) dual Gigabit Ethernet=
=2E
+
 config DL2K
 	tristate "DL2000/TC902x-based Gigabit Ethernet support"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index b90738d..2d3491b 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -257,6 +257,7 @@ obj-$(CONFIG_MLX4_CORE) +=3D mlx4/
 obj-$(CONFIG_ENC28J60) +=3D enc28j60.o
 obj-$(CONFIG_ETHOC) +=3D ethoc.o
 obj-$(CONFIG_GRETH) +=3D greth.o
+obj-$(CONFIG_GEMINI_SL351X) +=3D sl351x.o
=20
 obj-$(CONFIG_XTENSA_XT2000_SONIC) +=3D xtsonic.o
=20
diff --git a/drivers/net/sl351x.c b/drivers/net/sl351x.c
new file mode 100644
index 0000000..de21f07
--- /dev/null
+++ b/drivers/net/sl351x.c
@@ -0,0 +1,2323 @@
+/*
+ *  Ethernet device driver for Gemini SoC (SL351x GMAC).
+ *
+ *  Copyright (C) 2010, Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmq=
m.pl>
+ *
+ *  Based on work by Paulius Zaleckas <paulius.zaleckas@gmail.com> and
+ *  GPLd spaghetti code from Raidsonic and other Gemini-based NAS vend=
ors.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License as published b=
y
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+
+#include <linux/spinlock.h>
+#include <linux/slab.h>
+#include <linux/dma-mapping.h>
+#include <linux/cache.h>
+#include <linux/interrupt.h>
+
+#include <linux/platform_device.h>
+#include <linux/etherdevice.h>
+#include <linux/if_vlan.h>
+#include <linux/skbuff.h>
+#include <linux/phy.h>
+#include <linux/crc32.h>
+#include <linux/ethtool.h>
+#include <linux/tcp.h>
+#include <linux/u64_stats_sync.h>
+
+#include <mach/hardware.h>
+#include <mach/global_reg.h>
+#include <mach/irqs.h>
+#include <mach/gmac.h>
+#include "sl351x_hw.h"
+
+#define DEFAULT_TX_COALESCE		16
+#define DEFAULT_GMAC_RXQ_ORDER		10
+#define DEFAULT_GMAC_TXQ_ORDER		10
+#define DEFAULT_RX_BUF_ORDER		11
+#define DEFAULT_NAPI_WEIGHT		64
+#define RX_INSERT_BYTES			2
+#define TX_MAX_FRAGS			8
+#define TX_QUEUE_NUM			1	/* max: 6 */
+#define RX_MAX_ALLOC_ORDER		4
+#define NETIF_TSO_FEATURES	\
+	(NETIF_F_TSO|NETIF_F_TSO_ECN|NETIF_F_TSO6)
+
+static int debug_level;
+module_param(debug_level, int, 0600);
+MODULE_PARM_DESC(debug_level, "netif debug level mask");
+
+struct toe_private {
+	void __iomem	*iomem;
+	GMAC_RXDESC_T	*freeq_ring;
+	spinlock_t	irq_lock;
+
+	struct net_device *netdev[2];
+	struct device	*dev;
+	int		irq;
+
+	unsigned int	freeq_frag_order;
+	unsigned int	freeq_order;
+	unsigned int	freeq_entries;
+	dma_addr_t	freeq_dma_base;
+
+	struct page	*freeq_page;
+	unsigned int	freeq_page_count;
+	unsigned int	alloc_order;
+	unsigned int	freeq_page_offs;
+};
+
+struct gmac_txq {
+	GMAC_TXDESC_T	*ring;
+	unsigned int	cptr;
+	struct sk_buff	**skb;
+	unsigned int	noirq_packets;
+} ____cacheline_aligned_in_smp;
+
+struct gmac_private {
+	void __iomem		*dma_iomem;
+
+	void __iomem		*rxq_rwptr;
+	GMAC_RXDESC_T		*rxq_ring;
+	unsigned int		rxq_order;
+
+	struct napi_struct	napi;
+	struct gmac_txq		txq[TX_QUEUE_NUM];
+	unsigned int		txq_order;
+	unsigned int		irq_every_tx_packets;
+
+	dma_addr_t		rxq_dma_base;
+	dma_addr_t		txq_dma_base;
+
+	unsigned int		msg_enable;
+	spinlock_t		config_lock;
+
+	int			in_reset;
+
+	struct u64_stats_sync	tx_stats_syncp;
+	struct u64_stats_sync	rx_stats_syncp;
+	struct u64_stats_sync	ir_stats_syncp;
+
+	struct rtnl_link_stats64 stats;
+	u64			hw_stats[RX_STATS_NUM];
+	u64			rx_stats[RX_STATUS_NUM];
+	u64			rx_csum_stats[RX_CHKSUM_NUM];
+	u64			rx_napi_exits;
+	u64			tx_frag_stats[TX_MAX_FRAGS];
+	u64			tx_frags_linearized;
+	u64			tx_hw_csummed;
+};
+
+#define GMAC_STATS_NUM	( \
+	RX_STATS_NUM + RX_STATUS_NUM + RX_CHKSUM_NUM + 1 + \
+	TX_MAX_FRAGS + 2)
+
+static const char gmac_stats_strings[GMAC_STATS_NUM][ETH_GSTRING_LEN] =
=3D {
+	"GMAC_IN_DISCARDS",
+	"GMAC_IN_ERRORS",
+	"GMAC_IN_MCAST",
+	"GMAC_IN_BCAST",
+	"GMAC_IN_MAC1",
+	"GMAC_IN_MAC2",
+	"RX_STATUS_GOOD_FRAME",
+	"RX_STATUS_TOO_LONG_GOOD_CRC",
+	"RX_STATUS_RUNT_FRAME",
+	"RX_STATUS_SFD_NOT_FOUND",
+	"RX_STATUS_CRC_ERROR",
+	"RX_STATUS_TOO_LONG_BAD_CRC",
+	"RX_STATUS_ALIGNMENT_ERROR",
+	"RX_STATUS_TOO_LONG_BAD_ALIGN",
+	"RX_STATUS_RX_ERR",
+	"RX_STATUS_DA_FILTERED",
+	"RX_STATUS_BUFFER_FULL",
+	"RX_STATUS_11",
+	"RX_STATUS_12",
+	"RX_STATUS_13",
+	"RX_STATUS_14",
+	"RX_STATUS_15",
+	"RX_CHKSUM_IP_UDP_TCP_OK",
+	"RX_CHKSUM_IP_OK_ONLY",
+	"RX_CHKSUM_NONE",
+	"RX_CHKSUM_3",
+	"RX_CHKSUM_IP_ERR_UNKNOWN",
+	"RX_CHKSUM_IP_ERR",
+	"RX_CHKSUM_TCP_UDP_ERR",
+	"RX_CHKSUM_7",
+	"RX_NAPI_EXITS",
+	"TX_FRAGS[1]",
+	"TX_FRAGS[2]",
+	"TX_FRAGS[3]",
+	"TX_FRAGS[4]",
+	"TX_FRAGS[5]",
+	"TX_FRAGS[6]",
+	"TX_FRAGS[7]",
+	"TX_FRAGS[8]",
+	"TX_FRAGS_LINEARIZED",
+	"TX_HW_CSUMMED",
+};
+
+static struct gmac_private *netdev_to_gmac(struct net_device *dev)
+{
+	return netdev_priv(dev);
+}
+
+static struct toe_private *netdev_to_toe(struct net_device *dev)
+{
+	return dev->ml_priv;
+}
+
+static struct gmac_private *napi_to_gmac(struct napi_struct *napi)
+{
+	return container_of(napi, struct gmac_private, napi);
+}
+
+static void __iomem *toe_reg(struct toe_private *toe, unsigned int reg=
)
+{
+	return toe->iomem + reg;
+}
+
+static void __iomem *gmac_dma_reg(struct net_device *dev, unsigned int=
 reg)
+{
+	return netdev_to_gmac(dev)->dma_iomem + reg;
+}
+
+static void __iomem *gmac_ctl_reg(struct net_device *dev, unsigned int=
 reg)
+{
+	return (void __iomem *)dev->base_addr + reg;
+}
+
+static struct page *toe_unmap_rx_desc(struct toe_private *toe,
+	GMAC_RXDESC_T *rx)
+{
+	struct page *page;
+
+	if (unlikely(!rx->word2.buf_adr))
+		return NULL;
+
+	page =3D dma_to_page(toe->dev, rx->word2.buf_adr);
+
+	dma_unmap_page(toe->dev, rx->word2.buf_adr,
+		1 << toe->freeq_frag_order, DMA_FROM_DEVICE);
+
+	return page;
+}
+
+static void gmac_hw_start(struct net_device *dev)
+{
+	GMAC_DMA_CTRL_T	dma_ctrl;
+
+	dma_ctrl.bits32 =3D __raw_readl(gmac_dma_reg(dev, GMAC_DMA_CTRL_REG))=
;
+
+	dma_ctrl.bits.rd_enable =3D 1;
+	dma_ctrl.bits.td_enable =3D 1;
+	dma_ctrl.bits.loopback =3D 0;
+	dma_ctrl.bits.drop_small_ack =3D 0;
+	dma_ctrl.bits.rd_prot =3D 0;
+	dma_ctrl.bits.rd_burst_size =3D 3;
+	dma_ctrl.bits.rd_insert_bytes =3D RX_INSERT_BYTES;
+	dma_ctrl.bits.rd_bus =3D 3;
+	dma_ctrl.bits.td_prot =3D 0;
+	dma_ctrl.bits.td_burst_size =3D 3;
+	dma_ctrl.bits.td_bus =3D 3;
+
+	__raw_writel(dma_ctrl.bits32, gmac_dma_reg(dev, GMAC_DMA_CTRL_REG));
+}
+
+static void gmac_hw_stop(struct net_device *dev)
+{
+	GMAC_DMA_CTRL_T	dma_ctrl;
+
+	dma_ctrl.bits32 =3D __raw_readl(gmac_dma_reg(dev, GMAC_DMA_CTRL_REG))=
;
+
+	dma_ctrl.bits.rd_enable =3D 0;
+	dma_ctrl.bits.td_enable =3D 0;
+
+	__raw_writel(dma_ctrl.bits32, gmac_dma_reg(dev, GMAC_DMA_CTRL_REG));
+}
+
+static void gmac_update_config0_reg(struct net_device *dev, u32 val, u=
32 vmask)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	unsigned long flags;
+	u32 reg;
+
+	spin_lock_irqsave(&gmac->config_lock, flags);
+
+	reg =3D __raw_readl(gmac_ctl_reg(dev, GMAC_CONFIG0));
+	reg =3D (reg & ~vmask) | val;
+	__raw_writel(reg, gmac_ctl_reg(dev, GMAC_CONFIG0));
+
+	spin_unlock_irqrestore(&gmac->config_lock, flags);
+}
+
+static void gmac_enable_tx_rx(struct net_device *dev)
+{
+	gmac_update_config0_reg(dev, 0, CONFIG0_TX_RX_DISABLE);
+}
+
+static void gmac_disable_tx_rx(struct net_device *dev)
+{
+	gmac_update_config0_reg(dev, CONFIG0_TX_RX_DISABLE,
+		CONFIG0_TX_RX_DISABLE);
+	mdelay(10);	/* let GMAC consume packet */
+}
+
+static void gmac_set_flow_control(struct net_device *dev, bool tx, boo=
l rx)
+{
+	u32 val =3D (tx ? CONFIG0_FLOW_TX : 0)|(rx ? CONFIG0_FLOW_RX : 0);
+
+	gmac_update_config0_reg(dev, val, CONFIG0_FLOW_CTL);
+}
+
+static void gmac_update_link_state(struct net_device *dev)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	void __iomem *status_reg =3D gmac_ctl_reg(dev, GMAC_STATUS);
+	struct phy_device *phydev =3D dev->phydev;
+	GMAC_STATUS_T status, old_status;
+
+	old_status.bits32 =3D status.bits32 =3D __raw_readl(status_reg);
+
+	status.bits.link =3D phydev->link;
+	status.bits.duplex =3D phydev->duplex;
+
+	switch (phydev->speed) {
+	case 1000:
+		status.bits.speed =3D GMAC_SPEED_1000;
+		if (phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII)
+			status.bits.mii_rmii =3D GMAC_PHY_RGMII_1000;
+		break;
+	case 100:
+		status.bits.speed =3D GMAC_SPEED_100;
+		if (phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII)
+			status.bits.mii_rmii =3D GMAC_PHY_RGMII_100_10;
+		break;
+	case 10:
+		status.bits.speed =3D GMAC_SPEED_10;
+		if (phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII)
+			status.bits.mii_rmii =3D GMAC_PHY_RGMII_100_10;
+		break;
+	default:
+		dev_warn(&dev->dev, "Not supported PHY speed (%d)\n",
+			phydev->speed);
+	}
+
+	gmac_set_flow_control(dev, phydev->pause,
+		phydev->pause ^ phydev->asym_pause);
+
+	if (old_status.bits32 =3D=3D status.bits32)
+		return;
+
+	if (netif_msg_link(gmac)) {
+		phy_print_status(phydev);
+		netdev_info(dev, "link flow control: %s\n",
+			phydev->pause
+				? (phydev->asym_pause ? "tx" : "both")
+				: (phydev->asym_pause ? "rx" : "none")
+		);
+	}
+
+	gmac_disable_tx_rx(dev);
+	__raw_writel(status.bits32, status_reg);
+	gmac_enable_tx_rx(dev);
+}
+
+static int gmac_setup_phy(struct net_device *dev)
+{
+	struct toe_private *toe =3D netdev_to_toe(dev);
+	struct gemini_gmac_platform_data *pdata =3D toe->dev->platform_data;
+	GMAC_STATUS_T status =3D { .bits32 =3D 0 };
+	int num =3D dev->dev_id;
+
+	dev->phydev =3D phy_connect(dev, pdata->bus_id[num],
+		&gmac_update_link_state, 0, pdata->interface[num]);
+
+	if (IS_ERR(dev->phydev)) {
+		int err =3D PTR_ERR(dev->phydev);
+		dev->phydev =3D NULL;
+		return err;
+	}
+
+	dev->phydev->supported &=3D PHY_GBIT_FEATURES|SUPPORTED_Pause;
+	dev->phydev->advertising =3D dev->phydev->supported;
+
+	/* set PHY interface type */
+	switch (dev->phydev->interface) {
+	case PHY_INTERFACE_MODE_MII:
+		status.bits.mii_rmii =3D GMAC_PHY_MII;
+		break;
+	case PHY_INTERFACE_MODE_GMII:
+		status.bits.mii_rmii =3D GMAC_PHY_GMII;
+		break;
+	case PHY_INTERFACE_MODE_RGMII:
+		status.bits.mii_rmii =3D GMAC_PHY_RGMII_100_10;
+		break;
+	default:
+		dev_err(&dev->dev, "Unsupported MII interface\n");
+		phy_disconnect(dev->phydev);
+		dev->phydev =3D NULL;
+		return -EINVAL;
+	}
+	__raw_writel(status.bits32, gmac_ctl_reg(dev, GMAC_STATUS));
+
+	return 0;
+}
+
+static int gmac_pick_rx_max_len(int max_l3_len)
+{
+	/* index =3D CONFIG_MAXLEN_XXX values */
+	static const int max_len[8] =3D {
+		1536, 1518, 1522, 1542,
+		9212, 10236, 1518, 1518
+	};
+	int i, n =3D 5;
+
+	max_l3_len +=3D ETH_HLEN + VLAN_HLEN;
+
+	if (max_l3_len > max_len[n])
+		return -1;
+
+	for (i =3D 0; i < 5; ++i) {
+		if (max_len[i] >=3D max_l3_len && max_len[i] < max_len[n])
+			n =3D i;
+	}
+
+	return n;
+}
+
+static int gmac_init(struct net_device *dev)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	u32 val;
+
+	GMAC_CONFIG0_T config0 =3D { .bits =3D {
+		.dis_tx =3D 1,
+		.dis_rx =3D 1,
+		.ipv4_rx_chksum =3D 1,
+		.ipv6_rx_chksum =3D 1,
+		.rx_err_detect =3D 1,
+		.rgmm_edge =3D 1,
+		.port0_chk_hwq =3D 1,
+		.port1_chk_hwq =3D 1,
+		.port0_chk_toeq =3D 1,
+		.port1_chk_toeq =3D 1,
+		.port0_chk_classq =3D 1,
+		.port1_chk_classq =3D 1,
+	} };
+	GMAC_TX_WCR0_T hw_weigh =3D { .bits =3D {
+		.hw_tq3 =3D 1,
+		.hw_tq2 =3D 1,
+		.hw_tq1 =3D 1,
+		.hw_tq0 =3D 1,
+	} };
+	GMAC_TX_WCR1_T sw_weigh =3D { .bits =3D {
+		.sw_tq5 =3D 1,
+		.sw_tq4 =3D 1,
+		.sw_tq3 =3D 1,
+		.sw_tq2 =3D 1,
+		.sw_tq1 =3D 1,
+		.sw_tq0 =3D 1,
+	} };
+	GMAC_CONFIG1_T config1 =3D { .bits =3D {
+		.set_threshold =3D 16,
+		.rel_threshold =3D 24,
+	} };
+	GMAC_CONFIG2_T config2 =3D { .bits =3D {
+		.set_threshold =3D 16,
+		.rel_threshold =3D 32,
+	} };
+	GMAC_CONFIG3_T config3 =3D { .bits =3D {
+		.set_threshold =3D 0,
+		.rel_threshold =3D 0,
+	} };
+
+	config0.bits.max_len =3D gmac_pick_rx_max_len(dev->mtu);
+
+	val =3D __raw_readl(gmac_ctl_reg(dev, GMAC_CONFIG0));
+	config0.bits.reserved =3D ((GMAC_CONFIG0_T)val).bits.reserved;
+	__raw_writel(config0.bits32, gmac_ctl_reg(dev, GMAC_CONFIG0));
+	__raw_writel(config1.bits32, gmac_ctl_reg(dev, GMAC_CONFIG1));
+	__raw_writel(config2.bits32, gmac_ctl_reg(dev, GMAC_CONFIG2));
+	__raw_writel(config3.bits32, gmac_ctl_reg(dev, GMAC_CONFIG3));
+	__raw_writel(hw_weigh.bits32,
+		gmac_dma_reg(dev, GMAC_TX_WEIGHTING_CTRL_0_REG));
+	__raw_writel(sw_weigh.bits32,
+		gmac_dma_reg(dev, GMAC_TX_WEIGHTING_CTRL_1_REG));
+
+	gmac->rxq_order =3D DEFAULT_GMAC_RXQ_ORDER;
+	gmac->txq_order =3D DEFAULT_GMAC_TXQ_ORDER;
+
+	gmac->irq_every_tx_packets =3D DEFAULT_TX_COALESCE;
+
+	return 0;
+}
+
+static void gmac_uninit(struct net_device *dev)
+{
+	if (dev->phydev)
+		phy_disconnect(dev->phydev);
+}
+
+static int gmac_setup_txqs(struct net_device *dev)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	struct toe_private *toe =3D netdev_to_toe(dev);
+	void __iomem *rwptr_reg =3D gmac_dma_reg(dev, GMAC_SW_TX_QUEUE0_PTR_R=
EG);
+	void __iomem *base_reg =3D gmac_dma_reg(dev, GMAC_SW_TX_QUEUE_BASE_RE=
G);
+
+	unsigned int n_txq =3D dev->num_tx_queues;
+	struct gmac_txq *txq =3D gmac->txq;
+	GMAC_TXDESC_T *desc_ring;
+	struct sk_buff **skb_tab;
+	int i;
+
+	skb_tab =3D kzalloc(
+		n_txq * sizeof(*skb_tab) << gmac->txq_order, GFP_KERNEL);
+	if (!skb_tab)
+		return -ENOMEM;
+
+	desc_ring =3D dma_alloc_coherent(toe->dev,
+		n_txq * sizeof(*desc_ring) << gmac->txq_order,
+		&gmac->txq_dma_base, GFP_KERNEL);
+	if (!desc_ring) {
+		kfree(skb_tab);
+		return -ENOMEM;
+	}
+
+	BUG_ON(gmac->txq_dma_base & ~DMA_Q_BASE_MASK);
+
+	for (i =3D 0; i < n_txq; i++) {
+		netif_info(gmac, ifup, dev,
+			"txq%u: ring %p (dma 0x%08x), skb %p, rwptr %p, len %u (order %u)\n=
",
+			i, desc_ring, gmac->txq_dma_base, skb_tab, rwptr_reg,
+			1 << gmac->txq_order, gmac->txq_order);
+
+		__raw_writel(0, rwptr_reg);
+		txq->ring =3D desc_ring;
+		txq->cptr =3D 0;
+		txq->skb =3D skb_tab;
+
+		desc_ring +=3D 1 << gmac->txq_order;
+		skb_tab +=3D 1 << gmac->txq_order;
+		rwptr_reg +=3D 4;
+	}
+
+	__raw_writel(gmac->txq_dma_base | gmac->txq_order, base_reg);
+
+	return 0;
+}
+
+static void gmac_cleanup_txqs(struct net_device *dev)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	struct toe_private *toe =3D netdev_to_toe(dev);
+	void __iomem *rwptr_reg =3D gmac_dma_reg(dev, GMAC_SW_TX_QUEUE0_PTR_R=
EG);
+	void __iomem *base_reg =3D gmac_dma_reg(dev, GMAC_SW_TX_QUEUE_BASE_RE=
G);
+
+	struct gmac_txq *txq =3D gmac->txq;
+	unsigned n_txq =3D dev->num_tx_queues;
+	int i, j;
+
+	for (i =3D 0; i < n_txq; ++i, ++txq) {
+		__raw_writel(0, rwptr_reg + 4 * i);
+		for (j =3D 0; j < (1 << gmac->txq_order); ++j)
+			if (txq->skb[j])
+				dev_kfree_skb(txq->skb[j]);
+	}
+
+	__raw_writel(0, base_reg);
+
+	kfree(gmac->txq->skb);
+	dma_free_coherent(toe->dev,
+		n_txq * sizeof(*gmac->txq->ring) << gmac->txq_order,
+		gmac->txq->ring, gmac->txq_dma_base);
+}
+
+static int gmac_setup_rxq(struct net_device *dev)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	struct toe_private *toe =3D netdev_to_toe(dev);
+	NONTOE_QHDR_T __iomem *qhdr =3D toe_reg(toe, TOE_DEFAULT_Q_HDR_BASE(d=
ev->dev_id));
+
+	gmac->rxq_rwptr =3D &qhdr->word1;
+	gmac->rxq_ring =3D dma_alloc_coherent(toe->dev,
+		sizeof(*gmac->rxq_ring) << gmac->rxq_order,
+		&gmac->rxq_dma_base, GFP_KERNEL);
+	if (!gmac->rxq_ring)
+		return -ENOMEM;
+
+	BUG_ON(gmac->rxq_dma_base & ~NONTOE_QHDR0_BASE_MASK);
+
+	__raw_writel(0, gmac->rxq_rwptr);
+	__raw_writel(gmac->rxq_dma_base | gmac->rxq_order, &qhdr->word0);
+
+	netif_info(gmac, ifup, dev,
+		"rxq: ring %p (dma 0x%08x), rwptr %p, len %u (order %u)\n",
+		gmac->rxq_ring, gmac->rxq_dma_base, gmac->rxq_rwptr,
+		1 << gmac->rxq_order, gmac->rxq_order);
+	return 0;
+}
+
+static void gmac_cleanup_rxq(struct net_device *dev)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	struct toe_private *toe =3D netdev_to_toe(dev);
+
+	NONTOE_QHDR_T __iomem *qhdr =3D toe_reg(toe, TOE_DEFAULT_Q_HDR_BASE(d=
ev->dev_id));
+	void __iomem *dma_reg =3D &qhdr->word0;
+	void __iomem *ptr_reg =3D &qhdr->word1;
+	unsigned i, e, mask =3D __RWPTR_MASK(gmac->rxq_order);
+	struct page *page;
+
+	i =3D GET_RPTR(ptr_reg);
+	e =3D GET_WPTR(ptr_reg);
+	__raw_writel(0, ptr_reg);
+	__raw_writel(0, dma_reg);
+
+	for (; i !=3D e; i =3D __RWPTR_NEXT(i, mask)) {
+		page =3D toe_unmap_rx_desc(toe, &gmac->rxq_ring[i]);
+		if (likely(page))
+			put_page(page);
+	}
+
+	dma_free_coherent(toe->dev, sizeof(*gmac->rxq_ring) << gmac->rxq_orde=
r,
+		gmac->rxq_ring, gmac->rxq_dma_base);
+}
+
+static void __gmac_enable_txfin_irq(struct net_device *, int txq, int =
enable);
+
+static void gmac_tx_interrupt(struct net_device *dev, unsigned txq_num=
)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	struct toe_private *toe =3D netdev_to_toe(dev);
+
+	void __iomem *ptr_reg =3D gmac_dma_reg(dev, GMAC_SW_TX_QUEUE_PTR_REG(=
txq_num));
+	struct netdev_queue *ntxq =3D netdev_get_tx_queue(dev, txq_num);
+	struct gmac_txq *txq =3D &gmac->txq[txq_num];
+
+	unsigned i, n, errs =3D 0, mask =3D __RWPTR_MASK(gmac->txq_order);
+	struct sk_buff *skb;
+	GMAC_TXDESC_T *tx;
+
+	netif_info(gmac, tx_done, dev, "txirq%u: %u,%u,%u\n",
+		txq_num, txq->cptr, GET_RPTR(ptr_reg), GET_WPTR(ptr_reg));
+
+	for (i =3D txq->cptr; i !=3D GET_RPTR(ptr_reg); i =3D __RWPTR_NEXT(i,=
 mask)) {
+retry:
+		tx =3D &txq->ring[i];
+		skb =3D txq->skb[i];
+		txq->skb[i] =3D NULL;
+
+		BUG_ON(!skb);
+
+		dma_unmap_single(toe->dev, tx->word2.buf_adr,
+			tx->word0.bits.buffer_size, DMA_TO_DEVICE);
+
+		if (tx->word0.bits.status_tx_ok) {
+			netif_info(gmac, tx_done, dev,
+				"TX done descriptor: [%u] 0x%08x 0x%08x 0x%08x 0x%08x\n",
+				i, tx->word0.bits32, tx->word1.bits32,
+				tx->word2.bits32, tx->word3.bits32);
+		} else {
+			errs++;
+			netif_err(gmac, tx_err, dev,
+				"TX error descriptor: [%u] 0x%08x 0x%08x 0x%08x 0x%08x\n",
+				i, tx->word0.bits32, tx->word1.bits32,
+				tx->word2.bits32, tx->word3.bits32);
+		}
+
+		n =3D tx->word0.bits.desc_count;
+		BUG_ON(__RWPTR_DISTANCE(i, GET_RPTR(ptr_reg), mask) < n);
+
+		while (--n) {
+			i =3D __RWPTR_NEXT(i, mask);
+			dma_unmap_page(toe->dev, txq->ring[i].word2.buf_adr,
+				txq->ring[i].word0.bits.buffer_size,
+				DMA_TO_DEVICE);
+			netif_info(gmac, tx_done, dev,
+				"TX frag descriptor: [%u] 0x%08x 0x%08x 0x%08x 0x%08x\n",
+				i, txq->ring[i].word0.bits32,
+				txq->ring[i].word1.bits32,
+				txq->ring[i].word2.bits32,
+				txq->ring[i].word3.bits32);
+		}
+
+		dev_kfree_skb_irq(skb);
+	}
+
+	spin_lock(&toe->irq_lock);
+
+	u64_stats_update_begin(&gmac->ir_stats_syncp);
+	gmac->stats.tx_errors +=3D errs;
+	u64_stats_update_end(&gmac->ir_stats_syncp);
+
+	txq->cptr =3D i;
+	__gmac_enable_txfin_irq(dev, txq_num, 0);
+	netif_tx_wake_queue(ntxq);
+
+	spin_unlock(&toe->irq_lock);
+
+	__raw_writel(
+		(GMAC0_SWTQ00_EOF_INT_BIT|GMAC0_SWTQ00_FIN_INT_BIT)
+			<< (6 * dev->dev_id + txq_num),
+		toe_reg(toe, GLOBAL_INTERRUPT_STATUS_0_REG));
+	txq->noirq_packets =3D gmac->irq_every_tx_packets;
+
+	if (unlikely(i !=3D GET_RPTR(ptr_reg))) {
+		errs =3D 0;
+		goto retry;
+	}
+}
+
+static inline unsigned tss_pkt_len(struct sk_buff *skb)
+{
+	if (!skb_is_gso(skb))
+		return 0;
+
+	return skb_transport_offset(skb) +
+		tcp_hdrlen(skb) + skb_shinfo(skb)->gso_size;
+}
+
+static int gmac_map_tx_bufs(struct net_device *dev, struct sk_buff *sk=
b,
+	struct gmac_txq *txq, int desc, unsigned tss_flags)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	struct device *dma_dev =3D netdev_to_toe(dev)->dev;
+	skb_frag_t *frag;
+	dma_addr_t mapping;
+	int nfrags, w;
+
+	frag =3D skb_shinfo(skb)->frags;
+	nfrags =3D skb_shinfo(skb)->nr_frags;
+	w =3D desc;
+
+	mapping =3D dma_map_single(dma_dev, skb->data,
+		skb_headlen(skb), DMA_TO_DEVICE);
+	if (dma_mapping_error(dma_dev, mapping))
+		goto map1_error;
+
+	if (!skb_is_gso(skb))
+		tss_flags |=3D TSS_BYPASS_BIT;
+
+	txq->ring[w].word0.bits32 =3D skb_headlen(skb);
+	txq->ring[w].word1.bits32 =3D skb->len | tss_flags;
+	txq->ring[w].word2.bits32 =3D mapping;
+	txq->ring[w].word3.bits32 =3D tss_pkt_len(skb) | SOF_BIT;
+
+	/* racing with TX completion irq, harmless */
+	if (txq->noirq_packets =3D=3D 1) {
+		txq->noirq_packets =3D 0;
+		txq->ring[w].word3.bits32 |=3D EOFIE_BIT;
+	} else if (txq->noirq_packets)
+		txq->noirq_packets--;
+
+	netif_info(gmac, tx_queued, dev,
+		"txq%ld[%u]: 0x%08x 0x%08x 0x%08x 0x%08x, datap %p\n",
+		txq - gmac->txq, w,
+		txq->ring[w].word0.bits32, txq->ring[w].word1.bits32,
+		txq->ring[w].word2.bits32, txq->ring[w].word3.bits32,
+		skb->data);
+
+	while (nfrags--) {
+		mapping =3D dma_map_page(dma_dev, frag->page,
+			frag->page_offset, frag->size, DMA_TO_DEVICE);
+		if (dma_mapping_error(dma_dev, mapping))
+			goto map_error;
+
+		w =3D RWPTR_NEXT(w, gmac->txq_order);
+		txq->ring[w].word0.bits32 =3D frag->size;
+		txq->ring[w].word1.bits32 =3D 0;
+		txq->ring[w].word2.bits32 =3D mapping;
+		txq->ring[w].word3.bits32 =3D 0;
+
+		netif_info(gmac, tx_queued, dev,
+			"txq%ld[%u]: 0x%08x 0x%08x 0x%08x 0x%08x, data %u @ %p+0x%03x\n",
+			txq - gmac->txq, w,
+			txq->ring[w].word0.bits32, txq->ring[w].word1.bits32,
+			txq->ring[w].word2.bits32, txq->ring[w].word3.bits32,
+			frag->size, frag->page, frag->page_offset);
+
+		++frag;
+	}
+
+	txq->ring[w].word3.bits32 |=3D EOFIE_BIT | EOF_BIT;
+
+	return RWPTR_NEXT(w, gmac->txq_order);
+
+map_error:
+	while (w !=3D desc) {
+		dma_unmap_page(dma_dev, txq->ring[w].word2.buf_adr,
+			txq->ring[w].word0.bits.buffer_size, DMA_TO_DEVICE);
+		w =3D RWPTR_PREV(w, gmac->txq_order);
+	}
+
+	dma_unmap_single(dma_dev, txq->ring[w].word2.buf_adr,
+		txq->ring[w].word0.bits.buffer_size, DMA_TO_DEVICE);
+
+map1_error:
+	netif_info(gmac, tx_err, dev,
+		"txq%ld: DMA mapping error\n", txq - gmac->txq);
+
+	return -ENOMEM;
+}
+
+static int gmac_start_xmit(struct sk_buff *skb, struct net_device *dev=
)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	struct toe_private *toe =3D netdev_to_toe(dev);
+
+	void __iomem *ptr_reg;
+	struct gmac_txq *txq;
+	struct netdev_queue *ntxq;
+	int w, nw, txq_num, nfrags;
+	unsigned long flags;
+
+	SKB_FRAG_ASSERT(skb);
+
+	txq_num =3D skb_get_queue_mapping(skb);
+	ptr_reg =3D gmac_dma_reg(dev, GMAC_SW_TX_QUEUE_PTR_REG(txq_num));
+	txq =3D &gmac->txq[txq_num];
+	ntxq =3D netdev_get_tx_queue(dev, txq_num);
+
+	netif_info(gmac, tx_queued, dev, "txq%u: %u,%u,%u ? %p (%u @ %p) /%u\=
n",
+		txq_num, txq->cptr, GET_RPTR(ptr_reg), GET_WPTR(ptr_reg),
+		skb, skb->len, skb->data, skb_shinfo(skb)->gso_size);
+	if (netif_msg_pktdata(gmac))
+		print_hex_dump(KERN_DEBUG, "TX: ", DUMP_PREFIX_OFFSET, 16, 1,
+			skb->data, skb_headlen(skb), true);
+
+	u64_stats_update_begin(&gmac->tx_stats_syncp);
+
+	if (skb->len >=3D 0x10000)
+		goto out_drop_free;
+
+	w =3D GET_WPTR(ptr_reg);
+	spin_lock_irqsave(&toe->irq_lock, flags);
+	nw =3D RWPTR_DISTANCE(w, txq->cptr - 1, gmac->txq_order);
+	if (!nw) {
+		netif_tx_stop_queue(ntxq);
+		__gmac_enable_txfin_irq(dev, txq_num, 1);
+		spin_unlock_irqrestore(&toe->irq_lock, flags);
+		goto out_drop_free;
+	}
+	spin_unlock_irqrestore(&toe->irq_lock, flags);
+
+	nfrags =3D skb_shinfo(skb)->nr_frags;
+	if (nw <=3D nfrags || nfrags >=3D TX_MAX_FRAGS) {
+		if (skb_linearize(skb))
+			goto out_drop;
+		gmac->tx_frags_linearized++;
+	} else
+		gmac->tx_frag_stats[nfrags]++;
+
+	txq->skb[w] =3D skb;
+
+	w =3D gmac_map_tx_bufs(dev, skb, txq, w,
+		(skb->ip_summed !=3D CHECKSUM_NONE ? TSS_CHECKUM_ENABLE : 0)
+	);
+
+	if (w < 0)
+		goto out_drop_free;
+
+	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
+		gmac->tx_hw_csummed++;
+
+	ntxq->tx_bytes +=3D skb->len;
+	ntxq->tx_packets++;
+
+	u64_stats_update_end(&gmac->tx_stats_syncp);
+
+	netif_info(gmac, tx_queued, dev, "txq%u: %u,%u,%u + %p\n",
+		txq_num, txq->cptr, GET_RPTR(ptr_reg), w, skb);
+
+	SET_WPTR(ptr_reg, w);
+	ntxq->trans_start =3D jiffies;
+
+	/* stats updated on tx completion */
+	return NETDEV_TX_OK;
+
+out_drop_free:
+	dev_kfree_skb(skb);
+out_drop:
+	ntxq->tx_dropped++;
+	u64_stats_update_end(&gmac->tx_stats_syncp);
+	return NETDEV_TX_OK;
+}
+
+static void gmac_unmap_rx_frags(struct toe_private *toe, struct sk_buf=
f *skb)
+{
+	int i =3D skb_shinfo(skb)->nr_frags;
+	skb_frag_t *frag =3D &skb_shinfo(skb)->frags[0];
+
+	for (; i--; frag++)
+		dma_unmap_page(toe->dev,
+			page_to_dma(toe->dev, frag->page) + frag->page_offset,
+			frag->size, DMA_FROM_DEVICE);
+}
+
+static struct sk_buff *gmac_drop_napi_skb(struct gmac_private *gmac,
+	struct toe_private *toe)
+{
+	gmac_unmap_rx_frags(toe, napi_get_frags(&gmac->napi));
+
+	napi_free_frags(&gmac->napi);
+
+	u64_stats_update_begin(&gmac->rx_stats_syncp);
+	gmac->stats.rx_dropped++;
+	u64_stats_update_end(&gmac->rx_stats_syncp);
+
+	return NULL;
+}
+
+static struct sk_buff *gmac_skb_if_good_frame(struct gmac_private *gma=
c,
+	GMAC_RXDESC_T *rx)
+{
+	struct sk_buff *skb;
+	unsigned pkt_size =3D rx->word1.bits.byte_count;
+	unsigned rx_status =3D rx->word0.bits.status;
+	unsigned rx_csum =3D rx->word0.bits.chksum_status;
+
+	u64_stats_update_begin(&gmac->rx_stats_syncp);
+
+	gmac->rx_stats[rx_status]++;
+	gmac->rx_csum_stats[rx_csum]++;
+
+	if (rx->word0.bits.derr || rx->word0.bits.perr ||
+	    rx_status || pkt_size < ETH_ZLEN ||
+	    rx_csum >=3D RX_CHKSUM_IP_ERR_UNKNOWN) {
+		gmac->stats.rx_errors++;
+
+		if (pkt_size < ETH_ZLEN || RX_ERROR_LENGTH(rx_status))
+			gmac->stats.rx_length_errors++;
+		if (RX_ERROR_OVER(rx_status))
+			gmac->stats.rx_over_errors++;
+		if (RX_ERROR_CRC(rx_status))
+			gmac->stats.rx_crc_errors++;
+		if (RX_ERROR_FRAME(rx_status))
+			gmac->stats.rx_frame_errors++;
+
+		u64_stats_update_end(&gmac->rx_stats_syncp);
+
+		return NULL;
+	}
+
+	skb =3D napi_get_frags(&gmac->napi);
+	if (!skb) {
+		gmac->stats.rx_dropped++;
+		u64_stats_update_end(&gmac->rx_stats_syncp);
+
+		return NULL;
+	}
+
+	if (rx_csum =3D=3D RX_CHKSUM_IP_UDP_TCP_OK)
+		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
+
+	gmac->stats.rx_bytes +=3D pkt_size;
+	gmac->stats.rx_packets++;
+
+	u64_stats_update_end(&gmac->rx_stats_syncp);
+
+	return skb;
+}
+
+static unsigned gmac_rx(struct net_device *dev, unsigned budget)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	struct toe_private *toe =3D netdev_to_toe(dev);
+	void __iomem *ptr_reg =3D gmac->rxq_rwptr;
+
+	unsigned i, mask =3D __RWPTR_MASK(gmac->rxq_order);
+	GMAC_RXDESC_T *rx =3D NULL;
+	struct sk_buff *skb =3D NULL;
+	struct page *page, *last_page =3D NULL;
+	unsigned page_offs, next_offs =3D 0;
+	unsigned pkt_size =3D 0, frag_size;
+	int frag_nr =3D 0;
+
+	netif_info(gmac, rx_status, dev, "rxq: %u,%u\n",
+		 GET_RPTR(ptr_reg), GET_WPTR(ptr_reg));
+
+	i =3D GET_RPTR(ptr_reg);
+	for (; budget && i !=3D GET_WPTR(ptr_reg); i =3D __RWPTR_NEXT(i, mask=
)) {
+		rx =3D &gmac->rxq_ring[i];
+
+		page =3D dma_to_page(toe->dev, rx->word2.buf_adr);
+		page_offs =3D rx->word2.buf_adr & ~PAGE_MASK;
+
+		netif_info(gmac, rx_status, dev,
+			"rxq[%u]: 0x%08x 0x%08x 0x%08x 0x%08x, page %p, offs 0x%04x\n",
+			i, rx->word0.bits32, rx->word1.bits32,
+			rx->word2.bits32, rx->word3.bits32, page, page_offs);
+
+		if (unlikely(!rx->word2.buf_adr)) {
+			netif_err(gmac, rx_status, dev,
+				"rxq[%u]: HW BUG: zero DMA descriptor\n", i);
+			if (skb)
+				skb =3D gmac_drop_napi_skb(gmac, toe);
+			continue;
+		}
+
+		if (rx->word3.bits32 & SOF_BIT) {
+			if (skb)
+				gmac_drop_napi_skb(gmac, toe);
+
+			skb =3D gmac_skb_if_good_frame(gmac, rx);
+			if (!skb) {
+				put_page(page);
+				continue;
+			}
+			skb->dev =3D dev;
+
+			pkt_size =3D rx->word1.bits.byte_count;
+			frag_nr =3D -1;
+			last_page =3D NULL;
+			page_offs +=3D RX_INSERT_BYTES;
+		} else if (!skb) {
+			put_page(page);
+			continue;
+		}
+
+		/* append page frag to skb */
+
+		if (rx->word3.bits32 & EOF_BIT)
+			frag_size =3D pkt_size;
+		else {
+			frag_size =3D 1 << toe->freeq_frag_order;
+			if (rx->word3.bits32 & SOF_BIT)
+				frag_size -=3D RX_INSERT_BYTES;
+		}
+
+		if (page =3D=3D last_page && page_offs =3D=3D next_offs) {
+			skb_shinfo(skb)->frags[frag_nr].size +=3D frag_size;
+			put_page(page);
+		} else if (likely(++frag_nr !=3D MAX_SKB_FRAGS))
+			skb_fill_page_desc(skb, frag_nr,
+				page, page_offs, frag_size);
+		else {
+			skb =3D gmac_drop_napi_skb(gmac, toe);
+			put_page(page);
+			continue;
+		}
+
+		last_page =3D page;
+		next_offs =3D page_offs + frag_size;
+
+		skb->len +=3D frag_size;
+		skb->data_len +=3D frag_size;
+		skb->truesize +=3D frag_size;
+
+		/* receive */
+
+		if (rx->word3.bits32 & EOF_BIT) {
+			gmac_unmap_rx_frags(toe, skb);
+			napi_gro_frags(&gmac->napi);
+			skb =3D NULL;
+			--budget;
+		}
+	}
+
+	SET_RPTR(ptr_reg, i);
+
+	if (rx)
+		dev->last_rx =3D jiffies;
+
+	if (skb)
+		gmac_drop_napi_skb(gmac, toe);
+
+	return budget;
+}
+
+#define GMAC0_IRQ0_2 (GMAC0_TXDERR_INT_BIT|GMAC0_TXPERR_INT_BIT| \
+	GMAC0_RXDERR_INT_BIT|GMAC0_RXPERR_INT_BIT)
+#define GMAC0_IRQ0_6 (GMAC0_SWTQ00_EOF_INT_BIT|GMAC0_SWTQ00_FIN_INT_BI=
T)
+#define GMAC0_IRQ4_8 (GMAC0_MIB_INT_BIT|GMAC0_RX_OVERRUN_INT_BIT)
+
+static void gmac_enable_irq(struct net_device *dev, int enable)
+{
+	struct toe_private *toe =3D netdev_to_toe(dev);
+	unsigned long flags;
+	unsigned val, mask;
+
+	spin_lock_irqsave(&toe->irq_lock, flags);
+
+	mask =3D (GMAC0_IRQ0_2 << (dev->dev_id * 2)) |
+		(GMAC0_IRQ0_6 << (dev->dev_id * 6));
+	val =3D __raw_readl(toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_0_REG));
+	val =3D enable ? (val | mask) : (val & ~mask);
+	__raw_writel(val, toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_0_REG));
+
+	mask =3D DEFAULT_Q0_INT_BIT << dev->dev_id;
+	val =3D __raw_readl(toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_1_REG));
+	val =3D enable ? (val | mask) : (val & ~mask);
+	__raw_writel(val, toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_1_REG));
+
+	mask =3D GMAC0_IRQ4_8 << (dev->dev_id * 8);
+	val =3D __raw_readl(toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_4_REG));
+	val =3D enable ? (val | mask) : (val & ~mask);
+	__raw_writel(val, toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_4_REG));
+
+	spin_unlock_irqrestore(&toe->irq_lock, flags);
+}
+
+static void __gmac_enable_txfin_irq(struct net_device *dev, int txq, i=
nt enable)
+{
+	struct toe_private *toe =3D netdev_to_toe(dev);
+	unsigned val, mask;
+
+	mask =3D GMAC0_SWTQ00_FIN_INT_BIT << (6 * dev->dev_id + txq);
+	val =3D __raw_readl(toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_0_REG));
+	val =3D enable ? (val | mask) : (val & ~mask);
+	__raw_writel(val, toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_0_REG));
+}
+
+static void gmac_enable_rx_irq(struct net_device *dev, int enable)
+{
+	struct toe_private *toe =3D netdev_to_toe(dev);
+	unsigned long flags;
+	unsigned val, mask;
+
+	spin_lock_irqsave(&toe->irq_lock, flags);
+
+	mask =3D DEFAULT_Q0_INT_BIT << dev->dev_id;
+	val =3D __raw_readl(toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_1_REG));
+	val =3D enable ? (val | mask) : (val & ~mask);
+	__raw_writel(val, toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_1_REG));
+
+	spin_unlock_irqrestore(&toe->irq_lock, flags);
+}
+
+static int gmac_napi_poll(struct napi_struct *napi, int max_work)
+{
+	struct gmac_private *gmac =3D napi_to_gmac(napi);
+	unsigned work_left;
+
+	work_left =3D gmac_rx(napi->dev, max_work);
+
+	if (work_left !=3D max_work) {
+		if (work_left) {
+			struct toe_private *toe =3D netdev_to_toe(napi->dev);
+			/* we've cleared the queue, ack rx interrupt;
+			 * on next poll the interrupt will be enabled
+			 * if the queue stays empty
+			 */
+			__raw_writel(DEFAULT_Q0_INT_BIT << napi->dev->dev_id,
+				toe_reg(toe, GLOBAL_INTERRUPT_STATUS_1_REG));
+		}
+		return max_work - work_left;
+	}
+
+	napi_complete(napi);
+	u64_stats_update_begin(&gmac->rx_stats_syncp);
+	++gmac->rx_napi_exits;
+	u64_stats_update_end(&gmac->rx_stats_syncp);
+	gmac_enable_rx_irq(napi->dev, 1);
+
+	return 0;
+}
+
+static void gmac_dump_dma_state(struct net_device *dev)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	struct toe_private *toe =3D netdev_to_toe(dev);
+	void __iomem *ptr_reg;
+	unsigned reg[5];
+
+	/* Interrupt status */
+	reg[0] =3D __raw_readl(toe_reg(toe, GLOBAL_INTERRUPT_STATUS_0_REG));
+	reg[1] =3D __raw_readl(toe_reg(toe, GLOBAL_INTERRUPT_STATUS_1_REG));
+	reg[2] =3D __raw_readl(toe_reg(toe, GLOBAL_INTERRUPT_STATUS_2_REG));
+	reg[3] =3D __raw_readl(toe_reg(toe, GLOBAL_INTERRUPT_STATUS_3_REG));
+	reg[4] =3D __raw_readl(toe_reg(toe, GLOBAL_INTERRUPT_STATUS_4_REG));
+	netdev_err(dev, "IRQ status: 0x%08x 0x%08x 0x%08x 0x%08x 0x%08x\n",
+		reg[0], reg[1], reg[2], reg[3], reg[4]);
+
+	/* Interrupt enable */
+	reg[0] =3D __raw_readl(toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_0_REG));
+	reg[1] =3D __raw_readl(toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_1_REG));
+	reg[2] =3D __raw_readl(toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_2_REG));
+	reg[3] =3D __raw_readl(toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_3_REG));
+	reg[4] =3D __raw_readl(toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_4_REG));
+	netdev_err(dev, "IRQ enable: 0x%08x 0x%08x 0x%08x 0x%08x 0x%08x\n",
+		reg[0], reg[1], reg[2], reg[3], reg[4]);
+
+	/* RX DMA status */
+	reg[0] =3D __raw_readl(gmac_dma_reg(dev, GMAC_DMA_RX_FIRST_DESC_REG))=
;
+	reg[1] =3D __raw_readl(gmac_dma_reg(dev, GMAC_DMA_RX_CURR_DESC_REG));
+	reg[2] =3D GET_RPTR(gmac->rxq_rwptr);
+	reg[3] =3D GET_WPTR(gmac->rxq_rwptr);
+	netdev_err(dev, "RX DMA regs: 0x%08x 0x%08x, ptr: %u %u\n",
+		reg[0], reg[1], reg[2], reg[3]);
+
+	reg[0] =3D __raw_readl(gmac_dma_reg(dev, GMAC_DMA_RX_DESC_WORD0_REG))=
;
+	reg[1] =3D __raw_readl(gmac_dma_reg(dev, GMAC_DMA_RX_DESC_WORD1_REG))=
;
+	reg[2] =3D __raw_readl(gmac_dma_reg(dev, GMAC_DMA_RX_DESC_WORD2_REG))=
;
+	reg[3] =3D __raw_readl(gmac_dma_reg(dev, GMAC_DMA_RX_DESC_WORD3_REG))=
;
+	netdev_err(dev, "RX DMA descriptor: 0x%08x 0x%08x 0x%08x 0x%08x\n",
+		reg[0], reg[1], reg[2], reg[3]);
+
+	/* TX DMA status */
+	ptr_reg =3D gmac_dma_reg(dev, GMAC_SW_TX_QUEUE0_PTR_REG);
+
+	reg[0] =3D __raw_readl(gmac_dma_reg(dev, GMAC_DMA_TX_FIRST_DESC_REG))=
;
+	reg[1] =3D __raw_readl(gmac_dma_reg(dev, GMAC_DMA_TX_CURR_DESC_REG));
+	reg[2] =3D GET_RPTR(ptr_reg);
+	reg[3] =3D GET_WPTR(ptr_reg);
+	netdev_err(dev, "TX DMA regs: 0x%08x 0x%08x, ptr: %u %u\n",
+		reg[0], reg[1], reg[2], reg[3]);
+
+	reg[0] =3D __raw_readl(gmac_dma_reg(dev, GMAC_DMA_TX_DESC_WORD0_REG))=
;
+	reg[1] =3D __raw_readl(gmac_dma_reg(dev, GMAC_DMA_TX_DESC_WORD1_REG))=
;
+	reg[2] =3D __raw_readl(gmac_dma_reg(dev, GMAC_DMA_TX_DESC_WORD2_REG))=
;
+	reg[3] =3D __raw_readl(gmac_dma_reg(dev, GMAC_DMA_TX_DESC_WORD3_REG))=
;
+	netdev_err(dev, "TX DMA descriptor: 0x%08x 0x%08x 0x%08x 0x%08x\n",
+		reg[0], reg[1], reg[2], reg[3]);
+
+	/* FREE queues status */
+	ptr_reg =3D toe_reg(toe, GLOBAL_SWFQ_RWPTR_REG);
+
+	reg[0] =3D GET_RPTR(ptr_reg);
+	reg[1] =3D GET_WPTR(ptr_reg);
+
+	ptr_reg =3D toe_reg(toe, GLOBAL_HWFQ_RWPTR_REG);
+
+	reg[2] =3D GET_RPTR(ptr_reg);
+	reg[3] =3D GET_WPTR(ptr_reg);
+	netdev_err(dev, "FQ SW ptr: %u %u, HW ptr: %u %u\n",
+		reg[0], reg[1], reg[2], reg[3]);
+}
+
+static void gmac_update_hw_stats(struct net_device *dev)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	struct toe_private *toe =3D netdev_to_toe(dev);
+	unsigned long flags;
+	unsigned int rx_discards, rx_mcast, rx_bcast;
+
+	spin_lock_irqsave(&toe->irq_lock, flags);
+	u64_stats_update_begin(&gmac->ir_stats_syncp);
+
+	gmac->hw_stats[0] +=3D rx_discards =3D __raw_readl(gmac_ctl_reg(dev, =
GMAC_IN_DISCARDS));
+	gmac->hw_stats[1] +=3D __raw_readl(gmac_ctl_reg(dev, GMAC_IN_ERRORS))=
;
+	gmac->hw_stats[2] +=3D rx_mcast =3D __raw_readl(gmac_ctl_reg(dev, GMA=
C_IN_MCAST));
+	gmac->hw_stats[3] +=3D rx_bcast =3D __raw_readl(gmac_ctl_reg(dev, GMA=
C_IN_BCAST));
+	gmac->hw_stats[4] +=3D __raw_readl(gmac_ctl_reg(dev, GMAC_IN_MAC1));
+	gmac->hw_stats[5] +=3D __raw_readl(gmac_ctl_reg(dev, GMAC_IN_MAC2));
+
+	gmac->stats.rx_missed_errors +=3D rx_discards;
+	gmac->stats.multicast +=3D rx_mcast;
+	gmac->stats.multicast +=3D rx_bcast;
+
+	__raw_writel(GMAC0_MIB_INT_BIT << (dev->dev_id * 8),
+		toe_reg(toe, GLOBAL_INTERRUPT_STATUS_4_REG));
+
+	u64_stats_update_end(&gmac->ir_stats_syncp);
+	spin_unlock_irqrestore(&toe->irq_lock, flags);
+}
+
+static inline unsigned gmac_get_intr_flags(struct net_device *dev, int=
 i)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	struct toe_private *toe =3D netdev_to_toe(dev);
+	void __iomem *irqif_reg, *irqen_reg;
+	unsigned offs, val;
+
+	offs =3D i * (GLOBAL_INTERRUPT_STATUS_1_REG - GLOBAL_INTERRUPT_STATUS=
_0_REG);
+
+	irqif_reg =3D toe_reg(toe, GLOBAL_INTERRUPT_STATUS_0_REG + offs);
+	irqen_reg =3D toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_0_REG + offs);
+
+	val =3D __raw_readl(irqif_reg) & __raw_readl(irqen_reg);
+	if (val)
+		netif_info(gmac, intr, dev, "irq: val%d&en =3D 0x%08x\n", i, val);
+
+	return val;
+}
+
+static irqreturn_t gmac_interrupt(int irq, void *data)
+{
+	struct net_device *dev =3D data;
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	struct toe_private *toe =3D netdev_to_toe(dev);
+	unsigned val, orr =3D 0;
+
+
+	orr |=3D val =3D gmac_get_intr_flags(dev, 0);
+
+	if (unlikely(val & (GMAC0_IRQ0_2 << (dev->dev_id * 2)))) {
+		/* oh, crap. */
+		netif_err(gmac, intr, dev, "hw failure/sw bug\n");
+		gmac_dump_dma_state(dev);
+
+		/* don't know how to recover, just reduce losses */
+		gmac_enable_irq(dev, 0);
+		return IRQ_HANDLED;
+	}
+
+	if (val & (GMAC0_IRQ0_6 << (dev->dev_id * 6)))
+		gmac_tx_interrupt(dev, 0);
+
+
+	orr |=3D val =3D gmac_get_intr_flags(dev, 1);
+
+	if (val & (DEFAULT_Q0_INT_BIT << dev->dev_id)) {
+		gmac_enable_rx_irq(dev, 0);
+		napi_schedule(&gmac->napi);
+	}
+
+
+	orr |=3D val =3D gmac_get_intr_flags(dev, 4);
+
+	if (unlikely(val & (GMAC0_MIB_INT_BIT << (dev->dev_id * 8))))
+		gmac_update_hw_stats(dev);
+
+	if (unlikely(val & (GMAC0_RX_OVERRUN_INT_BIT << (dev->dev_id * 8)))) =
{
+		__raw_writel(GMAC0_RXDERR_INT_BIT << (dev->dev_id * 8),
+			toe_reg(toe, GLOBAL_INTERRUPT_STATUS_4_REG));
+
+		spin_lock(&toe->irq_lock);
+		u64_stats_update_begin(&gmac->ir_stats_syncp);
+		++gmac->stats.rx_fifo_errors;
+		u64_stats_update_end(&gmac->ir_stats_syncp);
+		spin_unlock(&toe->irq_lock);
+	}
+
+	return orr ? IRQ_HANDLED : IRQ_NONE;
+}
+
+static int gmac_open_running(struct net_device *dev)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	int err;
+
+	err =3D gmac_setup_rxq(dev);
+	if (unlikely(err))
+		return err;
+
+	err =3D gmac_setup_txqs(dev);
+	if (unlikely(err)) {
+		gmac_cleanup_rxq(dev);
+		return err;
+	}
+
+	napi_enable(&gmac->napi);
+	gmac_hw_start(dev);
+	gmac_enable_irq(dev, 1);
+	gmac_enable_tx_rx(dev);
+	netif_tx_start_all_queues(dev);
+
+	gmac->in_reset =3D 0;
+
+	return 0;
+}
+
+static void gmac_stop_running(struct net_device *dev)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+
+	netif_tx_stop_all_queues(dev);
+
+	gmac_disable_tx_rx(dev);
+	gmac_hw_stop(dev);
+
+	napi_disable(&gmac->napi);
+
+	gmac_enable_irq(dev, 0);
+
+	gmac_cleanup_txqs(dev);
+	gmac_cleanup_rxq(dev);
+
+	gmac->in_reset =3D 1;
+}
+
+static int gmac_open(struct net_device *dev)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	int err;
+
+	if (!dev->phydev) {
+		err =3D gmac_setup_phy(dev);
+		if (err) {
+			netif_err(gmac, ifup, dev,
+				"PHY init failed: %d\n", err);
+			return err;
+		}
+	}
+
+	err =3D request_irq(dev->irq, gmac_interrupt,
+		IRQF_SHARED, dev->name, dev);
+	if (unlikely(err))
+		return err;
+
+	netif_carrier_off(dev);
+	phy_start(dev->phydev);
+
+	err =3D gmac_open_running(dev);
+	if (likely(!err))
+		return 0;
+
+	phy_stop(dev->phydev);
+	free_irq(dev->irq, dev);
+	return err;
+}
+
+static int gmac_stop(struct net_device *dev)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+
+	if (!gmac->in_reset)
+		gmac_stop_running(dev);
+
+	phy_stop(dev->phydev);
+	free_irq(dev->irq, dev);
+
+	gmac_update_hw_stats(dev);
+
+	return 0;
+}
+
+static void gmac_set_multicast_list(struct net_device *dev)
+{
+	struct netdev_hw_addr *ha;
+	__u32 mc_filter[2];
+	unsigned bit_nr;
+
+	if (dev->flags & IFF_ALLMULTI)
+		return;
+
+	mc_filter[1] =3D mc_filter[0] =3D 0;
+	netdev_for_each_mc_addr(ha, dev) {
+		bit_nr =3D ~crc32_be(~0, ha->addr, ETH_ALEN) & 0x3f;
+		mc_filter[bit_nr >> 5] |=3D 1 << (bit_nr & 0x1f);
+	}
+
+	__raw_writel(mc_filter[0], gmac_ctl_reg(dev, GMAC_MCAST_FIL0));
+	__raw_writel(mc_filter[1], gmac_ctl_reg(dev, GMAC_MCAST_FIL1));
+}
+
+static void gmac_set_rx_mode(struct net_device *dev)
+{
+	GMAC_RX_FLTR_T filter =3D { .bits =3D {
+		.broadcast =3D 1,
+		.multicast =3D 1,
+		.unicast =3D 1,
+	} };
+
+	if (dev->flags & IFF_PROMISC) {
+		filter.bits.error =3D 1;
+		filter.bits.promiscuous =3D 1;
+	} else if (dev->flags & IFF_ALLMULTI) {
+		__raw_writel(~0, gmac_ctl_reg(dev, GMAC_MCAST_FIL0));
+		__raw_writel(~0, gmac_ctl_reg(dev, GMAC_MCAST_FIL1));
+	} else {
+		gmac_set_multicast_list(dev);
+	}
+
+	__raw_writel(filter.bits32, gmac_ctl_reg(dev, GMAC_RX_FLTR));
+}
+
+static void __gmac_set_mac_address(struct net_device *dev)
+{
+	__le32 addr[3];
+
+	memset(addr, 0, sizeof(addr));
+	memcpy(addr, dev->dev_addr, ETH_ALEN);
+
+	__raw_writel(le32_to_cpu(addr[0]), gmac_ctl_reg(dev, GMAC_STA_ADD0));
+	__raw_writel(le32_to_cpu(addr[1]), gmac_ctl_reg(dev, GMAC_STA_ADD1));
+	__raw_writel(le32_to_cpu(addr[2]), gmac_ctl_reg(dev, GMAC_STA_ADD2));
+}
+
+static int gmac_set_mac_address(struct net_device *dev, void *addr)
+{
+	struct sockaddr *sa =3D addr;
+
+	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
+	__gmac_set_mac_address(dev);
+
+	return 0;
+}
+
+static void gmac_clear_hw_stats(struct net_device *dev)
+{
+	__raw_readl(gmac_ctl_reg(dev, GMAC_IN_DISCARDS));
+	__raw_readl(gmac_ctl_reg(dev, GMAC_IN_ERRORS));
+	__raw_readl(gmac_ctl_reg(dev, GMAC_IN_MCAST));
+	__raw_readl(gmac_ctl_reg(dev, GMAC_IN_BCAST));
+	__raw_readl(gmac_ctl_reg(dev, GMAC_IN_MAC1));
+	__raw_readl(gmac_ctl_reg(dev, GMAC_IN_MAC2));
+}
+
+static struct rtnl_link_stats64 *gmac_get_stats64(struct net_device *d=
ev,
+	struct rtnl_link_stats64 *storage)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	unsigned int start;
+
+	gmac_update_hw_stats(dev);
+	dev_txq_stats_fold(dev, storage);
+
+	/* racing with RX NAPI */
+	do {
+		start =3D u64_stats_fetch_begin(&gmac->rx_stats_syncp);
+
+		storage->rx_packets =3D gmac->stats.rx_packets;
+		storage->rx_bytes =3D gmac->stats.rx_bytes;
+		storage->rx_errors =3D gmac->stats.rx_errors;
+		storage->rx_dropped =3D gmac->stats.rx_dropped;
+
+		storage->rx_length_errors =3D gmac->stats.rx_length_errors;
+		storage->rx_over_errors =3D gmac->stats.rx_over_errors;
+		storage->rx_crc_errors =3D gmac->stats.rx_crc_errors;
+		storage->rx_frame_errors =3D gmac->stats.rx_frame_errors;
+
+	} while (u64_stats_fetch_retry(&gmac->rx_stats_syncp, start));
+
+	/* racing with MIB and TX completion interrupts */
+	do {
+		start =3D u64_stats_fetch_begin(&gmac->ir_stats_syncp);
+
+		storage->tx_errors =3D gmac->stats.tx_errors;
+
+		storage->multicast =3D gmac->stats.multicast;
+		storage->rx_missed_errors =3D gmac->stats.rx_missed_errors;
+		storage->rx_fifo_errors =3D gmac->stats.rx_fifo_errors;
+
+	} while (u64_stats_fetch_retry(&gmac->ir_stats_syncp, start));
+
+	storage->rx_dropped +=3D storage->rx_missed_errors;
+
+	return storage;
+}
+
+static int gmac_change_mtu(struct net_device *dev, int new_mtu)
+{
+	int max_len =3D gmac_pick_rx_max_len(new_mtu);
+
+	if (max_len < 0)
+		return -EINVAL;
+
+	gmac_disable_tx_rx(dev);
+
+	dev->mtu =3D new_mtu;
+	gmac_update_config0_reg(dev,
+		max_len << CONFIG0_MAXLEN_SHIFT,
+		CONFIG0_MAXLEN_MASK);
+
+	gmac_enable_tx_rx(dev);
+
+	return 0;
+}
+
+static u32 gmac_get_rx_csum(struct net_device *dev)
+{
+	return !!(__raw_readl(gmac_ctl_reg(dev, GMAC_CONFIG0)) & CONFIG0_RX_C=
HKSUM);
+}
+
+static int gmac_set_rx_csum(struct net_device *dev, u32 enable)
+{
+	gmac_update_config0_reg(dev,
+		enable ? CONFIG0_RX_CHKSUM : 0, CONFIG0_RX_CHKSUM);
+
+	return 0;
+}
+
+static int gmac_set_tso(struct net_device *dev, u32 data)
+{
+	if (data)
+		dev->features |=3D NETIF_TSO_FEATURES;
+	else
+		dev->features &=3D ~NETIF_TSO_FEATURES;
+
+	return 0;
+}
+
+static int gmac_get_sset_count(struct net_device *dev, int sset)
+{
+	return sset =3D=3D ETH_SS_STATS ? GMAC_STATS_NUM : 0;
+}
+
+static void gmac_get_strings(struct net_device *dev, u32 stringset, u8=
 *data)
+{
+	if (stringset !=3D ETH_SS_STATS)
+		return;
+
+	memcpy(data, gmac_stats_strings, sizeof(gmac_stats_strings));
+}
+
+static void gmac_get_ethtool_stats(struct net_device *dev,
+	struct ethtool_stats *estats, u64 *values)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	unsigned int start;
+	u64 *p;
+	int i;
+
+	gmac_update_hw_stats(dev);
+
+	/* racing with MIB interrupt */
+	do {
+		p =3D values;
+		start =3D u64_stats_fetch_begin(&gmac->ir_stats_syncp);
+
+		for (i =3D 0; i < RX_STATS_NUM; ++i)
+			*p++ =3D gmac->hw_stats[i];
+
+	} while (u64_stats_fetch_retry(&gmac->ir_stats_syncp, start));
+	values =3D p;
+
+	/* racing with RX NAPI */
+	do {
+		p =3D values;
+		start =3D u64_stats_fetch_begin(&gmac->rx_stats_syncp);
+
+		for (i =3D 0; i < RX_STATUS_NUM; ++i)
+			*p++ =3D gmac->rx_stats[i];
+		for (i =3D 0; i < RX_CHKSUM_NUM; ++i)
+			*p++ =3D gmac->rx_csum_stats[i];
+		*p++ =3D gmac->rx_napi_exits;
+
+	} while (u64_stats_fetch_retry(&gmac->rx_stats_syncp, start));
+	values =3D p;
+
+	/* racing with TX start_xmit */
+	do {
+		p =3D values;
+		start =3D u64_stats_fetch_begin(&gmac->tx_stats_syncp);
+
+		for (i =3D 0; i < TX_MAX_FRAGS; ++i)
+			*values++ =3D gmac->tx_frag_stats[i];
+		*values++ =3D gmac->tx_frags_linearized;
+		*values++ =3D gmac->tx_hw_csummed;
+
+	} while (u64_stats_fetch_retry(&gmac->tx_stats_syncp, start));
+}
+
+static int gmac_get_settings(struct net_device *dev, struct ethtool_cm=
d *cmd)
+{
+	if (!dev->phydev)
+		return -ENXIO;
+	return phy_ethtool_gset(dev->phydev, cmd);
+}
+
+static int gmac_set_settings(struct net_device *dev, struct ethtool_cm=
d *cmd)
+{
+	if (!dev->phydev)
+		return -ENXIO;
+	return phy_ethtool_sset(dev->phydev, cmd);
+}
+
+static int gmac_nway_reset(struct net_device *dev)
+{
+	if (!dev->phydev)
+		return -ENXIO;
+	return phy_start_aneg(dev->phydev);
+}
+
+static void gmac_get_pauseparam(struct net_device *dev,
+	struct ethtool_pauseparam *pparam)
+{
+	GMAC_CONFIG0_T config0;
+
+	config0.bits32 =3D __raw_readl(gmac_ctl_reg(dev, GMAC_CONFIG0));
+
+	pparam->rx_pause =3D config0.bits.rx_fc_en;
+	pparam->tx_pause =3D config0.bits.tx_fc_en;
+	pparam->autoneg =3D true;
+}
+
+static void gmac_get_ringparam(struct net_device *dev,
+	struct ethtool_ringparam *rp)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	GMAC_CONFIG0_T config0;
+
+	config0.bits32 =3D __raw_readl(gmac_ctl_reg(dev, GMAC_CONFIG0));
+
+	rp->rx_max_pending =3D 1 << 15;
+	rp->rx_mini_max_pending =3D 0;
+	rp->rx_jumbo_max_pending =3D 0;
+	rp->tx_max_pending =3D 1 << 15;
+
+	rp->rx_pending =3D 1 << gmac->rxq_order;
+	rp->rx_mini_pending =3D 0;
+	rp->rx_jumbo_pending =3D 0;
+	rp->tx_pending =3D 1 << gmac->txq_order;
+}
+
+static int toe_resize_freeq(struct toe_private *toe, int changing_dev_=
id);
+
+static int gmac_set_ringparam(struct net_device *dev,
+	struct ethtool_ringparam *rp)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	struct toe_private *toe =3D netdev_to_toe(dev);
+	int err =3D 0;
+
+	if (netif_running(dev))
+		return -EBUSY;
+
+	if (rp->rx_pending) {
+		gmac->rxq_order =3D min(15, ilog2(rp->rx_pending - 1) + 1);
+		err =3D toe_resize_freeq(toe, dev->dev_id);
+	}
+
+	if (rp->tx_pending)
+		gmac->txq_order =3D min(15, ilog2(rp->tx_pending - 1) + 1);
+
+	return err;
+}
+
+static int gmac_get_coalesce(struct net_device *dev,
+	struct ethtool_coalesce *ecmd)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+
+	ecmd->rx_max_coalesced_frames =3D 1;
+	ecmd->tx_max_coalesced_frames =3D gmac->irq_every_tx_packets;
+
+	return 0;
+}
+
+static int gmac_set_coalesce(struct net_device *dev,
+	struct ethtool_coalesce *ecmd)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+
+	if (ecmd->tx_max_coalesced_frames < 1)
+		return -EINVAL;
+	if (ecmd->tx_max_coalesced_frames >=3D 1 << gmac->txq_order)
+		return -EINVAL;
+
+	gmac->irq_every_tx_packets =3D ecmd->tx_max_coalesced_frames;
+
+	return 0;
+}
+
+static u32 gmac_get_msglevel(struct net_device *dev)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	return gmac->msg_enable;
+}
+
+static void gmac_set_msglevel(struct net_device *dev, u32 level)
+{
+	struct gmac_private *gmac =3D netdev_to_gmac(dev);
+	gmac->msg_enable =3D level;
+}
+
+static void gmac_get_drvinfo(struct net_device *dev,
+	struct ethtool_drvinfo *info)
+{
+	strcpy(info->driver, "sl351x");
+	strcpy(info->version, "mq-k");
+	strcpy(info->bus_info, dev->dev_id ? "1" : "0");
+}
+
+static const struct net_device_ops gmac_351x_ops =3D {
+	.ndo_init		=3D gmac_init,
+	.ndo_uninit		=3D gmac_uninit,
+	.ndo_open		=3D gmac_open,
+	.ndo_stop		=3D gmac_stop,
+	.ndo_start_xmit		=3D gmac_start_xmit,
+	.ndo_tx_timeout		=3D gmac_dump_dma_state,
+	.ndo_set_multicast_list	=3D gmac_set_multicast_list,
+	.ndo_set_rx_mode	=3D gmac_set_rx_mode,
+	.ndo_set_mac_address	=3D gmac_set_mac_address,
+	.ndo_get_stats64	=3D gmac_get_stats64,
+	.ndo_change_mtu		=3D gmac_change_mtu,
+};
+
+static const struct ethtool_ops gmac_351x_ethtool_ops =3D {
+	.get_rx_csum	=3D gmac_get_rx_csum,
+	.set_rx_csum	=3D gmac_set_rx_csum,
+	.get_tx_csum	=3D ethtool_op_get_tx_csum,
+	.set_tx_csum	=3D ethtool_op_set_tx_ipv6_csum,
+	.get_sg		=3D ethtool_op_get_sg,
+	.set_sg		=3D ethtool_op_set_sg,
+	.get_tso	=3D ethtool_op_get_tso,
+	.set_tso	=3D gmac_set_tso,
+	.get_sset_count	=3D gmac_get_sset_count,
+	.get_strings	=3D gmac_get_strings,
+	.get_ethtool_stats =3D gmac_get_ethtool_stats,
+	.get_settings	=3D gmac_get_settings,
+	.set_settings	=3D gmac_set_settings,
+	.get_link	=3D ethtool_op_get_link,
+	.nway_reset	=3D gmac_nway_reset,
+	.get_pauseparam	=3D gmac_get_pauseparam,
+	.get_ringparam	=3D gmac_get_ringparam,
+	.set_ringparam	=3D gmac_set_ringparam,
+	.get_coalesce	=3D gmac_get_coalesce,
+	.set_coalesce	=3D gmac_set_coalesce,
+	.get_msglevel	=3D gmac_get_msglevel,
+	.set_msglevel	=3D gmac_set_msglevel,
+	.get_drvinfo	=3D gmac_get_drvinfo,
+};
+
+static int __devinit gmac_init_netdev(struct toe_private *toe, int num=
,
+	struct platform_device *pdev)
+{
+	struct gemini_gmac_platform_data *pdata =3D pdev->dev.platform_data;
+	struct gmac_private *gmac;
+	struct net_device *dev;
+	__le32 addr[3];
+	int irq, err;
+
+	if (!pdata->bus_id[num])
+		return 0;
+
+	irq =3D platform_get_irq(pdev, num);
+	if (irq < 0) {
+		dev_err(toe->dev, "No IRQ for ethernet device #%d\n", num);
+		return irq;
+	}
+
+	dev =3D alloc_etherdev_mq(sizeof(*gmac), TX_QUEUE_NUM);
+	if (!dev) {
+		dev_err(toe->dev, "Can't allocate ethernet device #%d\n", num);
+		return -ENOMEM;
+	}
+
+	gmac =3D netdev_priv(dev);
+	dev->ml_priv =3D toe;
+	SET_NETDEV_DEV(dev, toe->dev);
+
+	toe->netdev[num] =3D dev;
+	dev->dev_id =3D num;
+
+	gmac->dma_iomem =3D toe->iomem + TOE_GMAC_DMA_BASE(num);
+	dev->base_addr =3D (unsigned long)(toe->iomem + TOE_GMAC_BASE(num));
+	dev->irq =3D irq;
+
+	dev->netdev_ops =3D &gmac_351x_ops;
+	SET_ETHTOOL_OPS(dev, &gmac_351x_ethtool_ops);
+
+	spin_lock_init(&gmac->config_lock);
+	gmac->msg_enable =3D debug_level;
+	gmac_clear_hw_stats(dev);
+
+	/* select working offloads by default */
+	/* (SG will be disabled when HW csum is disabled) */
+	/* TSO_ECN untested, TX csum unreliable, TX DMA unreliable */
+	dev->features |=3D NETIF_F_SG | NETIF_F_GSO | NETIF_F_GRO;
+
+	netif_napi_add(dev, &gmac->napi, gmac_napi_poll, DEFAULT_NAPI_WEIGHT)=
;
+
+	/* dump MAC address regs; CPU is LE anyway */
+	addr[0] =3D cpu_to_le32(__raw_readl(gmac_ctl_reg(dev, GMAC_STA_ADD0))=
);
+	addr[1] =3D cpu_to_le32(__raw_readl(gmac_ctl_reg(dev, GMAC_STA_ADD1))=
);
+	addr[2] =3D cpu_to_le32(__raw_readl(gmac_ctl_reg(dev, GMAC_STA_ADD2))=
);
+	dev_dbg(&pdev->dev, "port %d address regs: %pM %pM\n",
+		num, (char *)addr, (char *)addr + ETH_ALEN);
+
+	if (is_valid_ether_addr((void *)addr))
+		memcpy(dev->dev_addr, addr, ETH_ALEN);
+	else
+		random_ether_addr(dev->dev_addr);
+	__gmac_set_mac_address(dev);
+
+	err =3D gmac_setup_phy(dev);
+	if (err)
+		netif_warn(gmac, probe, dev,
+			"PHY init failed: %d, deferring to ifup time\n", err);
+
+	err =3D register_netdev(dev);
+	if (!err)
+		return 0;
+
+	toe->netdev[num] =3D NULL;
+	free_netdev(dev);
+	return err;
+}
+
+static struct page *toe_alloc_freeq_pages(struct toe_private *toe, boo=
l emerg)
+{
+	gfp_t gfp_mask =3D GFP_NOIO;
+	bool retried =3D false;
+
+retry:
+	toe->freeq_page =3D alloc_pages(gfp_mask, toe->alloc_order);
+	if (!toe->freeq_page) {
+		toe->alloc_order >>=3D 1;
+		if (gfp_mask & __GFP_HIGH)
+			/* even emergency alloc failed */
+			return NULL;
+		if (!toe->alloc_order && emerg)
+			gfp_mask |=3D __GFP_HIGH;
+		retried =3D true;
+		goto retry;
+	}
+
+	if (dma_mapping_error(toe->dev, dma_map_page(toe->dev,
+	    toe->freeq_page, 0, PAGE_SIZE << toe->alloc_order,
+	    DMA_FROM_DEVICE))) {
+		put_page(toe->freeq_page);
+		goto retry;
+	}
+
+	toe->freeq_page_count =3D 1 << toe->alloc_order;
+	toe->freeq_page_offs =3D 0;
+
+	if (!retried && toe->alloc_order < RX_MAX_ALLOC_ORDER)
+		toe->alloc_order++;
+
+	return toe->freeq_page;
+}
+
+static struct page *toe_get_next_page(struct toe_private *toe,
+	struct page *page, unsigned eaten_size)
+{
+	toe->freeq_page_offs +=3D eaten_size;
+	if (toe->freeq_page_offs & ~PAGE_MASK) {
+		get_page(page);
+		return page;
+	}
+
+	if (!--toe->freeq_page_count)
+		return NULL;
+
+	toe->freeq_page_offs =3D 0;
+
+	toe->freeq_page =3D ++page;
+	get_page(page);
+
+	return page;
+}
+
+static unsigned int toe_fill_freeq_range(struct toe_private *toe,
+	unsigned int begin, unsigned int end)
+{
+	void __iomem *ptr_reg =3D toe_reg(toe, GLOBAL_SWFQ_RWPTR_REG);
+	GMAC_RXDESC_T *desc, *dend;
+	struct page *page;
+	unsigned count;
+
+	dev_dbg(toe->dev, "freeq: filling <%u,%u)  (ptr: %u %u)\n",
+		begin, end, GET_RPTR(ptr_reg), GET_WPTR(ptr_reg));
+
+	if (toe->freeq_page_count)
+		page =3D toe->freeq_page;
+	else
+		page =3D NULL;
+
+	desc =3D toe->freeq_ring + begin;
+	dend =3D toe->freeq_ring + end;
+
+	for (count =3D 0; desc !=3D dend; ++desc, ++count) {
+		if (!page) {
+			page =3D toe_alloc_freeq_pages(toe, 0);
+			if (!page)
+				break;
+		}
+
+		/* only word2 gets copied to rxq descriptor */
+		/* buffer size is taken from DMA_SKB_SIZE_REG */
+		desc->word2.buf_adr =3D page_to_dma(toe->dev, page) +
+			toe->freeq_page_offs;
+
+		if (unlikely(!count))
+			dev_dbg(toe->dev,
+				"freeq[%zu]: 0x%08x 0x%08x 0x%08x 0x%08x, page %p, offs 0x%04x\n",
+				desc - toe->freeq_ring,
+				desc->word0.bits32, desc->word1.bits32,
+				desc->word2.bits32, desc->word3.bits32,
+				page, toe->freeq_page_offs);
+
+		page =3D toe_get_next_page(toe, page,
+			1 << toe->freeq_frag_order);
+	}
+
+	end =3D (desc - toe->freeq_ring) & __RWPTR_MASK(toe->freeq_order);
+	SET_WPTR(ptr_reg, end);
+
+	return count;
+}
+
+static void toe_enable_irq(struct toe_private *toe, int enable)
+{
+	void __iomem *irqen_reg =3D toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_4_RE=
G);
+
+	unsigned long flags;
+	unsigned val;
+
+	spin_lock_irqsave(&toe->irq_lock, flags);
+
+	val =3D __raw_readl(irqen_reg);
+	if (enable)
+		val |=3D SWFQ_EMPTY_INT_BIT;
+	else
+		val &=3D ~SWFQ_EMPTY_INT_BIT;
+	__raw_writel(val, irqen_reg);
+
+	spin_unlock_irqrestore(&toe->irq_lock, flags);
+}
+
+static irqreturn_t toe_interrupt(int irq, void *data)
+{
+	struct toe_private *toe =3D data;
+
+	void __iomem *irqif_reg =3D toe_reg(toe, GLOBAL_INTERRUPT_STATUS_4_RE=
G);
+	void __iomem *irqen_reg =3D toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_4_RE=
G);
+	unsigned val, en;
+	irqreturn_t ret =3D IRQ_NONE;
+
+	spin_lock(&toe->irq_lock);
+
+	val =3D __raw_readl(irqif_reg);
+	val &=3D en =3D __raw_readl(irqen_reg);
+
+	if (val & SWFQ_EMPTY_INT_BIT) {
+		toe_enable_irq(toe, 0);
+		ret =3D IRQ_WAKE_THREAD;
+	}
+
+	spin_unlock(&toe->irq_lock);
+
+	return ret;
+}
+
+static irqreturn_t toe_interrupt_thread(int irq, void *data)
+{
+	struct toe_private *toe =3D data;
+	void __iomem *rwptr_reg =3D toe_reg(toe, GLOBAL_SWFQ_RWPTR_REG);
+	void __iomem *irqif_reg =3D toe_reg(toe, GLOBAL_INTERRUPT_STATUS_4_RE=
G);
+	unsigned int r, w, d, end, count =3D 0;
+
+retry:
+	w =3D GET_WPTR(rwptr_reg);
+	r =3D GET_RPTR(rwptr_reg);
+
+	d =3D RWPTR_DISTANCE(r, w, toe->freeq_order);
+	if (unlikely(d >=3D toe->freeq_entries))
+		goto full;
+	d =3D toe->freeq_entries - d;
+
+	end =3D min(w + d, 1u << toe->freeq_order);
+	count +=3D toe_fill_freeq_range(toe, w, end);
+
+	if (count =3D=3D end - w && !(end & __RWPTR_MASK(toe->freeq_order)))
+		goto retry;
+
+full:
+	dev_dbg(toe->dev, "freeq: filled %u buffers\n", count);
+
+	__raw_writel(SWFQ_EMPTY_INT_BIT, irqif_reg);
+	if (unlikely(GET_WPTR(rwptr_reg) =3D=3D GET_RPTR(rwptr_reg))) {
+		if (unlikely(!count))
+			dev_warn(toe->dev, "freeq: full, but empty?\n");
+		count =3D 0;
+		goto retry;
+	}
+
+	toe_enable_irq(toe, 1);
+
+	return IRQ_HANDLED;
+}
+
+static int toe_setup_freeq(struct toe_private *toe)
+{
+	void __iomem *dma_reg =3D toe_reg(toe, GLOBAL_SW_FREEQ_BASE_SIZE_REG)=
;
+	QUEUE_THRESHOLD_T qt;
+	DMA_SKB_SIZE_T skbsz =3D { .bits =3D { .sw_skb_size =3D 1 << toe->fre=
eq_frag_order } };
+	unsigned n;
+
+	toe->freeq_ring =3D dma_alloc_coherent(toe->dev,
+		sizeof(*toe->freeq_ring) << toe->freeq_order,
+		&toe->freeq_dma_base, GFP_KERNEL);
+	if (!toe->freeq_ring)
+		return -ENOMEM;
+
+	BUG_ON(toe->freeq_dma_base & ~DMA_Q_BASE_MASK);
+
+	__raw_writel(skbsz.bits32, toe_reg(toe, GLOBAL_DMA_SKB_SIZE_REG));
+	__raw_writel(toe->freeq_dma_base | toe->freeq_order, dma_reg);
+
+	/* fill ring */
+	n =3D toe_fill_freeq_range(toe, 0, toe->freeq_entries);
+	if (!n)
+		goto err_freeq;
+	if (n !=3D toe->freeq_entries)
+		dev_warn(toe->dev, "Allocated only %u of %u RX buffers\n",
+			n, toe->freeq_entries);
+
+	qt.bits32 =3D __raw_readl(toe_reg(toe, GLOBAL_QUEUE_THRESHOLD_REG));
+	qt.bits.swfq_empty =3D min_t(unsigned, (n + 1) >> 1, 255);
+	__raw_writel(qt.bits32, toe_reg(toe, GLOBAL_QUEUE_THRESHOLD_REG));
+
+	dev_dbg(toe->dev, "freeq: ring %p (dma 0x%08x), len %u (order %u), th=
r %u\n",
+		toe->freeq_ring, toe->freeq_dma_base,
+		toe->freeq_entries, toe->freeq_order, qt.bits.swfq_empty);
+
+	return 0;
+
+err_freeq:
+	__raw_writel(0, dma_reg);
+	dma_free_coherent(toe->dev,
+		sizeof(*toe->freeq_ring) << toe->freeq_order,
+		toe->freeq_ring, toe->freeq_dma_base);
+	toe->freeq_ring =3D NULL;
+
+	return -ENOMEM;
+}
+
+static void toe_cleanup_freeq(struct toe_private *toe)
+{
+	void __iomem *dma_reg =3D toe_reg(toe, GLOBAL_SW_FREEQ_BASE_SIZE_REG)=
;
+	void __iomem *ptr_reg =3D toe_reg(toe, GLOBAL_SWFQ_RWPTR_REG);
+	unsigned i, e, mask =3D __RWPTR_MASK(toe->freeq_order);
+
+	i =3D GET_RPTR(ptr_reg);
+	e =3D GET_WPTR(ptr_reg);
+	__raw_writel(0, ptr_reg);
+	__raw_writel(0, dma_reg);
+
+	for (; i !=3D e; i =3D __RWPTR_NEXT(i, mask))
+		put_page(toe_unmap_rx_desc(toe, &toe->freeq_ring[i]));
+
+	dma_free_coherent(toe->dev,
+		sizeof(*toe->freeq_ring) << toe->freeq_order,
+		toe->freeq_ring, toe->freeq_dma_base);
+
+	toe->freeq_ring =3D NULL;
+}
+
+static int toe_resize_freeq(struct toe_private *toe, int changing_dev_=
id)
+{
+	struct net_device *other =3D toe->netdev[1 - changing_dev_id];
+	unsigned new_size =3D 0;
+	unsigned new_order;
+	int err;
+
+	if (other && netif_running(other))
+		return -EBUSY;
+
+	if (toe->netdev[0])
+		new_size  =3D 1 << netdev_to_gmac(toe->netdev[0])->rxq_order;
+
+	if (toe->netdev[1])
+		new_size +=3D 1 << netdev_to_gmac(toe->netdev[1])->rxq_order;
+
+	new_order =3D min(15, ilog2(new_size - 1) + 1);
+	if (new_size >=3D 1 << new_order)
+		new_size =3D (1 << new_order) - 1;
+
+	toe_enable_irq(toe, 0);
+	if (toe->freeq_ring)
+		toe_cleanup_freeq(toe);
+
+	toe->freeq_order =3D new_order;
+	toe->freeq_entries =3D new_size;
+
+	err =3D toe_setup_freeq(toe);
+	if (unlikely(err))
+		return err;
+
+	toe_enable_irq(toe, 1);
+
+	return 0;
+}
+
+
+/*
+ * Interrupt config:
+ *
+ *	GMAC0 intr bits ------> int0 ----> eth0
+ *	GMAC1 intr bits ------> int1 ----> eth1
+ *	TOE intr -------------> int1 ----> eth1
+ *	Classification Intr --> int0 ----> eth0
+ *	Default Q0 -----------> int0 ----> eth0
+ *	Default Q1 -----------> int1 ----> eth1
+ *	FreeQ intr -----------> int1 ----> eth1
+ */
+static void toe_prepare_irq(struct toe_private *toe)
+{
+	__raw_writel(0, toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_0_REG));
+	__raw_writel(0, toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_1_REG));
+	__raw_writel(0, toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_2_REG));
+	__raw_writel(0, toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_3_REG));
+	__raw_writel(0, toe_reg(toe, GLOBAL_INTERRUPT_ENABLE_4_REG));
+
+	__raw_writel(0xCCFC0FC0, toe_reg(toe, GLOBAL_INTERRUPT_SELECT_0_REG))=
;
+	__raw_writel(0x00F00002, toe_reg(toe, GLOBAL_INTERRUPT_SELECT_1_REG))=
;
+	__raw_writel(0xFFFFFFFF, toe_reg(toe, GLOBAL_INTERRUPT_SELECT_2_REG))=
;
+	__raw_writel(0xFFFFFFFF, toe_reg(toe, GLOBAL_INTERRUPT_SELECT_3_REG))=
;
+	__raw_writel(0xFF000003, toe_reg(toe, GLOBAL_INTERRUPT_SELECT_4_REG))=
;
+
+	/* edge-triggered interrupts packed to level-triggered one... */
+	__raw_writel(~0, toe_reg(toe, GLOBAL_INTERRUPT_STATUS_0_REG));
+	__raw_writel(~0, toe_reg(toe, GLOBAL_INTERRUPT_STATUS_1_REG));
+	__raw_writel(~0, toe_reg(toe, GLOBAL_INTERRUPT_STATUS_2_REG));
+	__raw_writel(~0, toe_reg(toe, GLOBAL_INTERRUPT_STATUS_3_REG));
+	__raw_writel(~0, toe_reg(toe, GLOBAL_INTERRUPT_STATUS_4_REG));
+}
+
+static __devinit int toe_init(struct toe_private *toe,
+	struct platform_device *pdev)
+{
+	int err;
+
+	__raw_writel(0, toe_reg(toe, GLOBAL_SW_FREEQ_BASE_SIZE_REG));
+	__raw_writel(0, toe_reg(toe, GLOBAL_HW_FREEQ_BASE_SIZE_REG));
+	__raw_writel(0, toe_reg(toe, GLOBAL_SWFQ_RWPTR_REG));
+	__raw_writel(0, toe_reg(toe, GLOBAL_HWFQ_RWPTR_REG));
+
+	toe->freeq_frag_order =3D DEFAULT_RX_BUF_ORDER;
+	toe->freeq_order =3D ~0;
+
+	toe_prepare_irq(toe);
+	err =3D request_threaded_irq(toe->irq, toe_interrupt,
+		toe_interrupt_thread, IRQF_SHARED, "sl351x-TOE", toe);
+	if (err)
+		goto err_freeq;
+
+	return 0;
+
+err_freeq:
+	toe_cleanup_freeq(toe);
+	return err;
+}
+
+static void toe_deinit(struct toe_private *toe)
+{
+	toe_prepare_irq(toe);
+	free_irq(toe->irq, toe);
+	toe_cleanup_freeq(toe);
+
+	if (toe->freeq_page_count)
+		put_page(toe->freeq_page);
+}
+
+static int toe_reset(struct toe_private *toe)
+{
+	unsigned int reg, retry =3D 5;
+
+	reg =3D __raw_readl(IO_ADDRESS(GEMINI_GLOBAL_BASE) + GLOBAL_RESET);
+	reg |=3D RESET_GMAC1 | RESET_GMAC0;
+	__raw_writel(reg, IO_ADDRESS(GEMINI_GLOBAL_BASE) + GLOBAL_RESET);
+
+	do {
+		udelay(2);
+		reg =3D __raw_readl(toe_reg(toe, GLOBAL_TOE_VERSION_REG));
+		barrier();
+	} while (!reg && --retry);
+
+	dev_info(toe->dev, "Gemini GMAC version 0x%x\n", reg);
+
+	return reg ? 0 : -EIO;
+}
+
+static int __devinit gemini_gmac_probe(struct platform_device *pdev)
+{
+	struct resource *res;
+	struct toe_private *toe;
+	int retval;
+
+	if (!pdev->dev.platform_data)
+		return -EINVAL;
+
+	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		dev_err(&pdev->dev, "can't get device resources\n");
+		return -ENODEV;
+	}
+
+	toe =3D kzalloc(sizeof(*toe), GFP_KERNEL);
+	if (!toe)
+		return -ENOMEM;
+
+	platform_set_drvdata(pdev, toe);
+	toe->dev =3D &pdev->dev;
+	toe->iomem =3D ioremap(res->start, resource_size(res));
+	if (!toe->iomem) {
+		dev_err(toe->dev, "ioremap failed\n");
+		retval =3D -EIO;
+		goto err_data;
+	}
+
+	retval =3D toe_reset(toe);
+	if (retval < 0)
+		goto err_unmap;
+
+	retval =3D toe->irq =3D platform_get_irq(pdev, 1);
+	if (retval < 0)
+		goto err_unmap;
+
+	spin_lock_init(&toe->irq_lock);
+
+	retval =3D toe_init(toe, pdev);
+	if (retval)
+		goto err_unmap;
+
+	retval =3D gmac_init_netdev(toe, 0, pdev);
+	if (retval)
+		goto err_uninit;
+
+	retval =3D gmac_init_netdev(toe, 1, pdev);
+	if (retval)
+		goto err_uninit;
+
+	toe_resize_freeq(toe, 0);
+
+	dev_dbg(&pdev->dev, "initialized.\n");
+	return 0;
+
+err_uninit:
+	if (toe->netdev[0])
+		unregister_netdev(toe->netdev[0]);
+	toe_deinit(toe);
+err_unmap:
+	iounmap(toe->iomem);
+err_data:
+	kfree(toe);
+	return retval;
+}
+
+static int __devexit gemini_gmac_remove(struct platform_device *pdev)
+{
+	struct toe_private *toe =3D platform_get_drvdata(pdev);
+	int i;
+
+	for (i =3D 0; i < 2; i++)
+		if (toe->netdev[i])
+			unregister_netdev(toe->netdev[i]);
+	toe_deinit(toe);
+
+	iounmap(toe->iomem);
+	kfree(toe);
+
+	return 0;
+}
+
+static struct platform_driver gemini_gmac_driver =3D {
+	.probe		=3D gemini_gmac_probe,
+	.remove		=3D __devexit_p(gemini_gmac_remove),
+	.driver.name	=3D "gemini-gmac",
+	.driver.owner	=3D THIS_MODULE,
+};
+
+static int __init gemini_gmac_init(void)
+{
+#ifdef CONFIG_MDIO_GPIO_MODULE
+	request_module("mdio-gpio");
+#endif
+	return platform_driver_register(&gemini_gmac_driver);
+}
+
+static void __exit gemini_gmac_exit(void)
+{
+	platform_driver_unregister(&gemini_gmac_driver);
+}
+
+module_init(gemini_gmac_init);
+module_exit(gemini_gmac_exit);
+
+MODULE_AUTHOR("Micha=C5=82 Miros=C5=82aw");
+MODULE_DESCRIPTION("StorLink SL351x (Gemini) ethernet driver");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:gemini-gmac");
diff --git a/drivers/net/sl351x_hw.h b/drivers/net/sl351x_hw.h
new file mode 100644
index 0000000..05b1b36
--- /dev/null
+++ b/drivers/net/sl351x_hw.h
@@ -0,0 +1,1436 @@
+/*
+ *  Register definitions for Gemini LEPUS GMAC Ethernet device driver.
+ *
+ *  Copyright (C) 2006, Storlink, Corp.
+ *  Copyright (C) 2008-2009, Paulius Zaleckas <paulius.zaleckas@telton=
ika.lt>
+ *  Copyright (C) 2010, Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmq=
m.pl>
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License as published b=
y
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+#ifndef _GMAC_HW_H
+#define _GMAC_HW_H
+
+#include <linux/bitops.h>
+
+/*
+ * Base Registers
+ */
+#define TOE_NONTOE_QUE_HDR_BASE		0x2000
+#define TOE_TOE_QUE_HDR_BASE		0x3000
+#define TOE_V_BIT_BASE			0x4000
+#define TOE_A_BIT_BASE			0x6000
+#define TOE_GMAC_DMA_BASE(x)		(0x8000 + 0x4000 * (x))
+#define TOE_GMAC_BASE(x)		(0xA000 + 0x4000 * (x))
+
+/*
+ * Queue ID
+ */
+#define TOE_SW_FREE_QID			0x00
+#define TOE_HW_FREE_QID			0x01
+#define TOE_GMAC0_SW_TXQ0_QID		0x02
+#define TOE_GMAC0_SW_TXQ1_QID		0x03
+#define TOE_GMAC0_SW_TXQ2_QID		0x04
+#define TOE_GMAC0_SW_TXQ3_QID		0x05
+#define TOE_GMAC0_SW_TXQ4_QID		0x06
+#define TOE_GMAC0_SW_TXQ5_QID		0x07
+#define TOE_GMAC0_HW_TXQ0_QID		0x08
+#define TOE_GMAC0_HW_TXQ1_QID		0x09
+#define TOE_GMAC0_HW_TXQ2_QID		0x0A
+#define TOE_GMAC0_HW_TXQ3_QID		0x0B
+#define TOE_GMAC1_SW_TXQ0_QID		0x12
+#define TOE_GMAC1_SW_TXQ1_QID		0x13
+#define TOE_GMAC1_SW_TXQ2_QID		0x14
+#define TOE_GMAC1_SW_TXQ3_QID		0x15
+#define TOE_GMAC1_SW_TXQ4_QID		0x16
+#define TOE_GMAC1_SW_TXQ5_QID		0x17
+#define TOE_GMAC1_HW_TXQ0_QID		0x18
+#define TOE_GMAC1_HW_TXQ1_QID		0x19
+#define TOE_GMAC1_HW_TXQ2_QID		0x1A
+#define TOE_GMAC1_HW_TXQ3_QID		0x1B
+#define TOE_GMAC0_DEFAULT_QID		0x20
+#define TOE_GMAC1_DEFAULT_QID		0x21
+#define TOE_CLASSIFICATION_QID(x)	(0x22 + x)	/* 0x22 ~ 0x2F */
+#define TOE_TOE_QID(x)			(0x40 + x)	/* 0x40 ~ 0x7F */
+
+/*
+ * old info:
+ * TOE DMA Queue Size should be 2^n, n =3D 6...12
+ * TOE DMA Queues are the following queue types:
+ *		SW Free Queue, HW Free Queue,
+ *		GMAC 0/1 SW TX Q0-5, and GMAC 0/1 HW TX Q0-5
+ * The base address and descriptor number are configured at
+ * DMA Queues Descriptor Ring Base Address/Size Register (offset 0x000=
4)
+ */
+
+#define GET_WPTR(addr)			__raw_readw((addr) + 2)
+#define GET_RPTR(addr)			__raw_readw((addr))
+#define SET_WPTR(addr, data)		__raw_writew((data), (addr) + 2)
+#define SET_RPTR(addr, data)		__raw_writew((data), (addr))
+#define __RWPTR_NEXT(x, mask)		(((unsigned int)(x) + 1) & (mask))
+#define __RWPTR_PREV(x, mask)		(((unsigned int)(x) - 1) & (mask))
+#define __RWPTR_DISTANCE(r, w, mask)	(((unsigned int)(w) - (r)) & (mas=
k))
+#define __RWPTR_MASK(order)		((1 << (order)) - 1)
+#define RWPTR_NEXT(x, order)		__RWPTR_NEXT((x), __RWPTR_MASK((order)))
+#define RWPTR_PREV(x, order)		__RWPTR_PREV((x), __RWPTR_MASK((order)))
+#define RWPTR_DISTANCE(r, w, order)	__RWPTR_DISTANCE((r), (w), \
+						__RWPTR_MASK((order)))
+
+/*
+ * Global registers
+ * #define TOE_GLOBAL_BASE			(TOE_BASE + 0x0000)
+ * Base 0x60000000
+ */
+#define GLOBAL_TOE_VERSION_REG		0x0000
+#define GLOBAL_SW_FREEQ_BASE_SIZE_REG	0x0004
+#define GLOBAL_HW_FREEQ_BASE_SIZE_REG	0x0008
+#define GLOBAL_DMA_SKB_SIZE_REG		0x0010
+#define GLOBAL_SWFQ_RWPTR_REG		0x0014
+#define GLOBAL_HWFQ_RWPTR_REG		0x0018
+#define GLOBAL_INTERRUPT_STATUS_0_REG	0x0020
+#define GLOBAL_INTERRUPT_ENABLE_0_REG	0x0024
+#define GLOBAL_INTERRUPT_SELECT_0_REG	0x0028
+#define GLOBAL_INTERRUPT_STATUS_1_REG	0x0030
+#define GLOBAL_INTERRUPT_ENABLE_1_REG	0x0034
+#define GLOBAL_INTERRUPT_SELECT_1_REG	0x0038
+#define GLOBAL_INTERRUPT_STATUS_2_REG	0x0040
+#define GLOBAL_INTERRUPT_ENABLE_2_REG	0x0044
+#define GLOBAL_INTERRUPT_SELECT_2_REG	0x0048
+#define GLOBAL_INTERRUPT_STATUS_3_REG	0x0050
+#define GLOBAL_INTERRUPT_ENABLE_3_REG	0x0054
+#define GLOBAL_INTERRUPT_SELECT_3_REG	0x0058
+#define GLOBAL_INTERRUPT_STATUS_4_REG	0x0060
+#define GLOBAL_INTERRUPT_ENABLE_4_REG	0x0064
+#define GLOBAL_INTERRUPT_SELECT_4_REG	0x0068
+#define GLOBAL_HASH_TABLE_BASE_REG	0x006C
+#define GLOBAL_QUEUE_THRESHOLD_REG	0x0070
+
+/*
+ * GMAC 0/1 DMA/TOE register
+ * #define TOE_GMAC0_DMA_BASE		(TOE_BASE + 0x8000)
+ * #define TOE_GMAC1_DMA_BASE		(TOE_BASE + 0xC000)
+ * Base 0x60008000 or 0x6000C000
+ */
+#define GMAC_DMA_CTRL_REG		0x0000
+#define GMAC_TX_WEIGHTING_CTRL_0_REG	0x0004
+#define GMAC_TX_WEIGHTING_CTRL_1_REG	0x0008
+#define GMAC_SW_TX_QUEUE0_PTR_REG	0x000C
+#define GMAC_SW_TX_QUEUE1_PTR_REG	0x0010
+#define GMAC_SW_TX_QUEUE2_PTR_REG	0x0014
+#define GMAC_SW_TX_QUEUE3_PTR_REG	0x0018
+#define GMAC_SW_TX_QUEUE4_PTR_REG	0x001C
+#define GMAC_SW_TX_QUEUE5_PTR_REG	0x0020
+#define GMAC_SW_TX_QUEUE_PTR_REG(i)	(GMAC_SW_TX_QUEUE0_PTR_REG + 4 * (=
i))
+#define GMAC_HW_TX_QUEUE0_PTR_REG	0x0024
+#define GMAC_HW_TX_QUEUE1_PTR_REG	0x0028
+#define GMAC_HW_TX_QUEUE2_PTR_REG	0x002C
+#define GMAC_HW_TX_QUEUE3_PTR_REG	0x0030
+#define GMAC_HW_TX_QUEUE_PTR_REG(i)	(GMAC_HW_TX_QUEUE0_PTR_REG + 4 * (=
i))
+#define GMAC_DMA_TX_FIRST_DESC_REG	0x0038
+#define GMAC_DMA_TX_CURR_DESC_REG	0x003C
+#define GMAC_DMA_TX_DESC_WORD0_REG	0x0040
+#define GMAC_DMA_TX_DESC_WORD1_REG	0x0044
+#define GMAC_DMA_TX_DESC_WORD2_REG	0x0048
+#define GMAC_DMA_TX_DESC_WORD3_REG	0x004C
+#define GMAC_SW_TX_QUEUE_BASE_REG	0x0050
+#define GMAC_HW_TX_QUEUE_BASE_REG	0x0054
+#define GMAC_DMA_RX_FIRST_DESC_REG	0x0058
+#define GMAC_DMA_RX_CURR_DESC_REG	0x005C
+#define GMAC_DMA_RX_DESC_WORD0_REG	0x0060
+#define GMAC_DMA_RX_DESC_WORD1_REG	0x0064
+#define GMAC_DMA_RX_DESC_WORD2_REG	0x0068
+#define GMAC_DMA_RX_DESC_WORD3_REG	0x006C
+#define GMAC_HASH_ENGINE_REG0		0x0070
+#define GMAC_HASH_ENGINE_REG1		0x0074
+/* matching rule 0 Control register 0 */
+#define GMAC_MR0CR0			0x0078
+#define GMAC_MR0CR1			0x007C
+#define GMAC_MR0CR2			0x0080
+#define GMAC_MR1CR0			0x0084
+#define GMAC_MR1CR1			0x0088
+#define GMAC_MR1CR2			0x008C
+#define GMAC_MR2CR0			0x0090
+#define GMAC_MR2CR1			0x0094
+#define GMAC_MR2CR2			0x0098
+#define GMAC_MR3CR0			0x009C
+#define GMAC_MR3CR1			0x00A0
+#define GMAC_MR3CR2			0x00A4
+/* Support Protocol Regsister 0 */
+#define GMAC_SPR0			0x00A8
+#define GMAC_SPR1			0x00AC
+#define GMAC_SPR2			0x00B0
+#define GMAC_SPR3			0x00B4
+#define GMAC_SPR4			0x00B8
+#define GMAC_SPR5			0x00BC
+#define GMAC_SPR6			0x00C0
+#define GMAC_SPR7			0x00C4
+/* GMAC Hash/Rx/Tx AHB Weighting register */
+#define GMAC_AHB_WEIGHT_REG		0x00C8
+
+/*
+ * TOE GMAC 0/1 register
+ * #define TOE_GMAC0_BASE				(TOE_BASE + 0xA000)
+ * #define TOE_GMAC1_BASE				(TOE_BASE + 0xE000)
+ * Base 0x6000A000 or 0x6000E000
+ */
+enum GMAC_REGISTER {
+	GMAC_STA_ADD0	=3D 0x0000,
+	GMAC_STA_ADD1	=3D 0x0004,
+	GMAC_STA_ADD2	=3D 0x0008,
+	GMAC_RX_FLTR	=3D 0x000c,
+	GMAC_MCAST_FIL0 =3D 0x0010,
+	GMAC_MCAST_FIL1 =3D 0x0014,
+	GMAC_CONFIG0	=3D 0x0018,
+	GMAC_CONFIG1	=3D 0x001c,
+	GMAC_CONFIG2	=3D 0x0020,
+	GMAC_CONFIG3	=3D 0x0024,
+	GMAC_RESERVED	=3D 0x0028,
+	GMAC_STATUS	=3D 0x002c,
+	GMAC_IN_DISCARDS=3D 0x0030,
+	GMAC_IN_ERRORS  =3D 0x0034,
+	GMAC_IN_MCAST   =3D 0x0038,
+	GMAC_IN_BCAST   =3D 0x003c,
+	GMAC_IN_MAC1    =3D 0x0040,	/* for STA 1 MAC Address */
+	GMAC_IN_MAC2    =3D 0x0044	/* for STA 2 MAC Address */
+};
+
+#define RX_STATS_NUM	6
+
+/*
+ * DMA Queues description Ring Base Address/Size Register (offset 0x00=
04)
+ */
+typedef union {
+	unsigned int bits32;
+	unsigned int base_size;
+} DMA_Q_BASE_SIZE_T;
+#define DMA_Q_BASE_MASK		(~0x0f)
+
+/*
+ * DMA SKB Buffer register (offset 0x0008)
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_0008 {
+		unsigned int sw_skb_size : 16;	/* SW Free poll SKB Size */
+		unsigned int hw_skb_size : 16;	/* HW Free poll SKB Size */
+	} bits;
+} DMA_SKB_SIZE_T;
+
+/*
+ * DMA SW Free Queue Read/Write Pointer Register (offset 0x000C)
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_000c {
+		unsigned int rptr	: 16;	/* Read Ptr, RO */
+		unsigned int wptr	: 16;	/* Write Ptr, RW */
+	} bits;
+} DMA_RWPTR_T;
+
+/*
+ * DMA HW Free Queue Read/Write Pointer Register (offset 0x0010)
+ * see DMA_RWPTR_T structure
+ */
+
+/*
+ * Interrupt Status Register 0	(offset 0x0020)
+ * Interrupt Mask Register 0	(offset 0x0024)
+ * Interrupt Select Register 0	(offset 0x0028)
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_0020 {
+		/* GMAC0 SW Tx Queue 0 EOF Interrupt */
+		unsigned int swtq00_eof	: 1;
+		unsigned int swtq01_eof	: 1;
+		unsigned int swtq02_eof	: 1;
+		unsigned int swtq03_eof	: 1;
+		unsigned int swtq04_eof	: 1;
+		unsigned int swtq05_eof	: 1;
+		/* GMAC1 SW Tx Queue 0 EOF Interrupt */
+		unsigned int swtq10_eof	: 1;
+		unsigned int swtq11_eof	: 1;
+		unsigned int swtq12_eof	: 1;
+		unsigned int swtq13_eof	: 1;
+		unsigned int swtq14_eof	: 1;
+		unsigned int swtq15_eof	: 1;
+		/* GMAC0 SW Tx Queue 0 Finish Interrupt */
+		unsigned int swtq00_fin	: 1;
+		unsigned int swtq01_fin	: 1;
+		unsigned int swtq02_fin	: 1;
+		unsigned int swtq03_fin	: 1;
+		unsigned int swtq04_fin	: 1;
+		unsigned int swtq05_fin	: 1;
+		/* GMAC1 SW Tx Queue 0 Finish Interrupt */
+		unsigned int swtq10_fin	: 1;
+		unsigned int swtq11_fin	: 1;
+		unsigned int swtq12_fin	: 1;
+		unsigned int swtq13_fin	: 1;
+		unsigned int swtq14_fin	: 1;
+		unsigned int swtq15_fin	: 1;
+		/* GMAC0 Rx Descriptor Protocol Error */
+		unsigned int rxPerr0	: 1;
+		/* GMAC0 AHB Bus Error while Rx */
+		unsigned int rxDerr0	: 1;
+		/* GMAC1 Rx Descriptor Protocol Error */
+		unsigned int rxPerr1	: 1;
+		/* GMAC1 AHB Bus Error while Rx */
+		unsigned int rxDerr1	: 1;
+		/* GMAC0 Tx Descriptor Protocol Error */
+		unsigned int txPerr0	: 1;
+		/* GMAC0 AHB Bus Error while Tx */
+		unsigned int txDerr0	: 1;
+		/* GMAC1 Tx Descriptor Protocol Error */
+		unsigned int txPerr1	: 1;
+		/* GMAC1 AHB Bus Error while Tx */
+		unsigned int txDerr1	: 1;
+	} bits;
+} INTR_REG0_T;
+
+#define GMAC1_TXDERR_INT_BIT		BIT(31)
+#define GMAC1_TXPERR_INT_BIT		BIT(30)
+#define GMAC0_TXDERR_INT_BIT		BIT(29)
+#define GMAC0_TXPERR_INT_BIT		BIT(28)
+#define GMAC1_RXDERR_INT_BIT		BIT(27)
+#define GMAC1_RXPERR_INT_BIT		BIT(26)
+#define GMAC0_RXDERR_INT_BIT		BIT(25)
+#define GMAC0_RXPERR_INT_BIT		BIT(24)
+#define GMAC1_SWTQ15_FIN_INT_BIT	BIT(23)
+#define GMAC1_SWTQ14_FIN_INT_BIT	BIT(22)
+#define GMAC1_SWTQ13_FIN_INT_BIT	BIT(21)
+#define GMAC1_SWTQ12_FIN_INT_BIT	BIT(20)
+#define GMAC1_SWTQ11_FIN_INT_BIT	BIT(19)
+#define GMAC1_SWTQ10_FIN_INT_BIT	BIT(18)
+#define GMAC0_SWTQ05_FIN_INT_BIT	BIT(17)
+#define GMAC0_SWTQ04_FIN_INT_BIT	BIT(16)
+#define GMAC0_SWTQ03_FIN_INT_BIT	BIT(15)
+#define GMAC0_SWTQ02_FIN_INT_BIT	BIT(14)
+#define GMAC0_SWTQ01_FIN_INT_BIT	BIT(13)
+#define GMAC0_SWTQ00_FIN_INT_BIT	BIT(12)
+#define GMAC1_SWTQ15_EOF_INT_BIT	BIT(11)
+#define GMAC1_SWTQ14_EOF_INT_BIT	BIT(10)
+#define GMAC1_SWTQ13_EOF_INT_BIT	BIT(9)
+#define GMAC1_SWTQ12_EOF_INT_BIT	BIT(8)
+#define GMAC1_SWTQ11_EOF_INT_BIT	BIT(7)
+#define GMAC1_SWTQ10_EOF_INT_BIT	BIT(6)
+#define GMAC0_SWTQ05_EOF_INT_BIT	BIT(5)
+#define GMAC0_SWTQ04_EOF_INT_BIT	BIT(4)
+#define GMAC0_SWTQ03_EOF_INT_BIT	BIT(3)
+#define GMAC0_SWTQ02_EOF_INT_BIT	BIT(2)
+#define GMAC0_SWTQ01_EOF_INT_BIT	BIT(1)
+#define GMAC0_SWTQ00_EOF_INT_BIT	BIT(0)
+
+/*
+ * Interrupt Status Register 1	(offset 0x0030)
+ * Interrupt Mask Register 1	(offset 0x0034)
+ * Interrupt Select Register 1	(offset 0x0038)
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_0030 {
+		unsigned int default_q0_eof	: 1;	/* Default Queue 0 EOF Interrupt */
+		unsigned int default_q1_eof	: 1;	/* Default Queue 1 EOF Interrupt */
+		unsigned int class_rx		: 14;	/* Classification Queue Rx Interrupt */
+		unsigned int hwtq00_eof		: 1;	/* GMAC0 HW Tx Queue0 EOF Interrupt */
+		unsigned int hwtq01_eof		: 1;	/* GMAC0 HW Tx Queue1 EOF Interrupt */
+		unsigned int hwtq02_eof		: 1;	/* GMAC0 HW Tx Queue2 EOF Interrupt */
+		unsigned int hwtq03_eof		: 1;	/* GMAC0 HW Tx Queue3 EOF Interrupt */
+		unsigned int hwtq10_eof		: 1;	/* GMAC1 HW Tx Queue0 EOF Interrupt */
+		unsigned int hwtq11_eof		: 1;	/* GMAC1 HW Tx Queue1 EOF Interrupt */
+		unsigned int hwtq12_eof		: 1;	/* GMAC1 HW Tx Queue2 EOF Interrupt */
+		unsigned int hwtq13_eof		: 1;	/* GMAC1 HW Tx Queue3 EOF Interrupt */
+		unsigned int toe_iq0_intr	: 1;	/* TOE Interrupt Queue 0 with Interru=
pts */
+		unsigned int toe_iq1_intr	: 1;	/* TOE Interrupt Queue 1 with Interru=
pts */
+		unsigned int toe_iq2_intr	: 1;	/* TOE Interrupt Queue 2 with Interru=
pts */
+		unsigned int toe_iq3_intr	: 1;	/* TOE Interrupt Queue 3 with Interru=
pts */
+		unsigned int toe_iq0_full	: 1;	/* TOE Interrupt Queue 0 Full Interru=
pt */
+		unsigned int toe_iq1_full	: 1;	/* TOE Interrupt Queue 1 Full Interru=
pt */
+		unsigned int toe_iq2_full	: 1;	/* TOE Interrupt Queue 2 Full Interru=
pt */
+		unsigned int toe_iq3_full	: 1;	/* TOE Interrupt Queue 3 Full Interru=
pt */
+	} bits;
+} INTR_REG1_T;
+
+#define TOE_IQ3_FULL_INT_BIT		BIT(31)
+#define TOE_IQ2_FULL_INT_BIT		BIT(30)
+#define TOE_IQ1_FULL_INT_BIT		BIT(29)
+#define TOE_IQ0_FULL_INT_BIT		BIT(28)
+#define TOE_IQ3_INT_BIT			BIT(27)
+#define TOE_IQ2_INT_BIT			BIT(26)
+#define TOE_IQ1_INT_BIT			BIT(25)
+#define TOE_IQ0_INT_BIT			BIT(24)
+#define GMAC1_HWTQ13_EOF_INT_BIT	BIT(23)
+#define GMAC1_HWTQ12_EOF_INT_BIT	BIT(22)
+#define GMAC1_HWTQ11_EOF_INT_BIT	BIT(21)
+#define GMAC1_HWTQ10_EOF_INT_BIT	BIT(20)
+#define GMAC0_HWTQ03_EOF_INT_BIT	BIT(19)
+#define GMAC0_HWTQ02_EOF_INT_BIT	BIT(18)
+#define GMAC0_HWTQ01_EOF_INT_BIT	BIT(17)
+#define GMAC0_HWTQ00_EOF_INT_BIT	BIT(16)
+#define CLASS_RX_INT_BIT(x)		BIT((x + 2))
+#define DEFAULT_Q1_INT_BIT		BIT(1)
+#define DEFAULT_Q0_INT_BIT		BIT(0)
+
+#define TOE_IQ_INT_BITS		(TOE_IQ0_INT_BIT | TOE_IQ1_INT_BIT | \
+				 TOE_IQ2_INT_BIT | TOE_IQ3_INT_BIT)
+#define	TOE_IQ_FULL_BITS	(TOE_IQ0_FULL_INT_BIT | TOE_IQ1_FULL_INT_BIT =
| \
+		                 TOE_IQ2_FULL_INT_BIT | TOE_IQ3_FULL_INT_BIT)
+#define	TOE_IQ_ALL_BITS		(TOE_IQ_INT_BITS | TOE_IQ_FULL_BITS)
+#define TOE_CLASS_RX_INT_BITS	0xfffc
+
+/*
+ * Interrupt Status Register 2	(offset 0x0040)
+ * Interrupt Mask Register 2	(offset 0x0044)
+ * Interrupt Select Register 2	(offset 0x0048)
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_0040 {
+		unsigned int toe_q0_full	: 1;	/* bit 0	TOE Queue 0 Full Interrupt */
+		unsigned int toe_q1_full	: 1;	/* bit 1	TOE Queue 1 Full Interrupt */
+		unsigned int toe_q2_full	: 1;	/* bit 2	TOE Queue 2 Full Interrupt */
+		unsigned int toe_q3_full	: 1;	/* bit 3	TOE Queue 3 Full Interrupt */
+		unsigned int toe_q4_full	: 1;	/* bit 4	TOE Queue 4 Full Interrupt */
+		unsigned int toe_q5_full	: 1;	/* bit 5	TOE Queue 5 Full Interrupt */
+		unsigned int toe_q6_full	: 1;	/* bit 6	TOE Queue 6 Full Interrupt */
+		unsigned int toe_q7_full	: 1;	/* bit 7	TOE Queue 7 Full Interrupt */
+		unsigned int toe_q8_full	: 1;	/* bit 8	TOE Queue 8 Full Interrupt */
+		unsigned int toe_q9_full	: 1;	/* bit 9	TOE Queue 9 Full Interrupt */
+		unsigned int toe_q10_full	: 1;	/* bit 10	TOE Queue 10 Full Interrupt=
 */
+		unsigned int toe_q11_full	: 1;	/* bit 11	TOE Queue 11 Full Interrupt=
 */
+		unsigned int toe_q12_full	: 1;	/* bit 12	TOE Queue 12 Full Interrupt=
 */
+		unsigned int toe_q13_full	: 1;	/* bit 13	TOE Queue 13 Full Interrupt=
 */
+		unsigned int toe_q14_full	: 1;	/* bit 14	TOE Queue 14 Full Interrupt=
 */
+		unsigned int toe_q15_full	: 1;	/* bit 15	TOE Queue 15 Full Interrupt=
 */
+		unsigned int toe_q16_full	: 1;	/* bit 16	TOE Queue 16 Full Interrupt=
 */
+		unsigned int toe_q17_full	: 1;	/* bit 17	TOE Queue 17 Full Interrupt=
 */
+		unsigned int toe_q18_full	: 1;	/* bit 18	TOE Queue 18 Full Interrupt=
 */
+		unsigned int toe_q19_full	: 1;	/* bit 19	TOE Queue 19 Full Interrupt=
 */
+		unsigned int toe_q20_full	: 1;	/* bit 20	TOE Queue 20 Full Interrupt=
 */
+		unsigned int toe_q21_full	: 1;	/* bit 21	TOE Queue 21 Full Interrupt=
 */
+		unsigned int toe_q22_full	: 1;	/* bit 22	TOE Queue 22 Full Interrupt=
 */
+		unsigned int toe_q23_full	: 1;	/* bit 23	TOE Queue 23 Full Interrupt=
 */
+		unsigned int toe_q24_full	: 1;	/* bit 24	TOE Queue 24 Full Interrupt=
 */
+		unsigned int toe_q25_full	: 1;	/* bit 25	TOE Queue 25 Full Interrupt=
 */
+		unsigned int toe_q26_full	: 1;	/* bit 26	TOE Queue 26 Full Interrupt=
 */
+		unsigned int toe_q27_full	: 1;	/* bit 27	TOE Queue 27 Full Interrupt=
 */
+		unsigned int toe_q28_full	: 1;	/* bit 28	TOE Queue 28 Full Interrupt=
 */
+		unsigned int toe_q29_full	: 1;	/* bit 29	TOE Queue 29 Full Interrupt=
 */
+		unsigned int toe_q30_full	: 1;	/* bit 30	TOE Queue 30 Full Interrupt=
 */
+		unsigned int toe_q31_full	: 1;	/* bit 31	TOE Queue 31 Full Interrupt=
 */
+	} bits;
+} INTR_REG2_T;
+
+#define TOE_QL_FULL_INT_BIT(x)		BIT(x)
+
+/*
+ * Interrupt Status Register 3	(offset 0x0050)
+ * Interrupt Mask Register 3	(offset 0x0054)
+ * Interrupt Select Register 3	(offset 0x0058)
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_0050 {
+		unsigned int toe_q32_full	: 1;	/* bit 32	TOE Queue 32 Full Interrupt=
 */
+		unsigned int toe_q33_full	: 1;	/* bit 33	TOE Queue 33 Full Interrupt=
 */
+		unsigned int toe_q34_full	: 1;	/* bit 34	TOE Queue 34 Full Interrupt=
 */
+		unsigned int toe_q35_full	: 1;	/* bit 35	TOE Queue 35 Full Interrupt=
 */
+		unsigned int toe_q36_full	: 1;	/* bit 36	TOE Queue 36 Full Interrupt=
 */
+		unsigned int toe_q37_full	: 1;	/* bit 37	TOE Queue 37 Full Interrupt=
 */
+		unsigned int toe_q38_full	: 1;	/* bit 38	TOE Queue 38 Full Interrupt=
 */
+		unsigned int toe_q39_full	: 1;	/* bit 39	TOE Queue 39 Full Interrupt=
 */
+		unsigned int toe_q40_full	: 1;	/* bit 40	TOE Queue 40 Full Interrupt=
 */
+		unsigned int toe_q41_full	: 1;	/* bit 41	TOE Queue 41 Full Interrupt=
 */
+		unsigned int toe_q42_full	: 1;	/* bit 42	TOE Queue 42 Full Interrupt=
 */
+		unsigned int toe_q43_full	: 1;	/* bit 43	TOE Queue 43 Full Interrupt=
 */
+		unsigned int toe_q44_full	: 1;	/* bit 44	TOE Queue 44 Full Interrupt=
 */
+		unsigned int toe_q45_full	: 1;	/* bit 45	TOE Queue 45 Full Interrupt=
 */
+		unsigned int toe_q46_full	: 1;	/* bit 46	TOE Queue 46 Full Interrupt=
 */
+		unsigned int toe_q47_full	: 1;	/* bit 47	TOE Queue 47 Full Interrupt=
 */
+		unsigned int toe_q48_full	: 1;	/* bit 48	TOE Queue 48 Full Interrupt=
 */
+		unsigned int toe_q49_full	: 1;	/* bit 49	TOE Queue 49 Full Interrupt=
 */
+		unsigned int toe_q50_full	: 1;	/* bit 50	TOE Queue 50 Full Interrupt=
 */
+		unsigned int toe_q51_full	: 1;	/* bit 51	TOE Queue 51 Full Interrupt=
 */
+		unsigned int toe_q52_full	: 1;	/* bit 52	TOE Queue 52 Full Interrupt=
 */
+		unsigned int toe_q53_full	: 1;	/* bit 53	TOE Queue 53 Full Interrupt=
 */
+		unsigned int toe_q54_full	: 1;	/* bit 54	TOE Queue 54 Full Interrupt=
 */
+		unsigned int toe_q55_full	: 1;	/* bit 55	TOE Queue 55 Full Interrupt=
 */
+		unsigned int toe_q56_full	: 1;	/* bit 56	TOE Queue 56 Full Interrupt=
 */
+		unsigned int toe_q57_full	: 1;	/* bit 57	TOE Queue 57 Full Interrupt=
 */
+		unsigned int toe_q58_full	: 1;	/* bit 58	TOE Queue 58 Full Interrupt=
 */
+		unsigned int toe_q59_full	: 1;	/* bit 59	TOE Queue 59 Full Interrupt=
 */
+		unsigned int toe_q60_full	: 1;	/* bit 60	TOE Queue 60 Full Interrupt=
 */
+		unsigned int toe_q61_full	: 1;	/* bit 61	TOE Queue 61 Full Interrupt=
 */
+		unsigned int toe_q62_full	: 1;	/* bit 62	TOE Queue 62 Full Interrupt=
 */
+		unsigned int toe_q63_full	: 1;	/* bit 63	TOE Queue 63 Full Interrupt=
 */
+	} bits;
+} INTR_REG3_T;
+
+#define TOE_QH_FULL_INT_BIT(x)		BIT(x-32)
+
+/*
+ * Interrupt Status Register 4	(offset 0x0060)
+ * Interrupt Mask Register 4	(offset 0x0064)
+ * Interrupt Select Register 4	(offset 0x0068)
+ */
+typedef union {
+	unsigned char byte;
+	struct bit_0060 {
+		unsigned char status_changed	: 1;	/* Status Changed Intr for RGMII M=
ode */
+		unsigned char rx_overrun	: 1;   /* GMAC Rx FIFO overrun interrupt */
+		unsigned char tx_pause_off	: 1;	/* received pause off frame interrup=
t */
+		unsigned char rx_pause_off	: 1;	/* received pause off frame interrup=
t */
+		unsigned char tx_pause_on	: 1;	/* transmit pause on frame interrupt =
*/
+		unsigned char rx_pause_on	: 1;	/* received pause on frame interrupt =
*/
+		unsigned char cnt_full		: 1;	/* MIB counters half full interrupt */
+		unsigned char reserved		: 1;	/* */
+	} __packed bits;
+} __packed GMAC_INTR_T;
+
+typedef union {
+	unsigned int bits32;
+	struct bit_0060_2 {
+		unsigned int    swfq_empty	: 1;	/* bit 0	Software Free Queue Empty I=
ntr. */
+		unsigned int    hwfq_empty	: 1;	/* bit 1	Hardware Free Queue Empty I=
ntr. */
+		unsigned int	class_qf_int	: 14;	/* bit 15:2 Classification Rx Queue1=
3-0 Full Intr. */
+		GMAC_INTR_T	gmac0;
+		GMAC_INTR_T	gmac1;
+	} bits;
+} INTR_REG4_T;
+
+#define GMAC1_RESERVED_INT_BIT		BIT(31)
+#define GMAC1_MIB_INT_BIT		BIT(30)
+#define GMAC1_RX_PAUSE_ON_INT_BIT	BIT(29)
+#define GMAC1_TX_PAUSE_ON_INT_BIT	BIT(28)
+#define GMAC1_RX_PAUSE_OFF_INT_BIT	BIT(27)
+#define GMAC1_TX_PAUSE_OFF_INT_BIT	BIT(26)
+#define GMAC1_RX_OVERRUN_INT_BIT	BIT(25)
+#define GMAC1_STATUS_CHANGE_INT_BIT	BIT(24)
+#define GMAC0_RESERVED_INT_BIT		BIT(23)
+#define GMAC0_MIB_INT_BIT		BIT(22)
+#define GMAC0_RX_PAUSE_ON_INT_BIT	BIT(21)
+#define GMAC0_TX_PAUSE_ON_INT_BIT	BIT(20)
+#define GMAC0_RX_PAUSE_OFF_INT_BIT	BIT(19)
+#define GMAC0_TX_PAUSE_OFF_INT_BIT	BIT(18)
+#define GMAC0_RX_OVERRUN_INT_BIT	BIT(17)
+#define GMAC0_STATUS_CHANGE_INT_BIT	BIT(16)
+#define CLASS_RX_FULL_INT_BIT(x)	BIT((x+2))
+#define HWFQ_EMPTY_INT_BIT		BIT(1)
+#define SWFQ_EMPTY_INT_BIT		BIT(0)
+
+#define GMAC0_INT_BITS		(GMAC0_RESERVED_INT_BIT | GMAC0_MIB_INT_BIT | =
\
+				 GMAC0_RX_PAUSE_ON_INT_BIT | GMAC0_TX_PAUSE_ON_INT_BIT |	\
+				 GMAC0_RX_PAUSE_OFF_INT_BIT | GMAC0_TX_PAUSE_OFF_INT_BIT |	\
+				 GMAC0_RX_OVERRUN_INT_BIT | GMAC0_STATUS_CHANGE_INT_BIT)
+#define GMAC1_INT_BITS		(GMAC1_RESERVED_INT_BIT | GMAC1_MIB_INT_BIT | =
\
+				 GMAC1_RX_PAUSE_ON_INT_BIT | GMAC1_TX_PAUSE_ON_INT_BIT |	\
+				 GMAC1_RX_PAUSE_OFF_INT_BIT | GMAC1_TX_PAUSE_OFF_INT_BIT |	\
+				 GMAC1_RX_OVERRUN_INT_BIT | GMAC1_STATUS_CHANGE_INT_BIT)
+
+#define CLASS_RX_FULL_INT_BITS		0xfffc
+
+/*
+ * GLOBAL_QUEUE_THRESHOLD_REG	(offset 0x0070)
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_0070_2 {
+		unsigned int    swfq_empty	: 8;	/*  7:0		Software Free Queue Empty T=
hreshold */
+		unsigned int    hwfq_empty	: 8;	/* 15:8		Hardware Free Queue Empty T=
hreshold */
+		unsigned int	intrq		: 8;	/* 23:16 */
+		unsigned int	toe_class	: 8;	/* 31:24 */
+	} bits;
+} QUEUE_THRESHOLD_T;
+
+
+/*
+ * GMAC DMA Control Register
+ * GMAC0 offset 0x8000
+ * GMAC1 offset 0xC000
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_8000 {
+		unsigned int	td_bus		: 2;	/* bit 1:0	Peripheral Bus Width */
+		unsigned int	td_burst_size	: 2;	/* bit 3:2	TxDMA max burst size for =
every AHB request */
+		unsigned int	td_prot		: 4;	/* bit 7:4	TxDMA protection control */
+		unsigned int	rd_bus		: 2;	/* bit 9:8	Peripheral Bus Width */
+		unsigned int	rd_burst_size	: 2;	/* bit 11:10	DMA max burst size for =
every AHB request */
+		unsigned int	rd_prot		: 4;	/* bit 15:12	DMA Protection Control */
+		unsigned int	rd_insert_bytes	: 2;	/* bit 17:16 */
+		unsigned int	reserved	: 10;	/* bit 27:18 */
+		unsigned int    drop_small_ack	: 1;	/* bit 28	1: Drop, 0: Accept */
+		unsigned int    loopback	: 1;	/* bit 29	Loopback TxDMA to RxDMA */
+		unsigned int    td_enable	: 1;	/* bit 30	Tx DMA Enable */
+		unsigned int    rd_enable	: 1;	/* bit 31	Rx DMA Enable */
+	} bits;
+} GMAC_DMA_CTRL_T;
+
+/*
+ * GMAC Tx Weighting Control Register 0
+ * GMAC0 offset 0x8004
+ * GMAC1 offset 0xC004
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_8004 {
+		unsigned int    hw_tq0		: 6;	/* bit 5:0	HW TX Queue 3 */
+		unsigned int    hw_tq1		: 6;	/* bit 11:6	HW TX Queue 2 */
+		unsigned int    hw_tq2		: 6;	/* bit 17:12	HW TX Queue 1 */
+		unsigned int    hw_tq3		: 6;	/* bit 23:18	HW TX Queue 0 */
+		unsigned int    reserved	: 8;	/* bit 31:24 */
+	} bits;
+} GMAC_TX_WCR0_T;	/* Weighting Control Register 0 */
+
+/*
+ * GMAC Tx Weighting Control Register 1
+ * GMAC0 offset 0x8008
+ * GMAC1 offset 0xC008
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_8008 {
+		unsigned int    sw_tq0		: 5;	/* bit 4:0	SW TX Queue 0 */
+		unsigned int    sw_tq1		: 5;	/* bit 9:5	SW TX Queue 1 */
+		unsigned int    sw_tq2		: 5;	/* bit 14:10	SW TX Queue 2 */
+		unsigned int    sw_tq3		: 5;	/* bit 19:15	SW TX Queue 3 */
+		unsigned int    sw_tq4		: 5;	/* bit 24:20	SW TX Queue 4 */
+		unsigned int    sw_tq5		: 5;	/* bit 29:25	SW TX Queue 5 */
+		unsigned int    reserved	: 2;	/* bit 31:30 */
+	} bits;
+} GMAC_TX_WCR1_T;	/* Weighting Control Register 1 */
+
+/*
+ * Queue Read/Write Pointer
+ * GMAC SW TX Queue 0~5 Read/Write Pointer register
+ * GMAC0 offset 0x800C ~ 0x8020
+ * GMAC1 offset 0xC00C ~ 0xC020
+ * GMAC HW TX Queue 0~3 Read/Write Pointer register
+ * GMAC0 offset 0x8024 ~ 0x8030
+ * GMAC1 offset 0xC024 ~ 0xC030
+ *
+ * see DMA_RWPTR_T structure
+ */
+
+/*
+ * GMAC DMA Tx First Description Address Register
+ * GMAC0 offset 0x8038
+ * GMAC1 offset 0xC038
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_8038 {
+		unsigned int reserved		:  3;
+		unsigned int td_busy		:  1;	/* bit 3	1: TxDMA busy; 0: TxDMA idle */
+		unsigned int td_first_des_ptr	: 28;	/* bit 31:4	first descriptor add=
ress */
+	} bits;
+} GMAC_TXDMA_FIRST_DESC_T;
+
+/*
+ * GMAC DMA Tx Current Description Address Register
+ * GMAC0 offset 0x803C
+ * GMAC1 offset 0xC03C
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_803C {
+		unsigned int reserved		:  4;
+		unsigned int td_curr_desc_ptr	: 28;	/* bit 31:4	current descriptor a=
ddress */
+	} bits;
+} GMAC_TXDMA_CURR_DESC_T;
+
+/*
+ * GMAC DMA Tx Description Word 0 Register
+ * GMAC0 offset 0x8040
+ * GMAC1 offset 0xC040
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_8040 {
+		unsigned int buffer_size	: 16;	/* bit 15:0	Transfer size */
+		unsigned int desc_count		: 6;	/* bit 21:16	number of descriptors use=
d for the current frame */
+		unsigned int status_tx_ok	: 1;	/* bit 22	Tx Status, 1: Successful 0:=
 Failed */
+		unsigned int status_rvd		: 6;	/* bit 28:23	Tx Status, Reserved bits =
*/
+		unsigned int perr		: 1;	/* bit 29	protocol error during processing t=
his descriptor */
+		unsigned int derr		: 1;	/* bit 30	data error during processing this =
descriptor */
+		unsigned int reserved		: 1;	/* bit 31 */
+	} bits;
+} GMAC_TXDESC_0_T;
+
+/*
+ * GMAC DMA Tx Description Word 1 Register
+ * GMAC0 offset 0x8044
+ * GMAC1 offset 0xC044
+ */
+typedef union {
+	unsigned int bits32;
+	struct txdesc_word1 {
+		unsigned int	byte_count	: 16;	/* bit 15: 0	Tx Frame Byte Count */
+		unsigned int	mtu_enable	: 1;	/* bit 16	TSS segmentation use MTU sett=
ing */
+		unsigned int	ip_chksum	: 1;	/* bit 17	IPV4 Header Checksum Enable */
+		unsigned int	ipv6_enable	: 1;	/* bit 18	IPV6 Tx Enable */
+		unsigned int	tcp_chksum	: 1;	/* bit 19	TCP Checksum Enable */
+		unsigned int	udp_chksum	: 1;	/* bit 20	UDP Checksum Enable */
+		unsigned int	bypass_tss	: 1;	/* bit 21 */
+		unsigned int	ip_fixed_len	: 1;	/* bit 22 */
+		unsigned int	reserved	: 9;	/* bit 31:23	Tx Flag, Reserved */
+	} bits;
+} GMAC_TXDESC_1_T;
+
+#define TSS_IP_FIXED_LEN_BIT	BIT(22)
+#define TSS_BYPASS_BIT		BIT(21)
+#define TSS_UDP_CHKSUM_BIT	BIT(20)
+#define TSS_TCP_CHKSUM_BIT	BIT(19)
+#define TSS_IPV6_ENABLE_BIT	BIT(18)
+#define TSS_IP_CHKSUM_BIT	BIT(17)
+#define TSS_MTU_ENABLE_BIT	BIT(16)
+
+#define TSS_CHECKUM_ENABLE	\
+	(TSS_IP_CHKSUM_BIT|TSS_IPV6_ENABLE_BIT| \
+	 TSS_TCP_CHKSUM_BIT|TSS_UDP_CHKSUM_BIT)
+
+/*
+ * GMAC DMA Tx Description Word 2 Register
+ * GMAC0 offset 0x8048
+ * GMAC1 offset 0xC048
+ */
+typedef union {
+	unsigned int	bits32;
+	unsigned int	buf_adr;
+} GMAC_TXDESC_2_T;
+
+/*
+ * GMAC DMA Tx Description Word 3 Register
+ * GMAC0 offset 0x804C
+ * GMAC1 offset 0xC04C
+ */
+typedef union {
+	unsigned int bits32;
+	struct txdesc_word3 {
+		unsigned int	mtu_size	: 11;	/* bit 10: 0	Tx Frame Byte Count */
+		unsigned int	reserved	: 18;	/* bit 28:11 */
+		unsigned int	eofie		: 1;	/* bit 29	End of frame interrupt enable */
+		unsigned int	sof_eof		: 2;	/* bit 31:30	11: only one, 10: first, 01:=
 last, 00: linking */
+	} bits;
+} GMAC_TXDESC_3_T;
+#define SOF_EOF_BIT_MASK	0x3fffffff
+#define SOF_BIT			0x80000000
+#define EOF_BIT			0x40000000
+#define EOFIE_BIT		BIT(29)
+#define MTU_SIZE_BIT_MASK	0x7ff
+
+/*
+ * GMAC Tx Descriptor
+ */
+typedef struct {
+	GMAC_TXDESC_0_T	word0;
+	GMAC_TXDESC_1_T	word1;
+	GMAC_TXDESC_2_T	word2;
+	GMAC_TXDESC_3_T	word3;
+} GMAC_TXDESC_T;
+
+/*
+ * GMAC DMA Rx First Description Address Register
+ * GMAC0 offset 0x8058
+ * GMAC1 offset 0xC058
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_8058 {
+		unsigned int reserved		:  3;	/* bit 2:0 */
+		unsigned int rd_busy		:  1;	/* bit 3	1-RxDMA busy; 0-RxDMA idle */
+		unsigned int rd_first_des_ptr	: 28;	/* bit 31:4 first descriptor add=
ress */
+	} bits;
+} GMAC_RXDMA_FIRST_DESC_T;
+
+/*
+ * GMAC DMA Rx Current Description Address Register
+ * GMAC0 offset 0x805C
+ * GMAC1 offset 0xC05C
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_805C {
+		unsigned int reserved		:  4;	/* bit 3:0 */
+		unsigned int rd_curr_des_ptr	: 28;	/* bit 31:4 current descriptor ad=
dress */
+	} bits;
+} GMAC_RXDMA_CURR_DESC_T;
+
+/*
+ * GMAC DMA Rx Description Word 0 Register
+ * GMAC0 offset 0x8060
+ * GMAC1 offset 0xC060
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_8060 {
+		unsigned int buffer_size	: 16;	/* bit 15:0  number of descriptors us=
ed for the current frame */
+		unsigned int desc_count		: 6;	/* bit 21:16 number of descriptors use=
d for the current frame */
+		unsigned int status		: 4;	/* bit 24:22 Status of rx frame */
+		unsigned int chksum_status	: 3;	/* bit 28:26 Check Sum Status */
+		unsigned int perr		: 1;	/* bit 29	 protocol error during processing =
this descriptor */
+		unsigned int derr		: 1;	/* bit 30	 data error during processing this=
 descriptor */
+		unsigned int drop		: 1;	/* bit 31	 TOE/CIS Queue Full dropped packet=
 to default queue */
+	} bits;
+} GMAC_RXDESC_0_T;
+
+#define		GMAC_RXDESC_0_T_derr			BIT(30)
+#define		GMAC_RXDESC_0_T_perr			BIT(29)
+#define		GMAC_RXDESC_0_T_chksum_status(x)	BIT((x+26))
+#define		GMAC_RXDESC_0_T_status(x)		BIT((x+22))
+#define		GMAC_RXDESC_0_T_desc_count(x)		BIT((x+16))
+
+#define	RX_CHKSUM_IP_UDP_TCP_OK			0
+#define	RX_CHKSUM_IP_OK_ONLY			1
+#define	RX_CHKSUM_NONE				2
+#define	RX_CHKSUM_IP_ERR_UNKNOWN		4
+#define	RX_CHKSUM_IP_ERR			5
+#define	RX_CHKSUM_TCP_UDP_ERR			6
+#define RX_CHKSUM_NUM				8
+
+#define RX_STATUS_GOOD_FRAME			0
+#define RX_STATUS_TOO_LONG_GOOD_CRC		1
+#define RX_STATUS_RUNT_FRAME			2
+#define RX_STATUS_SFD_NOT_FOUND			3
+#define RX_STATUS_CRC_ERROR			4
+#define RX_STATUS_TOO_LONG_BAD_CRC		5
+#define RX_STATUS_ALIGNMENT_ERROR		6
+#define RX_STATUS_TOO_LONG_BAD_ALIGN		7
+#define RX_STATUS_RX_ERR			8
+#define RX_STATUS_DA_FILTERED			9
+#define RX_STATUS_BUFFER_FULL			10
+#define RX_STATUS_NUM				16
+
+#define RX_ERROR_LENGTH(s) \
+	((s) =3D=3D RX_STATUS_TOO_LONG_GOOD_CRC || \
+	 (s) =3D=3D RX_STATUS_TOO_LONG_BAD_CRC || \
+	 (s) =3D=3D RX_STATUS_TOO_LONG_BAD_ALIGN)
+#define RX_ERROR_OVER(s) \
+	((s) =3D=3D RX_STATUS_BUFFER_FULL)
+#define RX_ERROR_CRC(s) \
+	((s) =3D=3D RX_STATUS_CRC_ERROR || \
+	 (s) =3D=3D RX_STATUS_TOO_LONG_BAD_CRC)
+#define RX_ERROR_FRAME(s) \
+	((s) =3D=3D RX_STATUS_ALIGNMENT_ERROR || \
+	 (s) =3D=3D RX_STATUS_TOO_LONG_BAD_ALIGN)
+#define RX_ERROR_FIFO(s) \
+	(0)
+
+/*
+ * GMAC DMA Rx Description Word 1 Register
+ * GMAC0 offset 0x8064
+ * GMAC1 offset 0xC064
+ */
+typedef union {
+	unsigned int bits32;
+	struct rxdesc_word1 {
+		unsigned int	byte_count	: 16;	/* bit 15: 0	Rx Frame Byte Count */
+		unsigned int	sw_id		: 16;	/* bit 31:16	Software ID */
+	} bits;
+} GMAC_RXDESC_1_T;
+
+/*
+ * GMAC DMA Rx Description Word 2 Register
+ * GMAC0 offset 0x8068
+ * GMAC1 offset 0xC068
+ */
+typedef union {
+	unsigned int	bits32;
+	unsigned int	buf_adr;
+} GMAC_RXDESC_2_T;
+
+#define RX_INSERT_NONE		0
+#define RX_INSERT_1_BYTE	1
+#define RX_INSERT_2_BYTE	2
+#define RX_INSERT_3_BYTE	3
+
+/*
+ * GMAC DMA Rx Description Word 3 Register
+ * GMAC0 offset 0x806C
+ * GMAC1 offset 0xC06C
+ */
+typedef union {
+	unsigned int bits32;
+	struct rxdesc_word3 {
+		unsigned int	l3_offset	: 8;	/* bit 7: 0	L3 data offset */
+		unsigned int	l4_offset	: 8;	/* bit 15: 8	L4 data offset */
+		unsigned int	l7_offset	: 8;	/* bit 23: 16	L7 data offset */
+		unsigned int	dup_ack		: 1;	/* bit 24	Duplicated ACK detected */
+		unsigned int	abnormal	: 1;	/* bit 25	abnormal case found */
+		unsigned int	option		: 1;	/* bit 26	IPV4 option or IPV6 extension he=
ader */
+		unsigned int	out_of_seq	: 1;	/* bit 27	Out of Sequence packet */
+		unsigned int	ctrl_flag	: 1;	/* bit 28	Control Flag is present */
+		unsigned int	eofie		: 1;	/* bit 29	End of frame interrupt enable */
+		unsigned int	sof_eof		: 2;	/* bit 31:30	11: only one, 10: first, 01:=
 last, 00: linking */
+	} bits;
+} GMAC_RXDESC_3_T;
+
+/*
+ * GMAC Rx Descriptor
+ */
+typedef struct {
+	GMAC_RXDESC_0_T	word0;
+	GMAC_RXDESC_1_T	word1;
+	GMAC_RXDESC_2_T	word2;
+	GMAC_RXDESC_3_T	word3;
+} GMAC_RXDESC_T;
+
+/*
+ * GMAC Hash Engine Enable/Action Register 0 Offset Register
+ * GMAC0 offset 0x8070
+ * GMAC1 offset 0xC070
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_8070 {
+		unsigned int	mr0hel		: 6;	/* bit 5:0	match rule 0 hash entry size */
+		unsigned int	mr0_action	: 5;	/* bit 10:6	Matching Rule 0 action offs=
et */
+		unsigned int	reserved0	: 4;	/* bit 14:11 */
+		unsigned int	mr0en		: 1;	/* bit 15	Enable Matching Rule 0 */
+		unsigned int	mr1hel		: 6;	/* bit 21:16	match rule 1 hash entry size =
*/
+		unsigned int	mr1_action	: 5;	/* bit 26:22	Matching Rule 1 action off=
set */
+		unsigned int	timing		: 3;	/* bit 29:27 */
+		unsigned int	reserved1	: 1;	/* bit 30 */
+		unsigned int	mr1en		: 1;	/* bit 31	Enable Matching Rule 1 */
+	} bits;
+} GMAC_HASH_ENABLE_REG0_T;
+
+/*
+ * GMAC Hash Engine Enable/Action Register 1 Offset Register
+ * GMAC0 offset 0x8074
+ * GMAC1 offset 0xC074
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_8074 {
+		unsigned int	mr2hel		: 6;	/* bit 5:0	match rule 2 hash entry size */
+		unsigned int	mr2_action	: 5;	/* bit 10:6	Matching Rule 2 action offs=
et */
+		unsigned int	reserved2	: 4;	/* bit 14:11 */
+		unsigned int	mr2en		: 1;	/* bit 15	Enable Matching Rule 2 */
+		unsigned int	mr3hel		: 6;	/* bit 21:16	match rule 3 hash entry size =
*/
+		unsigned int	mr3_action	: 5;	/* bit 26:22	Matching Rule 3 action off=
set */
+		unsigned int	reserved1	: 4;	/* bit 30:27 */
+		unsigned int	mr3en		: 1;	/* bit 31	Enable Matching Rule 3 */
+	} bits;
+} GMAC_HASH_ENABLE_REG1_T;
+
+/*
+ * GMAC Matching Rule Control Register 0
+ * GMAC0 offset 0x8078
+ * GMAC1 offset 0xC078
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_8078 {
+		unsigned int	sprx		: 8;	/* bit 7:0	Support Protocol Register 7:0 */
+		unsigned int	reserved2	: 4;	/* bit 11:8 */
+		unsigned int	tos_traffic	: 1;	/* bit 12	IPV4 TOS or IPV6 Traffice Cl=
ass */
+		unsigned int	flow_lable	: 1;	/* bit 13	IPV6 Flow label */
+		unsigned int	ip_hdr_len	: 1;	/* bit 14	IPV4 Header length */
+		unsigned int	ip_version	: 1;	/* bit 15	0: IPV4, 1: IPV6 */
+		unsigned int	reserved1	: 3;	/* bit 18:16 */
+		unsigned int	pppoe		: 1;	/* bit 19	PPPoE Session ID enable */
+		unsigned int	vlan		: 1;	/* bit 20	VLAN ID enable */
+		unsigned int	ether_type	: 1;	/* bit 21	Ethernet type enable */
+		unsigned int	sa		: 1;	/* bit 22	MAC SA enable */
+		unsigned int	da		: 1;	/* bit 23	MAC DA enable */
+		unsigned int	priority	: 3;	/* bit 26:24	priority if multi-rules matc=
hed */
+		unsigned int	port		: 1;	/* bit 27	PORT ID matching enable */
+		unsigned int	l7		: 1;	/* bit 28	L7 matching enable */
+		unsigned int	l4		: 1;	/* bit 29	L4 matching enable */
+		unsigned int	l3		: 1;	/* bit 30	L3 matching enable */
+		unsigned int	l2		: 1;	/* bit 31	L2 matching enable */
+	} bits;
+} GMAC_MRxCR0_T;
+
+#define MR_L2_BIT		BIT(31)
+#define MR_L3_BIT		BIT(30)
+#define MR_L4_BIT		BIT(29)
+#define MR_L7_BIT		BIT(28)
+#define MR_PORT_BIT		BIT(27)
+#define MR_PRIORITY_BIT		BIT(26)
+#define MR_DA_BIT		BIT(23)
+#define MR_SA_BIT		BIT(22)
+#define MR_ETHER_TYPE_BIT	BIT(21)
+#define MR_VLAN_BIT		BIT(20)
+#define MR_PPPOE_BIT		BIT(19)
+#define MR_IP_VER_BIT		BIT(15)
+#define MR_IP_HDR_LEN_BIT	BIT(14)
+#define MR_FLOW_LABLE_BIT	BIT(13)
+#define MR_TOS_TRAFFIC_BIT	BIT(12)
+#define MR_SPR_BIT(x)		BIT(x)
+#define MR_SPR_BITS		0xff
+
+/*
+ * GMAC Matching Rule Control Register 1
+ * GMAC0 offset 0x807C
+ * GMAC1 offset 0xC07C
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_807C {
+		unsigned int    l4_byte0_15	: 16;	/* bit 15: 0 */
+		unsigned int	dip_netmask	: 7;	/* bit 22:16	Dest IP net mask, number =
of mask bits */
+		unsigned int	dip		: 1;	/* bit 23		Dest IP */
+		unsigned int	sip_netmask	: 7;	/* bit 30:24	Srce IP net mask, number =
of mask bits */
+		unsigned int	sip		: 1;	/* bit 31		Srce IP */
+	} bits;
+} GMAC_MRxCR1_T;
+
+/*
+ * GMAC Matching Rule Control Register 2
+ * GMAC0 offset 0x8080
+ * GMAC1 offset 0xC080
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_8080 {
+		unsigned int    l7_byte0_23	: 24;	/* bit 23:0 */
+		unsigned int    l4_byte16_24	: 8;	/* bit 31: 24 */
+	} bits;
+} GMAC_MRxCR2_T;
+
+/*
+ * GMAC Support registers
+ * GMAC0 offset 0x80A8
+ * GMAC1 offset 0xC0A8
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_80A8 {
+		unsigned int    protocol	: 8;	/* bit 7:0		Supported protocol */
+		unsigned int    swap		: 3;	/* bit 10:8		Swap */
+		unsigned int    reserved	: 21;	/* bit 31:11 */
+	} bits;
+} GMAC_SPR_T;
+
+/*
+ * GMAC_AHB_WEIGHT registers
+ * GMAC0 offset 0x80C8
+ * GMAC1 offset 0xC0C8
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_80C8 {
+		unsigned int    hash_weight	: 5;	/* 4:0 */
+		unsigned int    rx_weight	: 5;	/* 9:5 */
+		unsigned int    tx_weight	: 5;	/* 14:10 */
+		unsigned int    pre_req		: 5;	/* 19:15 Rx Data Pre Request FIFO Thre=
shold */
+		unsigned int    tqDV_threshold	: 5;	/* 24:20 DMA TqCtrl to Start tqD=
V FIFO Threshold */
+		unsigned int    reserved	: 7;	/* 31:25 */
+	} bits;
+} GMAC_AHB_WEIGHT_T;
+
+/*
+ * the register structure of GMAC
+ */
+
+/*
+ * GMAC RX FLTR
+ * GMAC0 Offset 0xA00C
+ * GMAC1 Offset 0xE00C
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit1_000c {
+		unsigned int unicast		:  1;	/* enable receive of unicast frames that=
 are sent to STA address */
+		unsigned int multicast		:  1;	/* enable receive of multicast frames =
that pass multicast filter */
+		unsigned int broadcast		:  1;	/* enable receive of broadcast frames =
*/
+		unsigned int promiscuous	:  1;   /* enable receive of all frames */
+		unsigned int error		:  1;	/* enable receive of all error frames */
+		unsigned int			: 27;
+	} bits;
+} GMAC_RX_FLTR_T;
+
+/*
+ * GMAC Configuration 0
+ * GMAC0 Offset 0xA018
+ * GMAC1 Offset 0xE018
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit1_0018 {
+		unsigned int dis_tx		:  1;	/* 0: disable transmit */
+		unsigned int dis_rx		:  1;	/* 1: disable receive */
+		unsigned int loop_back		:  1;	/* 2: transmit data loopback enable */
+		unsigned int flow_ctrl		:  1;   /* 3: flow control also trigged by R=
x queues */
+		unsigned int adj_ifg		:  4;	/* 4-7: adjust IFG from 96+/-56 */
+		unsigned int max_len		:  3;	/* 8-10 maximum receive frame length all=
owed */
+		unsigned int dis_bkoff		:  1;	/* 11: disable back-off function */
+		unsigned int dis_col		:  1;	/* 12: disable 16 collisions abort funct=
ion */
+		unsigned int sim_test		:  1;	/* 13: speed up timers in simulation */
+		unsigned int rx_fc_en		:  1;	/* 14: RX flow control enable */
+		unsigned int tx_fc_en		:  1;	/* 15: TX flow control enable */
+		unsigned int rgmii_en		:  1;   /* 16: RGMII in-band status enable */
+		unsigned int ipv4_rx_chksum	:  1;   /* 17: IPv4 RX Checksum enable *=
/
+		unsigned int ipv6_rx_chksum	:  1;   /* 18: IPv6 RX Checksum enable *=
/
+		unsigned int rx_tag_remove	:  1;   /* 19: Remove Rx VLAN tag */
+		unsigned int rgmm_edge		:  1;	/* 20 */
+		unsigned int rxc_inv		:  1;	/* 21 */
+		unsigned int ipv6_exthdr_order	:  1;	/* 22 */
+		unsigned int rx_err_detect	:  1;	/* 23 */
+		unsigned int port0_chk_hwq	:  1;	/* 24 */
+		unsigned int port1_chk_hwq	:  1;	/* 25 */
+		unsigned int port0_chk_toeq	:  1;	/* 26 */
+		unsigned int port1_chk_toeq	:  1;	/* 27 */
+		unsigned int port0_chk_classq	:  1;	/* 28 */
+		unsigned int port1_chk_classq	:  1;	/* 29 */
+		unsigned int reserved		:  2;	/* 31 */
+	} bits;
+} GMAC_CONFIG0_T;
+
+#define CONFIG0_TX_RX_DISABLE	(BIT(1)|BIT(0))
+#define CONFIG0_RX_CHKSUM	(BIT(18)|BIT(17))
+#define CONFIG0_FLOW_RX		(BIT(14))
+#define CONFIG0_FLOW_TX		(BIT(15))
+#define CONFIG0_FLOW_TX_RX	(BIT(14)|BIT(15))
+#define CONFIG0_FLOW_CTL	(BIT(14)|BIT(15))
+
+#define CONFIG0_MAXLEN_SHIFT	8
+#define CONFIG0_MAXLEN_MASK	(7 << CONFIG0_MAXLEN_SHIFT)
+#define  CONFIG0_MAXLEN_1536	0
+#define  CONFIG0_MAXLEN_1518	1
+#define  CONFIG0_MAXLEN_1522	2
+#define  CONFIG0_MAXLEN_1542	3
+#define  CONFIG0_MAXLEN_9k	4	/* 9212 */
+#define  CONFIG0_MAXLEN_10k	5	/* 10236 */
+#define  CONFIG0_MAXLEN_1518__6	6
+#define  CONFIG0_MAXLEN_1518__7	7
+
+/*
+ * GMAC Configuration 1
+ * GMAC0 Offset 0xA01C
+ * GMAC1 Offset 0xE01C
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit1_001c {
+		unsigned int set_threshold	: 8;	/* flow control set threshold */
+		unsigned int rel_threshold	: 8;	/* flow control release threshold */
+		unsigned int reserved		: 16;
+	} bits;
+} GMAC_CONFIG1_T;
+
+#define GMAC_FLOWCTRL_SET_MAX		32
+#define GMAC_FLOWCTRL_SET_MIN		0
+#define GMAC_FLOWCTRL_RELEASE_MAX	32
+#define GMAC_FLOWCTRL_RELEASE_MIN	0
+
+/*
+ * GMAC Configuration 2
+ * GMAC0 Offset 0xA020
+ * GMAC1 Offset 0xE020
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit1_0020 {
+		unsigned int set_threshold	: 16;	/* flow control set threshold */
+		unsigned int rel_threshold	: 16;	/* flow control release threshold *=
/
+	} bits;
+} GMAC_CONFIG2_T;
+
+/*
+ * GMAC Configuration 3
+ * GMAC0 Offset 0xA024
+ * GMAC1 Offset 0xE024
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit1_0024 {
+		unsigned int set_threshold	: 16;	/* flow control set threshold */
+		unsigned int rel_threshold	: 16;	/* flow control release threshold *=
/
+	} bits;
+} GMAC_CONFIG3_T;
+
+
+/*
+ * GMAC STATUS
+ * GMAC0 Offset 0xA02C
+ * GMAC1 Offset 0xE02C
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit1_002c {
+		unsigned int link		:  1;	/* link status */
+		unsigned int speed		:  2;	/* link speed(00->2.5M 01->25M 10->125M) *=
/
+		unsigned int duplex		:  1;	/* duplex mode */
+		unsigned int reserved		:  1;
+		unsigned int mii_rmii		:  2;   /* PHY interface type */
+		unsigned int			: 25;
+	} bits;
+} GMAC_STATUS_T;
+
+#define GMAC_SPEED_10			0
+#define GMAC_SPEED_100			1
+#define GMAC_SPEED_1000			2
+
+#define GMAC_PHY_MII			0
+#define GMAC_PHY_GMII			1
+#define GMAC_PHY_RGMII_100_10		2
+#define GMAC_PHY_RGMII_1000		3
+
+/*
+ * Queue Header
+ *	(1) TOE Queue Header
+ *	(2) Non-TOE Queue Header
+ *	(3) Interrupt Queue Header
+ *
+ * memory Layout
+ *	TOE Queue Header
+ *		     0x60003000 +---------------------------+ 0x0000
+ *				|     TOE Queue 0 Header    |
+ *				|         8 * 4 Bytes	    |
+ *				+---------------------------+ 0x0020
+ *				|     TOE Queue 1 Header    |
+ *				|         8 * 4 Bytes	    |
+ *				+---------------------------+ 0x0040
+ *				|          ......           |
+ *				|                           |
+ *				+---------------------------+
+ *
+ *	Non TOE Queue Header
+ *		     0x60002000 +---------------------------+ 0x0000
+ *				|   Default Queue 0 Header  |
+ *				|         2 * 4 Bytes       |
+ *				+---------------------------+ 0x0008
+ *				|   Default Queue 1 Header  |
+ *				|         2 * 4 Bytes       |
+ *				+---------------------------+ 0x0010
+ *				|   Classification Queue 0  |
+ *				|	  2 * 4 Bytes       |
+ *				+---------------------------+
+ *				|   Classification Queue 1  |
+ *				|	  2 * 4 Bytes       |
+ *				+---------------------------+ (n * 8 + 0x10)
+ *				|		...	    |
+ *				|	  2 * 4 Bytes	    |
+ *				+---------------------------+ (13 * 8 + 0x10)
+ *				|   Classification Queue 13 |
+ *				|	  2 * 4 Bytes	    |
+ *				+---------------------------+ 0x80
+ *				|      Interrupt Queue 0    |
+ *				|	  2 * 4 Bytes	    |
+ *				+---------------------------+
+ *				|      Interrupt Queue 1    |
+ *				|	  2 * 4 Bytes	    |
+ *				+---------------------------+
+ *				|      Interrupt Queue 2    |
+ *				|	  2 * 4 Bytes	    |
+ *				+---------------------------+
+ *				|      Interrupt Queue 3    |
+ *				|	  2 * 4 Bytes	    |
+ *				+---------------------------+
+ *
+ */
+#define TOE_QUEUE_HDR_ADDR(n)		(TOE_TOE_QUE_HDR_BASE + n * 32)
+#define TOE_Q_HDR_AREA_END		(TOE_QUEUE_HDR_ADDR(TOE_TOE_QUEUE_MAX + 1)=
)
+#define TOE_DEFAULT_Q_HDR_BASE(x)	(TOE_NONTOE_QUE_HDR_BASE + 0x08 * (x=
))
+#define TOE_CLASS_Q_HDR_BASE		(TOE_NONTOE_QUE_HDR_BASE + 0x10)
+#define TOE_INTR_Q_HDR_BASE		(TOE_NONTOE_QUE_HDR_BASE + 0x80)
+#define INTERRUPT_QUEUE_HDR_ADDR(n)	(TOE_INTR_Q_HDR_BASE + n * 8)
+#define NONTOE_Q_HDR_AREA_END		(INTERRUPT_QUEUE_HDR_ADDR(TOE_INTR_QUEU=
E_MAX + 1))
+/*
+ * TOE Queue Header Word 0
+ */
+typedef union {
+	unsigned int bits32;
+	unsigned int base_size;
+} TOE_QHDR0_T;
+
+#define TOE_QHDR0_BASE_MASK	(~0x0f)
+
+/*
+ * TOE Queue Header Word 1
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_qhdr1 {
+		unsigned int rptr	: 16;	/* bit 15:0 */
+		unsigned int wptr	: 16;	/* bit 31:16 */
+	} bits;
+} TOE_QHDR1_T;
+
+/*
+ * TOE Queue Header Word 2
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_qhdr2 {
+		unsigned int TotalPktSize	: 17;	/* bit 16: 0	Total packet size */
+		unsigned int reserved		: 7;	/* bit 23:17 */
+		unsigned int dack		: 1;	/* bit 24	1: Duplicated ACK */
+		unsigned int abn		: 1;	/* bit 25	1: Abnormal case Found */
+		unsigned int tcp_opt		: 1;	/* bit 26	1: Have TCP option */
+		unsigned int ip_opt		: 1;	/* bit 27	1: have IPV4 option or IPV6 Exte=
nsion header */
+		unsigned int sat		: 1;	/* bit 28	1: SeqCnt > SeqThreshold, or AckCnt=
 > AckThreshold */
+		unsigned int osq		: 1;	/* bit 29	1: out of sequence */
+		unsigned int ctl		: 1;	/* bit 30	1: have control flag bits (except a=
ck) */
+		unsigned int usd		: 1;	/* bit 31	0: if no data assembled yet */
+	} bits;
+} TOE_QHDR2_T;
+
+/*
+ * TOE Queue Header Word 3
+ */
+typedef union {
+	unsigned int bits32;
+	unsigned int seq_num;
+} TOE_QHDR3_T;
+
+/*
+ * TOE Queue Header Word 4
+ */
+typedef union {
+	unsigned int bits32;
+	unsigned int ack_num;
+} TOE_QHDR4_T;
+
+/*
+ * TOE Queue Header Word 5
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_qhdr5 {
+		unsigned int AckCnt	: 16;	/* bit 15:0 */
+		unsigned int SeqCnt	: 16;	/* bit 31:16 */
+	} bits;
+} TOE_QHDR5_T;
+
+/*
+ * TOE Queue Header Word 6
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_qhdr6 {
+		unsigned int WinSize	: 16;	/* bit 15:0 */
+		unsigned int iq_num	: 2;	/* bit 17:16 */
+		unsigned int MaxPktSize	: 14;	/* bit 31:18 */
+	} bits;
+} TOE_QHDR6_T;
+
+/*
+ * TOE Queue Header Word 7
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_qhdr7 {
+		unsigned int AckThreshold	: 16;	/* bit 15:0 */
+		unsigned int SeqThreshold	: 16;	/* bit 31:16 */
+	} bits;
+} TOE_QHDR7_T;
+
+/*
+ * TOE Queue Header
+ */
+typedef struct {
+	TOE_QHDR0_T		word0;
+	TOE_QHDR1_T		word1;
+	TOE_QHDR2_T		word2;
+	TOE_QHDR3_T		word3;
+	TOE_QHDR4_T		word4;
+	TOE_QHDR5_T		word5;
+	TOE_QHDR6_T		word6;
+	TOE_QHDR7_T		word7;
+} TOE_QHDR_T;
+
+/*
+ * NONTOE Queue Header Word 0
+ */
+typedef union {
+	unsigned int bits32;
+	unsigned int base_size;
+} NONTOE_QHDR0_T;
+
+#define NONTOE_QHDR0_BASE_MASK	(~0x0f)
+
+/*
+ * NONTOE Queue Header Word 1
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_nonqhdr1 {
+		unsigned int rptr	: 16;	/* bit 15:0 */
+		unsigned int wptr	: 16;	/* bit 31:16 */
+	} bits;
+} NONTOE_QHDR1_T;
+
+/*
+ * Non-TOE Queue Header
+ */
+typedef struct {
+	NONTOE_QHDR0_T		word0;
+	NONTOE_QHDR1_T		word1;
+} NONTOE_QHDR_T;
+
+/*
+ * Interrupt Queue Header Word 0
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_intrqhdr0 {
+		unsigned int win_size	: 16;	/* bit 15:0	Descriptor Ring Size */
+		unsigned int wptr	: 16;	/* bit 31:16	Write Pointer where hw stopped =
*/
+	} bits;
+} INTR_QHDR0_T;
+
+/*
+ * Interrupt Queue Header Word 1
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_intrqhdr1 {
+		unsigned int TotalPktSize	: 17;	/* bit 16: 0	Total packet size */
+		unsigned int tcp_qid		: 8;	/* bit 24:17	TCP Queue ID */
+		unsigned int dack		: 1;	/* bit 25	1: Duplicated ACK */
+		unsigned int abn		: 1;	/* bit 26	1: Abnormal case Found */
+		unsigned int tcp_opt		: 1;	/* bit 27	1: Have TCP option */
+		unsigned int ip_opt		: 1;	/* bit 28	1: have IPV4 option or IPV6 Exte=
nsion header */
+		unsigned int sat		: 1;	/* bit 29	1: SeqCnt > SeqThreshold, or AckCnt=
 > AckThreshold */
+		unsigned int osq		: 1;	/* bit 30	1: out of sequence */
+		unsigned int ctl		: 1;	/* bit 31	1: have control flag bits (except a=
ck) */
+	} bits;
+} INTR_QHDR1_T;
+
+/*
+ * Interrupt Queue Header Word 2
+ */
+typedef union {
+	unsigned int bits32;
+	unsigned int seq_num;
+} INTR_QHDR2_T;
+
+/*
+ * Interrupt Queue Header Word 3
+ */
+typedef union {
+	unsigned int bits32;
+	unsigned int ack_num;
+} INTR_QHDR3_T;
+
+/*
+ * Interrupt Queue Header Word 4
+ */
+typedef union {
+	unsigned int bits32;
+	struct bit_intrqhdr4 {
+		unsigned int AckCnt		: 16;	/* bit 15:0	Ack# change since last ack# i=
ntr. */
+		unsigned int SeqCnt		: 16;	/* bit 31:16	Seq# change since last seq# =
intr. */
+	} bits;
+} INTR_QHDR4_T;
+
+/*
+ * Interrupt Queue Header
+ */
+typedef struct {
+	INTR_QHDR0_T		word0;
+	INTR_QHDR1_T		word1;
+	INTR_QHDR2_T		word2;
+	INTR_QHDR3_T		word3;
+	INTR_QHDR4_T		word4;
+	unsigned int		word5;
+	unsigned int		word6;
+	unsigned int		word7;
+} INTR_QHDR_T;
+
+#endif /* _GMAC_SL351x_H */

