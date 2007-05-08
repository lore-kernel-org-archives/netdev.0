From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Tue, 08 May 2007 03:19:22 +0200
Message-ID: <m3zm4g3yed.fsf_-_@maximus.localdomain>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<m3vef5biob.fsf@maximus.localdomain>
	<5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk>
	<m3hcqoa772.fsf@maximus.localdomain>
	<86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk>
	<m33b289zku.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	ARM Linux Mailing List
	<linux-arm-kernel@lists.arm.linux.org.uk>
To: Michael-Luke Jones <mlj28@cam.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:52155 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966591AbXEHBTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 21:19:51 -0400
In-Reply-To: <m33b289zku.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Mon, 07 May 2007 21:57:21 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds a driver for built-in IXP4xx Ethernet MAC and HSS ports

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

diff --git a/arch/arm/mach-ixp4xx/ixdp425-setup.c b/arch/arm/mach-ixp4xx/ixdp425-setup.c
index ec4f079..f20d39d 100644
--- a/arch/arm/mach-ixp4xx/ixdp425-setup.c
+++ b/arch/arm/mach-ixp4xx/ixdp425-setup.c
@@ -101,10 +101,35 @@ static struct platform_device ixdp425_uart = {
 	.resource		= ixdp425_uart_resources
 };
 
+/* Built-in 10/100 Ethernet MAC interfaces */
+static struct mac_plat_info ixdp425_plat_mac[] = {
+	{
+		.phy		= 0,
+		.rxq		= 3,
+	}, {
+		.phy		= 1,
+		.rxq		= 4,
+	}
+};
+
+static struct platform_device ixdp425_mac[] = {
+	{
+		.name			= "ixp4xx_eth",
+		.id			= IXP4XX_ETH_NPEB,
+		.dev.platform_data	= ixdp425_plat_mac,
+	}, {
+		.name			= "ixp4xx_eth",
+		.id			= IXP4XX_ETH_NPEC,
+		.dev.platform_data	= ixdp425_plat_mac + 1,
+	}
+};
+
 static struct platform_device *ixdp425_devices[] __initdata = {
 	&ixdp425_i2c_controller,
 	&ixdp425_flash,
-	&ixdp425_uart
+	&ixdp425_uart,
+	&ixdp425_mac[0],
+	&ixdp425_mac[1],
 };
 
 static void __init ixdp425_init(void)
diff --git a/drivers/net/arm/Kconfig b/drivers/net/arm/Kconfig
index 678e4f4..5e2acb6 100644
--- a/drivers/net/arm/Kconfig
+++ b/drivers/net/arm/Kconfig
@@ -46,3 +46,13 @@ config EP93XX_ETH
 	help
 	  This is a driver for the ethernet hardware included in EP93xx CPUs.
 	  Say Y if you are building a kernel for EP93xx based devices.
+
+config IXP4XX_ETH
+	tristate "IXP4xx Ethernet support"
+	depends on NET_ETHERNET && ARM && ARCH_IXP4XX
+	select IXP4XX_NPE
+	select IXP4XX_QMGR
+	select MII
+	help
+	  Say Y here if you want to use built-in Ethernet ports
+	  on IXP4xx processor.
diff --git a/drivers/net/arm/Makefile b/drivers/net/arm/Makefile
index a4c8682..7c812ac 100644
--- a/drivers/net/arm/Makefile
+++ b/drivers/net/arm/Makefile
@@ -9,3 +9,4 @@ obj-$(CONFIG_ARM_ETHER3)	+= ether3.o
 obj-$(CONFIG_ARM_ETHER1)	+= ether1.o
 obj-$(CONFIG_ARM_AT91_ETHER)	+= at91_ether.o
 obj-$(CONFIG_EP93XX_ETH)	+= ep93xx_eth.o
+obj-$(CONFIG_IXP4XX_ETH)	+= ixp4xx_eth.o
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
new file mode 100644
index 0000000..dcea6e5
--- /dev/null
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -0,0 +1,1002 @@
+/*
+ * Intel IXP4xx Ethernet driver for Linux
+ *
+ * Copyright (C) 2007 Krzysztof Halasa <khc@pm.waw.pl>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ *
+ * Ethernet port config (0x00 is not present on IXP42X):
+ *
+ * logical port		0x00		0x10		0x20
+ * NPE			0 (NPE-A)	1 (NPE-B)	2 (NPE-C)
+ * physical PortId	2		0		1
+ * TX queue		23		24		25
+ * RX-free queue	26		27		28
+ * TX-done queue is always 31, RX queue is configurable
+ */
+
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/dmapool.h>
+#include <linux/kernel.h>
+#include <linux/mii.h>
+#include <linux/platform_device.h>
+#include <asm/io.h>
+#include <asm/arch/npe.h>
+#include <asm/arch/qmgr.h>
+
+#ifndef __ARMEB__
+#warning Little endian mode not supported
+#endif
+
+#define DEBUG_QUEUES	0
+#define DEBUG_RX	0
+#define DEBUG_TX	0
+#define DEBUG_PKT_BYTES	0
+#define DEBUG_MDIO	0
+
+#define DRV_NAME	"ixp4xx_eth"
+#define DRV_VERSION	"0.04"
+
+#define TX_QUEUE_LEN	16 /* dwords */
+#define PKT_DESCS	64 /* also length of queues: TX-done, RX-ready, RX */
+
+#define POOL_ALLOC_SIZE		(sizeof(struct desc) * (PKT_DESCS))
+#define REGS_SIZE		0x1000
+#define MAX_MRU			1536
+
+#define MDIO_INTERVAL		(3 * HZ)
+#define MAX_MDIO_RETRIES	100 /* microseconds, typically 30 cycles */
+
+#define NPE_ID(port)		((port)->id >> 4)
+#define PHYSICAL_ID(port)	((NPE_ID(port) + 2) % 3)
+#define TX_QUEUE(plat)		(NPE_ID(port) + 23)
+#define RXFREE_QUEUE(plat)	(NPE_ID(port) + 26)
+#define TXDONE_QUEUE		31
+
+/* TX Control Registers */
+#define TX_CNTRL0_TX_EN		BIT(0)
+#define TX_CNTRL0_HALFDUPLEX	BIT(1)
+#define TX_CNTRL0_RETRY		BIT(2)
+#define TX_CNTRL0_PAD_EN	BIT(3)
+#define TX_CNTRL0_APPEND_FCS	BIT(4)
+#define TX_CNTRL0_2DEFER	BIT(5)
+#define TX_CNTRL0_RMII		BIT(6)	/* reduced MII */
+#define TX_CNTRL1_RETRIES	0x0F /* 4 bits */
+
+/* RX Control Registers */
+#define RX_CNTRL0_RX_EN		BIT(0)
+#define RX_CNTRL0_PADSTRIP_EN	BIT(1)
+#define RX_CNTRL0_SEND_FCS	BIT(2)
+#define RX_CNTRL0_PAUSE_EN	BIT(3)
+#define RX_CNTRL0_LOOP_EN	BIT(4)
+#define RX_CNTRL0_ADDR_FLTR_EN	BIT(5)
+#define RX_CNTRL0_RX_RUNT_EN	BIT(6)
+#define RX_CNTRL0_BCAST_DIS	BIT(7)
+#define RX_CNTRL1_DEFER_EN	BIT(0)
+
+/* Core Control Register */
+#define CORE_RESET		BIT(0)
+#define CORE_RX_FIFO_FLUSH	BIT(1)
+#define CORE_TX_FIFO_FLUSH	BIT(2)
+#define CORE_SEND_JAM		BIT(3)
+#define CORE_MDC_EN		BIT(4) /* NPE-B ETH-0 only */
+
+/* Definitions for MII access routines */
+#define MII_CMD_GO		BIT(31)
+#define MII_CMD_WRITE		BIT(26)
+#define MII_STAT_READ_FAILED	BIT(31)
+
+/* NPE message codes */
+#define NPE_GETSTATUS			0x00
+#define NPE_EDB_SETPORTADDRESS		0x01
+#define NPE_EDB_GETMACADDRESSDATABASE	0x02
+#define NPE_EDB_SETMACADDRESSSDATABASE	0x03
+#define NPE_GETSTATS			0x04
+#define NPE_RESETSTATS			0x05
+#define NPE_SETMAXFRAMELENGTHS		0x06
+#define NPE_VLAN_SETRXTAGMODE		0x07
+#define NPE_VLAN_SETDEFAULTRXVID	0x08
+#define NPE_VLAN_SETPORTVLANTABLEENTRY	0x09
+#define NPE_VLAN_SETPORTVLANTABLERANGE	0x0A
+#define NPE_VLAN_SETRXQOSENTRY		0x0B
+#define NPE_VLAN_SETPORTIDEXTRACTIONMODE 0x0C
+#define NPE_STP_SETBLOCKINGSTATE	0x0D
+#define NPE_FW_SETFIREWALLMODE		0x0E
+#define NPE_PC_SETFRAMECONTROLDURATIONID 0x0F
+#define NPE_PC_SETAPMACTABLE		0x11
+#define NPE_SETLOOPBACK_MODE		0x12
+#define NPE_PC_SETBSSIDTABLE		0x13
+#define NPE_ADDRESS_FILTER_CONFIG	0x14
+#define NPE_APPENDFCSCONFIG		0x15
+#define NPE_NOTIFY_MAC_RECOVERY_DONE	0x16
+#define NPE_MAC_RECOVERY_START		0x17
+
+
+struct eth_regs {
+	u32 tx_control[2], __res1[2];		/* 000 */
+	u32 rx_control[2], __res2[2];		/* 010 */
+	u32 random_seed, __res3[3];		/* 020 */
+	u32 partial_empty_threshold, __res4;	/* 030 */
+	u32 partial_full_threshold, __res5;	/* 038 */
+	u32 tx_start_bytes, __res6[3];		/* 040 */
+	u32 tx_deferral, rx_deferral,__res7[2];	/* 050 */
+	u32 tx_2part_deferral[2], __res8[2];	/* 060 */
+	u32 slot_time, __res9[3];		/* 070 */
+	u32 mdio_command[4];			/* 080 */
+	u32 mdio_status[4];			/* 090 */
+	u32 mcast_mask[6], __res10[2];		/* 0A0 */
+	u32 mcast_addr[6], __res11[2];		/* 0C0 */
+	u32 int_clock_threshold, __res12[3];	/* 0E0 */
+	u32 hw_addr[6], __res13[61];		/* 0F0 */
+	u32 core_control;			/* 1FC */
+};
+
+struct port {
+	struct resource *mem_res;
+	struct eth_regs __iomem *regs;
+	struct npe *npe;
+	struct net_device *netdev;
+	struct net_device_stats stat;
+	struct mii_if_info mii;
+	struct delayed_work mdio_thread;
+	struct mac_plat_info *plat;
+	struct sk_buff *rx_skb_tab[PKT_DESCS];
+	struct desc *rx_desc_tab; /* coherent */
+	int id;			/* logical port ID */
+	u32 rx_desc_tab_phys;
+	u32 msg_enable;
+};
+
+/* NPE message structure */
+struct msg {
+	union {
+		struct {
+			u8 cmd, eth_id, mac[ETH_ALEN];
+		};
+		struct {
+			u8 cmd, eth_id, __byte2, byte3;
+			u8 __byte4, byte5, __byte6, byte7;
+		};
+		struct {
+			u8 cmd, eth_id, __b2, byte3;
+			u32 data32;
+		};
+	};
+};
+
+/* Ethernet packet descriptor */
+struct desc {
+	u32 next;		/* pointer to next buffer, unused */
+	u16 buf_len;		/* buffer length */
+	u16 pkt_len;		/* packet length */
+	u32 data;		/* pointer to data buffer in RAM */
+	u8 dest_id;
+	u8 src_id;
+	u16 flags;
+	u8 qos;
+	u8 padlen;
+	u16 vlan_tci;
+	u8 dest_mac[ETH_ALEN];
+	u8 src_mac[ETH_ALEN];
+};
+
+
+#define rx_desc_phys(port, n)	((port)->rx_desc_tab_phys +		\
+				 (n) * sizeof(struct desc))
+#define tx_desc_phys(n)		(tx_desc_tab_phys + (n) * sizeof(struct desc))
+
+static spinlock_t mdio_lock;
+static struct eth_regs __iomem *mdio_regs; /* mdio command and status only */
+static struct npe *mdio_npe;
+static int ports_open;
+static struct dma_pool *dma_pool;
+static struct sk_buff *tx_skb_tab[PKT_DESCS];
+static struct desc *tx_desc_tab; /* coherent */
+static u32 tx_desc_tab_phys;
+
+
+static inline void set_regbits(u32 bits, u32 __iomem *reg)
+{
+	__raw_writel(__raw_readl(reg) | bits, reg);
+}
+static inline void clr_regbits(u32 bits, u32 __iomem *reg)
+{
+	__raw_writel(__raw_readl(reg) & ~bits, reg);
+}
+
+
+static u16 mdio_cmd(struct net_device *dev, int phy_id, int location,
+		    int write, u16 cmd)
+{
+	int cycles = 0;
+
+	if (__raw_readl(&mdio_regs->mdio_command[3]) & 0x80) {
+		printk("%s: MII not ready to transmit\n", dev->name);
+		return 0;	/* not ready to transmit */
+	}
+	
+	if (write) {
+		__raw_writel(cmd & 0xFF, &mdio_regs->mdio_command[0]);
+		__raw_writel(cmd >> 8, &mdio_regs->mdio_command[1]);
+	}
+	__raw_writel(((phy_id << 5) | location) & 0xFF,
+		     &mdio_regs->mdio_command[2]);
+	__raw_writel((phy_id >> 3) | (write << 2) | 0x80 /* GO */,
+		     &mdio_regs->mdio_command[3]);
+
+	while ((cycles < MAX_MDIO_RETRIES) &&
+	       (__raw_readl(&mdio_regs->mdio_command[3]) & 0x80)) {
+		udelay(1);
+		cycles++;
+	}
+
+	if (cycles == MAX_MDIO_RETRIES) {
+		printk("%s: MII write failed\n", dev->name);
+		return 0;
+	}
+
+#if DEBUG_MDIO
+	printk(KERN_DEBUG "mdio_cmd() took %i cycles\n", cycles);
+#endif
+
+	if (write)
+		return 0;
+
+	if (__raw_readl(&mdio_regs->mdio_status[3]) & 0x80) {
+		printk("%s: MII read failed\n", dev->name);
+		return 0;
+	}
+
+	return (__raw_readl(&mdio_regs->mdio_status[0]) & 0xFF) |
+		(__raw_readl(&mdio_regs->mdio_status[1]) << 8);
+}
+
+static int mdio_read(struct net_device *dev, int phy_id, int location)
+{
+	unsigned long flags;
+	u16 val;
+
+	spin_lock_irqsave(&mdio_lock, flags);
+	val = mdio_cmd(dev, phy_id, location, 0, 0);
+	spin_unlock_irqrestore(&mdio_lock, flags);
+	return val;
+}
+
+static void mdio_write(struct net_device *dev, int phy_id, int location,
+		       int val)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&mdio_lock, flags);
+	mdio_cmd(dev, phy_id, location, 1, val);
+	spin_unlock_irqrestore(&mdio_lock, flags);
+}
+
+static void eth_set_duplex(struct port *port)
+{
+	if (port->mii.full_duplex)
+		clr_regbits(TX_CNTRL0_HALFDUPLEX, &port->regs->tx_control[0]);
+	else
+		set_regbits(TX_CNTRL0_HALFDUPLEX, &port->regs->tx_control[0]);
+}
+
+
+static void mdio_thread(struct work_struct *work)
+{
+	struct port *port = container_of(work, struct port, mdio_thread.work);
+
+	if (mii_check_media(&port->mii, 1, 0))
+		eth_set_duplex(port);
+	schedule_delayed_work(&port->mdio_thread, MDIO_INTERVAL);
+}
+
+
+static inline void debug_skb(const char *func, struct sk_buff *skb)
+{
+#if DEBUG_PKT_BYTES
+	int i;
+
+	printk(KERN_DEBUG "%s(%i): ", func, skb->len);
+	for (i = 0; i < skb->len; i++) {
+		if (i >= DEBUG_PKT_BYTES)
+			break;
+		printk("%s%02X",
+		       ((i == 6) || (i == 12) || (i >= 14)) ? " " : "",
+		       skb->data[i]);
+	}
+	printk("\n");
+#endif
+}
+
+
+static inline void debug_desc(unsigned int queue, u32 desc_phys,
+			      struct desc *desc, int is_get)
+{
+#if DEBUG_QUEUES
+	const char *op = is_get ? "->" : "<-";
+
+	if (!desc_phys) {
+		printk(KERN_DEBUG "queue %2i %s NULL\n", queue, op);
+		return;
+	}
+	printk(KERN_DEBUG "queue %2i %s %X: %X %3X %3X %08X %2X < %2X %4X %X"
+	       " %X %X %02X%02X%02X%02X%02X%02X < %02X%02X%02X%02X%02X%02X\n",
+	       queue, op, desc_phys, desc->next, desc->buf_len, desc->pkt_len,
+	       desc->data, desc->dest_id, desc->src_id,
+	       desc->flags, desc->qos,
+	       desc->padlen, desc->vlan_tci,
+	       desc->dest_mac[0], desc->dest_mac[1],
+	       desc->dest_mac[2], desc->dest_mac[3],
+	       desc->dest_mac[4], desc->dest_mac[5],
+	       desc->src_mac[0], desc->src_mac[1],
+	       desc->src_mac[2], desc->src_mac[3],
+	       desc->src_mac[4], desc->src_mac[5]);
+#endif
+}
+
+static inline int queue_get_desc(unsigned int queue, struct port *port,
+				 int is_tx)
+{
+	u32 phys, tab_phys, n_desc;
+	struct desc *tab;
+
+	if (!(phys = qmgr_get_entry(queue))) {
+		debug_desc(queue, phys, NULL, 1);
+		return -1;
+	}
+
+	phys &= ~0x1F; /* mask out non-address bits */
+	tab_phys = is_tx ? tx_desc_phys(0) : rx_desc_phys(port, 0);
+	tab = is_tx ? tx_desc_tab : port->rx_desc_tab;
+	n_desc = (phys - tab_phys) / sizeof(struct desc);
+	BUG_ON(n_desc >= PKT_DESCS);
+
+	debug_desc(queue, phys, &tab[n_desc], 1);
+	BUG_ON(tab[n_desc].next);
+	return n_desc;
+}
+
+static inline void queue_put_desc(unsigned int queue, u32 desc_phys,
+				  struct desc *desc)
+{
+	debug_desc(queue, desc_phys, desc, 0);
+	BUG_ON(desc_phys & 0x1F);
+	qmgr_put_entry(queue, desc_phys);
+}
+
+
+static void eth_rx_irq(void *pdev)
+{
+	struct net_device *dev = pdev;
+	struct port *port = netdev_priv(dev);
+
+#if DEBUG_RX
+	printk(KERN_DEBUG "eth_rx_irq() start\n");
+#endif
+	qmgr_disable_irq(port->plat->rxq);
+	netif_rx_schedule(dev);
+}
+
+static int eth_poll(struct net_device *dev, int *budget)
+{
+	struct port *port = netdev_priv(dev);
+	unsigned int queue = port->plat->rxq;
+	int quota = dev->quota, received = 0;
+
+#if DEBUG_RX
+	printk(KERN_DEBUG "eth_poll() start\n");
+#endif
+	while (quota) {
+		struct sk_buff *old_skb, *new_skb;
+		struct desc *desc;
+		u32 data;
+		int n = queue_get_desc(queue, port, 0);
+		if (n < 0) {	/* No packets received */
+			dev->quota -= received;
+			*budget -= received;
+			received = 0;
+			netif_rx_complete(dev);
+			qmgr_enable_irq(queue);
+			if (!qmgr_stat_empty(queue) &&
+			    netif_rx_reschedule(dev, 0)) {
+				qmgr_disable_irq(queue);
+				continue;
+			}
+			return 0; /* all work done */
+		}
+
+		desc = &port->rx_desc_tab[n];
+
+		if ((new_skb = netdev_alloc_skb(dev, MAX_MRU)) != NULL) {
+#if 0
+			skb_reserve(new_skb, 2);  /* FIXME */
+#endif
+			data = dma_map_single(&dev->dev, new_skb->data,
+					      MAX_MRU, DMA_FROM_DEVICE);
+		}
+
+		if (!new_skb || dma_mapping_error(data)) {
+			if (new_skb)
+				dev_kfree_skb(new_skb);
+			port->stat.rx_dropped++;
+			/* put the desc back on RX-ready queue */
+			desc->buf_len = MAX_MRU;
+			desc->pkt_len = 0;
+			queue_put_desc(RXFREE_QUEUE(port->plat),
+				       rx_desc_phys(port, n), desc);
+			BUG_ON(qmgr_stat_overflow(RXFREE_QUEUE(port->plat)));
+			continue;
+		}
+
+		/* process received skb */
+		old_skb = port->rx_skb_tab[n];
+		dma_unmap_single(&dev->dev, desc->data,
+				 MAX_MRU, DMA_FROM_DEVICE);
+		skb_put(old_skb, desc->pkt_len);
+
+		debug_skb("eth_poll", old_skb);
+
+		old_skb->protocol = eth_type_trans(old_skb, dev);
+		dev->last_rx = jiffies;
+		port->stat.rx_packets++;
+		port->stat.rx_bytes += old_skb->len;
+		netif_receive_skb(old_skb);
+
+		/* put the new skb on RX-free queue */
+		port->rx_skb_tab[n] = new_skb;
+		desc->buf_len = MAX_MRU;
+		desc->pkt_len = 0;
+		desc->data = data;
+		queue_put_desc(RXFREE_QUEUE(port->plat),
+			       rx_desc_phys(port, n), desc);
+		BUG_ON(qmgr_stat_overflow(RXFREE_QUEUE(port->plat)));
+		quota--;
+		received++;
+	}
+	dev->quota -= received;
+	*budget -= received;
+	return 1;		/* not all work done */
+}
+
+static void eth_xmit_ready_irq(void *pdev)
+{
+	struct net_device *dev = pdev;
+
+#if DEBUG_TX
+	printk(KERN_DEBUG "eth_xmit_empty() start\n");
+#endif
+	netif_start_queue(dev);
+}
+
+static int eth_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct port *port = netdev_priv(dev);
+	struct desc *desc;
+	u32 phys;
+	struct sk_buff *old_skb;
+	int n;
+
+#if DEBUG_TX
+	printk(KERN_DEBUG "eth_xmit() start\n");
+#endif
+	if (unlikely(skb->len > MAX_MRU)) {
+		dev_kfree_skb(skb);
+		port->stat.tx_errors++;
+		return NETDEV_TX_OK;
+	}
+
+	n = queue_get_desc(TXDONE_QUEUE, port, 1);
+	BUG_ON(n < 0);
+	desc = &tx_desc_tab[n];
+	phys = tx_desc_phys(n);
+
+	if ((old_skb = tx_skb_tab[n]) != NULL) {
+		dma_unmap_single(&dev->dev, desc->data,
+				 desc->buf_len, DMA_TO_DEVICE);
+		port->stat.tx_packets++;
+		port->stat.tx_bytes += old_skb->len;
+		dev_kfree_skb(old_skb);
+	}
+
+	/* disable VLAN functions in NPE image for now */
+	memset(desc, 0, sizeof(*desc));
+	desc->buf_len = desc->pkt_len = skb->len;
+	desc->data = dma_map_single(&dev->dev, skb->data,
+				    skb->len, DMA_TO_DEVICE);
+	if (dma_mapping_error(desc->data)) {
+		desc->data = 0;
+		dev_kfree_skb(skb);
+		tx_skb_tab[n] = NULL;
+		port->stat.tx_dropped++;
+		/* put the desc back on TX-done queue */
+		queue_put_desc(TXDONE_QUEUE, phys, desc);
+		return 0;
+	}
+
+	tx_skb_tab[n] = skb;
+	debug_skb("eth_xmit", skb);
+
+	/* NPE firmware pads short frames with zeros internally */
+	wmb();
+	queue_put_desc(TX_QUEUE(port->plat), phys, desc);
+	BUG_ON(qmgr_stat_overflow(TX_QUEUE(port->plat)));
+	dev->trans_start = jiffies;
+
+	if (qmgr_stat_full(TX_QUEUE(port->plat))) {
+		netif_stop_queue(dev);
+		/* we could miss TX ready interrupt */
+		if (!qmgr_stat_full(TX_QUEUE(port->plat))) {
+			netif_start_queue(dev);
+		}
+	}
+
+#if DEBUG_TX
+	printk(KERN_DEBUG "eth_xmit() end\n");
+#endif
+	return NETDEV_TX_OK;
+}
+
+
+static struct net_device_stats *eth_stats(struct net_device *dev)
+{
+	struct port *port = netdev_priv(dev);
+	return &port->stat;
+}
+
+static void eth_set_mcast_list(struct net_device *dev)
+{
+	struct port *port = netdev_priv(dev);
+	struct dev_mc_list *mclist = dev->mc_list;
+	u8 diffs[ETH_ALEN], *addr;
+	int cnt = dev->mc_count, i;
+
+	if ((dev->flags & IFF_PROMISC) || !mclist || !cnt) {
+		clr_regbits(RX_CNTRL0_ADDR_FLTR_EN,
+			    &port->regs->rx_control[0]);
+		return;
+	}
+
+	memset(diffs, 0, ETH_ALEN);
+	addr = mclist->dmi_addr; /* first MAC address */
+
+	while (--cnt && (mclist = mclist->next))
+		for (i = 0; i < ETH_ALEN; i++)
+			diffs[i] |= addr[i] ^ mclist->dmi_addr[i];
+
+	for (i = 0; i < ETH_ALEN; i++) {
+		__raw_writel(addr[i], &port->regs->mcast_addr[i]);
+		__raw_writel(~diffs[i], &port->regs->mcast_mask[i]);
+	}
+
+	set_regbits(RX_CNTRL0_ADDR_FLTR_EN, &port->regs->rx_control[0]);
+}
+
+
+static int eth_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
+{
+	struct port *port = netdev_priv(dev);
+	unsigned int duplex_chg;
+	int err;
+
+	if (!netif_running(dev))
+		return -EINVAL;
+	err = generic_mii_ioctl(&port->mii, if_mii(req), cmd, &duplex_chg);
+	if (duplex_chg)
+		eth_set_duplex(port);
+	return err;
+}
+
+
+static int request_queues(struct port *port)
+{
+	int err;
+
+	err = qmgr_request_queue(RXFREE_QUEUE(port->plat), PKT_DESCS, 0, 0);
+	if (err)
+		return err;
+
+	err = qmgr_request_queue(port->plat->rxq, PKT_DESCS, 0, 0);
+	if (err)
+		goto rel_rxfree;
+
+	err = qmgr_request_queue(TX_QUEUE(port->plat), TX_QUEUE_LEN, 0, 0);
+	if (err)
+		goto rel_rx;
+
+	/* TX-done queue handles skbs sent out by the NPEs */
+	if (!ports_open) {
+		err = qmgr_request_queue(TXDONE_QUEUE, PKT_DESCS, 0, 0);
+		if (err)
+			goto rel_tx;
+	}
+	return 0;
+
+rel_tx:
+	qmgr_release_queue(TX_QUEUE(port->plat));
+rel_rx:
+	qmgr_release_queue(port->plat->rxq);
+rel_rxfree:
+	qmgr_release_queue(RXFREE_QUEUE(port->plat));
+	return err;
+}
+
+static void release_queues(struct port *port)
+{
+	qmgr_release_queue(RXFREE_QUEUE(port->plat));
+	qmgr_release_queue(port->plat->rxq);
+	qmgr_release_queue(TX_QUEUE(port->plat));
+
+	if (!ports_open)
+		qmgr_release_queue(TXDONE_QUEUE);
+}
+
+static int init_queues(struct port *port)
+{
+	int i;
+
+	if (!dma_pool) {
+		/* Setup TX descriptors - common to all ports */
+		dma_pool = dma_pool_create(DRV_NAME, NULL, POOL_ALLOC_SIZE,
+					   32, 0);
+		if (!dma_pool)
+			return -ENOMEM;
+
+		if (!(tx_desc_tab = dma_pool_alloc(dma_pool, GFP_KERNEL,
+						   &tx_desc_tab_phys)))
+			return -ENOMEM;
+		memset(tx_desc_tab, 0, POOL_ALLOC_SIZE);
+		memset(tx_skb_tab, 0, sizeof(tx_skb_tab)); /* static table */
+
+		for (i = 0; i < PKT_DESCS; i++) {
+			queue_put_desc(TXDONE_QUEUE, tx_desc_phys(i),
+				       &tx_desc_tab[i]);
+			BUG_ON(qmgr_stat_overflow(TXDONE_QUEUE));
+		}
+	}
+
+	/* Setup RX buffers */
+	if (!(port->rx_desc_tab = dma_pool_alloc(dma_pool, GFP_KERNEL,
+						 &port->rx_desc_tab_phys)))
+		return -ENOMEM;
+	memset(port->rx_desc_tab, 0, POOL_ALLOC_SIZE);
+	memset(port->rx_skb_tab, 0, sizeof(port->rx_skb_tab)); /* table */
+
+	for (i = 0; i < PKT_DESCS; i++) {
+		struct desc *desc = &port->rx_desc_tab[i];
+		struct sk_buff *skb;
+
+		if (!(skb = netdev_alloc_skb(port->netdev, MAX_MRU)))
+			return -ENOMEM;
+		port->rx_skb_tab[i] = skb;
+		desc->buf_len = MAX_MRU;
+#if 0
+		skb_reserve(skb, 2);  /* FIXME */
+#endif
+		desc->data = dma_map_single(&port->netdev->dev, skb->data,
+					    MAX_MRU, DMA_FROM_DEVICE);
+		if (dma_mapping_error(desc->data)) {
+			desc->data = 0;
+			return -EIO;
+		}
+		queue_put_desc(RXFREE_QUEUE(port->plat),
+			       rx_desc_phys(port, i), desc);
+		BUG_ON(qmgr_stat_overflow(RXFREE_QUEUE(port->plat)));
+	}
+	return 0;
+}
+
+static void destroy_queues(struct port *port)
+{
+	int i;
+
+	while (queue_get_desc(RXFREE_QUEUE(port->plat), port, 0) >= 0)
+		/* nothing to do here */;
+	while (queue_get_desc(port->plat->rxq, port, 0) >= 0)
+		/* nothing to do here */;
+	while (queue_get_desc(TX_QUEUE(port->plat), port, 1) >= 0) {
+		/* nothing to do here */;
+	}
+	if (!ports_open)
+		while (queue_get_desc(TXDONE_QUEUE, port, 1) >= 0)
+			/* nothing to do here */;
+
+	if (port->rx_desc_tab) {
+		for (i = 0; i < PKT_DESCS; i++) {
+			struct desc *desc = &port->rx_desc_tab[i];
+			struct sk_buff *skb = port->rx_skb_tab[i];
+			if (skb) {
+				if (desc->data)
+					dma_unmap_single(&port->netdev->dev,
+							 desc->data, MAX_MRU,
+							 DMA_FROM_DEVICE);
+				dev_kfree_skb(skb);
+			}
+		}
+		dma_pool_free(dma_pool, port->rx_desc_tab,
+			      port->rx_desc_tab_phys);
+		port->rx_desc_tab = NULL;
+	}
+
+	if (!ports_open && tx_desc_tab) {
+		for (i = 0; i < PKT_DESCS; i++) {
+			struct desc *desc = &tx_desc_tab[i];
+			struct sk_buff *skb = tx_skb_tab[i];
+			if (skb) {
+				if (desc->data)
+					dma_unmap_single(&port->netdev->dev,
+							 desc->data,
+							 desc->buf_len,
+							 DMA_TO_DEVICE);
+				dev_kfree_skb(skb);
+			}
+		}
+		dma_pool_free(dma_pool, tx_desc_tab, tx_desc_tab_phys);
+		tx_desc_tab = NULL;
+	}
+	if (!ports_open && dma_pool) {
+		dma_pool_destroy(dma_pool);
+		dma_pool = NULL;
+	}
+}
+
+static int eth_load_firmware(struct net_device *dev, struct npe *npe)
+{
+	struct msg msg;
+	int err;
+
+	if ((err = npe_load_firmware(npe, npe_name(npe), &dev->dev)) != 0)
+		return err;
+
+	if ((err = npe_recv_message(npe, &msg, "ETH_GET_STATUS")) != 0) {
+		printk(KERN_ERR "%s: %s not responding\n", dev->name,
+		       npe_name(npe));
+		return err;
+	}
+	return 0;
+}
+
+static int eth_open(struct net_device *dev)
+{
+	struct port *port = netdev_priv(dev);
+	struct npe *npe = port->npe;
+	struct msg msg;
+	int i, err;
+
+	if (!npe_running(npe))
+		if (eth_load_firmware(dev, npe))
+			return -EIO;
+
+	if (!npe_running(mdio_npe))
+		if (eth_load_firmware(dev, mdio_npe))
+			return -EIO;
+
+	memset(&msg, 0, sizeof(msg));
+	msg.cmd = NPE_VLAN_SETRXQOSENTRY;
+	msg.eth_id = port->id;
+	msg.byte5 = port->plat->rxq | 0x80;
+	msg.byte7 = port->plat->rxq << 4;
+	for (i = 0; i < 8; i++) {
+		msg.byte3 = i;
+		if (npe_send_recv_message(port->npe, &msg, "ETH_SET_RXQ"))
+			return -EIO;
+	}
+
+	msg.cmd = NPE_EDB_SETPORTADDRESS;
+	msg.eth_id = PHYSICAL_ID(port);
+	memcpy(msg.mac, dev->dev_addr, ETH_ALEN);
+	if (npe_send_recv_message(port->npe, &msg, "ETH_SET_MAC"))
+		return -EIO;
+
+	memset(&msg, 0, sizeof(msg));
+	msg.cmd = NPE_FW_SETFIREWALLMODE;
+	msg.eth_id = port->id;
+	if (npe_send_recv_message(port->npe, &msg, "ETH_SET_FIREWALL_MODE"))
+		return -EIO;
+
+	if ((err = request_queues(port)) != 0)
+		return err;
+
+	if ((err = init_queues(port)) != 0) {
+		destroy_queues(port);
+		release_queues(port);
+		return err;
+	}
+
+	for (i = 0; i < ETH_ALEN; i++)
+		__raw_writel(dev->dev_addr[i], &port->regs->hw_addr[i]);
+	__raw_writel(0x08, &port->regs->random_seed);
+	__raw_writel(0x12, &port->regs->partial_empty_threshold);
+	__raw_writel(0x30, &port->regs->partial_full_threshold);
+	__raw_writel(0x08, &port->regs->tx_start_bytes);
+	__raw_writel(0x15, &port->regs->tx_deferral);
+	__raw_writel(0x08, &port->regs->tx_2part_deferral[0]);
+	__raw_writel(0x07, &port->regs->tx_2part_deferral[1]);
+	__raw_writel(0x80, &port->regs->slot_time);
+	__raw_writel(0x01, &port->regs->int_clock_threshold);
+	__raw_writel(TX_CNTRL1_RETRIES, &port->regs->tx_control[1]);
+	__raw_writel(TX_CNTRL0_TX_EN | TX_CNTRL0_RETRY | TX_CNTRL0_PAD_EN |
+		     TX_CNTRL0_APPEND_FCS | TX_CNTRL0_2DEFER,
+		     &port->regs->tx_control[0]);
+	__raw_writel(0, &port->regs->rx_control[1]);
+	__raw_writel(RX_CNTRL0_RX_EN | RX_CNTRL0_PADSTRIP_EN,
+		     &port->regs->rx_control[0]);
+
+	if (mii_check_media(&port->mii, 1, 1))
+		eth_set_duplex(port);
+	eth_set_mcast_list(dev);
+	netif_start_queue(dev);
+	schedule_delayed_work(&port->mdio_thread, MDIO_INTERVAL);
+
+	qmgr_set_irq(port->plat->rxq, QUEUE_IRQ_SRC_NOT_EMPTY,
+		     eth_rx_irq, dev);
+	qmgr_set_irq(TX_QUEUE(port->plat), QUEUE_IRQ_SRC_NOT_FULL,
+		     eth_xmit_ready_irq, dev);
+	qmgr_enable_irq(port->plat->rxq);
+	qmgr_enable_irq(TX_QUEUE(port->plat));
+	ports_open++;
+	return 0;
+}
+
+static int eth_close(struct net_device *dev)
+{
+	struct port *port = netdev_priv(dev);
+
+	ports_open--;
+	qmgr_disable_irq(port->plat->rxq);
+	qmgr_disable_irq(TX_QUEUE(port->plat));
+	netif_stop_queue(dev);
+
+	clr_regbits(RX_CNTRL0_RX_EN, &port->regs->rx_control[0]);
+	clr_regbits(TX_CNTRL0_TX_EN, &port->regs->tx_control[0]);
+	set_regbits(CORE_RESET | CORE_RX_FIFO_FLUSH | CORE_TX_FIFO_FLUSH,
+		    &port->regs->core_control);
+	udelay(10);
+	clr_regbits(CORE_RESET | CORE_RX_FIFO_FLUSH | CORE_TX_FIFO_FLUSH,
+		    &port->regs->core_control);
+
+	cancel_rearming_delayed_work(&port->mdio_thread);
+	destroy_queues(port);
+	release_queues(port);
+	return 0;
+}
+
+static int __devinit eth_init_one(struct platform_device *pdev)
+{
+	struct port *port;
+	struct net_device *dev;
+	struct mac_plat_info *plat = pdev->dev.platform_data;
+	u32 regs_phys;
+	int err;
+
+	if (!(dev = alloc_etherdev(sizeof(struct port))))
+		return -ENOMEM;
+
+	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+	port = netdev_priv(dev);
+	port->netdev = dev;
+	port->id = pdev->id;
+
+	switch (port->id) {
+	case IXP4XX_ETH_NPEA:
+		port->regs = (struct eth_regs __iomem *)IXP4XX_EthA_BASE_VIRT;
+		regs_phys  = IXP4XX_EthA_BASE_PHYS;
+		break;
+	case IXP4XX_ETH_NPEB:
+		port->regs = (struct eth_regs __iomem *)IXP4XX_EthB_BASE_VIRT;
+		regs_phys  = IXP4XX_EthB_BASE_PHYS;
+		break;
+	case IXP4XX_ETH_NPEC:
+		port->regs = (struct eth_regs __iomem *)IXP4XX_EthC_BASE_VIRT;
+		regs_phys  = IXP4XX_EthC_BASE_PHYS;
+		break;
+	default:
+		err = -ENOSYS;
+		goto err_free;
+	}
+
+	dev->open = eth_open;
+	dev->hard_start_xmit = eth_xmit;
+	dev->poll = eth_poll;
+	dev->stop = eth_close;
+	dev->get_stats = eth_stats;
+	dev->do_ioctl = eth_ioctl;
+	dev->set_multicast_list = eth_set_mcast_list;
+	dev->weight = 16;
+	dev->tx_queue_len = 100;
+
+	if (!(port->npe = npe_request(NPE_ID(port)))) {
+		err = -EIO;
+		goto err_free;
+	}
+
+	if (register_netdev(dev)) {
+		err = -EIO;
+		goto err_npe_rel;
+	}
+
+	port->mem_res = request_mem_region(regs_phys, REGS_SIZE, dev->name);
+	if (!port->mem_res) {
+		err = -EBUSY;
+		goto err_unreg;
+	}
+
+	port->plat = plat;
+	memcpy(dev->dev_addr, plat->hwaddr, ETH_ALEN);
+
+	platform_set_drvdata(pdev, dev);
+
+	__raw_writel(CORE_RESET, &port->regs->core_control);
+	udelay(50);
+	__raw_writel(CORE_MDC_EN, &port->regs->core_control);
+	udelay(50);
+
+	port->mii.dev = dev;
+	port->mii.mdio_read = mdio_read;
+	port->mii.mdio_write = mdio_write;
+	port->mii.phy_id = plat->phy;
+	port->mii.phy_id_mask = 0x1F;
+	port->mii.reg_num_mask = 0x1F;
+
+	INIT_DELAYED_WORK(&port->mdio_thread, mdio_thread);
+
+	printk(KERN_INFO "%s: MII PHY %i on %s\n", dev->name, plat->phy,
+	       npe_name(port->npe));
+	return 0;
+
+err_unreg:
+	unregister_netdev(dev);
+err_npe_rel:
+	npe_release(port->npe);
+err_free:
+	free_netdev(dev);
+	return err;
+}
+
+static int __devexit eth_remove_one(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct port *port = netdev_priv(dev);
+
+	unregister_netdev(dev);
+	platform_set_drvdata(pdev, NULL);
+	npe_release(port->npe);
+	release_resource(port->mem_res);
+	free_netdev(dev);
+	return 0;
+}
+
+static struct platform_driver drv = {
+	.driver.name	= DRV_NAME,
+	.probe		= eth_init_one,
+	.remove		= eth_remove_one,
+};
+
+static int __init eth_init_module(void)
+{
+	if (!(ixp4xx_read_fuses() & IXP4XX_FUSE_NPEB_ETH0))
+		return -ENOSYS;
+
+	/* All MII PHY accesses use NPE-B Ethernet registers */
+	if (!(mdio_npe = npe_request(1)))
+		return -EIO;
+	spin_lock_init(&mdio_lock);
+	mdio_regs = (struct eth_regs __iomem *)IXP4XX_EthB_BASE_VIRT;
+
+	return platform_driver_register(&drv);
+}
+
+static void __exit eth_cleanup_module(void)
+{
+	platform_driver_unregister(&drv);
+	npe_release(mdio_npe);
+}
+
+MODULE_AUTHOR("Krzysztof Halasa");
+MODULE_DESCRIPTION("Intel IXP4xx Ethernet driver");
+MODULE_LICENSE("GPL v2");
+module_init(eth_init_module);
+module_exit(eth_cleanup_module);
diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index 5f79622..b891e10 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -342,6 +342,16 @@ config DSCC4_PCI_RST
 
 	  Say Y if your card supports this feature.
 
+config IXP4XX_HSS
+	tristate "IXP4xx HSS (synchronous serial port) support"
+	depends on ARM && ARCH_IXP4XX
+	select IXP4XX_NPE
+	select IXP4XX_QMGR
+	select HDLC
+	help
+	  Say Y here if you want to use built-in HSS ports
+	  on IXP4xx processor.
+
 config DLCI
 	tristate "Frame Relay DLCI support"
 	---help---
diff --git a/drivers/net/wan/Makefile b/drivers/net/wan/Makefile
index d61fef3..1b1d116 100644
--- a/drivers/net/wan/Makefile
+++ b/drivers/net/wan/Makefile
@@ -42,6 +42,7 @@ obj-$(CONFIG_C101)		+= c101.o
 obj-$(CONFIG_WANXL)		+= wanxl.o
 obj-$(CONFIG_PCI200SYN)		+= pci200syn.o
 obj-$(CONFIG_PC300TOO)		+= pc300too.o
+obj-$(CONFIG_IXP4XX_HSS)	+= ixp4xx_hss.o
 
 clean-files := wanxlfw.inc
 $(obj)/wanxl.o:	$(obj)/wanxlfw.inc
diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
new file mode 100644
index 0000000..ed56ed8
--- /dev/null
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -0,0 +1,1048 @@
+/*
+ * Intel IXP4xx HSS (synchronous serial port) driver for Linux
+ *
+ * Copyright (C) 2007 Krzysztof Halasa <khc@pm.waw.pl>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ */
+
+#include <linux/dma-mapping.h>
+#include <linux/dmapool.h>
+#include <linux/kernel.h>
+#include <linux/hdlc.h>
+#include <linux/platform_device.h>
+#include <asm/io.h>
+#include <asm/arch/npe.h>
+#include <asm/arch/qmgr.h>
+
+#ifndef __ARMEB__
+#warning Little endian mode not supported
+#endif
+
+#define DEBUG_QUEUES		0
+#define DEBUG_RX		0
+#define DEBUG_TX		0
+
+#define DRV_NAME		"ixp4xx_hss"
+#define DRV_VERSION		"0.03"
+
+#define PKT_EXTRA_FLAGS		0 /* orig 1 */
+#define FRAME_SYNC_OFFSET	0 /* unused, channelized only */
+#define FRAME_SYNC_SIZE		1024
+#define PKT_NUM_PIPES		1 /* 1, 2 or 4 */
+#define PKT_PIPE_FIFO_SIZEW	4 /* total 4 dwords per HSS */
+
+#define RX_DESCS		16 /* also length of queues: RX-ready, RX */
+#define TX_DESCS		16 /* also length of queues: TX-done, TX */
+
+#define POOL_ALLOC_SIZE		(sizeof(struct desc) * (RX_DESCS + TX_DESCS))
+#define RX_SIZE			(HDLC_MAX_MRU + 4) /* NPE needs more space */
+
+/* Queue IDs */
+#define HSS0_CHL_RXTRIG_QUEUE	12	/* orig size = 32 dwords */
+#define HSS0_PKT_RX_QUEUE	13	/* orig size = 32 dwords */
+#define HSS0_PKT_TX0_QUEUE	14	/* orig size = 16 dwords */
+#define HSS0_PKT_TX1_QUEUE	15
+#define HSS0_PKT_TX2_QUEUE	16
+#define HSS0_PKT_TX3_QUEUE	17
+#define HSS0_PKT_RXFREE0_QUEUE	18	/* orig size = 16 dwords */
+#define HSS0_PKT_RXFREE1_QUEUE	19
+#define HSS0_PKT_RXFREE2_QUEUE	20
+#define HSS0_PKT_RXFREE3_QUEUE	21
+#define HSS0_PKT_TXDONE_QUEUE	22	/* orig size = 64 dwords */
+
+#define HSS1_CHL_RXTRIG_QUEUE	10
+#define HSS1_PKT_RX_QUEUE	0
+#define HSS1_PKT_TX0_QUEUE	5
+#define HSS1_PKT_TX1_QUEUE	6
+#define HSS1_PKT_TX2_QUEUE	7
+#define HSS1_PKT_TX3_QUEUE	8
+#define HSS1_PKT_RXFREE0_QUEUE	1
+#define HSS1_PKT_RXFREE1_QUEUE	2
+#define HSS1_PKT_RXFREE2_QUEUE	3
+#define HSS1_PKT_RXFREE3_QUEUE	4
+#define HSS1_PKT_TXDONE_QUEUE	9
+
+#define NPE_PKT_MODE_HDLC		0
+#define NPE_PKT_MODE_RAW		1
+#define NPE_PKT_MODE_56KMODE		2
+#define NPE_PKT_MODE_56KENDIAN_MSB	4
+
+/* PKT_PIPE_HDLC_CFG_WRITE flags */
+#define PKT_HDLC_IDLE_ONES		0x1 /* default = flags */
+#define PKT_HDLC_CRC_32			0x2 /* default = CRC-16 */
+#define PKT_HDLC_MSB_ENDIAN		0x4 /* default = LE */
+
+
+/* hss_config, PCRs */
+/* Frame sync sampling, default = active low */
+#define PCR_FRM_SYNC_ACTIVE_HIGH	0x40000000
+#define PCR_FRM_SYNC_FALLINGEDGE	0x80000000
+#define PCR_FRM_SYNC_RISINGEDGE		0xC0000000
+
+/* Frame sync pin: input (default) or output generated off a given clk edge */
+#define PCR_FRM_SYNC_OUTPUT_FALLING	0x20000000
+#define PCR_FRM_SYNC_OUTPUT_RISING	0x30000000
+
+/* Frame and data clock sampling on edge, default = falling */
+#define PCR_FCLK_EDGE_RISING		0x08000000
+#define PCR_DCLK_EDGE_RISING		0x04000000
+
+/* Clock direction, default = input */
+#define PCR_SYNC_CLK_DIR_OUTPUT		0x02000000
+
+/* Generate/Receive frame pulses, default = enabled */
+#define PCR_FRM_PULSE_DISABLED		0x01000000
+
+ /* Data rate is full (default) or half the configured clk speed */
+#define PCR_HALF_CLK_RATE		0x00200000
+
+/* Invert data between NPE and HSS FIFOs? (default = no) */
+#define PCR_DATA_POLARITY_INVERT	0x00100000
+
+/* TX/RX endianness, default = LSB */
+#define PCR_MSB_ENDIAN			0x00080000
+
+/* Normal (default) / open drain mode (TX only) */
+#define PCR_TX_PINS_OPEN_DRAIN		0x00040000
+
+/* No framing bit transmitted and expected on RX? (default = framing bit) */
+#define PCR_SOF_NO_FBIT			0x00020000
+
+/* Drive data pins? */
+#define PCR_TX_DATA_ENABLE		0x00010000
+
+/* Voice 56k type: drive the data pins low (default), high, high Z */
+#define PCR_TX_V56K_HIGH		0x00002000
+#define PCR_TX_V56K_HIGH_IMP		0x00004000
+
+/* Unassigned type: drive the data pins low (default), high, high Z */
+#define PCR_TX_UNASS_HIGH		0x00000800
+#define PCR_TX_UNASS_HIGH_IMP		0x00001000
+
+/* T1 @ 1.544MHz only: Fbit dictated in FIFO (default) or high Z */
+#define PCR_TX_FB_HIGH_IMP		0x00000400
+
+/* 56k data endiannes - which bit unused: high (default) or low */
+#define PCR_TX_56KE_BIT_0_UNUSED	0x00000200
+
+/* 56k data transmission type: 32/8 bit data (default) or 56K data */
+#define PCR_TX_56KS_56K_DATA		0x00000100
+
+/* hss_config, cCR */
+/* Number of packetized clients, default = 1 */
+#define CCR_NPE_HFIFO_2_HDLC		0x04000000
+#define CCR_NPE_HFIFO_3_OR_4HDLC	0x08000000
+
+/* default = no loopback */
+#define CCR_LOOPBACK			0x02000000
+
+/* HSS number, default = 0 (first) */
+#define CCR_SECOND_HSS			0x01000000
+
+
+/* hss_config, clkCR: main:10, num:10, denom:12 */
+#define CLK42X_SPEED_EXP	((0x3FF << 22) | (  2 << 12) |   15) /*65 KHz*/
+
+#define CLK42X_SPEED_512KHZ	((  130 << 22) | (  2 << 12) |   15)
+#define CLK42X_SPEED_1536KHZ	((   43 << 22) | ( 18 << 12) |   47)
+#define CLK42X_SPEED_1544KHZ	((   43 << 22) | ( 33 << 12) |  192)
+#define CLK42X_SPEED_2048KHZ	((   32 << 22) | ( 34 << 12) |   63)
+#define CLK42X_SPEED_4096KHZ	((   16 << 22) | ( 34 << 12) |  127)
+#define CLK42X_SPEED_8192KHZ	((    8 << 22) | ( 34 << 12) |  255)
+
+#define CLK46X_SPEED_512KHZ	((  130 << 22) | ( 24 << 12) |  127)
+#define CLK46X_SPEED_1536KHZ	((   43 << 22) | (152 << 12) |  383)
+#define CLK46X_SPEED_1544KHZ	((   43 << 22) | ( 66 << 12) |  385)
+#define CLK46X_SPEED_2048KHZ	((   32 << 22) | (280 << 12) |  511)
+#define CLK46X_SPEED_4096KHZ	((   16 << 22) | (280 << 12) | 1023)
+#define CLK46X_SPEED_8192KHZ	((    8 << 22) | (280 << 12) | 2047)
+
+
+/* hss_config, LUTs: default = unassigned */
+#define TDMMAP_HDLC		1	/* HDLC - packetised */
+#define TDMMAP_VOICE56K		2	/* Voice56K - channelised */
+#define TDMMAP_VOICE64K		3	/* Voice64K - channelised */
+
+
+/* NPE command codes */
+/* writes the ConfigWord value to the location specified by offset */
+#define PORT_CONFIG_WRITE			0x40
+
+/* triggers the NPE to load the contents of the configuration table */
+#define PORT_CONFIG_LOAD			0x41
+
+/* triggers the NPE to return an HssErrorReadResponse message */
+#define PORT_ERROR_READ				0x42
+
+/* reset NPE internal status and enable the HssChannelized operation */
+#define CHAN_FLOW_ENABLE			0x43
+#define CHAN_FLOW_DISABLE			0x44
+#define CHAN_IDLE_PATTERN_WRITE			0x45
+#define CHAN_NUM_CHANS_WRITE			0x46
+#define CHAN_RX_BUF_ADDR_WRITE			0x47
+#define CHAN_RX_BUF_CFG_WRITE			0x48
+#define CHAN_TX_BLK_CFG_WRITE			0x49
+#define CHAN_TX_BUF_ADDR_WRITE			0x4A
+#define CHAN_TX_BUF_SIZE_WRITE			0x4B
+#define CHAN_TSLOTSWITCH_ENABLE			0x4C
+#define CHAN_TSLOTSWITCH_DISABLE		0x4D
+
+/* downloads the gainWord value for a timeslot switching channel associated
+   with bypassNum */
+#define CHAN_TSLOTSWITCH_GCT_DOWNLOAD		0x4E
+
+/* triggers the NPE to reset internal status and enable the HssPacketized
+   operation for the flow specified by pPipe */
+#define PKT_PIPE_FLOW_ENABLE			0x50
+#define PKT_PIPE_FLOW_DISABLE			0x51
+#define PKT_NUM_PIPES_WRITE			0x52
+#define PKT_PIPE_FIFO_SIZEW_WRITE		0x53
+#define PKT_PIPE_HDLC_CFG_WRITE			0x54
+#define PKT_PIPE_IDLE_PATTERN_WRITE		0x55
+#define PKT_PIPE_RX_SIZE_WRITE			0x56
+#define PKT_PIPE_MODE_WRITE			0x57
+
+
+#define HSS_TIMESLOTS		128
+#define HSS_LUT_BITS		2
+
+/* HDLC packet status values - desc->status */
+#define ERR_SHUTDOWN		1 /* stop or shutdown occurrance */
+#define ERR_HDLC_ALIGN		2 /* HDLC alignment error */
+#define ERR_HDLC_FCS		3 /* HDLC Frame Check Sum error */
+#define ERR_RXFREE_Q_EMPTY	4 /* RX-free queue became empty while receiving
+				     this packet (if buf_len < pkt_len) */
+#define ERR_HDLC_TOO_LONG	5 /* HDLC frame size too long */
+#define ERR_HDLC_ABORT		6 /* abort sequence received */
+#define ERR_DISCONNECTING	7 /* disconnect is in progress */
+
+
+struct port {
+	struct npe *npe;
+	struct net_device *netdev;
+	struct hss_plat_info *plat;
+	struct sk_buff *rx_skb_tab[RX_DESCS], *tx_skb_tab[TX_DESCS];
+	struct desc *desc_tab;	/* coherent */
+	u32 desc_tab_phys;
+	sync_serial_settings settings;
+	int id;
+	u8 hdlc_cfg;
+};
+
+/* NPE message structure */
+struct msg {
+	u8 cmd, unused, hss_port, index;
+	union {
+		u8 data8[4];
+		u16 data16[2];
+		u32 data32;
+	};
+};
+
+
+/* HDLC packet descriptor */
+struct desc {
+	u32 next;		/* pointer to next buffer, unused */
+	u16 buf_len;		/* buffer length */
+	u16 pkt_len;		/* packet length */
+	u32 data;		/* pointer to data buffer in RAM */
+	u8 status;
+	u8 error_count;
+	u16 __reserved;
+	u32 __reserved1[4];
+};
+
+#define rx_desc_ptr(port, n)	(&(port)->desc_tab[n])
+#define rx_desc_phys(port, n)	((port)->desc_tab_phys +		\
+				 (n) * sizeof(struct desc))
+#define tx_desc_ptr(port, n)	(&(port)->desc_tab[(n) + RX_DESCS])
+#define tx_desc_phys(port, n)	((port)->desc_tab_phys +		\
+				 ((n) + RX_DESCS) * sizeof(struct desc))
+
+static int ports_open;
+static struct dma_pool *dma_pool;
+
+static struct {
+	int tx, txdone, rx, rxfree;
+}queue_ids[2] = {{ HSS0_PKT_TX0_QUEUE, HSS0_PKT_TXDONE_QUEUE,
+		   HSS0_PKT_RX_QUEUE, HSS0_PKT_RXFREE0_QUEUE },
+		 { HSS1_PKT_TX0_QUEUE, HSS1_PKT_TXDONE_QUEUE,
+		   HSS1_PKT_RX_QUEUE, HSS1_PKT_RXFREE0_QUEUE },
+};
+
+
+static inline struct port* dev_to_port(struct net_device *dev)
+{
+	return dev_to_hdlc(dev)->priv;
+}
+
+
+static inline void debug_desc(unsigned int queue, u32 desc_phys,
+			      struct desc *desc, int is_get)
+{
+#if DEBUG_QUEUES
+	const char *op = is_get ? "->" : "<-";
+
+	if (!desc_phys) {
+		printk(KERN_DEBUG "queue %2i %s NULL\n", queue, op);
+		return;
+	}
+	printk(KERN_DEBUG "queue %2i %s %X: %X %3X %3X %08X %X %X\n",
+	       queue, op, desc_phys, desc->next, desc->buf_len, desc->pkt_len,
+	       desc->data, desc->status, desc->error_count);
+#endif
+}
+
+static inline int queue_get_desc(unsigned int queue, struct port *port,
+				 int is_tx)
+{
+	u32 phys, tab_phys, n_desc;
+	struct desc *tab;
+
+	if (!(phys = qmgr_get_entry(queue))) {
+		debug_desc(queue, phys, NULL, 1);
+		return -1;
+	}
+
+	BUG_ON(phys & 0x1F);
+	tab_phys = is_tx ? tx_desc_phys(port, 0) : rx_desc_phys(port, 0);
+	tab = is_tx ? tx_desc_ptr(port, 0) : rx_desc_ptr(port, 0);
+	n_desc = (phys - tab_phys) / sizeof(struct desc);
+	BUG_ON(n_desc >= (is_tx ? TX_DESCS : RX_DESCS));
+
+	debug_desc(queue, phys, &tab[n_desc], 1);
+	BUG_ON(tab[n_desc].next);
+	return n_desc;
+}
+
+static inline void queue_put_desc(unsigned int queue, u32 desc_phys,
+				  struct desc *desc)
+{
+	debug_desc(queue, desc_phys, desc, 0);
+	BUG_ON(desc_phys & 0x1F);
+	qmgr_put_entry(queue, desc_phys);
+}
+
+
+static void hss_set_carrier(void *pdev, int carrier)
+{
+	struct net_device *dev = pdev;
+	if (carrier)
+		netif_carrier_on(dev);
+	else
+		netif_carrier_off(dev);
+}
+
+static void hss_rx_irq(void *pdev)
+{
+	struct net_device *dev = pdev;
+	struct port *port = dev_to_port(dev);
+
+#if DEBUG_RX
+	printk(KERN_DEBUG "hss_rx_irq() start\n");
+#endif
+	qmgr_disable_irq(queue_ids[port->id].rx);
+	netif_rx_schedule(dev);
+}
+
+static int hss_poll(struct net_device *dev, int *budget)
+{
+	struct port *port = dev_to_port(dev);
+	unsigned int queue = queue_ids[port->id].rx;
+	struct net_device_stats *stats = hdlc_stats(dev);
+	int quota = dev->quota, received = 0;
+
+#if DEBUG_RX
+	printk(KERN_DEBUG "hss_poll() start\n");
+#endif
+	while (quota) {
+		struct sk_buff *old_skb, *new_skb = NULL;
+		struct desc *desc;
+		u32 data;
+		int n = queue_get_desc(queue, port, 0);
+		if (n < 0) {	/* No packets received */
+			dev->quota -= received;
+			*budget -= received;
+			received = 0;
+#if DEBUG_RX
+	printk(KERN_DEBUG "hss_poll() netif_rx_complete()\n");
+#endif
+			netif_rx_complete(dev);
+			qmgr_enable_irq(queue);
+			if (!qmgr_stat_empty(queue) &&
+			    netif_rx_reschedule(dev, 0)) {
+#if DEBUG_RX
+				printk(KERN_DEBUG "hss_poll()"
+				       " netif_rx_reschedule() successed\n");
+#endif
+				qmgr_disable_irq(queue);
+				continue;
+			}
+#if DEBUG_RX
+				printk(KERN_DEBUG "hss_poll() all done\n");
+#endif
+			return 0; /* all work done */
+		}
+
+		desc = rx_desc_ptr(port, n);
+
+		if (!desc->status) /* check for RX errors */
+			new_skb = netdev_alloc_skb(dev, RX_SIZE);
+		if (new_skb)
+			data = dma_map_single(&dev->dev, new_skb->data,
+					      RX_SIZE, DMA_FROM_DEVICE);
+
+		if (!new_skb || dma_mapping_error(data)) {
+			if (new_skb)
+				dev_kfree_skb(new_skb);
+			switch (desc->status) {
+			case 0:
+				stats->rx_dropped++;
+				break;
+			case ERR_HDLC_ALIGN:
+			case ERR_HDLC_ABORT:
+				stats->rx_frame_errors++;
+				stats->rx_errors++;
+				break;
+			case ERR_HDLC_FCS:
+				stats->rx_crc_errors++;
+				stats->rx_errors++;
+				break;
+			case ERR_HDLC_TOO_LONG:
+				stats->rx_length_errors++;
+				stats->rx_errors++;
+				break;
+			default: /* FIXME - remove printk */
+				printk(KERN_ERR "hss_poll(): status 0x%02X"
+				       " errors %u\n", desc->status,
+				       desc->error_count);
+				stats->rx_errors++;
+			}
+			/* put the desc back on RX-ready queue */
+			desc->buf_len = RX_SIZE;
+			desc->pkt_len = desc->status = 0;
+			queue_put_desc(queue_ids[port->id].rxfree,
+				       rx_desc_phys(port, n), desc);
+			BUG_ON(qmgr_stat_overflow(queue_ids[port->id].rxfree));
+			continue;
+		}
+
+		if (desc->error_count) /* FIXME - remove printk */
+			printk(KERN_ERR "hss_poll(): status 0x%02X"
+			       " errors %u\n", desc->status,
+			       desc->error_count);
+
+		/* process received skb */
+		old_skb = port->rx_skb_tab[n];
+		dma_unmap_single(&dev->dev, desc->data,
+				 RX_SIZE, DMA_FROM_DEVICE);
+
+		skb_put(old_skb, desc->pkt_len);
+		old_skb->protocol = hdlc_type_trans(old_skb, dev);
+		dev->last_rx = jiffies;
+		stats->rx_packets++;
+		stats->rx_bytes += old_skb->len;
+		netif_receive_skb(old_skb);
+
+		/* put the new skb on RX-free queue */
+		port->rx_skb_tab[n] = new_skb;
+		desc->buf_len = RX_SIZE;
+		desc->pkt_len = 0;
+		desc->data = data;
+		queue_put_desc(queue_ids[port->id].rxfree,
+			       rx_desc_phys(port, n), desc);
+		BUG_ON(qmgr_stat_overflow(queue_ids[port->id].rxfree));
+		quota--;
+		received++;
+	}
+	dev->quota -= received;
+	*budget -= received;
+#if DEBUG_RX
+	printk(KERN_DEBUG "hss_poll() end, not all work done\n");
+#endif
+	return 1;		/* not all work done */
+}
+
+static void hss_xmit_ready_irq(void *pdev)
+{
+	struct net_device *dev = pdev;
+
+#if DEBUG_TX
+	printk(KERN_DEBUG "hss_xmit_empty() start\n");
+#endif
+	netif_start_queue(dev);
+
+#if DEBUG_TX
+	printk(KERN_DEBUG "hss_xmit_empty() end\n");
+#endif
+}
+
+static int hss_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct port *port = dev_to_port(dev);
+	struct net_device_stats *stats = hdlc_stats(dev);
+	struct desc *desc;
+	u32 phys;
+	struct sk_buff *old_skb;
+	int n;
+
+#if DEBUG_TX
+	printk(KERN_DEBUG "hss_xmit() start\n");
+#endif
+	if (unlikely(skb->len > HDLC_MAX_MRU)) {
+		dev_kfree_skb(skb);
+		stats->tx_errors++;
+		return NETDEV_TX_OK;
+	}
+
+	n = queue_get_desc(queue_ids[port->id].txdone, port, 1);
+	BUG_ON(n < 0);
+	desc = tx_desc_ptr(port, n);
+	phys = tx_desc_phys(port, n);
+
+	if ((old_skb = port->tx_skb_tab[n]) != NULL) {
+		dma_unmap_single(&dev->dev, desc->data,
+				 desc->buf_len, DMA_TO_DEVICE);
+		stats->tx_packets++;
+		stats->tx_bytes += old_skb->len;
+		dev_kfree_skb(old_skb);
+	}
+
+	desc->buf_len = desc->pkt_len = skb->len;
+	desc->data = dma_map_single(&dev->dev, skb->data,
+				    skb->len, DMA_TO_DEVICE);
+	if (dma_mapping_error(desc->data)) {
+		desc->data = 0;
+		dev_kfree_skb(skb);
+		port->tx_skb_tab[n] = NULL;
+		stats->tx_dropped++;
+		/* put the desc back on TX-done queue */
+		queue_put_desc(queue_ids[port->id].txdone, phys, desc);
+		return 0;
+	}
+
+	port->tx_skb_tab[n] = skb;
+	wmb();
+	queue_put_desc(queue_ids[port->id].tx, phys, desc);
+	BUG_ON(qmgr_stat_overflow(queue_ids[port->id].tx));
+	dev->trans_start = jiffies;
+
+	if (qmgr_stat_empty(queue_ids[port->id].txdone)) {
+		netif_stop_queue(dev);
+		/* we could miss TX ready interrupt */
+		if (!qmgr_stat_empty(queue_ids[port->id].txdone)) {
+			netif_start_queue(dev);
+		}
+	}
+
+#if DEBUG_TX
+	printk(KERN_DEBUG "hss_xmit() end\n");
+#endif
+	return NETDEV_TX_OK;
+}
+
+
+static int request_queues(struct port *port)
+{
+	int err;
+
+	err = qmgr_request_queue(queue_ids[port->id].rxfree, RX_DESCS, 0, 0);
+	if (err)
+		return err;
+
+	err = qmgr_request_queue(queue_ids[port->id].rx, RX_DESCS, 0, 0);
+	if (err)
+		goto rel_rxfree;
+
+	err = qmgr_request_queue(queue_ids[port->id].tx, TX_DESCS, 0, 0);
+	if (err)
+		goto rel_rx;
+
+	err = qmgr_request_queue(queue_ids[port->id].txdone, TX_DESCS, 0, 0);
+	if (err)
+		goto rel_tx;
+	return 0;
+
+rel_tx:
+	qmgr_release_queue(queue_ids[port->id].tx);
+rel_rx:
+	qmgr_release_queue(queue_ids[port->id].rx);
+rel_rxfree:
+	qmgr_release_queue(queue_ids[port->id].rxfree);
+	return err;
+}
+
+static void release_queues(struct port *port)
+{
+	qmgr_release_queue(queue_ids[port->id].rxfree);
+	qmgr_release_queue(queue_ids[port->id].rx);
+	qmgr_release_queue(queue_ids[port->id].txdone);
+	qmgr_release_queue(queue_ids[port->id].tx);
+}
+
+static int init_queues(struct port *port)
+{
+	int i;
+
+	if (!dma_pool) {
+		dma_pool = dma_pool_create(DRV_NAME, NULL, POOL_ALLOC_SIZE,
+					   32, 0);
+		if (!dma_pool)
+			return -ENOMEM;
+	}
+
+	if (!(port->desc_tab = dma_pool_alloc(dma_pool, GFP_KERNEL,
+					      &port->desc_tab_phys)))
+		return -ENOMEM;
+	memset(port->desc_tab, 0, POOL_ALLOC_SIZE);
+	memset(port->rx_skb_tab, 0, sizeof(port->rx_skb_tab)); /* tables */
+	memset(port->tx_skb_tab, 0, sizeof(port->tx_skb_tab));
+
+	/* Setup RX buffers */
+	for (i = 0; i < RX_DESCS; i++) {
+		struct desc *desc = rx_desc_ptr(port, i);
+		struct sk_buff *skb;
+
+		if (!(skb = netdev_alloc_skb(port->netdev, RX_SIZE)))
+			return -ENOMEM;
+		port->rx_skb_tab[i] = skb;
+		desc->buf_len = RX_SIZE;
+		desc->data = dma_map_single(&port->netdev->dev, skb->data,
+					    RX_SIZE, DMA_FROM_DEVICE);
+		if (dma_mapping_error(desc->data)) {
+			desc->data = 0;
+			return -EIO;
+		}
+		queue_put_desc(queue_ids[port->id].rxfree,
+			       rx_desc_phys(port, i), desc);
+		BUG_ON(qmgr_stat_overflow(queue_ids[port->id].rxfree));
+	}
+
+	/* Setup TX-done queue */
+	for (i = 0; i < TX_DESCS; i++) {
+		queue_put_desc(queue_ids[port->id].txdone,
+			       tx_desc_phys(port, i), tx_desc_ptr(port, i));
+		BUG_ON(qmgr_stat_overflow(queue_ids[port->id].txdone));
+	}
+	return 0;
+}
+
+static void destroy_queues(struct port *port)
+{
+	int i;
+
+	while (queue_get_desc(queue_ids[port->id].rxfree, port, 0) >= 0)
+		/* nothing to do here */;
+	while (queue_get_desc(queue_ids[port->id].rx, port, 0) >= 0)
+		/* nothing to do here */;
+	while (queue_get_desc(queue_ids[port->id].tx, port, 1) >= 0)
+		/* nothing to do here */;
+	while (queue_get_desc(queue_ids[port->id].txdone, port, 1) >= 0)
+		/* nothing to do here */;
+
+	if (port->desc_tab) {
+		for (i = 0; i < RX_DESCS; i++) {
+			struct desc *desc = rx_desc_ptr(port, i);
+			struct sk_buff *skb = port->rx_skb_tab[i];
+			if (skb) {
+				if (desc->data)
+					dma_unmap_single(&port->netdev->dev,
+							 desc->data, RX_SIZE,
+							 DMA_FROM_DEVICE);
+				dev_kfree_skb(skb);
+			}
+		}
+		for (i = 0; i < TX_DESCS; i++) {
+			struct desc *desc = tx_desc_ptr(port, i);
+			struct sk_buff *skb = port->tx_skb_tab[i];
+			if (skb) {
+				if (desc->data)
+					dma_unmap_single(&port->netdev->dev,
+							 desc->data,
+							 desc->buf_len,
+							 DMA_TO_DEVICE);
+				dev_kfree_skb(skb);
+			}
+		}
+		dma_pool_free(dma_pool, port->desc_tab, port->desc_tab_phys);
+		port->desc_tab = NULL;
+	}
+
+	if (!ports_open && dma_pool) {
+		dma_pool_destroy(dma_pool);
+		dma_pool = NULL;
+	}
+}
+
+
+static int hss_open(struct net_device *dev)
+{
+	struct port *port = dev_to_port(dev);
+	struct npe *npe = port->npe;
+	struct msg msg;
+	int i, err;
+
+	if (!npe_running(npe))
+		if ((err = npe_load_firmware(npe, npe_name(npe),
+					     &dev->dev)) != 0)
+			return err;
+
+	if ((err = hdlc_open(dev)) != 0)
+		return err;
+
+	if (port->plat->open)
+		if ((err = port->plat->open(port->id, port->netdev,
+					    hss_set_carrier)) != 0)
+			goto err_hdlc_close;
+
+	/* HSS main configuration */
+	memset(&msg, 0, sizeof(msg));
+	msg.cmd = PORT_CONFIG_WRITE;
+	msg.hss_port = port->id;
+	msg.index = 0;		/* offset in HSS config */
+
+	msg.data32 = PCR_FRM_PULSE_DISABLED |
+		PCR_SOF_NO_FBIT |
+		PCR_MSB_ENDIAN |
+		PCR_TX_DATA_ENABLE;
+
+	if (port->settings.clock_type == CLOCK_INT)
+		msg.data32 |= PCR_SYNC_CLK_DIR_OUTPUT;
+
+	if ((err = npe_send_message(npe, &msg, "HSS_SET_TX_PCR") != 0))
+		goto err_plat_close; /* 0: TX PCR */
+
+	msg.index = 4;
+	msg.data32 ^= PCR_TX_DATA_ENABLE | PCR_DCLK_EDGE_RISING;
+	if ((err = npe_send_message(npe, &msg, "HSS_SET_RX_PCR") != 0))
+		goto err_plat_close; /* 4: RX PCR */
+
+	msg.index = 8;
+	msg.data32 = (port->settings.loopback ? CCR_LOOPBACK : 0) |
+		(port->id ? CCR_SECOND_HSS : 0);
+	if ((err = npe_send_message(npe, &msg, "HSS_SET_CORE_CR") != 0))
+		goto err_plat_close; /* 8: Core CR */
+
+	msg.index = 12;
+	msg.data32 = CLK42X_SPEED_2048KHZ /* FIXME */;
+	if ((err = npe_send_message(npe, &msg, "HSS_SET_CLK_CR") != 0))
+		goto err_plat_close; /* 12: CLK CR */
+
+	msg.data32 = (FRAME_SYNC_OFFSET << 16) | (FRAME_SYNC_SIZE - 1);
+	msg.index = 16;
+	if ((err = npe_send_message(npe, &msg, "HSS_SET_TX_FCR") != 0))
+		goto err_plat_close; /* 16: TX FCR */
+
+	msg.index = 20;
+	if ((err = npe_send_message(npe, &msg, "HSS_SET_RX_FCR") != 0))
+		goto err_plat_close; /* 20: RX FCR */
+
+	msg.data32 = 0;		/* Fill LUT with HDLC timeslots */
+	for (i = 0; i < 32 / HSS_LUT_BITS; i++)
+		msg.data32 |= TDMMAP_HDLC << (HSS_LUT_BITS * i);
+
+	for (i = 0; i < 2 /* TX and RX */ * HSS_TIMESLOTS * HSS_LUT_BITS / 8;
+	     i += 4) {
+		msg.index = 24 + i; /* 24 - 55: TX LUT, 56 - 87: RX LUT */
+		if ((err = npe_send_message(npe, &msg, "HSS_SET_LUT") != 0))
+			goto err_plat_close;
+	}
+
+	/* HDLC mode configuration */
+	memset(&msg, 0, sizeof(msg));
+	msg.cmd = PKT_NUM_PIPES_WRITE;
+	msg.hss_port = port->id;
+	msg.data8[0] = PKT_NUM_PIPES;
+	if ((err = npe_send_message(npe, &msg, "HSS_SET_PKT_PIPES") != 0))
+		goto err_plat_close;
+
+	memset(&msg, 0, sizeof(msg));
+	msg.cmd = PKT_PIPE_FIFO_SIZEW_WRITE;
+	msg.hss_port = port->id;
+	msg.data8[0] = PKT_PIPE_FIFO_SIZEW;
+	if ((err = npe_send_message(npe, &msg, "HSS_SET_PKT_FIFO") != 0))
+		goto err_plat_close;
+
+	memset(&msg, 0, sizeof(msg));
+	msg.cmd = PKT_PIPE_IDLE_PATTERN_WRITE;
+	msg.hss_port = port->id;
+	msg.data32 = 0x7F7F7F7F;
+	if ((err = npe_send_message(npe, &msg, "HSS_SET_PKT_IDLE") != 0))
+		goto err_plat_close;
+
+	memset(&msg, 0, sizeof(msg));
+	msg.cmd = PORT_CONFIG_LOAD;
+	msg.hss_port = port->id;
+	if ((err = npe_send_message(npe, &msg, "HSS_LOAD_CONFIG") != 0))
+		goto err_plat_close;
+	if ((err = npe_recv_message(npe, &msg, "HSS_LOAD_CONFIG") != 0))
+		goto err_plat_close;
+
+	/* HSS_LOAD_CONFIG for port #1 returns port_id = #4 */
+	if (msg.cmd != PORT_CONFIG_LOAD || msg.data32) {
+		printk(KERN_DEBUG "%s: unexpected message received in"
+		       " response to HSS_LOAD_CONFIG: \n", npe_name(npe));
+		err = EIO;
+		goto err_plat_close;
+	}
+
+	memset(&msg, 0, sizeof(msg));
+	msg.cmd = PKT_PIPE_HDLC_CFG_WRITE;
+	msg.hss_port = port->id;
+	msg.data8[0] = port->hdlc_cfg; /* rx_cfg */
+	msg.data8[1] = port->hdlc_cfg | (PKT_EXTRA_FLAGS << 3); /* tx_cfg */
+	if ((err = npe_send_message(npe, &msg, "HSS_SET_HDLC_CFG") != 0))
+		goto err_plat_close;
+
+	memset(&msg, 0, sizeof(msg));
+	msg.cmd = PKT_PIPE_MODE_WRITE;
+	msg.hss_port = port->id;
+	msg.data8[0] = NPE_PKT_MODE_HDLC;
+	/* msg.data8[1] = inv_mask */
+	/* msg.data8[2] = or_mask */
+	if ((err = npe_send_message(npe, &msg, "HSS_SET_PKT_MODE") != 0))
+		goto err_plat_close;
+
+	memset(&msg, 0, sizeof(msg));
+	msg.cmd = PKT_PIPE_RX_SIZE_WRITE;
+	msg.hss_port = port->id;
+	msg.data16[0] = HDLC_MAX_MRU;
+	if ((err = npe_send_message(npe, &msg, "HSS_SET_PKT_RX_SIZE") != 0))
+		goto err_plat_close;
+
+	if ((err = request_queues(port)) != 0)
+		goto err_plat_close;
+
+	if ((err = init_queues(port)) != 0)
+		goto err_destroy_queues;
+
+	memset(&msg, 0, sizeof(msg));
+	msg.cmd = PKT_PIPE_FLOW_ENABLE;
+	msg.hss_port = port->id;
+	if ((err = npe_send_message(npe, &msg, "HSS_ENABLE_PKT_PIPE") != 0))
+		goto err_destroy_queues;
+
+	netif_start_queue(dev);
+
+	qmgr_set_irq(queue_ids[port->id].rx, QUEUE_IRQ_SRC_NOT_EMPTY,
+		     hss_rx_irq, dev);
+	qmgr_enable_irq(queue_ids[port->id].rx);
+
+	qmgr_set_irq(queue_ids[port->id].txdone, QUEUE_IRQ_SRC_NOT_EMPTY,
+		     hss_xmit_ready_irq, dev);
+	qmgr_enable_irq(queue_ids[port->id].txdone);
+
+	ports_open++;
+	return 0;
+
+err_destroy_queues:
+	destroy_queues(port);
+	release_queues(port);
+err_plat_close:
+	if (port->plat->close)
+		port->plat->close(port->id, port->netdev);
+err_hdlc_close:
+	hdlc_close(dev);
+	return err;
+}
+
+static int hss_close(struct net_device *dev)
+{
+	struct port *port = dev_to_port(dev);
+	struct npe *npe = port->npe;
+	struct msg msg;
+
+	ports_open--;
+	qmgr_disable_irq(queue_ids[port->id].rx);
+	qmgr_disable_irq(queue_ids[port->id].txdone);
+	netif_stop_queue(dev);
+
+	memset(&msg, 0, sizeof(msg));
+	msg.cmd = PKT_PIPE_FLOW_DISABLE;
+	msg.hss_port = port->id;
+	if (npe_send_message(npe, &msg, "HSS_DISABLE_PKT_PIPE")) {
+		printk(KERN_CRIT "HSS-%i: unable to stop HDLC flow\n",
+		       port->id);
+		/* The upper level would ignore the error anyway */
+	}
+
+	destroy_queues(port);
+	release_queues(port);
+
+	if (port->plat->close)
+		port->plat->close(port->id, port->netdev);
+	hdlc_close(dev);
+	return 0;
+}
+
+
+static int hss_attach(struct net_device *dev, unsigned short encoding,
+		      unsigned short parity)
+{
+	struct port *port = dev_to_port(dev);
+
+	if (encoding != ENCODING_NRZ)
+		return -EINVAL;
+
+	switch(parity) {
+	case PARITY_CRC16_PR1_CCITT:
+		port->hdlc_cfg = 0;
+		return 0;
+
+	case PARITY_CRC32_PR1_CCITT:
+		port->hdlc_cfg = PKT_HDLC_CRC_32;
+		return 0;
+
+	default:
+		return -EINVAL;
+	}
+}
+
+
+static int hss_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	const size_t size = sizeof(sync_serial_settings);
+	sync_serial_settings new_line;
+	int clk;
+	sync_serial_settings __user *line = ifr->ifr_settings.ifs_ifsu.sync;
+	struct port *port = dev_to_port(dev);
+
+	if (cmd != SIOCWANDEV)
+		return hdlc_ioctl(dev, ifr, cmd);
+
+	switch(ifr->ifr_settings.type) {
+	case IF_GET_IFACE:
+		ifr->ifr_settings.type = IF_IFACE_V35;
+		if (ifr->ifr_settings.size < size) {
+			ifr->ifr_settings.size = size; /* data size wanted */
+			return -ENOBUFS;
+		}
+		if (copy_to_user(line, &port->settings, size))
+			return -EFAULT;
+		return 0;
+
+	case IF_IFACE_SYNC_SERIAL:
+	case IF_IFACE_V35:
+		if(!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		if (dev->flags & IFF_UP)
+			return -EBUSY; /* Cannot change parameters when open */
+
+		if (copy_from_user(&new_line, line, size))
+			return -EFAULT;
+
+		clk = new_line.clock_type;
+		if (port->plat->set_clock)
+			clk = port->plat->set_clock(port->id, clk);
+
+		if (clk != CLOCK_EXT && clk != CLOCK_INT)
+			return -EINVAL;	/* No such clock setting */
+
+		if (new_line.loopback != 0 && new_line.loopback != 1)
+			return -EINVAL;
+
+		memcpy(&port->settings, &new_line, size); /* Update settings */
+		return 0;
+
+	default:
+		return hdlc_ioctl(dev, ifr, cmd);
+	}
+}
+
+
+static int __devinit hss_init_one(struct platform_device *pdev)
+{
+	struct port *port;
+	struct net_device *dev;
+	hdlc_device *hdlc;
+	int err;
+
+	if ((port = kzalloc(sizeof(*port), GFP_KERNEL)) == NULL)
+		return -ENOMEM;
+	platform_set_drvdata(pdev, port);
+	port->id = pdev->id;
+
+	if ((port->npe = npe_request(0)) == NULL) {
+		err = -ENOSYS;
+		goto err_free;
+	}
+
+	port->plat = pdev->dev.platform_data;
+	if ((port->netdev = dev = alloc_hdlcdev(port)) == NULL) {
+		err = -ENOMEM;
+		goto err_plat;
+	}
+
+	SET_MODULE_OWNER(net);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+	hdlc = dev_to_hdlc(dev);
+	hdlc->attach = hss_attach;
+	hdlc->xmit = hss_xmit;
+	dev->open = hss_open;
+	dev->poll = hss_poll;
+	dev->stop = hss_close;
+	dev->do_ioctl = hss_ioctl;
+	dev->weight = 16;
+	dev->tx_queue_len = 100;
+	port->settings.clock_type = CLOCK_EXT;
+	port->settings.clock_rate = 2048000;
+
+	if (register_hdlc_device(dev)) {
+		printk(KERN_ERR "HSS-%i: unable to register HDLC device\n",
+		       port->id);
+		err = -ENOBUFS;
+		goto err_free_netdev;
+	}
+	printk(KERN_INFO "%s: HSS-%i\n", dev->name, port->id);
+	return 0;
+
+err_free_netdev:
+	free_netdev(dev);
+err_plat:
+	npe_release(port->npe);
+	platform_set_drvdata(pdev, NULL);
+err_free:
+	kfree(port);
+	return err;
+}
+
+static int __devexit hss_remove_one(struct platform_device *pdev)
+{
+	struct port *port = platform_get_drvdata(pdev);
+
+	unregister_hdlc_device(port->netdev);
+	free_netdev(port->netdev);
+	npe_release(port->npe);
+	platform_set_drvdata(pdev, NULL);
+	kfree(port);
+	return 0;
+}
+
+static struct platform_driver drv = {
+	.driver.name	= DRV_NAME,
+	.probe		= hss_init_one,
+	.remove		= hss_remove_one,
+};
+
+static int __init hss_init_module(void)
+{
+	if ((ixp4xx_read_fuses() & (IXP4XX_FUSE_HDLC | IXP4XX_FUSE_HSS)) !=
+	    (IXP4XX_FUSE_HDLC | IXP4XX_FUSE_HSS))
+		return -ENOSYS;
+	return platform_driver_register(&drv);
+}
+
+static void __exit hss_cleanup_module(void)
+{
+	platform_driver_unregister(&drv);
+}
+
+MODULE_AUTHOR("Krzysztof Halasa <khc@pm.waw.pl>");
+MODULE_DESCRIPTION("Intel IXP4xx HSS driver");
+MODULE_LICENSE("GPL v2");
+
+module_init(hss_init_module);
+module_exit(hss_cleanup_module);
diff --git a/include/asm-arm/arch-ixp4xx/platform.h b/include/asm-arm/arch-ixp4xx/platform.h
index ab194e5..3a07ee2 100644
--- a/include/asm-arm/arch-ixp4xx/platform.h
+++ b/include/asm-arm/arch-ixp4xx/platform.h
@@ -86,6 +86,25 @@ struct ixp4xx_i2c_pins {
 	unsigned long scl_pin;
 };
 
+#define IXP4XX_ETH_NPEA		0x00
+#define IXP4XX_ETH_NPEB		0x10
+#define IXP4XX_ETH_NPEC		0x20
+
+/* Information about built-in Ethernet MAC interfaces */
+struct mac_plat_info {
+	u8 phy;		/* MII PHY ID, 0 - 31 */
+	u8 rxq;		/* configurable, currently 0 - 31 only */
+	u8 hwaddr[6];
+};
+
+/* Information about built-in HSS (synchronous serial) interfaces */
+struct hss_plat_info {
+	int (*set_clock)(int port, unsigned int clock_type);
+	int (*open)(int port, void *pdev,
+		    void (*set_carrier_cb)(void *pdev, int carrier));
+	void (*close)(int port, void *pdev);
+};
+
 /*
  * This structure provide a means for the board setup code
  * to give information to th pata_ixp4xx driver. It is
