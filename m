From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 07/12] phylib: support the National Semiconductor DP83640
 PHY.
Date: Tue, 15 Jun 2010 18:09:15 +0200
Message-ID: <d51c259ce9de54e17953d49acb92a39f92ba13a1.1276615626.git.richard.cochran@omicron.at>
References: <cover.1276615626.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43726 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753676Ab0FOQIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 12:08:25 -0400
Received: by mail-fx0-f46.google.com with SMTP id 10so266600fxm.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 09:08:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1276615626.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a driver for the DP83640. This device is one of a new
generation of PHYs able to time stamp PTP packets.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/phy/Kconfig       |    5 +
 drivers/net/phy/Makefile      |    1 +
 drivers/net/phy/dp83640.c     |  439 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/dp83640_reg.h |  237 ++++++++++++++++++++++
 4 files changed, 682 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/phy/dp83640.c
 create mode 100644 drivers/net/phy/dp83640_reg.h

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index a527e37..430cab1 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -77,6 +77,11 @@ config NATIONAL_PHY
 	---help---
 	  Currently supports the DP83865 PHY.
 
+config DP83640_PHY
+	tristate "Driver for the National Semiconductor DP83640 PHYTER"
+	---help---
+	  Supports the DP83640 PHYTER with IEEE 1588 features.
+
 config STE10XP
 	depends on PHYLIB
 	tristate "Driver for STMicroelectronics STe10Xp PHYs"
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 13bebab..2333215 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -19,6 +19,7 @@ obj-$(CONFIG_FIXED_PHY)		+= fixed.o
 obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
 obj-$(CONFIG_MDIO_GPIO)		+= mdio-gpio.o
 obj-$(CONFIG_NATIONAL_PHY)	+= national.o
+obj-$(CONFIG_DP83640_PHY)	+= dp83640.o
 obj-$(CONFIG_STE10XP)		+= ste10Xp.o
 obj-$(CONFIG_MICREL_PHY)	+= micrel.o
 obj-$(CONFIG_MDIO_OCTEON)	+= mdio-octeon.o
diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
new file mode 100644
index 0000000..a3217ea
--- /dev/null
+++ b/drivers/net/phy/dp83640.c
@@ -0,0 +1,439 @@
+/*
+ * Driver for the National Semiconductor DP83640 PHYTER
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
+#include <linux/ethtool.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/mii.h>
+#include <linux/module.h>
+#include <linux/net_tstamp.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/ptp_classify.h>
+
+#include "dp83640_reg.h"
+
+#define DP83640_PHY_ID	0x20005ce1
+#define PAGESEL		0x13
+#define LAYER4		0x02
+#define LAYER2		0x01
+#define MAX_RXTS	8
+
+struct rxts {
+	struct list_head list;
+	u64 ns;
+	unsigned long tmo;
+	u16 seqid;
+	u8  msgtype;
+	u16 hash;
+};
+
+struct dp83640_private {
+	int hwts_tx_en;
+	int hwts_rx_en;
+	int layer;
+	int version;
+	/* protects extended registers from concurrent access */
+	spinlock_t extreg_lock;
+	int page;
+	/* list of rx timestamps */
+	struct list_head rxts;
+	struct list_head pool;
+	struct rxts pool_data[MAX_RXTS];
+};
+
+/* globals */
+
+static struct sock_filter ptp_filter[] = {
+	PTP_FILTER
+};
+
+/* extended register access functions */
+
+static int ext_read(struct phy_device *phydev, int page, u32 regnum)
+{
+	struct dp83640_private *dp83640 = phydev->priv;
+	int val;
+
+	spin_lock(&dp83640->extreg_lock);
+
+	if (dp83640->page != page) {
+		phy_write(phydev, PAGESEL, page);
+		dp83640->page = page;
+	}
+	val = phy_read(phydev, regnum);
+
+	spin_unlock(&dp83640->extreg_lock);
+
+	return val;
+}
+
+static void ext_write(struct phy_device *phydev, int page, u32 regnum, u16 val)
+{
+	struct dp83640_private *dp83640 = phydev->priv;
+
+	spin_lock(&dp83640->extreg_lock);
+
+	if (dp83640->page != page) {
+		phy_write(phydev, PAGESEL, page);
+		dp83640->page = page;
+	}
+	phy_write(phydev, regnum, val);
+
+	spin_unlock(&dp83640->extreg_lock);
+}
+
+static int expired(struct rxts *rxts)
+{
+	return time_after(jiffies, rxts->tmo);
+}
+
+static int match(struct sk_buff *skb, unsigned int type, struct rxts *rxts)
+{
+	u16 *seqid;
+	u8 *msgtype, *data = skb->data;
+
+	switch (type) {
+	case PTP_CLASS_V1_IPV4:
+		msgtype = data + 42 + 32;
+		seqid = (u16 *)(data + 42 + 30);
+		break;
+	case PTP_CLASS_V1_IPV6:
+		msgtype = data + 62 + 32;
+		seqid = (u16 *)(data + 62 + 30);
+		break;
+	case PTP_CLASS_V2_IPV4:
+		msgtype = data + 42 + 0;
+		seqid = (u16 *)(data + 42 + 30);
+		break;
+	case PTP_CLASS_V2_IPV6:
+		msgtype = data + 62 + 0;
+		seqid = (u16 *)(data + 62 + 30);
+		break;
+	case PTP_CLASS_V2_L2:
+		msgtype = data + 14 + 0;
+		seqid = (u16 *)(data + 14 + 30);
+		break;
+	case PTP_CLASS_V2_VLAN:
+		msgtype = data + 18 + 0;
+		seqid = (u16 *)(data + 18 + 30);
+		break;
+	default:
+		return 0;
+	}
+
+	return ((*msgtype & 0xf) == rxts->msgtype && *seqid == rxts->seqid);
+}
+
+static int dp83640_probe(struct phy_device *phydev)
+{
+	struct dp83640_private *dp83640;
+	int i;
+
+	if (sk_chk_filter(ptp_filter, ARRAY_SIZE(ptp_filter))) {
+		pr_err("dp83640: bad ptp filter\n");
+		return -EINVAL;
+	}
+
+	dp83640 = kzalloc(sizeof(struct dp83640_private), GFP_KERNEL);
+	if (!dp83640)
+		return -ENOMEM;
+
+	spin_lock_init(&dp83640->extreg_lock);
+
+	INIT_LIST_HEAD(&dp83640->rxts);
+	INIT_LIST_HEAD(&dp83640->pool);
+
+	for (i = 0; i < MAX_RXTS; i++)
+		list_add(&dp83640->pool_data[i].list, &dp83640->pool);
+
+	phydev->priv = dp83640;
+
+	return 0;
+}
+
+static void dp83640_remove(struct phy_device *phydev)
+{
+	struct dp83640_private *dp83640 = phydev->priv;
+	kfree(dp83640);
+}
+
+static int dp83640_hwtstamp(struct phy_device *phydev, struct ifreq *ifr)
+{
+	struct dp83640_private *dp83640 = phydev->priv;
+	struct hwtstamp_config cfg;
+	u16 txcfg0, rxcfg0;
+
+	if (phydev->bus->locktype != MDIOBUS_ATOMIC_RW)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&cfg, ifr->ifr_data, sizeof(cfg)))
+		return -EFAULT;
+
+	if (cfg.flags) /* reserved for future extensions */
+		return -EINVAL;
+
+	switch (cfg.tx_type) {
+	case HWTSTAMP_TX_OFF:
+		dp83640->hwts_tx_en = 0;
+		break;
+	case HWTSTAMP_TX_ON:
+		dp83640->hwts_tx_en = 1;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (cfg.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		dp83640->hwts_rx_en = 0;
+		dp83640->layer = 0;
+		dp83640->version = 0;
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+		dp83640->hwts_rx_en = 1;
+		dp83640->layer = LAYER4;
+		dp83640->version = 1;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+		dp83640->hwts_rx_en = 1;
+		dp83640->layer = LAYER4;
+		dp83640->version = 2;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+		dp83640->hwts_rx_en = 1;
+		dp83640->layer = LAYER2;
+		dp83640->version = 2;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		dp83640->hwts_rx_en = 1;
+		dp83640->layer = LAYER4|LAYER2;
+		dp83640->version = 2;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	txcfg0 = (dp83640->version & TX_PTP_VER_MASK) << TX_PTP_VER_SHIFT;
+	rxcfg0 = (dp83640->version & TX_PTP_VER_MASK) << TX_PTP_VER_SHIFT;
+
+	if (dp83640->layer & LAYER2) {
+		txcfg0 |= TX_L2_EN;
+		rxcfg0 |= RX_L2_EN;
+	}
+	if (dp83640->layer & LAYER4) {
+		txcfg0 |= TX_IPV6_EN | TX_IPV4_EN;
+		rxcfg0 |= RX_IPV6_EN | RX_IPV4_EN;
+	}
+
+	if (dp83640->hwts_tx_en)
+		txcfg0 |= TX_TS_EN;
+
+	if (dp83640->hwts_rx_en)
+		rxcfg0 |= RX_TS_EN;
+
+	if (dp83640->hwts_tx_en || dp83640->hwts_rx_en)
+		ext_write(phydev, PAGE4, PTP_CTL, PTP_ENABLE);
+
+	ext_write(phydev, PAGE5, PTP_TXCFG0, txcfg0);
+	ext_write(phydev, PAGE5, PTP_RXCFG0, rxcfg0);
+
+	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
+}
+
+static void read_rxts(struct phy_device *phydev, struct rxts *rxts)
+{
+	u64 ns;
+	int overflow, sec, val;
+	u16 hash, seq;
+	u8 msgtype;
+
+	val = ext_read(phydev, PAGE4, PTP_RXTS); /* ns[15:0] */
+	ns = val;
+
+	val = ext_read(phydev, PAGE4, PTP_RXTS); /* overflow[1:0], ns[29:16] */
+	overflow = val >> 14;
+	ns |= (val & 0x3fff) << 16;
+
+	val = ext_read(phydev, PAGE4, PTP_RXTS); /* sec[15:0] */
+	sec = val;
+
+	val = ext_read(phydev, PAGE4, PTP_RXTS); /* sec[31:16] */
+	sec |= val << 16;
+
+	seq = ext_read(phydev, PAGE4, PTP_RXTS); /* sequenceId[15:0] */
+	val = ext_read(phydev, PAGE4, PTP_RXTS); /* messageType[3:0], hash[11:0] */
+	msgtype = (val >> 12) & 0xf;
+	hash = val & 0x0fff;
+	ns += ((u64)sec) * 1000000000ULL;
+
+	rxts->ns = ns;
+	rxts->tmo = jiffies + HZ;
+	rxts->seqid = seq;
+	rxts->msgtype = msgtype;
+	rxts->hash = hash;
+}
+
+static int dp83640_rxtstamp(struct phy_device *phydev, struct sk_buff *skb)
+{
+	struct dp83640_private *dp83640 = phydev->priv;
+	struct skb_shared_hwtstamps *shhwtstamps;
+	struct list_head *this, *next;
+	struct rxts *rxts;
+	unsigned int type;
+	int val;
+
+	if (!dp83640->hwts_rx_en)
+		return -1;
+
+	for (;;) {
+		val = ext_read(phydev, PAGE4, PTP_STS);
+		if (!(val & RXTS_RDY))
+			break;
+
+		if (list_empty(&dp83640->pool)) {
+			pr_warning("dp83640: rx timestamp pool is empty\n");
+			break;
+		}
+
+		rxts = list_first_entry(&dp83640->pool, struct rxts, list);
+		list_del_init(&rxts->list);
+		read_rxts(phydev, rxts);
+		list_add_tail(&rxts->list, &dp83640->rxts);
+	}
+
+	type = sk_run_filter(skb, ptp_filter, ARRAY_SIZE(ptp_filter));
+
+	list_for_each_safe(this, next, &dp83640->rxts) {
+
+		rxts = list_entry(this, struct rxts, list);
+
+		/* check sequenceID, messageType, 12 bit hash of offset 20-29 */
+
+		if (match(skb, type, rxts)) {
+			shhwtstamps = skb_hwtstamps(skb);
+			memset(shhwtstamps, 0, sizeof(*shhwtstamps));
+			shhwtstamps->hwtstamp = ns_to_ktime(rxts->ns);
+			list_del_init(&rxts->list);
+			list_add(&rxts->list, &dp83640->pool);
+			return 0;
+		}
+		if (expired(rxts)) {
+			list_del_init(&rxts->list);
+			list_add(&rxts->list, &dp83640->pool);
+		}
+	}
+
+	return -1;
+}
+
+static int dp83640_txtstamp(struct phy_device *phydev, struct sk_buff *skb)
+{
+	struct dp83640_private *dp83640 = phydev->priv;
+	struct skb_shared_hwtstamps shhwtstamps;
+	union skb_shared_tx *shtx;
+	u64 ns;
+	int cnt, overflow, sec, val;
+
+	if (!dp83640->hwts_tx_en)
+		return -1;
+
+	/*
+	 * This really stinks, but we have to poll for the Tx time stamp.
+	 */
+	for (cnt = 0; cnt < 100; cnt++) {
+		val = ext_read(phydev, PAGE4, PTP_STS);
+		if (val & TXTS_RDY)
+			break;
+		udelay(1);
+	}
+	if (!(val & TXTS_RDY))
+		return -1;
+
+	val = ext_read(phydev, PAGE4, PTP_TXTS); /* ns[15:0] */
+	ns = val;
+
+	val = ext_read(phydev, PAGE4, PTP_TXTS); /* overflow[1:0], ns[29:16] */
+	overflow = val >> 14;
+	ns |= (val & 0x3fff) << 16;
+
+	val = ext_read(phydev, PAGE4, PTP_TXTS); /* sec[15:0] */
+	sec = val;
+
+	val = ext_read(phydev, PAGE4, PTP_TXTS); /* sec[31:16] */
+	sec |= val << 16;
+
+	ns += ((u64)sec) * 1000000000ULL;
+
+	shtx = skb_tx(skb);
+	shtx->in_progress = 1;
+	memset(&shhwtstamps, 0, sizeof(shhwtstamps));
+	shhwtstamps.hwtstamp = ns_to_ktime(ns);
+	skb_tstamp_tx(skb, &shhwtstamps);
+
+	return 0;
+}
+
+static struct phy_driver dp83640_driver = {
+	.phy_id		= DP83640_PHY_ID,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "NatSemi DP83640",
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= 0,
+	.probe		= dp83640_probe,
+	.remove		= dp83640_remove,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.hwtstamp	= dp83640_hwtstamp,
+	.rxtstamp	= dp83640_rxtstamp,
+	.txtstamp	= dp83640_txtstamp,
+	.driver		= {.owner = THIS_MODULE,}
+};
+
+static int __init dp83640_init(void)
+{
+	return phy_driver_register(&dp83640_driver);
+}
+
+static void __exit dp83640_exit(void)
+{
+	phy_driver_unregister(&dp83640_driver);
+}
+
+MODULE_DESCRIPTION("National Semiconductor DP83640 PHY driver");
+MODULE_AUTHOR("Richard Cochran <richard.cochran@omicron.at>");
+MODULE_LICENSE("GPL");
+
+module_init(dp83640_init);
+module_exit(dp83640_exit);
+
+static struct mdio_device_id dp83640_tbl[] = {
+	{ DP83640_PHY_ID, 0xfffffff0 },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(mdio, dp83640_tbl);
diff --git a/drivers/net/phy/dp83640_reg.h b/drivers/net/phy/dp83640_reg.h
new file mode 100644
index 0000000..349fdbc
--- /dev/null
+++ b/drivers/net/phy/dp83640_reg.h
@@ -0,0 +1,237 @@
+/* dp83640_reg.h
+ * Generated by regen.tcl on Wed Jun 02 07:11:36 AM CEST 2010
+ */
+#ifndef HAVE_DP83640_REGISTERS
+#define HAVE_DP83640_REGISTERS
+
+#define PAGE4                     0x0004
+#define PTP_CTL                   0x0014 /* PTP Control Register */
+#define PTP_TDR                   0x0015 /* PTP Time Data Register */
+#define PTP_STS                   0x0016 /* PTP Status Register */
+#define PTP_TSTS                  0x0017 /* PTP Trigger Status Register */
+#define PTP_RATEL                 0x0018 /* PTP Rate Low Register */
+#define PTP_RATEH                 0x0019 /* PTP Rate High Register */
+#define PTP_RDCKSUM               0x001a /* PTP Read Checksum */
+#define PTP_WRCKSUM               0x001b /* PTP Write Checksum */
+#define PTP_TXTS                  0x001c /* PTP Transmit Timestamp Register, in four 16-bit reads */
+#define PTP_RXTS                  0x001d /* PTP Receive Timestamp Register, in six? 16-bit reads */
+#define PTP_ESTS                  0x001e /* PTP Event Status Register */
+#define PTP_EDATA                 0x001f /* PTP Event Data Register */
+
+#define PAGE5                     0x0005
+#define PTP_TRIG                  0x0014 /* PTP Trigger Configuration Register */
+#define PTP_EVNT                  0x0015 /* PTP Event Configuration Register */
+#define PTP_TXCFG0                0x0016 /* PTP Transmit Configuration Register 0 */
+#define PTP_TXCFG1                0x0017 /* PTP Transmit Configuration Register 1 */
+#define PSF_CFG0                  0x0018 /* PHY Status Frame Configuration Register 0 */
+#define PTP_RXCFG0                0x0019 /* PTP Receive Configuration Register 0 */
+#define PTP_RXCFG1                0x001a /* PTP Receive Configuration Register 1 */
+#define PTP_RXCFG2                0x001b /* PTP Receive Configuration Register 2 */
+#define PTP_RXCFG3                0x001c /* PTP Receive Configuration Register 3 */
+#define PTP_RXCFG4                0x001d /* PTP Receive Configuration Register 4 */
+#define PTP_TRDL                  0x001e /* PTP Temporary Rate Duration Low Register */
+#define PTP_TRDH                  0x001f /* PTP Temporary Rate Duration High Register */
+
+#define PAGE6                     0x0006
+#define PTP_COC                   0x0014 /* PTP Clock Output Control Register */
+#define PSF_CFG1                  0x0015 /* PHY Status Frame Configuration Register 1 */
+#define PSF_CFG2                  0x0016 /* PHY Status Frame Configuration Register 2 */
+#define PSF_CFG3                  0x0017 /* PHY Status Frame Configuration Register 3 */
+#define PSF_CFG4                  0x0018 /* PHY Status Frame Configuration Register 4 */
+#define PTP_SFDCFG                0x0019 /* PTP SFD Configuration Register */
+#define PTP_INTCTL                0x001a /* PTP Interrupt Control Register */
+#define PTP_CLKSRC                0x001b /* PTP Clock Source Register */
+#define PTP_ETR                   0x001c /* PTP Ethernet Type Register */
+#define PTP_OFF                   0x001d /* PTP Offset Register */
+#define PTP_GPIOMON               0x001e /* PTP GPIO Monitor Register */
+#define PTP_RXHASH                0x001f /* PTP Receive Hash Register */
+
+/* Bit definitions for the PTP_CTL register */
+#define TRIG_SEL_SHIFT            (10) /* PTP Trigger Select */
+#define TRIG_SEL_MASK             (0x7)
+#define TRIG_DIS                  (1<<9) /* Disable PTP Trigger */
+#define TRIG_EN                   (1<<8) /* Enable PTP Trigger */
+#define TRIG_READ                 (1<<7) /* Read PTP Trigger */
+#define TRIG_LOAD                 (1<<6) /* Load PTP Trigger */
+#define PTP_RD_CLK                (1<<5) /* Read PTP Clock */
+#define PTP_LOAD_CLK              (1<<4) /* Load PTP Clock */
+#define PTP_STEP_CLK              (1<<3) /* Step PTP Clock */
+#define PTP_ENABLE                (1<<2) /* Enable PTP Clock */
+#define PTP_DISABLE               (1<<1) /* Disable PTP Clock */
+#define PTP_RESET                 (1<<0) /* Reset PTP Clock */
+
+/* Bit definitions for the PTP_STS register */
+#define TXTS_RDY                  (1<<11) /* Transmit Timestamp Ready */
+#define RXTS_RDY                  (1<<10) /* Receive Timestamp Ready */
+#define TRIG_DONE                 (1<<9) /* PTP Trigger Done */
+#define EVENT_RDY                 (1<<8) /* PTP Event Timestamp Ready */
+#define TXTS_IE                   (1<<3) /* Transmit Timestamp Interrupt Enable */
+#define RXTS_IE                   (1<<2) /* Receive Timestamp Interrupt Enable */
+#define TRIG_IE                   (1<<1) /* Trigger Interrupt Enable */
+#define EVENT_IE                  (1<<0) /* Event Interrupt Enable */
+
+/* Bit definitions for the PTP_TSTS register */
+#define TRIG7_ERROR               (1<<15) /* Trigger 7 Error */
+#define TRIG7_ACTIVE              (1<<14) /* Trigger 7 Active */
+#define TRIG6_ERROR               (1<<13) /* Trigger 6 Error */
+#define TRIG6_ACTIVE              (1<<12) /* Trigger 6 Active */
+#define TRIG5_ERROR               (1<<11) /* Trigger 5 Error */
+#define TRIG5_ACTIVE              (1<<10) /* Trigger 5 Active */
+#define TRIG4_ERROR               (1<<9) /* Trigger 4 Error */
+#define TRIG4_ACTIVE              (1<<8) /* Trigger 4 Active */
+#define TRIG3_ERROR               (1<<7) /* Trigger 3 Error */
+#define TRIG3_ACTIVE              (1<<6) /* Trigger 3 Active */
+#define TRIG2_ERROR               (1<<5) /* Trigger 2 Error */
+#define TRIG2_ACTIVE              (1<<4) /* Trigger 2 Active */
+#define TRIG1_ERROR               (1<<3) /* Trigger 1 Error */
+#define TRIG1_ACTIVE              (1<<2) /* Trigger 1 Active */
+#define TRIG0_ERROR               (1<<1) /* Trigger 0 Error */
+#define TRIG0_ACTIVE              (1<<0) /* Trigger 0 Active */
+
+/* Bit definitions for the PTP_RATEH register */
+#define PTP_RATE_DIR              (1<<15) /* PTP Rate Direction */
+#define PTP_TMP_RATE              (1<<14) /* PTP Temporary Rate */
+#define PTP_RATE_HI_SHIFT         (0) /* PTP Rate High 10-bits */
+#define PTP_RATE_HI_MASK          (0x3ff)
+
+/* Bit definitions for the PTP_ESTS register */
+#define EVNTS_MISSED_SHIFT        (8) /* Indicates number of events missed */
+#define EVNTS_MISSED_MASK         (0x7)
+#define EVNT_TS_LEN_SHIFT         (6) /* Indicates length of the Timestamp field in 16-bit words minus 1 */
+#define EVNT_TS_LEN_MASK          (0x3)
+#define EVNT_RF                   (1<<5) /* Indicates whether the event is a rise or falling event */
+#define EVNT_NUM_SHIFT            (2) /* Indicates Event Timestamp Unit which detected an event */
+#define EVNT_NUM_MASK             (0x7)
+#define MULT_EVNT                 (1<<1) /* Indicates multiple events were detected at the same time */
+#define EVENT_DET                 (1<<0) /* PTP Event Detected */
+
+/* Bit definitions for the PTP_EDATA register */
+#define E7_RISE                   (1<<15) /* Indicates direction of Event 7 */
+#define E7_DET                    (1<<14) /* Indicates Event 7 detected */
+#define E6_RISE                   (1<<13) /* Indicates direction of Event 6 */
+#define E6_DET                    (1<<12) /* Indicates Event 6 detected */
+#define E5_RISE                   (1<<11) /* Indicates direction of Event 5 */
+#define E5_DET                    (1<<10) /* Indicates Event 5 detected */
+#define E4_RISE                   (1<<9) /* Indicates direction of Event 4 */
+#define E4_DET                    (1<<8) /* Indicates Event 4 detected */
+#define E3_RISE                   (1<<7) /* Indicates direction of Event 3 */
+#define E3_DET                    (1<<6) /* Indicates Event 3 detected */
+#define E2_RISE                   (1<<5) /* Indicates direction of Event 2 */
+#define E2_DET                    (1<<4) /* Indicates Event 2 detected */
+#define E1_RISE                   (1<<3) /* Indicates direction of Event 1 */
+#define E1_DET                    (1<<2) /* Indicates Event 1 detected */
+#define E0_RISE                   (1<<1) /* Indicates direction of Event 0 */
+#define E0_DET                    (1<<0) /* Indicates Event 0 detected */
+
+/* Bit definitions for the PTP_TRIG register */
+#define TRIG_PULSE                (1<<15) /* generate a Pulse rather than a single edge */
+#define TRIG_PER                  (1<<14) /* generate a periodic signal */
+#define TRIG_IF_LATE              (1<<13) /* trigger immediately if already past */
+#define TRIG_NOTIFY               (1<<12) /* Trigger Notification Enable */
+#define TRIG_GPIO_SHIFT           (8) /* Trigger GPIO Connection, value 1-12 */
+#define TRIG_GPIO_MASK            (0xf)
+#define TRIG_TOGGLE               (1<<7) /* Trigger Toggle Mode Enable */
+#define TRIG_CSEL_SHIFT           (1) /* Trigger Configuration Select */
+#define TRIG_CSEL_MASK            (0x7)
+#define TRIG_WR                   (1<<0) /* Trigger Configuration Write */
+
+/* Bit definitions for the PTP_EVNT register */
+#define EVNT_RISE                 (1<<14) /* Event Rise Detect Enable */
+#define EVNT_FALL                 (1<<13) /* Event Fall Detect Enable */
+#define EVNT_SINGLE               (1<<12) /* enable single event capture operation */
+#define EVNT_GPIO_SHIFT           (8) /* Event GPIO Connection, value 1-12 */
+#define EVNT_GPIO_MASK            (0xf)
+#define EVNT_SEL_SHIFT            (1) /* Event Select */
+#define EVNT_SEL_MASK             (0x7)
+#define EVNT_WR                   (1<<0) /* Event Configuration Write */
+
+/* Bit definitions for the PTP_TXCFG0 register */
+#define SYNC_1STEP                (1<<15) /* insert timestamp into transmit Sync Messages */
+#define DR_INSERT                 (1<<13) /* Insert Delay_Req Timestamp in Delay_Resp (dangerous) */
+#define NTP_TS_EN                 (1<<12) /* Enable Timestamping of NTP Packets */
+#define IGNORE_2STEP              (1<<11) /* Ignore Two_Step flag for One-Step operation */
+#define CRC_1STEP                 (1<<10) /* Disable checking of CRC for One-Step operation */
+#define CHK_1STEP                 (1<<9) /* Enable UDP Checksum correction for One-Step Operation */
+#define IP1588_EN                 (1<<8) /* Enable IEEE 1588 defined IP address filter */
+#define TX_L2_EN                  (1<<7) /* Layer2 Timestamp Enable */
+#define TX_IPV6_EN                (1<<6) /* IPv6 Timestamp Enable */
+#define TX_IPV4_EN                (1<<5) /* IPv4 Timestamp Enable */
+#define TX_PTP_VER_SHIFT          (1) /* Enable Timestamp capture for IEEE 1588 version X */
+#define TX_PTP_VER_MASK           (0xf)
+#define TX_TS_EN                  (1<<0) /* Transmit Timestamp Enable */
+
+/* Bit definitions for the PTP_TXCFG1 register */
+#define BYTE0_MASK_SHIFT          (8) /* Bit mask to be used for matching Byte0 of the PTP Message */
+#define BYTE0_MASK_MASK           (0xff)
+#define BYTE0_DATA_SHIFT          (0) /* Data to be used for matching Byte0 of the PTP Message */
+#define BYTE0_DATA_MASK           (0xff)
+
+/* Bit definitions for the PTP_RXCFG0 register */
+#define DOMAIN_EN                 (1<<15) /* Domain Match Enable */
+#define ALT_MAST_DIS              (1<<14) /* Alternate Master Timestamp Disable */
+#define USER_IP_SEL               (1<<13) /* Selects portion of IP address accessible thru PTP_RXCFG2 */
+#define USER_IP_EN                (1<<12) /* Enable User-programmed IP address filter */
+#define RX_SLAVE                  (1<<11) /* Receive Slave Only */
+#define IP1588_EN_SHIFT           (8) /* Enable IEEE 1588 defined IP address filters */
+#define IP1588_EN_MASK            (0xf)
+#define RX_L2_EN                  (1<<7) /* Layer2 Timestamp Enable */
+#define RX_IPV6_EN                (1<<6) /* IPv6 Timestamp Enable */
+#define RX_IPV4_EN                (1<<5) /* IPv4 Timestamp Enable */
+#define RX_PTP_VER_SHIFT          (1) /* Enable Timestamp capture for IEEE 1588 version X */
+#define RX_PTP_VER_MASK           (0xf)
+#define RX_TS_EN                  (1<<0) /* Receive Timestamp Enable */
+
+/* Bit definitions for the PTP_RXCFG1 register */
+#define BYTE0_MASK_SHIFT          (8) /* Bit mask to be used for matching Byte0 of the PTP Message */
+#define BYTE0_MASK_MASK           (0xff)
+#define BYTE0_DATA_SHIFT          (0) /* Data to be used for matching Byte0 of the PTP Message */
+#define BYTE0_DATA_MASK           (0xff)
+
+/* Bit definitions for the PTP_RXCFG3 register */
+#define TS_MIN_IFG_SHIFT          (12) /* Minimum Inter-frame Gap */
+#define TS_MIN_IFG_MASK           (0xf)
+#define ACC_UDP                   (1<<11) /* Record Timestamp if UDP Checksum Error */
+#define ACC_CRC                   (1<<10) /* Record Timestamp if CRC Error */
+#define TS_APPEND                 (1<<9) /* Append Timestamp for L2 */
+#define TS_INSERT                 (1<<8) /* Enable Timestamp Insertion */
+#define PTP_DOMAIN_SHIFT          (0) /* PTP Message domainNumber field */
+#define PTP_DOMAIN_MASK           (0xff)
+
+/* Bit definitions for the PTP_RXCFG4 register */
+#define IPV4_UDP_MOD              (1<<15) /* Enable IPV4 UDP Modification */
+#define TS_SEC_EN                 (1<<14) /* Enable Timestamp Seconds */
+#define TS_SEC_LEN_SHIFT          (12) /* Inserted Timestamp Seconds Length */
+#define TS_SEC_LEN_MASK           (0x3)
+#define RXTS_NS_OFF_SHIFT         (6) /* Receive Timestamp Nanoseconds offset */
+#define RXTS_NS_OFF_MASK          (0x3f)
+#define RXTS_SEC_OFF_SHIFT        (0) /* Receive Timestamp Seconds offset */
+#define RXTS_SEC_OFF_MASK         (0x3f)
+
+/* Bit definitions for the PTP_COC register */
+#define PTP_CLKOUT_EN             (1<<15) /* PTP Clock Output Enable */
+#define PTP_CLKOUT_SEL            (1<<14) /* PTP Clock Output Source Select */
+#define PTP_CLKOUT_SPEEDSEL       (1<<13) /* PTP Clock Output I/O Speed Select */
+#define PTP_CLKDIV_SHIFT          (0) /* PTP Clock Divide-by Value */
+#define PTP_CLKDIV_MASK           (0xff)
+
+/* Bit definitions for the PTP_SFDCFG register */
+#define TX_SFD_GPIO_SHIFT         (4) /* TX SFD GPIO Select, value 1-12 */
+#define TX_SFD_GPIO_MASK          (0xf)
+#define RX_SFD_GPIO_SHIFT         (0) /* RX SFD GPIO Select, value 1-12 */
+#define RX_SFD_GPIO_MASK          (0xf)
+
+/* Bit definitions for the PTP_INTCTL register */
+#define PTP_INT_GPIO_SHIFT        (0) /* PTP Interrupt GPIO Select */
+#define PTP_INT_GPIO_MASK         (0xf)
+
+/* Bit definitions for the PTP_CLKSRC register */
+#define CLK_SRC_SHIFT             (14) /* PTP Clock Source Select */
+#define CLK_SRC_MASK              (0x3)
+#define CLK_SRC_PER_SHIFT         (0) /* PTP Clock Source Period */
+#define CLK_SRC_PER_MASK          (0x7f)
+
+/* Bit definitions for the PTP_OFF register */
+#define PTP_OFFSET_SHIFT          (0) /* PTP Message offset from preceding header */
+#define PTP_OFFSET_MASK           (0xff)
+
+#endif
-- 
1.6.3.3

