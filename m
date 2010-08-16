From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 4/5] ptp: Added a clock driver for the IXP46x.
Date: Mon, 16 Aug 2010 13:18:51 +0200
Message-ID: <737f00e912375bae8797efaa6877ace9509f4707.1281956490.git.richard.cochran@omicron.at>
References: <cover.1281956490.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, Rodolfo Giometti <giometti@linux.it>,
	linux-arm-kernel@lists.infradead.org, Krzysztof Halasa <khc@pm.waw.pl>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <cover.1281956490.git.richard.cochran@omicron.at>
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

This patch adds a driver for the hardware time stamping unit found on the
IXP465. The basic clock operations and an external trigger are implemented.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h |   78 ++++++
 drivers/net/arm/ixp4xx_eth.c                  |  191 +++++++++++++
 drivers/ptp/Kconfig                           |   13 +
 drivers/ptp/Makefile                          |    1 +
 drivers/ptp/ptp_ixp46x.c                      |  359 +++++++++++++++++++++++++
 5 files changed, 642 insertions(+), 0 deletions(-)
 create mode 100644 arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h
 create mode 100644 drivers/ptp/ptp_ixp46x.c

diff --git a/arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h b/arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h
new file mode 100644
index 0000000..729a6b2
--- /dev/null
+++ b/arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h
@@ -0,0 +1,78 @@
+/*
+ * PTP 1588 clock using the IXP46X
+ *
+ * Copyright (C) 2010 OMICRON electronics GmbH
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#ifndef _IXP46X_TS_H_
+#define _IXP46X_TS_H_
+
+#define DEFAULT_ADDEND 0xF0000029
+#define TICKS_NS_SHIFT 4
+
+struct ixp46x_channel_ctl {
+	u32 Ch_Control; /* 0x40 Time Synchronization Channel Control */
+	u32 Ch_Event;   /* 0x44 Time Synchronization Channel Event */
+	u32 TxSnapLo;   /* 0x48 Transmit Snapshot Low Register */
+	u32 TxSnapHi;   /* 0x4C Transmit Snapshot High Register */
+	u32 RxSnapLo;   /* 0x50 Receive Snapshot Low Register */
+	u32 RxSnapHi;   /* 0x54 Receive Snapshot High Register */
+	u32 SrcUUIDLo;  /* 0x58 Source UUID0 Low Register */
+	u32 SrcUUIDHi;  /* 0x5C Sequence Identifier/Source UUID0 High */
+};
+
+struct ixp46x_ts_regs {
+	u32 Control;     /* 0x00 Time Sync Control Register */
+	u32 Event;       /* 0x04 Time Sync Event Register */
+	u32 Addend;      /* 0x08 Time Sync Addend Register */
+	u32 Accum;       /* 0x0C Time Sync Accumulator Register */
+	u32 Test;        /* 0x10 Time Sync Test Register */
+	u32 Unused;      /* 0x14 */
+	u32 RSysTime_Lo; /* 0x18 RawSystemTime_Low Register */
+	u32 RSysTimeHi;  /* 0x1C RawSystemTime_High Register */
+	u32 SysTimeLo;   /* 0x20 SystemTime_Low Register */
+	u32 SysTimeHi;   /* 0x24 SystemTime_High Register */
+	u32 TrgtLo;      /* 0x28 TargetTime_Low Register */
+	u32 TrgtHi;      /* 0x2C TargetTime_High Register */
+	u32 ASMSLo;      /* 0x30 Auxiliary Slave Mode Snapshot Low  */
+	u32 ASMSHi;      /* 0x34 Auxiliary Slave Mode Snapshot High */
+	u32 AMMSLo;      /* 0x38 Auxiliary Master Mode Snapshot Low */
+	u32 AMMSHi;      /* 0x3C Auxiliary Master Mode Snapshot High */
+
+	struct ixp46x_channel_ctl channel[3];
+};
+
+/* 0x00 Time Sync Control Register Bits */
+#define TSCR_AMM (1<<3)
+#define TSCR_ASM (1<<2)
+#define TSCR_TTM (1<<1)
+#define TSCR_RST (1<<0)
+
+/* 0x04 Time Sync Event Register Bits */
+#define TSER_SNM (1<<3)
+#define TSER_SNS (1<<2)
+#define TTIPEND  (1<<1)
+
+/* 0x40 Time Synchronization Channel Control Register Bits */
+#define MASTER_MODE   (1<<0)
+#define TIMESTAMP_ALL (1<<1)
+
+/* 0x44 Time Synchronization Channel Event Register Bits */
+#define TX_SNAPSHOT_LOCKED (1<<0)
+#define RX_SNAPSHOT_LOCKED (1<<1)
+
+#endif
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index 4f1cc71..3d36154 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -30,9 +30,12 @@
 #include <linux/etherdevice.h>
 #include <linux/io.h>
 #include <linux/kernel.h>
+#include <linux/net_tstamp.h>
 #include <linux/phy.h>
 #include <linux/platform_device.h>
+#include <linux/ptp_classify.h>
 #include <linux/slab.h>
+#include <mach/ixp46x_ts.h>
 #include <mach/npe.h>
 #include <mach/qmgr.h>
 
@@ -67,6 +70,14 @@
 #define RXFREE_QUEUE(port_id)	(NPE_ID(port_id) + 26)
 #define TXDONE_QUEUE		31
 
+#define PTP_SLAVE_MODE		1
+#define PTP_MASTER_MODE		2
+#define PORT2CHANNEL(p)		1
+/*
+ * PHYSICAL_ID(p->id) ?
+ * TODO - Figure out correct mapping.
+ */
+
 /* TX Control Registers */
 #define TX_CNTRL0_TX_EN		0x01
 #define TX_CNTRL0_HALFDUPLEX	0x02
@@ -171,6 +182,8 @@ struct port {
 	int id;			/* logical port ID */
 	int speed, duplex;
 	u8 firmware[4];
+	int hwts_tx_en;
+	int hwts_rx_en;
 };
 
 /* NPE message structure */
@@ -246,6 +259,171 @@ static int ports_open;
 static struct port *npe_port_tab[MAX_NPES];
 static struct dma_pool *dma_pool;
 
+static struct sock_filter ptp_filter[] = {
+	PTP_FILTER
+};
+
+static int match(struct sk_buff *skb, u16 uid_hi, u32 uid_lo, u16 seq)
+{
+	unsigned int type;
+	u16 *hi, *id;
+	u8 *lo, *data = skb->data;
+
+	type = sk_run_filter(skb, ptp_filter, ARRAY_SIZE(ptp_filter));
+
+	if (PTP_CLASS_V1_IPV4 == type) {
+
+		id = (u16 *)(data + 42 + 30);
+		hi = (u16 *)(data + 42 + 22);
+		lo = data + 42 + 24;
+
+		return (uid_hi == *hi &&
+			0 == memcmp(&uid_lo, lo, sizeof(uid_lo)) &&
+			seq == *id);
+	}
+
+	return 0;
+}
+
+static void do_rx_timestamp(struct port *port, struct sk_buff *skb)
+{
+	struct skb_shared_hwtstamps *shhwtstamps;
+	struct ixp46x_ts_regs *regs;
+	u64 ns;
+	u32 ch, hi, lo, val;
+	u16 uid, seq;
+
+	if (!port->hwts_rx_en)
+		return;
+
+	ch = PORT2CHANNEL(port);
+
+	regs = (struct ixp46x_ts_regs __iomem *) IXP4XX_TIMESYNC_BASE_VIRT;
+
+	val = __raw_readl(&regs->channel[ch].Ch_Event);
+
+	if (!(val & RX_SNAPSHOT_LOCKED))
+		return;
+
+	lo = __raw_readl(&regs->channel[ch].SrcUUIDLo);
+	hi = __raw_readl(&regs->channel[ch].SrcUUIDHi);
+
+	uid = hi & 0xffff;
+	seq = (hi >> 16) & 0xffff;
+
+	if (!match(skb, htons(uid), htonl(lo), htons(seq)))
+		goto out;
+
+	lo = __raw_readl(&regs->channel[ch].RxSnapLo);
+	hi = __raw_readl(&regs->channel[ch].RxSnapHi);
+	ns = ((u64) hi) << 32;
+	ns |= lo;
+	ns <<= TICKS_NS_SHIFT;
+
+	shhwtstamps = skb_hwtstamps(skb);
+	memset(shhwtstamps, 0, sizeof(*shhwtstamps));
+	shhwtstamps->hwtstamp = ns_to_ktime(ns);
+out:
+	__raw_writel(RX_SNAPSHOT_LOCKED, &regs->channel[ch].Ch_Event);
+}
+
+static void do_tx_timestamp(struct port *port, struct sk_buff *skb)
+{
+#ifdef __ARMEB__
+	struct skb_shared_hwtstamps shhwtstamps;
+	struct ixp46x_ts_regs *regs;
+	union skb_shared_tx *shtx;
+	u64 ns;
+	u32 ch, cnt, hi, lo, val;
+
+	shtx = skb_tx(skb);
+	if (unlikely(shtx->hardware && port->hwts_tx_en))
+		shtx->in_progress = 1;
+	else
+		return;
+
+	ch = PORT2CHANNEL(port);
+
+	regs = (struct ixp46x_ts_regs __iomem *) IXP4XX_TIMESYNC_BASE_VIRT;
+
+	/*
+	 * This really stinks, but we have to poll for the Tx time stamp.
+	 * Usually, the time stamp is ready after 4 to 6 microseconds.
+	 */
+	for (cnt = 0; cnt < 100; cnt++) {
+		val = __raw_readl(&regs->channel[ch].Ch_Event);
+		if (val & TX_SNAPSHOT_LOCKED)
+			break;
+		udelay(1);
+	}
+	if (!(val & TX_SNAPSHOT_LOCKED)) {
+		shtx->in_progress = 0;
+		return;
+	}
+
+	lo = __raw_readl(&regs->channel[ch].TxSnapLo);
+	hi = __raw_readl(&regs->channel[ch].TxSnapHi);
+	ns = ((u64) hi) << 32;
+	ns |= lo;
+	ns <<= TICKS_NS_SHIFT;
+
+	memset(&shhwtstamps, 0, sizeof(shhwtstamps));
+	shhwtstamps.hwtstamp = ns_to_ktime(ns);
+	skb_tstamp_tx(skb, &shhwtstamps);
+
+	__raw_writel(TX_SNAPSHOT_LOCKED, &regs->channel[ch].Ch_Event);
+#endif
+}
+
+static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	struct hwtstamp_config cfg;
+	struct ixp46x_ts_regs *regs;
+	struct port *port = netdev_priv(netdev);
+	int ch;
+
+	if (copy_from_user(&cfg, ifr->ifr_data, sizeof(cfg)))
+		return -EFAULT;
+
+	if (cfg.flags) /* reserved for future extensions */
+		return -EINVAL;
+
+	ch = PORT2CHANNEL(port);
+	regs = (struct ixp46x_ts_regs __iomem *) IXP4XX_TIMESYNC_BASE_VIRT;
+
+	switch (cfg.tx_type) {
+	case HWTSTAMP_TX_OFF:
+		port->hwts_tx_en = 0;
+		break;
+	case HWTSTAMP_TX_ON:
+		port->hwts_tx_en = 1;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (cfg.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		port->hwts_rx_en = 0;
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+		port->hwts_rx_en = PTP_SLAVE_MODE;
+		__raw_writel(0, &regs->channel[ch].Ch_Control);
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+		port->hwts_rx_en = PTP_MASTER_MODE;
+		__raw_writel(MASTER_MODE, &regs->channel[ch].Ch_Control);
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	/* Clear out any old time stamps. */
+	__raw_writel(TX_SNAPSHOT_LOCKED | RX_SNAPSHOT_LOCKED,
+		     &regs->channel[ch].Ch_Event);
+
+	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
+}
 
 static int ixp4xx_mdio_cmd(struct mii_bus *bus, int phy_id, int location,
 			   int write, u16 cmd)
@@ -573,6 +751,7 @@ static int eth_poll(struct napi_struct *napi, int budget)
 
 		debug_pkt(dev, "eth_poll", skb->data, skb->len);
 
+		do_rx_timestamp(port, skb);
 		skb->protocol = eth_type_trans(skb, dev);
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += skb->len;
@@ -728,6 +907,10 @@ static int eth_xmit(struct sk_buff *skb, struct net_device *dev)
 #if DEBUG_TX
 	printk(KERN_DEBUG "%s: eth_xmit end\n", dev->name);
 #endif
+
+	do_tx_timestamp(port, skb);
+	skb_tx_timestamp(skb);
+
 	return NETDEV_TX_OK;
 }
 
@@ -783,6 +966,9 @@ static int eth_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 	if (!netif_running(dev))
 		return -EINVAL;
 
+	if (cpu_is_ixp46x() && cmd == SIOCSHWTSTAMP)
+		return hwtstamp_ioctl(dev, req, cmd);
+
 	return phy_mii_ioctl(port->phydev, req, cmd);
 }
 
@@ -1171,6 +1357,11 @@ static int __devinit eth_init_one(struct platform_device *pdev)
 	char phy_id[MII_BUS_ID_SIZE + 3];
 	int err;
 
+	if (ptp_filter_init(ptp_filter, ARRAY_SIZE(ptp_filter))) {
+		pr_err("ixp4xx_eth: bad ptp filter\n");
+		return -EINVAL;
+	}
+
 	if (!(dev = alloc_etherdev(sizeof(struct port))))
 		return -ENOMEM;
 
diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index aaf957f..cc2d3a1 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -49,4 +49,17 @@ config PTP_1588_CLOCK_GIANFAR
 	  To compile this driver as a module, choose M here: the module
 	  will be called gianfar_ptp.
 
+config PTP_1588_CLOCK_IXP46X
+	tristate "Intel IXP46x as PTP clock"
+	depends on PTP_1588_CLOCK
+	depends on IXP4XX_ETH
+	help
+	  This driver adds support for using the IXP46X as a PTP
+	  clock. This clock is only useful if your PTP programs are
+	  getting hardware time stamps on the PTP Ethernet packets
+	  using the SO_TIMESTAMPING API.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called ptp_ixp46x.
+
 endmenu
diff --git a/drivers/ptp/Makefile b/drivers/ptp/Makefile
index 1651d52..5018f58 100644
--- a/drivers/ptp/Makefile
+++ b/drivers/ptp/Makefile
@@ -4,3 +4,4 @@
 
 obj-$(CONFIG_PTP_1588_CLOCK)		+= ptp_clock.o
 obj-$(CONFIG_PTP_1588_CLOCK_LINUX)	+= ptp_linux.o
+obj-$(CONFIG_PTP_1588_CLOCK_IXP46X)	+= ptp_ixp46x.o
diff --git a/drivers/ptp/ptp_ixp46x.c b/drivers/ptp/ptp_ixp46x.c
new file mode 100644
index 0000000..4530256
--- /dev/null
+++ b/drivers/ptp/ptp_ixp46x.c
@@ -0,0 +1,359 @@
+/*
+ * PTP 1588 clock using the IXP46X
+ *
+ * Copyright (C) 2010 OMICRON electronics GmbH
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#include <linux/device.h>
+#include <linux/err.h>
+#include <linux/gpio.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
+#include <linux/irq.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+
+#include <linux/ptp_clock_kernel.h>
+#include <mach/ixp46x_ts.h>
+
+#define DRIVER		"ptp_ixp46x"
+#define N_EXT_TS	2
+#define MASTER_GPIO	8
+#define MASTER_IRQ	25
+#define SLAVE_GPIO	7
+#define SLAVE_IRQ	24
+
+struct ixp_clock {
+	struct ixp46x_ts_regs *regs;
+	struct ptp_clock *ptp_clock;
+	int exts0_enabled;
+	int exts1_enabled;
+};
+
+DEFINE_SPINLOCK(register_lock);
+
+/*
+ * Register access functions
+ */
+
+static inline u32 ixp_read(volatile unsigned __iomem *addr)
+{
+	u32 val;
+	val = __raw_readl(addr);
+	return val;
+}
+
+static inline void ixp_write(volatile unsigned __iomem *addr, u32 val)
+{
+	__raw_writel(val, addr);
+}
+
+static u64 sys_time_read(struct ixp46x_ts_regs *regs)
+{
+	u64 ns;
+	u32 lo, hi;
+
+	lo = ixp_read(&regs->SysTimeLo);
+	hi = ixp_read(&regs->SysTimeHi);
+
+	ns = ((u64) hi) << 32;
+	ns |= lo;
+	ns <<= TICKS_NS_SHIFT;
+
+	return ns;
+}
+
+static void sys_time_write(struct ixp46x_ts_regs *regs, u64 ns)
+{
+	u32 hi, lo;
+
+	ns >>= TICKS_NS_SHIFT;
+	hi = ns >> 32;
+	lo = ns & 0xffffffff;
+
+	ixp_write(&regs->SysTimeLo, lo);
+	ixp_write(&regs->SysTimeHi, hi);
+}
+
+/*
+ * Interrupt service routine
+ */
+
+static irqreturn_t isr(int irq, void *priv)
+{
+	struct ixp_clock *ixp_clock = priv;
+	struct ixp46x_ts_regs *regs = ixp_clock->regs;
+	struct ptp_clock_event event;
+	u32 ack = 0, lo, hi, val;
+
+	val = ixp_read(&regs->Event);
+
+	if (val & TSER_SNS) {
+		ack |= TSER_SNS;
+		if (ixp_clock->exts0_enabled) {
+			hi = ixp_read(&regs->ASMSHi);
+			lo = ixp_read(&regs->ASMSLo);
+			event.type = PTP_CLOCK_EXTTS;
+			event.index = 0;
+			event.timestamp = ((u64) hi) << 32;
+			event.timestamp |= lo;
+			event.timestamp <<= TICKS_NS_SHIFT;
+			ptp_clock_event(ixp_clock->ptp_clock, &event);
+		}
+	}
+
+	if (val & TSER_SNM) {
+		ack |= TSER_SNM;
+		if (ixp_clock->exts1_enabled) {
+			hi = ixp_read(&regs->AMMSHi);
+			lo = ixp_read(&regs->AMMSLo);
+			event.type = PTP_CLOCK_EXTTS;
+			event.index = 1;
+			event.timestamp = ((u64) hi) << 32;
+			event.timestamp |= lo;
+			event.timestamp <<= TICKS_NS_SHIFT;
+			ptp_clock_event(ixp_clock->ptp_clock, &event);
+		}
+	}
+
+	if (val & TTIPEND)
+		ack |= TTIPEND; /* this bit seems to be always set */
+
+	if (ack) {
+		ixp_write(&regs->Event, ack);
+		return IRQ_HANDLED;
+	} else
+		return IRQ_NONE;
+}
+
+/*
+ * PTP clock operations
+ */
+
+static int ptp_ixp_adjfreq(void *priv, s32 ppb)
+{
+	u64 adj;
+	u32 diff, addend;
+	int neg_adj = 0;
+	struct ixp_clock *ixp_clock = priv;
+	struct ixp46x_ts_regs *regs = ixp_clock->regs;
+
+	if (!ppb)
+		return 0;
+
+	if (ppb < 0) {
+		neg_adj = 1;
+		ppb = -ppb;
+	}
+	addend = DEFAULT_ADDEND;
+	adj = addend;
+	adj *= ppb;
+	diff = div_u64(adj, 1000000000ULL);
+
+	addend = neg_adj ? addend - diff : addend + diff;
+
+	ixp_write(&regs->Addend, addend);
+
+	return 0;
+}
+
+static int ptp_ixp_adjtime(void *priv, struct timespec *ts)
+{
+	s64 delta, now;
+	unsigned long flags;
+	struct ixp_clock *ixp_clock = priv;
+	struct ixp46x_ts_regs *regs = ixp_clock->regs;
+
+	delta = 1000000000LL * ts->tv_sec;
+	delta += ts->tv_nsec;
+
+	spin_lock_irqsave(&register_lock, flags);
+
+	now = sys_time_read(regs);
+	now += delta;
+	sys_time_write(regs, now);
+
+	spin_unlock_irqrestore(&register_lock, flags);
+
+	return 0;
+}
+
+static int ptp_ixp_gettime(void *priv, struct timespec *ts)
+{
+	u64 ns;
+	u32 remainder;
+	unsigned long flags;
+	struct ixp_clock *ixp_clock = priv;
+	struct ixp46x_ts_regs *regs = ixp_clock->regs;
+
+	spin_lock_irqsave(&register_lock, flags);
+
+	ns = sys_time_read(regs);
+
+	spin_unlock_irqrestore(&register_lock, flags);
+
+	ts->tv_sec = div_u64_rem(ns, 1000000000, &remainder);
+	ts->tv_nsec = remainder;
+	return 0;
+}
+
+static int ptp_ixp_settime(void *priv, struct timespec *ts)
+{
+	u64 ns;
+	unsigned long flags;
+	struct ixp_clock *ixp_clock = priv;
+	struct ixp46x_ts_regs *regs = ixp_clock->regs;
+
+	ns = ts->tv_sec * 1000000000ULL;
+	ns += ts->tv_nsec;
+
+	spin_lock_irqsave(&register_lock, flags);
+
+	sys_time_write(regs, ns);
+
+	spin_unlock_irqrestore(&register_lock, flags);
+
+	return 0;
+}
+
+static int ptp_ixp_gettimer(void *priv, int index, struct itimerspec *ts)
+{
+	/* We do not offer any ancillary timer features. */
+	return -EOPNOTSUPP;
+}
+
+static int ptp_ixp_settimer(void *p, int i, int abs, struct itimerspec *ts)
+{
+	/* We do not offer any ancillary timer features. */
+	return -EOPNOTSUPP;
+}
+
+static int ptp_ixp_enable(void *priv, struct ptp_clock_request *rq, int on)
+{
+	struct ixp_clock *ixp_clock = priv;
+
+	switch (rq->type) {
+	case PTP_REQUEST_EXTTS:
+		switch (rq->index) {
+		case 0:
+			ixp_clock->exts0_enabled = on ? 1 : 0;
+			break;
+		case 1:
+			ixp_clock->exts1_enabled = on ? 1 : 0;
+			break;
+		default:
+			return -EINVAL;
+		}
+		return 0;
+	default:
+		break;
+	}
+
+	return -EOPNOTSUPP;
+}
+
+static struct ptp_clock_info ptp_ixp_caps = {
+	.owner		= THIS_MODULE,
+	.name		= "IXP46X timer",
+	.max_adj	= 66666655,
+	.n_ext_ts	= N_EXT_TS,
+	.pps		= 0,
+	.priv		= NULL,
+	.adjfreq	= ptp_ixp_adjfreq,
+	.adjtime	= ptp_ixp_adjtime,
+	.gettime	= ptp_ixp_gettime,
+	.settime	= ptp_ixp_settime,
+	.gettimer	= ptp_ixp_gettimer,
+	.settimer	= ptp_ixp_settimer,
+	.enable		= ptp_ixp_enable,
+};
+
+/* module operations */
+
+static struct ixp_clock ixp_clock;
+
+static int setup_interrupt(int gpio)
+{
+	int irq;
+
+	gpio_line_config(gpio, IXP4XX_GPIO_IN);
+
+	irq = gpio_to_irq(gpio);
+
+	if (NO_IRQ == irq)
+		return NO_IRQ;
+
+	if (set_irq_type(irq, IRQF_TRIGGER_FALLING)) {
+		pr_err("cannot set trigger type for irq %d\n", irq);
+		return NO_IRQ;
+	}
+
+	if (request_irq(irq, isr, 0, DRIVER, &ixp_clock)) {
+		pr_err("request_irq failed for irq %d\n", irq);
+		return NO_IRQ;
+	}
+
+	return irq;
+}
+
+static void __exit ptp_ixp_exit(void)
+{
+	free_irq(MASTER_IRQ, &ixp_clock);
+	free_irq(SLAVE_IRQ, &ixp_clock);
+	ptp_clock_unregister(ixp_clock.ptp_clock);
+}
+
+static int __init ptp_ixp_init(void)
+{
+	ixp_clock.regs = 
+		(struct ixp46x_ts_regs __iomem *)IXP4XX_TIMESYNC_BASE_VIRT;
+
+	ptp_ixp_caps.priv = &ixp_clock;
+
+	ixp_clock.ptp_clock = ptp_clock_register(&ptp_ixp_caps);
+
+	if (IS_ERR(ixp_clock.ptp_clock))
+		return PTR_ERR(ixp_clock.ptp_clock);
+
+	ixp_write(&ixp_clock.regs->Addend, DEFAULT_ADDEND);
+	ixp_write(&ixp_clock.regs->TrgtLo, 1);
+	ixp_write(&ixp_clock.regs->TrgtHi, 0);
+	ixp_write(&ixp_clock.regs->Event, TTIPEND);
+
+	if (MASTER_IRQ != setup_interrupt(MASTER_GPIO)) {
+		pr_err("failed to setup gpio %d as irq\n", MASTER_GPIO);
+		goto no_master;
+	}
+	if (SLAVE_IRQ != setup_interrupt(SLAVE_GPIO)) {
+		pr_err("failed to setup gpio %d as irq\n", SLAVE_GPIO);
+		goto no_slave;
+	}
+
+	return 0;
+no_slave:
+	free_irq(MASTER_IRQ, &ixp_clock);
+no_master:
+	ptp_clock_unregister(ixp_clock.ptp_clock);
+	return -ENODEV;
+}
+
+module_init(ptp_ixp_init);
+module_exit(ptp_ixp_exit);
+
+MODULE_AUTHOR("Richard Cochran <richard.cochran@omicron.at>");
+MODULE_DESCRIPTION("PTP clock using the IXP46X timer");
+MODULE_LICENSE("GPL");
-- 
1.7.0.4
