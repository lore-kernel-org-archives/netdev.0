From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH v2 13/13] net: add Xilinx ll_temac device driver
Date: Sat, 21 Mar 2009 16:29:24 -0600
Message-ID: <20090321222923.20493.19960.stgit@localhost.localdomain>
References: <20090321222047.20493.87335.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, galak@kernel.crashing.org,
	davem@davemloft.net
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:31077 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756267AbZCUW3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 18:29:32 -0400
Received: by wf-out-1314.google.com with SMTP id 29so2085459wff.4
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2009 15:29:30 -0700 (PDT)
In-Reply-To: <20090321222047.20493.87335.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

This patch adds support for the Xilinx ll_temac 10/100/1000 Ethernet
device.  The ll_temac ipcore is typically used on Xilinx Virtex and
Spartan designs attached to either a PowerPC 4xx or Microblaze
processor.

At the present moment, this driver only works with Virtex5 PowerPC
designs because it assumes DCR is used to access the DMA registers.
However, the low level access to DMA registers is abstracted and
it should be easy to adapt for the other implementations.

I'm posting this driver now as an RFC.  There are still some things that
need to be tightened up, but it does appear to be stable.

Derived from driver code written by Yoshio Kashiwagi and David H. Lynch Jr.

CC: Yoshio Kashiwagi <kashiwagi@co-nss.co.jp>
CC: David H. Lynch Jr. <dhlii@dlasys.net>
CC: John Linn <john.linn@xilinx.com>
CC: John Bonesio <john.bonesio@xilinx.com>
CC: David DeBonis <ddeboni@xilinx.com>
CC: Wilson Yang <wyang@xilinx.com>
Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/Kconfig             |    8 
 drivers/net/Makefile            |    2 
 drivers/net/xilinx_temac.c      |  970 +++++++++++++++++++++++++++++++++++++++
 drivers/net/xilinx_temac.h      |  374 +++++++++++++++
 drivers/net/xilinx_temac_mdio.c |  119 +++++
 5 files changed, 1473 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/xilinx_temac.c
 create mode 100644 drivers/net/xilinx_temac.h
 create mode 100644 drivers/net/xilinx_temac_mdio.c


diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 435e2e3..29d6c1f 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2321,6 +2321,14 @@ config MV643XX_ETH
 	  Some boards that use the Discovery chipset are the Momenco
 	  Ocelot C and Jaguar ATX and Pegasos II.
 
+config XILINX_TEMAC
+	tristate "Xilinx TEMAC 10/100/1000 Ethernet MAC driver"
+	select PHYLIB
+	depends on PPC
+	help
+	  This driver supports the Xilinx 10/100/1000 LocalLink TEMAC
+	  device found in Virtex FPGAs
+
 config QLA3XXX
 	tristate "QLogic QLA3XXX Network Driver Support"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 471baaf..c7b4dd9 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -132,6 +132,8 @@ obj-$(CONFIG_AX88796) += ax88796.o
 
 obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
 obj-$(CONFIG_MV643XX_ETH) += mv643xx_eth.o
+xilinxtemac-objs := xilinx_temac.o xilinx_temac_mdio.o
+obj-$(CONFIG_XILINX_TEMAC) += xilinxtemac.o
 obj-$(CONFIG_QLA3XXX) += qla3xxx.o
 obj-$(CONFIG_QLGE) += qlge/
 
diff --git a/drivers/net/xilinx_temac.c b/drivers/net/xilinx_temac.c
new file mode 100644
index 0000000..d778a55
--- /dev/null
+++ b/drivers/net/xilinx_temac.c
@@ -0,0 +1,970 @@
+/*
+ * Driver for Xilinx TEMAC Ethernet device
+ *
+ * Copyright (c) 2008 Nissin Systems Co., Ltd.,  Yoshio Kashiwagi
+ * Copyright (c) 2005-2008 DLA Systems,  David H. Lynch Jr. <dhlii@dlasys.net>
+ * Copyright (c) 2008-2009 Secret Lab Technologies Ltd.
+ *
+ * This is a driver for the Xilinx ll_temac ipcore which is often used
+ * in the Virtex and Spartan series of chips.
+ *
+ * Notes:
+ * - The ll_temac hardware uses indirect access for many of the TEMAC
+ *   registers, include the MDIO bus.  However, indirect access to MDIO
+ *   registers take considerably more clock cycles than to TEMAC registers.
+ *   MDIO accesses are long, so threads doing them should probably sleep
+ *   rather than busywait.  However, since only one indirect access can be
+ *   in progress at any given time, that means that *all* indirect accesses
+ *   could end up sleeping (to wait for an MDIO access to complete).
+ *   Fortunately none of the indirect accesses are on the 'hot' path for tx
+ *   or rx, so this should be okay.
+ *
+ * TODO:
+ * - Fix driver to work on more than just Virtex5.  Right now the driver
+ *   assumes that the locallink DMA registers are accessed via DCR
+ *   instructions.
+ * - Factor out locallink DMA code into separate driver
+ * - Fix multicast assignment.
+ * - Fix support for hardware checksumming.
+ * - Testing.  Lots and lots of testing.
+ *
+ */
+
+#include <linux/delay.h>
+#include <linux/etherdevice.h>
+#include <linux/init.h>
+#include <linux/mii.h>
+#include <linux/module.h>
+#include <linux/mutex.h>
+#include <linux/netdevice.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
+#include <linux/of_mdio.h>
+#include <linux/of_platform.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/tcp.h>      /* needed for sizeof(tcphdr) */
+#include <linux/udp.h>      /* needed for sizeof(udphdr) */
+#include <linux/pci.h>
+#include <linux/phy.h>
+#include <linux/in.h>
+#include <linux/io.h>
+#include <linux/ip.h>
+
+#include "xilinx_temac.h"
+
+#define TX_BD_NUM   64
+#define RX_BD_NUM   128
+
+/* ---------------------------------------------------------------------
+ * Low level register access functions
+ */
+
+u32 temac_ior(struct temac_local *lp, int offset)
+{
+	return in_be32((u32 *)(lp->regs + offset));
+}
+
+void temac_iow(struct temac_local *lp, int offset, u32 value)
+{
+	out_be32((u32 *) (lp->regs + offset), value);
+}
+
+int temac_indirect_busywait(struct temac_local *lp)
+{
+	long end = jiffies + 2;
+
+	while (!(temac_ior(lp, XTE_RDY0_OFFSET) & XTE_RDY0_HARD_ACS_RDY_MASK)) {
+		if (end - jiffies <= 0) {
+			WARN_ON(1);
+			return -ETIMEDOUT;
+		}
+		msleep(1);
+	}
+	return 0;
+}
+
+/**
+ * temac_indirect_in32
+ *
+ * lp->indirect_mutex must be held when calling this function
+ */
+u32 temac_indirect_in32(struct temac_local *lp, int reg)
+{
+	u32 val;
+
+	if (temac_indirect_busywait(lp))
+		return -ETIMEDOUT;
+	temac_iow(lp, XTE_CTL0_OFFSET, reg);
+	if (temac_indirect_busywait(lp))
+		return -ETIMEDOUT;
+	val = temac_ior(lp, XTE_LSW0_OFFSET);
+
+	return val;
+}
+
+/**
+ * temac_indirect_out32
+ *
+ * lp->indirect_mutex must be held when calling this function
+ */
+void temac_indirect_out32(struct temac_local *lp, int reg, u32 value)
+{
+	if (temac_indirect_busywait(lp))
+		return;
+	temac_iow(lp, XTE_LSW0_OFFSET, value);
+	temac_iow(lp, XTE_CTL0_OFFSET, CNTLREG_WRITE_ENABLE_MASK | reg);
+}
+
+static u32 temac_dma_in32(struct temac_local *lp, int reg)
+{
+	return dcr_read(lp->sdma_dcrs, reg);
+}
+
+static void temac_dma_out32(struct temac_local *lp, int reg, u32 value)
+{
+	dcr_write(lp->sdma_dcrs, reg, value);
+}
+
+/**
+ * temac_dma_bd_init - Setup buffer descriptor rings
+ */
+static int temac_dma_bd_init(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+	struct sk_buff *skb;
+	int i;
+
+	lp->rx_skb = kzalloc(sizeof(struct sk_buff)*RX_BD_NUM, GFP_KERNEL);
+	/* allocate the tx and rx ring buffer descriptors. */
+	/* returns a virtual addres and a physical address. */
+	lp->tx_bd_v = dma_alloc_coherent(NULL, sizeof(*lp->tx_bd_v) * TX_BD_NUM,
+					 &lp->tx_bd_p, GFP_KERNEL);
+	lp->rx_bd_v = dma_alloc_coherent(NULL, sizeof(*lp->rx_bd_v) * RX_BD_NUM,
+					 &lp->rx_bd_p, GFP_KERNEL);
+
+	memset(lp->tx_bd_v, 0, sizeof(*lp->tx_bd_v) * TX_BD_NUM);
+	for (i = 0; i < TX_BD_NUM; i++) {
+		lp->tx_bd_v[i].next = lp->tx_bd_p +
+				sizeof(*lp->tx_bd_v) * ((i + 1) % TX_BD_NUM);
+	}
+
+	memset(lp->rx_bd_v, 0, sizeof(*lp->rx_bd_v) * RX_BD_NUM);
+	for (i = 0; i < RX_BD_NUM; i++) {
+		lp->rx_bd_v[i].next = lp->rx_bd_p +
+				sizeof(*lp->rx_bd_v) * ((i + 1) % RX_BD_NUM);
+
+		skb = alloc_skb(XTE_MAX_JUMBO_FRAME_SIZE
+				+ XTE_ALIGN, GFP_ATOMIC);
+		if (skb == 0) {
+			dev_err(&ndev->dev, "alloc_skb error %d\n", i);
+			return -1;
+		}
+		lp->rx_skb[i] = skb;
+		skb_reserve(skb,  BUFFER_ALIGN(skb->data));
+		/* returns physical address of skb->data */
+		lp->rx_bd_v[i].phys = pci_map_single(NULL, skb->data,
+						     XTE_MAX_JUMBO_FRAME_SIZE,
+						     PCI_DMA_FROMDEVICE);
+		lp->rx_bd_v[i].len = XTE_MAX_JUMBO_FRAME_SIZE;
+		lp->rx_bd_v[i].app0 = STS_CTRL_APP0_IRQONEND;
+	}
+
+	temac_dma_out32(lp, TX_CHNL_CTRL, 0x10220400 |
+					  CHNL_CTRL_IRQ_EN |
+					  CHNL_CTRL_IRQ_DLY_EN |
+					  CHNL_CTRL_IRQ_COAL_EN);
+	/* 0x10220483 */
+	/* 0x00100483 */
+	temac_dma_out32(lp, RX_CHNL_CTRL, 0xff010000 |
+					  CHNL_CTRL_IRQ_EN |
+					  CHNL_CTRL_IRQ_DLY_EN |
+					  CHNL_CTRL_IRQ_COAL_EN |
+					  CHNL_CTRL_IRQ_IOE);
+	/* 0xff010283 */
+
+	temac_dma_out32(lp, RX_CURDESC_PTR,  lp->rx_bd_p);
+	temac_dma_out32(lp, RX_TAILDESC_PTR,
+		       lp->rx_bd_p + (sizeof(*lp->rx_bd_v) * (RX_BD_NUM - 1)));
+	temac_dma_out32(lp, TX_CURDESC_PTR, lp->tx_bd_p);
+
+	return 0;
+}
+
+/* ---------------------------------------------------------------------
+ * net_device_ops
+ */
+
+static int temac_set_mac_address(struct net_device *ndev, void *address)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+
+	if (address)
+		memcpy(ndev->dev_addr, address, ETH_ALEN);
+
+	if (!is_valid_ether_addr(ndev->dev_addr))
+		random_ether_addr(ndev->dev_addr);
+
+	/* set up unicast MAC address filter set its mac address */
+	mutex_lock(&lp->indirect_mutex);
+	temac_indirect_out32(lp, XTE_UAW0_OFFSET,
+			     (ndev->dev_addr[0]) |
+			     (ndev->dev_addr[1] << 8) |
+			     (ndev->dev_addr[2] << 16) |
+			     (ndev->dev_addr[3] << 24));
+	/* There are reserved bits in EUAW1
+	 * so don't affect them Set MAC bits [47:32] in EUAW1 */
+	temac_indirect_out32(lp, XTE_UAW1_OFFSET,
+			     (ndev->dev_addr[4] & 0x000000ff) |
+			     (ndev->dev_addr[5] << 8));
+	mutex_unlock(&lp->indirect_mutex);
+
+	return 0;
+}
+
+static void temac_set_multicast_list(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+	u32 multi_addr_msw, multi_addr_lsw, val;
+	int i;
+
+	mutex_lock(&lp->indirect_mutex);
+	if (ndev->flags & (IFF_ALLMULTI | IFF_PROMISC)
+			|| ndev->mc_count > MULTICAST_CAM_TABLE_NUM) {
+		/*
+		 *	We must make the kernel realise we had to move
+		 *	into promisc mode or we start all out war on
+		 *	the cable. If it was a promisc request the
+		 *	flag is already set. If not we assert it.
+		 */
+		ndev->flags |= IFF_PROMISC;
+		temac_indirect_out32(lp, XTE_AFM_OFFSET, XTE_AFM_EPPRM_MASK);
+		dev_info(&ndev->dev, "Promiscuous mode enabled.\n");
+	} else if (ndev->mc_count) {
+		struct dev_mc_list *mclist = ndev->mc_list;
+		for (i = 0; mclist && i < ndev->mc_count; i++) {
+
+			if (i >= MULTICAST_CAM_TABLE_NUM)
+				break;
+			multi_addr_msw = ((mclist->dmi_addr[3] << 24) |
+					  (mclist->dmi_addr[2] << 16) |
+					  (mclist->dmi_addr[1] << 8) |
+					  (mclist->dmi_addr[0]));
+			temac_indirect_out32(lp, XTE_MAW0_OFFSET,
+					     multi_addr_msw);
+			multi_addr_lsw = ((mclist->dmi_addr[5] << 8) |
+					  (mclist->dmi_addr[4]) | (i << 16));
+			temac_indirect_out32(lp, XTE_MAW1_OFFSET,
+					     multi_addr_lsw);
+			mclist = mclist->next;
+		}
+	} else {
+		val = temac_indirect_in32(lp, XTE_AFM_OFFSET);
+		temac_indirect_out32(lp, XTE_AFM_OFFSET,
+				     val & ~XTE_AFM_EPPRM_MASK);
+		temac_indirect_out32(lp, XTE_MAW0_OFFSET, 0);
+		temac_indirect_out32(lp, XTE_MAW1_OFFSET, 0);
+		dev_info(&ndev->dev, "Promiscuous mode disabled.\n");
+	}
+	mutex_unlock(&lp->indirect_mutex);
+}
+
+struct temac_option {
+	int flg;
+	u32 opt;
+	u32 reg;
+	u32 m_or;
+	u32 m_and;
+} temac_options[] = {
+	/* Turn on jumbo packet support for both Rx and Tx */
+	{
+		.opt = XTE_OPTION_JUMBO,
+		.reg = XTE_TXC_OFFSET,
+		.m_or = XTE_TXC_TXJMBO_MASK,
+	},
+	{
+		.opt = XTE_OPTION_JUMBO,
+		.reg = XTE_RXC1_OFFSET,
+		.m_or =XTE_RXC1_RXJMBO_MASK,
+	},
+	/* Turn on VLAN packet support for both Rx and Tx */
+	{
+		.opt = XTE_OPTION_VLAN,
+		.reg = XTE_TXC_OFFSET,
+		.m_or =XTE_TXC_TXVLAN_MASK,
+	},
+	{
+		.opt = XTE_OPTION_VLAN,
+		.reg = XTE_RXC1_OFFSET,
+		.m_or =XTE_RXC1_RXVLAN_MASK,
+	},
+	/* Turn on FCS stripping on receive packets */
+	{
+		.opt = XTE_OPTION_FCS_STRIP,
+		.reg = XTE_RXC1_OFFSET,
+		.m_or =XTE_RXC1_RXFCS_MASK,
+	},
+	/* Turn on FCS insertion on transmit packets */
+	{
+		.opt = XTE_OPTION_FCS_INSERT,
+		.reg = XTE_TXC_OFFSET,
+		.m_or =XTE_TXC_TXFCS_MASK,
+	},
+	/* Turn on length/type field checking on receive packets */
+	{
+		.opt = XTE_OPTION_LENTYPE_ERR,
+		.reg = XTE_RXC1_OFFSET,
+		.m_or =XTE_RXC1_RXLT_MASK,
+	},
+	/* Turn on flow control */
+	{
+		.opt = XTE_OPTION_FLOW_CONTROL,
+		.reg = XTE_FCC_OFFSET,
+		.m_or =XTE_FCC_RXFLO_MASK,
+	},
+	/* Turn on flow control */
+	{
+		.opt = XTE_OPTION_FLOW_CONTROL,
+		.reg = XTE_FCC_OFFSET,
+		.m_or =XTE_FCC_TXFLO_MASK,
+	},
+	/* Turn on promiscuous frame filtering (all frames are received ) */
+	{
+		.opt = XTE_OPTION_PROMISC,
+		.reg = XTE_AFM_OFFSET,
+		.m_or =XTE_AFM_EPPRM_MASK,
+	},
+	/* Enable transmitter if not already enabled */
+	{
+		.opt = XTE_OPTION_TXEN,
+		.reg = XTE_TXC_OFFSET,
+		.m_or =XTE_TXC_TXEN_MASK,
+	},
+	/* Enable receiver? */
+	{
+		.opt = XTE_OPTION_RXEN,
+		.reg = XTE_RXC1_OFFSET,
+		.m_or =XTE_RXC1_RXEN_MASK,
+	},
+	{}
+};
+
+/**
+ * temac_setoptions
+ */
+static u32 temac_setoptions(struct net_device *ndev, u32 options)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+	struct temac_option *tp = &temac_options[0];
+	int reg;
+
+	mutex_lock(&lp->indirect_mutex);
+	while (tp->opt) {
+		reg = temac_indirect_in32(lp, tp->reg) & ~tp->m_or;
+		if (options & tp->opt)
+			reg |= tp->m_or;
+		temac_indirect_out32(lp, tp->reg, reg);
+		tp++;
+	}
+	lp->options |= options;
+	mutex_unlock(&lp->indirect_mutex);
+
+	return (0);
+}
+
+/* Initilize temac */
+static void temac_device_reset(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+	u32 timeout;
+	u32 val;
+
+	/* Perform a software reset */
+
+	/* 0x300 host enable bit ? */
+	/* reset PHY through control register ?:1 */
+
+	dev_dbg(&ndev->dev, "%s()\n", __func__);
+
+	mutex_lock(&lp->indirect_mutex);
+	/* Reset the receiver and wait for it to finish reset */
+	temac_indirect_out32(lp, XTE_RXC1_OFFSET, XTE_RXC1_RXRST_MASK);
+	timeout = 1000;
+	while (temac_indirect_in32(lp, XTE_RXC1_OFFSET) & XTE_RXC1_RXRST_MASK) {
+		udelay(1);
+		if (--timeout == 0) {
+			dev_err(&ndev->dev,
+				"temac_device_reset RX reset timeout!!\n");
+			break;
+		}
+	}
+
+	/* Reset the transmitter and wait for it to finish reset */
+	temac_indirect_out32(lp, XTE_TXC_OFFSET, XTE_TXC_TXRST_MASK);
+	timeout = 1000;
+	while (temac_indirect_in32(lp, XTE_TXC_OFFSET) & XTE_TXC_TXRST_MASK) {
+		udelay(1);
+		if (--timeout == 0) {
+			dev_err(&ndev->dev,
+				"temac_device_reset TX reset timeout!!\n");
+			break;
+		}
+	}
+
+	/* Disable the receiver */
+	val = temac_indirect_in32(lp, XTE_RXC1_OFFSET);
+	temac_indirect_out32(lp, XTE_RXC1_OFFSET, val & ~XTE_RXC1_RXEN_MASK);
+
+	/* Reset Local Link (DMA) */
+	temac_dma_out32(lp, DMA_CONTROL_REG, DMA_CONTROL_RST);
+	timeout = 1000;
+	while (temac_dma_in32(lp, DMA_CONTROL_REG) & DMA_CONTROL_RST) {
+		udelay(1);
+		if (--timeout == 0) {
+			dev_err(&ndev->dev,
+				"temac_device_reset DMA reset timeout!!\n");
+			break;
+		}
+	}
+	temac_dma_out32(lp, DMA_CONTROL_REG, DMA_TAIL_ENABLE);
+
+	temac_dma_bd_init(ndev);
+
+	temac_indirect_out32(lp, XTE_RXC0_OFFSET, 0);
+	temac_indirect_out32(lp, XTE_RXC1_OFFSET, 0);
+	temac_indirect_out32(lp, XTE_TXC_OFFSET, 0);
+	temac_indirect_out32(lp, XTE_FCC_OFFSET, XTE_FCC_RXFLO_MASK);
+
+	mutex_unlock(&lp->indirect_mutex);
+
+	/* Sync default options with HW
+	 * but leave receiver and transmitter disabled.  */
+	temac_setoptions(ndev,
+			 lp->options & ~(XTE_OPTION_TXEN | XTE_OPTION_RXEN));
+
+	temac_set_mac_address(ndev, NULL);
+
+	/* Set address filter table */
+	temac_set_multicast_list(ndev);
+	if (temac_setoptions(ndev, lp->options))
+		dev_err(&ndev->dev, "Error setting TEMAC options\n");
+
+	/* Init Driver variable */
+	ndev->trans_start = 0;
+}
+
+void temac_adjust_link(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+	struct phy_device *phy = lp->phy_dev;
+	u32 mii_speed;
+	int link_state;
+
+	/* hash together the state values to decide if something has changed */
+	link_state = phy->speed | (phy->duplex << 1) | phy->link;
+
+	mutex_lock(&lp->indirect_mutex);
+	if (lp->last_link != link_state) {
+		mii_speed = temac_indirect_in32(lp, XTE_EMCFG_OFFSET);
+		mii_speed &= ~XTE_EMCFG_LINKSPD_MASK;
+
+		switch (phy->speed) {
+		case SPEED_1000: mii_speed |= XTE_EMCFG_LINKSPD_1000; break;
+		case SPEED_100: mii_speed |= XTE_EMCFG_LINKSPD_100; break;
+		case SPEED_10: mii_speed |= XTE_EMCFG_LINKSPD_10; break;
+		}
+
+		/* Write new speed setting out to TEMAC */
+		temac_indirect_out32(lp, XTE_EMCFG_OFFSET, mii_speed);
+		lp->last_link = link_state;
+		phy_print_status(phy);
+	}
+	mutex_unlock(&lp->indirect_mutex);
+}
+
+static void temac_start_xmit_done(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+	struct cdmac_bd *cur_p;
+	unsigned int stat = 0;
+
+	cur_p = &lp->tx_bd_v[lp->tx_bd_ci];
+	stat = cur_p->app0;
+
+	while (stat & STS_CTRL_APP0_CMPLT) {
+		pci_unmap_single(NULL, (unsigned long)cur_p->phys,
+				cur_p->len, PCI_DMA_TODEVICE);
+		if (cur_p->app4)
+			dev_kfree_skb_irq((struct sk_buff *)cur_p->app4);
+		cur_p->app0 = 0;
+
+		ndev->stats.tx_packets++;
+		ndev->stats.tx_bytes += cur_p->len;
+
+		lp->tx_bd_ci++;
+		if (lp->tx_bd_ci >= TX_BD_NUM)
+			lp->tx_bd_ci = 0;
+
+		cur_p = &lp->tx_bd_v[lp->tx_bd_ci];
+		stat = cur_p->app0;
+	}
+
+	netif_wake_queue(ndev);
+}
+
+static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+	struct cdmac_bd *cur_p;
+	dma_addr_t start_p, tail_p;
+	int ii;
+	unsigned long num_frag;
+	skb_frag_t *frag;
+
+	num_frag = skb_shinfo(skb)->nr_frags;
+	frag = &skb_shinfo(skb)->frags[0];
+	start_p = lp->tx_bd_p + sizeof(*lp->tx_bd_v) * lp->tx_bd_tail;
+	cur_p = &lp->tx_bd_v[lp->tx_bd_tail];
+
+	if (cur_p->app0 & STS_CTRL_APP0_CMPLT) {
+		if (!netif_queue_stopped(ndev)) {
+			netif_stop_queue(ndev);
+			return NETDEV_TX_BUSY;
+		}
+		return NETDEV_TX_BUSY;
+	}
+
+	cur_p->app0 = 0;
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		const struct iphdr *ip = ip_hdr(skb);
+		int length = 0, start, insert = 0, headlen;
+
+		switch (ip->protocol) {
+		case IPPROTO_TCP:
+			start = sizeof(struct iphdr) + ETH_HLEN;
+			insert = sizeof(struct iphdr) + ETH_HLEN + 16;
+			length = ip->tot_len - sizeof(struct iphdr);
+			headlen = ETH_HLEN + sizeof(struct iphdr) +
+				  sizeof(struct tcphdr);
+			break;
+		case IPPROTO_UDP:
+			start = sizeof(struct iphdr) + ETH_HLEN;
+			insert = sizeof(struct iphdr) + ETH_HLEN + 6;
+			length = ip->tot_len - sizeof(struct iphdr);
+			headlen = ETH_HLEN + sizeof(struct iphdr) +
+				  sizeof(struct udphdr);
+			break;
+		default:
+			break;
+		}
+		cur_p->app1 = ((start << 16) | insert);
+		cur_p->app2 = csum_tcpudp_magic(ip->saddr, ip->daddr,
+						length, ip->protocol, 0);
+		skb->data[insert] = 0;
+		skb->data[insert + 1] = 0;
+	}
+	cur_p->app0 |= STS_CTRL_APP0_SOP;
+	cur_p->len = skb_headlen(skb);
+	cur_p->phys = pci_map_single(NULL, skb->data, skb->len,
+				     PCI_DMA_TODEVICE);
+	cur_p->app4 = (unsigned long)skb;
+
+	for (ii = 0; ii < num_frag; ii++) {
+		lp->tx_bd_tail++;
+		if (lp->tx_bd_tail >= TX_BD_NUM)
+			lp->tx_bd_tail = 0;
+
+		cur_p = &lp->tx_bd_v[lp->tx_bd_tail];
+		cur_p->phys = pci_map_single(NULL,
+				(void *)page_address(frag->page)
+				+ frag->page_offset,
+				frag->size, PCI_DMA_TODEVICE);
+		cur_p->len = frag->size;
+		cur_p->app0 = 0;
+		frag++;
+	}
+	cur_p->app0 |= STS_CTRL_APP0_EOP;
+
+	tail_p = lp->tx_bd_p + sizeof(*lp->tx_bd_v) * lp->tx_bd_tail;
+	lp->tx_bd_tail++;
+	if (lp->tx_bd_tail >= TX_BD_NUM)
+		lp->tx_bd_tail = 0;
+
+	/* Kick off the transfer */
+	temac_dma_out32(lp, TX_TAILDESC_PTR, tail_p); /* DMA start */
+
+	return 0;
+}
+
+
+static void ll_temac_recv(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+	struct sk_buff *skb, *new_skb;
+	unsigned int bdstat;
+	struct cdmac_bd *cur_p;
+	dma_addr_t tail_p;
+	int length;
+	unsigned long skb_vaddr;
+	unsigned long flags;
+
+	spin_lock_irqsave(&lp->rx_lock, flags);
+
+	tail_p = lp->rx_bd_p + sizeof(*lp->rx_bd_v) * lp->rx_bd_ci;
+	cur_p = &lp->rx_bd_v[lp->rx_bd_ci];
+
+	bdstat = cur_p->app0;
+	while ((bdstat & STS_CTRL_APP0_CMPLT)) {
+
+		skb = lp->rx_skb[lp->rx_bd_ci];
+		length = cur_p->app4;
+
+		skb_vaddr = virt_to_bus(skb->data);
+		pci_unmap_single(NULL, skb_vaddr, length, PCI_DMA_FROMDEVICE);
+
+		skb_put(skb, length);
+		skb->dev = ndev;
+		skb->protocol = eth_type_trans(skb, ndev);
+		skb->ip_summed = CHECKSUM_NONE;
+
+		netif_rx(skb);
+
+		ndev->stats.rx_packets++;
+		ndev->stats.rx_bytes += length;
+
+		new_skb = alloc_skb(XTE_MAX_JUMBO_FRAME_SIZE + XTE_ALIGN,
+				GFP_ATOMIC);
+		if (new_skb == 0) {
+			dev_err(&ndev->dev, "no memory for new sk_buff\n");
+			spin_unlock_irqrestore(&lp->rx_lock, flags);
+			return;
+		}
+
+		skb_reserve(new_skb, BUFFER_ALIGN(new_skb->data));
+
+		cur_p->app0 = STS_CTRL_APP0_IRQONEND;
+		cur_p->phys = pci_map_single(NULL, new_skb->data,
+					     XTE_MAX_JUMBO_FRAME_SIZE,
+					     PCI_DMA_FROMDEVICE);
+		cur_p->len = XTE_MAX_JUMBO_FRAME_SIZE;
+		lp->rx_skb[lp->rx_bd_ci] = new_skb;
+
+		lp->rx_bd_ci++;
+		if (lp->rx_bd_ci >= RX_BD_NUM)
+			lp->rx_bd_ci = 0;
+
+		cur_p = &lp->rx_bd_v[lp->rx_bd_ci];
+		bdstat = cur_p->app0;
+	}
+	temac_dma_out32(lp, RX_TAILDESC_PTR, tail_p);
+
+	spin_unlock_irqrestore(&lp->rx_lock, flags);
+}
+
+static irqreturn_t ll_temac_tx_irq(int irq, void *_ndev)
+{
+	struct net_device *ndev = _ndev;
+	struct temac_local *lp = netdev_priv(ndev);
+	unsigned int status;
+
+	status = temac_dma_in32(lp, TX_IRQ_REG);
+	temac_dma_out32(lp, TX_IRQ_REG, status);
+
+	if (status & (IRQ_COAL | IRQ_DLY))
+		temac_start_xmit_done(lp->ndev);
+	if (status & 0x080)
+		dev_err(&ndev->dev, "DMA error 0x%x\n", status);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t ll_temac_rx_irq(int irq, void *_ndev)
+{
+	struct net_device *ndev = _ndev;
+	struct temac_local *lp = netdev_priv(ndev);
+	unsigned int status;
+
+	/* Read and clear the status registers */
+	status = temac_dma_in32(lp, RX_IRQ_REG);
+	temac_dma_out32(lp, RX_IRQ_REG, status);
+
+	if (status & (IRQ_COAL | IRQ_DLY))
+		ll_temac_recv(lp->ndev);
+
+	return IRQ_HANDLED;
+}
+
+static int temac_open(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+	int rc;
+
+	dev_dbg(&ndev->dev, "temac_open()\n");
+
+	if (lp->phy_node) {
+		lp->phy_dev = of_phy_connect(lp->ndev, lp->phy_node,
+					     temac_adjust_link, 0, 0);
+		if (!lp->phy_dev) {
+			dev_err(lp->dev, "of_phy_connect() failed\n");
+			return -ENODEV;
+		}
+
+		phy_start(lp->phy_dev);
+	}
+
+	rc = request_irq(lp->tx_irq, ll_temac_tx_irq, 0, ndev->name, ndev);
+	if (rc)
+		goto err_tx_irq;
+	rc = request_irq(lp->rx_irq, ll_temac_rx_irq, 0, ndev->name, ndev);
+	if (rc)
+		goto err_rx_irq;
+
+	temac_device_reset(ndev);
+	return 0;
+
+ err_rx_irq:
+	free_irq(lp->tx_irq, ndev);
+ err_tx_irq:
+	if (lp->phy_dev)
+		phy_disconnect(lp->phy_dev);
+	lp->phy_dev = NULL;
+	dev_err(lp->dev, "request_irq() failed\n");
+	return rc;
+}
+
+static int temac_stop(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+
+	dev_dbg(&ndev->dev, "temac_close()\n");
+
+	free_irq(lp->tx_irq, ndev);
+	free_irq(lp->rx_irq, ndev);
+
+	if (lp->phy_dev)
+		phy_disconnect(lp->phy_dev);
+	lp->phy_dev = NULL;
+
+	return 0;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void
+temac_poll_controller(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+
+	disable_irq(lp->tx_irq);
+	disable_irq(lp->rx_irq);
+
+	ll_temac_rx_irq(lp->tx_irq, lp, 0);
+	ll_temac_tx_irq(lp->rx_irq, lp, 0);
+
+	enable_irq(lp->tx_irq);
+	enable_irq(lp->rx_irq);
+}
+#endif
+
+static const struct net_device_ops temac_netdev_ops = {
+	.ndo_open = temac_open,
+	.ndo_stop = temac_stop,
+	.ndo_start_xmit = temac_start_xmit,
+	.ndo_set_mac_address = temac_set_mac_address,
+	//.ndo_set_multicast_list = temac_set_multicast_list,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = temac_poll_controller,
+#endif
+};
+
+/* ---------------------------------------------------------------------
+ * SYSFS device attributes
+ */
+static ssize_t temac_show_llink_regs(struct device *dev,
+				     struct device_attribute *attr, char *buf)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+	struct temac_local *lp = netdev_priv(ndev);
+	int i, len = 0;
+
+	for (i = 0; i < 0x11; i++)
+		len += sprintf(buf + len, "%.8x%s", temac_dma_in32(lp, i),
+			       (i % 8) == 7 ? "\n" : " ");
+	len += sprintf(buf + len, "\n");
+
+	return len;
+}
+
+static DEVICE_ATTR(llink_regs, 0440, temac_show_llink_regs, NULL);
+
+static struct attribute *temac_device_attrs[] = {
+	&dev_attr_llink_regs.attr,
+	NULL,
+};
+
+static const struct attribute_group temac_attr_group = {
+	.attrs = temac_device_attrs,
+};
+
+static int __init
+temac_of_probe(struct of_device *op, const struct of_device_id *match)
+{
+	struct device_node *np;
+	struct temac_local *lp;
+	struct net_device *ndev;
+	const void *addr;
+	int size, rc = 0;
+	unsigned int dcrs;
+
+	/* Init network device structure */
+	ndev = alloc_etherdev(sizeof(*lp));
+	if (!ndev) {
+		dev_err(&op->dev, "could not allocate device.\n");
+		return -ENOMEM;
+	}
+	ether_setup(ndev);
+	dev_set_drvdata(&op->dev, ndev);
+	SET_NETDEV_DEV(ndev, &op->dev);
+	ndev->flags &= ~IFF_MULTICAST;  /* clear multicast */
+	ndev->features = NETIF_F_SG | NETIF_F_FRAGLIST;
+	ndev->netdev_ops = &temac_netdev_ops;
+#if 0
+	ndev->features |= NETIF_F_IP_CSUM; /* Can checksum TCP/UDP over IPv4. */
+	ndev->features |= NETIF_F_HW_CSUM; /* Can checksum all the packets. */
+	ndev->features |= NETIF_F_IPV6_CSUM; /* Can checksum IPV6 TCP/UDP */
+	ndev->features |= NETIF_F_HIGHDMA; /* Can DMA to high memory. */
+	ndev->features |= NETIF_F_HW_VLAN_TX; /* Transmit VLAN hw accel */
+	ndev->features |= NETIF_F_HW_VLAN_RX; /* Receive VLAN hw acceleration */
+	ndev->features |= NETIF_F_HW_VLAN_FILTER; /* Receive VLAN filtering */
+	ndev->features |= NETIF_F_VLAN_CHALLENGED; /* cannot handle VLAN pkts */
+	ndev->features |= NETIF_F_GSO; /* Enable software GSO. */
+	ndev->features |= NETIF_F_MULTI_QUEUE; /* Has multiple TX/RX queues */
+	ndev->features |= NETIF_F_LRO; /* large receive offload */
+#endif
+
+	/* setup temac private info structure */
+	lp = netdev_priv(ndev);
+	lp->ndev = ndev;
+	lp->dev = &op->dev;
+	lp->options = XTE_OPTION_DEFAULTS;
+	spin_lock_init(&lp->rx_lock);
+	mutex_init(&lp->indirect_mutex);
+
+	/* map device registers */
+	lp->regs = of_iomap(op->node, 0);
+	if (!lp->regs) {
+		dev_err(&op->dev, "could not map temac regs.\n");
+		goto nodev;
+	}
+
+	/* Find the DMA node, map the DMA registers, and decode the DMA IRQs */
+	np = of_parse_phandle(op->node, "llink-connected", 0);
+	if (!np) {
+		dev_err(&op->dev, "could not find DMA node\n");
+		goto nodev;
+	}
+
+	dcrs = dcr_resource_start(np, 0);
+	if (dcrs == 0) {
+		dev_err(&op->dev, "could not get DMA register address\n");
+		goto nodev;;
+	}
+	lp->sdma_dcrs = dcr_map(np, dcrs, dcr_resource_len(np, 0));
+	dev_dbg(&op->dev, "DCR base: %x\n", dcrs);
+
+	lp->rx_irq = irq_of_parse_and_map(np, 0);
+	lp->tx_irq = irq_of_parse_and_map(np, 1);
+	if (!lp->rx_irq || !lp->tx_irq) {
+		dev_err(&op->dev, "could not determine irqs\n");
+		rc = -ENOMEM;
+		goto nodev;
+	}
+
+	of_node_put(np); /* Finished with the DMA node; drop the reference */
+
+	/* Retrieve the MAC address */
+	addr = of_get_property(op->node, "local-mac-address", &size);
+	if ((!addr) || (size != 6)) {
+		dev_err(&op->dev, "could not find MAC address\n");
+		rc = -ENODEV;
+		goto nodev;
+	}
+	temac_set_mac_address(ndev, (void *)addr);
+
+	rc = temac_mdio_setup(lp, op->node);
+	if (rc)
+		dev_warn(&op->dev, "error registering MDIO bus\n");
+
+	lp->phy_node = of_parse_phandle(op->node, "phy-handle", 0);
+	if (lp->phy_node)
+		dev_dbg(lp->dev, "using PHY node %s (%p)\n", np->full_name, np);
+
+	/* Add the device attributes */
+	rc = sysfs_create_group(&lp->dev->kobj, &temac_attr_group);
+	if (rc) {
+		dev_err(lp->dev, "Error creating sysfs files\n");
+		goto nodev;
+	}
+
+	rc = register_netdev(lp->ndev);
+	if (rc) {
+		dev_err(lp->dev, "register_netdev() error (%i)\n", rc);
+		goto err_register_ndev;
+	}
+
+	return 0;
+
+ err_register_ndev:
+	sysfs_remove_group(&lp->dev->kobj, &temac_attr_group);
+ nodev:
+	free_netdev(ndev);
+	ndev = NULL;
+	return rc;
+}
+
+static int __devexit temac_of_remove(struct of_device *op)
+{
+	struct net_device *ndev = dev_get_drvdata(&op->dev);
+	struct temac_local *lp = netdev_priv(ndev);
+
+	temac_mdio_teardown(lp);
+	unregister_netdev(ndev);
+	sysfs_remove_group(&lp->dev->kobj, &temac_attr_group);
+	if (lp->phy_node)
+		of_node_put(lp->phy_node);
+	lp->phy_node = NULL;
+	dev_set_drvdata(&op->dev, NULL);
+	free_netdev(ndev);
+	return 0;
+}
+
+static struct of_device_id temac_of_match[] __devinitdata = {
+	{ .compatible = "xlnx,xps-ll-temac-1.01.b", },
+	{},
+};
+MODULE_DEVICE_TABLE(of, temac_of_match);
+
+static struct of_platform_driver temac_of_driver = {
+	.match_table = temac_of_match,
+	.probe = temac_of_probe,
+	.remove = __devexit_p(temac_of_remove),
+	.driver = {
+		.owner = THIS_MODULE,
+		.name = "xilinx_temac",
+	},
+};
+
+static int __init temac_init(void)
+{
+	return of_register_platform_driver(&temac_of_driver);
+}
+module_init(temac_init);
+
+static void __exit temac_exit(void)
+{
+	of_unregister_platform_driver(&temac_of_driver);
+}
+module_exit(temac_exit);
+
+MODULE_DESCRIPTION("Xilinx LL_TEMAC Ethernet driver");
+MODULE_AUTHOR("Yoshio Kashiwagi");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/xilinx_temac.h b/drivers/net/xilinx_temac.h
new file mode 100644
index 0000000..4bc340c
--- /dev/null
+++ b/drivers/net/xilinx_temac.h
@@ -0,0 +1,374 @@
+
+#ifndef XILINX_TEMAC_H
+#define XILINX_TEMAC_H
+
+#include <linux/netdevice.h>
+#include <linux/of.h>
+#include <linux/spinlock.h>
+#include <asm/dcr.h>
+#include <asm/dcr-regs.h>
+
+/* packet size info */
+#define XTE_HDR_SIZE			14      /* size of Ethernet header */
+#define XTE_TRL_SIZE			4       /* size of Ethernet trailer (FCS) */
+#define XTE_JUMBO_MTU			9000
+#define XTE_MAX_JUMBO_FRAME_SIZE	(XTE_JUMBO_MTU + XTE_HDR_SIZE + XTE_TRL_SIZE)
+
+/*  Configuration options */
+
+/*  Accept all incoming packets.
+ *  This option defaults to disabled (cleared) */
+#define XTE_OPTION_PROMISC                      (1 << 0)
+/*  Jumbo frame support for Tx & Rx.
+ *  This option defaults to disabled (cleared) */
+#define XTE_OPTION_JUMBO                        (1 << 1)
+/*  VLAN Rx & Tx frame support.
+ *  This option defaults to disabled (cleared) */
+#define XTE_OPTION_VLAN                         (1 << 2)
+/*  Enable recognition of flow control frames on Rx
+ *  This option defaults to enabled (set) */
+#define XTE_OPTION_FLOW_CONTROL                 (1 << 4)
+/*  Strip FCS and PAD from incoming frames.
+ *  Note: PAD from VLAN frames is not stripped.
+ *  This option defaults to disabled (set) */
+#define XTE_OPTION_FCS_STRIP                    (1 << 5)
+/*  Generate FCS field and add PAD automatically for outgoing frames.
+ *  This option defaults to enabled (set) */
+#define XTE_OPTION_FCS_INSERT                   (1 << 6)
+/*  Enable Length/Type error checking for incoming frames. When this option is
+set, the MAC will filter frames that have a mismatched type/length field
+and if XTE_OPTION_REPORT_RXERR is set, the user is notified when these
+types of frames are encountered. When this option is cleared, the MAC will
+allow these types of frames to be received.
+This option defaults to enabled (set) */
+#define XTE_OPTION_LENTYPE_ERR                  (1 << 7)
+/*  Enable the transmitter.
+ *  This option defaults to enabled (set) */
+#define XTE_OPTION_TXEN                         (1 << 11)
+/*  Enable the receiver
+*   This option defaults to enabled (set) */
+#define XTE_OPTION_RXEN                         (1 << 12)
+
+/*  Default options set when device is initialized or reset */
+#define XTE_OPTION_DEFAULTS                     \
+	(XTE_OPTION_TXEN |                          \
+	 XTE_OPTION_FLOW_CONTROL |                  \
+	 XTE_OPTION_RXEN)
+
+/* XPS_LL_TEMAC SDMA registers definition */
+
+#define TX_NXTDESC_PTR      0x00            /* r */
+#define TX_CURBUF_ADDR      0x01            /* r */
+#define TX_CURBUF_LENGTH    0x02            /* r */
+#define TX_CURDESC_PTR      0x03            /* rw */
+#define TX_TAILDESC_PTR     0x04            /* rw */
+#define TX_CHNL_CTRL        0x05            /* rw */
+/*
+ 0:7      24:31       IRQTimeout
+ 8:15     16:23       IRQCount
+ 16:20    11:15       Reserved
+ 21       10          0
+ 22       9           UseIntOnEnd
+ 23       8           LdIRQCnt
+ 24       7           IRQEn
+ 25:28    3:6         Reserved
+ 29       2           IrqErrEn
+ 30       1           IrqDlyEn
+ 31       0           IrqCoalEn
+*/
+#define CHNL_CTRL_IRQ_IOE       (1 << 9)
+#define CHNL_CTRL_IRQ_EN        (1 << 7)
+#define CHNL_CTRL_IRQ_ERR_EN    (1 << 2)
+#define CHNL_CTRL_IRQ_DLY_EN    (1 << 1)
+#define CHNL_CTRL_IRQ_COAL_EN   (1 << 0)
+#define TX_IRQ_REG          0x06            /* rw */
+/*
+  0:7      24:31       DltTmrValue
+ 8:15     16:23       ClscCntrValue
+ 16:17    14:15       Reserved
+ 18:21    10:13       ClscCnt
+ 22:23    8:9         DlyCnt
+ 24:28    3::7        Reserved
+ 29       2           ErrIrq
+ 30       1           DlyIrq
+ 31       0           CoalIrq
+ */
+#define TX_CHNL_STS         0x07            /* r */
+/*
+   0:9      22:31   Reserved
+ 10       21      TailPErr
+ 11       20      CmpErr
+ 12       19      AddrErr
+ 13       18      NxtPErr
+ 14       17      CurPErr
+ 15       16      BsyWr
+ 16:23    8:15    Reserved
+ 24       7       Error
+ 25       6       IOE
+ 26       5       SOE
+ 27       4       Cmplt
+ 28       3       SOP
+ 29       2       EOP
+ 30       1       EngBusy
+ 31       0       Reserved
+*/
+
+#define RX_NXTDESC_PTR      0x08            /* r */
+#define RX_CURBUF_ADDR      0x09            /* r */
+#define RX_CURBUF_LENGTH    0x0a            /* r */
+#define RX_CURDESC_PTR      0x0b            /* rw */
+#define RX_TAILDESC_PTR     0x0c            /* rw */
+#define RX_CHNL_CTRL        0x0d            /* rw */
+/*
+ 0:7      24:31       IRQTimeout
+ 8:15     16:23       IRQCount
+ 16:20    11:15       Reserved
+ 21       10          0
+ 22       9           UseIntOnEnd
+ 23       8           LdIRQCnt
+ 24       7           IRQEn
+ 25:28    3:6         Reserved
+ 29       2           IrqErrEn
+ 30       1           IrqDlyEn
+ 31       0           IrqCoalEn
+ */
+#define RX_IRQ_REG          0x0e            /* rw */
+#define IRQ_COAL        (1 << 0)
+#define IRQ_DLY         (1 << 1)
+#define IRQ_ERR         (1 << 2)
+#define IRQ_DMAERR      (1 << 7)            /* this is not documented ??? */
+/*
+ 0:7      24:31       DltTmrValue
+ 8:15     16:23       ClscCntrValue
+ 16:17    14:15       Reserved
+ 18:21    10:13       ClscCnt
+ 22:23    8:9         DlyCnt
+ 24:28    3::7        Reserved
+*/
+#define RX_CHNL_STS         0x0f        /* r */
+#define CHNL_STS_ENGBUSY    (1 << 1)
+#define CHNL_STS_EOP        (1 << 2)
+#define CHNL_STS_SOP        (1 << 3)
+#define CHNL_STS_CMPLT      (1 << 4)
+#define CHNL_STS_SOE        (1 << 5)
+#define CHNL_STS_IOE        (1 << 6)
+#define CHNL_STS_ERR        (1 << 7)
+
+#define CHNL_STS_BSYWR      (1 << 16)
+#define CHNL_STS_CURPERR    (1 << 17)
+#define CHNL_STS_NXTPERR    (1 << 18)
+#define CHNL_STS_ADDRERR    (1 << 19)
+#define CHNL_STS_CMPERR     (1 << 20)
+#define CHNL_STS_TAILERR    (1 << 21)
+/*
+ 0:9      22:31   Reserved
+ 10       21      TailPErr
+ 11       20      CmpErr
+ 12       19      AddrErr
+ 13       18      NxtPErr
+ 14       17      CurPErr
+ 15       16      BsyWr
+ 16:23    8:15    Reserved
+ 24       7       Error
+ 25       6       IOE
+ 26       5       SOE
+ 27       4       Cmplt
+ 28       3       SOP
+ 29       2       EOP
+ 30       1       EngBusy
+ 31       0       Reserved
+*/
+
+#define DMA_CONTROL_REG             0x10            /* rw */
+#define DMA_CONTROL_RST                 (1 << 0)
+#define DMA_TAIL_ENABLE                 (1 << 2)
+
+/* XPS_LL_TEMAC direct registers definition */
+
+#define XTE_RAF0_OFFSET              0x00
+#define RAF0_RST                        (1 << 0)
+#define RAF0_MCSTREJ                    (1 << 1)
+#define RAF0_BCSTREJ                    (1 << 2)
+#define XTE_TPF0_OFFSET              0x04
+#define XTE_IFGP0_OFFSET             0x08
+#define XTE_ISR0_OFFSET              0x0c
+#define ISR0_HARDACSCMPLT               (1 << 0)
+#define ISR0_AUTONEG                    (1 << 1)
+#define ISR0_RXCMPLT                    (1 << 2)
+#define ISR0_RXREJ                      (1 << 3)
+#define ISR0_RXFIFOOVR                  (1 << 4)
+#define ISR0_TXCMPLT                    (1 << 5)
+#define ISR0_RXDCMLCK                   (1 << 6)
+
+#define XTE_IPR0_OFFSET              0x10
+#define XTE_IER0_OFFSET              0x14
+
+#define XTE_MSW0_OFFSET              0x20
+#define XTE_LSW0_OFFSET              0x24
+#define XTE_CTL0_OFFSET              0x28
+#define XTE_RDY0_OFFSET              0x2c
+
+#define XTE_RSE_MIIM_RR_MASK      0x0002
+#define XTE_RSE_MIIM_WR_MASK      0x0004
+#define XTE_RSE_CFG_RR_MASK       0x0020
+#define XTE_RSE_CFG_WR_MASK       0x0040
+#define XTE_RDY0_HARD_ACS_RDY_MASK  (0x10000)
+
+/* XPS_LL_TEMAC indirect registers offset definition */
+
+#define	XTE_RXC0_OFFSET			0x00000200 /* Rx configuration word 0 */
+#define	XTE_RXC1_OFFSET			0x00000240 /* Rx configuration word 1 */
+#define XTE_RXC1_RXRST_MASK		(1 << 31)  /* Receiver reset */
+#define XTE_RXC1_RXJMBO_MASK		(1 << 30)  /* Jumbo frame enable */
+#define XTE_RXC1_RXFCS_MASK		(1 << 29)  /* FCS not stripped */
+#define XTE_RXC1_RXEN_MASK		(1 << 28)  /* Receiver enable */
+#define XTE_RXC1_RXVLAN_MASK		(1 << 27)  /* VLAN enable */
+#define XTE_RXC1_RXHD_MASK		(1 << 26)  /* Half duplex */
+#define XTE_RXC1_RXLT_MASK		(1 << 25)  /* Length/type check disable */
+
+#define XTE_TXC_OFFSET			0x00000280 /*  Tx configuration */
+#define XTE_TXC_TXRST_MASK		(1 << 31)  /* Transmitter reset */
+#define XTE_TXC_TXJMBO_MASK		(1 << 30)  /* Jumbo frame enable */
+#define XTE_TXC_TXFCS_MASK		(1 << 29)  /* Generate FCS */
+#define XTE_TXC_TXEN_MASK		(1 << 28)  /* Transmitter enable */
+#define XTE_TXC_TXVLAN_MASK		(1 << 27)  /* VLAN enable */
+#define XTE_TXC_TXHD_MASK		(1 << 26)  /* Half duplex */
+
+#define XTE_FCC_OFFSET			0x000002C0 /* Flow control config */
+#define XTE_FCC_RXFLO_MASK		(1 << 29)  /* Rx flow control enable */
+#define XTE_FCC_TXFLO_MASK		(1 << 30)  /* Tx flow control enable */
+
+#define XTE_EMCFG_OFFSET		0x00000300 /* EMAC configuration */
+#define XTE_EMCFG_LINKSPD_MASK		0xC0000000 /* Link speed */
+#define XTE_EMCFG_HOSTEN_MASK		(1 << 26)  /* Host interface enable */
+#define XTE_EMCFG_LINKSPD_10		0x00000000 /* 10 Mbit LINKSPD_MASK */
+#define XTE_EMCFG_LINKSPD_100		(1 << 30)  /* 100 Mbit LINKSPD_MASK */
+#define XTE_EMCFG_LINKSPD_1000		(1 << 31)  /* 1000 Mbit LINKSPD_MASK */
+
+#define XTE_GMIC_OFFSET			0x00000320 /* RGMII/SGMII config */
+#define XTE_MC_OFFSET			0x00000340 /* MDIO configuration */
+#define XTE_UAW0_OFFSET			0x00000380 /* Unicast address word 0 */
+#define XTE_UAW1_OFFSET			0x00000384 /* Unicast address word 1 */
+
+#define XTE_MAW0_OFFSET			0x00000388 /* Multicast addr word 0 */
+#define XTE_MAW1_OFFSET			0x0000038C /* Multicast addr word 1 */
+#define XTE_AFM_OFFSET			0x00000390 /* Promiscuous mode */
+#define XTE_AFM_EPPRM_MASK		(1 << 31)  /* Promiscuous mode enable */
+
+/* Interrupt Request status */
+#define XTE_TIS_OFFSET			0x000003A0
+#define TIS_FRIS			(1 << 0)
+#define TIS_MRIS			(1 << 1)
+#define TIS_MWIS			(1 << 2)
+#define TIS_ARIS			(1 << 3)
+#define TIS_AWIS			(1 << 4)
+#define TIS_CRIS			(1 << 5)
+#define TIS_CWIS			(1 << 6)
+
+#define XTE_TIE_OFFSET			0x000003A4 /* Interrupt enable */
+
+/**  MII Mamagement Control register (MGTCR) */
+#define XTE_MGTDR_OFFSET		0x000003B0 /* MII data */
+#define XTE_MIIMAI_OFFSET		0x000003B4 /* MII control */
+
+#define CNTLREG_WRITE_ENABLE_MASK   0x8000
+#define CNTLREG_EMAC1SEL_MASK       0x0400
+#define CNTLREG_ADDRESSCODE_MASK    0x03ff
+
+/* CDMAC descriptor status bit definitions */
+
+#define STS_CTRL_APP0_ERR         (1 << 31)
+#define STS_CTRL_APP0_IRQONEND    (1 << 30)
+/* undoccumented */
+#define STS_CTRL_APP0_STOPONEND   (1 << 29)
+#define STS_CTRL_APP0_CMPLT       (1 << 28)
+#define STS_CTRL_APP0_SOP         (1 << 27)
+#define STS_CTRL_APP0_EOP         (1 << 26)
+#define STS_CTRL_APP0_ENGBUSY     (1 << 25)
+/* undocumented */
+#define STS_CTRL_APP0_ENGRST      (1 << 24)
+
+#define TX_CONTROL_CALC_CSUM_MASK   1
+
+#define XTE_ALIGN       32
+#define BUFFER_ALIGN(adr) ((XTE_ALIGN - ((u32) adr)) % XTE_ALIGN)
+
+#define MULTICAST_CAM_TABLE_NUM 4
+
+/* TX/RX CURDESC_PTR points to first descriptor */
+/* TX/RX TAILDESC_PTR points to last descriptor in linked list */
+
+/**
+ * struct cdmac_bd - LocalLink buffer descriptor format
+ *
+ * app0 bits:
+ *	0    Error
+ *	1    IrqOnEnd    generate an interrupt at completion of DMA  op
+ *	2    reserved
+ *	3    completed   Current descriptor completed
+ *	4    SOP         TX - marks first desc/ RX marks first desct
+ *	5    EOP         TX marks last desc/RX marks last desc
+ *	6    EngBusy     DMA is processing
+ *	7    reserved
+ *	8:31 application specific
+ */
+struct cdmac_bd {
+	u32 next;	/* Physical address of next buffer descriptor */
+	u32 phys;
+	u32 len;
+	u32 app0;
+	u32 app1;	/* TX start << 16 | insert */
+	u32 app2;	/* TX csum */
+	u32 app3;
+	u32 app4;	/* skb for TX length for RX */
+};
+
+struct temac_local {
+	struct net_device *ndev;
+	struct device *dev;
+
+	/* Connection to PHY device */
+	struct phy_device *phy_dev;	/* Pointer to PHY device */
+	struct device_node *phy_node;
+
+	/* MDIO bus data */
+	struct mii_bus *mii_bus;	/* MII bus reference */
+	int mdio_irqs[PHY_MAX_ADDR];	/* IRQs table for MDIO bus */
+
+	/* IO registers and IRQs */
+	void __iomem *regs;
+	dcr_host_t sdma_dcrs;
+	int tx_irq;
+	int rx_irq;
+	int emac_num;
+
+	struct sk_buff **rx_skb;
+	spinlock_t rx_lock;
+	struct mutex indirect_mutex;
+	u32 options;			/* Current options word */
+	int last_link;
+
+	/* Buffer descriptors */
+	struct cdmac_bd *tx_bd_v;
+	dma_addr_t tx_bd_p;
+	struct cdmac_bd *rx_bd_v;
+	dma_addr_t rx_bd_p;
+	int tx_bd_ci;
+	int tx_bd_next;
+	int tx_bd_tail;
+	int rx_bd_ci;
+};
+
+/* xilinx_temac.c */
+u32 temac_ior(struct temac_local *lp, int offset);
+void temac_iow(struct temac_local *lp, int offset, u32 value);
+int temac_indirect_busywait(struct temac_local *lp);
+u32 temac_indirect_in32(struct temac_local *lp, int reg);
+void temac_indirect_out32(struct temac_local *lp, int reg, u32 value);
+
+
+/* xilinx_temac_mdio.c */
+int temac_mdio_setup(struct temac_local *lp, struct device_node *np);
+void temac_mdio_teardown(struct temac_local *lp);
+
+#endif /* XILINX_TEMAC_H */
diff --git a/drivers/net/xilinx_temac_mdio.c b/drivers/net/xilinx_temac_mdio.c
new file mode 100644
index 0000000..eeea61b
--- /dev/null
+++ b/drivers/net/xilinx_temac_mdio.c
@@ -0,0 +1,119 @@
+/*
+ * MDIO bus driver for the Xilinx TEMAC device
+ *
+ * Copyright (c) 2009 Secret Lab Technologies, Ltd.
+ */
+
+#include <linux/io.h>
+#include <linux/netdevice.h>
+#include <linux/mutex.h>
+#include <linux/phy.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
+#include <linux/of_mdio.h>
+#include "xilinx_temac.h"
+
+/* ---------------------------------------------------------------------
+ * MDIO Bus functions
+ */
+static int temac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
+{
+	struct temac_local *lp = bus->priv;
+	u32 rc;
+
+	/* Write the PHY address to the MIIM Access Initiator register.
+	 * When the transfer completes, the PHY register value will appear
+	 * in the LSW0 register */
+	mutex_lock(&lp->indirect_mutex);
+	temac_iow(lp, XTE_LSW0_OFFSET, (phy_id << 5) | reg);
+	rc = temac_indirect_in32(lp, XTE_MIIMAI_OFFSET);
+	mutex_unlock(&lp->indirect_mutex);
+
+	dev_dbg(lp->dev, "temac_mdio_read(phy_id=%i, reg=%x) == %x\n",
+		phy_id, reg, rc);
+
+	return rc;
+}
+
+static int temac_mdio_write(struct mii_bus *bus, int phy_id, int reg, u16 val)
+{
+	struct temac_local *lp = bus->priv;
+
+	dev_dbg(lp->dev, "temac_mdio_write(phy_id=%i, reg=%x, val=%x)\n",
+		phy_id, reg, val);
+
+	/* First write the desired value into the write data register
+	 * and then write the address into the access initiator register
+	 */
+	mutex_lock(&lp->indirect_mutex);
+	temac_indirect_out32(lp, XTE_MGTDR_OFFSET, val);
+	temac_indirect_out32(lp, XTE_MIIMAI_OFFSET, (phy_id << 5) | reg);
+	mutex_unlock(&lp->indirect_mutex);
+
+	return 0;
+}
+
+int temac_mdio_setup(struct temac_local *lp, struct device_node *np)
+{
+	struct mii_bus *bus;
+	const u32 *bus_hz;
+	int clk_div;
+	int rc, size;
+	struct resource res;
+
+	/* Calculate a reasonable divisor for the clock rate */
+	clk_div = 0x3f; /* worst-case default setting */
+	bus_hz = of_get_property(np, "clock-frequency", &size);
+	if (bus_hz && size >= sizeof(*bus_hz)) {
+		clk_div = (*bus_hz) / (2500 * 1000 * 2) - 1;
+		if (clk_div < 1)
+			clk_div = 1;
+		if (clk_div > 0x3f)
+			clk_div = 0x3f;
+	}
+
+	/* Enable the MDIO bus by asserting the enable bit and writing
+	 * in the clock config */
+	mutex_lock(&lp->indirect_mutex);
+	temac_indirect_out32(lp, XTE_MC_OFFSET, 1 << 6 | clk_div);
+	mutex_unlock(&lp->indirect_mutex);
+
+	bus = mdiobus_alloc();
+	if (!bus)
+		return -ENOMEM;
+
+	of_address_to_resource(np, 0, &res);
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%.8llx",
+		 (unsigned long long)res.start);
+	bus->priv = lp;
+	bus->name = "Xilinx TEMAC MDIO";
+	bus->read = temac_mdio_read;
+	bus->write = temac_mdio_write;
+	bus->parent = lp->dev;
+	bus->irq = lp->mdio_irqs; /* preallocated IRQ table */
+
+	lp->mii_bus = bus;
+
+	rc = of_mdiobus_register(bus, np);
+	if (rc)
+		goto err_register;
+
+	mutex_lock(&lp->indirect_mutex);
+	dev_dbg(lp->dev, "MDIO bus registered;  MC:%x\n",
+		temac_indirect_in32(lp, XTE_MC_OFFSET));
+	mutex_unlock(&lp->indirect_mutex);
+	return 0;
+
+ err_register:
+	mdiobus_free(bus);
+	return rc;
+}
+
+void temac_mdio_teardown(struct temac_local *lp)
+{
+	mdiobus_unregister(lp->mii_bus);
+	kfree(lp->mii_bus->irq);
+	mdiobus_free(lp->mii_bus);
+	lp->mii_bus = NULL;
+}
+

